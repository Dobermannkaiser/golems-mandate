extends Node


const FoundationManagerScript = preload(
	"res://scripts/foundation/Part2FoundationManager.gd"
)
const Part3FoundationManagerScript = preload(
	"res://scripts/foundation/Part3FoundationManager.gd"
)
const CampaignManagerScript = preload(
	"res://scripts/campaign/CampaignManager.gd"
)
const BuildingManagerScript = preload(
	"res://scripts/buildings/BuildingManager.gd"
)
const StoryManagerScript = preload(
	"res://scripts/story/StoryManager.gd"
)
const EventManagerScript = preload(
	"res://scripts/events/EventManager.gd"
)
const FounderMemoryManagerScript = preload(
	"res://scripts/events/FounderMemoryManager.gd"
)
const RecruitmentManagerScript = preload(
	"res://scripts/council/CouncilRecruitmentManager.gd"
)
const OpportunityManagerScript = preload(
	"res://scripts/council/CouncillorOpportunityManager.gd"
)
const NpcRelationshipManagerScript = preload(
	"res://scripts/relationships/NpcRelationshipManager.gd"
)
const SaveManagerScript = preload("res://scripts/save/SaveManager.gd")
const DifficultyCatalogScript = preload(
	"res://scripts/campaign/DifficultyCatalog.gd"
)

const CAMPAIGN_SEED: int = 250025
const GAME_DAY: int = 8
const COMPLETED_DAY: int = 7
const RELATIONSHIP_NPC_ID: String = "aelric_ferreiro"
const INVARIANT_NAMES: Array[String] = [
	"PROFILE",
	"POPULATION",
	"CALENDAR",
	"NPC",
	"RELATIONSHIP",
	"STORY",
	"CAMPAIGN",
	"BUILDINGS",
	"RESOURCES"
]


func _ready() -> void:
	var source: Dictionary = _create_runtime()
	var construction_results: Dictionary = _build_nontrivial_state(source)
	_print_construction_results(construction_results)

	var before: Dictionary = _semantic_snapshot(source)
	_print_snapshot("INTEGRATED_BEFORE", before)

	var exported_a: Dictionary = _build_game_state(source)
	var transport_a: Dictionary = _json_transport(exported_a)
	_print_transport_result("A", transport_a)

	var restored_b: Dictionary = _create_runtime()
	var imports_b: Dictionary = _import_game_state(
		restored_b,
		transport_a.get("game_state", {}) as Dictionary
	)
	_print_import_results(imports_b)
	var after: Dictionary = _semantic_snapshot(restored_b)
	_print_snapshot("INTEGRATED_AFTER", after)

	var invariants: Dictionary = _compare_invariants(before, after)
	var first_roundtrip_ok: bool = (
		_all_true(construction_results)
		and bool(transport_a.get("success", false))
		and _all_true(imports_b)
		and _all_true(invariants)
	)
	if first_roundtrip_ok:
		print("INTEGRATED_ROUNDTRIP_ALL_OK")
	else:
		print("INTEGRATED_ROUNDTRIP_FAILED")

	var triple_ok: bool = _run_triple_roundtrip(
		before,
		restored_b,
		after,
		bool(transport_a.get("success", false)) and _all_true(imports_b)
	)
	if triple_ok:
		print("INTEGRATED_TRIPLE_ROUNDTRIP_OK")
	else:
		print("INTEGRATED_TRIPLE_ROUNDTRIP_FAILED")

	var determinism_ok: bool = _run_determinism(
		transport_a.get("game_state", {}) as Dictionary
	)
	if determinism_ok:
		print("INTEGRATED_DETERMINISM_OK")
	else:
		print("INTEGRATED_DETERMINISM_FAILED")

	if first_roundtrip_ok and triple_ok and determinism_ok:
		print("INTEGRATED_TEST_ALL_OK")
	else:
		print("INTEGRATED_TEST_FAILED")


