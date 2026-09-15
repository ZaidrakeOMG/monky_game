extends Control

## Menú visual de minijuegos para Android.
## Usa botones grandes con imágenes y casi nada de texto.

@onready var background: Sprite2D = $Background
@onready var btn_back: Button = $HUD/TopBar/BtnBack
@onready var coins_label: Label = $HUD/TopBar/CoinsBox/CoinsLabel
@onready var title_box: Control = $HUD/TopBar/TitleBox

@onready var fruit_card: Control = $HUD/Scroll/VBox/CardFruit
@onready var flappy_card: Control = $HUD/Scroll/VBox/CardFlappy
@onready var jump_card: Control = $HUD/Scroll/VBox/CardJump

@onready var btn_play_fruit: Button = $HUD/Scroll/VBox/CardFruit/Margin/HBox/BtnPlayFruit
@onready var btn_play_flappy: Button = $HUD/Scroll/VBox/CardFlappy/Margin/HBox/BtnPlayFlappy
@onready var btn_play_jump: Button = $HUD/Scroll/VBox/CardJump/Margin/HBox/BtnPlayJump

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

func _load_texture(path: String) -> Texture2D:
	if path != "" and ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null

func _set_big_icon(button: Button, path: String) -> void:
	if not button:
		return
	button.text = ""
	button.icon = _load_texture(path)
	button.expand_icon = true
	button.custom_minimum_size = Vector2(760, 300)
	button.add_theme_constant_override("icon_max_width", 260)
	button.focus_mode = Control.FOCUS_NONE

func _hide_card_text(card: Control) -> void:
	if not card:
		return
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
	if title_box:
		title_box.visible = false

	btn_back.text = ""
	btn_back.icon = _load_texture("res://imagenes/opt/navegacion/inicio.png")
	btn_back.expand_icon = true
	btn_back.add_theme_constant_override("icon_max_width", 70)
	btn_back.custom_minimum_size = Vector2(110, 90)

	_hide_card_text(fruit_card)
	_hide_card_text(flappy_card)
	_hide_card_text(jump_card)

	_set_big_icon(btn_play_fruit, "res://imagenes/opt/minijuegos/fruit_catcher.png")
	_set_big_icon(btn_play_flappy, "res://imagenes/opt/minijuegos/flappy.png")
	_set_big_icon(btn_play_jump, "res://imagenes/opt/minijuegos/monky_jump.png")

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
