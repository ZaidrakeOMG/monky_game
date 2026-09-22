extends Node2D

## Controlador del Minijuego "Flappy Monky"
## Minijuego estilo Flappy Bird adaptado a Monky con toques táctiles, obstáculos de jungla y recompensas.

@onready var background: Sprite2D = $Background
@onready var player: Area2D = $Player
@onready var monky_sprite: AnimatedSprite2D = $Player/MonkySprite
@onready var pipes_container: Node2D = $PipesContainer

@onready var spawn_timer: Timer = $SpawnTimer

# UI
@onready var score_label: Label = $HUD/TopBar/ScoreBox/ScoreLabel
@onready var coins_label: Label = $HUD/TopBar/CoinsBox/CoinsLabel
@onready var btn_exit: Button = $HUD/TopBar/BtnExit
@onready var tap_hint: Label = $HUD/TapHint

# Game Over Modal
@onready var game_over_modal: PanelContainer = $HUD/GameOverModal
@onready var final_score_label: Label = $HUD/GameOverModal/Margin/VBox/StatsGrid/HBoxScore/ScoreValue
@onready var final_coins_label: Label = $HUD/GameOverModal/Margin/VBox/StatsGrid/HBoxCoins/CoinsValue
@onready var high_score_label: Label = $HUD/GameOverModal/Margin/VBox/StatsGrid/HBoxHigh/HighScoreValue
@onready var btn_restart: Button = $HUD/GameOverModal/Margin/VBox/Buttons/BtnRestart
@onready var btn_home: Button = $HUD/GameOverModal/Margin/VBox/Buttons/BtnHome

# Físicas del vuelo
const GRAVITY: float = 1750.0
const JUMP_VELOCITY: float = -620.0
const PIPE_SPEED: float = 380.0
const GAP_SIZE: float = 420.0

var velocity_y: float = 0.0
var score: int = 0
var coins_earned: int = 0
var is_game_started: bool = false
var is_game_over: bool = false
var gm: Node = null

func _ready() -> void:
	gm = get_tree().root.get_node_or_null("GameManager")
	_setup_background()
	_setup_game_ui_icons()
	_setup_signals()
	reset_game()


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

func _setup_signals() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	btn_exit.pressed.connect(_on_btn_home_pressed)
	btn_restart.pressed.connect(reset_game)
	btn_home.pressed.connect(_on_btn_home_pressed)
	player.area_entered.connect(_on_player_area_entered)

func reset_game() -> void:
	is_game_started = false
	is_game_over = false
	velocity_y = 0.0
	score = 0
	coins_earned = 0
	player.position = Vector2(280, 960)
	player.rotation = 0.0
	background.position = Vector2(540, 960)
	tap_hint.visible = true
	game_over_modal.visible = false
	spawn_timer.stop()

	for child in pipes_container.get_children():
		child.queue_free()

	_update_hud()

func _unhandled_input(event: InputEvent) -> void:
	if is_game_over:
		return

	var is_tap = false
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		is_tap = true
	elif event is InputEventScreenTouch and event.pressed:
		is_tap = true

	if is_tap:
		_on_jump()

func _on_jump() -> void:
	if not is_game_started:
		is_game_started = true
		tap_hint.visible = false
		spawn_timer.start()

	if AudioManager:
		AudioManager.play_jump()
	velocity_y = JUMP_VELOCITY
	var tween = create_tween()
	tween.tween_property(player, "rotation", deg_to_rad(-22.0), 0.1)

func _process(delta: float) -> void:
	if not is_game_started or is_game_over:
		return

	# Aplicar gravedad
	velocity_y += GRAVITY * delta
	player.position.y += velocity_y * delta

	# Rotación hacia abajo al caer
	if velocity_y > 100.0:
		var target_rot = clampf(deg_to_rad((velocity_y - 100.0) * 0.08), -0.4, 1.2)
		player.rotation = lerpf(player.rotation, target_rot, 8.0 * delta)

	# Límites superior e inferior
	if player.position.y < 40.0:
		player.position.y = 40.0
		velocity_y = 0.0
	elif player.position.y > 1860.0:
		_trigger_game_over()

	# Mover obstáculos
	for pipe in pipes_container.get_children():
		if pipe is Node2D:
			pipe.position.x -= PIPE_SPEED * delta

			# Comprobar si cruza la posición de Monky para sumar punto
			if not pipe.get_meta("passed", false) and pipe.position.x < player.position.x:
				pipe.set_meta("passed", true)
				score += 1
				_spawn_floating_text("+1", player.position + Vector2(0, -60), Color(0.3, 1, 0.4))
				_update_hud()

			if pipe.position.x < -200.0:
				pipe.queue_free()

