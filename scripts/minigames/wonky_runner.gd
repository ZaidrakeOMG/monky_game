extends Node2D

## WONKY RUN V13 - ESCENARIO ESTABLE
## Runner 2D de 3 carriles con camino infinito, parallax y perspectiva compartida.
## Cambios clave:
## - La moneda gigante queda eliminada: HUD y pista usan texturas runtime pequeñas.
## - Personaje/enemigo normalizados para que no cambien de tamaño entre frames.
## - Camino, laterales, objetos y carriles comparten la misma proyección de perspectiva.
## - Fondo lejano casi fijo + camino rápido + laterales lentos + partículas de primer plano.
## - El enemigo se retira fuera de pantalla y solo se acerca al cometer errores.

const VIEW_W: float = 1080.0
const VIEW_H: float = 1920.0

# Perspectiva del escenario. Todo (camino, carriles y objetos) usa estas mismas reglas.
const ROAD_HORIZON_Y: float = 735.0
const ROAD_FAR_HALF_WIDTH: float = 42.0
const ROAD_NEAR_HALF_WIDTH: float = 515.0
const ROAD_FAR_SIDE_OUTER_HALF: float = 155.0
const ROAD_NEAR_SIDE_OUTER_HALF: float = 650.0
const ROAD_DEPTH_POWER: float = 1.50
const ROAD_WIDTH_POWER: float = 0.90
const ROAD_SEGMENTS: int = 24
const ROAD_TILES: float = 2.20
const SIDE_TILES: float = 1.15

const SPAWN_Y: float = ROAD_HORIZON_Y + 6.0
const DESPAWN_Y: float = 2050.0
const PLAYER_Y: float = 1590.0
const PLAYER_SCALE: float = 0.72
const ENEMY_SCALE: float = 0.52
const PLAYER_FRAME_FOOT_OFFSET: float = -244.0
const ENEMY_FRAME_FOOT_OFFSET: float = -244.0

const ENEMY_HIDDEN_Y: float = 2200.0
const ENEMY_WARNING_Y: float = 1770.0
const ENEMY_CATCH_Y: float = 1605.0

const TEX_BG: Texture2D = preload("res://imagenes/runner/parallax/fondo_lejano.png")
const TEX_ROAD: Texture2D = preload("res://imagenes/runner/parallax/camino_loop.png")
const TEX_SIDE_LEFT: Texture2D = preload("res://imagenes/runner/parallax/laterales_izq.png")
const TEX_SIDE_RIGHT: Texture2D = preload("res://imagenes/runner/parallax/laterales_der.png")
const TEX_COIN: Texture2D = preload("res://imagenes/runner/runtime/coin_track.png")
const TEX_COIN_UI: Texture2D = preload("res://imagenes/runner/runtime/coin_ui.png")
const TEX_CRATE: Texture2D = preload("res://imagenes/runner/runtime/crate.png")
const TEX_BARRIER: Texture2D = preload("res://imagenes/runner/runtime/high_barrier.png")
const TEX_SPIKE: Texture2D = preload("res://imagenes/runner/runtime/spike_ball.png")
const TEX_MAGNET: Texture2D = preload("res://imagenes/runner/runtime/magnet.png")
const TEX_SHIELD: Texture2D = preload("res://imagenes/runner/runtime/shield.png")
const TEX_MULTIPLIER: Texture2D = preload("res://imagenes/runner/runtime/multiplier.png")
const TEX_SPARKLES: Texture2D = preload("res://imagenes/runner/runtime/sparkles.png")
const TEX_DUST: Texture2D = preload("res://imagenes/runner/runtime/dust.png")
const TEX_PAUSE: Texture2D = preload("res://imagenes/runner/runtime/pause.png")
const TEX_GAMEOVER: Texture2D = preload("res://imagenes/runner/runtime/gameover_panel.png")
const TEX_RETRY: Texture2D = preload("res://imagenes/runner/runtime/retry.png")
const TEX_REVIVE: Texture2D = preload("res://imagenes/runner/runtime/revive.png")
const TEX_HOME: Texture2D = preload("res://imagenes/opt/navegacion/inicio.png")

const SPEED_PARTICLES = [
	preload("res://imagenes/runner/parallax/fx/dust_01.png"),
	preload("res://imagenes/runner/parallax/fx/dust_02.png"),
	preload("res://imagenes/runner/parallax/fx/dust_fast.png"),
	preload("res://imagenes/runner/parallax/fx/leaf_01.png"),
	preload("res://imagenes/runner/parallax/fx/leaf_02.png"),
	preload("res://imagenes/runner/parallax/fx/leaf_03.png"),
	preload("res://imagenes/runner/parallax/fx/petal_01.png"),
	preload("res://imagenes/runner/parallax/fx/petal_02.png"),
	preload("res://imagenes/runner/parallax/fx/speed_01.png"),
	preload("res://imagenes/runner/parallax/fx/speed_02.png"),
	preload("res://imagenes/runner/parallax/fx/speed_03.png")
]

const WONKY_RUN = [
	preload("res://imagenes/runner/runtime/wonky_run_01.png"),
	preload("res://imagenes/runner/runtime/wonky_run_02.png"),
	preload("res://imagenes/runner/runtime/wonky_run_03.png"),
	preload("res://imagenes/runner/runtime/wonky_run_04.png"),
	preload("res://imagenes/runner/runtime/wonky_run_05.png"),
	preload("res://imagenes/runner/runtime/wonky_run_06.png"),
	preload("res://imagenes/runner/runtime/wonky_run_07.png"),
	preload("res://imagenes/runner/runtime/wonky_run_08.png")
]
const WONKY_JUMP = [
	preload("res://imagenes/runner/runtime/wonky_jump_01.png"),
	preload("res://imagenes/runner/runtime/wonky_jump_02.png"),
	preload("res://imagenes/runner/runtime/wonky_jump_03.png")
]
const TEX_WONKY_SLIDE: Texture2D = preload("res://imagenes/runner/runtime/wonky_slide.png")
const TEX_WONKY_HIT: Texture2D = preload("res://imagenes/runner/runtime/wonky_hit.png")
const TEX_WONKY_CELEBRATE: Texture2D = preload("res://imagenes/runner/runtime/wonky_celebrate.png")

