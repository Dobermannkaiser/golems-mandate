class_name VillageRelationshipsWindow
extends Control


signal conversation_requested(npc_id: String, include_unknown: bool)
signal personal_event_requested(npc_id: String, event_id: String)
signal date_requested(npc_id: String)
signal closed()


const CHARACTER_CATALOG_SCRIPT = preload("res://scripts/dialogue/CharacterCatalog.gd")
const RELATIONSHIP_CATALOG_SCRIPT = preload("res://scripts/relationships/RelationshipCatalog.gd")
const PIXEL_FONT: FontFile = preload("res://assets/dialogue/alagard.ttf")

var overlay: ColorRect
var list_container: VBoxContainer
var summary_label: Label
var current_overview: Dictionary = {}
var current_npc_map: Dictionary = {}
var current_day: int = 1
var current_test_mode: bool = false
var map_filter: String = "all"
var close_button: Button
var previous_focus: Control


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 720
	_create_window()


func show_relationships(
	overview: Dictionary,
	day_value: int,
	test_mode: bool = false,
	npc_map: Dictionary = {}
) -> void:
	previous_focus = VillageUIAccessibility.remember_focus(self)
	current_overview = overview.duplicate(true)
	current_day = day_value
	current_test_mode = test_mode
	current_npc_map = npc_map.duplicate(true)
	overlay.visible = true
	_rebuild()
	VillageUIAccessibility.focus_first_enabled(overlay, close_button)


func refresh(overview: Dictionary, day_value: int, npc_map: Dictionary = {}) -> void:
	current_overview = overview.duplicate(true)
	current_day = day_value
	if not npc_map.is_empty():
		current_npc_map = npc_map.duplicate(true)
	if is_window_visible():
		_rebuild()


func hide_window() -> void:
	if not is_window_visible():
		return
	overlay.visible = false
	VillageUIAccessibility.restore_focus_deferred(previous_focus)
	previous_focus = null
	closed.emit()


func is_window_visible() -> bool:
	return is_instance_valid(overlay) and overlay.visible


func _create_window() -> void:
	overlay = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.02, 0.02, 0.03, 0.82)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.visible = false
	add_child(overlay)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 110)
	margin.add_theme_constant_override("margin_top", 48)
	margin.add_theme_constant_override("margin_right", 110)
	margin.add_theme_constant_override("margin_bottom", 48)
	overlay.add_child(margin)

	var panel: PanelContainer = PanelContainer.new()
	panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(Color("#21182D"), Color("#D2A85B"), 3, 14, 22, 8)
	)
	margin.add_child(panel)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 10)
	panel.add_child(layout)

	var heading: HBoxContainer = HBoxContainer.new()
	layout.add_child(heading)

	var title: Label = Label.new()
	title.text = "RELAÇÕES DA VILA"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_override("font", PIXEL_FONT)
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color("#F1C86C"))
	heading.add_child(title)

	close_button = _make_button("FECHAR", 120.0)
	close_button.tooltip_text = "Fecha a tela de relações."
	close_button.pressed.connect(hide_window)
	heading.add_child(close_button)

	summary_label = Label.new()
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_label.add_theme_font_override("font", PIXEL_FONT)
	summary_label.add_theme_font_size_override("font_size", 14)
	summary_label.add_theme_color_override("font_color", Color("#D9C7F0"))
	layout.add_child(summary_label)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(scroll)

	list_container = VBoxContainer.new()
	list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_container.add_theme_constant_override("separation", 10)
	scroll.add_child(list_container)


func _rebuild() -> void:
	for child: Node in list_container.get_children():
		list_container.remove_child(child)
		child.queue_free()

	var partner_id: String = String(current_overview.get("official_partner_id", ""))
	var test_prefix: String = (
		"MODO DE TESTE • TODOS OS PERSONAGENS\n"
		+ "Conversas de teste geram pontos sem limite diário e não consomem a conversa normal do dia.\n"
		if current_test_mode
		else ""
	)
	summary_label.text = (
		test_prefix
		+ "Dia %d • Parceiro oficial: %s" % [
			current_day,
			String(current_overview.get("official_partner_name", "Nenhum"))
		]
		+ (
			"\nEncontros românticos possuem intervalo de sete dias."
			if current_test_mode
			else "\nConversas geram pontos apenas uma vez por personagem em cada dia. Encontros românticos possuem intervalo de sete dias."
		)
		+ " Cenas importantes são liberadas em 200, 400, 600 e 800 pontos. O romance exige duas demonstrações claras de interesse nas cenas de 400 e 600 e só pode começar na decisão de 800."
	)
	_add_npc_relationship_map()

	var entries_value: Variant = current_overview.get("entries", [])
	if not entries_value is Array or (entries_value as Array).is_empty():
		var empty_label: Label = Label.new()
		empty_label.text = "Nenhum vínculo pessoal foi apresentado pela história ainda."
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.add_theme_font_override("font", PIXEL_FONT)
		empty_label.add_theme_font_size_override("font_size", 16)
		list_container.add_child(empty_label)
		return

	for entry_value: Variant in entries_value:
		if entry_value is Dictionary:
			list_container.add_child(_create_relationship_card(entry_value as Dictionary, partner_id))


