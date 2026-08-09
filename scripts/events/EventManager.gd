class_name VillageEventManager
extends RefCounted


const EVENT_CATALOG_SCRIPT = preload(
	"res://scripts/events/EventCatalog.gd"
)

const STORY_CHAPTER_CATALOG_SCRIPT = preload(
	"res://scripts/story/StoryChapterCatalog.gd"
)

const EVENT_CHANCE: float = 0.525
const MAX_DAYS_WITHOUT_EVENT: int = 2
const RECENT_EVENT_LIMIT: int = 5


var active_event: Dictionary = {}
var used_event_ids: Array[String] = []
var recent_event_ids: Array[String] = []
var days_without_event: int = 0

var event_catalog: Array[Dictionary] = []
var events_by_id: Dictionary = {}
var external_event_ids: Array[String] = []
var event_random: RandomNumberGenerator = RandomNumberGenerator.new()
var campaign_seed: int = 1


func setup(new_campaign_seed: int = 0) -> void:
	configure_seed(new_campaign_seed)
	event_catalog = EVENT_CATALOG_SCRIPT.create()
	events_by_id.clear()

	for event_data: Dictionary in event_catalog:
		var event_id: String = String(
			event_data.get(
				"id",
				""
			)
		)

		if not event_id.is_empty():
			events_by_id[event_id] = event_data

	for story_event: Dictionary in (
		STORY_CHAPTER_CATALOG_SCRIPT.create_story_events()
	):
		var story_event_id: String = String(
			story_event.get("id", "")
		)
		if not story_event_id.is_empty():
			events_by_id[story_event_id] = story_event

	active_event.clear()
	used_event_ids.clear()
	recent_event_ids.clear()
	external_event_ids.clear()
	days_without_event = 0


func configure_seed(new_campaign_seed: int) -> void:
	campaign_seed = maxi(1, new_campaign_seed)
	event_random.seed = campaign_seed + 104729


func set_external_events(events: Array[Dictionary]) -> bool:
	for event_id: String in external_event_ids:
		events_by_id.erase(event_id)
	external_event_ids.clear()

	for event_data: Dictionary in events:
		var event_id: String = String(event_data.get("id", "")).strip_edges()
		if event_id.is_empty() or events_by_id.has(event_id):
			return false
		events_by_id[event_id] = event_data.duplicate(true)
		external_event_ids.append(event_id)
	return true


func has_active_event() -> bool:
	return not active_event.is_empty()


func get_active_event() -> Dictionary:
	return active_event.duplicate(true)


func export_save_data() -> Dictionary:
	var active_event_id: String = ""
	var triggered_after_day: int = 0

	if has_active_event():
		active_event_id = String(
			active_event.get(
				"id",
				""
			)
		)

		triggered_after_day = int(
			active_event.get(
				"triggered_after_day",
				0
			)
		)

	return {
		"active_event_id": active_event_id,
		"triggered_after_day": triggered_after_day,
		"used_event_ids": used_event_ids.duplicate(),
		"recent_event_ids": recent_event_ids.duplicate(),
		"days_without_event": days_without_event,
		"campaign_seed": campaign_seed,
		"rng_state": str(event_random.state)
	}


func import_save_data(save_data: Dictionary) -> bool:
	var saved_used_ids_value: Variant = save_data.get(
		"used_event_ids",
		[]
	)

	if not saved_used_ids_value is Array:
		return false

	var active_event_id: String = String(
		save_data.get(
			"active_event_id",
			""
		)
	)

	var restored_event: Dictionary = {}

	if not active_event_id.is_empty():
		restored_event = _find_event(
			active_event_id
		)

		if restored_event.is_empty():
			return false

	active_event.clear()
	used_event_ids.clear()
	recent_event_ids.clear()

	for event_id_value: Variant in saved_used_ids_value:
		var event_id: String = String(event_id_value)

		if (
			not event_id.is_empty()
			and not _find_event(event_id).is_empty()
			and not used_event_ids.has(event_id)
		):
			used_event_ids.append(event_id)

	var saved_recent_value: Variant = save_data.get("recent_event_ids", [])
	if not saved_recent_value is Array:
		return false
	for event_id_value: Variant in saved_recent_value as Array:
		var event_id: String = String(event_id_value).strip_edges()
		if (
			event_id.is_empty()
			or _find_event(event_id).is_empty()
			or recent_event_ids.has(event_id)
		):
			return false
		recent_event_ids.append(event_id)
	if recent_event_ids.size() > RECENT_EVENT_LIMIT:
		return false

	days_without_event = clampi(
		int(
			save_data.get(
				"days_without_event",
				0
			)
		),
		0,
		MAX_DAYS_WITHOUT_EVENT
	)
	var saved_seed: int = maxi(1, int(save_data.get("campaign_seed", campaign_seed)))
	if saved_seed != campaign_seed:
		configure_seed(saved_seed)
	var rng_state_text: String = String(save_data.get("rng_state", ""))
	if rng_state_text.is_valid_int():
		event_random.state = int(rng_state_text)

	if active_event_id.is_empty():
		return true

	active_event = restored_event.duplicate(true)
	active_event["triggered_after_day"] = maxi(
		1,
		int(
			save_data.get(
				"triggered_after_day",
				1
			)
		)
	)

	if not used_event_ids.has(active_event_id):
		used_event_ids.append(active_event_id)
	_record_recent_event(active_event_id)

	return true


