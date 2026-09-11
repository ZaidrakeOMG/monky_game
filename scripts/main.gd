extends Node2D

## Controlador de la Escena Principal del Juego
## Coordina el fondo de las habitaciones, Monky y la interfaz HUD.

@onready var background: Sprite2D = 
@onready var monky: Monky = 
@onready var hud: HUD = 

# Colores de tinte según la habitación (mientras se añaden los fondos de cocina, baño, etc.)
const ROOM_TINTS := {
	dormitorio: Color(1.0, 1.0, 1.0),
	cocina: Color(1.0, 0.95, 0.85),
	baño: Color(0.85, 0.95, 1.0),
	sala de juegos: Color(0.95, 0.85, 1.0)
}

func _ready() -> void:
	if GameManager:
		GameManager.room_changed.connect(_on_room_changed)
		_on_room_changed(GameManager.current_room)

func _on_room_changed(room_name: String) -> void:
	var key = room_name.to_lower()
	if ROOM_TINTS.has(key):
		var target_color: Color = ROOM_TINTS[key]
		var tween = create_tween()
		tween.tween_property(background, modulate, target_color, 0.3)
