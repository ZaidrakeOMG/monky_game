extends Node2D
class_name Monky

## Controlador visual e interactivo de Monky
## Maneja las animaciones, estados y eventos táctiles (caricias / toques).

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var touch_area: Area2D = $TouchArea
@onready var mouth_area: Area2D = $MouthArea
@onready var body_area: Area2D = $BodyArea
@onready var soap_particles: CPUParticles2D = $SoapParticles
@onready var water_particles: CPUParticles2D = $WaterParticles
@onready var sparkle_particles: CPUParticles2D = $SparkleParticles

var is_interacting: bool = false
var original_scale: Vector2
var gm: Node = null
var soap_level: float = 0.0

func _ready() -> void:
	original_scale = scale
	gm = get_tree().root.get_node_or_null("GameManager")
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("pensando"):
		animated_sprite.play("pensando")

	# Conectar con el GameManager
	if gm:
		gm.monky_state_changed.connect(_on_monky_state_changed)

	if touch_area:
		touch_area.input_event.connect(_on_touch_area_input_event)

	if mouth_area:
		mouth_area.area_entered.connect(_on_mouth_area_entered)

	if body_area:
		body_area.area_entered.connect(_on_body_area_entered)

func can_eat() -> bool:
	if gm:
		return gm.can_eat_food()
	return true

func reject_food() -> void:
	if is_interacting:
		return
	is_interacting = true
	var orig_pos = position
	var tween = create_tween()
	tween.tween_property(self, "position:x", orig_pos.x - 25.0, 0.06)
	tween.tween_property(self, "position:x", orig_pos.x + 25.0, 0.08)
	tween.tween_property(self, "position:x", orig_pos.x - 18.0, 0.07)
	tween.tween_property(self, "position:x", orig_pos.x, 0.06)
	if gm:
		gm.show_floating_text.emit("¡Estoy lleno! 😋", global_position + Vector2(0, -180), Color(1.0, 0.8, 0.2))
	await tween.finished
	is_interacting = false

func _on_mouth_area_entered(other_area: Area2D) -> void:
	var item = other_area.get_parent()
	if item and item.has_method("take_bite") and item.get("item_type") == "food":
		if can_eat():
			item.take_bite(self)
		else:
			reject_food()

func _on_body_area_entered(other_area: Area2D) -> void:
	var item = other_area.get_parent()
	if item and item.has_method("finish_and_destroy"):
		var type = item.get("item_type")
		if type == "soap":
			apply_soap(15.0)
		elif type == "shower":
			rinse_water()

## Reacción física a cada mordisco de comida
func on_bite_received(_food_name: String) -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", original_scale * Vector2(1.18, 0.82), 0.08)
	tween.tween_property(self, "scale", original_scale * Vector2(0.92, 1.08), 0.1)
	tween.tween_property(self, "scale", original_scale, 0.12)

## Aplicar jabón y generar burbujas
func apply_soap(amount: float = 15.0) -> void:
	soap_level = minf(soap_level + amount, 100.0)
	if soap_particles:
		soap_particles.emitting = true
	if gm:
		gm.clean(amount * 0.4)
	play_reaction_bounce(Vector2(1.08, 1.08))

## Enjuagar con agua y limpiar toda la espuma
func rinse_water() -> void:
	if water_particles:
		water_particles.emitting = true
	
	await get_tree().create_timer(0.6).timeout
	
	if soap_particles:
		soap_particles.emitting = false
	if water_particles:
		water_particles.emitting = false
	if sparkle_particles:
		sparkle_particles.emitting = true

	if gm:
		gm.clean(50.0)
		gm.show_floating_text.emit("✨ ¡Monky está reluciente! ✨", global_position + Vector2(0, -180), Color(0.4, 0.9, 1.0))

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
	if gm:
		gm.play_with_monky(2.0)
		gm.add_coins(1)

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

## Reacción física cuando la pelota golpea a Monky (cabezazo / volea)
func on_ball_hit(_ball_vel: Vector2) -> void:
	play_reaction_bounce(Vector2(1.25, 0.8))
	if gm:
		gm.play_with_monky(12.0)
		gm.add_coins(2)
		gm.show_floating_text.emit("⚽ ¡Buen pase! +2🪙", global_position + Vector2(0, -180), Color(0.3, 0.9, 1.0))



