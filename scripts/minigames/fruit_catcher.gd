extends Node2D

## Controlador del Minijuego "¡Atrapa la Fruta!" (Fruit Catcher)
## Sala de Juegos - Minijuego arcade táctil con frutas, monedas, bombas y recompensas reales.

@onready var background: Sprite2D = $Background
@onready var player_basket: Area2D = $PlayerBasket
@onready var basket_label: Label = $PlayerBasket/BasketLabel
@onready var monky_sprite: AnimatedSprite2D = $PlayerBasket/MonkySprite
@onready var items_container: Node2D = $ItemsContainer

@onready var spawn_timer: Timer = $SpawnTimer

# UI Nodes
@onready var score_label: Label = $HUD/TopBar/HBox/ScoreBox/ScoreLabel
@onready var coins_label: Label = $HUD/TopBar/HBox/CoinsBox/CoinsLabel
@onready var lives_label: Label = $HUD/TopBar/HBox/LivesBox/LivesLabel
@onready var btn_exit: Button = $HUD/TopBar/HBox/BtnExit

# Game Over Modal
@onready var game_over_modal: PanelContainer = $HUD/GameOverModal
@onready var final_score_label: Label = $HUD/GameOverModal/Margin/VBox/StatsGrid/HBoxScore/ScoreValue
@onready var final_coins_label: Label = $HUD/GameOverModal/Margin/VBox/StatsGrid/HBoxCoins/CoinsValue
@onready var high_score_label: Label = $HUD/GameOverModal/Margin/VBox/StatsGrid/HBoxHigh/HighScoreValue
@onready var btn_restart: Button = $HUD/GameOverModal/Margin/VBox/Buttons/BtnRestart
@onready var btn_home: Button = $HUD/GameOverModal/Margin/VBox/Buttons/BtnHome


const FRUIT_TYPES := [
	{"image": "res://imagenes/opt/alimentos/manzana.png", "name": "Manzana", "points": 10, "is_bomb": false, "is_coin": false},
	{"image": "res://imagenes/opt/alimentos/platano.png", "name": "Plátano", "points": 15, "is_bomb": false, "is_coin": false},
	{"image": "res://imagenes/opt/alimentos/fresa.png", "name": "Fresa", "points": 20, "is_bomb": false, "is_coin": false},
	{"image": "res://imagenes/opt/alimentos/sandia.png", "name": "Sandía", "points": 25, "is_bomb": false, "is_coin": false},
	{"image": "res://imagenes/opt/alimentos/pina.png", "name": "Piña", "points": 30, "is_bomb": false, "is_coin": false},
	{"image": "res://imagenes/opt/hud/nivel.png", "name": "Estrella", "points": 50, "is_bomb": false, "is_coin": false},
	{"image": "res://imagenes/opt/hud/moneda.png", "name": "Moneda", "points": 10, "is_bomb": false, "is_coin": true},
	{"image": "res://imagenes/opt/minijuegos/bomba.png", "name": "Bomba", "points": 0, "is_bomb": true, "is_coin": false}
]
var score: int = 0
var coins_earned: int = 0
var lives: int = 3
var max_lives: int = 3
var is_game_over: bool = false
var fall_speed: float = 550.0
var base_spawn_interval: float = 0.85
var gm: Node = null

# Screen bounds
const MIN_X: float = 120.0
const MAX_X: float = 960.0
const BASKET_Y: float = 1620.0

func _ready() -> void:
	gm = get_tree().root.get_node_or_null("GameManager")
	_setup_background()
	_setup_game_ui_icons()
	_setup_basket_visual()
	_setup_signals()
	start_game()


func _set_game_button_icon(button: Button, image_path: String, width: int = 50) -> void:
	if not button:
		return
	var tex = load(image_path) as Texture2D
	if tex:
		button.icon = tex
		button.expand_icon = true
		button.add_theme_constant_override("icon_max_width", width)

