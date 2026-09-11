extends Node2D

## Controlador de la Escena Principal del Juego
## Coordina el fondo de las habitaciones, Monky y la interfaz HUD.

@onready var background: Sprite2D = $Background
@onready var monky: Monky = $Monky
@onready var hud: HUD = $HUD

const ROOM_BACKGROUNDS := {
	"dormitorio": "res://assets/backgrounds/cuarto-principal.png",
	"cocina": "res://assets/backgrounds/cocina.jpg",
	"baño": "res://assets/backgrounds/bano.jpg",
	"sala de juegos": "res://assets/backgrounds/sala_juegos.jpg"
}

func _ready() -> void:
	if GameManager:
		GameManager.room_changed.connect(_on_room_changed)
		_on_room_changed(GameManager.current_room)

func _on_room_changed(room_name: String) -> void:
	var key = room_name.to_lower()
	if ROOM_BACKGROUNDS.has(key) and background:
		var path: String = ROOM_BACKGROUNDS[key]
		if ResourceLoader.exists(path):
			var new_tex: Texture2D = load(path)
			if new_tex:
				var tween = create_tween()
				tween.tween_property(background, "modulate:a", 0.3, 0.1)
				tween.tween_callback(func():
					background.texture = new_tex
				)
				tween.tween_property(background, "modulate:a", 1.0, 0.1)


