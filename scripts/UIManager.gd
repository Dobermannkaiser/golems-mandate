extends Control


const EVENT_WINDOW_SCRIPT = preload(
	"res://scripts/ui/EventWindow.gd"
)

const CAMPAIGN_WINDOW_SCRIPT = preload(
	"res://scripts/ui/CampaignWindow.gd"
)

const RECRUITMENT_WINDOW_SCRIPT = preload(
	"res://scripts/ui/RecruitmentWindow.gd"
)

const SEASON_HINT_WINDOW_SCRIPT = preload(
	"res://scripts/ui/SeasonHintWindow.gd"
)

const BUILDING_WINDOW_SCRIPT = preload(
	"res://scripts/ui/BuildingWindow.gd"
)

const BUILDING_VISUALS_SCRIPT = preload(
	"res://scripts/ui/BuildingVisuals.gd"
)

const VILLAGE_WINDOW_SCRIPT = preload(
	"res://scripts/ui/VillageWindow.gd"
)

const SAVE_WINDOW_SCRIPT = preload(
	"res://scripts/ui/SaveWindow.gd"
)

const MAIN_MENU_SCRIPT = preload(
	"res://scripts/ui/MainMenu.gd"
)

const TUTORIAL_WINDOW_SCRIPT = preload(
	"res://scripts/ui/TutorialWindow.gd"
)

const TUTORIAL_MANAGER_SCRIPT = preload(
	"res://scripts/tutorial/TutorialManager.gd"
)

const COUNCIL_WINDOW_SCRIPT = preload("res://scripts/ui/CouncilWindow.gd")

const COUNCILLOR_HISTORY_WINDOW_SCRIPT = preload(
	"res://scripts/ui/CouncillorHistoryWindow.gd"
)

const FORECAST_DETAILS_WINDOW_SCRIPT = preload(
	"res://scripts/ui/ForecastDetailsWindow.gd"
)

const COUNCILLOR_PROGRESSION_DIALOGUE_CATALOG_SCRIPT = preload(
	"res://scripts/council/CouncillorProgressionDialogueCatalog.gd"
)

const COUNCILLOR_OPPORTUNITY_DIALOGUE_CATALOG_SCRIPT = preload(
	"res://scripts/council/CouncillorOpportunityDialogueCatalog.gd"
)

const DIALOGUE_WINDOW_SCRIPT = preload(
	"res://scripts/ui/DialogueWindow.gd"
)

const DIALOGUE_CATALOG_SCRIPT = preload(
	"res://scripts/dialogue/DialogueCatalog.gd"
)

const DIAGNOSTICS_WINDOW_SCRIPT = preload(
	"res://scripts/ui/DiagnosticsWindow.gd"
)

const RELATIONSHIPS_WINDOW_SCRIPT = preload(
	"res://scripts/ui/RelationshipsWindow.gd"
)

const PROFILE_SETUP_WINDOW_SCRIPT = preload(
	"res://scripts/ui/ProfileSetupWindow.gd"
)

const RELATIONSHIP_DIALOGUE_CATALOG_SCRIPT = preload(
	"res://scripts/relationships/RelationshipDialogueCatalog.gd"
)

const VILLAGER_CARD_SCENE = preload(
	"res://scenes/ui/villager_card.tscn"
)

const VILLAGE_VILLAGER_HORIZONTAL_MARGIN: float = 20.0
const VILLAGE_VILLAGER_TOP_MARGIN: float = 52.0
const VILLAGE_VILLAGER_BOTTOM_MARGIN: float = 68.0
const VILLAGER_VISUAL_CENTER_OFFSET_Y: float = 20.0


var interface_root: MarginContainer
var top_bar: PanelContainer
var residents_panel: PanelContainer
var bottom_bar: PanelContainer
var summary_area: VBoxContainer

var game_title_label: Label
var day_label: Label
var checkpoint_label: Label
var population_label: Label
var food_label: Label
var material_label: Label
var happiness_label: Label

var forecast_status_label: Label
var forecast_population_label: Label
var forecast_food_label: Label
var forecast_material_label: Label
var forecast_happiness_label: Label
var forecast_details_button: Button

var selection_status_label: Label
var selected_profession_selector: OptionButton
var updating_selected_profession: bool = false
var summary_label: RichTextLabel
var advance_day_button: Button
var campaign_button: Button
var building_button: Button
var save_button: Button
var menu_button: Button
var help_button: Button
var council_button: Button
var expand_village_button: Button

var villager_cards: GridContainer
var village_frame: PanelContainer
var building_visuals: VillageBuildingVisuals
var world_background: ColorRect
var village_ground: ColorRect
var legacy_villagers_layer: CanvasItem
var resource_tiles: Array[PanelContainer] = []

var event_window
var campaign_window
var recruitment_window: RecruitmentWindow
var season_hint_window
var building_window
var save_window
var main_menu: MainMenu
var tutorial_window
var tutorial_manager
var council_window
var councillor_history_window: CouncillorHistoryWindow
var forecast_details_window: ForecastDetailsWindow
var village_window: VillageWindow
var dialogue_window: VillageDialogueWindow
var diagnostics_window: VillageDiagnosticsWindow
var relationships_window: VillageRelationshipsWindow
var profile_setup_window: VillageProfileSetupWindow

var selected_villager: Villager
var selected_card: VillagerCard

var villager_cards_by_id: Dictionary = {}
var label_tweens: Dictionary = {}
var world_tweens: Dictionary = {}

var interface_ready: bool = false
var has_resource_snapshot: bool = false
var world_layout_queued: bool = false
var tutorial_return_to_menu: bool = false
var tutorial_menu_opened_from_game: bool = false
var tutorial_started_automatically: bool = false
var tutorial_is_full_guide: bool = false
var tutorial_context_hint_id: String = ""
var current_season_id: String = ""
var active_story_dialogue_id: String = ""
var active_level_dialogue_id: String = ""
var tutorial_after_story: bool = false
var profile_setup_return_to_game: bool = false

var previous_food: float = 0.0
var previous_material: float = 0.0
var previous_happiness: float = 0.0
var previous_day: int = 0


func _ready() -> void:
	_hide_old_interface()

	theme = MedievalTheme.create_theme(
		"spring",
		GameSettings.enhanced_contrast
	)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_manager = TUTORIAL_MANAGER_SCRIPT.new()

	_create_interface()

	# Apenas o menu inicial precisa existir no primeiro quadro. As demais
	# janelas são criadas quando o jogador realmente as abre ou quando
	# um acontecimento solicita uma delas. Isso reduz nós, controles e
	# conexões mantidos ocultos durante toda a campanha.
	_create_main_menu()
	_connect_game_signals()
	_apply_world_appearance()

	get_viewport().size_changed.connect(
		_on_viewport_size_changed
	)

	if not GameSettings.settings_changed.is_connected(
		_on_game_settings_changed
	):
		GameSettings.settings_changed.connect(
			_on_game_settings_changed
		)

	_on_resources_changed(
		GameManager.food,
		GameManager.building_material,
		GameManager.happiness,
		GameManager.current_day
	)

	_on_campaign_progress_changed(
		GameManager.get_campaign_progress()
	)

	_refresh_building_state(
		false,
		true
	)

	_on_save_state_changed(
		GameManager.get_save_overview()
	)

	_rebuild_villager_list()

	_set_summary(
		"Escolha as profissões, selecione um representante "
		+ "e confira a previsão do próximo dia.",
		false
	)

	interface_ready = true

	_queue_world_layout()
	call_deferred("_animate_interface_entrance")
	call_deferred("_show_startup_menu")


func _hide_old_interface() -> void:
	var old_children: Array[Node] = get_children()

	for child: Node in old_children:
		if child is CanvasItem:
			var old_item: CanvasItem = child as CanvasItem
			old_item.visible = false


func _create_interface() -> void:
	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	interface_root = MarginContainer.new()
	interface_root.name = "MedievalInterface"
	interface_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	interface_root.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.0
	)

	interface_root.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	interface_root.add_theme_constant_override(
		"margin_left",
		16
	)

	interface_root.add_theme_constant_override(
		"margin_top",
		16
	)

	interface_root.add_theme_constant_override(
		"margin_right",
		16
	)

	interface_root.add_theme_constant_override(
		"margin_bottom",
		16
	)

	add_child(interface_root)

	var screen_layout: VBoxContainer = VBoxContainer.new()
	screen_layout.mouse_filter = Control.MOUSE_FILTER_IGNORE

	screen_layout.add_theme_constant_override(
		"separation",
		12
	)

	interface_root.add_child(screen_layout)

	top_bar = _create_top_bar()
	screen_layout.add_child(top_bar)

	var main_area: HBoxContainer = _create_main_area()
	main_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	screen_layout.add_child(main_area)

	bottom_bar = _create_bottom_bar()
	screen_layout.add_child(bottom_bar)


func _create_top_bar() -> PanelContainer:
	var top_panel: PanelContainer = PanelContainer.new()

	top_panel.custom_minimum_size = Vector2(
		0.0,
		112.0
	)

	top_panel.add_theme_stylebox_override(
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

	var top_row: HBoxContainer = HBoxContainer.new()

	top_row.add_theme_constant_override(
		"separation",
		8
	)

	top_panel.add_child(top_row)

	var title_area: VBoxContainer = VBoxContainer.new()

	title_area.custom_minimum_size = Vector2(
		300.0,
		0.0
	)

	title_area.add_theme_constant_override(
		"separation",
		1
	)

	top_row.add_child(title_area)

	game_title_label = MedievalTheme.create_label(
		"GOLEM'S MANDATE",
		MedievalTheme.PARCHMENT_LIGHT,
		15
	)

	title_area.add_child(game_title_label)

	day_label = MedievalTheme.create_label(
		"DIA 1/120 — PRIMAVERA 1/30",
		MedievalTheme.GOLD,
		21
	)

	day_label.mouse_filter = Control.MOUSE_FILTER_STOP
	day_label.tooltip_text = (
		"Dia atual da vila."
	)

	title_area.add_child(day_label)

	checkpoint_label = MedievalTheme.create_label(
		"PRÓXIMA AVALIAÇÃO: DIA 20 — FALTAM 20 DIAS",
		MedievalTheme.PARCHMENT_LIGHT,
		12
	)
	checkpoint_label.mouse_filter = (
		Control.MOUSE_FILTER_STOP
	)
	checkpoint_label.tooltip_text = (
		"Metas obrigatórias verificadas ao encerrar "
		+ "o próximo dia de avaliação."
	)
	title_area.add_child(checkpoint_label)

	forecast_status_label = MedievalTheme.create_label(
		"CALCULANDO PREVISÃO...",
		MedievalTheme.TEXT_MUTED,
		12
	)

	forecast_status_label.mouse_filter = (
		Control.MOUSE_FILTER_STOP
	)

	forecast_status_label.tooltip_text = (
		"A previsão ainda está sendo calculada."
	)

	title_area.add_child(forecast_status_label)

	forecast_details_button = Button.new()
	forecast_details_button.text = "DETALHAR MODIFICADORES"
	forecast_details_button.custom_minimum_size = Vector2(0.0, 26.0)
	forecast_details_button.add_theme_font_size_override("font_size", 11)
	forecast_details_button.tooltip_text = (
		"Abre a composição da previsão: passivas, sinergias, "
		+ "concentração, consumo e manutenção."
	)
	forecast_details_button.pressed.connect(_on_forecast_details_pressed)
	title_area.add_child(forecast_details_button)

	var separator: VSeparator = VSeparator.new()
	top_row.add_child(separator)

	campaign_button = Button.new()
	campaign_button.text = "OBJETIVOS\n0 / 5"

	campaign_button.custom_minimum_size = Vector2(
		142.0,
		76.0
	)

	campaign_button.size_flags_vertical = (
		Control.SIZE_SHRINK_CENTER
	)

	campaign_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	campaign_button.add_theme_font_size_override(
		"font_size",
		14
	)

	campaign_button.tooltip_text = (
		"Abra os objetivos, as condições de vitória "
		+ "e os riscos de derrota da campanha."
	)

	top_row.add_child(campaign_button)

	building_button = Button.new()
	building_button.text = "OBRAS\n0/15 • 2 CASAS"

	building_button.custom_minimum_size = Vector2(
		142.0,
		76.0
	)

	building_button.size_flags_vertical = (
		Control.SIZE_SHRINK_CENTER
	)

	building_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	building_button.add_theme_font_size_override(
		"font_size",
		13
	)

	building_button.tooltip_text = (
		"Invista material em construções permanentes "
		+ "durante esta campanha."
	)

	top_row.add_child(building_button)

	var population_tile: Array[Label] = (
		_create_resource_tile(
			top_row,
			"POPULAÇÃO",
			"8 / 10",
			MedievalTheme.PARCHMENT_LIGHT,
			true
		)
	)

	population_label = population_tile[0]
	forecast_population_label = population_tile[1]
	population_label.mouse_filter = Control.MOUSE_FILTER_STOP

	var food_tile: Array[Label] = (
		_create_resource_tile(
			top_row,
			"ALIMENTAÇÃO",
			"0.0",
			Color("#E6D27B"),
			true
		)
	)

	food_label = food_tile[0]
	forecast_food_label = food_tile[1]
	food_label.mouse_filter = Control.MOUSE_FILTER_STOP

	var material_tile: Array[Label] = (
		_create_resource_tile(
			top_row,
			"MATERIAL",
			"0.0",
			Color("#D4B08C"),
			true
		)
	)

	material_label = material_tile[0]
	forecast_material_label = material_tile[1]
	material_label.mouse_filter = Control.MOUSE_FILTER_STOP

	var happiness_tile: Array[Label] = (
		_create_resource_tile(
			top_row,
			"FELICIDADE",
			"0.0 / 100",
			Color("#E7A29B"),
			true
		)
	)

	happiness_label = happiness_tile[0]
	forecast_happiness_label = happiness_tile[1]
	happiness_label.mouse_filter = Control.MOUSE_FILTER_STOP

	return top_panel


func _create_resource_tile(
	parent: HBoxContainer,
	title_text: String,
	initial_value: String,
	value_color: Color,
	show_forecast: bool
) -> Array[Label]:
	var tile: PanelContainer = PanelContainer.new()
	resource_tiles.append(tile)

	tile.custom_minimum_size = Vector2(
		120.0,
		76.0
	)

	tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	tile.add_theme_stylebox_override(
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

	var tile_content: VBoxContainer = VBoxContainer.new()

	tile_content.add_theme_constant_override(
		"separation",
		0
	)

	tile.add_child(tile_content)

	var title: Label = MedievalTheme.create_label(
		title_text,
		MedievalTheme.TEXT_MUTED,
		12
	)

	tile_content.add_child(title)

	var value: Label = MedievalTheme.create_label(
		initial_value,
		value_color,
		21
	)

	tile_content.add_child(value)

	var forecast_value: Label = MedievalTheme.create_label(
		"PRÓXIMO DIA: --",
		MedievalTheme.TEXT_MUTED,
		11
	)

	forecast_value.visible = show_forecast
	forecast_value.mouse_filter = Control.MOUSE_FILTER_STOP

	tile_content.add_child(forecast_value)
	parent.add_child(tile)

	var created_labels: Array[Label] = [
		value,
		forecast_value
	]

	return created_labels


func _create_main_area() -> HBoxContainer:
	var main_area: HBoxContainer = HBoxContainer.new()
	main_area.mouse_filter = Control.MOUSE_FILTER_IGNORE

	main_area.add_theme_constant_override(
		"separation",
		12
	)

	residents_panel = (
		_create_residents_panel()
	)

	main_area.add_child(residents_panel)

	village_frame = _create_village_frame()
	main_area.add_child(village_frame)

	return main_area


func _create_residents_panel() -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()

	panel.custom_minimum_size = Vector2(
		620.0,
		0.0
	)

	panel.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			MedievalTheme.WOOD_DARK,
			MedievalTheme.GOLD_DARK,
			2,
			10,
			14,
			3
		)
	)

	var residents_layout: VBoxContainer = VBoxContainer.new()

	residents_layout.add_theme_constant_override(
		"separation",
		8
	)

	panel.add_child(residents_layout)

	var title_row: HBoxContainer = HBoxContainer.new()
	residents_layout.add_child(title_row)

	var title: Label = MedievalTheme.create_label(
		"CARTAS DO CONSELHO",
		MedievalTheme.GOLD,
		21
	)

	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title)

	council_button = Button.new()
	council_button.text = "TROCAR CARTAS"
	council_button.tooltip_text = "Compare uma carta ativa com a reserva e confirme a troca."
	council_button.pressed.connect(_on_council_button_pressed)
	title_row.add_child(council_button)

	var work_row: HBoxContainer = HBoxContainer.new()
	work_row.add_theme_constant_override("separation", 8)
	residents_layout.add_child(work_row)

	selection_status_label = MedievalTheme.create_label(
		"SELECIONE UMA CARTA",
		MedievalTheme.TEXT_MUTED,
		13
	)
	selection_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	selection_status_label.mouse_filter = Control.MOUSE_FILTER_STOP
	selection_status_label.tooltip_text = (
		"Selecione uma carta para destacá-la na vila e definir seu trabalho."
	)
	work_row.add_child(selection_status_label)

	var profession_label: Label = MedievalTheme.create_label(
		"TRABALHO",
		MedievalTheme.PARCHMENT_LIGHT,
		11
	)
	work_row.add_child(profession_label)

	selected_profession_selector = OptionButton.new()
	selected_profession_selector.custom_minimum_size = Vector2(180.0, 34.0)
	selected_profession_selector.disabled = true
	selected_profession_selector.tooltip_text = (
		"Selecione uma carta e escolha a profissão exercida por ela."
	)
	for profession: int in Villager.get_all_professions():
		selected_profession_selector.add_item(
			Villager.get_profession_name(profession),
			profession
		)
	selected_profession_selector.item_selected.connect(
		_on_selected_profession_changed
	)
	work_row.add_child(selected_profession_selector)

	var divider: HSeparator = HSeparator.new()
	residents_layout.add_child(divider)

	var cards_scroll: ScrollContainer = ScrollContainer.new()

	cards_scroll.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	cards_scroll.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)

	cards_scroll.horizontal_scroll_mode = (
		ScrollContainer.SCROLL_MODE_DISABLED
	)

	cards_scroll.vertical_scroll_mode = (
		ScrollContainer.SCROLL_MODE_AUTO
	)

	cards_scroll.follow_focus = true
	residents_layout.add_child(cards_scroll)

	villager_cards = GridContainer.new()
	villager_cards.columns = 2

	villager_cards.custom_minimum_size = Vector2(
		570.0,
		0.0
	)

	villager_cards.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	villager_cards.add_theme_constant_override(
		"h_separation",
		10
	)

	villager_cards.add_theme_constant_override(
		"v_separation",
		10
	)

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

	var village_title_panel: PanelContainer = (
		PanelContainer.new()
	)

	village_title_panel.custom_minimum_size = Vector2(
		0.0,
		44.0
	)

	village_title_panel.mouse_filter = (
		Control.MOUSE_FILTER_STOP
	)

	village_title_panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			Color(0.20, 0.13, 0.09, 0.94),
			MedievalTheme.GOLD_DARK,
			1,
			6,
			10,
			0
		)
	)

	frame_layout.add_child(village_title_panel)

	var title_row: HBoxContainer = HBoxContainer.new()
	title_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	village_title_panel.add_child(title_row)

	var village_title: Label = MedievalTheme.create_label(
		"ÁREA DA VILA",
		MedievalTheme.GOLD,
		18
	)

	village_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	village_title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	village_title.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	title_row.add_child(village_title)

	expand_village_button = Button.new()
	expand_village_button.text = "AMPLIAR"
	expand_village_button.custom_minimum_size = Vector2(
		120.0,
		30.0
	)
	expand_village_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)
	expand_village_button.tooltip_text = ""
	expand_village_button.pressed.connect(
		_on_expand_village_button_pressed
	)
	title_row.add_child(expand_village_button)

	var empty_space: Control = Control.new()
	empty_space.mouse_filter = Control.MOUSE_FILTER_IGNORE
	empty_space.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame_layout.add_child(empty_space)

	building_visuals = (
		BUILDING_VISUALS_SCRIPT.new()
		as VillageBuildingVisuals
	)

	if not is_instance_valid(building_visuals):
		push_error(
			"Não foi possível criar a área visual da vila."
		)
		return frame

	building_visuals.building_requested.connect(
		_on_village_building_requested
	)
	building_visuals.council_member_requested.connect(
		_on_village_council_member_requested
	)
	frame.add_child(building_visuals)

	frame.resized.connect(
		_on_village_frame_resized
	)

	return frame