func _setup_game_ui_icons() -> void:
	if btn_exit:
		btn_exit.text = ""
		_set_game_button_icon(btn_exit, "res://imagenes/opt/navegacion/inicio.png", 48)
	if btn_home:
		_set_game_button_icon(btn_home, "res://imagenes/opt/navegacion/inicio.png", 42)
	if btn_restart:
		_set_game_button_icon(btn_restart, "res://imagenes/opt/configuracion/reiniciar.png", 42)

func _setup_background() -> void:
	if background and background.texture:
		var tex_size = background.texture.get_size()
		if tex_size.x > 0 and tex_size.y > 0:
			var scale_factor = maxf(1080.0 / tex_size.x, 1920.0 / tex_size.y)
			background.scale = Vector2(scale_factor, scale_factor)


func _setup_basket_visual() -> void:
	if not basket_label:
		return
	basket_label.text = ""
	var basket = Sprite2D.new()
	basket.texture = load("res://imagenes/opt/minijuegos/canasta.png") as Texture2D
	if basket.texture:
		var size = basket.texture.get_size()
		var factor = 150.0 / maxf(size.x, size.y)
		basket.scale = Vector2.ONE * factor
	basket.position = Vector2(0, 30)
	basket.z_index = 3
	player_basket.add_child(basket)

func _setup_signals() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	btn_exit.pressed.connect(_on_btn_home_pressed)
	btn_restart.pressed.connect(start_game)
	btn_home.pressed.connect(_on_btn_home_pressed)
	player_basket.area_entered.connect(_on_basket_area_entered)

func start_game() -> void:
	is_game_over = false
	score = 0
	coins_earned = 0
	lives = max_lives
	fall_speed = 550.0
	background.position = Vector2(540, 960)
	game_over_modal.visible = false

	# Limpiar items existentes
	for child in items_container.get_children():
		child.queue_free()

	_update_hud()
	spawn_timer.wait_time = base_spawn_interval
	spawn_timer.start()

func _process(delta: float) -> void:
	if is_game_over:
		return

	# Seguir posición táctil / ratón suavemente
	var target_x = clampf(get_global_mouse_position().x, MIN_X, MAX_X)
	var prev_x = player_basket.global_position.x
	player_basket.global_position.x = lerpf(player_basket.global_position.x, target_x, 22.0 * delta)
	player_basket.global_position.y = BASKET_Y

	# Inclinación dinámica de la canasta según velocidad horizontal
	var velocity_x = (player_basket.global_position.x - prev_x) / delta
	var target_rot = clampf(velocity_x * 0.0004, -0.2, 0.2)
	player_basket.rotation = lerpf(player_basket.rotation, target_rot, 15.0 * delta)

	# Actualizar caída de items
	for item in items_container.get_children():
		if item is Area2D and item.has_meta("speed"):
			var spd: float = item.get_meta("speed")
			item.position.y += spd * delta
			# Rotación suave del item cayendo
			item.rotation += item.get_meta("rot_speed", 1.0) * delta
			if item.position.y > 1950.0:
				item.queue_free()

func _on_spawn_timer_timeout() -> void:
	if is_game_over:
		return
	_spawn_falling_item()
	# Dificultad progresiva: velocidad y frecuencia
	fall_speed = minf(550.0 + (score * 2.0), 980.0)
	spawn_timer.wait_time = maxf(0.38, base_spawn_interval - (score * 0.003))

func _spawn_falling_item() -> void:
	var item_area = Area2D.new()
	var spawn_x = randf_range(MIN_X + 40, MAX_X - 40)
	item_area.position = Vector2(spawn_x, -60)

	# Elegir tipo de item ponderado
	var roll = randf()
	var chosen_data: Dictionary
	if roll < 0.15: # 15% Bomba
		chosen_data = FRUIT_TYPES[7]
	elif roll < 0.30: # 15% Moneda
		chosen_data = FRUIT_TYPES[6]
	elif roll < 0.40: # 10% Estrella
		chosen_data = FRUIT_TYPES[5]
	else: # 60% Frutas variadas
		var fruit_idx = randi_range(0, 4)
		chosen_data = FRUIT_TYPES[fruit_idx]

	item_area.set_meta("data", chosen_data)
	item_area.set_meta("speed", fall_speed * randf_range(0.9, 1.15))
	item_area.set_meta("rot_speed", randf_range(-2.0, 2.0))

	# Collision Shape
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 45.0
	col.shape = shape
	item_area.add_child(col)

	# Visual con imagen real del objeto.
	var sprite = Sprite2D.new()
	sprite.texture = load(str(chosen_data["image"])) as Texture2D
	if sprite.texture:
		var size = sprite.texture.get_size()
		var factor = 96.0 / maxf(size.x, size.y)
		sprite.scale = Vector2.ONE * factor
	sprite.z_index = 4
	item_area.add_child(sprite)

	items_container.add_child(item_area)

