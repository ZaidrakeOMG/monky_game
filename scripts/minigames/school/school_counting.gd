extends Control

## Minijuego educativo "Contando con Wonky" para La Escuelita.
## Los niños aprenden los números del 1 al 5 contando frutas interactivas con Wonky.

const UI := preload("res://scripts/ui/wonder_ui.gd")

const FRUITS := [
	{"name": "manzanas", "icon": "res://imagenes/ui_polished/alimentos/manzana.png", "singular": "manzana"},
	{"name": "fresas", "icon": "res://imagenes/ui_polished/alimentos/fresa.png", "singular": "fresa"},
	{"name": "plátanos", "icon": "res://imagenes/ui_polished/alimentos/platano.png", "singular": "plátano"},
	{"name": "sandías", "icon": "res://imagenes/ui_polished/alimentos/sandia.png", "singular": "sandía"}
]

const NUMBER_COLORS := {
	1: Color("#3498DB"),
	2: Color("#2ECC71"),
	3: Color("#F1C40F"),
	4: Color("#E67E22"),
	5: Color("#9B59B6")
}

var gm: Node = null
var target_count: int = 1
var current_fruit_idx: int = 0
var is_round_transition: bool = false
var stars_earned: int = 0
var counted_fruits: Array[int] = []

var sfx_player: AudioStreamPlayer = null
var coins_label: Label = null
var stars_label: Label = null
var banner_label: Label = null
var fruits_container: HBoxContainer = null
var number_buttons: Array[Button] = []

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
	bg.color = Color("#1E332B")
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
	layout.add_theme_constant_override("separation", 24)
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
	title_lbl.text = "CONTANDO CON WONKY"
	title_lbl.add_theme_font_size_override("font_size", 36)
	title_lbl.add_theme_color_override("font_color", Color("#FFF5DF"))
	title_box.add_child(title_lbl)

	var sub_lbl := Label.new()
	sub_lbl.text = "NÚMEROS Y CANTIDADES (1 AL 5)"
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

	# 2. Mesa interactiva de frutas
	var table_card := PanelContainer.new()
	table_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	table_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var tc_style := StyleBoxFlat.new()
	tc_style.bg_color = Color("#152720", 0.95)
	tc_style.border_color = Color("#D9A84E")
	tc_style.set_border_width_all(3)
	tc_style.set_corner_radius_all(24)
	tc_style.content_margin_top = 28
	tc_style.content_margin_bottom = 28
	tc_style.content_margin_left = 24
	tc_style.content_margin_right = 24
	table_card.add_theme_stylebox_override("panel", tc_style)
	layout.add_child(table_card)

	var table_inner := VBoxContainer.new()
	table_inner.alignment = BoxContainer.ALIGNMENT_CENTER
	table_inner.add_theme_constant_override("separation", 24)
	table_card.add_child(table_inner)

	banner_label = Label.new()
	banner_label.text = "¡Toca y cuenta las frutas con tu dedo!"
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.add_theme_font_size_override("font_size", 34)
	banner_label.add_theme_color_override("font_color", Color("#FFF9EA"))
	banner_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	table_inner.add_child(banner_label)

	var hint_lbl := Label.new()
	hint_lbl.text = "¡Toca cada fruta para contarla!"
	hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_lbl.add_theme_font_size_override("font_size", 22)
	hint_lbl.add_theme_color_override("font_color", Color("#B0CDBC"))
	table_inner.add_child(hint_lbl)

	# Contenedor central de frutas
	var center_wrap := CenterContainer.new()
	center_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_wrap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	table_inner.add_child(center_wrap)

	fruits_container = HBoxContainer.new()
	fruits_container.alignment = BoxContainer.ALIGNMENT_CENTER
	fruits_container.add_theme_constant_override("separation", 18)
	center_wrap.add_child(fruits_container)

	# 3. Fila de botones con los números del 1 al 5
	var numbers_title := Label.new()
	numbers_title.text = "¿CUÁNTAS FRUTAS HAY EN TOTAL?"
	numbers_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	numbers_title.add_theme_font_size_override("font_size", 28)
	numbers_title.add_theme_color_override("font_color", Color("#FFD97D"))
	layout.add_child(numbers_title)

	var numbers_grid := GridContainer.new()
	numbers_grid.columns = 5
	numbers_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	numbers_grid.custom_minimum_size.y = 230
	numbers_grid.add_theme_constant_override("h_separation", 16)
	layout.add_child(numbers_grid)

	for num in range(1, 6):
		var btn := _create_number_button(num)
		numbers_grid.add_child(btn)
		number_buttons.append(btn)