func _create_bottom_bar() -> PanelContainer:
	var bottom_panel: PanelContainer = PanelContainer.new()

	bottom_panel.custom_minimum_size = Vector2(
		0.0,
		152.0
	)

	bottom_panel.add_theme_stylebox_override(
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

	var bottom_row: HBoxContainer = HBoxContainer.new()

	bottom_row.add_theme_constant_override(
		"separation",
		18
	)

	bottom_panel.add_child(bottom_row)

	summary_area = VBoxContainer.new()
	summary_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	summary_area.add_theme_constant_override(
		"separation",
		4
	)

	bottom_row.add_child(summary_area)

	var summary_title: Label = MedievalTheme.create_label(
		"REGISTRO DO DIA",
		MedievalTheme.GOLD,
		14
	)

	summary_area.add_child(summary_title)

	var summary_scroll_frame: PanelContainer = PanelContainer.new()
	summary_scroll_frame.custom_minimum_size = Vector2(0.0, 92.0)
	summary_scroll_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary_scroll_frame.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	summary_scroll_frame.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			Color(0.18, 0.11, 0.07, 0.92),
			MedievalTheme.GOLD_DARK,
			1,
			6,
			8,
			0
		)
	)
	summary_area.add_child(summary_scroll_frame)

	summary_label = RichTextLabel.new()
	summary_label.bbcode_enabled = false
	summary_label.fit_content = false
	summary_label.scroll_active = true
	summary_label.scroll_following = false
	summary_label.selection_enabled = true
	summary_label.custom_minimum_size = Vector2(0.0, 92.0)
	summary_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_label.add_theme_font_size_override("normal_font_size", 16)
	summary_label.add_theme_color_override("default_color", MedievalTheme.PARCHMENT_LIGHT)
	summary_label.add_theme_constant_override("line_separation", 4)
	summary_label.add_theme_constant_override("margin_left", 8)
	summary_label.add_theme_constant_override("margin_top", 6)
	summary_label.add_theme_constant_override("margin_right", 8)
	summary_label.add_theme_constant_override("margin_bottom", 6)
	summary_label.scroll_to_line(0)
	summary_scroll_frame.add_child(summary_label)

	menu_button = Button.new()
	menu_button.text = "MENU"

	menu_button.custom_minimum_size = Vector2(
		120.0,
		62.0
	)

	menu_button.size_flags_vertical = (
		Control.SIZE_SHRINK_CENTER
	)

	menu_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	menu_button.tooltip_text = (
		"Abra o menu principal sem alterar a vila."
	)

	bottom_row.add_child(menu_button)

	help_button = Button.new()
	help_button.text = "AJUDA"

	help_button.custom_minimum_size = Vector2(
		104.0,
		62.0
	)

	help_button.size_flags_vertical = (
		Control.SIZE_SHRINK_CENTER
	)

	help_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	help_button.tooltip_text = (
		"Reabra o guia de profissões, recursos, "
		+ "acontecimentos, construções e objetivos."
	)

	bottom_row.add_child(help_button)

	save_button = Button.new()
	save_button.text = "SALVAR\nCARREGAR"

	save_button.custom_minimum_size = Vector2(
		160.0,
		62.0
	)

	save_button.size_flags_vertical = (
		Control.SIZE_SHRINK_CENTER
	)

	save_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	save_button.tooltip_text = (
		"Salve a campanha atual ou carregue "
		+ "uma campanha anterior."
	)

	bottom_row.add_child(save_button)

	advance_day_button = Button.new()
	advance_day_button.text = "ENCERRAR O DIA"

	advance_day_button.custom_minimum_size = Vector2(
		230.0,
		62.0
	)

	advance_day_button.size_flags_vertical = (
		Control.SIZE_SHRINK_CENTER
	)

	advance_day_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	advance_day_button.tooltip_text = (
		"Calcula a produção, o consumo "
		+ "e as consequências do dia."
	)

	bottom_row.add_child(advance_day_button)

	return bottom_panel


func _create_event_window() -> void:
	if is_instance_valid(event_window):
		return

	event_window = EVENT_WINDOW_SCRIPT.new()
	add_child(event_window)


func _create_campaign_window() -> void:
	if is_instance_valid(campaign_window):
		return

	campaign_window = CAMPAIGN_WINDOW_SCRIPT.new()
	add_child(campaign_window)

	campaign_window.restart_requested.connect(
		_on_campaign_restart_requested
	)
	campaign_window.free_play_requested.connect(
		_on_free_play_requested
	)
	campaign_window.closed.connect(
		_on_campaign_window_closed
	)


func _create_recruitment_window() -> void:
	if is_instance_valid(recruitment_window):
		return
	recruitment_window = RECRUITMENT_WINDOW_SCRIPT.new()
	add_child(recruitment_window)
	recruitment_window.species_selected.connect(
		_on_recruitment_species_selected
	)
	recruitment_window.candidate_selected.connect(
		_on_recruitment_candidate_selected
	)


func _on_campaign_window_closed() -> void:
	call_deferred("_open_pending_recruitment_if_available")


func _open_pending_recruitment_if_available() -> void:
	if (
		is_instance_valid(main_menu)
		and main_menu.is_menu_visible()
	):
		return
	if (
		is_instance_valid(campaign_window)
		and campaign_window.is_window_visible()
	):
		return
	if not GameManager.has_pending_recruitment_offer():
		return
	if not is_instance_valid(recruitment_window):
		_create_recruitment_window()
	recruitment_window.show_offer(
		GameManager.get_pending_recruitment_offer()
	)


func _on_recruitment_species_selected(species_name: String) -> void:
	var result: Dictionary = GameManager.select_recruitment_species(species_name)
	var success: bool = bool(result.get("success", false))
	if not success:
		_set_summary(
			String(result.get("message", "Não foi possível escolher a espécie.")),
			true
		)
		return
	var offer_value: Variant = result.get("offer", {})
	if offer_value is Dictionary and is_instance_valid(recruitment_window):
		recruitment_window.show_offer(offer_value as Dictionary)


func _on_recruitment_candidate_selected(candidate_id: String) -> void:
	var result: Dictionary = GameManager.accept_recruitment_candidate(candidate_id)
	var success: bool = bool(result.get("success", false))
	_set_summary(
		String(result.get("message", "Não foi possível recrutar a carta.")),
		not success
	)
	if success and is_instance_valid(recruitment_window):
		recruitment_window.hide_window()
		AudioManager.play_sfx("council_change")


func _on_recruitment_offer_ready(_offer_data: Dictionary) -> void:
	call_deferred("_open_pending_recruitment_if_available")


func _on_recruitment_status_changed(status_data: Dictionary) -> void:
	if String(status_data.get("state", "")) != "blocked":
		return
	var message: String = String(status_data.get("message", ""))
	if not message.is_empty():
		_set_summary(message, false)



func _create_season_hint_window() -> void:
	if is_instance_valid(season_hint_window):
		return

	season_hint_window = SEASON_HINT_WINDOW_SCRIPT.new()
	add_child(season_hint_window)


func _create_building_window() -> void:
	if is_instance_valid(building_window):
		return

	building_window = BUILDING_WINDOW_SCRIPT.new()
	add_child(building_window)

	building_window.upgrade_requested.connect(
		_on_building_upgrade_requested
	)
	building_window.construction_cancel_requested.connect(
		_on_construction_cancel_requested
	)
	building_window.construction_move_requested.connect(
		_on_construction_move_requested
	)


func _create_save_window() -> void:
	if is_instance_valid(save_window):
		return

	save_window = SAVE_WINDOW_SCRIPT.new()
	add_child(save_window)

	save_window.save_requested.connect(
		_on_save_requested
	)

	save_window.load_requested.connect(
		_on_load_requested
	)

	save_window.delete_requested.connect(
		_on_delete_save_requested
	)


func _create_main_menu() -> void:
	if is_instance_valid(main_menu):
		return

	main_menu = MAIN_MENU_SCRIPT.new()
	add_child(main_menu)

	main_menu.continue_requested.connect(
		_on_main_menu_continue_requested
	)

	main_menu.new_campaign_requested.connect(
		_on_main_menu_new_campaign_requested
	)

	main_menu.load_requested.connect(
		_on_main_menu_load_requested
	)

	main_menu.tutorial_requested.connect(
		_on_main_menu_tutorial_requested
	)

	main_menu.quit_requested.connect(
		_on_main_menu_quit_requested
	)


func _create_tutorial_window() -> void:
	if is_instance_valid(tutorial_window):
		return

	tutorial_window = TUTORIAL_WINDOW_SCRIPT.new()
	if not is_instance_valid(tutorial_window):
		push_error(
			"Não foi possível criar a janela de tutorial."
		)
		return

	add_child(tutorial_window)

	tutorial_window.closed.connect(
		_on_tutorial_closed
	)


func _ensure_tutorial_window() -> bool:
	if not is_instance_valid(tutorial_window):
		_create_tutorial_window()

	if is_instance_valid(tutorial_window):
		return true

	push_error(
		"A janela de tutorial não está disponível."
	)
	return false


func _create_council_window() -> void:
	if is_instance_valid(council_window):
		return

	council_window = COUNCIL_WINDOW_SCRIPT.new()
	add_child(council_window)
	council_window.swap_requested.connect(
		_on_council_swap_requested
	)


func _create_councillor_history_window() -> void:
	if is_instance_valid(councillor_history_window):
		return
	councillor_history_window = (
		COUNCILLOR_HISTORY_WINDOW_SCRIPT.new() as CouncillorHistoryWindow
	)
	add_child(councillor_history_window)


func _create_forecast_details_window() -> void:
	if is_instance_valid(forecast_details_window):
		return
	forecast_details_window = (
		FORECAST_DETAILS_WINDOW_SCRIPT.new() as ForecastDetailsWindow
	)
	add_child(forecast_details_window)


func _on_forecast_details_pressed() -> void:
	if not is_instance_valid(forecast_details_window):
		_create_forecast_details_window()
	forecast_details_window.open_window(
		GameManager.calculate_next_day_forecast()
	)


func _create_village_window() -> void:
	if is_instance_valid(village_window):
		return

	village_window = (
		VILLAGE_WINDOW_SCRIPT.new()
		as VillageWindow
	)

	if not is_instance_valid(village_window):
		push_error(
			"Não foi possível criar a janela ampliada da vila."
		)
		return

	add_child(village_window)
	village_window.building_requested.connect(
		_on_village_building_requested
	)
	village_window.council_member_requested.connect(
		_on_village_council_member_requested
	)


func _create_dialogue_window() -> void:
	if is_instance_valid(dialogue_window):
		return

	dialogue_window = DIALOGUE_WINDOW_SCRIPT.new() as VillageDialogueWindow

	if not is_instance_valid(dialogue_window):
		push_error("Não foi possível criar a caixa de diálogo.")
		return

	add_child(dialogue_window)
	dialogue_window.dialogue_closed.connect(
		_on_dialogue_closed
	)
	dialogue_window.choice_selected.connect(
		_on_dialogue_choice_selected
	)


func _create_diagnostics_window() -> void:
	if is_instance_valid(diagnostics_window):
		return

	diagnostics_window = (
		DIAGNOSTICS_WINDOW_SCRIPT.new() as VillageDiagnosticsWindow
	)

	if not is_instance_valid(diagnostics_window):
		push_error("Não foi possível criar o diagnóstico interno.")
		return

	add_child(diagnostics_window)
	diagnostics_window.dialogue_test_requested.connect(
		_on_diagnostic_dialogue_test_requested
	)
	diagnostics_window.story_test_requested.connect(
		_on_diagnostic_story_test_requested
	)
	diagnostics_window.relationship_test_requested.connect(
		_open_relationships_test_window
	)


func _create_relationships_window() -> void:
	if is_instance_valid(relationships_window):
		return
	relationships_window = RELATIONSHIPS_WINDOW_SCRIPT.new() as VillageRelationshipsWindow
	if not is_instance_valid(relationships_window):
		push_error("Não foi possível criar a janela de relações.")
		return
	add_child(relationships_window)
	relationships_window.conversation_requested.connect(
		_open_relationship_conversation
	)
	relationships_window.personal_event_requested.connect(
		_open_relationship_personal_event
	)
	relationships_window.date_requested.connect(
		_open_relationship_date
	)
	relationships_window.closed.connect(
		_on_relationships_window_closed
	)


func _create_profile_setup_window() -> void:
	if is_instance_valid(profile_setup_window):
		return
	profile_setup_window = PROFILE_SETUP_WINDOW_SCRIPT.new() as VillageProfileSetupWindow
	if not is_instance_valid(profile_setup_window):
		push_error("Não foi possível criar a configuração do Prefeito.")
		return
	add_child(profile_setup_window)
	profile_setup_window.profile_confirmed.connect(
		_on_profile_setup_confirmed
	)
	profile_setup_window.profile_cancelled.connect(
		_on_profile_setup_cancelled
	)


func _open_relationships_window() -> void:
	AudioManager.play_ui("window_open", false)
	if not is_instance_valid(relationships_window):
		_create_relationships_window()
	if is_instance_valid(relationships_window):
		if is_instance_valid(building_visuals):
			building_visuals.set_simulation_active(false)
			relationships_window.show_relationships(
				GameManager.get_relationship_overview(),
				GameManager.current_day,
				false,
				GameManager.get_npc_relationship_overview()
			)
		_request_contextual_tutorial(
			"area_relationships",
			relationships_window
		)


func _open_relationships_test_window() -> void:
	if not is_instance_valid(relationships_window):
		_create_relationships_window()
	if is_instance_valid(relationships_window):
		if is_instance_valid(building_visuals):
			building_visuals.set_simulation_active(false)
			relationships_window.show_relationships(
				GameManager.get_relationship_test_overview(),
				GameManager.current_day,
				true,
				GameManager.get_npc_relationship_overview()
			)


func _on_relationships_window_closed() -> void:
	if is_instance_valid(building_visuals):
		building_visuals.set_simulation_active(
			is_instance_valid(village_frame)
			and village_frame.is_visible_in_tree()
			and not GameManager.has_active_event()
			and not GameManager.has_pending_story_dialogue()
		)


func _on_council_button_pressed() -> void:
	AudioManager.play_ui("window_open", false)
	if not is_instance_valid(council_window):
		_create_council_window()
	council_window.open_window(GameManager.get_council_overview())
	_request_contextual_tutorial(
		"area_council",
		council_window
	)


func _on_council_swap_requested(active_id: String, reserve_id: String) -> void:
	var result: Dictionary = GameManager.swap_council_member(active_id, reserve_id)
	var success: bool = bool(result.get("success", false))
	_set_summary(String(result.get("message", "Troca concluída.")), not success)
	if success:
		AudioManager.play_sfx("council_change")


func _connect_game_signals() -> void:
	GameManager.resources_changed.connect(
		_on_resources_changed
	)

	GameManager.villagers_changed.connect(
		_rebuild_villager_list
	)
	GameManager.council_changed.connect(_on_council_changed)
	GameManager.recruitment_offer_ready.connect(
		_on_recruitment_offer_ready
	)
	GameManager.recruitment_status_changed.connect(
		_on_recruitment_status_changed
	)
	GameManager.founder_memory_changed.connect(
		_on_founder_memory_changed
	)

	GameManager.day_advanced.connect(
		_on_day_advanced
	)

	GameManager.village_event_started.connect(
		_on_village_event_started
	)

	GameManager.village_event_resolved.connect(
		_on_village_event_resolved
	)

	GameManager.campaign_progress_changed.connect(
		_on_campaign_progress_changed
	)

	GameManager.campaign_checkpoint_completed.connect(
		_on_campaign_checkpoint_completed
	)

	GameManager.campaign_finished.connect(
		_on_campaign_finished
	)

	GameManager.free_play_started.connect(
		_on_free_play_started
	)

	GameManager.season_hint_available.connect(
		_on_season_hint_available
	)

	GameManager.buildings_changed.connect(
		_on_buildings_changed
	)

	GameManager.save_state_changed.connect(
		_on_save_state_changed
	)

	GameManager.game_loaded.connect(
		_on_game_loaded
	)

	GameManager.story_dialogue_requested.connect(
		_on_story_dialogue_requested
	)
	GameManager.story_npc_recruited.connect(
		_on_story_npc_recruited
	)
	GameManager.story_chapter_completed.connect(
		_on_story_chapter_completed
	)
	GameManager.relationships_changed.connect(
		_on_relationships_changed
	)
	GameManager.npc_relationship_dialogue_requested.connect(
		_on_npc_relationship_dialogue_requested
	)
	GameManager.npc_relationships_changed.connect(
		_on_npc_relationships_changed
	)
	GameManager.village_visual_feedback_requested.connect(
		_on_village_visual_feedback_requested
	)
	GameManager.councillor_level_dialogue_requested.connect(
		_on_councillor_level_dialogue_requested
	)
	GameManager.councillor_history_changed.connect(
		_on_councillor_history_changed
	)
	GameManager.councillor_opportunities_changed.connect(
		_on_councillor_opportunities_changed
	)

	advance_day_button.pressed.connect(
		_on_advance_day_pressed
	)

	campaign_button.pressed.connect(
		_on_campaign_button_pressed
	)

	building_button.pressed.connect(
		_on_building_button_pressed
	)

	save_button.pressed.connect(
		_on_save_button_pressed
	)

	menu_button.pressed.connect(
		_on_menu_button_pressed
	)

	help_button.pressed.connect(
		_on_help_button_pressed
	)


