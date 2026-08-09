class_name CouncilRecruitmentManager
extends RefCounted


const STATE_VERSION: int = 3
const OFFER_DAYS: Array[int] = [20, 40, 60, 80, 100, 120]
const CANDIDATE_COUNT: int = 2
# Uma avaliação aprovada garante a oferta. O vínculo continua escolhendo a
# origem e a espécie, mas não pode bloquear o calendário de recrutamentos.
const RELATIONSHIP_REQUIREMENTS: Dictionary = {
	20: 0,
	40: 0,
	60: 0,
	80: 0,
	100: 0,
	120: 0
}

const CARD_CATALOG_SCRIPT = preload(
	"res://scripts/council/CouncilCardCatalog.gd"
)
const PERSONALITY_CATALOG_SCRIPT = preload(
	"res://scripts/council/CouncillorPersonalityCatalog.gd"
)


var used_source_npc_ids: Array[String] = []
var completed_offer_days: Array[int] = []
var pending_checkpoint_days: Array[int] = []
var pending_offer: Dictionary = {}
var next_recruit_sequence: int = 1
var last_requirement_status: Dictionary = {}
var legacy_offer_needs_reconciliation: bool = false


func setup() -> void:
	used_source_npc_ids.clear()
	completed_offer_days.clear()
	pending_checkpoint_days.clear()
	pending_offer.clear()
	next_recruit_sequence = 1
	legacy_offer_needs_reconciliation = false
	last_requirement_status = _build_waiting_status()


func register_checkpoint(checkpoint_day: int) -> bool:
	if not OFFER_DAYS.has(checkpoint_day):
		return false
	if completed_offer_days.has(checkpoint_day):
		return false
	if pending_checkpoint_days.has(checkpoint_day):
		return false
	pending_checkpoint_days.append(checkpoint_day)
	pending_checkpoint_days.sort()
	return true


func prepare_offer(
	triggered_checkpoint_day: int,
	campaign_seed: int,
	relationship_entries: Array,
	npc_overviews: Dictionary,
	existing_names: Array[String],
	existing_passive_ids: Array[String]
) -> Dictionary:
	if triggered_checkpoint_day > 0:
		register_checkpoint(triggered_checkpoint_day)
	if not pending_offer.is_empty():
		return pending_offer.duplicate(true)
	if pending_checkpoint_days.is_empty():
		last_requirement_status = _build_waiting_status()
		return {}

	var checkpoint_day: int = pending_checkpoint_days[0]
	var required_points: int = get_relationship_requirement(checkpoint_day)
	var source_rows: Array[Dictionary] = _build_source_rows(
		relationship_entries,
		npc_overviews
	)
	if source_rows.is_empty():
		last_requirement_status = _build_blocked_status(
			checkpoint_day,
			required_points,
			{},
			"Nenhum vínculo conhecido possui cartas disponíveis para recrutamento."
		)
		return {}

	source_rows.sort_custom(_sort_source_rows)
	var best_source: Dictionary = source_rows[0]
	var eligible_rows: Array[Dictionary] = source_rows.duplicate(true)

	eligible_rows.sort_custom(_sort_source_rows)
	var highest_points: int = int(
		eligible_rows[0].get("relationship_points", 0)
	)
	var species_options: Array[Dictionary] = []
	var included_species: Array[String] = []
	for source: Dictionary in eligible_rows:
		if int(source.get("relationship_points", 0)) != highest_points:
			break
		var species_name: String = String(source.get("species_name", ""))
		if species_name.is_empty() or included_species.has(species_name):
			continue
		included_species.append(species_name)
		species_options.append(source.duplicate(true))

	if species_options.is_empty():
		last_requirement_status = _build_blocked_status(
			checkpoint_day,
			required_points,
			best_source,
			"Não foi possível identificar uma espécie válida para a oferta."
		)
		return {}

	pending_offer = {
		"phase": "species_choice" if species_options.size() > 1 else "candidate_choice",
		"checkpoint_day": checkpoint_day,
		"required_relationship_points": required_points,
		"species_options": species_options.duplicate(true),
		"source_npc_id": "",
		"source_name": "",
		"species_name": "",
		"relationship_points": highest_points,
		"relationship_level": int(species_options[0].get("relationship_level", 0)),
		"candidates": []
	}

	if species_options.size() == 1:
		if not _activate_species_option(
			species_options[0],
			campaign_seed,
			existing_names,
			existing_passive_ids
		):
			pending_offer.clear()
			last_requirement_status = _build_blocked_status(
				checkpoint_day,
				required_points,
				best_source,
				"A espécie elegível não possui conteúdo suficiente para gerar duas cartas."
			)
			return {}
	else:
		last_requirement_status = _build_ready_status(
			checkpoint_day,
			required_points,
			"species_choice",
			highest_points,
			"",
			""
		)

	return pending_offer.duplicate(true)


