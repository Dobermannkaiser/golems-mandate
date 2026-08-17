class_name MainMenu
extends Control


signal continue_requested()
signal new_campaign_requested()
signal load_requested()
signal tutorial_requested(opened_from_game: bool)
signal quit_requested()


var overlay: ColorRect
var menu_panel: PanelContainer
var page_holder: Control

var main_page: VBoxContainer
var load_page: VBoxContainer
var settings_page: VBoxContainer
var confirmation_page: VBoxContainer
var records_page: VBoxContainer

var continue_button: Button
var load_button: Button
var new_campaign_button: Button
var quit_button: Button
var main_status_label: Label
var main_feedback_label: Label
var load_details_label: Label
var confirmation_title_label: Label
var confirmation_text_label: Label
var best_medal_button: Button
var records_details_label: Label

var audio_labels: Dictionary = {}
var mute_button: Button
var fullscreen_button: Button
var motion_button: Button
var instant_text_button: Button
var contrast_button: Button
var accessibility_defaults_button: Button
var page_focus_targets: Dictionary = {}
var confirmation_cancel_button: Button

var save_overview: Dictionary = {}
var opened_from_game: bool = false
var confirmation_action: String = ""
var previous_focus: Control


func _ready() -> void:
	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_create_menu()


func show_menu(
	overview: Dictionary,
	from_game: bool = false
) -> void:
	if not is_menu_visible():
		previous_focus = VillageUIAccessibility.remember_focus(self)
	save_overview = overview.duplicate(true)
	opened_from_game = from_game
	confirmation_action = ""
	AudioManager.enter_menu(from_game)

	overlay.visible = true
	_refresh_main_page()
	_refresh_best_medal()
	_show_page(main_page)

	main_feedback_label.text = ""
	call_deferred("_animate_open")


func show_settings(
	overview: Dictionary,
	from_game: bool = true
) -> void:
	show_menu(overview, from_game)
	_refresh_settings_page()
	_show_page(settings_page)


func show_new_campaign_confirmation(
	overview: Dictionary
) -> void:
	show_menu(overview, true)

	_show_confirmation(
		"new_campaign",
		"INICIAR NOVA CAMPANHA?",
		"Uma nova vila apagará o slot salvo e substituirá "
		+ "o progresso atual.\n\nEsta ação não pode ser "
		+ "desfeita."
	)


func hide_menu() -> void:
	confirmation_action = ""

	# O Godot não limpa foco de teclado automaticamente quando um Control
	# fica invisível. Sem isto, o botão que estava focado no menu continua
	# sendo o "dono do foco" da viewport mesmo escondido — e pode voltar a
	# receber navegação por teclado/gamepad mais tarde, mesmo com outra
	# janela aberta por cima. Libera o foco só se ele ainda pertence a este
	# menu, pra não interferir em foco de outras telas por engano.
	var viewport: Viewport = get_viewport()
	if is_instance_valid(viewport):
		var focus_owner: Control = viewport.gui_get_focus_owner()
		if (
			is_instance_valid(focus_owner)
			and is_instance_valid(overlay)
			and overlay.is_ancestor_of(focus_owner)
		):
			viewport.gui_release_focus()

	overlay.visible = false
	var restore_root: Control
	var parent_node: Node = get_parent()
	if (
		is_instance_valid(parent_node)
		and parent_node.has_method("get_focus_restore_root")
	):
		restore_root = parent_node.call("get_focus_restore_root") as Control
	VillageUIAccessibility.restore_focus_deferred(
		previous_focus,
		restore_root
	)
	previous_focus = null
	if opened_from_game:
		var season: Dictionary = GameManager.get_current_season()
		AudioManager.enter_game(String(season.get("id", "spring")))


func is_menu_visible() -> bool:
	return (
		is_instance_valid(overlay)
		and overlay.visible
	)


func get_active_focus_root() -> Control:
	if is_instance_valid(main_page) and main_page.visible:
		# Na página principal, o atalho de medalhas faz parte do menu.
		return overlay
	for page: VBoxContainer in [
		load_page,
		settings_page,
		confirmation_page,
		records_page
	]:
		if is_instance_valid(page) and page.visible:
			return page
	return overlay


func refresh_save_overview(
	overview: Dictionary
) -> void:
	save_overview = overview.duplicate(true)
	_refresh_main_page()

	if load_page.visible:
		_refresh_load_page()


func show_feedback(
	message: String,
	is_success: bool
) -> void:
	_refresh_main_page()
	_show_page(main_page)
	main_feedback_label.text = (
		VillageUIAccessibility.mark_feedback(message, is_success)
	)

	main_feedback_label.add_theme_color_override(
		"font_color",
		(
			Color("#9FD18B")
			if is_success
			else Color("#F07F72")
		)
	)


