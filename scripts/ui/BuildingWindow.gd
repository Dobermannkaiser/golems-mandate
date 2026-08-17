class_name BuildingWindow
extends Control


signal upgrade_requested(building_id: String, variant_id: String)
signal construction_cancel_requested(order_id: String)
signal construction_move_requested(order_id: String, direction: int)


var overlay: ColorRect
var building_panel: PanelContainer
var material_label: Label
var progress_label: Label
var feedback_label: Label
var queue_summary_label: Label
var queue_container: VBoxContainer
var housing_container: VBoxContainer
var cards_container: GridContainer
var close_button: Button
var previous_focus: Control

var cancel_confirmation_overlay: ColorRect
var cancel_confirmation_label: Label
var cancel_confirmation_confirm_button: Button
var cancel_confirmation_cancel_button: Button
var cancel_confirmation_previous_focus: Control
var pending_cancel_order_id: String = ""

var current_state: Dictionary = {}

var variant_choice_overlay: ColorRect
var variant_choice_cards: HBoxContainer
var variant_choice_feedback: Label
var variant_choice_confirm_button: Button
var variant_choice_previous_focus: Control
var pending_variant_building_id: String = ""
var pending_variant_building_name: String = ""
var pending_variant_id: String = ""


func _ready() -> void:
	set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_create_window()


func show_buildings(
	building_state: Dictionary
) -> void:
	previous_focus = VillageUIAccessibility.remember_focus(self)
	current_state = building_state.duplicate(true)
	overlay.visible = true

	if bool(
		current_state.get(
			"building_allowed",
			true
		)
	):
		feedback_label.text = (
			"Planeje obras, acompanhe canteiros e reorganize a fila."
		)

		feedback_label.add_theme_color_override(
			"font_color",
			MedievalTheme.TEXT_MUTED
		)
	else:
		feedback_label.text = String(
			current_state.get(
				"blocked_reason",
				"Não é possível construir agora."
			)
		)

		feedback_label.add_theme_color_override(
			"font_color",
			Color("#F07F72")
		)

	_refresh_content()
	call_deferred("_animate_open")
	VillageUIAccessibility.focus_first_enabled(overlay)


func refresh_state(
	building_state: Dictionary
) -> void:
	current_state = building_state.duplicate(true)
	_refresh_content()


func show_feedback(
	message: String,
	is_success: bool
) -> void:
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
	_hide_variant_choice(false)
	_hide_cancel_confirmation(false)
	overlay.visible = false
	VillageUIAccessibility.restore_focus_deferred(
		previous_focus,
		_get_parent_focus_restore_root()
	)
	previous_focus = null


func is_window_visible() -> bool:
	return (
		is_instance_valid(overlay)
		and overlay.visible
	)


func get_active_focus_root() -> Control:
	if (
		is_instance_valid(variant_choice_overlay)
		and variant_choice_overlay.visible
	):
		return variant_choice_overlay
	if (
		is_instance_valid(cancel_confirmation_overlay)
		and cancel_confirmation_overlay.visible
	):
		return cancel_confirmation_overlay
	return overlay


func _refresh_content() -> void:
	if not is_instance_valid(cards_container):
		return

	var available_material: float = float(
		current_state.get(
			"available_material",
			0.0
		)
	)

	var built_upgrades: int = int(
		current_state.get(
			"built_upgrades",
			0
		)
	)

	var total_upgrades: int = int(
		current_state.get(
			"total_upgrades",
			15
		)
	)

	material_label.text = (
		"MATERIAL DISPONÍVEL: %.1f"
		% available_material
	)

	progress_label.text = (
		"MELHORIAS: %d / %d     •     CASAS: %d"
		% [
			built_upgrades,
			total_upgrades,
			int(
				current_state.get(
					"house_count",
					2
				)
			)
		]
	)

	_refresh_queue_content()

	for child: Node in housing_container.get_children():
		housing_container.remove_child(child)
		child.queue_free()

	var housing: Dictionary = current_state.get(
		"housing",
		{}
	)

	if not housing.is_empty():
		housing_container.add_child(
			_create_housing_card(housing)
		)

	for child: Node in cards_container.get_children():
		cards_container.remove_child(child)
		child.queue_free()

	var buildings: Array = current_state.get(
		"buildings",
		[]
	)

	for building_value: Variant in buildings:
		var building: Dictionary = building_value

		cards_container.add_child(
			_create_building_card(
				building
			)
		)


