class_name VillageCampaignManager
extends RefCounted


const CAMPAIGN_STATE_VERSION: int = 5

const STATUS_ACTIVE: String = "active"
const STATUS_VICTORY: String = "victory"
const STATUS_DEFEAT: String = "defeat"
const STATUS_FREE_PLAY: String = "free_play"

# Mantido como constante pública para compatibilidade com os outros
# gerenciadores. Agora representa toda a campanha.
const TARGET_COMPLETED_DAYS: int = (
	VillageCampaignCatalog.CAMPAIGN_TOTAL_DAYS
)

const DEFAULT_MAX_CONSECUTIVE_ZERO_DAYS: int = 2
const RESOURCE_ZERO_EPSILON: float = 0.001


var status: String = STATUS_ACTIVE
var completed_days: int = 0
var food_crisis_days: int = 0
var material_crisis_days: int = 0
var completed_checkpoint_days: Array[int] = []
var last_evaluated_checkpoint_day: int = 0
var failed_checkpoint_day: int = 0
var result_title: String = ""
var result_text: String = ""
var difficulty_id: String = VillageDifficultyCatalog.DEFAULT_DIFFICULTY_ID
var lowest_happiness: float = 100.0
var total_crisis_days: int = 0
var checkpoint_margin_total: float = 0.0
var evaluation_reports: Array[Dictionary] = []
var final_statistics: Dictionary = {}
var final_profile: Dictionary = {}


func setup(new_difficulty_id: String = VillageDifficultyCatalog.DEFAULT_DIFFICULTY_ID) -> void:
	status = STATUS_ACTIVE
	completed_days = 0
	food_crisis_days = 0
	material_crisis_days = 0
	completed_checkpoint_days.clear()
	last_evaluated_checkpoint_day = 0
	failed_checkpoint_day = 0
	result_title = ""
	result_text = ""
	difficulty_id = VillageDifficultyCatalog.sanitize_difficulty_id(new_difficulty_id)
	lowest_happiness = 100.0
	total_crisis_days = 0
	checkpoint_margin_total = 0.0
	evaluation_reports.clear()
	final_statistics.clear()
	final_profile.clear()


func set_difficulty(new_difficulty_id: String) -> void:
	difficulty_id = VillageDifficultyCatalog.sanitize_difficulty_id(new_difficulty_id)


func is_finished() -> bool:
	return status in [
		STATUS_VICTORY,
		STATUS_DEFEAT
	]


func is_free_play() -> bool:
	return status == STATUS_FREE_PLAY


func enter_free_play() -> bool:
	if (
		status != STATUS_VICTORY
		or not VillageCampaignCatalog.FREE_PLAY_ENABLED
	):
		return false

	status = STATUS_FREE_PLAY
	result_title = "Modo Livre"
	result_text = (
		"A campanha foi vencida. As estações continuam "
		+ "se repetindo, sem novas avaliações obrigatórias."
	)
	return true


func export_save_data() -> Dictionary:
	return {
		"campaign_state_version": CAMPAIGN_STATE_VERSION,
		"difficulty_id": difficulty_id,
		"status": status,
		"completed_days": completed_days,
		"food_crisis_days": food_crisis_days,
		"material_crisis_days": material_crisis_days,
		"completed_checkpoint_days": (
			completed_checkpoint_days.duplicate()
		),
		"last_evaluated_checkpoint_day": (
			last_evaluated_checkpoint_day
		),
		"failed_checkpoint_day": failed_checkpoint_day,
		"result_title": result_title,
		"result_text": result_text,
		"lowest_happiness": lowest_happiness,
		"total_crisis_days": total_crisis_days,
		"checkpoint_margin_total": checkpoint_margin_total,
		"evaluation_reports": evaluation_reports.duplicate(true),
		"final_statistics": final_statistics.duplicate(true),
		"final_profile": final_profile.duplicate(true)
	}


