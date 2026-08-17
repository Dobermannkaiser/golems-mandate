class_name TutorialWindow
extends Control


signal closed(completed: bool)


const PANEL_SIZE: Vector2 = Vector2(
	520.0,
	430.0
)

const SCREEN_MARGIN: float = 18.0
const TARGET_PADDING: float = 8.0


var overlay: Control
var dim_top: ColorRect
var dim_bottom: ColorRect
var dim_left: ColorRect
var dim_right: ColorRect
var highlight_frame: PanelContainer
var tutorial_panel: PanelContainer

var step_label: Label
var section_label: Label
var title_label: Label
var description_label: Label
var tip_label: Label
var previous_button: Button
var next_button: Button
var skip_button: Button

var tutorial_steps: Array[Dictionary] = []
var current_step_index: int = 0


func _ready() -> void:
	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	# O tutorial precisa ter prioridade como janela inteira. Quando apenas o
	# painel interno possuía z_index alto, modais abertos por baixo ainda
	# podiam receber os cliques antes dos botões do tutorial.
	z_index = 1000
	z_as_relative = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_create_window()
	visible = false

	get_viewport().size_changed.connect(
		_on_viewport_size_changed
	)


func show_tutorial(
	steps: Array[Dictionary],
	start_index: int = 0
) -> void:
	if steps.is_empty():
		return

	tutorial_steps.clear()

	for step: Dictionary in steps:
		tutorial_steps.append(
			step.duplicate(true)
		)

	current_step_index = clampi(
		start_index,
		0,
		tutorial_steps.size() - 1
	)

	# move_to_front resolve também a ordem de irmãos criada dinamicamente.
	# O z_index absoluto garante que Conselho, Relações e outros modais não
	# interceptem a entrada mesmo quando continuam visíveis por baixo.
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	move_to_front()
	overlay.visible = true
	overlay.move_to_front()
	_refresh_step()
	call_deferred("_layout_current_step")
	call_deferred("_animate_open")
	call_deferred("_focus_primary_button")


func hide_tutorial() -> void:
	if is_instance_valid(overlay):
		overlay.visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func is_window_visible() -> bool:
	return (
		visible
		and is_instance_valid(overlay)
		and overlay.visible
	)


func uses_custom_focus_direction(action_name: StringName) -> bool:
	return action_name == &"ui_left" or action_name == &"ui_right"