func get_choice_state(
	choice_id: String,
	villager: Villager,
	food: float,
	material: float,
	happiness: float,
	context: Dictionary = {}
) -> Dictionary:
	var choice: Dictionary = _find_active_event_choice(
		choice_id
	)

	if choice.is_empty():
		return {
			"available": false,
			"reason": "Esta escolha não existe.",
			"has_test": false,
			"chance": 0.0
		}

	var requirement_result: Dictionary = (
		_validate_choice_requirements(choice, context)
	)
	if not bool(requirement_result.get("available", false)):
		return {
			"available": false,
			"reason": String(
				requirement_result.get(
					"reason",
					"Esta opção ainda não está disponível."
				)
			),
			"has_test": _choice_has_test(choice),
			"chance": calculate_success_chance(choice, villager)
		}

	var requires_villager: bool = bool(
		choice.get(
			"requires_villager",
			false
		)
	)

	if (
		requires_villager
		and not is_instance_valid(villager)
	):
		return {
			"available": false,
			"reason": (
				"Selecione um habitante responsável."
			),
			"has_test": true,
			"chance": 0.0
		}

	var costs: Dictionary = choice.get(
		"costs",
		{}
	)

	var missing_resources: Array[String] = []
	var food_cost: float = float(
		costs.get("food", 0.0)
	)

	var material_cost: float = float(
		costs.get("material", 0.0)
	)

	var happiness_cost: float = float(
		costs.get("happiness", 0.0)
	)

	if food + 0.001 < food_cost:
		missing_resources.append("alimentação")

	if material + 0.001 < material_cost:
		missing_resources.append("material")

	if happiness + 0.001 < happiness_cost:
		missing_resources.append("felicidade")

	if not missing_resources.is_empty():
		return {
			"available": false,
			"reason": (
				"Recursos insuficientes: "
				+ ", ".join(missing_resources)
				+ "."
			),
			"has_test": _choice_has_test(choice),
			"chance": calculate_success_chance(
				choice,
				villager
			)
		}

	return {
		"available": true,
		"reason": "",
		"has_test": _choice_has_test(choice),
		"chance": calculate_success_chance(
			choice,
			villager
		)
	}


func calculate_success_chance(
	choice: Dictionary,
	villager: Villager
) -> float:
	if not _choice_has_test(choice):
		return 1.0

	var chance: float = float(
		choice.get(
			"base_chance",
			0.50
		)
	)

	var attribute_name: String = String(
		choice.get(
			"test_attribute",
			""
		)
	)

	if (
		not attribute_name.is_empty()
		and is_instance_valid(villager)
	):
		var attribute_value: int = (
			_get_villager_attribute(
				villager,
				attribute_name
			)
		)

		chance += (
			float(attribute_value)
			* float(
				choice.get(
					"chance_per_point",
					0.0
				)
			)
		)
		if villager.passive_id == "improvisador":
			chance += 0.05

	return clampf(
		chance,
		float(
			choice.get(
				"min_chance",
				0.05
			)
		),
		float(
			choice.get(
				"max_chance",
				0.95
			)
		)
	)


