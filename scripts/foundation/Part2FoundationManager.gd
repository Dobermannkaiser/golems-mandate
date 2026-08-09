class_name Part2FoundationManager
extends RefCounted


const PLAYER_PROFILE_SCRIPT = preload(
	"res://scripts/models/PlayerProfile.gd"
)

const POPULATION_STATE_SCRIPT = preload(
	"res://scripts/models/PopulationState.gd"
)

const CALENDAR_STATE_SCRIPT = preload(
	"res://scripts/models/CalendarState.gd"
)

const NPC_MODEL_SCRIPT = preload(
	"res://scripts/models/NpcModel.gd"
)

const RELATIONSHIP_STATE_SCRIPT = preload(
	"res://scripts/models/RelationshipState.gd"
)

const SPECIALIST_CATALOG_SCRIPT = preload(
	"res://scripts/specialists/SpecialistCatalog.gd"
)

const RELATIONSHIP_CATALOG_SCRIPT = preload(
	"res://scripts/relationships/RelationshipCatalog.gd"
)

const ACTIVE_COUNCIL_LIMIT: int = 4


var player_profile = PLAYER_PROFILE_SCRIPT.new()
var population_state = POPULATION_STATE_SCRIPT.new()
var calendar_state = CALENDAR_STATE_SCRIPT.new()

var npc_entries: Dictionary = {}
var relationship_entries: Dictionary = {}
var official_partner_id: String = ""
var active_representative_ids: Array[String] = []
var reserve_representative_ids: Array[String] = []

var current_chapter_id: String = "capitulo_01"
var completed_chapter_ids: Array[String] = []
var seen_story_event_ids: Array[String] = []
var pending_story_event_id: String = ""


func setup() -> void:
	player_profile.setup()
	population_state.setup()
	calendar_state.setup()

	npc_entries.clear()
	relationship_entries.clear()
	_register_prepared_specialists()
	official_partner_id = ""
	active_representative_ids.clear()
	reserve_representative_ids.clear()

	for index: int in range(ACTIVE_COUNCIL_LIMIT):
		active_representative_ids.append(
			_get_default_representative_id(index)
		)

	current_chapter_id = "capitulo_01"
	completed_chapter_ids.clear()
	seen_story_event_ids.clear()
	pending_story_event_id = ""


func _register_prepared_specialists() -> void:
	var prepared_npc_data: Array[Dictionary] = (
		SPECIALIST_CATALOG_SCRIPT.get_all_prepared_npc_data()
	)

	for npc_data: Dictionary in prepared_npc_data:
		var prepared_id: String = String(
			npc_data.get("npc_id", "")
		).strip_edges()
		if prepared_id.is_empty():
			continue

		if npc_entries.has(prepared_id):
			_ensure_relationship_for_npc(
				prepared_id,
				npc_entries[prepared_id]
			)
			continue

		var npc_model = NPC_MODEL_SCRIPT.new()
		if not npc_model.import_save_data(npc_data):
			push_error(
				"Não foi possível preparar o NPC %s."
				% String(npc_data.get("npc_id", "desconhecido"))
			)
			continue
		if not register_npc(npc_model):
			push_error(
				"Não foi possível registrar o NPC %s."
				% npc_model.npc_id
			)


func build_save_sections(
	game_day: int,
	representative_states: Array[Dictionary]
) -> Dictionary:
	calendar_state.synchronize_with_game_day(game_day)
	_synchronize_active_representative_ids(
		representative_states
	)

	return {
		"player_profile": (
			player_profile.export_save_data()
		),
		"calendar": calendar_state.export_save_data(),
		"population": (
			population_state.export_save_data()
		),
		"council": {
			"active_limit": ACTIVE_COUNCIL_LIMIT,
			"active_representative_ids": (
				active_representative_ids.duplicate()
			),
			"reserve_representative_ids": (
				reserve_representative_ids.duplicate()
			),
			"representatives": (
				representative_states.duplicate(true)
			)
		},
		"npcs": _export_npc_entries(),
		"relationships": (
			_export_relationship_entries()
		),
		"narrative": {
			"current_chapter_id": current_chapter_id,
			"completed_chapter_ids": (
				completed_chapter_ids.duplicate()
			),
			"seen_story_event_ids": (
				seen_story_event_ids.duplicate()
			),
			"pending_story_event_id": (
				pending_story_event_id
			)
		}
	}