func _create_runtime() -> Dictionary:
	var part3_foundation = Part3FoundationManagerScript.new()
	part3_foundation.setup(CAMPAIGN_SEED)
	var event_manager = EventManagerScript.new()
	event_manager.setup(part3_foundation.campaign_seed)
	var founder_memory = FounderMemoryManagerScript.new()
	founder_memory.setup()
	var campaign = CampaignManagerScript.new()
	campaign.setup()
	var buildings = BuildingManagerScript.new()
	buildings.setup()
	var foundation = FoundationManagerScript.new()
	foundation.setup()
	var recruitment = RecruitmentManagerScript.new()
	recruitment.setup()
	var opportunities = OpportunityManagerScript.new()
	opportunities.setup()
	var story = StoryManagerScript.new()
	story.setup(false)
	var npc_relationships = NpcRelationshipManagerScript.new()
	npc_relationships.setup()

	return {
		"foundation": foundation,
		"part3_foundation": part3_foundation,
		"events": event_manager,
		"founder_memories": founder_memory,
		"campaign": campaign,
		"buildings": buildings,
		"recruitment": recruitment,
		"opportunities": opportunities,
		"story": story,
		"npc_relationships": npc_relationships,
		"resources": {
			"food": 30.0,
			"building_material": 10.0,
			"happiness": 60.0
		}
	}


func _build_nontrivial_state(runtime: Dictionary) -> Dictionary:
	var foundation = runtime["foundation"]
	var campaign = runtime["campaign"]
	var buildings = runtime["buildings"]
	var story = runtime["story"]

	foundation.configure_player_profile(
		"Ayla",
		"feminino",
		"hard",
		"Pedra Serena"
	)
	var profile: Dictionary = foundation.get_player_profile_overview()
	var profile_ok: bool = (
		String(profile.get("name", "")) == "Ayla"
		and String(profile.get("gender_id", "")) == "feminino"
		and String(profile.get("difficulty_id", "")) == "hard"
		and String(profile.get("village_name", "")) == "Pedra Serena"
	)

	var resident_added: bool = foundation.population_state.add_named_story_resident()
	var population_change: Dictionary = (
		foundation.population_state.apply_daily_conditions(
			true,
			false,
			"growing",
			"Condições integradas favoráveis."
		)
	)
	var population_ok: bool = (
		resident_added
		and foundation.population_state.total_population == 9
		and foundation.population_state.protected_named_resident_count == 6
		and int(population_change.get("attraction_progress", -1)) == 1
	)

	foundation.calendar_state.synchronize_with_game_day(GAME_DAY)
	var calendar_ok: bool = foundation.calendar_state.current_day == GAME_DAY

	var npc_known: bool = foundation.mark_npc_known(RELATIONSHIP_NPC_ID)
	var relationship_result: Dictionary = foundation.register_relationship_response(
		RELATIONSHIP_NPC_ID,
		COMPLETED_DAY,
		"good",
		125,
		"integrated_roundtrip_topic"
	)
	var relationship_ok: bool = (
		npc_known
		and bool(relationship_result.get("success", false))
		and int(relationship_result.get("applied_points", 0)) == 125
	)

	var first_story: bool = story.queue_custom_dialogue(
		"integrated_notice",
		"integrated_state_notice",
		{"source": "integrated_roundtrip", "day": "8"}
	)
	var second_story: bool = story.queue_custom_dialogue(
		"integrated_follow_up",
		"integrated_state_follow_up",
		{"source": "integrated_roundtrip", "sequence": "2"}
	)
	var story_ok: bool = (
		first_story
		and second_story
		and story.has_pending_dialogue()
		and story.custom_dialogue_queue.size() == 1
	)

	campaign.setup("hard")
	for day: int in range(1, COMPLETED_DAY + 1):
		campaign.evaluate_completed_day(day, 80.0, 60.0, 74.0, 9)
	var campaign_ok: bool = (
		campaign.completed_days == COMPLETED_DAY
		and campaign.status == campaign.STATUS_ACTIVE
		and is_equal_approx(campaign.lowest_happiness, 74.0)
	)

	buildings.configure_difficulty(1.0)
	var building_result: Dictionary = buildings.request_construction(
		"housing",
		100.0,
		COMPLETED_DAY
	)
	var buildings_ok: bool = (
		bool(building_result.get("queued", false))
		and buildings.get_queued_order_count() == 1
		and buildings.get_housing_capacity()
		== foundation.population_state.housing_capacity
	)

	runtime["resources"] = {
		"food": 47.5,
		"building_material": 83.0,
		"happiness": 74.25
	}

	return {
		"PROFILE": profile_ok,
		"POPULATION": population_ok,
		"CALENDAR": calendar_ok,
		"NPC_RELATIONSHIP": relationship_ok,
		"STORY": story_ok,
		"CAMPAIGN": campaign_ok,
		"BUILDINGS": buildings_ok,
		"RESOURCES": true
	}


