class_name CouncilWindow
extends Control


signal swap_requested(active_id: String, reserve_id: String)


const CHARACTER_CATALOG_SCRIPT = preload(
	"res://scripts/dialogue/CharacterCatalog.gd"
)


var _active_selector: OptionButton
var _reserve_selector: OptionButton
var _active_portrait: TextureRect
var _reserve_portrait: TextureRect
var _active_details: RichTextLabel
var _reserve_details: RichTextLabel
var _comparison_details: RichTextLabel
var _recruitment_status: Label
var _swap_button: Button
var _close_button: Button
var _previous_focus: Control

var _active_entries: Array[Dictionary] = []
var _reserve_entries: Array[Dictionary] = []


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 130
	z_as_relative = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.0, 0.0, 0.0, 0.65)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(920.0, 610.0)
	panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			MedievalTheme.WOOD_DARK,
			MedievalTheme.GOLD_DARK,
			3,
			12,
			18,
			5
		)
	)
	center.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)

	var title: Label = MedievalTheme.create_label(
		"TROCAR E COMPARAR CARTAS",
		MedievalTheme.GOLD,
		24
	)
	layout.add_child(title)

	var intro: Label = MedievalTheme.create_label(
		(
			"Compare as informações principais de uma carta ativa e da reserva. "
			+ "A troca é gratuita; a carta que entra assume o trabalho da vaga."
		),
		MedievalTheme.PARCHMENT_LIGHT,
		13
	)
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(intro)

	var recruitment_panel: PanelContainer = PanelContainer.new()
	recruitment_panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			Color(0.13, 0.08, 0.05, 0.94),
			MedievalTheme.GOLD_DARK,
			1,
			6,
			8,
			0
		)
	)
	layout.add_child(recruitment_panel)
	_recruitment_status = MedievalTheme.create_label(
		"RECRUTAMENTO • carregando estado...",
		MedievalTheme.PARCHMENT_LIGHT,
		12
	)
	_recruitment_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_recruitment_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	recruitment_panel.add_child(_recruitment_status)

	var selectors: HBoxContainer = HBoxContainer.new()
	selectors.add_theme_constant_override("separation", 12)
	layout.add_child(selectors)

	_active_selector = OptionButton.new()
	_active_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_active_selector.tooltip_text = "Escolha qual carta ativa será substituída."
	VillageUIAccessibility.configure_input(_active_selector)
	_active_selector.item_selected.connect(_refresh_details)
	selectors.add_child(_active_selector)

	_reserve_selector = OptionButton.new()
	_reserve_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reserve_selector.tooltip_text = "Escolha qual carta da reserva entrará."
	VillageUIAccessibility.configure_input(_reserve_selector)
	_reserve_selector.item_selected.connect(_refresh_details)
	selectors.add_child(_reserve_selector)

	var comparison_row: HBoxContainer = HBoxContainer.new()
	comparison_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	comparison_row.add_theme_constant_override("separation", 12)
	layout.add_child(comparison_row)

	var active_column: VBoxContainer = _create_card_column(
		"CARTA ATIVA",
		true
	)
	active_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	comparison_row.add_child(active_column)

	var comparison_panel: PanelContainer = PanelContainer.new()
	comparison_panel.custom_minimum_size = Vector2(250.0, 0.0)
	comparison_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	comparison_panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			Color(0.13, 0.08, 0.05, 0.94),
			MedievalTheme.GOLD_DARK,
			1,
			6,
			10,
			0
		)
	)
	comparison_row.add_child(comparison_panel)
	_comparison_details = RichTextLabel.new()
	_comparison_details.bbcode_enabled = true
	_comparison_details.fit_content = false
	_comparison_details.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_comparison_details.mouse_filter = Control.MOUSE_FILTER_IGNORE
	comparison_panel.add_child(_comparison_details)

	var reserve_column: VBoxContainer = _create_card_column(
		"CARTA DA RESERVA",
		false
	)
	reserve_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	comparison_row.add_child(reserve_column)

	var actions: HBoxContainer = HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_END
	actions.add_theme_constant_override("separation", 10)
	layout.add_child(actions)

	_swap_button = Button.new()
	_swap_button.text = "REALIZAR TROCA"
	VillageUIAccessibility.configure_button(
		_swap_button,
		"Confirma a substituição mostrada acima.",
		42.0
	)
	_swap_button.pressed.connect(_on_swap)
	actions.add_child(_swap_button)

	_close_button = Button.new()
	_close_button.text = "FECHAR"
	VillageUIAccessibility.configure_button(
		_close_button,
		"Fecha a comparação sem realizar uma troca.",
		42.0
	)
	_close_button.pressed.connect(hide_window)
	actions.add_child(_close_button)


