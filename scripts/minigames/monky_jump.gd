extends Node2D

## Monky Jump — versión visual para móvil/Android.
## Interfaz basada en iconos: los niños pueden jugar sin depender de texto.
## Fondos consecutivos 01-22 + zona infinita (parche integrado).

@onready var background: Sprite2D = $Background
@onready var player: Area2D = $Player
@onready var monky_sprite: AnimatedSprite2D = $Player/MonkySprite
@onready var platforms_container: Node2D = $PlatformsContainer
@onready var camera: Camera2D = $Camera2D

# HUD superior: icono + número solamente.
@onready var score_label: Label = $HUD/TopBar/ScoreBox/ScoreContent/ScoreLabel
@onready var coins_label: Label = $HUD/TopBar/CoinsBox/CoinsContent/CoinsLabel
@onready var btn_exit: Button = $HUD/TopBar/BtnExit

# Resultado: iconos grandes + números, sin párrafos ni instrucciones.
@onready var game_over_shade: ColorRect = $HUD/GameOverShade
@onready var game_over_modal: PanelContainer = $HUD/GameOverModal
@onready var final_score_label: Label = $HUD/GameOverModal/Margin/VBox/StatsRow/ScoreCard/ScoreVBox/ScoreValue
@onready var final_coins_label: Label = $HUD/GameOverModal/Margin/VBox/StatsRow/CoinsCard/CoinsVBox/CoinsValue
@onready var high_score_label: Label = $HUD/GameOverModal/Margin/VBox/StatsRow/BestCard/BestVBox/BestValue
@onready var btn_restart: Button = $HUD/GameOverModal/Margin/VBox/Buttons/BtnRestart
@onready var btn_home: Button = $HUD/GameOverModal/Margin/VBox/Buttons/BtnHome

const GRAVITY: float = 1750.0
const JUMP_POWER: float = -1180.0
const SUPER_JUMP_POWER: float = -1680.0
const SCREEN_WIDTH: float = 1080.0
const SCREEN_HEIGHT: float = 1920.0

# Fondos del modo Jump. Nómbralos fondo_01.png ... fondo_22.png.
# Después de la última escena, el juego sigue infinito.
# Opcional: agrega fondo_infinito_01.png, fondo_infinito_02.png, etc.
const BACKGROUND_DIR: String = "res://imagenes/jump/fondos"
const STORY_BACKGROUND_COUNT: int = 22
const INFINITE_BACKGROUND_MAX: int = 20
const BACKGROUND_START_CENTER_Y: float = 960.0
const BACKGROUND_KEEP_BEHIND: int = 1
const BACKGROUND_KEEP_AHEAD: int = 2

# Texturas ya recortadas del material que el proyecto traía en /imagenes.
# Se precargan una sola vez para evitar load() durante el juego.
const TEX_PLATFORM_NORMAL: Texture2D = preload("res://assets/ui/jump/platform_normal.png")
const TEX_PLATFORM_MOVING: Texture2D = preload("res://assets/ui/jump/platform_moving.png")
const TEX_PLATFORM_FRAGILE: Texture2D = preload("res://assets/ui/jump/platform_fragile.png")
const TEX_SPRING: Texture2D = preload("res://assets/ui/jump/spring.png")
const TEX_GHOST: Texture2D = preload("res://assets/ui/jump/ghost.png")
const TEX_COIN: Texture2D = preload("res://assets/ui/jump/coin.png")
const TEX_ROCKET: Texture2D = preload("res://assets/ui/jump/rocket.png")
const TEX_TROPHY: Texture2D = preload("res://assets/ui/jump/trophy.png")
const TEX_ALERT: Texture2D = preload("res://assets/ui/jump/alert.png")

var velocity: Vector2 = Vector2.ZERO
var score: int = 0
var coins_earned: int = 0
var best_score: int = 0
var is_game_over: bool = false
var highest_platform_y: float = 1400.0
var last_milestone: int = 0
var gm: Node = null

# Sistema de escenarios verticales.
var background_layer: Node2D = null
var story_backgrounds: Array[String] = []
var infinite_backgrounds: Array[String] = []
var active_background_tiles: Dictionary = {}


func _ready() -> void:
	gm = get_tree().root.get_node_or_null("GameManager")
	_load_best_score()
	_setup_background_system()
	_setup_signals()
	start_game()