func import_save_sections(
	game_state: Dictionary,
	expected_representative_count: int
) -> bool:
	var profile_value: Variant = game_state.get(
		"player_profile",
		null
	)
	var calendar_value: Variant = game_state.get(
		"calendar",
		null
	)
	var population_value: Variant = game_state.get(
		"population",
		null
	)
	var council_value: Variant = game_state.get(
		"council",
		null
	)
	var npcs_value: Variant = game_state.get(
		"npcs",
		null
	)
	var relationships_value: Variant = game_state.get(
		"relationships",
		null
	)
	var narrative_value: Variant = game_state.get(
		"narrative",
		null
	)

	if (
		not profile_value is Dictionary
		or not calendar_value is Dictionary
		or not population_value is Dictionary
		or not council_value is Dictionary
		or not npcs_value is Dictionary
		or not relationships_value is Dictionary
		or not narrative_value is Dictionary
	):
		return false

	var profile_candidate = PLAYER_PROFILE_SCRIPT.new()
	var population_candidate = (
		POPULATION_STATE_SCRIPT.new()
	)
	var calendar_candidate = CALENDAR_STATE_SCRIPT.new()

	if not profile_candidate.import_save_data(
		profile_value
	):
		return false

	if not population_candidate.import_save_data(
		population_value
	):
		return false

	if (
		population_candidate.total_population
		< expected_representative_count
	):
		return false

	if not calendar_candidate.import_save_data(
		calendar_value
	):
		return false

	var council_data: Dictionary = council_value
	var representatives_value: Variant = (
		council_data.get(
			"representatives",
			null
		)
	)

	if (
		not representatives_value is Array
		or representatives_value.size()
		!= expected_representative_count
		or int(
			council_data.get(
				"active_limit",
				0
			)
		) != ACTIVE_COUNCIL_LIMIT
	):
		return false

	var active_ids: Array[String] = []
	var reserve_ids: Array[String] = []

	if not _read_unique_id_array(
		council_data.get(
			"active_representative_ids",
			null
		),
		active_ids
	):
		return false

	if not _read_unique_id_array(
		council_data.get(
			"reserve_representative_ids",
			null
		),
		reserve_ids
	):
		return false

	if active_ids.size() > ACTIVE_COUNCIL_LIMIT:
		return false

	if active_ids.size() != ACTIVE_COUNCIL_LIMIT:
		return false

	if active_ids.size() + reserve_ids.size() != expected_representative_count:
		return false

	var representatives: Array = representatives_value
	var representative_ids: Dictionary = {}

	for representative_value: Variant in representatives:
		if not representative_value is Dictionary:
			return false

		var representative_data: Dictionary = representative_value
		var representative_id: String = String(
			representative_data.get("representative_id", "")
		).strip_edges()

		if (
			representative_id.is_empty()
			or representative_ids.has(representative_id)
			or (
				not active_ids.has(representative_id)
				and not reserve_ids.has(representative_id)
			)
		):
			return false

		var is_active: bool = bool(
			representative_data.get(
				"is_council_active",
				active_ids.has(representative_id)
			)
		)
		if is_active != active_ids.has(representative_id):
			return false

		representative_ids[representative_id] = true

	for active_id: String in active_ids:
		if not representative_ids.has(active_id):
			return false

	for reserve_id: String in reserve_ids:
		if (
			active_ids.has(reserve_id)
			or not representative_ids.has(reserve_id)
		):
			return false

	var npc_candidates: Dictionary = {}

	if not _import_npc_entries(
		npcs_value,
		npc_candidates
	):
		return false

	var relationship_candidates: Dictionary = {}

	if not _import_relationship_entries(
		relationships_value,
		npc_candidates,
		relationship_candidates
	):
		return false

	var narrative_data: Dictionary = narrative_value
	var completed_chapters: Array[String] = []
	var seen_events: Array[String] = []

	if not _read_unique_id_array(
		narrative_data.get(
			"completed_chapter_ids",
			null
		),
		completed_chapters
	):
		return false

	if not _read_unique_id_array(
		narrative_data.get(
			"seen_story_event_ids",
			null
		),
		seen_events
	):
		return false

	var saved_chapter_id: String = String(
		narrative_data.get(
			"current_chapter_id",
			""
		)
	).strip_edges()

	if saved_chapter_id.is_empty():
		return false

	player_profile = profile_candidate
	population_state = population_candidate
	calendar_state = calendar_candidate
	active_representative_ids = active_ids
	reserve_representative_ids = reserve_ids
	npc_entries = npc_candidates
	relationship_entries = relationship_candidates
	_register_prepared_specialists()
	official_partner_id = String(
		(relationships_value as Dictionary).get("official_partner_id", "")
	).strip_edges()
	for relationship_value: Variant in relationship_entries.values():
		if relationship_value != null:
			relationship_value.set_official_partner(
				relationship_value.npc_id == official_partner_id
			)
	current_chapter_id = saved_chapter_id
	completed_chapter_ids = completed_chapters
	seen_story_event_ids = seen_events
	pending_story_event_id = String(
		narrative_data.get(
			"pending_story_event_id",
			""
		)
	).strip_edges()
	return true