func _refresh_queue_content() -> void:
	if not is_instance_valid(queue_container):
		return
	for child: Node in queue_container.get_children():
		queue_container.remove_child(child)
		child.queue_free()

	var construction: Dictionary = current_state.get("construction", {})
	var capacity: int = int(construction.get("site_capacity", 1))
	var active_count: int = int(construction.get("active_count", 0))
	var queued_count: int = int(construction.get("queued_count", 0))
	queue_summary_label.text = (
		"CANTEIROS: %d/%d • FILA: %d • CAPACIDADE ATUAL PELA POPULAÇÃO"
		% [active_count, capacity, queued_count]
	)
	var warning: String = String(construction.get("capacity_warning", ""))
	if not warning.is_empty():
		queue_summary_label.text += "\nATENÇÃO: " + warning

	var active_orders: Array = construction.get("active_orders", [])
	var queued_orders: Array = construction.get("queued_orders", [])
	if active_orders.is_empty() and queued_orders.is_empty():
		var empty_label: Label = MedievalTheme.create_label(
			"Nenhuma obra planejada. O custo é pago ao entrar na fila; "
			+ "o trabalho começa a partir do dia seguinte.",
			MedievalTheme.TEXT_MUTED,
			13
		)
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		queue_container.add_child(empty_label)
		return

	for order_value: Variant in active_orders:
		if order_value is Dictionary:
			queue_container.add_child(
				_create_queue_order_row(order_value as Dictionary, -1, 0)
			)
	for index: int in range(queued_orders.size()):
		var order_value: Variant = queued_orders[index]
		if order_value is Dictionary:
			queue_container.add_child(
				_create_queue_order_row(
					order_value as Dictionary,
					index,
					queued_orders.size()
				)
			)


func _create_queue_order_row(
	order: Dictionary,
	queued_index: int,
	queued_count: int
) -> PanelContainer:
	var row_panel: PanelContainer = PanelContainer.new()
	row_panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			Color(0.18, 0.12, 0.08, 0.96),
			Color("#8C745C"),
			1,
			6,
			8,
			1
		)
	)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row_panel.add_child(row)

	var status_id: String = String(order.get("status", ""))
	var status: String = String(order.get("status_text", "NA FILA"))
	var progress: String = ""
	var schedule_text: String = String(order.get("audit_text", ""))
	if status_id == "active":
		progress = " • %d/%d DIA(S)" % [
			int(order.get("progress_days", 0)),
			int(order.get("work_days", 1))
		]
	elif status_id == "queued":
		var predicted_start_day: int = int(
			order.get("predicted_start_day", 0)
		)
		if predicted_start_day > 0:
			schedule_text = (
				"Início previsto: dia %d. %s"
				% [predicted_start_day, schedule_text]
			)
	var info: Label = MedievalTheme.create_label(
		"%s — %s%s\n%s" % [
			status,
			String(order.get("target_label", "Obra")),
			progress,
			schedule_text
		],
		MedievalTheme.PARCHMENT_LIGHT,
		12
	)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(info)

	var order_id: String = String(order.get("order_id", ""))
	if queued_index >= 0:
		var up_button: Button = Button.new()
		up_button.text = "▲"
		up_button.tooltip_text = "Mover esta obra para cima na fila."
		up_button.disabled = queued_index <= 0
		up_button.custom_minimum_size = Vector2(38.0, 38.0)
		VillageUIAccessibility.configure_button(up_button, "", 38.0)
		up_button.pressed.connect(
			_on_move_order_pressed.bind(order_id, -1)
		)
		row.add_child(up_button)

		var down_button: Button = Button.new()
		down_button.text = "▼"
		down_button.tooltip_text = "Mover esta obra para baixo na fila."
		down_button.disabled = queued_index >= queued_count - 1
		down_button.custom_minimum_size = Vector2(38.0, 38.0)
		VillageUIAccessibility.configure_button(down_button, "", 38.0)
		down_button.pressed.connect(
			_on_move_order_pressed.bind(order_id, 1)
		)
		row.add_child(down_button)

	var cancel_button: Button = Button.new()
	cancel_button.text = "CANCELAR\n+%.1f" % float(order.get("refund_amount", 0.0))
	cancel_button.tooltip_text = (
		"Cancela a obra e devolve %d%% do custo pago."
		% int(round(float(order.get("refund_rate", 1.0)) * 100.0))
	)
	cancel_button.disabled = not bool(order.get("can_cancel", false))
	cancel_button.custom_minimum_size = Vector2(96.0, 42.0)
	VillageUIAccessibility.configure_button(cancel_button, "", 42.0)
	cancel_button.pressed.connect(
		_on_cancel_order_pressed.bind(
			order_id,
			String(order.get("target_label", "Obra")),
			float(order.get("refund_amount", 0.0)),
			int(round(float(order.get("refund_rate", 1.0)) * 100.0)),
			String(order.get("status", "queued"))
		)
	)
	row.add_child(cancel_button)
	return row_panel