func resolve_choice(
	choice_id: String,
	villager: Villager,
	food: float,
	material: float,
	happiness: float,
	context: Dictionary = {}
) -> Dictionary:
	if not has_active_event():
		return {"resolved": false}

	var choice: Dictionary = _find_active_event_choice(
		choice_id
	)

	if choice.is_empty():
		return {"resolved": false}

	var choice_state: Dictionary = get_choice_state(
		choice_id,
		villager,
		food,
		material,
		happiness,
		context
	)

	if not bool(choice_state["available"]):
		return {"resolved": false}

	var resolved_event: Dictionary = active_event.duplicate(true)
	var resolved_choice: Dictionary = choice.duplicate(true)
	var succeeded: bool = true

	var combined_effects: Dictionary = {}
	_add_costs_to_effects(
		combined_effects,
		choice.get("costs", {})
	)

	var result_text: String = ""
	var tested_villager_name: String = ""

	if _choice_has_test(choice):
		var success_chance: float = float(
			choice_state["chance"]
		)

		succeeded = (
			event_random.randf() <= success_chance
		)

		if is_instance_valid(villager):
			tested_villager_name = (
				villager.villager_name
			)

		if succeeded:
			_add_effects(
				combined_effects,
				choice.get(
					"success_effects",
					{}
				)
			)

			result_text = String(
				choice.get(
					"success_text",
					"A tentativa foi bem-sucedida."
				)
			)
		else:
			var failure_effects: Dictionary = (
				(choice.get("failure_effects", {}) as Dictionary).duplicate(true)
			)
			if is_instance_valid(villager) and villager.passive_id == "protetor":
				for effect_key: Variant in failure_effects.keys():
					var effect_value: float = float(failure_effects[effect_key])
					if effect_value < 0.0:
						failure_effects[effect_key] = effect_value * 0.85
			_add_effects(
				combined_effects,
				failure_effects
			)

			result_text = String(
				choice.get(
					"failure_text",
					"A tentativa fracassou."
				)
			)
	else:
		_add_effects(
			combined_effects,
			choice.get("effects", {})
		)

		result_text = String(
			choice.get(
				"result_text",
				"A decisão foi cumprida."
			)
		)

	var event_title: String = String(
		active_event.get(
			"title",
			"Acontecimento"
		)
	)

	active_event.clear()

	return {
		"resolved": true,
		"event_title": event_title,
		"result_text": result_text,
		"tested_villager_name": tested_villager_name,
		"effects": combined_effects,
		"event_data": resolved_event,
		"choice_data": resolved_choice,
		"choice_id": choice_id,
		"succeeded": succeeded,
		"is_story_event": bool(
			resolved_event.get("is_story_event", false)
		)
	}


func start_forced_event(
	event_data: Dictionary,
	completed_day: int
) -> Dictionary:
	if event_data.is_empty() or has_active_event():
		return {}

	var event_id: String = String(event_data.get("id", "")).strip_edges()
	if event_id.is_empty():
		return {}

	active_event = event_data.duplicate(true)
	active_event["triggered_after_day"] = completed_day
	if not used_event_ids.has(event_id):
		used_event_ids.append(event_id)
	_record_recent_event(event_id)
	days_without_event = 0
	return active_event.duplicate(true)


func clear_active_event() -> void:
	active_event.clear()


func try_start_event(
	completed_day: int
) -> Dictionary:
	if event_catalog.is_empty() or has_active_event():
		return {}

	var should_start: bool = completed_day == 1

	if not should_start:
		should_start = (
			days_without_event
			>= MAX_DAYS_WITHOUT_EVENT
		)

	if not should_start:
		should_start = (
			event_random.randf() <= EVENT_CHANCE
		)

	if not should_start:
		days_without_event += 1
		return {}

	var candidates: Array[Dictionary] = (
		_get_unused_event_candidates(
			completed_day
		)
	)

	if candidates.is_empty():
		candidates = _get_event_candidates(
			completed_day
		)
	elif _all_candidates_are_recent(candidates):
		var all_candidates: Array[Dictionary] = _get_event_candidates(
			completed_day
		)
		for candidate: Dictionary in all_candidates:
			if not recent_event_ids.has(String(candidate.get("id", ""))):
				candidates = all_candidates
				break

	var non_recent_candidates: Array[Dictionary] = []
	for candidate: Dictionary in candidates:
		if not recent_event_ids.has(String(candidate.get("id", ""))):
			non_recent_candidates.append(candidate)
	if not non_recent_candidates.is_empty():
		candidates = non_recent_candidates

	if candidates.is_empty():
		days_without_event += 1
		return {}

	var selected_index: int = (
		event_random.randi_range(
			0,
			candidates.size() - 1
		)
	)

	active_event = _prepare_event_for_day(
		candidates[selected_index],
		completed_day
	)

	active_event["triggered_after_day"] = (
		completed_day
	)

	var event_id: String = String(
		active_event["id"]
	)

	if not used_event_ids.has(event_id):
		used_event_ids.append(event_id)
	_record_recent_event(event_id)

	days_without_event = 0
	return active_event.duplicate(true)