func _create_number_button(num: int) -> Button:
	var btn := Button.new()
	btn.name = "NumberButton_" + str(num)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(150, 210)
	btn.focus_mode = Control.FOCUS_NONE
	btn.set_meta("number", num)

	var col: Color = NUMBER_COLORS.get(num, Color("#F5B942"))
	var btn_st := StyleBoxFlat.new()
	btn_st.bg_color = Color("#FAF3E0")
	btn_st.border_color = col
	btn_st.set_border_width_all(5)
	btn_st.set_corner_radius_all(22)
	btn_st.shadow_size = 8
	btn_st.shadow_color = Color(0, 0, 0, 0.3)
	btn.add_theme_stylebox_override("normal", btn_st)
	btn.add_theme_stylebox_override("hover", btn_st)
	btn.add_theme_stylebox_override("pressed", btn_st)
	UIEffects.bind_button(btn)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 2)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(vbox)

	var num_lbl := Label.new()
	num_lbl.name = "NumLabel"
	num_lbl.text = str(num)
	num_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	num_lbl.add_theme_font_size_override("font_size", 76)
	num_lbl.add_theme_color_override("font_color", col)
	num_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(num_lbl)

	const NUMBER_WORDS := {1: "UNO", 2: "DOS", 3: "TRES", 4: "CUATRO", 5: "CINCO"}
	var word_lbl := Label.new()
	word_lbl.text = NUMBER_WORDS.get(num, "")
	word_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	word_lbl.add_theme_font_size_override("font_size", 22)
	word_lbl.add_theme_color_override("font_color", Color("#5D4037"))
	word_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(word_lbl)

	btn.pressed.connect(func(): _on_number_selected(btn))
	return btn

func _start_new_round() -> void:
	is_round_transition = false
	counted_fruits.clear()

	# Elegir cantidad aleatoria de 1 a 5 (diferente a la anterior)
	var new_target := randi_range(1, 5)
	if new_target == target_count:
		new_target = (new_target % 5) + 1
	target_count = new_target

	current_fruit_idx = randi() % FRUITS.size()
	var fruit_data: Dictionary = FRUITS[current_fruit_idx]

	banner_label.text = "¿Cuántas " + str(fruit_data["name"]) + " hay?"
	banner_label.add_theme_color_override("font_color", Color("#FFF9EA"))

	# Limpiar frutas anteriores
	for child in fruits_container.get_children():
		child.queue_free()

	# Crear frutas táctiles interactivas
	for i in range(target_count):
		var fruit_btn := _create_interactive_fruit(i, fruit_data["icon"])
		fruits_container.add_child(fruit_btn)

	# Reset botones de números
	for btn in number_buttons:
		btn.disabled = false
		btn.modulate = Color.WHITE
		var num: int = int(btn.get_meta("number", 1))
		var col: Color = NUMBER_COLORS.get(num, Color("#F5B942"))
		var btn_st := StyleBoxFlat.new()
		btn_st.bg_color = Color("#FAF3E0")
		btn_st.border_color = col
		btn_st.set_border_width_all(5)
		btn_st.set_corner_radius_all(22)
		btn_st.shadow_size = 8
		btn_st.shadow_color = Color(0, 0, 0, 0.3)
		btn.add_theme_stylebox_override("normal", btn_st)

func _create_interactive_fruit(index: int, texture_path: String) -> Control:
	var wrapper := Control.new()
	wrapper.custom_minimum_size = Vector2(160, 180)

	var btn := TextureButton.new()
	btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	if ResourceLoader.exists(texture_path):
		btn.texture_normal = load(texture_path)
	btn.ignore_texture_size = true
	btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	UIEffects.bind_button(btn)
	wrapper.add_child(btn)

	# Insignia de conteo (aparece al tocar)
	var badge := PanelContainer.new()
	badge.name = "CountBadge"
	badge.custom_minimum_size = Vector2(56, 56)
	badge.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	badge.position = Vector2(100, 0)
	var b_st := StyleBoxFlat.new()
	b_st.bg_color = Color("#F5B942")
	b_st.border_color = Color("#FFFFFF")
	b_st.set_border_width_all(3)
	b_st.set_corner_radius_all(28)
	badge.add_theme_stylebox_override("panel", b_st)
	badge.visible = false
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrapper.add_child(badge)

	var badge_lbl := Label.new()
	badge_lbl.name = "BadgeLabel"
	badge_lbl.text = ""
	badge_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge_lbl.add_theme_font_size_override("font_size", 28)
	badge_lbl.add_theme_color_override("font_color", Color("#3D2314"))
	badge.add_child(badge_lbl)

	btn.pressed.connect(func():
		if not counted_fruits.has(index):
			counted_fruits.append(index)
			badge_lbl.text = str(counted_fruits.size())
			badge.visible = true
			if AudioManager:
				AudioManager.play_pop()
			var tw := create_tween()
			tw.tween_property(btn, "scale", Vector2(1.2, 1.2), 0.1)
			tw.tween_property(btn, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BOUNCE)
	)

	return wrapper

func _on_number_selected(btn: Button) -> void:
	if is_round_transition:
		return
	var num: int = int(btn.get_meta("number", 0))
	if num == target_count:
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

	var fruit_data: Dictionary = FRUITS[current_fruit_idx]
	var fruit_name: String = str(fruit_data["singular"] if target_count == 1 else fruit_data["name"])
	banner_label.text = "¡EXCELENTE! Hay " + str(target_count) + " " + fruit_name + " ⭐"
	banner_label.add_theme_color_override("font_color", Color("#7BF8A6"))

	var win_style := StyleBoxFlat.new()
	win_style.bg_color = Color("#E3FFDA")
	win_style.border_color = Color("#2E9E5B")
	win_style.set_border_width_all(6)
	win_style.set_corner_radius_all(22)
	win_style.shadow_color = Color(0.2, 0.8, 0.4, 0.5)
	win_style.shadow_size = 14
	btn.add_theme_stylebox_override("normal", win_style)

	var tw := create_tween()
	tw.tween_property(btn, "scale", Vector2(1.12, 1.12), 0.15).set_trans(Tween.TRANS_QUAD)
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

	banner_label.text = "¡Casi! Toca las frutas para contarlas una por una 🍎"
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