func _build_game_state(runtime: Dictionary) -> Dictionary:
	var foundation = runtime["foundation"]
	var game_state: Dictionary = foundation.build_save_sections(
		GAME_DAY,
		_representative_states()
	)
	game_state["resources"] = (
		(runtime["resources"] as Dictionary).duplicate(true)
	)
	game_state["events"] = runtime["events"].export_save_data()
	game_state["founder_memories"] = (
		runtime["founder_memories"].export_save_data()
	)
	game_state["campaign"] = runtime["campaign"].export_save_data()
	game_state["buildings"] = runtime["buildings"].export_save_data()
	game_state["story"] = runtime["story"].export_save_data()
	game_state["part3_foundation"] = (
		runtime["part3_foundation"].export_save_data()
	)
	game_state["council_recruitment"] = (
		runtime["recruitment"].export_save_data()
	)
	game_state["councillor_opportunities"] = (
		runtime["opportunities"].export_save_data()
	)
	game_state["npc_relationships"] = (
		runtime["npc_relationships"].export_save_data()
	)
	game_state["runtime"] = {
		"pending_campaign_completed_day": 0,
		"shown_season_hint_ids": ["season_hint_spring"],
		"pending_level_dialogues": [],
		"active_level_dialogue": {},
		"pending_level_resume_mode": ""
	}
	return game_state


func _json_transport(game_state: Dictionary) -> Dictionary:
	var save_manager = SaveManagerScript.new()
	var schema_before_error: String = String(
		save_manager.call("_get_game_state_schema_error", game_state)
	)
	var save_root: Dictionary = {
		"save_version": SaveManagerScript.SAVE_VERSION,
		"save_schema_id": SaveManagerScript.SAVE_SCHEMA_ID,
		"project_version": String(
			ProjectSettings.get_setting("application/config/version", "")
		),
		"saved_at_unix": 250025,
		"saved_at_text": "integrated-roundtrip",
		"game_state": game_state.duplicate(true)
	}
	var serialized: String = JSON.stringify(save_root, "\t", false)
	var parser: JSON = JSON.new()
	var parse_error: Error = parser.parse(serialized)
	if parse_error != OK or not parser.data is Dictionary:
		return {
			"success": false,
			"schema_before_error": schema_before_error,
			"schema_after_error": "parse_failed",
			"game_state": {},
			"serialized_sha256": serialized.sha256_text()
		}
	var parsed_root: Dictionary = parser.data as Dictionary
	var parsed_state_value: Variant = parsed_root.get("game_state", null)
	if not parsed_state_value is Dictionary:
		return {
			"success": false,
			"schema_before_error": schema_before_error,
			"schema_after_error": "missing_game_state",
			"game_state": {},
			"serialized_sha256": serialized.sha256_text()
		}
	var parsed_state: Dictionary = parsed_state_value as Dictionary
	var schema_after_error: String = String(
		save_manager.call("_get_game_state_schema_error", parsed_state)
	)
	return {
		"success": (
			not serialized.strip_edges().is_empty()
			and schema_before_error.is_empty()
			and schema_after_error.is_empty()
		),
		"schema_before_error": schema_before_error,
		"schema_after_error": schema_after_error,
		"game_state": parsed_state.duplicate(true),
		"serialized_sha256": serialized.sha256_text()
	}