func _setup_background_system() -> void:
	_discover_backgrounds()

	# Si todavía no hay fondos en la carpeta nueva, conserva el fondo original.
	if story_backgrounds.is_empty():
		if background and background.texture:
			var tex_size: Vector2 = background.texture.get_size()
			if tex_size.x > 0.0 and tex_size.y > 0.0:
				background.scale = Vector2(
					SCREEN_WIDTH / tex_size.x,
					SCREEN_HEIGHT / tex_size.y
				)
		return

	# El Sprite2D Background de la escena queda como respaldo, pero ya no se usa.
	if background:
		background.visible = false

	background_layer = Node2D.new()
	background_layer.name = "DynamicBackgrounds"
	background_layer.z_index = -100
	add_child(background_layer)


func _discover_backgrounds() -> void:
	story_backgrounds.clear()
	infinite_backgrounds.clear()

	# Escenas principales consecutivas: fondo_01.png ... fondo_22.png.
	for i in range(1, STORY_BACKGROUND_COUNT + 1):
		var path: String = "%s/fondo_%02d.png" % [BACKGROUND_DIR, i]
		if ResourceLoader.exists(path):
			story_backgrounds.append(path)

	# Variantes opcionales para la zona infinita.
	for i in range(1, INFINITE_BACKGROUND_MAX + 1):
		var path: String = "%s/fondo_infinito_%02d.png" % [BACKGROUND_DIR, i]
		if ResourceLoader.exists(path):
			infinite_backgrounds.append(path)


func _background_path_for_tile(tile_index: int) -> String:
	if story_backgrounds.is_empty():
		return ""

	if tile_index < story_backgrounds.size():
		return story_backgrounds[maxi(tile_index, 0)]

	# Tras la última escena, entra el modo infinito. Si existen variantes
	# fondo_infinito_XX.png, las alterna. Si no, repite la última escena.
	if not infinite_backgrounds.is_empty():
		var infinite_index: int = (tile_index - story_backgrounds.size()) % infinite_backgrounds.size()
		return infinite_backgrounds[infinite_index]

	return story_backgrounds[story_backgrounds.size() - 1]


func _create_background_tile(tile_index: int) -> void:
	if background_layer == null or active_background_tiles.has(tile_index):
		return

	var path: String = _background_path_for_tile(tile_index)
	if path.is_empty():
		return

	var texture := ResourceLoader.load(path) as Texture2D
	if texture == null:
		return

	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = true
	sprite.position = Vector2(
		SCREEN_WIDTH * 0.5,
		BACKGROUND_START_CENTER_Y - float(tile_index) * SCREEN_HEIGHT
	)
	sprite.z_index = -100
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

	var tex_size: Vector2 = texture.get_size()
	if tex_size.x > 0.0 and tex_size.y > 0.0:
		# 4 px extra de alto evitan una línea visible entre dos fondos.
		sprite.scale = Vector2(
			SCREEN_WIDTH / tex_size.x,
			(SCREEN_HEIGHT + 4.0) / tex_size.y
		)

	# Si no hay variantes infinitas, alternar espejo horizontal hace menos
	# evidente la repetición del último fondo sin afectar el gameplay.
	if tile_index >= story_backgrounds.size() and infinite_backgrounds.is_empty():
		sprite.flip_h = ((tile_index - story_backgrounds.size()) % 2) == 1

	background_layer.add_child(sprite)
	active_background_tiles[tile_index] = sprite


func _update_background_tiles(force_refresh: bool = false) -> void:
	if background_layer == null or story_backgrounds.is_empty():
		return

	var current_index: int = maxi(0, int(floor(
		(BACKGROUND_START_CENTER_Y - camera.position.y) / SCREEN_HEIGHT + 0.5
	)))
	var min_index: int = maxi(0, current_index - BACKGROUND_KEEP_BEHIND)
	var max_index: int = current_index + BACKGROUND_KEEP_AHEAD

	if force_refresh:
		for node in active_background_tiles.values():
			if is_instance_valid(node):
				node.queue_free()
		active_background_tiles.clear()

	for i in range(min_index, max_index + 1):
		_create_background_tile(i)

	var to_remove: Array[int] = []
	for key in active_background_tiles.keys():
		var idx: int = int(key)
		if idx < min_index or idx > max_index:
			var node: Node = active_background_tiles[key]
			if is_instance_valid(node):
				node.queue_free()
			to_remove.append(idx)

	for idx in to_remove:
		active_background_tiles.erase(idx)


