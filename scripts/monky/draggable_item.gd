extends Node2D
class_name DraggableItem

## Objeto interactivo arrastrable con el dedo o ratón.
## Usa imágenes optimizadas para comida y herramientas de baño.

signal item_consumed(item_data: Dictionary)
signal item_finished()

@onready var icon_sprite: Sprite2D = $IconSprite
@onready var area: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D

var item_type: String = "food" # "food", "soap", "shower", "toothbrush"
var item_data: Dictionary = {}
var is_dragging: bool = true
var bites_left: int = 3
var total_bites: int = 3
var can_bite: bool = true
var rub_timer: float = 0.0
var is_eating_sequence: bool = false

var gm: Node = null

const TOOL_IMAGES := {
	"soap": "res://imagenes/opt/bano/jabon.png",
	"shower": "res://imagenes/opt/bano/ducha.png",
	"toothbrush": "res://imagenes/opt/bano/cepillo_dientes.png"
}

func _ready() -> void:
	z_index = 40
	gm = get_tree().root.get_node_or_null("GameManager")
	_update_visuals()

	# Aparición corta y suave para Android.
	scale = Vector2(0.35, 0.35)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func setup(type: String, data: Dictionary = {}) -> void:
	item_type = type
	item_data = data
	if item_type == "food":
		bites_left = 3
		total_bites = 3
	_update_visuals()

func _update_visuals() -> void:
	if not icon_sprite:
		return

	var image_path: String = ""
	if item_type == "food":
		image_path = str(item_data.get("image", ""))
	else:
		image_path = str(TOOL_IMAGES.get(item_type, ""))

	if image_path != "" and ResourceLoader.exists(image_path):
		icon_sprite.texture = load(image_path)
	else:
		icon_sprite.texture = null


var is_shower_playing: bool = false

func _process(delta: float) -> void:
	if not is_dragging:
		return

	# Las herramientas del baño no pueden viajar a otros cuartos.
	if item_type in ["soap", "shower", "toothbrush"]:
		if not gm or str(gm.current_room).to_lower() != "baño":
			finish_and_destroy()
			return

	global_position = get_global_mouse_position()

	# Manejo continuo y fluido del sonido de la regadera
	if item_type == "shower":
		var touching_monky: bool = false
		if area and is_dragging:
			for ov in area.get_overlapping_areas():
				if ov.name == "BodyArea" or ov.name == "TouchArea":
					touching_monky = true
					break
		if touching_monky:
			if not is_shower_playing and AudioManager:
				is_shower_playing = true
				AudioManager.start_shower()
		else:
			if is_shower_playing and AudioManager:
				is_shower_playing = false
				AudioManager.stop_shower()

	if item_type == "soap" or item_type == "shower" or item_type == "toothbrush":
		rub_timer += delta
		if rub_timer >= 0.20:
			rub_timer = 0.0
			_check_rubbing()


func _check_rubbing() -> void:
	if not area or not gm or str(gm.current_room).to_lower() != "baño":
		return

	for ov in area.get_overlapping_areas():
		var parent_node = ov.get_parent()
		if not parent_node:
			continue

		if item_type == "soap" and (ov.name == "BodyArea" or ov.name == "TouchArea") and parent_node.has_method("apply_soap"):
			parent_node.apply_soap(8.0)
			if AudioManager:
				AudioManager.play_soap()
		elif item_type == "shower" and (ov.name == "BodyArea" or ov.name == "TouchArea") and parent_node.has_method("rinse_water"):
			parent_node.rinse_water()
		elif item_type == "toothbrush" and ov.name == "MouthArea" and parent_node.has_method("brush_teeth"):
			parent_node.brush_teeth(8.0)
			if AudioManager:
				AudioManager.play_toothbrush()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_release()
	elif event is InputEventScreenTouch and not event.pressed:
		_on_release()

func _on_release() -> void:
	if is_shower_playing and AudioManager:
		is_shower_playing = false
		AudioManager.stop_shower()

	if item_type != "food":
		if gm:
			gm.save_game()
		finish_and_destroy()
	else:
		if is_eating_sequence or bites_left < total_bites:
			return
		finish_and_destroy()

func take_bite(monky_ref: Node2D) -> void:
	if bites_left <= 0 or not can_bite:
		return

	is_eating_sequence = true
	can_bite = false
	bites_left -= 1

	var bite_ratio: float = float(bites_left) / float(total_bites)
	var target_scale := Vector2.ONE * maxf(0.25, bite_ratio)
	var tween = create_tween()
	tween.tween_property(self, "scale", target_scale * 1.16, 0.06)
	tween.tween_property(self, "scale", target_scale, 0.08)

	if is_instance_valid(monky_ref) and monky_ref.has_method("on_bite_received"):
		monky_ref.on_bite_received(item_data)

	if bites_left <= 0:
		if gm:
			gm.feed_item(item_data)
		item_consumed.emit(item_data)
		finish_and_destroy()
	else:
		await get_tree().create_timer(0.20).timeout
		if is_instance_valid(self) and is_instance_valid(monky_ref):
			can_bite = true
			take_bite(monky_ref)

func finish_and_destroy() -> void:
	if not is_inside_tree():
		return
	if item_type == "shower" and AudioManager:
		AudioManager.stop_shower()
	is_dragging = false
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.12).set_ease(Tween.EASE_IN)
	tween.finished.connect(func():
		item_finished.emit()
		queue_free()
	)
