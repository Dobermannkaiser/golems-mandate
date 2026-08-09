class_name CampaignWindow
extends Control


signal restart_requested()
signal free_play_requested()
signal closed()


var overlay: ColorRect
var campaign_panel: PanelContainer
var section_label: Label
var title_label: Label
var description_label: Label
var progress_label: Label
var checkpoint_timeline_label: Label
var goals_container: VBoxContainer
var details_label: Label
var warning_label: Label
var restart_button: Button
var free_play_button: Button
var close_button: Button

var current_progress: Dictionary = {}
var previous_focus: Control


func _ready() -> void:
	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_create_window()


func show_progress(
	progress_data: Dictionary
) -> void:
	if not is_window_visible():
		previous_focus = VillageUIAccessibility.remember_focus(self)
	current_progress = progress_data.duplicate(true)
	overlay.visible = true

	var is_finished: bool = bool(
		current_progress.get(
			"is_finished",
			false
		)
	)

	if is_finished:
		_show_result_content()
	else:
		_show_active_content()

	_update_checkpoint_timeline()
	_rebuild_goals()
	call_deferred("_animate_open")
	VillageUIAccessibility.focus_first_enabled(overlay, close_button)


func show_result(
	result_data: Dictionary
) -> void:
	if not is_window_visible():
		previous_focus = VillageUIAccessibility.remember_focus(self)
	current_progress = result_data.duplicate(true)
	overlay.visible = true
	_show_result_content()
	_update_checkpoint_timeline()
	_rebuild_goals()
	call_deferred("_animate_open")
	VillageUIAccessibility.focus_first_enabled(overlay, close_button)


func show_checkpoint_result(
	progress_data: Dictionary
) -> void:
	if not is_window_visible():
		previous_focus = VillageUIAccessibility.remember_focus(self)
	current_progress = progress_data.duplicate(true)
	overlay.visible = true
	_show_checkpoint_result_content()
	_update_checkpoint_timeline()
	_rebuild_goals()
	call_deferred("_animate_open")
	VillageUIAccessibility.focus_first_enabled(overlay, close_button)


func hide_window() -> void:
	if not is_instance_valid(overlay) or not overlay.visible:
		return

	overlay.visible = false
	VillageUIAccessibility.restore_focus_deferred(previous_focus)
	previous_focus = null
	closed.emit()


func is_window_visible() -> bool:
	return (
		is_instance_valid(overlay)
		and overlay.visible
	)


func _show_active_content() -> void:
	var is_free_play: bool = bool(
		current_progress.get(
			"is_free_play",
			false
		)
	)
	var completed_days: int = int(
		current_progress.get(
			"completed_days",
			0
		)
	)
	var season_name: String = String(
		current_progress.get(
			"season_name",
			"Primavera"
		)
	)
	var day_in_season: int = int(
		current_progress.get(
			"day_in_season",
			1
		)
	)

	if is_free_play:
		section_label.text = "CAMPANHA CONCLUÍDA"
		title_label.text = "MODO LIVRE"
		description_label.text = (
			"A vitória já está garantida. As estações e os "
			+ "acontecimentos continuam, mas não existem "
			+ "novas avaliações obrigatórias."
		)
		progress_label.text = (
			"DIA %d     •     %s %d / 30"
			% [
				completed_days + 1,
				season_name.to_upper(),
				day_in_season
			]
		)
		title_label.add_theme_color_override(
			"font_color",
			Color("#9FD18B")
		)
		warning_label.text = (
			"Crises ainda afetam os recursos, mas não "
			+ "podem apagar a vitória conquistada."
		)
		warning_label.add_theme_color_override(
			"font_color",
			MedievalTheme.TEXT_MUTED
		)
		restart_button.visible = false
		free_play_button.visible = false
		close_button.visible = true
		close_button.text = "VOLTAR À VILA"
		return

	section_label.text = "PLANO DA COMUNIDADE"
	var target_day: int = int(
		current_progress.get(
			"target_day",
			20
		)
	)
	title_label.text = (
		"PRÓXIMA AVALIAÇÃO — DIA %d"
		% target_day
	)

	var difficulty_name: String = String(
		current_progress.get("difficulty_name", "Moderada")
	)
	description_label.text = (
		(
			"Dificuldade %s. Os quatro mínimos precisam ser alcançados "
			+ "quando o dia %d terminar. Estação atual: %s. %s"
		)
		% [
			difficulty_name,
			target_day,
			season_name,
			String(
				current_progress.get(
					"season_effects_text",
					""
				)
			)
		]
	)

	var met_goals: int = int(
		current_progress.get(
			"met_goals",
			0
		)
	)

	var total_goals: int = int(
		current_progress.get(
			"total_goals",
			4
		)
	)

	progress_label.text = (
		"DIA CONCLUÍDO %d / 120     •     "
		+ "%d / %d METAS ATINGIDAS"
	) % [
		completed_days,
		met_goals,
		total_goals
	]

	title_label.add_theme_color_override(
		"font_color",
		MedievalTheme.GOLD
	)

	_update_warning()
	restart_button.visible = false
	free_play_button.visible = false
	close_button.visible = true
	close_button.text = "VOLTAR À VILA"


