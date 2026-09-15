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

const GRAVITY: float = 1750.0
const JUMP_POWER: float = -1180.0
const SUPER_JUMP_POWER: float = -1680.0
const SCREEN_WIDTH: float = 1080.0


var velocity: Vector2 = Vector2.ZERO
var max_altitude: float = 0.0
var score: int = 0
var coins_earned: int = 0
var is_game_over: bool = false
var highest_platform_y: float = 1400.0
var last_milestone: int = 0
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
	last_milestone = 0
	max_altitude = 1400.0
	highest_platform_y = 1400.0
	velocity = Vector2(0, JUMP_POWER)
	player.position = Vector2(540, 1400)
	camera.position = Vector2(540, 960)
	background.position = Vector2(540, 960)
	game_over_modal.visible = false

	# Limpiar plataformas
	for child in platforms_container.get_children():
		child.queue_free()

	# Plataforma inicial segura y ancha
	_create_platform(Vector2(540, 1500), "normal", 240.0)

	# Generar lote inicial de plataformas
	for i in range(12):
		_spawn_next_platform()

	_update_hud()

func _get_difficulty_factor() -> float:
	return clampf(float(score) / 180.0, 0.0, 1.0)

func _process(delta: float) -> void:
	if is_game_over:
		return

	var prev_x = player.position.x
	var accel = Input.get_accelerometer()
	var key_dir = Input.get_axis("ui_left", "ui_right")

	# Control horizontal con soporte de Inclinación de Celular (Acelerómetro), Teclado y Táctil/Mouse
	if absf(accel.x) > 0.3:
		# 📱 Modo Móvil: Mover inclinando el teléfono a los lados
		var tilt_amount = -clampf(accel.x / 3.5, -1.0, 1.0)
		velocity.x = lerpf(velocity.x, tilt_amount * 800.0, 14.0 * delta)
		player.position.x += velocity.x * delta
	elif absf(key_dir) > 0.05:
		# ⌨️ Modo Teclado: Flechas o A/D
		velocity.x = lerpf(velocity.x, key_dir * 780.0, 18.0 * delta)
		player.position.x += velocity.x * delta
	else:
		# 🖱️ Modo Ratón / Toque táctil en pantalla: Seguir posición horizontal
		var target_x = get_global_mouse_position().x
		player.position.x = lerpf(player.position.x, target_x, 14.0 * delta)

	# Orientación visual de Monky según dirección de movimiento
	if player.position.x > prev_x + 1.0:
		monky_sprite.flip_h = false
	elif player.position.x < prev_x - 1.0:
		monky_sprite.flip_h = true
	
	# Wrap-around horizontal clásico (Doodle Jump / Pou)
	# Si sale por el borde derecho, entra por el izquierdo y viceversa
	if player.position.x < -40.0:
		player.position.x = SCREEN_WIDTH + 30.0
	elif player.position.x > SCREEN_WIDTH + 40.0:
		player.position.x = -30.0

	# Aplicar gravedad y salto
	velocity.y += GRAVITY * delta
	player.position.y += velocity.y * delta

	# Cámara sigue la altura máxima de Monky
	if player.position.y < camera.position.y:
		camera.position.y = player.position.y
	
	# Sincronizar siempre el fondo con la posición actual de la cámara
	background.position = camera.position

	# Calcular puntuación según altitud alcanzada
	var current_height = 1400.0 - player.position.y
	if current_height > score * 10.0:
		score = int(current_height / 10.0)
		_update_hud()
		_check_altitude_milestones()

	# Generar más plataformas hacia arriba
	while highest_platform_y > (camera.position.y - 1200.0):
		_spawn_next_platform()

	# Velocidad dinámica para plataformas móviles según dificultad
	var move_speed: float = lerpf(180.0, 390.0, _get_difficulty_factor())

	# Actualizar plataformas
	for plat in platforms_container.get_children():
		if plat is Area2D:
			var p_type = plat.get_meta("type", "")
			if p_type == "moving":
				var dir = plat.get_meta("dir", 1.0)
				plat.position.x += dir * move_speed * delta
				var half_w = plat.get_meta("width", 180.0) / 2.0
				if plat.position.x < (50.0 + half_w):
					plat.position.x = 50.0 + half_w
					plat.set_meta("dir", 1.0)
				elif plat.position.x > (SCREEN_WIDTH - 50.0 - half_w):
					plat.position.x = SCREEN_WIDTH - 50.0 - half_w
					plat.set_meta("dir", -1.0)

			# Eliminar plataformas muy por debajo de la cámara
			if plat.position.y > (camera.position.y + 1100.0):
				plat.queue_free()

	# Comprobar caída al vacío
	if player.position.y > (camera.position.y + 1050.0):
		_trigger_game_over()

