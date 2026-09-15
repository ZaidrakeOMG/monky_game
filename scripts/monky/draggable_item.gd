extends Node2D
class_name DraggableItem

## Objeto interactivo arrastrable con el dedo o ratón (Comida, Jabón, Ducha)
## Detecta colisiones con la boca o el cuerpo de Monky para aplicar efectos físicos.

signal item_consumed(item_data: Dictionary)
signal item_finished()

@onready var icon_label: Label = $IconLabel
@onready var area: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D

var item_type: String = "food" # "food", "soap", "shower"
var item_data: Dictionary = {}
var is_dragging: bool = true
var bites_left: int = 3
var total_bites: int = 3
var can_bite: bool = true
var rub_timer: float = 0.0

var gm: Node = null

func _ready() -> void:
	z_index = 40
	gm = get_tree().root.get_node_or_null("GameManager")
	_update_visuals()

	# Animación de aparición elástica
	scale = Vector2(0.2, 0.2)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func setup(type: String, data: Dictionary = {}) -> void:
	item_type = type
	item_data = data
	if item_type == "food":
		bites_left = 3
		total_bites = 3
	_update_visuals()

func _update_visuals() -> void:
	if not icon_label:
		return
	match item_type:
		"food":
			icon_label.text = item_data.get("icon", "🍎")
		"soap":
			icon_label.text = "🧼"
		"shower":
			icon_label.text = "🚿"
		"toothbrush":
			icon_label.text = "🪥"

func _process(delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position()
		
		# Si es jabón, ducha o cepillo de dientes, frotar periódicamente sobre Monky
		if item_type == "soap" or item_type == "shower" or item_type == "toothbrush":
			rub_timer += delta
			if rub_timer >= 0.12:
				rub_timer = 0.0
				_check_rubbing()

func _check_rubbing() -> void:
	if not area:
		return
	var overlapping = area.get_overlapping_areas()
	for ov in overlapping:
		var parent_node = ov.get_parent()
		if parent_node:
			if item_type == "soap" and (ov.name == "BodyArea" or ov.name == "TouchArea") and parent_node.has_method("apply_soap"):
				parent_node.apply_soap(10.0)
			elif item_type == "shower" and (ov.name == "BodyArea" or ov.name == "TouchArea") and parent_node.has_method("rinse_water"):
				parent_node.rinse_water()
			elif item_type == "toothbrush" and ov.name == "MouthArea" and parent_node.has_method("brush_teeth"):
				parent_node.brush_teeth(12.0)


var is_eating_sequence: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_release()
	elif event is InputEventScreenTouch and not event.pressed:
		_on_release()

func _on_release() -> void:
	if item_type != "food":
		# Herramientas de baño terminan al soltar
		finish_and_destroy()
	else:
		if is_eating_sequence or bites_left < total_bites:
			# Ya comenzó a comer, permitir que termine la secuencia de mordiscos
			return
		# Si se soltó lejos sin comer nada
		finish_and_destroy()

func take_bite(monky_ref: Node2D) -> void:
	if bites_left <= 0:
		return

	is_eating_sequence = true
	can_bite = false
	bites_left -= 1

	# Efecto visual de mordisco: reduce escala y rebota
	var bite_ratio = float(bites_left) / float(total_bites)
	var target_scale = Vector2.ONE * maxf(0.25, bite_ratio)

	var tween = create_tween()
	tween.tween_property(self, "scale", target_scale * 1.25, 0.08)
	tween.tween_property(self, "scale", target_scale, 0.1)

	# Monky reacciona masticando
	if is_instance_valid(monky_ref) and monky_ref.has_method("on_bite_received"):
		monky_ref.on_bite_received(item_data.get("name", "Comida"))

	# Si ya no quedan mordiscos, aplicar la comida completa y descontar del inventario
	if bites_left <= 0:
		if gm:
			gm.feed_item(item_data)
		item_consumed.emit(item_data)
		finish_and_destroy()
	else:
		# Secuencia automática continua para terminar de comer
		await get_tree().create_timer(0.26).timeout
		if is_instance_valid(self) and is_instance_valid(monky_ref):
			take_bite(monky_ref)

func finish_and_destroy() -> void:
	is_dragging = false
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15).set_ease(Tween.EASE_IN)
	tween.finished.connect(func():
		item_finished.emit()
		queue_free()
	)