func _add_npc_relationship_map() -> void:
	if current_npc_map.is_empty():
		return
	var heading: Label = Label.new()
	heading.text = "MAPA DE AFINIDADES E CONFLITOS"
	heading.add_theme_font_override("font", PIXEL_FONT)
	heading.add_theme_font_size_override("font_size", 18)
	heading.add_theme_color_override("font_color", Color("#F1C86C"))
	list_container.add_child(heading)
	var filters: HBoxContainer = HBoxContainer.new()
	filters.add_theme_constant_override("separation", 6)
	for data: Dictionary in [
		{"id": "all", "label": "TODOS"},
		{"id": "positive", "label": "AFINIDADES"},
		{"id": "negative", "label": "CONFLITOS"}
	]:
		var button: Button = _make_button(String(data.get("label", "FILTRO")), 126.0)
		var filter_id: String = String(data.get("id", "all"))
		button.disabled = map_filter == filter_id
		button.pressed.connect(_on_map_filter_pressed.bind(filter_id))
		filters.add_child(button)
	list_container.add_child(filters)
	var shown: int = 0
	for value: Variant in current_npc_map.get("pairs", []) as Array:
		if not value is Dictionary:
			continue
		var pair: Dictionary = value as Dictionary
		var state_id: String = String(pair.get("state_id", "neutral"))
		if map_filter == "positive" and state_id not in ["affinity", "strong_bond"]:
			continue
		if map_filter == "negative" and state_id not in ["conflict", "tension"]:
			continue
		var line: Label = Label.new()
		line.text = "%s + %s — %s\n%s" % [
			String(pair.get("a_name", "NPC")),
			String(pair.get("b_name", "NPC")),
			String(pair.get("state_name", "Neutro")),
			String(pair.get("cause", "Ainda não compreendido."))
		]
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.add_theme_font_override("font", PIXEL_FONT)
		line.add_theme_font_size_override("font_size", 13)
		line.add_theme_color_override("font_color", _state_color(state_id))
		list_container.add_child(line)
		shown += 1
	if shown == 0:
		var empty: Label = Label.new()
		empty.text = "Nenhuma ligação corresponde a este filtro."
		empty.add_theme_font_override("font", PIXEL_FONT)
		empty.add_theme_font_size_override("font_size", 13)
		list_container.add_child(empty)
	var divider: HSeparator = HSeparator.new()
	list_container.add_child(divider)
	var personal_heading: Label = Label.new()
	personal_heading.text = "VÍNCULOS COM O PREFEITO"
	personal_heading.add_theme_font_override("font", PIXEL_FONT)
	personal_heading.add_theme_font_size_override("font_size", 18)
	personal_heading.add_theme_color_override("font_color", Color("#F1C86C"))
	list_container.add_child(personal_heading)


func _on_map_filter_pressed(filter_id: String) -> void:
	map_filter = filter_id
	_rebuild()


func _state_color(state_id: String) -> Color:
	match state_id:
		"conflict": return Color("#E78284")
		"tension": return Color("#E5B567")
		"affinity": return Color("#A7C080")
		"strong_bond": return Color("#7FBBB3")
		_: return Color("#D5C9B5")