func _create_menu() -> void:
	overlay = ColorRect.new()
	overlay.name = "MainMenuOverlay"

	overlay.color = Color(
		0.045,
		0.055,
		0.038,
		0.97
	)

	overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	overlay.z_index = 300
	overlay.visible = false
	add_child(overlay)

	var center: CenterContainer = CenterContainer.new()

	center.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)

	menu_panel = PanelContainer.new()
	menu_panel.name = "MainMenuPanel"

	menu_panel.custom_minimum_size = Vector2(
		720.0,
		610.0
	)

	menu_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	menu_panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(
			MedievalTheme.WOOD_DARK,
			MedievalTheme.GOLD,
			3,
			14,
			26,
			8
		)
	)

	center.add_child(menu_panel)

	var root_layout: VBoxContainer = VBoxContainer.new()

	root_layout.add_theme_constant_override(
		"separation",
		8
	)

	menu_panel.add_child(root_layout)

	var pretitle: Label = MedievalTheme.create_label(
		"UMA COMUNIDADE, 120 DIAS, MUITAS ESCOLHAS",
		MedievalTheme.TEXT_MUTED,
		12
	)

	pretitle.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	root_layout.add_child(pretitle)

	var title: Label = MedievalTheme.create_label(
		"GOLEM'S MANDATE",
		MedievalTheme.GOLD,
		38
	)

	title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	root_layout.add_child(title)

	var subtitle: Label = MedievalTheme.create_label(
		"Construa, organize os habitantes e mantenha "
		+ "a vila viva até o fim da campanha.",
		MedievalTheme.PARCHMENT_LIGHT,
		15
	)

	subtitle.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	root_layout.add_child(subtitle)

	var medal_row: HBoxContainer = HBoxContainer.new()
	medal_row.alignment = BoxContainer.ALIGNMENT_CENTER
	medal_row.add_theme_constant_override("separation", 4)
	root_layout.add_child(medal_row)

	best_medal_button = Button.new()
	best_medal_button.text = "SEM CAMPANHAS CONCLUÍDAS"
	best_medal_button.custom_minimum_size = Vector2(0.0, 30.0)
	best_medal_button.flat = true
	best_medal_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	best_medal_button.add_theme_font_size_override("font_size", 13)
	best_medal_button.pressed.connect(_on_records_pressed)
	medal_row.add_child(best_medal_button)

	var divider: HSeparator = HSeparator.new()
	root_layout.add_child(divider)

	page_holder = Control.new()
	page_holder.name = "Pages"

	page_holder.custom_minimum_size = Vector2(
		0.0,
		390.0
	)

	page_holder.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)
	# Evita que páginas maiores que o espaço disponível sejam
	# desenhadas para fora da moldura do menu.
	page_holder.clip_contents = true

	root_layout.add_child(page_holder)

	main_page = _create_page("MainPage")
	load_page = _create_page("LoadPage")
	settings_page = _create_page("SettingsPage")
	confirmation_page = _create_page(
		"ConfirmationPage"
	)
	records_page = _create_page("RecordsPage")

	_build_main_page()
	_build_load_page()
	_build_settings_page()
	_build_confirmation_page()
	_build_records_page()

	var version_color: Color = MedievalTheme.TEXT_MUTED
	version_color.a = 0.55

	var footer: Label = MedievalTheme.create_label(
		"v%s" % str(
		ProjectSettings.get_setting(
			"application/config/version",
				"3.11.7"
			)
		),
		version_color,
		10
	)

	footer.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_RIGHT
	)

	root_layout.add_child(footer)


func _create_page(page_name: String) -> VBoxContainer:
	var page: VBoxContainer = VBoxContainer.new()
	page.name = page_name

	page.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	page.add_theme_constant_override(
		"separation",
		9
	)

	page.visible = false
	page_holder.add_child(page)
	return page


func _build_main_page() -> void:
	main_status_label = _create_status_panel(
		main_page,
		70.0
	)

	continue_button = _create_menu_button(
		"CONTINUAR",
		330.0
	)

	continue_button.pressed.connect(
		_on_continue_pressed
	)

	_add_centered_control(
		main_page,
		continue_button
	)
	page_focus_targets[main_page.name] = continue_button

	new_campaign_button = (
		_create_menu_button(
			"NOVA CAMPANHA",
			330.0
		)
	)

	new_campaign_button.pressed.connect(
		_on_new_campaign_pressed
	)

	_add_centered_control(
		main_page,
		new_campaign_button
	)

	load_button = _create_menu_button(
		"CARREGAR",
		330.0
	)

	load_button.pressed.connect(
		_on_open_load_pressed
	)

	_add_centered_control(
		main_page,
		load_button
	)

	var tutorial_button: Button = _create_menu_button(
		"GUIA DO JOGO",
		330.0
	)

	tutorial_button.pressed.connect(
		_on_tutorial_pressed
	)

	_add_centered_control(
		main_page,
		tutorial_button
	)

	var settings_button: Button = _create_menu_button(
		"CONFIGURAÇÕES",
		330.0
	)

	settings_button.pressed.connect(
		_on_settings_pressed
	)

	_add_centered_control(
		main_page,
		settings_button
	)

	quit_button = _create_menu_button(
		"SAIR DO JOGO",
		330.0
	)

	quit_button.pressed.connect(
		_on_quit_pressed
	)

	_add_centered_control(
		main_page,
		quit_button
	)
	_apply_quiet_emphasis(quit_button)

	# Navegação explícita por teclado/gamepad entre os botões do menu
	# principal. O Godot calcula vizinho de foco por posição espacial
	# quando não é definido, mas isso é frágil em qualquer reflow futuro do
	# layout — fixar explicitamente garante ordem previsível de cima pra
	# baixo, com wrap do último pro primeiro e vice-versa.
	var main_menu_order: Array[Button] = [
		continue_button,
		new_campaign_button,
		load_button,
		tutorial_button,
		settings_button,
		quit_button
	]
	for i in main_menu_order.size():
		var current: Button = main_menu_order[i]
		var next: Button = main_menu_order[(i + 1) % main_menu_order.size()]
		var previous: Button = main_menu_order[
			(i - 1 + main_menu_order.size()) % main_menu_order.size()
		]
		current.focus_neighbor_bottom = current.get_path_to(next)
		current.focus_neighbor_top = current.get_path_to(previous)

	main_feedback_label = MedievalTheme.create_label(
		"",
		MedievalTheme.TEXT_MUTED,
		12
	)

	main_feedback_label.custom_minimum_size = Vector2(
		0.0,
		28.0
	)

	main_feedback_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	main_feedback_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	main_feedback_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	main_page.add_child(main_feedback_label)


