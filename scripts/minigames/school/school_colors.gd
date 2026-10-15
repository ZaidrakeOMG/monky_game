extends Control

## Minijuego educativo "Colores Mágicos" para La Escuelita de Wonky.
## Los niños aprenden y reconocen los colores jugando con manchas de pintura y objetos coloridos.

const UI := preload("res://scripts/ui/wonder_ui.gd")

const COLORS_DATA := {
	"rojo": {
		"name": "ROJO",
		"color": Color("#FF4757"),
		"text_color": Color("#FFFFFF"),
		"emoji": "🔴",
		"phrase": "¡Como una fresa roja!"
	},
	"azul": {
		"name": "AZUL",
		"color": Color("#2E86DE"),
		"text_color": Color("#FFFFFF"),
		"emoji": "🔵",
		"phrase": "¡Como el cielo y el mar!"
	},
	"amarillo": {
		"name": "AMARILLO",
		"color": Color("#FFD32A"),
		"text_color": Color("#3B2900"),
		"emoji": "🟡",
		"phrase": "¡Brillante como el sol!"
	},
	"verde": {
		"name": "VERDE",
		"color": Color("#2ED573"),
		"text_color": Color("#003814"),
		"emoji": "🟢",
		"phrase": "¡Fresco como una hojita!"
	},
	"naranja": {
		"name": "NARANJA",
		"color": Color("#FFA502"),
		"text_color": Color("#3B1D00"),
		"emoji": "🟠",
		"phrase": "¡Dulce como una naranja!"
	},
	"morado": {
		"name": "MORADO",
		"color": Color("#8854D0"),
		"text_color": Color("#FFFFFF"),
		"emoji": "🟣",
		"phrase": "¡Mágico como las uvas!"
	},
	"rosa": {
		"name": "ROSA",
		"color": Color("#FF78B9"),
		"text_color": Color("#FFFFFF"),
		"emoji": "🌸",
		"phrase": "¡Suave como una flor!"
	}
}

var gm: Node = null
var current_target: String = ""
var is_round_transition: bool = false
var stars_earned: int = 0

var sfx_player: AudioStreamPlayer = null
var coins_label: Label = null
var stars_label: Label = null
var banner_label: Label = null
var target_display: Control = null
var target_color_rect: Panel = null
var target_emoji_label: Label = null
var target_name_label: Label = null
var color_buttons: Array[Button] = []
var cards_grid: GridContainer = null

func _ready() -> void:
	gm = get_tree().root.get_node_or_null("GameManager")
	set_meta("wonder_custom", true)
	if AudioManager:
		AudioManager.set_music_volume_db(-18.0, 0.4)
	_setup_audio()
	_build_ui()
	_start_new_round()

func _exit_tree() -> void:
	if AudioManager:
		AudioManager.set_music_volume_db(AudioManager.DEFAULT_MUSIC_DB, 0.4)

func _setup_audio() -> void:
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "Master"
	sfx_player.volume_db = 1.0
	add_child(sfx_player)

