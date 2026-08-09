class_name VillageProfileSetupWindow
extends Control


signal profile_confirmed(
	player_name: String,
	gender_id: String,
	difficulty_id: String,
	village_name: String,
	campaign_seed: int
)
signal profile_cancelled()


const PIXEL_FONT: FontFile = preload("res://assets/dialogue/alagard.ttf")

var overlay: ColorRect
var name_input: LineEdit
var village_name_input: LineEdit
var seed_input: LineEdit
var gender_options: OptionButton
var difficulty_options: OptionButton
var difficulty_description_label: Label
var feedback_label: Label
var cancel_button: Button
var confirm_button: Button
var previous_focus: Control
var last_suggested_village_name: String = ""


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 950
	_create_window()


func show_setup(
	default_name: String = "Alex",
	default_gender: String = "masculino",
	default_difficulty: String = VillageDifficultyCatalog.DEFAULT_DIFFICULTY_ID,
	default_village_name: String = "",
	default_seed: int = 0
) -> void:
	previous_focus = VillageUIAccessibility.remember_focus(self)
	name_input.text = default_name
	gender_options.select(0 if default_gender == "masculino" else 1)
	_select_difficulty(default_difficulty)
	var selected_seed: int = (
		VillageCampaignIdentityCatalog.sanitize_seed(default_seed)
		if default_seed > 0
		else VillageCampaignIdentityCatalog.generate_seed()
	)
	seed_input.text = str(selected_seed)
	last_suggested_village_name = (
		VillageCampaignIdentityCatalog.suggest_village_name(selected_seed)
	)
	village_name_input.text = (
		default_village_name.strip_edges()
		if not default_village_name.strip_edges().is_empty()
		else last_suggested_village_name
	)
	_refresh_difficulty_description()
	feedback_label.text = ""
	feedback_label.add_theme_color_override("font_color", Color("#F07F72"))
	overlay.visible = true
	name_input.grab_focus()
	name_input.select_all()


func hide_window() -> void:
	overlay.visible = false
	VillageUIAccessibility.restore_focus_deferred(previous_focus)
	previous_focus = null


func is_window_visible() -> bool:
	return is_instance_valid(overlay) and overlay.visible