func _build_load_page() -> void:
	var section: Label = MedievalTheme.create_label(
		"ARQUIVO DA COMUNIDADE",
		MedievalTheme.TEXT_MUTED,
		13
	)

	section.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	load_page.add_child(section)

	var title: Label = MedievalTheme.create_label(
		"CARREGAR CAMPANHA",
		MedievalTheme.GOLD,
		26
	)

	title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	load_page.add_child(title)

	load_details_label = _create_status_panel(
		load_page,
		190.0
	)

	var load_selected_button: Button = (
		_create_menu_button(
			"CARREGAR ESTA CAMPANHA",
			330.0
		)
	)

	load_selected_button.pressed.connect(
		_on_load_selected_pressed
	)

	_add_centered_control(
		load_page,
		load_selected_button
	)
	page_focus_targets[load_page.name] = load_selected_button

	var back_button: Button = _create_menu_button(
		"VOLTAR",
		220.0
	)

	back_button.pressed.connect(
		_show_main_page
	)

	_add_centered_control(
		load_page,
		back_button
	)


func _build_settings_page() -> void:
	var section: Label = MedievalTheme.create_label(
		"PREFERÊNCIAS DO JOGADOR",
		MedievalTheme.TEXT_MUTED,
		13
	)
	section.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_page.add_child(section)

	var title: Label = MedievalTheme.create_label(
		"CONFIGURAÇÕES",
		MedievalTheme.GOLD,
		26
	)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_page.add_child(title)

	var scroll: ScrollContainer = ScrollContainer.new()
	# O cabeçalho e o botão VOLTAR também ocupam a página. Uma
	# altura mínima grande fazia o conteúdo ultrapassar o painel.
	scroll.custom_minimum_size = Vector2(0.0, 220.0)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.clip_contents = true
	settings_page.add_child(scroll)

	var scroll_layout: VBoxContainer = VBoxContainer.new()
	scroll_layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_layout.add_theme_constant_override("separation", 10)
	scroll.add_child(scroll_layout)

	var audio_panel: PanelContainer = PanelContainer.new()
	audio_panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(
			MedievalTheme.WOOD,
			MedievalTheme.GOLD_DARK,
			1,
			8,
			12,
			2
		)
	)
	scroll_layout.add_child(audio_panel)

	var audio_layout: VBoxContainer = VBoxContainer.new()
	audio_layout.add_theme_constant_override("separation", 7)
	audio_panel.add_child(audio_layout)

	var audio_title: Label = MedievalTheme.create_label(
		"CANAIS DE ÁUDIO",
		MedievalTheme.GOLD,
		16
	)
	audio_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	audio_layout.add_child(audio_title)

	_create_audio_setting_row(
		audio_layout,
		"master",
		"VOLUME GERAL",
		"master_volume_percent"
	)
	_create_audio_setting_row(
		audio_layout,
		"music",
		"MÚSICA",
		"music_volume_percent"
	)
	_create_audio_setting_row(
		audio_layout,
		"ambience",
		"AMBIENTE",
		"ambience_volume_percent"
	)
	_create_audio_setting_row(
		audio_layout,
		"effects",
		"EFEITOS",
		"effects_volume_percent"
	)
	_create_audio_setting_row(
		audio_layout,
		"interface",
		"INTERFACE",
		"interface_volume_percent"
	)

	var audio_actions: HBoxContainer = HBoxContainer.new()
	audio_actions.alignment = BoxContainer.ALIGNMENT_CENTER
	audio_actions.add_theme_constant_override("separation", 10)
	audio_layout.add_child(audio_actions)

	mute_button = _create_menu_button("SILENCIAR TUDO: NÃO", 240.0)
	mute_button.pressed.connect(_on_master_mute_pressed)
	audio_actions.add_child(mute_button)

	var defaults_button: Button = _create_menu_button(
		"RESTAURAR ÁUDIO",
		190.0
	)
	defaults_button.pressed.connect(_on_restore_audio_pressed)
	audio_actions.add_child(defaults_button)

	fullscreen_button = _create_menu_button(
		"TELA CHEIA: NÃO",
		0.0
	)
	fullscreen_button.pressed.connect(_on_fullscreen_pressed)
	scroll_layout.add_child(fullscreen_button)

	motion_button = _create_menu_button(
		"REDUZIR ANIMAÇÕES: NÃO",
		0.0
	)
	motion_button.pressed.connect(_on_motion_pressed)
	scroll_layout.add_child(motion_button)

	instant_text_button = _create_menu_button(
		"TEXTO INSTANTÂNEO: NÃO",
		0.0
	)
	instant_text_button.tooltip_text = (
		"Mostra falas completas sem o efeito de escrita."
	)
	instant_text_button.pressed.connect(_on_instant_text_pressed)
	scroll_layout.add_child(instant_text_button)

	contrast_button = _create_menu_button(
		"CONTRASTE REFORÇADO: NÃO",
		0.0
	)
	contrast_button.tooltip_text = (
		"Escurece painéis e reforça bordas, foco e realces."
	)
	contrast_button.pressed.connect(_on_contrast_pressed)
	scroll_layout.add_child(contrast_button)

	accessibility_defaults_button = _create_menu_button(
		"RESTAURAR ACESSIBILIDADE",
		0.0
	)
	accessibility_defaults_button.tooltip_text = (
		"Restaura animações, texto e contraste aos padrões."
	)
	accessibility_defaults_button.pressed.connect(
		_on_restore_accessibility_pressed
	)
	scroll_layout.add_child(accessibility_defaults_button)
	page_focus_targets[settings_page.name] = mute_button

	var settings_note: Label = MedievalTheme.create_label(
		"As alterações são aplicadas imediatamente. "
		+ "Use TESTAR para ouvir cada canal. Teclado e controle "
		+ "podem navegar por todos os botões.",
		MedievalTheme.TEXT_MUTED,
		12
	)
	settings_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scroll_layout.add_child(settings_note)

	var back_button: Button = _create_menu_button(
		"VOLTAR",
		220.0
	)
	back_button.pressed.connect(_show_main_page)
	_add_centered_control(settings_page, back_button)


