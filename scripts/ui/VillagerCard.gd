class_name VillagerCard
extends PanelContainer


signal selection_requested(
	card: PanelContainer,
	villager: Villager,
	show_message: bool
)
signal profession_requested(villager: Villager, profession: int)
signal attribute_point_requested(villager: Villager, attribute_id: String)
signal history_requested(villager: Villager)


const CHARACTER_CATALOG_SCRIPT = preload(
	"res://scripts/dialogue/CharacterCatalog.gd"
)


var villager: Villager
var _selection_marker: Label
var _attribute_badge: PanelContainer
var _attribute_badge_label: Label
var _dialogue_badge: PanelContainer
var _dialogue_badge_label: Label
var _name_label: Label
var _portrait: TextureRect
var _xp_bar: ProgressBar
var _xp_label: Label
var _passive_name_label: Label
var _passive_description_label: Label
var _passive_state_label: Label
var _details_button: Button
var _profession_selector: OptionButton
var _updating_profession: bool = false
var _details_panel: PanelContainer
var _details_text: RichTextLabel
var _attribute_point_status: Label
var _attribute_point_buttons: Dictionary = {}
var _history_button: Button
var _attribute_labels: Dictionary = {}
var _active_tween: Tween
var _is_selected: bool = false
var _is_built: bool = false
var _is_expanded: bool = false


func setup(target_villager: Villager) -> void:
	if not is_instance_valid(target_villager):
		return
	villager = target_villager
	if not _is_built:
		_build_interface()
		_is_built = true
	_refresh_all()
	set_selected(false, false)


func set_selected(value: bool, _animate: bool = true) -> void:
	_is_selected = value
	_set_card_style(value)
	if is_instance_valid(_selection_marker):
		_selection_marker.visible = value
	if is_instance_valid(villager):
		tooltip_text = _build_card_tooltip(value)
	# Não escala a carta: escala fracionária deixa a fonte borrada.
	scale = Vector2.ONE


func animate_entrance(card_index: int) -> void:
	pivot_offset = size * 0.5
	var target_scale: Vector2 = Vector2.ONE
	if GameSettings.reduced_motion:
		modulate = Color.WHITE
		scale = target_scale
		return
	modulate = Color(1.0, 1.0, 1.0, 0.0)
	scale = Vector2.ONE
	var delay: float = minf(float(card_index) * 0.04, 0.20)
	_kill_active_tween()
	_active_tween = create_tween()
	_active_tween.set_parallel(true)
	_active_tween.set_trans(Tween.TRANS_QUAD)
	_active_tween.set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(
		self,
		"modulate",
		Color.WHITE,
		0.22
	).set_delay(delay)


func refresh_production_preview() -> void:
	# Mantido como contrato da interface; a carta não mostra produção.
	_refresh_all()


