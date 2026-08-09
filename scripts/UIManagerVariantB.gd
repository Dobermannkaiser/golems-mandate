extends "res://scripts/UIManager.gd"


const SIDEBAR_WIDTH: float = 132.0
const TOP_BAR_HEIGHT: float = 92.0
const BOTTOM_BAR_HEIGHT: float = 82.0
const RESIDENTS_PANEL_WIDTH: float = 366.0
const LOG_HISTORY_LIMIT: int = 40

var workspace_stack: Control
var village_workspace: HBoxContainer
var register_workspace: PanelContainer
var register_text: RichTextLabel
var sidebar_panel: PanelContainer
var sidebar_buttons: Dictionary = {}
var settings_sidebar_button: Button
var diagnostics_sidebar_button: Button
var log_history: Array[String] = []
var last_logged_message: String = ""


func _create_interface() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	interface_root = MarginContainer.new()
	interface_root.name = "ExperimentalInterface"
	interface_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	interface_root.modulate = Color(1.0, 1.0, 1.0, 0.0)
	interface_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	interface_root.add_theme_constant_override("margin_left", 8)
	interface_root.add_theme_constant_override("margin_top", 8)
	interface_root.add_theme_constant_override("margin_right", 8)
	interface_root.add_theme_constant_override("margin_bottom", 8)
	add_child(interface_root)

	var root_row: HBoxContainer = HBoxContainer.new()
	root_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_row.add_theme_constant_override("separation", 8)
	interface_root.add_child(root_row)

	sidebar_panel = _create_sidebar()
	root_row.add_child(sidebar_panel)

	var main_column: VBoxContainer = VBoxContainer.new()
	main_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_column.add_theme_constant_override("separation", 8)
	root_row.add_child(main_column)

	top_bar = _create_top_bar()
	main_column.add_child(top_bar)

	workspace_stack = Control.new()
	workspace_stack.name = "WorkspaceStack"
	workspace_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	workspace_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	workspace_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_column.add_child(workspace_stack)

	village_workspace = _create_main_area()
	village_workspace.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	workspace_stack.add_child(village_workspace)

	register_workspace = _create_register_workspace()
	register_workspace.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	register_workspace.visible = false
	workspace_stack.add_child(register_workspace)

	bottom_bar = _create_bottom_bar()
	main_column.add_child(bottom_bar)

	_set_workspace("village")


func _create_sidebar() -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(SIDEBAR_WIDTH, 0.0)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			Color(0.20, 0.14, 0.09, 0.98),
			MedievalTheme.GOLD_DARK,
			2,
			10,
			10,
			3
		)
	)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 7)
	panel.add_child(layout)

	var navigation_label: Label = MedievalTheme.create_label(
		"NAVEGAÇÃO",
		MedievalTheme.TEXT_MUTED,
		11
	)
	navigation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(navigation_label)

	var village_button: Button = _create_sidebar_button("VILA", "Área principal da vila.")
	village_button.pressed.connect(_on_sidebar_village_pressed)
	layout.add_child(village_button)
	sidebar_buttons["village"] = village_button

	var representatives_button: Button = _create_sidebar_button(
		"CONSELHO",
		"Gerencie representantes ativos e reserva."
	)
	representatives_button.pressed.connect(_on_sidebar_representatives_pressed)
	layout.add_child(representatives_button)
	sidebar_buttons["representatives"] = representatives_button

	var relationships_button: Button = _create_sidebar_button(
		"RELAÇÕES",
		"Converse, acompanhe vínculos e participe das cenas de 200, 400, 600 e 800 pontos."
	)
	relationships_button.pressed.connect(_on_sidebar_relationships_pressed)
	layout.add_child(relationships_button)
	sidebar_buttons["relationships"] = relationships_button

	var register_button: Button = _create_sidebar_button(
		"REGISTRO",
		"Leia o histórico recente da campanha."
	)
	register_button.pressed.connect(_on_sidebar_register_pressed)
	layout.add_child(register_button)
	sidebar_buttons["register"] = register_button

	var management_separator: HSeparator = HSeparator.new()
	layout.add_child(management_separator)

	campaign_button = _create_sidebar_management_button(
		"AVALIAÇÃO",
		"Abra as metas e os riscos da próxima avaliação."
	)
	layout.add_child(campaign_button)

	building_button = _create_sidebar_management_button(
		"OBRAS",
		"Abra o planejamento de casas e melhorias."
	)
	layout.add_child(building_button)

	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(spacer)

	settings_sidebar_button = _create_sidebar_button(
		"CONFIGURAÇÕES",
		"Ajuste os canais de áudio, tela e movimento."
	)
	settings_sidebar_button.pressed.connect(_on_sidebar_settings_pressed)
	layout.add_child(settings_sidebar_button)

	help_button = _create_sidebar_button(
		"AJUDA",
		"Abra novamente o guia do jogo."
	)
	layout.add_child(help_button)

	diagnostics_sidebar_button = Button.new()
	diagnostics_sidebar_button.text = "TESTE INTERNO"
	diagnostics_sidebar_button.custom_minimum_size = Vector2(0.0, 32.0)
	diagnostics_sidebar_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	diagnostics_sidebar_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	diagnostics_sidebar_button.tooltip_text = (
		"Executa verificações de personagens, eventos, capítulos, diálogos, retratos e elenco."
	)
	diagnostics_sidebar_button.add_theme_font_size_override("font_size", 10)
	VillageUIAccessibility.configure_button(
		diagnostics_sidebar_button,
		diagnostics_sidebar_button.tooltip_text,
		32.0
	)
	diagnostics_sidebar_button.pressed.connect(show_internal_diagnostics)
	layout.add_child(diagnostics_sidebar_button)

	var variant_label: Label = MedievalTheme.create_label(
		"LAYOUT OFICIAL\nv3.11.5",
		MedievalTheme.TEXT_MUTED,
		10
	)
	variant_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(variant_label)

	return panel


