class_name Part3FoundationManager
extends RefCounted


const FOUNDATION_STATE_VERSION: int = 4
const FOUNDATION_SCHEMA_ID: String = "golems_mandate_part3_foundation"
const MAX_PRODUCTION_HISTORY: int = 512
const MAX_DECISION_HISTORY: int = 2048
const MAX_COUNCILLOR_HISTORY: int = 160
const DEFAULT_COUNCILLOR_LEVEL: int = 1
const CONSTRUCTION_POPULATION_STEP: int = 20
const MAX_CONSTRUCTION_SITES: int = 4


var campaign_seed: int = 0
var generator_version: int = VillageCampaignIdentityCatalog.GENERATOR_VERSION
var production_history: Array[Dictionary] = []
var decision_history: Array[Dictionary] = []
var event_flags: Dictionary = {}
var councillor_progress: Dictionary = {}
# Compatibilidade com o save v8 da Etapa 1. A fila funcional pertence
# exclusivamente a VillageBuildingManager e este array deve permanecer vazio.
var construction_queue: Array[Dictionary] = []
var building_variants: Dictionary = {}
var strategy_metrics: Dictionary = {}
var next_decision_sequence: int = 1
var next_queue_sequence: int = 1
var newly_reached_milestones: Array[Dictionary] = []


func setup(new_campaign_seed: int = 0) -> void:
	campaign_seed = _sanitize_seed(new_campaign_seed)
	generator_version = VillageCampaignIdentityCatalog.GENERATOR_VERSION
	production_history.clear()
	decision_history.clear()
	event_flags.clear()
	councillor_progress.clear()
	construction_queue.clear()
	building_variants.clear()
	next_decision_sequence = 1
	next_queue_sequence = 1
	newly_reached_milestones.clear()
	strategy_metrics = _create_empty_strategy_metrics()


func ensure_councillor(
	representative_id: String,
	display_name: String = "",
	joined_day: int = 1
) -> bool:
	var clean_id: String = representative_id.strip_edges()
	if clean_id.is_empty():
		return false

	if councillor_progress.has(clean_id):
		var existing: Dictionary = councillor_progress[clean_id]
		if not display_name.strip_edges().is_empty():
			existing["display_name"] = display_name.strip_edges()
			councillor_progress[clean_id] = existing
		return true

	councillor_progress[clean_id] = {
		"representative_id": clean_id,
		"display_name": display_name.strip_edges(),
		"level": DEFAULT_COUNCILLOR_LEVEL,
		"xp": 0,
		"lifetime_xp": 0,
		"unspent_attribute_points": 0,
		"attribute_points_spent": 0,
		"joined_day": maxi(1, joined_day),
		"days_in_council": 0,
		"days_in_reserve": 0,
		"level_ups": 0,
		"events_resolved": 0,
		"event_successes": 0,
		"event_failures": 0,
		"event_guaranteed": 0,
		"successful_audits": 0,
		"council_projects_started": 0,
		"council_projects_completed": 0,
		"total_production": {
			"food": 0.0,
			"material": 0.0,
			"happiness": 0.0
		},
		"profession_history": [],
		"profession_day_counts": {},
		"production_milestones": [],
		"behavioral_medals": [],
		"history_entries": []
	}
	return true