func _build_interface() -> void:
	custom_minimum_size = Vector2(290.0, 264.0)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	focus_entered.connect(_on_focus_entered)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	add_child(margin)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 5)
	margin.add_child(layout)

	var header: HBoxContainer = HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	layout.add_child(header)

	var portrait_frame: PanelContainer = PanelContainer.new()
	portrait_frame.custom_minimum_size = Vector2(82.0, 82.0)
	portrait_frame.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			MedievalTheme.WOOD,
			MedievalTheme.GOLD_DARK,
			2,
			6,
			3,
			0
		)
	)
	header.add_child(portrait_frame)

	_portrait = TextureRect.new()
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_frame.add_child(_portrait)

	var identity: VBoxContainer = VBoxContainer.new()
	identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity.add_theme_constant_override("separation", 3)
	header.add_child(identity)

	var name_row: HBoxContainer = HBoxContainer.new()
	identity.add_child(name_row)
	_name_label = MedievalTheme.create_label("", MedievalTheme.INK, 19)
	_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_row.add_child(_name_label)
	_selection_marker = MedievalTheme.create_label(
		"ATIVO",
		MedievalTheme.GOLD_DARK,
		11
	)
	_selection_marker.visible = false
	name_row.add_child(_selection_marker)

	_xp_bar = ProgressBar.new()
	_xp_bar.custom_minimum_size = Vector2(0.0, 16.0)
	_xp_bar.show_percentage = false
	_xp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	identity.add_child(_xp_bar)
	_xp_label = MedievalTheme.create_label(
		"",
		MedievalTheme.INK,
		14
	)
	identity.add_child(_xp_label)

	var status_column: VBoxContainer = VBoxContainer.new()
	status_column.custom_minimum_size = Vector2(34.0, 0.0)
	status_column.alignment = BoxContainer.ALIGNMENT_BEGIN
	status_column.add_theme_constant_override("separation", 5)
	header.add_child(status_column)

	_attribute_badge = _create_status_badge(
		Color("#8E2F2F"),
		Color("#F3C46A"),
		"Pontos de atributo disponíveis"
	)
	_attribute_badge_label = _attribute_badge.get_child(0) as Label
	_attribute_badge.visible = false
	status_column.add_child(_attribute_badge)

	_dialogue_badge = _create_status_badge(
		Color("#C88A24"),
		Color("#FFF0B0"),
		"Assunto importante disponível"
	)
	_dialogue_badge_label = _dialogue_badge.get_child(0) as Label
	_dialogue_badge_label.text = "!"
	_dialogue_badge.visible = false
	status_column.add_child(_dialogue_badge)

	var attributes: HBoxContainer = HBoxContainer.new()
	attributes.add_theme_constant_override("separation", 4)
	layout.add_child(attributes)
	for attribute_id: String in [
		"strength",
		"intelligence",
		"charisma",
		"agility"
	]:
		attributes.add_child(_create_attribute_badge(attribute_id))

	var passive_panel: PanelContainer = PanelContainer.new()
	passive_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	passive_panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			MedievalTheme.PARCHMENT_LIGHT,
			MedievalTheme.PARCHMENT_DARK,
			1,
			5,
			5,
			0
		)
	)
	layout.add_child(passive_panel)
	var passive_layout: VBoxContainer = VBoxContainer.new()
	passive_layout.add_theme_constant_override("separation", 1)
	passive_panel.add_child(passive_layout)
	_passive_name_label = MedievalTheme.create_label(
		"",
		MedievalTheme.INK,
		14
	)
	passive_layout.add_child(_passive_name_label)
	_passive_description_label = MedievalTheme.create_label(
		"",
		MedievalTheme.INK,
		12
	)
	_passive_description_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)
	_passive_description_label.max_lines_visible = 3
	_passive_description_label.text_overrun_behavior = (
		TextServer.OVERRUN_TRIM_ELLIPSIS
	)
	passive_layout.add_child(_passive_description_label)
	_passive_state_label = MedievalTheme.create_label(
		"",
		MedievalTheme.TEXT_MUTED,
		11
	)
	_passive_state_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	passive_layout.add_child(_passive_state_label)

	var profession_row: HBoxContainer = HBoxContainer.new()
	profession_row.add_theme_constant_override("separation", 8)
	layout.add_child(profession_row)
	var profession_label: Label = MedievalTheme.create_label(
		"PROFISSÃO",
		MedievalTheme.INK,
		13
	)
	profession_label.custom_minimum_size = Vector2(76.0, 0.0)
	profession_row.add_child(profession_label)
	_profession_selector = OptionButton.new()
	_profession_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_profession_selector.custom_minimum_size = Vector2(0.0, 34.0)
	_profession_selector.tooltip_text = (
		"Escolha o trabalho desta carta para definir o recurso produzido."
	)
	for profession: int in Villager.get_all_professions():
		_profession_selector.add_item(
			Villager.get_profession_name(profession),
			profession
		)
	_profession_selector.item_selected.connect(_on_profession_selected)
	profession_row.add_child(_profession_selector)

	_details_button = Button.new()
	_details_button.text = "EXPANDIR CARTA"
	_details_button.custom_minimum_size = Vector2(0.0, 30.0)
	_details_button.tooltip_text = (
		"Amplia os mesmos atributos, XP e detalhes da passiva."
	)
	_details_button.pressed.connect(_toggle_details)
	layout.add_child(_details_button)

	_details_panel = PanelContainer.new()
	_details_panel.visible = false
	_details_panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			Color(0.13, 0.08, 0.05, 0.94),
			MedievalTheme.GOLD_DARK,
			1,
			5,
			6,
			0
		)
	)
	layout.add_child(_details_panel)
	var details_layout: VBoxContainer = VBoxContainer.new()
	details_layout.add_theme_constant_override("separation", 6)
	_details_panel.add_child(details_layout)

	_details_text = RichTextLabel.new()
	_details_text.bbcode_enabled = true
	_details_text.fit_content = true
	_details_text.custom_minimum_size = Vector2(0.0, 86.0)
	_details_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	details_layout.add_child(_details_text)

	_attribute_point_status = MedievalTheme.create_label(
		"",
		MedievalTheme.GOLD_DARK,
		13
	)
	_attribute_point_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	details_layout.add_child(_attribute_point_status)

	var point_row: HBoxContainer = HBoxContainer.new()
	point_row.add_theme_constant_override("separation", 4)
	details_layout.add_child(point_row)
	for point_data: Dictionary in [
		{"id": "strength", "label": "+ FOR"},
		{"id": "intelligence", "label": "+ INT"},
		{"id": "charisma", "label": "+ CAR"},
		{"id": "agility", "label": "+ AGI"}
	]:
		var point_button: Button = Button.new()
		point_button.text = String(point_data.get("label", "+"))
		point_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		point_button.custom_minimum_size = Vector2(0.0, 32.0)
		point_button.tooltip_text = "Gasta 1 ponto para aprimorar este atributo, até o limite 8."
		var attribute_id: String = String(point_data.get("id", ""))
		point_button.pressed.connect(
			_on_attribute_point_pressed.bind(attribute_id)
		)
		point_row.add_child(point_button)
		_attribute_point_buttons[attribute_id] = point_button

	_history_button = Button.new()
	_history_button.text = "ABRIR FICHA HISTÓRICA"
	_history_button.custom_minimum_size = Vector2(0.0, 32.0)
	_history_button.tooltip_text = (
		"Mostra produção acumulada, profissões, acontecimentos e conquistas desta carta."
	)
	_history_button.pressed.connect(_on_history_pressed)
	details_layout.add_child(_history_button)
	_remove_card_text_shadows()