func select_species(
	species_name: String,
	campaign_seed: int,
	existing_names: Array[String],
	existing_passive_ids: Array[String]
) -> Dictionary:
	if String(pending_offer.get("phase", "")) != "species_choice":
		return {}
	var clean_species: String = species_name.strip_edges()
	if clean_species.is_empty():
		return {}
	var options_value: Variant = pending_offer.get("species_options", [])
	if not options_value is Array:
		return {}
	for option_value: Variant in options_value as Array:
		if not option_value is Dictionary:
			continue
		var option: Dictionary = option_value as Dictionary
		if String(option.get("species_name", "")) != clean_species:
			continue
		if not _activate_species_option(
			option,
			campaign_seed,
			existing_names,
			existing_passive_ids
		):
			return {}
		return pending_offer.duplicate(true)
	return {}


func has_pending_offer() -> bool:
	return not pending_offer.is_empty()


func get_pending_offer() -> Dictionary:
	return pending_offer.duplicate(true)


func get_pending_checkpoint_days() -> Array[int]:
	return pending_checkpoint_days.duplicate()


func get_overview(current_day: int = 1) -> Dictionary:
	var status: Dictionary = last_requirement_status.duplicate(true)
	status["completed_offer_days"] = completed_offer_days.duplicate()
	status["pending_checkpoint_days"] = pending_checkpoint_days.duplicate()
	status["completed_count"] = completed_offer_days.size()
	status["total_count"] = OFFER_DAYS.size()
	status["has_pending_offer"] = not pending_offer.is_empty()
	status["current_day"] = maxi(1, current_day)
	status["next_locked_checkpoint_day"] = _get_next_locked_checkpoint_day()
	status["pending_count"] = pending_checkpoint_days.size()
	status["offered_count"] = 1 if not pending_offer.is_empty() else 0
	status["future_count"] = maxi(
		0,
		OFFER_DAYS.size()
		- completed_offer_days.size()
		- pending_checkpoint_days.size()
	)
	if not pending_offer.is_empty():
		status["phase"] = String(pending_offer.get("phase", "candidate_choice"))
		status["checkpoint_day"] = int(pending_offer.get("checkpoint_day", 0))
		status["required_relationship_points"] = int(
			pending_offer.get("required_relationship_points", 0)
		)
	return status


func accept_candidate(candidate_id: String) -> Dictionary:
	var clean_id: String = candidate_id.strip_edges()
	if clean_id.is_empty() or pending_offer.is_empty():
		return {}
	if String(pending_offer.get("phase", "")) != "candidate_choice":
		return {}
	var candidates_value: Variant = pending_offer.get("candidates", [])
	if not candidates_value is Array:
		return {}
	for candidate_value: Variant in candidates_value as Array:
		if not candidate_value is Dictionary:
			continue
		var candidate: Dictionary = candidate_value as Dictionary
		if String(candidate.get("representative_id", "")) == clean_id:
			return candidate.duplicate(true)
	return {}


func complete_offer(candidate_id: String) -> bool:
	if accept_candidate(candidate_id).is_empty():
		return false
	var checkpoint_day: int = int(pending_offer.get("checkpoint_day", 0))
	pending_checkpoint_days.erase(checkpoint_day)
	if OFFER_DAYS.has(checkpoint_day) and not completed_offer_days.has(checkpoint_day):
		completed_offer_days.append(checkpoint_day)
		completed_offer_days.sort()
	pending_offer.clear()
	last_requirement_status = _build_waiting_status()
	return true


func export_save_data() -> Dictionary:
	return {
		"state_version": STATE_VERSION,
		"used_source_npc_ids": used_source_npc_ids.duplicate(),
		"completed_offer_days": completed_offer_days.duplicate(),
		"pending_checkpoint_days": pending_checkpoint_days.duplicate(),
		"pending_offer": pending_offer.duplicate(true),
		"next_recruit_sequence": next_recruit_sequence,
		"last_requirement_status": last_requirement_status.duplicate(true)
	}


