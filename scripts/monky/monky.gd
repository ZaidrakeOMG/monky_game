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
var body_dirt_level: float = 0.0
var dirt_overlay: Node2D = null

func _ready() -> void:
	original_scale = scale
	gm = get_tree().root.get_node_or_null("GameManager")
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("pensando"):
		animated_sprite.play("pensando")

	if gm:
		body_dirt_level = clampf((100.0 - gm.hygiene) / 100.0, 0.0, 1.0)
	_setup_dirt_overlay()

	# Conectar con el GameManager
	if gm:
		gm.monky_state_changed.connect(_on_monky_state_changed)
		gm.stat_changed.connect(_on_stat_changed)

	if touch_area:
		touch_area.input_event.connect(_on_touch_area_input_event)

	if mouth_area:
		mouth_area.area_entered.connect(_on_mouth_area_entered)

	if body_area:
		body_area.area_entered.connect(_on_body_area_entered)

func _setup_dirt_overlay() -> void:
	dirt_overlay = Node2D.new()
	dirt_overlay.name = "DirtOverlay"
	dirt_overlay.z_index = 2
	add_child(dirt_overlay)

	var patch_positions = [
		Vector2(-90, -40), # Mejilla izquierda
		Vector2(100, -30), # Mejilla derecha
		Vector2(10, -130), # Frente
		Vector2(-60, 90),  # Pancita izquierda
		Vector2(70, 110),  # Pancita derecha
		Vector2(-10, 160)  # Abajo
	]
	var patch_sizes = [
		Vector2(32, 24),
		Vector2(28, 26),
		Vector2(36, 20),
		Vector2(40, 28),
		Vector2(34, 25),
		Vector2(45, 22)
	]

	for i in range(patch_positions.size()):
		var patch = Panel.new()
		var p_style = StyleBoxFlat.new()
		p_style.bg_color = Color(0.42, 0.28, 0.15, 0.78) # Manchas de barro / suciedad
		p_style.set_corner_radius_all(14)
		patch.add_theme_stylebox_override("panel", p_style)
		patch.size = patch_sizes[i]
		patch.position = patch_positions[i] - (patch_sizes[i] / 2.0)
		patch.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dirt_overlay.add_child(patch)

	update_dirt_visuals()

func update_dirt_visuals() -> void:
	if not dirt_overlay:
		return
	var target_alpha = 0.0
	if body_dirt_level > 0.08:
		target_alpha = clampf((body_dirt_level - 0.08) / 0.85, 0.0, 1.0)
	
	var tween = create_tween()
	tween.tween_property(dirt_overlay, "modulate:a", target_alpha, 0.3)

func _on_stat_changed(stat_name: String, cur_val: float, _max_val: float) -> void:
	if stat_name == "hygiene":
		if cur_val < 70.0:
			var calculated_dirt = (100.0 - cur_val) / 100.0
			body_dirt_level = maxf(body_dirt_level, calculated_dirt)
			update_dirt_visuals()

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
	if not item:
		return
	var type = item.get("item_type")
	if item.has_method("take_bite") and type == "food":
		if can_eat():
			item.take_bite(self)
		else:
			reject_food()
	elif type == "toothbrush":
		brush_teeth(15.0)

func _on_body_area_entered(other_area: Area2D) -> void:
	var item = other_area.get_parent()
	if item and item.has_method("finish_and_destroy"):
		var type = item.get("item_type")
		if type == "soap":
			apply_soap(15.0)
		elif type == "shower":
			rinse_water()

## Cepillado de dientes con brillo en la boca (NO limpia el barro del cuerpo)
func brush_teeth(amount: float = 15.0) -> void:
	if sparkle_particles:
		sparkle_particles.emitting = true
	if gm:
		gm.brush_teeth_action(amount)
	play_reaction_bounce(Vector2(1.12, 0.9))

## Reacción física a cada mordisco de comida
func on_bite_received(_food_name: String) -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", original_scale * Vector2(1.18, 0.82), 0.08)
	tween.tween_property(self, "scale", original_scale * Vector2(0.92, 1.08), 0.1)
	tween.tween_property(self, "scale", original_scale, 0.12)

## Aplicar jabón y generar burbujas en el cuerpo (disuelve el barro progresivamente)
func apply_soap(amount: float = 15.0) -> void:
	soap_level = minf(soap_level + amount, 100.0)
	# El jabón disuelve las manchas de barro a medida que se frota
	body_dirt_level = maxf(0.0, body_dirt_level - 0.20)
	update_dirt_visuals()
	if soap_particles:
		soap_particles.emitting = true
	if gm:
		gm.clean(amount * 0.4)
	play_reaction_bounce(Vector2(1.08, 1.08))

## Enjuagar con agua y limpiar toda la espuma y suciedad del cuerpo
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
		var was_dirty: bool = (body_dirt_level > 0.05 or soap_level > 20.0 or gm.hygiene < 85.0)
		gm.wash_body(50.0)
		if was_dirty:
			gm.add_coins(3)
			gm.show_floating_text.emit("✨ ¡Monky está limpio! +3 🪙", global_position + Vector2(0, -180), Color(0.4, 0.9, 1.0))
		else:
			gm.show_floating_text.emit("✨ ¡Monky está reluciente! ✨", global_position + Vector2(0, -180), Color(0.4, 0.9, 1.0))
	
	soap_level = 0.0
	body_dirt_level = 0.0
	update_dirt_visuals()

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
	
	# Dar felicidad a Monky al acariciarlo
	if gm:
		gm.play_with_monky(3.0)

	await tween.finished
	is_interacting = false

func _on_monky_state_changed(new_state: String) -> void:
	match new_state:
		"eating":
			play_reaction_bounce(Vector2(1.1, 1.1))
			if animated_sprite and (not gm or gm.energy > 0):
				animated_sprite.modulate = Color.WHITE
		"happy":
			play_reaction_bounce(Vector2(1.15, 1.15))
			if animated_sprite and (not gm or gm.energy > 0):
				animated_sprite.modulate = Color.WHITE
		"tired":
			# Tono suave de descanso sin oscurecer excesivamente el sprite
			if animated_sprite:
				animated_sprite.modulate = Color(0.92, 0.90, 0.96)
		"sleeping":
			if animated_sprite:
				animated_sprite.modulate = Color(0.70, 0.70, 0.85)
		"idle":
			if animated_sprite:
				if gm and gm.energy <= 0.0:
					animated_sprite.modulate = Color(0.92, 0.90, 0.96)
				else:
					animated_sprite.modulate = Color.WHITE

func play_reaction_bounce(target_scale: Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", original_scale * target_scale, 0.15)
	tween.tween_property(self, "scale", original_scale, 0.2)

## Reacción física cuando la pelota golpea a Monky (cabezazo / volea)
func on_ball_hit(_ball_vel: Vector2) -> void:
	play_reaction_bounce(Vector2(1.25, 0.8))
	if gm:
		var needs_fun: bool = (gm.fun < 90.0)
		gm.play_with_monky(12.0)
		if needs_fun:
			gm.add_coins(1)
			gm.show_floating_text.emit("⚽ ¡Buen pase! +1🪙", global_position + Vector2(0, -180), Color(0.3, 0.9, 1.0))
		else:
			gm.show_floating_text.emit("⚽ ¡Buen pase!", global_position + Vector2(0, -180), Color(0.3, 0.9, 1.0))



