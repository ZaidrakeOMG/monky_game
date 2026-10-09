extends Node

const SAVE_PATH := "user://save.cfg"
const GAME_SCENE := "res://scenes/main.tscn"

var _finished: bool = false

@onready var video: VideoStreamPlayer = $Control/VideoStreamPlayer


func _ready() -> void:
	print("INTRO INICIADA")

	# Si ya vio la intro anteriormente, ir directo al juego.
	if intro_ya_vista():
		print("INTRO YA VISTA")
		ir_al_juego()
		return

	# Primera vez: reproducir intro.
	print("REPRODUCIENDO INTRO")

	var skip := Button.new()
	skip.text = "Omitir introducción"
	skip.position = Vector2(320, 1740)
	skip.custom_minimum_size = Vector2(440, 100)
	skip.add_theme_font_size_override("font_size", 30)
	skip.pressed.connect(_on_video_finished)
	$Control.add_child(skip)
	UIEffects.bind_button(skip)
	video.loop = false
	video.play()

	# Cuando termine el video.
	video.finished.connect(_on_video_finished)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		set_process_unhandled_input(false)
		call_deferred("_on_video_finished")


func _on_video_finished() -> void:
	if _finished:
		return
	_finished = true
	video.stop()
	print("VIDEO TERMINADO")

	marcar_intro_como_vista()
	ir_al_juego()


func intro_ya_vista() -> bool:
	var config := ConfigFile.new()

	var resultado := config.load(SAVE_PATH)

	# No existe guardado todavía = primera vez.
	if resultado != OK:
		return false

	return config.get_value("game", "intro_seen", false)


func marcar_intro_como_vista() -> void:
	var config := ConfigFile.new()

	# Si existe guardado lo carga.
	# Si no existe, simplemente creará uno nuevo.
	config.load(SAVE_PATH)

	config.set_value("game", "intro_seen", true)

	var resultado := SafeSave.write_config(config, SAVE_PATH)

	if resultado != OK:
		print("ERROR GUARDANDO INTRO: ", resultado)


func ir_al_juego() -> void:
	print("ABRIENDO MAIN")
	SceneRouter.go.call_deferred(GAME_SCENE)
