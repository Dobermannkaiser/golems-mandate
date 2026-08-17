extends Node


const UI_MANAGER_SCRIPT = preload("res://scripts/UIManagerVariantB.gd")


var ui_manager: Control
var failures: Array[String] = []
var background_activations: int = 0


func _ready() -> void:
	await _run_regression()
	if failures.is_empty():
		print("UI_MODAL_EXCLUSIVITY_OK A-J MOUSE")
	else:
		print("UI_MODAL_EXCLUSIVITY_FAILED %s" % ", ".join(failures))


func _run_regression() -> void:
	ui_manager = UI_MANAGER_SCRIPT.new() as Control
	ui_manager.name = "UIManagerUnderTest"
	add_child(ui_manager)
	await _wait_frames(5)

	var main_menu: Variant = ui_manager.get("main_menu")
	if is_instance_valid(main_menu):
		main_menu.call("hide_menu")
	var tutorial_manager: Variant = ui_manager.get("tutorial_manager")
	if is_instance_valid(tutorial_manager):
		tutorial_manager.call("mark_hint_seen", "area_relationships")
		tutorial_manager.call("mark_hint_seen", "area_council")
	await _wait_frames(2)

	var sidebar_buttons: Dictionary = ui_manager.get("sidebar_buttons") as Dictionary
	var village_button: Button = sidebar_buttons.get("village") as Button
	var relationships_button: Button = sidebar_buttons.get("relationships") as Button
	_assert_true(is_instance_valid(village_button), "A_VILLAGE_BUTTON")
	_assert_true(is_instance_valid(relationships_button), "A_RELATIONSHIPS_BUTTON")
	if not is_instance_valid(village_button) or not is_instance_valid(relationships_button):
		return
	relationships_button.pressed.connect(_on_background_activated)

	# A — sem modal, a navegação normal da interface base continua ativa.
	village_button.grab_focus()
	await _send_key(KEY_TAB)
	var base_focus: Control = get_viewport().gui_get_focus_owner()
	_assert_true(_active_id().is_empty(), "A_NO_ACTIVE_MODAL")
	_assert_true(
		is_instance_valid(base_focus)
		and VillageUIAccessibility.is_focus_within(ui_manager.get("interface_root") as Control, base_focus),
		"A_BASE_NAVIGATION"
	)

	# B/G — o Guia é a autoridade ativa e Tab/Shift+Tab não escapam.
	village_button.grab_focus()
	ui_manager.call("_show_campaign_tutorial", false, false, false, true)
	await _wait_frames(4)
	var tutorial: Control = ui_manager.get("tutorial_window") as Control
	var next_button: Button = tutorial.get("next_button") as Button
	var skip_button: Button = tutorial.get("skip_button") as Button
	_assert_true(_active_id() == &"tutorial", "B_TUTORIAL_ACTIVE")
	_assert_focus_within(tutorial, "B_INITIAL_FOCUS")
	_assert_true(
		is_instance_valid(tutorial.get("overlay") as Control)
		and (tutorial.get("overlay") as Control).mouse_filter == Control.MOUSE_FILTER_STOP,
		"MOUSE_TUTORIAL_BLOCKER"
	)

	next_button.grab_focus()
	await _send_key(KEY_TAB)
	_assert_focus_within(tutorial, "G_TAB_CONFINED")
	skip_button.grab_focus()
	await _send_key(KEY_TAB, true)
	_assert_focus_within(tutorial, "G_SHIFT_TAB_CONFINED")

	# H — ações direcionais de teclado/gamepad recuperam o foco para o topo.
	relationships_button.grab_focus()
	await _send_key(KEY_DOWN)
	_assert_focus_within(tutorial, "H_KEYBOARD_DIRECTION_CONFINED")
	relationships_button.grab_focus()
	await _send_action(&"ui_down")
	_assert_focus_within(tutorial, "H_GAMEPAD_ACTION_CONFINED")

	# I — Accept, Enter e Space não podem acionar o botão atrás.
	var activation_baseline: int = background_activations
	relationships_button.grab_focus()
	await _send_action(&"ui_accept")
	_assert_tutorial_exclusive(tutorial, activation_baseline, "I_ACCEPT")
	relationships_button.grab_focus()
	await _send_key(KEY_ENTER)
	_assert_tutorial_exclusive(tutorial, activation_baseline, "I_ENTER")
	relationships_button.grab_focus()
	await _send_key(KEY_SPACE)
	_assert_tutorial_exclusive(tutorial, activation_baseline, "I_SPACE")

	# D — mesmo uma chamada direta ao handler incompatível é recusada.
	ui_manager.call("_on_sidebar_relationships_pressed")
	await _wait_frames(2)
	_assert_true(_active_id() == &"tutorial", "D_SECOND_OPEN_BLOCKED")
	_assert_true(not _window_is_visible("relationships_window"), "D_RELATIONSHIPS_CLOSED")

	# Mouse — o overlay STOP impede que o botão visível atrás receba clique.
	await _send_mouse_click(relationships_button.get_global_rect().get_center())
	_assert_tutorial_exclusive(tutorial, activation_baseline, "MOUSE_BACKGROUND_BLOCKED")

	# J/E — Cancel fecha somente o Guia e restaura o foco anterior da base.
	await _send_key(KEY_ESCAPE)
	await _wait_frames(4)
	_assert_true(_active_id().is_empty(), "J_TUTORIAL_CANCEL")
	_assert_true(get_viewport().gui_get_focus_owner() == village_button, "E_FOCUS_RESTORED")

	# C — um segundo modal real também confina background e bloqueia outro menu.
	ui_manager.call("_on_sidebar_relationships_pressed")
	await _wait_frames(4)
	var relationships: Control = ui_manager.get("relationships_window") as Control
	_assert_true(_active_id() == &"relationships", "C_RELATIONSHIPS_ACTIVE")
	_assert_focus_within(relationships, "C_RELATIONSHIPS_FOCUS")
	_assert_true(
		is_instance_valid(relationships.get("overlay") as Control)
		and (relationships.get("overlay") as Control).mouse_filter == Control.MOUSE_FILTER_STOP,
		"MOUSE_RELATIONSHIPS_BLOCKER"
	)
	village_button.grab_focus()
	await _send_key(KEY_TAB)
	_assert_focus_within(relationships, "C_BACKGROUND_CONFINED")
	ui_manager.call("_on_council_button_pressed")
	await _wait_frames(2)
	_assert_true(_active_id() == &"relationships", "D_COUNCIL_OPEN_BLOCKED")
	_assert_true(not _window_is_visible("council_window"), "D_COUNCIL_CLOSED")

	# J/F — fecha Relações, abre Conselho e fecha sem estado residual.
	await _send_key(KEY_ESCAPE)
	await _wait_frames(4)
	_assert_true(_active_id().is_empty(), "J_RELATIONSHIPS_CANCEL")
	_assert_true(get_viewport().gui_get_focus_owner() == village_button, "E_RELATIONSHIPS_FOCUS_RESTORED")
	ui_manager.call("_on_council_button_pressed")
	await _wait_frames(3)
	_assert_true(_active_id() == &"council", "F_COUNCIL_AFTER_CLOSE")
	await _send_key(KEY_ESCAPE)
	await _wait_frames(3)
	_assert_true(_active_id().is_empty(), "F_NO_RESIDUAL_STATE")


