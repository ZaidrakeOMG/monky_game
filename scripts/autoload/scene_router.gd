extends CanvasLayer

signal progress_changed(value: float)
signal transition_failed(path: String, error: int)
signal transition_finished(path: String)

var busy: bool = false
var _path: String = ""
var _overlay: ColorRect
var _label: Label
var _bar: ProgressBar
var _retry: Button
var _close: Button
var _progress: float = -1.0
var _elapsed: float = 0.0

func _ready() -> void:
	layer = 120
	process_mode = Node.PROCESS_MODE_ALWAYS
	_overlay = ColorRect.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color(0.10, 0.075, 0.13, 0.97)
	add_child(_overlay)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(center)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(700, 0)
	box.add_theme_constant_override("separation", 24)
	center.add_child(box)
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", 32)
	box.add_child(_label)
	_bar = ProgressBar.new()
	_bar.custom_minimum_size = Vector2(700, 24)
	_bar.show_percentage = false
	box.add_child(_bar)
	_retry = Button.new()
	_retry.text = "Reintentar"
	_retry.custom_minimum_size.y = 100
	_retry.pressed.connect(func(): go(_path))
	box.add_child(_retry)
	_close = Button.new()
	_close.text = "Volver"
	_close.custom_minimum_size.y = 100
	_close.pressed.connect(func(): _overlay.hide())
	box.add_child(_close)
	_overlay.hide()
	set_process(false)

func go(path: String) -> bool:
	if busy:
		return false
	_path = path
	_progress = -1.0
	_elapsed = 0.0
	_retry.hide()
	_close.hide()
	_bar.show()
	_overlay.show()
	if not ResourceLoader.exists(path, "PackedScene"):
		_fail(ERR_FILE_NOT_FOUND)
		return false
	var error := ResourceLoader.load_threaded_request(path, "PackedScene")
	if error != OK:
		_fail(error)
		return false
	busy = true
	set_process(true)
	_update_progress(0.0)
	return true

func _process(delta: float) -> void:
	_elapsed += delta
	var progress: Array = []
	var status := ResourceLoader.load_threaded_get_status(_path, progress)
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if not progress.is_empty():
				_update_progress(float(progress[0]) * 100.0)
			if _elapsed > 15.0:
				_label.text = "Cargando recursos… %d%%" % int(_progress)
		ResourceLoader.THREAD_LOAD_LOADED:
			set_process(false)
			_update_progress(100.0)
			# get() is only called once LOADED: never blocks the main thread waiting for I/O.
			var scene := ResourceLoader.load_threaded_get(_path) as PackedScene
			if scene == null:
				_fail(ERR_FILE_CORRUPT)
				return
			_apply_scene.call_deferred(scene)
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			_fail(ERR_CANT_OPEN)

func _update_progress(value: float) -> void:
	if _progress == value:
		return
	_progress = clampf(value, 0.0, 100.0)
	_bar.value = _progress
	_label.text = "Preparando Monky · %d%%" % int(_progress)
	progress_changed.emit(_progress)

func _apply_scene(scene: PackedScene) -> void:
	AudioManager.stop_shower()
	AudioManager.stop_eat()
	AudioManager.stop_snore()
	get_tree().paused = false
	var error := get_tree().change_scene_to_packed(scene)
	if error != OK:
		_fail(error)
		return
	await get_tree().scene_changed
	busy = false
	_overlay.hide()
	transition_finished.emit(_path)

func _fail(error: int) -> void:
	busy = false
	set_process(false)
	_bar.hide()
	_label.text = "No se pudo abrir la pantalla.
Tu progreso no se ha borrado."
	_retry.show()
	_close.show()
	transition_failed.emit(_path, error)