func import_save_data(save_data: Dictionary) -> bool:
	var saved_status: String = String(
		save_data.get(
			"status",
			STATUS_ACTIVE
		)
	)

	if saved_status not in [
		STATUS_ACTIVE,
		STATUS_VICTORY,
		STATUS_DEFEAT,
		STATUS_FREE_PLAY
	]:
		return false

	var saved_completed_days: int = int(
		save_data.get(
			"completed_days",
			0
		)
	)

	if saved_completed_days < 0:
		return false

	var saved_state_version: int = int(
		save_data.get(
			"campaign_state_version",
			0
		)
	)

	if saved_state_version not in [3, 4, CAMPAIGN_STATE_VERSION]:
		return false
	difficulty_id = VillageDifficultyCatalog.sanitize_difficulty_id(
		String(
			save_data.get(
				"difficulty_id",
				VillageDifficultyCatalog.DEFAULT_DIFFICULTY_ID
			)
		)
	)

	if (
		saved_status != STATUS_FREE_PLAY
		and saved_completed_days > TARGET_COMPLETED_DAYS
	):
		return false

	if (
		saved_status == STATUS_FREE_PLAY
		and saved_completed_days < TARGET_COMPLETED_DAYS
	):
		return false

	status = saved_status
	completed_days = saved_completed_days
	food_crisis_days = clampi(
		int(
			save_data.get(
				"food_crisis_days",
				0
			)
		),
		0,
		_get_crisis_limit()
	)
	material_crisis_days = clampi(
		int(
			save_data.get(
				"material_crisis_days",
				0
			)
		),
		0,
		_get_crisis_limit()
	)

	completed_checkpoint_days.clear()
	var saved_checkpoints_value: Variant = save_data.get(
		"completed_checkpoint_days",
		null
	)

	if not saved_checkpoints_value is Array:
		return false

	var saved_checkpoints: Array = saved_checkpoints_value

	for checkpoint_value: Variant in saved_checkpoints:
		var checkpoint_day: int = int(checkpoint_value)

		if (
			not VillageCampaignCatalog.is_valid_checkpoint_day(
				checkpoint_day
			)
			or checkpoint_day > completed_days
			or completed_checkpoint_days.has(checkpoint_day)
		):
			return false

		completed_checkpoint_days.append(checkpoint_day)

	completed_checkpoint_days.sort()
	last_evaluated_checkpoint_day = int(
		save_data.get(
			"last_evaluated_checkpoint_day",
			(
				completed_checkpoint_days.back()
				if not completed_checkpoint_days.is_empty()
				else 0
			)
		)
	)

	if (
		last_evaluated_checkpoint_day != 0
		and not VillageCampaignCatalog.is_valid_checkpoint_day(
			last_evaluated_checkpoint_day
		)
	):
		return false

	failed_checkpoint_day = int(
		save_data.get(
			"failed_checkpoint_day",
			0
		)
	)

	if (
		failed_checkpoint_day != 0
		and (
			status != STATUS_DEFEAT
			or failed_checkpoint_day > completed_days
			or not VillageCampaignCatalog.is_valid_checkpoint_day(
				failed_checkpoint_day
			)
		)
	):
		return false

	result_title = String(
		save_data.get(
			"result_title",
			""
		)
	)
	result_text = String(
		save_data.get(
			"result_text",
			""
		)
	)
	lowest_happiness = clampf(float(save_data.get("lowest_happiness", 100.0)), 0.0, 100.0)
	total_crisis_days = maxi(0, int(save_data.get("total_crisis_days", 0)))
	checkpoint_margin_total = maxf(0.0, float(save_data.get("checkpoint_margin_total", 0.0)))
	evaluation_reports.clear()
	var reports_value: Variant = save_data.get("evaluation_reports", [])
	if not reports_value is Array:
		return false
	for report_value: Variant in reports_value as Array:
		if not report_value is Dictionary:
			return false
		evaluation_reports.append((report_value as Dictionary).duplicate(true))
	if evaluation_reports.size() > VillageCampaignCatalog.CHECKPOINTS.size():
		return false
	var statistics_value: Variant = save_data.get("final_statistics", {})
	var profile_value: Variant = save_data.get("final_profile", {})
	if not statistics_value is Dictionary or not profile_value is Dictionary:
		return false
	final_statistics = (statistics_value as Dictionary).duplicate(true)
	final_profile = (profile_value as Dictionary).duplicate(true)

	return true


