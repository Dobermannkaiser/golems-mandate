extends Node

# A interface observa estes sinais e atualiza somente quando algo muda.
signal resources_changed(
	food_value: float,
	material_value: float,
	happiness_value: float,
	day_value: int
)

signal villagers_changed()
signal council_changed(council_data: Dictionary, result_text: String)
signal day_advanced(summary: String)
signal village_event_started(event_data: Dictionary)
signal village_event_resolved(result_text: String)
signal campaign_progress_changed(progress_data: Dictionary)
signal campaign_checkpoint_completed(progress_data: Dictionary)
signal campaign_finished(result_data: Dictionary)
signal free_play_started(progress_data: Dictionary)
signal season_hint_available(hint_data: Dictionary)
signal buildings_changed(
	building_data: Dictionary,
	result_text: String
)
signal save_state_changed(save_data: Dictionary)
signal game_loaded(load_result: Dictionary)
signal story_dialogue_requested(dialogue_request: Dictionary)
signal story_npc_recruited(npc_data: Dictionary)
signal story_chapter_completed(chapter_data: Dictionary)
signal relationships_changed(relationship_data: Dictionary, result_text: String)
signal recruitment_offer_ready(offer_data: Dictionary)
signal recruitment_completed(candidate_data: Dictionary)
signal recruitment_status_changed(status_data: Dictionary)
signal founder_memory_changed(overview: Dictionary)
signal councillor_level_dialogue_requested(dialogue_request: Dictionary)
signal councillor_history_changed(representative_id: String)
signal councillor_opportunities_changed(overview: Dictionary, result_text: String)
signal npc_relationship_dialogue_requested(dialogue_request: Dictionary)
signal npc_relationships_changed(overview: Dictionary, result_text: String)
signal village_visual_feedback_requested(feedback_data: Dictionary)


# Recursos iniciais.
const INITIAL_FOOD: float = 30.0
const INITIAL_BUILDING_MATERIAL: float = 10.0
const INITIAL_HAPPINESS: float = 60.0
const MAX_HAPPINESS: float = 100.0

# Custos diários por habitante.
const FOOD_CONSUMPTION_PER_VILLAGER: float = 2.10
const MATERIAL_MAINTENANCE_PER_VILLAGER: float = 0.27
const HAPPINESS_DECAY_PER_VILLAGER: float = 0.53
const COMMON_HAPPINESS_DECAY_PER_VILLAGER: float = 0.13

# Produção própria dos habitantes comuns: pequenos cultivos,
# serviços locais e trocas dentro da comunidade.
const COMMON_FOOD_PRODUCTION_PER_VILLAGER: float = 1.55
const COMMON_MATERIAL_PRODUCTION_PER_VILLAGER: float = 0.19

const GROWTH_MINIMUM_HAPPINESS: float = 55.0
const ABANDONMENT_HAPPINESS_THRESHOLD: float = 40.0
const RESOURCE_EPSILON: float = 0.001

# Penalidades por falta de recursos.
const STARVATION_PENALTY_PER_MISSING_FOOD: float = 1.5
const MATERIAL_SHORTAGE_PENALTY: float = 0.5

const EVENT_MANAGER_SCRIPT = preload(
	"res://scripts/events/EventManager.gd"
)

const FOUNDER_MEMORY_MANAGER_SCRIPT = preload(
	"res://scripts/events/FounderMemoryManager.gd"
)

const CAMPAIGN_MANAGER_SCRIPT = preload(
	"res://scripts/campaign/CampaignManager.gd"
)

const DIFFICULTY_CATALOG_SCRIPT = preload(
	"res://scripts/campaign/DifficultyCatalog.gd"
)

const CAMPAIGN_RECORDS_SCRIPT = preload(
	"res://scripts/campaign/CampaignRecords.gd"
)
const CAMPAIGN_IDENTITY_CATALOG_SCRIPT = preload(
	"res://scripts/campaign/CampaignIdentityCatalog.gd"
)
const CAMPAIGN_OUTCOME_CATALOG_SCRIPT = preload(
	"res://scripts/campaign/CampaignOutcomeCatalog.gd"
)

const BUILDING_MANAGER_SCRIPT = preload(
	"res://scripts/buildings/BuildingManager.gd"
)
const BUILDING_VARIANT_CATALOG_SCRIPT = preload(
	"res://scripts/buildings/BuildingVariantCatalog.gd"
)

const SAVE_MANAGER_SCRIPT = preload(
	"res://scripts/save/SaveManager.gd"
)

const FOUNDATION_MANAGER_SCRIPT = preload(
	"res://scripts/foundation/Part2FoundationManager.gd"
)

const PART3_FOUNDATION_MANAGER_SCRIPT = preload(
	"res://scripts/foundation/Part3FoundationManager.gd"
)

const CHARACTER_CATALOG_SCRIPT = preload(
	"res://scripts/dialogue/CharacterCatalog.gd"
)

const COUNCIL_CARD_CATALOG_SCRIPT = preload(
	"res://scripts/council/CouncilCardCatalog.gd"
)

const COUNCIL_PASSIVE_CATALOG_SCRIPT = preload(
	"res://scripts/council/CouncilPassiveCatalog.gd"
)

const COUNCIL_COMPOSITION_CATALOG_SCRIPT = preload(
	"res://scripts/council/CouncilCompositionCatalog.gd"
)

const COUNCILLOR_PERSONALITY_CATALOG_SCRIPT = preload(
	"res://scripts/council/CouncillorPersonalityCatalog.gd"
)

const COUNCILLOR_PROGRESSION_DIALOGUE_CATALOG_SCRIPT = preload(
	"res://scripts/council/CouncillorProgressionDialogueCatalog.gd"
)

const COUNCIL_RECRUITMENT_MANAGER_SCRIPT = preload(
	"res://scripts/council/CouncilRecruitmentManager.gd"
)

const COUNCILLOR_OPPORTUNITY_MANAGER_SCRIPT = preload(
	"res://scripts/council/CouncillorOpportunityManager.gd"
)
const NPC_RELATIONSHIP_MANAGER_SCRIPT = preload(
	"res://scripts/relationships/NpcRelationshipManager.gd"
)

const VILLAGER_SCENE = preload("res://scenes/villager.tscn")

const STORY_MANAGER_SCRIPT = preload(
	"res://scripts/story/StoryManager.gd"
)

const STORY_CHAPTER_CATALOG_SCRIPT = preload(
	"res://scripts/story/StoryChapterCatalog.gd"
)

const ACTIVE_COUNCIL_LIMIT: int = 4
const INITIAL_HELPER_ID: String = "passos_leves_faz_tudo"
const INITIAL_FOUNDER_IDS: Array[String] = [
	"representante_01",
	"representante_02",
	"representante_03",
	"representante_04"
]
const INITIAL_ROSTER_IDS: Array[String] = [
	"representante_01",
	"representante_02",
	"representante_03",
	"representante_04",
	INITIAL_HELPER_ID
]

var food: float = INITIAL_FOOD
var building_material: float = INITIAL_BUILDING_MATERIAL
var happiness: float = INITIAL_HAPPINESS
var current_day: int = 1

var villagers: Array[Villager] = []

var event_manager = EVENT_MANAGER_SCRIPT.new()
var founder_memory_manager = FOUNDER_MEMORY_MANAGER_SCRIPT.new()
var campaign_manager = CAMPAIGN_MANAGER_SCRIPT.new()
var building_manager = BUILDING_MANAGER_SCRIPT.new()
var save_manager = SAVE_MANAGER_SCRIPT.new()
var foundation_manager = FOUNDATION_MANAGER_SCRIPT.new()
var part3_foundation_manager = PART3_FOUNDATION_MANAGER_SCRIPT.new()
var recruitment_manager = COUNCIL_RECRUITMENT_MANAGER_SCRIPT.new()
var councillor_opportunity_manager = COUNCILLOR_OPPORTUNITY_MANAGER_SCRIPT.new()
var story_manager = STORY_MANAGER_SCRIPT.new()
var npc_relationship_manager = NPC_RELATIONSHIP_MANAGER_SCRIPT.new()
var pending_campaign_completed_day: int = 0
var shown_season_hint_ids: Array[String] = []
var enter_game_after_reload: bool = false
var roster_initialized: bool = false
var debug_story_sequence_active: bool = false
var debug_story_snapshot: Dictionary = {}
var pending_level_dialogues: Array[Dictionary] = []
var active_level_dialogue: Dictionary = {}
var pending_level_resume_mode: String = ""


# Objeto usado para transportar os resultados da produção.
class Production:
	var food: float = 0.0
	var material: float = 0.0
	var happiness: float = 0.0


func _ready() -> void:
	# O GameManager é um autoload e existe antes da cena principal.
	# Por isso, não acessamos current_scene durante a inicialização.
	get_tree().node_added.connect(_on_node_added)
	get_tree().node_removed.connect(_on_node_removed)

	part3_foundation_manager.setup()
	event_manager.setup(part3_foundation_manager.campaign_seed)
	founder_memory_manager.setup()
	campaign_manager.setup()
	building_manager.setup()
	foundation_manager.setup()
	recruitment_manager.setup()
	councillor_opportunity_manager.setup()
	story_manager.setup(false)
	npc_relationship_manager.setup()
	call_deferred("_initialize_roster_if_ready")


func _on_node_added(node: Node) -> void:
	if node is Villager:
		register_villager(node as Villager)


func _on_node_removed(node: Node) -> void:
	if node is Villager:
		unregister_villager(node as Villager)


func register_villager(villager: Villager) -> void:
	if not is_instance_valid(villager) or villagers.has(villager):
		return

	for existing: Villager in villagers:
		if (
			is_instance_valid(existing)
			and existing.representative_id == villager.representative_id
		):
			push_error(
				"ID de representante duplicado: %s."
				% villager.representative_id
			)
			return

	villagers.append(villager)

	if not villager.profession_changed.is_connected(
		_on_villager_profession_changed
	):
		villager.profession_changed.connect(
			_on_villager_profession_changed
		)

	villagers_changed.emit()
	call_deferred("_initialize_roster_if_ready")


func _initialize_roster_if_ready() -> void:
	if roster_initialized:
		return

	var roster_by_id: Dictionary = _get_villagers_by_id()
	for expected_id: String in INITIAL_ROSTER_IDS:
		if not roster_by_id.has(expected_id):
			return

	var rng: RandomNumberGenerator = COUNCIL_CARD_CATALOG_SCRIPT.create_rng(
		part3_foundation_manager.campaign_seed
	)
	var founder_names: Array[String] = (
		COUNCIL_CARD_CATALOG_SCRIPT.get_unique_names(
			"Passos-Leves",
			INITIAL_FOUNDER_IDS.size(),
			rng
		)
	)
	var founder_portraits: Array[String] = (
		CHARACTER_CATALOG_SCRIPT.get_founder_appearance_ids()
	)
	_shuffle_strings_with_rng(founder_portraits, rng)
	var founder_passives: Array[Dictionary] = (
		COUNCIL_CARD_CATALOG_SCRIPT.get_randomized_passives(
			INITIAL_FOUNDER_IDS.size(),
			rng
		)
	)
	var personality_ids: Array[String] = (
		COUNCILLOR_PERSONALITY_CATALOG_SCRIPT.get_unique_random_ids(
			INITIAL_FOUNDER_IDS.size(),
			rng
		)
	)

	if founder_names.size() < INITIAL_FOUNDER_IDS.size():
		push_error(
			"O catálogo precisa de ao menos quatro nomes Passos-Leves."
		)
		return
	if founder_portraits.size() < INITIAL_FOUNDER_IDS.size():
		push_error(
			"O catálogo precisa de quatro aparências Passos-Leves para os fundadores."
		)
		return
	if founder_passives.size() < INITIAL_FOUNDER_IDS.size():
		push_error("O catálogo precisa de quatro passivas iniciais.")
		return
	if personality_ids.size() < INITIAL_FOUNDER_IDS.size():
		push_error("O catálogo precisa de quatro personalidades iniciais.")
		return

	for founder_index: int in range(INITIAL_FOUNDER_IDS.size()):
		var founder_id: String = INITIAL_FOUNDER_IDS[founder_index]
		var founder: Villager = roster_by_id[founder_id] as Villager
		if not is_instance_valid(founder):
			return

		var attributes: Dictionary = (
			COUNCIL_CARD_CATALOG_SCRIPT.generate_attributes(rng)
		)
		var passive: Dictionary = founder_passives[founder_index]
		var personality: Dictionary = (
			COUNCILLOR_PERSONALITY_CATALOG_SCRIPT.get_definition(
				personality_ids[founder_index]
			)
		)

		founder.randomize_on_ready = false
		founder.species_name = "Passos-Leves"
		founder.villager_name = founder_names[founder_index]
		founder.portrait_id = founder_portraits[founder_index]
		founder.set_council_active(true)
		founder.specialization = Villager.Profession.UNASSIGNED
		founder.strength = int(attributes.get("strength", 1))
		founder.intelligence = int(attributes.get("intelligence", 1))
		founder.charisma = int(attributes.get("charisma", 1))
		founder.agility = int(attributes.get("agility", 1))
		founder.level = COUNCIL_CARD_CATALOG_SCRIPT.STARTING_LEVEL
		founder.xp = COUNCIL_CARD_CATALOG_SCRIPT.STARTING_XP
		founder.passive_id = String(passive.get("id", ""))
		founder.passive_name = String(
			passive.get("name", "Sem passiva")
		)
		founder.passive_description = String(
			passive.get("description", "")
		)
		founder.personality_id = String(
			personality.get("id", "optimistic")
		)
		founder.personality_name = String(
			personality.get("name", "Otimista")
		)
		founder.personality_description = String(
			personality.get("description", "")
		)

	var helper: Villager = roster_by_id[INITIAL_HELPER_ID] as Villager
	if not is_instance_valid(helper):
		return

	helper.randomize_on_ready = false
	helper.villager_name = "Mimo"
	helper.species_name = "Passos-Leves"
	helper.is_special_npc = true
	helper.strength = 3
	helper.intelligence = 3
	helper.charisma = 3
	helper.agility = 3
	helper.specialization = Villager.Profession.UNASSIGNED
	helper.level = COUNCIL_CARD_CATALOG_SCRIPT.STARTING_LEVEL
	helper.xp = COUNCIL_CARD_CATALOG_SCRIPT.STARTING_XP
	helper.personality_id = "playful"
	helper.personality_name = "Brincalhão"
	helper.personality_description = (
		"Usa humor para aliviar tensão sem ignorar problemas reais."
	)
	helper.passive_id = "faz_tudo"
	helper.portrait_id = "mimo"
	helper.passive_name = "Faz-tudo"
	helper.passive_description = (
		"+5% em qualquer profissão e +5% adicional quando sua "
		+ "profissão é única no Conselho."
	)
	helper.set_council_active(false)

	if get_active_council().size() != ACTIVE_COUNCIL_LIMIT:
		push_error("Não foi possível formar o Conselho inicial.")
		return

	roster_initialized = true
	_sync_foundation_council_ids()
	_sync_part3_councillor_foundation()
	_ensure_founder_memory_initialized()
	villagers_changed.emit()
	council_changed.emit(get_council_overview(), "")


func _ensure_roster_portraits() -> bool:
	var roster_by_id: Dictionary = _get_villagers_by_id()
	var available_portraits: Array[String] = (
		CHARACTER_CATALOG_SCRIPT.get_founder_appearance_ids()
	)
	var used_portraits: Dictionary = {}

	for founder_id: String in INITIAL_FOUNDER_IDS:
		var founder: Villager = roster_by_id.get(founder_id, null) as Villager
		if not is_instance_valid(founder):
			return false

		var current_id: String = founder.portrait_id.strip_edges()
		if (
			current_id.is_empty()
			or not available_portraits.has(current_id)
			or used_portraits.has(current_id)
		):
			founder.portrait_id = ""
			continue

		used_portraits[current_id] = true

	var portrait_rng: RandomNumberGenerator = (
		COUNCIL_CARD_CATALOG_SCRIPT.create_rng(
			part3_foundation_manager.campaign_seed + 1709
		)
	)
	_shuffle_strings_with_rng(available_portraits, portrait_rng)

	for founder_id: String in INITIAL_FOUNDER_IDS:
		var founder: Villager = roster_by_id.get(founder_id, null) as Villager
		if not is_instance_valid(founder):
			return false

		if not founder.portrait_id.is_empty():
			continue

		var assigned_id: String = ""
		for portrait_id: String in available_portraits:
			if not used_portraits.has(portrait_id):
				assigned_id = portrait_id
				break

		if assigned_id.is_empty():
			return false

		founder.portrait_id = assigned_id
		used_portraits[assigned_id] = true

	var helper: Villager = roster_by_id.get(INITIAL_HELPER_ID, null) as Villager
	if not is_instance_valid(helper):
		return false
	helper.portrait_id = "mimo"
	return true


func _shuffle_strings_with_rng(
	values: Array[String],
	rng: RandomNumberGenerator
) -> void:
	for index: int in range(values.size() - 1, 0, -1):
		var swap_index: int = rng.randi_range(0, index)
		var temporary: String = values[index]
		values[index] = values[swap_index]
		values[swap_index] = temporary

func _get_villagers_by_id() -> Dictionary:
	var result: Dictionary = {}
	for villager: Villager in villagers:
		if not is_instance_valid(villager):
			continue
		var representative_id: String = (
			villager.representative_id.strip_edges()
		)
		if representative_id.is_empty():
			continue
		result[representative_id] = villager
	return result


func _has_complete_initial_roster() -> bool:
	var roster_by_id: Dictionary = _get_villagers_by_id()
	for expected_id: String in INITIAL_ROSTER_IDS:
		if not roster_by_id.has(expected_id):
			return false
	return true


func _ensure_founder_memory_initialized() -> bool:
	if not founder_memory_manager.initialize_founders(
		_build_founder_memory_rows()
	):
		return false
	if not event_manager.set_external_events(
		founder_memory_manager.get_registered_events()
	):
		return false
	founder_memory_changed.emit(get_founder_memory_overview())
	return true


func _build_founder_memory_rows() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var roster_by_id: Dictionary = _get_villagers_by_id()
	for founder_id: String in INITIAL_FOUNDER_IDS:
		var founder: Villager = roster_by_id.get(founder_id, null) as Villager
		if not is_instance_valid(founder):
			continue
		rows.append({
			"founder_id": founder.representative_id,
			"founder_name": founder.villager_name,
			"personality_id": founder.personality_id,
			"personality_name": founder.personality_name,
			"passive_id": founder.passive_id,
			"passive_name": founder.passive_name,
			"profession": founder.current_profession,
			"attributes": {
				"strength": founder.strength,
				"intelligence": founder.intelligence,
				"charisma": founder.charisma,
				"agility": founder.agility
			}
		})
	return rows


func get_founder_memory_overview() -> Dictionary:
	return founder_memory_manager.get_overview()


func _build_founder_memory_world_context(day_value: int) -> Dictionary:
	var building_levels: Dictionary = {}
	var building_signature_parts: Array[String] = []
	for building_value: Variant in get_building_state().get("buildings", []):
		if not building_value is Dictionary:
			continue
		var building: Dictionary = building_value as Dictionary
		var building_id: String = String(building.get("id", ""))
		if building_id.is_empty():
			continue
		var level: int = int(building.get("current_level", 0))
		var variant_id: String = String(building.get("current_variant_id", ""))
		building_levels[building_id] = level
		building_signature_parts.append("%s:%d:%s" % [building_id, level, variant_id])
	building_signature_parts.sort()

	var active_ids: Array[String] = []
	var council_signature_parts: Array[String] = []
	var professions: Array[int] = []
	for villager: Villager in get_active_council():
		if not is_instance_valid(villager):
			continue
		active_ids.append(villager.representative_id)
		council_signature_parts.append(
			"%s:%d" % [villager.representative_id, villager.current_profession]
		)
		if not professions.has(villager.current_profession):
			professions.append(villager.current_profession)
	active_ids.sort()
	council_signature_parts.sort()

	var founder_progress: Dictionary = {}
	for founder_id: String in INITIAL_FOUNDER_IDS:
		founder_progress[founder_id] = (
			part3_foundation_manager.get_councillor_history(founder_id)
		)
	var strategy: Dictionary = part3_foundation_manager.strategy_metrics
	var shortage_days: Dictionary = strategy.get("shortage_days", {})
	var season: Dictionary = VillageCampaignCatalog.get_season_for_day(
		maxi(1, day_value)
	)
	return {
		"day": maxi(1, day_value),
		"season_id": String(season.get("id", "spring")),
		"season_name": String(season.get("display_name", "Primavera")),
		"happiness": happiness,
		"building_levels": building_levels,
		"building_variants": building_manager.get_building_variants(),
		"building_signature": "|".join(building_signature_parts),
		"active_council_ids": active_ids,
		"council_signature": "|".join(council_signature_parts),
		"distinct_professions": professions.size(),
		"founder_progress": founder_progress,
		"food_shortage_days": int(shortage_days.get("food", 0)),
		"material_shortage_days": int(shortage_days.get("material", 0))
	}


func get_active_council() -> Array[Villager]:
	var result: Array[Villager] = []
	for villager: Villager in villagers:
		if is_instance_valid(villager) and villager.is_council_active:
			result.append(villager)
	return result


func get_reserve_roster() -> Array[Villager]:
	var result: Array[Villager] = []
	for villager: Villager in villagers:
		if is_instance_valid(villager) and not villager.is_council_active:
			result.append(villager)
	return result


func is_council_ready() -> bool:
	return (
		roster_initialized
		and _has_complete_initial_roster()
		and get_active_council().size() == ACTIVE_COUNCIL_LIMIT
	)


func get_council_overview() -> Dictionary:
	var active: Array[Dictionary] = []
	var reserve: Array[Dictionary] = []
	for villager: Villager in villagers:
		if not is_instance_valid(villager):
			continue
		var data: Dictionary = villager.export_save_data()
		if villager.is_council_active:
			active.append(data)
		else:
			reserve.append(data)
	return {
		"active_limit": ACTIVE_COUNCIL_LIMIT,
		"active": active,
		"reserve": reserve,
		"recruitment": get_recruitment_overview()
	}


func get_recruitment_overview() -> Dictionary:
	return recruitment_manager.get_overview(current_day)


func has_councillor_opportunity(representative_id: String) -> bool:
	return councillor_opportunity_manager.has_pending_for(representative_id)


func get_councillor_opportunity(representative_id: String) -> Dictionary:
	return councillor_opportunity_manager.get_pending_for(representative_id)


func get_councillor_opportunity_overview() -> Dictionary:
	return councillor_opportunity_manager.get_overview(current_day)


func get_active_councillor_project(representative_id: String) -> Dictionary:
	return councillor_opportunity_manager.get_active_project_for(
		representative_id,
		current_day
	)