func import_save_data(save_data: Dictionary) -> bool:
	var state_version: int = int(save_data.get("state_version", 0))
	if state_version not in [1, 2, STATE_VERSION]:
		return false
	var used_value: Variant = save_data.get("used_source_npc_ids", null)
	var days_value: Variant = save_data.get("completed_offer_days", null)
	var pending_value: Variant = save_data.get("pending_offer", null)
	if (
		not used_value is Array
		or not days_value is Array
		or not pending_value is Dictionary
	):
		return false

	used_source_npc_ids.clear()
	for value: Variant in used_value as Array:
		var npc_id: String = String(value).strip_edges()
		if npc_id.is_empty() or used_source_npc_ids.has(npc_id):
			return false
		used_source_npc_ids.append(npc_id)

	completed_offer_days.clear()
	for value: Variant in days_value as Array:
		var day_value: int = int(value)
		if not _append_unique_valid_day(completed_offer_days, day_value):
			return false
	completed_offer_days.sort()

	pending_checkpoint_days.clear()
	if state_version >= 2:
		var pending_days_value: Variant = save_data.get("pending_checkpoint_days", null)
		if not pending_days_value is Array:
			return false
		for value: Variant in pending_days_value as Array:
			var day_value: int = int(value)
			if (
				completed_offer_days.has(day_value)
				or not _append_unique_valid_day(pending_checkpoint_days, day_value)
			):
				return false
	else:
		var legacy_pending: Dictionary = pending_value as Dictionary
		if not legacy_pending.is_empty():
			var legacy_day: int = int(legacy_pending.get("checkpoint_day", 0))
			if not OFFER_DAYS.has(legacy_day):
				return false
			completed_offer_days.erase(legacy_day)
			pending_checkpoint_days.append(legacy_day)
	pending_checkpoint_days.sort()

	pending_offer = (pending_value as Dictionary).duplicate(true)
	if state_version == 1 and not pending_offer.is_empty():
		pending_offer = _migrate_legacy_pending_offer(pending_offer)
		legacy_offer_needs_reconciliation = true
	elif state_version == 2 and not pending_offer.is_empty():
		pending_offer = _migrate_threshold_offer(pending_offer)
		legacy_offer_needs_reconciliation = false
	else:
		legacy_offer_needs_reconciliation = false
	if not _validate_pending_offer(state_version == 1):
		return false

	next_recruit_sequence = maxi(
		1,
		int(save_data.get("next_recruit_sequence", 1))
	)
	if state_version == STATE_VERSION:
		var status_value: Variant = save_data.get("last_requirement_status", {})
		last_requirement_status = (
			(status_value as Dictionary).duplicate(true)
			if status_value is Dictionary
			else {}
		)
	else:
		last_requirement_status = (
			_build_ready_status(
				int(pending_offer.get("checkpoint_day", 0)),
				int(pending_offer.get("required_relationship_points", 0)),
				String(pending_offer.get("phase", "candidate_choice")),
				int(pending_offer.get("relationship_points", 0)),
				String(pending_offer.get("source_name", "")),
				String(pending_offer.get("species_name", ""))
			)
			if not pending_offer.is_empty()
			else _build_waiting_status()
		)
	if last_requirement_status.is_empty():
		last_requirement_status = _build_waiting_status()
	return true


func reconcile_legacy_offer(relationship_entries: Array) -> bool:
	if not legacy_offer_needs_reconciliation:
		return true
	if pending_offer.is_empty():
		legacy_offer_needs_reconciliation = false
		return true

	var source_npc_id: String = String(
		pending_offer.get("source_npc_id", "")
	).strip_edges()
	if source_npc_id.is_empty():
		return false
	for entry_value: Variant in relationship_entries:
		if not entry_value is Dictionary:
			continue
		var entry: Dictionary = entry_value as Dictionary
		if String(entry.get("npc_id", "")) != source_npc_id:
			continue
		pending_offer["relationship_points"] = maxi(
			0,
			int(entry.get("relationship_points", 0))
		)
		pending_offer["relationship_level"] = maxi(
			0,
			int(entry.get("relationship_level", 0))
		)
		last_requirement_status = _build_ready_status(
			int(pending_offer.get("checkpoint_day", 0)),
			int(pending_offer.get("required_relationship_points", 0)),
			String(pending_offer.get("phase", "candidate_choice")),
			int(pending_offer.get("relationship_points", 0)),
			String(pending_offer.get("source_name", "")),
			String(pending_offer.get("species_name", ""))
		)
		legacy_offer_needs_reconciliation = false
		return _validate_pending_offer(true)
	return false


