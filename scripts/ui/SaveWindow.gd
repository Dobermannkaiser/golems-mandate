class_name SaveWindow
extends Control


signal save_requested()
signal load_requested()
signal delete_requested()


var overlay: ColorRect
var save_panel: PanelContainer
var current_game_label: Label
var saved_game_label: Label
var autosave_label: Label
var feedback_label: Label
var save_button: Button
var load_button: Button
var delete_button: Button
var close_button: Button
var previous_focus: Control

var current_overview: Dictionary = {}
var confirmation_action: String = ""


func _ready() -> void:
	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_create_window()


func show_window(save_overview: Dictionary) -> void:
	previous_focus = VillageUIAccessibility.remember_focus(self)
	current_overview = save_overview.duplicate(true)
	confirmation_action = ""
	overlay.visible = true
	_refresh_content()

	feedback_label.text = (
		"Salve uma vez para ativar o salvamento "
		+ "automático nesta sessão."
	)

	feedback_label.add_theme_color_override(
		"font_color",
		MedievalTheme.TEXT_MUTED
	)

	if bool(
		current_overview.get(
			"autosave_enabled",
			false
		)
	):
		feedback_label.text = (
			"O salvamento automático está ativo."
		)

		feedback_label.add_theme_color_override(
			"font_color",
			Color("#9FD18B")
		)

	call_deferred("_animate_open")
	VillageUIAccessibility.focus_first_enabled(overlay, save_button)


func refresh_state(save_overview: Dictionary) -> void:
	current_overview = save_overview.duplicate(true)
	_refresh_content()


func show_feedback(
	message: String,
	is_success: bool
) -> void:
	confirmation_action = ""
	_reset_button_texts()
	feedback_label.text = (
		VillageUIAccessibility.mark_feedback(message, is_success)
	)

	feedback_label.add_theme_color_override(
		"font_color",
		(
			Color("#9FD18B")
			if is_success
			else Color("#F07F72")
		)
	)


func hide_window() -> void:
	confirmation_action = ""
	_reset_button_texts()
	overlay.visible = false
	VillageUIAccessibility.restore_focus_deferred(previous_focus)
	previous_focus = null


func is_window_visible() -> bool:
	return (
		is_instance_valid(overlay)
		and overlay.visible
	)


func _refresh_content() -> void:
	if not is_instance_valid(saved_game_label):
		return

	current_game_label.text = (
		"PARTIDA ATUAL\n"
		+ "Dia %d  •  População %d/%d  •  %d casas\n"
		+ "Alimentação %.1f  •  "
		+ "Material %.1f  •  Felicidade %.1f"
	) % [
		int(
			current_overview.get(
				"playing_day",
				1
			)
		),
		int(
			current_overview.get(
				"playing_population",
				0
			)
		),
		int(
			current_overview.get(
				"playing_housing_capacity",
				0
			)
		),
		int(
			current_overview.get(
				"playing_house_count",
				2
			)
		),
		float(
			current_overview.get(
				"playing_food",
				0.0
			)
		),
		float(
			current_overview.get(
				"playing_material",
				0.0
			)
		),
		float(
			current_overview.get(
				"playing_happiness",
				0.0
			)
		)
	]

	var has_save: bool = bool(
		current_overview.get(
			"has_save",
			false
		)
	)

	var is_valid: bool = bool(
		current_overview.get(
			"is_valid",
			false
		)
	)

	load_button.disabled = not is_valid
	delete_button.disabled = not has_save

	if is_valid:
		var status_text: String = _get_status_text(
			String(
				current_overview.get(
					"campaign_status",
					"active"
				)
			)
		)

		var event_text: String = ""

		if bool(
			current_overview.get(
				"has_active_event",
				false
			)
		):
			event_text = "\nAcontecimento pendente preservado."
		if bool(current_overview.get("loaded_from_backup", false)):
			event_text += (
				"\nBackup de segurança recuperado; o próximo save restaurará "
				+ "o arquivo principal sem apagar esse backup válido."
			)

		saved_game_label.text = (
			"CAMPANHA SALVA — %s\n"
			+ "Dia %d  •  População %d/%d  •  %d casas\n"
			+ "%d / 15 melhorias  •  "
			+ "Alimentação %.1f  •  Material %.1f  •  "
			+ "Felicidade %.1f\n"
			+ "Último registro: %s%s"
		) % [
			status_text,
			int(
				current_overview.get(
					"current_day",
					1
				)
			),
			int(
				current_overview.get(
					"population",
					0
				)
			),
			int(
				current_overview.get(
					"housing_capacity",
					0
				)
			),
			int(
				current_overview.get(
					"house_count",
					2
				)
			),
			int(
				current_overview.get(
					"built_upgrades",
					0
				)
			),
			float(
				current_overview.get(
					"food",
					0.0
				)
			),
			float(
				current_overview.get(
					"material",
					0.0
				)
			),
			float(
				current_overview.get(
					"happiness",
					0.0
				)
			),
			String(
				current_overview.get(
					"saved_at_text",
					"data desconhecida"
				)
			),
			event_text
		]

		saved_game_label.add_theme_color_override(
			"font_color",
			MedievalTheme.PARCHMENT_LIGHT
		)

	elif has_save:
		saved_game_label.text = (
			"CAMPANHA SALVA INDISPONÍVEL\n"
			+ String(
				current_overview.get(
					"error",
					"O arquivo não pôde ser lido."
				)
			)
			+ "\nVocê pode excluí-lo e criar um novo save."
		)

		saved_game_label.add_theme_color_override(
			"font_color",
			Color("#F07F72")
		)

	else:
		saved_game_label.text = (
			"NENHUMA CAMPANHA SALVA\n"
			+ "Use SALVAR AGORA para registrar esta vila. "
			+ "Depois disso, o jogo atualizará o mesmo "
			+ "arquivo automaticamente."
		)

		saved_game_label.add_theme_color_override(
			"font_color",
			MedievalTheme.TEXT_MUTED
		)

	autosave_label.text = (
		"AUTOSAVE ATIVO"
		if bool(
			current_overview.get(
				"autosave_enabled",
				false
			)
		)
		else "AUTOSAVE AGUARDANDO PRIMEIRO SAVE"
	)

	autosave_label.add_theme_color_override(
		"font_color",
		(
			Color("#9FD18B")
			if bool(
				current_overview.get(
					"autosave_enabled",
					false
				)
			)
			else MedievalTheme.TEXT_MUTED
		)
	)