func _create_sidebar_button(button_text: String, tooltip: String) -> Button:
	var button: Button = Button.new()
	button.text = button_text
	button.custom_minimum_size = Vector2(0.0, 48.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.tooltip_text = tooltip
	button.add_theme_font_size_override("font_size", 13)
	return button


func _create_sidebar_management_button(
	button_text: String,
	tooltip: String
) -> Button:
	var button: Button = Button.new()
	button.text = button_text
	button.custom_minimum_size = Vector2(0.0, 44.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.tooltip_text = tooltip
	button.add_theme_font_size_override("font_size", 11)
	return button


func _create_top_bar() -> PanelContainer:
	var top_panel: PanelContainer = PanelContainer.new()
	top_panel.custom_minimum_size = Vector2(0.0, TOP_BAR_HEIGHT)
	top_panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			MedievalTheme.WOOD_DARK,
			MedievalTheme.GOLD_DARK,
			2,
			10,
			10,
			3
		)
	)

	var top_row: HBoxContainer = HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 8)
	top_panel.add_child(top_row)

	var calendar_panel: PanelContainer = _create_top_section_panel(Vector2(330.0, 0.0))
	top_row.add_child(calendar_panel)

	var calendar_layout: VBoxContainer = VBoxContainer.new()
	calendar_layout.add_theme_constant_override("separation", 1)
	calendar_panel.add_child(calendar_layout)

	var profile_data: Dictionary = GameManager.get_player_profile_overview()
	var profile_name: String = String(profile_data.get("name", "Alex")).to_upper()
	if profile_name.length() > 18:
		profile_name = profile_name.substr(0, 17) + "…"
	game_title_label = MedievalTheme.create_label(
		"GOLEM'S MANDATE • %s" % profile_name,
		MedievalTheme.PARCHMENT_LIGHT,
		13
	)
	calendar_layout.add_child(game_title_label)

	day_label = MedievalTheme.create_label(
		"DIA 1/120 — PRIMAVERA 1/30",
		MedievalTheme.GOLD,
		18
	)
	day_label.mouse_filter = Control.MOUSE_FILTER_STOP
	calendar_layout.add_child(day_label)

	checkpoint_label = MedievalTheme.create_label(
		"PRÓXIMA AVALIAÇÃO: DIA 20",
		MedievalTheme.PARCHMENT_LIGHT,
		9
	)
	checkpoint_label.mouse_filter = Control.MOUSE_FILTER_STOP
	calendar_layout.add_child(checkpoint_label)

	forecast_status_label = MedievalTheme.create_label(
		"CALCULANDO PREVISÃO...",
		MedievalTheme.TEXT_MUTED,
		11
	)
	forecast_status_label.mouse_filter = Control.MOUSE_FILTER_STOP
	calendar_layout.add_child(forecast_status_label)

	var resources_panel: PanelContainer = _create_top_section_panel(Vector2(0.0, 0.0))
	resources_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(resources_panel)

	var resources_layout: VBoxContainer = VBoxContainer.new()
	resources_layout.add_theme_constant_override("separation", 0)
	resources_panel.add_child(resources_layout)

	var resources_row: HBoxContainer = HBoxContainer.new()
	resources_row.add_theme_constant_override("separation", 6)
	resources_layout.add_child(resources_row)

	var population_tile: Array[Label] = _create_compact_resource_tile(
		resources_row,
		"POP.",
		"8 / 10",
		MedievalTheme.PARCHMENT_LIGHT
	)
	population_label = population_tile[0]
	forecast_population_label = population_tile[1]

	var food_tile: Array[Label] = _create_compact_resource_tile(
		resources_row,
		"ALIMENT.",
		"30.0",
		Color("#E6D27B")
	)
	food_label = food_tile[0]
	forecast_food_label = food_tile[1]

	var material_tile: Array[Label] = _create_compact_resource_tile(
		resources_row,
		"MATERIAL",
		"10.0",
		Color("#D4B08C")
	)
	material_label = material_tile[0]
	forecast_material_label = material_tile[1]

	var happiness_tile: Array[Label] = _create_compact_resource_tile(
		resources_row,
		"FELIC.",
		"60.0",
		Color("#E7A29B")
	)
	happiness_label = happiness_tile[0]
	forecast_happiness_label = happiness_tile[1]

	return top_panel


