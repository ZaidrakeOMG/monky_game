extends Node2D

## Controlador de la Escena Principal del Juego
## Coordina el fondo en pantalla completa, Monky, la iluminación nocturna y la interfaz HUD.

@onready var background: Sprite2D = $Background
@onready var monky: Monky = $Monky
@onready var hud: HUD = $HUD
@onready var night_overlay: ColorRect = $NightOverlay

const ROOM_BACKGROUNDS := {
	"dormitorio": "res://assets/backgrounds/cuarto-principal.png",
	"cocina": "res://assets/backgrounds/cocina.jpg",
	"baño": "res://assets/backgrounds/bano.jpg",
	"sala de juegos": "res://assets/backgrounds/sala_juegos.jpg"
}

func _ready() -> void:
	if GameManager:
		GameManager.room_changed.connect(_on_room_changed)
		GameManager.monky_state_changed.connect(_on_monky_state_changed)
		GameManager.show_floating_text.connect(_spawn_floating_text)
		_on_room_changed(GameManager.current_room)

func _on_room_changed(room_name: String) -> void:
	var key = room_name.to_lower()
	if ROOM_BACKGROUNDS.has(key) and background:
		var path: String = ROOM_BACKGROUNDS[key]
		if ResourceLoader.exists(path):
			var new_tex: Texture2D = load(path)
			if new_tex:
				var tween = create_tween()
				tween.tween_property(background, "modulate:a", 0.4, 0.1)
				tween.tween_callback(func():
					_apply_cover_background(new_tex)
				)
				tween.tween_property(background, "modulate:a", 1.0, 0.1)

func _apply_cover_background(new_tex: Texture2D) -> void:
	background.texture = new_tex
	var tex_size = new_tex.get_size()
	if tex_size.x > 0 and tex_size.y > 0:
		# Escala para cubrir el 100% de la pantalla (1080x1920) sin bordes negros
		var scale_factor = maxf(1080.0 / tex_size.x, 1920.0 / tex_size.y)
		background.scale = Vector2(scale_factor, scale_factor)

func _on_monky_state_changed(state: String) -> void:
	if night_overlay:
		var tween = create_tween()
		if state == "sleeping":
			tween.tween_property(night_overlay, "color", Color(0.05, 0.05, 0.2, 0.75), 0.5)
		else:
			tween.tween_property(night_overlay, "color", Color(0, 0, 0, 0.0), 0.3)

func _spawn_floating_text(text: String, global_pos: Vector2, color: Color) -> void:
	var label = Label.new()
	label.text = text
	label.modulate = color
	label.add_theme_font_size_override("font_size", 42)
	label.global_position = global_pos + Vector2(randf_range(-30, 30), randf_range(-20, 20))
	label.z_index = 20
	add_child(label)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 100, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_ease(Tween.EASE_IN)
	tween.finished.connect(label.queue_free)