func record_daily_production(
	day_value: int,
	totals: Dictionary,
	councillor_rows: Array[Dictionary],
	context: Dictionary
) -> bool:
	if day_value < 1 or _has_production_day(day_value):
		return false

	newly_reached_milestones.clear()
	var sanitized_rows: Array[Dictionary] = []
	for row: Dictionary in councillor_rows:
		var representative_id: String = String(
			row.get("representative_id", "")
		).strip_edges()
		if representative_id.is_empty():
			continue

		var display_name: String = String(
			row.get("display_name", "")
		).strip_edges()
		ensure_councillor(representative_id, display_name)

		var sanitized_row: Dictionary = {
			"representative_id": representative_id,
			"display_name": display_name,
			"profession": int(row.get("profession", -1)),
			"profession_name": String(
				row.get("profession_name", "")
			),
			"is_active": bool(row.get("is_active", false)),
			"food": maxf(0.0, float(row.get("food", 0.0))),
			"material": maxf(0.0, float(row.get("material", 0.0))),
			"happiness": maxf(0.0, float(row.get("happiness", 0.0))),
			"attribute_base": (
				(row.get("attribute_base", {}) as Dictionary).duplicate(true)
				if row.get("attribute_base", null) is Dictionary
				else {}
			),
			"personal_bonus": (
				(row.get("personal_bonus", {}) as Dictionary).duplicate(true)
				if row.get("personal_bonus", null) is Dictionary
				else {}
			),
			"global_bonus": (
				(row.get("global_bonus", {}) as Dictionary).duplicate(true)
				if row.get("global_bonus", null) is Dictionary
				else {}
			),
			"specialization_bonus": maxf(
				0.0,
				float(row.get("specialization_bonus", 0.0))
			),
			"passive_id": String(row.get("passive_id", "")),
			"passive_active": bool(row.get("passive_active", false)),
			"output_scope": String(
				row.get(
					"output_scope",
					"individual_before_global_multipliers"
				)
			)
		}
		sanitized_rows.append(sanitized_row)
		_update_councillor_after_day(sanitized_row, day_value)

	var entry: Dictionary = {
		"day": day_value,
		"difficulty_id": String(context.get("difficulty_id", "")),
		"season_id": String(context.get("season_id", "")),
		"population_before": maxi(
			0,
			int(context.get("population_before", 0))
		),
		"population_after": maxi(
			0,
			int(context.get("population_after", 0))
		),
		"common_population": maxi(
			0,
			int(context.get("common_population", 0))
		),
		"council_size": maxi(
			0,
			int(context.get("council_size", 0))
		),
		"profession_counts": _sanitize_count_dictionary(
			context.get("profession_counts", {})
		),
		"production": {
			"food": maxf(0.0, float(totals.get("food", 0.0))),
			"material": maxf(
				0.0,
				float(totals.get("material", 0.0))
			),
			"happiness": maxf(
				0.0,
				float(totals.get("happiness", 0.0))
			)
		},
		"costs": {
			"food": maxf(
				0.0,
				float(context.get("food_consumption", 0.0))
			),
			"material": maxf(
				0.0,
				float(context.get("material_consumption", 0.0))
			),
			"happiness": maxf(
				0.0,
				float(context.get("happiness_decay", 0.0))
			)
		},
		"shortages": {
			"food": maxf(
				0.0,
				float(context.get("food_shortage", 0.0))
			),
			"material": maxf(
				0.0,
				float(context.get("material_shortage", 0.0))
			)
		},
		"resources_after": {
			"food": maxf(
				0.0,
				float(context.get("food_after", 0.0))
			),
			"material": maxf(
				0.0,
				float(context.get("material_after", 0.0))
			),
			"happiness": clampf(
				float(context.get("happiness_after", 0.0)),
				0.0,
				100.0
			)
		},
		"resources_before": {
			"food": maxf(0.0, float(context.get("food_before", 0.0))),
			"material": maxf(0.0, float(context.get("material_before", 0.0))),
			"happiness": clampf(
				float(context.get("happiness_before", 0.0)),
				0.0,
				100.0
			)
		},
		"councillors": sanitized_rows
	}

	production_history.append(entry)
	if production_history.size() > MAX_PRODUCTION_HISTORY:
		production_history.pop_front()
	_rebuild_strategy_metrics()
	return true


func record_decision(
	day_value: int,
	category: String,
	decision_id: String,
	actor_id: String = "",
	context: Dictionary = {},
	outcome: Dictionary = {}
) -> bool:
	var clean_category: String = category.strip_edges()
	var clean_decision_id: String = decision_id.strip_edges()
	if day_value < 1 or clean_category.is_empty() or clean_decision_id.is_empty():
		return false

	decision_history.append(
		{
			"sequence": next_decision_sequence,
			"day": day_value,
			"category": clean_category,
			"decision_id": clean_decision_id,
			"actor_id": actor_id.strip_edges(),
			"context": context.duplicate(true),
			"outcome": outcome.duplicate(true)
		}
	)
	next_decision_sequence += 1
	if decision_history.size() > MAX_DECISION_HISTORY:
		decision_history.pop_front()
	_rebuild_strategy_metrics()
	return true