func _create_top_section_panel(minimum_size: Vector2) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = minimum_size
	panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			MedievalTheme.WOOD,
			MedievalTheme.GOLD_DARK,
			1,
			7,
			8,
			0
		)
	)
	return panel


func _create_compact_resource_tile(
	parent: HBoxContainer,
	title_text: String,
	initial_value: String,
	value_color: Color
) -> Array[Label]:
	var tile: PanelContainer = PanelContainer.new()
	tile.custom_minimum_size = Vector2(106.0, 52.0)
	tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tile.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			Color(0.25, 0.16, 0.10, 0.90),
			MedievalTheme.GOLD_DARK,
			1,
			5,
			4,
			0
		)
	)
	resource_tiles.append(tile)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 0)
	tile.add_child(layout)

	var title: Label = MedievalTheme.create_label(
		title_text,
		MedievalTheme.TEXT_MUTED,
		9
	)
	layout.add_child(title)

	var value: Label = MedievalTheme.create_label(
		initial_value,
		value_color,
		17
	)
	layout.add_child(value)

	var forecast: Label = MedievalTheme.create_label(
		"PRÓX.: --",
		MedievalTheme.TEXT_MUTED,
		9
	)
	forecast.mouse_filter = Control.MOUSE_FILTER_STOP
	layout.add_child(forecast)

	parent.add_child(tile)
	var labels: Array[Label] = [value, forecast]
	return labels


func _create_main_area() -> HBoxContainer:
	var main_area: HBoxContainer = HBoxContainer.new()
	main_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_area.add_theme_constant_override("separation", 8)

	residents_panel = _create_residents_panel()
	main_area.add_child(residents_panel)

	village_frame = _create_village_frame()
	village_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_area.add_child(village_frame)

	return main_area


func _create_residents_panel() -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(RESIDENTS_PANEL_WIDTH, 0.0)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			MedievalTheme.WOOD_DARK,
			MedievalTheme.GOLD_DARK,
			2,
			10,
			10,
			3
		)
	)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 6)
	panel.add_child(layout)

	var title_row: HBoxContainer = HBoxContainer.new()
	layout.add_child(title_row)

	var title: Label = MedievalTheme.create_label(
		"REPRESENTANTES",
		MedievalTheme.GOLD,
		18
	)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title)

	council_button = Button.new()
	council_button.text = "GERENCIAR"
	council_button.custom_minimum_size = Vector2(112.0, 34.0)
	council_button.tooltip_text = "Troque membros ativos e personagens da reserva."
	council_button.pressed.connect(_on_council_button_pressed)
	title_row.add_child(council_button)

	selection_status_label = MedievalTheme.create_label(
		"SELECIONE UM CARTÃO",
		MedievalTheme.TEXT_MUTED,
		10
	)
	selection_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	layout.add_child(selection_status_label)

	var divider: HSeparator = HSeparator.new()
	layout.add_child(divider)

	var cards_scroll: ScrollContainer = ScrollContainer.new()
	cards_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cards_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	cards_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	cards_scroll.follow_focus = true
	layout.add_child(cards_scroll)

	villager_cards = GridContainer.new()
	villager_cards.columns = 1
	villager_cards.custom_minimum_size = Vector2(326.0, 0.0)
	villager_cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	villager_cards.add_theme_constant_override("h_separation", 6)
	villager_cards.add_theme_constant_override("v_separation", 8)
	cards_scroll.add_child(villager_cards)

	return panel


