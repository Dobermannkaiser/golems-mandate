class_name SeasonHintWindow
extends Control


signal closed()


var overlay: ColorRect
var hint_panel: PanelContainer
var season_label: Label
var title_label: Label
var effects_label: Label
var tip_label: Label
var close_button: Button
var previous_focus: Control


func _ready() -> void:
	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_create_window()


func show_hint(hint_data: Dictionary) -> void:
	var season_id: String = String(
		hint_data.get("season_id", "spring")
	)
	var season_name: String = String(
		hint_data.get(
			"season_name",
			"Próxima estação"
		)
	)
	var palette: Dictionary = (
		MedievalTheme.get_season_palette(
			season_id,
			GameSettings.enhanced_contrast
		)
	)

	season_label.text = (
		"PREPARAÇÃO PARA %s"
		% season_name.to_upper()
	)
	title_label.text = String(
		hint_data.get(
			"title",
			"MUDANÇA DE ESTAÇÃO"
		)
	)
	effects_label.text = (
		"EFEITOS: "
		+ String(
			hint_data.get(
				"effects_text",
				"Consulte a previsão diária."
			)
		)
	)
	tip_label.text = (
		"DICA: "
		+ String(
			hint_data.get(
				"tip_text",
				"Prepare as reservas da vila."
			)
		)
	)

	title_label.add_theme_color_override(
		"font_color",
		palette["accent"]
	)
	hint_panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			palette["panel_dark"],
			palette["accent"],
			3,
			12,
			24,
			8
		)
	)

	previous_focus = VillageUIAccessibility.remember_focus(self)
	overlay.visible = true
	VillageUIAccessibility.focus_deferred(close_button)
	call_deferred("_animate_open")


func hide_window() -> void:
	if not is_instance_valid(overlay) or not overlay.visible:
		return

	overlay.visible = false
	VillageUIAccessibility.restore_focus_deferred(previous_focus)
	previous_focus = null
	closed.emit()


func is_window_visible() -> bool:
	return (
		is_instance_valid(overlay)
		and overlay.visible
	)


func _create_window() -> void:
	overlay = ColorRect.new()
	overlay.name = "SeasonHintOverlay"
	overlay.color = Color(
		0.02,
		0.025,
		0.03,
		0.86
	)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	overlay.z_index = 145
	overlay.visible = false
	add_child(overlay)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)

	hint_panel = PanelContainer.new()
	hint_panel.custom_minimum_size = Vector2(
		720.0,
		430.0
	)
	hint_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	center.add_child(hint_panel)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override(
		"separation",
		16
	)
	hint_panel.add_child(layout)

	season_label = MedievalTheme.create_label(
		"PREPARAÇÃO SAZONAL",
		MedievalTheme.TEXT_MUTED,
		14
	)
	season_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	layout.add_child(season_label)

	title_label = MedievalTheme.create_label(
		"MUDANÇA DE ESTAÇÃO",
		MedievalTheme.GOLD,
		28
	)
	title_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	layout.add_child(title_label)

	var divider: HSeparator = HSeparator.new()
	layout.add_child(divider)

	effects_label = MedievalTheme.create_label(
		"",
		MedievalTheme.PARCHMENT_LIGHT,
		18
	)
	effects_label.custom_minimum_size = Vector2(
		0.0,
		92.0
	)
	effects_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)
	effects_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	effects_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)
	layout.add_child(effects_label)

	tip_label = MedievalTheme.create_label(
		"",
		MedievalTheme.TEXT_LIGHT,
		17
	)
	tip_label.custom_minimum_size = Vector2(
		0.0,
		108.0
	)
	tip_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)
	tip_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	tip_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)
	layout.add_child(tip_label)

	close_button = Button.new()
	close_button.text = "ENTENDI"
	close_button.tooltip_text = "Fecha o aviso sazonal."
	close_button.custom_minimum_size = Vector2(
		220.0,
		50.0
	)
	close_button.size_flags_horizontal = (
		Control.SIZE_SHRINK_CENTER
	)
	close_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)
	VillageUIAccessibility.configure_button(close_button, "", 50.0)
	close_button.pressed.connect(hide_window)
	layout.add_child(close_button)


func _animate_open() -> void:
	if not is_instance_valid(hint_panel):
		return

	hint_panel.pivot_offset = hint_panel.size * 0.5

	if GameSettings.reduced_motion:
		hint_panel.modulate = Color.WHITE
		hint_panel.scale = Vector2.ONE
		return

	hint_panel.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.0
	)
	hint_panel.scale = Vector2(
		0.96,
		0.96
	)

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(
		hint_panel,
		"modulate",
		Color.WHITE,
		0.22
	)
	tween.tween_property(
		hint_panel,
		"scale",
		Vector2.ONE,
		0.22
	)


func _unhandled_key_input(
	event: InputEvent
) -> void:
	if not is_window_visible():
		return

	if event.is_action_pressed("ui_cancel"):
		hide_window()
		get_viewport().set_input_as_handled()