func _build_ui() -> void:
	# Fondo de pizarra escolar
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#1C3329")
	add_child(bg)

	var frame_vignette := TextureRect.new()
	frame_vignette.texture = UI.gradient(Color(0.06, 0.14, 0.10, 0.85), Color(0.10, 0.20, 0.15, 0.35))
	frame_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame_vignette)

	# Borde de madera
	var board_frame := Panel.new()
	board_frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	board_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var frame_st := StyleBoxFlat.new()
	frame_st.bg_color = Color(0, 0, 0, 0)
	frame_st.border_color = Color("#8B5226")
	frame_st.set_border_width_all(20)
	frame_st.set_corner_radius_all(24)
	board_frame.add_theme_stylebox_override("panel", frame_st)
	add_child(board_frame)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_right"]:
		margin.add_theme_constant_override(side, 38)
	margin.add_theme_constant_override("margin_top", 44)
	margin.add_theme_constant_override("margin_bottom", 44)
	add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 22)
	margin.add_child(layout)

	# 1. Cabecera
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 18)
	layout.add_child(header)

	var btn_back := Button.new()
	btn_back.name = "BtnBack"
	btn_back.text = "‹"
	btn_back.custom_minimum_size = Vector2(92, 92)
	btn_back.focus_mode = Control.FOCUS_NONE
	var b_st := StyleBoxFlat.new()
	b_st.bg_color = Color("#4A2810")
	b_st.border_color = Color("#D9A84E")
	b_st.set_border_width_all(3)
	b_st.set_corner_radius_all(20)
	btn_back.add_theme_stylebox_override("normal", b_st)
	btn_back.add_theme_stylebox_override("hover", b_st)
	btn_back.add_theme_stylebox_override("pressed", b_st)
	btn_back.add_theme_font_size_override("font_size", 64)
	btn_back.add_theme_color_override("font_color", Color("#FFF0C8"))
	UIEffects.bind_button(btn_back)
	btn_back.pressed.connect(_on_back_pressed)
	header.add_child(btn_back)

	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_theme_constant_override("separation", -4)
	header.add_child(title_box)

	var title_lbl := Label.new()
	title_lbl.text = "COLORES MÁGICOS"
	title_lbl.add_theme_font_size_override("font_size", 38)
	title_lbl.add_theme_color_override("font_color", Color("#FFF5DF"))
	title_box.add_child(title_lbl)

	var sub_lbl := Label.new()
	sub_lbl.text = "TALLER DE PINTURA DE WONKY"
	sub_lbl.add_theme_font_size_override("font_size", 20)
	sub_lbl.add_theme_color_override("font_color", Color("#7BF8A6"))
	title_box.add_child(sub_lbl)

	var stats_box := HBoxContainer.new()
	stats_box.add_theme_constant_override("separation", 14)
	header.add_child(stats_box)

	var stars_panel := PanelContainer.new()
	var stars_st := StyleBoxFlat.new()
	stars_st.bg_color = Color("#1D2B24", 0.90)
	stars_st.border_color = Color("#F5B942")
	stars_st.set_border_width_all(2)
	stars_st.set_corner_radius_all(18)
	stars_st.content_margin_left = 16
	stars_st.content_margin_right = 16
	stars_panel.add_theme_stylebox_override("panel", stars_st)
	stats_box.add_child(stars_panel)

	stars_label = Label.new()
	stars_label.text = "⭐ 0"
	stars_label.add_theme_font_size_override("font_size", 28)
	stars_label.add_theme_color_override("font_color", Color("#FFE599"))
	stars_panel.add_child(stars_label)

	var coins_panel := PanelContainer.new()
	var coins_st := StyleBoxFlat.new()
	coins_st.bg_color = Color("#321C12", 0.92)
	coins_st.border_color = Color("#F5B942")
	coins_st.set_border_width_all(2)
	coins_st.set_corner_radius_all(18)
	coins_st.content_margin_left = 16
	coins_st.content_margin_right = 16
	coins_panel.add_theme_stylebox_override("panel", coins_st)
	stats_box.add_child(coins_panel)

	coins_label = Label.new()
	coins_label.text = "🪙 " + str(gm.coins if gm else 0)
	coins_label.add_theme_font_size_override("font_size", 28)
	coins_label.add_theme_color_override("font_color", Color("#FFF0C8"))
	coins_panel.add_child(coins_label)

	# 2. Lienzo / Tarjeta central de exhibición del color
	var canvas_card := PanelContainer.new()
	canvas_card.custom_minimum_size.y = 350
	canvas_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var cc_style := StyleBoxFlat.new()
	cc_style.bg_color = Color("#13241C", 0.95)
	cc_style.border_color = Color("#D9A84E")
	cc_style.set_border_width_all(3)
	cc_style.set_corner_radius_all(24)
	cc_style.content_margin_top = 20
	cc_style.content_margin_bottom = 20
	cc_style.content_margin_left = 24
	cc_style.content_margin_right = 24
	canvas_card.add_theme_stylebox_override("panel", cc_style)
	layout.add_child(canvas_card)

	var canvas_inner := VBoxContainer.new()
	canvas_inner.alignment = BoxContainer.ALIGNMENT_CENTER
	canvas_inner.add_theme_constant_override("separation", 16)
	canvas_card.add_child(canvas_inner)

	banner_label = Label.new()
	banner_label.text = "¡Toca el color correcto!"
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.add_theme_font_size_override("font_size", 28)
	banner_label.add_theme_color_override("font_color", Color("#FFF9EA"))
	banner_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	canvas_inner.add_child(banner_label)

	# Círculo central grande de pintura
	target_color_rect = Panel.new()
	target_color_rect.custom_minimum_size = Vector2(170, 170)
	target_color_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var splash_st := StyleBoxFlat.new()
	splash_st.set_corner_radius_all(85)
	splash_st.border_color = Color("#FFFFFF")
	splash_st.set_border_width_all(6)
	splash_st.shadow_size = 14
	splash_st.shadow_color = Color(0, 0, 0, 0.4)
	target_color_rect.add_theme_stylebox_override("panel", splash_st)
	canvas_inner.add_child(target_color_rect)

	target_name_label = Label.new()
	target_name_label.text = "¿QUÉ COLOR ES?"
	target_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	target_name_label.add_theme_font_size_override("font_size", 34)
	target_name_label.add_theme_color_override("font_color", Color("#FFD97D"))
	canvas_inner.add_child(target_name_label)

	# 3. Cuadrícula de opciones de colores (2x2 botones grandes)
	cards_grid = GridContainer.new()
	cards_grid.columns = 2
	cards_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cards_grid.add_theme_constant_override("h_separation", 28)
	cards_grid.add_theme_constant_override("v_separation", 28)
	layout.add_child(cards_grid)

	for i in range(4):
		var btn := _create_color_button(i)
		cards_grid.add_child(btn)
		color_buttons.append(btn)

