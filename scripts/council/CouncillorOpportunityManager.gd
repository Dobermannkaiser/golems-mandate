class_name CouncillorOpportunityManager
extends RefCounted


const STATE_VERSION: int = 1
const FIRST_OPPORTUNITY_DAY: int = 4
const OPPORTUNITY_INTERVAL_DAYS: int = 4
const INDIVIDUAL_COOLDOWN_DAYS: int = 10
const COMPLETION_XP: int = 6

const OPPORTUNITY_CATALOG_SCRIPT = preload(
	"res://scripts/council/CouncillorOpportunityCatalog.gd"
)


var pending_opportunity: Dictionary = {}
var active_projects: Array[Dictionary] = []
var completed_projects: Array[Dictionary] = []
var next_opportunity_day: int = FIRST_OPPORTUNITY_DAY
var next_sequence: int = 1
var representative_last_opportunity_day: Dictionary = {}
var representative_last_template_id: Dictionary = {}
var used_template_ids: Array[String] = []


func setup() -> void:
	pending_opportunity.clear()
	active_projects.clear()
	completed_projects.clear()
	next_opportunity_day = FIRST_OPPORTUNITY_DAY
	next_sequence = 1
	representative_last_opportunity_day.clear()
	representative_last_template_id.clear()
	used_template_ids.clear()


func has_pending_opportunity() -> bool:
	return not pending_opportunity.is_empty()


func has_pending_for(representative_id: String) -> bool:
	return (
		not pending_opportunity.is_empty()
		and String(pending_opportunity.get("representative_id", ""))
		== representative_id.strip_edges()
	)


func get_pending_opportunity() -> Dictionary:
	return pending_opportunity.duplicate(true)


func get_pending_for(representative_id: String) -> Dictionary:
	return (
		pending_opportunity.duplicate(true)
		if has_pending_for(representative_id)
		else {}
	)


func try_prepare_opportunity(
	day_value: int,
	campaign_seed: int,
	active_councillors: Array[Dictionary]
) -> Dictionary:
	if (
		day_value < next_opportunity_day
		or not pending_opportunity.is_empty()
		or not active_projects.is_empty()
		or active_councillors.is_empty()
	):
		return {}
	var eligible: Array[Dictionary] = []
	for row: Dictionary in active_councillors:
		if not _councillor_has_unused_template(row):
			continue
		var candidate_representative_id: String = String(
			row.get("representative_id", "")
		).strip_edges()
		if candidate_representative_id.is_empty() or not bool(row.get("is_active", true)):
			continue
		var last_day: int = int(
			representative_last_opportunity_day.get(candidate_representative_id, -9999)
		)
		if day_value - last_day >= INDIVIDUAL_COOLDOWN_DAYS:
			eligible.append(row.duplicate(true))
	if eligible.is_empty():
		for row: Dictionary in active_councillors:
			if _councillor_has_unused_template(row):
				eligible.append(row.duplicate(true))
	if eligible.is_empty():
		next_opportunity_day = day_value + OPPORTUNITY_INTERVAL_DAYS
		return {}
	eligible.sort_custom(_sort_councillors)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = maxi(1, campaign_seed + day_value * 3571 + next_sequence * 7919)
	var selection_pool_size: int = mini(2, eligible.size())
	var selected_index: int = rng.randi_range(0, selection_pool_size - 1)
	var selected: Dictionary = eligible[selected_index]
	var representative_id: String = String(
		selected.get("representative_id", "")
	)
	var profession: int = int(
		selected.get("profession", Villager.Profession.UNASSIGNED)
	)
	var templates: Array[Dictionary] = (
		OPPORTUNITY_CATALOG_SCRIPT.get_templates_for_profession(profession)
	)
	var available_templates: Array[Dictionary] = []
	for template: Dictionary in templates:
		var template_id: String = String(template.get("id", ""))
		if not used_template_ids.has(template_id):
			available_templates.append(template.duplicate(true))
	if available_templates.is_empty():
		next_opportunity_day = day_value + OPPORTUNITY_INTERVAL_DAYS
		return {}
	var template: Dictionary = available_templates[
		rng.randi_range(0, available_templates.size() - 1)
	]
	var choices_value: Variant = template.get("choices", [])
	if not choices_value is Array:
		return {}
	var choices: Array[Dictionary] = []
	for choice_value: Variant in choices_value as Array:
		if choice_value is Dictionary:
			choices.append((choice_value as Dictionary).duplicate(true))
	_shuffle_choices(choices, rng)
	var opportunity_id: String = "council_opportunity_%03d" % next_sequence
	next_sequence += 1
	pending_opportunity = {
		"opportunity_id": opportunity_id,
		"template_id": String(template.get("id", "")),
		"title": String(template.get("title", "Assunto do Conselho")),
		"representative_id": representative_id,
		"display_name": String(selected.get("display_name", "Conselheiro")),
		"portrait_id": String(selected.get("portrait_id", "")),
		"personality_id": String(selected.get("personality_id", "practical")),
		"profession": profession,
		"available_day": day_value,
		"choices": choices
	}
	representative_last_opportunity_day[representative_id] = day_value
	representative_last_template_id[representative_id] = String(
		template.get("id", "")
	)
	return pending_opportunity.duplicate(true)


