class_name MedievalTheme
extends RefCounted


# Paleta principal da interface.
const BACKGROUND: Color = Color("#28382F")

const WOOD_DARK: Color = Color("#332117")
const WOOD: Color = Color("#533522")
const WOOD_LIGHT: Color = Color("#765033")

const PARCHMENT: Color = Color("#E8D3A5")
const PARCHMENT_DARK: Color = Color("#C6A66D")
const PARCHMENT_LIGHT: Color = Color("#F3E3BC")

const INK: Color = Color("#302219")

const GOLD: Color = Color("#E1B95F")
const GOLD_DARK: Color = Color("#94672D")

const MOSS: Color = Color("#53663D")
const MOSS_HOVER: Color = Color("#687D4A")
const MOSS_PRESSED: Color = Color("#3E4E2E")

const GRASS: Color = Color("#75885A")

const TEXT_LIGHT: Color = Color("#F4E7C6")
const TEXT_MUTED: Color = Color("#CEBC98")
const DANGER: Color = Color("#A94738")
const SUCCESS: Color = Color("#9FD18B")
const WARNING: Color = Color("#F0C968")
const INFO: Color = Color("#A9D2E2")


static func get_season_palette(
	season_id: String,
	enhanced_contrast: bool = false
) -> Dictionary:
	if enhanced_contrast:
		return _get_high_contrast_palette(season_id)
	match season_id:
		"summer":
			return {
				"background": Color("#344238"),
				"ground": Color("#969451"),
				"panel_dark": Color("#3B2B19"),
				"panel": Color("#624526"),
				"panel_light": Color("#856538"),
				"accent": Color("#F0C968"),
				"accent_dark": Color("#A7772E"),
				"button": Color("#6F7136"),
				"button_hover": Color("#858845"),
				"button_pressed": Color("#55582A")
			}

		"autumn":
			return {
				"background": Color("#3A2D29"),
				"ground": Color("#806A45"),
				"panel_dark": Color("#3B241A"),
				"panel": Color("#633923"),
				"panel_light": Color("#8A5430"),
				"accent": Color("#E09A4B"),
				"accent_dark": Color("#9C572B"),
				"button": Color("#755039"),
				"button_hover": Color("#8C6243"),
				"button_pressed": Color("#573A2B")
			}

		"winter":
			return {
				"background": Color("#263743"),
				"ground": Color("#9EB4BB"),
				"panel_dark": Color("#28343D"),
				"panel": Color("#3C4D58"),
				"panel_light": Color("#59707C"),
				"accent": Color("#A9D2E2"),
				"accent_dark": Color("#63899B"),
				"button": Color("#486575"),
				"button_hover": Color("#5D7D8E"),
				"button_pressed": Color("#354E5C")
			}

		_:
			return {
				"background": BACKGROUND,
				"ground": GRASS,
				"panel_dark": WOOD_DARK,
				"panel": WOOD,
				"panel_light": WOOD_LIGHT,
				"accent": GOLD,
				"accent_dark": GOLD_DARK,
				"button": MOSS,
				"button_hover": MOSS_HOVER,
				"button_pressed": MOSS_PRESSED
			}


static func _get_high_contrast_palette(season_id: String) -> Dictionary:
	match season_id:
		"summer":
			return {
				"background": Color("#162018"),
				"ground": Color("#A8A75B"),
				"panel_dark": Color("#1F160D"),
				"panel": Color("#503515"),
				"panel_light": Color("#765221"),
				"accent": Color("#FFE08A"),
				"accent_dark": Color("#C99838"),
				"button": Color("#4B551B"),
				"button_hover": Color("#69762A"),
				"button_pressed": Color("#30380F")
			}

		"autumn":
			return {
				"background": Color("#1D1412"),
				"ground": Color("#8E754A"),
				"panel_dark": Color("#21110B"),
				"panel": Color("#542710"),
				"panel_light": Color("#793E18"),
				"accent": Color("#FFB85E"),
				"accent_dark": Color("#C46A28"),
				"button": Color("#5C321F"),
				"button_hover": Color("#7A4930"),
				"button_pressed": Color("#361C12")
			}

		"winter":
			return {
				"background": Color("#101C24"),
				"ground": Color("#B6CCD2"),
				"panel_dark": Color("#14212A"),
				"panel": Color("#283F4C"),
				"panel_light": Color("#416172"),
				"accent": Color("#C7EEFF"),
				"accent_dark": Color("#72A8BF"),
				"button": Color("#294F63"),
				"button_hover": Color("#3D6E84"),
				"button_pressed": Color("#183544")
			}

		_:
			return {
				"background": Color("#132018"),
				"ground": Color("#849B61"),
				"panel_dark": Color("#1D110A"),
				"panel": Color("#452813"),
				"panel_light": Color("#67401F"),
				"accent": Color("#FFE08A"),
				"accent_dark": Color("#C99035"),
				"button": Color("#344719"),
				"button_hover": Color("#4C6427"),
				"button_pressed": Color("#21300E")
			}