func _show_checkpoint_result_content() -> void:
	var evaluated_day: int = int(
		current_progress.get(
			"evaluated_checkpoint_day",
			0
		)
	)
	var next_checkpoint_day: int = int(
		current_progress.get(
			"checkpoint_day",
			0
		)
	)

	section_label.text = "AVALIAÇÃO DIVINA"
	title_label.text = String(
		current_progress.get(
			"checkpoint_result_title",
			"AVALIAÇÃO APROVADA"
		)
	)
	description_label.text = String(
		current_progress.get(
			"checkpoint_result_text",
			"A vila alcançou as metas obrigatórias."
		)
	)
	progress_label.text = (
		"DIA %d CONCLUÍDO     •     "
		+ "PRÓXIMA AVALIAÇÃO: DIA %d"
	) % [
		evaluated_day,
		next_checkpoint_day
	]
	title_label.add_theme_color_override(
		"font_color",
		Color("#9FD18B")
	)
	warning_label.text = (
		"O relatório abaixo preserva as metas avaliadas, a memória "
		+ "do período e as contribuições do Conselho."
	)
	warning_label.add_theme_color_override(
		"font_color",
		MedievalTheme.TEXT_MUTED
	)
	restart_button.visible = false
	free_play_button.visible = false
	close_button.visible = true
	close_button.text = "CONTINUAR CAMPANHA"


func _show_result_content() -> void:
	var status: String = String(
		current_progress.get(
			"status",
			"defeat"
		)
	)

	var is_victory: bool = status == "victory"

	section_label.text = (
		"CAMPANHA CONCLUÍDA"
		if is_victory
		else "FIM DA CAMPANHA"
	)

	title_label.text = String(
		current_progress.get(
			"result_title",
			"Resultado da Campanha"
		)
	).to_upper()

	description_label.text = String(
		current_progress.get(
			"result_text",
			"A campanha chegou ao fim."
		)
	)

	if is_victory:
		var final_profile: Dictionary = current_progress.get("final_profile", {})
		progress_label.text = (
			"PERFIL: %s     •     %s"
			% [
				String(final_profile.get("name", "Administração Equilibrada")).to_upper(),
				String(current_progress.get("difficulty_name", "Moderada")).to_upper()
			]
		)
	else:
		var final_statistics: Dictionary = current_progress.get("final_statistics", {})
		progress_label.text = "CAMPANHA ENCERRADA — %d DIAS — %d / 6 AVALIAÇÕES" % [
			int(final_statistics.get("completed_days", current_progress.get("completed_days", 0))),
			int(final_statistics.get("checkpoints_approved", 0))
		]

	title_label.add_theme_color_override(
		"font_color",
		(
			Color("#9FD18B")
			if is_victory
			else Color("#F07F72")
		)
	)

	warning_label.text = (
		"Escolha continuar no Modo Livre ou iniciar "
		+ "uma nova campanha."
		if is_victory
		else (
			"Revise as profissões e tente uma "
			+ "estratégia diferente na próxima campanha."
		)
	)

	warning_label.add_theme_color_override(
		"font_color",
		MedievalTheme.TEXT_MUTED
	)

	restart_button.visible = true
	free_play_button.visible = bool(
		current_progress.get(
			"can_enter_free_play",
			false
		)
	)
	close_button.visible = not free_play_button.visible
	close_button.text = "OBSERVAR A VILA"