func resolve_councillor_opportunity_choice(choice_data: Dictionary) -> Dictionary:
	var opportunity_id: String = String(
		choice_data.get("councillor_opportunity_id", "")
	).strip_edges()
	var representative_id: String = String(
		choice_data.get("councillor_representative_id", "")
	).strip_edges()
	var choice_id: String = String(
		choice_data.get("councillor_choice_id", "")
	).strip_edges()
	if opportunity_id.is_empty() or representative_id.is_empty() or choice_id.is_empty():
		return {
			"success": false,
			"message": "A decisão do Conselho está incompleta."
		}
	var villager: Villager = _find_villager_by_representative_id(
		representative_id
	)
	if not is_instance_valid(villager) or not villager.is_council_active:
		return {
			"success": false,
			"message": "A carta responsável precisa estar ativa no Conselho."
		}
	var pending: Dictionary = councillor_opportunity_manager.get_pending_for(
		representative_id
	)
	var immediate_costs: Dictionary = {}
	var choices_value: Variant = pending.get("choices", [])
	if choices_value is Array:
		for choice_value: Variant in choices_value as Array:
			if not choice_value is Dictionary:
				continue
			var pending_choice: Dictionary = choice_value as Dictionary
			if String(pending_choice.get("id", "")) == choice_id:
				immediate_costs = pending_choice.get("immediate", {})
				break
	if (
		food + float(immediate_costs.get("food", 0.0)) < 0.0
		or building_material + float(immediate_costs.get("material", 0.0)) < 0.0
		or happiness + float(immediate_costs.get("happiness", 0.0)) < 0.0
	):
		return {
			"success": false,
			"message": "A vila não possui os recursos exigidos por esta decisão."
		}
	var result: Dictionary = councillor_opportunity_manager.resolve_choice(
		opportunity_id,
		representative_id,
		choice_id,
		current_day
	)
	if not bool(result.get("success", false)):
		return result
	var immediate: Dictionary = result.get("immediate", {})
	food = maxf(0.0, food + float(immediate.get("food", 0.0)))
	building_material = maxf(
		0.0,
		building_material + float(immediate.get("material", 0.0))
	)
	happiness = clampf(
		happiness + float(immediate.get("happiness", 0.0)),
		0.0,
		MAX_HAPPINESS
	)
	var project: Dictionary = result.get("project", {})
	part3_foundation_manager.record_councillor_project_started(
		representative_id,
		String(project.get("title", "Projeto do Conselho")),
		String(project.get("choice_id", choice_id)),
		String(project.get("choice_text", "")),
		int(project.get("end_day", current_day)),
		current_day
	)
	part3_foundation_manager.record_decision(
		current_day,
		"councillor_project",
		"project_started",
		representative_id,
		{
			"project_id": String(project.get("project_id", opportunity_id)),
			"title": String(project.get("title", "Projeto do Conselho")),
			"choice_id": choice_id,
			"end_day": int(project.get("end_day", current_day))
		},
		{
			"food_delta": float(immediate.get("food", 0.0)),
			"material_delta": float(immediate.get("material", 0.0)),
			"happiness_delta": float(immediate.get("happiness", 0.0))
		}
	)
	resources_changed.emit(food, building_material, happiness, current_day)
	councillor_history_changed.emit(representative_id)
	councillor_opportunities_changed.emit(
		get_councillor_opportunity_overview(),
		String(result.get("message", "Projeto iniciado."))
	)
	_autosave_if_enabled()
	return result


func _build_opportunity_councillor_rows() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for villager: Villager in get_active_council():
		if not is_instance_valid(villager):
			continue
		rows.append(
			{
				"representative_id": villager.representative_id,
				"display_name": villager.villager_name,
				"portrait_id": villager.portrait_id,
				"personality_id": villager.personality_id,
				"profession": villager.current_profession,
				"is_active": villager.is_council_active
			}
		)
	return rows


func _try_prepare_councillor_opportunity() -> Dictionary:
	var opportunity: Dictionary = (
		councillor_opportunity_manager.try_prepare_opportunity(
			current_day,
			part3_foundation_manager.campaign_seed,
			_build_opportunity_councillor_rows()
		)
	)
	if not opportunity.is_empty():
		councillor_opportunities_changed.emit(
			get_councillor_opportunity_overview(),
			"%s tem um assunto importante para o Conselho." % String(
				opportunity.get("display_name", "Um representante")
			)
		)
	return opportunity


func _process_completed_councillor_projects(
	completed_day: int
) -> Array[String]:
	var messages: Array[String] = []
	var completed: Array[Dictionary] = (
		councillor_opportunity_manager.complete_projects_for_day(completed_day)
	)
	for project: Dictionary in completed:
		var representative_id: String = String(
			project.get("representative_id", "")
		)
		var villager: Villager = _find_villager_by_representative_id(
			representative_id
		)
		if is_instance_valid(villager):
			_grant_xp_to_villager(
				villager,
				COUNCILLOR_OPPORTUNITY_MANAGER_SCRIPT.COMPLETION_XP,
				"councillor_project_completed",
				completed_day
			)
		part3_foundation_manager.record_councillor_project_completed(
			representative_id,
			String(project.get("title", "Projeto do Conselho")),
			String(project.get("choice_id", "")),
			String(project.get("completion_text", "")),
			completed_day
		)
		part3_foundation_manager.record_decision(
			completed_day,
			"councillor_project",
			"project_completed",
			representative_id,
			{
				"project_id": String(project.get("project_id", "")),
				"choice_id": String(project.get("choice_id", ""))
			},
			{"success": true}
		)
		messages.append(
			"PROJETO CONCLUÍDO — %s recebeu +%d XP. %s" % [
				String(project.get("display_name", "Representante")),
				COUNCILLOR_OPPORTUNITY_MANAGER_SCRIPT.COMPLETION_XP,
				String(project.get("completion_text", "O trabalho foi concluído."))
			]
		)
		councillor_history_changed.emit(representative_id)
	if not completed.is_empty():
		councillor_opportunities_changed.emit(
			get_councillor_opportunity_overview(),
			"Um projeto temporário do Conselho foi concluído."
		)
	return messages


func has_pending_recruitment_offer() -> bool:
	return recruitment_manager.has_pending_offer()


func get_pending_recruitment_offer() -> Dictionary:
	return recruitment_manager.get_pending_offer()


func select_recruitment_species(species_name: String) -> Dictionary:
	var context: Dictionary = _build_recruitment_context()
	var offer: Dictionary = recruitment_manager.select_species(
		species_name,
		part3_foundation_manager.campaign_seed,
		context.get("existing_names", []),
		context.get("existing_passive_ids", [])
	)
	if offer.is_empty():
		return {
			"success": false,
			"message": "A espécie escolhida não pertence à oferta atual."
		}
	recruitment_status_changed.emit(get_recruitment_overview())
	_autosave_if_enabled()
	return {
		"success": true,
		"message": "Duas cartas foram apresentadas.",
		"offer": offer.duplicate(true)
	}


func recheck_pending_recruitment_after_final_audit() -> Dictionary:
	if current_day <= 120:
		return {}
	if recruitment_manager.has_pending_offer():
		return recruitment_manager.get_pending_offer()
	if recruitment_manager.get_pending_checkpoint_days().is_empty():
		return {}
	return _prepare_recruitment_offer(0)


func accept_recruitment_candidate(candidate_id: String) -> Dictionary:
	var offer_before_choice: Dictionary = recruitment_manager.get_pending_offer()
	var candidate: Dictionary = recruitment_manager.accept_candidate(candidate_id)
	if candidate.is_empty():
		return {
			"success": false,
			"message": "A carta escolhida não pertence à oferta atual."
		}
	var recruited: Villager = _create_recruited_villager(candidate)
	if not is_instance_valid(recruited):
		return {
			"success": false,
			"message": "Não foi possível adicionar a carta escolhida à reserva."
		}
	if not recruitment_manager.complete_offer(candidate_id):
		recruited.queue_free()
		return {
			"success": false,
			"message": "A oferta mudou antes da confirmação."
		}
	_sync_foundation_council_ids()
	_sync_part3_councillor_foundation()
	part3_foundation_manager.ensure_councillor(
		recruited.representative_id,
		recruited.villager_name,
		current_day
	)
	var recruited_progress: Dictionary = part3_foundation_manager.get_councillor_history(
		recruited.representative_id
	)
	if not recruited_progress.is_empty():
		recruited_progress["joined_day"] = current_day
		part3_foundation_manager.councillor_progress[
			recruited.representative_id
		] = recruited_progress
	part3_foundation_manager.record_decision(
		current_day,
		"council_recruitment",
		"candidate_selected",
		recruited.representative_id,
		{
			"checkpoint_day": int(offer_before_choice.get("checkpoint_day", 0)),
			"source_npc_id": String(offer_before_choice.get("source_npc_id", "")),
			"source_name": String(offer_before_choice.get("source_name", "")),
			"species_name": recruited.species_name,
			"portrait_id": recruited.portrait_id,
			"candidate_level": recruited.level
		},
		{"success": true}
	)
	var message: String = "%s entrou para a reserva do Conselho." % recruited.villager_name
	recruitment_completed.emit(candidate.duplicate(true))

	# Uma oferta atrasada não apaga as seguintes. Depois da escolha, o sistema
	# tenta preparar imediatamente o próximo recrutamento já desbloqueado.
	var next_offer: Dictionary = _prepare_recruitment_offer(0)
	villagers_changed.emit()
	council_changed.emit(get_council_overview(), message)
	_autosave_if_enabled()
	return {
		"success": true,
		"message": message,
		"candidate": candidate.duplicate(true),
		"next_offer_ready": not next_offer.is_empty()
	}


func _prepare_recruitment_offer(completed_day: int) -> Dictionary:
	var context: Dictionary = _build_recruitment_context()
	var offer: Dictionary = recruitment_manager.prepare_offer(
		completed_day,
		part3_foundation_manager.campaign_seed,
		context.get("relationship_entries", []) as Array,
		context.get("npc_overviews", {}) as Dictionary,
		context.get("existing_names", []),
		context.get("existing_passive_ids", [])
	)
	if not offer.is_empty():
		recruitment_offer_ready.emit(offer.duplicate(true))
	recruitment_status_changed.emit(get_recruitment_overview())
	return offer


func _build_recruitment_context() -> Dictionary:
	var relationship_overview: Dictionary = (
		foundation_manager.get_relationship_overview(current_day, true)
	)
	var entries: Array = []
	var entries_value: Variant = relationship_overview.get("entries", [])
	if entries_value is Array:
		entries = (entries_value as Array).duplicate(true)

	var npc_overviews: Dictionary = {}
	for entry_value: Variant in entries:
		if not entry_value is Dictionary:
			continue
		var npc_id: String = String(
			(entry_value as Dictionary).get("npc_id", "")
		).strip_edges()
		if npc_id.is_empty():
			continue
		npc_overviews[npc_id] = foundation_manager.get_npc_overview(npc_id)

	var existing_names: Array[String] = []
	var existing_passive_ids: Array[String] = []
	for villager: Villager in villagers:
		if not is_instance_valid(villager):
			continue
		existing_names.append(villager.villager_name)
		if (
			villager.passive_id != "faz_tudo"
			and not existing_passive_ids.has(villager.passive_id)
		):
			existing_passive_ids.append(villager.passive_id)
	return {
		"relationship_entries": entries,
		"npc_overviews": npc_overviews,
		"existing_names": existing_names,
		"existing_passive_ids": existing_passive_ids
	}


func _create_recruited_villager(candidate: Dictionary) -> Villager:
	var parent_node: Node = null
	if is_instance_valid(get_tree().current_scene):
		parent_node = get_tree().current_scene.get_node_or_null("World/Villagers")
	if not is_instance_valid(parent_node):
		return null
	var recruited: Villager = VILLAGER_SCENE.instantiate() as Villager
	if not is_instance_valid(recruited):
		return null
	recruited.randomize_on_ready = false
	recruited.representative_id = String(candidate.get("representative_id", ""))
	recruited.villager_name = String(candidate.get("name", "Nova carta"))
	recruited.species_name = String(candidate.get("species_name", "Passos-Leves"))
	recruited.is_council_active = bool(candidate.get("is_council_active", false))
	recruited.is_special_npc = false
	recruited.is_recruited_card = true
	recruited.specialization = Villager.Profession.UNASSIGNED
	recruited.current_profession = int(
		candidate.get("profession", Villager.Profession.UNASSIGNED)
	)
	recruited.portrait_id = String(candidate.get("portrait_id", ""))
	recruited.strength = int(candidate.get("strength", 1))
	recruited.intelligence = int(candidate.get("intelligence", 1))
	recruited.charisma = int(candidate.get("charisma", 1))
	recruited.agility = int(candidate.get("agility", 1))
	recruited.level = int(candidate.get("level", 1))
	recruited.xp = int(candidate.get("xp", 0))
	recruited.lifetime_xp = int(candidate.get("lifetime_xp", 0))
	recruited.unspent_attribute_points = int(
		candidate.get("unspent_attribute_points", 0)
	)
	recruited.attribute_points_spent = int(
		candidate.get("attribute_points_spent", 0)
	)
	recruited.passive_id = String(candidate.get("passive_id", ""))
	recruited.passive_name = String(candidate.get("passive_name", "Sem passiva"))
	recruited.passive_description = String(candidate.get("passive_description", ""))
	recruited.personality_id = String(candidate.get("personality_id", "optimistic"))
	recruited.personality_name = String(candidate.get("personality_name", "Otimista"))
	recruited.personality_description = String(
		candidate.get("personality_description", "")
	)
	recruited.position = Vector2(860.0, 500.0)
	parent_node.add_child(recruited)
	return recruited


func _ensure_dynamic_villagers_for_save(villager_states: Array) -> bool:
	var existing_by_id: Dictionary = _get_villagers_by_id()
	for state_value: Variant in villager_states:
		if not state_value is Dictionary:
			return false
		var state: Dictionary = state_value as Dictionary
		var representative_id: String = String(
			state.get("representative_id", "")
		).strip_edges()
		if representative_id.is_empty():
			return false
		if existing_by_id.has(representative_id):
			continue
		if (
			not bool(state.get("is_recruited_card", false))
			and not representative_id.begins_with("recruta_")
		):
			return false
		var created: Villager = _create_recruited_villager(state)
		if not is_instance_valid(created):
			return false
		existing_by_id[representative_id] = created
	return true


func swap_council_member(
	active_id: String,
	reserve_id: String
) -> Dictionary:
	var clean_active_id: String = active_id.strip_edges()
	var clean_reserve_id: String = reserve_id.strip_edges()
	if (
		clean_active_id.is_empty()
		or clean_reserve_id.is_empty()
		or clean_active_id == clean_reserve_id
	):
		return {
			"success": false,
			"message": "A troca escolhida não é válida."
		}

	if get_active_council().size() != ACTIVE_COUNCIL_LIMIT:
		return {
			"success": false,
			"message": (
				"O Conselho precisa ter quatro membros antes da troca."
			)
		}

	var outgoing: Villager = null
	var incoming: Villager = null
	for villager: Villager in villagers:
		if not is_instance_valid(villager):
			continue
		if (
			villager.representative_id == clean_active_id
			and villager.is_council_active
		):
			outgoing = villager
		elif (
			villager.representative_id == clean_reserve_id
			and not villager.is_council_active
		):
			incoming = villager

	if not is_instance_valid(outgoing) or not is_instance_valid(incoming):
		return {
			"success": false,
			"message": "A troca escolhida não é válida."
		}

	var inherited_profession: int = outgoing.current_profession
	var cancelled_opportunity: Dictionary = (
		councillor_opportunity_manager.cancel_pending_for(
			outgoing.representative_id,
			current_day
		)
	)
	outgoing.set_council_active(false)
	incoming.set_council_active(true)
	incoming.set_profession(inherited_profession)

	if get_active_council().size() != ACTIVE_COUNCIL_LIMIT:
		incoming.set_council_active(false)
		outgoing.set_council_active(true)
		return {
			"success": false,
			"message": "A troca foi cancelada para preservar o Conselho."
		}

	_sync_foundation_council_ids()
	part3_foundation_manager.record_decision(
		current_day,
		"council_swap",
		"swap_member",
		incoming.representative_id,
		{
			"outgoing_id": outgoing.representative_id,
			"incoming_id": incoming.representative_id,
			"inherited_profession": inherited_profession
		},
		{"success": true}
	)
	var message: String = (
		"%s entrou no Conselho no lugar de %s."
		% [incoming.villager_name, outgoing.villager_name]
	)
	if not cancelled_opportunity.is_empty():
		message += (
			" O assunto pendente de %s foi arquivado e uma nova oportunidade poderá surgir."
			% outgoing.villager_name
		)
		councillor_opportunities_changed.emit(
			get_councillor_opportunity_overview(),
			message
		)
	villagers_changed.emit()
	council_changed.emit(get_council_overview(), message)
	_autosave_if_enabled()
	return {"success": true, "message": message}


func _sync_foundation_council_ids() -> void:
	foundation_manager.active_representative_ids.clear()
	foundation_manager.reserve_representative_ids.clear()
	foundation_manager.population_state.set_protected_named_resident_count(
		villagers.size()
	)

	for villager: Villager in villagers:
		if not is_instance_valid(villager):
			continue
		var representative_id: String = (
			villager.representative_id.strip_edges()
		)
		if representative_id.is_empty():
			continue
		if villager.is_council_active:
			foundation_manager.active_representative_ids.append(
				representative_id
			)
		else:
			foundation_manager.reserve_representative_ids.append(
				representative_id
			)


func _sync_part3_councillor_foundation() -> void:
	for villager: Villager in villagers:
		if not is_instance_valid(villager):
			continue
		part3_foundation_manager.ensure_councillor(
			villager.representative_id,
			villager.villager_name,
			1
		)
		part3_foundation_manager.synchronize_councillor_progression(
			villager.representative_id,
			villager.level,
			villager.xp,
			villager.unspent_attribute_points,
			villager.lifetime_xp,
			villager.attribute_points_spent
		)


func unregister_villager(villager: Villager) -> void:
	if not villagers.has(villager):
		return

	villagers.erase(villager)
	if not _has_complete_initial_roster():
		roster_initialized = false
	villagers_changed.emit()


func _on_villager_profession_changed(
	_new_profession: int
) -> void:
	_autosave_if_enabled()


func get_current_difficulty_id() -> String:
	return VillageDifficultyCatalog.sanitize_difficulty_id(
		foundation_manager.player_profile.difficulty_id
	)


func get_current_difficulty_rules() -> Dictionary:
	return DIFFICULTY_CATALOG_SCRIPT.get_difficulty(
		get_current_difficulty_id()
	)


func get_current_difficulty_name() -> String:
	return DIFFICULTY_CATALOG_SCRIPT.get_display_name(
		get_current_difficulty_id()
	)


func calculate_villager_production(
	villager: Villager
) -> Production:
	var result: Production = _calculate_villager_personal_output(villager)

	result.food *= (
		1.0
		+ building_manager.get_effect_value(
			"food_production_bonus"
		)
	)

	result.material *= (
		1.0
		+ building_manager.get_effect_value(
			"material_production_bonus"
		)
	)

	return result


func _calculate_villager_personal_output(
	villager: Villager
) -> Production:
	var result: Production = Production.new()
	if not is_instance_valid(villager):
		return result

	var efficiency: float = 0.0
	match villager.current_profession:
		Villager.Profession.FARMER:
			efficiency = (
				float(villager.agility) * 0.60
				+ float(villager.intelligence) * 0.40
			)
			result.food = 1.0 + efficiency * 0.90

		Villager.Profession.BLACKSMITH:
			efficiency = (
				float(villager.strength) * 0.70
				+ float(villager.intelligence) * 0.30
			)
			result.material = 0.5 + efficiency * 0.60

		Villager.Profession.CIVIL_SERVANT:
			efficiency = (
				float(villager.charisma) * 0.70
				+ float(villager.intelligence) * 0.30
			)
			result.happiness = efficiency * 0.35

		Villager.Profession.GUARD:
			efficiency = (
				float(villager.strength) * 0.50
				+ float(villager.agility) * 0.50
			)
			result.happiness = efficiency * 0.20

		Villager.Profession.GATHERER:
			efficiency = (
				float(villager.agility) * 0.50
				+ float(villager.strength) * 0.30
				+ float(villager.intelligence) * 0.20
			)
			result.food = 0.4 + efficiency * 0.35
			result.material = 0.2 + efficiency * 0.25

		_:
			pass

	var passive_overview: Dictionary = get_villager_passive_overview(villager)
	var personal_multiplier: float = (
		1.0
		+ villager.get_specialization_bonus()
		+ float(passive_overview.get("production_multiplier_bonus", 0.0))
	)
	result.food *= personal_multiplier
	result.material *= personal_multiplier
	result.happiness *= personal_multiplier
	result.happiness += float(
		passive_overview.get("daily_happiness_bonus", 0.0)
	)

	return result


func _calculate_recorded_personal_production(
	villager: Villager,
	day_value: int
) -> Production:
	var result: Production = _calculate_villager_personal_output(villager)
	var season_modifiers: Dictionary = (
		VillageCampaignCatalog.get_season_modifiers_for_day(day_value)
	)
	result.food *= float(
		season_modifiers.get("food_production_multiplier", 1.0)
	)
	result.material *= float(
		season_modifiers.get("material_production_multiplier", 1.0)
	)
	return result