func _on_cancel_order_pressed(
	order_id: String,
	target_label: String,
	refund_amount: float,
	refund_percent: int,
	status: String
) -> void:
	if order_id.is_empty():
		return
	pending_cancel_order_id = order_id
	cancel_confirmation_previous_focus = get_viewport().gui_get_focus_owner()
	var consequence: String = (
		"Todo o progresso será perdido."
		if status == "active"
		else "A posição reservada na fila será perdida."
	)
	cancel_confirmation_label.text = (
		"CANCELAR %s?\n\n%s\nReembolso: %.1f de material (%d%%)."
		% [target_label.to_upper(), consequence, refund_amount, refund_percent]
	)
	cancel_confirmation_overlay.visible = true
	# O foco inicial fica na ação segura, nunca no cancelamento destrutivo.
	VillageUIAccessibility.focus_deferred(
		cancel_confirmation_cancel_button
	)


func _confirm_cancel_order() -> void:
	var order_id: String = pending_cancel_order_id
	_hide_cancel_confirmation(false)
	if not order_id.is_empty():
		construction_cancel_requested.emit(order_id)
		call_deferred("_restore_interaction_focus")


func _hide_cancel_confirmation(restore_focus: bool = true) -> void:
	if is_instance_valid(cancel_confirmation_overlay):
		cancel_confirmation_overlay.visible = false
	pending_cancel_order_id = ""
	if restore_focus:
		VillageUIAccessibility.restore_focus_deferred(
			cancel_confirmation_previous_focus,
			get_active_focus_root()
		)
	cancel_confirmation_previous_focus = null


func _on_move_order_pressed(order_id: String, direction: int) -> void:
	if not order_id.is_empty():
		construction_move_requested.emit(order_id, direction)
		call_deferred("_restore_interaction_focus")


func _restore_interaction_focus() -> void:
	if is_window_visible():
		VillageUIAccessibility.focus_first_enabled(
			get_active_focus_root()
		)


func _create_housing_card(
	housing: Dictionary
) -> PanelContainer:
	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = Vector2(
		0.0,
		102.0
	)

	card.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			Color(0.24, 0.16, 0.10, 0.98),
			Color("#B47D55"),
			2,
			8,
			11,
			1
		)
	)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override(
		"separation",
		5
	)
	card.add_child(layout)

	var header: HBoxContainer = HBoxContainer.new()
	header.add_theme_constant_override(
		"separation",
		10
	)
	layout.add_child(header)

	var title: Label = MedievalTheme.create_label(
		"MORADIA",
		MedievalTheme.GOLD,
		19
	)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var occupation: Label = MedievalTheme.create_label(
		"%d / %d HABITANTES     •     %d CASAS"
		% [
			int(
				housing.get(
					"total_population",
					0
				)
			),
			int(
				housing.get(
					"housing_capacity",
					0
				)
			),
			int(
				housing.get(
					"house_count",
					2
				)
			)
		],
		MedievalTheme.PARCHMENT_LIGHT,
		14
	)
	occupation.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)
	header.add_child(occupation)

	var footer: HBoxContainer = HBoxContainer.new()
	footer.add_theme_constant_override(
		"separation",
		12
	)
	layout.add_child(footer)

	var description: Label = MedievalTheme.create_label(
		(
			"Cada casa oferece %d vagas. Disponíveis agora: %d. "
			+ "Casas concluídas/planejadas: %d/%d."
		) % [
			int(housing.get("capacity_per_house", 5)),
			int(housing.get("available_housing", 0)),
			int(housing.get("house_count", 2)),
			int(housing.get("planned_house_count", 2))
		],
		MedievalTheme.TEXT_MUTED,
		13
	)
	description.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)
	description.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)
	footer.add_child(description)

	var build_button: Button = Button.new()
	build_button.custom_minimum_size = Vector2(
		170.0,
		42.0
	)
	build_button.text = (
		"ADICIONAR À FILA\n1 DIA • %.1f MATERIAL"
		% float(housing.get("next_cost", 8.0))
	)
	build_button.disabled = not bool(
		housing.get(
			"can_upgrade",
			false
		)
	)
	build_button.tooltip_text = (
		String(
			housing.get(
				"unavailable_reason",
				""
			)
		)
		if build_button.disabled
		else (
			"Paga o custo agora. A casa começa a partir do próximo dia "
			+ "quando houver canteiro e libera cinco vagas após um dia completo."
		)
	)
	build_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)
	VillageUIAccessibility.configure_button(
		build_button,
		"Adiciona uma nova casa à fila quando houver material.",
		42.0
	)
	build_button.pressed.connect(
		_on_upgrade_pressed.bind(
			String(
				housing.get(
					"id",
					"housing"
				)
			)
		)
	)
	footer.add_child(build_button)
	return card


