class_name CouncillorHistoryWindow
extends Control


const CHARACTER_CATALOG_SCRIPT = preload(
	"res://scripts/dialogue/CharacterCatalog.gd"
)


var _portrait: TextureRect
var _title_label: Label
var _summary_text: RichTextLabel
var _close_button: Button
var _previous_focus: Control


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 155
	z_as_relative = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.0, 0.0, 0.0, 0.72)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(880.0, 610.0)
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

	_title_label = MedievalTheme.create_label(
		"FICHA HISTÓRICA",
		MedievalTheme.GOLD,
		24
	)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(_title_label)

	var header: HBoxContainer = HBoxContainer.new()
	header.add_theme_constant_override("separation", 14)
	layout.add_child(header)

	var portrait_frame: PanelContainer = PanelContainer.new()
	portrait_frame.custom_minimum_size = Vector2(150.0, 150.0)
	portrait_frame.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			MedievalTheme.WOOD,
			MedievalTheme.GOLD_DARK,
			2,
			7,
			5,
			0
		)
	)
	header.add_child(portrait_frame)

	_portrait = TextureRect.new()
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_frame.add_child(_portrait)

	_summary_text = RichTextLabel.new()
	_summary_text.bbcode_enabled = true
	_summary_text.fit_content = false
	_summary_text.scroll_active = true
	_summary_text.selection_enabled = true
	_summary_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_summary_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_summary_text.custom_minimum_size = Vector2(680.0, 490.0)
	_summary_text.add_theme_font_size_override("normal_font_size", 15)
	header.add_child(_summary_text)

	_close_button = Button.new()
	_close_button.text = "FECHAR FICHA"
	_close_button.custom_minimum_size = Vector2(0.0, 42.0)
	_close_button.pressed.connect(hide_window)
	layout.add_child(_close_button)


func open_window(history: Dictionary) -> void:
	if history.is_empty():
		return
	_previous_focus = VillageUIAccessibility.remember_focus(self)
	var display_name: String = String(history.get("display_name", "Conselheiro"))
	_title_label.text = "FICHA HISTÓRICA — %s" % display_name.to_upper()
	_portrait.texture = CHARACTER_CATALOG_SCRIPT.get_portrait_texture(
		String(history.get("portrait_id", ""))
	)
	_summary_text.text = _build_history_text(history)
	_summary_text.scroll_to_line(0)
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


