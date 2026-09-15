extends Node2D

## Controlador del Minijuego "Monky Jump"
## Salto infinito vertical en plataformas con monedas, resortes y generación procedural.

@onready var background: Sprite2D = $Background
@onready var player: Area2D = $Player
@onready var monky_sprite: AnimatedSprite2D = $Player/MonkySprite
@onready var platforms_container: Node2D = $PlatformsContainer

@onready var camera: Camera2D = $Camera2D

# UI
@onready var score_label: Label = $HUD/TopBar/ScoreBox/ScoreLabel
@onready var coins_label: Label = $HUD/TopBar/CoinsBox/CoinsLabel
@onready var btn_exit: Button = $HUD/TopBar/BtnExit

# Game Over Modal
@onready var game_over_modal: PanelContainer = $HUD/GameOverModal
@onready var final_score_label: Label = $HUD/GameOverModal/Margin/VBox/StatsGrid/HBoxScore/ScoreValue
@onready var final_coins_label: Label = $HUD/GameOverModal/Margin/VBox/StatsGrid/HBoxCoins/CoinsValue
@onready var high_score_label: Label = $HUD/GameOverModal/Margin/VBox/StatsGrid/HBoxHigh/HighScoreValue
@onready var btn_restart: Button = $HUD/GameOverModal/Margin/VBox/Buttons/BtnRestart
@onready var btn_home: Button = $HUD/GameOverModal/Margin/VBox/Buttons/BtnHome

const GRAVITY: float = 1800.0
const JUMP_POWER: float = -950.0
const SUPER_JUMP_POWER: float = -1450.0
const SCREEN_WIDTH: float = 1080.0

var velocity: Vector2 = Vector2.ZERO
var max_altitude: float = 0.0
var score: int = 0
var coins_earned: int = 0
var is_game_over: bool = false
var highest_platform_y: float = 1400.0
var gm: Node = null

func _ready() -> void:
	gm = get_tree().root.get_node_or_null("GameManager")
	_setup_background()
	_setup_signals()
	start_game()

func _setup_background() -> void:
	if background and background.texture:
		var tex_size = background.texture.get_size()
		if tex_size.x > 0 and tex_size.y > 0:
			var scale_factor = maxf(1080.0 / tex_size.x, 1920.0 / tex_size.y)
			background.scale = Vector2(scale_factor, scale_factor)

func _setup_signals() -> void:
	btn_exit.pressed.connect(_on_btn_home_pressed)
	btn_restart.pressed.connect(start_game)
	btn_home.pressed.connect(_on_btn_home_pressed)
	player.area_entered.connect(_on_player_area_entered)

func start_game() -> void:
	is_game_over = false
	score = 0
	coins_earned = 0
	max_altitude = 1400.0
	highest_platform_y = 1400.0
	velocity = Vector2(0, JUMP_POWER)
	player.position = Vector2(540, 1400)
	camera.position = Vector2(540, 960)
	game_over_modal.visible = false

	# Limpiar plataformas
	for child in platforms_container.get_children():
		child.queue_free()

	# Plataforma inicial segura
	_create_platform(Vector2(540, 1500), "normal")

	# Generar lote inicial de plataformas
	for i in range(12):
		_spawn_next_platform()

	_update_hud()

func _process(delta: float) -> void:
	if is_game_over:
		return

	# Control horizontal suave (seguir puntero / toque)
	var target_x = get_global_mouse_position().x
	var prev_x = player.position.x
	player.position.x = lerpf(player.position.x, target_x, 18.0 * delta)
	
	# Wrap-around horizontal (si sale por un lado, entra por el otro)
	if player.position.x < -30:
		player.position.x = SCREEN_WIDTH + 20
	elif player.position.x > SCREEN_WIDTH + 30:
		player.position.x = -20

	# Aplicar gravedad
	velocity.y += GRAVITY * delta
	player.position.y += velocity.y * delta

	# Cámara sigue la altura máxima de Monky
	if player.position.y < camera.position.y:
		camera.position.y = player.position.y
		background.position.y = camera.position.y

	# Calcular puntuación según altitud alcanzada
	var current_height = 1400.0 - player.position.y
	if current_height > score:
		score = int(current_height / 10.0)
		_update_hud()

	# Generar más plataformas hacia arriba
	while highest_platform_y > (camera.position.y - 1200.0):
		_spawn_next_platform()

	# Actualizar plataformas móviles
	for plat in platforms_container.get_children():
		if plat is Node2D:
			if plat.get_meta("type", "") == "moving":
				var dir = plat.get_meta("dir", 1.0)
				plat.position.x += dir * 220.0 * delta
				if plat.position.x < 120.0:
					plat.set_meta("dir", 1.0)
				elif plat.position.x > 960.0:
					plat.set_meta("dir", -1.0)

			# Eliminar plataformas muy por debajo de la cámara
			if plat.position.y > (camera.position.y + 1100.0):
				plat.queue_free()

	# Comprobar caída al vacío
	if player.position.y > (camera.position.y + 1050.0):
		_trigger_game_over()

