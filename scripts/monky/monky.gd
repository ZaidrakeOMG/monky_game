extends Node2D
class_name Monky

## Controlador visual e interactivo de Monky.
## Maneja animaciones, sueño, comida, baño y reacciones táctiles.

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var touch_area: Area2D = $TouchArea
@onready var mouth_area: Area2D = $MouthArea
@onready var body_area: Area2D = $BodyArea
@onready var soap_particles: CPUParticles2D = $SoapParticles
@onready var water_particles: CPUParticles2D = $WaterParticles
@onready var sparkle_particles: CPUParticles2D = $SparkleParticles

@onready var accessory_container: Node2D = get_node_or_null("AccessoryContainer")
@onready var clothes_slot: Sprite2D = get_node_or_null("AccessoryContainer/ClothesSlot")
@onready var face_slot: Sprite2D = get_node_or_null("AccessoryContainer/FaceSlot")
@onready var hat_slot: Sprite2D = get_node_or_null("AccessoryContainer/HatSlot")

@onready var suit_parts_root: Node2D = get_node_or_null("AccessoryContainer/SuitParts")

const ANIM_TRACKING_OFFSETS: Dictionary = {
	"pensando": [0, 0, 0, 0, 6, 16, 22, 21, 9, -3, -3, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 11, 15, 15, 12, 3, 0, -1, -1, -1, -1, 0, -1, -1, -3, -4, -1, 0, 0, 3, 3, 3, 3, 6, 12, 19, 21, 15, 3, -4, -4, -1, -3, -3, -3],
	"comer": [0, -1, -1, -10, 0, -2, -1, -1],
	"rechazar_comida": [0, 4, 0, -13, -12, -12],
	"durmiendo": [0, 0, 0, 2, 5, 5, 5, 7, 0, -1, -2, -4, -4, -1, 0, 2, 5, 5, 5, 5, 5, 5, 5, 8, 14, 15, 16, 16, 19, 20, 20, 20, 20, 19, 19, 18, 16, 15, 14, 13, 13, 12, 13, 13, 14, 14, 15, 15, 18, 19, 19, 19, 19, 20, 19, 19, 16, 15, 14, 13]
}

const SUIT_REFERENCE_SIZE := Vector2(520.0, 521.0)

var is_interacting: bool = false
var original_scale: Vector2
var gm: Node = null
var soap_level: float = 0.0
var bath_animation_time: float = 0.0
var is_rinsing: bool = false
var last_suit_tracking_dy: float = 0.0
var last_suit_tracking_anim: String = ""


func _ready() -> void:
	original_scale = scale
	gm = get_tree().root.get_node_or_null("GameManager")

	if animated_sprite:
		if not animated_sprite.animation_finished.is_connected(_on_animation_finished):
			animated_sprite.animation_finished.connect(_on_animation_finished)
		if not animated_sprite.frame_changed.is_connected(_on_animation_frame_changed):
			animated_sprite.frame_changed.connect(_on_animation_frame_changed)

		if gm and gm.is_sleeping:
			_play_sleep_animation()
		else:
			_play_idle_animation()

	if gm:
		if not gm.monky_state_changed.is_connected(_on_monky_state_changed):
			gm.monky_state_changed.connect(_on_monky_state_changed)
		if not gm.accessory_equipped.is_connected(_on_accessory_equipped):
			gm.accessory_equipped.connect(_on_accessory_equipped)

	update_accessories()

	if touch_area:
		if not touch_area.input_event.is_connected(_on_touch_area_input_event):
			touch_area.input_event.connect(_on_touch_area_input_event)

	if mouth_area:
		if not mouth_area.area_entered.is_connected(_on_mouth_area_entered):
			mouth_area.area_entered.connect(_on_mouth_area_entered)

	if body_area:
		if not body_area.area_entered.is_connected(_on_body_area_entered):
			body_area.area_entered.connect(_on_body_area_entered)