const ENEMY_RUN = [
	preload("res://imagenes/runner/runtime/enemy_run_01.png"),
	preload("res://imagenes/runner/runtime/enemy_run_02.png"),
	preload("res://imagenes/runner/runtime/enemy_run_03.png"),
	preload("res://imagenes/runner/runtime/enemy_run_04.png"),
	preload("res://imagenes/runner/runtime/enemy_run_05.png"),
	preload("res://imagenes/runner/runtime/enemy_run_06.png")
]
const TEX_ENEMY_STUNNED: Texture2D = preload("res://imagenes/runner/runtime/enemy_stunned.png")
const TEX_ENEMY_CELEBRATE: Texture2D = preload("res://imagenes/runner/runtime/enemy_celebrate.png")

var gm: Node = null
var world: Node2D
var background: Sprite2D
var player: AnimatedSprite2D
var enemy: AnimatedSprite2D
var dust: Sprite2D
var active_items: Array[Node2D] = []
var speed_particles: Array[Node2D] = []
var road_scroll: float = 0.0
var side_scroll: float = 0.0
var particle_clock: float = 0.08

var lane_index: int = 1
var score: float = 0.0
var coins_collected: int = 0
var elapsed: float = 0.0
var scroll_speed: float = 0.205
var spawn_clock: float = 0.75
var power_spawn_cooldown: float = 4.0
var is_game_over: bool = false
var is_paused: bool = false
var is_jumping: bool = false
var is_sliding: bool = false
var slide_time: float = 0.0
var hit_lock: float = 0.0
var danger_window: float = 0.0
var enemy_target_y: float = ENEMY_HIDDEN_Y
var enemy_stun_time: float = 0.0
var intro_enemy_time: float = 1.7
var magnet_time: float = 0.0
var multiplier_time: float = 0.0
var shield_active: bool = false
var revive_used: bool = false
var rewards_given: bool = false
var best_score: int = 0
var start_grace: float = 0.85

var touch_origin: Vector2 = Vector2.ZERO
var touch_tracking: bool = false
var mouse_origin: Vector2 = Vector2.ZERO
var mouse_tracking: bool = false

# HUD
var score_label: Label
var coin_label: Label
var power_label: Label
var pause_button: TextureButton
var pause_overlay: Control
var game_over_overlay: Control
var final_score_label: Label
var final_best_label: Label
var final_coins_label: Label
var revive_button: TextureButton
var intro_overlay: Control

func _ready() -> void:
	randomize()
	# Necesario para que las texturas del camino/laterales puedan repetirse al dibujarse.
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	gm = get_tree().root.get_node_or_null("GameManager")
	_load_best_score()
	_build_world()
	_build_hud()
	_start_game()

func _build_world() -> void:
	background = Sprite2D.new()
	background.texture = TEX_BG
	background.position = Vector2(VIEW_W * 0.5, VIEW_H * 0.5)
	if background.texture != null:
		var bg_size: Vector2 = background.texture.get_size()
		if bg_size.x > 0.0 and bg_size.y > 0.0:
			var factor: float = maxf(VIEW_W / bg_size.x, VIEW_H / bg_size.y) * 1.025
			background.scale = Vector2.ONE * factor
	background.z_index = -30
	add_child(background)

	world = Node2D.new()
	world.name = "RunnerWorld"
	world.z_index = 5
	add_child(world)

	var center_x: float = _lane_x_at_y(1, PLAYER_Y)

	enemy = AnimatedSprite2D.new()
	enemy.sprite_frames = _build_enemy_frames()
	enemy.animation = "run"
	enemy.offset = Vector2(0.0, ENEMY_FRAME_FOOT_OFFSET)
	enemy.position = Vector2(center_x, ENEMY_WARNING_Y)
	enemy.scale = Vector2.ONE * ENEMY_SCALE
	enemy.z_index = 8
	world.add_child(enemy)
	enemy.play("run")

	dust = Sprite2D.new()
	dust.texture = TEX_DUST
	dust.position = Vector2(center_x, PLAYER_Y + 12.0)
	dust.scale = Vector2.ONE * 0.46
	dust.modulate = Color(1.0, 1.0, 1.0, 0.30)
	dust.z_index = 9
	world.add_child(dust)

	player = AnimatedSprite2D.new()
	player.sprite_frames = _build_player_frames()
	player.animation = "run"
	player.offset = Vector2(0.0, PLAYER_FRAME_FOOT_OFFSET)
	player.position = Vector2(center_x, PLAYER_Y)
	player.scale = Vector2.ONE * PLAYER_SCALE
	player.z_index = 10
	world.add_child(player)
	player.play("run")

	queue_redraw()