func _get_unused_event_candidates(
	completed_day: int
) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []

	for event_data: Dictionary in event_catalog:
		var event_id: String = String(
			event_data.get("id", "")
		)

		if (
			_event_is_available(
				event_data,
				completed_day
			)
			and not used_event_ids.has(event_id)
		):
			candidates.append(event_data)

	return candidates


func _all_candidates_are_recent(candidates: Array[Dictionary]) -> bool:
	if candidates.is_empty():
		return false
	for candidate: Dictionary in candidates:
		if not recent_event_ids.has(String(candidate.get("id", ""))):
			return false
	return true


func _get_event_candidates(
	completed_day: int
) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []

	for event_data: Dictionary in event_catalog:
		if _event_is_available(
			event_data,
			completed_day
		):
			candidates.append(event_data)

	return candidates


func _event_is_available(
	event_data: Dictionary,
	completed_day: int
) -> bool:
	if int(
		event_data.get("min_day", 1)
	) > completed_day:
		return false

	var required_season_id: String = String(
		event_data.get(
			"season_id",
			""
		)
	)

	if required_season_id.is_empty():
		return true

	var current_season: Dictionary = (
		VillageCampaignCatalog.get_season_for_day(
			completed_day
		)
	)

	return required_season_id == String(
		current_season.get("id", "")
	)


func _validate_choice_requirements(
	choice: Dictionary,
	context: Dictionary
) -> Dictionary:
	if bool(context.get("debug_unlock_story_choices", false)):
		return {"available": true, "reason": ""}

	var required_building: String = String(
		choice.get("required_building", "")
	).strip_edges()
	if not required_building.is_empty():
		var building_levels: Dictionary = context.get("building_levels", {})
		var required_level: int = int(
			choice.get("required_building_level", 1)
		)
		var current_level: int = int(
			building_levels.get(required_building, 0)
		)
		if current_level < required_level:
			return {
				"available": false,
				"reason": "Exige %s no nível %d." % [
					_get_building_display_name(required_building),
					required_level
				]
			}

	var required_variant: String = String(
		choice.get("required_building_variant", "")
	).strip_edges()
	if not required_variant.is_empty():
		var building_variants: Dictionary = context.get(
			"building_variants",
			{}
		)
		var variant_found: bool = false
		for selected_value: Variant in building_variants.values():
			if String(selected_value) == required_variant:
				variant_found = true
				break
		if not variant_found:
			return {
				"available": false,
				"reason": "Exige a build %s." % (
					_get_variant_display_name(required_variant)
				)
			}

	if choice.has("required_profession"):
		var required_profession: int = int(
			choice.get("required_profession", -1)
		)
		var active_professions: Array = context.get("active_professions", [])
		if not active_professions.has(required_profession):
			return {
				"available": false,
				"reason": "Exige %s no Conselho." % (
					Villager.get_profession_name(required_profession)
				)
			}

	var required_relationship_id: String = String(
		choice.get("required_relationship_id", "")
	).strip_edges()
	if not required_relationship_id.is_empty():
		var relationship_points: Dictionary = context.get(
			"relationship_points",
			{}
		)
		var required_relationship_points: int = int(
			choice.get("required_relationship_points", 0)
		)
		if int(relationship_points.get(required_relationship_id, 0)) < (
			required_relationship_points
		):
			var relationship_name: String = String(
				choice.get("required_relationship_name", "este personagem")
			)
			return {
				"available": false,
				"reason": "Exige %d pontos de amizade com %s." % [
					required_relationship_points,
					relationship_name
				]
			}

	if (
		bool(choice.get("requires_official_partner", false))
		and String(context.get("official_partner_id", "")).is_empty()
	):
		return {
			"available": false,
			"reason": "Exige ter assumido um compromisso romântico."
		}

	var required_known_npcs: int = int(
		choice.get("required_known_npcs", 0)
	)
	if required_known_npcs > int(context.get("known_story_npcs", 0)):
		return {
			"available": false,
			"reason": "Exige conhecer todos os aliados dos capítulos."
		}

	return {"available": true, "reason": ""}


