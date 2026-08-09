class_name VillageDiagnosticsWindow
extends Control


signal dialogue_test_requested()
signal story_test_requested(chapter_day: int)
signal relationship_test_requested()


const DIAGNOSTICS_SCRIPT = preload(
	"res://scripts/diagnostics/InternalDiagnostics.gd"
)
const CAMPAIGN_CATALOG_SCRIPT = preload(
	"res://scripts/campaign/CampaignCatalog.gd"
)
const DIFFICULTY_CATALOG_SCRIPT = preload(
	"res://scripts/campaign/DifficultyCatalog.gd"
)
const PIXEL_FONT: FontFile = preload(
	"res://assets/dialogue/alagard.ttf"
)

var overlay: ColorRect
var report_text: RichTextLabel
var status_label: Label
var story_selector: OptionButton
var balance_difficulty_selector: OptionButton
var balance_checkpoint_selector: OptionButton
var rerun_button: Button
var close_button: Button
var previous_focus: Control


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 940
	_create_window()


func show_diagnostics() -> void:
	previous_focus = VillageUIAccessibility.remember_focus(self)
	overlay.visible = true
	run_diagnostics()
	VillageUIAccessibility.focus_deferred(rerun_button)


func hide_window() -> void:
	overlay.visible = false
	VillageUIAccessibility.restore_focus_deferred(previous_focus)
	previous_focus = null


func is_window_visible() -> bool:
	return is_instance_valid(overlay) and overlay.visible


func run_diagnostics() -> void:
	var result: Dictionary = DIAGNOSTICS_SCRIPT.run_all()
	report_text.text = DIAGNOSTICS_SCRIPT.format_report(result)
	report_text.scroll_to_line(0)
	var success: bool = bool(result.get("success", false))
	status_label.text = (
		"[OK] TODOS OS TESTES PASSARAM"
		if success
		else "[ATENÇÃO] FORAM ENCONTRADOS PROBLEMAS"
	)
	status_label.add_theme_color_override(
		"font_color",
		MedievalTheme.SUCCESS if success else Color("#F07F72")
	)


