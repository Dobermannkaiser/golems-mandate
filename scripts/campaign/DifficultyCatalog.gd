class_name VillageDifficultyCatalog
extends RefCounted


const DEFAULT_DIFFICULTY_ID: String = "moderate"
const DIFFICULTY_IDS: Array[String] = ["cozy", "moderate", "hard"]

const DIFFICULTIES: Dictionary = {
	"cozy": {
		"id": "cozy",
		"display_name": "Acolhedora",
		"description": "Metas menores, crescimento populacional mais rápido, reservas iniciais maiores e quatro dias de tolerância a crises.",
		"production_multiplier": 1.0,
		"food_consumption_multiplier": 1.0,
		"maintenance_multiplier": 1.0,
		"happiness_decay_multiplier": 1.0,
		"building_cost_multiplier": 1.0,
		"food_target_multiplier": 0.80,
		"material_target_multiplier": 0.80,
		"population_target_multiplier": 1.0,
		"population_target_offset": -1,
		"happiness_target_offset": -8.0,
		"growth_minimum_happiness": 52.0,
		"attraction_target": 1,
		"abandonment_target": 4,
		"initial_food": 48.0,
		"initial_material": 22.0,
		"initial_happiness": 72.0,
		"crisis_grace_days": 4,
		"post_crisis_happiness_recovery": 2.0,
		"event_window_day_adjustment": 2,
		"guidance_level": "explicit"
	},
	"moderate": {
		"id": "moderate",
		"display_name": "Moderada",
		"description": "Metas populacionais reduzidas, crescimento regular e o ritmo principal de reservas, recuperação e narrativa.",
		"production_multiplier": 1.0,
		"food_consumption_multiplier": 1.0,
		"maintenance_multiplier": 1.0,
		"happiness_decay_multiplier": 1.0,
		"building_cost_multiplier": 1.0,
		"food_target_multiplier": 1.0,
		"material_target_multiplier": 1.0,
		"population_target_multiplier": 1.0,
		"population_target_offset": 0,
		"happiness_target_offset": 0.0,
		"growth_minimum_happiness": 55.0,
		"attraction_target": 2,
		"abandonment_target": 3,
		"initial_food": 34.0,
		"initial_material": 12.0,
		"initial_happiness": 62.0,
		"crisis_grace_days": 2,
		"post_crisis_happiness_recovery": 0.5,
		"event_window_day_adjustment": 0,
		"guidance_level": "complete"
	},
	"hard": {
		"id": "hard",
		"display_name": "Difícil",
		"description": "Metas ainda maiores, crescimento mais exigente, reservas menores e recuperação lenta; nenhuma informação é escondida.",
		"production_multiplier": 1.0,
		"food_consumption_multiplier": 1.0,
		"maintenance_multiplier": 1.0,
		"happiness_decay_multiplier": 1.0,
		"building_cost_multiplier": 1.0,
		"food_target_multiplier": 1.08,
		"material_target_multiplier": 1.05,
		"population_target_multiplier": 1.05,
		"population_target_offset": 0,
		"happiness_target_offset": 2.0,
		"growth_minimum_happiness": 58.0,
		"attraction_target": 2,
		"abandonment_target": 2,
		"initial_food": 30.0,
		"initial_material": 10.0,
		"initial_happiness": 60.0,
		"crisis_grace_days": 2,
		"post_crisis_happiness_recovery": 0.0,
		"event_window_day_adjustment": -1,
		"guidance_level": "complete"
	}
}


static func sanitize_difficulty_id(value: String) -> String:
	return value if DIFFICULTY_IDS.has(value) else DEFAULT_DIFFICULTY_ID


static func get_difficulty(value: String) -> Dictionary:
	var difficulty_id: String = sanitize_difficulty_id(value)
	return (DIFFICULTIES[difficulty_id] as Dictionary).duplicate(true)


static func get_display_name(value: String) -> String:
	return String(get_difficulty(value).get("display_name", "Moderada"))


static func get_effects_summary(value: String) -> String:
	var difficulty: Dictionary = get_difficulty(value)
	return String(difficulty.get("description", ""))


static func apply_checkpoint_targets(base_targets: Dictionary, difficulty_id: String) -> Dictionary:
	var rules: Dictionary = get_difficulty(difficulty_id)
	return {
		"food": roundf(float(base_targets.get("food", 0.0)) * float(rules.get("food_target_multiplier", 1.0))),
		"material": roundf(float(base_targets.get("material", 0.0)) * float(rules.get("material_target_multiplier", 1.0))),
		"happiness": clampf(
			float(base_targets.get("happiness", 0.0)) + float(rules.get("happiness_target_offset", 0.0)),
			0.0,
			100.0
		),
		"population": maxi(
			1,
			ceili(
				float(base_targets.get("population", 1))
				* float(rules.get("population_target_multiplier", 1.0))
			)
			+ int(rules.get("population_target_offset", 0))
		)
	}