func _create_card_column(
	heading: String,
	is_active_column: bool
) -> VBoxContainer:
	var column: VBoxContainer = VBoxContainer.new()
	column.custom_minimum_size = Vector2(285.0, 0.0)
	column.add_theme_constant_override("separation", 6)

	var heading_label: Label = MedievalTheme.create_label(
		heading,
		MedievalTheme.GOLD,
		15
	)
	heading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(heading_label)

	var portrait_frame: PanelContainer = PanelContainer.new()
	portrait_frame.custom_minimum_size = Vector2(0.0, 156.0)
	portrait_frame.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			MedievalTheme.WOOD,
			MedievalTheme.GOLD_DARK,
			2,
			6,
			5,
			0
		)
	)
	column.add_child(portrait_frame)

	var portrait: TextureRect = TextureRect.new()
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_frame.add_child(portrait)

	var details: RichTextLabel = RichTextLabel.new()
	details.bbcode_enabled = true
	details.fit_content = false
	details.size_flags_vertical = Control.SIZE_EXPAND_FILL
	details.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(details)

	if is_active_column:
		_active_portrait = portrait
		_active_details = details
	else:
		_reserve_portrait = portrait
		_reserve_details = details
	return column


func open_window(data: Dictionary) -> void:
	_previous_focus = VillageUIAccessibility.remember_focus(self)
	_active_entries.clear()
	_reserve_entries.clear()

	for value: Variant in data.get("active", []):
		if value is Dictionary:
			var active_entry: Dictionary = value
			_active_entries.append(active_entry.duplicate(true))

	for value: Variant in data.get("reserve", []):
		if value is Dictionary:
			var reserve_entry: Dictionary = value
			_reserve_entries.append(reserve_entry.duplicate(true))

	_active_selector.clear()
	_reserve_selector.clear()
	_refresh_recruitment_status(data.get("recruitment", {}) as Dictionary)

	for entry: Dictionary in _active_entries:
		_active_selector.add_item(
			"Ativa: %s — %s" % [
				String(entry.get("name", "?")),
				Villager.get_profession_name(
					int(entry.get("profession", 0))
				)
			]
		)

	for entry: Dictionary in _reserve_entries:
		_reserve_selector.add_item(
			"Reserva: %s" % String(entry.get("name", "?"))
		)

	if not _active_entries.is_empty():
		_active_selector.select(0)
	if not _reserve_entries.is_empty():
		_reserve_selector.select(0)

	_refresh_details(0)
	show()
	move_to_front()
	VillageUIAccessibility.focus_first_enabled(
		self,
		_active_selector
	)


func hide_window() -> void:
	if not visible:
		return
	hide()
	VillageUIAccessibility.restore_focus_deferred(_previous_focus)
	_previous_focus = null


func is_window_visible() -> bool:
	return visible


func _unhandled_input(event: InputEvent) -> void:
	if not is_window_visible():
		return
	if event.is_action_pressed("ui_cancel"):
		hide_window()
		get_viewport().set_input_as_handled()


func _refresh_details(_index: int) -> void:
	var has_swap: bool = (
		not _active_entries.is_empty()
		and not _reserve_entries.is_empty()
	)
	_swap_button.disabled = not has_swap

	if not has_swap:
		_active_details.text = "Não há carta ativa disponível."
		_reserve_details.text = "Não há carta na reserva."
		_comparison_details.text = "[center]Não há troca disponível.[/center]"
		_active_portrait.texture = null
		_reserve_portrait.texture = null
		return

	var active_index: int = clampi(
		_active_selector.selected,
		0,
		_active_entries.size() - 1
	)
	var reserve_index: int = clampi(
		_reserve_selector.selected,
		0,
		_reserve_entries.size() - 1
	)
	var active_entry: Dictionary = _active_entries[active_index]
	var reserve_entry: Dictionary = _reserve_entries[reserve_index]

	_active_portrait.texture = CHARACTER_CATALOG_SCRIPT.get_portrait_texture(
		String(active_entry.get("portrait_id", ""))
	)
	_reserve_portrait.texture = CHARACTER_CATALOG_SCRIPT.get_portrait_texture(
		String(reserve_entry.get("portrait_id", ""))
	)
	_active_details.text = _build_entry_text(active_entry)
	_reserve_details.text = _build_entry_text(reserve_entry)
	_comparison_details.text = _build_comparison_text(
		active_entry,
		reserve_entry
	)


func _build_entry_text(entry: Dictionary) -> String:
	var level: int = maxi(1, int(entry.get("level", 1)))
	var xp: int = maxi(0, int(entry.get("xp", 0)))
	var xp_required: int = 80 + 20 * maxi(0, level - 1)
	return (
		"[center][b]%s[/b][/center]\n"
		+ "[color=#D9B75B][b]ATRIBUTOS[/b][/color]\n"
		+ "FOR %d • INT %d • CAR %d • AGI %d\n\n"
		+ "[color=#D9B75B][b]XP[/b][/color]\n"
		+ "Nível %d • %d/%d\n\n"
		+ "[color=#D9B75B][b]PERSONALIDADE[/b][/color]\n%s\n\n"
		+ "[color=#D9B75B][b]PASSIVA • %s[/b][/color]\n%s"
	) % [
		String(entry.get("name", "?")),
		int(entry.get("strength", 0)),
		int(entry.get("intelligence", 0)),
		int(entry.get("charisma", 0)),
		int(entry.get("agility", 0)),
		level,
		xp,
		xp_required,
		String(entry.get("personality_name", "Não informada")),
		String(entry.get("passive_name", "Sem passiva")),
		String(entry.get("passive_description", ""))
	]