func get_population_overview() -> Dictionary:
	return population_state.export_save_data()


func register_npc(npc_model) -> bool:
	if npc_model == null:
		return false

	var npc_data: Dictionary = npc_model.export_save_data()
	var npc_id: String = String(
		npc_data.get("npc_id", "")
	)

	if npc_id.is_empty():
		return false

	npc_entries[npc_id] = npc_model

	return _ensure_relationship_for_npc(
		npc_id,
		npc_model
	)


func _ensure_relationship_for_npc(
	npc_id: String,
	npc_model
) -> bool:
	if relationship_entries.has(npc_id):
		return true

	if npc_model == null:
		return false

	var npc_data: Dictionary = npc_model.export_save_data()
	var relationship = RELATIONSHIP_STATE_SCRIPT.new()

	if not relationship.setup(
		npc_id,
		bool(
			npc_data.get(
				"romance_available",
				false
			)
		)
	):
		return false

	relationship_entries[npc_id] = relationship
	return true


func mark_npc_known(npc_id: String) -> bool:
	var clean_id: String = npc_id.strip_edges()
	if clean_id.is_empty() or not npc_entries.has(clean_id):
		return false

	var npc_model = npc_entries[clean_id]
	if npc_model == null:
		return false

	npc_model.known = true
	return _ensure_relationship_for_npc(clean_id, npc_model)


func add_relationship_points(npc_id: String, amount: int) -> bool:
	var clean_id: String = npc_id.strip_edges()
	if clean_id.is_empty() or not relationship_entries.has(clean_id):
		return false

	var relationship = relationship_entries[clean_id]
	if relationship == null:
		return false

	relationship.add_relationship_points(amount)
	return true


func get_known_npc_ids() -> Array[String]:
	var result: Array[String] = []
	for npc_id_value: Variant in npc_entries.keys():
		var npc_id: String = String(npc_id_value)
		var npc_model = npc_entries[npc_id]
		if npc_model != null and npc_model.known:
			result.append(npc_id)
	result.sort()
	return result


func get_npc_overview(npc_id: String) -> Dictionary:
	var clean_id: String = npc_id.strip_edges()
	if clean_id.is_empty() or not npc_entries.has(clean_id):
		return {}

	var npc_model = npc_entries[clean_id]
	if npc_model == null:
		return {}

	var overview: Dictionary = npc_model.export_save_data()
	if relationship_entries.has(clean_id):
		var relationship = relationship_entries[clean_id]
		if relationship != null:
			overview["relationship"] = relationship.export_save_data()
	return overview