func _create_audio_setting_row(
	parent: VBoxContainer,
	channel_id: String,
	label_text: String,
	setting_key: String
) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)

	var label: Label = MedievalTheme.create_label(
		"%s: 0%%" % label_text,
		MedievalTheme.PARCHMENT_LIGHT,
		14
	)
	label.custom_minimum_size = Vector2(250.0, 0.0)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	audio_labels[channel_id] = label

	var down_button: Button = _create_menu_button("−10", 72.0)
	down_button.pressed.connect(
		_on_audio_volume_changed.bind(setting_key, -10)
	)
	row.add_child(down_button)

	var up_button: Button = _create_menu_button("+10", 72.0)
	up_button.pressed.connect(
		_on_audio_volume_changed.bind(setting_key, 10)
	)
	row.add_child(up_button)

	var test_button: Button = _create_menu_button("TESTAR", 92.0)
	test_button.pressed.connect(
		_on_audio_test_pressed.bind(channel_id)
	)
	row.add_child(test_button)


func _build_confirmation_page() -> void:
	var section: Label = MedievalTheme.create_label(
		"CONFIRMAÇÃO NECESSÁRIA",
		MedievalTheme.TEXT_MUTED,
		13
	)

	section.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	confirmation_page.add_child(section)

	confirmation_title_label = MedievalTheme.create_label(
		"CONFIRMAR AÇÃO",
		MedievalTheme.GOLD,
		26
	)

	confirmation_title_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	confirmation_page.add_child(
		confirmation_title_label
	)

	confirmation_text_label = _create_status_panel(
		confirmation_page,
		190.0
	)

	var confirm_button: Button = _create_menu_button(
		"CONFIRMAR",
		300.0
	)

	confirm_button.pressed.connect(
		_on_confirmation_accepted
	)

	_add_centered_control(
		confirmation_page,
		confirm_button
	)

	confirmation_cancel_button = _create_menu_button(
		"CANCELAR",
		220.0
	)
	var cancel_button: Button = confirmation_cancel_button

	cancel_button.pressed.connect(
		_show_main_page
	)

	_add_centered_control(
		confirmation_page,
		cancel_button
	)
	page_focus_targets[confirmation_page.name] = cancel_button


func _build_records_page() -> void:
	var title: Label = MedievalTheme.create_label(
		"HISTÓRICO DE CAMPANHAS",
		MedievalTheme.GOLD,
		22
	)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	records_page.add_child(title)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	records_page.add_child(scroll)

	records_details_label = MedievalTheme.create_label(
		"",
		MedievalTheme.PARCHMENT_LIGHT,
		14
	)
	records_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	records_details_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(records_details_label)

	var back_button: Button = _create_menu_button("VOLTAR", 220.0)
	back_button.pressed.connect(_show_main_page)
	_add_centered_control(records_page, back_button)
	page_focus_targets[records_page.name] = back_button


