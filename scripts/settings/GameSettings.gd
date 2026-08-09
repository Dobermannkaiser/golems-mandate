extends Node


signal settings_changed(settings_data: Dictionary)


const SETTINGS_PATH: String = "user://golems_mandate_settings.cfg"
const LEGACY_SETTINGS_PATH: String = "user://square_village_settings.cfg"
const SETTINGS_SCHEMA_VERSION: int = 2
const DEFAULT_MASTER_VOLUME_PERCENT: int = 80
const DEFAULT_MUSIC_VOLUME_PERCENT: int = 60
const DEFAULT_AMBIENCE_VOLUME_PERCENT: int = 45
const DEFAULT_EFFECTS_VOLUME_PERCENT: int = 70
const DEFAULT_INTERFACE_VOLUME_PERCENT: int = 55
const DEFAULT_INSTANT_DIALOGUE_TEXT: bool = false
const DEFAULT_ENHANCED_CONTRAST: bool = false


var volume_percent: int = DEFAULT_MASTER_VOLUME_PERCENT
var master_volume_percent: int = DEFAULT_MASTER_VOLUME_PERCENT
var music_volume_percent: int = DEFAULT_MUSIC_VOLUME_PERCENT
var ambience_volume_percent: int = DEFAULT_AMBIENCE_VOLUME_PERCENT
var effects_volume_percent: int = DEFAULT_EFFECTS_VOLUME_PERCENT
var interface_volume_percent: int = DEFAULT_INTERFACE_VOLUME_PERCENT
var master_muted: bool = false
var fullscreen_enabled: bool = false
var reduced_motion: bool = false
var instant_dialogue_text: bool = DEFAULT_INSTANT_DIALOGUE_TEXT
var enhanced_contrast: bool = DEFAULT_ENHANCED_CONTRAST


func _ready() -> void:
	_load_settings()
	apply_settings()


func get_settings() -> Dictionary:
	return {
		"volume_percent": master_volume_percent,
		"master_volume_percent": master_volume_percent,
		"music_volume_percent": music_volume_percent,
		"ambience_volume_percent": ambience_volume_percent,
		"effects_volume_percent": effects_volume_percent,
		"interface_volume_percent": interface_volume_percent,
		"master_muted": master_muted,
		"fullscreen_enabled": fullscreen_enabled,
		"reduced_motion": reduced_motion,
		"instant_dialogue_text": instant_dialogue_text,
		"enhanced_contrast": enhanced_contrast
	}


func update_settings(settings_data: Dictionary) -> void:
	master_volume_percent = _read_percent(
		settings_data,
		"master_volume_percent",
		int(settings_data.get("volume_percent", master_volume_percent))
	)
	volume_percent = master_volume_percent
	music_volume_percent = _read_percent(
		settings_data,
		"music_volume_percent",
		music_volume_percent
	)
	ambience_volume_percent = _read_percent(
		settings_data,
		"ambience_volume_percent",
		ambience_volume_percent
	)
	effects_volume_percent = _read_percent(
		settings_data,
		"effects_volume_percent",
		effects_volume_percent
	)
	interface_volume_percent = _read_percent(
		settings_data,
		"interface_volume_percent",
		interface_volume_percent
	)
	master_muted = bool(settings_data.get("master_muted", master_muted))
	fullscreen_enabled = bool(
		settings_data.get("fullscreen_enabled", fullscreen_enabled)
	)
	reduced_motion = bool(
		settings_data.get("reduced_motion", reduced_motion)
	)
	instant_dialogue_text = bool(
		settings_data.get(
			"instant_dialogue_text",
			instant_dialogue_text
		)
	)
	enhanced_contrast = bool(
		settings_data.get(
			"enhanced_contrast",
			enhanced_contrast
		)
	)
	apply_settings()
	_save_settings()
	settings_changed.emit(get_settings())


func restore_audio_defaults() -> void:
	master_volume_percent = DEFAULT_MASTER_VOLUME_PERCENT
	volume_percent = master_volume_percent
	music_volume_percent = DEFAULT_MUSIC_VOLUME_PERCENT
	ambience_volume_percent = DEFAULT_AMBIENCE_VOLUME_PERCENT
	effects_volume_percent = DEFAULT_EFFECTS_VOLUME_PERCENT
	interface_volume_percent = DEFAULT_INTERFACE_VOLUME_PERCENT
	master_muted = false
	apply_settings()
	_save_settings()
	settings_changed.emit(get_settings())


func restore_accessibility_defaults() -> void:
	reduced_motion = false
	instant_dialogue_text = DEFAULT_INSTANT_DIALOGUE_TEXT
	enhanced_contrast = DEFAULT_ENHANCED_CONTRAST
	apply_settings()
	_save_settings()
	settings_changed.emit(get_settings())