# Dibujo segmentado del escenario: no depende de shaders. Cada franja se deforma
# hacia un punto de fuga y la UV se desplaza para simular avance real.
func _draw() -> void:
	var colors: PackedColorArray = PackedColorArray([Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE])

	# Laterales primero; el camino se pinta encima y mantiene bordes limpios.
	for i in range(ROAD_SEGMENTS):
		var d0: float = float(i) / float(ROAD_SEGMENTS)
		var d1: float = float(i + 1) / float(ROAD_SEGMENTS)
		var y0: float = _road_y_from_depth(d0, VIEW_H)
		var y1: float = _road_y_from_depth(d1, VIEW_H)
		var inner0: float = _road_half_width_at_y(y0) + 5.0
		var inner1: float = _road_half_width_at_y(y1) + 5.0
		var outer0: float = _side_outer_half_width_at_y(y0)
		var outer1: float = _side_outer_half_width_at_y(y1)
		var v0: float = d0 * SIDE_TILES - side_scroll
		var v1: float = d1 * SIDE_TILES - side_scroll

		var left_points: PackedVector2Array = PackedVector2Array([
			Vector2(VIEW_W * 0.5 - outer0, y0),
			Vector2(VIEW_W * 0.5 - inner0, y0),
			Vector2(VIEW_W * 0.5 - inner1, y1),
			Vector2(VIEW_W * 0.5 - outer1, y1)
		])
		var left_uvs: PackedVector2Array = PackedVector2Array([
			Vector2(0.0, v0), Vector2(1.0, v0), Vector2(1.0, v1), Vector2(0.0, v1)
		])
		draw_polygon(left_points, colors, left_uvs, TEX_SIDE_LEFT)

		var right_points: PackedVector2Array = PackedVector2Array([
			Vector2(VIEW_W * 0.5 + inner0, y0),
			Vector2(VIEW_W * 0.5 + outer0, y0),
			Vector2(VIEW_W * 0.5 + outer1, y1),
			Vector2(VIEW_W * 0.5 + inner1, y1)
		])
		var right_uvs: PackedVector2Array = PackedVector2Array([
			Vector2(0.0, v0), Vector2(1.0, v0), Vector2(1.0, v1), Vector2(0.0, v1)
		])
		draw_polygon(right_points, colors, right_uvs, TEX_SIDE_RIGHT)

	for i in range(ROAD_SEGMENTS):
		var d0: float = float(i) / float(ROAD_SEGMENTS)
		var d1: float = float(i + 1) / float(ROAD_SEGMENTS)
		var y0: float = _road_y_from_depth(d0, VIEW_H)
		var y1: float = _road_y_from_depth(d1, VIEW_H)
		var half0: float = _road_half_width_at_y(y0)
		var half1: float = _road_half_width_at_y(y1)
		var v0: float = d0 * ROAD_TILES - road_scroll
		var v1: float = d1 * ROAD_TILES - road_scroll
		var road_points: PackedVector2Array = PackedVector2Array([
			Vector2(VIEW_W * 0.5 - half0, y0),
			Vector2(VIEW_W * 0.5 + half0, y0),
			Vector2(VIEW_W * 0.5 + half1, y1),
			Vector2(VIEW_W * 0.5 - half1, y1)
		])
		var road_uvs: PackedVector2Array = PackedVector2Array([
			Vector2(0.0, v0), Vector2(1.0, v0), Vector2(1.0, v1), Vector2(0.0, v1)
		])
		draw_polygon(road_points, colors, road_uvs, TEX_ROAD)

func _road_y_from_depth(depth: float, bottom_y: float) -> float:
	var d: float = clampf(depth, 0.0, 1.0)
	return lerpf(ROAD_HORIZON_Y, bottom_y, pow(d, ROAD_DEPTH_POWER))

func _road_screen_progress(y: float) -> float:
	return clampf((y - ROAD_HORIZON_Y) / maxf(1.0, VIEW_H - ROAD_HORIZON_Y), 0.0, 1.0)

func _road_half_width_at_y(y: float) -> float:
	var p: float = _road_screen_progress(y)
	return lerpf(ROAD_FAR_HALF_WIDTH, ROAD_NEAR_HALF_WIDTH, pow(p, ROAD_WIDTH_POWER))

func _side_outer_half_width_at_y(y: float) -> float:
	var p: float = _road_screen_progress(y)
	return lerpf(ROAD_FAR_SIDE_OUTER_HALF, ROAD_NEAR_SIDE_OUTER_HALF, pow(p, ROAD_WIDTH_POWER))

func _lane_x_at_y(lane: int, y: float) -> float:
	var half_width: float = _road_half_width_at_y(y)
	var lane_step: float = (2.0 * half_width) / 3.0
	return VIEW_W * 0.5 + float(lane - 1) * lane_step

func _lane_width_at_y(y: float) -> float:
	return (2.0 * _road_half_width_at_y(y)) / 3.0

func _build_player_frames() -> SpriteFrames:
	var frames: SpriteFrames = SpriteFrames.new()
	frames.remove_animation("default")

	frames.add_animation("run")
	frames.set_animation_speed("run", 10.5)
	frames.set_animation_loop("run", true)
	for tex in WONKY_RUN:
		frames.add_frame("run", tex)

	frames.add_animation("jump")
	frames.set_animation_speed("jump", 6.0)
	frames.set_animation_loop("jump", false)
	for tex in WONKY_JUMP:
		frames.add_frame("jump", tex)
	frames.add_frame("jump", WONKY_JUMP[1])

	frames.add_animation("slide")
	frames.set_animation_speed("slide", 1.0)
	frames.set_animation_loop("slide", true)
	frames.add_frame("slide", TEX_WONKY_SLIDE)

	frames.add_animation("hit")
	frames.set_animation_speed("hit", 1.0)
	frames.set_animation_loop("hit", true)
	frames.add_frame("hit", TEX_WONKY_HIT)

	frames.add_animation("celebrate")
	frames.set_animation_speed("celebrate", 1.0)
	frames.set_animation_loop("celebrate", true)
	frames.add_frame("celebrate", TEX_WONKY_CELEBRATE)
	return frames

func _build_enemy_frames() -> SpriteFrames:
	var frames: SpriteFrames = SpriteFrames.new()
	frames.remove_animation("default")
	frames.add_animation("run")
	frames.set_animation_speed("run", 8.5)
	frames.set_animation_loop("run", true)
	for tex in ENEMY_RUN:
		frames.add_frame("run", tex)
	frames.add_animation("stunned")
	frames.set_animation_speed("stunned", 1.0)
	frames.set_animation_loop("stunned", true)
	frames.add_frame("stunned", TEX_ENEMY_STUNNED)
	frames.add_animation("celebrate")
	frames.set_animation_speed("celebrate", 1.0)
	frames.set_animation_loop("celebrate", true)
	frames.add_frame("celebrate", TEX_ENEMY_CELEBRATE)
	return frames