func _create_village_frame() -> PanelContainer:
	var frame: PanelContainer = PanelContainer.new()
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.clip_contents = true
	frame.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			Color(0.10, 0.07, 0.04, 0.10),
			MedievalTheme.GOLD_DARK,
			2,
			10,
			5,
			3
		)
	)

	var frame_layout: VBoxContainer = VBoxContainer.new()
	frame_layout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(frame_layout)

	var title_panel: PanelContainer = PanelContainer.new()
	title_panel.custom_minimum_size = Vector2(0.0, 42.0)
	title_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	title_panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			Color(0.20, 0.13, 0.09, 0.94),
			MedievalTheme.GOLD_DARK,
			1,
			6,
			8,
			0
		)
	)
	frame_layout.add_child(title_panel)

	var title_row: HBoxContainer = HBoxContainer.new()
	title_panel.add_child(title_row)

	var title: Label = MedievalTheme.create_label(
		"ÁREA DA VILA",
		MedievalTheme.GOLD,
		18
	)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_row.add_child(title)

	expand_village_button = Button.new()
	expand_village_button.text = "AMPLIAR"
	expand_village_button.custom_minimum_size = Vector2(112.0, 32.0)
	expand_village_button.tooltip_text = "Abra uma visualização ampliada da vila."
	expand_village_button.pressed.connect(_on_expand_village_button_pressed)
	title_row.add_child(expand_village_button)

	var empty_space: Control = Control.new()
	empty_space.mouse_filter = Control.MOUSE_FILTER_IGNORE
	empty_space.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame_layout.add_child(empty_space)

	building_visuals = BUILDING_VISUALS_SCRIPT.new()
	# A mini-vila permanece sempre abaixo de qualquer janela modal.
	building_visuals.z_index = 0
	building_visuals.z_as_relative = false
	building_visuals.building_requested.connect(_on_village_building_requested)
	building_visuals.council_member_requested.connect(_on_village_council_member_requested)
	frame.add_child(building_visuals)

	frame.resized.connect(_on_village_frame_resized)
	return frame


func _create_register_workspace() -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			MedievalTheme.WOOD_DARK,
			MedievalTheme.GOLD_DARK,
			2,
			10,
			14,
			4
		)
	)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	panel.add_child(layout)

	var header: HBoxContainer = HBoxContainer.new()
	layout.add_child(header)

	var title: Label = MedievalTheme.create_label(
		"REGISTRO DA CAMPANHA",
		MedievalTheme.GOLD,
		21
	)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var back_button: Button = Button.new()
	back_button.text = "VOLTAR À VILA"
	back_button.custom_minimum_size = Vector2(160.0, 38.0)
	back_button.pressed.connect(_on_sidebar_village_pressed)
	header.add_child(back_button)

	var explanation: Label = MedievalTheme.create_label(
		"Os registros mais recentes aparecem primeiro. O resumo atual também permanece no rodapé.",
		MedievalTheme.TEXT_MUTED,
		12
	)
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(explanation)

	register_text = RichTextLabel.new()
	register_text.bbcode_enabled = false
	register_text.fit_content = false
	register_text.scroll_active = true
	register_text.selection_enabled = true
	register_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	register_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	register_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	register_text.add_theme_font_size_override("normal_font_size", 15)
	register_text.add_theme_color_override("default_color", MedievalTheme.PARCHMENT_LIGHT)
	register_text.add_theme_constant_override("line_separation", 5)
	layout.add_child(register_text)

	_refresh_register_text()
	return panel


func _create_bottom_bar() -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0.0, BOTTOM_BAR_HEIGHT)
	panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			MedievalTheme.WOOD_DARK,
			MedievalTheme.GOLD_DARK,
			2,
			10,
			10,
			3
		)
	)

	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	panel.add_child(row)

	summary_area = VBoxContainer.new()
	summary_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary_area.add_theme_constant_override("separation", 1)
	row.add_child(summary_area)

	var summary_title: Label = MedievalTheme.create_label(
		"NOTÍCIAS DO DIA",
		MedievalTheme.GOLD,
		12
	)
	summary_area.add_child(summary_title)

	summary_label = RichTextLabel.new()
	summary_label.bbcode_enabled = false
	summary_label.fit_content = false
	summary_label.scroll_active = true
	summary_label.scroll_following = false
	summary_label.selection_enabled = true
	summary_label.custom_minimum_size = Vector2(0.0, 48.0)
	summary_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_label.add_theme_font_size_override("normal_font_size", 13)
	summary_label.add_theme_color_override("default_color", MedievalTheme.PARCHMENT_LIGHT)
	summary_area.add_child(summary_label)

	menu_button = Button.new()
	menu_button.text = "MENU"
	menu_button.custom_minimum_size = Vector2(102.0, 54.0)
	menu_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(menu_button)

	save_button = Button.new()
	save_button.text = "SALVAR /\nCARREGAR"
	save_button.custom_minimum_size = Vector2(142.0, 54.0)
	save_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(save_button)

	advance_day_button = Button.new()
	advance_day_button.text = "ENCERRAR O DIA"
	advance_day_button.custom_minimum_size = Vector2(188.0, 54.0)
	advance_day_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(advance_day_button)

	return panel


