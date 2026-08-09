class_name VillagePopulationState
extends RefCounted


const INITIAL_POPULATION: int = 8
const INITIAL_HOUSING_CAPACITY: int = 10
const ACTIVE_COUNCIL_COUNT: int = 4
const INITIAL_PROTECTED_NAMED_RESIDENT_COUNT: int = 5
const ATTRACTION_TARGET: int = 2
const ABANDONMENT_TARGET: int = 3
const MAX_SAFE_POPULATION: int = 100000


var total_population: int = INITIAL_POPULATION
var housing_capacity: int = INITIAL_HOUSING_CAPACITY
var protected_named_resident_count: int = (
	INITIAL_PROTECTED_NAMED_RESIDENT_COUNT
)
var attraction_progress: int = 0
var concerning_day_streak: int = 0
var last_population_status: String = "stable"
var attraction_target: int = ATTRACTION_TARGET
var abandonment_target: int = ABANDONMENT_TARGET
var last_population_reason: String = (
	"A comunidade está começando a se organizar."
)


func setup() -> void:
	total_population = INITIAL_POPULATION
	housing_capacity = INITIAL_HOUSING_CAPACITY
	protected_named_resident_count = (
		INITIAL_PROTECTED_NAMED_RESIDENT_COUNT
	)
	attraction_progress = 0
	concerning_day_streak = 0
	attraction_target = ATTRACTION_TARGET
	abandonment_target = ABANDONMENT_TARGET
	last_population_status = "stable"
	last_population_reason = (
		"A comunidade está começando a se organizar."
	)


func export_save_data() -> Dictionary:
	return {
		"total_population": total_population,
		"housing_capacity": housing_capacity,
		"representative_count": ACTIVE_COUNCIL_COUNT,
		"protected_named_resident_count": (
			protected_named_resident_count
		),
		"common_population": get_common_population(),
		"available_housing": get_available_housing(),
		"is_over_capacity": is_over_capacity(),
		"attraction_progress": attraction_progress,
		"attraction_target": attraction_target,
		"concerning_day_streak": concerning_day_streak,
		"abandonment_target": abandonment_target,
		"last_population_status": last_population_status,
		"last_population_reason": last_population_reason
	}


func import_save_data(save_data: Dictionary) -> bool:
	if (
		not save_data.has("total_population")
		or not save_data.has("housing_capacity")
		or not save_data.has("attraction_progress")
		or not save_data.has("concerning_day_streak")
	):
		return false

	var saved_population: int = int(
		save_data.get(
			"total_population",
			INITIAL_POPULATION
		)
	)

	var saved_capacity: int = int(
		save_data.get(
			"housing_capacity",
			INITIAL_HOUSING_CAPACITY
		)
	)
	var saved_attraction: int = int(
		save_data.get(
			"attraction_progress",
			0
		)
	)
	var saved_concerning_streak: int = int(
		save_data.get(
			"concerning_day_streak",
			0
		)
	)
	var saved_attraction_target: int = clampi(int(save_data.get("attraction_target", ATTRACTION_TARGET)), 1, 8)
	var saved_abandonment_target: int = clampi(int(save_data.get("abandonment_target", ABANDONMENT_TARGET)), 1, 8)
	var saved_protected_count: int = int(
		save_data.get(
			"protected_named_resident_count",
			INITIAL_PROTECTED_NAMED_RESIDENT_COUNT
		)
	)

	if (
		saved_protected_count < ACTIVE_COUNCIL_COUNT
		or saved_protected_count > saved_population
		or saved_population > MAX_SAFE_POPULATION
		or saved_capacity < INITIAL_HOUSING_CAPACITY
		or saved_capacity > MAX_SAFE_POPULATION
		or saved_capacity % 5 != 0
		or saved_attraction < 0
		or saved_attraction >= saved_attraction_target
		or saved_concerning_streak < 0
		or saved_concerning_streak >= saved_abandonment_target
	):
		return false

	total_population = saved_population
	housing_capacity = saved_capacity
	protected_named_resident_count = saved_protected_count
	attraction_progress = saved_attraction
	concerning_day_streak = saved_concerning_streak
	attraction_target = saved_attraction_target
	abandonment_target = saved_abandonment_target
	last_population_status = String(
		save_data.get(
			"last_population_status",
			"stable"
		)
	)
	last_population_reason = String(
		save_data.get(
			"last_population_reason",
			"A comunidade está estável."
		)
	)
	return true


func configure_difficulty(new_attraction_target: int, new_abandonment_target: int) -> void:
	attraction_target = clampi(new_attraction_target, 1, 8)
	abandonment_target = clampi(new_abandonment_target, 1, 8)
	attraction_progress = mini(attraction_progress, attraction_target - 1)
	concerning_day_streak = mini(concerning_day_streak, abandonment_target - 1)


func add_named_story_resident() -> bool:
	if total_population >= MAX_SAFE_POPULATION:
		return false
	total_population += 1
	protected_named_resident_count += 1
	attraction_progress = 0
	concerning_day_streak = 0
	return true


func apply_story_population_delta(delta: int) -> int:
	if delta == 0:
		return 0

	var old_population: int = total_population
	if delta > 0:
		total_population = mini(housing_capacity, total_population + delta)
	else:
		total_population = maxi(
			protected_named_resident_count,
			total_population + delta
		)

	if total_population != old_population:
		attraction_progress = 0
		concerning_day_streak = 0

	return total_population - old_population


func apply_daily_conditions(
	is_favorable: bool,
	is_concerning: bool,
	status: String,
	reason: String
) -> Dictionary:
	var old_population: int = total_population
	var movement: String = "none"

	last_population_status = status
	last_population_reason = reason

	if is_concerning:
		concerning_day_streak += 1

		if concerning_day_streak >= abandonment_target:
			concerning_day_streak = 0

			if total_population > protected_named_resident_count:
				total_population -= 1
				attraction_progress = 0
				movement = "departure"
	else:
		concerning_day_streak = 0

		if is_favorable and get_available_housing() > 0:
			attraction_progress += 1

			if attraction_progress >= attraction_target:
				attraction_progress = 0
				total_population += 1
				movement = "arrival"

	return {
		"movement": movement,
		"old_population": old_population,
		"new_population": total_population,
		"population_changed": old_population != total_population,
		"status": last_population_status,
		"reason": last_population_reason,
		"attraction_progress": attraction_progress,
		"concerning_day_streak": concerning_day_streak
	}


func set_protected_named_resident_count(new_count: int) -> bool:
	if (
		new_count < ACTIVE_COUNCIL_COUNT
		or new_count > total_population
	):
		return false

	protected_named_resident_count = new_count
	return true


func set_housing_capacity(new_capacity: int) -> bool:
	if (
		new_capacity < INITIAL_HOUSING_CAPACITY
		or new_capacity > MAX_SAFE_POPULATION
	):
		return false

	housing_capacity = new_capacity
	return true


func get_common_population() -> int:
	return maxi(
		0,
		total_population - ACTIVE_COUNCIL_COUNT
	)


func get_available_housing() -> int:
	return maxi(
		0,
		housing_capacity - total_population
	)


func is_over_capacity() -> bool:
	return total_population > housing_capacity