func _setup_signals() -> void:
	if not btn_exit.pressed.is_connected(_on_btn_home_pressed):
		btn_exit.pressed.connect(_on_btn_home_pressed)
	if not btn_restart.pressed.is_connected(start_game):
		btn_restart.pressed.connect(start_game)
	if not btn_home.pressed.is_connected(_on_btn_home_pressed):
		btn_home.pressed.connect(_on_btn_home_pressed)
	if not player.area_entered.is_connected(_on_player_area_entered):
		player.area_entered.connect(_on_player_area_entered)


func start_game() -> void:
	is_game_over = false
	score = 0
	coins_earned = 0
	last_milestone = 0
	highest_platform_y = 1400.0
	velocity = Vector2(0.0, JUMP_POWER)
	player.position = Vector2(540.0, 1400.0)
	player.scale = Vector2.ONE
	camera.position = Vector2(540.0, 960.0)
	if background_layer != null:
		_update_background_tiles(true)
	elif background:
		background.position = Vector2(540.0, 960.0)
	game_over_modal.visible = false
	game_over_shade.visible = false

	for child in platforms_container.get_children():
		child.queue_free()

	# Plataforma inicial grande: cómoda para niños y pantallas táctiles.
	_create_platform(Vector2(540.0, 1500.0), "normal", 340.0)

	for i in range(13):
		_spawn_next_platform()

	_update_hud()


func _get_difficulty_factor() -> float:
	# La dificultad aumenta más lentamente que antes.
	return clampf(float(score) / 240.0, 0.0, 1.0)


func _process(delta: float) -> void:
	if is_game_over:
		return

	var prev_x: float = player.position.x
	var accel: Vector3 = Input.get_accelerometer()
	var key_dir: float = Input.get_axis("ui_left", "ui_right")

	# Android: inclinación. PC: flechas. Táctil/mouse: seguimiento horizontal.
	if absf(accel.x) > 0.3:
		var tilt_amount: float = -clampf(accel.x / 3.5, -1.0, 1.0)
		velocity.x = lerpf(velocity.x, tilt_amount * 760.0, minf(1.0, 12.0 * delta))
		player.position.x += velocity.x * delta
	elif absf(key_dir) > 0.05:
		velocity.x = lerpf(velocity.x, key_dir * 740.0, minf(1.0, 16.0 * delta))
		player.position.x += velocity.x * delta
	else:
		var target_x: float = get_global_mouse_position().x
		player.position.x = lerpf(player.position.x, target_x, minf(1.0, 12.0 * delta))

	if player.position.x > prev_x + 1.0:
		monky_sprite.flip_h = false
	elif player.position.x < prev_x - 1.0:
		monky_sprite.flip_h = true

	if player.position.x < -50.0:
		player.position.x = SCREEN_WIDTH + 40.0
	elif player.position.x > SCREEN_WIDTH + 50.0:
		player.position.x = -40.0

	velocity.y += GRAVITY * delta
	player.position.y += velocity.y * delta

	if player.position.y < camera.position.y:
		camera.position.y = player.position.y

	if background_layer != null:
		_update_background_tiles()
	elif background:
		background.position = camera.position

	var current_height: float = 1400.0 - player.position.y
	if current_height > float(score) * 10.0:
		score = int(current_height / 10.0)
		_update_hud()
		_check_altitude_milestones()

	while highest_platform_y > camera.position.y - 1200.0:
		_spawn_next_platform()

	var move_speed: float = lerpf(145.0, 285.0, _get_difficulty_factor())

	for plat in platforms_container.get_children():
		if plat is Area2D:
			var p_type: String = str(plat.get_meta("type", ""))
			if p_type == "moving":
				var dir: float = float(plat.get_meta("dir", 1.0))
				plat.position.x += dir * move_speed * delta
				var half_w: float = float(plat.get_meta("width", 220.0)) / 2.0
				if plat.position.x < 38.0 + half_w:
					plat.position.x = 38.0 + half_w
					plat.set_meta("dir", 1.0)
				elif plat.position.x > SCREEN_WIDTH - 38.0 - half_w:
					plat.position.x = SCREEN_WIDTH - 38.0 - half_w
					plat.set_meta("dir", -1.0)

			if plat.position.y > camera.position.y + 1120.0:
				plat.queue_free()

	if player.position.y > camera.position.y + 1050.0:
		_trigger_game_over()


func _check_altitude_milestones() -> void:
	var tier: int = int(score / 50)
	if tier > last_milestone:
		last_milestone = tier
		# Nada de frases: un cohete/trofeo comunica el progreso visualmente.
		var tex: Texture2D = TEX_ROCKET if tier < 4 else TEX_TROPHY
		_spawn_floating_icon(tex, player.position + Vector2(0.0, -120.0), 92.0)


