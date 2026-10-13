extends Node
## Consistent colors for the existing care/shop/settings interfaces.
## Does not replace callbacks, disabled states, icons, prices or layout geometry.

const UI := preload("res://scripts/ui/wonder_ui.gd")
var _queued: bool = false

func _ready() -> void:
	get_tree().node_added.connect(_node_added)

func _node_added(node: Node) -> void:
	if node is Control and not _queued:
		_queued = true
		_refresh.call_deferred()

func _refresh() -> void:
	_queued = false
	var scene := get_tree().current_scene
	if scene != null and not str(scene.scene_file_path).contains("/minigames/"):
		_style(scene)

func _style(node: Node) -> void:
	if node.has_meta("wonder_custom"):
		return
	if node is Button:
		UI.button(node, "Play" in str(node.name) or "Confirm" in str(node.name))
	elif node is PanelContainer:
		node.add_theme_stylebox_override("panel", UI.panel(UI.INK, Color("536b85"), 28, 12))
	elif node is Label:
		node.add_theme_color_override("font_color", UI.GOLD if "Coin" in str(node.name) else UI.CREAM)
	elif node is ProgressBar:
		node.add_theme_stylebox_override("background", UI.panel(Color("1c2a3e"), Color("425874"), 14, 0))
		node.add_theme_stylebox_override("fill", UI.panel(UI.MINT, UI.MINT, 14, 0))
	for child in node.get_children():
		_style(child)
