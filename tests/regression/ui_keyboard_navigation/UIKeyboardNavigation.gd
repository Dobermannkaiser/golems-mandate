extends Node


const UI_MANAGER_SCRIPT = preload("res://scripts/UIManagerVariantB.gd")


var ui_manager: Control
var failures: Array[String] = []
var village_accept_count: int = 0
var last_village_building_id: String = ""


func _ready() -> void:
	await _run_regression()
	if failures.is_empty():
		print(
			"UI_KEYBOARD_NAVIGATION_OK "
			+ "DISABLED TAB SHIFT DIRECTION PAGE SUBMODAL SAVE "
			+ "VILLAGE SCROLL RESTORE ACCEPT REOPEN MATRIX"
		)
	else:
		print("UI_KEYBOARD_NAVIGATION_FAILED %s" % ", ".join(failures))


func _run_regression() -> void:
	ui_manager = UI_MANAGER_SCRIPT.new() as Control
	ui_manager.name = "UIManagerKeyboardUnderTest"
	add_child(ui_manager)
	await _wait_frames(6)
	await _prepare_clean_base()

	await _test_save_without_slot()
	await _test_tutorial_disabled_control()
	await _test_main_menu_focus_pages()
	await _test_dialogue_submodal_and_restore()
	await _test_village_keyboard_accept()
	await _test_reproducible_matrix_states()
	await _test_safe_synthetic_na_states()
	await _test_invalid_restore_fallback()


func _prepare_clean_base() -> void:
	var main_menu: Control = ui_manager.get("main_menu") as Control
	if is_instance_valid(main_menu):
		main_menu.call("hide_menu")
	var tutorial_manager: Variant = ui_manager.get("tutorial_manager")
	if is_instance_valid(tutorial_manager):
		for hint_id: String in [
			"area_village",
			"area_register",
			"area_relationships",
			"area_council",
			"area_campaign",
			"area_buildings",
			"area_village_expanded",
			"area_save"
		]:
			tutorial_manager.call("mark_hint_seen", hint_id)
	await _wait_frames(3)


func _test_save_without_slot() -> void:
	ui_manager.call("_create_save_window")
	await _wait_frames(2)
	var save_window: Control = ui_manager.get("save_window") as Control
	_assert_true(is_instance_valid(save_window), "SAVE_EXISTS")
	if not is_instance_valid(save_window):
		return
	var save_button: Button = save_window.get("save_button") as Button
	var load_button: Button = save_window.get("load_button") as Button
	var delete_button: Button = save_window.get("delete_button") as Button
	var close_button: Button = save_window.get("close_button") as Button

	save_window.call(
		"show_window",
		{
			"has_save": false,
			"is_valid": false,
			"autosave_enabled": false
		}
	)
	await _wait_frames(4)
	_assert_focus(save_button, "SAVE_INITIAL")
	_assert_true(load_button.disabled, "SAVE_LOAD_DISABLED")
	_assert_true(delete_button.disabled, "SAVE_DELETE_DISABLED")

	await _send_key(KEY_TAB)
	_assert_focus(close_button, "SAVE_TAB_SKIPS_DISABLED")
	await _send_key(KEY_TAB)
	_assert_focus(save_button, "SAVE_TAB_WRAP")
	await _send_key(KEY_TAB, true)
	_assert_focus(close_button, "SAVE_SHIFT_SKIPS_DISABLED")
	await _send_key(KEY_TAB, true)
	_assert_focus(save_button, "SAVE_SHIFT_WRAP")

	save_button.grab_focus()
	await _send_action(&"ui_down")
	_assert_focus(close_button, "SAVE_DIRECTION_DOWN")
	await _send_action(&"ui_up")
	_assert_focus(save_button, "SAVE_DIRECTION_UP")
	_assert_true(
		get_viewport().gui_get_focus_owner() not in [load_button, delete_button],
		"SAVE_DISABLED_NEVER_FOCUSED"
	)

	await _send_key(KEY_ESCAPE)
	await _wait_frames(2)
	_assert_true(not bool(save_window.call("is_window_visible")), "SAVE_CLOSE")
	save_window.call(
		"show_window",
		{"has_save": false, "is_valid": false}
	)
	await _wait_frames(3)
	_assert_focus(save_button, "SAVE_REOPEN_INITIAL")
	await _send_key(KEY_ESCAPE)
	await _wait_frames(2)