func _on_village_event_started(
	event_data: Dictionary
) -> void:
	if not is_instance_valid(event_window):
		_create_event_window()

	if (
		is_instance_valid(building_window)
		and building_window.is_window_visible()
	):
		building_window.hide_window()

	if (
		is_instance_valid(save_window)
		and save_window.is_window_visible()
	):
		save_window.hide_window()

	advance_day_button.disabled = true

	forecast_status_label.text = (
		"ACONTECIMENTO PENDENTE"
	)

	forecast_status_label.add_theme_color_override(
		"font_color",
		MedievalTheme.GOLD
	)

	forecast_status_label.tooltip_text = (
		"Resolva o acontecimento antes "
		+ "de encerrar outro dia."
	)

	event_window.show_event(
		event_data,
		selected_villager
	)


func _on_village_event_resolved(
	result_text: String
) -> void:
	if is_instance_valid(event_window):
		event_window.hide_event()

	if (
		is_instance_valid(season_hint_window)
		and season_hint_window.is_window_visible()
	):
		season_hint_window.hide_window()

	_refresh_advance_day_state()

	var displayed_result: String = result_text

	if (
		GameManager.current_day <= 3
		and is_instance_valid(tutorial_manager)
		and not tutorial_manager.has_seen_hint(
			"first_event_resolved"
		)
	):
		tutorial_manager.mark_hint_seen(
			"first_event_resolved"
		)

		displayed_result += (
			"\nDica: ajuste as profissões conforme o "
			+ "resultado antes de encerrar o próximo dia."
		)

	_set_summary(
		displayed_result,
		true
	)

	_update_forecast()


func _on_campaign_button_pressed() -> void:
	AudioManager.play_ui("window_open", false)
	if not is_instance_valid(campaign_window):
		_create_campaign_window()

	if (
		is_instance_valid(building_window)
		and building_window.is_window_visible()
	):
		building_window.hide_window()

	if (
		is_instance_valid(save_window)
		and save_window.is_window_visible()
	):
		save_window.hide_window()

	campaign_window.show_progress(
		GameManager.get_campaign_progress()
	)
	_request_contextual_tutorial(
		"area_campaign",
		campaign_window
	)


func _on_building_button_pressed() -> void:
	AudioManager.play_ui("window_open", false)
	if not is_instance_valid(building_window):
		_create_building_window()

	if (
		is_instance_valid(campaign_window)
		and campaign_window.is_window_visible()
	):
		campaign_window.hide_window()

	if (
		is_instance_valid(save_window)
		and save_window.is_window_visible()
	):
		save_window.hide_window()

	if (
		is_instance_valid(village_window)
		and village_window.is_window_visible()
	):
		village_window.hide_window()

	building_window.show_buildings(
		GameManager.get_building_state()
	)
	_request_contextual_tutorial(
		"area_buildings",
		building_window
	)


func _on_expand_village_button_pressed() -> void:
	AudioManager.play_ui("window_open", false)
	if not is_instance_valid(village_window):
		_create_village_window()

	_sync_village_visuals()
	village_window.show_village()
	_request_contextual_tutorial(
		"area_village_expanded",
		village_window
	)


func _on_village_building_requested(
	_building_id: String
) -> void:
	if (
		is_instance_valid(village_window)
		and village_window.is_window_visible()
	):
		village_window.hide_window()
	_on_building_button_pressed()


func _on_village_council_member_requested(
	representative_id: String
) -> void:
	var villager: Villager = _find_villager_by_representative_id(
		representative_id
	)

	if not is_instance_valid(villager):
		return

	var card: VillagerCard = (
		villager_cards_by_id.get(
			villager.get_instance_id(),
			null
		) as VillagerCard
	)

	if not is_instance_valid(card):
		return

	if selected_villager == villager:
		_open_dialogue_for_villager(villager)
		return

	_select_villager(
		villager,
		card,
		true
	)


func _find_villager_by_representative_id(
	representative_id: String
) -> Villager:
	for villager: Villager in GameManager.villagers:
		if (
			is_instance_valid(villager)
			and villager.representative_id == representative_id
		):
			return villager

	return null


func _on_building_upgrade_requested(
	building_id: String,
	variant_id: String
) -> void:
	var resolution: Dictionary = GameManager.upgrade_building(
		building_id,
		variant_id
	)
	if bool(resolution.get("queued", false)):
		return
	_show_building_action_error(
		String(
			resolution.get(
				"reason",
				"Não foi possível adicionar a obra à fila."
			)
		)
	)


func _on_construction_cancel_requested(order_id: String) -> void:
	var resolution: Dictionary = GameManager.cancel_construction(order_id)
	if bool(resolution.get("cancelled", false)):
		return
	_show_building_action_error(
		String(resolution.get("reason", "Não foi possível cancelar a obra."))
	)


func _on_construction_move_requested(
	order_id: String,
	direction: int
) -> void:
	var resolution: Dictionary = GameManager.reorder_construction(
		order_id,
		direction
	)
	if bool(resolution.get("reordered", false)):
		return
	_show_building_action_error(
		String(resolution.get("reason", "Não foi possível reordenar a fila."))
	)


func _show_building_action_error(message: String) -> void:
	if not is_instance_valid(building_window):
		return
	building_window.refresh_state(GameManager.get_building_state())
	building_window.show_feedback(message, false)


func _on_buildings_changed(
	building_data: Dictionary,
	result_text: String
) -> void:
	_update_building_interface(
		building_data,
		true
	)

	for card_value: Variant in villager_cards_by_id.values():
		var card: VillagerCard = (
			card_value as VillagerCard
		)

		if is_instance_valid(card):
			card.refresh_production_preview()

	var displayed_result: String = result_text

	if (
		not displayed_result.is_empty()
		and GameManager.current_day <= 3
		and is_instance_valid(tutorial_manager)
		and not tutorial_manager.has_seen_hint(
			"first_building_upgrade"
		)
	):
		tutorial_manager.mark_hint_seen(
			"first_building_upgrade"
		)

		displayed_result += (
			"\nDica: o custo já foi pago. A obra começa a partir do próximo dia "
			+ "quando houver canteiro, e o benefício só aparece após a conclusão."
		)

	if not displayed_result.is_empty():
		_set_summary(
			displayed_result,
			true
		)

		if is_instance_valid(building_window):
			building_window.show_feedback(
				displayed_result,
				true
			)

	_update_forecast()


func _show_startup_menu() -> void:
	if not is_instance_valid(main_menu):
		return

	var entering_new_campaign: bool = (
		GameManager.consume_enter_game_after_reload()
	)

	if entering_new_campaign:
		main_menu.hide_menu()
		var campaign_season: Dictionary = GameManager.get_current_season()
		AudioManager.enter_game(String(campaign_season.get("id", "spring")))

		if GameManager.has_pending_story_dialogue():
			tutorial_after_story = (
				is_instance_valid(tutorial_manager)
				and tutorial_manager.should_auto_show_intro()
			)
			call_deferred("_request_pending_story_dialogue")
			return

		if GameManager.has_pending_recruitment_offer():
			call_deferred("_open_pending_recruitment_if_available")
			return

		if (
			is_instance_valid(tutorial_manager)
			and tutorial_manager.should_auto_show_intro()
		):
			call_deferred(
				"_show_campaign_tutorial",
				false,
				false,
				true
			)

		return

	AudioManager.enter_menu(false)
	main_menu.show_menu(
		GameManager.get_save_overview(),
		false
	)


func _on_menu_button_pressed() -> void:
	AudioManager.play_ui("window_open", false)
	if not is_instance_valid(main_menu):
		_create_main_menu()

	if (
		is_instance_valid(recruitment_window)
		and recruitment_window.is_window_visible()
	):
		return

	if (
		is_instance_valid(campaign_window)
		and campaign_window.is_window_visible()
	):
		campaign_window.hide_window()

	if (
		is_instance_valid(building_window)
		and building_window.is_window_visible()
	):
		building_window.hide_window()

	if (
		is_instance_valid(save_window)
		and save_window.is_window_visible()
	):
		save_window.hide_window()

	AudioManager.enter_menu(true)
	main_menu.show_menu(
		GameManager.get_save_overview(),
		true
	)


func _on_main_menu_continue_requested() -> void:
	_load_game_from_main_menu()


func _on_main_menu_load_requested() -> void:
	_load_game_from_main_menu()


func _on_main_menu_tutorial_requested(
	opened_from_game: bool
) -> void:
	_show_campaign_tutorial(
		true,
		opened_from_game,
		false,
		true
	)


func _load_game_from_main_menu() -> void:
	var result: Dictionary = GameManager.load_game()

	if bool(result.get("success", false)):
		return

	if not is_instance_valid(main_menu):
		return

	main_menu.refresh_save_overview(
		GameManager.get_save_overview()
	)

	main_menu.show_feedback(
		String(
			result.get(
				"message",
				"Não foi possível carregar a campanha."
			)
		),
		false
	)


func _on_main_menu_new_campaign_requested() -> void:
	if not is_instance_valid(profile_setup_window):
		_create_profile_setup_window()
	profile_setup_return_to_game = (
		is_instance_valid(main_menu)
		and main_menu.opened_from_game
	)
	if is_instance_valid(main_menu):
		main_menu.hide_menu()
	if is_instance_valid(profile_setup_window):
		profile_setup_window.show_setup()


func _on_profile_setup_confirmed(
	player_name: String,
	gender_id: String,
	difficulty_id: String,
	village_name: String,
	campaign_seed: int
) -> void:
	GameManager.start_new_campaign(
		player_name,
		gender_id,
		difficulty_id,
		village_name,
		campaign_seed
	)
	get_tree().reload_current_scene()


func _on_profile_setup_cancelled() -> void:
	if is_instance_valid(main_menu):
		AudioManager.enter_menu(profile_setup_return_to_game)
		main_menu.show_menu(
			GameManager.get_save_overview(),
			profile_setup_return_to_game
		)
	profile_setup_return_to_game = false


func _on_main_menu_quit_requested() -> void:
	get_tree().quit()


func _on_help_button_pressed() -> void:
	AudioManager.play_ui("window_open", false)
	_show_campaign_tutorial(
		false,
		false,
		false,
		true
	)


func _show_campaign_tutorial(
	return_to_menu: bool,
	menu_opened_from_game: bool,
	started_automatically: bool,
	show_full_guide: bool = false
) -> void:
	if not _ensure_tutorial_window():
		return

	if is_instance_valid(main_menu):
		main_menu.hide_menu()

	if (
		is_instance_valid(campaign_window)
		and campaign_window.is_window_visible()
	):
		campaign_window.hide_window()

	if (
		is_instance_valid(building_window)
		and building_window.is_window_visible()
	):
		building_window.hide_window()

	if (
		is_instance_valid(save_window)
		and save_window.is_window_visible()
	):
		save_window.hide_window()

	if (
		is_instance_valid(relationships_window)
		and relationships_window.is_window_visible()
	):
		relationships_window.hide_window()

	if (
		is_instance_valid(council_window)
		and council_window.is_window_visible()
	):
		council_window.hide_window()

	tutorial_return_to_menu = return_to_menu
	tutorial_menu_opened_from_game = menu_opened_from_game
	tutorial_started_automatically = started_automatically
	tutorial_is_full_guide = show_full_guide
	tutorial_context_hint_id = ""

	var steps: Array[Dictionary] = (
		_build_full_guide_steps()
		if show_full_guide
		else _build_basic_tutorial_steps()
	)

	tutorial_window.show_tutorial(steps)


func _show_contextual_tutorial(
	hint_id: String,
	target: Control
) -> void:
	if hint_id.is_empty():
		return
	if not is_instance_valid(tutorial_manager):
		return
	if tutorial_manager.has_seen_hint(hint_id):
		return
	if not is_instance_valid(target):
		return
	if not _ensure_tutorial_window():
		return
	if (
		is_instance_valid(tutorial_window)
		and tutorial_window.is_window_visible()
	):
		return

	var steps: Array[Dictionary] = (
		_build_contextual_tutorial_steps(
			hint_id,
			target
		)
	)
	if steps.is_empty():
		return

	tutorial_context_hint_id = hint_id
	tutorial_return_to_menu = false
	tutorial_menu_opened_from_game = false
	tutorial_started_automatically = false
	tutorial_is_full_guide = false
	tutorial_window.show_tutorial(steps)


func _request_contextual_tutorial(
	hint_id: String,
	target: Control
) -> void:
	if not is_instance_valid(tutorial_manager):
		return
	if tutorial_manager.has_seen_hint(hint_id):
		return
	call_deferred(
		"_show_contextual_tutorial",
		hint_id,
		target
	)


func _on_tutorial_closed(
	completed: bool
) -> void:
	if not tutorial_context_hint_id.is_empty():
		if is_instance_valid(tutorial_manager):
			tutorial_manager.mark_hint_seen(
				tutorial_context_hint_id
			)
		tutorial_context_hint_id = ""
		_set_summary(
			"Dica contextual registrada. O Guia do Jogo permanece disponível em AJUDA.",
			false
		)
		call_deferred("_resume_pending_mandatory_content")
		return

	if (
		not tutorial_is_full_guide
		and is_instance_valid(tutorial_manager)
	):
		tutorial_manager.mark_intro_seen()

	var should_resume_game: bool = not tutorial_return_to_menu
	if tutorial_return_to_menu:
		if not is_instance_valid(main_menu):
			_create_main_menu()

		AudioManager.enter_menu(tutorial_menu_opened_from_game)
		main_menu.show_menu(
			GameManager.get_save_overview(),
			tutorial_menu_opened_from_game
		)
	else:
		var message: String = ""
		if tutorial_is_full_guide:
			message = (
				"Guia do Jogo fechado. Ele pode ser reaberto "
				+ "a qualquer momento em AJUDA."
			)
		elif completed:
			message = (
				"Tutorial básico concluído. Explore as áreas "
				+ "para receber explicações contextuais."
			)
		else:
			message = (
				"Tutorial encerrado. Use AJUDA para consultar "
				+ "o Guia do Jogo completo."
			)

		_set_summary(
			message,
			not tutorial_started_automatically
		)

	tutorial_return_to_menu = false
	tutorial_menu_opened_from_game = false
	tutorial_started_automatically = false
	tutorial_is_full_guide = false
	if should_resume_game:
		call_deferred("_resume_pending_mandatory_content")


func _build_basic_tutorial_steps() -> Array[Dictionary]:
	var steps: Array[Dictionary] = []

	steps.append(
		{
			"section": "INTRODUÇÃO DA CAMPANHA",
			"title": "BEM-VINDO À SUA VILA",
			"description": (
				"Você administrará esta comunidade por 120 dias, "
				+ "atravessando quatro estações. Cada decisão "
				+ "afeta alimentação, material, felicidade e "
				+ "população. A dificuldade escolhida altera metas, "
				+ "reservas, atração e tolerância a crises. "
				+ "Após a vitória, o Modo Livre será liberado."
			),
			"tip": (
				"Não existe uma única estratégia correta: "
				+ "equilíbrio e adaptação são mais importantes."
			),
			"target": village_frame,
			"side": "left"
		}
	)

	steps.append(
		{
			"section": "META DA COMUNIDADE",
			"title": "SEIS AVALIAÇÕES",
			"description": (
				"Abra AVALIAÇÃO para acompanhar as quatro metas obrigatórias "
				+ "— população, alimentação, material e felicidade — dos dias "
				+ "20, 40, 60, 80, 100 e 120. São 24 metas ao longo da campanha."
			),
			"tip": (
				"A próxima auditoria mostra os números completos; as futuras "
				+ "aparecem como prévia. Falhar qualquer meta encerra a campanha."
			),
			"target": campaign_button,
			"side": "bottom"
		}
	)

	steps.append(
		{
			"section": "RECURSOS E PREVISÃO",
			"title": "LEIA O PRÓXIMO DIA",
			"description": (
				"A barra superior mostra os valores atuais e "
				+ "a previsão do próximo dia. Verde indica ganho, "
				+ "amarelo pede atenção e vermelho anuncia uma "
				+ "situação crítica. A previsão já considera estação, "
				+ "passivas, sinergias e concentração profissional."
			),
			"tip": (
				"Clique em DETALHAR MODIFICADORES para conferir "
				+ "a composição completa antes de encerrar o dia."
			),
			"target": top_bar,
			"side": "bottom"
		}
	)

	steps.append(
		{
			"section": "POPULAÇÃO E MORADIA",
			"title": "ATRAÇÃO E ABANDONO",
			"description": (
				"É preciso ter vaga, reservas e a felicidade mínima da "
				+ "dificuldade: 52 na Acolhedora, 55 na Moderada e 58 "
				+ "na Difícil. Acolhedora atrai após 1 dia favorável; "
				+ "Moderada e Difícil, após 2."
			),
			"tip": (
				"Os habitantes comuns plantam e negociam, mas "
				+ "também consomem recursos. Observe os medidores "
				+ "de atração e risco sob POPULAÇÃO."
			),
			"target": population_label,
			"side": "bottom"
		}
	)

	steps.append(
		{
			"section": "REPRESENTANTES",
			"title": "ATRIBUTOS E PROFISSÕES",
			"description": (
				"As quatro cartas são representantes da população, "
				+ "cada um com atributos diferentes. Escolha uma "
				+ "profissão adequada e "
				+ "observe como a previsão muda imediatamente."
			),
			"tip": (
				"Cada carta começa com 10 pontos entre FOR, INT, CAR e AGI. "
				+ "Na passiva, verde significa ATIVA, amarelo CONDICIONAL e "
				+ "cinza INATIVA; a condição é permanente e não pode ser trocada."
			),
			"target": residents_panel,
			"side": "right"
		}
	)

	steps.append(
		{
			"section": "DESENVOLVIMENTO",
			"title": "MORADIA E CONSTRUÇÕES",
			"description": (
				"Casas e melhorias entram numa fila compartilhada. O custo é pago "
				+ "ao planejar; a obra começa a partir do dia seguinte quando houver "
				+ "canteiro. Casas e nível 1 levam um dia, nível 2 leva dois e nível 3 leva três. "
				+ "Ao planejar o nível 3 das cinco construções únicas, escolha uma de duas "
				+ "builds finais. A escolha se torna irreversível quando a obra é concluída."
			),
			"tip": (
				"A capacidade é 1 + parte inteira da população dividida por 20, até quatro. "
				+ "A fila pode ser reordenada e mostra se a conclusão antecede a avaliação. "
				+ "Cancelar a obra final antes da conclusão permite escolher a outra build depois."
			),
			"target": building_button,
			"side": "bottom"
		}
	)

	steps.append(
		{
			"section": "ACONTECIMENTOS",
			"title": "DECISÕES INESPERADAS",
			"description": (
				"Depois de encerrar um dia, um acontecimento pode "
				+ "aparecer. Compare custos, efeitos e chances. "
				+ "Quando houver um teste, o habitante selecionado "
				+ "poderá mudar a probabilidade de sucesso."
			),
			"tip": (
				"A carta responsável também pode alterar chance, perdas ou relação "
				+ "por meio de sua passiva. O registro informa quando isso acontece."
			),
			"target": summary_area,
			"side": "top"
		}
	)

	steps.append(
		{
			"section": "CICLO DIÁRIO",
			"title": "QUANDO ESTIVER PRONTO",
			"description": (
				"ENCERRAR O DIA aplica produção, consumo, "
				+ "manutenção e felicidade. O botão é bloqueado "
				+ "enquanto um acontecimento precisa ser resolvido "
				+ "ou após o fim da campanha."
			),
			"tip": (
				"Antes de clicar, revise profissões, previsão e "
				+ "investimentos. No outono, priorize reservas de "
				+ "alimentação para atravessar o inverno."
			),
			"target": advance_day_button,
			"side": "left"
		}
	)

	return steps


