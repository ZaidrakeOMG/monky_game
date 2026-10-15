extends Control
class_name CircleProgress

var value: float = 100.0:
	set(v):
		value = clampf(v, 0.0, max_value)
		queue_redraw()
var max_value: float = 100.0:
	set(mv):
		max_value = maxf(1.0, mv)
		queue_redraw()

var radius: float = 44.0
var ring_width: float = 6.0
var ring_color: Color = Color("#FF725E")
var bg_color: Color = Color("#2A1910", 0.92)
var border_color: Color = Color("#E6C280", 0.85)
var border_width: float = 2.5

func _draw() -> void:
	var center := size * 0.5
	# 1. Círculo de fondo con borde
	draw_circle(center, radius, bg_color)
	draw_arc(center, radius, 0.0, TAU, 48, border_color, border_width, true)
	
	# 2. Anillo de progreso radial (sentido horario desde las 12:00)
	var pct := clampf(value / max_value, 0.0, 1.0)
	if pct > 0.005:
		var start_angle := -PI * 0.5
		var sweep := TAU * pct
		var arc_col := ring_color
		if pct < 0.25:
			arc_col = Color("#FF4747")
		draw_arc(center, radius - 4.0, start_angle, start_angle + sweep, 48, arc_col, ring_width, true)
