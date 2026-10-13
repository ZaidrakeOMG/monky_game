extends RefCounted
## Shared presentation only. Never changes save data, prices or gameplay rules.

const INK := Color("15233e")
const PANEL := Color("203451")
const CREAM := Color("fff7e7")
const MUTED := Color("bacce0")
const GOLD := Color("ffd36b")
const MINT := Color("8bf0bc")

static func panel(fill: Color = PANEL, edge: Color = Color("486080"), radius: int = 28, padding: int = 20) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = edge
	box.set_border_width_all(2)
	box.set_corner_radius_all(radius)
	box.content_margin_left = padding
	box.content_margin_right = padding
	box.content_margin_top = padding
	box.content_margin_bottom = padding
	box.shadow_color = Color(0.02, 0.05, 0.12, 0.25)
	box.shadow_size = 8
	box.shadow_offset = Vector2(0, 5)
	return box

static func button(control: Button, primary: bool = false) -> void:
	var fill := GOLD if primary else PANEL
	var edge := Color("ffe9a9") if primary else Color("587595")
	control.add_theme_stylebox_override("normal", panel(fill, edge, 24, 16))
	control.add_theme_stylebox_override("hover", panel(fill.lightened(0.10), edge.lightened(0.15), 24, 16))
	control.add_theme_stylebox_override("pressed", panel(fill.darkened(0.16), edge, 24, 16))
	control.add_theme_stylebox_override("disabled", panel(Color("35445b"), Color("536178"), 24, 16))
	var focus := panel(Color.TRANSPARENT, MINT, 24, 16)
	focus.set_border_width_all(4)
	focus.shadow_size = 0
	control.add_theme_stylebox_override("focus", focus)
	var text_color := INK if primary else CREAM
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		control.add_theme_color_override(state, text_color)
	control.add_theme_color_override("font_disabled_color", MUTED)
	control.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	control.add_theme_constant_override("outline_size", 0)

static func text(value: String, font_size: int = 36, color: Color = CREAM) -> Label:
	var label := Label.new()
	label.text = value
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

static func texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null

static func gradient(top: Color, bottom: Color, horizontal: bool = false) -> GradientTexture2D:
	var colors := Gradient.new()
	colors.colors = PackedColorArray([top, bottom])
	var image := GradientTexture2D.new()
	image.gradient = colors
	image.width = 32
	image.height = 256
	image.fill_from = Vector2.ZERO
	image.fill_to = Vector2.RIGHT if horizontal else Vector2.DOWN
	return image

static func full_rect(control: Control, parent: Node) -> void:
	parent.add_child(control)
	control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE

static func skin_hud(root: Node) -> void:
	for child in root.get_children():
		if child is PanelContainer:
			child.add_theme_stylebox_override("panel", panel())
		elif child is Button:
			button(child, "Restart" in str(child.name) or "Play" in str(child.name))
		elif child is Label:
			child.add_theme_color_override("font_color", GOLD if "Coin" in str(child.name) else CREAM)
			child.add_theme_color_override("font_outline_color", INK)
			child.add_theme_constant_override("outline_size", 0)
		skin_hud(child)

static func cover(sprite: Sprite2D) -> void:
	if sprite.texture == null:
		return
	var dimensions := sprite.texture.get_size()
	if dimensions.x <= 0.0 or dimensions.y <= 0.0:
		return
	sprite.scale = Vector2.ONE * maxf(1080.0 / dimensions.x, 1920.0 / dimensions.y)
	sprite.position = Vector2(540, 960)
