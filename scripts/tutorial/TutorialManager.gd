class_name VillageTutorialManager
extends RefCounted


const TUTORIAL_VERSION: int = 7
const TUTORIAL_PATH: String = (
	"user://golems_mandate_tutorial.cfg"
)
const LEGACY_TUTORIAL_PATH: String = "user://square_village_tutorial.cfg"


var intro_seen: bool = false
var hints_seen: Dictionary = {}


func _init() -> void:
	_load_progress()


func should_auto_show_intro() -> bool:
	return not intro_seen


func mark_intro_seen() -> void:
	if intro_seen:
		return

	intro_seen = true
	_save_progress()


func has_seen_hint(hint_id: String) -> bool:
	return bool(
		hints_seen.get(
			hint_id,
			false
		)
	)


func mark_hint_seen(hint_id: String) -> void:
	if hint_id.is_empty():
		return

	if has_seen_hint(hint_id):
		return

	hints_seen[hint_id] = true
	_save_progress()


func reset_progress() -> void:
	intro_seen = false
	hints_seen.clear()
	_save_progress()


func get_progress() -> Dictionary:
	return {
		"tutorial_version": TUTORIAL_VERSION,
		"intro_seen": intro_seen,
		"hints_seen": hints_seen.duplicate(true)
	}


func _load_progress() -> void:
	var config: ConfigFile = ConfigFile.new()
	var load_path: String = (
		TUTORIAL_PATH
		if FileAccess.file_exists(TUTORIAL_PATH)
		else LEGACY_TUTORIAL_PATH
	)
	var load_error: Error = config.load(load_path)

	if load_error != OK:
		return

	var stored_version: int = int(
		config.get_value(
			"tutorial",
			"version",
			0
		)
	)

	if stored_version != TUTORIAL_VERSION:
		return

	intro_seen = bool(
		config.get_value(
			"tutorial",
			"intro_seen",
			false
		)
	)

	var stored_hints: Variant = config.get_value(
		"tutorial",
		"hints_seen",
		PackedStringArray()
	)

	if stored_hints is PackedStringArray:
		for hint_id: String in (
			stored_hints as PackedStringArray
		):
			if not hint_id.is_empty():
				hints_seen[hint_id] = true

	elif stored_hints is Array:
		for hint_value: Variant in (
			stored_hints as Array
		):
			var hint_id: String = String(hint_value)

			if not hint_id.is_empty():
				hints_seen[hint_id] = true

	if load_path == LEGACY_TUTORIAL_PATH:
		_save_progress()


func _save_progress() -> void:
	var config: ConfigFile = ConfigFile.new()
	var stored_hints: PackedStringArray = PackedStringArray()

	for hint_value: Variant in hints_seen.keys():
		var hint_id: String = String(hint_value)

		if not hint_id.is_empty():
			stored_hints.append(hint_id)

	stored_hints.sort()

	config.set_value(
		"tutorial",
		"version",
		TUTORIAL_VERSION
	)

	config.set_value(
		"tutorial",
		"intro_seen",
		intro_seen
	)

	config.set_value(
		"tutorial",
		"hints_seen",
		stored_hints
	)

	var save_error: Error = config.save(
		TUTORIAL_PATH
	)

	if save_error != OK:
		push_warning(
			"Não foi possível salvar o progresso "
			+ "do tutorial."
		)
