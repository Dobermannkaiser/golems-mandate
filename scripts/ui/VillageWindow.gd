class_name VillageWindow
extends Control


signal building_requested(building_id: String)
signal council_member_requested(representative_id: String)


const VILLAGE_VISUALS_SCRIPT = preload(
	"res://scripts/ui/BuildingVisuals.gd"
)


var overlay: ColorRect
var panel: PanelContainer
var village_visuals: VillageBuildingVisuals
var title_label: Label
var close_button: Button
var previous_focus: Control

var current_building_state: Dictionary = {}
var current_population_overview: Dictionary = {}
var current_council_members: Array = []
var current_selected_member_id: String = ""
var current_season_id: String = "spring"


func _ready() -> void:
	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_create_window()


func _create_window() -> void:
	overlay = ColorRect.new()
	overlay.name = "VillageOverlay"
	overlay.color = Color(
		0.02,
		0.02,
		0.03,
		0.82
	)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	overlay.z_index = 150
	overlay.visible = false
	add_child(overlay)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)

	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(
		960.0,
		560.0
	)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.clip_contents = true
	panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			Color(0.15, 0.10, 0.07, 0.98),
			MedievalTheme.GOLD_DARK,
			2,
			12,
			12,
			4
		)
	)
	center.add_child(panel)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)
	layout.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)
	layout.add_theme_constant_override(
		"separation",
		8
	)
	panel.add_child(layout)

	var header: HBoxContainer = HBoxContainer.new()
	header.custom_minimum_size = Vector2(
		0.0,
		44.0
	)
	header.add_theme_constant_override(
		"separation",
		12
	)
	layout.add_child(header)

	title_label = MedievalTheme.create_label(
		"VILA AMPLIADA",
		MedievalTheme.GOLD,
		20
	)
	title_label.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)
	title_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)
	header.add_child(title_label)

	close_button = Button.new()
	close_button.text = "FECHAR"
	close_button.custom_minimum_size = Vector2(
		140.0,
		42.0
	)
	close_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)
	VillageUIAccessibility.configure_button(
		close_button,
		"Fecha a visão ampliada e retorna à interface principal.",
		42.0
	)
	close_button.pressed.connect(
		hide_window
	)
	header.add_child(close_button)

	village_visuals = (
		VILLAGE_VISUALS_SCRIPT.new()
		as VillageBuildingVisuals
	)

	if not is_instance_valid(village_visuals):
		push_error(
			"Não foi possível criar a visualização ampliada da vila."
		)
		return

	village_visuals.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)
	village_visuals.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)
	village_visuals.set_large_view_enabled(true)
	village_visuals.set_simulation_active(false)
	village_visuals.building_requested.connect(
		_on_visual_building_requested
	)
	village_visuals.council_member_requested.connect(
		_on_visual_council_member_requested
	)
	layout.add_child(village_visuals)


func show_village() -> void:
	if not is_instance_valid(overlay):
		return

	previous_focus = VillageUIAccessibility.remember_focus(self)
	_sync_visual()
	overlay.visible = true
	VillageUIAccessibility.focus_deferred(close_button)
	village_visuals.set_simulation_active(true)

	if GameSettings.reduced_motion:
		panel.modulate = Color.WHITE
		return

	panel.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.30
	)

	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(
		panel,
		"modulate",
		Color.WHITE,
		0.18
	)


func hide_window() -> void:
	if is_instance_valid(village_visuals):
		village_visuals.set_simulation_active(false)

	if is_instance_valid(overlay):
		overlay.visible = false
	VillageUIAccessibility.restore_focus_deferred(previous_focus)
	previous_focus = null


func is_window_visible() -> bool:
	return (
		is_instance_valid(overlay)
		and overlay.visible
	)


func show_world_feedback(feedback_data: Dictionary) -> void:
	if is_instance_valid(village_visuals):
		village_visuals.show_world_feedback(feedback_data)


func _unhandled_input(event: InputEvent) -> void:
	if not is_window_visible():
		return
	if event.is_action_pressed("ui_cancel"):
		hide_window()
		get_viewport().set_input_as_handled()


func refresh(
	building_state: Dictionary,
	population_overview: Dictionary,
	council_members: Array,
	selected_member_id: String,
	season_id: String
) -> void:
	current_building_state = building_state.duplicate(true)
	current_population_overview = (
		population_overview.duplicate(true)
	)
	current_council_members = council_members.duplicate()
	current_selected_member_id = selected_member_id
	current_season_id = season_id
	_update_title()

	if is_window_visible():
		_sync_visual()


func _update_title() -> void:
	if not is_instance_valid(title_label):
		return

	var season_names := {
		"spring": "PRIMAVERA",
		"summer": "VERÃO",
		"autumn": "OUTONO",
		"winter": "INVERNO"
	}
	var population: int = int(
		current_population_overview.get(
			"total_population",
			0
		)
	)
	var happiness: float = float(
		current_population_overview.get("happiness", 60.0)
	)
	var mood_name: String = "ROTINA ESTÁVEL"
	if happiness >= 70.0:
		mood_name = "CONVIVÊNCIA ANIMADA"
	elif happiness < 20.0:
		mood_name = "CRISE"
	elif happiness < 40.0:
		mood_name = "PREOCUPAÇÃO"
	title_label.text = "VILA AMPLIADA — %s — %d HABITANTES — %s" % [
		String(season_names.get(current_season_id, "PRIMAVERA")),
		population,
		mood_name
	]


func _sync_visual() -> void:
	if not is_instance_valid(village_visuals):
		return

	village_visuals.apply_season(
		current_season_id
	)
	village_visuals.update_buildings(
		current_building_state,
		false
	)
	village_visuals.update_population_overview(
		current_population_overview
	)
	village_visuals.update_council(
		current_council_members,
		current_selected_member_id
	)


func _on_visual_building_requested(
	building_id: String
) -> void:
	building_requested.emit(building_id)


func _on_visual_council_member_requested(
	representative_id: String
) -> void:
	council_member_requested.emit(representative_id)
