class_name VillageMedalBadge
extends Control


var medal_id: String = ""


func _ready() -> void:
	custom_minimum_size = Vector2(42.0, 38.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func set_medal(new_medal_id: String) -> void:
	medal_id = new_medal_id if new_medal_id in ["bronze", "silver", "gold"] else ""
	visible = not medal_id.is_empty()
	queue_redraw()


func _draw() -> void:
	if medal_id.is_empty():
		return
	var medal_color: Color = Color("#C8834A")
	var bright_color: Color = Color("#F0B46D")
	match medal_id:
		"silver":
			medal_color = Color("#AEB8C4")
			bright_color = Color("#E5EDF2")
		"gold":
			medal_color = Color("#D9A62E")
			bright_color = Color("#FFE48A")
	var center: Vector2 = Vector2(size.x * 0.5, 17.0)
	var ribbon_left: PackedVector2Array = PackedVector2Array([
		Vector2(center.x - 12.0, 20.0),
		Vector2(center.x - 4.0, 22.0),
		Vector2(center.x - 8.0, 37.0),
		Vector2(center.x - 15.0, 30.0)
	])
	var ribbon_right: PackedVector2Array = PackedVector2Array([
		Vector2(center.x + 12.0, 20.0),
		Vector2(center.x + 4.0, 22.0),
		Vector2(center.x + 8.0, 37.0),
		Vector2(center.x + 15.0, 30.0)
	])
	draw_colored_polygon(ribbon_left, Color("#7E3151"))
	draw_colored_polygon(ribbon_right, Color("#4D5F91"))
	draw_circle(center, 14.0, Color("#5A3927"))
	draw_circle(center, 12.0, medal_color)
	draw_arc(center, 9.0, 0.0, TAU, 24, bright_color, 2.0, true)
	var star: PackedVector2Array = PackedVector2Array()
	for index: int in range(10):
		var angle: float = -PI * 0.5 + float(index) * PI / 5.0
		var radius: float = 6.0 if index % 2 == 0 else 2.8
		star.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_colored_polygon(star, bright_color)
