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
const PIPE_WIDTH: float = 110.0
const PIPE_POOL_SIZE: int = 5
const MAX_FLOATING_TEXTS: int = 4

# Estas rutas son OPCIONALES. Cuando lleguen los PNG se usan sin cambiar escenas.
const SKY_ART := "res://assets/flappy/sky_background.png"
const CLOUD_ART := "res://assets/flappy/cloud_overlay.png"
const PIPE_TOP_ART := "res://assets/flappy/vine_top.png"
const PIPE_BOTTOM_ART := "res://assets/flappy/vine_bottom.png"
const FLIGHT_FRAME_PATTERN := "res://assets/flappy/wonky_fly_%02d.png"
const TAP_ART := "res://assets/flappy/tap_hand.png"
const COIN_ART: Texture2D = preload("res://imagenes/opt/hud/moneda.png")

var velocity_y: float = 0.0
var score: int = 0
var coins_earned: int = 0
var is_game_started: bool = false
var is_game_over: bool = false
var gm: Node = null
var _run_token: String = ""
var _reward_saved: bool = false
var _free_pipes: Array[Node2D] = []
var _active_pipes: Array[Node2D] = []
var _floating_texts: Array[Label] = []
var _cloud_layer: Sprite2D = null
var _cloud_clock: float = 0.0

func _ready() -> void:
	gm = get_tree().root.get_node_or_null("GameManager")
	_setup_background()
	_setup_game_ui_icons()
	_setup_flight_frames()
	_build_pipe_pool()
	tap_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	player.collision_layer = 1
	player.collision_mask = 2
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
	tap_hint.text = "¡TOCA PARA VOLAR!"
	if ResourceLoader.exists(TAP_ART):
		var hand := TextureRect.new()
		hand.name = "TapHandArt"
		hand.texture = load(TAP_ART) as Texture2D
		hand.position = Vector2(252, -166)
		hand.size = Vector2(136, 136)
		hand.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		hand.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hand.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tap_hint.add_child(hand)

func _setup_background() -> void:
	# Un fondo ligero e ilustrado reemplaza al anterior al aparecer el archivo.
	if ResourceLoader.exists(SKY_ART):
		var sky := load(SKY_ART) as Texture2D
		if sky != null:
			background.texture = sky
	background.z_index = -20
	if background and background.texture:
		var tex_size := background.texture.get_size()
		if tex_size.x > 0.0 and tex_size.y > 0.0:
			var scale_factor := maxf(1080.0 / tex_size.x, 1920.0 / tex_size.y)
			background.scale = Vector2.ONE * scale_factor
	if ResourceLoader.exists(CLOUD_ART):
		var cloud_texture := load(CLOUD_ART) as Texture2D
		if cloud_texture != null:
			_cloud_layer = Sprite2D.new()
			_cloud_layer.texture = cloud_texture
			_cloud_layer.z_index = -10
			_cloud_layer.position = Vector2(540, 620)
			var tex_size := cloud_texture.get_size()
			if tex_size.x > 0.0 and tex_size.y > 0.0:
				_cloud_layer.scale = Vector2(1080.0 / tex_size.x, 540.0 / tex_size.y)
			add_child(_cloud_layer)

func _setup_flight_frames() -> void:
	# La hoja original de Wonky permanece como fallback hasta recibir SEIS
	# PNG legibles de 384x384. Nunca importamos un personaje incompleto.
	var images: Array[Texture2D] = []
	for index in range(1, 7):
		var path := FLIGHT_FRAME_PATTERN % index
		if not ResourceLoader.exists(path):
			return
		var image := load(path) as Texture2D
		if image == null or image.get_size() != Vector2(384, 384):
			push_warning("El cuadro de vuelo debe ser PNG 384x384: " + path)
			return
		images.append(image)
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	frames.add_animation("fly")
	frames.set_animation_speed("fly", 10.0)
	frames.set_animation_loop("fly", true)
	for image in images:
		frames.add_frame("fly", image)
	monky_sprite.sprite_frames = frames
	monky_sprite.scale = Vector2.ONE * 0.35
	monky_sprite.play("fly")

func _setup_signals() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	btn_exit.pressed.connect(_on_btn_home_pressed)
	btn_restart.pressed.connect(reset_game)
	btn_home.pressed.connect(_on_btn_home_pressed)
	player.area_entered.connect(_on_player_area_entered)

func reset_game() -> void:
	if not _run_token.is_empty() and not _reward_saved and not _settle_reward():
		return
	_run_token = gm.begin_run("flappy") if gm else ""
	_reward_saved = false
	is_game_started = false
	is_game_over = false
	velocity_y = 0.0
	score = 0
	coins_earned = 0
	player.position = Vector2(280, 960)
	UIEffects.cancel(player, "flight")
	player.rotation = 0.0
	background.position = Vector2(540, 960)
	tap_hint.visible = true
	game_over_modal.visible = false
	spawn_timer.stop()

	for pair in _active_pipes.duplicate():
		_recycle_pipe(pair)
	for label in _floating_texts:
		if is_instance_valid(label):
			label.queue_free()
	_floating_texts.clear()
	_cloud_clock = 0.0
	_update_hud()

