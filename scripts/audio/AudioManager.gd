extends Node


signal music_changed(track_group: String, resource_path: String)


const MUSIC_TRACKS: Dictionary = {
	"menu": [
		"res://assets/audio/music/music_menu.ogg"
	],
	"spring": [
		"res://assets/audio/music/music_spring_01.ogg",
		"res://assets/audio/music/music_spring_02.ogg"
	],
	"summer": [
		"res://assets/audio/music/music_summer.ogg"
	],
	"autumn": [
		"res://assets/audio/music/music_autumn.ogg"
	],
	"winter": [
		"res://assets/audio/music/music_winter_01.ogg",
		"res://assets/audio/music/music_winter_02.ogg"
	],
	"story": [
		"res://assets/audio/music/music_story_special.ogg"
	],
	"fun": [
		"res://assets/audio/music/music_fun.ogg"
	]
}

const AMBIENCE_TRACKS: Dictionary = {
	"spring": "res://assets/audio/ambience/ambience_spring.ogg",
	"summer": "res://assets/audio/ambience/ambience_summer.ogg",
	"autumn": "res://assets/audio/ambience/ambience_autumn.ogg",
	"winter": "res://assets/audio/ambience/ambience_winter.ogg"
}

const OCCASIONAL_AMBIENCE: Array[String] = [
	"res://assets/audio/ambience/occasional/village_hammer_soft.wav",
	"res://assets/audio/ambience/occasional/village_wood_creak.wav",
	"res://assets/audio/ambience/occasional/village_well.wav",
	"res://assets/audio/ambience/occasional/village_birds.wav"
]

const UI_EFFECTS: Dictionary = {
	"click": "res://assets/audio/sfx/ui/ui_click.wav",
	"hover": "res://assets/audio/sfx/ui/ui_hover.wav",
	"confirm": "res://assets/audio/sfx/ui/ui_confirm.wav",
	"cancel": "res://assets/audio/sfx/ui/ui_cancel.wav",
	"blocked": "res://assets/audio/sfx/ui/ui_blocked.wav",
	"window_open": "res://assets/audio/sfx/ui/ui_window_open.wav",
	"window_close": "res://assets/audio/sfx/ui/ui_window_close.wav"
}

const SFX_EFFECTS: Dictionary = {
	"build": "res://assets/audio/sfx/administration/game_build.wav",
	"upgrade": "res://assets/audio/sfx/administration/game_upgrade.wav",
	"end_day": "res://assets/audio/sfx/administration/game_end_day.wav",
	"save": "res://assets/audio/sfx/administration/game_save.wav",
	"load": "res://assets/audio/sfx/administration/game_load.wav",
	"profession": "res://assets/audio/sfx/administration/game_profession.wav",
	"council_change": "res://assets/audio/sfx/administration/game_council_change.wav",
	"event_positive": "res://assets/audio/sfx/events/event_positive.wav",
	"event_negative": "res://assets/audio/sfx/events/event_negative.wav",
	"event_magic": "res://assets/audio/sfx/events/event_magic.wav",
	"event_audit": "res://assets/audio/sfx/events/event_audit.wav",
	"event_victory": "res://assets/audio/sfx/events/event_victory.wav",
	"event_defeat": "res://assets/audio/sfx/events/event_defeat.wav",
	"relation_gain": "res://assets/audio/sfx/relationships/relation_gain.wav",
	"relation_loss": "res://assets/audio/sfx/relationships/relation_loss.wav",
	"relation_event": "res://assets/audio/sfx/relationships/relation_event_ready.wav",
	"relation_romance": "res://assets/audio/sfx/relationships/relation_romance.wav",
	"relation_date": "res://assets/audio/sfx/relationships/relation_date.wav",
	"dialogue_text": "res://assets/audio/sfx/dialogue/dialogue_text.wav",
	"dialogue_choice": "res://assets/audio/sfx/dialogue/dialogue_choice.wav",
	"story_chapter": "res://assets/audio/sfx/dialogue/story_chapter.wav",
	"story_recruit": "res://assets/audio/sfx/dialogue/story_recruit.wav",
	"story_divine": "res://assets/audio/sfx/dialogue/story_divine.wav",
	"resource_food": "res://assets/audio/sfx/resources/resource_food_gain.wav",
	"resource_material": "res://assets/audio/sfx/resources/resource_material_gain.wav",
	"resource_happiness": "res://assets/audio/sfx/resources/resource_happiness_gain.wav",
	"resource_warning": "res://assets/audio/sfx/resources/resource_warning.wav",
	"population_arrival": "res://assets/audio/sfx/resources/population_arrival.wav",
	"population_leave": "res://assets/audio/sfx/resources/population_leave.wav"
}

