class_name VillageDialogueWindow
extends Control


signal dialogue_closed(conversation_id: String)
signal choice_selected(conversation_id: String, choice_data: Dictionary)


const DIALOGUE_MANAGER_SCRIPT = preload(
	"res://scripts/dialogue/DialogueManager.gd"
)
const CHARACTER_CATALOG_SCRIPT = preload(
	"res://scripts/dialogue/CharacterCatalog.gd"
)
const PIXEL_FONT: FontFile = preload(
	"res://assets/dialogue/alagard.ttf"
)

const TYPEWRITER_CHARACTERS_PER_SECOND: float = 46.0

var overlay: ColorRect
var dialogue_spacer: Control
var scene_art_frame: PanelContainer
var scene_art_texture: TextureRect
var scene_art_caption: Label
var portrait_frame: PanelContainer
var portrait_texture: TextureRect
var portrait_fallback: Label
var name_label: Label
var title_label: Label
var dialogue_text: RichTextLabel
var choices_container: VBoxContainer
var continue_button: Button
var history_button: Button
var close_button: Button
var history_panel: PanelContainer
var history_text: RichTextLabel
var history_close_button: Button
var previous_focus: Control

var dialogue_manager: VillageDialogueManager
var typing_active: bool = false
var visible_character_progress: float = 0.0
var current_full_text: String = ""
var last_typed_audio_character: int = 0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 900
	dialogue_manager = DIALOGUE_MANAGER_SCRIPT.new()
	_create_window()
	set_process(false)


func show_conversation(conversation_data: Dictionary) -> bool:
	var prepared_conversation: Dictionary = conversation_data.duplicate(true)
	if not prepared_conversation.has("player_speaker_name"):
		var profile: Dictionary = GameManager.get_player_profile_overview()
		var player_name: String = String(profile.get("name", "Alex")).strip_edges()
		prepared_conversation["player_speaker_name"] = (
			"Prefeito %s" % player_name
			if not player_name.is_empty()
			else "Prefeito"
		)

	var scene_image_loaded: bool = _configure_scene_image(
		prepared_conversation
	)
	if (
		prepared_conversation.has("scene_image_path")
		and not scene_image_loaded
	):
		_apply_scene_image_fallback(prepared_conversation)

	previous_focus = VillageUIAccessibility.remember_focus(self)
	if not dialogue_manager.start_conversation(prepared_conversation):
		_reset_scene_image()
		push_error("Não foi possível iniciar a conversa solicitada.")
		return false

	overlay.visible = true
	history_panel.visible = false
	close_button.visible = bool(
		prepared_conversation.get("allow_close", true)
	)
	_render_current_node()
	call_deferred("_animate_open")
	return true


func hide_dialogue() -> void:
	if not is_instance_valid(overlay) or not overlay.visible:
		return

	var closed_conversation_id: String = (
		dialogue_manager.conversation_id
	)
	typing_active = false
	set_process(false)
	overlay.visible = false
	_reset_scene_image()
	dialogue_manager.reset()
	var restore_root: Control
	var parent_node: Node = get_parent()
	if (
		is_instance_valid(parent_node)
		and parent_node.has_method("get_focus_restore_root")
	):
		restore_root = parent_node.call("get_focus_restore_root") as Control
	VillageUIAccessibility.restore_focus_deferred(
		previous_focus,
		restore_root
	)
	previous_focus = null
	dialogue_closed.emit(closed_conversation_id)


func is_dialogue_visible() -> bool:
	return is_instance_valid(overlay) and overlay.visible


func get_active_focus_root() -> Control:
	if is_instance_valid(history_panel) and history_panel.visible:
		return history_panel
	return overlay


func _process(delta: float) -> void:
	if not typing_active:
		set_process(false)
		return

	visible_character_progress += (
		TYPEWRITER_CHARACTERS_PER_SECOND * delta
	)
	var visible_characters: int = mini(
		current_full_text.length(),
		int(floor(visible_character_progress))
	)
	dialogue_text.visible_characters = visible_characters
	if visible_characters >= last_typed_audio_character + 4:
		last_typed_audio_character = visible_characters
		AudioManager.play_dialogue_text_tick()

	if visible_characters >= current_full_text.length():
		_complete_typing()