func _remove_card_text_shadows() -> void:
	for node: Node in find_children("*", "Label", true, false):
		if not node is Label:
			continue
		var label: Label = node as Label
		label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
		label.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		label.add_theme_constant_override("shadow_offset_x", 0)
		label.add_theme_constant_override("shadow_offset_y", 0)
		label.add_theme_constant_override("shadow_outline_size", 0)
		label.add_theme_constant_override("outline_size", 0)

	if is_instance_valid(_details_text):
		_details_text.add_theme_color_override(
			"font_shadow_color",
			Color.TRANSPARENT
		)
		_details_text.add_theme_color_override(
			"font_outline_color",
			Color.TRANSPARENT
		)
		_details_text.add_theme_constant_override("shadow_offset_x", 0)
		_details_text.add_theme_constant_override("shadow_offset_y", 0)
		_details_text.add_theme_constant_override("shadow_outline_size", 0)
		_details_text.add_theme_constant_override("outline_size", 0)



func _create_status_badge(
	background: Color,
	border: Color,
	tooltip: String
) -> PanelContainer:
	var badge: PanelContainer = PanelContainer.new()
	badge.custom_minimum_size = Vector2(30.0, 24.0)
	badge.mouse_filter = Control.MOUSE_FILTER_PASS
	badge.tooltip_text = tooltip
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(2)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	badge.add_theme_stylebox_override("panel", style)
	var label: Label = MedievalTheme.create_label("", Color.WHITE, 12)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_child(label)
	return badge


func _create_attribute_badge(attribute_id: String) -> PanelContainer:
	var badge: PanelContainer = PanelContainer.new()
	badge.custom_minimum_size = Vector2(54.0, 30.0)
	badge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	badge.mouse_filter = Control.MOUSE_FILTER_PASS
	badge.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			MedievalTheme.PARCHMENT_LIGHT,
			MedievalTheme.PARCHMENT_DARK,
			1,
			5,
			3,
			0
		)
	)
	var label: Label = MedievalTheme.create_label(
		"",
		MedievalTheme.INK,
		13
	)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_child(label)
	_attribute_labels[attribute_id] = label
	return badge


