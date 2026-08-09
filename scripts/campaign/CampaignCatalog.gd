class_name VillageCampaignCatalog
extends RefCounted


const CATALOG_VERSION: int = 4
const SUPPORTED_CATALOG_VERSIONS: Array[int] = [4]
const CAMPAIGN_TOTAL_DAYS: int = 120
const SEASON_LENGTH_DAYS: int = 30
const CHECKPOINT_INTERVAL_DAYS: int = 20
const SEASON_HINT_DAYS_REMAINING: int = 10
const FREE_PLAY_ENABLED: bool = true

const SEASON_SPRING: String = "spring"
const SEASON_SUMMER: String = "summer"
const SEASON_AUTUMN: String = "autumn"
const SEASON_WINTER: String = "winter"

const SEASONS: Array[Dictionary] = [
	{
		"id": SEASON_SPRING,
		"display_name": "Primavera",
		"start_day": 1,
		"end_day": 30,
		"order": 0,
		"modifiers": {
			"food_production_multiplier": 1.10,
			"material_production_multiplier": 1.0,
			"food_consumption_multiplier": 1.0,
			"material_maintenance_multiplier": 1.10,
			"happiness_decay_multiplier": 1.0
		},
		"effects_text": (
			"+10% na produção de alimentação e "
			+ "+10% na manutenção de material."
		),
		"transition_hint": (
			"A Primavera favorece agricultores e coletores, "
			+ "mas as chuvas aumentam o desgaste da vila. "
			+ "Produza material antes da troca."
		)
	},
	{
		"id": SEASON_SUMMER,
		"display_name": "Verão",
		"start_day": 31,
		"end_day": 60,
		"order": 1,
		"modifiers": {
			"food_production_multiplier": 1.20,
			"material_production_multiplier": 1.0,
			"food_consumption_multiplier": 1.0,
			"material_maintenance_multiplier": 1.0,
			"happiness_decay_multiplier": 1.10
		},
		"effects_text": (
			"+20% na produção de alimentação e "
			+ "+10% na redução diária de felicidade."
		),
		"transition_hint": (
			"O Verão traz a melhor produção de alimentação, "
			+ "mas o calor desgasta o ânimo. Aproveite a "
			+ "colheita e mantenha alguém produzindo felicidade."
		)
	},
	{
		"id": SEASON_AUTUMN,
		"display_name": "Outono",
		"start_day": 61,
		"end_day": 90,
		"order": 2,
		"modifiers": {
			"food_production_multiplier": 1.10,
			"material_production_multiplier": 1.15,
			"food_consumption_multiplier": 1.0,
			"material_maintenance_multiplier": 1.0,
			"happiness_decay_multiplier": 1.0
		},
		"effects_text": (
			"+10% na produção de alimentação e "
			+ "+15% na produção de material."
		),
		"transition_hint": (
			"O Outono fortalece alimentação e material ao "
			+ "mesmo tempo. Use essa estação para criar as "
			+ "reservas que protegerão a vila no Inverno."
		)
	},
	{
		"id": SEASON_WINTER,
		"display_name": "Inverno",
		"start_day": 91,
		"end_day": 120,
		"order": 3,
		"modifiers": {
			"food_production_multiplier": 0.90,
			"material_production_multiplier": 1.0,
			"food_consumption_multiplier": 1.10,
			"material_maintenance_multiplier": 1.0,
			"happiness_decay_multiplier": 1.0
		},
		"effects_text": (
			"-10% na produção de alimentação e "
			+ "+10% no consumo de alimentação."
		),
		"transition_hint": (
			"O Inverno reduz levemente a produção e aumenta o consumo "
			+ "de alimentação. Entre nele com reservas altas "
			+ "e não dependa apenas dos agricultores."
		)
	}
]

const CHECKPOINT_DAYS: Array[int] = [
	20,
	40,
	60,
	80,
	100,
	120
]

# Vinte e quatro metas finais: alimentação, material, felicidade e população
# em cada uma das seis avaliações obrigatórias. Os valores abaixo são a base
# Moderada; DifficultyCatalog aplica os ajustes Acolhedora e Difícil.
const CHECKPOINTS: Array[Dictionary] = [
	{
		"id": "checkpoint_01",
		"chapter_id": "capitulo_01",
		"day": 20,
		"targets": {
			"food": 50.0,
			"material": 22.0,
			"happiness": 53.0,
			"population": 10
		},
		"balance_status": "final",
		"main_event_id": "",
		"arrival_npc_id": ""
	},
	{
		"id": "checkpoint_02",
		"chapter_id": "capitulo_02",
		"day": 40,
		"targets": {
			"food": 75.0,
			"material": 38.0,
			"happiness": 55.0,
			"population": 13
		},
		"balance_status": "final",
		"main_event_id": "",
		"arrival_npc_id": ""
	},
	{
		"id": "checkpoint_03",
		"chapter_id": "capitulo_03",
		"day": 60,
		"targets": {
			"food": 105.0,
			"material": 55.0,
			"happiness": 57.0,
			"population": 17
		},
		"balance_status": "final",
		"main_event_id": "",
		"arrival_npc_id": ""
	},
	{
		"id": "checkpoint_04",
		"chapter_id": "capitulo_04",
		"day": 80,
		"targets": {
			"food": 135.0,
			"material": 72.0,
			"happiness": 58.0,
			"population": 21
		},
		"balance_status": "final",
		"main_event_id": "",
		"arrival_npc_id": ""
	},
	{
		"id": "checkpoint_05",
		"chapter_id": "capitulo_05",
		"day": 100,
		"targets": {
			"food": 165.0,
			"material": 82.0,
			"happiness": 55.0,
			"population": 25
		},
		"balance_status": "final",
		"main_event_id": "",
		"arrival_npc_id": ""
	},
	{
		"id": "checkpoint_06",
		"chapter_id": "capitulo_06",
		"day": 120,
		"targets": {
			"food": 200.0,
			"material": 98.0,
			"happiness": 54.0,
			"population": 29
		},
		"balance_status": "final",
		"main_event_id": "",
		"arrival_npc_id": ""
	}
]