func _unhandled_input(event: InputEvent) -> void:
	if not is_dialogue_visible():
		return

	if event.is_action_pressed("ui_cancel"):
		if history_panel.visible:
			_on_history_close_pressed()
		elif close_button.visible:
			hide_dialogue()
		else:
			return
		get_viewport().set_input_as_handled()
		return

	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if (
			key_event.pressed
			and not key_event.echo
			and key_event.keycode in [KEY_ENTER, KEY_SPACE]
		):
			_handle_advance_request()
			get_viewport().set_input_as_handled()


func _create_window() -> void:
	overlay = ColorRect.new()
	overlay.name = "DialogueOverlay"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.015, 0.020, 0.028, 0.76)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.visible = false
	overlay.gui_input.connect(_on_overlay_gui_input)
	add_child(overlay)

	var outer_margin: MarginContainer = MarginContainer.new()
	outer_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outer_margin.add_theme_constant_override("margin_left", 34)
	outer_margin.add_theme_constant_override("margin_top", 28)
	outer_margin.add_theme_constant_override("margin_right", 34)
	outer_margin.add_theme_constant_override("margin_bottom", 24)
	overlay.add_child(outer_margin)

	var vertical: VBoxContainer = VBoxContainer.new()
	vertical.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outer_margin.add_child(vertical)

	dialogue_spacer = Control.new()
	dialogue_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dialogue_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vertical.add_child(dialogue_spacer)

	scene_art_frame = PanelContainer.new()
	scene_art_frame.name = "ImportantSceneArt"
	scene_art_frame.custom_minimum_size = Vector2(0.0, 190.0)
	scene_art_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scene_art_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scene_art_frame.clip_contents = true
	scene_art_frame.visible = false
	scene_art_frame.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			Color("#0E1420"),
			Color("#D2A85B"),
			2,
			10,
			6,
			2
		)
	)
	vertical.add_child(scene_art_frame)

	var art_layout: VBoxContainer = VBoxContainer.new()
	art_layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	art_layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	art_layout.add_theme_constant_override("separation", 4)
	scene_art_frame.add_child(art_layout)

	scene_art_texture = TextureRect.new()
	scene_art_texture.name = "SceneTexture"
	scene_art_texture.custom_minimum_size = Vector2(0.0, 160.0)
	scene_art_texture.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scene_art_texture.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scene_art_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	scene_art_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	scene_art_texture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	scene_art_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_layout.add_child(scene_art_texture)

	scene_art_caption = Label.new()
	scene_art_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scene_art_caption.add_theme_font_override("font", PIXEL_FONT)
	scene_art_caption.add_theme_font_size_override("font_size", 12)
	scene_art_caption.add_theme_color_override("font_color", Color("#F1C86C"))
	scene_art_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_layout.add_child(scene_art_caption)

	choices_container = VBoxContainer.new()
	choices_container.custom_minimum_size = Vector2(0.0, 0.0)
	choices_container.add_theme_constant_override("separation", 7)
	choices_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vertical.add_child(choices_container)

	var dialogue_panel: PanelContainer = PanelContainer.new()
	dialogue_panel.custom_minimum_size = Vector2(0.0, 238.0)
	dialogue_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	dialogue_panel.gui_input.connect(_on_dialogue_panel_gui_input)
	dialogue_panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			Color("#21182D"),
			Color("#D2A85B"),
			3,
			12,
			18,
			6
		)
	)
	vertical.add_child(dialogue_panel)

	var content_row: HBoxContainer = HBoxContainer.new()
	content_row.add_theme_constant_override("separation", 16)
	dialogue_panel.add_child(content_row)

	portrait_frame = PanelContainer.new()
	portrait_frame.custom_minimum_size = Vector2(214.0, 208.0)
	portrait_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_frame.clip_contents = true
	portrait_frame.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			Color("#0E1420"),
			Color("#8F73B8"),
			2,
			10,
			4,
			2
		)
	)
	content_row.add_child(portrait_frame)

	portrait_texture = TextureRect.new()
	portrait_texture.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	portrait_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_frame.add_child(portrait_texture)

	portrait_fallback = Label.new()
	portrait_fallback.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	portrait_fallback.text = "?"
	portrait_fallback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portrait_fallback.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	portrait_fallback.add_theme_font_override("font", PIXEL_FONT)
	portrait_fallback.add_theme_font_size_override("font_size", 60)
	portrait_fallback.add_theme_color_override(
		"font_color",
		Color("#D9C7F0")
	)
	portrait_fallback.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_frame.add_child(portrait_fallback)

	var text_column: VBoxContainer = VBoxContainer.new()
	text_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_column.add_theme_constant_override("separation", 6)
	content_row.add_child(text_column)

	var heading_row: HBoxContainer = HBoxContainer.new()
	text_column.add_child(heading_row)

	name_label = Label.new()
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_override("font", PIXEL_FONT)
	name_label.add_theme_font_size_override("font_size", 22)
	name_label.add_theme_color_override("font_color", Color("#F1C86C"))
	heading_row.add_child(name_label)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	title_label.add_theme_font_override("font", PIXEL_FONT)
	title_label.add_theme_font_size_override("font_size", 12)
	title_label.add_theme_color_override("font_color", Color("#BCA8CF"))
	heading_row.add_child(title_label)

	var divider: HSeparator = HSeparator.new()
	text_column.add_child(divider)

	dialogue_text = RichTextLabel.new()
	dialogue_text.bbcode_enabled = false
	dialogue_text.fit_content = false
	dialogue_text.scroll_active = true
	dialogue_text.scroll_following = false
	dialogue_text.selection_enabled = true
	dialogue_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_text.add_theme_font_override("normal_font", PIXEL_FONT)
	dialogue_text.add_theme_font_size_override("normal_font_size", 17)
	dialogue_text.add_theme_color_override(
		"default_color",
		Color("#F2E8D2")
	)
	dialogue_text.add_theme_constant_override("line_separation", 5)
	dialogue_text.mouse_filter = Control.MOUSE_FILTER_PASS
	text_column.add_child(dialogue_text)

	var action_row: HBoxContainer = HBoxContainer.new()
	action_row.alignment = BoxContainer.ALIGNMENT_END
	action_row.add_theme_constant_override("separation", 8)
	text_column.add_child(action_row)

	history_button = _create_small_button("HISTÓRICO")
	history_button.tooltip_text = "Reveja as falas da conversa atual."
	history_button.pressed.connect(_on_history_pressed)
	action_row.add_child(history_button)

	close_button = _create_small_button("SAIR")
	close_button.tooltip_text = "Encerra esta conversa."
	close_button.pressed.connect(hide_dialogue)
	action_row.add_child(close_button)

	continue_button = _create_small_button("CONTINUAR")
	continue_button.tooltip_text = "Completa ou avança a fala atual."
	continue_button.pressed.connect(_handle_advance_request)
	action_row.add_child(continue_button)

	_create_history_panel(overlay)