static func get_relationship_requirement(checkpoint_day: int) -> int:
	return int(RELATIONSHIP_REQUIREMENTS.get(checkpoint_day, 0))


static func get_candidate_level(checkpoint_day: int) -> int:
	return clampi(
		1 + floori(float(checkpoint_day) / 20.0),
		1,
		Villager.MAX_LEVEL
	)


func _build_source_rows(
	relationship_entries: Array,
	npc_overviews: Dictionary
) -> Array[Dictionary]:
	var source_rows: Array[Dictionary] = []
	for entry_value: Variant in relationship_entries:
		if not entry_value is Dictionary:
			continue
		var entry: Dictionary = entry_value as Dictionary
		var npc_id: String = String(entry.get("npc_id", "")).strip_edges()
		if npc_id.is_empty() or used_source_npc_ids.has(npc_id):
			continue
		var npc_value: Variant = npc_overviews.get(npc_id, null)
		if not npc_value is Dictionary:
			continue
		var npc_data: Dictionary = npc_value as Dictionary
		if not bool(npc_data.get("known", false)):
			continue
		var species_name: String = CARD_CATALOG_SCRIPT.get_species_name_from_id(
			String(npc_data.get("species_id", ""))
		)
		if not CARD_CATALOG_SCRIPT.has_recruitment_pool(species_name):
			continue
		source_rows.append({
			"npc_id": npc_id,
			"display_name": String(npc_data.get("display_name", "Personagem")),
			"species_name": species_name,
			"relationship_points": int(entry.get("relationship_points", 0)),
			"relationship_level": int(entry.get("relationship_level", 0)),
			"arrival_day": int(npc_data.get("arrival_checkpoint_day", 0))
		})
	return source_rows


func _activate_species_option(
	option: Dictionary,
	campaign_seed: int,
	existing_names: Array[String],
	existing_passive_ids: Array[String]
) -> bool:
	var checkpoint_day: int = int(pending_offer.get("checkpoint_day", 0))
	var species_name: String = String(option.get("species_name", ""))
	var candidates: Array[Dictionary] = _generate_candidates(
		checkpoint_day,
		species_name,
		campaign_seed,
		existing_names,
		existing_passive_ids
	)
	if candidates.size() != CANDIDATE_COUNT:
		return false
	var source_npc_id: String = String(option.get("npc_id", ""))
	if source_npc_id.is_empty():
		return false
	if not used_source_npc_ids.has(source_npc_id):
		used_source_npc_ids.append(source_npc_id)
	pending_offer["phase"] = "candidate_choice"
	pending_offer["source_npc_id"] = source_npc_id
	pending_offer["source_name"] = String(option.get("display_name", "Personagem"))
	pending_offer["species_name"] = species_name
	pending_offer["relationship_points"] = int(option.get("relationship_points", 0))
	pending_offer["relationship_level"] = int(option.get("relationship_level", 0))
	pending_offer["candidates"] = candidates
	last_requirement_status = _build_ready_status(
		checkpoint_day,
		get_relationship_requirement(checkpoint_day),
		"candidate_choice",
		int(option.get("relationship_points", 0)),
		String(option.get("display_name", "Personagem")),
		species_name
	)
	return true


