class_name VillageEventWindow
extends Control


const PIXEL_FONT: FontFile = preload(
	"res://assets/dialogue/alagard.ttf"
)


var event_overlay: ColorRect
var event_panel: PanelContainer
var event_title_label: Label
var event_description_label: Label
var event_villager_selector: OptionButton
var event_responsible_row: HBoxContainer
var event_responsible_label: Label
var event_choices_container: VBoxContainer
var event_hint_label: Label

var preferred_villager: Villager
var active_event_data: Dictionary = {}
var event_villager_options: Array[Villager] = []
var previous_focus: Control


func _ready() -> void:
	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_create_event_overlay()


func show_event(
	event_data: Dictionary,
	selected_villager: Villager
) -> void:
	previous_focus = VillageUIAccessibility.remember_focus(self)
	active_event_data = event_data.duplicate(true)
	preferred_villager = selected_villager
	event_overlay.visible = true

	event_title_label.text = String(
		active_event_data.get(
			"title",
			"ACONTECIMENTO"
		)
	)

	event_description_label.text = String(
		active_event_data.get(
			"description",
			"Algo aconteceu na vila."
		)
	)

	if bool(active_event_data.get("is_founder_memory", false)):
		event_hint_label.text = (
			"Esta é uma lembrança pessoal. O fundador indicado é o protagonista "
			+ "e receberá o registro e a experiência desta decisão."
		)
	else:
		event_hint_label.text = (
			"A carta selecionada já foi definida como responsável. "
			+ "Troque apenas quando quiser comparar outra pessoa; a decisão continua em um clique."
		)

	_populate_event_villager_selector()
	_rebuild_event_choice_buttons()
	_focus_event_controls()

	call_deferred("_animate_event_open")


func hide_event() -> void:
	active_event_data.clear()
	event_villager_options.clear()
	preferred_villager = null
	event_overlay.visible = false
	VillageUIAccessibility.restore_focus_deferred(previous_focus)
	previous_focus = null


func has_event_data() -> bool:
	return not active_event_data.is_empty()


func is_event_visible() -> bool:
	return (
		is_instance_valid(event_overlay)
		and event_overlay.visible
	)


func _create_event_overlay() -> void:
	event_overlay = ColorRect.new()
	event_overlay.name = "VillageEventOverlay"
	event_overlay.color = Color(
		0.025,
		0.015,
		0.008,
		0.82
	)

	event_overlay.mouse_filter = (
		Control.MOUSE_FILTER_STOP
	)

	event_overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	event_overlay.z_index = 100
	event_overlay.visible = false
	add_child(event_overlay)

	var event_center: CenterContainer = (
		CenterContainer.new()
	)

	event_center.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	event_center.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	event_overlay.add_child(event_center)

	event_panel = PanelContainer.new()

	event_panel.custom_minimum_size = Vector2(
		760.0,
		600.0
	)

	event_panel.mouse_filter = (
		Control.MOUSE_FILTER_STOP
	)

	event_panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			MedievalTheme.WOOD_DARK,
			MedievalTheme.GOLD,
			3,
			12,
			22,
			8
		)
	)

	event_center.add_child(event_panel)

	var event_layout: VBoxContainer = (
		VBoxContainer.new()
	)

	event_layout.add_theme_constant_override(
		"separation",
		10
	)

	event_panel.add_child(event_layout)

	var event_section_label: Label = MedievalTheme.create_label(
		"PRESSÁGIO DA VILA",
		MedievalTheme.TEXT_MUTED,
		13
	)

	event_section_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	event_layout.add_child(event_section_label)

	event_title_label = MedievalTheme.create_label(
		"",
		MedievalTheme.GOLD,
		27
	)

	event_title_label.add_theme_font_override("font", PIXEL_FONT)
	event_title_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	event_layout.add_child(event_title_label)

	var event_divider: HSeparator = HSeparator.new()
	event_layout.add_child(event_divider)

	event_description_label = MedievalTheme.create_label(
		"",
		MedievalTheme.PARCHMENT_LIGHT,
		17
	)

	event_description_label.add_theme_font_override("font", PIXEL_FONT)
	event_description_label.custom_minimum_size = Vector2(
		0.0,
		62.0
	)

	event_description_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	event_description_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	event_description_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	event_layout.add_child(event_description_label)

	event_responsible_row = (
		HBoxContainer.new()
	)

	event_responsible_row.add_theme_constant_override(
		"separation",
		12
	)

	event_layout.add_child(event_responsible_row)

	event_responsible_label = MedievalTheme.create_label(
		"HABITANTE RESPONSÁVEL",
		MedievalTheme.GOLD,
		14
	)

	event_responsible_label.custom_minimum_size = Vector2(
		230.0,
		0.0
	)

	event_responsible_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	event_responsible_row.add_child(event_responsible_label)

	event_villager_selector = OptionButton.new()
	event_villager_selector.tooltip_text = (
		"Escolha qual representante enfrentará o acontecimento."
	)
	VillageUIAccessibility.configure_input(event_villager_selector)

	event_villager_selector.custom_minimum_size = Vector2(
		0.0,
		42.0
	)

	event_villager_selector.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	event_villager_selector.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	event_villager_selector.tooltip_text = (
		"O atributo deste habitante altera "
		+ "a chance das escolhas de teste."
	)

	event_villager_selector.item_selected.connect(
		_on_event_villager_selected
	)

	event_responsible_row.add_child(
		event_villager_selector
	)

	event_hint_label = MedievalTheme.create_label(
		"",
		MedievalTheme.TEXT_MUTED,
		12
	)

	event_hint_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	event_hint_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	event_layout.add_child(event_hint_label)

	event_choices_container = VBoxContainer.new()

	event_choices_container.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	event_choices_container.add_theme_constant_override(
		"separation",
		9
	)

	event_layout.add_child(event_choices_container)