func _build_comparison_text(
	active_entry: Dictionary,
	reserve_entry: Dictionary
) -> String:
	var active_level: int = maxi(1, int(active_entry.get("level", 1)))
	var reserve_level: int = maxi(1, int(reserve_entry.get("level", 1)))
	var active_xp: int = maxi(0, int(active_entry.get("xp", 0)))
	var reserve_xp: int = maxi(0, int(reserve_entry.get("xp", 0)))
	return (
		"[center][color=#D9B75B][b]DIFERENÇA DA RESERVA[/b][/color][/center]\n\n"
		+ "FOR %s\nINT %s\nCAR %s\nAGI %s\n\n"
		+ "NÍVEL %s\nXP ATUAL %s\n\n"
		+ "[color=#D9B75B][b]PERSONALIDADES[/b][/color]\n"
		+ "Ativa: %s\nReserva: %s\n\n"
		+ "[color=#D9B75B][b]PASSIVAS[/b][/color]\n"
		+ "Ativa: %s\nReserva: %s\n\n"
		+ "[center]A carta da reserva assumirá o trabalho da vaga ativa.[/center]"
	) % [
		_format_difference(
			int(reserve_entry.get("strength", 0))
			- int(active_entry.get("strength", 0))
		),
		_format_difference(
			int(reserve_entry.get("intelligence", 0))
			- int(active_entry.get("intelligence", 0))
		),
		_format_difference(
			int(reserve_entry.get("charisma", 0))
			- int(active_entry.get("charisma", 0))
		),
		_format_difference(
			int(reserve_entry.get("agility", 0))
			- int(active_entry.get("agility", 0))
		),
		_format_difference(reserve_level - active_level),
		_format_difference(reserve_xp - active_xp),
		String(active_entry.get("personality_name", "Não informada")),
		String(reserve_entry.get("personality_name", "Não informada")),
		String(active_entry.get("passive_name", "Sem passiva")),
		String(reserve_entry.get("passive_name", "Sem passiva"))
	]


func _refresh_recruitment_status(status: Dictionary) -> void:
	if not is_instance_valid(_recruitment_status):
		return
	var completed_count: int = int(status.get("completed_count", 0))
	var total_count: int = int(status.get("total_count", 6))
	var state: String = String(status.get("state", "waiting"))
	var message: String = String(status.get("message", ""))
	var pending_count: int = int(status.get("pending_count", 0))
	var future_count: int = int(status.get("future_count", 0))
	var prefix: String = "RECRUTAMENTO • %d/%d ESCOLHAS CONCLUÍDAS" % [
		completed_count,
		total_count
	]
	if state == "blocked":
		_recruitment_status.text = (
			prefix + " • AGUARDANDO ORIGEM\n" + message
		)
		_recruitment_status.add_theme_color_override(
			"font_color",
			MedievalTheme.GOLD
		)
		return
	if state == "ready":
		_recruitment_status.text = prefix + " • OFERTA PRONTA\n" + message
		_recruitment_status.add_theme_color_override(
			"font_color",
			Color(0.52, 0.78, 0.46)
		)
		return
	var composition: String = ""
	if pending_count > 0:
		composition += " • %d pendente(s)" % pending_count
	if future_count > 0:
		composition += " • %d futura(s)" % future_count
	_recruitment_status.text = prefix + composition + "\n" + message
	_recruitment_status.add_theme_color_override(
		"font_color",
		MedievalTheme.PARCHMENT_LIGHT
	)


func _format_difference(value: int) -> String:
	if value > 0:
		return "[color=#7BBF72]+%d[/color]" % value
	if value < 0:
		return "[color=#D57868]%d[/color]" % value
	return "[color=#C9B98A]0[/color]"


func _on_swap() -> void:
	if _active_entries.is_empty() or _reserve_entries.is_empty():
		return

	var active_index: int = clampi(
		_active_selector.selected,
		0,
		_active_entries.size() - 1
	)
	var reserve_index: int = clampi(
		_reserve_selector.selected,
		0,
		_reserve_entries.size() - 1
	)
	var active_entry: Dictionary = _active_entries[active_index]
	var reserve_entry: Dictionary = _reserve_entries[reserve_index]

	swap_requested.emit(
		String(active_entry.get("representative_id", "")),
		String(reserve_entry.get("representative_id", ""))
	)
	hide_window()