static func create_theme(
	season_id: String = "spring",
	enhanced_contrast: bool = false
) -> Theme:
	var medieval_theme: Theme = Theme.new()
	var palette: Dictionary = get_season_palette(
		season_id,
		enhanced_contrast
	)

	medieval_theme.default_font_size = 18

	_configure_labels(medieval_theme)
	_configure_panels(medieval_theme, palette)
	_configure_buttons(
		medieval_theme,
		palette,
		enhanced_contrast
	)
	_configure_option_buttons(
		medieval_theme,
		palette,
		enhanced_contrast
	)
	_configure_popup_menus(medieval_theme, palette)
	_configure_separators(medieval_theme, palette)
	_configure_tooltips(medieval_theme, palette)
	_configure_line_edits(
		medieval_theme,
		palette,
		enhanced_contrast
	)

	return medieval_theme


static func create_label(
	label_text: String,
	label_color: Color,
	font_size: int
) -> Label:
	var label: Label = Label.new()
	label.text = label_text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	label.add_theme_color_override(
		"font_color",
		label_color
	)

	label.add_theme_font_size_override(
		"font_size",
		font_size
	)

	return label


static func create_panel_style(
	background_color: Color,
	border_color: Color,
	border_size: int,
	radius: int,
	padding: int,
	shadow_size: int = 0
) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()

	style.bg_color = background_color
	style.border_color = border_color

	style.set_border_width_all(border_size)
	style.set_corner_radius_all(radius)

	style.content_margin_left = float(padding)
	style.content_margin_top = float(padding)
	style.content_margin_right = float(padding)
	style.content_margin_bottom = float(padding)

	if shadow_size > 0:
		style.shadow_color = Color(
			0.06,
			0.03,
			0.02,
			0.60
		)

		style.shadow_size = shadow_size
		style.shadow_offset = Vector2(
			0.0,
			3.0
		)

	return style


static func _configure_labels(medieval_theme: Theme) -> void:
	medieval_theme.set_color(
		"font_color",
		"Label",
		TEXT_LIGHT
	)

	medieval_theme.set_color(
		"font_shadow_color",
		"Label",
		Color(0.08, 0.05, 0.03, 0.75)
	)

	medieval_theme.set_constant(
		"shadow_offset_x",
		"Label",
		1
	)

	medieval_theme.set_constant(
		"shadow_offset_y",
		"Label",
		2
	)

	medieval_theme.set_font_size(
		"font_size",
		"Label",
		18
	)


static func _configure_panels(
	medieval_theme: Theme,
	palette: Dictionary
) -> void:
	var main_panel: StyleBoxFlat = _make_box(
		palette["panel_dark"],
		palette["accent_dark"],
		2,
		10,
		6
	)

	main_panel.content_margin_left = 20.0
	main_panel.content_margin_right = 20.0
	main_panel.content_margin_top = 18.0
	main_panel.content_margin_bottom = 18.0

	medieval_theme.set_stylebox(
		"panel",
		"Panel",
		main_panel
	)

	medieval_theme.set_stylebox(
		"panel",
		"PanelContainer",
		main_panel
	)