func _create_building_card(
	building: Dictionary
) -> PanelContainer:
	var current_level: int = int(
		building.get(
			"current_level",
			0
		)
	)

	var max_level: int = int(
		building.get(
			"max_level",
			3
		)
	)

	var is_maximum: bool = bool(
		building.get(
			"is_maximum",
			false
		)
	)

	var accent_color: Color = Color(
		String(
			building.get(
				"color",
				"#8A765F"
			)
		)
	)

	var card: PanelContainer = PanelContainer.new()

	card.custom_minimum_size = Vector2(
		406.0,
		178.0
	)

	card.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			(
				Color(0.17, 0.12, 0.08, 0.97)
				if current_level == 0
				else Color(0.22, 0.16, 0.10, 0.98)
			),
			(
				MedievalTheme.GOLD
				if is_maximum
				else accent_color
			),
			2,
			8,
			11,
			1
		)
	)

	var layout: VBoxContainer = VBoxContainer.new()

	layout.add_theme_constant_override(
		"separation",
		5
	)

	card.add_child(layout)

	var header: HBoxContainer = HBoxContainer.new()

	header.add_theme_constant_override(
		"separation",
		8
	)

	layout.add_child(header)

	var accent: ColorRect = ColorRect.new()

	accent.custom_minimum_size = Vector2(
		7.0,
		28.0
	)

	accent.color = accent_color
	accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(accent)

	var name_label: Label = MedievalTheme.create_label(
		String(
			building.get(
				"name",
				"Construção"
			)
		).to_upper(),
		MedievalTheme.GOLD,
		19
	)

	name_label.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	name_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	header.add_child(name_label)

	var level_label: Label = MedievalTheme.create_label(
		"NÍVEL %d / %d"
		% [
			current_level,
			max_level
		],
		(
			Color("#B9DDA7")
			if is_maximum
			else MedievalTheme.PARCHMENT_LIGHT
		),
		13
	)

	level_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	header.add_child(level_label)

	var flavor_label: Label = MedievalTheme.create_label(
		String(
			building.get(
				"flavor",
				"Uma melhoria para a comunidade."
			)
		),
		MedievalTheme.TEXT_MUTED,
		13
	)

	flavor_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	layout.add_child(flavor_label)

	var current_effect_label: Label = MedievalTheme.create_label(
		"ATUAL: %s"
		% String(
			building.get(
				"current_effect_text",
				"Nenhum benefício ativo."
			)
		),
		(
			Color("#B9DDA7")
			if current_level > 0
			else MedievalTheme.TEXT_MUTED
		),
		13
	)

	current_effect_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	layout.add_child(current_effect_label)

	var current_variant_id: String = String(
		building.get("current_variant_id", "")
	)
	if not current_variant_id.is_empty():
		var build_label: Label = MedievalTheme.create_label(
			"BUILD FINAL — %s" % String(
				building.get("current_variant_name", "Especialização")
			).to_upper(),
			MedievalTheme.GOLD,
			13
		)
		build_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		layout.add_child(build_label)

		var completion_day: int = int(
			building.get("variant_completion_day", 0)
		)
		var event_uses_value: Variant = building.get(
			"variant_event_uses",
			[]
		)
		var event_use_count: int = (
			(event_uses_value as Array).size()
			if event_uses_value is Array
			else 0
		)
		var history_label: Label = MedievalTheme.create_label(
			"Concluída no dia %d • usada em %d acontecimento(s)." % [
				completion_day,
				event_use_count
			],
			MedievalTheme.TEXT_MUTED,
			11
		)
		history_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		layout.add_child(history_label)

	var footer: HBoxContainer = HBoxContainer.new()

	footer.add_theme_constant_override(
		"separation",
		10
	)

	layout.add_child(footer)

	var next_effect_label: Label = MedievalTheme.create_label(
		(
			"EDIFÍCIO COMPLETO"
			if is_maximum
			else (
				"PRÓXIMO: "
				+ String(
					building.get(
						"next_effect_text",
						"Novo benefício."
					)
				)
			)
		),
		(
			MedievalTheme.GOLD
			if is_maximum
			else MedievalTheme.PARCHMENT_LIGHT
		),
		12
	)

	next_effect_label.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	next_effect_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	next_effect_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	footer.add_child(next_effect_label)

	var upgrade_button: Button = Button.new()

	upgrade_button.custom_minimum_size = Vector2(
		124.0,
		42.0
	)

	upgrade_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)
	VillageUIAccessibility.configure_button(
		upgrade_button,
		"Planeja a próxima melhoria desta construção.",
		42.0
	)

	if is_maximum:
		upgrade_button.text = "CONCLUÍDO"
		upgrade_button.disabled = true
	else:
		var next_cost: float = float(
			building.get(
				"next_cost",
				0.0
			)
		)

		upgrade_button.text = (
			"PLANEJAR NÍVEL %d\n%d DIA(S) • %.1f MATERIAL"
			% [
				current_level + 1,
				int(building.get("next_work_days", current_level + 1)),
				next_cost
			]
		)

		upgrade_button.disabled = not bool(
			building.get(
				"can_upgrade",
				false
			)
		)

		upgrade_button.tooltip_text = (
			String(
				building.get(
					"unavailable_reason",
					""
				)
			)
			if upgrade_button.disabled
			else (
				"Paga o custo agora e adiciona a próxima melhoria à fila. "
				+ "O benefício só começa no dia seguinte à conclusão."
			)
		)

		if bool(building.get("requires_variant_choice", false)):
			upgrade_button.text = (
				"ESCOLHER BUILD FINAL\n%d DIA(S) • %.1f MATERIAL"
				% [
					int(building.get("next_work_days", 3)),
					next_cost
				]
			)
			upgrade_button.tooltip_text = (
				"Compara as duas especializações do nível 3 antes de pagar o custo."
				if not upgrade_button.disabled
				else upgrade_button.tooltip_text
			)
			upgrade_button.pressed.connect(
				_show_variant_choice.bind(building.duplicate(true))
			)
		else:
			upgrade_button.pressed.connect(
				_on_upgrade_pressed.bind(
					String(building.get("id", "")),
					""
				)
			)

	footer.add_child(upgrade_button)
	return card