func _test_tutorial_disabled_control() -> void:
	ui_manager.call("_show_campaign_tutorial", false, false, false, true)
	await _wait_frames(4)
	var tutorial: Control = ui_manager.get("tutorial_window") as Control
	_assert_true(is_instance_valid(tutorial), "GUIDE_EXISTS")
	if not is_instance_valid(tutorial):
		return
	var next_button: Button = tutorial.get("next_button") as Button
	var previous_button: Button = tutorial.get("previous_button") as Button
	_assert_true(previous_button.disabled, "GUIDE_BACK_DISABLED")
	next_button.grab_focus()
	for index: int in range(4):
		await _send_key(KEY_TAB)
		_assert_true(
			get_viewport().gui_get_focus_owner() != previous_button,
			"GUIDE_TAB_DISABLED_%d" % index
		)
	next_button.grab_focus()
	for index: int in range(4):
		await _send_key(KEY_TAB, true)
		_assert_true(
			get_viewport().gui_get_focus_owner() != previous_button,
			"GUIDE_SHIFT_DISABLED_%d" % index
		)
	var step_before: int = int(tutorial.get("current_step_index"))
	await _send_action(&"ui_right")
	_assert_true(
		int(tutorial.get("current_step_index")) != step_before,
		"GUIDE_SEMANTIC_RIGHT"
	)
	next_button.grab_focus()
	step_before = int(tutorial.get("current_step_index"))
	await _send_action(&"ui_accept")
	_assert_true(
		int(tutorial.get("current_step_index")) != step_before,
		"GUIDE_ACCEPT"
	)
	await _send_key(KEY_ESCAPE)
	await _wait_frames(3)


func _test_main_menu_focus_pages() -> void:
	var main_menu: Control = ui_manager.get("main_menu") as Control
	_assert_true(is_instance_valid(main_menu), "MENU_EXISTS")
	if not is_instance_valid(main_menu):
		return
	main_menu.call("show_settings", {}, true)
	await _wait_frames(5)
	var settings_page: Control = main_menu.get("settings_page") as Control
	_assert_true(
		ui_manager.call("get_active_focus_root") == settings_page,
		"SETTINGS_ACTIVE_ROOT"
	)
	_assert_focus_within(settings_page, "SETTINGS_INITIAL_WITHIN")
	_assert_focus_visible_in_scroll("SETTINGS_INITIAL_VISIBLE")
	for index: int in range(12):
		await _send_key(KEY_TAB)
		_assert_focus_within(
			settings_page,
			"SETTINGS_TAB_CONFINED_%d" % index
		)
	for index: int in range(12):
		await _send_key(KEY_TAB, true)
		_assert_focus_within(
			settings_page,
			"SETTINGS_SHIFT_CONFINED_%d" % index
		)

	main_menu.call("show_new_campaign_confirmation", {})
	await _wait_frames(4)
	var confirmation_page: Control = main_menu.get("confirmation_page") as Control
	_assert_true(
		ui_manager.call("get_active_focus_root") == confirmation_page,
		"CONFIRM_ACTIVE_ROOT"
	)
	for index: int in range(8):
		await _send_key(KEY_TAB, index % 2 == 1)
		_assert_focus_within(
			confirmation_page,
			"CONFIRM_CONFINED_%d" % index
		)
	main_menu.call("hide_menu")
	await _wait_frames(3)


