class_name RecruitmentWindow
extends Control


signal species_selected(species_name: String)
signal candidate_selected(candidate_id: String)


const CHARACTER_CATALOG_SCRIPT = preload(
	"res://scripts/dialogue/CharacterCatalog.gd"
)


var overlay: ColorRect
var title_label: Label
var description_label: Label
var species_choices: VBoxContainer
var candidates_row: GridContainer
var instruction_label: Label
var offer_scroll: ScrollContainer
var current_offer: Dictionary = {}
var previous_focus: Control


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 155
	z_as_relative = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_create_window()
	resized.connect(_apply_responsive_layout)


func show_offer(offer: Dictionary) -> void:
	if offer.is_empty():
		return
	if not is_window_visible():
		previous_focus = VillageUIAccessibility.remember_focus(self)
	current_offer = offer.duplicate(true)
	_rebuild_offer()
	_apply_responsive_layout()
	overlay.visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	move_to_front()
	call_deferred("_focus_first_action")


func hide_window() -> void:
	if not is_window_visible():
		return
	overlay.visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	VillageUIAccessibility.restore_focus_deferred(previous_focus)
	previous_focus = null
	current_offer.clear()


func is_window_visible() -> bool:
	return is_instance_valid(overlay) and overlay.visible


func _create_window() -> void:
	overlay = ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.0, 0.76)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.visible = false
	add_child(overlay)

	var safe_margin: MarginContainer = MarginContainer.new()
	safe_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe_margin.add_theme_constant_override("margin_left", 18)
	safe_margin.add_theme_constant_override("margin_top", 18)
	safe_margin.add_theme_constant_override("margin_right", 18)
	safe_margin.add_theme_constant_override("margin_bottom", 18)
	safe_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(safe_margin)

	var panel: PanelContainer = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size = Vector2.ZERO
	panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			MedievalTheme.WOOD_DARK,
			MedievalTheme.GOLD,
			3,
			12,
			18,
			4
		)
	)
	safe_margin.add_child(panel)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 10)
	panel.add_child(layout)

	title_label = _create_clear_label(
		"NOVAS CARTAS PARA O CONSELHO",
		MedievalTheme.GOLD,
		25
	)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(title_label)

	description_label = _create_clear_label(
		"",
		MedievalTheme.PARCHMENT_LIGHT,
		15
	)
	description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(description_label)

	offer_scroll = ScrollContainer.new()
	offer_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	offer_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	offer_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	layout.add_child(offer_scroll)

	var offer_content: VBoxContainer = VBoxContainer.new()
	offer_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	offer_content.add_theme_constant_override("separation", 12)
	offer_scroll.add_child(offer_content)

	species_choices = VBoxContainer.new()
	species_choices.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	species_choices.add_theme_constant_override("separation", 12)
	offer_content.add_child(species_choices)

	candidates_row = GridContainer.new()
	candidates_row.columns = 2
	candidates_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	candidates_row.add_theme_constant_override("h_separation", 18)
	candidates_row.add_theme_constant_override("v_separation", 18)
	offer_content.add_child(candidates_row)

	instruction_label = _create_clear_label(
		"Escolha uma carta. A outra seguirá seu próprio caminho.",
		MedievalTheme.TEXT_MUTED,
		13
	)
	instruction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(instruction_label)


func _rebuild_offer() -> void:
	_clear_container(species_choices)
	_clear_container(candidates_row)
	var phase: String = String(current_offer.get("phase", "candidate_choice"))
	if phase == "species_choice":
		_rebuild_species_choices()
	else:
		_rebuild_candidates()


