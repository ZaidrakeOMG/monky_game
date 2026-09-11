extends Node2D
class_name Monky

## Controlador visual e interactivo de Monky
## Maneja las animaciones, estados y eventos táctiles (caricias / toques).

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var touch_area: Area2D = $TouchArea

var is_interacting: bool = false
var original_scale: Vector2

func _ready() -> void:
	original_scale = scale
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("pensando"):
		animated_sprite.play("pensando")

	# Conectar con el GameManager
	if GameManager:
		GameManager.monky_state_changed.connect(_on_monky_state_changed)

	if touch_area:
		touch_area.input_event.connect(_on_touch_area_input_event)

func _on_touch_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		on_tapped()
	elif event is InputEventScreenTouch and event.pressed:
		on_tapped()

## Reacción al tocar o acariciar a Monky (cosquillas / caricias)
func on_tapped() -> void:
	if is_interacting:
		return
	is_interacting = true

	# Efecto visual de rebote (Squash & Stretch)
	var tween = create_tween()
	tween.tween_property(self, "scale", original_scale * Vector2(1.15, 0.85), 0.1)
	tween.tween_property(self, "scale", original_scale * Vector2(0.9, 1.1), 0.1)
	tween.tween_property(self, "scale", original_scale, 0.15)
	
	# Dar un poco de felicidad y monedas
	if GameManager:
		GameManager.play_with_monky(2.0)
		GameManager.add_coins(1)

	await tween.finished
	is_interacting = false

func _on_monky_state_changed(new_state: String) -> void:
	match new_state:
		"eating":
			play_reaction_bounce(Vector2(1.1, 1.1))
		"happy":
			play_reaction_bounce(Vector2(1.15, 1.15))
		"sleeping":
			if animated_sprite:
				animated_sprite.modulate = Color(0.6, 0.6, 0.8)
		"idle":
			if animated_sprite:
				animated_sprite.modulate = Color.WHITE

func play_reaction_bounce(target_scale: Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", original_scale * target_scale, 0.15)
	tween.tween_property(self, "scale", original_scale, 0.2)