func _test_dialogue_submodal_and_restore() -> void:
	ui_manager.call("show_internal_diagnostics")
	await _wait_frames(5)
	var diagnostics: Control = ui_manager.get("diagnostics_window") as Control
	var dialogue_test_button: Button = _find_button_by_text(
		diagnostics,
		"TESTAR DIÁLOGO"
	)
	_assert_true(
		is_instance_valid(dialogue_test_button),
		"DIALOGUE_TEST_BUTTON"
	)
	if not is_instance_valid(dialogue_test_button):
		return
	dialogue_test_button.emit_signal("pressed")
	await _wait_frames(5)
	var dialogue: Control = ui_manager.get("dialogue_window") as Control
	_assert_true(bool(dialogue.call("is_dialogue_visible")), "DIALOGUE_OPEN")
	var history_button: Button = dialogue.get("history_button") as Button
	history_button.emit_signal("pressed")
	await _wait_frames(3)
	var history_panel: Control = dialogue.get("history_panel") as Control
	_assert_true(
		ui_manager.call("get_active_focus_root") == history_panel,
		"HISTORY_ACTIVE_ROOT"
	)
	for index: int in range(6):
		await _send_key(KEY_TAB, index % 2 == 1)
		_assert_focus_within(
			history_panel,
			"HISTORY_CONFINED_%d" % index
		)
	await _send_key(KEY_ESCAPE)
	await _wait_frames(3)
	_assert_true(not history_panel.visible, "HISTORY_CANCEL_ONLY_TOP")
	_assert_focus_within(dialogue, "HISTORY_RETURN_DIALOGUE")
	await _send_key(KEY_ESCAPE)
	await _wait_frames(4)
	_assert_true(not bool(dialogue.call("is_dialogue_visible")), "DIALOGUE_CLOSE")
	_assert_focus_within(
		ui_manager.get("interface_root") as Control,
		"DIALOGUE_INVALID_PREVIOUS_FALLBACK"
	)


func _test_village_keyboard_accept() -> void:
	ui_manager.call("_create_village_window")
	await _wait_frames(2)
	var village: Control = ui_manager.get("village_window") as Control
	_assert_true(is_instance_valid(village), "VILLAGE_EXISTS")
	if not is_instance_valid(village):
		return
	var village_callback: Callable = _on_village_building_requested
	if not village.is_connected("building_requested", village_callback):
		village.connect("building_requested", village_callback)
	village.call("show_village")
	await _wait_frames(5)
	var close_button: Button = village.get("close_button") as Button
	var visuals: Control = village.get("village_visuals") as Control
	var building_buttons: Dictionary = visuals.get("building_buttons") as Dictionary
	_assert_true(building_buttons.size() == 5, "VILLAGE_BUILDING_COUNT")
	var visited: Dictionary = {}
	close_button.grab_focus()
	for _index: int in range(6):
		await _send_key(KEY_TAB)
		var focus_owner: Control = get_viewport().gui_get_focus_owner()
		for building_id_value: Variant in building_buttons.keys():
			var building_id: String = String(building_id_value)
			var button: TextureButton = (
				building_buttons.get(building_id) as TextureButton
			)
			_assert_true(
				button.focus_mode == Control.FOCUS_ALL,
				"VILLAGE_FOCUS_MODE_%s" % building_id
			)
			if focus_owner == button:
				visited[building_id] = true
	_assert_true(visited.size() == building_buttons.size(), "VILLAGE_TAB_ALL")

	var first_button: TextureButton = (
		building_buttons.values()[0] as TextureButton
	)
	first_button.grab_focus()
	village_accept_count = 0
	last_village_building_id = ""
	await _send_action(&"ui_accept")
	_assert_true(village_accept_count == 1, "VILLAGE_ACCEPT_ONCE")
	_assert_true(not last_village_building_id.is_empty(), "VILLAGE_ACCEPT_ID")
	var building_window: Control = ui_manager.get("building_window") as Control
	if (
		is_instance_valid(building_window)
		and bool(building_window.call("is_window_visible"))
	):
		building_window.call("hide_window")
	if bool(village.call("is_window_visible")):
		village.call("hide_window")
	await _wait_frames(3)