func _create_history_panel(parent: Control) -> void:
	history_panel = PanelContainer.new()
	history_panel.set_anchors_preset(Control.PRESET_CENTER)
	history_panel.offset_left = -390.0
	history_panel.offset_top = -245.0
	history_panel.offset_right = 390.0
	history_panel.offset_bottom = 245.0
	history_panel.visible = false
	history_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	history_panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			Color("#25182C"),
			Color("#D2A85B"),
			3,
			12,
			18,
			8
		)
	)
	parent.add_child(history_panel)

	var history_layout: VBoxContainer = VBoxContainer.new()
	history_layout.add_theme_constant_override("separation", 8)
	history_panel.add_child(history_layout)

	var history_title: Label = Label.new()
	history_title.text = "CRÔNICA DA CONVERSA"
	history_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	history_title.add_theme_font_override("font", PIXEL_FONT)
	history_title.add_theme_font_size_override("font_size", 21)
	history_title.add_theme_color_override("font_color", Color("#F1C86C"))
	history_layout.add_child(history_title)

	history_text = RichTextLabel.new()
	history_text.bbcode_enabled = false
	history_text.fit_content = false
	history_text.scroll_active = true
	history_text.selection_enabled = true
	history_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	history_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	history_text.add_theme_font_override("normal_font", PIXEL_FONT)
	history_text.add_theme_font_size_override("normal_font_size", 16)
	history_text.add_theme_color_override("default_color", Color("#F2E8D2"))
	history_layout.add_child(history_text)

	history_close_button = _create_small_button("VOLTAR")
	history_close_button.tooltip_text = "Retorna à conversa atual."
	history_close_button.pressed.connect(_on_history_close_pressed)
	history_layout.add_child(history_close_button)