const MUSIC_CROSSFADE_SECONDS: float = 1.20
const AMBIENCE_CROSSFADE_SECONDS: float = 1.00
const SILENT_DB: float = -48.0
const DIALOGUE_MUSIC_DUCK_DB: float = -4.5
const DIALOGUE_AMBIENCE_DUCK_DB: float = -7.0
const MENU_AMBIENCE_DUCK_DB: float = -9.0
const HOVER_COOLDOWN_MSEC: int = 55
const OCCASIONAL_MIN_SECONDS: float = 16.0
const OCCASIONAL_MAX_SECONDS: float = 34.0


var music_player_a: AudioStreamPlayer
var music_player_b: AudioStreamPlayer
var current_music_player: AudioStreamPlayer
var ambience_player_a: AudioStreamPlayer
var ambience_player_b: AudioStreamPlayer
var current_ambience_player: AudioStreamPlayer
var occasional_player: AudioStreamPlayer
var test_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var ui_players: Array[AudioStreamPlayer] = []
var stream_cache: Dictionary = {}
var random: RandomNumberGenerator = RandomNumberGenerator.new()
var occasional_timer: Timer
var music_tween: Tween
var ambience_tween: Tween
var duck_tween: Tween
var current_music_group: String = ""
var current_music_path: String = ""
var current_ambience_path: String = ""
var current_season_id: String = "spring"
var in_game: bool = false
var game_menu_open: bool = false
var dialogue_active: bool = false
var story_music_active: bool = false
var temporary_event_music_active: bool = false
var ui_pool_index: int = 0
var sfx_pool_index: int = 0
var last_hover_msec: int = 0
var last_resource_values: Dictionary = {}
var last_population_count: int = -1
var focus_attenuated: bool = false