func _refresh_best_medal() -> void:
	if not is_instance_valid(best_medal_button):
		return
	var recent: Dictionary = VillageCampaignRecords.get_recent_record()
	if recent.is_empty():
		best_medal_button.text = "SEM CAMPANHAS CONCLUÍDAS"
		best_medal_button.disabled = true
		return
	best_medal_button.disabled = false
	best_medal_button.text = (
		"ÚLTIMA: %s — %s  •  ABRIR HISTÓRICO"
		% [
			String(recent.get("village_name", "Vila")).to_upper(),
			String(recent.get("campaign_profile_name", "Administração Equilibrada")).to_upper()
		]
	)


func _refresh_records_page() -> void:
	if not is_instance_valid(records_details_label):
		return
	var records: Array[Dictionary] = VillageCampaignRecords.get_all_records()
	if records.is_empty():
		records_details_label.text = "Nenhuma campanha concluída ainda."
		return
	var lines: Array[String] = []
	var limit: int = mini(10, records.size())
	for index: int in range(limit):
		var record: Dictionary = records[index]
		lines.append(
			(
				"%d. %s — %s — %s\n"
				+ "%s  •  Prefeito %s  •  População %d  •  Semente %d  •  %s\n%s"
			) % [
				index + 1,
				String(record.get("village_name", "Vila")).to_upper(),
				(
					"APROVADA"
					if String(record.get("status", "victory")) == "victory"
					else "ENCERRADA"
				),
				String(record.get("campaign_profile_name", "Administração Equilibrada")).to_upper(),
				String(record.get("difficulty_name", "Moderada")),
				String(record.get("player_name", "Alex")),
				int(record.get("population", 0)),
				int(record.get("campaign_seed", 0)),
				String(record.get("completed_at_text", "data desconhecida")),
				String(record.get("campaign_profile_description", ""))
			]
		)
	records_details_label.text = "\n\n".join(lines)


func _on_records_pressed() -> void:
	_refresh_records_page()
	_show_page(records_page)


func _refresh_main_page() -> void:
	if not is_instance_valid(main_status_label):
		return

	var is_valid: bool = bool(
		save_overview.get(
			"is_valid",
			false
		)
	)

	load_button.disabled = not is_valid

	if opened_from_game:
		continue_button.text = "VOLTAR À VILA"
		continue_button.disabled = false
		_apply_primary_emphasis(continue_button)
		_clear_emphasis(new_campaign_button)

		main_status_label.text = (
			"%s — DIA %d — SEMENTE %d\n"
			+ "População %d/%d  •  %d casas  •  "
			+ "Alimentação %.1f  •  Material %.1f  •  "
			+ "Felicidade %.1f"
		) % [
			String(save_overview.get("playing_village_name", "VILA ATUAL")).to_upper(),
			int(
				save_overview.get(
					"playing_day",
					1
				)
			),
			int(save_overview.get("playing_campaign_seed", 0)),
			int(
				save_overview.get(
					"playing_population",
					0
				)
			),
			int(
				save_overview.get(
					"playing_housing_capacity",
					0
				)
			),
			int(
				save_overview.get(
					"playing_house_count",
					2
				)
			),
			float(
				save_overview.get(
					"playing_food",
					0.0
				)
			),
			float(
				save_overview.get(
					"playing_material",
					0.0
				)
			),
			float(
				save_overview.get(
					"playing_happiness",
					0.0
				)
			)
		]

	elif is_valid:
		continue_button.text = "CONTINUAR"
		continue_button.disabled = false
		_apply_primary_emphasis(continue_button)
		_clear_emphasis(new_campaign_button)

		main_status_label.text = (
			"%s — %s — DIA %d — SEMENTE %d\n"
			+ "População %d/%d  •  %d casas  •  "
			+ "%d / 15 melhorias  •  %s"
		) % [
			String(save_overview.get("village_name", "CAMPANHA SALVA")).to_upper(),
			String(save_overview.get("difficulty_name", "Moderada")).to_upper(),
			int(
				save_overview.get(
					"current_day",
					1
				)
			),
			int(save_overview.get("campaign_seed", 0)),
			int(
				save_overview.get(
					"population",
					0
				)
			),
			int(
				save_overview.get(
					"housing_capacity",
					0
				)
			),
			int(
				save_overview.get(
					"house_count",
					2
				)
			),
			int(
				save_overview.get(
					"built_upgrades",
					0
				)
			),
			_get_status_text(
				String(
					save_overview.get(
						"campaign_status",
						"active"
					)
				)
			)
		]
		if bool(save_overview.get("loaded_from_backup", false)):
			main_status_label.text += (
				"\nBACKUP DE SEGURANÇA RECUPERADO — continue; o próximo save "
				+ "restaurará o arquivo principal."
			)

	else:
		continue_button.text = "CONTINUAR"
		continue_button.disabled = true
		_clear_emphasis(continue_button)
		_apply_primary_emphasis(new_campaign_button)

		if bool(
			save_overview.get(
				"has_save",
				false
			)
		):
			main_status_label.text = (
				"O ARQUIVO SALVO NÃO PÔDE SER CARREGADO\n"
				+ String(
					save_overview.get(
						"error",
						"Save incompatível."
					)
				)
			)
		else:
			main_status_label.text = (
				"NENHUMA CAMPANHA SALVA\n"
				+ "Inicie uma nova comunidade para jogar."
			)