func _update_warning() -> void:
	var warnings: Array[String] = []

	var food_crisis_days: int = int(
		current_progress.get(
			"food_crisis_days",
			0
		)
	)

	var material_crisis_days: int = int(
		current_progress.get(
			"material_crisis_days",
			0
		)
	)

	var crisis_limit: int = int(
		current_progress.get(
			"crisis_limit",
			2
		)
	)

	if food_crisis_days > 0:
		warnings.append(
			"Alimentação zerada: %d / %d dias críticos."
			% [
				food_crisis_days,
				crisis_limit
			]
		)

	if material_crisis_days > 0:
		warnings.append(
			"Material zerado: %d / %d dias críticos."
			% [
				material_crisis_days,
				crisis_limit
			]
		)

	if warnings.is_empty():
		var forecast_text: String = String(
			current_progress.get(
				"forecast_text",
				"Prefeito Perfeito: tendência ainda não calculada."
			)
		)
		var future_lines: Array[String] = []
		var future_value: Variant = current_progress.get("future_checkpoint_preview", [])
		if future_value is Array:
			var future_previews: Array = future_value as Array
			for preview_value: Variant in future_previews:
				if preview_value is Dictionary and future_lines.size() < 2:
					var preview: Dictionary = preview_value as Dictionary
					future_lines.append(String(preview.get("summary", "")))
		warning_label.text = forecast_text
		if not future_lines.is_empty():
			warning_label.text += "\nPRÓXIMAS: " + "  •  ".join(future_lines)

		warning_label.add_theme_color_override(
			"font_color",
			MedievalTheme.TEXT_MUTED
		)
	else:
		warning_label.text = "\n".join(warnings)

		warning_label.add_theme_color_override(
			"font_color",
			Color("#F07F72")
		)


func _rebuild_goals() -> void:
	for child: Node in goals_container.get_children():
		goals_container.remove_child(child)
		child.queue_free()

	var goals: Array = current_progress.get("goals", [])
	var evaluation_report: Dictionary = current_progress.get("evaluation_report", {})
	if evaluation_report.is_empty():
		evaluation_report = current_progress.get("last_evaluation_report", {})
	if bool(current_progress.get("checkpoint_evaluated", false)) and not evaluation_report.is_empty():
		goals = evaluation_report.get("goals", []) as Array

	if goals.is_empty():
		var free_play_label: Label = (
			MedievalTheme.create_label(
				"SEM METAS OBRIGATÓRIAS",
				MedievalTheme.TEXT_MUTED,
				17
			)
		)
		free_play_label.horizontal_alignment = (
			HORIZONTAL_ALIGNMENT_CENTER
		)
		free_play_label.vertical_alignment = (
			VERTICAL_ALIGNMENT_CENTER
		)
		free_play_label.size_flags_vertical = (
			Control.SIZE_EXPAND_FILL
		)
		goals_container.add_child(free_play_label)
		_update_details()
		return

	for goal_value: Variant in goals:
		var goal: Dictionary = goal_value
		goals_container.add_child(
			_create_goal_row(goal)
		)
	_update_details()


func _update_details() -> void:
	if not is_instance_valid(details_label):
		return
	if bool(current_progress.get("is_finished", false)):
		details_label.text = _build_final_details_text()
	elif bool(current_progress.get("checkpoint_evaluated", false)):
		details_label.text = _build_evaluation_details_text()
	else:
		details_label.text = _build_preparation_details_text()