func _check_altitude_milestones() -> void:
	var tier = int(score / 50)
	if tier > last_milestone:
		last_milestone = tier
		var meters = tier * 50
		var title = "☁️ %dm: ¡Entre las Nubes!" % meters
		if meters == 100:
			title = "🚀 100m: ¡Estratosfera!"
		elif meters == 150:
			title = "🛰️ 150m: ¡Órbita Terrestre!"
		elif meters >= 200:
			title = "🌌 %dm: ¡Espacio Profundo!" % meters
		_spawn_floating_text(title, player.position + Vector2(0, -90), Color(1.0, 0.88, 0.25), 44)

func _spawn_next_platform() -> void:
	var diff = _get_difficulty_factor()
	
	# Separación vertical aumenta con la altura
	var min_gap = lerpf(125.0, 160.0, diff)
	var max_gap = lerpf(155.0, 215.0, diff)
	highest_platform_y -= randf_range(min_gap, max_gap)

	# Ancho de plataforma se reduce con la altura
	var p_width = lerpf(205.0, 120.0, diff)
	
	var min_x = 50.0 + (p_width / 2.0)
	var max_x = SCREEN_WIDTH - 50.0 - (p_width / 2.0)
	var spawn_x = randf_range(min_x, max_x)
	
	var p_type = "normal"
	var roll = randf()

	# Distribución de tipos según la altitud
	if score < 30:
		if roll < 0.15:
			p_type = "moving"
		elif roll < 0.30:
			p_type = "spring"
		elif roll < 0.45:
			p_type = "coin"
	elif score < 80:
		if roll < 0.28:
			p_type = "moving"
		elif roll < 0.45:
			p_type = "fragile"
		elif roll < 0.58:
			p_type = "spring"
		elif roll < 0.70:
			p_type = "coin"
	elif score < 150:
		if roll < 0.35:
			p_type = "moving"
		elif roll < 0.56:
			p_type = "fragile"
		elif roll < 0.70:
			p_type = "vanishing"
		elif roll < 0.78:
			p_type = "spring"
		elif roll < 0.85:
			p_type = "coin"
	else:
		# 150m+ Modo Extremo
		if roll < 0.42:
			p_type = "moving"
		elif roll < 0.68:
			p_type = "fragile"
		elif roll < 0.84:
			p_type = "vanishing"
		elif roll < 0.90:
			p_type = "spring"
		elif roll < 0.95:
			p_type = "coin"

	_create_platform(Vector2(spawn_x, highest_platform_y), p_type, p_width)