func evaluate_completed_day(
	completed_day: int,
	food: float,
	material: float,
	happiness: float,
	population: int
) -> Dictionary:
	var was_finished: bool = is_finished()
	var checkpoint_evaluated: bool = false
	var checkpoint_passed: bool = false
	var evaluated_checkpoint_day: int = 0
	var evaluated_goals: Array[Dictionary] = []

	if was_finished:
		return _build_progress(
			completed_day + 1,
			food,
			material,
			happiness,
			population,
			false
		)

	completed_days = maxi(
		completed_days,
		completed_day
	)
	_update_crisis_counters(food, material)
	lowest_happiness = minf(lowest_happiness, happiness)
	if food <= RESOURCE_ZERO_EPSILON or material <= RESOURCE_ZERO_EPSILON:
		total_crisis_days += 1

	if is_free_play():
		return _build_progress(
			completed_day + 1,
			food,
			material,
			happiness,
			population,
			false
		)

	if happiness <= RESOURCE_ZERO_EPSILON:
		_finish_defeat(
			"A Esperança se Apagou",
			"A felicidade da vila chegou a zero. "
			+ "Sem confiança no futuro, os habitantes "
			+ "abandonaram o projeto de construir uma "
			+ "comunidade próspera."
		)

	elif food_crisis_days >= _get_crisis_limit():
		_finish_defeat(
			"Fome Prolongada",
			(
				"A vila terminou %d dias consecutivos sem "
				+ "nenhuma reserva de alimentação. A crise "
				+ "tornou impossível manter a comunidade unida."
			) % _get_crisis_limit()
		)

	elif material_crisis_days >= _get_crisis_limit():
		_finish_defeat(
			"Vila em Ruínas",
			(
				"A vila terminou %d dias consecutivos sem "
				+ "material para manutenção. As estruturas "
				+ "se deterioraram além do que os habitantes "
				+ "conseguiriam reparar."
			) % _get_crisis_limit()
		)

	else:
		var checkpoint: Dictionary = (
			VillageCampaignCatalog.get_checkpoint_for_day(
				completed_day
			)
		)

		if not checkpoint.is_empty():
			checkpoint_evaluated = true
			evaluated_checkpoint_day = completed_day
			last_evaluated_checkpoint_day = completed_day
			evaluated_goals = _build_goals_for_checkpoint(
				checkpoint,
				completed_day,
				food,
				material,
				happiness,
				population
			)
			checkpoint_passed = (
				_are_all_goals_met(evaluated_goals)
			)

			if checkpoint_passed:
				checkpoint_margin_total += _calculate_checkpoint_margin(evaluated_goals)
				if not completed_checkpoint_days.has(
					completed_day
				):
					completed_checkpoint_days.append(
						completed_day
					)

				if completed_day >= TARGET_COMPLETED_DAYS:
					_finish_victory(food, material, happiness, population)
			else:
				_finish_checkpoint_defeat(
					checkpoint,
					evaluated_goals
				)

	var finished_now: bool = (
		not was_finished
		and is_finished()
	)
	var progress: Dictionary = _build_progress(
		completed_day + 1,
		food,
		material,
		happiness,
		population,
		finished_now
	)

	progress["checkpoint_evaluated"] = checkpoint_evaluated
	progress["checkpoint_passed"] = checkpoint_passed
	progress["evaluated_checkpoint_day"] = (
		evaluated_checkpoint_day
	)
	progress["evaluated_goals"] = evaluated_goals

	if checkpoint_evaluated and checkpoint_passed:
		progress["checkpoint_result_title"] = (
			"AVALIAÇÃO DO DIA %d APROVADA"
			% evaluated_checkpoint_day
		)
		progress["checkpoint_result_text"] = (
			"A vila alcançou todas as metas obrigatórias. "
			+ (
				"A auditoria final reconheceu seu governo."
				if evaluated_checkpoint_day
				>= TARGET_COMPLETED_DAYS
				else (
					"A campanha continua até a próxima "
					+ "avaliação."
				)
			)
		)

	return progress