func get_player_profile_overview() -> Dictionary:
	return player_profile.export_save_data()


func configure_player_profile(
	player_name: String,
	gender_id: String,
	difficulty_id: String = VillageDifficultyCatalog.DEFAULT_DIFFICULTY_ID,
	village_name: String = VillagePlayerProfile.DEFAULT_VILLAGE_NAME
) -> void:
	player_profile.setup(player_name, gender_id, difficulty_id, village_name)
	refresh_population_difficulty()


func refresh_population_difficulty() -> void:
	var difficulty: Dictionary = VillageDifficultyCatalog.get_difficulty(
		player_profile.difficulty_id
	)
	population_state.configure_difficulty(
		int(difficulty.get("attraction_target", 3)),
		int(difficulty.get("abandonment_target", 3))
	)


func get_relationship_overview(day_value: int, known_only: bool = true) -> Dictionary:
	var entries: Array[Dictionary] = []
	for npc_id_value: Variant in relationship_entries.keys():
		var npc_id: String = String(npc_id_value)
		if not RELATIONSHIP_CATALOG_SCRIPT.is_tracked(npc_id):
			continue
		var npc_model = npc_entries.get(npc_id, null)
		var relationship = relationship_entries.get(npc_id, null)
		if npc_model == null or relationship == null:
			continue
		if known_only and not npc_model.known:
			continue
		var npc_data: Dictionary = npc_model.export_save_data()
		var relation_data: Dictionary = relationship.export_save_data()
		relation_data["display_name"] = String(npc_data.get("display_name", "Personagem"))
		relation_data["portrait_id"] = RELATIONSHIP_CATALOG_SCRIPT.get_portrait_id(npc_id)
		relation_data["known"] = bool(npc_data.get("known", false))
		relation_data["next_personal_event_id"] = RELATIONSHIP_CATALOG_SCRIPT.get_next_personal_event_id(npc_id, relation_data)
		var next_threshold: int = RELATIONSHIP_CATALOG_SCRIPT.get_next_personal_event_threshold(
			relation_data
		)
		relation_data["next_personal_event_threshold"] = next_threshold
		var next_stage_index: int = RELATIONSHIP_CATALOG_SCRIPT.PERSONAL_EVENT_POINT_THRESHOLDS.find(
			next_threshold
		)
		relation_data["next_personal_event_stage"] = (
			RELATIONSHIP_CATALOG_SCRIPT.PERSONAL_EVENT_STAGE_NAMES[next_stage_index]
			if next_stage_index >= 0
			else "Cena importante"
		)
		relation_data["bonus_description"] = RELATIONSHIP_CATALOG_SCRIPT.get_management_bonus_description(
			npc_id,
			int(relation_data.get("relationship_level", 0)),
			npc_id == official_partner_id,
			relation_data
		)
		relation_data["can_date_today"] = relationship.can_go_on_date(day_value)
		entries.append(relation_data)
	entries.sort_custom(_sort_relationship_entries)
	var partner_name: String = "Nenhum"
	if not official_partner_id.is_empty() and npc_entries.has(official_partner_id):
		partner_name = String(npc_entries[official_partner_id].display_name)
	return {
		"official_partner_id": official_partner_id,
		"official_partner_name": partner_name,
		"entries": entries
	}


func register_relationship_response(
	npc_id: String,
	day_value: int,
	quality: String,
	point_delta: int,
	topic_id: String = "",
	ignore_daily_limit: bool = false
) -> Dictionary:
	var clean_id: String = npc_id.strip_edges()
	if not relationship_entries.has(clean_id):
		return {"success": false, "message": "Vínculo não encontrado."}
	var relationship = relationship_entries[clean_id]
	if relationship == null:
		return {"success": false, "message": "Vínculo inválido."}
	var could_apply_points: bool = (
		ignore_daily_limit
		or relationship.can_gain_conversation_points(day_value)
	)
	var applied: int = relationship.register_conversation(
		day_value,
		quality,
		point_delta,
		topic_id,
		ignore_daily_limit
	)
	return {
		"success": true,
		"applied_points": applied,
		"relationship": relationship.export_save_data(),
		"message": _format_relationship_change_message(
			clean_id,
			applied,
			quality,
			could_apply_points
		)
	}


