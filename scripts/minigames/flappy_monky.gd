extends "res://scripts/minigames/flappy_core.gd"
## Visual layer. The original core keeps scoring, rewards, saving and flight rules.

const UI := preload("res://scripts/ui/wonder_ui.gd")
const Art := preload("res://scripts/ui/wonder_assets.gd")
const PipeArt := preload("res://scripts/minigames/wonder_pipe.gd")
const Sheet := preload("res://scripts/ui/wonder_overlay.gd")
var _pause_sheet: Sheet
var _paused: bool = false
var _scenery_time: float = 0.0

func _ready() -> void:
	super._ready()
	UI.skin_hud($HUD)
	var top := $HUD/TopBar as HBoxContainer
	top.offset_top = 100
	top.offset_bottom = 220
	var pause := Button.new()
	pause.name = "BtnPause"
	pause.text = "Ⅱ"
	pause.tooltip_text = "Pausar partida"
	pause.custom_minimum_size = Vector2(112, 112)
	pause.add_theme_font_size_override("font_size", 42)
	UI.button(pause)
	top.add_child(pause)
	pause.pressed.connect(_show_pause)
	btn_exit.tooltip_text = "Volver a minijuegos"
	tap_hint.text = "TOCA PARA VOLAR\nPasa entre los tubos y reúne monedas."
	tap_hint.add_theme_font_size_override("font_size", 36)
	tap_hint.add_theme_color_override("font_color", UI.CREAM)
	tap_hint.add_theme_color_override("font_outline_color", UI.INK)
	tap_hint.add_theme_constant_override("outline_size", 6)
	tap_hint.offset_left = -470
	tap_hint.offset_right = 470
	_pause_sheet = Sheet.new()
	$HUD.add_child(_pause_sheet)
	_pause_sheet.build("Un pequeño descanso", "Tu vuelo te espera. Continúa cuando estés listo.", "SEGUIR VOLANDO")
	_pause_sheet.primary_pressed.connect(_resume)
	_pause_sheet.secondary_pressed.connect(_on_btn_home_pressed)
	_pause_sheet.hide()

func _setup_background() -> void:
	background.texture = Art.background("flappy")
	UI.cover(background)

func _spawn_pipe_obstacle() -> void:
	super._spawn_pipe_obstacle()
	if pipes_container.get_child_count() > 0:
		PipeArt.dress(pipes_container.get_child(pipes_container.get_child_count() - 1) as Node2D)

func _update_hud() -> void:
	score_label.text = str(score) + "  PUNTOS"
	coins_label.text = "+" + str(coins_earned)

func reset_game() -> void:
	super.reset_game()
	if is_game_over:
		return # An unsuccessful save must not reset a run.
	_paused = false
	spawn_timer.paused = false
	if is_instance_valid(_pause_sheet):
		_pause_sheet.hide()

func _show_pause() -> void:
	if is_game_over or _paused:
		return
	_paused = true
	spawn_timer.paused = true
	_pause_sheet.show()

func _resume() -> void:
	_paused = false
	spawn_timer.paused = false
	_pause_sheet.hide()
	get_viewport().set_input_as_handled()

func _physics_process(delta: float) -> void:
	if not _paused:
		super._physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not is_game_over:
		if _paused:
			_resume()
		else:
			_show_pause()
		get_viewport().set_input_as_handled()
		return
	if not _paused:
		super._unhandled_input(event)

func _process(delta: float) -> void:
	if _paused or is_game_over or (gm != null and gm.reduced_effects):
		return
	_scenery_time += minf(delta, 0.05)
	if background.texture != null:
		var overflow: float = maxf(0.0, (background.texture.get_width() * background.scale.x - 1080.0) / 2.0)
		background.position.x = 540.0 + sin(_scenery_time * 0.06) * minf(160.0, overflow)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(_pause_sheet) and is_game_started:
		_show_pause()

func _on_player_area_entered(area: Area2D) -> void:
	if not _paused:
		super._on_player_area_entered(area)