func _refresh_load_page() -> void:
	var is_valid: bool = bool(
		save_overview.get(
			"is_valid",
			false
		)
	)

	if not is_valid:
		load_details_label.text = (
			"Nenhuma campanha válida está disponível."
		)

		return

	var event_text: String = (
		"\nAcontecimento pendente: SIM"
		if bool(
			save_overview.get(
				"has_active_event",
				false
			)
		)
		else "\nAcontecimento pendente: NÃO"
	)

	var saved_player_name: String = String(
		save_overview.get("player_name", "Alex")
	).strip_edges()
	if saved_player_name.is_empty():
		saved_player_name = "Alex"

	load_details_label.text = (
		"%s — CAMPANHA %s — %s — PREFEITO %s\n"
		+ "Dia %d  •  População %d/%d  •  %d casas\n"
		+ "%d / 15 melhorias  •  "
		+ "Alimentação %.1f  •  Material %.1f  •  "
		+ "Felicidade %.1f\n"
		+ "Semente %d • gerador v%d  •  Último registro: %s%s"
	) % [
		String(save_overview.get("village_name", "Vila")).to_upper(),
		_get_status_text(
			String(
				save_overview.get(
					"campaign_status",
					"active"
				)
			)
		),
		String(save_overview.get("difficulty_name", "Moderada")).to_upper(),
		saved_player_name.to_upper(),
		int(
			save_overview.get(
				"current_day",
				1
			)
		),
		int(
			save_overview.get(
				"population",
				0
			)
		),
		int(
			save_overview.get(
				"housing_capacity",
				0
			)
		),
		int(
			save_overview.get(
				"house_count",
				2
			)
		),
		int(
			save_overview.get(
				"built_upgrades",
				0
			)
		),
		float(
			save_overview.get(
				"food",
				0.0
			)
		),
		float(
			save_overview.get(
				"material",
				0.0
			)
		),
		float(
			save_overview.get(
				"happiness",
				0.0
			)
		),
		int(save_overview.get("campaign_seed", 0)),
		int(save_overview.get("generator_version", 1)),
		String(
			save_overview.get(
				"saved_at_text",
				"data desconhecida"
			)
		),
		event_text
	]


func _refresh_settings_page() -> void:
	var settings: Dictionary = GameSettings.get_settings()
	var channel_data: Array[Dictionary] = [
		{
			"id": "master",
			"title": "VOLUME GERAL",
			"key": "master_volume_percent",
			"fallback": 80
		},
		{
			"id": "music",
			"title": "MÚSICA",
			"key": "music_volume_percent",
			"fallback": 60
		},
		{
			"id": "ambience",
			"title": "AMBIENTE",
			"key": "ambience_volume_percent",
			"fallback": 45
		},
		{
			"id": "effects",
			"title": "EFEITOS",
			"key": "effects_volume_percent",
			"fallback": 70
		},
		{
			"id": "interface",
			"title": "INTERFACE",
			"key": "interface_volume_percent",
			"fallback": 55
		}
	]
	for channel: Dictionary in channel_data:
		var channel_id: String = String(channel.get("id", ""))
		var label_value: Variant = audio_labels.get(channel_id)
		if not label_value is Label:
			continue
		var label: Label = label_value as Label
		var percent: int = int(
			settings.get(
				String(channel.get("key", "")),
				int(channel.get("fallback", 50))
			)
		)
		label.text = "%s: %d%%" % [
			String(channel.get("title", "ÁUDIO")),
			percent
		]

	var muted: bool = bool(settings.get("master_muted", false))
	var fullscreen: bool = bool(
		settings.get("fullscreen_enabled", false)
	)
	var motion_reduced: bool = bool(
		settings.get("reduced_motion", false)
	)
	var instant_text: bool = bool(
		settings.get("instant_dialogue_text", false)
	)
	var enhanced_contrast: bool = bool(
		settings.get("enhanced_contrast", false)
	)
	mute_button.text = (
		"SILENCIAR TUDO: SIM"
		if muted
		else "SILENCIAR TUDO: NÃO"
	)
	fullscreen_button.text = (
		"TELA CHEIA: SIM"
		if fullscreen
		else "TELA CHEIA: NÃO"
	)
	motion_button.text = (
		"REDUZIR ANIMAÇÕES: SIM"
		if motion_reduced
		else "REDUZIR ANIMAÇÕES: NÃO"
	)
	instant_text_button.text = (
		"TEXTO INSTANTÂNEO: SIM"
		if instant_text
		else "TEXTO INSTANTÂNEO: NÃO"
	)
	contrast_button.text = (
		"CONTRASTE REFORÇADO: SIM"
		if enhanced_contrast
		else "CONTRASTE REFORÇADO: NÃO"
	)


func _show_confirmation(
	action: String,
	title_text: String,
	body_text: String
) -> void:
	confirmation_action = action
	confirmation_title_label.text = title_text
	confirmation_text_label.text = body_text
	_show_page(confirmation_page)