func _create_window() -> void:
	overlay = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.01, 0.01, 0.02, 0.86)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.visible = false
	add_child(overlay)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(1040.0, 590.0)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			Color("#201826"),
			Color("#D2A85B"),
			3,
			12,
			18,
			7
		)
	)
	center.add_child(panel)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 9)
	panel.add_child(layout)

	var title: Label = Label.new()
	title.text = "ORÁCULO DE DIAGNÓSTICO"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", PIXEL_FONT)
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("#F1C86C"))
	layout.add_child(title)

	status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_override("font", PIXEL_FONT)
	status_label.add_theme_font_size_override("font_size", 15)
	layout.add_child(status_label)

	report_text = RichTextLabel.new()
	report_text.bbcode_enabled = false
	report_text.fit_content = false
	report_text.scroll_active = true
	report_text.selection_enabled = true
	report_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	report_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	report_text.add_theme_font_override("normal_font", PIXEL_FONT)
	report_text.add_theme_font_size_override("normal_font_size", 14)
	report_text.add_theme_color_override("default_color", Color("#EEE2CB"))
	layout.add_child(report_text)

	var buttons: HBoxContainer = HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 10)
	layout.add_child(buttons)

	rerun_button = _create_button("EXECUTAR NOVAMENTE")
	rerun_button.tooltip_text = "Executa novamente todas as verificações internas."
	rerun_button.pressed.connect(run_diagnostics)
	buttons.add_child(rerun_button)

	var dialogue_button: Button = _create_button("TESTAR DIÁLOGO")
	dialogue_button.pressed.connect(_on_dialogue_test_pressed)
	buttons.add_child(dialogue_button)

	var relationship_button: Button = _create_button("TESTAR RELAÇÕES")
	relationship_button.pressed.connect(_on_relationship_test_pressed)
	buttons.add_child(relationship_button)

	story_selector = OptionButton.new()
	story_selector.tooltip_text = "Escolha o prólogo ou capítulo a testar."
	VillageUIAccessibility.configure_input(story_selector)
	story_selector.custom_minimum_size = Vector2(155.0, 42.0)
	story_selector.add_theme_font_override("font", PIXEL_FONT)
	story_selector.add_theme_font_size_override("font_size", 12)
	for chapter_day: int in [0, 15, 30, 45, 60, 75, 120]:
		story_selector.add_item(
			"PRÓLOGO" if chapter_day == 0 else "DIA %d" % chapter_day
		)
		story_selector.set_item_metadata(
			story_selector.item_count - 1,
			chapter_day
		)
	buttons.add_child(story_selector)

	var story_button: Button = _create_button("TESTAR CAPÍTULO")
	story_button.custom_minimum_size = Vector2(150.0, 42.0)
	story_button.pressed.connect(_on_story_test_pressed)
	buttons.add_child(story_button)

	close_button = _create_button("FECHAR")
	close_button.tooltip_text = "Fecha o Oráculo e retorna ao jogo."
	close_button.pressed.connect(hide_window)
	buttons.add_child(close_button)

	var balance_row: HBoxContainer = HBoxContainer.new()
	balance_row.alignment = BoxContainer.ALIGNMENT_CENTER
	balance_row.add_theme_constant_override("separation", 10)
	layout.add_child(balance_row)

	var balance_label: Label = Label.new()
	balance_label.text = "SIMULAR METAS:"
	balance_label.add_theme_font_override("font", PIXEL_FONT)
	balance_label.add_theme_font_size_override("font_size", 13)
	balance_label.add_theme_color_override("font_color", Color("#D9C49A"))
	balance_row.add_child(balance_label)

	balance_difficulty_selector = OptionButton.new()
	balance_difficulty_selector.tooltip_text = "Escolha a dificuldade simulada."
	VillageUIAccessibility.configure_input(balance_difficulty_selector)
	balance_difficulty_selector.custom_minimum_size = Vector2(170.0, 38.0)
	balance_difficulty_selector.add_theme_font_override("font", PIXEL_FONT)
	balance_difficulty_selector.add_theme_font_size_override("font_size", 12)
	for difficulty_id: String in DIFFICULTY_CATALOG_SCRIPT.DIFFICULTY_IDS:
		balance_difficulty_selector.add_item(
			DIFFICULTY_CATALOG_SCRIPT.get_display_name(difficulty_id)
		)
		balance_difficulty_selector.set_item_metadata(
			balance_difficulty_selector.item_count - 1,
			difficulty_id
		)
		if difficulty_id == DIFFICULTY_CATALOG_SCRIPT.DEFAULT_DIFFICULTY_ID:
			balance_difficulty_selector.select(
				balance_difficulty_selector.item_count - 1
			)
	balance_row.add_child(balance_difficulty_selector)

	balance_checkpoint_selector = OptionButton.new()
	balance_checkpoint_selector.tooltip_text = "Escolha a avaliação simulada."
	VillageUIAccessibility.configure_input(balance_checkpoint_selector)
	balance_checkpoint_selector.custom_minimum_size = Vector2(130.0, 38.0)
	balance_checkpoint_selector.add_theme_font_override("font", PIXEL_FONT)
	balance_checkpoint_selector.add_theme_font_size_override("font_size", 12)
	for checkpoint_day: int in CAMPAIGN_CATALOG_SCRIPT.CHECKPOINT_DAYS:
		balance_checkpoint_selector.add_item("DIA %d" % checkpoint_day)
		balance_checkpoint_selector.set_item_metadata(
			balance_checkpoint_selector.item_count - 1,
			checkpoint_day
		)
	balance_row.add_child(balance_checkpoint_selector)

	var balance_button: Button = _create_button("VER METAS")
	balance_button.custom_minimum_size = Vector2(145.0, 38.0)
	balance_button.pressed.connect(_show_balance_snapshot)
	balance_row.add_child(balance_button)


func _create_button(button_text: String) -> Button:
	var button: Button = Button.new()
	button.text = button_text
	button.custom_minimum_size = Vector2(145.0, 42.0)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", PIXEL_FONT)
	button.add_theme_font_size_override("font_size", 13)
	VillageUIAccessibility.configure_button(button, "", 42.0)
	return button