func _calculate_total_production_internal(apply_composition: bool) -> Production:
	var total: Production = Production.new()

	for villager: Villager in villagers:
		if not is_instance_valid(villager) or not villager.is_council_active:
			continue

		var individual: Production = (
			calculate_villager_production(villager)
		)

		total.food += individual.food
		total.material += individual.material
		total.happiness += individual.happiness

	var common_population: float = float(
		get_common_population()
	)
	var food_bonus: float = (
		1.0
		+ building_manager.get_effect_value(
			"food_production_bonus"
		)
	)
	var material_bonus: float = (
		1.0
		+ building_manager.get_effect_value(
			"material_production_bonus"
		)
	)

	total.food += (
		common_population
		* COMMON_FOOD_PRODUCTION_PER_VILLAGER
		* food_bonus
	)
	total.material += (
		common_population
		* COMMON_MATERIAL_PRODUCTION_PER_VILLAGER
		* material_bonus
	)

	total.happiness += (
		building_manager.get_effect_value(
			"daily_happiness_bonus"
		)
	)

	var season_modifiers: Dictionary = (
		get_current_season_modifiers()
	)

	total.food *= float(
		season_modifiers.get(
			"food_production_multiplier",
			1.0
		)
	)
	total.material *= float(
		season_modifiers.get(
			"material_production_multiplier",
			1.0
		)
	)

	var estimated_food_consumption: float = maxf(
		0.0,
		float(get_total_population())
		* get_effective_food_consumption_per_villager()
		- _get_council_fixed_food_reduction_for_day(current_day)
		- _get_building_fixed_food_reduction_for_day(current_day)
	)
	var relationship_modifiers: Dictionary = (
		foundation_manager.get_relationship_management_modifiers({
			"food_balance_negative": (
				total.food - estimated_food_consumption < -0.001
			)
		})
	)
	total.food *= 1.0 + float(
		relationship_modifiers.get("food_production_bonus", 0.0)
	)
	total.material *= 1.0 + float(
		relationship_modifiers.get("material_production_bonus", 0.0)
	)
	total.happiness += float(
		relationship_modifiers.get("daily_happiness_bonus", 0.0)
	)

	var opportunity_modifiers: Dictionary = (
		councillor_opportunity_manager.get_modifiers_for_day(current_day)
	)
	total.food *= float(
		opportunity_modifiers.get("food_production_multiplier", 1.0)
	)
	total.material *= float(
		opportunity_modifiers.get("material_production_multiplier", 1.0)
	)
	total.happiness *= float(
		opportunity_modifiers.get("happiness_production_multiplier", 1.0)
	)
	total.happiness += float(
		opportunity_modifiers.get("daily_happiness_bonus", 0.0)
	)

	var difficulty_rules: Dictionary = get_current_difficulty_rules()
	var difficulty_production: float = float(
		difficulty_rules.get("production_multiplier", 1.0)
	)
	total.food *= difficulty_production
	total.material *= difficulty_production
	total.happiness *= difficulty_production

	if apply_composition:
		_apply_council_composition_to_production(total)
	return total


func calculate_total_production() -> Production:
	return _calculate_total_production_internal(true)


func get_council_effects_overview() -> Dictionary:
	var base_total: Production = _calculate_total_production_internal(false)
	var base_values: Dictionary = {
		"food": base_total.food,
		"material": base_total.material,
		"happiness": base_total.happiness
	}
	var synergy_overview: Dictionary = (
		COUNCIL_COMPOSITION_CATALOG_SCRIPT.select_synergies(
			get_active_council(),
			base_values
		)
	)
	var active_synergies: Array = synergy_overview.get("active", [])
	var synergy_modifiers: Dictionary = (
		COUNCIL_COMPOSITION_CATALOG_SCRIPT.get_combined_modifiers(
			active_synergies
		)
	)
	var concentration: Dictionary = (
		COUNCIL_COMPOSITION_CATALOG_SCRIPT.get_concentration_overview(
			get_active_council()
		)
	)
	var all_bonus: float = float(
		synergy_modifiers.get("all_production_multiplier_bonus", 0.0)
	)
	var npc_relationship_bonus: float = npc_relationship_manager.get_production_bonus()
	all_bonus += npc_relationship_bonus
	var final_food: float = base_total.food * (
		1.0
		+ all_bonus
		+ float(synergy_modifiers.get("food_multiplier_bonus", 0.0))
	)
	var final_material: float = base_total.material * (
		1.0
		+ all_bonus
		+ float(synergy_modifiers.get("material_multiplier_bonus", 0.0))
	)
	var final_happiness: float = (
		base_total.happiness * (1.0 + all_bonus)
		+ float(synergy_modifiers.get("happiness_bonus", 0.0))
	)
	var concentration_multiplier: float = float(
		concentration.get("multiplier", 1.0)
	)
	final_food *= concentration_multiplier
	final_material *= concentration_multiplier
	final_happiness *= concentration_multiplier
	return {
		"passives": get_council_passive_rows(),
		"synergies": synergy_overview,
		"synergy_modifiers": synergy_modifiers,
		"concentration": concentration,
		"npc_relationship_synergy": {
			"active": npc_relationship_bonus > 0.0,
			"value": npc_relationship_bonus,
			"description": "Afinidade entre personagens: +1% em toda produção do Conselho."
		},
		"base_production": base_values,
		"final_production": {
			"food": final_food,
			"material": final_material,
			"happiness": final_happiness
		}
	}


func _apply_council_composition_to_production(total: Production) -> void:
	var overview: Dictionary = get_council_effects_overview()
	var final_values: Dictionary = overview.get("final_production", {})
	total.food = maxf(0.0, float(final_values.get("food", total.food)))
	total.material = maxf(0.0, float(final_values.get("material", total.material)))
	total.happiness = maxf(0.0, float(final_values.get("happiness", total.happiness)))


func _build_part3_councillor_production_rows(day_value: int) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var council_effects: Dictionary = get_council_effects_overview()
	var council_base: Dictionary = council_effects.get("base_production", {})
	var council_final: Dictionary = council_effects.get("final_production", {})
	var relationship_modifiers: Dictionary = (
		foundation_manager.get_relationship_management_modifiers({})
	)
	var opportunity_modifiers: Dictionary = (
		councillor_opportunity_manager.get_modifiers_for_day(day_value)
	)
	var difficulty_multiplier: float = float(
		get_current_difficulty_rules().get("production_multiplier", 1.0)
	)
	var season_modifiers: Dictionary = (
		VillageCampaignCatalog.get_season_modifiers_for_day(day_value)
	)
	for villager: Villager in villagers:
		if not is_instance_valid(villager):
			continue
		var attribute_output: Production = Production.new()
		var personal_output: Production = Production.new()
		var before_synergy: Production = Production.new()
		var final_output: Production = Production.new()
		var passive_overview: Dictionary = {}
		if villager.is_council_active:
			attribute_output = _calculate_villager_attribute_output(villager)
			personal_output = _calculate_villager_personal_output(villager)
			before_synergy = calculate_villager_production(villager)
			before_synergy.food *= float(
				season_modifiers.get("food_production_multiplier", 1.0)
			)
			before_synergy.material *= float(
				season_modifiers.get("material_production_multiplier", 1.0)
			)
			before_synergy.food *= 1.0 + float(
				relationship_modifiers.get("food_production_bonus", 0.0)
			)
			before_synergy.material *= 1.0 + float(
				relationship_modifiers.get("material_production_bonus", 0.0)
			)
			before_synergy.happiness += float(
				relationship_modifiers.get("daily_happiness_bonus", 0.0)
			) / float(maxi(1, get_active_council().size()))
			before_synergy.food *= float(
				opportunity_modifiers.get("food_production_multiplier", 1.0)
			) * difficulty_multiplier
			before_synergy.material *= float(
				opportunity_modifiers.get("material_production_multiplier", 1.0)
			) * difficulty_multiplier
			before_synergy.happiness *= float(
				opportunity_modifiers.get("happiness_production_multiplier", 1.0)
			) * difficulty_multiplier
			final_output.food = before_synergy.food * _safe_contribution_multiplier(
				float(council_base.get("food", 0.0)),
				float(council_final.get("food", 0.0))
			)
			final_output.material = before_synergy.material * _safe_contribution_multiplier(
				float(council_base.get("material", 0.0)),
				float(council_final.get("material", 0.0))
			)
			final_output.happiness = before_synergy.happiness * _safe_contribution_multiplier(
				float(council_base.get("happiness", 0.0)),
				float(council_final.get("happiness", 0.0))
			)
			passive_overview = get_villager_passive_overview(villager)
		rows.append(
			{
				"representative_id": villager.representative_id,
				"display_name": villager.villager_name,
				"profession": villager.current_profession,
				"profession_name": Villager.get_profession_name(
					villager.current_profession
				),
				"is_active": villager.is_council_active,
				"food": final_output.food,
				"material": final_output.material,
				"happiness": final_output.happiness,
				"attribute_base": {
					"food": attribute_output.food,
					"material": attribute_output.material,
					"happiness": attribute_output.happiness
				},
				"personal_bonus": {
					"food": maxf(0.0, personal_output.food - attribute_output.food),
					"material": maxf(0.0, personal_output.material - attribute_output.material),
					"happiness": maxf(0.0, personal_output.happiness - attribute_output.happiness)
				},
				"global_bonus": {
					"food": maxf(0.0, final_output.food - personal_output.food),
					"material": maxf(0.0, final_output.material - personal_output.material),
					"happiness": maxf(0.0, final_output.happiness - personal_output.happiness)
				},
				"specialization_bonus": villager.get_specialization_bonus(),
				"passive_id": villager.passive_id,
				"passive_active": bool(passive_overview.get("active", false)),
				"output_scope": "estimated_final_personal_contribution_with_shared_bonuses"
			}
		)
	return rows


func _calculate_villager_attribute_output(villager: Villager) -> Production:
	var result: Production = Production.new()
	if not is_instance_valid(villager):
		return result
	var efficiency: float = 0.0
	match villager.current_profession:
		Villager.Profession.FARMER:
			efficiency = float(villager.agility) * 0.60 + float(villager.intelligence) * 0.40
			result.food = 1.0 + efficiency * 0.90
		Villager.Profession.BLACKSMITH:
			efficiency = float(villager.strength) * 0.70 + float(villager.intelligence) * 0.30
			result.material = 0.5 + efficiency * 0.60
		Villager.Profession.CIVIL_SERVANT:
			efficiency = float(villager.charisma) * 0.70 + float(villager.intelligence) * 0.30
			result.happiness = efficiency * 0.35
		Villager.Profession.GUARD:
			efficiency = float(villager.strength) * 0.50 + float(villager.agility) * 0.50
			result.happiness = efficiency * 0.20
		Villager.Profession.GATHERER:
			efficiency = (
				float(villager.agility) * 0.50
				+ float(villager.strength) * 0.30
				+ float(villager.intelligence) * 0.20
			)
			result.food = 0.4 + efficiency * 0.35
			result.material = 0.2 + efficiency * 0.25
		_:
			pass
	return result


func _safe_contribution_multiplier(base_value: float, final_value: float) -> float:
	if base_value <= RESOURCE_EPSILON:
		return 1.0
	return maxf(0.0, final_value / base_value)


func _get_active_profession_counts() -> Dictionary:
	var result: Dictionary = {}
	for villager: Villager in get_active_council():
		if not is_instance_valid(villager):
			continue
		var profession_id: String = str(villager.current_profession)
		result[profession_id] = int(result.get(profession_id, 0)) + 1
	return result


func get_villager_passive_overview(villager: Villager) -> Dictionary:
	if not is_instance_valid(villager):
		return {}
	var active_council: Array[Villager] = get_active_council()
	var profession_counts: Dictionary = _get_active_profession_counts()
	var same_profession_count: int = int(
		profession_counts.get(str(villager.current_profession), 0)
	)
	var all_assigned: bool = active_council.size() == ACTIVE_COUNCIL_LIMIT
	for colleague: Villager in active_council:
		if colleague.current_profession == Villager.Profession.UNASSIGNED:
			all_assigned = false
			break
	var history: Dictionary = part3_foundation_manager.get_councillor_history(
		villager.representative_id
	)
	return COUNCIL_PASSIVE_CATALOG_SCRIPT.evaluate(
		villager.passive_id,
		{
			"assigned": villager.current_profession != Villager.Profession.UNASSIGNED,
			"active_in_council": villager.is_council_active,
			"same_profession_count": same_profession_count,
			"all_assigned": all_assigned,
			"level": villager.level,
			"profession_streak_days": villager.profession_streak_days,
			"profession_change_count": villager.profession_change_count,
			"profession_day_counts": history.get("profession_day_counts", {}),
			"current_happiness": happiness,
			"food_consumption_per_villager": _get_effective_food_consumption_for_day(current_day)
		}
	)


func get_council_passive_rows() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for villager: Villager in get_active_council():
		var overview: Dictionary = get_villager_passive_overview(villager)
		overview["representative_id"] = villager.representative_id
		overview["display_name"] = villager.villager_name
		rows.append(overview)
	return rows


func get_part3_foundation_overview() -> Dictionary:
	return part3_foundation_manager.get_diagnostic_overview()


func get_current_season() -> Dictionary:
	return VillageCampaignCatalog.get_season_for_day(
		current_day
	)


func get_current_season_modifiers() -> Dictionary:
	return (
		VillageCampaignCatalog.get_season_modifiers_for_day(
			current_day
		)
	)


func get_effective_food_consumption_per_villager() -> float:
	return _get_effective_food_consumption_for_day(
		current_day
	)


func _get_effective_food_consumption_for_day(
	day: int
) -> float:
	var modifiers: Dictionary = (
		VillageCampaignCatalog.get_season_modifiers_for_day(
			day
		)
	)
	var base_value: float = FOOD_CONSUMPTION_PER_VILLAGER * float(
		modifiers.get(
			"food_consumption_multiplier",
			1.0
		)
	) * float(
		get_current_difficulty_rules().get(
			"food_consumption_multiplier",
			1.0
		)
	)
	var relationship_reduction: float = float(
		foundation_manager.get_relationship_management_modifiers().get(
			"food_consumption_reduction",
			0.0
		)
	)
	var opportunity_multiplier: float = float(
		councillor_opportunity_manager.get_modifiers_for_day(day).get(
			"food_consumption_multiplier",
			1.0
		)
	)
	return (
		base_value
		* (1.0 - clampf(relationship_reduction, 0.0, 0.25))
		* opportunity_multiplier
	)


func _get_council_fixed_food_reduction_for_day(day: int) -> float:
	var total_reduction: float = 0.0
	var per_villager: float = _get_effective_food_consumption_for_day(day)
	for villager: Villager in get_active_council():
		var overview: Dictionary = COUNCIL_PASSIVE_CATALOG_SCRIPT.evaluate(
			villager.passive_id,
			{
				"active_in_council": true,
				"food_consumption_per_villager": per_villager
			}
		)
		total_reduction += float(
			overview.get("fixed_food_consumption_reduction", 0.0)
		)
	return maxf(0.0, total_reduction)


func _get_building_fixed_food_reduction_for_day(_day: int) -> float:
	return maxf(
		0.0,
		building_manager.get_effect_value("fixed_food_consumption_reduction")
	)


func _get_council_fixed_material_reduction_for_day(_day: int) -> float:
	var total_reduction: float = 0.0
	for villager: Villager in get_active_council():
		var overview: Dictionary = COUNCIL_PASSIVE_CATALOG_SCRIPT.evaluate(
			villager.passive_id,
			{"active_in_council": true}
		)
		total_reduction += float(
			overview.get("fixed_material_maintenance_reduction", 0.0)
		)
	var composition: Dictionary = get_council_effects_overview()
	var synergy_modifiers: Dictionary = composition.get("synergy_modifiers", {})
	total_reduction += float(
		synergy_modifiers.get("maintenance_reduction", 0.0)
	)
	return maxf(0.0, total_reduction)


func get_effective_material_maintenance_per_villager() -> float:
	return _get_effective_material_maintenance_for_day(
		current_day
	)


func _get_effective_material_maintenance_for_day(
	day: int
) -> float:
	var reduction: float = building_manager.get_effect_value(
		"maintenance_reduction"
	)
	var modifiers: Dictionary = (
		VillageCampaignCatalog.get_season_modifiers_for_day(
			day
		)
	)

	var relationship_reduction: float = float(
		foundation_manager.get_relationship_management_modifiers().get(
			"maintenance_reduction",
			0.0
		)
	)
	var opportunity_multiplier: float = float(
		councillor_opportunity_manager.get_modifiers_for_day(day).get(
			"material_maintenance_multiplier",
			1.0
		)
	)
	return MATERIAL_MAINTENANCE_PER_VILLAGER * (
		1.0 - clampf(reduction + relationship_reduction, 0.0, 0.75)
	) * float(
		modifiers.get(
			"material_maintenance_multiplier",
			1.0
		)
	) * float(
		get_current_difficulty_rules().get(
			"maintenance_multiplier",
			1.0
		)
	) * opportunity_multiplier


func get_effective_happiness_decay_per_villager() -> float:
	return _get_effective_representative_happiness_decay_for_day(
		current_day
	)


func get_effective_common_happiness_decay_per_villager() -> float:
	return _get_effective_common_happiness_decay_for_day(
		current_day
	)


func _get_effective_representative_happiness_decay_for_day(
	day: int
) -> float:
	var reduction: float = building_manager.get_effect_value(
		"happiness_decay_reduction"
	)
	var modifiers: Dictionary = (
		VillageCampaignCatalog.get_season_modifiers_for_day(
			day
		)
	)

	var relationship_reduction: float = float(
		foundation_manager.get_relationship_management_modifiers().get(
			"happiness_decay_reduction",
			0.0
		)
	)
	var opportunity_multiplier: float = float(
		councillor_opportunity_manager.get_modifiers_for_day(day).get(
			"happiness_decay_multiplier",
			1.0
		)
	)
	return HAPPINESS_DECAY_PER_VILLAGER * (
		1.0 - clampf(reduction + relationship_reduction, 0.0, 0.75)
	) * float(
		modifiers.get(
			"happiness_decay_multiplier",
			1.0
		)
	) * float(
		get_current_difficulty_rules().get(
			"happiness_decay_multiplier",
			1.0
		)
	) * opportunity_multiplier


func _get_effective_common_happiness_decay_for_day(
	day: int
) -> float:
	var reduction: float = building_manager.get_effect_value(
		"happiness_decay_reduction"
	)
	var modifiers: Dictionary = (
		VillageCampaignCatalog.get_season_modifiers_for_day(
			day
		)
	)

	var relationship_reduction: float = float(
		foundation_manager.get_relationship_management_modifiers().get(
			"happiness_decay_reduction",
			0.0
		)
	)
	var opportunity_multiplier: float = float(
		councillor_opportunity_manager.get_modifiers_for_day(day).get(
			"happiness_decay_multiplier",
			1.0
		)
	)
	return COMMON_HAPPINESS_DECAY_PER_VILLAGER * (
		1.0 - clampf(reduction + relationship_reduction, 0.0, 0.75)
	) * float(
		modifiers.get(
			"happiness_decay_multiplier",
			1.0
		)
	) * float(
		get_current_difficulty_rules().get(
			"happiness_decay_multiplier",
			1.0
		)
	) * opportunity_multiplier


func get_population_overview() -> Dictionary:
	return foundation_manager.get_population_overview()


func get_total_population() -> int:
	return int(
		get_population_overview().get(
			"total_population",
			0
		)
	)


func get_common_population() -> int:
	return int(
		get_population_overview().get(
			"common_population",
			0
		)
	)


func calculate_next_day_forecast() -> Dictionary:
	var population: float = float(get_total_population())
	var representative_population: float = float(
		get_active_council().size()
	)
	var common_population: float = float(
		get_common_population()
	)
	var production: Production = calculate_total_production()

	var food_consumption_before_council: float = (
		population
		* get_effective_food_consumption_per_villager()
	)
	var food_fixed_reduction: float = (
		_get_council_fixed_food_reduction_for_day(current_day)
	)
	var building_food_reduction: float = (
		_get_building_fixed_food_reduction_for_day(current_day)
	)
	var food_consumption: float = maxf(
		0.0,
		food_consumption_before_council
		- food_fixed_reduction
		- building_food_reduction
	)

	var material_consumption_before_council: float = (
		population
		* get_effective_material_maintenance_per_villager()
	)
	var material_fixed_reduction: float = (
		_get_council_fixed_material_reduction_for_day(current_day)
	)
	var material_consumption: float = maxf(
		0.0,
		material_consumption_before_council - material_fixed_reduction
	)

	var happiness_decay: float = (
		representative_population
		* get_effective_happiness_decay_per_villager()
		+ common_population
		* get_effective_common_happiness_decay_per_villager()
	)

	var available_food: float = food + production.food
	var available_material: float = (
		building_material + production.material
	)

	var food_shortage: float = maxf(
		0.0,
		food_consumption - available_food
	)

	var material_shortage: float = maxf(
		0.0,
		material_consumption - available_material
	)

	var projected_food: float = maxf(
		0.0,
		available_food - food_consumption
	)

	var projected_material: float = maxf(
		0.0,
		available_material - material_consumption
	)

	var starvation_penalty: float = (
		food_shortage * STARVATION_PENALTY_PER_MISSING_FOOD
	)

	var maintenance_penalty: float = (
		material_shortage * MATERIAL_SHORTAGE_PENALTY
	)
	var difficulty_recovery_bonus: float = 0.0
	if (
		(campaign_manager.food_crisis_days > 0 or campaign_manager.material_crisis_days > 0)
		and food_shortage <= RESOURCE_EPSILON
		and material_shortage <= RESOURCE_EPSILON
	):
		difficulty_recovery_bonus = float(
			get_current_difficulty_rules().get(
				"post_crisis_happiness_recovery",
				0.0
			)
		)

	var projected_happiness: float = clampf(
		happiness
		+ production.happiness
		+ difficulty_recovery_bonus
		- happiness_decay
		- starvation_penalty
		- maintenance_penalty,
		0.0,
		MAX_HAPPINESS
	)
	var population_outlook: Dictionary = (
		_build_population_outlook(
			projected_food,
			projected_material,
			projected_happiness,
			food_shortage,
			material_shortage,
			current_day + 1
		)
	)

	return {
		"next_day": current_day + 1,
		"season": get_current_season(),
		"season_modifiers": (
			get_current_season_modifiers()
		),
		"food": projected_food,
		"material": projected_material,
		"happiness": projected_happiness,
		"population": int(
			population_outlook.get(
				"projected_population",
				get_total_population()
			)
		),
		"population_outlook": population_outlook,
		"food_change": projected_food - food,
		"material_change": (
			projected_material - building_material
		),
		"happiness_change": (
			projected_happiness - happiness
		),
		"food_production": production.food,
		"material_production": production.material,
		"happiness_production": production.happiness,
		"common_food_production": (
			common_population
			* COMMON_FOOD_PRODUCTION_PER_VILLAGER
		),
		"common_material_production": (
			common_population
			* COMMON_MATERIAL_PRODUCTION_PER_VILLAGER
		),
		"food_consumption": food_consumption,
		"material_consumption": material_consumption,
		"food_consumption_before_council": food_consumption_before_council,
		"material_consumption_before_council": material_consumption_before_council,
		"food_fixed_reduction": food_fixed_reduction,
		"material_fixed_reduction": material_fixed_reduction,
		"council_effects": get_council_effects_overview(),
		"happiness_decay": happiness_decay,
		"food_shortage": food_shortage,
		"material_shortage": material_shortage,
		"food_production_bonus": (
			building_manager.get_effect_value(
				"food_production_bonus"
			)
		),
		"material_production_bonus": (
			building_manager.get_effect_value(
				"material_production_bonus"
			)
		),
		"happiness_decay_reduction": (
			building_manager.get_effect_value(
				"happiness_decay_reduction"
			)
		),
		"daily_happiness_bonus": (
			building_manager.get_effect_value(
				"daily_happiness_bonus"
			)
		),
		"maintenance_reduction": (
			building_manager.get_effect_value(
				"maintenance_reduction"
			)
		),
		"difficulty_recovery_bonus": difficulty_recovery_bonus
	}