func _configure_scene_image(conversation_data: Dictionary) -> bool:
	_reset_scene_image()
	var image_path: String = String(
		conversation_data.get("scene_image_path", "")
	).strip_edges()
	if image_path.is_empty() or not ResourceLoader.exists(image_path):
		return false
	var texture: Texture2D = load(image_path) as Texture2D
	if texture == null:
		return false
	scene_art_texture.texture = texture
	scene_art_texture.tooltip_text = String(
		conversation_data.get(
			"scene_image_alt",
			"Ilustração da cena importante."
		)
	)
	scene_art_caption.text = String(
		conversation_data.get("scene_image_caption", "CENA IMPORTANTE")
	)
	scene_art_frame.visible = true
	dialogue_spacer.visible = false
	return true


func _reset_scene_image() -> void:
	if is_instance_valid(scene_art_texture):
		scene_art_texture.texture = null
		scene_art_texture.tooltip_text = ""
	if is_instance_valid(scene_art_caption):
		scene_art_caption.text = ""
	if is_instance_valid(scene_art_frame):
		scene_art_frame.visible = false
	if is_instance_valid(dialogue_spacer):
		dialogue_spacer.visible = true


func _apply_scene_image_fallback(conversation_data: Dictionary) -> void:
	var nodes_value: Variant = conversation_data.get("nodes", null)
	if not nodes_value is Dictionary:
		return
	var nodes: Dictionary = nodes_value as Dictionary
	var start_id: String = String(conversation_data.get("start", "opening"))
	var opening_value: Variant = nodes.get(start_id, null)
	if not opening_value is Dictionary:
		return
	var opening: Dictionary = (opening_value as Dictionary).duplicate(true)
	opening["speaker_id"] = String(
		conversation_data.get("scene_fallback_portrait_id", "")
	)
	opening["speaker_name"] = String(
		conversation_data.get("scene_fallback_name", "Personagem")
	)
	opening["hide_portrait"] = false
	nodes[start_id] = opening
	conversation_data["nodes"] = nodes


func _create_small_button(text_value: String) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(118.0, 34.0)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", PIXEL_FONT)
	button.add_theme_font_size_override("font_size", 13)
	VillageUIAccessibility.configure_button(button, "", 38.0)
	return button


func _render_current_node() -> void:
	var node: Dictionary = dialogue_manager.get_current_node()

	if node.is_empty():
		hide_dialogue()
		return

	var speaker_id: String = String(node.get("speaker_id", ""))
	var speaker_name: String = String(node.get("speaker_name", "Personagem"))
	var expression: String = String(node.get("expression", "neutral"))
	var hide_portrait: bool = bool(node.get("hide_portrait", false))
	var texture: Texture2D = null
	if not hide_portrait:
		texture = CHARACTER_CATALOG_SCRIPT.get_portrait_texture(
			speaker_id,
			expression
		)

	portrait_frame.visible = not hide_portrait
	name_label.text = speaker_name.to_upper()
	title_label.text = dialogue_manager.conversation_title.to_upper()
	portrait_texture.texture = texture
	portrait_texture.visible = texture != null
	portrait_fallback.visible = texture == null
	portrait_fallback.text = _get_initials(speaker_name)
	_apply_portrait_expression(expression)

	current_full_text = String(node.get("text", ""))
	dialogue_text.text = current_full_text
	dialogue_text.scroll_to_line(0)
	visible_character_progress = 0.0
	last_typed_audio_character = 0

	if (
		GameSettings.reduced_motion
		or GameSettings.instant_dialogue_text
	):
		dialogue_text.visible_characters = -1
		typing_active = false
		set_process(false)
		_rebuild_choices()
	else:
		dialogue_text.visible_characters = 0
		typing_active = true
		set_process(true)
		_clear_choices()

	_update_continue_button()
	_focus_current_action()


func _complete_typing() -> void:
	typing_active = false
	set_process(false)
	dialogue_text.visible_characters = -1
	_rebuild_choices()
	_update_continue_button()
	_focus_current_action()