func _process(delta: float) -> void:
	# La animación de baño permanece mientras se usa la herramienta y
	# vuelve a Pensando poco después de dejar de frotar.
	if bath_animation_time > 0.0:
		bath_animation_time = maxf(0.0, bath_animation_time - delta)
		if bath_animation_time <= 0.0 and not is_rinsing:
			if animated_sprite and animated_sprite.animation == &"bano_jabon":
				_play_idle_animation()

	_update_contextual_accessory_visibility()


func can_eat() -> bool:
	if gm:
		return gm.can_eat_food()
	return true


func reject_food() -> void:
	if is_interacting:
		return

	if AudioManager:
		AudioManager.play_reject()

	is_interacting = true

	if animated_sprite and animated_sprite.sprite_frames:
		if animated_sprite.sprite_frames.has_animation("rechazar_comida"):
			animated_sprite.modulate = Color.WHITE
			animated_sprite.play("rechazar_comida")

	var orig_pos: Vector2 = position
	var tween = create_tween()
	tween.tween_property(self, "position:x", orig_pos.x - 25.0, 0.06)
	tween.tween_property(self, "position:x", orig_pos.x + 25.0, 0.08)
	tween.tween_property(self, "position:x", orig_pos.x - 18.0, 0.07)
	tween.tween_property(self, "position:x", orig_pos.x, 0.06)

	if gm:
		gm.show_floating_text.emit(
			"¡Estoy lleno!",
			global_position + Vector2(0, -180),
			Color(1.0, 0.8, 0.2)
		)

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


func _play_bath_animation(duration: float = 0.65) -> void:
	bath_animation_time = maxf(bath_animation_time, duration)
	if not animated_sprite or not animated_sprite.sprite_frames:
		return
	if animated_sprite.sprite_frames.has_animation("bano_jabon"):
		animated_sprite.modulate = Color.WHITE
		if animated_sprite.animation != &"bano_jabon":
			animated_sprite.play("bano_jabon")


func _is_in_bathroom() -> bool:
	return gm != null and str(gm.current_room).to_lower() == "baño"


func _bathroom_only_hint() -> void:
	if gm:
		gm.show_floating_text.emit(
			"Usa esto dentro del baño",
			global_position + Vector2(0, -170),
			Color(0.55, 0.85, 1.0)
		)


## Cepillado de dientes.

func brush_teeth(amount: float = 15.0) -> void:
	if not _is_in_bathroom():
		_bathroom_only_hint()
		return

	_play_bath_animation(0.65)

	if sparkle_particles:
		sparkle_particles.emitting = true

	if gm:
		gm.brush_teeth_action(amount)

	play_reaction_bounce(Vector2(1.08, 0.94))

func on_bite_received(food_info = null) -> void:
	var is_drink: bool = false
	if food_info is Dictionary:
		var cat: String = str(food_info.get("category", "")).to_lower()
		var fid: String = str(food_info.get("id", "")).to_lower()
		if "bebida" in cat or fid == "milk" or "jugo" in fid or "agua" in fid or "drink" in fid:
			is_drink = true
	elif food_info is String:
		if "leche" in food_info.to_lower() or "jugo" in food_info.to_lower() or "bebida" in food_info.to_lower():
			is_drink = true

	if AudioManager:
		if is_drink:
			AudioManager.play_drink()
		else:
			AudioManager.play_eat()
	if animated_sprite and animated_sprite.sprite_frames:
		if animated_sprite.sprite_frames.has_animation("comer"):
			animated_sprite.modulate = Color.WHITE
			if animated_sprite.animation != &"comer":
				animated_sprite.play("comer")

	var tween = create_tween()
	tween.tween_property(self, "scale", original_scale * Vector2(1.12, 0.88), 0.07)
	tween.tween_property(self, "scale", original_scale * Vector2(0.96, 1.04), 0.08)
	tween.tween_property(self, "scale", original_scale, 0.10)


## Aplicar jabón. No se dibujan manchas sobre el personaje.