func _create_window() -> void:
	overlay = ColorRect.new()
	overlay.name = "BuildingOverlay"

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

	overlay.z_index = 115
	overlay.visible = false
	add_child(overlay)

	var center: CenterContainer = CenterContainer.new()

	center.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)

	building_panel = PanelContainer.new()

	building_panel.custom_minimum_size = Vector2(
		900.0,
		620.0
	)

	building_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	building_panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			MedievalTheme.WOOD_DARK,
			MedievalTheme.GOLD,
			3,
			12,
			20,
			8
		)
	)

	center.add_child(building_panel)

	var layout: VBoxContainer = VBoxContainer.new()

	layout.add_theme_constant_override(
		"separation",
		8
	)

	building_panel.add_child(layout)

	var section_label: Label = MedievalTheme.create_label(
		"PLANEJAMENTO DA VILA",
		MedievalTheme.TEXT_MUTED,
		13
	)

	section_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	layout.add_child(section_label)

	var title_label: Label = MedievalTheme.create_label(
		"CONSTRUÇÕES E MELHORIAS",
		MedievalTheme.GOLD,
		27
	)

	title_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	layout.add_child(title_label)

	var description_label: Label = MedievalTheme.create_label(
		"Construa casas repetíveis e invista nas cinco "
		+ "construções permanentes da campanha.",
		MedievalTheme.PARCHMENT_LIGHT,
		14
	)

	description_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	layout.add_child(description_label)

	var status_row: HBoxContainer = HBoxContainer.new()

	status_row.add_theme_constant_override(
		"separation",
		12
	)

	layout.add_child(status_row)

	material_label = MedievalTheme.create_label(
		"MATERIAL DISPONÍVEL: 0.0",
		Color("#D4B08C"),
		15
	)

	material_label.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	status_row.add_child(material_label)

	progress_label = MedievalTheme.create_label(
		"MELHORIAS: 0 / 15     •     CASAS: 2",
		MedievalTheme.GOLD,
		15
	)

	progress_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_RIGHT
	)

	status_row.add_child(progress_label)

	var divider: HSeparator = HSeparator.new()
	layout.add_child(divider)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.follow_focus = true
	layout.add_child(scroll)

	var content: VBoxContainer = VBoxContainer.new()
	content.custom_minimum_size = Vector2(842.0, 0.0)
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 9)
	scroll.add_child(content)

	var queue_label: Label = MedievalTheme.create_label(
		"FILA DE OBRAS",
		MedievalTheme.GOLD,
		15
	)
	content.add_child(queue_label)

	queue_summary_label = MedievalTheme.create_label(
		"CANTEIROS: 0/1 • FILA: 0",
		MedievalTheme.PARCHMENT_LIGHT,
		13
	)
	queue_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(queue_summary_label)

	queue_container = VBoxContainer.new()
	queue_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	queue_container.add_theme_constant_override("separation", 6)
	content.add_child(queue_container)

	var queue_divider: HSeparator = HSeparator.new()
	content.add_child(queue_divider)

	housing_container = VBoxContainer.new()
	housing_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(housing_container)

	var buildings_label: Label = MedievalTheme.create_label(
		"MELHORIAS DA COMUNIDADE",
		MedievalTheme.TEXT_MUTED,
		12
	)
	content.add_child(buildings_label)

	cards_container = GridContainer.new()
	cards_container.columns = 2
	cards_container.custom_minimum_size = Vector2(842.0, 0.0)
	cards_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards_container.add_theme_constant_override("h_separation", 10)
	cards_container.add_theme_constant_override("v_separation", 10)
	content.add_child(cards_container)

	feedback_label = MedievalTheme.create_label(
		"Planeje obras, acompanhe canteiros e reorganize a fila.",
		MedievalTheme.TEXT_MUTED,
		13
	)

	feedback_label.custom_minimum_size = Vector2(
		0.0,
		34.0
	)

	feedback_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	feedback_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	feedback_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	layout.add_child(feedback_label)

	close_button = Button.new()
	close_button.text = "VOLTAR À VILA"
	close_button.tooltip_text = "Fecha a tela de construções."

	close_button.custom_minimum_size = Vector2(
		220.0,
		46.0
	)

	close_button.size_flags_horizontal = (
		Control.SIZE_SHRINK_CENTER
	)

	close_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	VillageUIAccessibility.configure_button(close_button, "", 46.0)
	close_button.pressed.connect(
		hide_window
	)

	layout.add_child(close_button)
	_create_cancel_confirmation()
	_create_variant_choice_overlay()