func _on_basket_area_entered(area: Area2D) -> void:
	if is_game_over or not area.has_meta("data"):
		return

	var data: Dictionary = area.get_meta("data")
	var hit_pos = area.global_position
	area.queue_free()

	if data.is_bomb:
		_on_bomb_caught(hit_pos)
	elif data.is_coin:
		_on_coin_caught(hit_pos, data.points)
	else:
		_on_fruit_caught(hit_pos, int(data.points))

func _on_fruit_caught(pos: Vector2, pts: int) -> void:
	score += pts
	_spawn_floating_popup("+" + str(pts), pos, Color(0.3, 1.0, 0.4))
	_bounce_basket(Vector2(1.15, 0.85))
	_update_hud()

func _on_coin_caught(pos: Vector2, pts: int) -> void:
	score += pts
	coins_earned += 1
	_spawn_floating_popup("+1 moneda", pos, Color(1.0, 0.85, 0.1))
	_bounce_basket(Vector2(1.2, 0.8))
	_update_hud()

func _on_bomb_caught(pos: Vector2) -> void:
	lives -= 1
	_spawn_floating_popup("¡BOOM!", pos, Color(1.0, 0.2, 0.2))
	_screen_shake()
	_bounce_basket(Vector2(0.8, 1.2))
	_update_hud()

	if lives <= 0:
		_trigger_game_over()

func _bounce_basket(scale_mod: Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(player_basket, "scale", scale_mod, 0.08)
	tween.tween_property(player_basket, "scale", Vector2.ONE, 0.12)

func _screen_shake() -> void:
	var tween = create_tween()
	for i in range(4):
		var offset = Vector2(randf_range(-15, 15), randf_range(-15, 15))
		tween.tween_property(self, "position", offset, 0.04)
	tween.tween_property(self, "position", Vector2.ZERO, 0.05)

func _spawn_floating_popup(text: String, pos: Vector2, color: Color) -> void:
	var label = Label.new()
	label.text = text
	label.modulate = color
	label.add_theme_font_size_override("font_size", 46)
	label.global_position = pos + Vector2(-60, -40)
	label.z_index = 50
	add_child(label)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 80, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.6).set_ease(Tween.EASE_IN)
	tween.finished.connect(label.queue_free)

func _update_hud() -> void:
	score_label.text = "PUNTOS " + str(score)
	coins_label.text = "MONEDAS +" + str(coins_earned)
	
	lives_label.text = "VIDAS " + str(lives) + "/" + str(max_lives)

func _trigger_game_over() -> void:
	is_game_over = true
	spawn_timer.stop()

	# Aplicar recompensas reales al GameManager
	if gm:
		var extra_coins = int(float(score) / 40.0)
		gm.add_coins(coins_earned + extra_coins)
		gm.play_with_monky(100.0) # 100% de Diversión
		gm.hygiene = maxf(0.0, gm.hygiene - 8.0) # Se ensucia jugando
		gm.add_xp(minf(score * 0.1, 20.0))

	# Actualizar modal de Game Over
	final_score_label.text = str(score) + " pts"
	final_coins_label.text = "+" + str(coins_earned + int(float(score) / 40.0)) + " monedas"
	high_score_label.text = str(score) + " pts"


	game_over_modal.visible = true
	game_over_modal.scale = Vector2(0.5, 0.5)
	game_over_modal.pivot_offset = game_over_modal.size / 2.0
	var tween = create_tween()
	tween.tween_property(game_over_modal, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_btn_home_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/minigames/minigames_menu.tscn")