func complete_relationship_personal_event(
	npc_id: String,
	event_id: String,
	point_delta: int
) -> Dictionary:
	var clean_id: String = npc_id.strip_edges()
	if not relationship_entries.has(clean_id):
		return {"success": false, "message": "Vínculo não encontrado."}
	var relationship = relationship_entries[clean_id]
	if relationship == null or relationship.has_completed_personal_event(event_id):
		return {"success": false, "message": "Este evento pessoal já foi concluído."}
	var applied: int = relationship.add_relationship_points(point_delta)
	relationship.complete_personal_event(event_id)
	return {"success": true, "applied_points": applied, "relationship": relationship.export_save_data()}


func mark_relationship_seasonal_dialogue_seen(
	npc_id: String,
	dialogue_key: String
) -> bool:
	var clean_id: String = npc_id.strip_edges()
	if not relationship_entries.has(clean_id):
		return false
	var relationship = relationship_entries[clean_id]
	if relationship == null:
		return false
	return relationship.mark_seasonal_dialogue_seen(dialogue_key)


func set_relationship_interest(npc_id: String, value: bool) -> bool:
	if not relationship_entries.has(npc_id):
		return false
	var relationship = relationship_entries[npc_id]
	if relationship == null or not relationship.romance_available:
		return false
	relationship.romance_interest = value
	if value:
		relationship.romance_declined = false
	return true


func record_relationship_interest(npc_id: String, marker_id: String) -> bool:
	if not relationship_entries.has(npc_id):
		return false
	var relationship = relationship_entries[npc_id]
	if relationship == null or not relationship.romance_available:
		return false
	return relationship.add_romance_interest_marker(marker_id)


func decline_relationship_romance(npc_id: String) -> bool:
	if not relationship_entries.has(npc_id):
		return false
	var relationship = relationship_entries[npc_id]
	if relationship == null:
		return false
	relationship.romance_interest = false
	relationship.romance_declined = true
	return true


func set_official_partner(npc_id: String) -> Dictionary:
	var clean_id: String = npc_id.strip_edges()
	if not official_partner_id.is_empty() and official_partner_id != clean_id:
		return {"success": false, "message": "O Prefeito já possui um parceiro oficial."}
	if not relationship_entries.has(clean_id):
		return {"success": false, "message": "Vínculo não encontrado."}
	var relationship = relationship_entries[clean_id]
	if relationship == null or not relationship.romance_available:
		return {"success": false, "message": "Este personagem não possui rota romântica."}
	official_partner_id = clean_id
	for state_value: Variant in relationship_entries.values():
		if state_value != null:
			state_value.set_official_partner(state_value.npc_id == official_partner_id)
	return {"success": true, "message": "%s tornou-se o parceiro oficial do Prefeito." % String(npc_entries[clean_id].display_name)}


func register_relationship_date(npc_id: String, day_value: int, point_delta: int) -> Dictionary:
	if not relationship_entries.has(npc_id):
		return {"success": false, "message": "Vínculo não encontrado."}
	var relationship = relationship_entries[npc_id]
	if relationship == null:
		return {"success": false, "message": "Vínculo inválido."}
	var was_available: bool = relationship.can_go_on_date(day_value)
	if not was_available:
		return {
			"success": false,
			"message": "O próximo encontro ainda não está disponível."
		}
	var applied: int = relationship.register_date(day_value, point_delta)
	return {
		"success": true,
		"applied_points": applied,
		"relationship": relationship.export_save_data(),
		"message": (
			"O encontro aproximou vocês em %d pontos." % applied
			if applied > 0
			else "O encontro foi concluído."
		)
	}