func _test_invalid_restore_fallback() -> void:
	var focus_root: VBoxContainer = VBoxContainer.new()
	var invalid_previous: Button = Button.new()
	var fallback: Button = Button.new()
	invalid_previous.text = "INVALID"
	fallback.text = "FALLBACK"
	focus_root.add_child(invalid_previous)
	focus_root.add_child(fallback)
	add_child(focus_root)
	await _wait_frames(2)
	invalid_previous.visible = false
	VillageUIAccessibility.restore_focus_deferred(
		invalid_previous,
		focus_root,
		fallback
	)
	await _wait_frames(3)
	_assert_focus(fallback, "RESTORE_FALLBACK")
	focus_root.queue_free()
	await _wait_frames(2)


func _test_reproducible_matrix_states() -> void:
	await _test_register_directional_layout()
	await _exercise_modal_state(
		&"council",
		&"council_window",
		Callable(ui_manager, "_on_council_button_pressed"),
		"COUNCIL"
	)
	await _exercise_modal_state(
		&"relationships",
		&"relationships_window",
		Callable(ui_manager, "_on_sidebar_relationships_pressed"),
		"RELATIONSHIPS"
	)
	await _exercise_modal_state(
		&"campaign",
		&"campaign_window",
		Callable(ui_manager, "_on_campaign_button_pressed"),
		"CAMPAIGN"
	)
	await _exercise_modal_state(
		&"building",
		&"building_window",
		Callable(ui_manager, "_on_building_button_pressed"),
		"BUILDING"
	)
	await _exercise_modal_state(
		&"main_menu",
		&"main_menu",
		Callable(self, "_open_main_menu"),
		"MAIN_MENU"
	)
	await _exercise_modal_state(
		&"diagnostics",
		&"diagnostics_window",
		Callable(ui_manager, "show_internal_diagnostics"),
		"DIAGNOSTICS"
	)


func _test_register_directional_layout() -> void:
	var sidebar_buttons: Dictionary = ui_manager.get("sidebar_buttons") as Dictionary
	var register_button: Button = sidebar_buttons.get("register") as Button
	var village_button: Button = sidebar_buttons.get("village") as Button
	_assert_true(is_instance_valid(register_button), "REGISTER_BUTTON")
	_assert_true(is_instance_valid(village_button), "REGISTER_VILLAGE_BUTTON")
	if not is_instance_valid(register_button) or not is_instance_valid(village_button):
		return
	register_button.emit_signal("pressed")
	await _wait_frames(3)
	var register_workspace: Control = ui_manager.get("register_workspace") as Control
	var register_text: RichTextLabel = ui_manager.get("register_text") as RichTextLabel
	var back_button: Button = ui_manager.get("register_back_button") as Button
	_assert_true(register_workspace.visible, "REGISTER_OPEN")
	register_text.text = "REGISTRO DE TESTE\n".repeat(60)
	await _wait_frames(3)
	back_button.grab_focus()
	await _send_action(&"ui_down")
	_assert_focus(register_text, "REGISTER_DIRECTION_TO_CONTENT")
	await _send_action(&"ui_left")
	_assert_focus(register_button, "REGISTER_DIRECTION_TO_SIDEBAR")
	await _send_key(KEY_TAB)
	_assert_focus_within(ui_manager.get("interface_root") as Control, "REGISTER_TAB")
	await _send_key(KEY_TAB, true)
	_assert_focus_within(ui_manager.get("interface_root") as Control, "REGISTER_SHIFT")
	village_button.emit_signal("pressed")
	await _wait_frames(2)