func apply_soap(amount: float = 15.0) -> void:
	if not _is_in_bathroom():
		_bathroom_only_hint()
		return

	soap_level = minf(soap_level + amount, 100.0)
	_play_bath_animation(0.70)

	if soap_particles:
		soap_particles.emitting = true

	if gm:
		gm.clean(amount * 0.4)

	play_reaction_bounce(Vector2(1.04, 1.04))


func rinse_water() -> void:
	if not _is_in_bathroom():
		_bathroom_only_hint()
		return
	if is_rinsing:
		return

	is_rinsing = true
	_play_bath_animation(0.95)

	if water_particles:
		water_particles.emitting = true

	await get_tree().create_timer(0.6).timeout

	if soap_particles:
		soap_particles.emitting = false
	if water_particles:
		water_particles.emitting = false

	if gm:
		var was_dirty: bool = soap_level > 20.0 or gm.hygiene < 90.0
		gm.wash_body(50.0)

		# V8: la popó sólo desaparece al bañar/enjuagar a Wonky dentro del baño.
		var removed_poop: int = 0
		if gm.has_method("clear_all_poop_after_bath"):
			removed_poop = gm.clear_all_poop_after_bath()
		if removed_poop > 0:
			if AudioManager:
				AudioManager.play_poop_clean()
			for poop_node in get_tree().get_nodes_in_group("wonky_poop"):
				if is_instance_valid(poop_node):
					poop_node.queue_free()

		if was_dirty or removed_poop > 0:
			if AudioManager:
				AudioManager.play_sparkle()
			if sparkle_particles:
				sparkle_particles.emitting = true
			gm.add_coins(3)
			var clean_text := "¡Wonky está limpio! +3"
			if removed_poop > 0:
				clean_text = "¡Baño completo! Popó limpia +3"
			gm.show_floating_text.emit(
				clean_text,
				global_position + Vector2(0, -180),
				Color(0.4, 0.9, 1.0)
			)

	soap_level = 0.0
	is_rinsing = false
	bath_animation_time = 0.0

	if gm and gm.is_sleeping:
		_play_sleep_animation()
	else:
		_play_idle_animation()

func _on_touch_area_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		on_tapped()
	elif event is InputEventScreenTouch and event.pressed:
		on_tapped()


## Reacción al tocar o acariciar a Monky.
func on_tapped() -> void:
	if is_interacting:
		return

	if AudioManager:
		AudioManager.play_pet()

	is_interacting = true
	var tween = create_tween()
	tween.tween_property(self, "scale", original_scale * Vector2(1.15, 0.85), 0.1)
	tween.tween_property(self, "scale", original_scale * Vector2(0.9, 1.1), 0.1)
	tween.tween_property(self, "scale", original_scale, 0.15)

	if gm:
		gm.play_with_monky(3.0)

	await tween.finished
	is_interacting = false


func _on_monky_state_changed(new_state: String) -> void:
	match new_state:
		"eating":
			if animated_sprite and animated_sprite.sprite_frames:
				if animated_sprite.sprite_frames.has_animation("comer"):
					animated_sprite.modulate = Color.WHITE
					animated_sprite.play("comer")
		"happy":
			if animated_sprite and (not gm or gm.energy > 0):
				animated_sprite.modulate = Color.WHITE
		"tired":
			if animated_sprite:
				animated_sprite.modulate = Color(0.92, 0.90, 0.96)
		"sleeping":
			_play_sleep_animation()
		"idle":
			_play_idle_animation()


## Primero reproduce la entrada de sueño y después queda durmiendo en bucle.
func _play_sleep_animation() -> void:
	if not animated_sprite or not animated_sprite.sprite_frames:
		return

	animated_sprite.modulate = Color.WHITE

	if animated_sprite.sprite_frames.has_animation("dormir_entrada"):
		animated_sprite.play("dormir_entrada")
	elif animated_sprite.sprite_frames.has_animation("durmiendo"):
		animated_sprite.play("durmiendo")