func _build_full_guide_steps() -> Array[Dictionary]:
	var steps: Array[Dictionary] = []

	steps.append(_make_guide_step(
		"VISÃO GERAL",
		"CAMPANHA E OBJETIVO",
		"Administre a vila durante 120 dias e atravesse primavera, verão, outono e inverno. Produção, consumo, felicidade, população, construções, acontecimentos, capítulos e relações avançam juntos. Falhar numa avaliação encerra a campanha; vencer o Dia 120 libera o Modo Livre.",
		"Consulte a previsão antes de encerrar cada dia e prepare as metas com antecedência."
	))

	steps.append(_make_guide_step(
		"PERFIL DO PREFEITO",
		"NOME, GÊNERO E PAPEL",
		"Uma nova campanha permite escolher nome, gênero masculino ou feminino e dificuldade. O cargo permanece Prefeito em todas as interfaces. O protagonista é um Golem de Pedregulho com a habilidade Prefeito Perfeito, que revela custos, riscos, requisitos e probabilidades sem escolher pelo jogador.",
		"Nome, gênero e dificuldade são salvos e aparecem no menu de carregamento."
	))

	steps.append(_make_guide_step(
		"DIFICULDADE",
		"ACOLHEDORA, MODERADA E DIFÍCIL",
		"As três dificuldades usam metas populacionais menores. Acolhedora exige um habitante a menos que a Moderada, começa com reservas maiores e tolera quatro dias seguidos sem um recurso antes da derrota. Moderada é o equilíbrio principal. Difícil mantém metas e pressão maiores, mas também recebeu a redução populacional. Produção, consumo, manutenção e custos de construção permanecem iguais nas três dificuldades. A escolha é permanente para aquela campanha e não altera a frequência dos acontecimentos aleatórios.",
		"Acolhedora oferece mais espaço para história e experimentação; Difícil exige preparação desde a primavera."
	))

	steps.append(_make_guide_step(
		"RECURSOS",
		"ALIMENTAÇÃO, MATERIAL E FELICIDADE",
		"Alimentação mantém a população; material paga casas, obras e manutenção; felicidade influencia atração, abandono e segurança social. A barra superior mostra o valor atual e a variação prevista. A previsão já incorpora passivas, sinergias automáticas, concentração profissional, projetos, estação e dificuldade.",
		"Abra DETALHAR MODIFICADORES para entender cada parcela antes de encerrar o dia."
	))

	steps.append(_make_guide_step(
		"POPULAÇÃO",
		"VAGAS, ATRAÇÃO E ABANDONO",
		"Casas determinam o limite populacional. Acolhedora exige um dia favorável para uma chegada e quatro preocupantes para abandono; Moderada usa dois e três; Difícil usa dois e dois. A felicidade mínima para atrair é 52, 55 e 58, respectivamente. Também é necessário ter vaga e reservas. Especialistas da história passam a viver na comunidade.",
		"Crescer cedo demais aumenta o consumo; crescer tarde demais reduz produção e progresso."
	))

	steps.append(_make_guide_step(
		"REPRESENTANTES",
		"ATRIBUTOS E PROFISSÕES",
		"As quatro cartas ativas mostram retrato, nome, atributos, nível, XP e passiva. Cada dia ativo concede 2 XP; o responsável por resolver um acontecimento recebe mais 20 XP; cada marco pessoal de 100 unidades de alimentação, material ou felicidade concede 10 XP. Ao subir de nível, a carta recebe um ponto manual e abre uma conversa especial. O marcador vermelho +N mostra pontos pendentes; expanda a carta para distribuí-los e abrir a FICHA HISTÓRICA. O marcador ! aparece somente quando o representante traz uma decisão que inicia um projeto de dois ou três dias com efeitos reais na economia. Esses assuntos dependem da profissão e um mesmo caso narrativo não se repete na campanha.",
		"Distribua profissões para cobrir as necessidades atuais; mudar funções também pode revelar assuntos ainda não encontrados."
	))

	steps.append(_make_guide_step(
		"PASSIVAS E COMPOSIÇÃO",
		"CONDIÇÕES, SINERGIAS E CONCENTRAÇÃO",
		"Cada carta possui uma passiva permanente com condição explícita. O estado aparece como ATIVA, CONDICIONAL ou INATIVA: verde indica efeito ativo; amarelo indica que a condição ainda não foi cumprida; cinza indica ausência de efeito naquela situação. O sistema escolhe automaticamente até duas sinergias de composição e cada carta participa de no máximo uma. Concentração profissional aplica uma penalidade geral sobre tudo que entra no estoque: profissões repetidas reduzem em 3%, 7% ou 12%, deixando 97% com duas cartas iguais, 93% com três e 88% com quatro.",
		"Não existe botão para ativar sinergias. Troque profissões e consulte o detalhamento da previsão para comparar o resultado final."
	))

	steps.append(_make_guide_step(
		"CONSELHO",
		"ATIVOS E RESERVA AMPLIADA",
		"O Conselho mantém quatro cartas ativas e uma reserva que cresce com os recrutamentos. A Mimo começa na reserva e nenhuma carta é apagada quando sai do grupo ativo. TROCAR CARTAS permite comparar atributos, nível, XP, personalidade e passiva antes de confirmar a substituição.",
		"Antes de uma decisão arriscada, confira qual representante está selecionado e ativo."
	))

	steps.append(_make_guide_step(
		"RECRUTAMENTO",
		"AVALIAÇÃO, RELAÇÃO E ESPÉCIE",
		"Uma avaliação aprovada garante uma escolha de recrutamento nos dias 20, 40, 60, 80, 100 e 120. Pontos de relacionamento não bloqueiam a escolha: o vínculo conhecido mais forte que ainda não originou outra oferta define a espécie. Quando espécies diferentes empatam na maior pontuação, o jogador escolhe entre elas. Em seguida aparecem duas candidatas da mesma espécie e apenas uma entra na reserva. Se mais de uma escolha estiver pendente, elas são apresentadas em sequência e nenhuma vaga antiga apaga ou bloqueia as seguintes.",
		"As cartas chegam nos níveis 2, 3, 4, 5, 6 e 6 conforme a vaga original, mesmo quando o recrutamento acontece atrasado."
	))

	steps.append(_make_guide_step(
		"OBRAS",
		"CASAS E MELHORIAS",
		"Casas e melhorias usam a mesma fila. O custo é pago ao entrar; obras pendentes podem ser reordenadas. Casas e nível 1 exigem um dia completo, nível 2 exige dois e nível 3 exige três. Ao iniciar o nível 3 de Celeiro, Serraria, Poço, Praça ou Muralha, duas builds finais são comparadas lado a lado. Cada uma possui efeito, aparência e interações próprias com acontecimentos. A build só se torna irreversível quando a obra termina; enquanto estiver na fila ou em andamento, o cancelamento permite escolher novamente no futuro. Canteiros simultâneos = 1 + parte inteira da população ÷ 20, limitados a quatro.",
		"O reembolso é de 100% antes do início e de 50% depois que o trabalho começa. Depois da conclusão, a janela registra a build, o dia e quantas vezes ela já ajudou em acontecimentos."
	))

	steps.append(_make_guide_step(
		"AVALIAÇÕES",
		"METAS DOS DIAS 20 A 120",
		"A campanha possui seis avaliações, cada uma com quatro metas obrigatórias: alimentação, material, felicidade e população. Isso forma 24 metas. A tela mostra todos os números da próxima auditoria e apenas um resumo das futuras. No dia especial, produção e custos entram primeiro, depois ocorre o capítulo e por fim Sanctuary-Void verifica as metas.",
		"Prefeito Perfeito classifica a tendência como segura, apertada, perigosa ou impossível no ritmo atual."
	))

	steps.append(_make_guide_step(
		"ACONTECIMENTOS",
		"ESCOLHAS, CUSTOS E TESTES",
		"Acontecimentos aleatórios podem surgir após o encerramento do dia. Cada resposta mostra custos e efeitos conhecidos. Algumas opções exigem profissão, construção, aliado ou recursos; outras usam atributos e uma chance de sucesso. Improvisador melhora testes arriscados, Protetor reduz perdas de falhas e Mediador pode favorecer relações quando a carta é responsável. O dia seguinte fica bloqueado até a decisão ser resolvida.",
		"Opções arriscadas não são automaticamente melhores; confira também a passiva da carta responsável."
	))

	steps.append(_make_guide_step(
		"MEMÓRIA DOS FUNDADORES",
		"DECISÕES QUE PODEM RETORNAR",
		"Cada um dos quatro fundadores recebe uma história pessoal compatível com seus traços. A primeira conversa registra sua decisão na Ficha Histórica. Nos dez dias concluídos seguintes, uma mudança real na vila pode fazer o assunto retornar: participação no Conselho, pressão sobre recursos, troca de composição ou avanço de uma construção. Se a condição não surgir, a história termina silenciosamente e nenhuma consequência tardia é aplicada.",
		"Personalidade, estação, obras e Conselho oferecem pistas sem revelar o resultado. Algumas respostas marcantes podem deixar um pequeno vestígio visual permanente na vila."
	))

	steps.append(_make_guide_step(
		"HISTÓRIA",
		"PRÓLOGO E CAPÍTULOS",
		"O prólogo apresenta Sanctuary-Void, Mimo e os Passos-Leves. A cada 15 dias chegam personagens pela mesma lógica narrativa: Aelric, Kobi, Orion, Rubra, Brunna, Silas e Dália nos dias 15 a 105. O Dia 120 encerra a auditoria. Decisões de capítulo deixam flags narrativas, consequências de gestão e afinidade inicial persistentes.",
		"Os novos personagens entram obrigatoriamente; suas escolhas mudam a forma como chegam e se relacionam."
	))

	steps.append(_make_guide_step(
		"RELAÇÕES",
		"AMIZADE E ROMANCE",
		"Mimo possui rota de amizade. Aelric, Kobi, Orion, Rubra, Brunna, Silas e Dália possuem amizade e romance. A primeira conversa diária com cada personagem pode ganhar, manter ou perder pontos conforme a resposta. Assuntos e posições das respostas são randomizados; cenas importantes surgem exatamente em 200, 400, 600 e 800 pontos.",
		"A partir do nível 4 surgem bônus pequenos de gestão. Apenas um parceiro oficial pode ser escolhido."
	))

	steps.append(_make_guide_step(
		"ENCONTROS",
		"COMPROMISSO E PÓS-ROMANCE",
		"O romance só pode ser escolhido na cena de 800 pontos quando escolhas claras de interesse foram feitas nas cenas de 400 e 600 pontos e não existe outro parceiro. A decisão de 800 também permite assumir uma amizade profunda ou decidir depois sem fechar a rota. Depois do compromisso, encontros ficam disponíveis a cada sete dias.",
		"Romance não depende do gênero escolhido para o Prefeito."
	))

	steps.append(_make_guide_step(
		"ESTAÇÕES",
		"QUATRO CICLOS DE TRINTA DIAS",
		"Cada estação dura 30 dias. Primavera favorece alimentação, verão aumenta a colheita mas desgasta o ânimo, outono beneficia alimentação e material ao mesmo tempo, e inverno reduz em 10% a produção de comida enquanto aumenta em 10% o consumo. Personagens e representantes também alertam sobre a preparação para o frio.",
		"Use o outono para estocar comida. Entrar no inverno dependendo apenas da produção diária é perigoso."
	))

	steps.append(_make_guide_step(
		"AVALIAÇÕES E RECONHECIMENTOS",
		"MEMÓRIA, CONTRIBUIÇÕES E MEDALHAS COMPORTAMENTAIS",
		"Cada avaliação registra os valores realmente julgados, o movimento dos recursos no período, contribuições individuais, profissões, passivas, especializações, decisões e comparação com a avaliação anterior. Medalhas como Sustento da Vila e Voz da Conciliação reconhecem comportamentos observados; elas não concedem bônus.",
		"O relatório preserva as metas avaliadas. As metas da próxima avaliação aparecem somente depois que você continuar."
	))

	steps.append(_make_guide_step(
		"IDENTIDADE DA CAMPANHA",
		"VILA, SEMENTE E PERFIL FINAL",
		"Ao iniciar uma campanha, você escolhe o nome da vila e pode informar uma semente numérica ou uma palavra. A semente e a versão do gerador ficam no save e tornam reproduzíveis as gerações de jogabilidade. Ao fim, estatísticas e um perfil descritivo contam como a administração aconteceu sem condensar tudo em uma pontuação geral.",
		"Efeitos apenas visuais ou sonoros não fazem parte da reprodução da jogabilidade."
	))

	steps.append(_make_guide_step(
		"REGISTRO",
		"HISTÓRICO DA SESSÃO",
		"REGISTRO reúne as mensagens recentes desta sessão: produção, acontecimentos, construções, profissões, relações e capítulos. Ele ajuda a lembrar o que acabou de mudar e por que a previsão ficou diferente. O histórico mais importante da campanha também permanece nos estados narrativos e no save.",
		"Leia o registro após uma decisão importante antes de reorganizar a vila."
	))

	steps.append(_make_guide_step(
		"SALVAR E CARREGAR",
		"PROGRESSO COMPLETO",
		"SALVAR/CARREGAR guarda calendário, identidade e semente da campanha, dificuldade, recursos, população, representantes, reserva ampliada, recrutamentos, construções, fila de obras, builds finais, história, memórias dos fundadores, telemetria das avaliações, perfil, relacionamentos e resultado final. Depois do primeiro salvamento ou carregamento, o autosave acompanha mudanças importantes.",
		"O menu mostra a vila, semente, dificuldade e estado da campanha; campanhas concluídas ficam no histórico com seu perfil descritivo."
	))

	steps.append(_make_guide_step(
		"ÁUDIO",
		"MÚSICA, AMBIENTE E EFEITOS",
		"A trilha muda conforme a estação e músicas especiais acompanham capítulos e auditorias. O ambiente da vila toca abaixo da música, enquanto interface, acontecimentos, construções e relações possuem efeitos próprios. Em CONFIGURAÇÕES, Volume Geral, Música, Ambiente, Efeitos e Interface podem ser ajustados e testados separadamente.",
		"Silenciar tudo não apaga os valores individuais; ao reativar o áudio, cada canal retorna ao volume escolhido."
	))

	steps.append(_make_guide_step(
		"ACESSIBILIDADE",
		"FOCO, CONTRASTE E LEITURA",
		"A interface pode ser percorrida com mouse, teclado ou controle. O foco visível indica qual ação será confirmada; ui_cancel ou Esc fecha janelas que permitem retorno. Em CONFIGURAÇÕES, Reduzir Animações limita movimentos, Texto Instantâneo elimina a escrita gradual e Contraste Reforçado intensifica painéis, bordas e foco sem alterar a economia ou o save da campanha.",
		"Mensagens importantes usam texto e símbolos além de cor. Os padrões de acessibilidade são globais e podem ser restaurados separadamente do áudio."
	))

	steps.append(_make_guide_step(
		"INTERFACE",
		"VILA, MENU, AJUDA E TESTES",
		"VILA retorna à área principal; a vila ampliada permite observar moradores e acessar construções ou representantes. MENU pausa a interação e oferece campanha, carregamento, Guia do Jogo e configurações com canais separados de áudio. AJUDA reabre este guia. TESTE INTERNO é uma ferramenta de desenvolvimento e não faz parte da progressão normal.",
		"Use as dicas contextuais na primeira visita e o guia sempre que esquecer uma regra."
	))

	return steps


func _make_guide_step(
	section: String,
	title: String,
	description: String,
	tip: String
) -> Dictionary:
	return {
		"section": section,
		"title": title,
		"description": description,
		"tip": tip,
		"side": "center",
		"finish_text": "FECHAR GUIA",
		"skip_text": "FECHAR GUIA"
	}