func _create_variant_choice_overlay() -> void:
	variant_choice_overlay = ColorRect.new()
	variant_choice_overlay.name = "BuildingVariantChoice"
	variant_choice_overlay.color = Color(0.02, 0.01, 0.005, 0.93)
	variant_choice_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	variant_choice_overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	variant_choice_overlay.z_index = 24
	variant_choice_overlay.visible = false
	overlay.add_child(variant_choice_overlay)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	variant_choice_overlay.add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(820.0, 590.0)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_theme_stylebox_override(
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
	center.add_child(panel)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	panel.add_child(layout)

	var title: Label = MedievalTheme.create_label(
		"ESCOLHA A BUILD FINAL",
		MedievalTheme.GOLD,
		25
	)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(title)

	var explanation: Label = MedievalTheme.create_label(
		"Compare as duas especializações. A escolha é confirmada agora, mas só se torna irreversível quando a obra termina; cancelar a obra permite escolher novamente.",
		MedievalTheme.PARCHMENT_LIGHT,
		14
	)
	explanation.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(explanation)

	variant_choice_cards = HBoxContainer.new()
	variant_choice_cards.alignment = BoxContainer.ALIGNMENT_CENTER
	variant_choice_cards.size_flags_vertical = Control.SIZE_EXPAND_FILL
	variant_choice_cards.add_theme_constant_override("separation", 16)
	layout.add_child(variant_choice_cards)

	variant_choice_feedback = MedievalTheme.create_label(
		"Selecione uma build para conferir e confirmar.",
		MedievalTheme.TEXT_MUTED,
		13
	)
	variant_choice_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	variant_choice_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(variant_choice_feedback)

	var warning: Label = MedievalTheme.create_label(
		"DECISÃO IRREVERSÍVEL APÓS A CONCLUSÃO DA OBRA",
		Color("#F2B39D"),
		13
	)
	warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(warning)

	var actions: HBoxContainer = HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 12)
	layout.add_child(actions)

	variant_choice_confirm_button = Button.new()
	variant_choice_confirm_button.text = "CONFIRMAR BUILD"
	variant_choice_confirm_button.disabled = true
	variant_choice_confirm_button.custom_minimum_size = Vector2(220.0, 48.0)
	VillageUIAccessibility.configure_button(
		variant_choice_confirm_button,
		"Confirma a build escolhida e paga o custo para colocá-la na fila.",
		48.0
	)
	variant_choice_confirm_button.pressed.connect(_confirm_variant_choice)
	actions.add_child(variant_choice_confirm_button)

	var back_button: Button = Button.new()
	back_button.text = "VOLTAR SEM ESCOLHER"
	back_button.custom_minimum_size = Vector2(220.0, 48.0)
	VillageUIAccessibility.configure_button(
		back_button,
		"Volta à lista de construções sem alterar nada.",
		48.0
	)
	back_button.pressed.connect(_hide_variant_choice)
	actions.add_child(back_button)