func _show_page(page: VBoxContainer) -> void:
	for page_node: VBoxContainer in [
		main_page,
		load_page,
		settings_page,
		confirmation_page,
		records_page
	]:
		page_node.visible = page_node == page
	var preferred_value: Variant = page_focus_targets.get(page.name)
	var preferred: Control = (
		preferred_value as Control
		if preferred_value is Control
		else null
	)
	VillageUIAccessibility.focus_first_enabled(page, preferred)


func _show_main_page() -> void:
	confirmation_action = ""
	_refresh_main_page()
	_show_page(main_page)


func _on_continue_pressed() -> void:
	if opened_from_game:
		hide_menu()
		return

	continue_button.disabled = true
	main_feedback_label.text = "Carregando a comunidade..."
	continue_requested.emit()


func _on_new_campaign_pressed() -> void:
	var has_any_save: bool = bool(
		save_overview.get(
			"has_save",
			false
		)
	)

	if opened_from_game or has_any_save:
		_show_confirmation(
			"new_campaign",
			"INICIAR NOVA CAMPANHA?",
			"Uma nova vila apagará o slot salvo e substituirá "
			+ "o progresso atual.\n\nEsta ação não pode ser "
			+ "desfeita."
		)

		return

	new_campaign_requested.emit()


func _on_open_load_pressed() -> void:
	if not bool(
		save_overview.get(
			"is_valid",
			false
		)
	):
		return

	_refresh_load_page()
	_show_page(load_page)


func _on_load_selected_pressed() -> void:
	var warning_text: String = (
		"A campanha do slot será restaurada exatamente "
		+ "como foi salva."
	)

	if opened_from_game:
		warning_text += (
			"\n\nO estado atual da vila será substituído."
		)

	_show_confirmation(
		"load_campaign",
		"CARREGAR CAMPANHA?",
		warning_text
	)


func _on_settings_pressed() -> void:
	_refresh_settings_page()
	_show_page(settings_page)


func _on_tutorial_pressed() -> void:
	tutorial_requested.emit(opened_from_game)


func _on_audio_volume_changed(
	setting_key: String,
	delta: int
) -> void:
	var settings: Dictionary = GameSettings.get_settings()
	settings[setting_key] = clampi(
		int(settings.get(setting_key, 50)) + delta,
		0,
		100
	)
	GameSettings.update_settings(settings)
	_refresh_settings_page()


func _on_audio_test_pressed(channel_id: String) -> void:
	AudioManager.test_channel(channel_id)


func _on_master_mute_pressed() -> void:
	var settings: Dictionary = GameSettings.get_settings()
	settings["master_muted"] = not bool(
		settings.get("master_muted", false)
	)
	GameSettings.update_settings(settings)
	_refresh_settings_page()
	if not bool(settings.get("master_muted", false)):
		AudioManager.test_channel("master")


func _on_restore_audio_pressed() -> void:
	GameSettings.restore_audio_defaults()
	_refresh_settings_page()
	AudioManager.test_channel("master")


func _on_fullscreen_pressed() -> void:
	var settings: Dictionary = (
		GameSettings.get_settings()
	)

	settings["fullscreen_enabled"] = not bool(
		settings.get(
			"fullscreen_enabled",
			false
		)
	)

	GameSettings.update_settings(settings)
	_refresh_settings_page()


func _on_motion_pressed() -> void:
	var settings: Dictionary = (
		GameSettings.get_settings()
	)

	settings["reduced_motion"] = not bool(
		settings.get(
			"reduced_motion",
			false
		)
	)

	GameSettings.update_settings(settings)
	_refresh_settings_page()


func _on_instant_text_pressed() -> void:
	var settings: Dictionary = GameSettings.get_settings()
	settings["instant_dialogue_text"] = not bool(
		settings.get("instant_dialogue_text", false)
	)
	GameSettings.update_settings(settings)
	_refresh_settings_page()


func _on_contrast_pressed() -> void:
	var settings: Dictionary = GameSettings.get_settings()
	settings["enhanced_contrast"] = not bool(
		settings.get("enhanced_contrast", false)
	)
	GameSettings.update_settings(settings)
	_refresh_settings_page()


func _on_restore_accessibility_pressed() -> void:
	GameSettings.restore_accessibility_defaults()
	_refresh_settings_page()


func _on_quit_pressed() -> void:
	_show_confirmation(
		"quit_game",
		"SAIR DO JOGO?",
		"O jogo será encerrado. Progresso sem um save "
		+ "ativo não poderá ser recuperado."
	)


func _on_confirmation_accepted() -> void:
	match confirmation_action:
		"new_campaign":
			new_campaign_requested.emit()

		"load_campaign":
			load_requested.emit()

		"quit_game":
			quit_requested.emit()


func _animate_open() -> void:
	if not is_instance_valid(menu_panel):
		return

	menu_panel.pivot_offset = menu_panel.size * 0.5

	if GameSettings.reduced_motion:
		menu_panel.modulate = Color.WHITE
		menu_panel.scale = Vector2.ONE
		return

	menu_panel.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.0
	)

	menu_panel.scale = Vector2(0.97, 0.97)

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		menu_panel,
		"modulate",
		Color.WHITE,
		0.22
	)

	tween.tween_property(
		menu_panel,
		"scale",
		Vector2.ONE,
		0.22
	)


