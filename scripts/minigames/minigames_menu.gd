extends Control

## Menú Selector de Minijuegos (Hub Arcade)
## Permite al jugador elegir entre los diferentes minijuegos disponibles, ver récords y volver a la sala.

@onready var background: Sprite2D = $Background
@onready var coins_label: Label = $HUD/TopBar/CoinsBox/CoinsLabel
@onready var btn_back: Button = $HUD/TopBar/BtnBack

# Botones de juego
@onready var btn_play_fruit: Button = $HUD/Scroll/VBox/CardFruit/Margin/HBox/BtnPlayFruit
@onready var btn_play_flappy: Button = $HUD/Scroll/VBox/CardFlappy/Margin/HBox/BtnPlayFlappy
@onready var btn_play_jump: Button = $HUD/Scroll/VBox/CardJump/Margin/HBox/BtnPlayJump

var gm: Node = null

func _ready() -> void:
	gm = get_tree().root.get_node_or_null("GameManager")
	_setup_background()
	_update_coins()
	_setup_buttons()

func _setup_background() -> void:
	if background and background.texture:
		var tex_size = background.texture.get_size()
		if tex_size.x > 0 and tex_size.y > 0:
			var scale_factor = maxf(1080.0 / tex_size.x, 1920.0 / tex_size.y)
			background.scale = Vector2(scale_factor, scale_factor)

func _update_coins() -> void:
	if gm and coins_label:
		coins_label.text = "🪙 " + str(gm.coins)

func _setup_buttons() -> void:
	btn_back.pressed.connect(func():
		if gm:
			gm.change_room("sala de juegos")
		get_tree().change_scene_to_file.call_deferred("res://scenes/main.tscn")
	)

	btn_play_fruit.pressed.connect(func():
		if _can_play_minigame():
			get_tree().change_scene_to_file.call_deferred("res://scenes/minigames/fruit_catcher.tscn")
	)

	btn_play_flappy.pressed.connect(func():
		if _can_play_minigame():
			get_tree().change_scene_to_file.call_deferred("res://scenes/minigames/flappy_monky.tscn")
	)

	btn_play_jump.pressed.connect(func():
		if _can_play_minigame():
			get_tree().change_scene_to_file.call_deferred("res://scenes/minigames/monky_jump.tscn")
	)

func _can_play_minigame() -> bool:
	if gm and gm.energy <= 5.0:
		gm.show_floating_text.emit("😴 ¡Monky no tiene energía! Ve a dormir", Vector2(540, 960), Color(1, 0.4, 0.4))
		return false
	return true
