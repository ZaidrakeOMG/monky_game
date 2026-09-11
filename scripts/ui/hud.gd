extends CanvasLayer
class_name HUD

## Controlador del HUD y Sistema de Interfaz Avanzado
## Maneja barras de estado, nivel, monedas, dock de cuartos y paneles de interacción.

@onready var level_label: Label = $TopBar/VBox/HeaderRow/LevelContainer/LevelLabel
@onready var xp_bar: ProgressBar = $TopBar/VBox/HeaderRow/LevelContainer/XPBar
@onready var coins_label: Label = $TopBar/VBox/HeaderRow/CoinsContainer/CoinsLabel

@onready var hunger_bar: ProgressBar = $TopBar/VBox/StatsGrid/HungerContainer/HungerBar
@onready var energy_bar: ProgressBar = $TopBar/VBox/StatsGrid/EnergyContainer/EnergyBar
@onready var fun_bar: ProgressBar = $TopBar/VBox/StatsGrid/FunContainer/FunBar
@onready var hygiene_bar: ProgressBar = $TopBar/VBox/StatsGrid/HygieneContainer/HygieneBar

@onready var hunger_label: Label = $TopBar/VBox/StatsGrid/HungerContainer/Label
@onready var energy_label: Label = $TopBar/VBox/StatsGrid/EnergyContainer/Label
@onready var fun_label: Label = $TopBar/VBox/StatsGrid/FunContainer/Label
@onready var hygiene_label: Label = $TopBar/VBox/StatsGrid/HygieneContainer/Label

# Dock de navegación
@onready var btn_bed: Button = $BottomBar/VBox/DockContainer/BtnBed
@onready var btn_kitchen: Button = $BottomBar/VBox/DockContainer/BtnKitchen
@onready var btn_bath: Button = $BottomBar/VBox/DockContainer/BtnBath
@onready var btn_play: Button = $BottomBar/VBox/DockContainer/BtnPlay
@onready var room_title: Label = $BottomBar/VBox/RoomTitle

# Paneles de interacción
@onready var kitchen_drawer: PanelContainer = $ActionDrawers/KitchenDrawer
@onready var food_items_grid: HBoxContainer = $ActionDrawers/KitchenDrawer/Margin/FoodScroll/FoodGrid
@onready var bath_drawer: PanelContainer = $ActionDrawers/BathDrawer
@onready var btn_soap: Button = $ActionDrawers/BathDrawer/Margin/HBox/BtnSoap
@onready var btn_shower: Button = $ActionDrawers/BathDrawer/Margin/HBox/BtnShower
@onready var bed_drawer: PanelContainer = $ActionDrawers/BedDrawer
@onready var btn_lamp: Button = $ActionDrawers/BedDrawer/Margin/HBox/BtnLamp
@onready var play_drawer: PanelContainer = $ActionDrawers/PlayDrawer
@onready var btn_ball: Button = $ActionDrawers/PlayDrawer/Margin/HBox/BtnBall
@onready var btn_game: Button = $ActionDrawers/PlayDrawer/Margin/HBox/BtnGame

# Popup de Nivel
@onready var level_popup: PanelContainer = $LevelUpPopup
@onready var level_popup_label: Label = $LevelUpPopup/Margin/VBox/DescLabel
@onready var btn_close_level: Button = $LevelUpPopup/Margin/VBox/BtnClaim

func _ready() -> void:
	if GameManager:
		GameManager.stat_changed.connect(_on_stat_changed)
		GameManager.coins_changed.connect(_on_coins_changed)
		GameManager.xp_changed.connect(_on_xp_changed)
		GameManager.level_up.connect(_on_level_up)
		GameManager.room_changed.connect(_on_room_changed)
		
		# Inicializar UI
		_update_stat_ui("hunger", GameManager.hunger, GameManager.MAX_STAT)
		_update_stat_ui("energy", GameManager.energy, GameManager.MAX_STAT)
		_update_stat_ui("fun", GameManager.fun, GameManager.MAX_STAT)
		_update_stat_ui("hygiene", GameManager.hygiene, GameManager.MAX_STAT)
		_on_coins_changed(GameManager.coins)
		_on_xp_changed(GameManager.xp, GameManager.get_xp_needed(), GameManager.level)

	_setup_dock_buttons()
	_setup_action_drawers()
	_update_room_view(GameManager.current_room if GameManager else "dormitorio")

func _setup_dock_buttons() -> void:
	btn_bed.pressed.connect(func(): _select_room("dormitorio"))
	btn_kitchen.pressed.connect(func(): _select_room("cocina"))
	btn_bath.pressed.connect(func(): _select_room("baño"))
	btn_play.pressed.connect(func(): _select_room("sala de juegos"))