func _generate_candidates(
	checkpoint_day: int,
	species_name: String,
	campaign_seed: int,
	existing_names: Array[String],
	existing_passive_ids: Array[String]
) -> Array[Dictionary]:
	var rng: RandomNumberGenerator = CARD_CATALOG_SCRIPT.create_rng(
		maxi(1, campaign_seed + checkpoint_day * 1009 + next_recruit_sequence * 7919)
	)
	var names: Array[String] = CARD_CATALOG_SCRIPT.get_unique_names(
		species_name,
		CANDIDATE_COUNT,
		rng,
		existing_names
	)
	var portraits: Array[String] = CARD_CATALOG_SCRIPT.get_portrait_ids(species_name)
	_shuffle_strings(portraits, rng)
	var passives: Array[Dictionary] = CARD_CATALOG_SCRIPT.get_randomized_passives(
		CANDIDATE_COUNT,
		rng,
		existing_passive_ids
	)
	var personality_ids: Array[String] = (
		PERSONALITY_CATALOG_SCRIPT.get_unique_random_ids(CANDIDATE_COUNT, rng)
	)
	if (
		names.size() < CANDIDATE_COUNT
		or portraits.size() < CANDIDATE_COUNT
		or passives.size() < CANDIDATE_COUNT
		or personality_ids.size() < CANDIDATE_COUNT
	):
		return []

	var candidate_level: int = get_candidate_level(checkpoint_day)
	var candidates: Array[Dictionary] = []
	for index: int in range(CANDIDATE_COUNT):
		var attributes: Dictionary = CARD_CATALOG_SCRIPT.generate_attributes(rng)
		attributes = CARD_CATALOG_SCRIPT.add_progression_attribute_points(
			attributes,
			candidate_level - 1,
			rng,
			8
		)
		var passive: Dictionary = passives[index]
		var personality: Dictionary = PERSONALITY_CATALOG_SCRIPT.get_definition(
			personality_ids[index]
		)
		var representative_id: String = "recruta_%03d" % next_recruit_sequence
		next_recruit_sequence += 1
		candidates.append({
			"representative_id": representative_id,
			"name": names[index],
			"species_name": species_name,
			"portrait_id": portraits[index],
			"strength": int(attributes.get("strength", 1)),
			"intelligence": int(attributes.get("intelligence", 1)),
			"charisma": int(attributes.get("charisma", 1)),
			"agility": int(attributes.get("agility", 1)),
			"level": candidate_level,
			"xp": 0,
			"lifetime_xp": 0,
			"unspent_attribute_points": 0,
			"attribute_points_spent": maxi(0, candidate_level - 1),
			"passive_id": String(passive.get("id", "")),
			"passive_name": String(passive.get("name", "Sem passiva")),
			"passive_description": String(passive.get("description", "")),
			"passive_condition": String(passive.get("condition", "")),
			"personality_id": String(personality.get("id", "optimistic")),
			"personality_name": String(personality.get("name", "Otimista")),
			"personality_description": String(personality.get("description", "")),
			"profession": Villager.Profession.UNASSIGNED,
			"is_council_active": false,
			"is_recruited_card": true
		})
	return candidates


func _build_waiting_status() -> Dictionary:
	var next_day: int = _get_next_locked_checkpoint_day()
	if next_day <= 0 and pending_checkpoint_days.is_empty():
		return {
			"state": "completed",
			"phase": "",
			"checkpoint_day": 0,
			"required_relationship_points": 0,
			"best_relationship_points": 0,
			"missing_points": 0,
			"message": "Os seis recrutamentos possíveis já foram concluídos."
		}
	return {
		"state": "waiting",
		"phase": "",
		"checkpoint_day": next_day,
		"required_relationship_points": get_relationship_requirement(next_day),
		"best_relationship_points": 0,
		"missing_points": 0,
		"message": (
			"A próxima escolha será liberada ao vencer a avaliação do Dia %d."
			% next_day
			if next_day > 0
			else "Nenhum recrutamento está aguardando verificação."
		)
	}


func _build_blocked_status(
	checkpoint_day: int,
	required_points: int,
	best_source: Dictionary,
	reason: String
) -> Dictionary:
	var best_points: int = int(best_source.get("relationship_points", 0))
	var source_name: String = String(best_source.get("display_name", "Nenhum vínculo"))
	return {
		"state": "blocked",
		"phase": "",
		"checkpoint_day": checkpoint_day,
		"required_relationship_points": required_points,
		"best_relationship_points": best_points,
		"missing_points": 0,
		"best_source_name": source_name,
		"message": "Escolha do Dia %d pendente. %s" % [checkpoint_day, reason]
	}


func _build_ready_status(
	checkpoint_day: int,
	required_points: int,
	phase: String,
	points: int,
	source_name: String,
	species_name: String
) -> Dictionary:
	var message: String = (
		"Os vínculos mais fortes empataram. Escolha a espécie antes de comparar as cartas."
		if phase == "species_choice"
		else "A oferta do Dia %d está pronta: %s atraiu duas cartas %s."
		% [checkpoint_day, source_name, species_name]
	)
	return {
		"state": "ready",
		"phase": phase,
		"checkpoint_day": checkpoint_day,
		"required_relationship_points": required_points,
		"best_relationship_points": points,
		"missing_points": 0,
		"best_source_name": source_name,
		"species_name": species_name,
		"message": message
	}