func advance_day() -> void:
	if not is_council_ready():
		push_warning(
			"O dia não pode avançar antes de o Conselho estar completo."
		)
		return
	if (
		has_active_event()
		or story_manager.has_pending_dialogue()
		or has_pending_level_dialogue()
		or npc_relationship_manager.has_pending_dialogue()
		or is_campaign_finished()
	):
		return

	var completed_day: int = current_day
	var happiness_before_day: float = happiness
	var population: float = float(get_total_population())
	var representative_population: float = float(
		get_active_council().size()
	)
	var common_population: float = float(
		get_common_population()
	)
	var production: Production = calculate_total_production()
	var active_projects_applied: Array = (
		councillor_opportunity_manager.get_overview(completed_day).get(
			"active_projects",
			[]
		)
	)

	var food_consumption_before_council: float = (
		population
		* get_effective_food_consumption_per_villager()
	)
	var food_fixed_reduction: float = (
		_get_council_fixed_food_reduction_for_day(current_day)
	)
	var building_food_reduction: float = (
		_get_building_fixed_food_reduction_for_day(current_day)
	)
	var food_consumption: float = maxf(
		0.0,
		food_consumption_before_council
		- food_fixed_reduction
		- building_food_reduction
	)

	var material_consumption_before_council: float = (
		population
		* get_effective_material_maintenance_per_villager()
	)
	var material_fixed_reduction: float = (
		_get_council_fixed_material_reduction_for_day(current_day)
	)
	var material_consumption: float = maxf(
		0.0,
		material_consumption_before_council - material_fixed_reduction
	)

	var happiness_decay: float = (
		representative_population
		* get_effective_happiness_decay_per_villager()
		+ common_population
		* get_effective_common_happiness_decay_per_villager()
	)

	# A produção entra antes do consumo diário.
	var available_food: float = food + production.food
	var available_material: float = (
		building_material + production.material
	)

	var food_shortage: float = maxf(
		0.0,
		food_consumption - available_food
	)

	var material_shortage: float = maxf(
		0.0,
		material_consumption - available_material
	)

	food = maxf(
		0.0,
		available_food - food_consumption
	)

	building_material = maxf(
		0.0,
		available_material - material_consumption
	)

	var starvation_penalty: float = (
		food_shortage * STARVATION_PENALTY_PER_MISSING_FOOD
	)

	var maintenance_penalty: float = (
		material_shortage * MATERIAL_SHORTAGE_PENALTY
	)
	var difficulty_recovery_bonus: float = 0.0
	if (
		(campaign_manager.food_crisis_days > 0 or campaign_manager.material_crisis_days > 0)
		and food_shortage <= RESOURCE_EPSILON
		and material_shortage <= RESOURCE_EPSILON
	):
		difficulty_recovery_bonus = float(
			get_current_difficulty_rules().get(
				"post_crisis_happiness_recovery",
				0.0
			)
		)

	happiness = clampf(
		happiness
		+ production.happiness
		+ difficulty_recovery_bonus
		- happiness_decay
		- starvation_penalty
		- maintenance_penalty,
		0.0,
		MAX_HAPPINESS
	)
	var relationship_passive_result: Dictionary = (
		foundation_manager.resolve_relationship_daily_passives(
			completed_day,
			happiness_before_day,
			happiness
		)
	)
	if not relationship_passive_result.is_empty():
		happiness = clampf(
			happiness + float(
				relationship_passive_result.get("happiness_recovery", 0.0)
			),
			0.0,
			MAX_HAPPINESS
		)

	var construction_work: Dictionary = (
		building_manager.process_construction_work_day(completed_day)
	)

	current_day += 1
	var population_outlook: Dictionary = (
		_build_population_outlook(
			food,
			building_material,
			happiness,
			food_shortage,
			material_shortage,
			current_day
		)
	)
	var population_resolution: Dictionary = (
		foundation_manager.population_state.apply_daily_conditions(
			bool(
				population_outlook.get(
					"is_favorable",
					false
				)
			),
			bool(
				population_outlook.get(
					"is_concerning",
					false
				)
			),
			String(
				population_outlook.get(
					"status",
					"stable"
				)
			),
			String(
				population_outlook.get(
					"reason",
					"A comunidade está estável."
				)
			)
		)
	)

	part3_foundation_manager.record_daily_production(
		completed_day,
		{
			"food": production.food,
			"material": production.material,
			"happiness": production.happiness
		},
		_build_part3_councillor_production_rows(completed_day),
		{
			"difficulty_id": get_current_difficulty_id(),
			"season_id": String(
				VillageCampaignCatalog.get_season_for_day(
					completed_day
				).get("id", "")
			),
			"population_before": int(population),
			"population_after": get_total_population(),
			"common_population": int(common_population),
			"council_size": int(representative_population),
			"profession_counts": _get_active_profession_counts(),
			"food_consumption": food_consumption,
			"material_consumption": material_consumption,
			"happiness_decay": happiness_decay,
			"food_shortage": food_shortage,
			"material_shortage": material_shortage,
			"food_after": food,
			"material_after": building_material,
			"happiness_after": happiness,
			"food_before": available_food - production.food,
			"material_before": available_material - production.material,
			"happiness_before": happiness_before_day,
			"difficulty_recovery_bonus": difficulty_recovery_bonus
		}
	)

	var milestone_messages: Array[String] = _process_production_milestones(
		completed_day
	)
	_grant_daily_council_xp(completed_day)
	var project_messages: Array[String] = (
		_process_completed_councillor_projects(completed_day)
	)
	var prepared_opportunity: Dictionary = _try_prepare_councillor_opportunity()

	resources_changed.emit(
		food,
		building_material,
		happiness,
		current_day
	)

	var summary: String = (
		"Dia %d concluído.\n"
		+ "Estação: %s — %s\n"
		+ "Produção: +%.1f alimentação, +%.1f material, "
		+ "+%.1f felicidade.\n"
		+ "Custos: -%.1f alimentação, -%.1f material "
		+ "e -%.1f felicidade."
	) % [
		completed_day,
		String(
			VillageCampaignCatalog.get_season_for_day(
				completed_day
			).get(
				"display_name",
				""
			)
		),
		String(
			VillageCampaignCatalog.get_season_for_day(
				completed_day
			).get(
				"effects_text",
				"Sem modificadores."
			)
		),
		production.food,
		production.material,
		production.happiness,
		food_consumption,
		material_consumption,
		happiness_decay
	]

	if food_shortage > 0.0:
		summary += (
			"\nALERTA: faltaram %.1f de alimentação "
			+ "e a fome retirou %.1f de felicidade."
		) % [
			food_shortage,
			starvation_penalty
		]

	if material_shortage > 0.0:
		summary += (
			"\nALERTA: faltaram %.1f de material "
			+ "para a manutenção da vila."
		) % material_shortage

	if happiness <= 0.0:
		summary += (
			"\nA vila está em crise: "
			+ "a felicidade chegou a zero."
		)
	if difficulty_recovery_bonus > 0.0:
		summary += (
			"\nRECUPERAÇÃO — a dificuldade restaurou +%.1f de felicidade "
			+ "após a crise."
		) % difficulty_recovery_bonus

	var relationship_passive_message: String = String(
		relationship_passive_result.get("message", "")
	)
	if not relationship_passive_message.is_empty():
		summary += "\n" + relationship_passive_message
	var npc_follow_up: String = npc_relationship_manager.get_follow_up_comment(completed_day)
	if not npc_follow_up.is_empty():
		summary += "\n" + npc_follow_up

	var population_summary: String = (
		_build_population_resolution_text(
			population_resolution
		)
	)

	if common_population > 0.0:
		summary += (
			"\nEconomia local: %d habitantes comuns "
			+ "plantaram e negociaram entre si."
		) % int(common_population)

	if not population_summary.is_empty():
		summary += "\n" + population_summary

	var construction_work_message: String = String(
		construction_work.get("message", "")
	)
	if not construction_work_message.is_empty():
		summary += "\n" + construction_work_message
	for active_project_value: Variant in active_projects_applied:
		if not active_project_value is Dictionary:
			continue
		var active_project: Dictionary = active_project_value as Dictionary
		summary += (
			"\nPROJETO ATIVO — %s, liderado por %s (efeito até o dia %d)."
			% [
				String(active_project.get("title", "Projeto do Conselho")),
				String(active_project.get("display_name", "Representante")),
				int(active_project.get("end_day", completed_day))
			]
		)
	for milestone_message: String in milestone_messages:
		summary += "\n" + milestone_message
	for project_message: String in project_messages:
		summary += "\n" + project_message
	if not prepared_opportunity.is_empty():
		summary += (
			"\nASSUNTO DO CONSELHO — %s quer apresentar uma decisão com efeitos temporários. "
			+ "Procure o marcador ! na carta."
		) % String(prepared_opportunity.get("display_name", "Um representante"))

	day_advanced.emit(summary)

	if not (construction_work.get("worked_orders", []) as Array).is_empty() or not (
		construction_work.get("completed_orders", []) as Array
	).is_empty():
		buildings_changed.emit(get_building_state(), "")

	if has_pending_level_dialogue():
		pending_campaign_completed_day = completed_day
		pending_level_resume_mode = "post_day"
		if request_next_level_dialogue():
			_autosave_if_enabled()
			return

	_continue_after_completed_day(completed_day)


func _continue_after_completed_day(completed_day: int) -> void:
	if story_manager.should_trigger_chapter(completed_day):
		pending_campaign_completed_day = completed_day
		var chapter: Dictionary = story_manager.begin_chapter(completed_day)
		if not chapter.is_empty():
			story_dialogue_requested.emit(
				story_manager.get_pending_dialogue_request()
			)
			_autosave_if_enabled()
			return

	if _try_request_npc_relationship_dialogue(completed_day):
		return

	_continue_after_npc_relationship_day(completed_day)


func _continue_after_npc_relationship_day(completed_day: int) -> void:

	var memory_result: Dictionary = founder_memory_manager.try_prepare_event(
		completed_day,
		_build_founder_memory_world_context(completed_day)
	)
	if bool(memory_result.get("state_changed", false)):
		founder_memory_changed.emit(get_founder_memory_overview())
	var memory_event: Dictionary = memory_result.get("event", {})
	if not memory_event.is_empty():
		if not event_manager.set_external_events(
			founder_memory_manager.get_registered_events()
		):
			push_error("Não foi possível registrar o acontecimento de memória.")
		else:
			var started_memory_event: Dictionary = event_manager.start_forced_event(
				memory_event,
				completed_day
			)
			if not started_memory_event.is_empty():
				pending_campaign_completed_day = completed_day
				village_event_started.emit(started_memory_event)
				_autosave_if_enabled()
				return

	var started_event: Dictionary = event_manager.try_start_event(completed_day)
	if not started_event.is_empty():
		pending_campaign_completed_day = completed_day
		village_event_started.emit(started_event)
		_autosave_if_enabled()
		return

	_evaluate_campaign_after_day(completed_day)
	_emit_season_hint_after_day(completed_day)
	_autosave_if_enabled()


func _try_request_npc_relationship_dialogue(completed_day: int) -> bool:
	var request: Dictionary = npc_relationship_manager.prepare_for_completed_day(
		completed_day,
		_build_npc_relationship_context()
	)
	if request.is_empty():
		return false
	pending_campaign_completed_day = completed_day
	npc_relationship_dialogue_requested.emit(request)
	_autosave_if_enabled()
	return true


func _build_npc_relationship_context() -> Dictionary:
	var known_npcs: Dictionary = {}
	var relationship_points: Dictionary = {}
	var overview: Dictionary = foundation_manager.get_relationship_overview(current_day, true)
	for value: Variant in overview.get("entries", []) as Array:
		if not value is Dictionary:
			continue
		var entry: Dictionary = value as Dictionary
		var npc_id: String = String(entry.get("npc_id", ""))
		known_npcs[npc_id] = bool(entry.get("known", false))
		relationship_points[npc_id] = int(entry.get("relationship_points", 0))
	return {
		"known_npcs": known_npcs,
		"relationship_points": relationship_points,
		"food": food,
		"material": building_material,
		"council_size": get_active_council().size()
	}


func get_npc_relationship_overview() -> Dictionary:
	var overview: Dictionary = npc_relationship_manager.get_overview()
	var known: Dictionary = {}
	for value: Variant in foundation_manager.get_relationship_overview(current_day, true).get("entries", []) as Array:
		if value is Dictionary:
			known[String((value as Dictionary).get("npc_id", ""))] = true
	var visible_pairs: Array[Dictionary] = []
	for value: Variant in overview.get("pairs", []) as Array:
		if not value is Dictionary:
			continue
		var pair: Dictionary = value as Dictionary
		if known.has(String(pair.get("a", ""))) and known.has(String(pair.get("b", ""))):
			visible_pairs.append(pair.duplicate(true))
	overview["pairs"] = visible_pairs
	return overview


func has_pending_npc_relationship_dialogue() -> bool:
	return npc_relationship_manager.has_pending_dialogue()


func request_pending_npc_relationship_dialogue() -> bool:
	var request: Dictionary = npc_relationship_manager.get_pending_conversation()
	if request.is_empty():
		return false
	npc_relationship_dialogue_requested.emit(request)
	return true


func resolve_npc_relationship_choice(choice_data: Dictionary) -> Dictionary:
	var result: Dictionary = npc_relationship_manager.resolve_choice(choice_data)
	if not bool(result.get("success", false)):
		return result
	var resolution: Dictionary = result.get("resolution", {}) as Dictionary
	var a: String = String(resolution.get("a", ""))
	var b: String = String(resolution.get("b", ""))
	var a_delta: int = int(resolution.get("player_a_delta", 0))
	var b_delta: int = int(resolution.get("player_b_delta", 0))
	if a_delta != 0:
		foundation_manager.add_relationship_points(a, a_delta)
	if b_delta != 0:
		foundation_manager.add_relationship_points(b, b_delta)
	part3_foundation_manager.record_decision(
		int(result.get("completed_day", current_day)),
		"npc_relationship_choice",
		String(resolution.get("choice_id", "neutral")),
		"",
		{"npc_a": a, "npc_b": b, "title": String(resolution.get("title", ""))},
		{"player_a_delta": a_delta, "player_b_delta": b_delta, "pair_delta": int(resolution.get("pair_delta", 0))}
	)
	npc_relationships_changed.emit(get_npc_relationship_overview(), String(result.get("message", "")))
	relationships_changed.emit(get_relationship_overview(), "")
	return result


func complete_npc_relationship_dialogue() -> Dictionary:
	if npc_relationship_manager.has_pending_dialogue():
		return {"handled": false}
	var completed_day: int = pending_campaign_completed_day
	pending_campaign_completed_day = 0
	if completed_day > 0:
		_continue_after_npc_relationship_day(completed_day)
	return {"handled": true}


func _process_production_milestones(completed_day: int) -> Array[String]:
	var messages: Array[String] = []
	var milestones: Array[Dictionary] = (
		part3_foundation_manager.consume_new_production_milestones()
	)
	for milestone: Dictionary in milestones:
		var representative_id: String = String(
			milestone.get("representative_id", "")
		)
		var villager: Villager = _find_villager_by_representative_id(
			representative_id
		)
		if not is_instance_valid(villager):
			continue
		var resource_id: String = String(milestone.get("resource_id", "food"))
		var milestone_value: int = int(milestone.get("value", 100))
		_grant_xp_to_villager(
			villager,
			10,
			"production_%s_%d" % [resource_id, milestone_value],
			completed_day
		)
		var quote: String = (
			COUNCILLOR_PROGRESSION_DIALOGUE_CATALOG_SCRIPT.get_milestone_quote(
				villager.personality_id,
				resource_id,
				milestone_value
			)
		)
		messages.append(
			"MARCO DE %s — %s recebeu +10 XP. “%s”" % [
				villager.villager_name,
				_get_resource_display_name(resource_id),
				quote
			]
		)
	return messages


func _grant_daily_council_xp(completed_day: int) -> void:
	var granted_any: bool = false
	for villager: Villager in get_active_council():
		if not is_instance_valid(villager):
			continue
		var passive_overview: Dictionary = get_villager_passive_overview(villager)
		var xp_amount: int = 2 + int(
			passive_overview.get("daily_xp_bonus", 0)
		)
		_grant_xp_to_villager(
			villager,
			xp_amount,
			"daily_council_service",
			completed_day
		)
		villager.record_completed_profession_day()
		granted_any = true
	if granted_any:
		council_changed.emit(get_council_overview(), "")


func _grant_xp_to_villager(
	villager: Villager,
	amount: int,
	reason_id: String,
	day_value: int
) -> Dictionary:
	if not is_instance_valid(villager) or amount <= 0:
		return {"success": false}
	var result: Dictionary = villager.grant_xp(amount)
	if not bool(result.get("success", false)):
		return result
	part3_foundation_manager.grant_councillor_xp(
		villager.representative_id,
		amount,
		reason_id,
		maxi(1, day_value)
	)
	part3_foundation_manager.synchronize_councillor_progression(
		villager.representative_id,
		villager.level,
		villager.xp,
		villager.unspent_attribute_points,
		villager.lifetime_xp,
		villager.attribute_points_spent
	)
	var levels_gained: int = int(result.get("levels_gained", 0))
	var previous_level: int = int(result.get("previous_level", villager.level))
	for gained_index: int in range(levels_gained):
		var reached_level: int = previous_level + gained_index + 1
		part3_foundation_manager.record_level_up(
			villager.representative_id,
			reached_level,
			maxi(1, day_value)
		)
		_queue_level_up_dialogue(villager, reached_level, maxi(1, day_value))
	councillor_history_changed.emit(villager.representative_id)
	return result


func _queue_level_up_dialogue(
	villager: Villager,
	reached_level: int,
	day_value: int
) -> void:
	if not is_instance_valid(villager):
		return
	var sequence: int = pending_level_dialogues.size() + 1
	var conversation_id: String = "level_up_%s_%d_%d_%d" % [
		villager.representative_id,
		reached_level,
		day_value,
		sequence
	]
	var dominant_resource: String = part3_foundation_manager.get_dominant_resource(
		villager.representative_id
	)
	var has_personal_production: bool = not dominant_resource.is_empty()
	if dominant_resource.is_empty():
		dominant_resource = _get_profession_resource(villager.current_profession)
	pending_level_dialogues.append(
		{
			"conversation_id": conversation_id,
			"representative_id": villager.representative_id,
			"display_name": villager.villager_name,
			"portrait_id": villager.portrait_id,
			"personality_id": villager.personality_id,
			"personality_name": villager.personality_name,
			"level": reached_level,
			"day": day_value,
			"dominant_resource": dominant_resource,
			"has_personal_production": has_personal_production,
			"resolved": false,
			"reward_claimed": false
		}
	)


func has_pending_level_dialogue() -> bool:
	return not active_level_dialogue.is_empty() or not pending_level_dialogues.is_empty()


func request_next_level_dialogue() -> bool:
	if not active_level_dialogue.is_empty():
		councillor_level_dialogue_requested.emit(active_level_dialogue.duplicate(true))
		return true
	if pending_level_dialogues.is_empty():
		return false
	active_level_dialogue = pending_level_dialogues.pop_front()
	councillor_level_dialogue_requested.emit(active_level_dialogue.duplicate(true))
	return true


func resolve_councillor_level_choice(choice_data: Dictionary) -> Dictionary:
	if active_level_dialogue.is_empty():
		return {"success": false, "message": "Nenhuma conquista aguarda resposta."}
	var conversation_id: String = String(
		choice_data.get("level_up_conversation_id", "")
	).strip_edges()
	if conversation_id != String(active_level_dialogue.get("conversation_id", "")):
		return {"success": false, "message": "A resposta não pertence a esta conquista."}
	if bool(active_level_dialogue.get("resolved", false)):
		return {"success": false, "message": "Esta conversa já foi resolvida."}

	var representative_id: String = String(
		active_level_dialogue.get("representative_id", "")
	)
	var quality: String = String(choice_data.get("level_up_quality", "neutral"))
	var reward_resource: String = ""
	var rewarded: bool = false
	if quality == "best" and not bool(active_level_dialogue.get("reward_claimed", false)):
		reward_resource = String(
			active_level_dialogue.get("dominant_resource", "material")
		)
		match reward_resource:
			"food": food += 1.0
			"material": building_material += 1.0
			"happiness": happiness = minf(MAX_HAPPINESS, happiness + 1.0)
			_:
				reward_resource = "material"
				building_material += 1.0
		rewarded = true
		active_level_dialogue["reward_claimed"] = true
		resources_changed.emit(food, building_material, happiness, current_day)

	active_level_dialogue["resolved"] = true
	active_level_dialogue["quality"] = quality
	part3_foundation_manager.record_level_dialogue(
		representative_id,
		int(active_level_dialogue.get("level", 1)),
		quality,
		reward_resource,
		int(active_level_dialogue.get("day", current_day))
	)
	part3_foundation_manager.record_decision(
		int(active_level_dialogue.get("day", current_day)),
		"level_up_dialogue",
		conversation_id,
		representative_id,
		{"quality": quality},
		{"rewarded": rewarded, "resource": reward_resource}
	)
	councillor_history_changed.emit(representative_id)
	return {
		"success": true,
		"rewarded": rewarded,
		"resource_id": reward_resource,
		"message": (
			"A resposta fortaleceu a conquista e gerou +1 de %s."
			% _get_resource_display_name(reward_resource)
			if rewarded
			else "A conversa foi registrada no histórico da carta."
		)
	}


func complete_councillor_level_dialogue(conversation_id: String) -> Dictionary:
	if active_level_dialogue.is_empty():
		return {"handled": false}
	if String(active_level_dialogue.get("conversation_id", "")) != conversation_id:
		return {"handled": false}
	var completed_day: int = pending_campaign_completed_day
	var resume_mode: String = pending_level_resume_mode
	active_level_dialogue.clear()
	if request_next_level_dialogue():
		_autosave_if_enabled()
		return {"handled": true, "more_dialogues": true}
	pending_level_resume_mode = ""
	if completed_day > 0:
		pending_campaign_completed_day = 0
		if resume_mode == "post_day":
			_continue_after_completed_day(completed_day)
		else:
			_evaluate_campaign_after_day(completed_day)
			_emit_season_hint_after_day(completed_day)
	_autosave_if_enabled()
	return {"handled": true, "more_dialogues": false}