func _exercise_modal_state(
	interface_id: StringName,
	property_name: StringName,
	opener: Callable,
	check_prefix: String
) -> void:
	var sidebar_buttons: Dictionary = ui_manager.get("sidebar_buttons") as Dictionary
	var background_button: Button = sidebar_buttons.get("village") as Button
	_assert_true(is_instance_valid(background_button), check_prefix + "_BACKGROUND")
	if not is_instance_valid(background_button):
		return
	background_button.grab_focus()
	opener.call()
	await _wait_frames(5)
	var modal: Control = ui_manager.get(property_name) as Control
	_assert_true(is_instance_valid(modal), check_prefix + "_EXISTS")
	if not is_instance_valid(modal):
		return
	_assert_true(
		StringName(ui_manager.call("get_active_interface_id")) == interface_id,
		check_prefix + "_ACTIVE"
	)
	var active_root: Control = ui_manager.call("get_active_focus_root") as Control
	_assert_true(
		VillageUIAccessibility.is_focus_within(modal, active_root),
		check_prefix + "_ROOT"
	)
	_assert_focus_within(active_root, check_prefix + "_INITIAL")
	await _send_key(KEY_TAB)
	_assert_focus_within(active_root, check_prefix + "_TAB")
	await _send_key(KEY_TAB, true)
	_assert_focus_within(active_root, check_prefix + "_SHIFT")
	background_button.grab_focus()
	await _send_action(&"ui_down")
	_assert_focus_within(active_root, check_prefix + "_DIRECTION_CONFINED")
	if interface_id == &"relationships":
		ui_manager.call("_on_council_button_pressed")
	else:
		ui_manager.call("_on_sidebar_relationships_pressed")
	await _wait_frames(2)
	_assert_true(
		StringName(ui_manager.call("get_active_interface_id")) == interface_id,
		check_prefix + "_SECOND_BLOCKED"
	)
	await _send_key(KEY_ESCAPE)
	await _wait_frames(4)
	_assert_true(
		StringName(ui_manager.call("get_active_interface_id")).is_empty(),
		check_prefix + "_CANCEL"
	)
	_assert_focus(background_button, check_prefix + "_RESTORE")
	opener.call()
	await _wait_frames(4)
	active_root = ui_manager.call("get_active_focus_root") as Control
	_assert_focus_within(active_root, check_prefix + "_REOPEN")
	var accept_button: Button = _get_safe_accept_button(modal, interface_id)
	_assert_true(is_instance_valid(accept_button), check_prefix + "_ACCEPT_TARGET")
	if is_instance_valid(accept_button):
		accept_button.grab_focus()
		await _send_action(&"ui_accept")
		await _wait_frames(4)
		if interface_id == &"main_menu":
			var settings_page: Control = modal.get("settings_page") as Control
			_assert_true(
				ui_manager.call("get_active_focus_root") == settings_page,
				check_prefix + "_ACCEPT"
			)
			modal.call("hide_menu")
			await _wait_frames(3)
		else:
			_assert_true(
				StringName(ui_manager.call("get_active_interface_id")).is_empty(),
				check_prefix + "_ACCEPT"
			)
		_assert_focus(background_button, check_prefix + "_ACCEPT_RESTORE")
	else:
		await _send_key(KEY_ESCAPE)
		await _wait_frames(3)


func _open_main_menu() -> void:
	var main_menu: Control = ui_manager.get("main_menu") as Control
	main_menu.call("show_menu", GameManager.get_save_overview(), true)


func _test_safe_synthetic_na_states() -> void:
	await _test_valid_save_slot_navigation()
	await _test_main_menu_load_and_records_pages()
	await _test_building_internal_focus_roots()


