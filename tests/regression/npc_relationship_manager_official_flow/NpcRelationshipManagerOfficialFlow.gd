extends Node


const RelationshipManagerScript = preload(
	"res://scripts/relationships/NpcRelationshipManager.gd"
)
const RelationshipCatalogScript = preload(
	"res://scripts/relationships/NpcRelationshipCatalog.gd"
)

const NPC_A: String = "passos_leves_faz_tudo"
const NPC_B: String = "aelric_ferreiro"
const DIALOGUE_DAY: int = 15


func _ready() -> void:
	var reduction: Dictionary = _run_official_case("support_a", 5, -15)
	var increase: Dictionary = _run_official_case("neutral", 5, 7)
	var lower_clamp: Dictionary = _run_official_case("support_a", -95, -100)
	var upper_clamp: Dictionary = _run_official_case("reconcile", 95, 100)
	var passed: bool = (
		bool(reduction.get("passed", false))
		and bool(increase.get("passed", false))
		and bool(lower_clamp.get("passed", false))
		and bool(upper_clamp.get("passed", false))
	)
	if passed:
		print("NPC_RELATIONSHIP_OFFICIAL_FLOW_OK")
	else:
		print(
			"NPC_RELATIONSHIP_OFFICIAL_FLOW_FAILED reduction=%s increase=%s lower=%s upper=%s"
			% [reduction, increase, lower_clamp, upper_clamp]
		)


func _run_official_case(
	choice_id: String,
	starting_score: int,
	expected_score: int
) -> Dictionary:
	var manager = RelationshipManagerScript.new()
	manager.setup()
	var pair_key: String = RelationshipCatalogScript.get_pair_key(NPC_A, NPC_B)
	var imported: bool = _set_score_through_save_api(
		manager,
		pair_key,
		starting_score
	)
	var conversation: Dictionary = manager.prepare_for_completed_day(
		DIALOGUE_DAY,
		_build_requirement_context()
	)
	var choice: Dictionary = _find_choice(conversation, choice_id)
	var choice_enabled: bool = not bool(choice.get("disabled", false))
	var result: Dictionary = {}
	if imported and not choice.is_empty() and choice_enabled:
		result = manager.resolve_choice(choice)
	var exported: Dictionary = manager.export_save_data()
	var scores: Dictionary = exported.get("pair_scores", {}) as Dictionary
	var resolved: Dictionary = exported.get("resolved_dialogues", {}) as Dictionary
	var memories: Dictionary = exported.get("memories", {}) as Dictionary
	var pair_memories: Array = memories.get(pair_key, []) as Array
	var actual_score: int = int(scores.get(pair_key, 9999))
	var duplicate_rejected: bool = not bool(
		manager.resolve_choice(choice).get("success", false)
	)
	return {
		"passed": (
			imported
			and not conversation.is_empty()
			and not choice.is_empty()
			and choice_enabled
			and bool(result.get("success", false))
			and actual_score == expected_score
			and resolved.size() == 1
			and pair_memories.size() == 1
			and not String(pair_memories[0]).is_empty()
			and not manager.has_pending_dialogue()
			and duplicate_rejected
		),
		"choice": choice_id,
		"starting_score": starting_score,
		"expected_score": expected_score,
		"actual_score": actual_score,
		"resolved_count": resolved.size(),
		"memory_count": pair_memories.size(),
		"success": bool(result.get("success", false))
	}


func _set_score_through_save_api(
	manager,
	pair_key: String,
	score: int
) -> bool:
	var state: Dictionary = manager.export_save_data()
	var scores: Dictionary = state.get("pair_scores", {}) as Dictionary
	scores[pair_key] = score
	state["pair_scores"] = scores
	return manager.import_save_data(state)


func _find_choice(conversation: Dictionary, choice_id: String) -> Dictionary:
	var nodes: Dictionary = conversation.get("nodes", {}) as Dictionary
	var opening: Dictionary = nodes.get("opening", {}) as Dictionary
	for value: Variant in opening.get("choices", []) as Array:
		if (
			value is Dictionary
			and String((value as Dictionary).get("npc_relationship_choice", ""))
			== choice_id
		):
			return (value as Dictionary).duplicate(true)
	return {}


func _build_requirement_context() -> Dictionary:
	return {
		"known_npcs": {NPC_A: true, NPC_B: true},
		"relationship_points": {NPC_A: 999, NPC_B: 999},
		"food": 999.0,
		"material": 999.0,
		"council_size": 4
	}