func resolve_choice(
	opportunity_id: String,
	representative_id: String,
	choice_id: String,
	day_value: int
) -> Dictionary:
	if pending_opportunity.is_empty():
		return {"success": false, "message": "Não há assunto pendente."}
	if (
		String(pending_opportunity.get("opportunity_id", ""))
		!= opportunity_id.strip_edges()
		or String(pending_opportunity.get("representative_id", ""))
		!= representative_id.strip_edges()
	):
		return {"success": false, "message": "A resposta não pertence a este assunto."}
	var template_id: String = String(pending_opportunity.get("template_id", ""))
	var choice: Dictionary = OPPORTUNITY_CATALOG_SCRIPT.get_choice(
		template_id,
		choice_id.strip_edges()
	)
	if choice.is_empty():
		return {"success": false, "message": "A decisão escolhida não existe."}
	var duration_days: int = clampi(int(choice.get("duration_days", 2)), 2, 3)
	var project: Dictionary = {
		"project_id": String(pending_opportunity.get("opportunity_id", "")),
		"template_id": template_id,
		"title": String(pending_opportunity.get("title", "Projeto do Conselho")),
		"representative_id": String(
			pending_opportunity.get("representative_id", "")
		),
		"display_name": String(pending_opportunity.get("display_name", "Conselheiro")),
		"choice_id": String(choice.get("id", "")),
		"choice_text": String(choice.get("text", "")),
		"start_day": day_value,
		"end_day": day_value + duration_days - 1,
		"duration_days": duration_days,
		"immediate": (choice.get("immediate", {}) as Dictionary).duplicate(true),
		"modifiers": (choice.get("modifiers", {}) as Dictionary).duplicate(true),
		"completion_text": String(
			choice.get("completion", "O projeto foi concluído.")
		)
	}
	active_projects.append(project)
	if not used_template_ids.has(template_id):
		used_template_ids.append(template_id)
	pending_opportunity.clear()
	next_opportunity_day = maxi(
		day_value + OPPORTUNITY_INTERVAL_DAYS,
		int(project.get("end_day", day_value)) + 1
	)
	return {
		"success": true,
		"project": project.duplicate(true),
		"immediate": (project.get("immediate", {}) as Dictionary).duplicate(true),
		"message": (
			"%s iniciou “%s”. O efeito permanece até o fim do dia %d."
			% [
				String(project.get("display_name", "O representante")),
				String(project.get("title", "Projeto do Conselho")),
				int(project.get("end_day", day_value))
			]
		)
	}


