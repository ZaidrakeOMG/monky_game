extends Control

## Minijuego educativo "Formas Mágicas" para La Escuelita de Wonky.
## Los niños aprenden y reconocen figuras geométricas mediante ilustraciones estilo sticker kawaii.

const UI := preload("res://scripts/ui/wonder_ui.gd")

const SHAPES_DATA := {
	"circulo": {
		"name": "CÍRCULO",
		"icon": "res://imagenes/escuela/formas/circulo.png",
		"color": Color("#F5B942"),
		"phrase": "¡Redondo como el sol!"
	},
	"cuadrado": {
		"name": "CUADRADO",
		"icon": "res://imagenes/escuela/formas/cuadrado.png",
		"color": Color("#4A90E2"),
		"phrase": "¡Con 4 lados iguales!"
	},
	"triangulo": {
		"name": "TRIÁNGULO",
		"icon": "res://imagenes/escuela/formas/triangulo.png",
		"color": Color("#FF7A36"),
		"phrase": "¡Con 3 puntitas divertidas!"
	},
	"estrella": {
		"name": "ESTRELLA",
		"icon": "res://imagenes/escuela/formas/estrella.png",
		"color": Color("#FFD93D"),
		"phrase": "¡Brillante en el cielo!"
	},
	"corazon": {
		"name": "CORAZÓN",
		"icon": "res://imagenes/escuela/formas/corazon.png",
		"color": Color("#FF6584"),
		"phrase": "¡Lleno de amor y cariño!"
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
var target_label: Label = null
var target_icon: TextureRect = null
var card_buttons: Array[Button] = []
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
	bg.color = Color("#1A3026")
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
	title_lbl.text = "FORMAS MÁGICAS"
	title_lbl.add_theme_font_size_override("font_size", 38)
	title_lbl.add_theme_color_override("font_color", Color("#FFF5DF"))
	title_box.add_child(title_lbl)

	var sub_lbl := Label.new()
	sub_lbl.text = "FIGURAS GEOMÉTRICAS"
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

	# 2. Tarjeta interactiva de pregunta
	var question_card := PanelContainer.new()
	question_card.custom_minimum_size.y = 350
	question_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var qc_style := StyleBoxFlat.new()
	qc_style.bg_color = Color("#13241C", 0.95)
	qc_style.border_color = Color("#D9A84E")
	qc_style.set_border_width_all(3)
	qc_style.set_corner_radius_all(24)
	qc_style.content_margin_top = 20
	qc_style.content_margin_bottom = 20
	qc_style.content_margin_left = 24
	qc_style.content_margin_right = 24
	question_card.add_theme_stylebox_override("panel", qc_style)
	layout.add_child(question_card)

	var qc_inner := VBoxContainer.new()
	qc_inner.alignment = BoxContainer.ALIGNMENT_CENTER
	qc_inner.add_theme_constant_override("separation", 14)
	question_card.add_child(qc_inner)

	banner_label = Label.new()
	banner_label.text = "¿Dónde está la forma..."
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.add_theme_font_size_override("font_size", 28)
	banner_label.add_theme_color_override("font_color", Color("#FFF9EA"))
	qc_inner.add_child(banner_label)

	target_icon = TextureRect.new()
	target_icon.custom_minimum_size = Vector2(160, 160)
	target_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	target_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	target_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	qc_inner.add_child(target_icon)

	target_label = Label.new()
	target_label.text = "¡FORMA!"
	target_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	target_label.add_theme_font_size_override("font_size", 36)
	target_label.add_theme_color_override("font_color", Color("#FFD97D"))
	qc_inner.add_child(target_label)

	# 3. Cuadrícula de opciones: 4 tarjetas de formas (2x2)
	cards_grid = GridContainer.new()
	cards_grid.columns = 2
	cards_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cards_grid.add_theme_constant_override("h_separation", 28)
	cards_grid.add_theme_constant_override("v_separation", 28)
	layout.add_child(cards_grid)

	for i in range(4):
		var card := _create_shape_card(i)
		cards_grid.add_child(card)
		card_buttons.append(card)

func _create_shape_card(index: int) -> Button:
	var btn := Button.new()
	btn.name = "ShapeCard_" + str(index)
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
	vbox.add_theme_constant_override("separation", 12)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(vbox)

	var icon_rect := TextureRect.new()
	icon_rect.name = "ShapeIcon"
	icon_rect.custom_minimum_size = Vector2(330, 330)
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(icon_rect)

	var name_label := Label.new()
	name_label.name = "ShapeName"
	name_label.text = "FORMA"
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 34)
	name_label.add_theme_color_override("font_color", Color("#4A2613"))
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_label)

	btn.pressed.connect(func(): _on_shape_selected(btn))
	return btn

