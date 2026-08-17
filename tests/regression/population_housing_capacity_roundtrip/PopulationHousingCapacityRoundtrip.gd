extends Node


const PopulationStateScript = preload("res://scripts/models/PopulationState.gd")


func _ready() -> void:
	var invalid_eleven: Dictionary = _run_case(
		11,
		false,
		PopulationStateScript.INITIAL_HOUSING_CAPACITY
	)
	var valid_fifteen: Dictionary = _run_case(15, true, 15)
	var invalid_fourteen: Dictionary = _run_case(
		14,
		false,
		PopulationStateScript.INITIAL_HOUSING_CAPACITY
	)
	var valid_maximum: Dictionary = _run_case(
		PopulationStateScript.MAX_SAFE_POPULATION,
		true,
		PopulationStateScript.MAX_SAFE_POPULATION
	)
	var passed: bool = (
		bool(invalid_eleven.get("passed", false))
		and bool(valid_fifteen.get("passed", false))
		and bool(invalid_fourteen.get("passed", false))
		and bool(valid_maximum.get("passed", false))
	)
	if passed:
		print("POPULATION_ROUNDTRIP_OK")
	else:
		print(
			"POPULATION_ROUNDTRIP_FAILED invalid11=%s valid15=%s invalid14=%s maximum=%s"
			% [
				invalid_eleven,
				valid_fifteen,
				invalid_fourteen,
				valid_maximum
			]
		)


func _run_case(
	requested_capacity: int,
	expected_accepted: bool,
	expected_capacity: int
) -> Dictionary:
	var source = PopulationStateScript.new()
	source.setup()
	var accepted: bool = source.set_housing_capacity(requested_capacity)
	var exported: Dictionary = source.export_save_data()
	var restored = PopulationStateScript.new()
	restored.setup()
	var import_ok: bool = restored.import_save_data(exported)
	return {
		"passed": (
			accepted == expected_accepted
			and int(exported.get("housing_capacity", -1)) == expected_capacity
			and import_ok
			and restored.housing_capacity == expected_capacity
		),
		"accepted": accepted,
		"exported_capacity": int(exported.get("housing_capacity", -1)),
		"import_ok": import_ok,
		"restored_capacity": restored.housing_capacity
	}
