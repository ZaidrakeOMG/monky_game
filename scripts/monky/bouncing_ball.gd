extends CharacterBody2D
class_name BouncingBall

## Pelota Física Interactiva para la Sala de Juegos
## Permite lanzar, arrastrar, rebotar en paredes y jugar pases con Monky.

@onready var area: Area2D = $Area2D

const GRAVITY: float = 1900.0
const BOUNCE_RESTITUTION: float = 0.82
const FLOOR_Y: float = 1520.0
const LEFT_WALL_X: float = 80.0
const RIGHT_WALL_X: float = 1000.0

var is_dragged: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var prev_mouse_pos: Vector2 = Vector2.ZERO
var mouse_velocity: Vector2 = Vector2.ZERO
var gm: Node = null

func _ready() -> void:
	z_index = 25
	gm = get_tree().root.get_node_or_null("GameManager")
	
	# Efecto de aparición elástica
	scale = Vector2(0.2, 0.2)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	velocity = Vector2(randf_range(-300, 300), -600.0)
	area.input_event.connect(_on_input_event)

func _physics_process(delta: float) -> void:
	if is_dragged:
		var current_mouse = get_global_mouse_position()
		global_position = current_mouse + drag_offset
		mouse_velocity = (current_mouse - prev_mouse_pos) / delta
		prev_mouse_pos = current_mouse
		velocity = mouse_velocity
		return

	# Aplicar gravedad
	velocity.y += GRAVITY * delta
	
	# Mover
	position += velocity * delta
	
	# Rotar según velocidad horizontal
	rotation += velocity.x * 0.005 * delta * 60.0

	# Rebote en el suelo
	if position.y >= FLOOR_Y:
		position.y = FLOOR_Y
		velocity.y = -abs(velocity.y) * BOUNCE_RESTITUTION
		velocity.x *= 0.94 # Fricción con el suelo
		_play_squash()

	# Rebote en el techo (para que nunca se salga de la pantalla)
	if position.y <= 140.0:
		position.y = 140.0
		velocity.y = abs(velocity.y) * BOUNCE_RESTITUTION
		_play_squash()

	# Rebote en paredes
	if position.x <= LEFT_WALL_X:
		position.x = LEFT_WALL_X
		velocity.x = abs(velocity.x) * BOUNCE_RESTITUTION
		_play_squash()
	elif position.x >= RIGHT_WALL_X:
		position.x = RIGHT_WALL_X
		velocity.x = -abs(velocity.x) * BOUNCE_RESTITUTION
		_play_squash()


	# Comprobar colisión con Monky
	_check_monky_collision()

func _check_monky_collision() -> void:
	if is_dragged or velocity.y <= 0:
		return

	var overlapping = area.get_overlapping_areas()
	for ov in overlapping:
		var parent_node = ov.get_parent()
		if parent_node and parent_node.has_method("on_ball_hit"):
			# Monky cabecea o patea la pelota hacia arriba
			velocity.y = -randf_range(850.0, 1150.0)
			velocity.x = randf_range(-450.0, 450.0)
			_play_squash()
			parent_node.on_ball_hit(velocity)
			break


func _play_squash() -> void:
	if abs(velocity.y) > 150.0:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.06)
		tween.tween_property(self, "scale", Vector2.ONE, 0.1)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragged = true
			drag_offset = global_position - get_global_mouse_position()
			prev_mouse_pos = get_global_mouse_position()
			velocity = Vector2.ZERO
		else:
			is_dragged = false
			velocity = mouse_velocity * 1.15
	elif event is InputEventScreenTouch:
		if event.pressed:
			is_dragged = true
			drag_offset = global_position - get_global_mouse_position()
			prev_mouse_pos = get_global_mouse_position()
			velocity = Vector2.ZERO
		else:
			is_dragged = false
			velocity = mouse_velocity * 1.15

func _unhandled_input(event: InputEvent) -> void:
	if is_dragged:
		if (event is InputEventMouseButton and not event.pressed) or (event is InputEventScreenTouch and not event.pressed):
			is_dragged = false
			velocity = mouse_velocity * 1.15