func _prepare_event_for_day(
	event_data: Dictionary,
	completed_day: int
) -> Dictionary:
	var prepared: Dictionary = event_data.duplicate(true)
	if bool(prepared.get("is_story_event", false)):
		return prepared

	var season: Dictionary = (
		VillageCampaignCatalog.get_season_for_day(completed_day)
	)
	var season_id: String = String(season.get("id", "spring"))
	var season_name: String = String(
		season.get("display_name", "Primavera")
	)
	prepared["active_season_id"] = season_id
	prepared["active_season_name"] = season_name

	if String(prepared.get("season_id", "")).is_empty():
		var base_description: String = String(
			prepared.get("description", "")
		)
		prepared["description"] = "%s\n\n%s" % [
			base_description,
			_get_seasonal_event_context(season_id)
		]
	return prepared


func _get_seasonal_event_context(season_id: String) -> String:
	match season_id:
		"summer":
			return "O calor do Verão agita a mana e torna criaturas mágicas mais ousadas."
		"autumn":
			return "No Outono, folhas rúnicas e espíritos da colheita alteram o acontecimento."
		"winter":
			return "O frio do Inverno cristaliza feitiços e torna qualquer decisão mais urgente."
		_:
			return "A Primavera desperta fadas, brotos encantados e magia adormecida."


func _get_variant_display_name(variant_id: String) -> String:
	match variant_id:
		"silo_reserve":
			return "Silo de Reserva"
		"community_kitchen":
			return "Cozinha Comunitária"
		"intensive_sawmill":
			return "Serraria Intensiva"
		"carpentry_workshop":
			return "Oficina de Carpintaria"
		"deep_reservoir":
			return "Reservatório Profundo"
		"community_fountain":
			return "Fonte Comunitária"
		"community_market":
			return "Mercado Comunitário"
		"public_garden":
			return "Jardim Público"
		"stone_bastion":
			return "Bastião de Pedra"
		"vigilant_gates":
			return "Portões Vigilantes"
		_:
			return "build necessária"


func _get_building_display_name(building_id: String) -> String:
	match building_id:
		"barn":
			return "Celeiro"
		"sawmill":
			return "Serraria"
		"well":
			return "Poço"
		"square":
			return "Praça"
		"palisade":
			return "Muralha"
		_:
			return "construção necessária"


func _find_active_event_choice(
	choice_id: String
) -> Dictionary:
	if not has_active_event():
		return {}

	var choices: Array = active_event.get(
		"choices",
		[]
	)

	for choice_value: Variant in choices:
		var choice: Dictionary = choice_value

		if String(choice.get("id", "")) == choice_id:
			return choice

	return {}


func _find_event(event_id: String) -> Dictionary:
	var event_data: Dictionary = events_by_id.get(
		event_id,
		{}
	)

	return event_data


func _record_recent_event(event_id: String) -> void:
	var clean_id: String = event_id.strip_edges()
	if clean_id.is_empty():
		return
	recent_event_ids.erase(clean_id)
	recent_event_ids.append(clean_id)
	while recent_event_ids.size() > RECENT_EVENT_LIMIT:
		recent_event_ids.pop_front()


func _choice_has_test(choice: Dictionary) -> bool:
	return choice.has("base_chance")


func _get_villager_attribute(
	villager: Villager,
	attribute_name: String
) -> int:
	match attribute_name:
		"strength":
			return villager.strength

		"intelligence":
			return villager.intelligence

		"charisma":
			return villager.charisma

		"agility":
			return villager.agility

		_:
			return 0


func _add_costs_to_effects(
	target: Dictionary,
	costs: Dictionary
) -> void:
	for resource_name: String in [
		"food",
		"material",
		"happiness"
	]:
		var cost: float = float(
			costs.get(resource_name, 0.0)
		)

		if cost <= 0.0:
			continue

		target[resource_name] = (
			float(
				target.get(
					resource_name,
					0.0
				)
			)
			- cost
		)


func _add_effects(
	target: Dictionary,
	effects: Dictionary
) -> void:
	for resource_name: String in [
		"food",
		"material",
		"happiness"
	]:
		var amount: float = float(
			effects.get(resource_name, 0.0)
		)

		if is_zero_approx(amount):
			continue

		target[resource_name] = (
			float(
				target.get(
					resource_name,
					0.0
				)
			)
			+ amount
		)