func _get_next_locked_checkpoint_day() -> int:
	for day: int in OFFER_DAYS:
		if completed_offer_days.has(day) or pending_checkpoint_days.has(day):
			continue
		return day
	return 0


func _migrate_legacy_pending_offer(legacy: Dictionary) -> Dictionary:
	var checkpoint_day: int = int(legacy.get("checkpoint_day", 0))
	var migrated: Dictionary = legacy.duplicate(true)
	migrated["phase"] = "candidate_choice"
	migrated["required_relationship_points"] = get_relationship_requirement(checkpoint_day)
	migrated["relationship_level"] = int(legacy.get("relationship_level", 0))
	migrated["species_options"] = []
	return migrated


func _migrate_threshold_offer(previous: Dictionary) -> Dictionary:
	var migrated: Dictionary = previous.duplicate(true)
	migrated["required_relationship_points"] = 0
	return migrated


func _validate_pending_offer(allow_legacy_threshold_bypass: bool = false) -> bool:
	if pending_offer.is_empty():
		return true
	var checkpoint_day: int = int(pending_offer.get("checkpoint_day", 0))
	if (
		not OFFER_DAYS.has(checkpoint_day)
		or not pending_checkpoint_days.has(checkpoint_day)
		or completed_offer_days.has(checkpoint_day)
	):
		return false
	var phase: String = String(pending_offer.get("phase", ""))
	if phase not in ["species_choice", "candidate_choice"]:
		return false
	var required_points: int = get_relationship_requirement(checkpoint_day)
	if int(pending_offer.get("required_relationship_points", 0)) != required_points:
		return false
	var relationship_points: int = int(
		pending_offer.get("relationship_points", 0)
	)
	if not allow_legacy_threshold_bypass and relationship_points < required_points:
		return false
	if phase == "species_choice":
		return _validate_species_choice_offer(required_points)
	return _validate_candidate_choice_offer(
		checkpoint_day,
		required_points,
		allow_legacy_threshold_bypass
	)


func _validate_species_choice_offer(required_points: int) -> bool:
	if (
		not String(pending_offer.get("source_npc_id", "")).is_empty()
		or not String(pending_offer.get("species_name", "")).is_empty()
	):
		return false
	var candidates_value: Variant = pending_offer.get("candidates", null)
	if not candidates_value is Array or not (candidates_value as Array).is_empty():
		return false
	var options_value: Variant = pending_offer.get("species_options", null)
	if not options_value is Array or (options_value as Array).size() < 2:
		return false
	var source_ids: Array[String] = []
	var species_names: Array[String] = []
	var expected_points: int = -1
	for option_value: Variant in options_value as Array:
		if not option_value is Dictionary:
			return false
		var option: Dictionary = option_value as Dictionary
		var source_id: String = String(option.get("npc_id", "")).strip_edges()
		var source_name: String = String(option.get("display_name", "")).strip_edges()
		var species_name: String = String(option.get("species_name", "")).strip_edges()
		var points: int = int(option.get("relationship_points", -1))
		if (
			source_id.is_empty()
			or source_name.is_empty()
			or species_name.is_empty()
			or source_ids.has(source_id)
			or species_names.has(species_name)
			or used_source_npc_ids.has(source_id)
			or not CARD_CATALOG_SCRIPT.has_recruitment_pool(species_name)
			or points < required_points
		):
			return false
		if expected_points < 0:
			expected_points = points
		elif points != expected_points:
			return false
		source_ids.append(source_id)
		species_names.append(species_name)
	return int(pending_offer.get("relationship_points", -1)) == expected_points