func _import_game_state(runtime: Dictionary, game_state: Dictionary) -> Dictionary:
	var foundation = runtime["foundation"]
	var campaign = runtime["campaign"]
	var buildings = runtime["buildings"]
	var story = runtime["story"]
	var part3_foundation = runtime["part3_foundation"]
	var recruitment = runtime["recruitment"]
	var opportunities = runtime["opportunities"]
	var npc_relationships = runtime["npc_relationships"]
	var founder_memories = runtime["founder_memories"]
	var events = runtime["events"]

	var foundation_ok: bool = foundation.import_save_sections(
		game_state,
		_representative_states().size()
	)
	var difficulty_id: String = String(
		foundation.get_player_profile_overview().get("difficulty_id", "moderate")
	)
	var rules: Dictionary = DifficultyCatalogScript.get_difficulty(difficulty_id)
	foundation.refresh_population_difficulty()

	var campaign_ok: bool = campaign.import_save_data(
		game_state.get("campaign", {}) as Dictionary
	)
	campaign.set_difficulty(difficulty_id)
	var buildings_ok: bool = buildings.import_save_data(
		game_state.get("buildings", {}) as Dictionary
	)
	buildings.configure_difficulty(
		float(rules.get("building_cost_multiplier", 1.0))
	)
	var story_ok: bool = story.import_save_data(
		game_state.get("story", {}) as Dictionary
	)
	var part3_ok: bool = part3_foundation.import_save_data(
		game_state.get("part3_foundation", {}) as Dictionary
	)
	events.configure_seed(part3_foundation.campaign_seed)
	founder_memories.configure_difficulty(
		int(rules.get("event_window_day_adjustment", 0))
	)
	var recruitment_ok: bool = recruitment.import_save_data(
		game_state.get("council_recruitment", {}) as Dictionary
	)
	var opportunities_ok: bool = opportunities.import_save_data(
		game_state.get("councillor_opportunities", {}) as Dictionary
	)
	var npc_relationships_ok: bool = npc_relationships.import_save_data(
		game_state.get("npc_relationships", {}) as Dictionary
	)
	var capacity_ok: bool = (
		buildings.get_housing_capacity()
		== int(
			foundation.get_population_overview().get("housing_capacity", 0)
		)
	)

	var resources_value: Variant = game_state.get("resources", null)
	var resources_ok: bool = resources_value is Dictionary
	if resources_ok:
		var resources: Dictionary = resources_value as Dictionary
		runtime["resources"] = {
			"food": maxf(0.0, float(resources.get("food", 30.0))),
			"building_material": maxf(
				0.0,
				float(resources.get("building_material", 10.0))
			),
			"happiness": clampf(
				float(resources.get("happiness", 60.0)),
				0.0,
				100.0
			)
		}

	var founder_ok: bool = founder_memories.import_save_data(
		game_state.get("founder_memories", {}) as Dictionary
	)
	var dependency_ok: bool = events.set_external_events(
		founder_memories.get_registered_events()
	)
	var events_ok: bool = events.import_save_data(
		game_state.get("events", {}) as Dictionary
	)

	return {
		"FOUNDATION": foundation_ok,
		"PROFILE": foundation_ok,
		"POPULATION": foundation_ok,
		"CALENDAR": foundation_ok,
		"NPCS": foundation_ok,
		"RELATIONSHIPS": foundation_ok,
		"CAMPAIGN": campaign_ok,
		"BUILDINGS": buildings_ok,
		"STORY": story_ok,
		"PART3_FOUNDATION": part3_ok,
		"RECRUITMENT": recruitment_ok,
		"OPPORTUNITIES": opportunities_ok,
		"NPC_RELATIONSHIPS": npc_relationships_ok,
		"CROSS_CAPACITY": capacity_ok,
		"RESOURCES": resources_ok,
		"FOUNDER_MEMORIES": founder_ok,
		"EVENT_DEPENDENCY": dependency_ok,
		"EVENTS": events_ok
	}


func _semantic_snapshot(runtime: Dictionary) -> Dictionary:
	var foundation = runtime["foundation"]
	var profile: Dictionary = foundation.get_player_profile_overview()
	var population: Dictionary = foundation.get_population_overview()
	var calendar: Dictionary = foundation.calendar_state.export_save_data()
	var npc: Dictionary = foundation.get_npc_overview(RELATIONSHIP_NPC_ID)
	var relationship: Dictionary = npc.get("relationship", {}) as Dictionary

	var population_persistent: Dictionary = population.duplicate(true)
	for derived_key: String in [
		"representative_count",
		"common_population",
		"available_housing",
		"is_over_capacity"
	]:
		population_persistent.erase(derived_key)

	var calendar_persistent: Dictionary = calendar.duplicate(true)
	for derived_key: String in [
		"campaign_total_days",
		"season_id",
		"season_name",
		"day_in_season",
		"next_checkpoint_day"
	]:
		calendar_persistent.erase(derived_key)

	return {
		"PROFILE": {
			"name": profile.get("name", ""),
			"gender_id": profile.get("gender_id", ""),
			"difficulty_id": profile.get("difficulty_id", ""),
			"village_name": profile.get("village_name", ""),
			"golem_form": profile.get("golem_form", "")
		},
		"POPULATION": population_persistent,
		"CALENDAR": calendar_persistent,
		"NPC": {
			"npc_id": npc.get("npc_id", ""),
			"display_name": npc.get("display_name", ""),
			"known": npc.get("known", false)
		},
		"RELATIONSHIP": relationship.duplicate(true),
		"STORY": runtime["story"].export_save_data(),
		"CAMPAIGN": runtime["campaign"].export_save_data(),
		"BUILDINGS": runtime["buildings"].export_save_data(),
		"RESOURCES": (runtime["resources"] as Dictionary).duplicate(true)
	}