func cancel_pending_for(representative_id: String, day_value: int) -> Dictionary:
	if not has_pending_for(representative_id):
		return {}
	var cancelled: Dictionary = pending_opportunity.duplicate(true)
	pending_opportunity.clear()
	next_opportunity_day = mini(next_opportunity_day, day_value + 1)
	return cancelled


func get_modifiers_for_day(day_value: int) -> Dictionary:
	var result: Dictionary = {
		"food_production_multiplier": 1.0,
		"material_production_multiplier": 1.0,
		"happiness_production_multiplier": 1.0,
		"food_consumption_multiplier": 1.0,
		"material_maintenance_multiplier": 1.0,
		"happiness_decay_multiplier": 1.0,
		"daily_happiness_bonus": 0.0
	}
	for project: Dictionary in active_projects:
		var start_day: int = int(project.get("start_day", 0))
		var end_day: int = int(project.get("end_day", 0))
		if day_value < start_day or day_value > end_day:
			continue
		var modifiers: Dictionary = project.get("modifiers", {})
		for key: String in [
			"food_production_multiplier",
			"material_production_multiplier",
			"happiness_production_multiplier",
			"food_consumption_multiplier",
			"material_maintenance_multiplier",
			"happiness_decay_multiplier"
		]:
			result[key] = float(result.get(key, 1.0)) * float(
				modifiers.get(key, 1.0)
			)
		result["daily_happiness_bonus"] = float(
			result.get("daily_happiness_bonus", 0.0)
		) + float(modifiers.get("daily_happiness_bonus", 0.0))
	return result


func complete_projects_for_day(completed_day: int) -> Array[Dictionary]:
	var completed: Array[Dictionary] = []
	var remaining: Array[Dictionary] = []
	for project: Dictionary in active_projects:
		if int(project.get("end_day", 0)) <= completed_day:
			var finished: Dictionary = project.duplicate(true)
			finished["completed_day"] = completed_day
			completed.append(finished)
			completed_projects.append(finished)
		else:
			remaining.append(project)
	active_projects = remaining
	while completed_projects.size() > 48:
		completed_projects.pop_front()
	return completed


func get_active_project_for(representative_id: String, day_value: int) -> Dictionary:
	var clean_id: String = representative_id.strip_edges()
	for project: Dictionary in active_projects:
		if (
			String(project.get("representative_id", "")) == clean_id
			and day_value >= int(project.get("start_day", 0))
			and day_value <= int(project.get("end_day", 0))
		):
			return project.duplicate(true)
	return {}


func get_overview(day_value: int) -> Dictionary:
	var active: Array[Dictionary] = []
	for project: Dictionary in active_projects:
		if day_value <= int(project.get("end_day", 0)):
			active.append(project.duplicate(true))
	return {
		"pending": pending_opportunity.duplicate(true),
		"active_projects": active,
		"next_opportunity_day": next_opportunity_day,
		"used_template_ids": used_template_ids.duplicate(),
		"remaining_unique_templates": maxi(
			0,
			OPPORTUNITY_CATALOG_SCRIPT.OPPORTUNITIES.size()
			- used_template_ids.size()
		),
		"completion_xp": COMPLETION_XP
	}


func export_save_data() -> Dictionary:
	return {
		"state_version": STATE_VERSION,
		"pending_opportunity": pending_opportunity.duplicate(true),
		"active_projects": active_projects.duplicate(true),
		"completed_projects": completed_projects.duplicate(true),
		"next_opportunity_day": next_opportunity_day,
		"next_sequence": next_sequence,
		"representative_last_opportunity_day": (
			representative_last_opportunity_day.duplicate(true)
		),
		"representative_last_template_id": (
			representative_last_template_id.duplicate(true)
		),
		"used_template_ids": used_template_ids.duplicate()
	}