func apply_settings() -> void:
	_apply_audio_buses()
	_apply_window_mode()


func _load_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	var load_path: String = (
		SETTINGS_PATH
		if FileAccess.file_exists(SETTINGS_PATH)
		else LEGACY_SETTINGS_PATH
	)
	var load_error: Error = config.load(load_path)
	if load_error != OK:
		return
	var legacy_volume: int = clampi(
		int(
			config.get_value(
				"audio",
				"volume_percent",
				DEFAULT_MASTER_VOLUME_PERCENT
			)
		),
		0,
		100
	)
	master_volume_percent = _config_percent(
		config,
		"master_volume_percent",
		legacy_volume
	)
	volume_percent = master_volume_percent
	music_volume_percent = _config_percent(
		config,
		"music_volume_percent",
		DEFAULT_MUSIC_VOLUME_PERCENT
	)
	ambience_volume_percent = _config_percent(
		config,
		"ambience_volume_percent",
		DEFAULT_AMBIENCE_VOLUME_PERCENT
	)
	effects_volume_percent = _config_percent(
		config,
		"effects_volume_percent",
		DEFAULT_EFFECTS_VOLUME_PERCENT
	)
	interface_volume_percent = _config_percent(
		config,
		"interface_volume_percent",
		DEFAULT_INTERFACE_VOLUME_PERCENT
	)
	master_muted = bool(
		config.get_value("audio", "master_muted", false)
	)
	fullscreen_enabled = bool(
		config.get_value("display", "fullscreen_enabled", false)
	)
	reduced_motion = bool(
		config.get_value("accessibility", "reduced_motion", false)
	)
	instant_dialogue_text = bool(
		config.get_value(
			"accessibility",
			"instant_dialogue_text",
			DEFAULT_INSTANT_DIALOGUE_TEXT
		)
	)
	enhanced_contrast = bool(
		config.get_value(
			"accessibility",
			"enhanced_contrast",
			DEFAULT_ENHANCED_CONTRAST
		)
	)
	if load_path == LEGACY_SETTINGS_PATH:
		# Mantém as preferências do nome provisório e passa a gravar no caminho
		# oficial sem apagar o arquivo antigo.
		_save_settings()


func _save_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value(
		"metadata",
		"schema_version",
		SETTINGS_SCHEMA_VERSION
	)
	config.set_value("audio", "volume_percent", master_volume_percent)
	config.set_value("audio", "master_volume_percent", master_volume_percent)
	config.set_value("audio", "music_volume_percent", music_volume_percent)
	config.set_value("audio", "ambience_volume_percent", ambience_volume_percent)
	config.set_value("audio", "effects_volume_percent", effects_volume_percent)
	config.set_value("audio", "interface_volume_percent", interface_volume_percent)
	config.set_value("audio", "master_muted", master_muted)
	config.set_value("display", "fullscreen_enabled", fullscreen_enabled)
	config.set_value("accessibility", "reduced_motion", reduced_motion)
	config.set_value(
		"accessibility",
		"instant_dialogue_text",
		instant_dialogue_text
	)
	config.set_value(
		"accessibility",
		"enhanced_contrast",
		enhanced_contrast
	)
	config.save(SETTINGS_PATH)


func _apply_audio_buses() -> void:
	_apply_bus_volume(
		"Master",
		master_volume_percent,
		master_muted
	)
	_apply_bus_volume("Music", music_volume_percent, false)
	_apply_bus_volume("Ambience", ambience_volume_percent, false)
	_apply_bus_volume("SFX", effects_volume_percent, false)
	_apply_bus_volume("UI", interface_volume_percent, false)


func _apply_bus_volume(
	bus_name: String,
	percent: int,
	forced_mute: bool
) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return
	var linear_volume: float = float(clampi(percent, 0, 100)) / 100.0
	var should_mute: bool = forced_mute or linear_volume <= 0.0
	AudioServer.set_bus_mute(bus_index, should_mute)
	if not should_mute:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_volume))


func _apply_window_mode() -> void:
	var desired_mode: DisplayServer.WindowMode = (
		DisplayServer.WINDOW_MODE_FULLSCREEN
		if fullscreen_enabled
		else DisplayServer.WINDOW_MODE_WINDOWED
	)
	if DisplayServer.window_get_mode() == desired_mode:
		return
	DisplayServer.window_set_mode(desired_mode)


func _read_percent(
	settings_data: Dictionary,
	key: String,
	fallback: int
) -> int:
	return clampi(int(settings_data.get(key, fallback)), 0, 100)


func _config_percent(
	config: ConfigFile,
	key: String,
	fallback: int
) -> int:
	return clampi(
		int(config.get_value("audio", key, fallback)),
		0,
		100
	)