func _build_hud() -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.name = "HUD"
	canvas.layer = 50
	add_child(canvas)

	var root: Control = Control.new()
	root.name = "HUDRoot"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_PASS
	canvas.add_child(root)

	var top_bg: ColorRect = ColorRect.new()
	top_bg.color = Color(0.08, 0.05, 0.02, 0.16)
	top_bg.position = Vector2(0.0, 0.0)
	top_bg.size = Vector2(VIEW_W, 175.0)
	top_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(top_bg)

	# Icono dedicado de 96 px: aunque el Control fallara, nunca puede cubrir la pantalla.
	var coin_icon: TextureRect = TextureRect.new()
	coin_icon.texture = TEX_COIN_UI
	coin_icon.position = Vector2(34.0, 47.0)
	coin_icon.size = Vector2(70.0, 70.0)
	coin_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	coin_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(coin_icon)

	coin_label = _make_hud_label("0", Vector2(105.0, 38.0), Vector2(205.0, 95.0), 45, HORIZONTAL_ALIGNMENT_LEFT)
	root.add_child(coin_label)

	score_label = _make_hud_label("0", Vector2(355.0, 34.0), Vector2(370.0, 105.0), 54, HORIZONTAL_ALIGNMENT_CENTER)
	root.add_child(score_label)

	power_label = _make_hud_label("", Vector2(255.0, 118.0), Vector2(570.0, 52.0), 25, HORIZONTAL_ALIGNMENT_CENTER)
	power_label.add_theme_color_override("font_color", Color("#FFF4B6"))
	root.add_child(power_label)

	pause_button = TextureButton.new()
	pause_button.texture_normal = TEX_PAUSE
	pause_button.ignore_texture_size = true
	pause_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	pause_button.position = Vector2(930.0, 34.0)
	pause_button.size = Vector2(104.0, 104.0)
	pause_button.focus_mode = Control.FOCUS_NONE
	pause_button.pressed.connect(_toggle_pause)
	root.add_child(pause_button)

	_build_pause_overlay(root)
	_build_game_over_overlay(root)
	_build_intro_overlay(root)

func _make_hud_label(text_value: String, pos: Vector2, size_value: Vector2, font_size: int, align: int) -> Label:
	var label: Label = Label.new()
	label.text = text_value
	label.position = pos
	label.size = size_value
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color("#4A210F"))
	label.add_theme_constant_override("outline_size", 7)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.22))
	label.add_theme_constant_override("shadow_offset_y", 3)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _build_pause_overlay(root: Control) -> void:
	pause_overlay = Control.new()
	pause_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_overlay.visible = false
	pause_overlay.z_index = 80
	pause_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(pause_overlay)

	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.03, 0.02, 0.02, 0.72)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_overlay.add_child(dim)

	var title: Label = _make_hud_label("PAUSA", Vector2(240.0, 650.0), Vector2(600.0, 120.0), 72, HORIZONTAL_ALIGNMENT_CENTER)
	pause_overlay.add_child(title)

	var resume: Button = Button.new()
	resume.text = "CONTINUAR"
	resume.position = Vector2(310.0, 835.0)
	resume.size = Vector2(460.0, 125.0)
	resume.add_theme_font_size_override("font_size", 42)
	resume.pressed.connect(_toggle_pause)
	pause_overlay.add_child(resume)

	var home: Button = Button.new()
	home.text = "SALIR AL MENÚ"
	home.position = Vector2(310.0, 995.0)
	home.size = Vector2(460.0, 108.0)
	home.add_theme_font_size_override("font_size", 31)
	home.pressed.connect(_leave_to_menu)
	pause_overlay.add_child(home)

func _build_game_over_overlay(root: Control) -> void:
	game_over_overlay = Control.new()
	game_over_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game_over_overlay.visible = false
	game_over_overlay.z_index = 100
	game_over_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(game_over_overlay)

	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.04, 0.02, 0.01, 0.78)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game_over_overlay.add_child(dim)

	var panel: TextureRect = TextureRect.new()
	panel.texture = TEX_GAMEOVER
	panel.position = Vector2(120.0, 370.0)
	panel.size = Vector2(840.0, 1050.0)
	panel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	panel.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_over_overlay.add_child(panel)

	var title: Label = _make_hud_label("FIN DE LA CARRERA", Vector2(175.0, 505.0), Vector2(730.0, 100.0), 50, HORIZONTAL_ALIGNMENT_CENTER)
	title.add_theme_color_override("font_color", Color("#FFCC43"))
	game_over_overlay.add_child(title)

	final_score_label = _make_hud_label("PUNTOS 0", Vector2(205.0, 675.0), Vector2(670.0, 78.0), 42, HORIZONTAL_ALIGNMENT_CENTER)
	final_best_label = _make_hud_label("RÉCORD 0", Vector2(205.0, 785.0), Vector2(670.0, 78.0), 35, HORIZONTAL_ALIGNMENT_CENTER)
	final_coins_label = _make_hud_label("MONEDAS +0", Vector2(205.0, 895.0), Vector2(670.0, 78.0), 35, HORIZONTAL_ALIGNMENT_CENTER)
	game_over_overlay.add_child(final_score_label)
	game_over_overlay.add_child(final_best_label)
	game_over_overlay.add_child(final_coins_label)

	var retry_btn: TextureButton = _make_texture_button(TEX_RETRY, Vector2(175.0, 1080.0), Vector2(190.0, 190.0))
	retry_btn.pressed.connect(_restart_from_game_over)
	game_over_overlay.add_child(retry_btn)
	var retry_text: Label = _make_hud_label("REINTENTAR", Vector2(125.0, 1260.0), Vector2(290.0, 55.0), 24, HORIZONTAL_ALIGNMENT_CENTER)
	game_over_overlay.add_child(retry_text)

	revive_button = _make_texture_button(TEX_REVIVE, Vector2(445.0, 1080.0), Vector2(190.0, 190.0))
	revive_button.pressed.connect(_revive)
	game_over_overlay.add_child(revive_button)
	var revive_text: Label = _make_hud_label("REVIVIR", Vector2(400.0, 1260.0), Vector2(280.0, 55.0), 24, HORIZONTAL_ALIGNMENT_CENTER)
	game_over_overlay.add_child(revive_text)

	var home_btn: TextureButton = _make_texture_button(TEX_HOME, Vector2(720.0, 1090.0), Vector2(175.0, 175.0))
	home_btn.pressed.connect(_leave_to_menu)
	game_over_overlay.add_child(home_btn)
	var home_text: Label = _make_hud_label("MENÚ", Vector2(675.0, 1260.0), Vector2(270.0, 55.0), 24, HORIZONTAL_ALIGNMENT_CENTER)
	game_over_overlay.add_child(home_text)

func _make_texture_button(tex: Texture2D, pos: Vector2, size_value: Vector2) -> TextureButton:
	var button: TextureButton = TextureButton.new()
	button.texture_normal = tex
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.position = pos
	button.size = size_value
	button.focus_mode = Control.FOCUS_NONE
	return button

