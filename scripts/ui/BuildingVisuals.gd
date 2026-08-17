class_name VillageBuildingVisuals
extends Control


signal building_requested(building_id: String)
signal council_member_requested(representative_id: String)


const VILLAGE_PAWN_SCRIPT = preload(
	"res://scripts/ui/VillagePawn.gd"
)

const MAP_TOP_MARGIN: float = 52.0
const MAP_SIDE_MARGIN: float = 8.0
const MAP_BOTTOM_MARGIN: float = 8.0
const HOUSE_VISUAL_LIMIT: int = 12
const COMMON_VILLAGER_LIMIT_SMALL: int = 10
const COMMON_VILLAGER_LIMIT_LARGE: int = 20

const COUNCIL_POINTS_SMALL: Array[Vector2] = [
	Vector2(0.42, 0.40),
	Vector2(0.56, 0.35),
	Vector2(0.62, 0.54),
	Vector2(0.46, 0.57)
]

const COUNCIL_POINTS_LARGE: Array[Vector2] = [
	Vector2(0.40, 0.38),
	Vector2(0.53, 0.31),
	Vector2(0.65, 0.51),
	Vector2(0.47, 0.57)
]

# Os primeiros lotes são os mais livres. Assim, as duas casas
# iniciais nunca cobrem os prédios principais.
const HOUSE_POINTS_SMALL: Array[Vector2] = [
	Vector2(0.34, 0.67),
	Vector2(0.68, 0.69),
	Vector2(0.31, 0.48),
	Vector2(0.74, 0.51),
	Vector2(0.43, 0.76),
	Vector2(0.57, 0.77),
	Vector2(0.79, 0.66),
	Vector2(0.24, 0.78),
	Vector2(0.69, 0.23),
	Vector2(0.57, 0.21),
	Vector2(0.37, 0.25),
	Vector2(0.84, 0.80)
]

const HOUSE_POINTS_LARGE: Array[Vector2] = [
	Vector2(0.33, 0.68),
	Vector2(0.69, 0.70),
	Vector2(0.29, 0.48),
	Vector2(0.76, 0.49),
	Vector2(0.42, 0.79),
	Vector2(0.57, 0.80),
	Vector2(0.81, 0.66),
	Vector2(0.21, 0.79),
	Vector2(0.70, 0.22),
	Vector2(0.58, 0.18),
	Vector2(0.38, 0.22),
	Vector2(0.86, 0.81)
]

const COMMON_ROUTE_POINTS: Array[Vector2] = [
	Vector2(0.25, 0.35),
	Vector2(0.35, 0.39),
	Vector2(0.45, 0.35),
	Vector2(0.55, 0.44),
	Vector2(0.66, 0.42),
	Vector2(0.76, 0.36),
	Vector2(0.70, 0.56),
	Vector2(0.59, 0.61),
	Vector2(0.47, 0.57),
	Vector2(0.36, 0.59),
	Vector2(0.28, 0.70),
	Vector2(0.43, 0.72),
	Vector2(0.58, 0.72),
	Vector2(0.74, 0.67)
]

const PATH_NETWORK: Array[Array] = [
	[
		Vector2(0.17, 0.30),
		Vector2(0.31, 0.36),
		Vector2(0.45, 0.39),
		Vector2(0.56, 0.45),
		Vector2(0.81, 0.33)
	],
	[
		Vector2(0.56, 0.45),
		Vector2(0.55, 0.57),
		Vector2(0.54, 0.79)
	],
	[
		Vector2(0.45, 0.39),
		Vector2(0.36, 0.51),
		Vector2(0.22, 0.70)
	],
	[
		Vector2(0.56, 0.45),
		Vector2(0.69, 0.57),
		Vector2(0.80, 0.73)
	],
	[
		Vector2(0.45, 0.39),
		Vector2(0.51, 0.22),
		Vector2(0.51, 0.08)
	]
]

const PAWN_COLORS: Array[Color] = [
	Color("#5DADE2"),
	Color("#E67E80"),
	Color("#73C991"),
	Color("#C792EA"),
	Color("#E5B567"),
	Color("#56B6C2"),
	Color("#D19A66"),
	Color("#F07178"),
	Color("#98C379"),
	Color("#61AFEF"),
	Color("#C678DD"),
	Color("#E06C75")
]

const REPRESENTATIVE_COLOR_INDEX: Dictionary = {
	"representante_01": 0,
	"representante_02": 1,
	"representante_03": 2,
	"representante_04": 3,
	"passos_leves_faz_tudo": 4,
	"aelric_ferreiro": 5,
	"kobi_mercante": 6,
	"orion_draconato": 7,
	"rubra_meio_demonia": 8,
	"brunna_ana_barbara": 9,
	"meio_vampiro_emo_gotico": 10,
	"bruxinha_ruiva": 11
}

const GROUND_TEXTURE_PATHS := {
	"spring": "res://assets/etapa5/ground_spring.png",
	"summer": "res://assets/etapa5/ground_summer.png",
	"autumn": "res://assets/etapa5/ground_autumn.png",
	"winter": "res://assets/etapa5/ground_winter.png"
}

const BUILDING_TEXTURES := {
	"empty": "res://assets/etapa5/empty_lot.png",
	"house_1": "res://assets/etapa5/house_level1.png",
	"house_2": "res://assets/etapa5/house_level2.png",
	"house_3": "res://assets/etapa5/house_level3.png",
	"barn_1": "res://assets/etapa5/barn_level1.png",
	"barn_2": "res://assets/etapa5/barn_level2.png",
	"barn_3": "res://assets/etapa5/barn_level3.png",
	"sawmill_1": "res://assets/etapa5/sawmill_level1.png",
	"sawmill_2": "res://assets/etapa5/sawmill_level2.png",
	"sawmill_3": "res://assets/etapa5/sawmill_level3.png",
	"well_1": "res://assets/etapa5/well_level1.png",
	"well_2": "res://assets/etapa5/well_level2.png",
	"well_3": "res://assets/etapa5/well_level3.png",
	"square_1": "res://assets/etapa5/square_level1.png",
	"square_2": "res://assets/etapa5/square_level2.png",
	"square_3": "res://assets/etapa5/square_level3.png"
}

const BUILDING_VARIANT_TEXTURES := {
	"silo_reserve": "res://assets/buildings/variants/barn_silo.png",
	"community_kitchen": "res://assets/buildings/variants/barn_kitchen.png",
	"intensive_sawmill": "res://assets/buildings/variants/sawmill_intensive.png",
	"carpentry_workshop": "res://assets/buildings/variants/sawmill_carpentry.png",
	"deep_reservoir": "res://assets/buildings/variants/well_reservoir.png",
	"community_fountain": "res://assets/buildings/variants/well_fountain.png",
	"community_market": "res://assets/buildings/variants/square_market.png",
	"public_garden": "res://assets/buildings/variants/square_garden.png",
	"stone_bastion": "res://assets/buildings/variants/palisade_bastion.png",
	"vigilant_gates": "res://assets/buildings/variants/palisade_gates.png"
}

var is_large_view: bool = false
var simulation_active: bool = true
var current_season_id: String = "spring"
var current_building_state: Dictionary = {}
var current_population_overview: Dictionary = {}
var current_council_members: Array = []
var current_selected_member_id: String = ""
var current_memory_markers: Array = []

var ground_rect: TextureRect
var building_layer: Control
var villager_layer: Control
var overlay_label: Label
var extra_house_label: Label
var feedback_banner: PanelContainer
var feedback_label: Label

var building_buttons: Dictionary = {}
var building_levels: Dictionary = {}
var building_variants: Dictionary = {}
var house_nodes: Array[TextureRect] = []
var council_nodes_by_id: Dictionary = {}
var common_villager_nodes: Array[Control] = []
var villager_tweens: Dictionary = {}

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _loaded_textures: Dictionary = {}
var _palisade_icon_textures: Dictionary = {}
var _last_population_signature: String = ""
var _last_council_signature: String = ""
var _last_house_signature: String = ""
var _feedback_tween: Tween
var _feedback_kind: String = ""
var _feedback_target: Vector2 = Vector2(0.53, 0.45)
var _feedback_alpha: float = 0.0
var _reduced_motion_active: bool = false


func _ready() -> void:
	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	_rng.seed = 251052
	_reduced_motion_active = GameSettings.reduced_motion
	# A vila sempre fica abaixo das janelas modais. Os filhos
	# usam apenas pequenas faixas locais de profundidade.
	z_index = 0
	_create_layers()
	_apply_view_mode()
	resized.connect(_on_resized)
	_apply_ground_texture()
	_ensure_building_buttons()
	_ensure_house_nodes()
	_on_resized()


func set_large_view_enabled(value: bool) -> void:
	if is_large_view == value:
		return

	is_large_view = value
	_last_house_signature = ""

	if not is_instance_valid(ground_rect):
		return

	_apply_view_mode()
	_restart_common_villager_routes()
	_on_resized()


func set_simulation_active(value: bool) -> void:
	if simulation_active == value:
		return

	simulation_active = value

	if simulation_active:
		_restart_common_villager_routes()
	else:
		_stop_common_villager_routes()


func refresh_motion_setting() -> void:
	if _reduced_motion_active == GameSettings.reduced_motion:
		return
	_restart_common_villager_routes()


func apply_season(season_id: String) -> void:
	var normalized_id: String = season_id

	if not GROUND_TEXTURE_PATHS.has(normalized_id):
		normalized_id = "spring"

	if current_season_id == normalized_id:
		return

	current_season_id = normalized_id
	_apply_ground_texture()
	_restyle_common_villagers()
	queue_redraw()