func _build_history_text(history: Dictionary) -> String:
	var totals: Dictionary = history.get("total_production", {})
	var profession_counts: Dictionary = history.get("profession_day_counts", {})
	var favorite_profession: String = "Nenhuma"
	var favorite_days: int = 0
	for key_value: Variant in profession_counts.keys():
		var days: int = int(profession_counts[key_value])
		if days > favorite_days:
			favorite_days = days
			favorite_profession = Villager.get_profession_name(int(String(key_value)))

	var event_successes: int = int(history.get("event_successes", 0))
	var event_failures: int = int(history.get("event_failures", 0))
	var event_guaranteed: int = int(history.get("event_guaranteed", 0))
	var milestones: Array = history.get("production_milestones", [])
	var history_entries: Array = history.get("history_entries", [])
	var attributes: Dictionary = history.get("attributes", {})
	var level_value: int = int(history.get("level", 1))
	var current_xp: int = int(history.get("xp", 0))
	var xp_line: String = (
		"Nível %d — máximo • %d XP vitalício" % [
			level_value,
			int(history.get("lifetime_xp", 0))
		]
		if level_value >= Villager.MAX_LEVEL
		else "Nível %d • %d/%d XP • %d XP vitalício" % [
			level_value,
			current_xp,
			80 + 20 * maxi(0, level_value - 1),
			int(history.get("lifetime_xp", 0))
		]
	)
	var milestone_counts: Dictionary = {
		"food": 0,
		"material": 0,
		"happiness": 0
	}
	for milestone_value: Variant in milestones:
		if not milestone_value is Dictionary:
			continue
		var milestone: Dictionary = milestone_value as Dictionary
		var resource_id: String = String(milestone.get("resource_id", ""))
		if milestone_counts.has(resource_id):
			milestone_counts[resource_id] = int(milestone_counts[resource_id]) + 1
	var spent_points: int = int(history.get("attribute_points_spent", 0))
	var pending_points: int = int(history.get("unspent_attribute_points", 0))

	var lines: Array[String] = [
		"[color=#D9B75B][b]IDENTIDADE[/b][/color]",
		"%s • %s" % [
			String(history.get("species_name", "Espécie desconhecida")),
			String(history.get("personality_name", "Personalidade desconhecida"))
		],
		String(history.get("personality_description", "")),
		"Passiva: %s" % String(history.get("passive_name", "Sem passiva")),
		"",
		"[color=#D9B75B][b]PROGRESSÃO[/b][/color]",
		"Entrou na vila: dia %d" % int(history.get("joined_day", 1)),
		xp_line,
		"Subidas de nível registradas: %d" % int(history.get("level_ups", 0)),
		"Dias no Conselho: %d • Dias na reserva: %d" % [
			int(history.get("days_in_council", 0)),
			int(history.get("days_in_reserve", 0))
		],
		"Pontos recebidos: %d • Distribuídos: %d • Pendentes: %d" % [
			spent_points + pending_points,
			spent_points,
			pending_points
		],
		"FOR %d • INT %d • CAR %d • AGI %d" % [
			int(attributes.get("strength", 0)),
			int(attributes.get("intelligence", 0)),
			int(attributes.get("charisma", 0)),
			int(attributes.get("agility", 0))
		],
		"",
		"[color=#D9B75B][b]PRODUÇÃO PESSOAL[/b][/color]",
		"Alimentação: %.1f" % float(totals.get("food", 0.0)),
		"Material: %.1f" % float(totals.get("material", 0.0)),
		"Felicidade: %.1f" % float(totals.get("happiness", 0.0)),
		"Profissão mais exercida: %s (%d dias)" % [favorite_profession, favorite_days],
		"Marcos de 100 unidades: alimentação %d • material %d • felicidade %d" % [
			int(milestone_counts.get("food", 0)),
			int(milestone_counts.get("material", 0)),
			int(milestone_counts.get("happiness", 0))
		],
		"",
		"[color=#D9B75B][b]ACONTECIMENTOS[/b][/color]",
		"Responsável em %d acontecimento(s)" % int(history.get("events_resolved", 0)),
		"Projetos temporários: %d iniciados • %d concluídos" % [
			int(history.get("council_projects_started", 0)),
			int(history.get("council_projects_completed", 0))
		],
		"Avaliações aprovadas com esta carta ativa: %d" % int(history.get("successful_audits", 0)),
		"Sucessos em testes: %d • Falhas: %d • Soluções garantidas: %d" % [
			event_successes,
			event_failures,
			event_guaranteed
		],
		"",
		"[color=#D9B75B][b]CRÔNICA PESSOAL[/b][/color]"
	]

	if history_entries.is_empty():
		lines.append("Nenhuma conquista importante foi registrada ainda.")
	else:
		var start_index: int = maxi(0, history_entries.size() - 24)
		for index: int in range(history_entries.size() - 1, start_index - 1, -1):
			var entry_value: Variant = history_entries[index]
			if not entry_value is Dictionary:
				continue
			var entry: Dictionary = entry_value as Dictionary
			lines.append(
				"Dia %d — %s" % [
					int(entry.get("day", 1)),
					_format_history_entry(entry)
				]
			)
	return "\n".join(lines)


func _format_history_entry(entry: Dictionary) -> String:
	var entry_type: String = String(entry.get("type", ""))
	match entry_type:
		"production_milestone":
			return "alcançou %d unidades pessoais de %s." % [
				int(entry.get("value", 100)),
				_resource_name(String(entry.get("resource_id", "food")))
			]
		"level_up":
			return "alcançou o nível %d e recebeu um ponto de atributo." % int(entry.get("level", 1))
		"attribute":
			return String(entry.get("title", "distribuiu um ponto de atributo.")) + "."
		"event":
			var result_word: String = (
				"sucesso" if bool(entry.get("succeeded", true)) else "falha"
			)
			if not bool(entry.get("was_test", false)):
				result_word = "solução garantida"
			return "assumiu %s: %s." % [
				String(entry.get("title", "um acontecimento")),
				result_word
			]
		"audit":
			return String(entry.get("title", "participou de uma avaliação aprovada.")) + "."
		"level_dialogue":
			var quality: String = String(entry.get("quality", "neutral"))
			return (
				"transformou a conversa de nível em +1 de %s."
				% _resource_name(String(entry.get("reward_resource", "material")))
				if quality == "best"
				else "concluiu a conversa especial de nível."
			)
		"council_project_started":
			var choice_text: String = String(entry.get("choice_text", "")).strip_edges()
			return (
				"iniciou “%s” ao decidir: %s Efeitos previstos até o dia %d."
				% [
					String(entry.get("title", "Projeto do Conselho")),
					choice_text if not choice_text.is_empty() else "seguir o plano escolhido.",
					int(entry.get("end_day", int(entry.get("day", 1))))
				]
			)
		"council_project_completed":
			var completion_text: String = String(
				entry.get("completion_text", "")
			).strip_edges()
			return "concluiu “%s” e recebeu experiência. %s" % [
				String(entry.get("title", "Projeto do Conselho")),
				completion_text
			]
		"founder_memory_opening", "founder_memory_consequence":
			return String(entry.get("title", "registrou uma lembrança pessoal.")) + "."
		_:
			return String(entry.get("title", "registrou uma conquista."))


func _resource_name(resource_id: String) -> String:
	match resource_id:
		"food": return "alimentação"
		"material": return "material"
		"happiness": return "felicidade"
		_: return "recurso"
