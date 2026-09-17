extends Control

const STICKER_SHADER: Shader = preload("res://resources/ui_sticker.gdshader")

## Menú visual de minijuegos para Android.
## Usa botones grandes con imágenes y casi nada de texto.

@onready var background: Sprite2D = $Background
@onready var btn_back: Button = $HUD/TopBar/BtnBack
@onready var coins_label: Label = $HUD/TopBar/CoinsBox/CoinsLabel
@onready var title_box: Control = $HUD/TopBar/TitleBox

@onready var fruit_card: Control = $HUD/Scroll/VBox/CardFruit
@onready var flappy_card: Control = $HUD/Scroll/VBox/CardFlappy
@onready var jump_card: Control = $HUD/Scroll/VBox/CardJump
@onready var games_vbox: VBoxContainer = $HUD/Scroll/VBox

@onready var btn_play_fruit: Button = $HUD/Scroll/VBox/CardFruit/Margin/HBox/BtnPlayFruit
@onready var btn_play_flappy: Button = $HUD/Scroll/VBox/CardFlappy/Margin/HBox/BtnPlayFlappy
@onready var btn_play_jump: Button = $HUD/Scroll/VBox/CardJump/Margin/HBox/BtnPlayJump
var btn_play_runner: Button = null

var gm: Node = null

func _ready() -> void:
	gm = get_tree().root.get_node_or_null("GameManager")
	_setup_background()
	_setup_visuals()
	_setup_buttons()
	_update_coins()

func _setup_background() -> void:
	if background and background.texture:
		var tex_size := background.texture.get_size()
		if tex_size.x > 0.0 and tex_size.y > 0.0:
			var scale_factor := maxf(1080.0 / tex_size.x, 1920.0 / tex_size.y)
			background.scale = Vector2(scale_factor, scale_factor)

func _update_coins() -> void:
	if coins_label:
		coins_label.text = str(gm.coins) if gm else "0"

func _sticker_material(outline_px: float = 8.0, shadow_y: float = 5.0) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = STICKER_SHADER
	material.set_shader_parameter("outline_color", Color("#1D140F"))
	material.set_shader_parameter("outline_size", outline_px)
	material.set_shader_parameter("shadow_offset", Vector2(0.0, shadow_y))
	material.set_shader_parameter("shadow_color", Color(0.03, 0.02, 0.02, 0.30))
	return material

func _load_texture(path: String) -> Texture2D:
	if path != "" and ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


func _set_big_icon(button: Button, path: String, title_text: String) -> void:
	if not button:
		return

	button.text = ""
	button.icon = null
	button.custom_minimum_size = Vector2(860, 300)
	button.focus_mode = Control.FOCUS_NONE
	button.flat = true
	button.clip_contents = false

	var empty := StyleBoxEmpty.new()
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state, empty)

	var art := TextureRect.new()
	art.name = "GameArt"
	art.texture = _load_texture(path)
	art.material = null
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.anchor_left = 0.5
	art.anchor_right = 0.5
	art.anchor_top = 0.0
	art.anchor_bottom = 0.0
	art.offset_left = -170.0
	art.offset_right = 170.0
	art.offset_top = -10.0
	art.offset_bottom = 330.0
	button.add_child(art)

	var title := Label.new()
	title.name = "GameTitle"
	title.text = title_text
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.anchor_left = 0.0
	title.anchor_right = 1.0
	title.anchor_top = 1.0
	title.anchor_bottom = 1.0
	title.offset_left = 10.0
	title.offset_right = -10.0
	title.offset_top = -56.0
	title.offset_bottom = -4.0
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 33)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.add_theme_color_override("font_outline_color", Color("#17100C"))
	title.add_theme_constant_override("outline_size", 8)
	title.add_theme_color_override("font_shadow_color", Color(0,0,0,0.30))
	title.add_theme_constant_override("shadow_offset_y", 3)
	button.add_child(title)

	_bind_tap_feedback(button)