func spend_councillor_attribute_point(
	representative_id: String,
	attribute_id: String
) -> Dictionary:
	var villager: Villager = _find_villager_by_representative_id(representative_id)
	if not is_instance_valid(villager):
		return {"success": false, "message": "A carta não foi encontrada."}
	var result: Dictionary = villager.spend_attribute_point(attribute_id)
	if not bool(result.get("success", false)):
		return result
	part3_foundation_manager.synchronize_councillor_progression(
		villager.representative_id,
		villager.level,
		villager.xp,
		villager.unspent_attribute_points,
		villager.lifetime_xp,
		villager.attribute_points_spent
	)
	part3_foundation_manager.record_attribute_spent(
		villager.representative_id,
		attribute_id,
		int(result.get("attribute_value", 0)),
		current_day
	)
	council_changed.emit(
		get_council_overview(),
		"%s aprimorou %s para %d." % [
			villager.villager_name,
			_get_attribute_display_name(attribute_id),
			int(result.get("attribute_value", 0))
		]
	)
	councillor_history_changed.emit(villager.representative_id)
	_autosave_if_enabled()
	return result


func get_councillor_history(representative_id: String) -> Dictionary:
	var villager: Villager = _find_villager_by_representative_id(representative_id)
	if not is_instance_valid(villager):
		return {}
	var history: Dictionary = part3_foundation_manager.get_councillor_history(
		representative_id
	)
	if history.is_empty():
		return {}
	history["representative_id"] = villager.representative_id
	history["display_name"] = villager.villager_name
	history["portrait_id"] = villager.portrait_id
	history["species_name"] = villager.species_name
	history["personality_name"] = villager.personality_name
	history["personality_description"] = villager.personality_description
	history["passive_name"] = villager.passive_name
	history["level"] = villager.level
	history["xp"] = villager.xp
	history["lifetime_xp"] = villager.lifetime_xp
	history["unspent_attribute_points"] = villager.unspent_attribute_points
	history["attribute_points_spent"] = villager.attribute_points_spent
	history["attributes"] = {
		"strength": villager.strength,
		"intelligence": villager.intelligence,
		"charisma": villager.charisma,
		"agility": villager.agility
	}
	return history


func _find_villager_by_representative_id(representative_id: String) -> Villager:
	var clean_id: String = representative_id.strip_edges()
	for villager: Villager in villagers:
		if is_instance_valid(villager) and villager.representative_id == clean_id:
			return villager
	return null


func _get_resource_display_name(resource_id: String) -> String:
	match resource_id:
		"food": return "alimentação"
		"material": return "material"
		"happiness": return "felicidade"
		_: return "recurso"


func _get_profession_resource(profession: int) -> String:
	match profession:
		Villager.Profession.FARMER: return "food"
		Villager.Profession.BLACKSMITH: return "material"
		Villager.Profession.CIVIL_SERVANT: return "happiness"
		Villager.Profession.GUARD: return "happiness"
		Villager.Profession.GATHERER: return "food"
		_: return "material"


func _get_attribute_display_name(attribute_id: String) -> String:
	match attribute_id:
		"strength": return "Força"
		"intelligence": return "Inteligência"
		"charisma": return "Carisma"
		"agility": return "Agilidade"
		_: return "Atributo"


func has_active_event() -> bool:
	return event_manager.has_active_event()


func get_active_event() -> Dictionary:
	return event_manager.get_active_event()


func get_event_choice_state(
	choice_id: String,
	villager: Villager
) -> Dictionary:
	return event_manager.get_choice_state(
		choice_id,
		villager,
		food,
		building_material,
		happiness,
		_build_event_context()
	)


func calculate_event_success_chance(
	choice: Dictionary,
	villager: Villager
) -> float:
	return event_manager.calculate_success_chance(
		choice,
		villager
	)


func resolve_event_choice(
	choice_id: String,
	villager: Villager
) -> bool:
	var old_food: float = food
	var old_material: float = building_material
	var old_happiness: float = happiness

	var resolution: Dictionary = (
		event_manager.resolve_choice(
			choice_id,
			villager,
			food,
			building_material,
			happiness,
			_build_event_context()
		)
	)

	if not bool(
		resolution.get(
			"resolved",
			false
		)
	):
		return false

	_apply_resource_effects(
		resolution.get(
			"effects",
			{}
		)
	)

	var event_title: String = String(
		resolution.get(
			"event_title",
			"Acontecimento"
		)
	)

	var result_text: String = String(
		resolution.get(
			"result_text",
			"A decisão foi cumprida."
		)
	)

	var tested_villager_name: String = String(
		resolution.get(
			"tested_villager_name",
			""
		)
	)

	var complete_result: String = (
		"%s — %s"
	) % [
		event_title,
		result_text
	]

	if not tested_villager_name.is_empty():
		complete_result = (
			"%s — %s: %s"
		) % [
			event_title,
			tested_villager_name,
			result_text
		]

	var changes_text: String = (
		_build_resource_changes_text(
			food - old_food,
			building_material - old_material,
			happiness - old_happiness
		)
	)

	if not changes_text.is_empty():
		complete_result += "\n" + changes_text

	var resolved_event_data: Dictionary = resolution.get("event_data", {})
	var resolved_event_id: String = String(
		resolved_event_data.get("id", "unknown_event")
	)
	var is_founder_memory: bool = bool(
		resolved_event_data.get("is_founder_memory", false)
	)
	var credited_villager: Villager = villager
	if is_founder_memory:
		credited_villager = _find_villager_by_representative_id(
			String(resolved_event_data.get("memory_founder_id", ""))
		)
	var actor_id: String = ""
	if is_instance_valid(credited_villager):
		actor_id = credited_villager.representative_id
	part3_foundation_manager.record_decision(
		current_day,
		"event_choice",
		String(resolution.get("choice_id", choice_id)),
		actor_id,
		{
			"event_id": resolved_event_id,
			"is_story_event": bool(resolution.get("is_story_event", false)),
			"is_founder_memory": is_founder_memory,
			"memory_chain_id": String(
				resolved_event_data.get("memory_chain_id", "")
			),
			"memory_stage": String(
				resolved_event_data.get("memory_stage", "")
			)
		},
		{
			"succeeded": bool(resolution.get("succeeded", true)),
			"effects": (resolution.get("effects", {}) as Dictionary).duplicate(true)
		}
	)
	var resolved_choice_data: Dictionary = resolution.get("choice_data", {})
	var used_variant_id: String = String(
		resolved_choice_data.get("required_building_variant", "")
	)
	if not used_variant_id.is_empty():
		building_manager.record_variant_event_use(
			used_variant_id,
			String(resolution.get("choice_id", choice_id))
		)
	var event_had_test: bool = (
		bool(resolved_choice_data.get("requires_villager", false))
		or not String(resolved_choice_data.get("test_attribute", "")).is_empty()
	)
	part3_foundation_manager.mark_event_resolution(
		current_day,
		resolved_event_id,
		String(resolution.get("choice_id", choice_id)),
		bool(resolution.get("succeeded", true)),
		actor_id,
		event_had_test,
		event_title,
		not is_founder_memory
	)
	if is_founder_memory:
		var memory_resolution: Dictionary = founder_memory_manager.record_resolution(
			resolved_event_data,
			resolved_choice_data,
			current_day,
			_build_founder_memory_world_context(current_day)
		)
		if not memory_resolution.is_empty():
			part3_foundation_manager.record_founder_memory_entry(
				String(memory_resolution.get("founder_id", actor_id)),
				memory_resolution.get("history_entry", {})
			)
			event_manager.set_external_events(
				founder_memory_manager.get_registered_events()
			)
			founder_memory_changed.emit(get_founder_memory_overview())
			councillor_history_changed.emit(
				String(memory_resolution.get("founder_id", actor_id))
			)

	if is_instance_valid(credited_villager):
		var xp_result: Dictionary = _grant_xp_to_villager(
			credited_villager,
			20,
			"event_%s" % resolved_event_id,
			current_day
		)
		complete_result += "\nXP: %s recebeu +20." % credited_villager.villager_name
		if int(xp_result.get("levels_gained", 0)) > 0:
			complete_result += " Subiu para o nível %d." % credited_villager.level
		if not is_founder_memory:
			var achievement_comment: String = (
				COUNCILLOR_PROGRESSION_DIALOGUE_CATALOG_SCRIPT.get_event_result_quote(
					credited_villager.personality_id,
					bool(resolution.get("succeeded", true)),
					event_had_test
				)
			)
			complete_result += "\n%s: “%s”" % [
				credited_villager.villager_name,
				achievement_comment
			]
		council_changed.emit(get_council_overview(), "")

	var is_story_event: bool = bool(
		resolution.get("is_story_event", false)
	)
	var story_resolution: Dictionary = {}

	if is_story_event:
		var event_data: Dictionary = resolution.get("event_data", {})
		var choice_data: Dictionary = resolution.get("choice_data", {})
		story_resolution = story_manager.record_story_event_resolution(
			event_data,
			choice_data,
			debug_story_sequence_active
		)

		if not debug_story_sequence_active:
			var population_delta: int = int(
				story_resolution.get("population_delta", 0)
			)
			var applied_population_delta: int = (
				foundation_manager.population_state.apply_story_population_delta(
					population_delta
				)
			)
			if applied_population_delta != 0:
				var population_sign: String = (
					"+" if applied_population_delta > 0 else ""
				)
				complete_result += "\nPopulação: %s%d habitante." % [
					population_sign,
					applied_population_delta
				]

			var recruited_npc_id: String = String(
				story_resolution.get("recruit_npc_id", "")
			)
			if not recruited_npc_id.is_empty():
				foundation_manager.mark_npc_known(recruited_npc_id)
				if bool(story_resolution.get("new_recruit", false)):
					if foundation_manager.population_state.add_named_story_resident():
						complete_result += "\n%s passou a morar na vila." % String(
							foundation_manager.get_npc_overview(
								recruited_npc_id
							).get("display_name", "O novo aliado")
						)
				var relationship_delta: int = int(
					story_resolution.get("relationship_delta", 0)
				)
				if relationship_delta != 0:
					var mediator_triggered: bool = false
					if (
						is_instance_valid(villager)
						and villager.passive_id == "mediador"
						and villager.mediator_last_trigger_day != current_day
					):
						# Somar 1 amplia ganhos positivos e torna perdas negativas menos severas.
						relationship_delta += 1
						villager.mediator_last_trigger_day = current_day
						mediator_triggered = true
					foundation_manager.add_relationship_points(
						recruited_npc_id,
						relationship_delta * 35
					)
					if mediator_triggered:
						complete_result += "\nPassiva Mediador: relação ajustada em favor do vínculo."
				story_npc_recruited.emit(
					foundation_manager.get_npc_overview(
						recruited_npc_id
					)
				)

	resources_changed.emit(
		food,
		building_material,
		happiness,
		current_day
	)

	village_event_resolved.emit(complete_result)
	village_visual_feedback_requested.emit({
		"kind": (
			"success"
			if bool(resolution.get("succeeded", true))
			else "crisis"
		),
		"message": (
			"Acontecimento resolvido"
			if bool(resolution.get("succeeded", true))
			else "A vila enfrenta uma consequência"
		),
		"target_id": "square"
	})

	if is_story_event:
		story_dialogue_requested.emit(
			story_manager.get_pending_dialogue_request()
		)
		_autosave_if_enabled()
		return true

	if has_pending_level_dialogue():
		pending_level_resume_mode = "after_event"
		if request_next_level_dialogue():
			_autosave_if_enabled()
			return true

	if pending_campaign_completed_day > 0:
		var completed_day: int = pending_campaign_completed_day
		pending_campaign_completed_day = 0
		_evaluate_campaign_after_day(completed_day)
		_emit_season_hint_after_day(completed_day)

	_autosave_if_enabled()
	return true


func get_player_profile_overview() -> Dictionary:
	return foundation_manager.get_player_profile_overview()


func get_relationship_overview() -> Dictionary:
	return foundation_manager.get_relationship_overview(current_day, true)


func get_relationship_test_overview() -> Dictionary:
	return foundation_manager.get_relationship_overview(current_day, false)


func get_relationship_world_context() -> Dictionary:
	var forecast: Dictionary = calculate_next_day_forecast()
	return {
		"day": current_day,
		"campaign_seed": part3_foundation_manager.campaign_seed,
		"season_id": String(get_current_season().get("id", "spring")),
		"food": food,
		"material": building_material,
		"happiness": happiness,
		"food_balance": float(forecast.get("food_change", 0.0)),
		"material_balance": float(forecast.get("material_change", 0.0)),
		"happiness_balance": float(forecast.get("happiness_change", 0.0))
	}


func resolve_relationship_choice(choice_data: Dictionary) -> Dictionary:
	var npc_id: String = String(
		choice_data.get("relationship_npc_id", "")
	).strip_edges()
	if npc_id.is_empty():
		return {"success": false, "message": "A resposta não pertence a um vínculo."}
	var action: String = String(choice_data.get("relationship_action", "conversation"))
	var quality: String = String(choice_data.get("relationship_quality", "neutral"))
	var points: int = int(choice_data.get("relationship_points", 0))
	var result: Dictionary = {}

	if action == "date":
		result = foundation_manager.register_relationship_date(npc_id, current_day, points)
	elif choice_data.has("personal_event_id"):
		if action == "defer_relationship_decision":
			result = {
				"success": true,
				"applied_points": 0,
				"message": (
					"A decisão foi adiada. A cena de 800 pontos continua disponível e nenhuma rota foi encerrada."
				)
			}
		else:
			result = foundation_manager.complete_relationship_personal_event(
				npc_id,
				String(choice_data.get("personal_event_id", "")),
				points
			)
		if bool(result.get("success", false)):
			match action:
				"record_romance_interest":
					var marker_id: String = String(
						choice_data.get("romance_interest_marker", "")
					)
					if not foundation_manager.record_relationship_interest(
						npc_id,
						marker_id
					):
						return {
							"success": false,
							"message": "Não foi possível registrar esta demonstração de interesse."
						}
					result["message"] = (
						"O interesse foi demonstrado com clareza, sem criar um compromisso imediato."
					)
				"commit_romance":
					var partner_result: Dictionary = foundation_manager.set_official_partner(npc_id)
					if not bool(partner_result.get("success", false)):
						return partner_result
					result["message"] = String(partner_result.get("message", "Compromisso assumido."))
				"decline_romance":
					foundation_manager.decline_relationship_romance(npc_id)
					result["message"] = "A rota romântica foi encerrada com respeito; a amizade continua disponível."
				"respectful_friendship":
					foundation_manager.decline_relationship_romance(npc_id)
					result["message"] = "O vínculo continuará como amizade, respeitando o compromisso atual."
	else:
		var internal_test_mode: bool = bool(
			choice_data.get("relationship_internal_test", false)
		)
		result = foundation_manager.register_relationship_response(
			npc_id,
			current_day,
			quality,
			points,
			String(choice_data.get("relationship_topic_id", "")),
			internal_test_mode
		)
		var seasonal_key: String = String(
			choice_data.get("seasonal_dialogue_key", "")
		).strip_edges()
		if not seasonal_key.is_empty():
			foundation_manager.mark_relationship_seasonal_dialogue_seen(
				npc_id,
				seasonal_key
			)

	if bool(result.get("success", false)):
		part3_foundation_manager.record_decision(
			current_day,
			"relationship_choice",
			action,
			npc_id,
			{
				"quality": quality,
				"topic_id": String(
					choice_data.get("relationship_topic_id", "")
				),
				"personal_event_id": String(
					choice_data.get("personal_event_id", "")
				),
				"romance_interest_marker": String(
					choice_data.get("romance_interest_marker", "")
				)
			},
			{
				"applied_points": int(result.get("applied_points", 0)),
				"success": true
			}
		)
		var overview: Dictionary = get_relationship_overview()
		relationships_changed.emit(overview, String(result.get("message", "Relação atualizada.")))
		resources_changed.emit(food, building_material, happiness, current_day)
		_autosave_if_enabled()
	return result


func get_story_overview() -> Dictionary:
	return story_manager.get_overview()


func get_pending_story_dialogue_request() -> Dictionary:
	return story_manager.get_pending_dialogue_request()


func has_pending_story_dialogue() -> bool:
	return story_manager.has_pending_dialogue()


func request_pending_story_dialogue() -> bool:
	var request: Dictionary = story_manager.get_pending_dialogue_request()
	if request.is_empty():
		return false
	story_dialogue_requested.emit(request)
	return true


func complete_story_dialogue(dialogue_id: String) -> Dictionary:
	var result: Dictionary = story_manager.finish_dialogue(dialogue_id)
	if not bool(result.get("handled", false)):
		return result

	if bool(result.get("prologue_completed", false)):
		_autosave_if_enabled()
		return result

	if bool(result.get("debug_sequence_completed", false)):
		_restore_debug_story_snapshot()
		return result

	var start_event_id: String = String(
		result.get("start_event_id", "")
	)
	if not start_event_id.is_empty():
		var story_event: Dictionary = (
			STORY_CHAPTER_CATALOG_SCRIPT.get_story_event(
				start_event_id
			)
		)
		if story_event.is_empty():
			push_error(
				"Evento principal inexistente: %s." % start_event_id
			)
			return {"handled": false, "error": "Evento principal ausente."}

		var event_completed_day: int = pending_campaign_completed_day
		if debug_story_sequence_active:
			event_completed_day = int(story_event.get("chapter_day", 1))
		var started_event: Dictionary = event_manager.start_forced_event(
			story_event,
			event_completed_day
		)
		if started_event.is_empty():
			return {"handled": false, "error": "Não foi possível iniciar o capítulo."}
		village_event_started.emit(started_event)
		_autosave_if_enabled()
		return result

	if bool(result.get("chapter_completed", false)):
		var chapter_id: String = String(result.get("chapter_id", ""))
		var chapter: Dictionary = (
			STORY_CHAPTER_CATALOG_SCRIPT.get_chapter_by_id(chapter_id)
		)
		_sync_legacy_narrative_from_story()
		story_chapter_completed.emit(chapter)

		if pending_campaign_completed_day > 0:
			var chapter_completed_day: int = pending_campaign_completed_day
			if has_pending_level_dialogue():
				pending_level_resume_mode = "after_story"
				if request_next_level_dialogue():
					_autosave_if_enabled()
					return result
			if _try_request_npc_relationship_dialogue(chapter_completed_day):
				return result
			pending_campaign_completed_day = 0
			_continue_after_npc_relationship_day(chapter_completed_day)
		_autosave_if_enabled()

	return result


func debug_start_story_sequence(chapter_day: int) -> Dictionary:
	if (
		has_active_event()
		or story_manager.has_pending_dialogue()
		or has_pending_level_dialogue()
		or debug_story_sequence_active
	):
		return {
			"success": false,
			"message": "Resolva o acontecimento atual antes de iniciar um teste narrativo."
		}

	var original_story_state: Dictionary = story_manager.export_save_data()
	var villager_states: Array[Dictionary] = []
	for villager: Villager in villagers:
		if is_instance_valid(villager):
			villager_states.append(villager.export_save_data())
	debug_story_snapshot = {
		"food": food,
		"material": building_material,
		"happiness": happiness,
		"foundation_sections": foundation_manager.build_save_sections(
			current_day,
			villager_states
		),
		"villagers": villager_states.duplicate(true),
		"part3_foundation": part3_foundation_manager.export_save_data(),
		"councillor_opportunities": councillor_opportunity_manager.export_save_data(),
		"events": event_manager.export_save_data(),
		"story": original_story_state,
		"pending_campaign_completed_day": pending_campaign_completed_day,
		"pending_level_dialogues": pending_level_dialogues.duplicate(true),
		"active_level_dialogue": active_level_dialogue.duplicate(true),
		"pending_level_resume_mode": pending_level_resume_mode
	}

	var request: Dictionary = story_manager.debug_begin_sequence(chapter_day)
	if request.is_empty():
		debug_story_snapshot.clear()
		story_manager.import_save_data(original_story_state)
		return {
			"success": false,
			"message": "Dia de capítulo inválido."
		}

	debug_story_sequence_active = true
	food = maxf(food, 999.0)
	building_material = maxf(building_material, 999.0)
	happiness = MAX_HAPPINESS
	pending_campaign_completed_day = 0
	resources_changed.emit(food, building_material, happiness, current_day)
	story_dialogue_requested.emit(request)
	return {
		"success": true,
		"message": (
			"Prólogo de teste iniciado."
			if chapter_day <= 0
			else "Capítulo do dia %d iniciado em modo de teste." % chapter_day
		)
	}


func _restore_debug_story_snapshot() -> void:
	if not debug_story_sequence_active or debug_story_snapshot.is_empty():
		debug_story_sequence_active = false
		return

	food = float(debug_story_snapshot.get("food", food))
	building_material = float(
		debug_story_snapshot.get("material", building_material)
	)
	happiness = float(debug_story_snapshot.get("happiness", happiness))

	var villager_states_value: Variant = debug_story_snapshot.get("villagers", [])
	if villager_states_value is Array:
		var villagers_by_id: Dictionary = _get_villagers_by_id()
		for state_value: Variant in villager_states_value as Array:
			if not state_value is Dictionary:
				continue
			var state: Dictionary = state_value as Dictionary
			var representative_id: String = String(
				state.get("representative_id", "")
			)
			var villager: Villager = villagers_by_id.get(
				representative_id,
				null
			) as Villager
			if is_instance_valid(villager):
				villager.import_save_data(state)

	var foundation_sections: Dictionary = debug_story_snapshot.get(
		"foundation_sections",
		{}
	)
	if not foundation_sections.is_empty():
		foundation_manager.import_save_sections(
			foundation_sections,
			villagers.size()
		)

	var part3_state: Dictionary = debug_story_snapshot.get(
		"part3_foundation",
		{}
	)
	if not part3_state.is_empty():
		part3_foundation_manager.import_save_data(part3_state)

	var opportunity_state: Dictionary = debug_story_snapshot.get(
		"councillor_opportunities",
		{}
	)
	if not opportunity_state.is_empty():
		councillor_opportunity_manager.import_save_data(opportunity_state)

	var event_state: Dictionary = debug_story_snapshot.get("events", {})
	if not event_state.is_empty():
		event_manager.import_save_data(event_state)

	var story_state: Dictionary = debug_story_snapshot.get("story", {})
	if not story_state.is_empty():
		story_manager.import_save_data(story_state)

	pending_campaign_completed_day = int(
		debug_story_snapshot.get("pending_campaign_completed_day", 0)
	)
	pending_level_dialogues.clear()
	var pending_levels_value: Variant = debug_story_snapshot.get(
		"pending_level_dialogues",
		[]
	)
	if pending_levels_value is Array:
		for level_value: Variant in pending_levels_value as Array:
			if level_value is Dictionary:
				pending_level_dialogues.append(
					(level_value as Dictionary).duplicate(true)
				)
	active_level_dialogue = (
		debug_story_snapshot.get("active_level_dialogue", {}) as Dictionary
	).duplicate(true)
	pending_level_resume_mode = String(
		debug_story_snapshot.get("pending_level_resume_mode", "")
	)
	debug_story_snapshot.clear()
	debug_story_sequence_active = false
	resources_changed.emit(food, building_material, happiness, current_day)
	villagers_changed.emit()
	buildings_changed.emit(get_building_state(), "")