func get_progress(
	current_day: int,
	food: float,
	material: float,
	happiness: float,
	population: int
) -> Dictionary:
	return _build_progress(
		current_day,
		food,
		material,
		happiness,
		population,
		false
	)


func _build_progress(
	current_day: int,
	food: float,
	material: float,
	happiness: float,
	population: int,
	finished_now: bool
) -> Dictionary:
	var visible_completed_days: int = maxi(
		completed_days,
		maxi(0, current_day - 1)
	)
	var display_checkpoint: Dictionary = (
		_get_display_checkpoint()
	)
	var goals: Array[Dictionary] = []

	if not display_checkpoint.is_empty():
		goals = _build_goals_for_checkpoint(
			display_checkpoint,
			visible_completed_days,
			food,
			material,
			happiness,
			population
		)

	var met_goals: int = 0

	for goal: Dictionary in goals:
		if bool(goal.get("met", false)):
			met_goals += 1

	var season: Dictionary = (
		VillageCampaignCatalog.get_season_for_day(
			current_day
		)
	)
	var checkpoint_day: int = int(
		display_checkpoint.get("day", 0)
	)

	return {
		"status": status,
		"difficulty_id": difficulty_id,
		"difficulty_name": VillageDifficultyCatalog.get_display_name(difficulty_id),
		"is_finished": is_finished(),
		"is_free_play": is_free_play(),
		"can_enter_free_play": (
			status == STATUS_VICTORY
			and VillageCampaignCatalog.FREE_PLAY_ENABLED
		),
		"finished_now": finished_now,
		"current_day": current_day,
		"completed_days": visible_completed_days,
		"target_day": checkpoint_day,
		"campaign_total_days": TARGET_COMPLETED_DAYS,
		"days_remaining": (
			maxi(0, checkpoint_day - visible_completed_days)
			if checkpoint_day > 0
			else 0
		),
		"checkpoint_day": checkpoint_day,
		"completed_checkpoint_days": (
			completed_checkpoint_days.duplicate()
		),
		"checkpoint_timeline": _build_checkpoint_timeline(
			checkpoint_day
		),
		"future_checkpoint_preview": _build_future_checkpoint_preview(checkpoint_day),
		"season_id": String(season.get("id", "")),
		"season_name": String(
			season.get("display_name", "")
		),
		"day_in_season": (
			VillageCampaignCatalog.get_day_in_season(
				current_day
			)
		),
		"season_effects_text": String(
			season.get("effects_text", "")
		),
		"food": food,
		"material": material,
		"happiness": happiness,
		"population": population,
		"food_crisis_days": food_crisis_days,
		"material_crisis_days": material_crisis_days,
		"crisis_limit": _get_crisis_limit(),
		"goals": goals,
		"met_goals": met_goals,
		"total_goals": goals.size(),
		"result_title": result_title,
		"result_text": result_text,
		"lowest_happiness": lowest_happiness,
		"total_crisis_days": total_crisis_days,
		"checkpoint_margin_total": checkpoint_margin_total,
		"evaluation_reports": evaluation_reports.duplicate(true),
		"last_evaluation_report": (
			evaluation_reports.back().duplicate(true)
			if not evaluation_reports.is_empty()
			else {}
		),
		"final_statistics": final_statistics.duplicate(true),
		"final_profile": final_profile.duplicate(true)
	}


func _get_display_checkpoint() -> Dictionary:
	if is_free_play():
		return {}

	if status == STATUS_VICTORY:
		return VillageCampaignCatalog.get_checkpoint_for_day(
			TARGET_COMPLETED_DAYS
		)

	if (
		status == STATUS_DEFEAT
		and failed_checkpoint_day > 0
	):
		return VillageCampaignCatalog.get_checkpoint_for_day(
			failed_checkpoint_day
		)

	return VillageCampaignCatalog.get_next_checkpoint(
		completed_days
	)