func _create_window() -> void:
	overlay = Control.new()
	overlay.name = "TutorialOverlay"
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	overlay.z_index = 0
	overlay.visible = false
	add_child(overlay)

	dim_top = _create_dim_rect()
	dim_bottom = _create_dim_rect()
	dim_left = _create_dim_rect()
	dim_right = _create_dim_rect()

	overlay.add_child(dim_top)
	overlay.add_child(dim_bottom)
	overlay.add_child(dim_left)
	overlay.add_child(dim_right)

	highlight_frame = PanelContainer.new()
	highlight_frame.name = "TutorialHighlight"
	highlight_frame.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	highlight_frame.add_theme_stylebox_override(
		"panel",
		_make_highlight_style()
	)

	overlay.add_child(highlight_frame)

	tutorial_panel = PanelContainer.new()
	tutorial_panel.name = "TutorialPanel"
	tutorial_panel.custom_minimum_size = PANEL_SIZE
	tutorial_panel.mouse_filter = (
		Control.MOUSE_FILTER_STOP
	)

	tutorial_panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(
			MedievalTheme.WOOD_DARK,
			MedievalTheme.GOLD,
			3,
			14,
			22,
			8
		)
	)

	overlay.add_child(tutorial_panel)

	var layout: VBoxContainer = VBoxContainer.new()

	layout.add_theme_constant_override(
		"separation",
		9
	)

	tutorial_panel.add_child(layout)

	var header_row: HBoxContainer = HBoxContainer.new()
	layout.add_child(header_row)

	section_label = MedievalTheme.create_label(
		"GUIA DA COMUNIDADE",
		MedievalTheme.GOLD,
		13
	)

	section_label.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	header_row.add_child(section_label)

	step_label = MedievalTheme.create_label(
		"1 / 1",
		MedievalTheme.TEXT_MUTED,
		13
	)

	step_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_RIGHT
	)

	header_row.add_child(step_label)

	var divider: HSeparator = HSeparator.new()
	layout.add_child(divider)

	title_label = MedievalTheme.create_label(
		"",
		MedievalTheme.PARCHMENT_LIGHT,
		24
	)

	title_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	layout.add_child(title_label)

	description_label = MedievalTheme.create_label(
		"",
		MedievalTheme.PARCHMENT_LIGHT,
		15
	)

	description_label.custom_minimum_size = Vector2(
		0.0,
		112.0
	)

	description_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	layout.add_child(description_label)

	var tip_panel: PanelContainer = PanelContainer.new()

	tip_panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(
			Color(0.19, 0.13, 0.08, 0.96),
			MedievalTheme.GOLD_DARK,
			1,
			8,
			10,
			0
		)
	)

	layout.add_child(tip_panel)

	tip_label = MedievalTheme.create_label(
		"",
		Color("#E6D27B"),
		13
	)

	tip_label.custom_minimum_size = Vector2(
		0.0,
		46.0
	)

	tip_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	tip_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	tip_panel.add_child(tip_label)

	var button_row: HBoxContainer = HBoxContainer.new()

	button_row.add_theme_constant_override(
		"separation",
		10
	)

	layout.add_child(button_row)

	skip_button = Button.new()
	skip_button.text = "PULAR TUTORIAL"
	skip_button.custom_minimum_size = Vector2(
		152.0,
		42.0
	)

	skip_button.mouse_filter = Control.MOUSE_FILTER_STOP
	skip_button.focus_mode = Control.FOCUS_ALL
	skip_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	skip_button.pressed.connect(
		_on_skip_pressed
	)

	button_row.add_child(skip_button)

	var spacer: Control = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_row.add_child(spacer)

	previous_button = Button.new()
	previous_button.text = "VOLTAR"
	previous_button.custom_minimum_size = Vector2(
		98.0,
		42.0
	)

	previous_button.mouse_filter = Control.MOUSE_FILTER_STOP
	previous_button.focus_mode = Control.FOCUS_ALL
	previous_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	previous_button.pressed.connect(
		_on_previous_pressed
	)

	button_row.add_child(previous_button)

	next_button = Button.new()
	next_button.text = "PRÓXIMO"
	next_button.custom_minimum_size = Vector2(
		118.0,
		42.0
	)

	next_button.mouse_filter = Control.MOUSE_FILTER_STOP
	next_button.focus_mode = Control.FOCUS_ALL
	next_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	next_button.pressed.connect(
		_on_next_pressed
	)

	button_row.add_child(next_button)


func _create_dim_rect() -> ColorRect:
	var dim_rect: ColorRect = ColorRect.new()

	dim_rect.color = Color(
		0.025,
		0.020,
		0.014,
		0.78
	)

	dim_rect.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	return dim_rect


func _refresh_step() -> void:
	if tutorial_steps.is_empty():
		return

	var step: Dictionary = (
		tutorial_steps[current_step_index]
	)

	var step_count: int = tutorial_steps.size()
	var is_last_step: bool = (
		current_step_index == step_count - 1
	)

	step_label.text = (
		"%d / %d"
		% [
			current_step_index + 1,
			step_count
		]
	)

	section_label.text = String(
		step.get(
			"section",
			"GUIA DA COMUNIDADE"
		)
	)

	title_label.text = String(
		step.get(
			"title",
			"COMO JOGAR"
		)
	)

	description_label.text = String(
		step.get(
			"description",
			""
		)
	)

	tip_label.text = (
		"DICA — "
		+ String(
			step.get(
				"tip",
				"Observe a área destacada."
			)
		)
	)

	previous_button.disabled = current_step_index == 0

	next_button.text = (
		String(
			step.get(
				"finish_text",
				"COMEÇAR"
			)
		)
		if is_last_step
		else "PRÓXIMO"
	)

	skip_button.text = String(
		step.get(
			"skip_text",
			"PULAR TUTORIAL"
		)
	)

	call_deferred("_layout_current_step")


