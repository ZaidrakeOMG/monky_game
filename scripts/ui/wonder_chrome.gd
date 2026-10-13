extends Node
## Style each newly created control once, after its owner's _ready completes.
## Preserve layout margins and semantic label/progress colors from the existing HUD.
const UI := preload("res://scripts/ui/wonder_ui.gd")
var _pending: Array[WeakRef] = []
var _queued: bool = false

func _ready() -> void:
	get_tree().node_added.connect(_node_added)

func _node_added(node: Node) -> void:
	if not node is Button and not node is PanelContainer:
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
		if control is Button:
			var margins: Array[float] = []
			var old_button: StyleBox = control.get_theme_stylebox("normal")
			for side in range(4):
				margins.append(old_button.get_content_margin(side))
			UI.button(control, "Play" in str(control.name) or "Confirm" in str(control.name))
			for state in ["normal", "hover", "pressed", "disabled", "focus"]:
				var style: StyleBox = control.get_theme_stylebox(state)
				for side in range(4):
					style.set_content_margin(side, margins[side])
		elif control is PanelContainer:
			var old_panel: StyleBox = control.get_theme_stylebox("panel")
			var replacement: StyleBoxFlat = UI.panel(UI.INK, Color("536b85"), 28, 0)
			for side in range(4):
				replacement.set_content_margin(side, old_panel.get_content_margin(side))
			control.add_theme_stylebox_override("panel", replacement)
