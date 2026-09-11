extends Control

## Controlador de Pantalla de Carga Inicial
## Realiza la carga de recursos, animación de progreso y transición a la Intro.

@onready var progress_bar: ProgressBar = $BottomContainer/VBox/ProgressBar
@onready var percent_label: Label = $BottomContainer/VBox/PercentLabel
@onready var tip_label: Label = $BottomContainer/VBox/TipLabel

const NEXT_SCENE := "res://scenes/Intro/intro.tscn"

const TIPS: Array[String] = [
	"Preparando la casita de Monky... 🏡",
	"Llenando el refrigerador de frutas y pizza... 🍎🍕",
	"Acomodando los peluches y la consola arcade... 🎮",
	"Preparando las burbujas para el baño... 🧼🛁",
	"¡Todo listo para la diversión! ⭐"
]

var progress: float = 0.0

func _ready() -> void:
	progress_bar.value = 0.0
	percent_label.text = "0%"
	tip_label.text = TIPS[0]

	# Iniciar precarga en segundo plano
	ResourceLoader.load_threaded_request(NEXT_SCENE)
	_start_loading_sequence()

func _start_loading_sequence() -> void:
	var tween = create_tween()
	tween.tween_method(_set_progress, 0.0, 30.0, 0.7)
	tween.tween_callback(func(): _next_tip(1))
	tween.tween_method(_set_progress, 30.0, 65.0, 0.7)
	tween.tween_callback(func(): _next_tip(2))
	tween.tween_method(_set_progress, 65.0, 90.0, 0.6)
	tween.tween_callback(func(): _next_tip(3))
	tween.tween_method(_set_progress, 90.0, 100.0, 0.5)
	tween.tween_callback(func(): _next_tip(4))
	tween.tween_interval(0.2)
	tween.tween_callback(_finish_loading)

func _set_progress(val: float) -> void:
	progress = val
	progress_bar.value = progress
	percent_label.text = str(roundi(progress)) + "%"

func _next_tip(idx: int) -> void:
	if idx < TIPS.size():
		var tween = create_tween()
		tween.tween_property(tip_label, "modulate:a", 0.0, 0.1)
		tween.tween_callback(func():
			tip_label.text = TIPS[idx]
		)
		tween.tween_property(tip_label, "modulate:a", 1.0, 0.1)

func _finish_loading() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func():
		get_tree().change_scene_to_file.call_deferred(NEXT_SCENE)
	)