func _build_intro_overlay(root: Control) -> void:
	intro_overlay = Control.new()
	intro_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	intro_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	intro_overlay.z_index = 70
	root.add_child(intro_overlay)

	var box: ColorRect = ColorRect.new()
	box.color = Color(0.04, 0.025, 0.01, 0.56)
	box.position = Vector2(115.0, 660.0)
	box.size = Vector2(850.0, 340.0)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	intro_overlay.add_child(box)

	var title: Label = _make_hud_label("¡CORRE, WONKY!", Vector2(150.0, 700.0), Vector2(780.0, 90.0), 50, HORIZONTAL_ALIGNMENT_CENTER)
	intro_overlay.add_child(title)
	var help: Label = _make_hud_label("←  CAMBIA DE CARRIL  →\n↑  SALTA     ·     ↓  DESLÍZATE", Vector2(145.0, 805.0), Vector2(790.0, 130.0), 28, HORIZONTAL_ALIGNMENT_CENTER)
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro_overlay.add_child(help)

func _start_game() -> void:
	for item in active_items:
		if is_instance_valid(item):
			item.queue_free()
	active_items.clear()

	lane_index = 1
	score = 0.0
	coins_collected = 0
	elapsed = 0.0
	scroll_speed = 0.205
	spawn_clock = 0.72
	power_spawn_cooldown = 4.0
	is_game_over = false
	is_paused = false
	is_jumping = false
	is_sliding = false
	slide_time = 0.0
	hit_lock = 0.0
	danger_window = 0.0
	enemy_target_y = ENEMY_HIDDEN_Y
	enemy_stun_time = 0.0
	intro_enemy_time = 1.7
	magnet_time = 0.0
	multiplier_time = 0.0
	shield_active = false
	revive_used = false
	rewards_given = false
	start_grace = 0.85
	road_scroll = 0.0
	side_scroll = 0.0
	particle_clock = 0.06
	_clear_speed_particles()
	queue_redraw()

	player.position = Vector2(_lane_x_at_y(1, PLAYER_Y), PLAYER_Y)
	player.rotation = 0.0
	player.scale = Vector2.ONE * PLAYER_SCALE
	player.modulate = Color.WHITE
	player.play("run")

	enemy.position = Vector2(_lane_x_at_y(1, ENEMY_WARNING_Y), ENEMY_WARNING_Y)
	enemy.scale = Vector2.ONE * ENEMY_SCALE
	enemy.modulate = Color.WHITE
	enemy.play("run")

	dust.position = Vector2(_lane_x_at_y(1, PLAYER_Y), PLAYER_Y + 12.0)
	pause_overlay.visible = false
	game_over_overlay.visible = false
	revive_button.modulate = Color.WHITE
	revive_button.mouse_filter = Control.MOUSE_FILTER_STOP
	intro_overlay.visible = true
	intro_overlay.modulate.a = 1.0
	_update_hud()

	var tween: Tween = create_tween()
	tween.tween_interval(1.65)
	tween.tween_property(intro_overlay, "modulate:a", 0.0, 0.30)
	tween.finished.connect(func():
		intro_overlay.visible = false
		intro_overlay.modulate.a = 1.0
	)

func _process(delta: float) -> void:
	if is_paused or is_game_over:
		return

	elapsed += delta
	hit_lock = maxf(0.0, hit_lock - delta)
	power_spawn_cooldown = maxf(0.0, power_spawn_cooldown - delta)
	magnet_time = maxf(0.0, magnet_time - delta)
	multiplier_time = maxf(0.0, multiplier_time - delta)
	enemy_stun_time = maxf(0.0, enemy_stun_time - delta)
	start_grace = maxf(0.0, start_grace - delta)

	if intro_enemy_time > 0.0:
		intro_enemy_time -= delta
		if intro_enemy_time <= 0.0 and danger_window <= 0.0:
			enemy_target_y = ENEMY_HIDDEN_Y

	if danger_window > 0.0:
		danger_window -= delta
		if danger_window <= 0.0:
			danger_window = 0.0
			enemy_target_y = ENEMY_HIDDEN_Y

	if is_sliding:
		slide_time -= delta
		if slide_time <= 0.0:
			_finish_slide()

	scroll_speed = minf(0.355, 0.205 + elapsed * 0.00155)
	var score_multi: float = 2.0 if multiplier_time > 0.0 else 1.0
	score += delta * (16.0 + elapsed * 0.075) * score_multi

	if start_grace <= 0.0:
		spawn_clock -= delta
		if spawn_clock <= 0.0:
			_spawn_pattern()
			spawn_clock = maxf(0.50, 0.94 - elapsed * 0.0038)

	_update_parallax(delta)
	_update_speed_particles(delta)
	_update_items(delta)
	_update_enemy(delta)
	_update_dust(delta)
	_update_hud()

func _update_parallax(delta: float) -> void:
	var speed_factor: float = clampf((scroll_speed - 0.205) / 0.150, 0.0, 1.0)
	# V13: el paisaje y los laterales quedan anclados. Solo avanza el suelo.
	# Esto evita el efecto de "mareo" que producía mover capas con perspectivas distintas.
	var road_rate: float = lerpf(0.34, 0.62, speed_factor)
	road_scroll = fmod(road_scroll + delta * road_rate, 1.0)
	side_scroll = 0.0
	background.position = Vector2(VIEW_W * 0.5, VIEW_H * 0.5)
	queue_redraw()

func _clear_speed_particles() -> void:
	for fx in speed_particles:
		if is_instance_valid(fx):
			fx.queue_free()
	speed_particles.clear()

func _spawn_speed_particle() -> void:
	if SPEED_PARTICLES.is_empty():
		return
	var fx: Sprite2D = Sprite2D.new()
	var tex_index: int = randi_range(0, SPEED_PARTICLES.size() - 1)
	fx.texture = SPEED_PARTICLES[tex_index]
	var left_side: bool = randf() < 0.5
	var x: float = randf_range(35.0, 245.0) if left_side else randf_range(835.0, 1045.0)
	var y: float = randf_range(720.0, 1420.0)
	fx.position = Vector2(x, y)
	var base_scale: float = randf_range(0.16, 0.34)
	fx.scale = Vector2.ONE * base_scale
	fx.rotation = randf_range(-0.35, 0.35)
	fx.modulate = Color(1.0, 1.0, 1.0, randf_range(0.34, 0.68))
	fx.z_index = 6 if randf() < 0.7 else 14
	var speed_factor: float = clampf((scroll_speed - 0.205) / 0.150, 0.0, 1.0)
	fx.set_meta("vy", randf_range(300.0, 520.0) * lerpf(0.85, 1.25, speed_factor))
	fx.set_meta("vx", randf_range(-55.0, 55.0))
	fx.set_meta("growth", randf_range(0.10, 0.28))
	world.add_child(fx)
	speed_particles.append(fx)