func _get_status_text(status: String) -> String:
	match status:
		"victory":
			return "VITÓRIA"

		"defeat":
			return "DERROTA"

		"free_play":
			return "MODO LIVRE"

		_:
			return "EM ANDAMENTO"


func _create_window() -> void:
	overlay = ColorRect.new()
	overlay.name = "SaveOverlay"

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

	overlay.z_index = 140
	overlay.visible = false
	add_child(overlay)

	var center: CenterContainer = CenterContainer.new()

	center.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)

	save_panel = PanelContainer.new()

	save_panel.custom_minimum_size = Vector2(
		760.0,
		500.0
	)

	save_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	save_panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(
			MedievalTheme.WOOD_DARK,
			MedievalTheme.GOLD,
			3,
			12,
			22,
			8
		)
	)

	center.add_child(save_panel)

	var layout: VBoxContainer = VBoxContainer.new()

	layout.add_theme_constant_override(
		"separation",
		12
	)

	save_panel.add_child(layout)

	var section_label: Label = MedievalTheme.create_label(
		"ARQUIVO DA COMUNIDADE",
		MedievalTheme.TEXT_MUTED,
		13
	)

	section_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	layout.add_child(section_label)

	var title_label: Label = MedievalTheme.create_label(
		"SALVAR E CARREGAR",
		MedievalTheme.GOLD,
		27
	)

	title_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	layout.add_child(title_label)

	var divider: HSeparator = HSeparator.new()
	layout.add_child(divider)

	current_game_label = _create_status_panel(
		layout,
		MedievalTheme.WOOD,
		MedievalTheme.GOLD_DARK,
		MedievalTheme.PARCHMENT_LIGHT,
		100.0
	)

	saved_game_label = _create_status_panel(
		layout,
		Color("#30251A"),
		MedievalTheme.GOLD_DARK,
		MedievalTheme.TEXT_MUTED,
		150.0
	)

	autosave_label = MedievalTheme.create_label(
		"",
		MedievalTheme.TEXT_MUTED,
		12
	)

	autosave_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	layout.add_child(autosave_label)

	feedback_label = MedievalTheme.create_label(
		"",
		MedievalTheme.TEXT_MUTED,
		13
	)

	feedback_label.custom_minimum_size = Vector2(
		0.0,
		38.0
	)

	feedback_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	feedback_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	feedback_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	layout.add_child(feedback_label)

	var button_row: HBoxContainer = HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER

	button_row.add_theme_constant_override(
		"separation",
		10
	)

	layout.add_child(button_row)

	save_button = _create_button(
		"SALVAR AGORA",
		160.0
	)

	save_button.pressed.connect(
		_on_save_pressed
	)

	button_row.add_child(save_button)

	load_button = _create_button(
		"CARREGAR",
		145.0
	)

	load_button.pressed.connect(
		_on_load_pressed
	)

	button_row.add_child(load_button)

	delete_button = _create_button(
		"EXCLUIR",
		130.0
	)

	delete_button.pressed.connect(
		_on_delete_pressed
	)

	button_row.add_child(delete_button)

	close_button = _create_button(
		"VOLTAR",
		130.0
	)
	close_button.tooltip_text = "Fecha a janela sem alterar o save."

	close_button.pressed.connect(
		hide_window
	)

	button_row.add_child(close_button)