func _build_event_context() -> Dictionary:
	var building_levels: Dictionary = {}
	for building_value: Variant in get_building_state().get("buildings", []):
		if not building_value is Dictionary:
			continue
		var building: Dictionary = building_value as Dictionary
		var building_id: String = String(building.get("id", ""))
		if not building_id.is_empty():
			building_levels[building_id] = int(
				building.get("current_level", 0)
			)

	var active_professions: Array[int] = []
	for villager: Villager in get_active_council():
		if not active_professions.has(villager.current_profession):
			active_professions.append(villager.current_profession)

	var relationship_overview: Dictionary = (
		foundation_manager.get_relationship_overview(current_day, true)
	)
	var relationship_points: Dictionary = {}
	for entry_value: Variant in relationship_overview.get("entries", []):
		if not entry_value is Dictionary:
			continue
		var relationship_entry: Dictionary = entry_value as Dictionary
		var relationship_npc_id: String = String(
			relationship_entry.get("npc_id", "")
		)
		if not relationship_npc_id.is_empty():
			relationship_points[relationship_npc_id] = int(
				relationship_entry.get("relationship_points", 0)
			)

	return {
		"building_levels": building_levels,
		"building_variants": building_manager.get_building_variants(),
		"active_professions": active_professions,
		"known_story_npcs": story_manager.get_known_story_npc_count(),
		"relationship_points": relationship_points,
		"official_partner_id": String(
			relationship_overview.get("official_partner_id", "")
		),
		"part3_event_flags": part3_foundation_manager.get_event_flags(),
		"debug_unlock_story_choices": debug_story_sequence_active
	}


func _sync_legacy_narrative_from_story() -> void:
	var overview: Dictionary = story_manager.get_overview()
	foundation_manager.completed_chapter_ids.clear()
	for chapter_id_value: Variant in overview.get(
		"completed_chapter_ids",
		[]
	):
		foundation_manager.completed_chapter_ids.append(
			String(chapter_id_value)
		)
	foundation_manager.current_chapter_id = String(
		overview.get("pending_chapter_id", "capitulo_01")
	)
	if foundation_manager.current_chapter_id.is_empty():
		foundation_manager.current_chapter_id = "capitulo_01"


func get_building_state() -> Dictionary:
	var building_allowed: bool = true
	var blocked_reason: String = ""

	if has_active_event():
		building_allowed = false
		blocked_reason = (
			"Resolva o acontecimento pendente antes de planejar obras."
		)

	elif story_manager.has_pending_dialogue():
		building_allowed = false
		blocked_reason = (
			"Conclua o capítulo narrativo antes de planejar obras."
		)

	elif has_pending_level_dialogue():
		building_allowed = false
		blocked_reason = (
			"Conclua a conversa de conquista antes de planejar obras."
		)

	elif is_campaign_finished() and not is_free_play():
		building_allowed = false
		blocked_reason = (
			"A campanha terminou. Entre no Modo Livre ou inicie "
			+ "uma nova campanha para planejar obras."
		)

	return building_manager.get_state(
		building_material,
		building_allowed,
		blocked_reason,
		get_total_population(),
		current_day,
		VillageCampaignCatalog.CHECKPOINT_DAYS
	)


func upgrade_building(
	building_id: String,
	variant_id: String = ""
) -> Dictionary:
	var state: Dictionary = get_building_state()
	var resolution: Dictionary = building_manager.request_construction(
		building_id,
		building_material,
		current_day,
		bool(state.get("building_allowed", false)),
		String(
			state.get(
				"blocked_reason",
				"Não é possível planejar obras agora."
			)
		),
		variant_id
	)
	if not bool(resolution.get("queued", false)):
		return resolution

	var material_cost: float = float(resolution.get("cost", 0.0))
	building_material = maxf(0.0, building_material - material_cost)
	resources_changed.emit(food, building_material, happiness, current_day)
	campaign_progress_changed.emit(get_campaign_progress())

	part3_foundation_manager.record_decision(
		current_day,
		"construction_enqueued",
		String(resolution.get("order_id", building_id)),
		"",
		{
			"building_id": building_id,
			"target_level": int(resolution.get("target_level", 0)),
			"variant_id": String(resolution.get("variant_id", "")),
			"variant_name": String(resolution.get("variant_name", "")),
			"work_days": int(resolution.get("work_days", 1)),
			"cost": material_cost
		},
		{"success": true}
	)

	buildings_changed.emit(
		get_building_state(),
		String(resolution.get("message", "A obra entrou na fila."))
	)
	village_visual_feedback_requested.emit({
		"kind": "construction",
		"message": "Obra adicionada à fila",
		"target_id": building_id
	})
	_autosave_if_enabled()
	return resolution


func cancel_construction(order_id: String) -> Dictionary:
	var resolution: Dictionary = building_manager.cancel_construction(order_id)
	if not bool(resolution.get("cancelled", false)):
		return resolution

	var refund: float = float(resolution.get("refund", 0.0))
	building_material += refund
	resources_changed.emit(food, building_material, happiness, current_day)
	campaign_progress_changed.emit(get_campaign_progress())
	part3_foundation_manager.record_decision(
		current_day,
		"construction_cancelled",
		order_id,
		"",
		{
			"building_id": String(resolution.get("building_id", "")),
			"was_active": bool(resolution.get("was_active", false)),
			"paid_cost": float(resolution.get("paid_cost", 0.0))
		},
		{"refund": refund}
	)
	buildings_changed.emit(
		get_building_state(),
		String(resolution.get("message", "A obra foi cancelada."))
	)
	_autosave_if_enabled()
	return resolution


func reorder_construction(order_id: String, direction: int) -> Dictionary:
	var resolution: Dictionary = building_manager.reorder_construction(
		order_id,
		direction
	)
	if not bool(resolution.get("reordered", false)):
		return resolution

	part3_foundation_manager.record_decision(
		current_day,
		"construction_reordered",
		order_id,
		"",
		{"direction": direction},
		{"success": true}
	)
	buildings_changed.emit(
		get_building_state(),
		String(resolution.get("message", "A fila foi reordenada."))
	)
	_autosave_if_enabled()
	return resolution


func save_game() -> Dictionary:
	if debug_story_sequence_active:
		return {
			"success": false,
			"message": "Encerre o teste narrativo antes de salvar."
		}

	if (
		not roster_initialized
		or not _has_complete_initial_roster()
		or get_active_council().size() != ACTIVE_COUNCIL_LIMIT
	):
		var empty_result: Dictionary = {
			"success": false,
			"message": (
				"Espere o Conselho completo aparecer antes de salvar."
			)
		}

		save_state_changed.emit(get_save_overview())
		return empty_result

	var result: Dictionary = save_manager.save_game(
		_build_save_game_state()
	)

	save_state_changed.emit(
		get_save_overview()
	)

	return result


func load_game() -> Dictionary:
	if not _has_complete_initial_roster():
		var roster_result: Dictionary = {
			"success": false,
			"message": (
				"O elenco ainda está sendo preparado. Tente novamente."
			)
		}
		save_state_changed.emit(get_save_overview())
		return roster_result

	var result: Dictionary = save_manager.load_game()

	if not bool(result.get("success", false)):
		save_state_changed.emit(
			get_save_overview()
		)

		return result

	var save_data: Dictionary = result.get(
		"save_data",
		{}
	)

	var game_state: Dictionary = save_data.get(
		"game_state",
		{}
	)

	if not _apply_loaded_game_state(game_state):
		save_manager.set_autosave_enabled(false)

		var invalid_result: Dictionary = {
			"success": false,
			"message": (
				"A campanha salva contém dados incompatíveis "
				+ "com esta vila."
			)
		}

		save_state_changed.emit(
			get_save_overview()
		)

		return invalid_result

	var was_migrated: bool = bool(result.get("was_migrated", false))
	if was_migrated:
		save_manager.save_game(_build_save_game_state())

	var load_result: Dictionary = {
		"success": true,
		"message": (
			"Campanha convertida e carregada no dia %d."
			if was_migrated
			else "Campanha carregada no dia %d."
		) % current_day,
		"was_migrated": was_migrated
	}

	resources_changed.emit(
		food,
		building_material,
		happiness,
		current_day
	)

	villagers_changed.emit()
	council_changed.emit(get_council_overview(), "")

	buildings_changed.emit(
		get_building_state(),
		""
	)

	campaign_progress_changed.emit(
		get_campaign_progress()
	)
	relationships_changed.emit(get_relationship_overview(), "")

	game_loaded.emit(load_result)

	if has_pending_level_dialogue():
		request_next_level_dialogue()

	elif story_manager.has_pending_dialogue():
		story_dialogue_requested.emit(
			story_manager.get_pending_dialogue_request()
		)

	elif npc_relationship_manager.has_pending_dialogue():
		npc_relationship_dialogue_requested.emit(
			npc_relationship_manager.get_pending_conversation()
		)

	elif has_active_event():
		village_event_started.emit(
			get_active_event()
		)

	elif is_campaign_finished():
		campaign_finished.emit(
			get_campaign_result()
		)

	save_state_changed.emit(
		get_save_overview()
	)

	return load_result


func delete_saved_game() -> Dictionary:
	var result: Dictionary = save_manager.delete_save()

	save_state_changed.emit(
		get_save_overview()
	)

	return result


func get_save_overview() -> Dictionary:
	var overview: Dictionary = (
		save_manager.get_save_overview()
	)

	overview["playing_day"] = (
		campaign_manager.completed_days
		if is_campaign_finished()
		else current_day
	)
	overview["playing_food"] = food
	overview["playing_material"] = building_material
	overview["playing_happiness"] = happiness
	overview["playing_population"] = int(
		foundation_manager.get_population_overview().get(
			"total_population",
			0
		)
	)
	overview["playing_housing_capacity"] = int(
		foundation_manager.get_population_overview().get(
			"housing_capacity",
			0
		)
	)
	overview["playing_house_count"] = (
		building_manager.house_count
	)
	var playing_profile: Dictionary = get_player_profile_overview()
	overview["playing_village_name"] = String(
		playing_profile.get("village_name", VillagePlayerProfile.DEFAULT_VILLAGE_NAME)
	)
	overview["playing_campaign_seed"] = part3_foundation_manager.campaign_seed
	overview["playing_generator_version"] = part3_foundation_manager.generator_version

	return overview


func get_campaign_progress() -> Dictionary:
	var progress: Dictionary = campaign_manager.get_progress(
		current_day,
		food,
		building_material,
		happiness,
		get_total_population()
	)
	return _enrich_campaign_progress(progress)


func _enrich_campaign_progress(progress: Dictionary) -> Dictionary:
	var enriched: Dictionary = progress.duplicate(true)
	enriched["campaign_identity"] = get_campaign_identity()
	enriched["difficulty_effects_text"] = (
		VillageDifficultyCatalog.get_effects_summary(get_current_difficulty_id())
	)
	if bool(enriched.get("is_finished", false)) or bool(enriched.get("is_free_play", false)):
		return enriched
	var goals_value: Variant = enriched.get("goals", [])
	if not goals_value is Array:
		return enriched
	var goals: Array = goals_value as Array
	var forecast: Dictionary = calculate_next_day_forecast()
	var days_remaining: int = maxi(1, int(enriched.get("days_remaining", 1)))
	var target_day: int = int(enriched.get("target_day", current_day))
	var construction_projection: Dictionary = _build_construction_projection(
		target_day,
		forecast
	)
	var changes: Dictionary = {
		"food": float(forecast.get("food_change", 0.0)),
		"material": float(forecast.get("material_change", 0.0)),
		"happiness": float(forecast.get("happiness_change", 0.0)),
		"population": 0.0
	}
	var ratios: Dictionary = {}
	var all_met: bool = true
	var all_projected: bool = true
	var worst_id: String = ""
	var worst_ratio: float = 999.0
	var enriched_goals: Array[Dictionary] = []
	for goal_value: Variant in goals:
		if not goal_value is Dictionary:
			continue
		var goal: Dictionary = goal_value as Dictionary
		var goal_id: String = String(goal.get("id", ""))
		var current_value: float = float(goal.get("current_value", 0.0))
		var target_value: float = maxf(0.001, float(goal.get("target_value", 1.0)))
		var projected_value: float = current_value + float(changes.get(goal_id, 0.0)) * float(days_remaining)
		projected_value += float(
			construction_projection.get("resource_adjustments", {}).get(goal_id, 0.0)
		)
		if goal_id == "population":
			projected_value = float(
				_project_population_to_checkpoint(
					forecast,
					days_remaining,
					int(construction_projection.get("housing_capacity", 0))
				)
			)
		if goal_id == "happiness":
			projected_value = clampf(projected_value, 0.0, 100.0)
		elif goal_id in ["food", "material"]:
			projected_value = maxf(0.0, projected_value)
		var ratio: float = projected_value / target_value
		var goal_status: String = "safe"
		if ratio < 0.85:
			goal_status = "danger"
		elif ratio < 1.0:
			goal_status = "tight"
		goal["projected_value"] = projected_value
		goal["projected_text"] = (
			"%d" % int(round(projected_value))
			if goal_id == "population"
			else "%.1f" % projected_value
		)
		goal["difference_to_target"] = projected_value - target_value
		goal["projection_status"] = goal_status
		enriched_goals.append(goal)
		ratios[goal_id] = ratio
		if not bool(goal.get("met", false)):
			all_met = false
		if ratio < 1.0:
			all_projected = false
		if ratio < worst_ratio:
			worst_ratio = ratio
			worst_id = goal_id
	enriched["goals"] = enriched_goals
	var status: String = "safe"
	var label: String = "SEGURA"
	if not all_met:
		if worst_ratio < 0.70 and days_remaining <= 5:
			status = "impossible_pace"
			label = "IMPOSSÍVEL NO RITMO ATUAL"
		elif not all_projected:
			status = "danger"
			label = "PERIGOSA"
		else:
			status = "tight"
			label = "APERTADA"
	var resource_names: Dictionary = {
		"food": "alimentação",
		"material": "material",
		"happiness": "felicidade",
		"population": "população"
	}
	enriched["forecast_status"] = status
	enriched["forecast_label"] = label
	enriched["threatened_resource_id"] = worst_id
	enriched["threatened_resource_name"] = String(resource_names.get(worst_id, "nenhum recurso"))
	enriched["forecast_ratios"] = ratios
	enriched["construction_forecast"] = construction_projection.get("works", [])
	enriched["projection_assumptions"] = [
		"Mantém a tendência do próximo dia até a avaliação.",
		"Inclui somente obras já contratadas e previstas para ficar disponíveis a tempo.",
		"Não antecipa escolhas futuras, acontecimentos, trocas no Conselho ou novas obras."
	]
	enriched["forecast_risks"] = _build_campaign_forecast_risks(
		enriched_goals,
		forecast
	)
	enriched["forecast_text"] = (
		"Prefeito Perfeito: tendência %s. Recurso mais ameaçado: %s."
		% [label.to_lower(), String(resource_names.get(worst_id, "nenhum"))]
	)
	return enriched


func get_campaign_identity() -> Dictionary:
	var profile: Dictionary = get_player_profile_overview()
	return {
		"village_name": String(
			profile.get("village_name", VillagePlayerProfile.DEFAULT_VILLAGE_NAME)
		),
		"player_name": String(profile.get("name", VillagePlayerProfile.DEFAULT_NAME)),
		"difficulty_id": get_current_difficulty_id(),
		"difficulty_name": get_current_difficulty_name(),
		"campaign_seed": part3_foundation_manager.campaign_seed,
		"generator_version": part3_foundation_manager.generator_version,
		"created_at": String(profile.get("campaign_created_at_text", "Data não registrada")),
		"created_project_version": String(
			profile.get("created_project_version", "3.10.1")
		),
		"current_project_version": String(
			ProjectSettings.get_setting("application/config/version", "")
		)
	}


func _build_construction_projection(
	target_day: int,
	forecast: Dictionary
) -> Dictionary:
	var state: Dictionary = get_building_state()
	var construction: Dictionary = state.get("construction", {})
	var orders: Array = []
	orders.append_array(construction.get("active_orders", []) as Array)
	orders.append_array(construction.get("queued_orders", []) as Array)
	var works: Array[Dictionary] = []
	var adjustments: Dictionary = {
		"food": 0.0,
		"material": 0.0,
		"happiness": 0.0
	}
	var housing_capacity: int = int(state.get("housing_capacity", 0))
	for order_value: Variant in orders:
		if not order_value is Dictionary:
			continue
		var order: Dictionary = order_value as Dictionary
		var available_day: int = int(order.get("predicted_available_day", 0))
		if available_day <= 0 or available_day > target_day:
			continue
		var active_days: int = maxi(0, target_day - available_day + 1)
		var is_housing: bool = bool(order.get("is_housing", false))
		if is_housing:
			housing_capacity += VillageBuildingManager.HOUSING_CAPACITY_PER_HOUSE
		else:
			var building_id: String = String(order.get("building_id", ""))
			var current_effects: Dictionary = building_manager.get_effects_for_state(
				building_id,
				building_manager.get_building_level(building_id),
				building_manager.get_building_variant(building_id)
			)
			var target_effects: Dictionary = building_manager.get_effects_for_state(
				building_id,
				int(order.get("target_level", 0)),
				String(order.get("variant_id", ""))
			)
			_apply_projected_building_effects(
				adjustments,
				current_effects,
				target_effects,
				active_days,
				forecast
			)
		works.append({
			"order_id": String(order.get("order_id", "")),
			"name": String(order.get("building_name", "Obra")),
			"available_day": available_day,
			"active_days_before_checkpoint": active_days,
			"effect_text": String(order.get("effect_text", "")),
			"is_housing": is_housing
		})
	return {
		"works": works,
		"resource_adjustments": adjustments,
		"housing_capacity": housing_capacity
	}


func _apply_projected_building_effects(
	adjustments: Dictionary,
	current_effects: Dictionary,
	target_effects: Dictionary,
	active_days: int,
	forecast: Dictionary
) -> void:
	if active_days <= 0:
		return
	var food_bonus_delta: float = float(target_effects.get("food_production_bonus", 0.0)) - float(current_effects.get("food_production_bonus", 0.0))
	var material_bonus_delta: float = float(target_effects.get("material_production_bonus", 0.0)) - float(current_effects.get("material_production_bonus", 0.0))
	var happiness_bonus_delta: float = float(target_effects.get("daily_happiness_bonus", 0.0)) - float(current_effects.get("daily_happiness_bonus", 0.0))
	var maintenance_delta: float = float(target_effects.get("maintenance_reduction", 0.0)) - float(current_effects.get("maintenance_reduction", 0.0))
	var decay_delta: float = float(target_effects.get("happiness_decay_reduction", 0.0)) - float(current_effects.get("happiness_decay_reduction", 0.0))
	var food_base: float = float(forecast.get("food_production", 0.0)) / maxf(
		0.10,
		1.0 + float(forecast.get("food_production_bonus", 0.0))
	)
	var material_base: float = float(forecast.get("material_production", 0.0)) / maxf(
		0.10,
		1.0 + float(forecast.get("material_production_bonus", 0.0))
	)
	adjustments["food"] = float(adjustments.get("food", 0.0)) + food_base * food_bonus_delta * active_days
	adjustments["material"] = float(adjustments.get("material", 0.0)) + material_base * material_bonus_delta * active_days
	adjustments["material"] = float(adjustments.get("material", 0.0)) + float(forecast.get("material_consumption_before_council", 0.0)) * maintenance_delta * active_days
	adjustments["happiness"] = float(adjustments.get("happiness", 0.0)) + happiness_bonus_delta * active_days
	adjustments["happiness"] = float(adjustments.get("happiness", 0.0)) + float(forecast.get("happiness_decay", 0.0)) * decay_delta * active_days


func _project_population_to_checkpoint(
	forecast: Dictionary,
	days_remaining: int,
	housing_capacity: int
) -> int:
	var population: int = get_total_population()
	var outlook: Dictionary = forecast.get("population_outlook", {})
	var favorable: bool = bool(outlook.get("is_favorable", false))
	var concerning: bool = bool(outlook.get("is_concerning", false))
	var attraction_progress: int = int(outlook.get("attraction_progress", 0))
	var concerning_streak: int = int(outlook.get("concerning_day_streak", 0))
	var attraction_target: int = maxi(1, int(outlook.get("attraction_target", 3)))
	var abandonment_target: int = maxi(1, int(outlook.get("abandonment_target", 3)))
	var protected_population: int = int(
		get_population_overview().get("protected_named_resident_count", 4)
	)
	for _day_offset: int in range(days_remaining):
		if concerning:
			concerning_streak += 1
			attraction_progress = 0
			if concerning_streak >= abandonment_target and population > protected_population:
				population -= 1
				concerning_streak = 0
		elif favorable and population < housing_capacity:
			attraction_progress += 1
			concerning_streak = 0
			if attraction_progress >= attraction_target:
				population += 1
				attraction_progress = 0
	return population


func _build_campaign_forecast_risks(
	goals: Array[Dictionary],
	forecast: Dictionary
) -> Array[String]:
	var risks: Array[String] = []
	for goal: Dictionary in goals:
		match String(goal.get("projection_status", "safe")):
			"danger":
				risks.append("%s está muito abaixo da meta no ritmo atual." % String(goal.get("label", "Uma meta")))
			"tight":
				risks.append("%s ainda depende de melhora antes da avaliação." % String(goal.get("label", "Uma meta")))
	var outlook: Dictionary = forecast.get("population_outlook", {})
	if bool(outlook.get("is_concerning", false)):
		risks.append("População: %s" % String(outlook.get("reason", "condições preocupantes")))
	if risks.is_empty():
		risks.append("Nenhum risco imediato detectado; acontecimentos e novas decisões ainda podem mudar a projeção.")
	return risks


func get_campaign_result() -> Dictionary:
	return get_campaign_progress()


func is_campaign_finished() -> bool:
	return campaign_manager.is_finished()


func is_free_play() -> bool:
	return campaign_manager.is_free_play()


func enter_free_play() -> bool:
	if not campaign_manager.enter_free_play():
		return false

	foundation_manager.calendar_state.synchronize_with_game_day(
		current_day
	)

	var progress: Dictionary = get_campaign_progress()
	campaign_progress_changed.emit(progress)
	free_play_started.emit(progress)

	var started: Dictionary = building_manager.start_constructions_for_day(
		current_day,
		get_total_population()
	)
	buildings_changed.emit(
		get_building_state(),
		String(started.get("message", ""))
	)

	_autosave_if_enabled()
	return true


