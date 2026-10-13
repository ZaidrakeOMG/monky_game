extends "res://scripts/minigames/fruit_core.gd"
## Presentation and onboarding. Item pooling and reward settlement stay in the core.

const UI := preload("res://scripts/ui/wonder_ui.gd")
const Art := preload("res://scripts/ui/wonder_assets.gd")
const Sheet := preload("res://scripts/ui/wonder_overlay.gd")
var _start_sheet: Sheet
var _pause_sheet: Sheet
var _waiting: bool = true
var _paused: bool = false

func _ready() -> void:
	super._ready()
	UI.skin_hud($HUD)
	var top := $HUD/TopBar/HBox as HBoxContainer
	var pause := Button.new()
	pause.name = "BtnPause"
	pause.text = "Ⅱ"
	pause.tooltip_text = "Pausar cosecha"
	pause.custom_minimum_size = Vector2(112, 112)
	pause.add_theme_font_size_override("font_size", 42)
	UI.button(pause)
	top.add_child(pause)
	btn_exit.tooltip_text = "Volver a minijuegos"
	pause.pressed.connect(_show_pause)
	_start_sheet = Sheet.new()
	$HUD.add_child(_start_sheet)
	_start_sheet.build("¡Vamos al huerto!", "Arrastra la canasta para atrapar frutas y monedas.\nEvita las bombas: tienes 3 vidas.\nEn computadora también puedes usar las flechas.", "EMPEZAR A JUGAR")
	_start_sheet.primary_pressed.connect(_begin)
	_start_sheet.secondary_pressed.connect(_on_btn_home_pressed)
	_pause_sheet = Sheet.new()
	$HUD.add_child(_pause_sheet)
	_pause_sheet.build("Cosecha en pausa", "Las frutas pueden esperar. Retoma tu partida sin perder el avance.", "CONTINUAR")
	_pause_sheet.primary_pressed.connect(_resume)
	_pause_sheet.secondary_pressed.connect(_on_btn_home_pressed)
	_pause_sheet.hide()
	_start_sheet.show()
	_start_sheet.primary_button.grab_focus.call_deferred()

func _setup_background() -> void:
	background.texture = Art.background("fruit")
	UI.cover(background)

func start_game() -> void:
	super.start_game()
	if is_game_over:
		return # Preserve the core's save-failure guard.
	_waiting = true
	_paused = false
	_touch_active = false
	_touch_x = 540.0
	spawn_timer.stop()
	spawn_timer.paused = false
	if is_instance_valid(_pause_sheet):
		_pause_sheet.hide()
	if is_instance_valid(_start_sheet):
		_start_sheet.show()

func _begin() -> void:
	_waiting = false
	_start_sheet.hide()
	spawn_timer.start()
	get_viewport().set_input_as_handled()

func _show_pause() -> void:
	if _waiting or _paused or is_game_over:
		return
	_paused = true
	_touch_active = false
	spawn_timer.paused = true
	_pause_sheet.show()

func _resume() -> void:
	_paused = false
	_touch_active = false
	_touch_x = player_basket.position.x
	spawn_timer.paused = false
	_pause_sheet.hide()
	get_viewport().set_input_as_handled()

func _physics_process(delta: float) -> void:
	if not _waiting and not _paused:
		super._physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _paused:
			_resume()
		elif not _waiting:
			_show_pause()
		else:
			_on_btn_home_pressed()
		get_viewport().set_input_as_handled()
		return
	if not _waiting and not _paused:
		super._unhandled_input(event)

func _update_hud() -> void:
	score_label.text = str(score) + " PTS"
	coins_label.text = "+" + str(coins_earned)
	lives_label.text = str(lives) + " / " + str(max_lives)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(_pause_sheet):
		_show_pause()

func _on_basket_area_entered(area: Area2D) -> void:
	if not _waiting and not _paused:
		super._on_basket_area_entered(area)