func _start_new_round() -> void:
	is_round_transition = false
	var all_keys: Array = SHAPES_DATA.keys()
	all_keys.shuffle()
	current_target = str(all_keys[0])

	var target_data: Dictionary = SHAPES_DATA[current_target]

	banner_label.text = "¿Dónde está la forma..."
	banner_label.add_theme_color_override("font_color", Color("#FFF9EA"))
	target_label.text = "¡" + str(target_data["name"]) + "!"
	target_label.add_theme_color_override("font_color", target_data["color"])

	if ResourceLoader.exists(target_data["icon"]):
		target_icon.texture = load(target_data["icon"]) as Texture2D

	var pulse := create_tween()
	pulse.tween_property(target_icon, "scale", Vector2(1.15, 1.15), 0.15).set_trans(Tween.TRANS_QUAD)
	pulse.tween_property(target_icon, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BOUNCE)

	# Seleccionar 4 candidatos (1 correcto + 3 distractores)
	var choices: Array = [current_target]
	for k in all_keys:
		if k != current_target and choices.size() < 4:
			choices.append(k)
	choices.shuffle()

	for i in range(4):
		var card: Button = card_buttons[i]
		var shape_id: String = str(choices[i])
		var data: Dictionary = SHAPES_DATA[shape_id]

		card.set_meta("shape_id", shape_id)
		card.disabled = false
		card.modulate = Color.WHITE

		var default_style := StyleBoxFlat.new()
		default_style.bg_color = Color("#FAF3E0")
		default_style.border_color = Color("#8B5226")
		default_style.set_border_width_all(4)
		default_style.set_corner_radius_all(26)
		card.add_theme_stylebox_override("normal", default_style)
		card.add_theme_stylebox_override("hover", default_style)

		var icon := card.find_child("ShapeIcon", true, false) as TextureRect
		if icon:
			if ResourceLoader.exists(data["icon"]):
				icon.texture = load(data["icon"]) as Texture2D

		var lbl := card.find_child("ShapeName", true, false) as Label
		if lbl:
			lbl.text = str(data["name"])

func _on_shape_selected(card: Button) -> void:
	if is_round_transition:
		return
	var chosen_id: String = str(card.get_meta("shape_id", ""))
	if chosen_id == current_target:
		_handle_correct(card)
	else:
		_handle_incorrect(card)

func _handle_correct(card: Button) -> void:
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

	var target_data: Dictionary = SHAPES_DATA[current_target]
	banner_label.text = "¡EXCELENTE! " + str(target_data["phrase"])
	banner_label.add_theme_color_override("font_color", Color("#7BF8A6"))

	var win_style := StyleBoxFlat.new()
	win_style.bg_color = Color("#E3FFDA")
	win_style.border_color = Color("#2E9E5B")
	win_style.set_border_width_all(6)
	win_style.set_corner_radius_all(26)
	win_style.shadow_color = Color(0.2, 0.8, 0.4, 0.5)
	win_style.shadow_size = 14
	card.add_theme_stylebox_override("normal", win_style)
	card.add_theme_stylebox_override("hover", win_style)

	var tw := create_tween()
	tw.tween_property(card, "scale", Vector2(1.08, 1.08), 0.15).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(card, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BOUNCE)

	get_tree().create_timer(1.8).timeout.connect(func():
		if is_inside_tree():
			_start_new_round()
	)

func _handle_incorrect(card: Button) -> void:
	var tw := create_tween()
	tw.tween_property(card, "rotation", deg_to_rad(4.0), 0.08)
	tw.tween_property(card, "rotation", deg_to_rad(-4.0), 0.08)
	tw.tween_property(card, "rotation", 0.0, 0.08)

	banner_label.text = "¡Casi! Observa bien la forma y vuelve a intentar ✨"
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