func update_population_overview(
	population_overview: Dictionary
) -> void:
	current_population_overview = (
		population_overview.duplicate(true)
	)

	var signature: String = "%d|%d|%d|%d|%s" % [
		int(current_population_overview.get("total_population", 0)),
		int(current_population_overview.get("housing_capacity", 0)),
		int(current_population_overview.get("common_population", 0)),
		int(current_population_overview.get("protected_named_resident_count", 5)),
		_get_happiness_band()
	]

	_update_house_visuals()
	_update_overlay_label()

	if signature != _last_population_signature:
		_last_population_signature = signature
		_rebuild_common_villagers()
		queue_redraw()


func update_council(
	council_members: Array,
	selected_member_id: String = ""
) -> void:
	var previous_selected_id: String = (
		current_selected_member_id
	)
	current_council_members = council_members.duplicate()
	current_selected_member_id = selected_member_id

	var signature_parts: Array[String] = []

	for villager_value: Variant in current_council_members:
		var villager: Villager = villager_value as Villager

		if not is_instance_valid(villager):
			continue

		signature_parts.append(
			"%s:%s:%d" % [
				villager.representative_id,
				villager.villager_name,
				villager.current_profession
			]
		)

	var signature: String = "|".join(signature_parts)
	var roster_changed: bool = (
		signature != _last_council_signature
	)
	var selection_changed: bool = (
		previous_selected_id != selected_member_id
	)

	if not roster_changed and not selection_changed:
		return

	_last_council_signature = signature
	_sync_council_nodes()

	if roster_changed:
		_rebuild_common_villagers()


func set_selected_member(
	representative_id: String
) -> void:
	if current_selected_member_id == representative_id:
		return

	current_selected_member_id = representative_id
	_sync_council_nodes()


func update_buildings(
	building_state: Dictionary,
	animate_changes: bool = true
) -> void:
	current_building_state = building_state.duplicate(true)
	_ensure_building_buttons()
	_refresh_building_buttons(animate_changes)
	_update_house_visuals()
	_update_overlay_label()
	queue_redraw()


func update_memory_markers(markers: Array) -> void:
	var signature_before: String = str(current_memory_markers)
	current_memory_markers = markers.duplicate(true)
	if str(current_memory_markers) != signature_before:
		queue_redraw()


func show_world_feedback(feedback_data: Dictionary) -> void:
	var message: String = String(
		feedback_data.get("message", "")
	).strip_edges()
	if message.is_empty() or not is_instance_valid(feedback_banner):
		return

	_feedback_kind = String(feedback_data.get("kind", "notice"))
	var target_id: String = String(feedback_data.get("target_id", ""))
	_feedback_target = (
		_get_building_position(target_id)
		if target_id in ["barn", "sawmill", "well", "square", "palisade"]
		else Vector2(0.53, 0.45)
	)
	_feedback_alpha = 1.0
	feedback_label.text = message.to_upper()
	feedback_banner.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			Color(0.08, 0.06, 0.07, 0.96),
			_get_feedback_color(),
			2,
			8,
			10,
			3
		)
	)
	feedback_label.add_theme_color_override(
		"font_color",
		_get_feedback_color()
	)
	feedback_banner.visible = true
	feedback_banner.modulate = Color.WHITE
	feedback_banner.scale = Vector2.ONE
	queue_redraw()

	if _feedback_tween != null and _feedback_tween.is_valid():
		_feedback_tween.kill()
	_feedback_tween = create_tween()
	if GameSettings.reduced_motion:
		_feedback_tween.tween_interval(1.8)
	else:
		feedback_banner.scale = Vector2(0.96, 0.96)
		_feedback_tween.tween_property(
			feedback_banner,
			"scale",
			Vector2.ONE,
			0.16
		)
		_feedback_tween.tween_method(
			_set_feedback_alpha,
			1.0,
			0.0,
			0.90
		)
		_feedback_tween.tween_interval(0.75)
		_feedback_tween.tween_property(
			feedback_banner,
			"modulate",
			Color(1.0, 1.0, 1.0, 0.0),
			0.22
		)
	_feedback_tween.tween_callback(_hide_world_feedback)


func _create_layers() -> void:
	ground_rect = TextureRect.new()
	ground_rect.name = "Ground"
	ground_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ground_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ground_rect.stretch_mode = TextureRect.STRETCH_SCALE
	ground_rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	ground_rect.show_behind_parent = true
	ground_rect.z_index = -20
	add_child(ground_rect)

	building_layer = Control.new()
	building_layer.name = "Buildings"
	building_layer.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	building_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	building_layer.clip_contents = true
	building_layer.z_index = 0
	add_child(building_layer)

	villager_layer = Control.new()
	villager_layer.name = "Villagers"
	villager_layer.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	villager_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	villager_layer.clip_contents = true
	villager_layer.z_index = 30
	add_child(villager_layer)

	overlay_label = Label.new()
	overlay_label.name = "VillageStatus"
	overlay_label.z_index = 55
	overlay_label.visible = false
	overlay_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_LEFT
	)
	overlay_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)
	overlay_label.add_theme_font_size_override(
		"font_size",
		13
	)
	overlay_label.add_theme_color_override(
		"font_color",
		MedievalTheme.PARCHMENT_LIGHT
	)
	overlay_label.add_theme_color_override(
		"font_shadow_color",
		Color(0.0, 0.0, 0.0, 0.82)
	)
	overlay_label.add_theme_constant_override(
		"shadow_offset_x",
		1
	)
	overlay_label.add_theme_constant_override(
		"shadow_offset_y",
		1
	)
	add_child(overlay_label)

	extra_house_label = Label.new()
	extra_house_label.name = "ExtraHouses"
	extra_house_label.z_index = 54
	extra_house_label.visible = false
	extra_house_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	extra_house_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	extra_house_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)
	extra_house_label.add_theme_font_size_override(
		"font_size",
		15
	)
	extra_house_label.add_theme_color_override(
		"font_color",
		MedievalTheme.PARCHMENT_LIGHT
	)
	extra_house_label.add_theme_color_override(
		"font_shadow_color",
		Color(0.0, 0.0, 0.0, 0.82)
	)
	extra_house_label.add_theme_color_override(
		"font_outline_color",
		Color(0.08, 0.05, 0.03, 0.95)
	)
	extra_house_label.add_theme_constant_override(
		"outline_size",
		4
	)
	extra_house_label.add_theme_constant_override(
		"shadow_offset_x",
		1
	)
	extra_house_label.add_theme_constant_override(
		"shadow_offset_y",
		1
	)
	add_child(extra_house_label)

	feedback_banner = PanelContainer.new()
	feedback_banner.name = "VillageFeedback"
	feedback_banner.visible = false
	feedback_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	feedback_banner.z_index = 70
	feedback_banner.pivot_offset = Vector2(180.0, 24.0)
	add_child(feedback_banner)

	feedback_label = Label.new()
	feedback_label.custom_minimum_size = Vector2(360.0, 42.0)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	feedback_label.add_theme_font_size_override("font_size", 13)
	feedback_banner.add_child(feedback_label)


func _apply_view_mode() -> void:
	if is_instance_valid(overlay_label):
		overlay_label.visible = is_large_view

	for button_value: Variant in council_nodes_by_id.values():
		var button: Button = button_value as Button

		if not is_instance_valid(button):
			continue

		var name_label: Label = (
			button.get_node_or_null("Name") as Label
		)

		if is_instance_valid(name_label):
			name_label.visible = is_large_view


func _ensure_building_buttons() -> void:
	for building_id: String in [
		"barn",
		"sawmill",
		"well",
		"square",
		"palisade"
	]:
		if building_buttons.has(building_id):
			continue

		var button: TextureButton = TextureButton.new()
		button.name = "%sButton" % building_id.capitalize()
		button.ignore_texture_size = true
		button.stretch_mode = (
			TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		)
		button.texture_filter = (
			CanvasItem.TEXTURE_FILTER_LINEAR
		)
		button.mouse_default_cursor_shape = (
			Control.CURSOR_POINTING_HAND
		)
		button.focus_mode = Control.FOCUS_ALL
		button.pressed.connect(
			_on_building_button_pressed.bind(
				building_id
			)
		)
		building_layer.add_child(button)
		building_buttons[building_id] = button
		building_levels[building_id] = 0
		building_variants[building_id] = ""


func _ensure_house_nodes() -> void:
	if not house_nodes.is_empty():
		return

	for index: int in range(HOUSE_VISUAL_LIMIT):
		var house: TextureRect = TextureRect.new()
		house.name = "House_%02d" % index
		house.mouse_filter = Control.MOUSE_FILTER_IGNORE
		house.visible = false
		house.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		house.stretch_mode = (
			TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		)
		house.texture_filter = (
			CanvasItem.TEXTURE_FILTER_LINEAR
		)
		building_layer.add_child(house)
		house_nodes.append(house)


