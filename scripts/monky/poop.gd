extends Node2D
class_name MonkyPoop

@onready var touch_area: Area2D = $Area2D
@onready var sparkle_particles: CPUParticles2D = $SparkleParticles

var is_cleaning: bool = false
var gm: Node = null

func _ready() -> void:
	gm = get_tree().root.get_node_or_null("GameManager")
	z_index = 8
	scale = Vector2(0.1, 0.1)
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	add_to_group("wonky_poop")
	if touch_area:
		touch_area.input_event.connect(_on_touch_event)


func _on_touch_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	var pressed := false
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed = true
	elif event is InputEventScreenTouch and event.pressed:
		pressed = true

	if pressed and gm:
		gm.show_floating_text.emit(
			"Baña a Wonky para limpiar la popó",
			global_position + Vector2(-120, -70),
			Color(0.55, 0.85, 1.0)
		)


func clean_up() -> void:
	# Se conserva el método por compatibilidad, pero ya no elimina la popó.
	# La limpieza real ocurre en Monky.rinse_water() dentro del baño.
	if gm:
		gm.show_floating_text.emit(
			"Baña a Wonky para limpiar la popó",
			global_position + Vector2(-120, -70),
			Color(0.55, 0.85, 1.0)
		)