func _update_speed_particles(delta: float) -> void:
	particle_clock -= delta
	var speed_factor: float = clampf((scroll_speed - 0.205) / 0.150, 0.0, 1.0)
	if particle_clock <= 0.0:
		_spawn_speed_particle()
		particle_clock = lerpf(0.34, 0.16, speed_factor)

	for fx in speed_particles.duplicate():
		if not is_instance_valid(fx):
			speed_particles.erase(fx)
			continue
		var vy: float = float(fx.get_meta("vy", 420.0))
		var vx: float = float(fx.get_meta("vx", 0.0))
		var growth: float = float(fx.get_meta("growth", 0.15))
		fx.position += Vector2(vx, vy) * delta
		fx.scale += Vector2.ONE * growth * delta
		fx.rotation += delta * 0.35 * signf(vx if absf(vx) > 0.1 else 1.0)
		if fx.position.y > 1580.0:
			fx.modulate.a = maxf(0.0, fx.modulate.a - delta * 0.85)
		if fx.position.y > 2050.0 or fx.modulate.a <= 0.01:
			speed_particles.erase(fx)
			fx.queue_free()

func _update_enemy(delta: float) -> void:
	enemy.position.x = lerpf(enemy.position.x, player.position.x, minf(1.0, delta * 4.0))
	enemy.position.y = lerpf(enemy.position.y, enemy_target_y, minf(1.0, delta * 3.2))
	if enemy_stun_time <= 0.0 and enemy.animation == "stunned":
		enemy.play("run")

func _update_dust(delta: float) -> void:
	dust.position.x = lerpf(dust.position.x, player.position.x, minf(1.0, delta * 13.0))
	dust.position.y = PLAYER_Y + 18.0
	dust.rotation = sin(elapsed * 6.0) * 0.02
	dust.modulate.a = 0.22 + 0.10 * (0.5 + 0.5 * sin(elapsed * 11.0))
	dust.visible = not is_jumping and not is_sliding and hit_lock <= 0.0

func _spawn_pattern() -> void:
	var roll: float = randf()
	if roll < 0.53:
		_spawn_coin_line()
	elif roll < 0.84:
		_spawn_obstacle_pattern()
	else:
		if power_spawn_cooldown <= 0.0:
			_spawn_powerup()
			power_spawn_cooldown = randf_range(6.0, 9.0)
		else:
			_spawn_coin_line()

func _spawn_coin_line() -> void:
	var lane: int = randi_range(0, 2)
	var count: int = randi_range(3, 6)
	for i in range(count):
		_spawn_item("coin", lane, -float(i) * 0.078)

func _spawn_obstacle_pattern() -> void:
	var lane_a: int = randi_range(0, 2)
	var kind_a: String = _random_obstacle()
	_spawn_item(kind_a, lane_a, 0.0)

	# Más adelante pueden ocuparse dos carriles, pero siempre queda uno libre.
	if elapsed > 28.0 and randf() < 0.24:
		var options: Array[int] = [0, 1, 2]
		options.erase(lane_a)
		var lane_b: int = options[randi_range(0, options.size() - 1)]
		_spawn_item(_random_obstacle(), lane_b, -0.018)
		var free_lane: int = 3 - lane_a - lane_b
		_spawn_item("coin", free_lane, -0.07)
		_spawn_item("coin", free_lane, -0.15)

func _random_obstacle() -> String:
	var r: float = randf()
	if r < 0.43:
		return "crate"
	if r < 0.72:
		return "spike"
	return "barrier"

func _spawn_powerup() -> void:
	var lane: int = randi_range(0, 2)
	var kinds: Array[String] = ["magnet", "shield", "multiplier"]
	var power_kind: String = kinds[randi_range(0, kinds.size() - 1)]
	_spawn_item(power_kind, lane, 0.0)

func _spawn_item(kind: String, lane: int, start_progress: float) -> void:
	var holder: Node2D = Node2D.new()
	holder.name = "RunnerItem_" + kind
	holder.set_meta("kind", kind)
	holder.set_meta("lane", lane)
	holder.set_meta("p", start_progress)
	holder.set_meta("resolved", false)

	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = _texture_for(kind)
	sprite.name = "Sprite"
	sprite.centered = true
	holder.add_child(sprite)

	# Se dimensiona ANTES de entrar al árbol para evitar cualquier frame gigante.
	var initial_t: float = clampf(maxf(start_progress, 0.0), 0.0, 1.0)
	_apply_item_transform(holder, sprite, kind, lane, initial_t)
	holder.visible = start_progress >= 0.0
	world.add_child(holder)
	active_items.append(holder)

func _texture_for(kind: String) -> Texture2D:
	match kind:
		"coin":
			return TEX_COIN
		"crate":
			return TEX_CRATE
		"spike":
			return TEX_SPIKE
		"barrier":
			return TEX_BARRIER
		"magnet":
			return TEX_MAGNET
		"shield":
			return TEX_SHIELD
		"multiplier":
			return TEX_MULTIPLIER
	return TEX_COIN

func _target_width(kind: String, y: float) -> float:
	var lane_width: float = _lane_width_at_y(y)
	var ratio: float = 0.36
	var min_width: float = 13.0
	var max_width: float = 150.0
	match kind:
		"coin":
			ratio = 0.34
			max_width = 142.0
		"crate":
			ratio = 0.74
			max_width = 300.0
		"spike":
			ratio = 0.60
			max_width = 245.0
		"barrier":
			ratio = 0.94
			max_width = 385.0
		"magnet", "shield", "multiplier":
			ratio = 0.42
			max_width = 175.0
	return clampf(lane_width * ratio, min_width, max_width)

