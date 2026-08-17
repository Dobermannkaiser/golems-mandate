extends Node


const BuildingManagerScript = preload("res://scripts/buildings/BuildingManager.gd")


func _ready() -> void:
	var source = BuildingManagerScript.new()
	source.setup()
	var request: Dictionary = source.request_construction(
		"housing",
		100.0,
		7
	)
	var exported: Dictionary = source.export_save_data()
	var orders: Array = exported.get("construction_orders", []) as Array
	var saved_order: Dictionary = {}
	if orders.size() == 1 and orders[0] is Dictionary:
		saved_order = orders[0] as Dictionary

	var direct_restored = BuildingManagerScript.new()
	direct_restored.setup()
	var direct_import_ok: bool = direct_restored.import_save_data(exported)

	var serialized: String = JSON.stringify(exported)
	var parsed_value: Variant = JSON.parse_string(serialized)
	var json_restored = BuildingManagerScript.new()
	json_restored.setup()
	var json_import_ok: bool = (
		parsed_value is Dictionary
		and json_restored.import_save_data(parsed_value as Dictionary)
	)

	var passed: bool = (
		bool(request.get("queued", false))
		and bool(request.get("is_housing", false))
		and int(request.get("target_level", -1)) == 3
		and source.get_queued_order_count() == 1
		and bool(saved_order.get("is_housing", false))
		and String(saved_order.get("variant_id", "")).is_empty()
		and direct_import_ok
		and direct_restored.get_queued_order_count() == 1
		and json_import_ok
		and json_restored.get_queued_order_count() == 1
	)
	if passed:
		print("BUILDING_QUEUE_ROUNDTRIP_OK")
	else:
		print(
			"BUILDING_QUEUE_ROUNDTRIP_FAILED queued=%s housing=%s target=%d source_orders=%d direct=%s direct_orders=%d json=%s json_orders=%d"
			% [
				request.get("queued", false),
				request.get("is_housing", false),
				int(request.get("target_level", -1)),
				source.get_queued_order_count(),
				direct_import_ok,
				direct_restored.get_queued_order_count(),
				json_import_ok,
				json_restored.get_queued_order_count()
			]
		)
