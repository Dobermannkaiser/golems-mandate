extends Control

const BUILDING_VISUALS_SCRIPT := preload("res://scripts/ui/BuildingVisuals.gd")
const SAMPLE_FRAMES := 24

var _failures: Array[String] = []
var _visuals: Control


func _ready() -> void:
	var original_reduced_motion: bool = GameSettings.reduced_motion
	GameSettings.reduced_motion = false

	await _run_regression()

	if is_instance_valid(_visuals):
		_visuals.call("set_simulation_active", false)
	GameSettings.reduced_motion = original_reduced_motion

	if _failures.is_empty():
		print("REDUCED_MOTION_REGRESSION_OK")
	else:
		push_error("REDUCED_MOTION_REGRESSION_FAILED: %s" % " | ".join(_failures))


func _run_regression() -> void:
	_visuals = BUILDING_VISUALS_SCRIPT.new()
	add_child(_visuals)
	_visuals.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	await get_tree().process_frame

	_visuals.call("update_population_overview", {
		"total_population": 5,
		"housing_capacity": 10,
		"common_population": 4,
		"protected_named_resident_count": 1,
		"happiness": 72.0,
	})
	await get_tree().process_frame

	var villagers: Array = _visuals.get("common_villager_nodes")
	_check(villagers.size() == 3, "a fixture deveria criar exatamente 3 aldeões visuais")
	var normal_before := _capture_positions(villagers)
	await _wait_frames(12)
	var normal_after := _capture_positions(villagers)
	_check(not _positions_equal(normal_before, normal_after), "movimento normal não avançou antes da alternância")
	var normal_tween_ids := _capture_tween_ids()
	_refresh_motion_setting()
	_check(
		normal_tween_ids == _capture_tween_ids(),
		"reaplicar a mesma preferência reiniciou os tweens normais"
	)

	GameSettings.reduced_motion = true
	_refresh_motion_setting()
	var reduced_start := _capture_positions(villagers)
	var reduced_measurement := await _sample_motion(villagers, SAMPLE_FRAMES)
	print(
		"REDUCED_MOTION_MEASUREMENT frames=%d distinct_tweens=%d active_end=%d position_changes=%d"
		% [
			SAMPLE_FRAMES,
			reduced_measurement["distinct_tweens"],
			reduced_measurement["active_end"],
			reduced_measurement["position_changes"],
		]
	)
	_check(reduced_measurement["distinct_tweens"] == 0, "movimento reduzido ainda cria/recria tweens")
	_check(reduced_measurement["active_end"] == 0, "movimento reduzido deixou tweens ativos")
	_check(reduced_measurement["position_changes"] == 0, "aldeões se moveram durante movimento reduzido")
	_check(_villagers_are_valid_and_deterministic(villagers), "posições reduzidas não são válidas/determinísticas")

	_refresh_motion_setting()
	await _wait_frames(3)
	_check(
		_positions_equal(reduced_start, _capture_positions(villagers)),
		"reaplicar movimento reduzido alterou as posições determinísticas"
	)

	GameSettings.reduced_motion = false
	_refresh_motion_setting()
	var restored_before := _capture_positions(villagers)
	await _wait_frames(12)
	var restored_after := _capture_positions(villagers)
	var restored_tweens: Dictionary = _visuals.get("villager_tweens")
	_check(restored_tweens.size() == villagers.size(), "desativar movimento reduzido não restaurou os tweens normais")
	_check(not _positions_equal(restored_before, restored_after), "desativar movimento reduzido não restaurou o movimento")

	GameSettings.reduced_motion = true
	_refresh_motion_setting()
	var immediate_tweens: Dictionary = _visuals.get("villager_tweens")
	_check(immediate_tweens.is_empty(), "ativar movimento reduzido não interrompeu tweens imediatamente")

	_visuals.call("set_simulation_active", false)
	_visuals.call("set_simulation_active", true)
	var reopened_tweens: Dictionary = _visuals.get("villager_tweens")
	_check(reopened_tweens.is_empty(), "reativar a simulação em movimento reduzido criou tweens órfãos")

	_visuals.call("set_large_view_enabled", true)
	var expanded_tweens: Dictionary = _visuals.get("villager_tweens")
	_check(expanded_tweens.is_empty(), "ampliar a interface em movimento reduzido criou tweens")
	_check(_villagers_are_valid_and_deterministic(villagers), "ampliar a interface invalidou posições reduzidas")
	_visuals.call("set_large_view_enabled", false)

	_visuals.call("update_population_overview", {
		"total_population": 7,
		"housing_capacity": 12,
		"common_population": 6,
		"protected_named_resident_count": 1,
		"happiness": 72.0,
	})
	await get_tree().process_frame
	villagers = _visuals.get("common_villager_nodes")
	_check(villagers.size() == 4, "atualizar o estado da campanha deveria reconstruir 4 aldeões visuais")
	var rebuilt_measurement := await _sample_motion(villagers, 8)
	_check(rebuilt_measurement["distinct_tweens"] == 0, "reconstruir aldeões em movimento reduzido criou tweens")
	_check(rebuilt_measurement["active_end"] == 0, "reconstruir aldeões deixou tweens ativos")
	_check(rebuilt_measurement["position_changes"] == 0, "reconstruir aldeões deixou movimento residual")
	_check(_villagers_are_valid_and_deterministic(villagers), "reconstruir aldeões gerou posições incorretas")