func _populate_event_villager_selector() -> void:
	event_villager_selector.clear()
	event_villager_options.clear()

	var fixed_actor_id: String = String(
		active_event_data.get("fixed_actor_id", "")
	).strip_edges()
	if not fixed_actor_id.is_empty():
		for villager: Villager in GameManager.villagers:
			if (
				is_instance_valid(villager)
				and villager.representative_id == fixed_actor_id
			):
				event_villager_options.append(villager)
				event_villager_selector.add_item(
					"%s — memória pessoal" % villager.villager_name
				)
				event_villager_selector.disabled = true
				if is_instance_valid(event_responsible_label):
					event_responsible_label.text = "FUNDADOR LEMBRADO"
				return
	if is_instance_valid(event_responsible_label):
		event_responsible_label.text = "HABITANTE RESPONSÁVEL"

	var preferred_index: int = 0
	var valid_index: int = 0

	for villager: Villager in GameManager.villagers:
		if not is_instance_valid(villager) or not villager.is_council_active:
			continue

		event_villager_options.append(villager)

		event_villager_selector.add_item(
			"%s — %s" % [
				villager.villager_name,
				Villager.get_profession_name(
					villager.current_profession
				)
			]
		)

		if villager == preferred_villager:
			preferred_index = valid_index

		valid_index += 1

	if event_villager_options.is_empty():
		event_villager_selector.add_item(
			"Nenhum habitante disponível"
		)

		event_villager_selector.disabled = true
		return

	event_villager_selector.disabled = false
	event_villager_selector.select(preferred_index)


func _on_event_villager_selected(
	_selected_index: int
) -> void:
	_rebuild_event_choice_buttons()
	_focus_event_controls(false)


func _get_event_selected_villager() -> Villager:
	if event_villager_options.is_empty():
		return null

	var selected_index: int = (
		event_villager_selector.selected
	)

	if (
		selected_index < 0
		or selected_index >= event_villager_options.size()
	):
		return null

	var villager: Villager = (
		event_villager_options[selected_index]
	)

	if not is_instance_valid(villager):
		return null

	return villager


func _rebuild_event_choice_buttons() -> void:
	if not is_instance_valid(event_choices_container):
		return

	var old_buttons: Array[Node] = (
		event_choices_container.get_children()
	)

	for old_button: Node in old_buttons:
		event_choices_container.remove_child(
			old_button
		)

		old_button.queue_free()

	if active_event_data.is_empty():
		return

	var villager: Villager = (
		_get_event_selected_villager()
	)

	var choices: Array = active_event_data.get(
		"choices",
		[]
	)

	for choice_value: Variant in choices:
		var choice: Dictionary = choice_value
		var choice_id: String = String(
			choice.get("id", "")
		)

		var choice_state: Dictionary = (
			GameManager.get_event_choice_state(
				choice_id,
				villager
			)
		)
		if (
			bool(choice.get("is_build_variant_choice", false))
			and not bool(choice_state.get("available", false))
			and String(choice_state.get("reason", "")).begins_with(
				"Exige a build"
			)
		):
			continue

		var choice_button: Button = Button.new()
		choice_button.add_theme_font_override("font", PIXEL_FONT)
		choice_button.add_theme_font_size_override("font_size", 14)

		choice_button.custom_minimum_size = Vector2(
			0.0,
			82.0
		)

		choice_button.size_flags_vertical = (
			Control.SIZE_EXPAND_FILL
		)

		choice_button.mouse_default_cursor_shape = (
			Control.CURSOR_POINTING_HAND
		)

		choice_button.alignment = (
			HORIZONTAL_ALIGNMENT_LEFT
		)

		choice_button.text_overrun_behavior = (
			TextServer.OVERRUN_NO_TRIMMING
		)

		choice_button.text = (
			_build_event_choice_text(
				choice,
				choice_state,
				villager
			)
		)

		choice_button.disabled = not bool(
			choice_state["available"]
		)

		var unavailable_reason: String = String(
			choice_state.get("reason", "")
		)

		if unavailable_reason.is_empty():
			choice_button.tooltip_text = (
				"Clique para confirmar esta decisão."
			)
		else:
			choice_button.tooltip_text = (
				unavailable_reason
			)

		VillageUIAccessibility.configure_button(
			choice_button,
			choice_button.tooltip_text,
			82.0
		)

		choice_button.pressed.connect(
			_on_event_choice_pressed.bind(
				choice_id
			)
		)

		event_choices_container.add_child(
			choice_button
		)