func _create_status_panel(
	parent: VBoxContainer,
	background_color: Color,
	border_color: Color,
	text_color: Color,
	minimum_height: float
) -> Label:
	var panel: PanelContainer = PanelContainer.new()

	panel.custom_minimum_size = Vector2(
		0.0,
		minimum_height
	)

	panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(
			background_color,
			border_color,
			1,
			7,
			12,
			0
		)
	)

	parent.add_child(panel)

	var label: Label = MedievalTheme.create_label(
		"",
		text_color,
		15
	)

	label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	panel.add_child(label)
	return label


func _create_button(
	button_text: String,
	minimum_width: float
) -> Button:
	var button: Button = Button.new()
	button.text = button_text

	button.custom_minimum_size = Vector2(
		minimum_width,
		46.0
	)

	button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)
	VillageUIAccessibility.configure_button(button, "", 46.0)

	return button


func _on_save_pressed() -> void:
	confirmation_action = ""
	_reset_button_texts()
	save_requested.emit()


func _on_load_pressed() -> void:
	if confirmation_action != "load":
		confirmation_action = "load"
		_reset_button_texts()
		load_button.text = "CONFIRMAR"

		feedback_label.text = (
			"[ATENÇÃO] O carregamento substituirá a partida atual. "
			+ "Clique em CONFIRMAR para continuar."
		)
		VillageUIAccessibility.focus_deferred(load_button)

		feedback_label.add_theme_color_override(
			"font_color",
			Color("#E6C15A")
		)

		return

	confirmation_action = ""
	_reset_button_texts()
	load_requested.emit()


func _on_delete_pressed() -> void:
	if confirmation_action != "delete":
		confirmation_action = "delete"
		_reset_button_texts()
		delete_button.text = "CONFIRMAR"

		feedback_label.text = (
			"[ATENÇÃO] Esta ação apaga o arquivo salvo. "
			+ "Clique em CONFIRMAR para excluir."
		)
		VillageUIAccessibility.focus_deferred(delete_button)

		feedback_label.add_theme_color_override(
			"font_color",
			Color("#E6C15A")
		)

		return

	confirmation_action = ""
	_reset_button_texts()
	delete_requested.emit()


func _reset_button_texts() -> void:
	if is_instance_valid(save_button):
		save_button.text = "SALVAR AGORA"

	if is_instance_valid(load_button):
		load_button.text = "CARREGAR"

	if is_instance_valid(delete_button):
		delete_button.text = "EXCLUIR"


func _animate_open() -> void:
	if not is_instance_valid(save_panel):
		return

	save_panel.pivot_offset = save_panel.size * 0.5

	if GameSettings.reduced_motion:
		save_panel.modulate = Color.WHITE
		save_panel.scale = Vector2.ONE
		return

	save_panel.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.0
	)

	save_panel.scale = Vector2(
		0.96,
		0.96
	)

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		save_panel,
		"modulate",
		Color.WHITE,
		0.22
	)

	tween.tween_property(
		save_panel,
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
		if not confirmation_action.is_empty():
			confirmation_action = ""
			_reset_button_texts()
			feedback_label.text = "Confirmação cancelada."
			VillageUIAccessibility.focus_deferred(close_button)
		else:
			hide_window()
		get_viewport().set_input_as_handled()


func _make_panel_style(
	background_color: Color,
	border_color: Color,
	border_width: int,
	corner_radius: int,
	content_margin: int,
	shadow_size: int
) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = background_color
	style.border_color = border_color

	style.set_border_width_all(border_width)
	style.set_corner_radius_all(corner_radius)

	style.content_margin_left = content_margin
	style.content_margin_top = content_margin
	style.content_margin_right = content_margin
	style.content_margin_bottom = content_margin

	style.shadow_color = Color(
		0.0,
		0.0,
		0.0,
		0.42
	)

	style.shadow_size = shadow_size
	return style