## _input se recibe ANTES de los controles del HUD: la etiqueta de ayuda
## ya no se come los toques. Se ignoran copias emuladas para no saltar doble.
func _input(event: InputEvent) -> void:
	if is_game_over:
		return
	var flap: bool = false
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		flap = touch.pressed and touch.device != InputEvent.DEVICE_ID_EMULATION
		if flap and _is_exit_hit(touch.position):
			return
	elif event is InputEventMouseButton:
		var click := event as InputEventMouseButton
		flap = click.pressed and click.button_index == MOUSE_BUTTON_LEFT and click.device != InputEvent.DEVICE_ID_EMULATION
		if flap and _is_exit_hit(click.position):
			return
	elif event is InputEventKey:
		var key := event as InputEventKey
		flap = key.pressed and not key.echo and (key.is_action_pressed("ui_accept") or key.is_action_pressed("ui_up"))
	if flap:
		_on_jump()
		get_viewport().set_input_as_handled()

func _is_exit_hit(point: Vector2) -> bool:
	return btn_exit != null and btn_exit.visible and btn_exit.get_global_rect().has_point(point)

func _on_jump() -> void:
	if not is_game_started:
		is_game_started = true
		tap_hint.visible = false
		spawn_timer.start()

	if AudioManager:
		AudioManager.play_jump()
	velocity_y = JUMP_VELOCITY
	var tween = UIEffects.tween_for(player, "flight")
	tween.tween_property(player, "rotation", deg_to_rad(-22.0), 0.1)

func _physics_process(delta: float) -> void:
	if not is_game_started or is_game_over:
		return
	delta = minf(delta, 0.05)
	if _cloud_layer != null and not (gm and gm.reduced_effects):
		_cloud_clock += delta
		_cloud_layer.position.x = 540.0 + sin(_cloud_clock * 0.32) * 38.0

	# Aplicar gravedad
	velocity_y += GRAVITY * delta
	player.position.y += velocity_y * delta

	# Rotación hacia abajo al caer
	if velocity_y > 100.0:
		var target_rot = clampf(deg_to_rad((velocity_y - 100.0) * 0.08), -0.4, 1.2)
		player.rotation = lerpf(player.rotation, target_rot, minf(1.0, 8.0 * delta))

	# Límites superior e inferior
	if player.position.y < 40.0:
		player.position.y = 40.0
		velocity_y = 0.0
	elif player.position.y > 1860.0:
		_trigger_game_over()
		return

	# Mover obstáculos
	for index in range(_active_pipes.size() - 1, -1, -1):
		var pipe := _active_pipes[index]
		pipe.position.x -= PIPE_SPEED * delta
		if not pipe.get_meta("passed", false) and pipe.position.x < player.position.x:
			pipe.set_meta("passed", true)
			score += 1
			_spawn_floating_text("+1", player.position + Vector2(0, -60), Color(0.3, 1, 0.4))
			_update_hud()
		if pipe.position.x < -200.0:
			_recycle_pipe(pipe)

func _on_spawn_timer_timeout() -> void:
	if is_game_over:
		return
	_spawn_pipe_obstacle()

## Cinco parejas preparadas al entrar a la escena: sin crear nodos en cada
## obstáculo, sin bloquear el toque y sin asignar texturas durante el vuelo.
func _build_pipe_pool() -> void:
	for index in range(PIPE_POOL_SIZE):
		var pair := _create_pipe_pair()
		pair.name = "ObstaclePair%d" % index
		pipes_container.add_child(pair)
		pair.hide()
		_free_pipes.append(pair)

func _create_pipe_pair() -> Node2D:
	var pair := Node2D.new()
	for side in ["Top", "Bottom"]:
		var area := Area2D.new()
		area.name = side
		area.collision_layer = 2
		area.collision_mask = 0
		area.monitoring = false
		area.set_meta("obstacle", true)
		var collision := CollisionShape2D.new()
		collision.name = "Collision"
		var shape := RectangleShape2D.new()
		shape.size = Vector2(PIPE_WIDTH, 800)
		collision.shape = shape
		collision.disabled = true
		area.add_child(collision)
		var visual := _make_obstacle_visual(side == "Top")
		area.add_child(visual)
		pair.add_child(area)

	var coin := Area2D.new()
	coin.name = "Coin"
	coin.collision_layer = 2
	coin.collision_mask = 0
	coin.monitoring = false
	coin.set_meta("coin", true)
	var collision := CollisionShape2D.new()
	collision.name = "Collision"
	var coin_shape := CircleShape2D.new()
	coin_shape.radius = 35.0
	collision.shape = coin_shape
	collision.disabled = true
	coin.add_child(collision)
	var sprite := Sprite2D.new()
	sprite.texture = COIN_ART
	if sprite.texture:
		var tex_size := sprite.texture.get_size()
		sprite.scale = Vector2.ONE * (70.0 / maxf(tex_size.x, tex_size.y))
	coin.add_child(sprite)
	pair.add_child(coin)
	return pair