func _show_variant_choice(building: Dictionary) -> void:
	if not bool(building.get("can_upgrade", false)):
		show_feedback(
			String(building.get("unavailable_reason", "A build não pode ser planejada agora.")),
			false
		)
		return
	pending_variant_building_id = String(building.get("id", ""))
	pending_variant_building_name = String(building.get("name", "Construção"))
	pending_variant_id = ""
	variant_choice_previous_focus = get_viewport().gui_get_focus_owner()
	variant_choice_confirm_button.disabled = true
	variant_choice_feedback.text = (
		"%s chegará ao nível 3. Escolha qual função final ela cumprirá na vila."
		% pending_variant_building_name
	)
	for child: Node in variant_choice_cards.get_children():
		variant_choice_cards.remove_child(child)
		child.queue_free()
	var options: Array = building.get("variant_options", [])
	for option_value: Variant in options:
		if option_value is Dictionary:
			variant_choice_cards.add_child(
				_create_variant_option_card(option_value as Dictionary)
			)
	variant_choice_overlay.visible = true
	VillageUIAccessibility.focus_first_enabled(variant_choice_overlay)


func _create_variant_option_card(variant: Dictionary) -> PanelContainer:
	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = Vector2(360.0, 360.0)
	card.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			Color(0.20, 0.14, 0.09, 0.98),
			Color("#8C745C"),
			2,
			9,
			14,
			2
		)
	)
	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	card.add_child(layout)

	var preview: TextureRect = TextureRect.new()
	preview.custom_minimum_size = Vector2(250.0, 150.0)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var preview_path: String = String(variant.get("preview_path", ""))
	if not preview_path.is_empty() and ResourceLoader.exists(preview_path):
		preview.texture = load(preview_path) as Texture2D
	layout.add_child(preview)

	var name_label: Label = MedievalTheme.create_label(
		String(variant.get("name", "Build final")).to_upper(),
		MedievalTheme.GOLD,
		19
	)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(name_label)

	var identity: Label = MedievalTheme.create_label(
		String(variant.get("identity", "Especialização permanente.")),
		MedievalTheme.TEXT_MUTED,
		13
	)
	identity.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	identity.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(identity)

	var effect: Label = MedievalTheme.create_label(
		String(variant.get("effect_text", "Benefício permanente.")),
		Color("#B9DDA7"),
		13
	)
	effect.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	effect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(effect)

	var event_hint: Label = MedievalTheme.create_label(
		"ACONTECIMENTOS — %s" % String(
			variant.get(
				"event_hint",
				"Pode abrir soluções próprias em acontecimentos da vila."
			)
		),
		Color("#D8C18D"),
		12
	)
	event_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	event_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(event_hint)

	var cost: Label = MedievalTheme.create_label(
		"%d DIAS • %.1f MATERIAL" % [
			int(variant.get("work_days", 3)),
			float(variant.get("cost", 0.0))
		],
		MedievalTheme.PARCHMENT_LIGHT,
		13
	)
	cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(cost)

	var select_button: Button = Button.new()
	select_button.text = "SELECIONAR"
	select_button.custom_minimum_size = Vector2(190.0, 44.0)
	select_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	VillageUIAccessibility.configure_button(select_button, "", 44.0)
	select_button.pressed.connect(
		_select_variant.bind(
			String(variant.get("id", "")),
			String(variant.get("name", "Build final")),
			String(variant.get("effect_text", ""))
		)
	)
	layout.add_child(select_button)
	return card


func _select_variant(
	variant_id: String,
	variant_name: String,
	effect_text: String
) -> void:
	pending_variant_id = variant_id
	variant_choice_confirm_button.disabled = pending_variant_id.is_empty()
	variant_choice_feedback.text = "%s selecionada: %s" % [
		variant_name,
		effect_text
	]
	VillageUIAccessibility.focus_deferred(
		variant_choice_confirm_button
	)


func _confirm_variant_choice() -> void:
	var building_id: String = pending_variant_building_id
	var variant_id: String = pending_variant_id
	if building_id.is_empty() or variant_id.is_empty():
		return
	_hide_variant_choice(false)
	upgrade_requested.emit(building_id, variant_id)
	call_deferred("_restore_interaction_focus")