func _sprite_scale_for(sprite: Sprite2D, target_width: float) -> float:
	if sprite.texture == null:
		return 0.1
	var tex_size: Vector2 = sprite.texture.get_size()
	if tex_size.x <= 0.0:
		return 0.1
	return target_width / tex_size.x

func _apply_item_transform(holder: Node2D, sprite: Sprite2D, kind: String, lane: int, t: float) -> void:
	var clamped_t: float = clampf(t, 0.0, 1.0)
	var y: float = _road_y_from_depth(clamped_t, DESPAWN_Y)
	var x: float = _lane_x_at_y(lane, y)
	holder.position = Vector2(x, y)

	var target_width: float = _target_width(kind, y)
	var scale_value: float = _sprite_scale_for(sprite, target_width)
	sprite.scale = Vector2.ONE * scale_value

	# El Node2D representa el punto donde el objeto toca el piso.
	var anchor_ratio: float = 0.50
	if kind == "coin" or kind == "magnet" or kind == "shield" or kind == "multiplier":
		anchor_ratio = 0.72
	sprite.position.y = -target_width * anchor_ratio
	holder.z_index = int(2.0 + y / 115.0)

func _update_items(delta: float) -> void:
	for item in active_items.duplicate():
		if not is_instance_valid(item):
			active_items.erase(item)
			continue

		var p: float = float(item.get_meta("p")) + delta * scroll_speed
		item.set_meta("p", p)
		if p < 0.0:
			item.visible = false
			continue
		item.visible = true

		var t: float = clampf(p, 0.0, 1.0)
		var lane: int = int(item.get_meta("lane"))
		var kind: String = str(item.get_meta("kind"))
		var spr: Sprite2D = item.get_node_or_null("Sprite") as Sprite2D
		if spr == null:
			_remove_item(item)
			continue

		_apply_item_transform(item, spr, kind, lane, t)

		if kind == "coin":
			spr.rotation += delta * 2.2
		elif kind == "spike":
			spr.rotation += delta * 0.75
		elif kind == "magnet" or kind == "shield" or kind == "multiplier":
			spr.rotation = sin(elapsed * 4.2 + float(lane)) * 0.07

		if magnet_time > 0.0 and kind == "coin" and p > 0.36 and not bool(item.get_meta("resolved")):
			_collect_item(item)
			continue

		var close_to_player: bool = absf(item.position.y - PLAYER_Y) <= 115.0
		if close_to_player and lane == lane_index and not bool(item.get_meta("resolved")):
			_resolve_contact(item)

		if p > 1.02:
			_remove_item(item)

func _resolve_contact(item: Node2D) -> void:
	var kind: String = str(item.get_meta("kind"))
	match kind:
		"coin":
			item.set_meta("resolved", true)
			_collect_item(item)
		"magnet", "shield", "multiplier":
			item.set_meta("resolved", true)
			_collect_powerup(item, kind)
		"crate", "spike":
			item.set_meta("resolved", true)
			if not is_jumping:
				_crash()
		"barrier":
			item.set_meta("resolved", true)
			if not is_sliding:
				_crash()

func _collect_item(item: Node2D) -> void:
	if not is_instance_valid(item):
		return
	item.set_meta("resolved", true)
	coins_collected += 1
	var score_multi: int = 2 if multiplier_time > 0.0 else 1
	score += 24.0 * float(score_multi)
	_spawn_pickup_fx(item.position)
	_remove_item(item)

func _collect_powerup(item: Node2D, kind: String) -> void:
	if not is_instance_valid(item):
		return
	_spawn_pickup_fx(item.position)
	match kind:
		"magnet":
			magnet_time = 8.0
		"shield":
			shield_active = true
		"multiplier":
			multiplier_time = 9.0
	_remove_item(item)