func _refresh_all() -> void:
	if not is_instance_valid(villager):
		return
	_name_label.text = villager.villager_name
	_portrait.texture = CHARACTER_CATALOG_SCRIPT.get_portrait_texture(
		villager.portrait_id
	)
	if villager.is_max_level():
		_xp_bar.max_value = 1.0
		_xp_bar.value = 1.0
		_xp_label.text = "NÍVEL %d • MÁXIMO" % villager.level
	else:
		_xp_bar.max_value = float(villager.get_xp_required())
		_xp_bar.value = float(villager.xp)
		_xp_label.text = "NÍVEL %d • XP %d / %d" % [
			villager.level,
			villager.xp,
			villager.get_xp_required()
		]
	_set_attribute("strength", "FOR", villager.strength, "Força")
	_set_attribute(
		"intelligence",
		"INT",
		villager.intelligence,
		"Inteligência"
	)
	_set_attribute("charisma", "CAR", villager.charisma, "Carisma")
	_set_attribute("agility", "AGI", villager.agility, "Agilidade")
	_passive_name_label.text = "PASSIVA • %s" % villager.passive_name
	_passive_description_label.text = villager.passive_description
	var passive_overview: Dictionary = GameManager.get_villager_passive_overview(villager)
	var passive_state: String = String(passive_overview.get("state", "inactive"))
	var state_prefix: String = "INATIVA"
	var state_color: Color = MedievalTheme.TEXT_MUTED
	if passive_state == "active":
		state_prefix = "ATIVA"
		state_color = Color("#3E7A42")
	elif passive_state == "conditional":
		state_prefix = "CONDICIONAL"
		state_color = Color("#A26916")
	_passive_state_label.text = "%s • %s" % [
		state_prefix,
		String(passive_overview.get("status_text", ""))
	]
	_passive_state_label.add_theme_color_override("font_color", state_color)
	_passive_state_label.tooltip_text = String(
		passive_overview.get("condition", villager.passive_description)
	)
	_refresh_profession_selector()
	_refresh_details()
	_refresh_attribute_point_controls()
	_refresh_status_indicators()
	tooltip_text = _build_card_tooltip(_is_selected)


func _set_attribute(
	attribute_id: String,
	short_name: String,
	value: int,
	full_name: String
) -> void:
	var label: Label = _attribute_labels.get(attribute_id, null) as Label
	if not is_instance_valid(label):
		return
	label.text = "%s %d" % [short_name, value]
	var badge: Control = label.get_parent() as Control
	if is_instance_valid(badge):
		badge.tooltip_text = "%s: %d" % [full_name, value]


func _refresh_details() -> void:
	if not is_instance_valid(_details_text) or not is_instance_valid(villager):
		return
	var xp_text: String = (
		"Nível %d • máximo alcançado • %d XP vitalício"
		% [villager.level, villager.lifetime_xp]
		if villager.is_max_level()
		else "Nível %d • %d de %d XP • %d XP vitalício" % [
			villager.level,
			villager.xp,
			villager.get_xp_required(),
			villager.lifetime_xp
		]
	)
	_details_text.text = (
		"[color=#D9B75B][b]ATRIBUTOS[/b][/color]\n"
		+ "Força %d • Inteligência %d • Carisma %d • Agilidade %d\n\n"
		+ "[color=#D9B75B][b]EXPERIÊNCIA[/b][/color]\n"
		+ xp_text
		+ "\n\n[color=#D9B75B][b]PASSIVA • %s[/b][/color]\n%s\n%s"
	) % [
		villager.strength,
		villager.intelligence,
		villager.charisma,
		villager.agility,
		villager.passive_name,
		villager.passive_description,
		_passive_state_label.text
	]


func _refresh_status_indicators() -> void:
	if not is_instance_valid(villager):
		return
	var points: int = villager.unspent_attribute_points
	if is_instance_valid(_attribute_badge) and is_instance_valid(_attribute_badge_label):
		_attribute_badge.visible = points > 0
		_attribute_badge_label.text = "+%d" % points
		_attribute_badge.tooltip_text = (
			"%d ponto(s) de atributo disponível(is). Expanda a carta para distribuir."
			% points
		)
	var has_dialogue: bool = GameManager.has_councillor_opportunity(
		villager.representative_id
	)
	if is_instance_valid(_dialogue_badge):
		_dialogue_badge.visible = has_dialogue
		if has_dialogue:
			var opportunity: Dictionary = GameManager.get_councillor_opportunity(
				villager.representative_id
			)
			_dialogue_badge.tooltip_text = (
				"Assunto com consequência disponível: %s. Selecione a carta e clique novamente."
				% String(opportunity.get("title", "Assunto do Conselho"))
			)


func _refresh_attribute_point_controls() -> void:
	if not is_instance_valid(villager) or not is_instance_valid(_attribute_point_status):
		return
	var points: int = villager.unspent_attribute_points
	_attribute_point_status.visible = points > 0
	_attribute_point_status.text = (
		"%d PONTO(S) DE ATRIBUTO DISPONÍVEL(IS)" % points
	)
	for attribute_id_value: Variant in _attribute_point_buttons.keys():
		var attribute_id: String = String(attribute_id_value)
		var button: Button = _attribute_point_buttons[attribute_id] as Button
		if not is_instance_valid(button):
			continue
		button.visible = points > 0
		button.disabled = (
			points <= 0
			or villager.get_attribute_value(attribute_id) >= Villager.MAX_ATTRIBUTE_VALUE
		)