func _create_relationship_card(entry: Dictionary, partner_id: String) -> PanelContainer:
	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = Vector2(0.0, 156.0)
	card.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(Color("#151B26"), Color("#8F73B8"), 2, 10, 14, 3)
	)

	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	card.add_child(row)

	var portrait: TextureRect = TextureRect.new()
	portrait.custom_minimum_size = Vector2(128.0, 128.0)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture = CHARACTER_CATALOG_SCRIPT.get_portrait_texture(String(entry.get("portrait_id", "")))
	row.add_child(portrait)

	var info: VBoxContainer = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 4)
	row.add_child(info)

	var name_label: Label = Label.new()
	name_label.text = String(entry.get("display_name", "Personagem")).to_upper()
	name_label.add_theme_font_override("font", PIXEL_FONT)
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.add_theme_color_override("font_color", Color("#F1C86C"))
	info.add_child(name_label)

	var level: int = int(entry.get("relationship_level", 0))
	var kind: String = String(entry.get("relationship_kind", "friendship"))
	var status: Label = Label.new()
	status.text = "Nível %d — %s — %d/1000 pontos" % [level, RELATIONSHIP_CATALOG_SCRIPT.get_relationship_title(level, kind), int(entry.get("relationship_points", 0))]
	status.add_theme_font_override("font", PIXEL_FONT)
	status.add_theme_font_size_override("font_size", 14)
	status.add_theme_color_override("font_color", Color("#F2E8D2"))
	info.add_child(status)

	var bonus: Label = Label.new()
	bonus.text = String(entry.get("bonus_description", ""))
	bonus.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bonus.add_theme_font_override("font", PIXEL_FONT)
	bonus.add_theme_font_size_override("font_size", 13)
	bonus.add_theme_color_override("font_color", Color("#BCA8CF"))
	info.add_child(bonus)

	if bool(entry.get("romance_available", false)):
		var romance_status: Label = Label.new()
		var interest_count: int = mini(
			2,
			(entry.get("romance_interest_markers", []) as Array).size()
		)
		if bool(entry.get("romance_declined", false)):
			romance_status.text = "Rota íntima encerrada; amizade preservada."
		else:
			romance_status.text = "Interesse demonstrado: %d/2 escolhas." % interest_count
		romance_status.add_theme_font_override("font", PIXEL_FONT)
		romance_status.add_theme_font_size_override("font_size", 12)
		romance_status.add_theme_color_override("font_color", Color("#D9A9C6"))
		info.add_child(romance_status)

	var next_event: String = String(entry.get("next_personal_event_id", ""))
	var next_threshold: int = int(entry.get("next_personal_event_threshold", 0))
	var next_stage: String = String(entry.get("next_personal_event_stage", "Cena importante"))
	var event_label: Label = Label.new()
	event_label.text = (
		"Cena de %s disponível." % next_stage
		if not next_event.is_empty()
		else (
			"Próxima cena: %s em %d pontos." % [next_stage, next_threshold]
			if next_threshold > 0
			else "Todos os marcos deste vínculo foram vividos."
		)
	)
	event_label.add_theme_font_override("font", PIXEL_FONT)
	event_label.add_theme_font_size_override("font_size", 12)
	event_label.add_theme_color_override("font_color", Color("#9FD18B") if not next_event.is_empty() else Color("#91899B"))
	info.add_child(event_label)

	var actions: VBoxContainer = VBoxContainer.new()
	actions.custom_minimum_size = Vector2(178.0, 0.0)
	actions.add_theme_constant_override("separation", 6)
	row.add_child(actions)

	var npc_id: String = String(entry.get("npc_id", ""))
	var talk_button: Button = _make_button("CONVERSAR", 174.0)
	talk_button.tooltip_text = (
		"No Teste Interno, toda conversa pode alterar a relação."
		if current_test_mode
		else "A primeira conversa do dia pode alterar a relação."
	)
	talk_button.pressed.connect(_on_conversation_pressed.bind(npc_id))
	actions.add_child(talk_button)

	var event_button: Button = _make_button("CENA IMPORTANTE", 174.0)
	event_button.disabled = next_event.is_empty()
	event_button.tooltip_text = (
		"Disponível nos marcos de 200, 400, 600 e 800 pontos."
	)
	event_button.pressed.connect(_on_event_pressed.bind(npc_id, next_event))
	actions.add_child(event_button)

	var date_button: Button = _make_button("ENCONTRO", 174.0)
	date_button.visible = npc_id == partner_id
	date_button.disabled = not bool(entry.get("can_date_today", false))
	date_button.tooltip_text = "Disponível a cada sete dias para o parceiro oficial."
	date_button.pressed.connect(_on_date_pressed.bind(npc_id))
	actions.add_child(date_button)
	return card


func _unhandled_input(event: InputEvent) -> void:
	if not is_window_visible():
		return
	if event.is_action_pressed("ui_cancel"):
		hide_window()
		get_viewport().set_input_as_handled()


func _make_button(text_value: String, width: float) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(width, 36.0)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", PIXEL_FONT)
	button.add_theme_font_size_override("font_size", 12)
	VillageUIAccessibility.configure_button(button, "", 40.0)
	return button


func _on_conversation_pressed(npc_id: String) -> void:
	hide_window()
	conversation_requested.emit(npc_id, current_test_mode)


func _on_event_pressed(npc_id: String, event_id: String) -> void:
	if event_id.is_empty():
		return
	hide_window()
	personal_event_requested.emit(npc_id, event_id)


func _on_date_pressed(npc_id: String) -> void:
	hide_window()
	date_requested.emit(npc_id)