func _build_contextual_tutorial_steps(
	hint_id: String,
	target: Control
) -> Array[Dictionary]:
	var steps: Array[Dictionary] = []

	match hint_id:
		"area_council":
			steps.append(_make_context_step(
				"CONSELHO",
				"QUATRO ATIVOS E RESERVA AMPLIADA",
				"Aqui você troca livremente os quatro representantes ativos pelas cartas disponíveis na reserva. A troca não apaga ninguém, e a reserva cresce quando novos recrutamentos são concluídos.",
				"Monte o Conselho pensando em produção, atributos e próximos acontecimentos.",
				target
			))
			steps.append(_make_context_step(
				"CONSELHO",
				"PASSIVAS E SINERGIAS AUTOMÁTICAS",
				"Cada passiva informa sua condição e seu estado atual. O jogo escolhe automaticamente até duas sinergias sem repetir uma carta. Profissões concentradas reduzem o total que entra no estoque, não a produção individual mostrada na ficha.",
				"Use DETALHAR MODIFICADORES para comparar o ganho da sinergia com a penalidade de concentração.",
				target
			))
			steps.append(_make_context_step(
				"RECRUTAMENTO",
				"VAGAS PENDENTES NÃO SÃO PERDIDAS",
				"As avaliações aprovadas dos dias 20 a 120 desbloqueiam seis vagas. Cada uma exige uma pontuação progressiva de relacionamento. Quando o requisito ainda não foi cumprido, a vaga fica pendente e será verificada novamente após a próxima avaliação aprovada. Depois do Dia 120, uma vaga antiga ainda pendente volta a ser verificada quando um vínculo muda.",
				"O quadro desta janela mostra a próxima vaga, a pontuação necessária e quanto ainda falta.",
				target
			))

		"area_relationships":
			steps.append(_make_context_step(
				"RELAÇÕES",
				"CONVERSAS E PONTOS",
				"A primeira conversa de cada dia com um personagem pode ganhar, manter ou perder pontos. Os assuntos e a ordem das respostas são aleatórios, então observe a personalidade e a história de quem está falando.",
				"Mimo possui amizade; os outros sete personagens principais também podem formar romance quando duas escolhas anteriores demonstram interesse.",
				target
			))
			steps.append(_make_context_step(
				"RELAÇÕES",
				"EVENTOS, BÔNUS E PARCEIRO",
				"Cada personagem possui quatro cenas importantes, liberadas exatamente em 200, 400, 600 e 800 pontos. Vínculos de nível 4 liberam bônus pequenos de gestão. Na cena de 800, você pode escolher amizade profunda, romance quando habilitado ou decidir depois. Apenas um parceiro oficial pode ser escolhido.",
				"Decidir depois mantém a cena disponível e não encerra nenhuma rota.",
				target
			))

		"area_register":
			steps.append(_make_context_step(
				"REGISTRO",
				"O QUE MUDOU NA VILA",
				"O Registro reúne mensagens recentes desta sessão, incluindo produção, construções, profissões, acontecimentos, capítulos e relações. Use-o para entender por que os recursos ou a previsão mudaram.",
				"As entradas mais recentes aparecem primeiro.",
				target
			))

		"area_campaign":
			steps.append(_make_context_step(
				"AVALIAÇÃO",
				"SEIS AUDITORIAS OBRIGATÓRIAS",
				"Confira aqui as metas dos dias 20, 40, 60, 80, 100 e 120. Uma meta precisa estar cumprida quando a auditoria ocorrer; falhar encerra a campanha imediatamente.",
				"Prepare recursos e construções vários dias antes da data limite.",
				target
			))
			steps.append(_make_context_step(
				"AVALIAÇÃO",
				"CAPÍTULO ANTES DA VERIFICAÇÃO",
				"No dia de auditoria, primeiro entram produção e custos; depois acontece o capítulo obrigatório e suas consequências; somente então Sanctuary-Void verifica as metas.",
				"Uma decisão narrativa pode salvar ou comprometer a avaliação do mesmo dia.",
				target
			))

		"area_buildings":
			steps.append(_make_context_step(
				"OBRAS",
				"CASAS E CAPACIDADE",
				"Cada nova casa acrescenta cinco vagas, custa mais que a anterior e leva um dia completo de trabalho. Casas compartilham os mesmos canteiros das melhorias.",
				"O custo é pago ao entrar na fila; planeje moradia antes de atingir o limite populacional.",
				target
			))
			steps.append(_make_context_step(
				"OBRAS",
				"FILA, CANTEIROS E PRAZOS",
				"Obras na fila podem subir ou descer; obras ativas não podem ser pausadas nem movidas. A janela mostra início e conclusão previstos e informa se o benefício estará disponível antes da próxima avaliação.",
				"O reembolso é integral na fila; em andamento, devolve metade e todo o progresso é perdido.",
				target
			))
			steps.append(_make_context_step(
				"OBRAS",
				"BUILDS FINAIS IRREVERSÍVEIS",
				"No nível 3, as cinco construções únicas oferecem duas especializações. Compare efeito, aparência, custo e interações conhecidas antes de confirmar. A decisão fica permanente apenas quando o trabalho termina.",
				"Cancelar antes da conclusão libera uma nova escolha; depois de pronta, a build não pode ser trocada.",
				target
			))

		"area_village_expanded":
			steps.append(_make_context_step(
				"VILA AMPLIADA",
				"UMA VISÃO MAIS PRÓXIMA",
				"A vila ampliada mostra construções, moradores comuns e representantes com mais espaço. Clique em construções para abrir Obras e em representantes para selecioná-los. Uma segunda seleção abre diálogo apenas quando a carta exibe o marcador !.",
				"O marcador ! indica uma decisão com consequência; sem ele, a seleção não abre conversa decorativa.",
				target
			))

		"area_save":
			steps.append(_make_context_step(
				"SALVAR E CARREGAR",
				"PROGRESSO DA CAMPANHA",
				"O save inclui recursos, calendário, Conselho, construções, história, perfil e relacionamentos. Após salvar ou carregar, o autosave passa a acompanhar mudanças importantes.",
				"Use o salvamento manual antes de escolhas arriscadas ou testes internos.",
				target
			))

	return steps


func _make_context_step(
	section: String,
	title: String,
	description: String,
	tip: String,
	target: Control
) -> Dictionary:
	return {
		"section": section,
		"title": title,
		"description": description,
		"tip": tip,
		"target": target,
		"side": "center",
		"finish_text": "ENTENDI",
		"skip_text": "FECHAR DICA"
	}


func _on_save_button_pressed() -> void:
	AudioManager.play_ui("window_open", false)
	if not is_instance_valid(save_window):
		_create_save_window()

	if (
		is_instance_valid(campaign_window)
		and campaign_window.is_window_visible()
	):
		campaign_window.hide_window()

	if (
		is_instance_valid(building_window)
		and building_window.is_window_visible()
	):
		building_window.hide_window()

	save_window.show_window(
		GameManager.get_save_overview()
	)
	_request_contextual_tutorial(
		"area_save",
		save_window
	)


func _on_save_requested() -> void:
	var result: Dictionary = GameManager.save_game()

	if not is_instance_valid(save_window):
		return

	save_window.refresh_state(
		GameManager.get_save_overview()
	)

	var save_success: bool = bool(result.get("success", false))
	save_window.show_feedback(
		String(
			result.get(
				"message",
				"Não foi possível salvar a campanha."
			)
		),
		save_success
	)
	if save_success:
		AudioManager.play_sfx("save")
	else:
		AudioManager.play_ui("blocked", false)


func _on_load_requested() -> void:
	var result: Dictionary = GameManager.load_game()

	if bool(result.get("success", false)):
		return

	if not is_instance_valid(save_window):
		return

	save_window.refresh_state(
		GameManager.get_save_overview()
	)

	save_window.show_feedback(
		String(
			result.get(
				"message",
				"Não foi possível carregar a campanha."
			)
		),
		false
	)


func _on_delete_save_requested() -> void:
	var result: Dictionary = (
		GameManager.delete_saved_game()
	)

	if not is_instance_valid(save_window):
		return

	save_window.refresh_state(
		GameManager.get_save_overview()
	)

	save_window.show_feedback(
		String(
			result.get(
				"message",
				"Não foi possível excluir a campanha salva."
			)
		),
		bool(
			result.get(
				"success",
				false
			)
		)
	)


func _on_save_state_changed(
	save_data: Dictionary
) -> void:
	if is_instance_valid(main_menu):
		main_menu.refresh_save_overview(save_data)

	if not is_instance_valid(save_button):
		return

	var has_valid_save: bool = (
		bool(save_data.get("has_save", false))
		and bool(save_data.get("is_valid", false))
	)

	var autosave_enabled: bool = bool(
		save_data.get(
			"autosave_enabled",
			false
		)
	)

	save_button.text = (
		"SALVO\nAUTOMÁTICO"
		if autosave_enabled
		else "SALVAR\nCARREGAR"
	)

	if has_valid_save:
		save_button.tooltip_text = (
			"Campanha salva no dia %d.\n"
			+ "Clique para salvar, carregar ou excluir."
		) % int(
			save_data.get(
				"current_day",
				1
			)
		)
	else:
		save_button.tooltip_text = (
			"Nenhuma campanha válida salva.\n"
			+ "Clique para criar o primeiro save."
		)

	if (
		is_instance_valid(save_window)
		and save_window.is_window_visible()
	):
		save_window.refresh_state(save_data)

func _on_game_loaded(
	load_result: Dictionary
) -> void:
	if is_instance_valid(main_menu):
		main_menu.hide_menu()

	if is_instance_valid(save_window):
		save_window.hide_window()

	if is_instance_valid(campaign_window):
		campaign_window.hide_window()

	if is_instance_valid(building_window):
		building_window.hide_window()

	if is_instance_valid(event_window):
		event_window.hide_event()

	selected_villager = null
	selected_card = null

	advance_day_button.text = "ENCERRAR O DIA"
	_refresh_advance_day_state()

	_refresh_building_state(
		false,
		true
	)

	_set_summary(
		String(
			load_result.get(
				"message",
				"Campanha carregada."
			)
		),
		true
	)

	_update_forecast()
	_sync_village_visuals()
	_update_profile_header()
	_queue_world_layout()
	call_deferred("_open_pending_recruitment_if_available")
	call_deferred("_resume_pending_mandatory_content")


func _update_profile_header() -> void:
	if not is_instance_valid(game_title_label):
		return
	var profile_data: Dictionary = GameManager.get_player_profile_overview()
	var profile_name: String = String(profile_data.get("name", "Alex")).to_upper()
	if profile_name.length() > 18:
		profile_name = profile_name.substr(0, 17) + "…"
	game_title_label.text = "GOLEM'S MANDATE • %s" % profile_name


func _refresh_building_state(
	animate_changes: bool,
	refresh_visuals: bool,
	refresh_window: bool = true
) -> void:
	var building_data: Dictionary = (
		GameManager.get_building_state()
	)

	_update_building_interface(
		building_data,
		animate_changes,
		refresh_visuals,
		refresh_window
	)


func _update_building_interface(
	building_data: Dictionary,
	animate_changes: bool,
	refresh_visuals: bool = true,
	refresh_window: bool = true
) -> void:
	var built_upgrades: int = int(
		building_data.get(
			"built_upgrades",
			0
		)
	)

	var total_upgrades: int = int(
		building_data.get(
			"total_upgrades",
			15
		)
	)
	var house_count: int = int(
		building_data.get(
			"house_count",
			2
		)
	)

	if is_instance_valid(building_button):
		var construction: Dictionary = building_data.get("construction", {})
		var active_count: int = int(construction.get("active_count", 0))
		var site_capacity: int = int(construction.get("site_capacity", 1))
		var queued_count: int = int(construction.get("queued_count", 0))
		building_button.text = (
			"OBRAS\n%d/%d ATIVAS • FILA %d"
			% [active_count, site_capacity, queued_count]
		)

		building_button.tooltip_text = (
			"%d de %d melhorias concluídas.\n"
			+ "%d casas construídas.\n"
			+ "Canteiros ativos: %d de %d. Fila: %d.\n"
			+ "Material disponível: %.1f.\n"
			+ "Clique para planejar, cancelar ou reordenar obras."
		) % [
			built_upgrades,
			total_upgrades,
			house_count,
			active_count,
			site_capacity,
			queued_count,
			float(building_data.get("available_material", 0.0))
		]

	if (
		refresh_window
		and is_instance_valid(building_window)
		and building_window.is_window_visible()
	):
		building_window.refresh_state(
			building_data
		)

	if (
		refresh_visuals
		and is_instance_valid(building_visuals)
	):
		building_visuals.update_buildings(
			building_data,
			animate_changes
		)

	_sync_village_visuals()


func _sync_village_visuals() -> void:
	var population_overview: Dictionary = (
		GameManager.get_population_overview()
	)
	population_overview["happiness"] = GameManager.happiness
	var active_council: Array[Villager] = (
		GameManager.get_active_council()
	)
	var selected_member_id: String = ""

	if is_instance_valid(selected_villager):
		selected_member_id = selected_villager.representative_id

	# O mapa usa peças simplificadas próprias. Os antigos nós de
	# personagem continuam como modelos de dados, mas ficam ocultos.
	for villager: Villager in GameManager.villagers:
		if is_instance_valid(villager):
			villager.visible = false

	if is_instance_valid(building_visuals):
		building_visuals.apply_season(current_season_id)
		building_visuals.update_memory_markers(
			GameManager.get_founder_memory_overview().get("visual_markers", [])
		)
		building_visuals.update_population_overview(
			population_overview
		)
		building_visuals.update_council(
			active_council,
			selected_member_id
		)

	if is_instance_valid(village_window):
		village_window.refresh(
			GameManager.get_building_state(),
			population_overview,
			active_council,
			selected_member_id,
			current_season_id
		)


func _on_village_visual_feedback_requested(
	feedback_data: Dictionary
) -> void:
	if is_instance_valid(building_visuals):
		building_visuals.show_world_feedback(feedback_data)
	if (
		is_instance_valid(village_window)
		and village_window.is_window_visible()
	):
		village_window.show_world_feedback(feedback_data)


func _on_founder_memory_changed(overview: Dictionary) -> void:
	if is_instance_valid(building_visuals):
		building_visuals.update_memory_markers(
			overview.get("visual_markers", [])
		)


func _on_campaign_progress_changed(
	progress_data: Dictionary
) -> void:
	AudioManager.set_season(
		String(progress_data.get("season_id", "spring"))
	)
	_update_calendar_display(progress_data)

	if not is_instance_valid(campaign_button):
		return

	var met_goals: int = int(
		progress_data.get(
			"met_goals",
			0
		)
	)

	var total_goals: int = int(
		progress_data.get(
			"total_goals",
			5
		)
	)

	var completed_days: int = int(
		progress_data.get(
			"completed_days",
			0
		)
	)

	var target_day: int = int(
		progress_data.get(
			"target_day",
			20
		)
	)
	var is_free_play: bool = bool(
		progress_data.get(
			"is_free_play",
			false
		)
	)

	if is_free_play:
		campaign_button.text = "MODO LIVRE\nSEM METAS"
		campaign_button.tooltip_text = (
			"A campanha de 120 dias foi vencida. "
			+ "As estações continuam sem novas avaliações."
		)
		return

	campaign_button.text = (
		"AVALIAÇÃO %d\n%d / %d METAS"
		% [
			target_day,
			met_goals,
			total_goals
		]
	)

	campaign_button.tooltip_text = (
		"Campanha: %d de 120 dias concluídos.\n"
		+ "Próxima avaliação: dia %d.\n"
		+ "Metas atingidas agora: %d de %d.\n"
		+ "Clique para ver os detalhes."
	) % [
		completed_days,
		target_day,
		met_goals,
		total_goals
	]


func _update_calendar_display(
	progress_data: Dictionary
) -> void:
	if (
		not is_instance_valid(day_label)
		or not is_instance_valid(checkpoint_label)
	):
		return

	var status: String = String(
		progress_data.get(
			"status",
			"active"
		)
	)
	var is_free_play: bool = bool(
		progress_data.get(
			"is_free_play",
			false
		)
	)
	var display_day: int = int(
		progress_data.get(
			"current_day",
			GameManager.current_day
		)
	)

	if status in ["victory", "defeat"]:
		display_day = maxi(
			1,
			int(
				progress_data.get(
					"completed_days",
					display_day
				)
			)
		)

	_apply_season_appearance(display_day)

	var season: Dictionary = (
		VillageCampaignCatalog.get_season_for_day(
			display_day
		)
	)
	var season_name: String = String(
		season.get(
			"display_name",
			"Estação"
		)
	).to_upper()
	var day_in_season: int = (
		VillageCampaignCatalog.get_day_in_season(
			display_day
		)
	)
	day_label.tooltip_text = (
		"%s — dia %d de 30.\n%s"
		% [
			String(
				season.get(
					"display_name",
					"Estação"
				)
			),
			day_in_season,
			String(
				season.get(
					"effects_text",
					"Sem modificadores sazonais."
				)
			)
		]
	)

	if is_free_play:
		day_label.text = (
			"DIA %d — %s %d/30"
			% [
				display_day,
				season_name,
				day_in_season
			]
		)
		checkpoint_label.text = (
			"MODO LIVRE — SEM NOVAS AVALIAÇÕES"
		)
		checkpoint_label.tooltip_text = (
			"A vitória já foi conquistada. As estações "
			+ "continuam se repetindo."
		)
		return

	day_label.text = (
		"DIA %d/120 — %s %d/30"
		% [
			mini(display_day, 120),
			season_name,
			day_in_season
		]
	)

	if status == "victory":
		checkpoint_label.text = (
			"CAMPANHA APROVADA — SEIS AVALIAÇÕES CONCLUÍDAS"
		)
	elif status == "defeat":
		checkpoint_label.text = "CAMPANHA REPROVADA"
	else:
		var checkpoint_day: int = int(
			progress_data.get(
				"checkpoint_day",
				20
			)
		)
		var completed_days: int = int(
			progress_data.get(
				"completed_days",
				0
			)
		)
		var days_until_checkpoint: int = maxi(
			0,
			checkpoint_day - completed_days
		)

		checkpoint_label.text = (
			"PRÓXIMA AVALIAÇÃO: DIA %d — FALTAM %d DIAS"
			% [
				checkpoint_day,
				days_until_checkpoint
			]
		)

	checkpoint_label.tooltip_text = (
		"Os recursos serão verificados ao encerrar "
		+ "o dia indicado."
	)