func _make_obstacle_visual(top: bool) -> Control:
	var art_path := PIPE_TOP_ART if top else PIPE_BOTTOM_ART
	var visual: Control
	if ResourceLoader.exists(art_path):
		var tex := load(art_path) as Texture2D
		if tex != null:
			var nine := NinePatchRect.new()
			nine.texture = tex
			# Capuchón en la boca del hueco; cuerpo estirable verticalmente.
			nine.patch_margin_bottom = 125 if top else 0
			nine.patch_margin_top = 0 if top else 125
			visual = nine
	if visual == null:
		var fallback := ColorRect.new()
		fallback.color = Color(0.2, 0.65, 0.25, 0.95)
		visual = fallback
	visual.name = "Visual"
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return visual

func _resize_pipe_area(area: Area2D, start_y: float, height: float) -> void:
	var collision := area.get_node("Collision") as CollisionShape2D
	var shape := collision.shape as RectangleShape2D
	shape.size = Vector2(PIPE_WIDTH, height)
	collision.position = Vector2(0, start_y + height * 0.5)
	collision.set_deferred("disabled", false)
	var visual := area.get_node("Visual") as Control
	visual.position = Vector2(-PIPE_WIDTH * 0.5, start_y)
	visual.size = Vector2(PIPE_WIDTH, height)

func _spawn_pipe_obstacle() -> void:
	if _free_pipes.is_empty() or is_game_over:
		return
	var pair: Node2D = _free_pipes.pop_back()
	var center_y := randf_range(500.0, 1420.0)
	pair.position = Vector2(1180, 0)
	pair.set_meta("passed", false)
	_resize_pipe_area(pair.get_node("Top") as Area2D, 0.0, center_y - GAP_SIZE * 0.5)
	var lower_start := center_y + GAP_SIZE * 0.5
	_resize_pipe_area(pair.get_node("Bottom") as Area2D, lower_start, 1920.0 - lower_start)
	var coin := pair.get_node("Coin") as Area2D
	coin.position = Vector2(0, center_y)
	coin.set_meta("consumed", false)
	coin.get_node("Collision").set_deferred("disabled", false)
	coin.show()
	pair.show()
	_active_pipes.append(pair)

func _recycle_pipe(pair: Node2D) -> void:
	if not pair in _active_pipes:
		return
	_active_pipes.erase(pair)
	pair.hide()
	for side in ["Top", "Bottom", "Coin"]:
		var col := pair.get_node("%s/Collision" % side) as CollisionShape2D
		col.set_deferred("disabled", true)
	_free_pipes.append(pair)

func _on_player_area_entered(area: Area2D) -> void:
	if is_game_over or area.get_meta("consumed", false):
		return

	if area.has_meta("coin"):
		area.set_meta("consumed", true)
		coins_earned += 1
		if AudioManager:
			AudioManager.play_coins()
		_spawn_floating_text("+1 moneda", area.global_position, Color(1, 0.85, 0.2))
		area.get_node("Collision").set_deferred("disabled", true)
		area.hide()
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
	_settle_reward()

	final_score_label.text = str(score) + " pts"
	final_coins_label.text = "+" + str(coins_earned + int(float(score) / 5.0)) + " monedas"
	high_score_label.text = str(gm.get_record("flappy") if gm else score) + " pts"


	if not _reward_saved:
		final_coins_label.text = "Guardado pendiente · reintenta"

	game_over_modal.visible = true
	game_over_modal.scale = Vector2(0.5, 0.5)
	game_over_modal.pivot_offset = game_over_modal.size / 2.0
	var tween = create_tween()
	tween.tween_property(game_over_modal, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _spawn_floating_text(text: String, pos: Vector2, color: Color) -> void:
	if gm and gm.reduced_effects:
		return
	if _floating_texts.size() >= MAX_FLOATING_TEXTS:
		var oldest: Label = _floating_texts.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()
	var label := Label.new()
	_floating_texts.append(label)
	label.text = text
	label.modulate = color
	label.add_theme_font_size_override("font_size", 42)
	label.global_position = pos
	label.z_index = 50
	add_child(label)

	var tween = label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 70, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.6).set_ease(Tween.EASE_IN)
	tween.finished.connect(func():
		_floating_texts.erase(label)
		if is_instance_valid(label):
			label.queue_free()
	)

func _update_hud() -> void:
	UIEffects.set_text(score_label, str(score))
	UIEffects.set_text(coins_label, "+" + str(coins_earned))

func _on_btn_home_pressed() -> void:
	if not _settle_reward():
		return
	get_tree().paused = false
	SceneRouter.go.call_deferred("res://scenes/minigames/minigames_menu.tscn")

func _settle_reward() -> bool:
	if _reward_saved:
		return true
	# Leaving an untouched game does not farm care/XP.
	if score == 0 and coins_earned == 0 and not is_game_over:
		_reward_saved = true
		return true
	_reward_saved = gm != null and gm.settle_run(_run_token, score, coins_earned)
	if not _reward_saved:
		final_coins_label.text = "Guardado pendiente · reintenta"
	return _reward_saved
