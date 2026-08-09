class_name VillageStoryManager
extends RefCounted


const STORY_STATE_VERSION: int = 2
const CHAPTER_CATALOG_SCRIPT = preload(
	"res://scripts/story/StoryChapterCatalog.gd"
)

var prologue_completed: bool = false
var completed_chapter_ids: Array[String] = []
var seen_dialogue_ids: Array[String] = []
var story_flags: Dictionary = {}
var recruited_npc_ids: Array[String] = []
var chapter_choices: Dictionary = {}

var pending_dialogue_id: String = ""
var pending_dialogue_context: String = ""
var pending_chapter_id: String = ""
var pending_event_id: String = ""
var pending_outro_variant: String = ""
var awaiting_story_event: bool = false
var custom_dialogue_queue: Array[Dictionary] = []
var pending_custom_metadata: Dictionary = {}


func setup(start_with_prologue: bool = false) -> void:
	prologue_completed = false
	completed_chapter_ids.clear()
	seen_dialogue_ids.clear()
	story_flags.clear()
	recruited_npc_ids.clear()
	chapter_choices.clear()
	custom_dialogue_queue.clear()
	pending_custom_metadata.clear()
	clear_pending()

	if start_with_prologue:
		queue_prologue()


func queue_prologue() -> void:
	if prologue_completed:
		return
	pending_dialogue_id = "prologue_reincarnation"
	pending_dialogue_context = "prologue"
	pending_chapter_id = "prologo"
	pending_event_id = ""
	awaiting_story_event = false


func should_trigger_chapter(completed_day: int) -> bool:
	if not CHAPTER_CATALOG_SCRIPT.is_chapter_day(completed_day):
		return false
	var chapter: Dictionary = CHAPTER_CATALOG_SCRIPT.get_chapter_for_day(
		completed_day
	)
	if chapter.is_empty():
		return false
	return not completed_chapter_ids.has(String(chapter.get("id", "")))


func begin_chapter(completed_day: int) -> Dictionary:
	var chapter: Dictionary = CHAPTER_CATALOG_SCRIPT.get_chapter_for_day(
		completed_day
	)
	if chapter.is_empty():
		return {}

	pending_chapter_id = String(chapter.get("id", ""))
	pending_event_id = String(chapter.get("event_id", ""))
	pending_dialogue_id = String(chapter.get("intro_dialogue_id", ""))
	pending_dialogue_context = "chapter_intro"
	pending_outro_variant = ""
	awaiting_story_event = false
	pending_custom_metadata.clear()
	return chapter


func debug_begin_sequence(chapter_day: int) -> Dictionary:
	clear_pending()
	if chapter_day <= 0:
		pending_dialogue_id = "prologue_reincarnation"
		pending_dialogue_context = "debug_prologue"
		pending_chapter_id = "prologo_teste"
		return get_pending_dialogue_request()

	var chapter: Dictionary = CHAPTER_CATALOG_SCRIPT.get_chapter_for_day(
		chapter_day
	)
	if chapter.is_empty():
		return {}

	pending_chapter_id = String(chapter.get("id", ""))
	pending_event_id = String(chapter.get("event_id", ""))
	pending_dialogue_id = String(chapter.get("intro_dialogue_id", ""))
	pending_dialogue_context = "debug_chapter_intro"
	return get_pending_dialogue_request()


func has_pending_dialogue() -> bool:
	return not pending_dialogue_id.is_empty()


func get_pending_dialogue_request() -> Dictionary:
	if not has_pending_dialogue():
		return {}
	return {
		"dialogue_id": pending_dialogue_id,
		"context": pending_dialogue_context,
		"chapter_id": pending_chapter_id,
		"event_id": pending_event_id,
		"outro_variant": pending_outro_variant,
		"metadata": pending_custom_metadata.duplicate(true)
	}


func queue_custom_dialogue(
	dialogue_id: String,
	context: String,
	metadata: Dictionary = {}
) -> bool:
	var clean_id: String = dialogue_id.strip_edges()
	var clean_context: String = context.strip_edges()
	if clean_id.is_empty() or clean_context.is_empty():
		return false
	for queued: Dictionary in custom_dialogue_queue:
		if String(queued.get("dialogue_id", "")) == clean_id:
			return false
	if pending_dialogue_id == clean_id:
		return false
	custom_dialogue_queue.append(
		{
			"dialogue_id": clean_id,
			"context": clean_context,
			"metadata": metadata.duplicate(true)
		}
	)
	_promote_next_custom_dialogue()
	return true


func _promote_next_custom_dialogue() -> void:
	if has_pending_dialogue() or custom_dialogue_queue.is_empty():
		return
	var queued: Dictionary = custom_dialogue_queue.pop_front()
	pending_dialogue_id = String(queued.get("dialogue_id", ""))
	pending_dialogue_context = String(queued.get("context", ""))
	pending_custom_metadata = (
		queued.get("metadata", {}) as Dictionary
	).duplicate(true)