func _unhandled_input(event: InputEvent) -> void:
	if not is_window_visible():
		return
	if event.is_action_pressed("ui_cancel"):
		hide_window()
		get_viewport().set_input_as_handled()


func _show_balance_snapshot() -> void:
	if (
		not is_instance_valid(balance_difficulty_selector)
		or not is_instance_valid(balance_checkpoint_selector)
	):
		return
	var difficulty_index: int = balance_difficulty_selector.selected
	var checkpoint_index: int = balance_checkpoint_selector.selected
	var difficulty_id: String = String(
		balance_difficulty_selector.get_item_metadata(difficulty_index)
	)
	var checkpoint_day: int = int(
		balance_checkpoint_selector.get_item_metadata(checkpoint_index)
	)
	var checkpoint: Dictionary = CAMPAIGN_CATALOG_SCRIPT.get_checkpoint_for_day(
		checkpoint_day
	)
	var base_targets: Dictionary = checkpoint.get("targets", {}) as Dictionary
	var targets: Dictionary = DIFFICULTY_CATALOG_SCRIPT.apply_checkpoint_targets(
		base_targets,
		difficulty_id
	)
	var rules: Dictionary = DIFFICULTY_CATALOG_SCRIPT.get_difficulty(
		difficulty_id
	)
	var lines: Array[String] = [
		"VISÃO DE BALANCEAMENTO — %s"
		% DIFFICULTY_CATALOG_SCRIPT.get_display_name(difficulty_id).to_upper(),
		"",
		"Avaliação selecionada: Dia %d" % checkpoint_day,
		"Alimentação: %.0f" % float(targets.get("food", 0.0)),
		"Material: %.0f" % float(targets.get("material", 0.0)),
		"Felicidade: %.0f" % float(targets.get("happiness", 0.0)),
		"População: %d" % int(targets.get("population", 0)),
		"",
		"Regras econômicas:",
		"Reservas iniciais: %.0f alimentação, %.0f material, %.0f felicidade" % [
			float(rules.get("initial_food", 0.0)),
			float(rules.get("initial_material", 0.0)),
			float(rules.get("initial_happiness", 0.0))
		],
		"Produção: %.0f%%" % (float(rules.get("production_multiplier", 1.0)) * 100.0),
		"Consumo de alimentação: %.0f%%" % (float(rules.get("food_consumption_multiplier", 1.0)) * 100.0),
		"Manutenção: %.0f%%" % (float(rules.get("maintenance_multiplier", 1.0)) * 100.0),
		"Custos de construção: %.0f%%" % (float(rules.get("building_cost_multiplier", 1.0)) * 100.0),
		"Felicidade mínima para atração: %.0f" % float(rules.get("growth_minimum_happiness", 55.0)),
		"Atração: 1 morador após %d dias favoráveis" % int(rules.get("attraction_target", 3)),
		"Abandono: 1 morador após %d dias preocupantes" % int(rules.get("abandonment_target", 3)),
		"Derrota por recurso zerado: %d dias consecutivos" % int(rules.get("crisis_grace_days", 2)),
		"Recuperação após crise: +%.1f felicidade" % float(rules.get("post_crisis_happiness_recovery", 0.0)),
		"",
		"Esta tela não altera a campanha. Ela serve para conferir as metas e regras."
	]
	report_text.text = "\n".join(lines)
	report_text.scroll_to_line(0)
	status_label.text = "VISÃO DE BALANCEAMENTO"
	status_label.add_theme_color_override("font_color", Color("#F1C86C"))


func _on_dialogue_test_pressed() -> void:
	hide_window()
	dialogue_test_requested.emit()


func _on_relationship_test_pressed() -> void:
	hide_window()
	relationship_test_requested.emit()


func _on_story_test_pressed() -> void:
	if not is_instance_valid(story_selector):
		return
	var selected_index: int = story_selector.selected
	var chapter_day: int = int(
		story_selector.get_item_metadata(selected_index)
	)
	hide_window()
	story_test_requested.emit(chapter_day)