func _build_checkpoint_timeline(
	current_checkpoint_day: int
) -> Array[Dictionary]:
	var timeline: Array[Dictionary] = []

	for checkpoint: Dictionary in (
		VillageCampaignCatalog.CHECKPOINTS
	):
		var checkpoint_day: int = int(
			checkpoint.get("day", 0)
		)
		var checkpoint_state: String = "future"

		if completed_checkpoint_days.has(checkpoint_day):
			checkpoint_state = "completed"
		elif (
			status == STATUS_DEFEAT
			and checkpoint_day == failed_checkpoint_day
		):
			checkpoint_state = "failed"
		elif checkpoint_day == current_checkpoint_day:
			checkpoint_state = "current"

		timeline.append(
			{
				"day": checkpoint_day,
				"state": checkpoint_state
			}
		)

	return timeline


func _build_goals_for_checkpoint(
	checkpoint: Dictionary,
	_visible_completed_days: int,
	food: float,
	material: float,
	happiness: float,
	population: int
) -> Array[Dictionary]:
	var targets: Dictionary = VillageDifficultyCatalog.apply_checkpoint_targets(
		checkpoint.get("targets", {}) as Dictionary,
		difficulty_id
	)
	var target_food: float = float(
		targets.get("food", 0.0)
	)
	var target_material: float = float(
		targets.get("material", 0.0)
	)
	var target_happiness: float = float(
		targets.get("happiness", 0.0)
	)
	var target_population: int = int(
		targets.get("population", 0)
	)

	return [
		{
			"id": "food",
			"label": (
				"Guardar %.0f de alimentação"
				% target_food
			),
			"current_text": "%.1f / %.1f" % [
				food,
				target_food
			],
			"current_value": food,
			"target_value": target_food,
			"met": (
				food + RESOURCE_ZERO_EPSILON
				>= target_food
			)
		},
		{
			"id": "material",
			"label": (
				"Guardar %.0f de material"
				% target_material
			),
			"current_text": "%.1f / %.1f" % [
				material,
				target_material
			],
			"current_value": material,
			"target_value": target_material,
			"met": (
				material + RESOURCE_ZERO_EPSILON
				>= target_material
			)
		},
		{
			"id": "happiness",
			"label": (
				"Manter %.0f de felicidade"
				% target_happiness
			),
			"current_text": "%.1f / %.1f" % [
				happiness,
				target_happiness
			],
			"current_value": happiness,
			"target_value": target_happiness,
			"met": (
				happiness + RESOURCE_ZERO_EPSILON
				>= target_happiness
			)
		},
		{
			"id": "population",
			"label": (
				"Alcançar %d habitantes"
				% target_population
			),
			"current_text": "%d / %d" % [
				population,
				target_population
			],
			"current_value": population,
			"target_value": target_population,
			"met": population >= target_population
		}
	]


func _are_all_goals_met(
	goals: Array[Dictionary]
) -> bool:
	for goal: Dictionary in goals:
		if not bool(goal.get("met", false)):
			return false

	return true


func _update_crisis_counters(
	food: float,
	material: float
) -> void:
	if food <= RESOURCE_ZERO_EPSILON:
		food_crisis_days += 1
	else:
		food_crisis_days = 0

	if material <= RESOURCE_ZERO_EPSILON:
		material_crisis_days += 1
	else:
		material_crisis_days = 0


func _finish_victory(
	_food: float,
	_material: float,
	_happiness: float,
	_population: int
) -> void:
	status = STATUS_VICTORY
	result_title = "Uma Vila para Todas as Estações"
	result_text = (
		"Após 120 dias e seis avaliações, a comunidade atravessou "
		+ "Primavera, Verão, Outono e Inverno. O relatório final "
		+ "registra o perfil desta administração sem reduzir a "
		+ "campanha a uma pontuação."
	)