func _spawn_next_platform() -> void:
	var diff: float = _get_difficulty_factor()

	# Más amplias y más cercanas: mejores para móvil y para niños.
	var min_gap: float = lerpf(112.0, 142.0, diff)
	var max_gap: float = lerpf(145.0, 182.0, diff)
	highest_platform_y -= randf_range(min_gap, max_gap)

	var p_width: float = lerpf(270.0, 185.0, diff)
	var min_x: float = 34.0 + p_width / 2.0
	var max_x: float = SCREEN_WIDTH - 34.0 - p_width / 2.0
	var spawn_x: float = randf_range(min_x, max_x)

	var p_type: String = "normal"
	var roll: float = randf()

	if score < 35:
		if roll < 0.10:
			p_type = "moving"
		elif roll < 0.22:
			p_type = "spring"
		elif roll < 0.38:
			p_type = "coin"
	elif score < 90:
		if roll < 0.20:
			p_type = "moving"
		elif roll < 0.34:
			p_type = "fragile"
		elif roll < 0.47:
			p_type = "spring"
		elif roll < 0.62:
			p_type = "coin"
	elif score < 160:
		if roll < 0.26:
			p_type = "moving"
		elif roll < 0.43:
			p_type = "fragile"
		elif roll < 0.55:
			p_type = "vanishing"
		elif roll < 0.68:
			p_type = "spring"
		elif roll < 0.80:
			p_type = "coin"
	else:
		if roll < 0.31:
			p_type = "moving"
		elif roll < 0.52:
			p_type = "fragile"
		elif roll < 0.66:
			p_type = "vanishing"
		elif roll < 0.77:
			p_type = "spring"
		elif roll < 0.87:
			p_type = "coin"

	_create_platform(Vector2(spawn_x, highest_platform_y), p_type, p_width)


func _add_platform_sprite(
	plat: Area2D,
	texture: Texture2D,
	width: float,
	height: float,
	alpha: float = 1.0
) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.z_index = 1
	if texture:
		var size: Vector2 = texture.get_size()
		if size.x > 0.0 and size.y > 0.0:
			sprite.scale = Vector2(width / size.x, height / size.y)
	# Alinea la parte superior del dibujo con la superficie de colisión.
	sprite.position = Vector2(0.0, -18.0 + height / 2.0)
	sprite.modulate.a = alpha
	plat.add_child(sprite)
	return sprite


func _add_platform_badge(
	plat: Area2D,
	texture: Texture2D,
	size_px: float,
	y_pos: float
) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.z_index = 3
	if texture:
		var tex_size: Vector2 = texture.get_size()
		if tex_size.x > 0.0 and tex_size.y > 0.0:
			var factor: float = size_px / maxf(tex_size.x, tex_size.y)
			sprite.scale = Vector2.ONE * factor
	sprite.position = Vector2(0.0, y_pos)
	plat.add_child(sprite)


func _create_platform(pos: Vector2, p_type: String, p_width: float = 220.0) -> void:
	var plat := Area2D.new()
	plat.position = pos
	plat.set_meta("platform", true)
	plat.set_meta("type", p_type)
	plat.set_meta("width", p_width)
	plat.set_meta("dir", 1.0 if randf() > 0.5 else -1.0)

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(p_width * 0.90, 36.0)
	col.shape = shape
	plat.add_child(col)

	match p_type:
		"moving":
			_add_platform_sprite(plat, TEX_PLATFORM_MOVING, p_width, 84.0)
		"fragile":
			_add_platform_sprite(plat, TEX_PLATFORM_FRAGILE, p_width, 126.0)
		"spring":
			_add_platform_sprite(plat, TEX_PLATFORM_NORMAL, p_width, 110.0)
			_add_platform_badge(plat, TEX_SPRING, 76.0, -66.0)
		"coin":
			_add_platform_sprite(plat, TEX_PLATFORM_NORMAL, p_width, 110.0)
			_add_platform_badge(plat, TEX_COIN, 68.0, -69.0)
		"vanishing":
			_add_platform_sprite(plat, TEX_PLATFORM_NORMAL, p_width, 110.0, 0.48)
			_add_platform_badge(plat, TEX_GHOST, 70.0, -67.0)
		_:
			_add_platform_sprite(plat, TEX_PLATFORM_NORMAL, p_width, 110.0)

	platforms_container.add_child(plat)