func _build_preparation_details_text() -> String:
	var lines: Array[String] = ["PREPARAÇÃO"]
	var identity: Dictionary = current_progress.get("campaign_identity", {})
	lines.append("%s • semente %d • gerador v%d" % [
		String(identity.get("village_name", "Vila")),
		int(identity.get("campaign_seed", 0)),
		int(identity.get("generator_version", 1))
	])
	var works: Array = current_progress.get("construction_forecast", []) as Array
	if works.is_empty():
		lines.append("OBRAS CONSIDERADAS: nenhuma obra contratada ficará disponível antes da avaliação.")
	else:
		lines.append("OBRAS CONSIDERADAS:")
		for work_value: Variant in works:
			if work_value is Dictionary:
				var work: Dictionary = work_value as Dictionary
				lines.append("• %s no dia %d — %s" % [
					String(work.get("name", "Obra")),
					int(work.get("available_day", 0)),
					String(work.get("effect_text", "efeito já contratado"))
				])
	lines.append("RISCOS E LIMITES:")
	for risk_value: Variant in current_progress.get("forecast_risks", []) as Array:
		lines.append("• %s" % String(risk_value))
	lines.append("PREMISSAS:")
	for assumption_value: Variant in current_progress.get("projection_assumptions", []) as Array:
		lines.append("• %s" % String(assumption_value))
	return "\n".join(lines)


func _build_evaluation_details_text() -> String:
	var report: Dictionary = current_progress.get("evaluation_report", {})
	if report.is_empty():
		report = current_progress.get("last_evaluation_report", {})
	if report.is_empty():
		return "O detalhamento desta avaliação não está disponível."
	var lines: Array[String] = [
		"MEMÓRIA DOS DIAS %d–%d" % [
			int(report.get("period_start_day", 1)),
			int(report.get("period_end_day", 20))
		]
	]
	var breakdown: Dictionary = report.get("resource_breakdown", {})
	var resource_names: Dictionary = {
		"food": "Alimentação",
		"material": "Material",
		"happiness": "Felicidade"
	}
	for resource_id: String in ["food", "material", "happiness"]:
		var data: Dictionary = breakdown.get(resource_id, {})
		lines.append("%s: início %.1f • produção +%.1f • custos -%.1f • outros %+.1f • final %.1f" % [
			String(resource_names[resource_id]),
			float(data.get("opening", 0.0)),
			float(data.get("production", 0.0)),
			float(data.get("costs", 0.0)),
			float(data.get("other_adjustments", 0.0)),
			float(data.get("closing", 0.0))
		])
	lines.append("CONTRIBUIÇÕES DO CONSELHO:")
	for contribution_value: Variant in report.get("councillor_contributions", []) as Array:
		if contribution_value is Dictionary:
			var contribution: Dictionary = contribution_value as Dictionary
			lines.append("• %s — A %.1f • M %.1f • F %.1f • %d dias • %s" % [
				String(contribution.get("display_name", "Conselheiro")),
				float(contribution.get("food", 0.0)),
				float(contribution.get("material", 0.0)),
				float(contribution.get("happiness", 0.0)),
				int(contribution.get("active_days", 0)),
				", ".join(contribution.get("profession_names", []) as Array)
			])
	lines.append("MEDALHAS COMPORTAMENTAIS — reconhecimento, sem bônus:")
	var medals: Array = report.get("behavioral_medals", []) as Array
	if medals.is_empty():
		lines.append("• Nenhuma medalha pôde ser atribuída neste período.")
	for medal_value: Variant in medals:
		if medal_value is Dictionary:
			var medal: Dictionary = medal_value as Dictionary
			lines.append("• %s — %s: %s" % [
				String(medal.get("display_name", "Conselheiro")),
				String(medal.get("name", "Reconhecimento")),
				String(medal.get("description", ""))
			])
	var comparison: Array = report.get("comparison_with_previous", []) as Array
	if not comparison.is_empty():
		lines.append("COMPARAÇÃO COM A AVALIAÇÃO ANTERIOR:")
		for comparison_value: Variant in comparison:
			if comparison_value is Dictionary:
				var row: Dictionary = comparison_value as Dictionary
				lines.append("• %s: %+.1f" % [
					String(row.get("label", "Meta")),
					float(row.get("change", 0.0))
				])
	lines.append("CONSEQUÊNCIAS:")
	for consequence_value: Variant in report.get("consequences", []) as Array:
		lines.append("• %s" % String(consequence_value))
	return "\n".join(lines)