func mark_event_resolution(
	day_value: int,
	event_id: String,
	choice_id: String,
	succeeded: bool,
	actor_id: String = "",
	was_test: bool = false,
	event_title: String = "Acontecimento",
	record_personal_event_entry: bool = true
) -> bool:
	var clean_event_id: String = event_id.strip_edges()
	if clean_event_id.is_empty() or day_value < 1:
		return false

	event_flags[clean_event_id] = {
		"resolved": true,
		"last_day": day_value,
		"last_choice_id": choice_id.strip_edges(),
		"last_succeeded": succeeded,
		"last_actor_id": actor_id.strip_edges(),
		"last_was_test": was_test
	}

	var clean_actor_id: String = actor_id.strip_edges()
	if not clean_actor_id.is_empty():
		ensure_councillor(clean_actor_id, "", day_value)
		var progress: Dictionary = councillor_progress[clean_actor_id]
		progress["events_resolved"] = maxi(
			0,
			int(progress.get("events_resolved", 0)) + 1
		)
		if was_test:
			var counter_id: String = (
				"event_successes" if succeeded else "event_failures"
			)
			progress[counter_id] = maxi(
				0,
				int(progress.get(counter_id, 0)) + 1
			)
		else:
			progress["event_guaranteed"] = maxi(
				0,
				int(progress.get("event_guaranteed", 0)) + 1
			)
		if record_personal_event_entry:
			_append_history_entry(
				progress,
				{
					"day": day_value,
					"type": "event",
					"title": event_title.strip_edges(),
					"event_id": clean_event_id,
					"choice_id": choice_id.strip_edges(),
					"succeeded": succeeded,
					"was_test": was_test
				}
			)
		councillor_progress[clean_actor_id] = progress
	return true


func record_founder_memory_entry(
	representative_id: String,
	entry: Dictionary
) -> bool:
	var clean_id: String = representative_id.strip_edges()
	if clean_id.is_empty() or entry.is_empty():
		return false
	ensure_councillor(clean_id, "", int(entry.get("day", 1)))
	if not councillor_progress.has(clean_id):
		return false
	var progress: Dictionary = councillor_progress[clean_id]
	_append_history_entry(progress, entry)
	councillor_progress[clean_id] = progress
	return true


func set_event_flag(
	event_id: String,
	flag_id: String,
	value: Variant,
	day_value: int
) -> bool:
	var clean_event_id: String = event_id.strip_edges()
	var clean_flag_id: String = flag_id.strip_edges()
	if clean_event_id.is_empty() or clean_flag_id.is_empty() or day_value < 1:
		return false

	var entry: Dictionary = event_flags.get(clean_event_id, {})
	var custom_flags: Dictionary = entry.get("custom_flags", {})
	custom_flags[clean_flag_id] = {
		"value": value,
		"day": day_value
	}
	entry["custom_flags"] = custom_flags
	event_flags[clean_event_id] = entry
	return true


func get_event_flags() -> Dictionary:
	return event_flags.duplicate(true)


func grant_councillor_xp(
	representative_id: String,
	amount: int,
	reason_id: String,
	day_value: int
) -> bool:
	var clean_id: String = representative_id.strip_edges()
	if clean_id.is_empty() or amount <= 0 or day_value < 1:
		return false
	ensure_councillor(clean_id)
	var progress: Dictionary = councillor_progress[clean_id]
	progress["xp"] = maxi(0, int(progress.get("xp", 0)) + amount)
	progress["lifetime_xp"] = maxi(
		0,
		int(progress.get("lifetime_xp", 0)) + amount
	)
	councillor_progress[clean_id] = progress
	return record_decision(
		day_value,
		"councillor_xp",
		reason_id,
		clean_id,
		{"amount": amount},
		{"xp_after": int(progress.get("xp", 0))}
	)


func synchronize_councillor_progression(
	representative_id: String,
	level_value: int,
	xp_value: int,
	unspent_points: int,
	lifetime_xp_value: int = -1,
	spent_points: int = -1
) -> bool:
	var clean_id: String = representative_id.strip_edges()
	if clean_id.is_empty():
		return false
	ensure_councillor(clean_id)
	var progress: Dictionary = councillor_progress[clean_id]
	progress["level"] = clampi(level_value, 1, 6)
	progress["xp"] = maxi(0, xp_value)
	progress["unspent_attribute_points"] = maxi(0, unspent_points)
	if lifetime_xp_value >= 0:
		progress["lifetime_xp"] = maxi(0, lifetime_xp_value)
	if spent_points >= 0:
		progress["attribute_points_spent"] = maxi(0, spent_points)
	councillor_progress[clean_id] = progress
	return true


func record_level_up(
	representative_id: String,
	new_level: int,
	day_value: int
) -> bool:
	var clean_id: String = representative_id.strip_edges()
	if clean_id.is_empty() or day_value < 1:
		return false
	ensure_councillor(clean_id, "", day_value)
	var progress: Dictionary = councillor_progress[clean_id]
	progress["level_ups"] = maxi(0, int(progress.get("level_ups", 0)) + 1)
	_append_history_entry(
		progress,
		{
			"day": day_value,
			"type": "level_up",
			"title": "Alcançou o nível %d" % new_level,
			"level": new_level
		}
	)
	councillor_progress[clean_id] = progress
	return true


