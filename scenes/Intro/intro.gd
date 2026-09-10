extends Node

const SAVE_PATH := "user://save.cfg"
const GAME_SCENE := "res://scenes/main.tscn"

@onready var video: VideoStreamPlayer = $Control/VideoStreamPlayer


func _ready() -> void:
	# Si el jugador ya vio la intro anteriormente,
	# entramos directamente al juego.
	if intro_ya_vista():
		ir_al_juego()
		return

	# La primera vez reproducimos el video.
	video.finished.connect(_on_video_finished)
	video.play()


func intro_ya_vista() -> bool:
	var config := ConfigFile.new()

	# Si todavía no existe guardado, significa
	# que es la primera vez que abre el juego.
	if config.load(SAVE_PATH) != OK:
		return false

	return config.get_value("game", "intro_seen", false)


func marcar_intro_como_vista() -> void:
	var config := ConfigFile.new()

	# Intentamos cargar el guardado anterior.
	# Si no existe, simplemente crearemos uno nuevo.
	config.load(SAVE_PATH)

	config.set_value("game", "intro_seen", true)

	var error := config.save(SAVE_PATH)

	if error != OK:
		push_error("No se pudo guardar el progreso de la intro.")


func _on_video_finished() -> void:
	# Guardamos que el jugador ya vio la intro.
	marcar_intro_como_vista()

	# Entramos al juego principal.
	ir_al_juego()


func ir_al_juego() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)
