class_name ForecastDetailsWindow
extends Control


var _content: RichTextLabel
var _close_button: Button
var _previous_focus: Control


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 154
	z_as_relative = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.0, 0.0, 0.0, 0.70)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(820.0, 520.0)
	panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			MedievalTheme.WOOD_DARK,
			MedievalTheme.GOLD,
			3,
			12,
			20,
			6
		)
	)
	center.add_child(panel)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 10)
	panel.add_child(layout)

	var title: Label = MedievalTheme.create_label(
		"DETALHAMENTO DA PREVISÃO",
		MedievalTheme.GOLD,
		24
	)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(title)

	_content = RichTextLabel.new()
	_content.bbcode_enabled = true
	_content.fit_content = false
	_content.scroll_active = true
	_content.selection_enabled = true
	_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content.custom_minimum_size = Vector2(760.0, 400.0)
	_content.add_theme_font_size_override("normal_font_size", 15)
	layout.add_child(_content)

	_close_button = Button.new()
	_close_button.text = "FECHAR DETALHAMENTO"
	_close_button.custom_minimum_size = Vector2(0.0, 42.0)
	_close_button.pressed.connect(hide_window)
	layout.add_child(_close_button)


func open_window(forecast: Dictionary) -> void:
	_previous_focus = VillageUIAccessibility.remember_focus(self)
	_content.text = _build_text(forecast)
	_content.scroll_to_line(0)
	show()
	move_to_front()
	VillageUIAccessibility.focus_deferred(_close_button)


func hide_window() -> void:
	if not visible:
		return
	hide()
	VillageUIAccessibility.restore_focus_deferred(_previous_focus)
	_previous_focus = null


func is_window_visible() -> bool:
	return visible


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		hide_window()
		get_viewport().set_input_as_handled()


func _build_text(forecast: Dictionary) -> String:
	var effects: Dictionary = forecast.get("council_effects", {})
	var base: Dictionary = effects.get("base_production", {})
	var final_values: Dictionary = effects.get("final_production", {})
	var concentration: Dictionary = effects.get("concentration", {})
	var synergies: Dictionary = effects.get("synergies", {})
	var active_synergies: Array = synergies.get("active", [])
	var limited_synergies: Array = synergies.get("qualified_but_limited", [])
	var npc_relationship_synergy: Dictionary = effects.get("npc_relationship_synergy", {})
	var passive_rows: Array = effects.get("passives", [])
	var lines: Array[String] = [
		"[color=#D9B75B][b]PRODUÇÃO DO PRÓXIMO DIA[/b][/color]",
		"Antes de sinergias e concentração: alimentação %.2f • material %.2f • felicidade %.2f" % [
			float(base.get("food", 0.0)),
			float(base.get("material", 0.0)),
			float(base.get("happiness", 0.0))
		],
		"Entrada final prevista: alimentação %.2f • material %.2f • felicidade %.2f" % [
			float(final_values.get("food", 0.0)),
			float(final_values.get("material", 0.0)),
			float(final_values.get("happiness", 0.0))
		],
		"",
		"[color=#D9B75B][b]RETORNO POR CONCENTRAÇÃO[/b][/color]"
	]
	if bool(concentration.get("active", false)):
		lines.append(
			"%d cartas em %s: -%d%% sobre tudo que entra ao final do dia." % [
				int(concentration.get("max_same_profession", 1)),
				String(concentration.get("profession_name", "uma profissão")),
				int(concentration.get("penalty_percent", 0))
			]
		)
	else:
		lines.append("Sem penalidade: nenhuma profissão está concentrada.")

	lines.append("")
	lines.append("[color=#D9B75B][b]SINERGIAS AUTOMÁTICAS[/b][/color]")
	if active_synergies.is_empty():
		lines.append("Nenhuma sinergia de composição está ativa.")
	else:
		for value: Variant in active_synergies:
			if not value is Dictionary:
				continue
			var synergy: Dictionary = value as Dictionary
			var member_names: Array = []
			var member_names_value: Variant = synergy.get("member_names", [])
			if member_names_value is Array:
				member_names = member_names_value as Array
			lines.append(
				"• [b]%s[/b] — %s Participantes: %s." % [
					String(synergy.get("name", "Sinergia")),
					String(synergy.get("description", "")),
					_join_values(member_names)
				]
			)
	if not limited_synergies.is_empty():
		lines.append("Qualificadas, mas não escolhidas pelo limite e pela exclusividade de cada carta:")
		var shown_ids: Dictionary = {}
		for value: Variant in limited_synergies:
			if not value is Dictionary:
				continue
			var synergy: Dictionary = value as Dictionary
			var synergy_id: String = String(synergy.get("id", ""))
			if shown_ids.has(synergy_id):
				continue
			shown_ids[synergy_id] = true
			lines.append("• %s" % String(synergy.get("description", "Sinergia")))
	lines.append("")
	lines.append("[color=#D9B75B][b]RELAÇÕES ENTRE PERSONAGENS[/b][/color]")
	if bool(npc_relationship_synergy.get("active", false)):
		lines.append("• %s" % String(npc_relationship_synergy.get("description", "Afinidade positiva: +1% em toda produção do Conselho.")))
	else:
		lines.append("Nenhuma afinidade positiva descoberta está contribuindo para o Conselho.")

	lines.append("")
	lines.append("[color=#D9B75B][b]PASSIVAS DAS CARTAS ATIVAS[/b][/color]")
	for value: Variant in passive_rows:
		if not value is Dictionary:
			continue
		var row: Dictionary = value as Dictionary
		var state_label: String = "INATIVA"
		if String(row.get("state", "inactive")) == "active":
			state_label = "ATIVA"
		elif String(row.get("state", "inactive")) == "conditional":
			state_label = "CONDICIONAL"
		lines.append(
			"• %s — %s [%s]: %s" % [
				String(row.get("display_name", "Carta")),
				String(row.get("name", "Sem passiva")),
				state_label,
				String(row.get("status_text", ""))
			]
		)

	lines.append("")
	lines.append("[color=#D9B75B][b]CONSUMO E MANUTENÇÃO[/b][/color]")
	lines.append(
		"Alimentação: %.2f antes das reduções • -%.2f por passivas • %.2f final." % [
			float(forecast.get("food_consumption_before_council", 0.0)),
			float(forecast.get("food_fixed_reduction", 0.0)),
			float(forecast.get("food_consumption", 0.0))
		]
	)
	lines.append(
		"Material: %.2f antes das reduções • -%.2f por passivas/sinergias • %.2f final." % [
			float(forecast.get("material_consumption_before_council", 0.0)),
			float(forecast.get("material_fixed_reduction", 0.0)),
			float(forecast.get("material_consumption", 0.0))
		]
	)
	lines.append("")
	lines.append("Ordem: produção pessoal e global → passivas → sinergias → penalidade de concentração → entrada no estoque → consumo e manutenção.")
	return "\n".join(lines)


func _join_values(values: Array) -> String:
	var result: PackedStringArray = PackedStringArray()
	for value: Variant in values:
		result.append(String(value))
	return ", ".join(result)