func _ready() -> void:
	random.randomize()
	_ensure_audio_buses()
	_create_audio_players()
	_create_occasional_timer()
	GameSettings.apply_settings()
	get_tree().node_added.connect(_on_tree_node_added)
	call_deferred("_bind_existing_buttons")
	call_deferred("_connect_game_signals")
	enter_menu(false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_set_master_focus_attenuation(true)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_set_master_focus_attenuation(false)


func enter_menu(from_game: bool) -> void:
	game_menu_open = from_game
	if from_game:
		in_game = true
		_set_ambience_duck(MENU_AMBIENCE_DUCK_DB)
		return
	in_game = false
	story_music_active = false
	dialogue_active = false
	_stop_ambience()
	_play_music_group("menu")


func enter_game(season_id: String) -> void:
	in_game = true
	game_menu_open = false
	var population: Dictionary = GameManager.get_population_overview()
	last_population_count = int(population.get("total_population", 0))
	current_season_id = _normalize_season_id(season_id)
	if not story_music_active:
		_play_music_group(current_season_id)
	_play_ambience(current_season_id)
	_apply_ducking()


func set_season(season_id: String) -> void:
	var normalized_id: String = _normalize_season_id(season_id)
	if normalized_id == current_season_id:
		return
	current_season_id = normalized_id
	if in_game and not story_music_active:
		_play_music_group(current_season_id)
	if in_game:
		_play_ambience(current_season_id)


func begin_dialogue(is_story_dialogue: bool = false) -> void:
	dialogue_active = true
	if is_story_dialogue:
		story_music_active = true
		_play_music_group("story")
	_apply_ducking()


func end_dialogue() -> void:
	dialogue_active = false
	if story_music_active:
		story_music_active = false
		if in_game:
			_play_music_group(current_season_id)
		else:
			_play_music_group("menu")
	_apply_ducking()


func play_fun_music() -> void:
	story_music_active = true
	_play_music_group("fun")


func restore_context_music() -> void:
	story_music_active = false
	if in_game:
		_play_music_group(current_season_id)
	else:
		_play_music_group("menu")


func play_ui(effect_id: String, pitch_variation: bool = true) -> void:
	var path: String = String(UI_EFFECTS.get(effect_id, ""))
	if path.is_empty():
		return
	var player: AudioStreamPlayer = _next_ui_player()
	_play_stream_on_player(player, path, pitch_variation, 0.0)


func play_sfx(effect_id: String, pitch_variation: bool = false) -> void:
	var path: String = String(SFX_EFFECTS.get(effect_id, ""))
	if path.is_empty():
		return
	var player: AudioStreamPlayer = _next_sfx_player()
	_play_stream_on_player(player, path, pitch_variation, 0.0)


func play_dialogue_text_tick() -> void:
	play_sfx("dialogue_text", true)


func test_channel(channel_id: String) -> void:
	var requested_bus: String = "UI"
	match channel_id:
		"master":
			requested_bus = "UI"
		"music":
			requested_bus = "Music"
		"ambience":
			requested_bus = "Ambience"
		"effects":
			requested_bus = "SFX"
		"interface":
			requested_bus = "UI"
		_:
			requested_bus = "UI"
	test_player.stop()
	test_player.bus = requested_bus
	test_player.stream = _get_stream(String(UI_EFFECTS.get("confirm", "")), false)
	test_player.pitch_scale = 1.0
	test_player.volume_db = 0.0
	test_player.play()


func _ensure_audio_buses() -> void:
	for bus_name: String in ["Music", "Ambience", "SFX", "UI"]:
		if AudioServer.get_bus_index(bus_name) >= 0:
			continue
		AudioServer.add_bus()
		var bus_index: int = AudioServer.bus_count - 1
		AudioServer.set_bus_name(bus_index, bus_name)
		AudioServer.set_bus_send(bus_index, "Master")


func _create_audio_players() -> void:
	music_player_a = _create_player("Music")
	music_player_b = _create_player("Music")
	ambience_player_a = _create_player("Ambience")
	ambience_player_b = _create_player("Ambience")
	occasional_player = _create_player("Ambience")
	test_player = _create_player("UI")
	for _index: int in range(8):
		sfx_players.append(_create_player("SFX"))
	for _index: int in range(6):
		ui_players.append(_create_player("UI"))


func _create_player(bus_name: String) -> AudioStreamPlayer:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.bus = bus_name
	add_child(player)
	return player


func _create_occasional_timer() -> void:
	occasional_timer = Timer.new()
	occasional_timer.one_shot = true
	occasional_timer.timeout.connect(_on_occasional_timer_timeout)
	add_child(occasional_timer)
	_schedule_next_occasional_sound()


func _play_music_group(group_id: String) -> void:
	var tracks_value: Variant = MUSIC_TRACKS.get(group_id, [])
	if not tracks_value is Array:
		return
	var tracks: Array = tracks_value as Array
	if tracks.is_empty():
		return
	if current_music_group == group_id and is_instance_valid(current_music_player) and current_music_player.playing:
		return
	var candidates: Array[String] = []
	for path_value: Variant in tracks:
		var path: String = String(path_value)
		if path != current_music_path or tracks.size() == 1:
			candidates.append(path)
	if candidates.is_empty():
		candidates.append(String(tracks[0]))
	var selected_path: String = candidates[random.randi_range(0, candidates.size() - 1)]
	var next_player: AudioStreamPlayer = (
		music_player_b
		if current_music_player == music_player_a
		else music_player_a
	)
	var stream: AudioStream = _get_stream(selected_path, true)
	if not is_instance_valid(stream):
		return
	if is_instance_valid(music_tween):
		music_tween.kill()
	next_player.stop()
	next_player.stream = stream
	next_player.pitch_scale = 1.0
	next_player.volume_db = SILENT_DB
	next_player.play()
	var old_player: AudioStreamPlayer = current_music_player
	current_music_player = next_player
	current_music_group = group_id
	current_music_path = selected_path
	music_tween = create_tween()
	music_tween.set_parallel(true)
	music_tween.set_trans(Tween.TRANS_SINE)
	music_tween.set_ease(Tween.EASE_IN_OUT)
	if is_instance_valid(old_player) and old_player.playing:
		music_tween.tween_property(old_player, "volume_db", SILENT_DB, MUSIC_CROSSFADE_SECONDS)
	music_tween.tween_property(next_player, "volume_db", _get_music_target_db(), MUSIC_CROSSFADE_SECONDS)
	music_tween.finished.connect(_finish_music_crossfade.bind(old_player))
	music_changed.emit(group_id, selected_path)


func _finish_music_crossfade(old_player: AudioStreamPlayer) -> void:
	if is_instance_valid(old_player) and old_player != current_music_player:
		old_player.stop()


func _play_ambience(season_id: String) -> void:
	var selected_path: String = String(AMBIENCE_TRACKS.get(season_id, ""))
	if selected_path.is_empty():
		return
	if selected_path == current_ambience_path and is_instance_valid(current_ambience_player) and current_ambience_player.playing:
		_apply_ducking()
		return
	var next_player: AudioStreamPlayer = (
		ambience_player_b
		if current_ambience_player == ambience_player_a
		else ambience_player_a
	)
	var stream: AudioStream = _get_stream(selected_path, true)
	if not is_instance_valid(stream):
		return
	if is_instance_valid(ambience_tween):
		ambience_tween.kill()
	next_player.stop()
	next_player.stream = stream
	next_player.pitch_scale = 1.0
	next_player.volume_db = SILENT_DB
	next_player.play()
	var old_player: AudioStreamPlayer = current_ambience_player
	current_ambience_player = next_player
	current_ambience_path = selected_path
	ambience_tween = create_tween()
	ambience_tween.set_parallel(true)
	ambience_tween.set_trans(Tween.TRANS_SINE)
	ambience_tween.set_ease(Tween.EASE_IN_OUT)
	if is_instance_valid(old_player) and old_player.playing:
		ambience_tween.tween_property(old_player, "volume_db", SILENT_DB, AMBIENCE_CROSSFADE_SECONDS)
	ambience_tween.tween_property(next_player, "volume_db", _get_ambience_target_db(), AMBIENCE_CROSSFADE_SECONDS)
	ambience_tween.finished.connect(_finish_ambience_crossfade.bind(old_player))


func _finish_ambience_crossfade(old_player: AudioStreamPlayer) -> void:
	if is_instance_valid(old_player) and old_player != current_ambience_player:
		old_player.stop()


func _stop_ambience() -> void:
	current_ambience_path = ""
	if is_instance_valid(ambience_tween):
		ambience_tween.kill()
	for player: AudioStreamPlayer in [ambience_player_a, ambience_player_b]:
		if is_instance_valid(player):
			player.stop()
	current_ambience_player = null


func _apply_ducking() -> void:
	if is_instance_valid(duck_tween):
		duck_tween.kill()
	duck_tween = create_tween()
	duck_tween.set_parallel(true)
	duck_tween.set_trans(Tween.TRANS_QUAD)
	duck_tween.set_ease(Tween.EASE_OUT)
	if is_instance_valid(current_music_player):
		duck_tween.tween_property(current_music_player, "volume_db", _get_music_target_db(), 0.24)
	if is_instance_valid(current_ambience_player):
		duck_tween.tween_property(current_ambience_player, "volume_db", _get_ambience_target_db(), 0.24)


func _set_ambience_duck(_target_db: float) -> void:
	_apply_ducking()


func _get_music_target_db() -> float:
	return DIALOGUE_MUSIC_DUCK_DB if dialogue_active else 0.0


func _get_ambience_target_db() -> float:
	if dialogue_active:
		return DIALOGUE_AMBIENCE_DUCK_DB
	if game_menu_open:
		return MENU_AMBIENCE_DUCK_DB
	return 0.0


func _get_stream(path: String, loop_enabled: bool) -> AudioStream:
	if path.is_empty():
		return null
	var cached_value: Variant = stream_cache.get(path)
	if cached_value is AudioStream:
		return cached_value as AudioStream
	var loaded_resource: Resource = load(path)
	var stream: AudioStream = loaded_resource as AudioStream
	if not is_instance_valid(stream):
		push_warning("Áudio ausente ou inválido: %s" % path)
		return null
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = loop_enabled
	elif stream is AudioStreamWAV and loop_enabled:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream_cache[path] = stream
	return stream


func _play_stream_on_player(
	player: AudioStreamPlayer,
	path: String,
	pitch_variation: bool,
	volume_db: float
) -> void:
	if not is_instance_valid(player):
		return
	var stream: AudioStream = _get_stream(path, false)
	if not is_instance_valid(stream):
		return
	player.stop()
	player.stream = stream
	player.pitch_scale = random.randf_range(0.965, 1.035) if pitch_variation else 1.0
	player.volume_db = volume_db
	player.play()


func _next_ui_player() -> AudioStreamPlayer:
	var player: AudioStreamPlayer = ui_players[ui_pool_index]
	ui_pool_index = (ui_pool_index + 1) % ui_players.size()
	return player


func _next_sfx_player() -> AudioStreamPlayer:
	var player: AudioStreamPlayer = sfx_players[sfx_pool_index]
	sfx_pool_index = (sfx_pool_index + 1) % sfx_players.size()
	return player


func _normalize_season_id(season_id: String) -> String:
	var normalized_id: String = season_id.strip_edges().to_lower()
	if not AMBIENCE_TRACKS.has(normalized_id):
		return "spring"
	return normalized_id


func _schedule_next_occasional_sound() -> void:
	if not is_instance_valid(occasional_timer):
		return
	occasional_timer.start(random.randf_range(OCCASIONAL_MIN_SECONDS, OCCASIONAL_MAX_SECONDS))


func _on_occasional_timer_timeout() -> void:
	if in_game and not game_menu_open and not dialogue_active and not OCCASIONAL_AMBIENCE.is_empty():
		var path: String = OCCASIONAL_AMBIENCE[random.randi_range(0, OCCASIONAL_AMBIENCE.size() - 1)]
		_play_stream_on_player(occasional_player, path, true, -6.0)
	_schedule_next_occasional_sound()


func _bind_existing_buttons() -> void:
	_bind_buttons_recursive(get_tree().root)


func _bind_buttons_recursive(node: Node) -> void:
	if node is Button:
		_bind_button_audio(node as Button)
	for child: Node in node.get_children():
		_bind_buttons_recursive(child)


func _on_tree_node_added(node: Node) -> void:
	if node is Button:
		call_deferred("_bind_button_audio", node)


func _bind_button_audio(button: Button) -> void:
	if not is_instance_valid(button) or button.has_meta("golems_mandate_audio_bound"):
		return
	button.set_meta("golems_mandate_audio_bound", true)
	button.mouse_entered.connect(_on_button_hover.bind(button))
	button.pressed.connect(_on_button_pressed.bind(button))


func _on_button_hover(button: Button) -> void:
	if not is_instance_valid(button) or button.disabled or not button.is_visible_in_tree():
		return
	var now_msec: int = Time.get_ticks_msec()
	if now_msec - last_hover_msec < HOVER_COOLDOWN_MSEC:
		return
	last_hover_msec = now_msec
	play_ui("hover", true)


func _on_button_pressed(button: Button) -> void:
	if not is_instance_valid(button):
		return
	var button_text: String = button.text.to_upper()
	if (
		"VOLTAR" in button_text
		or "CANCELAR" in button_text
		or "FECHAR" in button_text
		or "SAIR" in button_text
	):
		play_ui("cancel", true)
	elif (
		"CONFIRMAR" in button_text
		or "SALVAR" in button_text
		or "CARREGAR" in button_text
		or "INICIAR" in button_text
		or "ENCERRAR" in button_text
		or "CONSTRUIR" in button_text
		or "MELHORAR" in button_text
	):
		play_ui("confirm", true)
	else:
		play_ui("click", true)


func _connect_game_signals() -> void:
	if not GameManager.day_advanced.is_connected(_on_game_day_advanced):
		GameManager.day_advanced.connect(_on_game_day_advanced)
	if not GameManager.village_event_started.is_connected(_on_village_event_started):
		GameManager.village_event_started.connect(_on_village_event_started)
	if not GameManager.village_event_resolved.is_connected(_on_village_event_resolved):
		GameManager.village_event_resolved.connect(_on_village_event_resolved)
	if not GameManager.campaign_progress_changed.is_connected(_on_campaign_progress_changed):
		GameManager.campaign_progress_changed.connect(_on_campaign_progress_changed)
	if not GameManager.campaign_checkpoint_completed.is_connected(_on_checkpoint_completed):
		GameManager.campaign_checkpoint_completed.connect(_on_checkpoint_completed)
	if not GameManager.campaign_finished.is_connected(_on_campaign_finished):
		GameManager.campaign_finished.connect(_on_campaign_finished)
	if not GameManager.buildings_changed.is_connected(_on_buildings_changed):
		GameManager.buildings_changed.connect(_on_buildings_changed)
	if not GameManager.game_loaded.is_connected(_on_game_loaded):
		GameManager.game_loaded.connect(_on_game_loaded)
	if not GameManager.story_dialogue_requested.is_connected(_on_story_dialogue_requested):
		GameManager.story_dialogue_requested.connect(_on_story_dialogue_requested)
	if not GameManager.story_npc_recruited.is_connected(_on_story_npc_recruited):
		GameManager.story_npc_recruited.connect(_on_story_npc_recruited)
	if not GameManager.story_chapter_completed.is_connected(_on_story_chapter_completed):
		GameManager.story_chapter_completed.connect(_on_story_chapter_completed)
	if not GameManager.resources_changed.is_connected(_on_resources_changed):
		GameManager.resources_changed.connect(_on_resources_changed)
	if not GameManager.villagers_changed.is_connected(_on_villagers_changed):
		GameManager.villagers_changed.connect(_on_villagers_changed)


func _on_game_day_advanced(_summary: String) -> void:
	play_sfx("end_day")


func _on_village_event_started(event_data: Dictionary) -> void:
	var combined_text: String = (
		String(event_data.get("title", ""))
		+ " "
		+ String(event_data.get("description", ""))
	).to_lower()
	if "auditoria" in combined_text or "avaliação" in combined_text:
		play_sfx("event_audit")
	elif (
		"mimo" in combined_text
		or "engraç" in combined_text
		or "cômic" in combined_text
	):
		temporary_event_music_active = true
		play_fun_music()
		play_sfx("event_magic")
	else:
		play_sfx("event_magic")


func _on_village_event_resolved(result_text: String) -> void:
	var normalized_text: String = result_text.to_lower()
	if (
		"falha" in normalized_text
		or "fracasso" in normalized_text
		or "perdeu" in normalized_text
		or "não conseguiu" in normalized_text
	):
		play_sfx("event_negative")
	else:
		play_sfx("event_positive")
	if temporary_event_music_active:
		temporary_event_music_active = false
		restore_context_music()


func _on_campaign_progress_changed(progress_data: Dictionary) -> void:
	var season_id: String = String(progress_data.get("season_id", current_season_id))
	set_season(season_id)


func _on_checkpoint_completed(_progress_data: Dictionary) -> void:
	play_sfx("event_audit")


func _on_campaign_finished(result_data: Dictionary) -> void:
	var status: String = String(result_data.get("status", ""))
	if status == "victory":
		play_sfx("event_victory")
	else:
		play_sfx("event_defeat")


func _on_buildings_changed(_building_data: Dictionary, result_text: String) -> void:
	if result_text.is_empty():
		return
	var normalized_text: String = result_text.to_lower()
	if "melhor" in normalized_text or "nível" in normalized_text:
		play_sfx("upgrade")
	else:
		play_sfx("build")


func _on_game_loaded(_load_result: Dictionary) -> void:
	play_sfx("load")
	var season: Dictionary = GameManager.get_current_season()
	enter_game(String(season.get("id", "spring")))


func _on_story_dialogue_requested(request: Dictionary) -> void:
	begin_dialogue(true)
	var dialogue_id: String = String(request.get("dialogue_id", ""))
	if "prologue" in dialogue_id or "120" in dialogue_id:
		play_sfx("story_divine")
	else:
		play_sfx("story_chapter")


func _on_story_npc_recruited(_npc_data: Dictionary) -> void:
	play_sfx("story_recruit")


func _on_story_chapter_completed(_chapter_data: Dictionary) -> void:
	play_sfx("story_chapter")


func _on_resources_changed(
	food_value: float,
	material_value: float,
	happiness_value: float,
	_day_value: int
) -> void:
	if last_resource_values.is_empty():
		last_resource_values = {
			"food": food_value,
			"material": material_value,
			"happiness": happiness_value
		}
		return
	var previous_food: float = float(last_resource_values.get("food", food_value))
	var previous_material: float = float(last_resource_values.get("material", material_value))
	var previous_happiness: float = float(last_resource_values.get("happiness", happiness_value))
	if food_value <= 8.0 and previous_food > 8.0:
		play_sfx("resource_warning")
	elif material_value <= 3.0 and previous_material > 3.0:
		play_sfx("resource_warning")
	elif happiness_value <= 40.0 and previous_happiness > 40.0:
		play_sfx("resource_warning")
	last_resource_values = {
		"food": food_value,
		"material": material_value,
		"happiness": happiness_value
	}


func _on_villagers_changed() -> void:
	var population: Dictionary = GameManager.get_population_overview()
	var current_population: int = int(
		population.get("total_population", 0)
	)
	if last_population_count < 0:
		last_population_count = current_population
		return
	if current_population > last_population_count:
		play_sfx("population_arrival")
	elif current_population < last_population_count:
		play_sfx("population_leave")
	last_population_count = current_population


func _set_master_focus_attenuation(is_unfocused: bool) -> void:
	var master_index: int = AudioServer.get_bus_index("Master")
	if master_index < 0 or is_unfocused == focus_attenuated:
		return
	focus_attenuated = is_unfocused
	if is_unfocused:
		var current_db: float = AudioServer.get_bus_volume_db(master_index)
		AudioServer.set_bus_volume_db(master_index, current_db - 12.0)
	else:
		GameSettings.apply_settings()