func _spawn_next_platform() -> void:
	highest_platform_y -= randf_range(160.0, 240.0)
	var spawn_x = randf_range(120.0, 960.0)
	var p_type = "normal"
	var roll = randf()
	if roll < 0.25:
		p_type = "moving"
	elif roll < 0.45:
		p_type = "spring"
	elif roll < 0.65:
		p_type = "coin"

	_create_platform(Vector2(spawn_x, highest_platform_y), p_type)

func _create_platform(pos: Vector2, p_type: String) -> void:
	var plat = Area2D.new()
	plat.position = pos
	plat.set_meta("platform", true)
	plat.set_meta("type", p_type)
	plat.set_meta("dir", 1.0 if randf() > 0.5 else -1.0)

	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(180.0, 32.0)
	col.shape = shape
	plat.add_child(col)

	var rect = ColorRect.new()
	rect.size = Vector2(180.0, 32.0)
	rect.position = Vector2(-90.0, -16.0)

	match p_type:
		"normal":
			rect.color = Color(0.2, 0.75, 0.3, 0.95)
		"moving":
			rect.color = Color(0.2, 0.6, 0.9, 0.95)
		"spring":
			rect.color = Color(0.9, 0.75, 0.2, 0.95)
			var spr_label = Label.new()
			spr_label.text = "🌀"
			spr_label.offset_left = -20
			spr_label.offset_top = -45
			spr_label.offset_right = 20
			spr_label.offset_bottom = -5
			spr_label.add_theme_font_size_override("font_size", 34)
			plat.add_child(spr_label)
		"coin":
			rect.color = Color(0.2, 0.75, 0.3, 0.95)
			var coin_label = Label.new()
			coin_label.text = "🪙"
			coin_label.offset_left = -20
			coin_label.offset_top = -50
			coin_label.offset_right = 20
			coin_label.offset_bottom = -10
			coin_label.add_theme_font_size_override("font_size", 36)
			plat.add_child(coin_label)

	plat.add_child(rect)
	platforms_container.add_child(plat)

func _on_player_area_entered(area: Area2D) -> void:
	if is_game_over:
		return

	# Solo rebotar si Monky está cayendo hacia abajo
	if velocity.y > 0 and area.has_meta("platform"):
		var p_type: String = area.get_meta("type", "normal")
		if p_type == "spring":
			velocity.y = SUPER_JUMP_POWER
			_spawn_floating_text("🌀 ¡SUPER SALTO!", player.position + Vector2(0, -60), Color(1, 0.9, 0.2))
		elif p_type == "coin":
			velocity.y = JUMP_POWER
			coins_earned += 1
			_spawn_floating_text("+1 🪙", player.position + Vector2(0, -60), Color(1, 0.85, 0.2))
			area.set_meta("type", "normal") # Consume la moneda
			_update_hud()
		else:
			velocity.y = JUMP_POWER

		# Rebote elástico visual
		var tween = create_tween()
		tween.tween_property(player, "scale", Vector2(1.25, 0.8), 0.08)
		tween.tween_property(player, "scale", Vector2.ONE, 0.12)

func _trigger_game_over() -> void:
	if is_game_over:
		return
	is_game_over = true

	# Recompensas al GameManager
	if gm:
		gm.add_coins(coins_earned + int(score / 15.0))
		gm.play_with_monky(100.0)
		gm.add_xp(score * 0.4)

	final_score_label.text = str(score) + " m"
	final_coins_label.text = "+" + str(coins_earned + int(score / 15.0)) + " 🪙"
	high_score_label.text = str(score) + " m"

	game_over_modal.visible = true
	game_over_modal.scale = Vector2(0.5, 0.5)
	game_over_modal.pivot_offset = game_over_modal.size / 2.0
	var tween = create_tween()
	tween.tween_property(game_over_modal, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _spawn_floating_text(text: String, pos: Vector2, color: Color) -> void:
	var label = Label.new()
	label.text = text
	label.modulate = color
	label.add_theme_font_size_override("font_size", 40)
	label.global_position = pos
	label.z_index = 50
	add_child(label)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 70, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.6).set_ease(Tween.EASE_IN)
	tween.finished.connect(label.queue_free)

func _update_hud() -> void:
	score_label.text = "🦘 " + str(score) + "m"
	coins_label.text = "🪙 +" + str(coins_earned)

func _on_btn_home_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/minigames/minigames_menu.tscn")