func _create_color_button(index: int) -> Button:
	var btn := Button.new()
	btn.name = "ColorButton_" + str(index)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(440, 480)
	btn.focus_mode = Control.FOCUS_NONE

	var c_style := StyleBoxFlat.new()
	c_style.bg_color = Color("#FAF3E0")
	c_style.border_color = Color("#8B5226")
	c_style.set_border_width_all(4)
	c_style.set_corner_radius_all(26)
	c_style.shadow_color = Color(0, 0, 0, 0.35)
	c_style.shadow_size = 8
	btn.add_theme_stylebox_override("normal", c_style)
	btn.add_theme_stylebox_override("hover", c_style)
	btn.add_theme_stylebox_override("pressed", c_style)
	UIEffects.bind_button(btn)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(vbox)

	# Mancha / Bote de pintura circular
	var jar := Panel.new()
	jar.name = "ColorJar"
	jar.custom_minimum_size = Vector2(230, 230)
	jar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var j_st := StyleBoxFlat.new()
	j_st.set_corner_radius_all(115)
	j_st.border_color = Color("#FAF3E0")
	j_st.set_border_width_all(8)
	j_st.shadow_size = 10
	j_st.shadow_color = Color(0, 0, 0, 0.25)
	jar.add_theme_stylebox_override("panel", j_st)
	jar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(jar)

	var name_label := Label.new()
	name_label.name = "ColorName"
	name_label.text = "COLOR"
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 38)
	name_label.add_theme_color_override("font_color", Color("#3D2314"))
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_label)

	btn.pressed.connect(func(): _on_color_selected(btn))
	return btn