func _unhandled_input(event: InputEvent) -> void:
	if not is_menu_visible():
		return

	if not event.is_action_pressed("ui_cancel"):
		return

	if not main_page.visible:
		_show_main_page()
	elif opened_from_game:
		hide_menu()
	else:
		return

	get_viewport().set_input_as_handled()


func _get_status_text(status: String) -> String:
	match status:
		"victory":
			return "CONCLUÍDA COM VITÓRIA"

		"defeat":
			return "ENCERRADA EM DERROTA"

		"free_play":
			return "MODO LIVRE"

		_:
			return "EM ANDAMENTO"


func _add_centered_control(
	parent: VBoxContainer,
	control: Control
) -> void:
	var center: CenterContainer = CenterContainer.new()
	center.add_child(control)
	parent.add_child(center)


func _create_status_panel(
	parent: VBoxContainer,
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
			Color("#30251A"),
			MedievalTheme.GOLD_DARK,
			1,
			7,
			12,
			1
		)
	)

	var label: Label = MedievalTheme.create_label(
		"",
		MedievalTheme.PARCHMENT_LIGHT,
		15
	)

	label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	panel.add_child(label)
	parent.add_child(panel)
	return label


func _create_menu_button(
	button_text: String,
	minimum_width: float
) -> Button:
	var button: Button = Button.new()
	button.text = button_text

	button.custom_minimum_size = Vector2(
		minimum_width,
		42.0
	)

	button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	button.add_theme_font_size_override(
		"font_size",
		16
	)
	VillageUIAccessibility.configure_button(button)

	return button


## Realça um botão como a ação primária da tela (fundo dourado, texto
## escuro, levemente maior). Usa overrides só nesta instância — não mexe no
## tema global, então não afeta nenhum outro botão do jogo.
func _apply_primary_emphasis(button: Button) -> void:
	if not is_instance_valid(button):
		return

	button.add_theme_font_size_override("font_size", 18)

	var normal_style: StyleBoxFlat = StyleBoxFlat.new()
	normal_style.bg_color = MedievalTheme.GOLD
	normal_style.border_color = MedievalTheme.GOLD_DARK
	normal_style.set_border_width_all(2)
	normal_style.set_corner_radius_all(8)

	var hover_style: StyleBoxFlat = StyleBoxFlat.new()
	hover_style.bg_color = MedievalTheme.GOLD.lightened(0.12)
	hover_style.border_color = MedievalTheme.GOLD_DARK
	hover_style.set_border_width_all(2)
	hover_style.set_corner_radius_all(8)

	var pressed_style: StyleBoxFlat = StyleBoxFlat.new()
	pressed_style.bg_color = MedievalTheme.GOLD_DARK
	pressed_style.border_color = MedievalTheme.GOLD_DARK
	pressed_style.set_border_width_all(2)
	pressed_style.set_corner_radius_all(8)

	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_color_override("font_color", MedievalTheme.INK)
	button.add_theme_color_override("font_hover_color", MedievalTheme.INK)
	button.add_theme_color_override("font_pressed_color", MedievalTheme.INK)


## Reduz o peso visual de um botão secundário/pouco frequente (ex: Sair do
## Jogo), sem desabilitá-lo. Overrides só nesta instância.
func _apply_quiet_emphasis(button: Button) -> void:
	if not is_instance_valid(button):
		return

	var normal_style: StyleBoxFlat = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	normal_style.border_color = MedievalTheme.WOOD_LIGHT
	normal_style.set_border_width_all(1)
	normal_style.set_corner_radius_all(8)

	var hover_style: StyleBoxFlat = StyleBoxFlat.new()
	hover_style.bg_color = MedievalTheme.WOOD_DARK
	hover_style.border_color = MedievalTheme.WOOD_LIGHT
	hover_style.set_border_width_all(1)
	hover_style.set_corner_radius_all(8)

	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_color_override("font_color", MedievalTheme.TEXT_MUTED)


## Remove os overrides de ênfase (primário ou discreto), voltando o botão ao
## estilo padrão do tema. Necessário porque qual botão é "primário" muda
## dinamicamente conforme existe ou não uma campanha salva.
func _clear_emphasis(button: Button) -> void:
	if not is_instance_valid(button):
		return
	button.remove_theme_font_size_override("font_size")
	button.add_theme_font_size_override("font_size", 16)
	button.remove_theme_stylebox_override("normal")
	button.remove_theme_stylebox_override("hover")
	button.remove_theme_stylebox_override("pressed")
	button.remove_theme_color_override("font_color")
	button.remove_theme_color_override("font_hover_color")
	button.remove_theme_color_override("font_pressed_color")


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

	style.content_margin_left = float(content_margin)
	style.content_margin_right = float(content_margin)
	style.content_margin_top = float(content_margin)
	style.content_margin_bottom = float(content_margin)

	style.shadow_color = Color(
		0.02,
		0.01,
		0.005,
		0.70
	)

	style.shadow_size = shadow_size
	style.shadow_offset = Vector2(0.0, 4.0)
	return style