func _test_valid_save_slot_navigation() -> void:
	var save_window: Control = ui_manager.get("save_window") as Control
	var background_button: Button = (
		(ui_manager.get("sidebar_buttons") as Dictionary).get("village") as Button
	)
	background_button.grab_focus()
	save_window.call(
		"show_window",
		{
			"has_save": true,
			"is_valid": true,
			"saved_day": 24,
			"saved_population": 12,
			"saved_housing_capacity": 15
		}
	)
	await _wait_frames(4)
	_assert_true(not (save_window.get("load_button") as Button).disabled, "SAVE_VALID_LOAD")
	_assert_true(not (save_window.get("delete_button") as Button).disabled, "SAVE_VALID_DELETE")
	for index: int in range(5):
		await _send_key(KEY_TAB, index % 2 == 1)
		_assert_focus_within(save_window, "SAVE_VALID_CONFINED_%d" % index)
	var close_button: Button = save_window.get("close_button") as Button
	close_button.grab_focus()
	await _send_action(&"ui_accept")
	await _wait_frames(3)
	_assert_true(not bool(save_window.call("is_window_visible")), "SAVE_VALID_ACCEPT")
	_assert_focus(background_button, "SAVE_VALID_RESTORE")


func _test_main_menu_load_and_records_pages() -> void:
	var main_menu: Control = ui_manager.get("main_menu") as Control
	var background_button: Button = (
		(ui_manager.get("sidebar_buttons") as Dictionary).get("village") as Button
	)
	background_button.grab_focus()
	main_menu.call(
		"show_menu",
		{
			"has_save": true,
			"is_valid": true,
			"saved_day": 24,
			"saved_population": 12
		},
		true
	)
	main_menu.call("_on_open_load_pressed")
	await _wait_frames(4)
	var load_page: Control = main_menu.get("load_page") as Control
	_assert_true(ui_manager.call("get_active_focus_root") == load_page, "LOAD_PAGE_ROOT")
	_assert_focus_within(load_page, "LOAD_PAGE_INITIAL")
	await _send_key(KEY_TAB)
	_assert_focus_within(load_page, "LOAD_PAGE_TAB")
	await _send_key(KEY_TAB, true)
	_assert_focus_within(load_page, "LOAD_PAGE_SHIFT")
	main_menu.call("_show_main_page")
	await _wait_frames(3)
	var main_root: Control = main_menu.get("overlay") as Control
	_assert_true(ui_manager.call("get_active_focus_root") == main_root, "LOAD_PAGE_BACK")

	main_menu.call("_refresh_records_page")
	var records_page: Control = main_menu.get("records_page") as Control
	main_menu.call("_show_page", records_page)
	await _wait_frames(3)
	_assert_true(ui_manager.call("get_active_focus_root") == records_page, "RECORDS_PAGE_ROOT")
	_assert_focus_within(records_page, "RECORDS_PAGE_INITIAL")
	await _send_key(KEY_TAB)
	_assert_focus_within(records_page, "RECORDS_PAGE_TAB")
	await _send_key(KEY_TAB, true)
	_assert_focus_within(records_page, "RECORDS_PAGE_SHIFT")
	main_menu.call("_show_main_page")
	await _wait_frames(3)
	_assert_true(ui_manager.call("get_active_focus_root") == main_root, "RECORDS_PAGE_BACK")
	main_menu.call("hide_menu")
	await _wait_frames(3)
	_assert_focus(background_button, "RECORDS_PAGE_RESTORE")


