class_name VillageBoardPawn
extends Control


var pawn_color: Color = Color("#5DADE2")
var mood_id: String = "steady"
var pattern_index: int = 0
var selected: bool = false
var named_piece: bool = false


func configure(
	color_value: Color,
	mood_value: String,
	pattern_value: int,
	is_named: bool = false,
	is_selected: bool = false
) -> void:
	pawn_color = color_value
	mood_id = mood_value
	pattern_index = maxi(0, pattern_value)
	named_piece = is_named
	selected = is_selected
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func set_mood(mood_value: String) -> void:
	if mood_id == mood_value:
		return
	mood_id = mood_value
	queue_redraw()


func _draw() -> void:
	var width: float = size.x
	var height: float = size.y
	if width <= 2.0 or height <= 2.0:
		return

	var center_x: float = width * 0.5
	var unit: float = minf(width, height)
	var head_radius: float = unit * 0.17
	var head_center: Vector2 = Vector2(center_x, height * 0.27)
	var body_top: float = head_center.y + head_radius * 0.72
	var body_bottom: float = height * 0.76
	var body_half_top: float = unit * 0.13
	var body_half_bottom: float = unit * 0.28
	var outline: Color = Color(0.08, 0.07, 0.10, 0.96)
	var highlight: Color = pawn_color.lightened(0.24)
	var shadow: Color = pawn_color.darkened(0.30)

	# A base larga e o corpo afunilado lembram uma peça de tabuleiro,
	# sem depender de sprite, espécie, corpo ou roupa.
	draw_circle(
		Vector2(center_x, height * 0.80),
		unit * 0.29,
		outline
	)
	draw_circle(
		Vector2(center_x, height * 0.79),
		unit * 0.25,
		shadow
	)
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(center_x - body_half_top, body_top),
			Vector2(center_x + body_half_top, body_top),
			Vector2(center_x + body_half_bottom, body_bottom),
			Vector2(center_x - body_half_bottom, body_bottom)
		]),
		pawn_color
	)
	draw_polyline(
		PackedVector2Array([
			Vector2(center_x - body_half_top, body_top),
			Vector2(center_x - body_half_bottom, body_bottom),
			Vector2(center_x + body_half_bottom, body_bottom),
			Vector2(center_x + body_half_top, body_top)
		]),
		outline,
		maxf(1.0, unit * 0.045),
		true
	)
	draw_circle(head_center, head_radius + unit * 0.035, outline)
	draw_circle(head_center, head_radius, pawn_color)
	draw_circle(
		head_center + Vector2(-head_radius * 0.34, -head_radius * 0.30),
		maxf(1.0, head_radius * 0.24),
		highlight
	)

	_draw_pattern(center_x, body_top, body_bottom, unit, outline, highlight)
	_draw_mood_mark(head_center, head_radius, unit)

	if selected:
		draw_arc(
			Vector2(center_x, height * 0.53),
			unit * 0.44,
			0.0,
			TAU,
			28,
			Color("#F1C86C"),
			maxf(1.5, unit * 0.055),
			true
		)


func _draw_pattern(
	center_x: float,
	body_top: float,
	body_bottom: float,
	unit: float,
	outline: Color,
	highlight: Color
) -> void:
	var center_y: float = lerpf(body_top, body_bottom, 0.55)
	match pattern_index % 5:
		0:
			draw_circle(Vector2(center_x, center_y), unit * 0.055, outline)
		1:
			draw_line(
				Vector2(center_x - unit * 0.17, center_y),
				Vector2(center_x + unit * 0.17, center_y),
				highlight,
				maxf(1.0, unit * 0.045),
				true
			)
		2:
			for offset: float in [-0.07, 0.07]:
				draw_line(
					Vector2(center_x - unit * 0.15, center_y + unit * offset),
					Vector2(center_x + unit * 0.15, center_y + unit * offset),
					outline,
					maxf(1.0, unit * 0.035),
					true
				)
		3:
			draw_arc(
				Vector2(center_x, center_y),
				unit * 0.09,
				0.0,
				TAU,
				18,
				outline,
				maxf(1.0, unit * 0.035),
				true
			)
		_:
			draw_colored_polygon(
				PackedVector2Array([
					Vector2(center_x, center_y - unit * 0.08),
					Vector2(center_x + unit * 0.08, center_y),
					Vector2(center_x, center_y + unit * 0.08),
					Vector2(center_x - unit * 0.08, center_y)
				]),
				outline
			)


func _draw_mood_mark(
	head_center: Vector2,
	head_radius: float,
	unit: float
) -> void:
	var marker_center: Vector2 = head_center + Vector2(
		head_radius * 1.12,
		-head_radius * 0.95
	)
	match mood_id:
		"joyful":
			draw_circle(marker_center, unit * 0.055, Color("#F1C86C"))
			draw_line(
				marker_center + Vector2(-unit * 0.08, 0.0),
				marker_center + Vector2(unit * 0.08, 0.0),
				Color("#FFF0B8"),
				maxf(1.0, unit * 0.025),
				true
			)
		"worried":
			draw_line(
				marker_center + Vector2(-unit * 0.06, 0.0),
				marker_center + Vector2(unit * 0.06, 0.0),
				Color("#E5B567"),
				maxf(1.0, unit * 0.035),
				true
			)
		"crisis":
			draw_circle(marker_center, unit * 0.075, Color("#8E3036"))
			draw_line(
				marker_center + Vector2(0.0, -unit * 0.04),
				marker_center + Vector2(0.0, unit * 0.025),
				Color.WHITE,
				maxf(1.0, unit * 0.03),
				true
			)
			draw_circle(
				marker_center + Vector2(0.0, unit * 0.05),
				maxf(0.8, unit * 0.015),
				Color.WHITE
			)