func _rebuild_species_choices() -> void:
	title_label.text = "ESCOLHA A ESPÉCIE"
	species_choices.visible = true
	candidates_row.visible = false
	instruction_label.text = (
		"A escolha define a espécie das duas cartas. Depois você comparará as candidatas."
	)
	var checkpoint_day: int = int(current_offer.get("checkpoint_day", 0))
	var top_points: int = int(current_offer.get("relationship_points", 0))
	description_label.text = (
		"Na escolha do Dia %d, dois ou mais vínculos empataram como os mais "
		+ "fortes, com %d pontos."
	) % [checkpoint_day, top_points]
	var options_value: Variant = current_offer.get("species_options", [])
	if not options_value is Array:
		return
	for option_value: Variant in options_value as Array:
		if not option_value is Dictionary:
			continue
		var option: Dictionary = option_value as Dictionary
		var species_name: String = String(option.get("species_name", ""))
		if species_name.is_empty():
			continue
		var button: Button = Button.new()
		button.text = "%s\nVínculo: %s • %d pontos" % [
			species_name.to_upper(),
			String(option.get("display_name", "Personagem")),
			int(option.get("relationship_points", 0))
		]
		button.custom_minimum_size = Vector2(0.0, 62.0)
		button.tooltip_text = (
			"Gera duas cartas da espécie %s ligadas a este vínculo."
			% species_name
		)
		button.pressed.connect(_on_species_pressed.bind(species_name))
		button.name = "SpeciesChoice_%02d" % species_choices.get_child_count()
		species_choices.add_child(button)
	call_deferred("_configure_focus_loop")


func _rebuild_candidates() -> void:
	title_label.text = "NOVAS CARTAS PARA O CONSELHO"
	species_choices.visible = false
	candidates_row.visible = true
	instruction_label.text = "Escolha uma carta. A outra seguirá seu próprio caminho."
	var source_name: String = String(
		current_offer.get("source_name", "um vínculo da vila")
	)
	var species_name: String = String(
		current_offer.get("species_name", "")
	)
	var checkpoint_day: int = int(current_offer.get("checkpoint_day", 0))
	var relationship_points: int = int(
		current_offer.get("relationship_points", 0)
	)
	description_label.text = (
		"Escolha do Dia %d: seu vínculo com %s (%d pontos) atraiu "
		+ "duas cartas da espécie %s."
	) % [
		checkpoint_day,
		source_name,
		relationship_points,
		species_name
	]

	var candidates_value: Variant = current_offer.get("candidates", [])
	if not candidates_value is Array:
		return
	for candidate_value: Variant in candidates_value as Array:
		if candidate_value is Dictionary:
			candidates_row.add_child(
				_create_candidate_card(candidate_value as Dictionary)
			)
	call_deferred("_configure_focus_loop")


func _create_candidate_card(candidate: Dictionary) -> PanelContainer:
	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = Vector2(300.0, 410.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			MedievalTheme.PARCHMENT,
			MedievalTheme.GOLD_DARK,
			2,
			8,
			12,
			0
		)
	)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 7)
	card.add_child(layout)

	var portrait_frame: PanelContainer = PanelContainer.new()
	portrait_frame.custom_minimum_size = Vector2(0.0, 205.0)
	portrait_frame.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			MedievalTheme.WOOD,
			MedievalTheme.GOLD_DARK,
			2,
			6,
			4,
			0
		)
	)
	layout.add_child(portrait_frame)

	var portrait: TextureRect = TextureRect.new()
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture = CHARACTER_CATALOG_SCRIPT.get_portrait_texture(
		String(candidate.get("portrait_id", ""))
	)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_frame.add_child(portrait)

	var name_label: Label = _create_clear_label(
		String(candidate.get("name", "Nova carta")),
		MedievalTheme.INK,
		22
	)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(name_label)

	var info_label: Label = _create_clear_label(
		"%s • NÍVEL %d • XP %d / %d" % [
			String(candidate.get("species_name", "")),
			int(candidate.get("level", 1)),
			int(candidate.get("xp", 0)),
			80 + 20 * maxi(0, int(candidate.get("level", 1)) - 1)
		],
		MedievalTheme.INK,
		14
	)
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(info_label)

	var attributes: Label = _create_clear_label(
		"FOR %d   •   INT %d   •   CAR %d   •   AGI %d" % [
			int(candidate.get("strength", 0)),
			int(candidate.get("intelligence", 0)),
			int(candidate.get("charisma", 0)),
			int(candidate.get("agility", 0))
		],
		MedievalTheme.INK,
		15
	)
	attributes.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(attributes)

	var passive: Label = _create_clear_label(
		"PASSIVA • %s\n%s\nCondição: %s" % [
			String(candidate.get("passive_name", "Sem passiva")),
			String(candidate.get("passive_description", "")),
			String(candidate.get("passive_condition", "Consulte a carta depois do recrutamento."))
		],
		MedievalTheme.INK,
		14
	)
	passive.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	passive.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	passive.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(passive)

	var choose_button: Button = Button.new()
	choose_button.text = "ESCOLHER ESTA CARTA"
	choose_button.custom_minimum_size = Vector2(0.0, 44.0)
	choose_button.tooltip_text = (
		"Adiciona esta carta à reserva do Conselho."
	)
	choose_button.pressed.connect(
		_on_candidate_pressed.bind(
			String(candidate.get("representative_id", ""))
		)
	)
	choose_button.name = "Choose_%s" % String(candidate.get("representative_id", "card"))
	layout.add_child(choose_button)
	return card