func record_evaluation_report(report: Dictionary) -> bool:
	var checkpoint_day: int = int(report.get("checkpoint_day", 0))
	if (
		not VillageCampaignCatalog.is_valid_checkpoint_day(checkpoint_day)
		or not report.get("goals", null) is Array
		or not report.get("councillor_contributions", null) is Array
		or not report.get("behavioral_medals", null) is Array
	):
		return false
	for existing: Dictionary in evaluation_reports:
		if int(existing.get("checkpoint_day", 0)) == checkpoint_day:
			return false
	evaluation_reports.append(report.duplicate(true))
	evaluation_reports.sort_custom(_sort_evaluation_reports)
	return true


func set_final_outcome(
	statistics: Dictionary,
	profile: Dictionary
) -> bool:
	if statistics.is_empty() or profile.is_empty():
		return false
	final_statistics = statistics.duplicate(true)
	final_profile = profile.duplicate(true)
	var profile_name: String = String(
		final_profile.get("name", "Administração Equilibrada")
	)
	result_text = (
		"A campanha terminou com o perfil %s. %s "
		+ "As estatísticas completas permanecem disponíveis neste relatório."
	) % [
		profile_name,
		String(final_profile.get("description", ""))
	]
	return true


func get_evaluation_reports() -> Array[Dictionary]:
	return evaluation_reports.duplicate(true)


func _get_crisis_limit() -> int:
	return clampi(
		int(
			VillageDifficultyCatalog.get_difficulty(difficulty_id).get(
				"crisis_grace_days",
				DEFAULT_MAX_CONSECUTIVE_ZERO_DAYS
			)
		),
		2,
		4
	)


func _sort_evaluation_reports(a: Dictionary, b: Dictionary) -> bool:
	return int(a.get("checkpoint_day", 0)) < int(b.get("checkpoint_day", 0))


func _calculate_checkpoint_margin(goals: Array[Dictionary]) -> float:
	var margin: float = 0.0
	for goal: Dictionary in goals:
		var goal_id: String = String(goal.get("id", ""))
		if goal_id == "days":
			continue
		var current_value: float = float(goal.get("current_value", 0.0))
		var target_value: float = maxf(0.001, float(goal.get("target_value", 1.0)))
		margin += clampf(current_value / target_value - 1.0, 0.0, 0.5)
	return margin


func _build_future_checkpoint_preview(current_checkpoint_day: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for checkpoint: Dictionary in VillageCampaignCatalog.CHECKPOINTS:
		var day: int = int(checkpoint.get("day", 0))
		if day <= current_checkpoint_day:
			continue
		var targets: Dictionary = VillageDifficultyCatalog.apply_checkpoint_targets(
			checkpoint.get("targets", {}) as Dictionary,
			difficulty_id
		)
		result.append({
			"day": day,
			"summary": "Dia %d — população %d, reservas maiores e felicidade %.0f+" % [
				day,
				int(targets.get("population", 0)),
				float(targets.get("happiness", 0.0))
			]
		})
	return result


func _finish_defeat(
	title: String,
	description: String
) -> void:
	status = STATUS_DEFEAT
	result_title = title
	result_text = description


func _finish_checkpoint_defeat(
	checkpoint: Dictionary,
	evaluated_goals: Array[Dictionary]
) -> void:
	var missing_labels: Array[String] = []

	for goal: Dictionary in evaluated_goals:
		if (
			String(goal.get("id", "")) != "days"
			and not bool(goal.get("met", false))
		):
			missing_labels.append(
				String(goal.get("label", "Meta"))
			)

	var checkpoint_day: int = int(
		checkpoint.get("day", completed_days)
	)
	failed_checkpoint_day = checkpoint_day
	status = STATUS_DEFEAT
	result_title = "Avaliação do Dia %d Reprovada" % checkpoint_day
	result_text = (
		"A auditoria encontrou metas obrigatórias abaixo "
		+ "do mínimo: "
		+ ", ".join(missing_labels)
		+ ". A campanha terminou, mas o resultado servirá "
		+ "para ajustar sua próxima estratégia."
	)