func record_attribute_spent(
	representative_id: String,
	attribute_id: String,
	new_value: int,
	day_value: int
) -> bool:
	var clean_id: String = representative_id.strip_edges()
	if clean_id.is_empty() or day_value < 1:
		return false
	ensure_councillor(clean_id, "", day_value)
	var progress: Dictionary = councillor_progress[clean_id]
	_append_history_entry(
		progress,
		{
			"day": day_value,
			"type": "attribute",
			"title": "Aprimorou %s para %d" % [
				_attribute_display_name(attribute_id),
				new_value
			],
			"attribute_id": attribute_id,
			"value": new_value
		}
	)
	councillor_progress[clean_id] = progress
	return true


func record_level_dialogue(
	representative_id: String,
	level_value: int,
	quality: String,
	reward_resource: String,
	day_value: int
) -> bool:
	var clean_id: String = representative_id.strip_edges()
	if clean_id.is_empty() or day_value < 1:
		return false
	ensure_councillor(clean_id, "", day_value)
	var progress: Dictionary = councillor_progress[clean_id]
	_append_history_entry(
		progress,
		{
			"day": day_value,
			"type": "level_dialogue",
			"title": "Conversa após alcançar o nível %d" % level_value,
			"quality": quality,
			"reward_resource": reward_resource
		}
	)
	councillor_progress[clean_id] = progress
	return true


func record_councillor_project_started(
	representative_id: String,
	project_title: String,
	choice_id: String,
	choice_text: String,
	end_day: int,
	day_value: int
) -> bool:
	var clean_id: String = representative_id.strip_edges()
	if clean_id.is_empty() or day_value < 1 or end_day < day_value:
		return false
	ensure_councillor(clean_id, "", day_value)
	var progress: Dictionary = councillor_progress[clean_id]
	progress["council_projects_started"] = maxi(
		0,
		int(progress.get("council_projects_started", 0)) + 1
	)
	_append_history_entry(
		progress,
		{
			"day": day_value,
			"type": "council_project_started",
			"title": project_title.strip_edges(),
			"choice_id": choice_id.strip_edges(),
			"choice_text": choice_text.strip_edges(),
			"end_day": end_day
		}
	)
	councillor_progress[clean_id] = progress
	return true


func record_councillor_project_completed(
	representative_id: String,
	project_title: String,
	choice_id: String,
	completion_text: String,
	day_value: int
) -> bool:
	var clean_id: String = representative_id.strip_edges()
	if clean_id.is_empty() or day_value < 1:
		return false
	ensure_councillor(clean_id, "", day_value)
	var progress: Dictionary = councillor_progress[clean_id]
	progress["council_projects_completed"] = maxi(
		0,
		int(progress.get("council_projects_completed", 0)) + 1
	)
	_append_history_entry(
		progress,
		{
			"day": day_value,
			"type": "council_project_completed",
			"title": project_title.strip_edges(),
			"choice_id": choice_id.strip_edges(),
			"completion_text": completion_text.strip_edges()
		}
	)
	councillor_progress[clean_id] = progress
	return true


func get_councillor_history(representative_id: String) -> Dictionary:
	var clean_id: String = representative_id.strip_edges()
	if clean_id.is_empty() or not councillor_progress.has(clean_id):
		return {}
	return (councillor_progress[clean_id] as Dictionary).duplicate(true)


func get_all_councillor_progress() -> Dictionary:
	return councillor_progress.duplicate(true)


func get_dominant_resource(representative_id: String) -> String:
	var progress: Dictionary = get_councillor_history(representative_id)
	var totals: Dictionary = progress.get("total_production", {})
	var best_id: String = ""
	var best_value: float = 0.0
	for resource_id: String in ["food", "material", "happiness"]:
		var value: float = float(totals.get(resource_id, 0.0))
		if value > best_value:
			best_value = value
			best_id = resource_id
	return best_id


func consume_new_production_milestones() -> Array[Dictionary]:
	var result: Array[Dictionary] = newly_reached_milestones.duplicate(true)
	newly_reached_milestones.clear()
	return result