func _create_platform(pos: Vector2, p_type: String, p_width: float = 180.0) -> void:
	var plat = Area2D.new()
	plat.position = pos
	plat.set_meta("platform", true)
	plat.set_meta("type", p_type)
	plat.set_meta("width", p_width)
	plat.set_meta("dir", 1.0 if randf() > 0.5 else -1.0)

	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(p_width, 32.0)
	col.shape = shape
	plat.add_child(col)

	var rect = ColorRect.new()
	rect.size = Vector2(p_width, 32.0)
	rect.position = Vector2(-p_width / 2.0, -16.0)

	match p_type:
		"normal":
			rect.color = Color(0.2, 0.78, 0.35, 0.95)
		"moving":
			rect.color = Color(0.2, 0.65, 0.95, 0.95)
			var arrow_label = Label.new()
			arrow_label.text = "↔️"
			arrow_label.offset_left = -16
			arrow_label.offset_top = -42
			arrow_label.offset_right = 16
			arrow_label.offset_bottom = -10
			arrow_label.add_theme_font_size_override("font_size", 28)
			plat.add_child(arrow_label)
		"fragile":
			rect.color = Color(0.72, 0.45, 0.22, 0.95)
			var crack_label = Label.new()
			crack_label.text = "🪵"
			crack_label.offset_left = -16
			crack_label.offset_top = -42
			crack_label.offset_right = 16
			crack_label.offset_bottom = -10
			crack_label.add_theme_font_size_override("font_size", 28)
			plat.add_child(crack_label)
		"vanishing":
			rect.color = Color(0.78, 0.45, 0.95, 0.8)
			var ghost_label = Label.new()
			ghost_label.text = "👻"
			ghost_label.offset_left = -16
			ghost_label.offset_top = -42
			ghost_label.offset_right = 16
			ghost_label.offset_bottom = -10
			ghost_label.add_theme_font_size_override("font_size", 28)
			plat.add_child(ghost_label)
		"spring":
			rect.color = Color(0.95, 0.75, 0.15, 0.95)
			var spr_label = Label.new()
			spr_label.text = "🌀"
			spr_label.offset_left = -20
			spr_label.offset_top = -45
			spr_label.offset_right = 20
			spr_label.offset_bottom = -5
			spr_label.add_theme_font_size_override("font_size", 34)
			plat.add_child(spr_label)
		"coin":
			rect.color = Color(0.2, 0.78, 0.35, 0.95)
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
		if area.has_meta("broken"):
			return

		var p_type: String = area.get_meta("type", "normal")
		if p_type == "spring":
			velocity.y = SUPER_JUMP_POWER
			_spawn_floating_text("🌀 ¡SUPER SALTO!", player.position + Vector2(0, -60), Color(1, 0.9, 0.2), 40)
		elif p_type == "coin":
			velocity.y = JUMP_POWER
			coins_earned += 1
			_spawn_floating_text("+1 🪙", player.position + Vector2(0, -60), Color(1, 0.85, 0.2), 38)
			area.set_meta("type", "normal") # Consume la moneda
			_update_hud()
		elif p_type == "fragile":
			area.set_meta("broken", true)
			velocity.y = JUMP_POWER
			_spawn_floating_text("💥 ¡CRACK!", area.position + Vector2(0, -50), Color(1, 0.45, 0.3), 36)
			# Desmoronamiento de la plataforma
			var tween_break = create_tween()
			tween_break.set_parallel(true)
			tween_break.tween_property(area, "position:y", area.position.y + 120.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			tween_break.tween_property(area, "modulate:a", 0.0, 0.35)
			tween_break.tween_property(area, "scale", Vector2(0.6, 0.6), 0.35)
			tween_break.finished.connect(area.queue_free)
		elif p_type == "vanishing":
			area.set_meta("broken", true)
			velocity.y = JUMP_POWER
			_spawn_floating_text("👻 ¡Desvanecido!", area.position + Vector2(0, -50), Color(0.85, 0.6, 1.0), 34)
			# Desvanecimiento rápido
			var tween_vanish = create_tween()
			tween_vanish.tween_property(area, "modulate:a", 0.0, 0.25)
			tween_vanish.finished.connect(area.queue_free)
		else:
			velocity.y = JUMP_POWER

		# Rebote elástico visual en Monky
		var tween = create_tween()
		tween.tween_property(player, "scale", Vector2(1.25, 0.8), 0.08)
		tween.tween_property(player, "scale", Vector2.ONE, 0.12)

func _trigger_game_over() -> void:
	if is_game_over:
		return
	is_game_over = true

	# Recompensas al GameManager
	if gm:
		var extra_coins = int(float(score) / 30.0)
		gm.add_coins(coins_earned + extra_coins)
		gm.play_with_monky(100.0)
		gm.hygiene = maxf(0.0, gm.hygiene - 8.0) # Se ensucia jugando
		gm.add_xp(minf(score * 0.15, 20.0))

	final_score_label.text = str(score) + " m"
	final_coins_label.text = "+" + str(coins_earned + int(float(score) / 30.0)) + " 🪙"
	high_score_label.text = str(score) + " m"

	game_over_modal.visible = true
	game_over_modal.scale = Vector2(0.5, 0.5)
	game_over_modal.pivot_offset = game_over_modal.size / 2.0
	var tween = create_tween()
	tween.tween_property(game_over_modal, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _spawn_floating_text(text: String, pos: Vector2, color: Color, font_size: int = 40) -> void:
	var label = Label.new()
	label.text = text
	label.modulate = color
	label.add_theme_font_size_override("font_size", font_size)
	label.global_position = pos
	label.z_index = 50
	add_child(label)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 80, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.7).set_ease(Tween.EASE_IN)
	tween.finished.connect(label.queue_free)

func _update_hud() -> void:
	score_label.text = "🦘 " + str(score) + "m"
	coins_label.text = "🪙 +" + str(coins_earned)

func _on_btn_home_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/minigames/minigames_menu.tscn")