func _on_species_pressed(species_name: String) -> void:
	if species_name.is_empty():
		return
	species_selected.emit(species_name)


func _on_candidate_pressed(candidate_id: String) -> void:
	if candidate_id.is_empty():
		return
	candidate_selected.emit(candidate_id)


func _focus_first_action() -> void:
	var containers: Array[Control] = [species_choices, candidates_row]
	for container: Control in containers:
		if not is_instance_valid(container) or not container.visible:
			continue
		for child: Node in container.find_children("*", "Button", true, false):
			if child is Button:
				(child as Button).grab_focus()
				return


func _configure_focus_loop() -> void:
	var buttons: Array[Button] = []
	for container: Control in [species_choices, candidates_row]:
		if not is_instance_valid(container) or not container.visible:
			continue
		for child: Node in container.find_children("*", "Button", true, false):
			if child is Button and not (child as Button).disabled:
				buttons.append(child as Button)
	if buttons.is_empty():
		return
	for index: int in range(buttons.size()):
		var button: Button = buttons[index]
		var previous: Button = buttons[(index - 1 + buttons.size()) % buttons.size()]
		var next: Button = buttons[(index + 1) % buttons.size()]
		button.focus_previous = button.get_path_to(previous)
		button.focus_next = button.get_path_to(next)
		button.focus_entered.connect(_ensure_button_visible.bind(button))
	buttons[0].focus_neighbor_top = buttons[0].get_path_to(buttons.back())
	buttons.back().focus_neighbor_bottom = buttons.back().get_path_to(buttons[0])


func _ensure_button_visible(button: Button) -> void:
	if not is_instance_valid(offer_scroll) or not is_instance_valid(button):
		return
	offer_scroll.ensure_control_visible(button)


func _apply_responsive_layout() -> void:
	if not is_instance_valid(candidates_row):
		return
	var available_width: float = size.x
	candidates_row.columns = 1 if available_width < 780.0 else 2


func _unhandled_input(event: InputEvent) -> void:
	if not is_window_visible():
		return
	if event.is_action_pressed("ui_cancel"):
		# A oferta é uma decisão obrigatória e persistente. Cancelar não pode
		# deixar um bloqueio invisível nem fechar a janela sem resolver a vaga.
		_focus_first_action()
		get_viewport().set_input_as_handled()


static func _clear_container(container: Node) -> void:
	if not is_instance_valid(container):
		return
	for child: Node in container.get_children():
		container.remove_child(child)
		child.queue_free()


static func _create_clear_label(
	text_value: String,
	color_value: Color,
	font_size: int
) -> Label:
	var label: Label = MedievalTheme.create_label(
		text_value,
		color_value,
		font_size
	)
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	label.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 0)
	label.add_theme_constant_override("shadow_outline_size", 0)
	label.add_theme_constant_override("outline_size", 0)
	return label