func start_new_campaign(
	player_name: String = VillagePlayerProfile.DEFAULT_NAME,
	gender_id: String = VillagePlayerProfile.DEFAULT_GENDER,
	difficulty_id: String = VillageDifficultyCatalog.DEFAULT_DIFFICULTY_ID,
	village_name: String = VillagePlayerProfile.DEFAULT_VILLAGE_NAME,
	campaign_seed: int = 0
) -> void:
	var clean_seed: int = (
		CAMPAIGN_IDENTITY_CATALOG_SCRIPT.sanitize_seed(campaign_seed)
		if campaign_seed > 0
		else CAMPAIGN_IDENTITY_CATALOG_SCRIPT.generate_seed()
	)
	reset_game(clean_seed)
	foundation_manager.configure_player_profile(
		player_name,
		gender_id,
		difficulty_id,
		CAMPAIGN_IDENTITY_CATALOG_SCRIPT.sanitize_village_name(
			village_name,
			clean_seed
		)
	)
	var rules: Dictionary = get_current_difficulty_rules()
	food = float(rules.get("initial_food", INITIAL_FOOD))
	building_material = float(
		rules.get("initial_material", INITIAL_BUILDING_MATERIAL)
	)
	happiness = float(rules.get("initial_happiness", INITIAL_HAPPINESS))
	building_manager.configure_difficulty(
		float(rules.get("building_cost_multiplier", 1.0))
	)
	founder_memory_manager.configure_difficulty(
		int(rules.get("event_window_day_adjustment", 0))
	)
	campaign_manager.setup(get_current_difficulty_id())
	enter_game_after_reload = true


func consume_enter_game_after_reload() -> bool:
	var should_enter_game: bool = enter_game_after_reload
	enter_game_after_reload = false
	return should_enter_game


func reset_game(campaign_seed: int = 0) -> void:
	save_manager.delete_save()
	food = INITIAL_FOOD
	building_material = INITIAL_BUILDING_MATERIAL
	happiness = INITIAL_HAPPINESS
	current_day = 1
	pending_campaign_completed_day = 0
	shown_season_hint_ids.clear()

	villagers.clear()
	roster_initialized = false
	part3_foundation_manager.setup(campaign_seed)
	event_manager.setup(part3_foundation_manager.campaign_seed)
	founder_memory_manager.setup()
	campaign_manager.setup()
	building_manager.setup()
	foundation_manager.setup()
	recruitment_manager.setup()
	councillor_opportunity_manager.setup()
	story_manager.setup(true)
	npc_relationship_manager.setup()
	debug_story_sequence_active = false
	pending_level_dialogues.clear()
	active_level_dialogue.clear()
	pending_level_resume_mode = ""


func _build_save_game_state() -> Dictionary:
	var villager_states: Array[Dictionary] = []

	for villager: Villager in villagers:
		if not is_instance_valid(villager):
			continue

		villager_states.append(
			villager.export_save_data()
		)

	var game_state: Dictionary = (
		foundation_manager.build_save_sections(
			current_day,
			villager_states
		)
	)

	game_state["resources"] = {
		"food": food,
		"building_material": building_material,
		"happiness": happiness
	}

	game_state["events"] = (
		event_manager.export_save_data()
	)
	game_state["founder_memories"] = (
		founder_memory_manager.export_save_data()
	)
	game_state["campaign"] = (
		campaign_manager.export_save_data()
	)
	game_state["buildings"] = (
		building_manager.export_save_data()
	)
	game_state["story"] = story_manager.export_save_data()
	game_state["part3_foundation"] = (
		part3_foundation_manager.export_save_data()
	)
	game_state["council_recruitment"] = (
		recruitment_manager.export_save_data()
	)
	game_state["councillor_opportunities"] = (
		councillor_opportunity_manager.export_save_data()
	)
	game_state["npc_relationships"] = npc_relationship_manager.export_save_data()
	game_state["runtime"] = {
		"pending_campaign_completed_day": (
			pending_campaign_completed_day
		),
		"shown_season_hint_ids": (
			shown_season_hint_ids.duplicate()
		),
		"pending_level_dialogues": pending_level_dialogues.duplicate(true),
		"active_level_dialogue": active_level_dialogue.duplicate(true),
		"pending_level_resume_mode": pending_level_resume_mode
	}

	return game_state


func _apply_loaded_game_state(
	game_state: Dictionary
) -> bool:
	var resources_value: Variant = game_state.get(
		"resources",
		null
	)

	var event_state_value: Variant = game_state.get(
		"events",
		null
	)

	var founder_memory_value: Variant = game_state.get(
		"founder_memories",
		null
	)

	var campaign_state_value: Variant = game_state.get(
		"campaign",
		null
	)

	var building_state_value: Variant = game_state.get(
		"buildings",
		null
	)

	var runtime_state_value: Variant = game_state.get(
		"runtime",
		null
	)

	var story_state_value: Variant = game_state.get(
		"story",
		null
	)

	var part3_foundation_value: Variant = game_state.get(
		"part3_foundation",
		null
	)

	var recruitment_state_value: Variant = game_state.get(
		"council_recruitment",
		null
	)

	var opportunity_state_value: Variant = game_state.get(
		"councillor_opportunities",
		null
	)

	var council_state_value: Variant = game_state.get(
		"council",
		null
	)
	var npc_relationship_state_value: Variant = game_state.get(
		"npc_relationships",
		null
	)

	if (
		not resources_value is Dictionary
		or not event_state_value is Dictionary
		or not founder_memory_value is Dictionary
		or not campaign_state_value is Dictionary
		or not building_state_value is Dictionary
		or not runtime_state_value is Dictionary
		or not story_state_value is Dictionary
		or not part3_foundation_value is Dictionary
		or not recruitment_state_value is Dictionary
		or not opportunity_state_value is Dictionary
		or not council_state_value is Dictionary
		or not npc_relationship_state_value is Dictionary
	):
		return false

	var council_state: Dictionary = council_state_value
	var villager_states_value: Variant = council_state.get(
		"representatives",
		null
	)
	if not villager_states_value is Array:
		return false
	var villager_states: Array = villager_states_value
	for villager_state_value: Variant in villager_states:
		if not villager_state_value is Dictionary:
			return false
	if not _ensure_dynamic_villagers_for_save(villager_states):
		return false
	if villager_states.size() != villagers.size():
		return false

	if not foundation_manager.import_save_sections(
		game_state,
		villagers.size()
	):
		return false

	var loaded_difficulty_rules: Dictionary = get_current_difficulty_rules()
	foundation_manager.refresh_population_difficulty()
	building_manager.configure_difficulty(
		float(loaded_difficulty_rules.get("building_cost_multiplier", 1.0))
	)
	campaign_manager.set_difficulty(get_current_difficulty_id())

	var resources_state: Dictionary = resources_value
	var event_state: Dictionary = event_state_value
	var founder_memory_state: Dictionary = founder_memory_value
	var campaign_state: Dictionary = campaign_state_value
	var building_state: Dictionary = building_state_value
	var runtime_state: Dictionary = runtime_state_value
	var story_state: Dictionary = story_state_value
	var part3_foundation_state: Dictionary = part3_foundation_value
	var recruitment_state: Dictionary = recruitment_state_value
	var legacy_recruitment_state: bool = (
		int(recruitment_state.get("state_version", 0)) == 1
	)
	var opportunity_state: Dictionary = opportunity_state_value

	if not campaign_manager.import_save_data(
		campaign_state
	):
		return false
	campaign_manager.set_difficulty(get_current_difficulty_id())

	if not building_manager.import_save_data(
		building_state
	):
		return false
	building_manager.configure_difficulty(
		float(loaded_difficulty_rules.get("building_cost_multiplier", 1.0))
	)

	if not story_manager.import_save_data(story_state):
		return false

	if not part3_foundation_manager.import_save_data(
		part3_foundation_state
	):
		return false
	event_manager.configure_seed(part3_foundation_manager.campaign_seed)
	founder_memory_manager.configure_difficulty(
		int(loaded_difficulty_rules.get("event_window_day_adjustment", 0))
	)

	if not recruitment_manager.import_save_data(recruitment_state):
		return false
	if legacy_recruitment_state:
		for checkpoint_day: int in campaign_manager.completed_checkpoint_days:
			recruitment_manager.register_checkpoint(checkpoint_day)

	if not councillor_opportunity_manager.import_save_data(opportunity_state):
		return false
	if not npc_relationship_manager.import_save_data(npc_relationship_state_value as Dictionary):
		return false

	if (
		building_manager.get_housing_capacity()
		!= int(
			foundation_manager.get_population_overview().get(
				"housing_capacity",
				0
			)
		)
	):
		return false

	food = maxf(
		0.0,
		float(
			resources_state.get(
				"food",
				INITIAL_FOOD
			)
		)
	)

	building_material = maxf(
		0.0,
		float(
			resources_state.get(
				"building_material",
				INITIAL_BUILDING_MATERIAL
			)
		)
	)

	happiness = clampf(
		float(
			resources_state.get(
				"happiness",
				INITIAL_HAPPINESS
			)
		),
		0.0,
		MAX_HAPPINESS
	)

	var saved_current_day: int = (
		foundation_manager.calendar_state.current_day
	)

	if saved_current_day < 1:
		return false

	if (
		not campaign_manager.is_free_play()
		and saved_current_day
		> campaign_manager.TARGET_COMPLETED_DAYS + 1
	):
		return false

	current_day = saved_current_day

	var villagers_by_id: Dictionary = _get_villagers_by_id()
	var loaded_ids: Dictionary = {}
	for villager_state_value: Variant in villager_states:
		var villager_state: Dictionary = villager_state_value
		var representative_id: String = String(
			villager_state.get("representative_id", "")
		).strip_edges()
		if (
			representative_id.is_empty()
			or loaded_ids.has(representative_id)
			or not villagers_by_id.has(representative_id)
		):
			return false

		var villager: Villager = (
			villagers_by_id[representative_id] as Villager
		)
		if (
			not is_instance_valid(villager)
			or not villager.import_save_data(villager_state)
		):
			return false
		loaded_ids[representative_id] = true

	if loaded_ids.size() != villagers_by_id.size():
		return false

	if not _ensure_roster_portraits():
		return false

	if get_active_council().size() != ACTIVE_COUNCIL_LIMIT:
		return false

	roster_initialized = true
	_sync_foundation_council_ids()

	if not founder_memory_manager.import_save_data(founder_memory_state):
		return false
	if not _ensure_founder_memory_initialized():
		return false
	if not event_manager.import_save_data(event_state):
		return false

	pending_campaign_completed_day = clampi(
		int(
			runtime_state.get(
				"pending_campaign_completed_day",
				0
			)
		),
		0,
		maxi(
			campaign_manager.TARGET_COMPLETED_DAYS,
			current_day - 1
		)
	)

	shown_season_hint_ids.clear()
	var shown_hints_value: Variant = runtime_state.get(
		"shown_season_hint_ids",
		[]
	)

	if not shown_hints_value is Array:
		return false

	var shown_hints: Array = shown_hints_value

	for hint_value: Variant in shown_hints:
		var hint_id: String = String(hint_value)

		if (
			hint_id.is_empty()
			or shown_season_hint_ids.has(hint_id)
		):
			return false

		shown_season_hint_ids.append(hint_id)

	var pending_levels_value: Variant = runtime_state.get(
		"pending_level_dialogues",
		[]
	)
	var active_level_value: Variant = runtime_state.get(
		"active_level_dialogue",
		{}
	)
	if not pending_levels_value is Array or not active_level_value is Dictionary:
		return false
	pending_level_dialogues.clear()
	for level_value: Variant in pending_levels_value as Array:
		if not level_value is Dictionary:
			return false
		pending_level_dialogues.append((level_value as Dictionary).duplicate(true))
	active_level_dialogue = (active_level_value as Dictionary).duplicate(true)
	pending_level_resume_mode = String(
		runtime_state.get("pending_level_resume_mode", "")
	)

	if has_active_event():
		pending_campaign_completed_day = maxi(
			1,
			pending_campaign_completed_day
		)
	else:
		if (
			not story_manager.has_pending_dialogue()
			and not has_pending_level_dialogue()
			and not npc_relationship_manager.has_pending_dialogue()
		):
			pending_campaign_completed_day = 0

	_sync_legacy_narrative_from_story()
	var recruitment_context: Dictionary = _build_recruitment_context()
	if not recruitment_manager.reconcile_legacy_offer(
		recruitment_context.get("relationship_entries", []) as Array
	):
		return false
	# Recalcula o estado derivado depois de toda carga. Isso restaura ofertas
	# prontas, atualiza bloqueios e também conclui a migração do formato antigo.
	_prepare_recruitment_offer(0)
	return true


func _build_population_outlook(
	projected_food: float,
	projected_material: float,
	projected_happiness: float,
	food_shortage: float,
	material_shortage: float,
	sustain_day: int
) -> Dictionary:
	var overview: Dictionary = get_population_overview()
	var population: int = int(
		overview.get(
			"total_population",
			0
		)
	)
	var housing_capacity: int = int(
		overview.get(
			"housing_capacity",
			0
		)
	)
	var protected_named_resident_count: int = int(
		overview.get(
			"protected_named_resident_count",
			VillagePopulationState.INITIAL_PROTECTED_NAMED_RESIDENT_COUNT
		)
	)
	var attraction_progress: int = int(
		overview.get(
			"attraction_progress",
			0
		)
	)
	var concerning_streak: int = int(
		overview.get(
			"concerning_day_streak",
			0
		)
	)
	var attraction_target: int = int(
		overview.get(
			"attraction_target",
			3
		)
	)
	var abandonment_target: int = int(
		overview.get(
			"abandonment_target",
			3
		)
	)
	var growth_minimum_happiness: float = float(
		get_current_difficulty_rules().get(
			"growth_minimum_happiness",
			GROWTH_MINIMUM_HAPPINESS
		)
	)
	var next_food_need: float = (
		float(population)
		* _get_effective_food_consumption_for_day(
			sustain_day
		)
	)
	var next_material_need: float = (
		float(population)
		* _get_effective_material_maintenance_for_day(
			sustain_day
		)
	)
	var reasons: Array[String] = []

	if projected_happiness < ABANDONMENT_HAPPINESS_THRESHOLD:
		reasons.append(
			"felicidade abaixo de %.0f"
			% ABANDONMENT_HAPPINESS_THRESHOLD
		)

	if projected_food + RESOURCE_EPSILON < next_food_need:
		reasons.append(
			"alimentação insuficiente para o próximo dia"
		)

	if (
		projected_material + RESOURCE_EPSILON
		< next_material_need
	):
		reasons.append(
			"material insuficiente para a próxima manutenção"
		)

	if population > housing_capacity:
		reasons.append("população acima da capacidade")

	if food_shortage > RESOURCE_EPSILON:
		reasons.append("houve falta de alimentação")

	if material_shortage > RESOURCE_EPSILON:
		reasons.append("houve falta de material")

	var is_concerning: bool = not reasons.is_empty()
	var has_housing: bool = population < housing_capacity
	var is_favorable: bool = (
		not is_concerning
		and has_housing
		and projected_happiness
		>= growth_minimum_happiness
	)
	var status: String = "stable"
	var reason: String = (
		"A vila está segura, mas ainda não alcançou "
		+ "todas as condições de atração."
	)

	if is_concerning:
		status = "concerning"
		reason = "; ".join(reasons).capitalize() + "."
	elif not has_housing:
		status = "housing_paused"
		reason = (
			"Não há vagas. Construa uma casa para "
			+ "retomar o crescimento."
		)
	elif is_favorable:
		status = "favorable"
		reason = (
			"Há moradia, felicidade e reservas "
			+ "para sustentar o próximo dia."
		)
	elif projected_happiness < growth_minimum_happiness:
		reason = (
			"A felicidade precisa chegar a %.0f "
			+ "para atrair novos moradores."
		) % growth_minimum_happiness

	var projected_attraction: int = attraction_progress
	var projected_concerning: int = 0
	var projected_population: int = population
	var projected_movement: String = "none"

	if is_concerning:
		projected_concerning = concerning_streak + 1

		if (
			projected_concerning >= abandonment_target
			and population > protected_named_resident_count
		):
			projected_population -= 1
			projected_concerning = 0
			projected_attraction = 0
			projected_movement = "departure"
	elif is_favorable:
		projected_attraction += 1

		if projected_attraction >= attraction_target:
			projected_population += 1
			projected_attraction = 0
			projected_movement = "arrival"

	return {
		"status": status,
		"reason": reason,
		"is_favorable": is_favorable,
		"is_concerning": is_concerning,
		"population": population,
		"housing_capacity": housing_capacity,
		"available_housing": maxi(
			0,
			housing_capacity - population
		),
		"attraction_progress": attraction_progress,
		"attraction_target": attraction_target,
		"concerning_day_streak": concerning_streak,
		"abandonment_target": abandonment_target,
		"growth_minimum_happiness": growth_minimum_happiness,
		"projected_attraction_progress": projected_attraction,
		"projected_concerning_day_streak": projected_concerning,
		"projected_population": projected_population,
		"projected_movement": projected_movement,
		"next_food_need": next_food_need,
		"next_material_need": next_material_need
	}


func _build_population_resolution_text(
	resolution: Dictionary
) -> String:
	var movement: String = String(
		resolution.get(
			"movement",
			"none"
		)
	)
	var new_population: int = int(
		resolution.get(
			"new_population",
			get_total_population()
		)
	)

	if movement == "arrival":
		return (
			"CHEGADA: um novo habitante escolheu a vila. "
			+ "População: %d/%d."
		) % [
			new_population,
			int(
				get_population_overview().get(
					"housing_capacity",
					0
				)
			)
		]

	if movement == "departure":
		return (
			"ABANDONO: após %d dias preocupantes, "
			+ "um habitante deixou a vila. População: %d."
		) % [
			int(resolution.get("abandonment_target", 3)),
			new_population
		]

	var status: String = String(
		resolution.get(
			"status",
			"stable"
		)
	)

	if status == "favorable":
		return (
			"Atração da vila: %d/%d dias favoráveis."
			% [
				int(
					resolution.get(
						"attraction_progress",
						0
					)
				),
				int(resolution.get("attraction_target", 3))
			]
		)

	if status == "housing_paused":
		return (
			"CRESCIMENTO PAUSADO — construa uma casa."
		)

	if status == "concerning":
		return (
			"Risco de abandono: %d/%d dias preocupantes. %s"
			% [
				int(
					resolution.get(
						"concerning_day_streak",
						0
					)
				),
				int(resolution.get("abandonment_target", 3)),
				String(
					resolution.get(
						"reason",
						"A vila precisa de atenção."
					)
				)
			]
		)

	return "População estável — " + String(
		resolution.get(
			"reason",
			"a vila ainda não está atraindo novos moradores."
		)
	)


func _autosave_if_enabled() -> void:
	if debug_story_sequence_active:
		return
	if not save_manager.autosave_enabled:
		return

	save_game()


func _evaluate_campaign_after_day(
	completed_day: int
) -> void:
	var progress: Dictionary = (
		campaign_manager.evaluate_completed_day(
			completed_day,
			food,
			building_material,
			happiness,
			get_total_population()
		)
	)
	var checkpoint_evaluated: bool = bool(
		progress.get("checkpoint_evaluated", false)
	)
	var evaluation_report: Dictionary = {}
	if checkpoint_evaluated:
		evaluation_report = _build_evaluation_report(progress, completed_day)
		if campaign_manager.record_evaluation_report(evaluation_report):
			part3_foundation_manager.record_behavioral_medals(
				completed_day,
				evaluation_report.get("behavioral_medals", []) as Array
			)
		progress["evaluation_report"] = evaluation_report

	var checkpoint_passed: bool = (
		checkpoint_evaluated
		and bool(progress.get("checkpoint_passed", false))
	)
	var finished_now: bool = bool(progress.get("finished_now", false))
	if finished_now:
		var final_statistics: Dictionary = _build_final_statistics(
			String(progress.get("status", "defeat")),
			completed_day,
			evaluation_report
		)
		var final_profile: Dictionary = (
			CAMPAIGN_OUTCOME_CATALOG_SCRIPT.select_campaign_profile(final_statistics)
		)
		final_statistics["profile"] = final_profile.duplicate(true)
		campaign_manager.set_final_outcome(final_statistics, final_profile)
		progress["final_statistics"] = final_statistics
		progress["final_profile"] = final_profile

	progress = _refresh_campaign_event_progress(progress)
	progress = _enrich_campaign_progress(progress)
	campaign_progress_changed.emit(progress)

	if checkpoint_passed:
		var active_ids: Array[String] = []
		for villager: Villager in get_active_council():
			if is_instance_valid(villager):
				active_ids.append(villager.representative_id)
		part3_foundation_manager.record_successful_audit(
			active_ids,
			completed_day
		)
		_prepare_recruitment_offer(completed_day)
		if not finished_now:
			campaign_checkpoint_completed.emit(progress)
			village_visual_feedback_requested.emit({
				"kind": "major_success",
				"message": "Avaliação vencida",
				"target_id": "square"
			})

	if finished_now:
		_record_campaign_result(progress)
		village_visual_feedback_requested.emit({
			"kind": (
				"major_success"
				if String(progress.get("status", "")) == "victory"
				else "crisis"
			),
			"message": (
				"Campanha aprovada"
				if String(progress.get("status", "")) == "victory"
				else "Campanha encerrada em crise"
			),
			"target_id": "square"
		})
		campaign_finished.emit(progress)

	_finalize_construction_transition(completed_day)


func _refresh_campaign_event_progress(event_progress: Dictionary) -> Dictionary:
	var refreshed: Dictionary = campaign_manager.get_progress(
		current_day,
		food,
		building_material,
		happiness,
		get_total_population()
	)
	for key: String in [
		"finished_now",
		"checkpoint_evaluated",
		"checkpoint_passed",
		"evaluated_checkpoint_day",
		"evaluated_goals",
		"checkpoint_result_title",
		"checkpoint_result_text",
		"evaluation_report"
	]:
		if event_progress.has(key):
			refreshed[key] = event_progress[key]
	return refreshed