func _create_window() -> void:
	overlay = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.025, 0.025, 0.035, 0.92)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.visible = false
	add_child(overlay)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(700.0, 620.0)
	panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(Color("#21182D"), Color("#D2A85B"), 3, 14, 28, 8)
	)
	center.add_child(panel)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 10)
	panel.add_child(layout)

	var title: Label = Label.new()
	title.text = "CRIAR NOVA VILA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", PIXEL_FONT)
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("#F1C86C"))
	layout.add_child(title)

	var description: Label = Label.new()
	description.text = "Defina o Prefeito, dê um nome à vila e escolha a semente reproduzível da campanha."
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.add_theme_font_override("font", PIXEL_FONT)
	description.add_theme_font_size_override("font_size", 14)
	description.add_theme_color_override("font_color", Color("#F2E8D2"))
	layout.add_child(description)

	var name_label: Label = _make_field_label("NOME")
	layout.add_child(name_label)

	name_input = LineEdit.new()
	name_input.placeholder_text = "Digite o nome do protagonista"
	name_input.max_length = 32
	name_input.add_theme_font_override("font", PIXEL_FONT)
	name_input.add_theme_font_size_override("font_size", 17)
	VillageUIAccessibility.configure_input(name_input)
	layout.add_child(name_input)

	var village_label: Label = _make_field_label("NOME DA VILA")
	layout.add_child(village_label)

	village_name_input = LineEdit.new()
	village_name_input.placeholder_text = "Nome da comunidade"
	village_name_input.max_length = VillageCampaignIdentityCatalog.MAX_VILLAGE_NAME_LENGTH
	village_name_input.add_theme_font_override("font", PIXEL_FONT)
	village_name_input.add_theme_font_size_override("font_size", 17)
	VillageUIAccessibility.configure_input(village_name_input)
	layout.add_child(village_name_input)

	var identity_row: HBoxContainer = HBoxContainer.new()
	identity_row.add_theme_constant_override("separation", 14)
	layout.add_child(identity_row)

	var gender_box: VBoxContainer = VBoxContainer.new()
	gender_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity_row.add_child(gender_box)
	gender_box.add_child(_make_field_label("GÊNERO"))
	gender_options = OptionButton.new()
	gender_options.add_item("Masculino")
	gender_options.set_item_metadata(0, "masculino")
	gender_options.add_item("Feminino")
	gender_options.set_item_metadata(1, "feminino")
	gender_options.add_theme_font_override("font", PIXEL_FONT)
	gender_options.add_theme_font_size_override("font_size", 16)
	VillageUIAccessibility.configure_input(gender_options)
	gender_box.add_child(gender_options)

	var difficulty_box: VBoxContainer = VBoxContainer.new()
	difficulty_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity_row.add_child(difficulty_box)
	difficulty_box.add_child(_make_field_label("DIFICULDADE"))
	difficulty_options = OptionButton.new()
	for difficulty_id: String in VillageDifficultyCatalog.DIFFICULTY_IDS:
		var data: Dictionary = VillageDifficultyCatalog.get_difficulty(difficulty_id)
		difficulty_options.add_item(String(data.get("display_name", "Moderada")))
		difficulty_options.set_item_metadata(difficulty_options.item_count - 1, difficulty_id)
	difficulty_options.add_theme_font_override("font", PIXEL_FONT)
	difficulty_options.add_theme_font_size_override("font_size", 16)
	difficulty_options.item_selected.connect(_on_difficulty_selected)
	VillageUIAccessibility.configure_input(difficulty_options)
	difficulty_box.add_child(difficulty_options)

	var seed_row: HBoxContainer = HBoxContainer.new()
	seed_row.add_theme_constant_override("separation", 8)
	layout.add_child(seed_row)
	var seed_box: VBoxContainer = VBoxContainer.new()
	seed_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	seed_row.add_child(seed_box)
	seed_box.add_child(_make_field_label("SEMENTE DA CAMPANHA"))
	seed_input = LineEdit.new()
	seed_input.placeholder_text = "Número ou palavra"
	seed_input.max_length = 32
	seed_input.add_theme_font_override("font", PIXEL_FONT)
	seed_input.add_theme_font_size_override("font_size", 15)
	seed_input.text_changed.connect(_on_seed_text_changed)
	VillageUIAccessibility.configure_input(seed_input)
	seed_box.add_child(seed_input)

	var random_seed_button: Button = _make_button("NOVA SEMENTE")
	random_seed_button.custom_minimum_size = Vector2(150.0, 42.0)
	random_seed_button.tooltip_text = "Gera uma nova semente e atualiza apenas o nome sugerido da vila."
	random_seed_button.pressed.connect(_on_random_seed_pressed)
	seed_row.add_child(random_seed_button)

	var copy_seed_button: Button = _make_button("COPIAR")
	copy_seed_button.custom_minimum_size = Vector2(105.0, 42.0)
	copy_seed_button.tooltip_text = "Copia a semente numérica para reutilizar em outra campanha."
	copy_seed_button.pressed.connect(_on_copy_seed_pressed)
	seed_row.add_child(copy_seed_button)

	var difficulty_panel: PanelContainer = PanelContainer.new()
	difficulty_panel.custom_minimum_size = Vector2(0.0, 92.0)
	difficulty_panel.add_theme_stylebox_override(
		"panel",
		MedievalTheme.create_panel_style(Color("#171320"), Color("#795F38"), 1, 8, 12, 0)
	)
	layout.add_child(difficulty_panel)

	difficulty_description_label = Label.new()
	difficulty_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	difficulty_description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	difficulty_description_label.add_theme_font_override("font", PIXEL_FONT)
	difficulty_description_label.add_theme_font_size_override("font_size", 13)
	difficulty_description_label.add_theme_color_override("font_color", Color("#E9D8AE"))
	difficulty_panel.add_child(difficulty_description_label)

	feedback_label = Label.new()
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.add_theme_font_override("font", PIXEL_FONT)
	feedback_label.add_theme_font_size_override("font_size", 13)
	feedback_label.add_theme_color_override("font_color", Color("#F07F72"))
	layout.add_child(feedback_label)

	var buttons: HBoxContainer = HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 12)
	layout.add_child(buttons)

	cancel_button = _make_button("VOLTAR")
	cancel_button.tooltip_text = "Cancela a criação da vila."
	cancel_button.pressed.connect(_on_cancel_pressed)
	buttons.add_child(cancel_button)

	confirm_button = _make_button("INICIAR CAMPANHA")
	confirm_button.tooltip_text = (
		"Cria a vila com a identidade, a dificuldade e a semente escolhidas."
	)
	confirm_button.pressed.connect(_on_confirm_pressed)
	buttons.add_child(confirm_button)