func _build_final_details_text() -> String:
	var statistics: Dictionary = current_progress.get("final_statistics", {})
	var profile: Dictionary = current_progress.get("final_profile", {})
	if statistics.is_empty():
		return _build_evaluation_details_text()
	var lines: Array[String] = [
		"PERFIL DESCRITIVO — %s" % String(profile.get("name", "Administração Equilibrada")),
		String(profile.get("description", "A campanha deixou uma história própria.")),
		"%s • dificuldade %s • semente %d" % [
			String(statistics.get("village_name", "Vila")),
			String(statistics.get("difficulty_name", "Moderada")),
			int(statistics.get("campaign_seed", 0))
		],
		"Duração: %d dias • avaliações: %d/%d" % [
			int(statistics.get("completed_days", 0)),
			int(statistics.get("checkpoints_approved", 0)),
			int(statistics.get("checkpoints_total", 6))
		],
		"População: %d final • %d máxima" % [
			int(statistics.get("final_population", 0)),
			int(statistics.get("maximum_population", 0))
		],
		"Felicidade: %.1f final • %.1f média • %.1f mínima" % [
			float(statistics.get("final_happiness", 0.0)),
			float(statistics.get("average_happiness", 0.0)),
			float(statistics.get("lowest_happiness", 0.0))
		],
		"Reservas finais: %.1f alimentação • %.1f material" % [
			float(statistics.get("final_food", 0.0)),
			float(statistics.get("final_material", 0.0))
		],
		"Escassez: %d dias • crise em reserva zerada: %d dias" % [
			int(statistics.get("shortage_days", 0)),
			int(statistics.get("crisis_days", 0))
		],
		"Vila: %d melhorias • %d casas • %d decisões registradas" % [
			int(statistics.get("built_upgrades", 0)),
			int(statistics.get("house_count", 0)),
			int(statistics.get("decision_count", 0))
		],
		"Relações: %d conhecidas • %d pares positivos • parceria: %s" % [
			int(statistics.get("known_relationships", 0)),
			int(statistics.get("positive_npc_pairs", 0)),
			String(statistics.get("official_partner_name", "Nenhum"))
		],
		"Não há pontuação geral: o perfil e os números permanecem separados."
	]
	var closing_medals: Array = statistics.get("closing_behavioral_medals", []) as Array
	lines.append("RECONHECIMENTOS DO ENCERRAMENTO — sem bônus:")
	if closing_medals.is_empty():
		lines.append("• Nenhum reconhecimento pôde ser atribuído no período final.")
	for medal_value: Variant in closing_medals:
		if medal_value is Dictionary:
			var medal: Dictionary = medal_value as Dictionary
			lines.append("• %s — %s" % [
				String(medal.get("display_name", "Conselheiro")),
				String(medal.get("name", "Reconhecimento"))
			])
	return "\n".join(lines)


func _update_checkpoint_timeline() -> void:
	if not is_instance_valid(checkpoint_timeline_label):
		return

	var timeline_value: Variant = current_progress.get(
		"checkpoint_timeline",
		[]
	)

	if not timeline_value is Array:
		checkpoint_timeline_label.text = ""
		return

	var timeline: Array = timeline_value
	var entries: Array[String] = []

	for checkpoint_value: Variant in timeline:
		if not checkpoint_value is Dictionary:
			continue

		var checkpoint: Dictionary = checkpoint_value
		var state: String = String(
			checkpoint.get("state", "future")
		)
		var marker: String = "○"

		match state:
			"completed":
				marker = "✓"
			"current":
				marker = "●"
			"failed":
				marker = "×"

		entries.append(
			"%s %d"
			% [
				marker,
				int(checkpoint.get("day", 0))
			]
		)

	checkpoint_timeline_label.text = (
		"AVALIAÇÕES     "
		+ "     ".join(entries)
	)

