extends Node
## Incremental skin for the reviewed main HUD and shop. Never rescans every frame.
## Art-backed modals keep their original surfaces; slot text keeps its own contrast.
const UI := preload("res://scripts/ui/wonder_ui.gd")
var _pending: Array[WeakRef] = []
var _queued: bool = false

func _ready() -> void:
	get_tree().node_added.connect(_node_added)

func _node_added(node: Node) -> void:
	if not node is Button and not node is PanelContainer and not node is Label:
		return
	_pending.append(weakref(node))
	if not _queued:
		_queued = true
		_flush.call_deferred()

func _flush() -> void:
	_queued = false
	var batch: Array[WeakRef] = _pending
	_pending = []
	var scene := get_tree().current_scene
	if scene == null or str(scene.scene_file_path).contains("/minigames/"):
		return
	for reference in batch:
		var control := reference.get_ref() as Control
		if control == null or not scene.is_ancestor_of(control):
			continue
		var ancestor: Node = control
		var custom: bool = false
		while ancestor != null:
			if ancestor.has_meta("wonder_custom"):
				custom = true
				break
			ancestor = ancestor.get_parent()
		if custom or control.has_meta("wonder_styled"):
			continue
		control.set_meta("wonder_styled", true)
		var path: String = str(scene.get_path_to(control))
		if control is Label:
			_paint_label(control, path)
		elif control is Button:
			var margins: Array[float] = []
			var old_button: StyleBox = control.get_theme_stylebox("normal")
			for side in range(4):
				margins.append(old_button.get_content_margin(side))
			UI.button(control, "Play" in str(control.name) or "Confirm" in str(control.name))
			for state in ["normal", "hover", "pressed", "disabled", "focus"]:
				var style: StyleBox = control.get_theme_stylebox(state)
				for side in range(4):
					style.set_content_margin(side, margins[side])
			if "/SettingsPopup/" in path:
				var settings := scene.get_node_or_null("HUD/SettingsPopup")
				if settings != null:
					control.pressed.connect(_settings_changed.bind(weakref(settings)), CONNECT_DEFERRED)
		elif control is PanelContainer:
			# Do not paint a dark background underneath unreviewed cream/art-backed modals.
			if not ("/ShopPopup/" in path or "/TopBar/" in path or "/ActionDrawers/" in path):
				continue
			var old_panel: StyleBox = control.get_theme_stylebox("panel")
			var replacement: StyleBoxFlat = UI.panel(UI.INK, Color("536b85"), 28, 0)
			for side in range(4):
				replacement.set_content_margin(side, old_panel.get_content_margin(side))
			control.add_theme_stylebox_override("panel", replacement)

func _paint_label(label: Label, path: String) -> void:
	if "/SettingsPopup/" in path:
		if label.name == &"ButtonLabel":
			_settings_label(label)
		return
	if not "/ShopPopup/" in path:
		return
	var parent: Node = label.get_parent()
	while parent != null and parent.name != &"ShopPopup":
		if parent is BaseButton:
			return # The product cards are cream and must retain dark text.
		parent = parent.get_parent()
	var color: Color = UI.CREAM
	if "CoinsBalance" in str(label.name):
		color = UI.GOLD
	elif "DiamondsBalance" in str(label.name):
		color = UI.MINT
	elif label.text == label.text.to_upper():
		color = UI.GOLD
	else:
		color = UI.MUTED
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("outline_size", 0)

func _settings_label(label: Label) -> void:
	label.add_theme_color_override("font_color", UI.INK)
	label.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	label.add_theme_constant_override("outline_size", 0)

func _settings_changed(reference: WeakRef) -> void:
	var settings := reference.get_ref() as Control
	if settings == null:
		return
	for label in settings.find_children("ButtonLabel", "Label", true, false):
		_settings_label(label as Label)