func _select_room(r_name: String) -> void:
	if GameManager:
		GameManager.change_room(r_name)

func _setup_action_drawers() -> void:
	# Configurar comidas en la cocina
	for child in food_items_grid.get_children():
		child.queue_free()

	for food in GameManager.FOOD_CATALOG:
		var card = Button.new()
		card.custom_minimum_size = Vector2(160, 180)
		card.text = food.icon + "\n" + food.name + "\n" + (str(food.price) + " 🪙" if food.price > 0 else "GRATIS")
		card.add_theme_font_size_override("font_size", 22)
		card.pressed.connect(func():
			if GameManager:
				GameManager.feed_item(food)
		)
		food_items_grid.add_child(card)

	# Configurar acciones de baño
	btn_soap.pressed.connect(func():
		if GameManager:
			GameManager.clean(20.0)
	)
	btn_shower.pressed.connect(func():
		if GameManager:
			GameManager.clean(35.0)
	)

	# Configurar acciones de dormitorio
	btn_lamp.pressed.connect(func():
		if GameManager:
			GameManager.toggle_sleep()
			btn_lamp.text = "☀️ Despertar" if GameManager.is_sleeping else "🌙 Dormir"
	)

	# Configurar acciones de juego
	btn_ball.pressed.connect(func():
		if GameManager:
			GameManager.play_with_monky(25.0)
			GameManager.add_coins(3)
	)
	btn_game.pressed.connect(func():
		if GameManager:
			GameManager.play_with_monky(40.0)
			GameManager.add_coins(15)
			GameManager.show_floating_text.emit("¡Minijuego Ganado! +15 🪙", Vector2(540, 800), Color(1, 0.8, 0.2))
	)

	btn_close_level.pressed.connect(func():
		level_popup.visible = false
	)

func _on_stat_changed(stat_name: String, current_value: float, max_value: float) -> void:
	_update_stat_ui(stat_name, current_value, max_value)

func _update_stat_ui(stat_name: String, value: float, max_val: float) -> void:
	var target_bar: ProgressBar = null
	var target_label: Label = null

	match stat_name:
		"hunger":
			target_bar = hunger_bar
			target_label = hunger_label
		"energy":
			target_bar = energy_bar
			target_label = energy_label
		"fun":
			target_bar = fun_bar
			target_label = fun_label
		"hygiene":
			target_bar = hygiene_bar
			target_label = hygiene_label

	if target_bar:
		target_bar.max_value = max_val
		var tween = create_tween()
		tween.tween_property(target_bar, "value", value, 0.25)
		if target_label:
			target_label.text = str(int(value)) + "%"

func _on_coins_changed(new_coins: int) -> void:
	coins_label.text = str(new_coins)

func _on_xp_changed(cur_xp: float, max_xp: float, lvl: int) -> void:
	level_label.text = "⭐ NIV. " + str(lvl)
	xp_bar.max_value = max_xp
	xp_bar.value = cur_xp

func _on_level_up(new_level: int) -> void:
	level_popup_label.text = "¡Monky ha alcanzado el Nivel " + str(new_level) + "!\nHas ganado " + str(new_level * 10) + " 🪙 de bonificación."
	level_popup.visible = true
	var tween = create_tween()
	level_popup.scale = Vector2(0.5, 0.5)
	level_popup.pivot_offset = level_popup.size / 2.0
	tween.tween_property(level_popup, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_room_changed(room_name: String) -> void:
	_update_room_view(room_name)

func _update_room_view(room_name: String) -> void:
	var key = room_name.to_lower()
	room_title.text = key.to_upper()

	# Ocultar todos los cajones y mostrar solo el del cuarto activo
	kitchen_drawer.visible = (key == "cocina")
	bath_drawer.visible = (key == "baño")
	bed_drawer.visible = (key == "dormitorio")
	play_drawer.visible = (key == "sala de juegos" or key == "juegos")

	# Resaltar botón activo del Dock
	btn_bed.modulate = Color(1.3, 1.3, 1.3) if key == "dormitorio" else Color(0.7, 0.7, 0.7)
	btn_kitchen.modulate = Color(1.3, 1.3, 1.3) if key == "cocina" else Color(0.7, 0.7, 0.7)
	btn_bath.modulate = Color(1.3, 1.3, 1.3) if key == "baño" else Color(0.7, 0.7, 0.7)
	btn_play.modulate = Color(1.3, 1.3, 1.3) if (key == "sala de juegos" or key == "juegos") else Color(0.7, 0.7, 0.7)