func _focus_event_controls(prefer_selector: bool = true) -> void:
	if not is_event_visible():
		return
	if prefer_selector and not event_villager_selector.disabled:
		VillageUIAccessibility.focus_deferred(
			event_villager_selector
		)
		return
	VillageUIAccessibility.focus_first_enabled(
		event_choices_container
	)


func _build_event_choice_text(
	choice: Dictionary,
	choice_state: Dictionary,
	villager: Villager
) -> String:
	var button_text: String = String(
		choice.get(
			"title",
			"Escolher"
		)
	)

	var description: String = String(
		choice.get(
			"description",
			""
		)
	)

	if not description.is_empty():
		button_text += (
			"\n"
			+ _wrap_event_choice_text(
				description
			)
		)

	if bool(choice_state.get("has_test", false)):
		var success_percent: int = int(
			round(
				float(choice_state["chance"])
				* 100.0
			)
		)

		var attribute_name: String = String(
			choice.get(
				"test_attribute",
				""
			)
		)

		if (
			not attribute_name.is_empty()
			and is_instance_valid(villager)
		):
			button_text += (
				"\nCHANCE: %d%% — %s %d de %s"
			) % [
				success_percent,
				_get_event_attribute_short_name(
					attribute_name
				),
				_get_event_attribute_value(
					villager,
					attribute_name
				),
				villager.villager_name
			]
		else:
			button_text += (
				"\nCHANCE DE SUCESSO: %d%%"
				% success_percent
			)

	var unavailable_reason: String = String(
		choice_state.get("reason", "")
	)

	if not unavailable_reason.is_empty():
		button_text += (
			"\nINDISPONÍVEL — "
			+ unavailable_reason
		)

	return button_text


func _wrap_event_choice_text(
	source_text: String,
	maximum_line_length: int = 68
) -> String:
	var words: PackedStringArray = (
		source_text.split(
			" ",
			false
		)
	)

	var wrapped_lines: Array[String] = []
	var current_line: String = ""

	for word: String in words:
		if current_line.is_empty():
			current_line = word
			continue

		var candidate_line: String = (
			current_line + " " + word
		)

		if candidate_line.length() <= maximum_line_length:
			current_line = candidate_line
			continue

		wrapped_lines.append(current_line)
		current_line = word

	if not current_line.is_empty():
		wrapped_lines.append(current_line)

	return "\n".join(wrapped_lines)


func _get_event_attribute_short_name(
	attribute_name: String
) -> String:
	match attribute_name:
		"strength":
			return "FOR"

		"intelligence":
			return "INT"

		"charisma":
			return "CAR"

		"agility":
			return "AGI"

		_:
			return "ATR"


func _get_event_attribute_value(
	villager: Villager,
	attribute_name: String
) -> int:
	match attribute_name:
		"strength":
			return villager.strength

		"intelligence":
			return villager.intelligence

		"charisma":
			return villager.charisma

		"agility":
			return villager.agility

		_:
			return 0


func _on_event_choice_pressed(
	choice_id: String
) -> void:
	var choice_buttons: Array[Node] = (
		event_choices_container.get_children()
	)

	for button_node: Node in choice_buttons:
		if button_node is Button:
			var button: Button = button_node as Button
			button.disabled = true

	var resolved: bool = (
		GameManager.resolve_event_choice(
			choice_id,
			_get_event_selected_villager()
		)
	)

	if not resolved:
		_rebuild_event_choice_buttons()



func _animate_event_open() -> void:
	if not is_instance_valid(event_panel):
		return

	event_panel.pivot_offset = (
		event_panel.size * 0.5
	)

	if GameSettings.reduced_motion:
		event_panel.modulate = Color.WHITE
		event_panel.scale = Vector2.ONE
		return

	event_panel.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.0
	)

	event_panel.scale = Vector2(
		0.94,
		0.94
	)

	var tween: Tween = create_tween()

	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		event_panel,
		"modulate",
		Color.WHITE,
		0.24
	)

	tween.tween_property(
		event_panel,
		"scale",
		Vector2.ONE,
		0.28
	)