func _active_id() -> StringName:
	return StringName(ui_manager.call("get_active_interface_id"))


func _window_is_visible(property_name: StringName) -> bool:
	var window: Variant = ui_manager.get(property_name)
	return is_instance_valid(window) and bool(window.call("is_window_visible"))


func _assert_tutorial_exclusive(
	tutorial: Control,
	activation_baseline: int,
	check_name: String
) -> void:
	_assert_true(_active_id() == &"tutorial", check_name + "_TOP")
	_assert_true(not _window_is_visible("relationships_window"), check_name + "_NO_OPEN")
	_assert_true(background_activations == activation_baseline, check_name + "_NO_PRESS")
	_assert_focus_within(tutorial, check_name + "_FOCUS")


func _assert_focus_within(root: Control, check_name: String) -> void:
	_assert_true(
		VillageUIAccessibility.is_focus_within(root, get_viewport().gui_get_focus_owner()),
		check_name
	)


func _assert_true(condition: bool, check_name: String) -> void:
	if condition:
		return
	failures.append(check_name)


func _on_background_activated() -> void:
	background_activations += 1


func _send_action(action_name: StringName) -> void:
	var pressed_event: InputEventAction = InputEventAction.new()
	pressed_event.action = action_name
	pressed_event.pressed = true
	Input.parse_input_event(pressed_event)
	await get_tree().process_frame
	var released_event: InputEventAction = InputEventAction.new()
	released_event.action = action_name
	released_event.pressed = false
	Input.parse_input_event(released_event)
	await get_tree().process_frame


func _send_key(keycode: Key, shift_pressed: bool = false) -> void:
	var pressed_event: InputEventKey = InputEventKey.new()
	pressed_event.keycode = keycode
	pressed_event.physical_keycode = keycode
	pressed_event.shift_pressed = shift_pressed
	pressed_event.pressed = true
	Input.parse_input_event(pressed_event)
	await get_tree().process_frame
	var released_event: InputEventKey = InputEventKey.new()
	released_event.keycode = keycode
	released_event.physical_keycode = keycode
	released_event.shift_pressed = shift_pressed
	released_event.pressed = false
	Input.parse_input_event(released_event)
	await get_tree().process_frame


func _send_mouse_click(position: Vector2) -> void:
	var motion_event: InputEventMouseMotion = InputEventMouseMotion.new()
	motion_event.position = position
	Input.parse_input_event(motion_event)
	await get_tree().process_frame
	var pressed_event: InputEventMouseButton = InputEventMouseButton.new()
	pressed_event.position = position
	pressed_event.button_index = MOUSE_BUTTON_LEFT
	pressed_event.pressed = true
	Input.parse_input_event(pressed_event)
	await get_tree().process_frame
	var released_event: InputEventMouseButton = InputEventMouseButton.new()
	released_event.position = position
	released_event.button_index = MOUSE_BUTTON_LEFT
	released_event.pressed = false
	Input.parse_input_event(released_event)
	await get_tree().process_frame


func _wait_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().process_frame