func _spawn_pickup_fx(pos: Vector2) -> void:
	var fx: Sprite2D = Sprite2D.new()
	fx.texture = TEX_SPARKLES
	fx.position = pos + Vector2(0.0, -65.0)
	fx.scale = Vector2.ONE * 0.28
	fx.modulate = Color(1.0, 1.0, 1.0, 0.90)
	fx.z_index = 35
	world.add_child(fx)
	var tw: Tween = create_tween()
	tw.set_parallel(true)
	tw.tween_property(fx, "scale", Vector2.ONE * 0.40, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(fx, "modulate:a", 0.0, 0.34)
	tw.finished.connect(fx.queue_free)

func _remove_item(item: Node2D) -> void:
	active_items.erase(item)
	if is_instance_valid(item):
		item.queue_free()

func _crash() -> void:
	if hit_lock > 0.0 or is_game_over:
		return

	if shield_active:
		shield_active = false
		hit_lock = 0.9
		enemy.position.y = maxf(enemy.position.y, 1885.0)
		enemy_target_y = 1910.0
		enemy.play("stunned")
		enemy_stun_time = 0.9
		_flash_player(Color(1.0, 0.95, 0.45, 1.0))
		return

	hit_lock = 1.15
	player.play("hit")
	_flash_player(Color(1.0, 0.72, 0.72, 1.0))

	if danger_window > 0.0:
		_trigger_game_over()
		return

	danger_window = 5.5
	enemy_target_y = ENEMY_WARNING_Y
	score = maxf(0.0, score - 35.0)
	var tw: Tween = create_tween()
	tw.tween_interval(0.62)
	tw.finished.connect(func():
		if not is_game_over and not is_jumping and not is_sliding:
			player.play("run")
	)

func _flash_player(color_value: Color) -> void:
	player.modulate = color_value
	var tw: Tween = create_tween()
	tw.tween_property(player, "modulate", Color.WHITE, 0.32)

func _trigger_game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	is_jumping = false
	is_sliding = false
	player.position.y = PLAYER_Y
	player.play("hit")
	enemy_target_y = ENEMY_CATCH_Y
	enemy.play("celebrate")

	var final_score: int = int(score)
	if final_score > best_score:
		best_score = final_score
		_save_best_score()

	final_score_label.text = "PUNTOS  " + str(final_score)
	final_best_label.text = "RÉCORD  " + str(best_score)
	var bonus: int = int(float(final_score) / 300.0)
	final_coins_label.text = "MONEDAS  +" + str(coins_collected + bonus)
	revive_button.modulate = Color(1.0, 1.0, 1.0, 0.38) if revive_used else Color.WHITE
	revive_button.mouse_filter = Control.MOUSE_FILTER_IGNORE if revive_used else Control.MOUSE_FILTER_STOP
	game_over_overlay.visible = true
	game_over_overlay.modulate.a = 0.0
	var tw: Tween = create_tween()
	tw.tween_property(game_over_overlay, "modulate:a", 1.0, 0.20)

func _revive() -> void:
	if not is_game_over or revive_used:
		return
	revive_used = true
	is_game_over = false
	game_over_overlay.visible = false
	danger_window = 0.0
	hit_lock = 1.7
	enemy_target_y = ENEMY_HIDDEN_Y
	enemy.play("stunned")
	enemy_stun_time = 1.0
	player.position.y = PLAYER_Y
	player.play("run")
	_clear_near_player()

func _clear_near_player() -> void:
	for item in active_items.duplicate():
		if not is_instance_valid(item):
			continue
		var p: float = float(item.get_meta("p"))
		if p > 0.48:
			_remove_item(item)

func _restart_from_game_over() -> void:
	_award_rewards()
	_start_game()

func _leave_to_menu() -> void:
	_award_rewards()
	get_tree().change_scene_to_file.call_deferred("res://scenes/minigames/minigames_menu.tscn")

func _award_rewards() -> void:
	if rewards_given:
		return
	rewards_given = true
	if gm != null:
		var earned: int = coins_collected + int(score / 300.0)
		if earned > 0:
			gm.add_coins(earned)
		gm.play_with_monky(28.0)
		gm.add_xp(minf(score / 115.0, 24.0))
		if gm.has_method("save_game"):
			gm.save_game()

func _toggle_pause() -> void:
	if is_game_over:
		return
	is_paused = not is_paused
	pause_overlay.visible = is_paused
	if is_paused:
		player.pause()
		enemy.pause()
	else:
		if is_sliding:
			player.play("slide")
		elif is_jumping:
			player.play("jump")
		elif hit_lock > 0.0:
			player.play("hit")
		else:
			player.play("run")
		if enemy_stun_time > 0.0:
			enemy.play("stunned")
		else:
			enemy.play("run")

func _update_hud() -> void:
	if score_label != null:
		score_label.text = str(int(score))
	if coin_label != null:
		coin_label.text = str(coins_collected)
	if power_label != null:
		var parts: Array[String] = []
		if magnet_time > 0.0:
			parts.append("IMÁN " + str(int(ceil(magnet_time))) + "s")
		if shield_active:
			parts.append("ESCUDO")
		if multiplier_time > 0.0:
			parts.append("x2 " + str(int(ceil(multiplier_time))) + "s")
		power_label.text = "  ·  ".join(parts)

func _input(event: InputEvent) -> void:
	if is_game_over or is_paused:
		return

	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.pressed and not key_event.echo:
			match key_event.keycode:
				KEY_LEFT, KEY_A:
					_change_lane(-1)
				KEY_RIGHT, KEY_D:
					_change_lane(1)
				KEY_UP, KEY_W, KEY_SPACE:
					_jump()
				KEY_DOWN, KEY_S:
					_slide()

	if event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		if touch_event.pressed:
			touch_origin = touch_event.position
			touch_tracking = true
		else:
			if touch_tracking:
				_handle_swipe(touch_event.position - touch_origin)
			touch_tracking = false
	elif event is InputEventScreenDrag and touch_tracking:
		var drag_event: InputEventScreenDrag = event as InputEventScreenDrag
		var drag_diff: Vector2 = drag_event.position - touch_origin
		if drag_diff.length() > 105.0:
			_handle_swipe(drag_diff)
			touch_tracking = false

	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				mouse_origin = mouse_event.position
				mouse_tracking = true
			else:
				if mouse_tracking:
					_handle_swipe(mouse_event.position - mouse_origin)
				mouse_tracking = false

func _handle_swipe(delta_swipe: Vector2) -> void:
	if delta_swipe.length() < 55.0:
		return
	if absf(delta_swipe.x) > absf(delta_swipe.y):
		_change_lane(-1 if delta_swipe.x < 0.0 else 1)
	else:
		if delta_swipe.y < 0.0:
			_jump()
		else:
			_slide()

func _change_lane(direction: int) -> void:
	if is_game_over:
		return
	var new_lane: int = clampi(lane_index + direction, 0, 2)
	if new_lane == lane_index:
		return
	lane_index = new_lane
	var target_x: float = _lane_x_at_y(lane_index, PLAYER_Y)
	var tilt: float = -0.09 if direction < 0 else 0.09
	var tw: Tween = create_tween()
	tw.set_parallel(true)
	tw.tween_property(player, "position:x", target_x, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(player, "rotation", tilt, 0.08)
	var dust_tw: Tween = create_tween()
	dust_tw.tween_property(dust, "position:x", target_x, 0.17).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var reset: Tween = create_tween()
	reset.tween_interval(0.09)
	reset.tween_property(player, "rotation", 0.0, 0.10)

func _jump() -> void:
	if is_jumping or is_sliding or hit_lock > 0.0 or is_game_over:
		return
	is_jumping = true
	player.play("jump")
	var tw: Tween = create_tween()
	tw.tween_property(player, "position:y", PLAYER_Y - 285.0, 0.29).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(player, "position:y", PLAYER_Y, 0.34).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.finished.connect(_finish_jump)

func _finish_jump() -> void:
	is_jumping = false
	player.position.y = PLAYER_Y
	if not is_game_over and not is_sliding and hit_lock <= 0.0:
		player.play("run")

func _slide() -> void:
	if is_sliding or is_jumping or hit_lock > 0.0 or is_game_over:
		return
	is_sliding = true
	slide_time = 0.70
	player.position.y = PLAYER_Y + 18.0
	player.play("slide")

func _finish_slide() -> void:
	is_sliding = false
	player.position.y = PLAYER_Y
	if not is_game_over and not is_jumping and hit_lock <= 0.0:
		player.play("run")

func _load_best_score() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	if cfg.load("user://wonky_runner.cfg") == OK:
		best_score = int(cfg.get_value("runner", "best_score", 0))

func _save_best_score() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	cfg.set_value("runner", "best_score", best_score)
	cfg.save("user://wonky_runner.cfg")