func record_successful_audit(
	representative_ids: Array[String],
	day_value: int
) -> void:
	for representative_id: String in representative_ids:
		var clean_id: String = representative_id.strip_edges()
		if clean_id.is_empty():
			continue
		ensure_councillor(clean_id, "", day_value)
		var progress: Dictionary = councillor_progress[clean_id]
		progress["successful_audits"] = maxi(
			0,
			int(progress.get("successful_audits", 0)) + 1
		)
		_append_history_entry(
			progress,
			{
				"day": day_value,
				"type": "audit",
				"title": "Participou da aprovação da avaliação do dia %d" % day_value
			}
		)
		councillor_progress[clean_id] = progress


func record_behavioral_medals(
	day_value: int,
	medals: Array
) -> void:
	for medal_value: Variant in medals:
		if not medal_value is Dictionary:
			continue
		var medal: Dictionary = medal_value as Dictionary
		var representative_id: String = String(
			medal.get("representative_id", "")
		).strip_edges()
		var medal_id: String = String(medal.get("id", "")).strip_edges()
		if representative_id.is_empty() or medal_id.is_empty():
			continue
		ensure_councillor(
			representative_id,
			String(medal.get("display_name", "")),
			day_value
		)
		var progress: Dictionary = councillor_progress[representative_id]
		var stored_medals: Array = progress.get("behavioral_medals", [])
		var already_recorded: bool = false
		for stored_value: Variant in stored_medals:
			if not stored_value is Dictionary:
				continue
			var stored: Dictionary = stored_value as Dictionary
			if int(stored.get("day", 0)) == day_value:
				already_recorded = true
				break
		if already_recorded:
			continue
		var award: Dictionary = medal.duplicate(true)
		award["day"] = day_value
		stored_medals.append(award)
		progress["behavioral_medals"] = stored_medals
		_append_history_entry(progress, {
			"day": day_value,
			"type": "behavioral_medal",
			"title": "Recebeu a medalha %s" % String(
				medal.get("name", "Comportamental")
			),
			"medal_id": medal_id
		})
		councillor_progress[representative_id] = progress


func get_production_history_between(
	start_day_exclusive: int,
	end_day_inclusive: int
) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in production_history:
		var day_value: int = int(entry.get("day", 0))
		if day_value > start_day_exclusive and day_value <= end_day_inclusive:
			result.append(entry.duplicate(true))
	return result


func get_decision_history() -> Array[Dictionary]:
	return decision_history.duplicate(true)


func calculate_prepared_construction_site_capacity(
	population_value: int
) -> int:
	return clampi(
		1 + floori(
			float(maxi(0, population_value))
			/ float(CONSTRUCTION_POPULATION_STEP)
		),
		1,
		MAX_CONSTRUCTION_SITES
	)


func get_prepared_construction_work_days(
	is_house: bool,
	target_level: int
) -> int:
	if is_house:
		return 1
	return clampi(target_level, 1, 3)


func enqueue_construction_blueprint(
	building_id: String,
	requested_day: int,
	work_days: int,
	paid_cost: float
) -> Dictionary:
	# Contrato aposentado na Etapa 2. Os argumentos permanecem para que
	# ferramentas antigas falhem de forma explícita, sem criar uma segunda fila.
	var ignored: Array = [building_id, requested_day, work_days, paid_cost]
	if ignored.is_empty():
		return {}
	return {
		"success": false,
		"message": (
			"A fila preparatória foi aposentada. Use VillageBuildingManager."
		)
	}


func choose_building_variant(
	building_id: String,
	variant_id: String,
	chosen_day: int
) -> Dictionary:
	var clean_building_id: String = building_id.strip_edges()
	var clean_variant_id: String = variant_id.strip_edges()
	if clean_building_id.is_empty() or clean_variant_id.is_empty() or chosen_day < 1:
		return {
			"success": false,
			"message": "A variante preparada é inválida."
		}
	if building_variants.has(clean_building_id):
		return {
			"success": false,
			"message": "A variante desta construção já foi escolhida e é irreversível."
		}

	building_variants[clean_building_id] = {
		"variant_id": clean_variant_id,
		"chosen_day": chosen_day
	}
	return {
		"success": true,
		"message": "Variante registrada de forma irreversível."
	}


func export_save_data() -> Dictionary:
	return {
		"foundation_state_version": FOUNDATION_STATE_VERSION,
		"foundation_schema_id": FOUNDATION_SCHEMA_ID,
		"campaign_seed": campaign_seed,
		"generator_version": generator_version,
		"production_history": production_history.duplicate(true),
		"decision_history": decision_history.duplicate(true),
		"event_flags": event_flags.duplicate(true),
		"councillor_progress": councillor_progress.duplicate(true),
		"construction_queue": construction_queue.duplicate(true),
		"building_variants": building_variants.duplicate(true),
		"strategy_metrics": strategy_metrics.duplicate(true),
		"next_decision_sequence": next_decision_sequence,
		"next_queue_sequence": next_queue_sequence
	}