func _run_triple_roundtrip(
	snapshot_a: Dictionary,
	runtime_b: Dictionary,
	snapshot_b: Dictionary,
	previous_ok: bool
) -> bool:
	var transport_b: Dictionary = _json_transport(_build_game_state(runtime_b))
	var runtime_c: Dictionary = _create_runtime()
	var imports_c: Dictionary = _import_game_state(
		runtime_c,
		transport_b.get("game_state", {}) as Dictionary
	)
	var snapshot_c: Dictionary = _semantic_snapshot(runtime_c)
	var transport_c: Dictionary = _json_transport(_build_game_state(runtime_c))
	print("INTEGRATED_TRIPLE_A_SHA256=%s" % _snapshot_hash(snapshot_a))
	print("INTEGRATED_TRIPLE_B_SHA256=%s" % _snapshot_hash(snapshot_b))
	print("INTEGRATED_TRIPLE_C_SHA256=%s" % _snapshot_hash(snapshot_c))
	return (
		previous_ok
		and bool(transport_b.get("success", false))
		and bool(transport_c.get("success", false))
		and _all_true(imports_c)
		and snapshot_a == snapshot_b
		and snapshot_b == snapshot_c
	)


func _run_determinism(exported_state: Dictionary) -> bool:
	var runtime_a: Dictionary = _create_runtime()
	var runtime_b: Dictionary = _create_runtime()
	var imports_a: Dictionary = _import_game_state(runtime_a, exported_state)
	var imports_b: Dictionary = _import_game_state(runtime_b, exported_state)
	var snapshot_a: Dictionary = _semantic_snapshot(runtime_a)
	var snapshot_b: Dictionary = _semantic_snapshot(runtime_b)
	print("INTEGRATED_DETERMINISM_A_SHA256=%s" % _snapshot_hash(snapshot_a))
	print("INTEGRATED_DETERMINISM_B_SHA256=%s" % _snapshot_hash(snapshot_b))
	return (
		_all_true(imports_a)
		and _all_true(imports_b)
		and snapshot_a == snapshot_b
	)


func _compare_invariants(before: Dictionary, after: Dictionary) -> Dictionary:
	var results: Dictionary = {}
	for invariant_name: String in INVARIANT_NAMES:
		var before_value: Variant = before.get(invariant_name)
		var after_value: Variant = after.get(invariant_name)
		var matches: bool = before_value == after_value
		results[invariant_name] = matches
		if matches:
			print("INTEGRATED_%s_OK" % invariant_name)
		else:
			print(
				"INTEGRATED_%s_FAILED before=%s after=%s"
				% [
					invariant_name,
					JSON.stringify(before_value),
					JSON.stringify(after_value)
				]
			)
	return results


func _representative_states() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for index: int in range(4):
		result.append({
			"representative_id": "representante_%02d" % (index + 1),
			"name": "Representante %02d" % (index + 1),
			"is_council_active": true
		})
	return result


func _print_construction_results(results: Dictionary) -> void:
	for key: Variant in results.keys():
		print(
			"BUILD_STATE_%s_%s"
			% [String(key), "OK" if bool(results[key]) else "FAILED"]
		)


func _print_import_results(results: Dictionary) -> void:
	for key: Variant in results.keys():
		print(
			"IMPORT_%s_%s"
			% [String(key), "OK" if bool(results[key]) else "FAILED"]
		)


func _print_transport_result(label: String, result: Dictionary) -> void:
	print(
		"INTEGRATED_SAVE_SCHEMA_%s_%s"
		% [label, "OK" if bool(result.get("success", false)) else "FAILED"]
	)
	print(
		"INTEGRATED_SERIALIZED_%s_SHA256=%s"
		% [label, String(result.get("serialized_sha256", ""))]
	)
	if not bool(result.get("success", false)):
		print(
			"INTEGRATED_SAVE_SCHEMA_%s_ERRORS before=%s after=%s"
			% [
				label,
				String(result.get("schema_before_error", "")),
				String(result.get("schema_after_error", ""))
			]
		)


func _print_snapshot(marker: String, snapshot: Dictionary) -> void:
	print(marker)
	print(JSON.stringify(snapshot))
	print("%s_SHA256=%s" % [marker, _snapshot_hash(snapshot)])


func _snapshot_hash(snapshot: Dictionary) -> String:
	return JSON.stringify(snapshot).sha256_text()


func _all_true(results: Dictionary) -> bool:
	for value: Variant in results.values():
		if not bool(value):
			return false
	return true
