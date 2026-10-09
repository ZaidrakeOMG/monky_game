extends Control

const NEXT_SCENE := "res://scenes/Intro/intro.tscn"
@onready var progress_bar: ProgressBar = $BottomContainer/VBox/ProgressBar
@onready var percent_label: Label = $BottomContainer/VBox/PercentLabel
@onready var tip_label: Label = $BottomContainer/VBox/TipLabel

func _ready() -> void:
	progress_bar.value = 0.0
	percent_label.text = "0%"
	tip_label.text = "Cargando los recursos de Monky…"
	SceneRouter.progress_changed.connect(_on_progress)
	SceneRouter.transition_failed.connect(_on_failed)
	SceneRouter.go.call_deferred(NEXT_SCENE)

func _on_progress(value: float) -> void:
	progress_bar.value = value
	UIEffects.set_text(percent_label, "%d%%" % int(value))

func _on_failed(_path: String, _error: int) -> void:
	tip_label.text = "No se pudo cargar. Utiliza Reintentar para continuar."
