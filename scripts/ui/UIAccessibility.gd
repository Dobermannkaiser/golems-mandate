class_name VillageUIAccessibility
extends RefCounted


const DEFAULT_TARGET_HEIGHT: float = 40.0


static func remember_focus(owner: Control) -> Control:
	if not is_instance_valid(owner):
		return null
	var viewport: Viewport = owner.get_viewport()
	if not is_instance_valid(viewport):
		return null
	var focus_owner: Control = viewport.gui_get_focus_owner()
	if not is_instance_valid(focus_owner):
		return null
	if not focus_owner.is_visible_in_tree():
		return null
	return focus_owner


static func focus_deferred(control: Control) -> void:
	if not _is_focusable(control):
		return
	control.call_deferred("grab_focus")


static func restore_focus_deferred(control: Control) -> void:
	if not _is_focusable(control):
		return
	control.call_deferred("grab_focus")


static func focus_first_enabled(
	root: Node,
	preferred: Control = null
) -> void:
	if _is_focusable(preferred):
		preferred.call_deferred("grab_focus")
		return
	var candidate: Control = _find_first_focusable(root)
	if is_instance_valid(candidate):
		candidate.call_deferred("grab_focus")


static func configure_button(
	button: Button,
	tooltip: String = "",
	minimum_height: float = DEFAULT_TARGET_HEIGHT
) -> void:
	if not is_instance_valid(button):
		return
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.custom_minimum_size.y = maxf(
		button.custom_minimum_size.y,
		minimum_height
	)
	if not tooltip.strip_edges().is_empty():
		button.tooltip_text = tooltip


static func configure_input(control: Control) -> void:
	if not is_instance_valid(control):
		return
	control.focus_mode = Control.FOCUS_ALL


static func mark_feedback(
	message: String,
	is_success: bool
) -> String:
	var clean_message: String = message.strip_edges()
	if clean_message.is_empty():
		return ""
	return "%s %s" % [
		"[OK]" if is_success else "[ATENÇÃO]",
		clean_message
	]


static func _find_first_focusable(node: Node) -> Control:
	if not is_instance_valid(node):
		return null
	if node is Control:
		var control: Control = node as Control
		if _is_focusable(control):
			return control
	for child: Node in node.get_children():
		var candidate: Control = _find_first_focusable(child)
		if is_instance_valid(candidate):
			return candidate
	return null


static func _is_focusable(control: Control) -> bool:
	if not is_instance_valid(control):
		return false
	if not control.is_inside_tree():
		return false
	if not control.is_visible_in_tree():
		return false
	if control.focus_mode == Control.FOCUS_NONE:
		return false
	if control is BaseButton and (control as BaseButton).disabled:
		return false
	if control is LineEdit and not (control as LineEdit).editable:
		return false
	return true