func _hide_variant_choice(restore_focus: bool = true) -> void:
	if is_instance_valid(variant_choice_overlay):
		variant_choice_overlay.visible = false
	pending_variant_building_id = ""
	pending_variant_building_name = ""
	pending_variant_id = ""
	if restore_focus:
		VillageUIAccessibility.restore_focus_deferred(
			variant_choice_previous_focus,
			get_active_focus_root()
		)
	variant_choice_previous_focus = null


func _get_parent_focus_restore_root() -> Control:
	var parent_node: Node = get_parent()
	if (
		is_instance_valid(parent_node)
		and parent_node.has_method("get_focus_restore_root")
	):
		return parent_node.call("get_focus_restore_root") as Control
	return null


func _create_cancel_confirmation() -> void:
	cancel_confirmation_overlay = ColorRect.new()
	cancel_confirmation_overlay.name = "CancelConstructionConfirmation"
	cancel_confirmation_overlay.color = Color(0.02, 0.01, 0.005, 0.90)
	cancel_confirmation_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	cancel_confirmation_overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	cancel_confirmation_overlay.z_index = 20
	cancel_confirmation_overlay.visible = false
	overlay.add_child(cancel_confirmation_overlay)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cancel_confirmation_overlay.add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(520.0, 250.0)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(
			MedievalTheme.WOOD_DARK,
			Color("#C67A63"),
			3,
			10,
			22,
			6
		)
	)
	center.add_child(panel)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 16)
	panel.add_child(layout)

	var title: Label = MedievalTheme.create_label(
		"CONFIRMAÇÃO DE CANCELAMENTO",
		Color("#F2B39D"),
		20
	)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(title)

	cancel_confirmation_label = MedievalTheme.create_label(
		"Cancelar esta obra?",
		MedievalTheme.PARCHMENT_LIGHT,
		14
	)
	cancel_confirmation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cancel_confirmation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cancel_confirmation_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(cancel_confirmation_label)

	var actions: HBoxContainer = HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 12)
	layout.add_child(actions)

	cancel_confirmation_confirm_button = Button.new()
	cancel_confirmation_confirm_button.text = "CANCELAR OBRA"
	cancel_confirmation_confirm_button.tooltip_text = (
		"Confirma o cancelamento e aplica o reembolso informado."
	)
	cancel_confirmation_confirm_button.custom_minimum_size = Vector2(190.0, 46.0)
	VillageUIAccessibility.configure_button(
		cancel_confirmation_confirm_button,
		"",
		46.0
	)
	cancel_confirmation_confirm_button.pressed.connect(_confirm_cancel_order)
	actions.add_child(cancel_confirmation_confirm_button)

	cancel_confirmation_cancel_button = Button.new()
	cancel_confirmation_cancel_button.text = "MANTER OBRA"
	cancel_confirmation_cancel_button.tooltip_text = (
		"Fecha a confirmação sem alterar a fila."
	)
	cancel_confirmation_cancel_button.custom_minimum_size = Vector2(190.0, 46.0)
	VillageUIAccessibility.configure_button(
		cancel_confirmation_cancel_button,
		"",
		46.0
	)
	cancel_confirmation_cancel_button.pressed.connect(_hide_cancel_confirmation)
	actions.add_child(cancel_confirmation_cancel_button)


func _on_upgrade_pressed(
	building_id: String,
	variant_id: String = ""
) -> void:
	if building_id.is_empty():
		return

	upgrade_requested.emit(building_id, variant_id)
	call_deferred("_restore_interaction_focus")


func _animate_open() -> void:
	if not is_instance_valid(building_panel):
		return

	building_panel.pivot_offset = (
		building_panel.size * 0.5
	)

	if GameSettings.reduced_motion:
		building_panel.modulate = Color.WHITE
		building_panel.scale = Vector2.ONE
		return

	building_panel.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.0
	)

	building_panel.scale = Vector2(
		0.96,
		0.96
	)

	var tween: Tween = create_tween()

	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		building_panel,
		"modulate",
		Color.WHITE,
		0.22
	)

	tween.tween_property(
		building_panel,
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
		if (
			is_instance_valid(variant_choice_overlay)
			and variant_choice_overlay.visible
		):
			_hide_variant_choice()
		elif (
			is_instance_valid(cancel_confirmation_overlay)
			and cancel_confirmation_overlay.visible
		):
			_hide_cancel_confirmation()
		else:
			hide_window()
		get_viewport().set_input_as_handled()
