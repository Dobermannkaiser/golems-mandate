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
	_ensure_control_visible_deferred(control)


static func restore_focus_deferred(
	control: Control,
	fallback_root: Node = null,
	fallback: Control = null
) -> void:
	if is_instance_valid(fallback_root):
		if is_focus_within(fallback_root, control) and _is_focusable(control):
			focus_deferred(control)
			return
		focus_first_enabled(fallback_root, fallback)
		return
	if _is_focusable(control):
		focus_deferred(control)


static func restore_focus_within_deferred(
	root: Node,
	preferred: Control = null
) -> void:
	if is_focus_within(root, preferred) and _is_focusable(preferred):
		focus_deferred(preferred)
		return
	focus_first_enabled(root)


static func focus_first_enabled(
	root: Node,
	preferred: Control = null
) -> void:
	if _is_focusable(preferred):
		focus_deferred(preferred)
		return
	var candidate: Control = _find_first_focusable(root)
	if is_instance_valid(candidate):
		focus_deferred(candidate)


static func focus_edge(
	root: Node,
	reverse: bool = false,
	deferred: bool = false
) -> Control:
	var candidate: Control = (
		_find_last_focusable(root)
		if reverse
		else _find_first_focusable(root)
	)
	if not is_instance_valid(candidate):
		return null
	if deferred:
		focus_deferred(candidate)
	else:
		focus_control(candidate)
	return candidate


static func focus_control(control: Control) -> Control:
	if not _is_focusable(control):
		return null
	control.grab_focus()
	_ensure_control_visible(control)
	_ensure_control_visible_deferred(control)
	return control


static func get_focusable_controls(root: Node) -> Array[Control]:
	var controls: Array[Control] = []
	_collect_focusable_controls(root, controls)
	return controls


static func focus_relative(
	root: Node,
	current: Control,
	reverse: bool = false
) -> Control:
	var controls: Array[Control] = get_focusable_controls(root)
	if controls.is_empty():
		return null
	var current_index: int = controls.find(current)
	if current_index < 0:
		return focus_control(controls.back() if reverse else controls[0])
	var step: int = -1 if reverse else 1
	var target_index: int = (
		current_index + step + controls.size()
	) % controls.size()
	return focus_control(controls[target_index])


static func focus_directional(
	root: Node,
	current: Control,
	side: int
) -> Control:
	var controls: Array[Control] = get_focusable_controls(root)
	if controls.is_empty():
		return null
	if not is_focus_within(root, current) or not _is_focusable(current):
		return focus_control(controls[0])

	var explicit_target: Control = _get_explicit_focus_neighbor(
		root,
		current,
		side
	)
	if is_instance_valid(explicit_target):
		return focus_control(explicit_target)

	var current_center: Vector2 = current.get_global_rect().get_center()
	var best_target: Control
	var best_score: float = INF
	for candidate: Control in controls:
		if candidate == current:
			continue
		var delta: Vector2 = (
			candidate.get_global_rect().get_center() - current_center
		)
		var primary_distance: float = 0.0
		var secondary_distance: float = 0.0
		match side:
			SIDE_TOP:
				if delta.y >= -0.5:
					continue
				primary_distance = -delta.y
				secondary_distance = absf(delta.x)
			SIDE_BOTTOM:
				if delta.y <= 0.5:
					continue
				primary_distance = delta.y
				secondary_distance = absf(delta.x)
			SIDE_LEFT:
				if delta.x >= -0.5:
					continue
				primary_distance = -delta.x
				secondary_distance = absf(delta.y)
			SIDE_RIGHT:
				if delta.x <= 0.5:
					continue
				primary_distance = delta.x
				secondary_distance = absf(delta.y)
			_:
				return null
		var score: float = primary_distance * 4.0 + secondary_distance
		if score < best_score:
			best_score = score
			best_target = candidate

	if is_instance_valid(best_target):
		return focus_control(best_target)
	return focus_relative(
		root,
		current,
		side == SIDE_TOP or side == SIDE_LEFT
	)


static func should_control_handle_direction(
	control: Control,
	side: int
) -> bool:
	if control is LineEdit or control is TextEdit:
		return true
	if control is OptionButton:
		return (control as OptionButton).get_popup().visible
	if control is RichTextLabel:
		var rich_text: RichTextLabel = control as RichTextLabel
		var scroll_bar: VScrollBar = rich_text.get_v_scroll_bar()
		if not is_instance_valid(scroll_bar):
			return false
		if side == SIDE_TOP:
			return scroll_bar.value > scroll_bar.min_value + 0.5
		if side == SIDE_BOTTOM:
			return (
				scroll_bar.value
				< scroll_bar.max_value - scroll_bar.page - 0.5
			)
	return false


static func is_focus_within(root: Node, control: Control) -> bool:
	if not is_instance_valid(root) or not is_instance_valid(control):
		return false
	return root == control or root.is_ancestor_of(control)


static func is_focusable(control: Control) -> bool:
	return _is_focusable(control)


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


static func _collect_focusable_controls(
	node: Node,
	result: Array[Control]
) -> void:
	if not is_instance_valid(node):
		return
	if node is Control and _is_focusable(node as Control):
		result.append(node as Control)
	for child: Node in node.get_children():
		_collect_focusable_controls(child, result)


static func _find_last_focusable(node: Node) -> Control:
	if not is_instance_valid(node):
		return null
	var children: Array[Node] = node.get_children()
	for child_index: int in range(children.size() - 1, -1, -1):
		var candidate: Control = _find_last_focusable(children[child_index])
		if is_instance_valid(candidate):
			return candidate
	if node is Control:
		var control: Control = node as Control
		if _is_focusable(control):
			return control
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
	if control is TextEdit and not (control as TextEdit).editable:
		return false
	if control is RichTextLabel:
		var rich_text: RichTextLabel = control as RichTextLabel
		if not rich_text.scroll_active:
			return false
		var scroll_bar: VScrollBar = rich_text.get_v_scroll_bar()
		if not is_instance_valid(scroll_bar):
			return false
		if scroll_bar.max_value <= scroll_bar.page + 0.5:
			return false
	return true


static func _get_explicit_focus_neighbor(
	root: Node,
	control: Control,
	side: int
) -> Control:
	var neighbor_path: NodePath = control.get_focus_neighbor(side)
	if neighbor_path.is_empty():
		return null
	var candidate: Control = control.get_node_or_null(neighbor_path) as Control
	if not is_focus_within(root, candidate) or not _is_focusable(candidate):
		return null
	return candidate


static func _ensure_control_visible_deferred(control: Control) -> void:
	if not is_instance_valid(control):
		return
	var ancestor: Node = control.get_parent()
	while is_instance_valid(ancestor):
		if ancestor is ScrollContainer:
			(ancestor as ScrollContainer).call_deferred(
				"ensure_control_visible",
				control
			)
		ancestor = ancestor.get_parent()


static func _ensure_control_visible(control: Control) -> void:
	if not is_instance_valid(control):
		return
	var ancestor: Node = control.get_parent()
	while is_instance_valid(ancestor):
		if ancestor is ScrollContainer:
			(ancestor as ScrollContainer).ensure_control_visible(control)
		ancestor = ancestor.get_parent()