func _layout_current_step() -> void:
	if not is_window_visible():
		return

	if tutorial_steps.is_empty():
		return

	var screen_size: Vector2 = overlay.size

	if screen_size.x <= 0.0 or screen_size.y <= 0.0:
		return

	var step: Dictionary = (
		tutorial_steps[current_step_index]
	)

	var target: Control = step.get(
		"target",
		null
	) as Control

	var target_rect: Rect2 = Rect2()
	var has_target: bool = is_instance_valid(target)

	if has_target:
		target_rect = target.get_global_rect()
		target_rect.position -= get_global_rect().position

		target_rect = target_rect.grow(
			TARGET_PADDING
		)

		target_rect.position.x = clampf(
			target_rect.position.x,
			SCREEN_MARGIN,
			screen_size.x - SCREEN_MARGIN
		)

		target_rect.position.y = clampf(
			target_rect.position.y,
			SCREEN_MARGIN,
			screen_size.y - SCREEN_MARGIN
		)

		target_rect.size.x = minf(
			target_rect.size.x,
			screen_size.x
			- target_rect.position.x
			- SCREEN_MARGIN
		)

		target_rect.size.y = minf(
			target_rect.size.y,
			screen_size.y
			- target_rect.position.y
			- SCREEN_MARGIN
		)

		highlight_frame.visible = true
		_set_control_rect(
			highlight_frame,
			target_rect
		)

		_layout_dimming(
			screen_size,
			target_rect
		)
	else:
		highlight_frame.visible = false
		_layout_full_dimming(screen_size)

	var preferred_side: String = String(
		step.get(
			"side",
			"center"
		)
	)

	var panel_position: Vector2 = _get_panel_position(
		screen_size,
		target_rect,
		has_target,
		preferred_side
	)

	_set_control_rect(
		tutorial_panel,
		Rect2(
			panel_position,
			PANEL_SIZE
		)
	)


func _layout_dimming(
	screen_size: Vector2,
	target_rect: Rect2
) -> void:
	_set_control_rect(
		dim_top,
		Rect2(
			Vector2.ZERO,
			Vector2(
				screen_size.x,
				maxf(0.0, target_rect.position.y)
			)
		)
	)

	var target_bottom: float = (
		target_rect.position.y
		+ target_rect.size.y
	)

	_set_control_rect(
		dim_bottom,
		Rect2(
			Vector2(
				0.0,
				target_bottom
			),
			Vector2(
				screen_size.x,
				maxf(
					0.0,
					screen_size.y - target_bottom
				)
			)
		)
	)

	_set_control_rect(
		dim_left,
		Rect2(
			Vector2(
				0.0,
				target_rect.position.y
			),
			Vector2(
				maxf(0.0, target_rect.position.x),
				target_rect.size.y
			)
		)
	)

	var target_right: float = (
		target_rect.position.x
		+ target_rect.size.x
	)

	_set_control_rect(
		dim_right,
		Rect2(
			Vector2(
				target_right,
				target_rect.position.y
			),
			Vector2(
				maxf(
					0.0,
					screen_size.x - target_right
				),
				target_rect.size.y
			)
		)
	)


func _layout_full_dimming(
	screen_size: Vector2
) -> void:
	_set_control_rect(
		dim_top,
		Rect2(
			Vector2.ZERO,
			screen_size
		)
	)

	for dim_rect: ColorRect in [
		dim_bottom,
		dim_left,
		dim_right
	]:
		_set_control_rect(
			dim_rect,
			Rect2()
		)