func _set_forecast_label(
	target_label: Label,
	next_day: int,
	projected_value: float,
	change: float,
	is_critical: bool
) -> void:
	var change_text: String = "%.1f" % change
	if change > 0.05:
		change_text = "+" + change_text

	var new_text: String = "%.1f (%s)" % [
		projected_value,
		change_text
	]
	var text_changed: bool = target_label.text != new_text
	target_label.text = new_text
	target_label.tooltip_text = "Previsão para o dia %d." % next_day

	var forecast_color: Color = MedievalTheme.PARCHMENT_LIGHT
	if is_critical:
		forecast_color = Color("#F07F72")
	elif change < -0.05:
		forecast_color = Color("#E6C15A")
	elif change > 0.05:
		forecast_color = Color("#9FD18B")

	target_label.add_theme_color_override(
		"font_color",
		forecast_color
	)

	if interface_ready and text_changed:
		_animate_label_pulse(target_label, 1.05)


func _apply_season_appearance(
	day_value: int,
	force_update: bool = false
) -> void:
	super._apply_season_appearance(day_value, force_update)

	if not is_instance_valid(sidebar_panel):
		return

	var season: Dictionary = VillageCampaignCatalog.get_season_for_day(day_value)
	var season_id: String = String(season.get("id", "spring"))
	var palette: Dictionary = MedievalTheme.get_season_palette(
		season_id,
		GameSettings.enhanced_contrast
	)
	sidebar_panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			palette["panel_dark"],
			palette["accent_dark"],
			2,
			10,
			10,
			3
		)
	)


func _set_summary(message: String, animate: bool) -> void:
	super._set_summary(message, animate)

	var normalized_message: String = message.strip_edges()
	if normalized_message.is_empty() or normalized_message == last_logged_message:
		return

	last_logged_message = normalized_message
	var day_number: int = maxi(1, GameManager.current_day)
	var entry: String = "DIA %d\n%s" % [day_number, normalized_message]
	log_history.push_front(entry)

	while log_history.size() > LOG_HISTORY_LIMIT:
		log_history.pop_back()

	_refresh_register_text()


func _refresh_register_text() -> void:
	if not is_instance_valid(register_text):
		return

	if log_history.is_empty():
		register_text.text = "Nenhum registro disponível nesta sessão."
		return

	var combined_text: String = ""
	for index: int in range(log_history.size()):
		if index > 0:
			combined_text += "\n\n────────────────────────────\n\n"
		combined_text += log_history[index]

	register_text.text = combined_text
	register_text.scroll_to_line(0)


func _set_workspace(workspace_id: String) -> void:
	if is_instance_valid(village_workspace):
		village_workspace.visible = workspace_id == "village"

	if is_instance_valid(register_workspace):
		register_workspace.visible = workspace_id == "register"

	if is_instance_valid(building_visuals):
		building_visuals.set_simulation_active(workspace_id == "village")

	for button_id in sidebar_buttons.keys():
		var button: Button = sidebar_buttons[button_id] as Button
		if not is_instance_valid(button):
			continue
		var base_text: String = String(button.get_meta("base_text", button.text))
		button.set_meta("base_text", base_text)
		button.text = ("▶ " + base_text) if button_id == workspace_id else base_text


func _on_sidebar_village_pressed() -> void:
	_set_workspace("village")


func _on_sidebar_representatives_pressed() -> void:
	_set_workspace("village")
	_on_council_button_pressed()


func _on_sidebar_relationships_pressed() -> void:
	_set_workspace("village")
	_open_relationships_window()


func _on_sidebar_register_pressed() -> void:
	_set_workspace("register")
	_refresh_register_text()
	_request_contextual_tutorial(
		"area_register",
		register_workspace
	)


func _on_sidebar_settings_pressed() -> void:
	AudioManager.play_ui("window_open", false)
	AudioManager.enter_menu(true)
	if not is_instance_valid(main_menu):
		_create_main_menu()

	main_menu.show_settings(
		GameManager.get_save_overview(),
		true
	)