func _refresh_building_buttons(
	animate_changes: bool
) -> void:
	var state_by_id: Dictionary = {}
	var buildings: Array = current_building_state.get(
		"buildings",
		[]
	)

	for building_value: Variant in buildings:
		var building: Dictionary = building_value
		var building_id: String = String(
			building.get("id", "")
		)

		if not building_id.is_empty():
			state_by_id[building_id] = building

	var building_names := {
		"barn": "Celeiro",
		"sawmill": "Serraria",
		"well": "Poço",
		"square": "Praça",
		"palisade": "Muralha"
	}

	var active_by_building: Dictionary = {}
	var construction: Dictionary = current_building_state.get("construction", {})
	for order_value: Variant in construction.get("active_orders", []):
		if not order_value is Dictionary:
			continue
		var order: Dictionary = order_value as Dictionary
		if bool(order.get("is_housing", false)):
			continue
		active_by_building[String(order.get("building_id", ""))] = order

	for building_id_value: Variant in building_buttons.keys():
		var building_id: String = String(building_id_value)
		var button: TextureButton = (
			building_buttons.get(building_id) as TextureButton
		)

		if not is_instance_valid(button):
			continue

		var building_state: Dictionary = state_by_id.get(
			building_id,
			{}
		)
		var old_level: int = int(
			building_levels.get(building_id, 0)
		)
		var level: int = int(
			building_state.get("current_level", 0)
		)
		var variant_id: String = String(
			building_state.get("current_variant_id", "")
		)
		var texture: Texture2D = _get_building_texture(
			building_id,
			level,
			variant_id
		)

		button.texture_normal = texture
		button.texture_hover = texture
		button.texture_pressed = texture
		button.texture_disabled = texture
		button.modulate = (
			Color.WHITE
			if level > 0
			else Color(1.0, 1.0, 1.0, 0.68)
		)
		button.tooltip_text = "%s — %s" % [
			String(
				building_names.get(
					building_id,
					building_id.capitalize()
				)
			),
			(
				"Nível %d" % level
				if level > 0
				else "terreno disponível"
			)
		]
		var variant_name: String = String(
			building_state.get("current_variant_name", "")
		)
		if not variant_name.is_empty():
			button.tooltip_text += "\nBUILD FINAL: %s" % variant_name
		if active_by_building.has(building_id):
			var active_order: Dictionary = active_by_building[building_id]
			button.tooltip_text += "\nEM OBRA: %d/%d dia(s)." % [
				int(active_order.get("progress_days", 0)),
				int(active_order.get("work_days", 1))
			]
		building_levels[building_id] = level
		building_variants[building_id] = variant_id

		if animate_changes and level > old_level:
			_animate_button_upgrade(button)

	_on_resized()


func _update_house_visuals() -> void:
	var house_count: int = int(
		current_building_state.get("house_count", 2)
	)
	var housing_capacity: int = int(
		current_population_overview.get(
			"housing_capacity",
			maxi(10, house_count * 5)
		)
	)
	var population: int = int(
		current_population_overview.get(
			"total_population",
			0
		)
	)
	var house_signature: String = "%d|%d|%d|%s" % [
		house_count,
		housing_capacity,
		population,
		str(is_large_view)
	]

	if house_signature == _last_house_signature:
		return

	_last_house_signature = house_signature
	var house_level: int = 1

	if housing_capacity >= 30 or population >= 25:
		house_level = 2

	if housing_capacity >= 55 or population >= 45:
		house_level = 3

	var house_texture: Texture2D = _get_texture(
		"house_%d" % house_level
	)
	var visible_house_count: int = mini(
		house_count,
		HOUSE_VISUAL_LIMIT
	)

	for index: int in range(house_nodes.size()):
		var house: TextureRect = house_nodes[index]

		if not is_instance_valid(house):
			continue

		house.visible = index < visible_house_count
		house.texture = house_texture

	extra_house_label.visible = (
		house_count > HOUSE_VISUAL_LIMIT
	)
	extra_house_label.text = "MORADIAS: +%d casas" % maxi(
		0,
		house_count - HOUSE_VISUAL_LIMIT
	)
	_on_resized()


func _sync_council_nodes() -> void:
	var active_ids: Array[String] = []
	var slot_index: int = 0

	for villager_value: Variant in current_council_members:
		var villager: Villager = villager_value as Villager

		if not is_instance_valid(villager):
			continue

		var representative_id: String = (
			villager.representative_id
		)
		active_ids.append(representative_id)

		var button: Button = (
			council_nodes_by_id.get(
				representative_id,
				null
			) as Button
		)

		if not is_instance_valid(button):
			button = _create_council_node(
				representative_id
			)
			council_nodes_by_id[representative_id] = button

		button.visible = true
		button.tooltip_text = "%s — %s" % [
			villager.villager_name,
			Villager.get_profession_name(
				villager.current_profession
			)
		]
		var pawn: VillageBoardPawn = (
			button.get_node_or_null("Pawn") as VillageBoardPawn
		)
		if is_instance_valid(pawn):
			pawn.configure(
				_get_representative_pawn_color(representative_id),
				_get_happiness_mood_id(),
				slot_index,
				true,
				representative_id == current_selected_member_id
			)

		var name_label: Label = (
			button.get_node_or_null("Name") as Label
		)

		if is_instance_valid(name_label):
			name_label.text = villager.villager_name
			name_label.visible = (
				is_large_view
				or representative_id
				== current_selected_member_id
			)

		var badge: Label = (
			button.get_node_or_null("Badge") as Label
		)

		if is_instance_valid(badge):
			badge.text = _get_pawn_initial(villager.villager_name)
			badge.modulate = Color.WHITE

		button.scale = (
			Vector2.ONE * 1.12
			if representative_id
			== current_selected_member_id
			else Vector2.ONE
		)
		button.modulate = Color.WHITE
		button.z_index = 10 + slot_index
		slot_index += 1

	for existing_id_value: Variant in council_nodes_by_id.keys():
		var existing_id: String = String(existing_id_value)

		if existing_id in active_ids:
			continue

		var stale_button: Button = (
			council_nodes_by_id.get(existing_id) as Button
		)

		if is_instance_valid(stale_button):
			stale_button.visible = false

	_layout_council_nodes()


func _create_council_node(
	representative_id: String
) -> Button:
	var button: Button = Button.new()
	button.name = "Council_" + representative_id
	button.flat = true
	button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)
	button.focus_mode = Control.FOCUS_ALL
	VillageUIAccessibility.configure_button(
		button,
		"Seleciona este representante no Conselho.",
		36.0
	)
	button.pressed.connect(
		_on_council_button_pressed.bind(
			representative_id
		)
	)
	villager_layer.add_child(button)

	var pawn: VillageBoardPawn = (
		VILLAGE_PAWN_SCRIPT.new() as VillageBoardPawn
	)
	pawn.name = "Pawn"
	pawn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(pawn)

	var badge: Label = Label.new()
	badge.name = "Badge"
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 13)
	badge.add_theme_color_override(
		"font_shadow_color",
		Color(0.0, 0.0, 0.0, 0.85)
	)
	badge.add_theme_constant_override("shadow_offset_x", 1)
	badge.add_theme_constant_override("shadow_offset_y", 1)
	button.add_child(badge)

	var name_label: Label = Label.new()
	name_label.name = "Name"
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 9)
	name_label.add_theme_color_override(
		"font_color",
		MedievalTheme.PARCHMENT_LIGHT
	)
	name_label.add_theme_color_override(
		"font_shadow_color",
		Color(0.0, 0.0, 0.0, 0.88)
	)
	name_label.add_theme_constant_override("shadow_offset_x", 1)
	name_label.add_theme_constant_override("shadow_offset_y", 1)
	button.add_child(name_label)
	return button


func _rebuild_common_villagers() -> void:
	var total_population: int = int(
		current_population_overview.get(
			"total_population",
			0
		)
	)
	var protected_count: int = int(
		current_population_overview.get(
			"protected_named_resident_count",
			5
		)
	)
	var common_population: int = int(
		current_population_overview.get(
			"common_population",
			maxi(0, total_population - protected_count)
		)
	)
	var active_named_count: int = (
		current_council_members.size()
	)
	var reserve_named_count: int = maxi(
		0,
		protected_count - active_named_count
	)
	var visual_limit: int = (
		COMMON_VILLAGER_LIMIT_LARGE
		if is_large_view
		else COMMON_VILLAGER_LIMIT_SMALL
	)
	var desired_count: int = mini(
		visual_limit,
		maxi(
			0,
			int(ceil(float(common_population) / 2.0))
			+ reserve_named_count
		)
	)

	while common_villager_nodes.size() > desired_count:
		var removed_node: Control = (
			common_villager_nodes.pop_back()
		)
		_stop_villager_tween(removed_node)

		if is_instance_valid(removed_node):
			removed_node.queue_free()

	while common_villager_nodes.size() < desired_count:
		var index: int = common_villager_nodes.size()
		var villager_proxy: VillageBoardPawn = (
			VILLAGE_PAWN_SCRIPT.new() as VillageBoardPawn
		)
		villager_proxy.name = "CommonVillager_%02d" % index
		villager_proxy.configure(
			_get_common_pawn_color(index),
			_get_happiness_mood_id(),
			index,
			false,
			false
		)
		villager_proxy.set_meta("route_index", index % COMMON_ROUTE_POINTS.size())
		villager_proxy.set_meta("visual_index", index)
		villager_layer.add_child(villager_proxy)
		common_villager_nodes.append(villager_proxy)

	_layout_common_villagers()
	_restyle_common_villagers()

	if simulation_active:
		_restart_common_villager_routes()


func _layout_common_villagers() -> void:
	var visual_size: Vector2 = (
		Vector2(28.0, 28.0)
		if is_large_view
		else Vector2(18.0, 18.0)
	)

	for index: int in range(common_villager_nodes.size()):
		var villager_node: Control = (
			common_villager_nodes[index]
		)

		if not is_instance_valid(villager_node):
			continue

		villager_node.size = visual_size
		villager_node.custom_minimum_size = visual_size
		villager_node.z_index = index % 10

		if not villager_node.has_meta("position_initialized"):
			var route_index: int = index % COMMON_ROUTE_POINTS.size()
			villager_node.set_meta("route_index", route_index)
			villager_node.position = (
				_normalized_to_map_position(
					COMMON_ROUTE_POINTS[route_index]
				)
				- visual_size * 0.5
			)
			villager_node.set_meta("position_initialized", true)