func _create_goal_row(
	goal: Dictionary
) -> PanelContainer:
	var goal_met: bool = bool(
		goal.get(
			"met",
			false
		)
	)
	var is_evaluated: bool = goal.has("actual_value")
	var projection_status: String = String(goal.get("projection_status", ""))

	var row_panel: PanelContainer = PanelContainer.new()

	row_panel.custom_minimum_size = Vector2(
		0.0,
		62.0 if not projection_status.is_empty() else 54.0
	)

	row_panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			(
				Color(0.20, 0.31, 0.19, 0.94)
				if goal_met
				else MedievalTheme.WOOD
			),
			(
				Color("#7FA66B")
				if goal_met
				else MedievalTheme.GOLD_DARK
			),
			1,
			6,
			9,
			0
		)
	)

	var row: HBoxContainer = HBoxContainer.new()

	row.add_theme_constant_override(
		"separation",
		12
	)

	row_panel.add_child(row)

	var state_text: String = "ATINGIDA" if goal_met else "NÃO ATINGIDA"
	if not is_evaluated:
		state_text = (
			"SEGURA" if projection_status == "safe"
			else ("APERTADA" if projection_status == "tight" else "RISCO")
		)
	var state_label: Label = MedievalTheme.create_label(
		state_text,
		(
			Color("#B9DDA7")
			if goal_met
			else Color("#E6C15A")
		),
		12
	)

	state_label.custom_minimum_size = Vector2(
		92.0,
		0.0
	)

	state_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	row.add_child(state_label)

	var goal_label: Label = MedievalTheme.create_label(
		String(
			goal.get(
				"label",
				"Objetivo"
			)
		),
		MedievalTheme.PARCHMENT_LIGHT,
		16
	)

	goal_label.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	goal_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	row.add_child(goal_label)

	var value_text: String = _format_goal_value(goal.get("current_text", ""))
	if not projection_status.is_empty():
		value_text = "Agora %s  •  Projeção %s  •  Meta %s" % [
			_format_goal_value(goal.get("current_value", 0.0)),
			_format_goal_value(goal.get("projected_text", "?")),
			_format_goal_value(goal.get("target_value", 0.0))
		]
	var value_label: Label = MedievalTheme.create_label(
		value_text,
		(
			Color("#B9DDA7")
			if goal_met
			else MedievalTheme.GOLD
		),
		15
	)

	value_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_RIGHT
	)

	value_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	row.add_child(value_label)
	return row_panel


func _format_goal_value(value: Variant) -> String:
	if value is float:
		return "%.1f" % float(value)
	if value is int:
		return "%d" % int(value)
	return str(value)