func _refresh_motion_setting() -> void:
	if _visuals.has_method("refresh_motion_setting"):
		_visuals.call("refresh_motion_setting")
	else:
		_visuals.call("_restart_common_villager_routes")


func _sample_motion(villagers: Array, frame_count: int) -> Dictionary:
	var seen_tweens: Dictionary = {}
	var position_changes := 0
	var previous_positions := _capture_positions(villagers)
	for _frame_index in range(frame_count):
		var tweens: Dictionary = _visuals.get("villager_tweens")
		for tween_value: Variant in tweens.values():
			if is_instance_valid(tween_value):
				seen_tweens[tween_value.get_instance_id()] = true
		await get_tree().process_frame
		var current_positions := _capture_positions(villagers)
		for index in range(mini(previous_positions.size(), current_positions.size())):
			if not previous_positions[index].is_equal_approx(current_positions[index]):
				position_changes += 1
		previous_positions = current_positions
	var active_tweens: Dictionary = _visuals.get("villager_tweens")
	return {
		"distinct_tweens": seen_tweens.size(),
		"active_end": active_tweens.size(),
		"position_changes": position_changes,
	}


func _villagers_are_valid_and_deterministic(villagers: Array) -> bool:
	var map_rect: Rect2 = _visuals.call("_get_map_rect")
	for index in range(villagers.size()):
		var villager: Control = villagers[index]
		if not is_instance_valid(villager):
			return false
		if int(villager.get_meta("route_index", -1)) != index:
			return false
		var center := villager.position + villager.size * 0.5
		if not map_rect.grow(0.5).has_point(center):
			return false
	return true


func _capture_positions(villagers: Array) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	for villager_value: Variant in villagers:
		var villager := villager_value as Control
		if is_instance_valid(villager):
			positions.append(villager.position)
	return positions


func _capture_tween_ids() -> Array[int]:
	var tween_ids: Array[int] = []
	var tweens: Dictionary = _visuals.get("villager_tweens")
	for tween_value: Variant in tweens.values():
		if is_instance_valid(tween_value):
			tween_ids.append(tween_value.get_instance_id())
	tween_ids.sort()
	return tween_ids


func _positions_equal(first: Array[Vector2], second: Array[Vector2]) -> bool:
	if first.size() != second.size():
		return false
	for index in range(first.size()):
		if not first[index].is_equal_approx(second[index]):
			return false
	return true


func _wait_frames(frame_count: int) -> void:
	for _frame_index in range(frame_count):
		await get_tree().process_frame


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