func _restart_common_villager_routes() -> void:
	_stop_common_villager_routes()
	_reduced_motion_active = GameSettings.reduced_motion

	if GameSettings.reduced_motion:
		_position_common_villagers_for_reduced_motion()
		return

	if not simulation_active:
		return

	for villager_node: Control in common_villager_nodes:
		if not is_instance_valid(villager_node):
			continue

		_start_common_villager_tween(villager_node)


func _position_common_villagers_for_reduced_motion() -> void:
	for index: int in range(common_villager_nodes.size()):
		var villager_node: Control = common_villager_nodes[index]
		if not is_instance_valid(villager_node):
			continue

		var route_index: int = index % COMMON_ROUTE_POINTS.size()
		villager_node.set_meta("route_index", route_index)
		villager_node.set_meta("position_initialized", true)
		villager_node.position = (
			_normalized_to_map_position(
				COMMON_ROUTE_POINTS[route_index]
			)
			- villager_node.size * 0.5
		)


func _stop_common_villager_routes() -> void:
	for villager_node: Control in common_villager_nodes:
		_stop_villager_tween(villager_node)


func _stop_villager_tween(
	villager_node: Control
) -> void:
	if not is_instance_valid(villager_node):
		return

	var instance_id: int = villager_node.get_instance_id()

	if not villager_tweens.has(instance_id):
		return

	var tween: Tween = villager_tweens.get(instance_id) as Tween

	if tween != null and tween.is_valid():
		tween.kill()

	villager_tweens.erase(instance_id)


func _start_common_villager_tween(
	villager_node: Control
) -> void:
	if (
		not simulation_active
		or GameSettings.reduced_motion
		or not is_instance_valid(villager_node)
	):
		return

	var current_index: int = int(
		villager_node.get_meta("route_index", 0)
	)
	var visual_index: int = int(
		villager_node.get_meta("visual_index", 0)
	)
	var step: int = 1 + (visual_index % 3)
	var next_index: int = (
		(current_index + step)
		% COMMON_ROUTE_POINTS.size()
	)
	villager_node.set_meta("route_index", next_index)

	var target_position: Vector2 = (
		_normalized_to_map_position(
			COMMON_ROUTE_POINTS[next_index]
		)
		- villager_node.size * 0.5
	)
	var distance: float = (
		villager_node.position.distance_to(
			target_position
		)
	)
	var duration: float = clampf(
		distance / (
			(82.0 if is_large_view else 58.0)
			* _get_happiness_movement_multiplier()
		),
		1.4,
		4.5
	)

	var tween: Tween = create_tween()
	villager_tweens[villager_node.get_instance_id()] = tween
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(
		villager_node,
		"position",
		target_position,
		duration
	)
	tween.finished.connect(
		_on_common_villager_tween_finished.bind(
			villager_node
		),
		Object.CONNECT_ONE_SHOT
	)


func _on_common_villager_tween_finished(
	villager_node: Control
) -> void:
	if not is_instance_valid(villager_node):
		return

	villager_tweens.erase(villager_node.get_instance_id())
	_start_common_villager_tween(villager_node)


func _restyle_common_villagers() -> void:
	var mood_id: String = _get_happiness_mood_id()
	for villager_node: Control in common_villager_nodes:
		if is_instance_valid(villager_node) and villager_node is VillageBoardPawn:
			(villager_node as VillageBoardPawn).set_mood(mood_id)
	for button_value: Variant in council_nodes_by_id.values():
		var button: Button = button_value as Button
		if not is_instance_valid(button):
			continue
		var pawn: VillageBoardPawn = button.get_node_or_null("Pawn") as VillageBoardPawn
		if is_instance_valid(pawn):
			pawn.set_mood(mood_id)


func _apply_ground_texture() -> void:
	if not is_instance_valid(ground_rect):
		return

	var texture_path: String = String(
		GROUND_TEXTURE_PATHS.get(
			current_season_id,
			GROUND_TEXTURE_PATHS["spring"]
		)
	)
	ground_rect.texture = _get_texture_from_path(texture_path)


func _update_overlay_label() -> void:
	if not is_instance_valid(overlay_label):
		return

	var total_population: int = int(
		current_population_overview.get(
			"total_population",
			0
		)
	)
	var housing_capacity: int = int(
		current_population_overview.get(
			"housing_capacity",
			0
		)
	)
	var house_count: int = int(
		current_building_state.get("house_count", 2)
	)
	overlay_label.text = (
		"%d habitantes   •   %d casas   •   capacidade %d   •   %s"
		% [
			total_population,
			house_count,
			housing_capacity,
			_get_happiness_status_name()
		]
	)


func _on_resized() -> void:
	if not is_instance_valid(ground_rect):
		return

	var map_rect: Rect2 = _get_map_rect()
	ground_rect.position = map_rect.position
	ground_rect.size = map_rect.size

	overlay_label.position = (
		map_rect.position + Vector2(12.0, 7.0)
	)
	overlay_label.size = Vector2(
		maxf(0.0, map_rect.size.x - 24.0),
		22.0
	)
	if is_instance_valid(feedback_banner):
		var feedback_width: float = minf(
			420.0,
			maxf(220.0, map_rect.size.x - 32.0)
		)
		feedback_banner.size = Vector2(feedback_width, 46.0)
		feedback_banner.position = Vector2(
			map_rect.position.x + (map_rect.size.x - feedback_width) * 0.5,
			map_rect.position.y + (30.0 if is_large_view else 6.0)
		)
		feedback_banner.pivot_offset = feedback_banner.size * 0.5

	_layout_buildings()
	_layout_houses()
	_layout_council_nodes()
	_layout_common_villagers()
	if GameSettings.reduced_motion:
		_position_common_villagers_for_reduced_motion()
	_layout_extra_house_label()
	queue_redraw()


func _layout_buildings() -> void:
	for building_id_value: Variant in building_buttons.keys():
		var building_id: String = String(building_id_value)
		var button: TextureButton = (
			building_buttons.get(building_id) as TextureButton
		)

		if not is_instance_valid(button):
			continue

		var level: int = int(
			building_levels.get(building_id, 0)
		)
		var center: Vector2 = _normalized_to_map_position(
			_get_building_position(building_id)
		)
		var target_size: Vector2 = _get_building_size(
			building_id,
			level
		)
		button.size = target_size
		button.position = center - target_size * 0.5
		button.pivot_offset = target_size * 0.5
		button.z_index = _local_depth_for_y(center.y, 0, 18)


func _layout_houses() -> void:
	var house_points: Array[Vector2] = (
		HOUSE_POINTS_LARGE
		if is_large_view
		else HOUSE_POINTS_SMALL
	)
	var base_size: Vector2 = (
		Vector2(82.0, 82.0)
		if is_large_view
		else Vector2(43.0, 43.0)
	)

	for index: int in range(house_nodes.size()):
		var house: TextureRect = house_nodes[index]

		if (
			not is_instance_valid(house)
			or not house.visible
		):
			continue

		var center: Vector2 = _normalized_to_map_position(
			house_points[index]
		)
		house.size = base_size
		house.position = center - base_size * 0.5
		house.z_index = _local_depth_for_y(center.y, 0, 18)


func _layout_council_nodes() -> void:
	var council_points: Array[Vector2] = (
		COUNCIL_POINTS_LARGE
		if is_large_view
		else COUNCIL_POINTS_SMALL
	)
	var visual_size: Vector2 = (
		Vector2(48.0, 58.0)
		if is_large_view
		else Vector2(29.0, 36.0)
	)
	var slot_index: int = 0

	for villager_value: Variant in current_council_members:
		var villager: Villager = villager_value as Villager

		if not is_instance_valid(villager):
			continue

		var button: Button = (
			council_nodes_by_id.get(
				villager.representative_id,
				null
			) as Button
		)

		if not is_instance_valid(button):
			continue

		var point_index: int = clampi(
			slot_index,
			0,
			council_points.size() - 1
		)
		var center: Vector2 = _normalized_to_map_position(
			council_points[point_index]
		)
		button.size = visual_size
		button.custom_minimum_size = visual_size
		button.position = center - Vector2(
			visual_size.x * 0.5,
			visual_size.y * 0.58
		)
		button.pivot_offset = visual_size * 0.5
		button.z_index = _local_depth_for_y(center.y, 10, 24)

		var pawn: VillageBoardPawn = (
			button.get_node_or_null("Pawn") as VillageBoardPawn
		)
		if is_instance_valid(pawn):
			pawn.position = Vector2.ZERO
			pawn.size = Vector2(
				visual_size.x,
				visual_size.y - 4.0
			)

		var badge: Label = (
			button.get_node_or_null("Badge") as Label
		)

		if is_instance_valid(badge):
			badge.position = Vector2(
				visual_size.x * 0.27,
				visual_size.y * 0.29
			)
			badge.size = Vector2(
				visual_size.x * 0.46,
				18.0
			)

		var name_label: Label = (
			button.get_node_or_null("Name") as Label
		)

		if is_instance_valid(name_label):
			name_label.position = Vector2(
				-visual_size.x * 0.5,
				visual_size.y - 8.0
			)
			name_label.size = Vector2(
				visual_size.x * 2.0,
				18.0
			)

		slot_index += 1


func _layout_extra_house_label() -> void:
	if (
		not is_instance_valid(extra_house_label)
		or not extra_house_label.visible
	):
		return

	var anchor: Vector2 = _normalized_to_map_position(
		Vector2(0.93, 0.94)
	)
	extra_house_label.position = anchor - Vector2(92.0, 17.0)
	extra_house_label.size = Vector2(184.0, 30.0)


func _local_depth_for_y(
	y_position: float,
	minimum_depth: int,
	maximum_depth: int
) -> int:
	var map_rect: Rect2 = _get_map_rect()

	if map_rect.size.y <= 0.0:
		return minimum_depth

	var normalized_y: float = clampf(
		(y_position - map_rect.position.y) / map_rect.size.y,
		0.0,
		1.0
	)

	return roundi(lerpf(
		float(minimum_depth),
		float(maximum_depth),
		normalized_y
	))