func import_save_data(save_data: Dictionary) -> bool:
	if int(save_data.get("state_version", 0)) != STATE_VERSION:
		return false
	for key: String in ["pending_opportunity"]:
		if not save_data.get(key, null) is Dictionary:
			return false
	for key: String in ["active_projects", "completed_projects"]:
		if not save_data.get(key, null) is Array:
			return false
	for key: String in [
		"representative_last_opportunity_day",
		"representative_last_template_id"
	]:
		if not save_data.get(key, null) is Dictionary:
			return false
	if not save_data.get("used_template_ids", null) is Array:
		return false
	pending_opportunity = (
		(save_data.get("pending_opportunity", {}) as Dictionary).duplicate(true)
	)
	active_projects.clear()
	for value: Variant in save_data.get("active_projects", []) as Array:
		if not value is Dictionary:
			return false
		active_projects.append((value as Dictionary).duplicate(true))
	completed_projects.clear()
	for value: Variant in save_data.get("completed_projects", []) as Array:
		if not value is Dictionary:
			return false
		completed_projects.append((value as Dictionary).duplicate(true))
	next_opportunity_day = maxi(
		FIRST_OPPORTUNITY_DAY,
		int(save_data.get("next_opportunity_day", FIRST_OPPORTUNITY_DAY))
	)
	next_sequence = maxi(1, int(save_data.get("next_sequence", 1)))
	var last_days: Dictionary = save_data.get(
		"representative_last_opportunity_day",
		{}
	) as Dictionary
	var last_templates: Dictionary = save_data.get(
		"representative_last_template_id",
		{}
	) as Dictionary
	representative_last_opportunity_day = last_days.duplicate(true)
	representative_last_template_id = last_templates.duplicate(true)
	used_template_ids.clear()
	for template_id_value: Variant in save_data.get("used_template_ids", []) as Array:
		var template_id: String = String(template_id_value).strip_edges()
		if not template_id.is_empty() and not used_template_ids.has(template_id):
			used_template_ids.append(template_id)
	return validate_state().is_empty()


func validate_state() -> Array[String]:
	var errors: Array[String] = []
	if next_opportunity_day < FIRST_OPPORTUNITY_DAY:
		errors.append("Próximo dia de oportunidade inválido.")
	if next_sequence < 1:
		errors.append("Sequência de oportunidades inválida.")
	if not pending_opportunity.is_empty():
		for key: String in [
			"opportunity_id",
			"template_id",
			"representative_id",
			"available_day",
			"choices"
		]:
			if not pending_opportunity.has(key):
				errors.append("Oportunidade pendente sem %s." % key)
	for template_id: String in used_template_ids:
		if OPPORTUNITY_CATALOG_SCRIPT.get_template(template_id).is_empty():
			errors.append("Modelo usado não existe: %s." % template_id)
	for project: Dictionary in active_projects:
		if int(project.get("start_day", 0)) < 1:
			errors.append("Projeto possui dia inicial inválido.")
		if int(project.get("end_day", 0)) < int(project.get("start_day", 0)):
			errors.append("Projeto possui duração inválida.")
		if not project.get("modifiers", null) is Dictionary:
			errors.append("Projeto possui modificadores inválidos.")
	return errors


func _councillor_has_unused_template(row: Dictionary) -> bool:
	if not bool(row.get("is_active", true)):
		return false
	var profession: int = int(
		row.get("profession", Villager.Profession.UNASSIGNED)
	)
	for template: Dictionary in (
		OPPORTUNITY_CATALOG_SCRIPT.get_templates_for_profession(profession)
	):
		if not used_template_ids.has(String(template.get("id", ""))):
			return true
	return false


static func _sort_councillors(a: Dictionary, b: Dictionary) -> bool:
	var id_a: String = String(a.get("representative_id", ""))
	var id_b: String = String(b.get("representative_id", ""))
	return id_a < id_b


static func _shuffle_choices(
	choices: Array[Dictionary],
	rng: RandomNumberGenerator
) -> void:
	for index: int in range(choices.size() - 1, 0, -1):
		var swap_index: int = rng.randi_range(0, index)
		var temporary: Dictionary = choices[index]
		choices[index] = choices[swap_index]
		choices[swap_index] = temporary