func _get_panel_position(
	screen_size: Vector2,
	target_rect: Rect2,
	has_target: bool,
	preferred_side: String
) -> Vector2:
	var centered_position: Vector2 = Vector2(
		(screen_size.x - PANEL_SIZE.x) * 0.5,
		(screen_size.y - PANEL_SIZE.y) * 0.5
	)

	if not has_target:
		return centered_position

	var gap: float = 18.0
	var panel_position: Vector2 = centered_position

	match preferred_side:
		"left":
			panel_position = Vector2(
				target_rect.position.x
				- PANEL_SIZE.x
				- gap,
				target_rect.get_center().y
				- PANEL_SIZE.y * 0.5
			)

		"right":
			panel_position = Vector2(
				target_rect.end.x + gap,
				target_rect.get_center().y
				- PANEL_SIZE.y * 0.5
			)

		"top":
			panel_position = Vector2(
				target_rect.get_center().x
				- PANEL_SIZE.x * 0.5,
				target_rect.position.y
				- PANEL_SIZE.y
				- gap
			)

		"bottom":
			panel_position = Vector2(
				target_rect.get_center().x
				- PANEL_SIZE.x * 0.5,
				target_rect.end.y + gap
			)

		_:
			panel_position = centered_position

	var maximum_position: Vector2 = Vector2(
		maxf(
			SCREEN_MARGIN,
			screen_size.x
			- PANEL_SIZE.x
			- SCREEN_MARGIN
		),
		maxf(
			SCREEN_MARGIN,
			screen_size.y
			- PANEL_SIZE.y
			- SCREEN_MARGIN
		)
	)

	panel_position.x = clampf(
		panel_position.x,
		SCREEN_MARGIN,
		maximum_position.x
	)

	panel_position.y = clampf(
		panel_position.y,
		SCREEN_MARGIN,
		maximum_position.y
	)

	return panel_position


func _set_control_rect(
	control: Control,
	rect: Rect2
) -> void:
	control.position = rect.position
	control.size = rect.size


func _on_previous_pressed() -> void:
	if current_step_index <= 0:
		return

	current_step_index -= 1
	_refresh_step()
	_animate_step_change()


func _on_next_pressed() -> void:
	if current_step_index < tutorial_steps.size() - 1:
		current_step_index += 1
		_refresh_step()
		_animate_step_change()
		return

	hide_tutorial()
	closed.emit(true)


func _on_skip_pressed() -> void:
	hide_tutorial()
	closed.emit(false)


func _focus_primary_button() -> void:
	if not is_window_visible():
		return
	if is_instance_valid(next_button):
		next_button.grab_focus()


func _on_viewport_size_changed() -> void:
	call_deferred("_layout_current_step")


func _animate_open() -> void:
	if not is_instance_valid(tutorial_panel):
		return

	tutorial_panel.pivot_offset = (
		tutorial_panel.size * 0.5
	)

	if GameSettings.reduced_motion:
		tutorial_panel.modulate = Color.WHITE
		tutorial_panel.scale = Vector2.ONE
		return

	tutorial_panel.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.0
	)

	tutorial_panel.scale = Vector2(
		0.97,
		0.97
	)

	var tween: Tween = create_tween()

	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		tutorial_panel,
		"modulate",
		Color.WHITE,
		0.20
	)

	tween.tween_property(
		tutorial_panel,
		"scale",
		Vector2.ONE,
		0.20
	)


func _animate_step_change() -> void:
	if GameSettings.reduced_motion:
		tutorial_panel.modulate = Color.WHITE
		return

	tutorial_panel.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.45
	)

	var tween: Tween = create_tween()

	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		tutorial_panel,
		"modulate",
		Color.WHITE,
		0.15
	)


func _input(event: InputEvent) -> void:
	if not is_window_visible():
		return

	if event.is_action_pressed("ui_cancel"):
		_on_skip_pressed()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_left"):
		_on_previous_pressed()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
		_on_next_pressed()
		get_viewport().set_input_as_handled()


func _make_highlight_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()

	style.bg_color = Color(
		0.95,
		0.78,
		0.28,
		0.08
	)

	style.border_color = MedievalTheme.GOLD

	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3

	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10

	style.shadow_color = Color(
		0.95,
		0.78,
		0.28,
		0.40
	)

	style.shadow_size = 10

	return style


func _make_panel_style(
	background_color: Color,
	border_color: Color,
	border_size: int,
	radius: int,
	padding: int,
	shadow_size: int = 0
) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()

	style.bg_color = background_color
	style.border_color = border_color

	style.border_width_left = border_size
	style.border_width_top = border_size
	style.border_width_right = border_size
	style.border_width_bottom = border_size

	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius

	style.content_margin_left = float(padding)
	style.content_margin_top = float(padding)
	style.content_margin_right = float(padding)
	style.content_margin_bottom = float(padding)

	if shadow_size > 0:
		style.shadow_color = Color(
			0.06,
			0.03,
			0.02,
			0.70
		)

		style.shadow_size = shadow_size
		style.shadow_offset = Vector2(
			0.0,
			4.0
		)

	return style