func _get_map_rect() -> Rect2:
	return Rect2(
		Vector2(MAP_SIDE_MARGIN, MAP_TOP_MARGIN),
		Vector2(
			maxf(
				1.0,
				size.x - MAP_SIDE_MARGIN * 2.0
			),
			maxf(
				1.0,
				size.y - MAP_TOP_MARGIN - MAP_BOTTOM_MARGIN
			)
		)
	)


func _normalized_to_map_position(
	normalized: Vector2
) -> Vector2:
	var rect: Rect2 = _get_map_rect()
	return rect.position + Vector2(
		normalized.x * rect.size.x,
		normalized.y * rect.size.y
	)


func _get_building_position(
	building_id: String
) -> Vector2:
	match building_id:
		"barn":
			return Vector2(0.16, 0.27)
		"sawmill":
			return Vector2(0.16, 0.68)
		"square":
			return Vector2(0.55, 0.46)
		"well":
			return Vector2(0.82, 0.30)
		"palisade":
			return Vector2(0.51, 0.11)
		_:
			return Vector2(0.50, 0.50)


func _get_building_size(
	building_id: String,
	level: int
) -> Vector2:
	if level <= 0:
		return (
			Vector2(82.0, 48.0)
			if is_large_view
			else Vector2(48.0, 29.0)
		)

	if is_large_view:
		match building_id:
			"barn", "sawmill":
				return Vector2(124.0, 124.0)
			"well":
				return Vector2(112.0, 112.0)
			"square":
				return Vector2(176.0, 116.0)
			"palisade":
				return Vector2(72.0, 72.0)
			_:
				return Vector2(108.0, 108.0)

	match building_id:
		"barn", "sawmill":
			return Vector2(61.0, 61.0)
		"well":
			return Vector2(55.0, 55.0)
		"square":
			return Vector2(82.0, 54.0)
		"palisade":
			return Vector2(40.0, 40.0)
		_:
			return Vector2(56.0, 56.0)


func _get_texture(
	texture_key: String
) -> Texture2D:
	var texture_path: String = String(
		BUILDING_TEXTURES.get(
			texture_key,
			BUILDING_TEXTURES["empty"]
		)
	)
	return _get_texture_from_path(texture_path)


func _get_building_texture(
	building_id: String,
	level: int,
	variant_id: String = ""
) -> Texture2D:
	if level <= 0:
		return _get_texture("empty")

	if level >= 3 and BUILDING_VARIANT_TEXTURES.has(variant_id):
		return _get_texture_from_path(
			String(BUILDING_VARIANT_TEXTURES.get(variant_id, ""))
		)

	if building_id == "palisade":
		return _get_palisade_icon_texture(level)

	return _get_texture(
		"%s_%d" % [
			building_id,
			clampi(level, 1, 3)
		]
	)


func _get_palisade_icon_texture(level: int) -> Texture2D:
	var normalized_level: int = clampi(level, 1, 3)
	if _palisade_icon_textures.has(normalized_level):
		return _palisade_icon_textures[normalized_level] as Texture2D

	var image: Image = Image.create_empty(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))

	var shadow_color: Color = Color(0.16, 0.12, 0.09, 0.92)
	var body_color: Color = (
		Color(0.48, 0.31, 0.17, 1.0)
		if normalized_level == 1
		else Color(0.52, 0.50, 0.43, 1.0)
	)
	var light_color: Color = (
		Color(0.70, 0.47, 0.24, 1.0)
		if normalized_level == 1
		else Color(0.72, 0.69, 0.58, 1.0)
	)
	var mortar_color: Color = (
		Color(0.30, 0.20, 0.12, 1.0)
		if normalized_level == 1
		else Color(0.33, 0.32, 0.29, 1.0)
	)

	image.fill_rect(Rect2i(5, 29, 54, 16), shadow_color)
	image.fill_rect(Rect2i(5, 26, 54, 16), body_color)
	image.fill_rect(Rect2i(5, 26, 54, 3), light_color)
	image.fill_rect(Rect2i(5, 39, 54, 3), mortar_color)

	if normalized_level == 1:
		for stake_x: int in range(6, 59, 7):
			image.fill_rect(Rect2i(stake_x, 21, 4, 21), body_color)
			image.fill_rect(Rect2i(stake_x, 21, 4, 3), light_color)
	else:
		for block_x: int in range(7, 58, 10):
			image.fill_rect(Rect2i(block_x, 23, 6, 5), light_color)
		for joint_x: int in range(13, 58, 10):
			image.fill_rect(Rect2i(joint_x, 29, 2, 10), mortar_color)
		image.fill_rect(Rect2i(8, 20, 10, 24), body_color)
		image.fill_rect(Rect2i(46, 20, 10, 24), body_color)
		image.fill_rect(Rect2i(8, 18, 4, 5), light_color)
		image.fill_rect(Rect2i(15, 18, 4, 5), light_color)
		image.fill_rect(Rect2i(45, 18, 4, 5), light_color)
		image.fill_rect(Rect2i(52, 18, 4, 5), light_color)

	if normalized_level >= 3:
		image.fill_rect(Rect2i(24, 18, 16, 29), shadow_color)
		image.fill_rect(Rect2i(22, 16, 20, 27), body_color)
		image.fill_rect(Rect2i(22, 13, 6, 6), light_color)
		image.fill_rect(Rect2i(30, 13, 5, 6), light_color)
		image.fill_rect(Rect2i(37, 13, 5, 6), light_color)
		image.fill_rect(Rect2i(28, 28, 8, 15), shadow_color)

	var icon_texture: ImageTexture = ImageTexture.create_from_image(image)
	_palisade_icon_textures[normalized_level] = icon_texture
	return icon_texture


func _get_texture_from_path(
	path: String
) -> Texture2D:
	if _loaded_textures.has(path):
		return _loaded_textures[path] as Texture2D

	var texture: Texture2D = (
		ResourceLoader.load(path) as Texture2D
	)

	if texture == null:
		push_error(
			"Não foi possível carregar a textura: " + path
		)

	_loaded_textures[path] = texture
	return texture


func _get_representative_pawn_color(representative_id: String) -> Color:
	var index: int = int(
		REPRESENTATIVE_COLOR_INDEX.get(
			representative_id,
			posmod(representative_id.hash(), PAWN_COLORS.size())
		)
	)
	return PAWN_COLORS[posmod(index, PAWN_COLORS.size())]


func _get_common_pawn_color(index: int) -> Color:
	return PAWN_COLORS[posmod(index + 2, 6)]


func _get_pawn_initial(display_name: String) -> String:
	var clean_name: String = display_name.strip_edges()
	return clean_name.substr(0, 1).to_upper() if not clean_name.is_empty() else "?"


func _get_happiness_band() -> String:
	var happiness: float = float(
		current_population_overview.get("happiness", 60.0)
	)
	if happiness >= 70.0:
		return "high"
	if happiness >= 40.0:
		return "normal"
	if happiness >= 20.0:
		return "low"
	return "crisis"


func _get_happiness_mood_id() -> String:
	match _get_happiness_band():
		"high": return "joyful"
		"low": return "worried"
		"crisis": return "crisis"
		_: return "steady"


func _get_happiness_movement_multiplier() -> float:
	match _get_happiness_band():
		"high": return 1.15
		"low": return 0.70
		"crisis": return 0.40
		_: return 1.0


func _get_happiness_status_name() -> String:
	match _get_happiness_band():
		"high": return "CONVIVÊNCIA ANIMADA"
		"low": return "PREOCUPAÇÃO"
		"crisis": return "CRISE"
		_: return "ROTINA ESTÁVEL"


func _get_feedback_color() -> Color:
	match _feedback_kind:
		"construction": return Color("#E5B567")
		"success": return Color("#9FD18B")
		"major_success": return Color("#F1C86C")
		"crisis": return Color("#F07F72")
		_: return Color("#D9C7F0")


func _set_feedback_alpha(value: float) -> void:
	_feedback_alpha = clampf(value, 0.0, 1.0)
	queue_redraw()


func _hide_world_feedback() -> void:
	_feedback_alpha = 0.0
	if is_instance_valid(feedback_banner):
		feedback_banner.visible = false
		feedback_banner.modulate = Color.WHITE
	queue_redraw()


func _animate_button_upgrade(
	button: TextureButton
) -> void:
	if not is_instance_valid(button):
		return

	if GameSettings.reduced_motion:
		button.scale = Vector2.ONE
		return

	button.scale = Vector2(0.88, 0.88)
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(
		button,
		"scale",
		Vector2(1.06, 1.06),
		0.16
	)
	tween.tween_property(
		button,
		"scale",
		Vector2.ONE,
		0.12
	)


func _draw() -> void:
	var rect: Rect2 = _get_map_rect()
	_draw_map_frame(rect)
	_draw_growth_decorations(rect)
	_draw_paths(rect)
	_draw_responsive_ambience(rect)
	_draw_building_shadows(rect)
	_draw_construction_sites(rect)
	_draw_palisade(rect)
	_draw_memory_markers(rect)
	_draw_season_details(rect)
	_draw_world_feedback(rect)