func _create_window() -> void:
	overlay = ColorRect.new()
	overlay.name = "CampaignOverlay"

	overlay.color = Color(
		0.025,
		0.015,
		0.008,
		0.84
	)

	overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	overlay.z_index = 120
	overlay.visible = false
	add_child(overlay)

	var center: CenterContainer = CenterContainer.new()

	center.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)

	campaign_panel = PanelContainer.new()

	campaign_panel.custom_minimum_size = Vector2(
		760.0,
		620.0
	)

	campaign_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	campaign_panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			MedievalTheme.WOOD_DARK,
			MedievalTheme.GOLD,
			3,
			12,
			22,
			8
		)
	)

	center.add_child(campaign_panel)

	var layout: VBoxContainer = VBoxContainer.new()

	layout.add_theme_constant_override(
		"separation",
		10
	)

	campaign_panel.add_child(layout)

	section_label = MedievalTheme.create_label(
		"PLANO DA COMUNIDADE",
		MedievalTheme.TEXT_MUTED,
		13
	)

	section_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	layout.add_child(section_label)

	title_label = MedievalTheme.create_label(
		"OBJETIVOS DA CAMPANHA",
		MedievalTheme.GOLD,
		27
	)

	title_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	layout.add_child(title_label)

	var divider: HSeparator = HSeparator.new()
	layout.add_child(divider)

	description_label = MedievalTheme.create_label(
		"",
		MedievalTheme.PARCHMENT_LIGHT,
		16
	)

	description_label.custom_minimum_size = Vector2(
		0.0,
		66.0
	)

	description_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	description_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	description_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	layout.add_child(description_label)

	progress_label = MedievalTheme.create_label(
		"",
		MedievalTheme.GOLD,
		15
	)

	progress_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	layout.add_child(progress_label)

	checkpoint_timeline_label = MedievalTheme.create_label(
		"",
		MedievalTheme.TEXT_MUTED,
		14
	)
	checkpoint_timeline_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	layout.add_child(checkpoint_timeline_label)

	var report_scroll: ScrollContainer = ScrollContainer.new()
	report_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	report_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	report_scroll.custom_minimum_size = Vector2(0.0, 190.0)
	report_scroll.focus_mode = Control.FOCUS_ALL
	report_scroll.tooltip_text = "Relatório rolável da campanha."
	layout.add_child(report_scroll)

	var report_content: VBoxContainer = VBoxContainer.new()
	report_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	report_content.add_theme_constant_override("separation", 9)
	report_scroll.add_child(report_content)

	goals_container = VBoxContainer.new()

	goals_container.add_theme_constant_override(
		"separation",
		7
	)

	report_content.add_child(goals_container)

	details_label = MedievalTheme.create_label(
		"",
		MedievalTheme.PARCHMENT_LIGHT,
		13
	)
	details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	report_content.add_child(details_label)

	warning_label = MedievalTheme.create_label(
		"",
		MedievalTheme.TEXT_MUTED,
		13
	)

	warning_label.custom_minimum_size = Vector2(
		0.0,
		42.0
	)

	warning_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	warning_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	warning_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	layout.add_child(warning_label)

	var button_row: HBoxContainer = HBoxContainer.new()

	button_row.alignment = BoxContainer.ALIGNMENT_CENTER

	button_row.add_theme_constant_override(
		"separation",
		14
	)

	layout.add_child(button_row)

	restart_button = Button.new()
	restart_button.text = "NOVA CAMPANHA"

	restart_button.custom_minimum_size = Vector2(
		220.0,
		48.0
	)

	restart_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	VillageUIAccessibility.configure_button(
		restart_button,
		"Inicia uma nova campanha e substitui o progresso atual.",
		48.0
	)
	restart_button.pressed.connect(
		_on_restart_pressed
	)

	button_row.add_child(restart_button)

	free_play_button = Button.new()
	free_play_button.text = "CONTINUAR NO MODO LIVRE"
	free_play_button.custom_minimum_size = Vector2(
		250.0,
		48.0
	)
	free_play_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)
	VillageUIAccessibility.configure_button(
		free_play_button,
		"Continua administrando a vila após o Dia 120.",
		48.0
	)
	free_play_button.pressed.connect(
		_on_free_play_pressed
	)
	button_row.add_child(free_play_button)

	close_button = Button.new()
	close_button.text = "VOLTAR À VILA"

	close_button.custom_minimum_size = Vector2(
		220.0,
		48.0
	)

	close_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	VillageUIAccessibility.configure_button(
		close_button,
		"Fecha o relatório e retorna à vila.",
		48.0
	)
	close_button.pressed.connect(
		_on_close_pressed
	)

	button_row.add_child(close_button)


func _on_restart_pressed() -> void:
	restart_requested.emit()


func _on_free_play_pressed() -> void:
	free_play_requested.emit()


func _on_close_pressed() -> void:
	hide_window()


func _animate_open() -> void:
	if not is_instance_valid(campaign_panel):
		return

	campaign_panel.pivot_offset = (
		campaign_panel.size * 0.5
	)

	if GameSettings.reduced_motion:
		campaign_panel.modulate = Color.WHITE
		campaign_panel.scale = Vector2.ONE
		return

	campaign_panel.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.0
	)

	campaign_panel.scale = Vector2(
		0.96,
		0.96
	)

	var tween: Tween = create_tween()

	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		campaign_panel,
		"modulate",
		Color.WHITE,
		0.22
	)

	tween.tween_property(
		campaign_panel,
		"scale",
		Vector2.ONE,
		0.22
	)


func _unhandled_key_input(
	event: InputEvent
) -> void:
	if not is_window_visible():
		return

	if event.is_action_pressed("ui_cancel"):
		if bool(
			current_progress.get(
				"can_enter_free_play",
				false
			)
		):
			VillageUIAccessibility.focus_first_enabled(
				overlay,
				free_play_button
			)
			get_viewport().set_input_as_handled()
			return

		hide_window()
		get_viewport().set_input_as_handled()