func _test_building_internal_focus_roots() -> void:
	var background_button: Button = (
		(ui_manager.get("sidebar_buttons") as Dictionary).get("village") as Button
	)
	background_button.grab_focus()
	ui_manager.call("_on_building_button_pressed")
	await _wait_frames(5)
	var building: Control = ui_manager.get("building_window") as Control
	var base_root: Control = ui_manager.call("get_active_focus_root") as Control
	var close_button: Button = building.get("close_button") as Button
	close_button.grab_focus()
	building.call("_on_cancel_order_pressed", "synthetic", "Casa", 4.0, 50, "queued")
	await _wait_frames(3)
	var confirm_root: Control = ui_manager.call("get_active_focus_root") as Control
	_assert_true(confirm_root != base_root, "BUILD_CONFIRM_ROOT")
	_assert_focus_within(confirm_root, "BUILD_CONFIRM_INITIAL")
	await _send_key(KEY_TAB)
	_assert_focus_within(confirm_root, "BUILD_CONFIRM_TAB")
	await _send_key(KEY_TAB, true)
	_assert_focus_within(confirm_root, "BUILD_CONFIRM_SHIFT")
	await _send_key(KEY_ESCAPE)
	await _wait_frames(3)
	_assert_true(ui_manager.call("get_active_focus_root") == base_root, "BUILD_CONFIRM_CANCEL")
	_assert_focus(close_button, "BUILD_CONFIRM_RESTORE")

	building.call(
		"_show_variant_choice",
		{
			"can_upgrade": true,
			"id": "well",
			"name": "Poço",
			"variant_options": [
				{"id": "pure", "name": "Fonte Pura", "effect_text": "+Água"},
				{"id": "deep", "name": "Poço Fundo", "effect_text": "+Reserva"}
			]
		}
	)
	await _wait_frames(4)
	var variant_root: Control = ui_manager.call("get_active_focus_root") as Control
	_assert_true(variant_root != base_root, "BUILD_VARIANT_ROOT")
	_assert_focus_within(variant_root, "BUILD_VARIANT_INITIAL")
	await _send_key(KEY_TAB)
	_assert_focus_within(variant_root, "BUILD_VARIANT_TAB")
	await _send_key(KEY_TAB, true)
	_assert_focus_within(variant_root, "BUILD_VARIANT_SHIFT")
	await _send_key(KEY_ESCAPE)
	await _wait_frames(3)
	_assert_true(ui_manager.call("get_active_focus_root") == base_root, "BUILD_VARIANT_CANCEL")
	_assert_focus(close_button, "BUILD_VARIANT_RESTORE")
	await _send_key(KEY_ESCAPE)
	await _wait_frames(3)
	_assert_focus(background_button, "BUILD_INTERNAL_FINAL_RESTORE")


func _get_safe_accept_button(modal: Control, interface_id: StringName) -> Button:
	if interface_id == &"main_menu":
		return _find_button_by_text(modal, "CONFIGURAÇÕES")
	var property_name: StringName = (
		&"_close_button" if interface_id == &"council" else &"close_button"
	)
	return modal.get(property_name) as Button


func _find_button_by_text(root: Node, text_value: String) -> Button:
	if not is_instance_valid(root):
		return null
	for node: Node in root.find_children("*", "Button", true, false):
		var button: Button = node as Button
		if is_instance_valid(button) and button.text == text_value:
			return button
	return null


func _assert_focus_visible_in_scroll(check_name: String) -> void:
	var focus_owner: Control = get_viewport().gui_get_focus_owner()
	if not is_instance_valid(focus_owner):
		_assert_true(false, check_name)
		return
	var ancestor: Node = focus_owner.get_parent()
	while is_instance_valid(ancestor):
		if ancestor is ScrollContainer:
			_assert_true(
				(ancestor as ScrollContainer).get_global_rect().intersects(
					focus_owner.get_global_rect()
				),
				check_name
			)
			return
		ancestor = ancestor.get_parent()
	_assert_true(false, check_name + "_NO_SCROLL")


func _assert_focus(expected: Control, check_name: String) -> void:
	_assert_true(get_viewport().gui_get_focus_owner() == expected, check_name)


func _assert_focus_within(root: Control, check_name: String) -> void:
	_assert_true(
		VillageUIAccessibility.is_focus_within(
			root,
			get_viewport().gui_get_focus_owner()
		),
		check_name
	)


func _assert_true(condition: bool, check_name: String) -> void:
	if not condition:
		failures.append(check_name)


func _on_village_building_requested(building_id: String) -> void:
	village_accept_count += 1
	last_village_building_id = building_id


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


func _wait_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().process_frame