func import_save_data(save_data: Dictionary) -> bool:
	var saved_state_version: int = int(
		save_data.get("foundation_state_version", 0)
	)
	if saved_state_version not in [3, FOUNDATION_STATE_VERSION]:
		return false
	if String(save_data.get("foundation_schema_id", "")) != FOUNDATION_SCHEMA_ID:
		return false

	for key: String in [
		"production_history",
		"decision_history",
		"construction_queue"
	]:
		if not save_data.get(key, null) is Array:
			return false

	for key: String in [
		"event_flags",
		"councillor_progress",
		"building_variants",
		"strategy_metrics"
	]:
		if not save_data.get(key, null) is Dictionary:
			return false

	var loaded_production: Array = save_data.get("production_history", [])
	var loaded_decisions: Array = save_data.get("decision_history", [])
	var loaded_queue: Array = save_data.get("construction_queue", [])
	if loaded_production.size() > MAX_PRODUCTION_HISTORY:
		return false
	if loaded_decisions.size() > MAX_DECISION_HISTORY:
		return false

	campaign_seed = _sanitize_seed(int(save_data.get("campaign_seed", 0)))
	generator_version = maxi(
		1,
		int(
			save_data.get(
				"generator_version",
				VillageCampaignIdentityCatalog.GENERATOR_VERSION
			)
		)
	)
	production_history.clear()
	for entry_value: Variant in loaded_production:
		if not entry_value is Dictionary:
			return false
		production_history.append((entry_value as Dictionary).duplicate(true))

	decision_history.clear()
	for entry_value: Variant in loaded_decisions:
		if not entry_value is Dictionary:
			return false
		decision_history.append((entry_value as Dictionary).duplicate(true))

	construction_queue.clear()
	for entry_value: Variant in loaded_queue:
		if not entry_value is Dictionary:
			return false
		construction_queue.append((entry_value as Dictionary).duplicate(true))

	event_flags = (save_data.get("event_flags", {}) as Dictionary).duplicate(true)
	councillor_progress = (
		save_data.get("councillor_progress", {}) as Dictionary
	).duplicate(true)
	for councillor_id_value: Variant in councillor_progress.keys():
		var councillor_id: String = String(councillor_id_value)
		var progress_value: Variant = councillor_progress.get(councillor_id, null)
		if progress_value is Dictionary:
			var progress: Dictionary = progress_value as Dictionary
			if not progress.get("behavioral_medals", null) is Array:
				progress["behavioral_medals"] = []
			councillor_progress[councillor_id] = progress
	building_variants = (
		save_data.get("building_variants", {}) as Dictionary
	).duplicate(true)
	next_decision_sequence = maxi(
		1,
		int(save_data.get("next_decision_sequence", 1))
	)
	next_queue_sequence = maxi(
		1,
		int(save_data.get("next_queue_sequence", 1))
	)
	_rebuild_strategy_metrics()
	return bool(validate_current_state().get("success", false))