func _start_new_round() -> void:
	is_round_transition = false
	var all_keys: Array = COLORS_DATA.keys()
	all_keys.shuffle()
	current_target = str(all_keys[0])

	var target_info: Dictionary = COLORS_DATA[current_target]

	# Actualizar lienzo central
	var splash_st := target_color_rect.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	splash_st.bg_color = target_info["color"]
	target_color_rect.add_theme_stylebox_override("panel", splash_st)

	banner_label.text = "¿Cuál de estas pinturas es de color..."
	banner_label.add_theme_color_override("font_color", Color("#FFF9EA"))
	target_name_label.text = "¡" + str(target_info["name"]) + "!"
	target_name_label.add_theme_color_override("font_color", target_info["color"].lightened(0.2))

	# Pulso suave en la muestra de color
	var pulse := create_tween()
	pulse.tween_property(target_color_rect, "scale", Vector2(1.12, 1.12), 0.15).set_trans(Tween.TRANS_QUAD)
	pulse.tween_property(target_color_rect, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BOUNCE)

	# Seleccionar 4 candidatos (1 correcto + 3 distractores)
	var choices: Array = [current_target]
	for k in all_keys:
		if k != current_target and choices.size() < 4:
			choices.append(k)
	choices.shuffle()

	for i in range(4):
		var btn: Button = color_buttons[i]
		var col_id: String = str(choices[i])
		var col_data: Dictionary = COLORS_DATA[col_id]

		btn.set_meta("color_id", col_id)
		btn.disabled = false
		btn.modulate = Color.WHITE

		var default_style := StyleBoxFlat.new()
		default_style.bg_color = Color("#FAF3E0")
		default_style.border_color = Color("#8B5226")
		default_style.set_border_width_all(4)
		default_style.set_corner_radius_all(26)
		btn.add_theme_stylebox_override("normal", default_style)
		btn.add_theme_stylebox_override("hover", default_style)

		var jar := btn.find_child("ColorJar", true, false) as Panel
		if jar:
			var j_st := StyleBoxFlat.new()
			j_st.bg_color = col_data["color"]
			j_st.border_color = Color("#FAF3E0")
			j_st.set_border_width_all(8)
			j_st.set_corner_radius_all(115)
			j_st.shadow_size = 10
			j_st.shadow_color = Color(0, 0, 0, 0.25)
			jar.add_theme_stylebox_override("panel", j_st)

		var lbl := btn.find_child("ColorName", true, false) as Label
		if lbl:
			lbl.text = str(col_data["name"])

func _on_color_selected(btn: Button) -> void:
	if is_round_transition:
		return
	var chosen_id: String = str(btn.get_meta("color_id", ""))
	if chosen_id == current_target:
		_handle_correct(btn)
	else:
		_handle_incorrect(btn)

func _handle_correct(btn: Button) -> void:
	is_round_transition = true
	stars_earned += 1
	stars_label.text = "⭐ " + str(stars_earned)

	if gm:
		gm.add_coins(10)
		gm.add_xp(5)
		gm.save_game()
		coins_label.text = "🪙 " + str(gm.coins)

	if ResourceLoader.exists("res://audio/sfx/ui/buy_success.ogg"):
		sfx_player.stream = load("res://audio/sfx/ui/buy_success.ogg")
		sfx_player.play()

	var target_info: Dictionary = COLORS_DATA[current_target]
	banner_label.text = "¡EXCELENTE! " + str(target_info["phrase"])
	banner_label.add_theme_color_override("font_color", Color("#7BF8A6"))

	var win_style := StyleBoxFlat.new()
	win_style.bg_color = Color("#E3FFDA")
	win_style.border_color = Color("#2E9E5B")
	win_style.set_border_width_all(6)
	win_style.set_corner_radius_all(26)
	win_style.shadow_color = Color(0.2, 0.8, 0.4, 0.5)
	win_style.shadow_size = 14
	btn.add_theme_stylebox_override("normal", win_style)
	btn.add_theme_stylebox_override("hover", win_style)

	var tw := create_tween()
	tw.tween_property(btn, "scale", Vector2(1.08, 1.08), 0.15).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(btn, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BOUNCE)

	get_tree().create_timer(1.8).timeout.connect(func():
		if is_inside_tree():
			_start_new_round()
	)

func _handle_incorrect(btn: Button) -> void:
	var tw := create_tween()
	tw.tween_property(btn, "rotation", deg_to_rad(4.0), 0.08)
	tw.tween_property(btn, "rotation", deg_to_rad(-4.0), 0.08)
	tw.tween_property(btn, "rotation", 0.0, 0.08)

	banner_label.text = "¡Casi! Observa con cuidado el color 🎨"
	banner_label.add_theme_color_override("font_color", Color("#FFD97D"))

	if AudioManager:
		AudioManager.play_pop()

func _on_back_pressed() -> void:
	if AudioManager:
		AudioManager.set_music_volume_db(AudioManager.DEFAULT_MUSIC_DB, 0.4)
	if not SceneRouter.busy:
		SceneRouter.go("res://scenes/minigames/minigames_menu.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
		get_viewport().set_input_as_handled()
