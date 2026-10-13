extends Control
## Input-blocking, keyboard-accessible start/pause sheet. The game owns pause state.

signal primary_pressed
signal secondary_pressed
const UI := preload("res://scripts/ui/wonder_ui.gd")
var primary_button: Button

func build(title: String, instructions: String, action: String) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 80
	set_meta("wonder_custom", true)
	var shade := ColorRect.new()
	shade.color = Color(0.025, 0.055, 0.12, 0.76)
	UI.full_rect(shade, self)
	var center := CenterContainer.new()
	UI.full_rect(center, self)
	var sheet := PanelContainer.new()
	sheet.custom_minimum_size = Vector2(820, 0)
	sheet.add_theme_stylebox_override("panel", UI.panel(UI.INK, UI.MINT, 40, 48))
	center.add_child(sheet)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 30)
	sheet.add_child(stack)
	var eyebrow := UI.text("WONKY ARCADE", 26, UI.MINT)
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stack.add_child(eyebrow)
	var heading := UI.text(title, 66)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stack.add_child(heading)
	var body := UI.text(instructions, 34, UI.MUTED)
	body.custom_minimum_size.x = 710
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stack.add_child(body)
	primary_button = Button.new()
	primary_button.text = action
	primary_button.custom_minimum_size.y = 120
	primary_button.add_theme_font_size_override("font_size", 40)
	UI.button(primary_button, true)
	stack.add_child(primary_button)
	primary_button.pressed.connect(func(): primary_pressed.emit())
	var back := Button.new()
	back.text = "Volver a minijuegos"
	back.custom_minimum_size.y = 112
	back.add_theme_font_size_override("font_size", 34)
	UI.button(back)
	stack.add_child(back)
	back.pressed.connect(func(): secondary_pressed.emit())
	visibility_changed.connect(_focus_primary)

func _focus_primary() -> void:
	if visible and is_instance_valid(primary_button):
		primary_button.grab_focus.call_deferred()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch or event is InputEventScreenDrag:
		accept_event()