func _draw_responsive_ambience(rect: Rect2) -> void:
	var square_center: Vector2 = rect.position + Vector2(
		0.53 * rect.size.x,
		0.45 * rect.size.y
	)
	match _get_happiness_band():
		"high":
			var celebration_color: Color = Color(0.95, 0.78, 0.36, 0.54)
			for offset: Vector2 in [
				Vector2(-32.0, -18.0),
				Vector2(-15.0, -30.0),
				Vector2(7.0, -34.0),
				Vector2(29.0, -20.0),
				Vector2(-24.0, 12.0),
				Vector2(25.0, 14.0)
			]:
				draw_circle(
					square_center + offset * (1.35 if is_large_view else 0.72),
					2.4 if is_large_view else 1.4,
					celebration_color
				)
		"low":
			draw_arc(
				square_center,
				36.0 if is_large_view else 20.0,
				0.20,
				2.95,
				20,
				Color(0.90, 0.71, 0.40, 0.42),
				2.0,
				true
			)
		"crisis":
			draw_arc(
				square_center,
				42.0 if is_large_view else 23.0,
				0.0,
				TAU,
				28,
				Color(0.94, 0.35, 0.34, 0.62),
				3.0 if is_large_view else 2.0,
				true
			)


func _draw_world_feedback(rect: Rect2) -> void:
	if _feedback_alpha <= 0.0:
		return
	var center: Vector2 = rect.position + Vector2(
		_feedback_target.x * rect.size.x,
		_feedback_target.y * rect.size.y
	)
	var color: Color = _get_feedback_color()
	color.a = 0.82 * _feedback_alpha
	var radius: float = (58.0 if is_large_view else 32.0) * (
		1.0 + (1.0 - _feedback_alpha) * 0.35
	)
	draw_arc(
		center,
		radius,
		0.0,
		TAU,
		36,
		color,
		4.0 if is_large_view else 2.5,
		true
	)


func _draw_memory_markers(rect: Rect2) -> void:
	for marker_value: Variant in current_memory_markers:
		if not marker_value is Dictionary:
			continue
		var marker_id: String = String((marker_value as Dictionary).get("marker_id", ""))
		var normalized: Vector2 = Vector2.ZERO
		match marker_id:
			"founder_banner": normalized = Vector2(0.53, 0.61)
			"repair_cairn": normalized = Vector2(0.29, 0.65)
			"shared_bench": normalized = Vector2(0.69, 0.57)
			"council_lantern": normalized = Vector2(0.74, 0.38)
			_: continue
		var center: Vector2 = rect.position + Vector2(
			normalized.x * rect.size.x,
			normalized.y * rect.size.y
		)
		var scale_factor: float = 1.35 if is_large_view else 0.72
		match marker_id:
			"founder_banner": _draw_founder_banner(center, scale_factor)
			"repair_cairn": _draw_repair_cairn(center, scale_factor)
			"shared_bench": _draw_shared_bench(center, scale_factor)
			"council_lantern": _draw_council_lantern(center, scale_factor)


func _draw_founder_banner(center: Vector2, scale_factor: float) -> void:
	var pole_color: Color = Color(0.31, 0.19, 0.10, 0.98)
	draw_line(
		center + Vector2(0.0, 10.0) * scale_factor,
		center + Vector2(0.0, -22.0) * scale_factor,
		pole_color,
		3.0 * scale_factor,
		true
	)
	draw_colored_polygon(
		PackedVector2Array([
			center + Vector2(1.0, -21.0) * scale_factor,
			center + Vector2(18.0, -17.0) * scale_factor,
			center + Vector2(13.0, -7.0) * scale_factor,
			center + Vector2(1.0, -10.0) * scale_factor
		]),
		Color(0.55, 0.16, 0.13, 0.96)
	)
	draw_circle(center + Vector2(8.0, -14.0) * scale_factor, 2.4 * scale_factor, MedievalTheme.GOLD)


func _draw_repair_cairn(center: Vector2, scale_factor: float) -> void:
	for stone: Rect2 in [
		Rect2(Vector2(-10.0, 1.0), Vector2(20.0, 7.0)),
		Rect2(Vector2(-7.0, -6.0), Vector2(14.0, 7.0)),
		Rect2(Vector2(-4.0, -12.0), Vector2(8.0, 6.0))
	]:
		draw_rect(
			Rect2(center + stone.position * scale_factor, stone.size * scale_factor),
			Color(0.46, 0.43, 0.39, 0.98),
			true
		)


func _draw_shared_bench(center: Vector2, scale_factor: float) -> void:
	var wood: Color = Color(0.43, 0.25, 0.12, 0.98)
	draw_rect(
		Rect2(center + Vector2(-14.0, -4.0) * scale_factor, Vector2(28.0, 6.0) * scale_factor),
		wood,
		true
	)
	for x_value: float in [-10.0, 10.0]:
		draw_line(
			center + Vector2(x_value, 1.0) * scale_factor,
			center + Vector2(x_value, 9.0) * scale_factor,
			wood,
			3.0 * scale_factor,
			true
		)


func _draw_council_lantern(center: Vector2, scale_factor: float) -> void:
	draw_line(
		center + Vector2(0.0, 10.0) * scale_factor,
		center + Vector2(0.0, -16.0) * scale_factor,
		Color(0.25, 0.17, 0.10, 0.98),
		3.0 * scale_factor,
		true
	)
	draw_rect(
		Rect2(center + Vector2(-5.0, -16.0) * scale_factor, Vector2(10.0, 11.0) * scale_factor),
		Color(0.88, 0.62, 0.19, 0.95),
		true
	)
	draw_rect(
		Rect2(center + Vector2(-5.0, -16.0) * scale_factor, Vector2(10.0, 11.0) * scale_factor),
		MedievalTheme.GOLD_DARK,
		false,
		1.5 * scale_factor
	)


func _draw_construction_sites(rect: Rect2) -> void:
	var construction: Dictionary = current_building_state.get("construction", {})
	var active_orders: Array = construction.get("active_orders", [])
	if active_orders.is_empty():
		return

	var house_count: int = int(current_building_state.get("house_count", 2))
	var housing_site_index: int = 0
	for order_value: Variant in active_orders:
		if not order_value is Dictionary:
			continue
		var order: Dictionary = order_value as Dictionary
		var normalized: Vector2 = Vector2.ZERO
		if bool(order.get("is_housing", false)):
			var points: Array[Vector2] = (
				HOUSE_POINTS_LARGE if is_large_view else HOUSE_POINTS_SMALL
			)
			var point_index: int = clampi(
				house_count + housing_site_index,
				0,
				points.size() - 1
			)
			normalized = points[point_index]
			housing_site_index += 1
		else:
			normalized = _get_building_position(
				String(order.get("building_id", ""))
			)

		var center: Vector2 = rect.position + Vector2(
			normalized.x * rect.size.x,
			normalized.y * rect.size.y
		)
		var scale_factor: float = 1.0 if is_large_view else 0.58
		_draw_single_construction_site(center, order, scale_factor)


func _draw_single_construction_site(
	center: Vector2,
	order: Dictionary,
	scale_factor: float
) -> void:
	var foundation_size: Vector2 = Vector2(92.0, 42.0) * scale_factor
	var foundation_rect: Rect2 = Rect2(
		center - foundation_size * 0.5 + Vector2(0.0, 10.0 * scale_factor),
		foundation_size
	)
	draw_rect(
		foundation_rect,
		Color(0.36, 0.27, 0.18, 0.92),
		true
	)
	draw_rect(
		foundation_rect,
		Color(0.82, 0.62, 0.34, 0.95),
		false,
		2.0 * scale_factor
	)

	var scaffold_color: Color = Color(0.68, 0.45, 0.24, 0.98)
	var left_x: float = foundation_rect.position.x + 10.0 * scale_factor
	var right_x: float = foundation_rect.end.x - 10.0 * scale_factor
	var top_y: float = foundation_rect.position.y - 46.0 * scale_factor
	var bottom_y: float = foundation_rect.end.y
	for x_value: float in [left_x, right_x]:
		draw_line(
			Vector2(x_value, top_y),
			Vector2(x_value, bottom_y),
			scaffold_color,
			4.0 * scale_factor,
			true
		)
	for ratio: float in [0.0, 0.5, 1.0]:
		var y_value: float = lerpf(top_y, bottom_y, ratio)
		draw_line(
			Vector2(left_x, y_value),
			Vector2(right_x, y_value),
			scaffold_color,
			3.0 * scale_factor,
			true
		)
	draw_line(
		Vector2(left_x, top_y),
		Vector2(right_x, bottom_y),
		Color(0.78, 0.54, 0.29, 0.92),
		2.5 * scale_factor,
		true
	)
	draw_line(
		Vector2(right_x, top_y),
		Vector2(left_x, bottom_y),
		Color(0.78, 0.54, 0.29, 0.92),
		2.5 * scale_factor,
		true
	)

	var work_days: int = maxi(1, int(order.get("work_days", 1)))
	var progress_days: int = clampi(
		int(order.get("progress_days", 0)),
		0,
		work_days
	)
	var progress_width: float = foundation_size.x
	var progress_rect: Rect2 = Rect2(
		Vector2(foundation_rect.position.x, foundation_rect.end.y + 4.0 * scale_factor),
		Vector2(progress_width, 6.0 * scale_factor)
	)
	draw_rect(progress_rect, Color(0.08, 0.05, 0.03, 0.82), true)
	var fill_rect: Rect2 = progress_rect
	fill_rect.size.x *= float(progress_days) / float(work_days)
	draw_rect(fill_rect, MedievalTheme.GOLD, true)


func _draw_map_frame(rect: Rect2) -> void:
	draw_rect(
		rect,
		Color(0.12, 0.08, 0.04, 0.28),
		false,
		2.0
	)