func validate_current_state() -> Dictionary:
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var seen_days: Dictionary = {}
	for entry: Dictionary in production_history:
		var day_value: int = int(entry.get("day", 0))
		if day_value < 1:
			errors.append("Histórico de produção possui dia inválido.")
		elif seen_days.has(day_value):
			errors.append("Histórico de produção repete o dia %d." % day_value)
		else:
			seen_days[day_value] = true

	var previous_sequence: int = 0
	for entry: Dictionary in decision_history:
		var sequence: int = int(entry.get("sequence", 0))
		if sequence <= previous_sequence:
			errors.append("Histórico de decisões perdeu a ordem sequencial.")
			break
		previous_sequence = sequence

	if not construction_queue.is_empty():
		errors.append(
			"A fila preparatória antiga deve permanecer vazia na Etapa 2."
		)

	for councillor_id_value: Variant in councillor_progress.keys():
		var councillor_id: String = String(councillor_id_value).strip_edges()
		var progress_value: Variant = councillor_progress.get(councillor_id, null)
		if councillor_id.is_empty() or not progress_value is Dictionary:
			errors.append("Registro histórico de conselheiro inválido.")
			continue
		var progress: Dictionary = progress_value as Dictionary
		for required_key: String in [
			"level",
			"xp",
			"lifetime_xp",
			"unspent_attribute_points",
			"attribute_points_spent",
			"joined_day",
			"days_in_council",
			"days_in_reserve",
			"council_projects_started",
			"council_projects_completed",
			"total_production",
			"profession_day_counts",
			"production_milestones",
			"behavioral_medals",
			"history_entries"
		]:
			if not progress.has(required_key):
				errors.append(
					"Histórico de %s não possui o campo %s."
					% [councillor_id, required_key]
				)
		if not progress.get("total_production", null) is Dictionary:
			errors.append("Produção pessoal inválida em %s." % councillor_id)
		if not progress.get("profession_day_counts", null) is Dictionary:
			errors.append("Histórico de profissões inválido em %s." % councillor_id)
		for array_key: String in [
			"production_milestones",
			"behavioral_medals",
			"history_entries"
		]:
			var array_value: Variant = progress.get(array_key, null)
			if not array_value is Array:
				errors.append("Campo %s inválido em %s." % [array_key, councillor_id])
			elif array_key == "history_entries" and array_value.size() > MAX_COUNCILLOR_HISTORY:
				errors.append("Histórico pessoal excede o limite em %s." % councillor_id)
		var level_value: int = int(progress.get("level", 0))
		var xp_value: int = int(progress.get("xp", -1))
		var lifetime_value: int = int(progress.get("lifetime_xp", -1))
		if level_value < 1 or level_value > 6:
			errors.append("Nível histórico inválido em %s." % councillor_id)
		if xp_value < 0 or lifetime_value < xp_value:
			errors.append("Experiência histórica inválida em %s." % councillor_id)

	for building_id_value: Variant in building_variants.keys():
		var building_id: String = String(building_id_value).strip_edges()
		var variant_value: Variant = building_variants.get(building_id, null)
		if building_id.is_empty() or not variant_value is Dictionary:
			errors.append("Registro de variante de construção inválido.")

	if production_history.is_empty():
		warnings.append("A campanha ainda não possui dias registrados.")
	if decision_history.is_empty():
		warnings.append("A campanha ainda não possui decisões registradas.")

	return {
		"success": errors.is_empty(),
		"errors": errors,
		"warnings": warnings,
		"production_days": production_history.size(),
		"decisions": decision_history.size(),
		"event_flags": event_flags.size(),
		"councillors": councillor_progress.size(),
		"queued_blueprints": construction_queue.size(),
		"chosen_variants": building_variants.size()
	}


func get_diagnostic_overview() -> Dictionary:
	var validation: Dictionary = validate_current_state()
	validation["foundation_state_version"] = FOUNDATION_STATE_VERSION
	validation["foundation_schema_id"] = FOUNDATION_SCHEMA_ID
	validation["campaign_seed"] = campaign_seed
	validation["generator_version"] = generator_version
	validation["strategy_metrics"] = strategy_metrics.duplicate(true)
	return validation


func _update_councillor_after_day(
	row: Dictionary,
	day_value: int
) -> void:
	var representative_id: String = String(row.get("representative_id", ""))
	if representative_id.is_empty() or not councillor_progress.has(representative_id):
		return
	var progress: Dictionary = councillor_progress[representative_id]
	var is_active: bool = bool(row.get("is_active", false))
	if is_active:
		progress["days_in_council"] = maxi(
			0,
			int(progress.get("days_in_council", 0)) + 1
		)
	else:
		progress["days_in_reserve"] = maxi(
			0,
			int(progress.get("days_in_reserve", 0)) + 1
		)

	var totals: Dictionary = progress.get("total_production", {})
	var milestones: Array = progress.get("production_milestones", [])
	for resource_id: String in ["food", "material", "happiness"]:
		var previous_total: float = maxf(
			0.0,
			float(totals.get(resource_id, 0.0))
		)
		var new_total: float = maxf(
			0.0,
			previous_total + float(row.get(resource_id, 0.0))
		)
		totals[resource_id] = new_total
		var previous_step: int = floori(previous_total / 100.0)
		var new_step: int = floori(new_total / 100.0)
		for step: int in range(previous_step + 1, new_step + 1):
			var milestone_value: int = step * 100
			var milestone: Dictionary = {
				"day": day_value,
				"representative_id": representative_id,
				"display_name": String(progress.get("display_name", "Conselheiro")),
				"resource_id": resource_id,
				"value": milestone_value
			}
			milestones.append(milestone.duplicate(true))
			newly_reached_milestones.append(milestone.duplicate(true))
			_append_history_entry(
				progress,
				{
					"day": day_value,
					"type": "production_milestone",
					"title": "Alcançou %d de %s" % [milestone_value, resource_id],
					"resource_id": resource_id,
					"value": milestone_value
				}
			)
	progress["total_production"] = totals
	progress["production_milestones"] = milestones

	if is_active:
		var profession: int = int(row.get("profession", -1))
		var profession_history: Array = progress.get("profession_history", [])
		if profession_history.is_empty() or int(profession_history.back()) != profession:
			profession_history.append(profession)
		progress["profession_history"] = profession_history
		var profession_day_counts: Dictionary = progress.get(
			"profession_day_counts",
			{}
		)
		var profession_key: String = str(profession)
		profession_day_counts[profession_key] = maxi(
			0,
			int(profession_day_counts.get(profession_key, 0)) + 1
		)
		progress["profession_day_counts"] = profession_day_counts
	councillor_progress[representative_id] = progress