func _refresh_profession_selector() -> void:
	if not is_instance_valid(_profession_selector) or not is_instance_valid(villager):
		return
	_updating_profession = true
	var index: int = _profession_selector.get_item_index(
		villager.current_profession
	)
	if index >= 0:
		_profession_selector.select(index)
	_profession_selector.disabled = not villager.is_council_active
	_updating_profession = false


func _on_profession_selected(selected_index: int) -> void:
	if _updating_profession or not is_instance_valid(villager):
		return
	var profession: int = _profession_selector.get_item_id(selected_index)
	profession_requested.emit(villager, profession)


func _toggle_details() -> void:
	_is_expanded = not _is_expanded
	_details_panel.visible = _is_expanded
	_details_button.text = (
		"RECOLHER CARTA" if _is_expanded else "EXPANDIR CARTA"
	)
	_refresh_details()


func _on_attribute_point_pressed(attribute_id: String) -> void:
	if is_instance_valid(villager):
		attribute_point_requested.emit(villager, attribute_id)


func _on_history_pressed() -> void:
	if is_instance_valid(villager):
		history_requested.emit(villager)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = (
			event as InputEventMouseButton
		)
		if (
			mouse_event.button_index == MOUSE_BUTTON_LEFT
			and mouse_event.pressed
		):
			_request_selection(true)
			accept_event()
	elif event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if (
			key_event.pressed
			and not key_event.echo
			and key_event.keycode in [KEY_ENTER, KEY_SPACE]
		):
			_request_selection(true)
			accept_event()


func _on_mouse_entered() -> void:
	# Realce apenas pelo estilo; escala fracionária borra o texto.
	_set_card_style(true)


func _on_mouse_exited() -> void:
	_set_card_style(_is_selected)


func _on_focus_entered() -> void:
	_request_selection(false)


func _request_selection(show_message: bool) -> void:
	if is_instance_valid(villager):
		selection_requested.emit(self, villager, show_message)


func _build_card_tooltip(is_selected: bool) -> String:
	if not is_instance_valid(villager):
		return ""
	var has_dialogue: bool = GameManager.has_councillor_opportunity(
		villager.representative_id
	)
	var action_text: String = "Clique para selecionar."
	if is_selected and has_dialogue:
		action_text = "Clique novamente para tratar do assunto marcado com !."
	elif is_selected:
		action_text = "Nenhum assunto com consequência está pendente."
	if villager.unspent_attribute_points > 0:
		action_text += " Há +%d ponto(s) de atributo." % villager.unspent_attribute_points
	var active_project: Dictionary = GameManager.get_active_councillor_project(
		villager.representative_id
	)
	if not active_project.is_empty():
		action_text += " Projeto ativo: %s até o dia %d." % [
			String(active_project.get("title", "Projeto do Conselho")),
			int(active_project.get("end_day", GameManager.current_day))
		]
	var level_text: String = (
		"Nível %d • máximo" % villager.level
		if villager.is_max_level()
		else "Nível %d • XP %d/%d" % [villager.level, villager.xp, villager.get_xp_required()]
	)
	var passive_overview: Dictionary = GameManager.get_villager_passive_overview(villager)
	return (
		"%s\n%s\n"
		+ "FOR %d • INT %d • CAR %d • AGI %d\n"
		+ "Passiva: %s — %s\n%s"
	) % [
		villager.villager_name,
		level_text,
		villager.strength,
		villager.intelligence,
		villager.charisma,
		villager.agility,
		villager.passive_name,
		String(passive_overview.get("status_text", "Sem efeito atual.")),
		action_text
	]


func _set_card_style(selected: bool) -> void:
	add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			MedievalTheme.PARCHMENT
			if selected
			else MedievalTheme.PARCHMENT_DARK,
			MedievalTheme.GOLD if selected else MedievalTheme.WOOD,
			3 if selected else 2,
			8,
			8,
			2 if selected else 0
		)
	)


func _animate_scale(target_scale: Vector2, duration: float) -> void:
	if GameSettings.reduced_motion:
		scale = target_scale
		return
	_kill_active_tween()
	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_QUAD)
	_active_tween.set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(self, "scale", target_scale, duration)


func _kill_active_tween() -> void:
	if is_instance_valid(_active_tween):
		_active_tween.kill()
	_active_tween = null