func finish_dialogue(dialogue_id: String) -> Dictionary:
	if dialogue_id != pending_dialogue_id:
		return {"handled": false}

	if not seen_dialogue_ids.has(dialogue_id):
		seen_dialogue_ids.append(dialogue_id)

	var context: String = pending_dialogue_context
	var finished_metadata: Dictionary = pending_custom_metadata.duplicate(true)
	pending_dialogue_id = ""
	pending_dialogue_context = ""
	pending_custom_metadata.clear()

	match context:
		"prologue":
			prologue_completed = true
			pending_chapter_id = ""
			return {
				"handled": true,
				"prologue_completed": true
			}

		"debug_prologue":
			clear_pending()
			_promote_next_custom_dialogue()
			return {
				"handled": true,
				"debug_sequence_completed": true
			}

		"chapter_intro", "debug_chapter_intro":
			awaiting_story_event = true
			return {
				"handled": true,
				"start_event_id": pending_event_id,
				"chapter_id": pending_chapter_id,
				"debug_sequence": context == "debug_chapter_intro"
			}

		"chapter_outro":
			var completed_id: String = pending_chapter_id
			if (
				not completed_id.is_empty()
				and not completed_chapter_ids.has(completed_id)
			):
				completed_chapter_ids.append(completed_id)
			clear_pending()
			_promote_next_custom_dialogue()
			return {
				"handled": true,
				"chapter_completed": true,
				"chapter_id": completed_id
			}

		"debug_chapter_outro":
			clear_pending()
			_promote_next_custom_dialogue()
			return {
				"handled": true,
				"debug_sequence_completed": true
			}

		"building_variant_reaction":
			_promote_next_custom_dialogue()
			return {
				"handled": true,
				"building_variant_reaction_completed": true,
				"metadata": finished_metadata
			}

	_promote_next_custom_dialogue()
	return {"handled": true}


func record_story_event_resolution(
	event_data: Dictionary,
	choice_data: Dictionary,
	debug_sequence: bool = false
) -> Dictionary:
	var event_id: String = String(event_data.get("id", ""))
	var chapter_id: String = String(
		event_data.get("chapter_id", pending_chapter_id)
	)
	var choice_id: String = String(choice_data.get("id", ""))
	var story_flag: String = String(choice_data.get("story_flag", ""))
	var recruit_npc_id: String = String(
		event_data.get("recruit_npc_id", "")
	)
	var outro_variant: String = String(
		choice_data.get("outro_variant", "default")
	)

	var new_recruit: bool = false

	if not debug_sequence:
		if not story_flag.is_empty():
			story_flags[story_flag] = true

		if not chapter_id.is_empty():
			chapter_choices[chapter_id] = choice_id

		if (
			not recruit_npc_id.is_empty()
			and not recruited_npc_ids.has(recruit_npc_id)
		):
			recruited_npc_ids.append(recruit_npc_id)
			story_flags["recruited_%s" % recruit_npc_id] = true
			new_recruit = true

	pending_chapter_id = chapter_id
	pending_event_id = event_id
	pending_outro_variant = outro_variant
	pending_dialogue_id = _get_outro_dialogue_id(event_data)
	pending_dialogue_context = (
		"debug_chapter_outro" if debug_sequence else "chapter_outro"
	)
	awaiting_story_event = false

	return {
		"dialogue_id": pending_dialogue_id,
		"chapter_id": chapter_id,
		"choice_id": choice_id,
		"story_flag": story_flag,
		"recruit_npc_id": recruit_npc_id,
		"new_recruit": new_recruit,
		"relationship_delta": int(
			choice_data.get("relationship_delta", 0)
		),
		"population_delta": int(
			choice_data.get("population_delta", 0)
		),
		"outro_variant": outro_variant,
		"debug_sequence": debug_sequence
	}


func is_npc_recruited(npc_id: String) -> bool:
	return recruited_npc_ids.has(npc_id)


func has_flag(flag_id: String) -> bool:
	return bool(story_flags.get(flag_id, false))


func get_known_story_npc_count() -> int:
	return recruited_npc_ids.size()


func get_overview() -> Dictionary:
	return {
		"prologue_completed": prologue_completed,
		"completed_chapter_ids": completed_chapter_ids.duplicate(),
		"completed_chapter_count": completed_chapter_ids.size(),
		"recruited_npc_ids": recruited_npc_ids.duplicate(),
		"recruited_npc_count": recruited_npc_ids.size(),
		"story_flags": story_flags.duplicate(true),
		"chapter_choices": chapter_choices.duplicate(true),
		"pending_dialogue_id": pending_dialogue_id,
		"pending_dialogue_context": pending_dialogue_context,
		"pending_chapter_id": pending_chapter_id,
		"pending_event_id": pending_event_id,
		"awaiting_story_event": awaiting_story_event,
		"custom_dialogue_queue": custom_dialogue_queue.duplicate(true),
		"pending_custom_metadata": pending_custom_metadata.duplicate(true)
	}