func _unhandled_input(event: InputEvent) -> void:
	if not is_window_visible():
		return
	if event.is_action_pressed("ui_cancel"):
		_on_cancel_pressed()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_accept") and name_input.has_focus():
		_on_confirm_pressed()
		get_viewport().set_input_as_handled()


func _make_field_label(text_value: String) -> Label:
	var label: Label = Label.new()
	label.text = text_value
	label.add_theme_font_override("font", PIXEL_FONT)
	label.add_theme_font_size_override("font_size", 15)
	return label


func _make_button(text_value: String) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(190.0, 46.0)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", PIXEL_FONT)
	button.add_theme_font_size_override("font_size", 15)
	VillageUIAccessibility.configure_button(button, "", 46.0)
	return button


func _select_difficulty(difficulty_id: String) -> void:
	var clean_id: String = VillageDifficultyCatalog.sanitize_difficulty_id(difficulty_id)
	for index: int in range(difficulty_options.item_count):
		if String(difficulty_options.get_item_metadata(index)) == clean_id:
			difficulty_options.select(index)
			return
	difficulty_options.select(1)


func _on_difficulty_selected(_index: int) -> void:
	_refresh_difficulty_description()


func _refresh_difficulty_description() -> void:
	var difficulty_id: String = String(
		difficulty_options.get_item_metadata(difficulty_options.selected)
	)
	var data: Dictionary = VillageDifficultyCatalog.get_difficulty(difficulty_id)
	difficulty_description_label.text = (
		"%s — %s"
		% [
			String(data.get("display_name", "Moderada")).to_upper(),
			String(data.get("description", ""))
		]
	)


func _on_confirm_pressed() -> void:
	var clean_name: String = name_input.text.strip_edges()
	if clean_name.length() < 2:
		feedback_label.add_theme_color_override("font_color", Color("#F07F72"))
		feedback_label.text = (
			"[ATENÇÃO] Digite um nome com pelo menos duas letras."
		)
		VillageUIAccessibility.focus_deferred(name_input)
		return
	var clean_seed: int = VillageCampaignIdentityCatalog.seed_from_text(
		seed_input.text
	)
	seed_input.text = str(clean_seed)
	var clean_village_name: String = (
		VillageCampaignIdentityCatalog.sanitize_village_name(
			village_name_input.text,
			clean_seed
		)
	)
	if clean_village_name.length() < 2:
		feedback_label.add_theme_color_override("font_color", Color("#F07F72"))
		feedback_label.text = "[ATENÇÃO] Digite um nome válido para a vila."
		VillageUIAccessibility.focus_deferred(village_name_input)
		return
	var gender_id: String = String(gender_options.get_item_metadata(gender_options.selected))
	if gender_id not in ["masculino", "feminino"]:
		gender_id = "masculino"
	var difficulty_id: String = VillageDifficultyCatalog.sanitize_difficulty_id(
		String(difficulty_options.get_item_metadata(difficulty_options.selected))
	)
	hide_window()
	profile_confirmed.emit(
		clean_name,
		gender_id,
		difficulty_id,
		clean_village_name,
		clean_seed
	)


func _on_seed_text_changed(_new_text: String) -> void:
	feedback_label.text = ""


func _on_random_seed_pressed() -> void:
	var should_replace_village: bool = (
		village_name_input.text.strip_edges().is_empty()
		or village_name_input.text.strip_edges() == last_suggested_village_name
	)
	var new_seed: int = VillageCampaignIdentityCatalog.generate_seed()
	seed_input.text = str(new_seed)
	last_suggested_village_name = (
		VillageCampaignIdentityCatalog.suggest_village_name(new_seed)
	)
	if should_replace_village:
		village_name_input.text = last_suggested_village_name
	feedback_label.text = "Nova semente preparada."
	feedback_label.add_theme_color_override("font_color", Color("#9FD18B"))


func _on_copy_seed_pressed() -> void:
	var clean_seed: int = VillageCampaignIdentityCatalog.seed_from_text(
		seed_input.text
	)
	seed_input.text = str(clean_seed)
	DisplayServer.clipboard_set(seed_input.text)
	feedback_label.text = "Semente copiada: %d" % clean_seed
	feedback_label.add_theme_color_override("font_color", Color("#9FD18B"))


func _on_cancel_pressed() -> void:
	hide_window()
	profile_cancelled.emit()