func _on_campaign_checkpoint_completed(
	progress_data: Dictionary
) -> void:
	if (
		is_instance_valid(building_window)
		and building_window.is_window_visible()
	):
		building_window.hide_window()

	if (
		is_instance_valid(save_window)
		and save_window.is_window_visible()
	):
		save_window.hide_window()

	if not is_instance_valid(campaign_window):
		_create_campaign_window()

	campaign_window.show_checkpoint_result(
		progress_data
	)


func _on_campaign_finished(
	result_data: Dictionary
) -> void:
	if (
		is_instance_valid(building_window)
		and building_window.is_window_visible()
	):
		building_window.hide_window()

	if (
		is_instance_valid(save_window)
		and save_window.is_window_visible()
	):
		save_window.hide_window()

	advance_day_button.disabled = true
	advance_day_button.text = "CAMPANHA ENCERRADA"

	forecast_status_label.text = (
		"PARTIDA ENCERRADA"
	)

	forecast_status_label.add_theme_color_override(
		"font_color",
		MedievalTheme.GOLD
	)

	forecast_status_label.tooltip_text = (
		"Abra os objetivos para rever o resultado."
	)

	var result_title: String = String(
		result_data.get(
			"result_title",
			"Fim da campanha"
		)
	)

	_set_summary(
		"Campanha encerrada: " + result_title + ".",
		true
	)

	if not is_instance_valid(campaign_window):
		_create_campaign_window()

	campaign_window.show_result(result_data)


func _on_free_play_requested() -> void:
	if not GameManager.enter_free_play():
		return

	if is_instance_valid(campaign_window):
		campaign_window.hide_window()


func _on_free_play_started(
	_progress_data: Dictionary
) -> void:
	_refresh_advance_day_state()

	_set_summary(
		"Modo Livre iniciado. A Primavera recomeça no "
		+ "dia 121 e as estações continuarão se repetindo.",
		true
	)
	_update_forecast()


func _on_season_hint_available(
	hint_data: Dictionary
) -> void:
	if not is_instance_valid(season_hint_window):
		_create_season_hint_window()

	season_hint_window.show_hint(hint_data)


func _on_campaign_restart_requested() -> void:
	if is_instance_valid(campaign_window):
		campaign_window.hide_window()

	if not is_instance_valid(main_menu):
		_create_main_menu()

	main_menu.show_new_campaign_confirmation(
		GameManager.get_save_overview()
	)


func _apply_world_appearance() -> void:
	var current_scene: Node = get_tree().current_scene

	if current_scene == null:
		return

	world_background = current_scene.find_child(
		"Background",
		true,
		false
	) as ColorRect

	if is_instance_valid(world_background):
		world_background.mouse_filter = (
			Control.MOUSE_FILTER_IGNORE
		)

	village_ground = current_scene.find_child(
		"VillageGround",
		true,
		false
	) as ColorRect

	if is_instance_valid(village_ground):
		village_ground.mouse_filter = (
			Control.MOUSE_FILTER_IGNORE
		)

	legacy_villagers_layer = current_scene.find_child(
		"Villagers",
		true,
		false
	) as CanvasItem

	# A Etapa 5 usa sprites próprios dentro da interface. Os nós
	# antigos continuam existindo como dados, mas deixam de ser
	# desenhados para evitar renderização e interação duplicadas.
	if is_instance_valid(legacy_villagers_layer):
		legacy_villagers_layer.visible = false

	_apply_season_appearance(
		GameManager.current_day,
		true
	)


func _apply_season_appearance(
	day_value: int,
	force_update: bool = false
) -> void:
	var season: Dictionary = (
		VillageCampaignCatalog.get_season_for_day(
			day_value
		)
	)
	var season_id: String = String(
		season.get("id", "spring")
	)

	if not force_update and season_id == current_season_id:
		return

	current_season_id = season_id
	var palette: Dictionary = (
		MedievalTheme.get_season_palette(
			season_id,
			GameSettings.enhanced_contrast
		)
	)

	theme = MedievalTheme.create_theme(
		season_id,
		GameSettings.enhanced_contrast
	)

	if is_instance_valid(world_background):
		world_background.color = palette["background"]

	if is_instance_valid(village_ground):
		village_ground.color = palette["ground"]

	if is_instance_valid(top_bar):
		top_bar.add_theme_stylebox_override(
			"panel",
			MedievalTheme.create_panel_style(
				palette["panel_dark"],
				palette["accent_dark"],
				2,
				10,
				14,
				4
			)
		)

	if is_instance_valid(residents_panel):
		residents_panel.add_theme_stylebox_override(
			"panel",
			MedievalTheme.create_panel_style(
				palette["panel_dark"],
				palette["accent_dark"],
				2,
				10,
				14,
				3
			)
		)

	if is_instance_valid(village_frame):
		var village_panel_color: Color = palette["background"]
		village_panel_color.a = 0.22

		village_frame.add_theme_stylebox_override(
			"panel",
			MedievalTheme.create_panel_style(
				village_panel_color,
				palette["accent_dark"],
				2,
				10,
				5,
				3
			)
		)

	if is_instance_valid(bottom_bar):
		bottom_bar.add_theme_stylebox_override(
			"panel",
			MedievalTheme.create_panel_style(
				palette["panel_dark"],
				palette["accent_dark"],
				2,
				10,
				14,
				4
			)
		)

	for tile: PanelContainer in resource_tiles:
		if not is_instance_valid(tile):
			continue

		tile.add_theme_stylebox_override(
			"panel",
			MedievalTheme.create_panel_style(
				palette["panel"],
				palette["accent_dark"],
				1,
				7,
				8,
				0
			)
		)

	if is_instance_valid(day_label):
		day_label.add_theme_color_override(
			"font_color",
			palette["accent"]
		)

	_sync_village_visuals()


func _update_forecast() -> void:
	if (
		not is_instance_valid(forecast_population_label)
		or not is_instance_valid(forecast_food_label)
	):
		return

	_refresh_advance_day_state()
	var advance_blocker: Dictionary = _get_advance_day_blocker()
	if not advance_blocker.is_empty():
		var blocker_color: Color = advance_blocker.get(
			"color",
			MedievalTheme.GOLD
		)
		forecast_status_label.text = String(
			advance_blocker.get("status", "AÇÃO PENDENTE")
		)
		forecast_status_label.add_theme_color_override(
			"font_color",
			blocker_color
		)
		forecast_status_label.tooltip_text = String(
			advance_blocker.get(
				"message",
				"Conclua a ação pendente antes de encerrar outro dia."
			)
		)
		return

	var forecast: Dictionary = (
		GameManager.calculate_next_day_forecast()
	)
	var season_data: Dictionary = forecast.get(
		"season",
		{}
	)
	var season_name: String = String(
		season_data.get(
			"display_name",
			"Estação"
		)
	)
	var season_effects: String = String(
		season_data.get(
			"effects_text",
			"Sem modificadores sazonais."
		)
	)
	var season_forecast_text: String = (
		"%s: %s"
		% [
			season_name,
			season_effects
		]
	)

	var next_day: int = int(forecast["next_day"])
	var projected_food: float = float(forecast["food"])
	var projected_material: float = float(forecast["material"])

	var projected_happiness: float = float(
		forecast["happiness"]
	)

	var food_change: float = float(
		forecast["food_change"]
	)

	var material_change: float = float(
		forecast["material_change"]
	)

	var happiness_change: float = float(
		forecast["happiness_change"]
	)

	var food_shortage: float = float(
		forecast["food_shortage"]
	)

	var material_shortage: float = float(
		forecast["material_shortage"]
	)
	var population_outlook: Dictionary = forecast.get(
		"population_outlook",
		{}
	)

	_update_population_forecast(
		population_outlook
	)

	_set_forecast_label(
		forecast_food_label,
		next_day,
		projected_food,
		food_change,
		food_shortage > 0.0
	)

	_set_forecast_label(
		forecast_material_label,
		next_day,
		projected_material,
		material_change,
		material_shortage > 0.0
	)

	_set_forecast_label(
		forecast_happiness_label,
		next_day,
		projected_happiness,
		happiness_change,
		projected_happiness <= 0.0
	)

	forecast_food_label.tooltip_text = (
		"Produção prevista: +%.1f\n"
		+ "Consumo previsto: -%.1f\n"
		+ "Resultado no dia %d: %.1f\n%s"
	) % [
		float(forecast["food_production"]),
		float(forecast["food_consumption"]),
		next_day,
		projected_food,
		season_forecast_text
	]

	var food_production_bonus: float = float(
		forecast.get(
			"food_production_bonus",
			0.0
		)
	)

	if food_production_bonus > 0.0:
		forecast_food_label.tooltip_text += (
			"\nCeleiro: +%.0f%% na produção."
			% (food_production_bonus * 100.0)
		)

	forecast_material_label.tooltip_text = (
		"Produção prevista: +%.1f\n"
		+ "Manutenção prevista: -%.1f\n"
		+ "Resultado no dia %d: %.1f\n%s"
	) % [
		float(forecast["material_production"]),
		float(forecast["material_consumption"]),
		next_day,
		projected_material,
		season_forecast_text
	]

	var material_production_bonus: float = float(
		forecast.get(
			"material_production_bonus",
			0.0
		)
	)

	if material_production_bonus > 0.0:
		forecast_material_label.tooltip_text += (
			"\nSerraria: +%.0f%% na produção."
			% (material_production_bonus * 100.0)
		)

	var maintenance_reduction: float = float(
		forecast.get(
			"maintenance_reduction",
			0.0
		)
	)

	if maintenance_reduction > 0.0:
		forecast_material_label.tooltip_text += (
			"\nMuralha: -%.0f%% na manutenção."
			% (maintenance_reduction * 100.0)
		)

	forecast_happiness_label.tooltip_text = (
		"Produção prevista: +%.1f\n"
		+ "Redução diária: -%.1f\n"
		+ "Resultado no dia %d: %.1f\n%s"
	) % [
		float(forecast["happiness_production"]),
		float(forecast["happiness_decay"]),
		next_day,
		projected_happiness,
		season_forecast_text
	]

	var happiness_decay_reduction: float = float(
		forecast.get(
			"happiness_decay_reduction",
			0.0
		)
	)

	if happiness_decay_reduction > 0.0:
		forecast_happiness_label.tooltip_text += (
			"\nPoço: -%.0f%% na redução diária."
			% (happiness_decay_reduction * 100.0)
		)

	var daily_happiness_bonus: float = float(
		forecast.get(
			"daily_happiness_bonus",
			0.0
		)
	)

	if daily_happiness_bonus > 0.0:
		forecast_happiness_label.tooltip_text += (
			"\nPraça: +%.1f de felicidade."
			% daily_happiness_bonus
		)

	var alerts: Array[String] = []
	var has_critical_alert: bool = false

	if food_shortage > 0.0:
		alerts.append(
			"Faltarão %.1f de alimentação."
			% food_shortage
		)

		has_critical_alert = true

	elif food_change < -0.05:
		alerts.append(
			"A alimentação cairá %.1f."
			% absf(food_change)
		)

	if material_shortage > 0.0:
		alerts.append(
			"Faltarão %.1f de material."
			% material_shortage
		)

		has_critical_alert = true

	elif material_change < -0.05:
		alerts.append(
			"O material cairá %.1f."
			% absf(material_change)
		)

	if projected_happiness <= 0.0:
		alerts.append(
			"A felicidade chegará a zero."
		)

		has_critical_alert = true

	elif projected_happiness < 30.0:
		alerts.append(
			"A felicidade ficará perigosamente baixa."
		)

	elif happiness_change < -0.05:
		alerts.append(
			"A felicidade cairá %.1f."
			% absf(happiness_change)
		)

	if alerts.is_empty():
		forecast_status_label.text = (
			"PREVISÃO ESTÁVEL — "
			+ season_name.to_upper()
		)

		forecast_status_label.add_theme_color_override(
			"font_color",
			Color("#9FD18B")
		)

		forecast_status_label.tooltip_text = (
			season_forecast_text
			+ "\nNenhum recurso diminuirá "
			+ "com a escala de trabalho atual."
		)

		return

	var alert_word: String = (
		"ALERTA"
		if alerts.size() == 1
		else "ALERTAS"
	)

	forecast_status_label.text = (
		"%d %s — %s"
		% [
			alerts.size(),
			alert_word,
			season_name.to_upper()
		]
	)

	if has_critical_alert:
		forecast_status_label.add_theme_color_override(
			"font_color",
			Color("#F07F72")
		)
	else:
		forecast_status_label.add_theme_color_override(
			"font_color",
			Color("#E6C15A")
		)

	var alert_text: String = season_forecast_text

	for alert: String in alerts:
		alert_text += "\n" + alert

	forecast_status_label.tooltip_text = alert_text


func _update_population_forecast(
	outlook: Dictionary
) -> void:
	if not is_instance_valid(forecast_population_label):
		return

	var status: String = String(
		outlook.get(
			"status",
			"stable"
		)
	)
	var attraction: int = int(
		outlook.get(
			"projected_attraction_progress",
			0
		)
	)
	var attraction_target: int = int(
		outlook.get(
			"attraction_target",
			3
		)
	)
	var risk: int = int(
		outlook.get(
			"projected_concerning_day_streak",
			0
		)
	)
	var risk_target: int = int(
		outlook.get(
			"abandonment_target",
			3
		)
	)
	var movement: String = String(
		outlook.get(
			"projected_movement",
			"none"
		)
	)
	var forecast_text: String = "ESTÁVEL"
	var forecast_color: Color = MedievalTheme.TEXT_MUTED

	if movement == "arrival":
		forecast_text = "PRÓXIMO: +1"
		forecast_color = Color("#9FD18B")
	elif movement == "departure":
		forecast_text = "PRÓXIMO: -1"
		forecast_color = Color("#F07F72")
	elif status == "favorable":
		forecast_text = (
			"ATRAÇÃO %d/%d"
			% [
				attraction,
				attraction_target
			]
		)
		forecast_color = Color("#9FD18B")
	elif status == "concerning":
		forecast_text = (
			"RISCO %d/%d"
			% [
				risk,
				risk_target
			]
		)
		forecast_color = Color("#F07F72")
	elif status == "housing_paused":
		forecast_text = "SEM VAGAS"
		forecast_color = Color("#E6C15A")

	forecast_population_label.text = forecast_text
	forecast_population_label.add_theme_color_override(
		"font_color",
		forecast_color
	)
	forecast_population_label.tooltip_text = (
		String(
			outlook.get(
				"reason",
				"A comunidade está estável."
			)
		)
		+ (
			"\nAtração: %d/%d dias favoráveis."
			% [
			int(
				outlook.get(
					"attraction_progress",
					0
				)
			),
			attraction_target
			]
		)
		+ (
			"\nFelicidade mínima para atração: %.0f."
			% float(
				outlook.get(
					"growth_minimum_happiness",
					55.0
				)
			)
		)
		+ (
			"\nRisco de abandono: %d/%d dias preocupantes."
			% [
			int(
				outlook.get(
					"concerning_day_streak",
					0
				)
			),
			risk_target
			]
		)
	)


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

	var new_text: String = (
		"DIA %d: %.1f (%s)"
	) % [
		next_day,
		projected_value,
		change_text
	]

	var text_changed: bool = (
		target_label.text != new_text
	)

	target_label.text = new_text

	var forecast_color: Color = (
		MedievalTheme.PARCHMENT_LIGHT
	)

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
		_animate_label_pulse(
			target_label,
			1.05
		)


func _on_resources_changed(
	food_value: float,
	material_value: float,
	happiness_value: float,
	day_value: int
) -> void:
	_apply_season_appearance(day_value)
	_update_calendar_display(
		GameManager.get_campaign_progress()
	)
	food_label.text = "%.1f" % food_value
	material_label.text = "%.1f" % material_value

	happiness_label.text = (
		"%.1f / 100" % happiness_value
	)
	var population_overview: Dictionary = (
		GameManager.get_population_overview()
	)
	var total_population: int = int(
		population_overview.get(
			"total_population",
			0
		)
	)
	var housing_capacity: int = int(
		population_overview.get(
			"housing_capacity",
			0
		)
	)
	var common_population: int = int(
		population_overview.get(
			"common_population",
			0
		)
	)
	population_label.text = (
		"%d / %d"
		% [
			total_population,
			housing_capacity
		]
	)

	population_label.tooltip_text = (
		"População total: %d/%d.\n"
		+ "Conselho ativo: %d • reserva: %d • "
		+ "mão de obra comunitária: %d.\n"
		+ "Todos consomem %.1f de alimentação e %.2f de "
		+ "material. A mão de obra comunitária também produz "
		+ "%.1f de alimentação e %.1f de material."
	) % [
		total_population,
		housing_capacity,
		GameManager.get_active_council().size(),
		GameManager.get_reserve_roster().size(),
		common_population,
		GameManager.get_effective_food_consumption_per_villager(),
		GameManager.get_effective_material_maintenance_per_villager(),
		GameManager.COMMON_FOOD_PRODUCTION_PER_VILLAGER,
		GameManager.COMMON_MATERIAL_PRODUCTION_PER_VILLAGER
	]

	food_label.tooltip_text = (
		"Alimentação disponível agora.\n"
		+ "Cada habitante consome %.1f por dia."
	) % (
		GameManager.get_effective_food_consumption_per_villager()
	)

	material_label.tooltip_text = (
		"Material disponível agora.\n"
		+ "A manutenção custa %.2f por habitante e por dia."
	) % (
		GameManager.get_effective_material_maintenance_per_villager()
	)

	happiness_label.tooltip_text = (
		"Felicidade atual da vila.\n"
		+ "Sem produção, ela cai %.1f por habitante e por dia."
	) % (
		GameManager.get_effective_happiness_decay_per_villager()
	)

	if interface_ready and has_resource_snapshot:
		if not is_equal_approx(
			food_value,
			previous_food
		):
			_animate_label_pulse(
				food_label,
				1.10
			)

		if not is_equal_approx(
			material_value,
			previous_material
		):
			_animate_label_pulse(
				material_label,
				1.10
			)

		if not is_equal_approx(
			happiness_value,
			previous_happiness
		):
			_animate_label_pulse(
				happiness_label,
				1.10
			)

		if day_value != previous_day:
			_animate_label_pulse(
				day_label,
				1.12
			)

	previous_food = food_value
	previous_material = material_value
	previous_happiness = happiness_value
	previous_day = day_value
	has_resource_snapshot = true

	_refresh_building_state(
		false,
		false,
		false
	)

	_update_forecast()