static func _configure_buttons(
	medieval_theme: Theme,
	palette: Dictionary,
	enhanced_contrast: bool
) -> void:
	var normal_style: StyleBoxFlat = _make_box(
		palette["button"],
		palette["accent_dark"],
		2,
		8,
		4
	)

	var hover_style: StyleBoxFlat = _make_box(
		palette["button_hover"],
		palette["accent"],
		2,
		8,
		6
	)

	var pressed_style: StyleBoxFlat = _make_box(
		palette["button_pressed"],
		palette["accent_dark"],
		2,
		8,
		2
	)

	var disabled_style: StyleBoxFlat = _make_box(
		Color(0.24, 0.28, 0.20, 0.70),
		Color(0.45, 0.40, 0.28, 0.70),
		2,
		8,
		0
	)

	var focus_style: StyleBoxFlat = _make_box(
		Color(0.0, 0.0, 0.0, 0.0),
		palette["accent"],
		4 if enhanced_contrast else 3,
		8,
		0
	)

	medieval_theme.set_stylebox(
		"normal",
		"Button",
		normal_style
	)

	medieval_theme.set_stylebox(
		"hover",
		"Button",
		hover_style
	)

	medieval_theme.set_stylebox(
		"pressed",
		"Button",
		pressed_style
	)

	medieval_theme.set_stylebox(
		"disabled",
		"Button",
		disabled_style
	)

	medieval_theme.set_stylebox(
		"focus",
		"Button",
		focus_style
	)

	medieval_theme.set_color(
		"font_color",
		"Button",
		TEXT_LIGHT
	)

	medieval_theme.set_color(
		"font_hover_color",
		"Button",
		Color.WHITE
	)

	medieval_theme.set_color(
		"font_pressed_color",
		"Button",
		PARCHMENT_LIGHT
	)

	medieval_theme.set_color(
		"font_focus_color",
		"Button",
		Color.WHITE
	)

	medieval_theme.set_color(
		"font_disabled_color",
		"Button",
		TEXT_MUTED
	)

	medieval_theme.set_font_size(
		"font_size",
		"Button",
		19
	)


static func _configure_option_buttons(
	medieval_theme: Theme,
	palette: Dictionary,
	enhanced_contrast: bool
) -> void:
	var normal_style: StyleBoxFlat = _make_box(
		PARCHMENT,
		palette["accent_dark"],
		2,
		6,
		2
	)

	var hover_style: StyleBoxFlat = _make_box(
		PARCHMENT_LIGHT,
		palette["accent"],
		2,
		6,
		4
	)

	var pressed_style: StyleBoxFlat = _make_box(
		PARCHMENT_DARK,
		palette["accent_dark"],
		2,
		6,
		1
	)

	var focus_style: StyleBoxFlat = _make_box(
		Color(0.0, 0.0, 0.0, 0.0),
		palette["accent"],
		4 if enhanced_contrast else 3,
		6,
		0
	)

	medieval_theme.set_stylebox(
		"normal",
		"OptionButton",
		normal_style
	)

	medieval_theme.set_stylebox(
		"hover",
		"OptionButton",
		hover_style
	)

	medieval_theme.set_stylebox(
		"pressed",
		"OptionButton",
		pressed_style
	)

	medieval_theme.set_stylebox(
		"focus",
		"OptionButton",
		focus_style
	)

	medieval_theme.set_stylebox(
		"disabled",
		"OptionButton",
		normal_style
	)

	medieval_theme.set_color(
		"font_color",
		"OptionButton",
		INK
	)

	medieval_theme.set_color(
		"font_hover_color",
		"OptionButton",
		INK
	)

	medieval_theme.set_color(
		"font_pressed_color",
		"OptionButton",
		INK
	)

	medieval_theme.set_color(
		"font_focus_color",
		"OptionButton",
		INK
	)

	medieval_theme.set_color(
		"font_disabled_color",
		"OptionButton",
		Color(0.30, 0.25, 0.20, 0.65)
	)

	medieval_theme.set_font_size(
		"font_size",
		"OptionButton",
		17
	)


