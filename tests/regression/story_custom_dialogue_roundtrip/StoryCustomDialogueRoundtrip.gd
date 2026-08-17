extends Node


const StoryManagerScript = preload("res://scripts/story/StoryManager.gd")


func _ready() -> void:
	var custom_ok: bool = _run_round_trip(
		"custom_season_notice",
		"seasonal_custom_notice",
		{"source": "regression", "nested": {"preserved": true}}
	)
	var production_context_ok: bool = _run_round_trip(
		"variant_reaction_regression",
		"building_variant_reaction",
		{"variant_id": "silo_reserve", "building_id": "barn"}
	)
	var boundary_ok: bool = _run_round_trip("x", "y", {})
	var invalid_ok: bool = _run_invalid_cases()
	var double_ok: bool = _run_double_round_trip()
	var passed: bool = (
		custom_ok
		and production_context_ok
		and boundary_ok
		and invalid_ok
		and double_ok
	)
	if passed:
		print("STORY_ROUNDTRIP_OK")
	else:
		print(
			"STORY_ROUNDTRIP_FAILED custom=%s production=%s boundary=%s invalid=%s double=%s"
			% [custom_ok, production_context_ok, boundary_ok, invalid_ok, double_ok]
		)


func _run_round_trip(
	dialogue_id: String,
	context: String,
	metadata: Dictionary
) -> bool:
	var source = StoryManagerScript.new()
	source.setup(false)
	var accepted: bool = source.queue_custom_dialogue(
		dialogue_id,
		context,
		metadata
	)
	var exported: Dictionary = source.export_save_data()
	var restored = StoryManagerScript.new()
	restored.setup(false)
	var import_ok: bool = restored.import_save_data(exported)
	var request: Dictionary = restored.get_pending_dialogue_request()
	return (
		accepted
		and import_ok
		and String(request.get("dialogue_id", "")) == dialogue_id.strip_edges()
		and String(request.get("context", "")) == context.strip_edges()
		and request.get("metadata", {}) == metadata
		and restored.export_save_data() == exported
	)


func _run_invalid_cases() -> bool:
	var source = StoryManagerScript.new()
	source.setup(false)
	var empty_context_rejected: bool = not source.queue_custom_dialogue(
		"invalid_context",
		"   "
	)
	var baseline: Dictionary = source.export_save_data()
	var malformed_id_only: Dictionary = baseline.duplicate(true)
	malformed_id_only["pending_dialogue_id"] = "orphan_dialogue"
	malformed_id_only["pending_dialogue_context"] = ""
	var malformed_context_only: Dictionary = baseline.duplicate(true)
	malformed_context_only["pending_dialogue_id"] = ""
	malformed_context_only["pending_dialogue_context"] = "orphan_context"
	var restored_id_only = StoryManagerScript.new()
	restored_id_only.setup(false)
	var restored_context_only = StoryManagerScript.new()
	restored_context_only.setup(false)
	return (
		empty_context_rejected
		and not restored_id_only.import_save_data(malformed_id_only)
		and not restored_context_only.import_save_data(malformed_context_only)
	)


func _run_double_round_trip() -> bool:
	var source = StoryManagerScript.new()
	source.setup(false)
	var first_ok: bool = source.queue_custom_dialogue(
		"first_custom_dialogue",
		"seasonal_notice",
		{"step": 1}
	)
	var second_ok: bool = source.queue_custom_dialogue(
		"second_custom_dialogue",
		"festival_follow_up",
		{"step": 2}
	)
	var export_a: Dictionary = source.export_save_data()
	var restored_a = StoryManagerScript.new()
	restored_a.setup(false)
	var import_a: bool = restored_a.import_save_data(export_a)
	var export_b: Dictionary = restored_a.export_save_data()
	var restored_b = StoryManagerScript.new()
	restored_b.setup(false)
	var import_b: bool = restored_b.import_save_data(export_b)
	var export_c: Dictionary = restored_b.export_save_data()
	return first_ok and second_ok and import_a and import_b and export_a == export_b and export_b == export_c