func _on_council_changed(
	_data: Dictionary,
	result_text: String
) -> void:
	_rebuild_villager_list()
	_queue_world_layout()
	if not result_text.is_empty():
		_set_summary(result_text, false)


func _on_councillor_opportunities_changed(
	_overview: Dictionary,
	result_text: String
) -> void:
	_refresh_villager_cards()
	_update_forecast()
	if not result_text.is_empty():
		_set_summary(result_text, false)


func _rebuild_villager_list() -> void:
	if not is_instance_valid(villager_cards):
		return

	var existing_cards: Array[Node] = (
		villager_cards.get_children()
	)

	for card_node: Node in existing_cards:
		villager_cards.remove_child(card_node)
		card_node.queue_free()

	villager_cards_by_id.clear()
	selected_card = null

	if (
		selected_villager != null
		and (
			not is_instance_valid(selected_villager)
			or not selected_villager.is_council_active
		)
	):
		if is_instance_valid(selected_villager):
			_set_world_villager_selected(
				selected_villager,
				false
			)
		selected_villager = null

	var population_overview: Dictionary = (
		GameManager.get_population_overview()
	)
	population_label.text = (
		"%d / %d"
		% [
			int(
				population_overview.get(
					"total_population",
					0
				)
			),
			int(
				population_overview.get(
					"housing_capacity",
					0
				)
			)
		]
	)

	var card_index: int = 0

	for villager: Villager in GameManager.villagers:
		if not is_instance_valid(villager) or not villager.is_council_active:
			continue

		var card: VillagerCard = (
			VILLAGER_CARD_SCENE.instantiate()
			as VillagerCard
		)

		if not is_instance_valid(card):
			push_error(
				"Não foi possível criar o cartão de "
				+ villager.villager_name
				+ "."
			)

			continue

		card.setup(villager)

		card.selection_requested.connect(
			_on_villager_card_selection_requested
		)
		card.profession_requested.connect(
			_on_card_profession_requested
		)
		card.attribute_point_requested.connect(
			_on_card_attribute_point_requested
		)
		card.history_requested.connect(
			_on_card_history_requested
		)

		villager_cards.add_child(card)

		villager_cards_by_id[
			villager.get_instance_id()
		] = card

		_prepare_world_villager_interaction(
			villager
		)

		if villager == selected_villager:
			selected_card = card
			card.set_selected(
				true,
				false
			)

		card.call_deferred(
			"animate_entrance",
			card_index
		)

		card_index += 1

	if selected_villager == null:
		selection_status_label.text = "CLIQUE EM UMA CARTA"
		selection_status_label.add_theme_color_override(
			"font_color",
			MedievalTheme.TEXT_MUTED
		)
		if is_instance_valid(selected_profession_selector):
			selected_profession_selector.disabled = true
	else:
		_update_selection_status(
			selected_villager
		)

	_update_forecast()
	_sync_village_visuals()
	_queue_world_layout()


func _refresh_villager_cards() -> void:
	for card_value: Variant in villager_cards_by_id.values():
		var card: VillagerCard = card_value as VillagerCard
		if is_instance_valid(card):
			card.refresh_production_preview()


func _on_villager_card_selection_requested(
	card_node: PanelContainer,
	villager: Villager,
	show_message: bool
) -> void:
	var card: VillagerCard = (
		card_node as VillagerCard
	)

	if not is_instance_valid(card):
		return

	if (
		show_message
		and is_instance_valid(selected_villager)
		and selected_villager == villager
	):
		if GameManager.has_councillor_opportunity(villager.representative_id):
			_open_dialogue_for_villager(villager)
		else:
			_set_summary(
				"%s não possui um assunto com consequência pendente. Os representantes só conversam quando uma decisão altera a vila."
				% villager.villager_name,
				true
			)
		return

	_select_villager(
		villager,
		card,
		show_message
	)


func _on_card_profession_requested(
	villager: Villager,
	profession: int
) -> void:
	if not is_instance_valid(villager):
		return
	selected_villager = villager
	villager.set_profession(profession)
	_update_selection_status(villager)
	_refresh_villager_cards()
	_update_forecast()
	_set_summary(
		"%s agora trabalha como %s." % [
			villager.villager_name,
			Villager.get_profession_name(profession)
		],
		true
	)


func _on_card_attribute_point_requested(
	villager: Villager,
	attribute_id: String
) -> void:
	if not is_instance_valid(villager):
		return
	var result: Dictionary = GameManager.spend_councillor_attribute_point(
		villager.representative_id,
		attribute_id
	)
	var success: bool = bool(result.get("success", false))
	_set_summary(
		String(result.get("message", "Ponto de atributo distribuído.")),
		not success
	)
	_refresh_villager_cards()
	_update_forecast()


func _on_card_history_requested(villager: Villager) -> void:
	if not is_instance_valid(villager):
		return
	if not is_instance_valid(councillor_history_window):
		_create_councillor_history_window()
	var history: Dictionary = GameManager.get_councillor_history(
		villager.representative_id
	)
	if history.is_empty():
		_set_summary("Ainda não há histórico disponível para esta carta.", true)
		return
	councillor_history_window.open_window(history)


func _on_councillor_history_changed(_representative_id: String) -> void:
	_refresh_villager_cards()


func _on_councillor_level_dialogue_requested(request: Dictionary) -> void:
	var conversation_id: String = String(
		request.get("conversation_id", "")
	).strip_edges()
	if conversation_id.is_empty():
		return
	if not is_instance_valid(dialogue_window):
		_create_dialogue_window()
	var conversation: Dictionary = (
		COUNCILLOR_PROGRESSION_DIALOGUE_CATALOG_SCRIPT.create_level_up_conversation(
			request
		)
	)
	if conversation.is_empty():
		push_error("Não foi possível criar o diálogo de nível %s." % conversation_id)
		return
	_close_management_windows_for_dialogue()
	_refresh_advance_day_state()
	forecast_status_label.text = "CONQUISTA PENDENTE"
	forecast_status_label.add_theme_color_override(
		"font_color",
		MedievalTheme.GOLD
	)
	forecast_status_label.tooltip_text = (
		"Conclua a conversa especial da carta antes de encerrar outro dia."
	)
	if is_instance_valid(building_visuals):
		building_visuals.set_simulation_active(false)
	active_level_dialogue_id = conversation_id
	if not dialogue_window.show_conversation(conversation):
		active_level_dialogue_id = ""
		_set_summary("Não foi possível abrir a conversa especial de nível.", true)
	else:
		AudioManager.begin_dialogue(false)


func _on_selected_profession_changed(selected_index: int) -> void:
	if updating_selected_profession:
		return
	if not is_instance_valid(selected_villager):
		return
	var profession: int = selected_profession_selector.get_item_id(
		selected_index
	)
	selected_villager.set_profession(profession)
	_update_selection_status(selected_villager)
	_refresh_villager_cards()
	_update_forecast()

	var profession_message: String = (
		"%s agora trabalha como %s."
		% [
			selected_villager.villager_name,
			Villager.get_profession_name(profession)
		]
	)

	if (
		GameManager.current_day <= 3
		and is_instance_valid(tutorial_manager)
		and not tutorial_manager.has_seen_hint(
			"first_profession_change"
		)
	):
		tutorial_manager.mark_hint_seen(
			"first_profession_change"
		)
		profession_message += (
			"\nDica: os atributos da carta definem seu desempenho em cada trabalho."
		)

	_set_summary(profession_message, true)


func _unhandled_input(event: InputEvent) -> void:
	if (
		is_instance_valid(tutorial_window)
		and tutorial_window.is_window_visible()
	):
		return

	if (
		is_instance_valid(dialogue_window)
		and dialogue_window.is_dialogue_visible()
	):
		return

	if (
		is_instance_valid(diagnostics_window)
		and diagnostics_window.is_window_visible()
	):
		return

	if (
		is_instance_valid(main_menu)
		and main_menu.is_menu_visible()
	):
		return

	if (
		is_instance_valid(event_window)
		and event_window.is_event_visible()
	):
		return

	if (
		is_instance_valid(recruitment_window)
		and recruitment_window.is_window_visible()
	):
		return

	if (
		is_instance_valid(campaign_window)
		and campaign_window.is_window_visible()
	):
		return

	if (
		is_instance_valid(building_window)
		and building_window.is_window_visible()
	):
		return

	if (
		is_instance_valid(save_window)
		and save_window.is_window_visible()
	):
		return

	if (
		is_instance_valid(council_window)
		and council_window.is_window_visible()
	):
		return

	if (
		is_instance_valid(relationships_window)
		and relationships_window.is_window_visible()
	):
		return

	if (
		is_instance_valid(councillor_history_window)
		and councillor_history_window.is_window_visible()
	):
		return

	if (
		is_instance_valid(forecast_details_window)
		and forecast_details_window.is_window_visible()
	):
		return

	if (
		is_instance_valid(profile_setup_window)
		and profile_setup_window.is_window_visible()
	):
		return

	if (
		is_instance_valid(village_window)
		and village_window.is_window_visible()
	):
		return

	if not event is InputEventMouseButton:
		return

	var mouse_event: InputEventMouseButton = (
		event as InputEventMouseButton
	)

	if (
		mouse_event.button_index != MOUSE_BUTTON_LEFT
		or not mouse_event.pressed
	):
		return

	var villager: Villager = (
		_find_world_villager_at_position(
			mouse_event.position
		)
	)

	if not is_instance_valid(villager):
		return

	var villager_id: int = villager.get_instance_id()

	if not villager_cards_by_id.has(villager_id):
		return

	var card: VillagerCard = (
		villager_cards_by_id[villager_id]
		as VillagerCard
	)

	if not is_instance_valid(card):
		return

	_select_villager(
		villager,
		card,
		true
	)

	get_viewport().set_input_as_handled()


func _find_world_villager_at_position(
	screen_position: Vector2
) -> Villager:
	if is_instance_valid(building_visuals):
		return null

	if not is_instance_valid(village_frame):
		return null

	if not village_frame.get_global_rect().has_point(
		screen_position
	):
		return null

	for index: int in range(
		GameManager.villagers.size() - 1,
		-1,
		-1
	):
		var villager: Villager = (
			GameManager.villagers[index]
		)

		if (
			not is_instance_valid(villager)
			or not villager.is_council_active
			or not villager.visible
		):
			continue

		var canvas_transform: Transform2D = (
			villager.get_global_transform_with_canvas()
		)

		var local_mouse_position: Vector2 = (
			canvas_transform.affine_inverse()
			* screen_position
		)

		var villager_rect: Rect2 = Rect2(
			Vector2.ZERO,
			Vector2(48.0, 48.0)
		)

		if villager_rect.has_point(
			local_mouse_position
		):
			return villager

	return null


func _select_villager(
	villager: Villager,
	card: VillagerCard,
	show_message: bool
) -> void:
	if not is_instance_valid(villager):
		return

	if not is_instance_valid(card):
		return

	var previous_selected_villager: Villager = (
		selected_villager
	)

	if (
		is_instance_valid(selected_card)
		and selected_card != card
	):
		selected_card.set_selected(
			false
		)

	if (
		is_instance_valid(previous_selected_villager)
		and previous_selected_villager != villager
	):
		_set_world_villager_selected(
			previous_selected_villager,
			false
		)

	selected_villager = villager
	selected_card = card

	card.set_selected(
		true
	)

	_set_world_villager_selected(
		villager,
		true
	)

	_update_selection_status(villager)
	_sync_village_visuals()

	if show_message:
		var dialogue_hint: String = (
			"Há um assunto importante marcado com !. Clique novamente para decidir."
			if GameManager.has_councillor_opportunity(villager.representative_id)
			else "Nenhum assunto com consequência está pendente."
		)
		var point_hint: String = (
			" A carta possui +%d ponto(s) de atributo."
			% villager.unspent_attribute_points
			if villager.unspent_attribute_points > 0
			else ""
		)
		_set_summary(
			"%s foi selecionado. Profissão atual: %s. %s%s" % [
				villager.villager_name,
				Villager.get_profession_name(villager.current_profession),
				dialogue_hint,
				point_hint
			],
			true
		)


func _open_dialogue_for_villager(villager: Villager) -> void:
	if not is_instance_valid(villager):
		return
	var opportunity: Dictionary = GameManager.get_councillor_opportunity(
		villager.representative_id
	)
	if opportunity.is_empty():
		_set_summary(
			"%s não possui um assunto com consequência pendente."
			% villager.villager_name,
			true
		)
		return
	if not is_instance_valid(dialogue_window):
		_create_dialogue_window()
	if not is_instance_valid(dialogue_window):
		return
	var conversation: Dictionary = (
		COUNCILLOR_OPPORTUNITY_DIALOGUE_CATALOG_SCRIPT.create_conversation(
			opportunity,
			{
				"food": GameManager.food,
				"material": GameManager.building_material,
				"happiness": GameManager.happiness
			}
		)
	)
	if conversation.is_empty():
		_set_summary("Não foi possível preparar o assunto do Conselho.", true)
		return
	_close_management_windows_for_dialogue()
	if is_instance_valid(building_visuals):
		building_visuals.set_simulation_active(false)
	if not dialogue_window.show_conversation(conversation):
		_set_summary("Não foi possível abrir o assunto do Conselho.", true)
	else:
		AudioManager.begin_dialogue(false)


func _open_relationship_conversation(
	npc_id: String,
	include_unknown: bool = false
) -> void:
	var overview: Dictionary = (
		GameManager.get_relationship_test_overview()
		if include_unknown
		else GameManager.get_relationship_overview()
	)
	var entry: Dictionary = _find_relationship_entry(overview, npc_id)
	if entry.is_empty():
		_set_summary("Este personagem ainda não foi apresentado pela história.", true)
		return
	var season: Dictionary = GameManager.get_current_season()
	var conversation: Dictionary = RELATIONSHIP_DIALOGUE_CATALOG_SCRIPT.create_conversation(
		npc_id,
		String(season.get("id", "spring")),
		entry,
		GameManager.get_player_profile_overview(),
		GameManager.get_relationship_world_context(),
		include_unknown,
		int(GameManager.get_campaign_identity().get("campaign_seed", 1))
	)
	_show_relationship_conversation(conversation)


func _open_relationship_personal_event(npc_id: String, event_id: String) -> void:
	var overview: Dictionary = GameManager.get_relationship_overview()
	var entry: Dictionary = _find_relationship_entry(overview, npc_id)
	if entry.is_empty():
		return
	var conversation: Dictionary = RELATIONSHIP_DIALOGUE_CATALOG_SCRIPT.create_personal_event(
		npc_id,
		event_id,
		entry,
		String(overview.get("official_partner_id", "")),
		int(GameManager.get_campaign_identity().get("campaign_seed", 1)),
		int(GameManager.get_relationship_world_context().get("day", 1))
	)
	_show_relationship_conversation(conversation)


func _open_relationship_date(npc_id: String) -> void:
	var season: Dictionary = GameManager.get_current_season()
	var conversation: Dictionary = RELATIONSHIP_DIALOGUE_CATALOG_SCRIPT.create_date_conversation(
		npc_id,
		String(season.get("id", "spring")),
		int(GameManager.get_campaign_identity().get("campaign_seed", 1)),
		int(GameManager.get_relationship_world_context().get("day", 1))
	)
	_show_relationship_conversation(conversation)


func _show_relationship_conversation(conversation: Dictionary) -> void:
	if conversation.is_empty():
		_set_summary("Não foi possível preparar esta conversa.", true)
		return
	if not is_instance_valid(dialogue_window):
		_create_dialogue_window()
	if not is_instance_valid(dialogue_window):
		return
	_close_management_windows_for_dialogue()
	if is_instance_valid(building_visuals):
		building_visuals.set_simulation_active(false)
	if not dialogue_window.show_conversation(conversation):
		_set_summary("Não foi possível abrir a conversa de relacionamento.", true)
	else:
		AudioManager.begin_dialogue(false)


func _find_relationship_entry(overview: Dictionary, npc_id: String) -> Dictionary:
	var entries_value: Variant = overview.get("entries", [])
	if not entries_value is Array:
		return {}
	for entry_value: Variant in entries_value:
		if entry_value is Dictionary and String((entry_value as Dictionary).get("npc_id", "")) == npc_id:
			return (entry_value as Dictionary).duplicate(true)
	return {}


func _on_dialogue_choice_selected(_conversation_id: String, choice_data: Dictionary) -> void:
	AudioManager.play_sfx("dialogue_choice", true)
	if choice_data.has("npc_relationship_choice"):
		var npc_result: Dictionary = GameManager.resolve_npc_relationship_choice(choice_data)
		if not bool(npc_result.get("success", false)):
			AudioManager.play_ui("blocked", false)
			_set_summary(String(npc_result.get("message", "Não foi possível registrar a decisão.")), true)
		return
	if choice_data.has("councillor_opportunity_id"):
		var opportunity_result: Dictionary = (
			GameManager.resolve_councillor_opportunity_choice(choice_data)
		)
		if bool(opportunity_result.get("success", false)):
			_set_summary(
				String(opportunity_result.get("message", "Projeto iniciado.")),
				false
			)
		else:
			AudioManager.play_ui("blocked", false)
			_set_summary(
				String(opportunity_result.get("message", "Não foi possível iniciar o projeto.")),
				true
			)
		return
	if choice_data.has("level_up_representative_id"):
		var level_result: Dictionary = GameManager.resolve_councillor_level_choice(
			choice_data
		)
		if bool(level_result.get("success", false)):
			_set_summary(String(level_result.get("message", "Conquista registrada.")), false)
		else:
			_set_summary(String(level_result.get("message", "Não foi possível registrar a resposta.")), true)
		return
	if not choice_data.has("relationship_npc_id"):
		return
	var result: Dictionary = GameManager.resolve_relationship_choice(choice_data)
	if not bool(result.get("success", false)):
		AudioManager.play_ui("blocked", false)
		_set_summary(String(result.get("message", "Não foi possível atualizar a relação.")), true)
		return
	var action: String = String(choice_data.get("relationship_action", "conversation"))
	var quality: String = String(choice_data.get("relationship_quality", "neutral"))
	if action == "commit_romance":
		AudioManager.play_sfx("relation_romance")
	elif action == "date":
		AudioManager.play_sfx("relation_date")
	elif quality == "good":
		AudioManager.play_sfx("relation_gain", true)
	elif quality == "bad":
		AudioManager.play_sfx("relation_loss", true)