func _rebuild_choices() -> void:
	_clear_choices()
	var choices: Array[Dictionary] = dialogue_manager.get_current_choices()

	if choices.is_empty():
		return

	for choice: Dictionary in choices:
		var button: Button = Button.new()
		button.text = "%s: %s" % [
			dialogue_manager.player_speaker_name.to_upper(),
			String(choice.get("text", "..."))
		]
		button.custom_minimum_size = Vector2(0.0, 58.0)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.disabled = bool(choice.get("disabled", false))
		button.tooltip_text = String(choice.get("disabled_reason", ""))
		button.mouse_default_cursor_shape = (
			Control.CURSOR_FORBIDDEN
			if button.disabled
			else Control.CURSOR_POINTING_HAND
		)
		button.add_theme_font_override("font", PIXEL_FONT)
		button.add_theme_font_size_override("font_size", 14)
		button.pressed.connect(
			_on_choice_pressed.bind(String(choice.get("id", "")))
		)
		choices_container.add_child(button)


func _clear_choices() -> void:
	for child: Node in choices_container.get_children():
		choices_container.remove_child(child)
		child.queue_free()


func _handle_advance_request() -> void:
	if not is_dialogue_visible() or history_panel.visible:
		return

	if typing_active:
		_complete_typing()
		return

	if not dialogue_manager.get_current_choices().is_empty():
		return

	var result: Dictionary = dialogue_manager.advance()

	if bool(result.get("finished", false)):
		hide_dialogue()
		return

	_render_current_node()


func _on_choice_pressed(choice_id: String) -> void:
	if typing_active:
		_complete_typing()
		return

	var conversation_id: String = dialogue_manager.conversation_id
	var result: Dictionary = dialogue_manager.choose(choice_id)

	if not bool(result.get("chosen", false)):
		push_error(String(result.get("error", "Escolha de diálogo inválida.")))
		return

	var choice_data: Dictionary = result.get("choice", {})
	if not choice_data.is_empty():
		choice_selected.emit(conversation_id, choice_data)

	if bool(result.get("finished", false)):
		hide_dialogue()
		return

	_render_current_node()


func _update_continue_button() -> void:
	if typing_active:
		continue_button.text = "COMPLETAR"
		continue_button.disabled = false
		return

	var choices: Array[Dictionary] = dialogue_manager.get_current_choices()
	continue_button.text = "CONTINUAR"
	continue_button.disabled = not choices.is_empty()


func _on_history_pressed() -> void:
	history_text.text = dialogue_manager.get_history_text()
	history_text.scroll_to_line(0)
	history_panel.visible = true
	VillageUIAccessibility.focus_deferred(history_close_button)


func _on_history_close_pressed() -> void:
	history_panel.visible = false
	_focus_current_action()


func _focus_current_action() -> void:
	if not is_dialogue_visible() or history_panel.visible:
		return
	var choices: Array[Node] = choices_container.get_children()
	for choice_node: Node in choices:
		if choice_node is Button and not (choice_node as Button).disabled:
			VillageUIAccessibility.focus_deferred(
				choice_node as Button
			)
			return
	if not continue_button.disabled:
		VillageUIAccessibility.focus_deferred(continue_button)
	elif close_button.visible:
		VillageUIAccessibility.focus_deferred(close_button)


func _on_overlay_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_handle_advance_request()


func _on_dialogue_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_handle_advance_request()


func _get_initials(display_name: String) -> String:
	var parts: PackedStringArray = display_name.strip_edges().split(" ", false)
	var initials: String = "?"

	if parts.size() >= 1 and not parts[0].is_empty():
		initials = parts[0].substr(0, 1).to_upper()

	if parts.size() >= 2 and not parts[1].is_empty():
		initials += parts[1].substr(0, 1).to_upper()

	return initials


func _apply_portrait_expression(_expression: String) -> void:
	# Retratos aprovados devem manter exatamente as cores do arquivo PNG.
	# Expressões com arte própria continuam sendo resolvidas pelo catálogo.
	portrait_texture.modulate = Color.WHITE
	portrait_fallback.modulate = Color.WHITE


func _animate_open() -> void:
	if GameSettings.reduced_motion:
		modulate = Color.WHITE
		return

	modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.20)