func _bind_tap_feedback(button: Button) -> void:
	if not button or button.has_meta("wonky_tap_fx"):
		return
	button.set_meta("wonky_tap_fx", true)
	button.resized.connect(func(): button.pivot_offset = button.size * 0.5)
	button.button_down.connect(func():
		var tween := create_tween()
		tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.07).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)
	button.button_up.connect(func():
		var tween := create_tween()
		tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(button, "scale", Vector2.ONE, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)


func _hide_card_text(card: Control) -> void:
	if not card:
		return
	if card is PanelContainer:
		(card as PanelContainer).add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	card.custom_minimum_size = Vector2(0, 325)

	var margin := card.get_node_or_null("Margin") as MarginContainer
	if margin:
		for side in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
			margin.add_theme_constant_override(side, 0)

	var hbox := card.get_node_or_null("Margin/HBox")
	if not hbox:
		return
	var icon_label := hbox.get_node_or_null("IconLabel") as Control
	var info_box := hbox.get_node_or_null("InfoVBox") as Control
	if icon_label:
		icon_label.visible = false
	if info_box:
		info_box.visible = false
	if hbox is BoxContainer:
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER


func _setup_visuals() -> void:
	# Se conserva el título; sólo los botones de juego quedan sin tarjeta.
	if title_box:
		title_box.visible = true
		if title_box is PanelContainer:
			(title_box as PanelContainer).add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		var title_label := title_box.get_node_or_null("TitleLabel") as Label
		if title_label:
			title_label.text = "MINIJUEGOS"
			title_label.add_theme_font_size_override("font_size", 36)
			title_label.add_theme_color_override("font_color", Color("#FFD654"))
			title_label.add_theme_color_override("font_outline_color", Color("#17100C"))
			title_label.add_theme_constant_override("outline_size", 8)

	# Volver: flecha tipo sticker, sin tarjeta.
	btn_back.text = ""
	btn_back.icon = null
	btn_back.custom_minimum_size = Vector2(112, 92)
	btn_back.focus_mode = Control.FOCUS_NONE
	btn_back.flat = true
	var empty := StyleBoxEmpty.new()
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		btn_back.add_theme_stylebox_override(state, empty)
	var back_art := TextureRect.new()
	back_art.texture = _load_texture("res://imagenes/ui_polished/navegacion/atras.png")
	back_art.material = null
	back_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back_art.set_anchors_preset(Control.PRESET_FULL_RECT)
	back_art.offset_left = 8
	back_art.offset_top = 2
	back_art.offset_right = -8
	back_art.offset_bottom = -2
	back_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	back_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	btn_back.add_child(back_art)
	_bind_tap_feedback(btn_back)


	var coins_box := coins_label.get_parent() as PanelContainer if coins_label else null
	if coins_box:
		coins_box.add_theme_stylebox_override("panel", StyleBoxEmpty.new())

	if coins_label:
		coins_label.add_theme_color_override("font_outline_color", Color("#17100C"))
		coins_label.add_theme_constant_override("outline_size", 6)

	_hide_card_text(fruit_card)
	_hide_card_text(flappy_card)
	_hide_card_text(jump_card)

	_set_big_icon(btn_play_fruit, "res://imagenes/ui_polished/minijuegos/fruit_catcher.png", "ATRAPA LA FRUTA")
	_set_big_icon(btn_play_flappy, "res://imagenes/ui_polished/minijuegos/flappy.png", "FLAPPY MONKY")
	_set_big_icon(btn_play_jump, "res://imagenes/ui_polished/minijuegos/monky_jump.png", "MONKY JUMP")
	_add_runner_button()

	btn_play_fruit.tooltip_text = "Atrapa la Fruta"
	btn_play_flappy.tooltip_text = "Flappy Monky"
	btn_play_jump.tooltip_text = "Monky Jump"
	if btn_play_runner:
		btn_play_runner.tooltip_text = "Wonky Run"

func _add_runner_button() -> void:
	if not games_vbox or btn_play_runner:
		return
	btn_play_runner = Button.new()
	btn_play_runner.name = "BtnPlayRunner"
	games_vbox.add_child(btn_play_runner)
	games_vbox.move_child(btn_play_runner, 0)
	_set_big_icon(btn_play_runner, "res://imagenes/runner/cover.png", "WONKY RUN")

func _open_scene(path: String) -> void:
	if not ResourceLoader.exists(path):
		push_error("No existe la escena: " + path)
		return
	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("No se pudo abrir la escena " + path + ". Error: " + str(err))

func _setup_buttons() -> void:
	btn_back.pressed.connect(func():
		if gm:
			gm.change_room("sala de juegos")
		_open_scene("res://scenes/main.tscn")
	)

	btn_play_fruit.pressed.connect(func():
		_open_scene("res://scenes/minigames/fruit_catcher.tscn")
	)

	btn_play_flappy.pressed.connect(func():
		_open_scene("res://scenes/minigames/flappy_monky.tscn")
	)

	btn_play_jump.pressed.connect(func():
		_open_scene("res://scenes/minigames/monky_jump.tscn")
	)

	if btn_play_runner:
		btn_play_runner.pressed.connect(func():
			_open_scene("res://scenes/minigames/wonky_runner.tscn")
		)