func _on_spawn_timer_timeout() -> void:
	if is_game_over:
		return
	_spawn_pipe_obstacle()

func _spawn_pipe_obstacle() -> void:
	var pipe_pair = Node2D.new()
	var center_y = randf_range(500.0, 1420.0)
	pipe_pair.position = Vector2(1180.0, 0.0)
	pipe_pair.set_meta("passed", false)

	# Tubo Superior
	var top_area = Area2D.new()
	top_area.set_meta("obstacle", true)
	var top_col = CollisionShape2D.new()
	var top_shape = RectangleShape2D.new()
	var top_height = center_y - (GAP_SIZE / 2.0)
	top_shape.size = Vector2(110.0, top_height)
	top_col.shape = top_shape
	top_col.position = Vector2(0, top_height / 2.0)
	top_area.add_child(top_col)

	var top_rect = ColorRect.new()
	top_rect.color = Color(0.2, 0.65, 0.25, 0.95)
	top_rect.size = Vector2(110.0, top_height)
	top_rect.position = Vector2(-55.0, 0.0)
	top_area.add_child(top_rect)
	pipe_pair.add_child(top_area)

	# Tubo Inferior
	var bot_area = Area2D.new()
	bot_area.set_meta("obstacle", true)
	var bot_col = CollisionShape2D.new()
	var bot_shape = RectangleShape2D.new()
	var bot_y_start = center_y + (GAP_SIZE / 2.0)
	var bot_height = 1920.0 - bot_y_start
	bot_shape.size = Vector2(110.0, bot_height)
	bot_col.shape = bot_shape
	bot_col.position = Vector2(0, bot_y_start + (bot_height / 2.0))
	bot_area.add_child(bot_col)

	var bot_rect = ColorRect.new()
	bot_rect.color = Color(0.2, 0.65, 0.25, 0.95)
	bot_rect.size = Vector2(110.0, bot_height)
	bot_rect.position = Vector2(-55.0, bot_y_start)
	bot_area.add_child(bot_rect)
	pipe_pair.add_child(bot_area)

	# Moneda en el hueco
	var coin_area = Area2D.new()
	coin_area.position = Vector2(0, center_y)
	coin_area.set_meta("coin", true)
	var coin_col = CollisionShape2D.new()
	var coin_shape = CircleShape2D.new()
	coin_shape.radius = 35.0
	coin_col.shape = coin_shape
	coin_area.add_child(coin_col)

	var coin_sprite = Sprite2D.new()
	coin_sprite.texture = load("res://imagenes/opt/hud/moneda.png") as Texture2D
	if coin_sprite.texture:
		var size = coin_sprite.texture.get_size()
		coin_sprite.scale = Vector2.ONE * (70.0 / maxf(size.x, size.y))
	coin_area.add_child(coin_sprite)
	pipe_pair.add_child(coin_area)

	pipes_container.add_child(pipe_pair)

func _on_player_area_entered(area: Area2D) -> void:
	if is_game_over:
		return

	if area.has_meta("coin"):
		coins_earned += 1
		if AudioManager:
			AudioManager.play_coins()
		_spawn_floating_text("+1 moneda", area.global_position, Color(1, 0.85, 0.2))
		area.queue_free()
		_update_hud()
	elif area.has_meta("obstacle"):
		_trigger_game_over()

func _trigger_game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	spawn_timer.stop()
	if AudioManager:
		AudioManager.play_game_over()

	# Recompensas al GameManager
	if gm:
		var extra_coins = int(float(score) / 5.0)
		gm.add_coins(coins_earned + extra_coins)
		gm.play_with_monky(100.0)
		gm.hygiene = maxf(0.0, gm.hygiene - 8.0) # Se ensucia jugando
		gm.add_xp(minf(score * 0.8, 20.0))

	final_score_label.text = str(score) + " pts"
	final_coins_label.text = "+" + str(coins_earned + int(float(score) / 5.0)) + " monedas"
	high_score_label.text = str(score) + " pts"


	game_over_modal.visible = true
	game_over_modal.scale = Vector2(0.5, 0.5)
	game_over_modal.pivot_offset = game_over_modal.size / 2.0
	var tween = create_tween()
	tween.tween_property(game_over_modal, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _spawn_floating_text(text: String, pos: Vector2, color: Color) -> void:
	var label = Label.new()
	label.text = text
	label.modulate = color
	label.add_theme_font_size_override("font_size", 42)
	label.global_position = pos
	label.z_index = 50
	add_child(label)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 70, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.6).set_ease(Tween.EASE_IN)
	tween.finished.connect(label.queue_free)

func _update_hud() -> void:
	score_label.text = "PUNTOS " + str(score)
	coins_label.text = "MONEDAS +" + str(coins_earned)

func _on_btn_home_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/minigames/minigames_menu.tscn")