func _on_player_area_entered(area: Area2D) -> void:
	if is_game_over:
		return

	if velocity.y > 0.0 and area.has_meta("platform"):
		if area.has_meta("broken"):
			return

		var p_type: String = str(area.get_meta("type", "normal"))
		if AudioManager:
			AudioManager.play_jump()
		match p_type:
			"spring":
				velocity.y = SUPER_JUMP_POWER
				_spawn_floating_icon(TEX_SPRING, player.position + Vector2(0.0, -82.0), 74.0)
			"coin":
				velocity.y = JUMP_POWER
				coins_earned += 1
				if AudioManager:
					AudioManager.play_coins()
				_spawn_floating_icon(TEX_COIN, player.position + Vector2(0.0, -82.0), 72.0)
				area.set_meta("type", "normal")
				# Quitar el distintivo de moneda para dejar la plataforma normal.
				if area.get_child_count() > 2:
					var badge: Node = area.get_child(area.get_child_count() - 1)
					if badge is Sprite2D:
						badge.queue_free()
				_update_hud()
			"fragile":
				area.set_meta("broken", true)
				velocity.y = JUMP_POWER
				_spawn_floating_icon(TEX_ALERT, area.position + Vector2(0.0, -78.0), 65.0)
				var tween_break := create_tween()
				tween_break.set_parallel(true)
				tween_break.tween_property(area, "position:y", area.position.y + 140.0, 0.38).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
				tween_break.tween_property(area, "modulate:a", 0.0, 0.38)
				tween_break.tween_property(area, "rotation", randf_range(-0.18, 0.18), 0.38)
				tween_break.finished.connect(area.queue_free)
			"vanishing":
				area.set_meta("broken", true)
				velocity.y = JUMP_POWER
				_spawn_floating_icon(TEX_GHOST, area.position + Vector2(0.0, -82.0), 68.0)
				var tween_vanish := create_tween()
				tween_vanish.tween_property(area, "modulate:a", 0.0, 0.28)
				tween_vanish.finished.connect(area.queue_free)
			_:
				velocity.y = JUMP_POWER

		var tween := create_tween()
		tween.tween_property(player, "scale", Vector2(1.14, 0.88), 0.07)
		tween.tween_property(player, "scale", Vector2.ONE, 0.11)


func _trigger_game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	if AudioManager:
		AudioManager.play_game_over()

	var total_coins: int = coins_earned + int(float(score) / 30.0)

	if gm:
		gm.add_coins(total_coins)
		gm.play_with_monky(100.0)
		gm.hygiene = maxf(0.0, gm.hygiene - 8.0)
		gm.add_xp(minf(float(score) * 0.15, 20.0))

	if score > best_score:
		best_score = score
		_save_best_score()

	# Solo números; los iconos de cada tarjeta explican qué representa cada valor.
	final_score_label.text = str(score)
	final_coins_label.text = str(total_coins)
	high_score_label.text = str(best_score)

	game_over_shade.visible = true
	game_over_modal.visible = true
	game_over_modal.scale = Vector2(0.72, 0.72)
	game_over_modal.modulate.a = 0.0
	game_over_modal.pivot_offset = game_over_modal.size / 2.0
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(game_over_modal, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(game_over_modal, "modulate:a", 1.0, 0.18)


func _spawn_floating_icon(texture: Texture2D, pos: Vector2, size_px: float = 76.0) -> void:
	if not texture:
		return
	var sprite := Sprite2D.new()
	sprite.texture = texture
	var tex_size: Vector2 = texture.get_size()
	if tex_size.x > 0.0 and tex_size.y > 0.0:
		var factor: float = size_px / maxf(tex_size.x, tex_size.y)
		sprite.scale = Vector2.ONE * factor
	sprite.global_position = pos
	sprite.z_index = 50
	add_child(sprite)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "position:y", sprite.position.y - 92.0, 0.62).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", sprite.scale * 1.25, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.62).set_delay(0.14).set_ease(Tween.EASE_IN)
	tween.finished.connect(sprite.queue_free)


func _update_hud() -> void:
	score_label.text = str(score)
	coins_label.text = str(coins_earned)


func _load_best_score() -> void:
	var config := ConfigFile.new()
	if config.load("user://monky_jump_score.cfg") == OK:
		best_score = int(config.get_value("score", "best", 0))


func _save_best_score() -> void:
	var config := ConfigFile.new()
	config.set_value("score", "best", best_score)
	config.save("user://monky_jump_score.cfg")


func _on_btn_home_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/minigames/minigames_menu.tscn")
