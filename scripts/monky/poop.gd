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

	if touch_area:
		touch_area.input_event.connect(_on_touch_event)

func _on_touch_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clean_up()
	elif event is InputEventScreenTouch and event.pressed:
		clean_up()

func clean_up() -> void:
	if is_cleaning:
		return
	is_cleaning = true

	if gm:
		gm.add_coins(5)
		gm.add_xp(3.0)
		gm.clean(8.0)
		if gm.has_method("remove_poop"):
			gm.remove_poop()
		gm.show_floating_text.emit("¡Limpio! +5 monedas", global_position + Vector2(0, -60), Color(1, 0.9, 0.2))

	if sparkle_particles:
		sparkle_particles.emitting = true

	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.3, 0.7), 0.08)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15).set_ease(Tween.EASE_IN)
	await tween.finished
	queue_free()