func _validate_candidate_choice_offer(
	checkpoint_day: int,
	required_points: int,
	allow_legacy_threshold_bypass: bool
) -> bool:
	var source_id: String = String(
		pending_offer.get("source_npc_id", "")
	).strip_edges()
	var source_name: String = String(
		pending_offer.get("source_name", "")
	).strip_edges()
	var species_name: String = String(
		pending_offer.get("species_name", "")
	).strip_edges()
	var points: int = int(pending_offer.get("relationship_points", -1))
	if (
		source_id.is_empty()
		or source_name.is_empty()
		or species_name.is_empty()
		or not used_source_npc_ids.has(source_id)
		or not CARD_CATALOG_SCRIPT.has_recruitment_pool(species_name)
		or (not allow_legacy_threshold_bypass and points < required_points)
	):
		return false
	var options_value: Variant = pending_offer.get("species_options", [])
	if options_value is Array and not (options_value as Array).is_empty():
		var matched_source: bool = false
		for option_value: Variant in options_value as Array:
			if not option_value is Dictionary:
				return false
			var option: Dictionary = option_value as Dictionary
			if (
				String(option.get("npc_id", "")) == source_id
				and String(option.get("species_name", "")) == species_name
			):
				matched_source = true
		if not matched_source:
			return false
	var candidates_value: Variant = pending_offer.get("candidates", null)
	if not candidates_value is Array:
		return false
	var candidates: Array = candidates_value as Array
	if candidates.size() != CANDIDATE_COUNT:
		return false
	var expected_level: int = get_candidate_level(checkpoint_day)
	var expected_attribute_total: int = 10 + maxi(0, expected_level - 1)
	var portrait_ids: Array[String] = CARD_CATALOG_SCRIPT.get_portrait_ids(
		species_name
	)
	var candidate_ids: Array[String] = []
	var candidate_names: Array[String] = []
	var passive_ids: Array[String] = []
	for candidate_value: Variant in candidates:
		if not candidate_value is Dictionary:
			return false
		var candidate: Dictionary = candidate_value as Dictionary
		var candidate_id: String = String(
			candidate.get("representative_id", "")
		).strip_edges()
		var candidate_name: String = String(candidate.get("name", "")).strip_edges()
		var passive_id: String = String(candidate.get("passive_id", "")).strip_edges()
		var portrait_id: String = String(candidate.get("portrait_id", "")).strip_edges()
		if (
			candidate_id.is_empty()
			or candidate_name.is_empty()
			or passive_id.is_empty()
			or candidate_ids.has(candidate_id)
			or candidate_names.has(candidate_name)
			or passive_ids.has(passive_id)
			or String(candidate.get("species_name", "")) != species_name
			or int(candidate.get("level", 0)) != expected_level
			or not portrait_ids.has(portrait_id)
			or bool(candidate.get("is_council_active", true))
			or not bool(candidate.get("is_recruited_card", false))
			or int(candidate.get("unspent_attribute_points", -1)) != 0
			or int(candidate.get("attribute_points_spent", -1)) != expected_level - 1
		):
			return false
		var attribute_total: int = 0
		for attribute_key: String in [
			"strength", "intelligence", "charisma", "agility"
		]:
			var attribute_value: int = int(candidate.get(attribute_key, 0))
			if attribute_value < 1 or attribute_value > 8:
				return false
			attribute_total += attribute_value
		if attribute_total != expected_attribute_total:
			return false
		candidate_ids.append(candidate_id)
		candidate_names.append(candidate_name)
		passive_ids.append(passive_id)
	return true


static func _append_unique_valid_day(output: Array[int], day_value: int) -> bool:
	if not OFFER_DAYS.has(day_value) or output.has(day_value):
		return false
	output.append(day_value)
	return true


static func _sort_source_rows(a: Dictionary, b: Dictionary) -> bool:
	var points_a: int = int(a.get("relationship_points", 0))
	var points_b: int = int(b.get("relationship_points", 0))
	if points_a != points_b:
		return points_a > points_b
	var level_a: int = int(a.get("relationship_level", 0))
	var level_b: int = int(b.get("relationship_level", 0))
	if level_a != level_b:
		return level_a > level_b
	var arrival_a: int = int(a.get("arrival_day", 0))
	var arrival_b: int = int(b.get("arrival_day", 0))
	if arrival_a != arrival_b:
		return arrival_a < arrival_b
	return String(a.get("npc_id", "")) < String(b.get("npc_id", ""))


static func _shuffle_strings(
	values: Array[String],
	rng: RandomNumberGenerator
) -> void:
	for index: int in range(values.size() - 1, 0, -1):
		var swap_index: int = rng.randi_range(0, index)
		var temporary: String = values[index]
		values[index] = values[swap_index]
		values[swap_index] = temporary