func get_relationship_management_modifiers(context: Dictionary = {}) -> Dictionary:
	var total: Dictionary = {
		"food_production_bonus": 0.0,
		"material_production_bonus": 0.0,
		"daily_happiness_bonus": 0.0,
		"food_consumption_reduction": 0.0,
		"maintenance_reduction": 0.0,
		"happiness_decay_reduction": 0.0
	}
	for npc_id_value: Variant in relationship_entries.keys():
		var npc_id: String = String(npc_id_value)
		var npc_model = npc_entries.get(npc_id, null)
		var relationship = relationship_entries.get(npc_id, null)
		if npc_model == null or relationship == null or not npc_model.known:
			continue
		var modifiers: Dictionary = RELATIONSHIP_CATALOG_SCRIPT.get_management_modifiers(
			npc_id,
			relationship.get_relationship_level(),
			npc_id == official_partner_id,
			context
		)
		for key: String in total.keys():
			total[key] = float(total[key]) + float(modifiers.get(key, 0.0))
	return total


func resolve_relationship_daily_passives(
	completed_day: int,
	happiness_before: float,
	happiness_after: float
) -> Dictionary:
	const SILAS_ID: String = "meio_vampiro_emo_gotico"
	const REQUIRED_LEVEL: int = 4
	const COOLDOWN_DAYS: int = 5
	var relationship = relationship_entries.get(SILAS_ID, null)
	var npc_model = npc_entries.get(SILAS_ID, null)
	if relationship == null or npc_model == null or not npc_model.known:
		return {}
	if relationship.get_relationship_level() < REQUIRED_LEVEL:
		return {}
	if happiness_after >= happiness_before - 0.001:
		return {}
	if not relationship.can_trigger_management_passive(
		completed_day,
		COOLDOWN_DAYS
	):
		return {}
	relationship.mark_management_passive_triggered(completed_day)
	return {
		"npc_id": SILAS_ID,
		"happiness_recovery": 1.0,
		"message": (
			"PASSIVA — Canção de Vigília: Silas transformou a perda do dia "
			+ "em cuidado coletivo. Felicidade +1."
		)
	}


func _sort_relationship_entries(a: Dictionary, b: Dictionary) -> bool:
	return String(a.get("display_name", "")) < String(b.get("display_name", ""))


func _format_relationship_change_message(
	npc_id: String,
	applied: int,
	quality: String,
	was_first_today: bool
) -> String:
	var name: String = npc_id
	if npc_entries.has(npc_id):
		name = String(npc_entries[npc_id].display_name)
	if not was_first_today:
		return "Você já conversou com %s hoje; nenhum ponto adicional foi aplicado." % name
	if applied > 0:
		return "%s gostou da resposta. Relação +%d." % [name, applied]
	if applied < 0:
		return "%s não gostou da resposta. Relação %d." % [name, applied]
	if quality == "good":
		return "%s gostou da resposta, mas o vínculo já está no máximo." % name
	if quality == "bad":
		return "%s não gostou da resposta, mas o vínculo já estava no mínimo." % name
	return "A conversa com %s não alterou a relação." % name


func _export_npc_entries() -> Dictionary:
	var entries: Dictionary = {}
	var known_ids: Array[String] = []

	for npc_id_value: Variant in npc_entries.keys():
		var npc_id: String = String(npc_id_value)
		var npc_model = npc_entries[npc_id]
		var npc_data: Dictionary = (
			npc_model.export_save_data()
		)

		entries[npc_id] = npc_data

		if bool(npc_data.get("known", false)):
			known_ids.append(npc_id)

	known_ids.sort()

	return {
		"known_ids": known_ids,
		"entries": entries
	}