static func _configure_popup_menus(
	medieval_theme: Theme,
	palette: Dictionary
) -> void:
	var popup_panel: StyleBoxFlat = _make_box(
		PARCHMENT_LIGHT,
		palette["accent_dark"],
		2,
		6,
		5
	)

	popup_panel.content_margin_left = 8.0
	popup_panel.content_margin_right = 8.0
	popup_panel.content_margin_top = 8.0
	popup_panel.content_margin_bottom = 8.0

	var popup_hover: StyleBoxFlat = _make_box(
		palette["panel_light"],
		palette["accent"],
		1,
		4,
		0
	)

	medieval_theme.set_stylebox(
		"panel",
		"PopupMenu",
		popup_panel
	)

	medieval_theme.set_stylebox(
		"hover",
		"PopupMenu",
		popup_hover
	)

	medieval_theme.set_color(
		"font_color",
		"PopupMenu",
		INK
	)

	medieval_theme.set_color(
		"font_hover_color",
		"PopupMenu",
		TEXT_LIGHT
	)

	medieval_theme.set_color(
		"font_accelerator_color",
		"PopupMenu",
		INK
	)

	medieval_theme.set_font_size(
		"font_size",
		"PopupMenu",
		17
	)


static func _configure_line_edits(
	medieval_theme: Theme,
	palette: Dictionary,
	enhanced_contrast: bool
) -> void:
	var normal_style: StyleBoxFlat = _make_box(
		PARCHMENT_LIGHT,
		palette["accent_dark"],
		2,
		6,
		1
	)
	var focus_style: StyleBoxFlat = _make_box(
		Color("#FFF4D2"),
		palette["accent"],
		4 if enhanced_contrast else 3,
		6,
		2
	)
	medieval_theme.set_stylebox("normal", "LineEdit", normal_style)
	medieval_theme.set_stylebox("focus", "LineEdit", focus_style)
	medieval_theme.set_color("font_color", "LineEdit", INK)
	medieval_theme.set_color("font_placeholder_color", "LineEdit", Color("#6B5A49"))
	medieval_theme.set_color("caret_color", "LineEdit", palette["accent_dark"] )
	medieval_theme.set_font_size("font_size", "LineEdit", 17)


static func _configure_separators(
	medieval_theme: Theme,
	palette: Dictionary
) -> void:
	var horizontal_line: StyleBoxLine = StyleBoxLine.new()
	horizontal_line.color = palette["accent_dark"]
	horizontal_line.thickness = 2

	var vertical_line: StyleBoxLine = StyleBoxLine.new()
	vertical_line.color = palette["accent_dark"]
	vertical_line.thickness = 2
	vertical_line.vertical = true

	medieval_theme.set_stylebox(
		"separator",
		"HSeparator",
		horizontal_line
	)

	medieval_theme.set_stylebox(
		"separator",
		"VSeparator",
		vertical_line
	)


static func _configure_tooltips(
	medieval_theme: Theme,
	palette: Dictionary
) -> void:
	var tooltip_panel: StyleBoxFlat = _make_box(
		PARCHMENT_LIGHT,
		palette["accent_dark"],
		2,
		6,
		4
	)

	tooltip_panel.content_margin_left = 12.0
	tooltip_panel.content_margin_right = 12.0
	tooltip_panel.content_margin_top = 9.0
	tooltip_panel.content_margin_bottom = 9.0

	medieval_theme.set_stylebox(
		"panel",
		"TooltipPanel",
		tooltip_panel
	)

	medieval_theme.set_color(
		"font_color",
		"TooltipLabel",
		INK
	)

	medieval_theme.set_font_size(
		"font_size",
		"TooltipLabel",
		16
	)


static func _make_box(
	background_color: Color,
	border_color: Color,
	border_size: int,
	radius: int,
	shadow_size: int = 0
) -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()

	box.bg_color = background_color

	box.border_color = border_color
	box.border_width_left = border_size
	box.border_width_top = border_size
	box.border_width_right = border_size
	box.border_width_bottom = border_size

	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_left = radius
	box.corner_radius_bottom_right = radius

	box.content_margin_left = 14.0
	box.content_margin_right = 14.0
	box.content_margin_top = 10.0
	box.content_margin_bottom = 10.0

	if shadow_size > 0:
		box.shadow_color = Color(0.06, 0.03, 0.02, 0.65)
		box.shadow_size = shadow_size
		box.shadow_offset = Vector2(0.0, 3.0)

	return box