func clear_pending() -> void:
	pending_dialogue_id = ""
	pending_dialogue_context = ""
	pending_chapter_id = ""
	pending_event_id = ""
	pending_outro_variant = ""
	awaiting_story_event = false


func export_save_data() -> Dictionary:
	return {
		"story_state_version": STORY_STATE_VERSION,
		"prologue_completed": prologue_completed,
		"completed_chapter_ids": completed_chapter_ids.duplicate(),
		"seen_dialogue_ids": seen_dialogue_ids.duplicate(),
		"story_flags": story_flags.duplicate(true),
		"recruited_npc_ids": recruited_npc_ids.duplicate(),
		"chapter_choices": chapter_choices.duplicate(true),
		"pending_dialogue_id": pending_dialogue_id,
		"pending_dialogue_context": pending_dialogue_context,
		"pending_chapter_id": pending_chapter_id,
		"pending_event_id": pending_event_id,
		"pending_outro_variant": pending_outro_variant,
		"awaiting_story_event": awaiting_story_event,
		"custom_dialogue_queue": custom_dialogue_queue.duplicate(true),
		"pending_custom_metadata": pending_custom_metadata.duplicate(true)
	}


func import_save_data(save_data: Dictionary) -> bool:
	if int(save_data.get("story_state_version", 0)) != STORY_STATE_VERSION:
		return false

	var completed_value: Variant = save_data.get("completed_chapter_ids", null)
	var seen_value: Variant = save_data.get("seen_dialogue_ids", null)
	var flags_value: Variant = save_data.get("story_flags", null)
	var recruited_value: Variant = save_data.get("recruited_npc_ids", null)
	var choices_value: Variant = save_data.get("chapter_choices", null)
	var custom_queue_value: Variant = save_data.get(
		"custom_dialogue_queue",
		[]
	)
	var custom_metadata_value: Variant = save_data.get(
		"pending_custom_metadata",
		{}
	)

	if (
		not completed_value is Array
		or not seen_value is Array
		or not flags_value is Dictionary
		or not recruited_value is Array
		or not choices_value is Dictionary
		or not custom_queue_value is Array
		or not custom_metadata_value is Dictionary
	):
		return false

	prologue_completed = bool(save_data.get("prologue_completed", false))
	completed_chapter_ids = _read_unique_strings(completed_value as Array)
	seen_dialogue_ids = _read_unique_strings(seen_value as Array)
	recruited_npc_ids = _read_unique_strings(recruited_value as Array)
	story_flags = (flags_value as Dictionary).duplicate(true)
	chapter_choices = (choices_value as Dictionary).duplicate(true)
	custom_dialogue_queue.clear()
	for queued_value: Variant in custom_queue_value as Array:
		if not queued_value is Dictionary:
			return false
		var queued: Dictionary = (queued_value as Dictionary).duplicate(true)
		if (
			String(queued.get("dialogue_id", "")).strip_edges().is_empty()
			or String(queued.get("context", "")).strip_edges().is_empty()
			or not queued.get("metadata", {}) is Dictionary
		):
			return false
		custom_dialogue_queue.append(queued)
	pending_custom_metadata = (
		custom_metadata_value as Dictionary
	).duplicate(true)
	pending_dialogue_id = String(save_data.get("pending_dialogue_id", ""))
	pending_dialogue_context = String(
		save_data.get("pending_dialogue_context", "")
	)
	pending_chapter_id = String(save_data.get("pending_chapter_id", ""))
	pending_event_id = String(save_data.get("pending_event_id", ""))
	pending_outro_variant = String(
		save_data.get("pending_outro_variant", "")
	)
	awaiting_story_event = bool(
		save_data.get("awaiting_story_event", false)
	)

	if pending_dialogue_context not in [
		"",
		"prologue",
		"chapter_intro",
		"chapter_outro",
		"building_variant_reaction"
	]:
		return false
	if pending_dialogue_id.is_empty() != pending_dialogue_context.is_empty():
		return false
	return true


func _get_outro_dialogue_id(event_data: Dictionary) -> String:
	var chapter_day: int = int(event_data.get("chapter_day", 0))
	return "chapter_%d_outro_%s" % [chapter_day, pending_outro_variant]


func _read_unique_strings(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value: Variant in values:
		var text: String = String(value).strip_edges()
		if not text.is_empty() and not result.has(text):
			result.append(text)
	return result