func _draw_paths(rect: Rect2) -> void:
	var path_color: Color = Color(0.72, 0.57, 0.37, 0.88)
	var edge_color: Color = Color(0.48, 0.34, 0.20, 0.42)
	var width: float = 18.0 if is_large_view else 10.0

	for path_points: Array in PATH_NETWORK:
		var polyline: PackedVector2Array = PackedVector2Array()

		for point_value: Variant in path_points:
			var point: Vector2 = point_value
			polyline.append(
				rect.position
				+ Vector2(
					point.x * rect.size.x,
					point.y * rect.size.y
				)
			)

		draw_polyline(
			polyline,
			edge_color,
			width + 3.0,
			true
		)
		draw_polyline(
			polyline,
			path_color,
			width,
			true
		)


func _draw_building_shadows(
	rect: Rect2
) -> void:
	for building_id_value: Variant in building_buttons.keys():
		var building_id: String = String(building_id_value)
		var level: int = int(
			building_levels.get(building_id, 0)
		)

		if level <= 0:
			continue

		var normalized: Vector2 = _get_building_position(
			building_id
		)
		var center: Vector2 = (
			rect.position
			+ Vector2(
				normalized.x * rect.size.x,
				normalized.y * rect.size.y
			)
		)
		var shadow_size: Vector2 = (
			Vector2(88.0, 23.0)
			if is_large_view
			else Vector2(43.0, 12.0)
		)

		if building_id == "square":
			shadow_size.x *= 1.35

		_draw_ellipse_shape(
			center + Vector2(0.0, shadow_size.y * 0.65),
			shadow_size,
			Color(0.04, 0.03, 0.02, 0.22)
		)


func _draw_ellipse_shape(
	center: Vector2,
	ellipse_size: Vector2,
	color: Color
) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	var point_count: int = 28

	for index: int in range(point_count):
		var angle: float = TAU * float(index) / float(point_count)
		points.append(
			center
			+ Vector2(
				cos(angle) * ellipse_size.x * 0.5,
				sin(angle) * ellipse_size.y * 0.5
			)
		)

	draw_colored_polygon(points, color)


func _draw_growth_decorations(
	rect: Rect2
) -> void:
	var population: int = int(
		current_population_overview.get(
			"total_population",
			0
		)
	)
	var growth_tier: int = 0

	if population >= 10:
		growth_tier = 1

	if population >= 20:
		growth_tier = 2

	if population >= 40:
		growth_tier = 3

	var tree_points: Array[Vector2] = [
		Vector2(0.08, 0.25),
		Vector2(0.91, 0.22),
		Vector2(0.10, 0.82),
		Vector2(0.91, 0.78),
		Vector2(0.84, 0.57),
		Vector2(0.14, 0.52)
	]
	var visible_trees: int = mini(
		tree_points.size(),
		3 + growth_tier
	)

	for index: int in range(visible_trees):
		var point: Vector2 = tree_points[index]
		var center: Vector2 = (
			rect.position
			+ Vector2(
				point.x * rect.size.x,
				point.y * rect.size.y
			)
		)
		var scale_factor: float = (
			1.45 if is_large_view else 0.78
		)
		draw_rect(
			Rect2(
				center + Vector2(-2.0, 4.0) * scale_factor,
				Vector2(4.0, 10.0) * scale_factor
			),
			Color(0.34, 0.22, 0.12, 0.90),
			true
		)
		draw_circle(
			center,
			10.0 * scale_factor,
			_get_tree_color()
		)
		draw_circle(
			center + Vector2(-5.0, 2.0) * scale_factor,
			6.0 * scale_factor,
			_get_tree_color().lightened(0.08)
		)

	if growth_tier >= 1:
		var stall_center: Vector2 = (
			rect.position
			+ Vector2(
				0.62 * rect.size.x,
				0.37 * rect.size.y
			)
		)
		var stall_scale: float = (
			1.6 if is_large_view else 0.82
		)
		draw_rect(
			Rect2(
				stall_center + Vector2(-9.0, -3.0) * stall_scale,
				Vector2(18.0, 10.0) * stall_scale
			),
			Color(0.45, 0.25, 0.13, 0.88),
			true
		)
		draw_colored_polygon(
			PackedVector2Array([
				stall_center + Vector2(-11.0, -4.0) * stall_scale,
				stall_center + Vector2(11.0, -4.0) * stall_scale,
				stall_center + Vector2(7.0, -12.0) * stall_scale,
				stall_center + Vector2(-7.0, -12.0) * stall_scale
			]),
			Color(0.73, 0.28, 0.18, 0.90)
		)


func _get_tree_color() -> Color:
	match current_season_id:
		"summer":
			return Color(0.22, 0.48, 0.19, 0.96)
		"autumn":
			return Color(0.73, 0.35, 0.13, 0.96)
		"winter":
			return Color(0.49, 0.55, 0.56, 0.88)
		_:
			return Color(0.29, 0.57, 0.24, 0.96)


func _draw_palisade(rect: Rect2) -> void:
	var level: int = int(
		building_levels.get("palisade", 0)
	)
	var variant_id: String = String(
		building_variants.get("palisade", "")
	)

	if level <= 0:
		return

	var visual_scale: float = 2.0 if is_large_view else 1.0
	var side_margin: float = 7.0 * visual_scale
	var wall_y: float = rect.position.y + 13.0 * visual_scale
	var wall_height: float = 13.0 * visual_scale
	var tower_width: float = 18.0 * visual_scale
	var tower_height: float = 25.0 * visual_scale
	var left_tower: Rect2 = Rect2(
		Vector2(
			rect.position.x + side_margin,
			wall_y - 8.0 * visual_scale
		),
		Vector2(tower_width, tower_height)
	)
	var right_tower: Rect2 = Rect2(
		Vector2(
			rect.end.x - side_margin - tower_width,
			wall_y - 8.0 * visual_scale
		),
		Vector2(tower_width, tower_height)
	)
	var wall_start: float = left_tower.end.x - visual_scale
	var wall_end: float = right_tower.position.x + visual_scale
	var center_x: float = rect.position.x + rect.size.x * 0.5

	if level >= 3:
		var gatehouse_width: float = 38.0 * visual_scale
		var gatehouse_height: float = 31.0 * visual_scale
		var gatehouse_rect: Rect2 = Rect2(
			Vector2(
				center_x - gatehouse_width * 0.5,
				wall_y - 13.0 * visual_scale
			),
			Vector2(gatehouse_width, gatehouse_height)
		)
		_paint_wall_segment(
			Rect2(
				Vector2(wall_start, wall_y),
				Vector2(
					maxf(0.0, gatehouse_rect.position.x - wall_start),
					wall_height
				)
			),
			level,
			visual_scale
		)
		_paint_wall_segment(
			Rect2(
				Vector2(gatehouse_rect.end.x, wall_y),
				Vector2(
					maxf(0.0, wall_end - gatehouse_rect.end.x),
					wall_height
				)
			),
			level,
			visual_scale
		)
		_paint_gatehouse(gatehouse_rect, visual_scale)
	else:
		_paint_wall_segment(
			Rect2(
				Vector2(wall_start, wall_y),
				Vector2(maxf(0.0, wall_end - wall_start), wall_height)
			),
			level,
			visual_scale
		)

	_paint_wall_tower(left_tower, level, visual_scale)
	_paint_wall_tower(right_tower, level, visual_scale)

	if level >= 3 and variant_id == "stone_bastion":
		var bastion_color: Color = Color(0.42, 0.41, 0.38, 0.96)
		draw_rect(
			Rect2(
				Vector2(rect.position.x + rect.size.x * 0.24, rect.position.y + 4.0 * visual_scale),
				Vector2(rect.size.x * 0.12, 22.0 * visual_scale)
			),
			bastion_color,
			true
		)
		draw_rect(
			Rect2(
				Vector2(rect.position.x + rect.size.x * 0.64, rect.position.y + 4.0 * visual_scale),
				Vector2(rect.size.x * 0.12, 22.0 * visual_scale)
			),
			bastion_color,
			true
		)
	elif level >= 3 and variant_id == "vigilant_gates":
		var flag_color: Color = Color(0.78, 0.39, 0.20, 0.96)
		for flag_x: float in [rect.position.x + rect.size.x * 0.22, rect.position.x + rect.size.x * 0.78]:
			draw_line(
				Vector2(flag_x, rect.position.y + 2.0 * visual_scale),
				Vector2(flag_x, rect.position.y + 24.0 * visual_scale),
				Color(0.24, 0.18, 0.12, 1.0),
				2.0 * visual_scale
			)
			draw_colored_polygon(
				PackedVector2Array([
					Vector2(flag_x, rect.position.y + 3.0 * visual_scale),
					Vector2(flag_x + 11.0 * visual_scale, rect.position.y + 7.0 * visual_scale),
					Vector2(flag_x, rect.position.y + 11.0 * visual_scale)
				]),
				flag_color
			)