func _on_relationships_changed(overview: Dictionary, result_text: String) -> void:
	if is_instance_valid(relationships_window):
		relationships_window.refresh(overview, GameManager.current_day, GameManager.get_npc_relationship_overview())
	if not result_text.is_empty():
		_set_summary(result_text, false)


func _on_npc_relationship_dialogue_requested(request: Dictionary) -> void:
	if not is_instance_valid(dialogue_window):
		_create_dialogue_window()
	if not is_instance_valid(dialogue_window):
		return
	_close_management_windows_for_dialogue()
	if is_instance_valid(building_visuals):
		building_visuals.set_simulation_active(false)
	if dialogue_window.show_conversation(request):
		AudioManager.begin_dialogue(false)
	_refresh_advance_day_state()
	_update_forecast()


func _on_npc_relationships_changed(overview: Dictionary, result_text: String) -> void:
	if is_instance_valid(relationships_window):
		relationships_window.refresh(GameManager.get_relationship_overview(), GameManager.current_day, overview)
	if not result_text.is_empty():
		_set_summary(result_text, false)


func _open_diagnostic_dialogue() -> void:
	if not is_instance_valid(dialogue_window):
		_create_dialogue_window()

	if not is_instance_valid(dialogue_window):
		return

	_close_management_windows_for_dialogue()

	if is_instance_valid(building_visuals):
		building_visuals.set_simulation_active(false)

	dialogue_window.show_conversation(
		DIALOGUE_CATALOG_SCRIPT.create_diagnostic_conversation()
	)


func show_internal_diagnostics() -> void:
	if not is_instance_valid(diagnostics_window):
		_create_diagnostics_window()

	if is_instance_valid(diagnostics_window):
		diagnostics_window.show_diagnostics()


func _close_management_windows_for_dialogue() -> void:
	if is_instance_valid(village_window) and village_window.is_window_visible():
		village_window.hide_window()
	if is_instance_valid(council_window) and council_window.is_window_visible():
		council_window.hide_window()
	if is_instance_valid(building_window) and building_window.is_window_visible():
		building_window.hide_window()
	if is_instance_valid(campaign_window) and campaign_window.is_window_visible():
		campaign_window.hide_window()
	if is_instance_valid(save_window) and save_window.is_window_visible():
		save_window.hide_window()
	if is_instance_valid(relationships_window) and relationships_window.is_window_visible():
		relationships_window.hide_window()
	if is_instance_valid(councillor_history_window) and councillor_history_window.is_window_visible():
		councillor_history_window.hide_window()
	if is_instance_valid(forecast_details_window) and forecast_details_window.is_window_visible():
		forecast_details_window.hide_window()


func _on_dialogue_closed(conversation_id: String) -> void:
	AudioManager.end_dialogue()
	if conversation_id.begins_with("npc_relation_"):
		GameManager.complete_npc_relationship_dialogue()
		_refresh_advance_day_state()
		_update_forecast()
		return
	var was_level_dialogue: bool = (
		not active_level_dialogue_id.is_empty()
		and conversation_id == active_level_dialogue_id
	)
	if was_level_dialogue:
		active_level_dialogue_id = ""
		GameManager.complete_councillor_level_dialogue(conversation_id)
		_refresh_advance_day_state()
		if is_instance_valid(building_visuals):
			building_visuals.set_simulation_active(
				is_instance_valid(village_frame)
				and village_frame.is_visible_in_tree()
				and not GameManager.has_active_event()
				and not GameManager.has_pending_story_dialogue()
				and not GameManager.has_pending_level_dialogue()
			)
		_update_forecast()
		return
	var was_story_dialogue: bool = (
		not active_story_dialogue_id.is_empty()
		and conversation_id == active_story_dialogue_id
	)
	active_story_dialogue_id = ""

	var story_result: Dictionary = {}
	if was_story_dialogue:
		story_result = GameManager.complete_story_dialogue(conversation_id)

	if is_instance_valid(building_visuals):
		building_visuals.set_simulation_active(
			is_instance_valid(village_frame)
			and village_frame.is_visible_in_tree()
			and not GameManager.has_active_event()
			and not GameManager.has_pending_story_dialogue()
		)

	if bool(story_result.get("prologue_completed", false)):
		_set_summary(
			"Prólogo concluído. A administração da vila começou.",
			false
		)
		if tutorial_after_story:
			tutorial_after_story = false
			call_deferred(
				"_show_campaign_tutorial",
				false,
				false,
				true
			)
		return

	if bool(story_result.get("debug_sequence_completed", false)):
		_set_summary("Teste narrativo encerrado sem alterar a campanha.", false)
		return

	if (
		was_story_dialogue
		and GameManager.has_pending_story_dialogue()
		and not GameManager.has_active_event()
		and not GameManager.has_pending_level_dialogue()
	):
		call_deferred("_request_pending_story_dialogue")
		return

	if not was_story_dialogue:
		if conversation_id.begins_with("relationship_") or "_personal_" in conversation_id:
			_on_relationships_changed(GameManager.get_relationship_overview(), "")
			# Depois da auditoria final não existem novas avaliações. Vagas antigas
			# ainda pendentes são rechecadas quando um vínculo muda, sem criar
			# recrutamentos adicionais além dos seis já desbloqueados.
			GameManager.recheck_pending_recruitment_after_final_audit()
			return
		_set_summary("A conversa foi encerrada.", false)


func _request_pending_story_dialogue() -> void:
	GameManager.request_pending_story_dialogue()


func _on_story_dialogue_requested(request: Dictionary) -> void:
	var dialogue_id: String = String(
		request.get("dialogue_id", "")
	).strip_edges()
	if dialogue_id.is_empty():
		return

	if not is_instance_valid(dialogue_window):
		_create_dialogue_window()
	if not is_instance_valid(dialogue_window):
		return

	var conversation: Dictionary = (
		DIALOGUE_CATALOG_SCRIPT.create_story_conversation(dialogue_id)
	)
	if conversation.is_empty():
		AudioManager.end_dialogue()
		push_error("Diálogo principal inexistente: %s." % dialogue_id)
		_set_summary(
			"Não foi possível abrir um trecho da história.",
			true
		)
		return

	_close_management_windows_for_dialogue()
	if is_instance_valid(building_visuals):
		building_visuals.set_simulation_active(false)
	active_story_dialogue_id = dialogue_id
	_refresh_advance_day_state()
	if not dialogue_window.show_conversation(conversation):
		active_story_dialogue_id = ""
		AudioManager.end_dialogue()
		_set_summary("Não foi possível abrir o diálogo principal.", true)


func _on_story_npc_recruited(npc_data: Dictionary) -> void:
	var display_name: String = String(
		npc_data.get("display_name", "Novo personagem")
	)
	_set_summary(
		"%s decidiu permanecer na vila." % display_name,
		true
	)


func _on_story_chapter_completed(chapter_data: Dictionary) -> void:
	var title: String = String(
		chapter_data.get("title", "Capítulo concluído")
	)
	_set_summary("CAPÍTULO CONCLUÍDO — %s" % title, true)


func _on_diagnostic_story_test_requested(chapter_day: int) -> void:
	var result: Dictionary = GameManager.debug_start_story_sequence(
		chapter_day
	)
	if not bool(result.get("success", false)):
		_set_summary(
			String(result.get("message", "Teste narrativo indisponível.")),
			true
		)


func _on_diagnostic_dialogue_test_requested() -> void:
	_open_diagnostic_dialogue()


func _update_selection_status(
	villager: Villager
) -> void:
	if not is_instance_valid(villager):
		return

	selection_status_label.text = (
		"SELECIONADO: %s"
		% villager.villager_name.to_upper()
	)

	selection_status_label.add_theme_color_override(
		"font_color",
		MedievalTheme.GOLD
	)

	var dialogue_status: String = (
		"Há um assunto marcado com !; clique novamente para decidir."
		if GameManager.has_councillor_opportunity(villager.representative_id)
		else "Nenhuma decisão do Conselho está pendente para esta carta."
	)
	selection_status_label.tooltip_text = "%s trabalha como %s. %s" % [
		villager.villager_name,
		Villager.get_profession_name(villager.current_profession),
		dialogue_status
	]

	if is_instance_valid(selected_profession_selector):
		updating_selected_profession = true
		selected_profession_selector.disabled = false
		var profession_index: int = (
			selected_profession_selector.get_item_index(
				villager.current_profession
			)
		)
		if profession_index >= 0:
			selected_profession_selector.select(profession_index)
		selected_profession_selector.tooltip_text = (
			"Trabalho atual de %s: %s."
		) % [
			villager.villager_name,
			Villager.get_profession_name(villager.current_profession)
		]
		updating_selected_profession = false


func _prepare_world_villager_interaction(
	villager: Villager
) -> void:
	if not is_instance_valid(villager):
		return

	if not villager.has_meta(
		"ui_original_modulate"
	):
		villager.set_meta(
			"ui_original_modulate",
			villager.self_modulate
		)

	if not villager.has_meta(
		"ui_original_scale"
	):
		villager.set_meta(
			"ui_original_scale",
			villager.scale
		)


func _set_world_villager_selected(
	villager: Villager,
	is_selected: bool
) -> void:
	if is_instance_valid(building_visuals):
		return

	if not is_instance_valid(villager):
		return

	var scale_multiplier: float = (
		1.14
		if is_selected
		else 1.0
	)

	_animate_world_villager(
		villager,
		scale_multiplier,
		is_selected,
		0.16
	)


func _animate_world_villager(
	villager: Villager,
	scale_multiplier: float,
	is_selected: bool,
	duration: float
) -> void:
	if not is_instance_valid(villager):
		return

	var villager_id: int = villager.get_instance_id()

	if world_tweens.has(villager_id):
		var old_tween: Tween = (
			world_tweens[villager_id] as Tween
		)

		if old_tween != null and old_tween.is_valid():
			old_tween.kill()

	var base_scale: Vector2 = villager.get_meta(
		"ui_original_scale",
		Vector2.ONE
	)

	var target_scale: Vector2 = (
		base_scale * scale_multiplier
	)

	var original_modulate: Color = villager.get_meta(
		"ui_original_modulate",
		Color.WHITE
	)

	var target_modulate: Color = original_modulate

	if is_selected:
		target_modulate = (
			original_modulate
			* Color("#FFF2B8")
		)

	if GameSettings.reduced_motion:
		villager.scale = target_scale
		villager.self_modulate = target_modulate
		return

	var tween: Tween = create_tween()
	world_tweens[villager_id] = tween

	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		villager,
		"scale",
		target_scale,
		duration
	)

	tween.tween_property(
		villager,
		"self_modulate",
		target_modulate,
		duration
	)


func _get_advance_day_blocker() -> Dictionary:
	if GameManager.is_campaign_finished():
		return {
			"id": "campaign_finished",
			"status": "PARTIDA ENCERRADA",
			"message": "Abra os objetivos para rever o resultado.",
			"color": MedievalTheme.GOLD
		}
	if GameManager.has_active_event():
		return {
			"id": "active_event",
			"status": "ACONTECIMENTO PENDENTE",
			"message": "Resolva o acontecimento antes de encerrar outro dia.",
			"color": MedievalTheme.GOLD
		}
	if GameManager.has_pending_level_dialogue():
		return {
			"id": "level_dialogue",
			"status": "CONQUISTA PENDENTE",
			"message": "Conclua a conversa especial da carta para continuar.",
			"color": MedievalTheme.GOLD
		}
	if GameManager.has_pending_story_dialogue():
		return {
			"id": "story_dialogue",
			"status": "HISTÓRIA PENDENTE",
			"message": "Conclua a conversa da história antes de encerrar outro dia.",
			"color": MedievalTheme.GOLD
		}
	if GameManager.has_pending_npc_relationship_dialogue():
		return {
			"id": "npc_relationship_dialogue",
			"status": "CONVERSA PENDENTE",
			"message": "Conclua a conversa entre personagens antes de continuar.",
			"color": MedievalTheme.GOLD
		}
	if not GameManager.is_council_ready():
		return {
			"id": "council_incomplete",
			"status": "CONSELHO INCOMPLETO",
			"message": "Complete o Conselho antes de encerrar o dia.",
			"color": Color("#F07F72")
		}
	return {}


func _refresh_advance_day_state() -> void:
	if not is_instance_valid(advance_day_button):
		return
	var blocker: Dictionary = _get_advance_day_blocker()
	advance_day_button.disabled = not blocker.is_empty()
	advance_day_button.text = (
		"CAMPANHA ENCERRADA"
		if String(blocker.get("id", "")) == "campaign_finished"
		else "ENCERRAR O DIA"
	)
	advance_day_button.tooltip_text = String(
		blocker.get(
			"message",
			"Calcula a produção, o consumo e as consequências do dia."
		)
	)


func _resume_pending_mandatory_content() -> void:
	_refresh_advance_day_state()
	_update_forecast()
	if (
		is_instance_valid(tutorial_window)
		and tutorial_window.is_window_visible()
	):
		return
	if (
		is_instance_valid(dialogue_window)
		and dialogue_window.is_dialogue_visible()
	):
		return
	if GameManager.has_active_event():
		var pending_event: Dictionary = GameManager.get_active_event()
		if (
			not pending_event.is_empty()
			and (
				not is_instance_valid(event_window)
				or not event_window.has_event_data()
				or not event_window.is_event_visible()
			)
		):
			_on_village_event_started(pending_event)
		return
	if GameManager.has_pending_level_dialogue():
		GameManager.request_next_level_dialogue()
		return
	if GameManager.has_pending_story_dialogue():
		GameManager.request_pending_story_dialogue()
		return
	if GameManager.has_pending_npc_relationship_dialogue():
		GameManager.request_pending_npc_relationship_dialogue()


func _on_advance_day_pressed() -> void:
	var blocker: Dictionary = _get_advance_day_blocker()
	if not blocker.is_empty():
		if String(blocker.get("id", "")) == "campaign_finished":
			if not is_instance_valid(campaign_window):
				_create_campaign_window()
			campaign_window.show_result(GameManager.get_campaign_result())
		else:
			_resume_pending_mandatory_content()
		return

	advance_day_button.disabled = true
	_animate_advance_day_button()

	GameManager.advance_day()
	_refresh_advance_day_state()


func _on_day_advanced(summary: String) -> void:
	_set_summary(
		summary,
		true
	)


func _on_game_settings_changed(_settings_data: Dictionary) -> void:
	_apply_season_appearance(GameManager.current_day, true)



func _on_viewport_size_changed() -> void:
	_queue_world_layout()


func _on_village_frame_resized() -> void:
	_queue_world_layout()


func _queue_world_layout() -> void:
	# O layout moderno desenha a vila dentro de BuildingVisuals.
	# Sem o antigo VillageGround não há nada para reposicionar.
	if not is_instance_valid(village_ground):
		return

	if world_layout_queued:
		return

	world_layout_queued = true
	call_deferred(
		"_layout_world_after_containers"
	)


func _layout_world_after_containers() -> void:
	# Os Container do Godot concluem a distribuição no fim do
	# quadro. Novo jogo e carregamento podem disparar vários
	# redimensionamentos antes de a Área da Vila chegar ao
	# tamanho definitivo.
	await get_tree().process_frame

	world_layout_queued = false
	_layout_world()


func _layout_world() -> void:
	if not is_instance_valid(village_frame):
		return

	if not is_instance_valid(village_ground):
		return

	var frame_rect: Rect2 = village_frame.get_global_rect()
	var ground_position: Vector2 = (
		frame_rect.position + Vector2(5.0, 5.0)
	)
	var ground_size: Vector2 = (
		frame_rect.size - Vector2(10.0, 10.0)
	)

	if ground_size.x <= 0.0 or ground_size.y <= 0.0:
		return

	village_ground.global_position = ground_position
	village_ground.size = ground_size
	village_ground.color = MedievalTheme.GRASS

	# Os representantes são desenhados por BuildingVisuals.gd.
	# A cena original permanece somente como modelo de dados.


func _animate_interface_entrance() -> void:
	if not is_instance_valid(interface_root):
		return

	if GameSettings.reduced_motion:
		interface_root.modulate = Color.WHITE
		return

	var tween: Tween = create_tween()

	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		interface_root,
		"modulate",
		Color.WHITE,
		0.30
	)


func _animate_label_pulse(
	target_label: Label,
	scale_amount: float
) -> void:
	if not is_instance_valid(target_label):
		return

	var label_id: int = target_label.get_instance_id()

	if label_tweens.has(label_id):
		var old_tween: Tween = (
			label_tweens[label_id] as Tween
		)

		if old_tween != null and old_tween.is_valid():
			old_tween.kill()

	target_label.pivot_offset = (
		target_label.size * 0.5
	)

	target_label.scale = Vector2.ONE

	if GameSettings.reduced_motion:
		return

	var tween: Tween = create_tween()
	label_tweens[label_id] = tween

	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		target_label,
		"scale",
		Vector2(scale_amount, scale_amount),
		0.09
	)

	tween.tween_property(
		target_label,
		"scale",
		Vector2.ONE,
		0.15
	)


func _animate_advance_day_button() -> void:
	if GameSettings.reduced_motion:
		advance_day_button.scale = Vector2.ONE
		return

	advance_day_button.pivot_offset = (
		advance_day_button.size * 0.5
	)

	var tween: Tween = create_tween()

	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		advance_day_button,
		"scale",
		Vector2(0.96, 0.96),
		0.07
	)

	tween.tween_property(
		advance_day_button,
		"scale",
		Vector2.ONE,
		0.14
	)


func _set_summary(
	message: String,
	animate: bool
) -> void:
	if not is_instance_valid(summary_label):
		return

	summary_label.text = message
	summary_label.scroll_to_line(0)

	if (
		not interface_ready
		or not animate
		or GameSettings.reduced_motion
	):
		summary_label.modulate = Color.WHITE
		return

	var label_id: int = summary_label.get_instance_id()

	if label_tweens.has(label_id):
		var old_tween: Tween = (
			label_tweens[label_id] as Tween
		)

		if old_tween != null and old_tween.is_valid():
			old_tween.kill()

	summary_label.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.25
	)

	var tween: Tween = create_tween()
	label_tweens[label_id] = tween

	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		summary_label,
		"modulate",
		Color.WHITE,
		0.24
	)
