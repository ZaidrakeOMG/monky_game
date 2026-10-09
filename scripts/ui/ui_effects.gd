class_name UIEffects
extends RefCounted

## One owner-bound tween per animation channel. Never leaves old callbacks alive.
static func tween_for(node: Node, channel: String) -> Tween:
	var key := "_monky_tween_" + channel
	if node.has_meta(key):
		var previous: Tween = node.get_meta(key)
		if previous != null and previous.is_valid():
			previous.kill()
	var tween := node.create_tween()
	node.set_meta(key, tween)
	return tween

static func cancel(node: Node, channel: String) -> void:
	var key := "_monky_tween_" + channel
	if node.has_meta(key):
		var previous: Tween = node.get_meta(key)
		if previous != null and previous.is_valid():
			previous.kill()
		node.remove_meta(key)

static func set_text(label: Label, value: String) -> void:
	if label != null and label.text != value:
		label.text = value

static func bind_button(button: BaseButton) -> void:
	button.focus_mode = Control.FOCUS_ALL
	var focus := StyleBoxFlat.new()
	focus.bg_color = Color(0, 0, 0, 0)
	focus.border_color = Color("#FACB68")
	focus.set_border_width_all(3)
	focus.set_corner_radius_all(16)
	button.add_theme_stylebox_override("focus", focus)
	if button.has_meta("monky_feedback"):
		return
	button.set_meta("monky_feedback", true)
	button.button_down.connect(func(): _press(button, true))
	button.button_up.connect(func(): _press(button, false))
	button.mouse_exited.connect(func(): _press(button, false))
	button.pressed.connect(func():
		if not button.disabled:
			AudioManager.play_click()
			if GameManager.vibration_enabled and OS.has_feature("mobile"):
				Input.vibrate_handheld(12)
	)

static func _press(button: Control, pressed: bool) -> void:
	if not is_instance_valid(button) or not button.is_inside_tree():
		return
	button.pivot_offset = button.size * 0.5
	var target := Vector2.ONE * (0.96 if pressed else 1.0)
	if GameManager.reduced_effects:
		cancel(button, "press")
		button.scale = Vector2.ONE
	else:
		var tween := tween_for(button, "press")
		tween.tween_property(button, "scale", target, 0.09).set_trans(Tween.TRANS_QUAD)

static func popup(popup_root: Control, opened: bool) -> void:
	var panel := popup_root.get_node_or_null("Panel") as Control
	if panel == null:
		popup_root.visible = opened
		return
	var tween := tween_for(panel, "popup")
	if opened:
		popup_root.show()
		panel.pivot_offset = panel.size * 0.5
		panel.modulate.a = 1.0
		panel.scale = Vector2.ONE * (1.0 if GameManager.reduced_effects else 0.96)
		tween.tween_property(panel, "scale", Vector2.ONE, 0.16)
	else:
		tween.tween_property(panel, "modulate:a", 0.0, 0.10)
		tween.tween_callback(func():
			popup_root.hide()
			panel.modulate.a = 1.0
			panel.scale = Vector2.ONE
		)