func _on_animation_finished() -> void:
	if not animated_sprite:
		return

	if animated_sprite.animation == &"dormir_entrada":
		if gm and gm.is_sleeping and animated_sprite.sprite_frames.has_animation("durmiendo"):
			animated_sprite.play("durmiendo")
		return

	if animated_sprite.animation == &"comer" or animated_sprite.animation == &"rechazar_comida":
		if AudioManager:
			AudioManager.stop_eat()
		if gm and gm.is_sleeping:
			_play_sleep_animation()
		else:
			_play_idle_animation()


func _play_idle_animation() -> void:
	if not animated_sprite or not animated_sprite.sprite_frames:
		return

	if gm and gm.energy <= 0.0:
		animated_sprite.modulate = Color(0.92, 0.90, 0.96)
	else:
		animated_sprite.modulate = Color.WHITE

	if animated_sprite.sprite_frames.has_animation("pensando"):
		animated_sprite.play("pensando")


func play_reaction_bounce(target_scale: Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", original_scale * target_scale, 0.15)
	tween.tween_property(self, "scale", original_scale, 0.2)


## Reacción física cuando la pelota golpea a Monky.
func on_ball_hit(_ball_vel: Vector2) -> void:
	play_reaction_bounce(Vector2(1.25, 0.8))

	if gm:
		var needs_fun: bool = gm.fun < 90.0
		gm.play_with_monky(12.0)

		if needs_fun:
			gm.add_coins(1)
			gm.show_floating_text.emit(
				"¡Buen pase! +1",
				global_position + Vector2(0, -180),
				Color(0.3, 0.9, 1.0)
			)
		else:
			gm.show_floating_text.emit(
				"¡Buen pase!",
				global_position + Vector2(0, -180),
				Color(0.3, 0.9, 1.0)
			)


## Actualiza todos los accesorios equipados desde GameManager
func update_accessories() -> void:
	if not gm:
		return
	for cat in ["clothes", "glasses", "hat"]:
		var equipped_id: String = gm.get_equipped_accessory(cat)
		_apply_accessory(cat, equipped_id)
	_update_contextual_accessory_visibility()


func _on_accessory_equipped(category: String, item_id: String) -> void:
	_apply_accessory(category, item_id)
	_update_contextual_accessory_visibility()


func _apply_accessory(category: String, item_id: String) -> void:
	var slot: Sprite2D = null
	match category:
		"clothes":
			slot = clothes_slot
		"glasses":
			slot = face_slot
		"hat":
			slot = hat_slot

	if not slot:
		return

	if category == "clothes":
		_clear_piece_suit()

	var item: Dictionary = AccessoryCatalog.get_item(item_id)

	if category == "clothes" and bool(item.get("piece_suit", false)):
		slot.texture = null
		slot.visible = false
		_apply_piece_suit(item)
		return

	var slot_tex_path: String = str(item.get("slot_texture", ""))
	if slot_tex_path == "" or item_id.begins_with("none"):
		slot.texture = null
		slot.visible = false
		return

	if ResourceLoader.exists(slot_tex_path):
		slot.texture = load(slot_tex_path)
		slot.region_enabled = false
		slot.position = item.get("offset", Vector2.ZERO)
		slot.scale = item.get("scale", Vector2.ONE)
		slot.visible = true
	else:
		slot.texture = null
		slot.visible = false


func _ensure_suit_parts_root() -> Node2D:
	if suit_parts_root and is_instance_valid(suit_parts_root):
		return suit_parts_root
	if not accessory_container:
		return null
	var root := Node2D.new()
	root.name = "SuitParts"
	accessory_container.add_child(root)
	suit_parts_root = root
	return root


func _clear_piece_suit() -> void:
	var root := _ensure_suit_parts_root()
	if not root:
		return
	for child in root.get_children():
		child.queue_free()


func _apply_piece_suit(item: Dictionary) -> void:
	var root := _ensure_suit_parts_root()
	if not root:
		return
	_clear_piece_suit()

	var parts: Dictionary = item.get("parts", {})

	# Cada tipo de pieza tiene una zona anatómica propia de Wonky.
	var layout := {
		"cape": {"center": Vector2(0, 68), "size": Vector2(360, 270), "z": -1},
		"body": {"center": Vector2(0, 92), "size": Vector2(278, 208), "z": 1},
		"arms": {"center": Vector2(0, 88), "size": Vector2(342, 142), "z": 2},
		"feet": {"center": Vector2(0, 205), "size": Vector2(202, 82), "z": 2},
		"mask": {"center": Vector2(0, -78), "size": Vector2(240, 100), "z": 3},
		"hat": {"center": Vector2(0, -210), "size": Vector2(240, 112), "z": 4}
	}

	for part_name in ["cape", "body", "arms", "feet", "mask", "hat"]:
		if not parts.has(part_name):
			continue

		var path: String = str(parts[part_name])
		if not ResourceLoader.exists(path):
			continue

		var texture := _prepare_suit_piece_texture(path)
		if texture == null:
			continue

		var spr := Sprite2D.new()
		spr.name = String(part_name).capitalize()
		spr.texture = texture
		spr.centered = true

		var target: Dictionary = layout[part_name]
		var target_size: Vector2 = target["size"]
		var tex_size: Vector2 = texture.get_size()
		if tex_size.x <= 0.0 or tex_size.y <= 0.0:
			continue

		# Ajuste anatómico: cada pieza llena exactamente su zona objetivo.
		# Esto evita que un PNG con proporciones raras quede como "sticker".
		var scale_x: float = target_size.x / tex_size.x
		var scale_y: float = target_size.y / tex_size.y
		spr.scale = Vector2(scale_x, scale_y)
		spr.position = target["center"]
		spr.z_index = int(target["z"])
		spr.set_meta("suit_base_position", spr.position)
		spr.set_meta("suit_base_scale", spr.scale)
		spr.set_meta("suit_base_rotation", spr.rotation)
		root.add_child(spr)


func _prepare_suit_piece_texture(path: String) -> Texture2D:
	var source = load(path)
	if source == null or not (source is Texture2D):
		return null

	var image: Image = source.get_image()
	if image == null or image.is_empty():
		return source

	image.convert(Image.FORMAT_RGBA8)

	# Elimina el falso patrón de transparencia si el generador lo dibujó.
	if _has_fake_checkerboard_background(image):
		_remove_fake_checkerboard_background(image)

	# Recorta automáticamente todo el espacio transparente. La pieza resultante
	# se escala después según su zona anatómica (torso, brazos, pies, etc.).
	var used: Rect2i = image.get_used_rect()
	if used.size.x <= 1 or used.size.y <= 1:
		return null

	var cropped := Image.create(used.size.x, used.size.y, false, Image.FORMAT_RGBA8)
	cropped.blit_rect(image, used, Vector2i.ZERO)

	return ImageTexture.create_from_image(cropped)


func _is_light_neutral_pixel(color: Color) -> bool:
	if color.a < 0.90:
		return false
	var hi := maxf(color.r, maxf(color.g, color.b))
	var lo := minf(color.r, minf(color.g, color.b))
	var brightness := (color.r + color.g + color.b) / 3.0
	return brightness >= 0.62 and (hi - lo) <= 0.11


func _has_fake_checkerboard_background(image: Image) -> bool:
	var w := image.get_width()
	var h := image.get_height()
	if w < 4 or h < 4:
		return false

	var samples: Array[Vector2i] = [
		Vector2i(0, 0),
		Vector2i(w - 1, 0),
		Vector2i(0, h - 1),
		Vector2i(w - 1, h - 1),
		Vector2i(int(w / 2), 0),
		Vector2i(int(w / 2), h - 1),
		Vector2i(0, int(h / 2)),
		Vector2i(w - 1, int(h / 2))
	]
	var matches: int = 0
	for p: Vector2i in samples:
		if _is_light_neutral_pixel(image.get_pixel(p.x, p.y)):
			matches += 1
	return matches >= 5


func _remove_fake_checkerboard_background(image: Image) -> void:
	var w := image.get_width()
	var h := image.get_height()
	var total := w * h
	var visited := PackedByteArray()
	visited.resize(total)

	var queue := PackedInt32Array()

	# Sembramos desde todo el borde. Solo se elimina gris/blanco conectado
	# al exterior para no borrar detalles claros dentro del traje.
	var edge_rows: PackedInt32Array = PackedInt32Array([0, h - 1])
	var edge_cols: PackedInt32Array = PackedInt32Array([0, w - 1])

	for x_value in range(w):
		var x: int = int(x_value)
		for y_value in edge_rows:
			var y: int = int(y_value)
			var edge_idx: int = y * w + x
			if visited[edge_idx] == 0 and _is_light_neutral_pixel(image.get_pixel(x, y)):
				visited[edge_idx] = 1
				queue.append(edge_idx)

	for y_value in range(h):
		var y: int = int(y_value)
		for x_value in edge_cols:
			var x: int = int(x_value)
			var edge_idx: int = y * w + x
			if visited[edge_idx] == 0 and _is_light_neutral_pixel(image.get_pixel(x, y)):
				visited[edge_idx] = 1
				queue.append(edge_idx)

	var read_index: int = 0
	while read_index < queue.size():
		var current_idx: int = int(queue[read_index])
		read_index += 1
		var x: int = current_idx % w
		var y: int = int(current_idx / w)

		var c := image.get_pixel(x, y)
		c.a = 0.0
		image.set_pixel(x, y, c)

		if x > 0:
			_try_enqueue_checker_pixel(image, visited, queue, x - 1, y, w)
		if x + 1 < w:
			_try_enqueue_checker_pixel(image, visited, queue, x + 1, y, w)
		if y > 0:
			_try_enqueue_checker_pixel(image, visited, queue, x, y - 1, w)
		if y + 1 < h:
			_try_enqueue_checker_pixel(image, visited, queue, x, y + 1, w)


func _try_enqueue_checker_pixel(
	image: Image,
	visited: PackedByteArray,
	queue: PackedInt32Array,
	x: int,
	y: int,
	width: int
) -> void:
	var idx: int = y * width + x
	if visited[idx] != 0:
		return
	visited[idx] = 1
	if _is_light_neutral_pixel(image.get_pixel(x, y)):
		queue.append(idx)


func _on_animation_frame_changed() -> void:
	if not animated_sprite or not accessory_container:
		return

	var anim_name: String = str(animated_sprite.animation)
	var current_frame: int = animated_sprite.frame
	var dy: float = 0.0

	var offsets: Array = ANIM_TRACKING_OFFSETS.get(anim_name, [])
	if current_frame >= 0 and current_frame < offsets.size():
		dy = float(offsets[current_frame])

	# Seguimiento general: sombreros, lentes y todo el traje acompañan
	# el desplazamiento vertical real medido en cada frame de Wonky.
	accessory_container.position.y = dy

	# Seguimiento V2: cada pieza del traje recibe microajustes propios
	# para que el torso respire/rebote y los pies se mantengan más anclados.
	_update_suit_frame_tracking(anim_name, current_frame, dy)


func _update_suit_frame_tracking(anim_name: String, _frame: int, dy: float) -> void:
	var root := _ensure_suit_parts_root()
	if not root or root.get_child_count() == 0:
		last_suit_tracking_dy = dy
		last_suit_tracking_anim = anim_name
		return

	if anim_name != last_suit_tracking_anim:
		last_suit_tracking_dy = dy
		last_suit_tracking_anim = anim_name
		_reset_suit_part_tracking()

	var frame_motion: float = dy - last_suit_tracking_dy
	last_suit_tracking_dy = dy

	var intensity: float = 1.0
	match anim_name:
		"pensando":
			intensity = 1.0
		"comer":
			intensity = 1.20
		"rechazar_comida":
			intensity = 1.35
		"durmiendo":
			intensity = 0.45
		_:
			intensity = 0.70

	for child_node in root.get_children():
		if not (child_node is Sprite2D):
			continue

		var part := child_node as Sprite2D
		var base_position: Vector2 = part.get_meta("suit_base_position", part.position)
		var base_scale: Vector2 = part.get_meta("suit_base_scale", part.scale)
		var base_rotation: float = float(part.get_meta("suit_base_rotation", 0.0))

		part.position = base_position
		part.scale = base_scale
		part.rotation = base_rotation

		var part_name: String = str(part.name).to_lower()

		if part_name == "body":
			# Cuando Wonky sube/baja, el torso se estira/suaviza ligeramente.
			var squash: float = clampf(frame_motion * 0.0015 * intensity, -0.015, 0.015)
			part.scale = base_scale * Vector2(1.0 + squash, 1.0 - squash)
			part.position.y += clampf(dy * 0.02, -1.0, 2.0)

		elif part_name == "arms":
			# Los brazos responden un poco más al cambio entre frames.
			var arm_squash: float = clampf(frame_motion * 0.0012 * intensity, -0.012, 0.012)
			part.scale = base_scale * Vector2(1.0 + arm_squash, 1.0 - arm_squash)
			part.position.y += clampf(frame_motion * 0.10 * intensity, -2.0, 2.0)

		elif part_name == "feet":
			# Compensa parte del rebote global para que los zapatos no floten.
			part.position.y -= dy * 0.42

		elif part_name == "cape":
			# La capa tiene un pequeño retraso visual respecto al cuerpo.
			part.position.y -= clampf(frame_motion * 0.10 * intensity, -2.0, 2.0)

		elif part_name == "mask" or part_name == "hat":
			# Accesorios de cabeza siguen el rebote, con menos deformación.
			part.position.y += clampf(frame_motion * 0.10 * intensity, -2.0, 2.0)


func _reset_suit_part_tracking() -> void:
	var root := _ensure_suit_parts_root()
	if not root:
		return

	for child_node in root.get_children():
		if not (child_node is Sprite2D):
			continue
		var part := child_node as Sprite2D
		part.position = part.get_meta("suit_base_position", part.position)
		part.scale = part.get_meta("suit_base_scale", part.scale)
		part.rotation = float(part.get_meta("suit_base_rotation", 0.0))


func _update_contextual_accessory_visibility() -> void:
	if not gm or not accessory_container:
		return

	var anim_name: String = str(animated_sprite.animation) if animated_sprite else ""
	var is_in_bath: bool = (anim_name == "bano_jabon") or (bath_animation_time > 0.0) or is_rinsing
	var is_asleep: bool = (anim_name == "durmiendo") or (anim_name == "dormir_entrada") or gm.is_sleeping

	# 1. En el baño se desviste para lavarse con jabón y agua
	if is_in_bath:
		accessory_container.visible = false
		return

	accessory_container.visible = true

	# 2. Al dormir se quita lentes y sombreros no dormilones
	var equipped_hat: String = gm.get_equipped_accessory("hat")
	var equipped_glasses: String = gm.get_equipped_accessory("glasses")
	var equipped_clothes: String = gm.get_equipped_accessory("clothes")

	if hat_slot:
		if is_asleep:
			hat_slot.visible = (equipped_hat == "hat_nightcap")
		else:
			hat_slot.visible = (equipped_hat != "" and not equipped_hat.begins_with("none"))

	if face_slot:
		if is_asleep:
			face_slot.visible = false
		else:
			face_slot.visible = (equipped_glasses != "" and not equipped_glasses.begins_with("none"))

	if clothes_slot:
		clothes_slot.visible = (equipped_clothes != "" and not equipped_clothes.begins_with("none"))

	if suit_parts_root:
		suit_parts_root.visible = (equipped_clothes != "" and not equipped_clothes.begins_with("none"))