func _export_relationship_entries() -> Dictionary:
	var entries: Dictionary = {}

	for npc_id_value: Variant in relationship_entries.keys():
		var npc_id: String = String(npc_id_value)
		var relationship = relationship_entries[npc_id]
		entries[npc_id] = relationship.export_save_data()

	return {
		"relationship_system_version": 3,
		"minimum_points": VillageRelationshipState.MIN_RELATIONSHIP_POINTS,
		"maximum_points": VillageRelationshipState.MAX_RELATIONSHIP_POINTS,
		"maximum_level": VillageRelationshipState.MAX_LEVEL,
		"official_partner_id": official_partner_id,
		"entries": entries
	}


func _import_npc_entries(
	npcs_data: Dictionary,
	output: Dictionary
) -> bool:
	var entries_value: Variant = npcs_data.get(
		"entries",
		null
	)
	var known_ids_value: Variant = npcs_data.get(
		"known_ids",
		null
	)

	if (
		not entries_value is Dictionary
		or not known_ids_value is Array
	):
		return false

	var entries: Dictionary = entries_value

	for npc_id_value: Variant in entries.keys():
		var npc_id: String = String(
			npc_id_value
		).strip_edges()
		var entry_value: Variant = entries[npc_id_value]

		if (
			npc_id.is_empty()
			or not entry_value is Dictionary
		):
			return false

		var npc_model = NPC_MODEL_SCRIPT.new()

		if (
			not npc_model.import_save_data(
				entry_value
			)
			or npc_model.npc_id != npc_id
		):
			return false

		output[npc_id] = npc_model

	var known_ids: Array[String] = []

	if not _read_unique_id_array(
		known_ids_value,
		known_ids
	):
		return false

	for known_id: String in known_ids:
		if (
			not output.has(known_id)
			or not output[known_id].known
		):
			return false

	return true


func _import_relationship_entries(
	relationships_data: Dictionary,
	npcs: Dictionary,
	output: Dictionary
) -> bool:
	var entries_value: Variant = relationships_data.get("entries", null)
	if not entries_value is Dictionary:
		return false

	var entries: Dictionary = entries_value
	for npc_id_value: Variant in entries.keys():
		var npc_id: String = String(npc_id_value).strip_edges()
		var entry_value: Variant = entries[npc_id_value]
		if not npcs.has(npc_id) or not entry_value is Dictionary:
			return false

		var relationship = RELATIONSHIP_STATE_SCRIPT.new()
		if (
			not relationship.import_save_data(entry_value)
			or relationship.npc_id != npc_id
			or relationship.romance_available != npcs[npc_id].romance_available
		):
			return false
		output[npc_id] = relationship

	var saved_partner: String = String(
		relationships_data.get("official_partner_id", "")
	).strip_edges()
	if not saved_partner.is_empty():
		if not output.has(saved_partner):
			return false
		var partner_state = output[saved_partner]
		if partner_state == null or not partner_state.romance_available:
			return false
	return true


func _read_unique_id_array(
	value: Variant,
	output: Array[String]
) -> bool:
	if not value is Array:
		return false

	for id_value: Variant in value:
		var entry_id: String = String(
			id_value
		).strip_edges()

		if entry_id.is_empty() or output.has(entry_id):
			return false

		output.append(entry_id)

	return true


func _synchronize_active_representative_ids(
	representative_states: Array[Dictionary]
) -> void:
	active_representative_ids.clear()
	reserve_representative_ids.clear()
	for index: int in range(representative_states.size()):
		var state: Dictionary = representative_states[index]
		var representative_id: String = String(
			state.get(
				"representative_id",
				_get_default_representative_id(index)
			)
		).strip_edges()
		var should_be_active: bool = bool(
			state.get(
				"is_council_active",
				index < ACTIVE_COUNCIL_LIMIT
			)
		)
		if (
			should_be_active
			and active_representative_ids.size() < ACTIVE_COUNCIL_LIMIT
		):
			active_representative_ids.append(representative_id)
		else:
			reserve_representative_ids.append(representative_id)


func _get_default_representative_id(
	index: int
) -> String:
	return "representante_%02d" % (index + 1)