func _attribute_display_name(attribute_id: String) -> String:
	match attribute_id:
		"strength": return "Força"
		"intelligence": return "Inteligência"
		"charisma": return "Carisma"
		"agility": return "Agilidade"
		_: return "Atributo"


func _append_history_entry(
	progress: Dictionary,
	entry: Dictionary
) -> void:
	var history: Array = progress.get("history_entries", [])
	history.append(entry.duplicate(true))
	while history.size() > MAX_COUNCILLOR_HISTORY:
		history.pop_front()
	progress["history_entries"] = history


func _rebuild_strategy_metrics() -> void:
	var rebuilt: Dictionary = _create_empty_strategy_metrics()
	var total_production: Dictionary = rebuilt["total_production"]
	var shortage_days: Dictionary = rebuilt["shortage_days"]
	var profession_day_counts: Dictionary = rebuilt["profession_day_counts"]

	for entry: Dictionary in production_history:
		rebuilt["recorded_days"] = int(rebuilt["recorded_days"]) + 1
		var production: Dictionary = entry.get("production", {})
		for resource_id: String in ["food", "material", "happiness"]:
			total_production[resource_id] = float(
				total_production.get(resource_id, 0.0)
			) + float(production.get(resource_id, 0.0))

		var shortages: Dictionary = entry.get("shortages", {})
		for resource_id: String in ["food", "material"]:
			if float(shortages.get(resource_id, 0.0)) > 0.0:
				shortage_days[resource_id] = int(
					shortage_days.get(resource_id, 0)
				) + 1

		var profession_counts: Dictionary = entry.get("profession_counts", {})
		var local_peak: int = 0
		for profession_id_value: Variant in profession_counts.keys():
			var profession_id: String = String(profession_id_value)
			var count: int = int(profession_counts[profession_id_value])
			profession_day_counts[profession_id] = int(
				profession_day_counts.get(profession_id, 0)
			) + count
			local_peak = maxi(local_peak, count)
		rebuilt["max_same_profession"] = maxi(
			int(rebuilt.get("max_same_profession", 0)),
			local_peak
		)

	var decision_categories: Dictionary = rebuilt["decision_categories"]
	for entry: Dictionary in decision_history:
		var category: String = String(entry.get("category", "unknown"))
		decision_categories[category] = int(
			decision_categories.get(category, 0)
		) + 1

	rebuilt["total_production"] = total_production
	rebuilt["shortage_days"] = shortage_days
	rebuilt["profession_day_counts"] = profession_day_counts
	rebuilt["decision_categories"] = decision_categories
	strategy_metrics = rebuilt


func _create_empty_strategy_metrics() -> Dictionary:
	return {
		"recorded_days": 0,
		"total_production": {
			"food": 0.0,
			"material": 0.0,
			"happiness": 0.0
		},
		"shortage_days": {
			"food": 0,
			"material": 0
		},
		"profession_day_counts": {},
		"max_same_profession": 0,
		"decision_categories": {}
	}


func _has_production_day(day_value: int) -> bool:
	for entry: Dictionary in production_history:
		if int(entry.get("day", 0)) == day_value:
			return true
	return false


func _sanitize_count_dictionary(value: Variant) -> Dictionary:
	var result: Dictionary = {}
	if not value is Dictionary:
		return result
	var source: Dictionary = value
	for key_value: Variant in source.keys():
		var clean_key: String = String(key_value).strip_edges()
		if clean_key.is_empty():
			continue
		result[clean_key] = maxi(0, int(source[key_value]))
	return result


func _sanitize_seed(value: int) -> int:
	if value > 0:
		return VillageCampaignIdentityCatalog.sanitize_seed(value)
	return VillageCampaignIdentityCatalog.generate_seed()