func _build_evaluation_report(
	progress: Dictionary,
	checkpoint_day: int
) -> Dictionary:
	var previous_reports: Array[Dictionary] = campaign_manager.get_evaluation_reports()
	var start_day: int = (
		int(previous_reports.back().get("checkpoint_day", 0))
		if not previous_reports.is_empty()
		else 0
	)
	var history: Array[Dictionary] = (
		part3_foundation_manager.get_production_history_between(start_day, checkpoint_day)
	)
	var interval_data: Dictionary = _build_interval_contribution_data(
		start_day,
		checkpoint_day,
		history
	)
	var goal_rows: Array[Dictionary] = []
	var evaluated_goals_value: Variant = progress.get("evaluated_goals", [])
	if evaluated_goals_value is Array:
		for goal_value: Variant in evaluated_goals_value as Array:
			if not goal_value is Dictionary:
				continue
			var goal: Dictionary = (goal_value as Dictionary).duplicate(true)
			var actual: float = float(goal.get("current_value", 0.0))
			var target: float = float(goal.get("target_value", 0.0))
			goal["actual_value"] = actual
			goal["difference"] = actual - target
			goal["result_label"] = "ATINGIDA" if bool(goal.get("met", false)) else "NÃO ATINGIDA"
			goal_rows.append(goal)
	var comparison: Array[Dictionary] = _build_evaluation_comparison(
		goal_rows,
		previous_reports
	)
	var passed: bool = bool(progress.get("checkpoint_passed", false))
	var consequences: Array[String] = []
	if passed:
		consequences.append("A campanha continua e esta avaliação fica registrada no histórico.")
		if checkpoint_day < VillageCampaignCatalog.CAMPAIGN_TOTAL_DAYS:
			consequences.append("Uma oferta de recrutamento pode ser preparada para o Conselho.")
	else:
		consequences.append(String(progress.get("result_text", "A campanha terminou nesta avaliação.")))
	return {
		"checkpoint_day": checkpoint_day,
		"period_start_day": start_day + 1,
		"period_end_day": checkpoint_day,
		"passed": passed,
		"result_label": "APROVADA" if passed else "REPROVADA",
		"goals": goal_rows,
		"resource_breakdown": _build_period_resource_breakdown(history),
		"councillor_contributions": interval_data.get("contributions", []),
		"behavioral_medals": interval_data.get("medals", []),
		"comparison_with_previous": comparison,
		"factors": _build_period_factors(start_day, checkpoint_day),
		"consequences": consequences
	}


func _build_interval_contribution_data(
	start_day: int,
	end_day: int,
	history: Array[Dictionary]
) -> Dictionary:
	var metrics_by_id: Dictionary = {}
	for entry: Dictionary in history:
		var shortages: Dictionary = entry.get("shortages", {})
		var crisis_day: bool = (
			float(shortages.get("food", 0.0)) > RESOURCE_EPSILON
			or float(shortages.get("material", 0.0)) > RESOURCE_EPSILON
		)
		var day_value: int = int(entry.get("day", 0))
		for row_value: Variant in entry.get("councillors", []) as Array:
			if not row_value is Dictionary:
				continue
			var row: Dictionary = row_value as Dictionary
			if not bool(row.get("is_active", false)):
				continue
			var representative_id: String = String(row.get("representative_id", ""))
			if representative_id.is_empty():
				continue
			var metrics: Dictionary = metrics_by_id.get(
				representative_id,
				_create_empty_contribution_metrics(row)
			)
			var output: float = 0.0
			for resource_id: String in ["food", "material", "happiness"]:
				var amount: float = float(row.get(resource_id, 0.0))
				metrics[resource_id] = float(metrics.get(resource_id, 0.0)) + amount
				output += amount
			metrics["active_days"] = int(metrics.get("active_days", 0)) + 1
			metrics["total_output"] = float(metrics.get("total_output", 0.0)) + output
			if crisis_day:
				metrics["crisis_output"] = float(metrics.get("crisis_output", 0.0)) + output
			if day_value == end_day:
				metrics["checkpoint_output"] = output
			var profession_name: String = String(row.get("profession_name", "Sem profissão"))
			var professions: Dictionary = metrics.get("professions", {})
			professions[profession_name] = true
			metrics["professions"] = professions
			if float(row.get("specialization_bonus", 0.0)) > 0.001:
				metrics["specialization_days"] = int(metrics.get("specialization_days", 0)) + 1
			if bool(row.get("passive_active", false)):
				metrics["passive_active_days"] = int(metrics.get("passive_active_days", 0)) + 1
			metrics_by_id[representative_id] = metrics
	var all_progress: Dictionary = part3_foundation_manager.get_all_councillor_progress()
	for representative_id_value: Variant in metrics_by_id.keys():
		var representative_id: String = String(representative_id_value)
		var metrics: Dictionary = metrics_by_id[representative_id]
		var progress: Dictionary = all_progress.get(representative_id, {})
		var resolved_actions: int = 0
		for history_value: Variant in progress.get("history_entries", []) as Array:
			if not history_value is Dictionary:
				continue
			var personal_entry: Dictionary = history_value as Dictionary
			var action_day: int = int(personal_entry.get("day", 0))
			var action_type: String = String(personal_entry.get("type", ""))
			if action_day > start_day and action_day <= end_day and action_type in [
				"event",
				"council_project_completed",
				"founder_memory"
			]:
				resolved_actions += 1
		metrics["resolved_actions"] = resolved_actions
		metrics["profession_variety"] = (metrics.get("professions", {}) as Dictionary).size()
		metrics_by_id[representative_id] = metrics
	var medals: Array[Dictionary] = (
		CAMPAIGN_OUTCOME_CATALOG_SCRIPT.select_behavior_medals(metrics_by_id)
	)
	var contributions: Array[Dictionary] = []
	for metrics_value: Variant in metrics_by_id.values():
		if not metrics_value is Dictionary:
			continue
		var metrics: Dictionary = (metrics_value as Dictionary).duplicate(true)
		var profession_names: Array[String] = []
		for profession_value: Variant in (metrics.get("professions", {}) as Dictionary).keys():
			profession_names.append(String(profession_value))
		profession_names.sort()
		metrics["profession_names"] = profession_names
		metrics.erase("professions")
		contributions.append(metrics)
	contributions.sort_custom(_sort_contributions)
	return {"contributions": contributions, "medals": medals}


func _create_empty_contribution_metrics(row: Dictionary) -> Dictionary:
	return {
		"representative_id": String(row.get("representative_id", "")),
		"display_name": String(row.get("display_name", "Conselheiro")),
		"food": 0.0,
		"material": 0.0,
		"happiness": 0.0,
		"total_output": 0.0,
		"active_days": 0,
		"profession_variety": 0,
		"professions": {},
		"crisis_output": 0.0,
		"checkpoint_output": 0.0,
		"resolved_actions": 0,
		"specialization_days": 0,
		"passive_active_days": 0
	}


func _build_period_resource_breakdown(
	history: Array[Dictionary]
) -> Dictionary:
	var result: Dictionary = {}
	for resource_id: String in ["food", "material", "happiness"]:
		var opening: float = 0.0
		var closing: float = 0.0
		var produced: float = 0.0
		var costs: float = 0.0
		var shortages: float = 0.0
		if not history.is_empty():
			opening = float(history.front().get("resources_before", {}).get(resource_id, 0.0))
			closing = float(history.back().get("resources_after", {}).get(resource_id, 0.0))
		for entry: Dictionary in history:
			produced += float(entry.get("production", {}).get(resource_id, 0.0))
			costs += float(entry.get("costs", {}).get(resource_id, 0.0))
			shortages += float(entry.get("shortages", {}).get(resource_id, 0.0))
		result[resource_id] = {
			"opening": opening,
			"production": produced,
			"costs": costs,
			"other_adjustments": closing - (opening + produced - costs),
			"shortages": shortages,
			"closing": closing,
			"net_change": closing - opening
		}
	return result


func _build_evaluation_comparison(
	goals: Array[Dictionary],
	previous_reports: Array[Dictionary]
) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if previous_reports.is_empty():
		return result
	var previous: Dictionary = previous_reports.back()
	var previous_by_id: Dictionary = {}
	for previous_goal_value: Variant in previous.get("goals", []) as Array:
		if previous_goal_value is Dictionary:
			var previous_goal: Dictionary = previous_goal_value as Dictionary
			previous_by_id[String(previous_goal.get("id", ""))] = previous_goal
	for goal: Dictionary in goals:
		var goal_id: String = String(goal.get("id", ""))
		if not previous_by_id.has(goal_id):
			continue
		var old_goal: Dictionary = previous_by_id[goal_id]
		var old_actual: float = float(old_goal.get("actual_value", old_goal.get("current_value", 0.0)))
		var actual: float = float(goal.get("actual_value", 0.0))
		result.append({
			"id": goal_id,
			"label": String(goal.get("label", goal_id)),
			"previous_value": old_actual,
			"current_value": actual,
			"change": actual - old_actual
		})
	return result


func _build_period_factors(start_day: int, end_day: int) -> Dictionary:
	var categories: Dictionary = {}
	var completed_constructions: int = 0
	var event_decisions: int = 0
	var relationship_decisions: int = 0
	for decision: Dictionary in part3_foundation_manager.get_decision_history():
		var day_value: int = int(decision.get("day", 0))
		if day_value <= start_day or day_value > end_day:
			continue
		var category: String = String(decision.get("category", "other"))
		categories[category] = int(categories.get(category, 0)) + 1
		if category == "construction_completed":
			completed_constructions += 1
		if "event" in category:
			event_decisions += 1
		if "relationship" in category:
			relationship_decisions += 1
	return {
		"decision_count": _sum_integer_dictionary(categories),
		"decision_categories": categories,
		"completed_constructions": completed_constructions,
		"event_decisions": event_decisions,
		"relationship_decisions": relationship_decisions
	}


func _build_final_statistics(
	status: String,
	completed_day: int,
	final_evaluation_report: Dictionary
) -> Dictionary:
	var history: Array[Dictionary] = (
		part3_foundation_manager.get_production_history_between(0, completed_day)
	)
	var totals: Dictionary = {
		"food_produced": 0.0,
		"material_produced": 0.0,
		"happiness_produced": 0.0,
		"food_consumed": 0.0,
		"material_consumed": 0.0,
		"happiness_decay": 0.0
	}
	var shortage_days: int = 0
	var crisis_days: int = 0
	var maximum_population: int = get_total_population()
	var minimum_happiness: float = happiness
	var happiness_total: float = 0.0
	for entry: Dictionary in history:
		var production: Dictionary = entry.get("production", {})
		var costs: Dictionary = entry.get("costs", {})
		var shortages: Dictionary = entry.get("shortages", {})
		var resources_after: Dictionary = entry.get("resources_after", {})
		totals["food_produced"] = float(totals["food_produced"]) + float(production.get("food", 0.0))
		totals["material_produced"] = float(totals["material_produced"]) + float(production.get("material", 0.0))
		totals["happiness_produced"] = float(totals["happiness_produced"]) + float(production.get("happiness", 0.0))
		totals["food_consumed"] = float(totals["food_consumed"]) + float(costs.get("food", 0.0))
		totals["material_consumed"] = float(totals["material_consumed"]) + float(costs.get("material", 0.0))
		totals["happiness_decay"] = float(totals["happiness_decay"]) + float(costs.get("happiness", 0.0))
		var had_shortage: bool = float(shortages.get("food", 0.0)) > RESOURCE_EPSILON or float(shortages.get("material", 0.0)) > RESOURCE_EPSILON
		if had_shortage:
			shortage_days += 1
		if float(resources_after.get("food", 0.0)) <= RESOURCE_EPSILON or float(resources_after.get("material", 0.0)) <= RESOURCE_EPSILON:
			crisis_days += 1
		maximum_population = maxi(maximum_population, int(entry.get("population_after", 0)))
		var day_happiness: float = float(resources_after.get("happiness", happiness))
		minimum_happiness = minf(minimum_happiness, day_happiness)
		happiness_total += day_happiness
	var all_progress: Dictionary = part3_foundation_manager.get_all_councillor_progress()
	var profession_names: Dictionary = {}
	var councillor_summaries: Array[Dictionary] = []
	for progress_value: Variant in all_progress.values():
		if not progress_value is Dictionary:
			continue
		var councillor: Dictionary = progress_value as Dictionary
		for profession_value: Variant in (councillor.get("profession_day_counts", {}) as Dictionary).keys():
			profession_names[String(profession_value)] = true
		councillor_summaries.append({
			"representative_id": String(councillor.get("representative_id", "")),
			"display_name": String(councillor.get("display_name", "Conselheiro")),
			"level": int(councillor.get("level", 1)),
			"days_in_council": int(councillor.get("days_in_council", 0)),
			"events_resolved": int(councillor.get("events_resolved", 0)),
			"projects_completed": int(councillor.get("council_projects_completed", 0)),
			"behavioral_medals": (councillor.get("behavioral_medals", []) as Array).duplicate(true)
		})
	var relationship: Dictionary = get_relationship_overview()
	var npc_relationships: Dictionary = get_npc_relationship_overview()
	var resolved_pair_actions: int = 0
	for pair_value: Variant in npc_relationships.get("pairs", []) as Array:
		if pair_value is Dictionary:
			resolved_pair_actions += int((pair_value as Dictionary).get("resolved_count", 0))
	var building_state: Dictionary = get_building_state()
	var decision_history: Array[Dictionary] = part3_foundation_manager.get_decision_history()
	var decision_categories: Dictionary = {}
	for decision: Dictionary in decision_history:
		var category: String = String(decision.get("category", "other"))
		decision_categories[category] = int(decision_categories.get(category, 0)) + 1
	var closing_medals: Array[Dictionary] = []
	if not final_evaluation_report.is_empty():
		closing_medals = (final_evaluation_report.get("behavioral_medals", []) as Array).duplicate(true)
	else:
		var reports: Array[Dictionary] = campaign_manager.get_evaluation_reports()
		var start_day: int = int(reports.back().get("checkpoint_day", 0)) if not reports.is_empty() else 0
		var closing_data: Dictionary = _build_interval_contribution_data(
			start_day,
			completed_day,
			part3_foundation_manager.get_production_history_between(start_day, completed_day)
		)
		closing_medals.assign(closing_data.get("medals", []) as Array)
		part3_foundation_manager.record_behavioral_medals(completed_day, closing_medals)
	var identity: Dictionary = get_campaign_identity()
	return {
		"status": status,
		"completed_days": completed_day,
		"campaign_total_days": VillageCampaignCatalog.CAMPAIGN_TOTAL_DAYS,
		"checkpoints_approved": campaign_manager.completed_checkpoint_days.size(),
		"checkpoints_total": VillageCampaignCatalog.CHECKPOINTS.size(),
		"final_population": get_total_population(),
		"maximum_population": maximum_population,
		"final_food": food,
		"final_material": building_material,
		"final_happiness": happiness,
		"average_happiness": happiness_total / maxf(1.0, float(history.size())),
		"lowest_happiness": minimum_happiness,
		"shortage_days": shortage_days,
		"crisis_days": crisis_days,
		"production_totals": totals,
		"built_upgrades": int(building_state.get("built_upgrades", 0)),
		"house_count": int(building_state.get("house_count", 0)),
		"building_variants": building_manager.get_building_variants(),
		"decision_count": decision_history.size(),
		"decision_categories": decision_categories,
		"profession_variety": profession_names.size(),
		"councillors": councillor_summaries,
		"positive_npc_pairs": int(npc_relationships.get("positive_pair_count", 0)),
		"resolved_relationship_actions": resolved_pair_actions,
		"known_relationships": (relationship.get("entries", []) as Array).size(),
		"official_partner_name": String(relationship.get("official_partner_name", "Nenhum")),
		"closing_behavioral_medals": closing_medals,
		"village_name": String(identity.get("village_name", "Vila")),
		"difficulty_name": String(identity.get("difficulty_name", "Moderado")),
		"campaign_seed": int(identity.get("campaign_seed", 0)),
		"generator_version": int(identity.get("generator_version", 1))
	}


func _sum_integer_dictionary(values: Dictionary) -> int:
	var total: int = 0
	for value: Variant in values.values():
		total += int(value)
	return total


func _sort_contributions(a: Dictionary, b: Dictionary) -> bool:
	var a_total: float = float(a.get("total_output", 0.0))
	var b_total: float = float(b.get("total_output", 0.0))
	if not is_equal_approx(a_total, b_total):
		return a_total > b_total
	return String(a.get("display_name", "")) < String(b.get("display_name", ""))


func _finalize_construction_transition(completed_day: int) -> void:
	if debug_story_sequence_active:
		return

	var completion: Dictionary = (
		building_manager.finalize_completed_constructions(completed_day)
	)
	var applied_orders: Array = completion.get("applied_orders", [])
	if not applied_orders.is_empty():
		foundation_manager.population_state.set_housing_capacity(
			building_manager.get_housing_capacity()
		)
		for order_value: Variant in applied_orders:
			if not order_value is Dictionary:
				continue
			var order: Dictionary = order_value as Dictionary
			part3_foundation_manager.record_decision(
				current_day,
				"construction_completed",
				String(order.get("order_id", "")),
				"",
				{
					"building_id": String(order.get("building_id", "")),
					"target_level": int(order.get("target_level", 0)),
					"variant_id": String(order.get("variant_id", "")),
					"completed_work_day": completed_day
				},
				{"available_day": current_day}
			)
			var completed_variant_id: String = String(
				order.get("variant_id", "")
			)
			if not completed_variant_id.is_empty():
				_queue_building_variant_reaction(completed_variant_id)

	var started: Dictionary = {"started_orders": [], "message": ""}
	if not is_campaign_finished() or is_free_play():
		started = building_manager.start_constructions_for_day(
			current_day,
			get_total_population()
		)

	var messages: Array[String] = []
	var completion_message: String = String(completion.get("message", ""))
	var started_message: String = String(started.get("message", ""))
	if not completion_message.is_empty():
		messages.append(completion_message)
	if not started_message.is_empty():
		messages.append(started_message)

	if not applied_orders.is_empty():
		resources_changed.emit(food, building_material, happiness, current_day)
		campaign_progress_changed.emit(get_campaign_progress())

	var started_orders: Array = started.get("started_orders", []) as Array
	if not applied_orders.is_empty():
		var completed_order: Dictionary = applied_orders[0] as Dictionary
		village_visual_feedback_requested.emit({
			"kind": "success",
			"message": (
				"Obra concluída"
				if applied_orders.size() == 1
				else "%d obras concluídas" % applied_orders.size()
			),
			"target_id": String(completed_order.get("building_id", "square"))
		})
	elif not started_orders.is_empty():
		var started_order: Dictionary = started_orders[0] as Dictionary
		village_visual_feedback_requested.emit({
			"kind": "construction",
			"message": (
				"Canteiro em atividade"
				if started_orders.size() == 1
				else "%d canteiros em atividade" % started_orders.size()
			),
			"target_id": String(started_order.get("building_id", "square"))
		})

	if not messages.is_empty() or not applied_orders.is_empty() or not (
		started_orders
	).is_empty():
		buildings_changed.emit(
			get_building_state(),
			"\n".join(messages)
		)


func _queue_building_variant_reaction(variant_id: String) -> void:
	var variant: Dictionary = BUILDING_VARIANT_CATALOG_SCRIPT.get_variant(variant_id)
	if variant.is_empty():
		return
	var preferred_npc_id: String = String(
		variant.get("preferred_npc_id", "")
	)
	var dialogue_id: String = String(
		variant.get("fallback_dialogue_id", "")
	)
	if (
		not preferred_npc_id.is_empty()
		and story_manager.is_npc_recruited(preferred_npc_id)
	):
		dialogue_id = String(variant.get("dialogue_id", dialogue_id))
	if dialogue_id.is_empty():
		return
	var had_pending_dialogue: bool = story_manager.has_pending_dialogue()
	var queued: bool = story_manager.queue_custom_dialogue(
		dialogue_id,
		"building_variant_reaction",
		{
			"variant_id": variant_id,
			"building_id": String(variant.get("building_id", ""))
		}
	)
	if not queued or had_pending_dialogue:
		return
	var pending_request: Dictionary = story_manager.get_pending_dialogue_request()
	if (
		String(pending_request.get("dialogue_id", "")) == dialogue_id
		and not has_active_event()
		and not has_pending_level_dialogue()
	):
		story_dialogue_requested.emit(pending_request)


func _record_campaign_result(progress: Dictionary) -> void:
	var identity: Dictionary = get_campaign_identity()
	var final_profile: Dictionary = progress.get("final_profile", {})
	var statistics: Dictionary = progress.get("final_statistics", {})
	CAMPAIGN_RECORDS_SCRIPT.record_campaign({
		"status": String(progress.get("status", "defeat")),
		"campaign_profile_id": String(
			final_profile.get("id", "administracao_equilibrada")
		),
		"campaign_profile_name": String(
			final_profile.get("name", "Administração Equilibrada")
		),
		"campaign_profile_description": String(
			final_profile.get("description", "")
		),
		"difficulty_id": get_current_difficulty_id(),
		"difficulty_name": get_current_difficulty_name(),
		"player_name": String(identity.get("player_name", "Alex")),
		"village_name": String(identity.get("village_name", "Vila")),
		"campaign_seed": int(identity.get("campaign_seed", 0)),
		"generator_version": int(identity.get("generator_version", 1)),
		"completed_days": int(statistics.get("completed_days", 120)),
		"checkpoints_approved": int(statistics.get("checkpoints_approved", 6)),
		"population": get_total_population(),
		"food": food,
		"material": building_material,
		"happiness": happiness,
		"partner_name": String(statistics.get("official_partner_name", "Nenhum"))
	})


func _emit_season_hint_after_day(
	completed_day: int
) -> void:
	if is_campaign_finished():
		return

	var hint: Dictionary = (
		VillageCampaignCatalog.get_season_transition_hint_after_day(
			completed_day
		)
	)

	if hint.is_empty():
		return

	var hint_id: String = String(
		hint.get("id", "")
	)

	if (
		hint_id.is_empty()
		or shown_season_hint_ids.has(hint_id)
	):
		return

	shown_season_hint_ids.append(hint_id)
	season_hint_available.emit(hint)


func _apply_resource_effects(
	effects: Dictionary
) -> void:
	food = maxf(
		0.0,
		food + float(effects.get("food", 0.0))
	)

	building_material = maxf(
		0.0,
		building_material
		+ float(
			effects.get(
				"material",
				0.0
			)
		)
	)

	happiness = clampf(
		happiness
		+ float(
			effects.get(
				"happiness",
				0.0
			)
		),
		0.0,
		MAX_HAPPINESS
	)


func _build_resource_changes_text(
	food_change: float,
	material_change: float,
	happiness_change: float
) -> String:
	var changes: Array[String] = []

	if not is_zero_approx(food_change):
		changes.append(
			"Alimentação: "
			+ _format_signed_change(food_change)
		)

	if not is_zero_approx(material_change):
		changes.append(
			"Material: "
			+ _format_signed_change(material_change)
		)

	if not is_zero_approx(happiness_change):
		changes.append(
			"Felicidade: "
			+ _format_signed_change(happiness_change)
		)

	if changes.is_empty():
		return "Nenhum recurso foi alterado."

	return "Consequências: " + ", ".join(changes) + "."


func _format_signed_change(value: float) -> String:
	var formatted_value: String = "%.1f" % value

	if value > 0.0:
		formatted_value = "+" + formatted_value

	return formatted_value