func _paint_wall_segment(
	segment: Rect2,
	level: int,
	visual_scale: float
) -> void:
	if segment.size.x <= visual_scale:
		return

	if level == 1:
		var wood_dark: Color = Color(0.25, 0.15, 0.08, 0.98)
		var wood_body: Color = Color(0.49, 0.30, 0.15, 0.98)
		var wood_light: Color = Color(0.68, 0.43, 0.21, 0.98)
		draw_rect(
			Rect2(
				segment.position + Vector2(0.0, 3.0 * visual_scale),
				segment.size
			),
			wood_dark,
			true
		)
		var stake_step: float = 7.0 * visual_scale
		var stake_width: float = 4.0 * visual_scale
		var stake_count: int = maxi(1, int(floor(segment.size.x / stake_step)))
		for stake_index: int in range(stake_count + 1):
			var stake_x: float = minf(
				segment.end.x - stake_width,
				segment.position.x + stake_index * stake_step
			)
			var stake_top: float = segment.position.y - 3.0 * visual_scale
			draw_colored_polygon(
				PackedVector2Array([
					Vector2(stake_x, stake_top + 3.0 * visual_scale),
					Vector2(stake_x + stake_width * 0.5, stake_top),
					Vector2(stake_x + stake_width, stake_top + 3.0 * visual_scale),
					Vector2(stake_x + stake_width, segment.end.y),
					Vector2(stake_x, segment.end.y)
				]),
				wood_body
			)
			draw_rect(
				Rect2(
					Vector2(stake_x, stake_top + 4.0 * visual_scale),
					Vector2(visual_scale, segment.size.y - visual_scale)
				),
				wood_light,
				true
			)
		draw_rect(
			Rect2(
				segment.position + Vector2(0.0, 6.0 * visual_scale),
				Vector2(segment.size.x, 3.0 * visual_scale)
			),
			wood_dark,
			true
		)
		return

	var stone_shadow: Color = Color(0.19, 0.18, 0.16, 0.98)
	var stone_body: Color = Color(0.48, 0.47, 0.41, 0.99)
	var stone_light: Color = Color(0.67, 0.65, 0.55, 0.99)
	var mortar: Color = Color(0.31, 0.30, 0.27, 0.96)
	draw_rect(
		Rect2(
			segment.position + Vector2(0.0, 3.0 * visual_scale),
			segment.size
		),
		stone_shadow,
		true
	)
	draw_rect(segment, stone_body, true)
	draw_rect(
		Rect2(
			segment.position,
			Vector2(segment.size.x, 2.0 * visual_scale)
		),
		stone_light,
		true
	)
	draw_rect(
		Rect2(
			Vector2(
				segment.position.x,
				segment.position.y + 7.0 * visual_scale
			),
			Vector2(segment.size.x, visual_scale)
		),
		mortar,
		true
	)

	var block_step: float = 13.0 * visual_scale
	var block_count: int = maxi(1, int(ceil(segment.size.x / block_step)))
	for block_index: int in range(block_count):
		var joint_x: float = segment.position.x + block_index * block_step
		var joint_y: float = (
			segment.position.y + visual_scale
			if block_index % 2 == 0
			else segment.position.y + 8.0 * visual_scale
		)
		draw_rect(
			Rect2(
				Vector2(joint_x, joint_y),
				Vector2(visual_scale, 5.0 * visual_scale)
			),
			mortar,
			true
		)

	var merlon_step: float = 12.0 * visual_scale
	var merlon_width: float = 7.0 * visual_scale
	var merlon_count: int = maxi(1, int(floor(segment.size.x / merlon_step)))
	for merlon_index: int in range(merlon_count + 1):
		var merlon_x: float = minf(
			segment.end.x - merlon_width,
			segment.position.x + merlon_index * merlon_step
		)
		draw_rect(
			Rect2(
				Vector2(merlon_x, segment.position.y - 4.0 * visual_scale),
				Vector2(merlon_width, 5.0 * visual_scale)
			),
			stone_body,
			true
		)
		draw_rect(
			Rect2(
				Vector2(merlon_x, segment.position.y - 4.0 * visual_scale),
				Vector2(merlon_width, visual_scale)
			),
			stone_light,
			true
		)


func _paint_wall_tower(
	tower: Rect2,
	level: int,
	visual_scale: float
) -> void:
	if level == 1:
		var post_dark: Color = Color(0.24, 0.14, 0.08, 0.99)
		var post_body: Color = Color(0.50, 0.30, 0.15, 0.99)
		var post_light: Color = Color(0.70, 0.44, 0.22, 0.99)
		draw_rect(
			Rect2(
				tower.position + Vector2(0.0, 3.0 * visual_scale),
				tower.size
			),
			post_dark,
			true
		)
		draw_colored_polygon(
			PackedVector2Array([
				Vector2(tower.position.x, tower.position.y + 7.0 * visual_scale),
				Vector2(tower.position.x + tower.size.x * 0.5, tower.position.y),
				Vector2(tower.end.x, tower.position.y + 7.0 * visual_scale),
				Vector2(tower.end.x, tower.end.y),
				Vector2(tower.position.x, tower.end.y)
			]),
			post_body
		)
		draw_rect(
			Rect2(
				tower.position + Vector2(2.0 * visual_scale, 8.0 * visual_scale),
				Vector2(2.0 * visual_scale, tower.size.y - 10.0 * visual_scale)
			),
			post_light,
			true
		)
		return

	var tower_shadow: Color = Color(0.18, 0.17, 0.15, 0.99)
	var tower_body: Color = Color(0.45, 0.44, 0.39, 1.0)
	var tower_light: Color = Color(0.66, 0.64, 0.55, 1.0)
	var tower_dark: Color = Color(0.28, 0.27, 0.24, 1.0)
	draw_rect(
		Rect2(
			tower.position + Vector2(0.0, 3.0 * visual_scale),
			tower.size
		),
		tower_shadow,
		true
	)
	draw_rect(tower, tower_body, true)
	draw_rect(
		Rect2(
			tower.position,
			Vector2(tower.size.x, 3.0 * visual_scale)
		),
		tower_light,
		true
	)

	var merlon_width: float = 5.0 * visual_scale
	for merlon_index: int in range(3):
		draw_rect(
			Rect2(
				Vector2(
					tower.position.x + merlon_index * 6.5 * visual_scale,
					tower.position.y - 5.0 * visual_scale
				),
				Vector2(merlon_width, 6.0 * visual_scale)
			),
			tower_body,
			true
		)
	draw_rect(
		Rect2(
			Vector2(
				tower.position.x + tower.size.x * 0.5 - visual_scale,
				tower.position.y + 10.0 * visual_scale
			),
			Vector2(2.0 * visual_scale, 6.0 * visual_scale)
		),
		tower_dark,
		true
	)


func _paint_gatehouse(
	gatehouse: Rect2,
	visual_scale: float
) -> void:
	var gate_shadow: Color = Color(0.17, 0.16, 0.14, 0.99)
	var gate_body: Color = Color(0.46, 0.45, 0.40, 1.0)
	var gate_light: Color = Color(0.69, 0.66, 0.56, 1.0)
	var gate_dark: Color = Color(0.20, 0.13, 0.08, 1.0)
	var metal_color: Color = Color(0.31, 0.28, 0.22, 1.0)
	draw_rect(
		Rect2(
			gatehouse.position + Vector2(0.0, 4.0 * visual_scale),
			gatehouse.size
		),
		gate_shadow,
		true
	)
	draw_rect(gatehouse, gate_body, true)
	draw_rect(
		Rect2(
			gatehouse.position,
			Vector2(gatehouse.size.x, 3.0 * visual_scale)
		),
		gate_light,
		true
	)

	var merlon_width: float = 7.0 * visual_scale
	for merlon_index: int in range(4):
		draw_rect(
			Rect2(
				Vector2(
					gatehouse.position.x + merlon_index * 10.0 * visual_scale,
					gatehouse.position.y - 6.0 * visual_scale
				),
				Vector2(merlon_width, 7.0 * visual_scale)
			),
			gate_body,
			true
		)

	var opening_width: float = 13.0 * visual_scale
	var opening_height: float = 20.0 * visual_scale
	var opening: Rect2 = Rect2(
		Vector2(
			gatehouse.position.x + gatehouse.size.x * 0.5 - opening_width * 0.5,
			gatehouse.end.y - opening_height
		),
		Vector2(opening_width, opening_height)
	)
	draw_rect(opening, gate_dark, true)
	for bar_index: int in range(3):
		var bar_x: float = opening.position.x + (3.0 + bar_index * 4.0) * visual_scale
		draw_rect(
			Rect2(
				Vector2(bar_x, opening.position.y + 3.0 * visual_scale),
				Vector2(visual_scale, opening.size.y - 3.0 * visual_scale)
			),
			metal_color,
			true
		)
	draw_rect(
		Rect2(
			opening.position + Vector2(0.0, 7.0 * visual_scale),
			Vector2(opening.size.x, visual_scale)
		),
		metal_color,
		true
	)


func _draw_season_details(rect: Rect2) -> void:
	match current_season_id:
		"spring":
			_draw_detail_points(
				rect,
				[
					Vector2(0.12, 0.40),
					Vector2(0.34, 0.83),
					Vector2(0.86, 0.62)
				],
				Color(1.0, 0.73, 0.86, 0.72),
				3.0
			)
		"summer":
			draw_rect(
				rect,
				Color(1.0, 0.91, 0.58, 0.035),
				true
			)
		"autumn":
			_draw_detail_points(
				rect,
				[
					Vector2(0.15, 0.18),
					Vector2(0.78, 0.26),
					Vector2(0.47, 0.87),
					Vector2(0.68, 0.65)
				],
				Color(0.85, 0.43, 0.15, 0.72),
				4.0
			)
		"winter":
			draw_rect(
				rect,
				Color(0.92, 0.97, 1.0, 0.075),
				true
			)
			_draw_detail_points(
				rect,
				[
					Vector2(0.14, 0.23),
					Vector2(0.43, 0.17),
					Vector2(0.73, 0.25),
					Vector2(0.86, 0.51)
				],
				Color(1.0, 1.0, 1.0, 0.60),
				4.0
			)


func _draw_detail_points(
	rect: Rect2,
	points: Array[Vector2],
	color: Color,
	radius: float
) -> void:
	var scaled_radius: float = (
		radius * 1.4
		if is_large_view
		else radius
	)

	for normalized: Vector2 in points:
		var center: Vector2 = (
			rect.position
			+ Vector2(
				normalized.x * rect.size.x,
				normalized.y * rect.size.y
			)
		)
		draw_circle(center, scaled_radius, color)


func _on_building_button_pressed(
	building_id: String
) -> void:
	building_requested.emit(building_id)


func _on_council_button_pressed(
	representative_id: String
) -> void:
	council_member_requested.emit(representative_id)