static func get_season_for_day(day: int) -> Dictionary:
	var positive_day: int = maxi(1, day)
	var cycle_day: int = (
		(positive_day - 1) % CAMPAIGN_TOTAL_DAYS
	) + 1
	var season_index: int = floori(
		float(cycle_day - 1)
		/ float(SEASON_LENGTH_DAYS)
	)

	return SEASONS[season_index].duplicate(true)


static func get_day_in_season(day: int) -> int:
	var positive_day: int = maxi(1, day)
	var cycle_day: int = (
		(positive_day - 1) % CAMPAIGN_TOTAL_DAYS
	) + 1

	return (
		(cycle_day - 1) % SEASON_LENGTH_DAYS
	) + 1


static func get_season_cycle(day: int) -> int:
	return floori(
		float(maxi(1, day) - 1)
		/ float(CAMPAIGN_TOTAL_DAYS)
	)


static func get_days_until_season_change(day: int) -> int:
	return (
		SEASON_LENGTH_DAYS
		- get_day_in_season(day)
		+ 1
	)


static func get_season_modifiers_for_day(
	day: int
) -> Dictionary:
	var season: Dictionary = get_season_for_day(day)
	var modifiers: Dictionary = season.get(
		"modifiers",
		{}
	)
	return modifiers.duplicate(true)


static func get_season_transition_hint_after_day(
	completed_day: int
) -> Dictionary:
	if (
		get_day_in_season(completed_day)
		!= SEASON_LENGTH_DAYS - SEASON_HINT_DAYS_REMAINING
	):
		return {}

	var transition_day: int = (
		completed_day
		+ SEASON_HINT_DAYS_REMAINING
		+ 1
	)
	var upcoming_season: Dictionary = (
		get_season_for_day(transition_day)
	)
	var season_id: String = String(
		upcoming_season.get("id", "")
	)

	return {
		"id": (
			"%d:%s"
			% [
				get_season_cycle(transition_day),
				season_id
			]
		),
		"season_id": season_id,
		"season_name": String(
			upcoming_season.get(
				"display_name",
				"Próxima estação"
			)
		),
		"days_remaining": SEASON_HINT_DAYS_REMAINING,
		"title": (
			"%s CHEGA EM %d DIAS"
			% [
				String(
					upcoming_season.get(
						"display_name",
						"Nova estação"
					)
				).to_upper(),
				SEASON_HINT_DAYS_REMAINING
			]
		),
		"effects_text": String(
			upcoming_season.get("effects_text", "")
		),
		"tip_text": String(
			upcoming_season.get(
				"transition_hint",
				"Prepare suas reservas para a mudança."
			)
		)
	}


static func get_checkpoint_for_day(day: int) -> Dictionary:
	for checkpoint: Dictionary in CHECKPOINTS:
		if int(checkpoint.get("day", 0)) == day:
			return checkpoint.duplicate(true)

	return {}


static func get_next_checkpoint(
	completed_days: int
) -> Dictionary:
	for checkpoint: Dictionary in CHECKPOINTS:
		if int(checkpoint.get("day", 0)) > completed_days:
			return checkpoint.duplicate(true)

	return {}


static func is_valid_checkpoint_day(day: int) -> bool:
	return CHECKPOINT_DAYS.has(day)


static func is_supported_catalog_version(
	version: int
) -> bool:
	return SUPPORTED_CATALOG_VERSIONS.has(version)


static func get_catalog_summary() -> Dictionary:
	return {
		"catalog_version": CATALOG_VERSION,
		"campaign_total_days": CAMPAIGN_TOTAL_DAYS,
		"season_length_days": SEASON_LENGTH_DAYS,
		"checkpoint_interval_days": (
			CHECKPOINT_INTERVAL_DAYS
		),
		"free_play_enabled": FREE_PLAY_ENABLED,
		"seasons": SEASONS.duplicate(true),
		"checkpoints": CHECKPOINTS.duplicate(true)
	}
