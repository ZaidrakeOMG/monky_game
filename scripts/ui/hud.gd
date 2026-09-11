extends CanvasLayer
class_name HUD

## Controlador del HUD y Sistema de Interfaz Avanzado
## Maneja barras de estado, nivel, monedas, dock de cuartos y paneles de interacción.

@onready var level_label: Label = $TopBar/VBox/HeaderRow/LevelContainer/LevelLabel
@onready var xp_bar: ProgressBar = $TopBar/VBox/HeaderRow/LevelContainer/XPBar
@onready var btn_coins: Button = $TopBar/VBox/HeaderRow/BtnCoins
@onready var coins_label: Label = $TopBar/VBox/HeaderRow/BtnCoins/HBox/CoinsLabel

# Modal de Tienda de Monedas / Pociones
@onready var shop_popup: Control = $ShopPopup
@onready var shop_balance_label: Label = $ShopPopup/Panel/Margin/VBox/HeaderRow/BalanceLabel
@onready var btn_close_shop: Button = $ShopPopup/Panel/Margin/VBox/HeaderRow/BtnCloseShop
@onready var btn_pack_daily: Button = $ShopPopup/Panel/Margin/VBox/Scroll/ContentVBox/CoinPacksGrid/BtnDaily
@onready var btn_pack_ad: Button = $ShopPopup/Panel/Margin/VBox/Scroll/ContentVBox/CoinPacksGrid/BtnAd
@onready var btn_pack_bag: Button = $ShopPopup/Panel/Margin/VBox/Scroll/ContentVBox/CoinPacksGrid/BtnBag
@onready var btn_pack_chest: Button = $ShopPopup/Panel/Margin/VBox/Scroll/ContentVBox/CoinPacksGrid/BtnChest
@onready var btn_pot_energy: Button = $ShopPopup/Panel/Margin/VBox/Scroll/ContentVBox/PotionsGrid/BtnPotEnergy
@onready var btn_pot_hygiene: Button = $ShopPopup/Panel/Margin/VBox/Scroll/ContentVBox/PotionsGrid/BtnPotHygiene
@onready var btn_pot_mega: Button = $ShopPopup/Panel/Margin/VBox/Scroll/ContentVBox/PotionsGrid/BtnPotMega

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

var gm: Node = null

func _ready() -> void:
	gm = get_tree().root.get_node_or_null("GameManager")
	if gm:
		gm.stat_changed.connect(_on_stat_changed)
		gm.coins_changed.connect(_on_coins_changed)
		gm.xp_changed.connect(_on_xp_changed)
		gm.level_up.connect(_on_level_up)
		gm.room_changed.connect(_on_room_changed)
		
		# Inicializar UI
		_update_stat_ui("hunger", gm.hunger, gm.MAX_STAT)
		_update_stat_ui("energy", gm.energy, gm.MAX_STAT)
		_update_stat_ui("fun", gm.fun, gm.MAX_STAT)
		_update_stat_ui("hygiene", gm.hygiene, gm.MAX_STAT)
		_on_coins_changed(gm.coins)
		_on_xp_changed(gm.xp, gm.get_xp_needed(), gm.level)

	_setup_dock_buttons()
	_setup_action_drawers()
	_setup_shop_modal()
	_update_room_view(gm.current_room if gm else "dormitorio")

func _setup_dock_buttons() -> void:
	btn_bed.pressed.connect(func(): _select_room("dormitorio"))
	btn_kitchen.pressed.connect(func(): _select_room("cocina"))
	btn_bath.pressed.connect(func(): _select_room("baño"))
	btn_play.pressed.connect(func(): _select_room("sala de juegos"))

func _select_room(r_name: String) -> void:
	if gm:
		gm.change_room(r_name)

func _setup_action_drawers() -> void:
	# Configurar comidas en la cocina
	for child in food_items_grid.get_children():
		child.queue_free()

	var catalog = gm.FOOD_CATALOG if gm else []
	for food in catalog:
		var card = Button.new()
		card.custom_minimum_size = Vector2(160, 180)
		card.text = food.icon + "\n" + food.name + "\n" + (str(food.price) + " 🪙" if food.price > 0 else "GRATIS")
		card.add_theme_font_size_override("font_size", 22)
		card.pressed.connect(func():
			if gm:
				gm.feed_item(food)
		)
		food_items_grid.add_child(card)

	# Configurar acciones de baño
	btn_soap.pressed.connect(func():
		if gm:
			gm.clean(20.0)
	)
	btn_shower.pressed.connect(func():
		if gm:
			gm.clean(35.0)
	)

	# Configurar acciones de dormitorio
	btn_lamp.pressed.connect(func():
		if gm:
			gm.toggle_sleep()
			btn_lamp.text = "☀️ Despertar" if gm.is_sleeping else "🌙 Dormir"
	)

	# Configurar acciones de juego
	btn_ball.pressed.connect(func():
		if gm:
			gm.play_with_monky(25.0)
			gm.add_coins(3)
	)
	btn_game.pressed.connect(func():
		if gm:
			gm.play_with_monky(40.0)
			gm.add_coins(15)
			gm.show_floating_text.emit("¡Minijuego Ganado! +15 🪙", Vector2(540, 800), Color(1, 0.8, 0.2))
	)

	btn_close_level.pressed.connect(func():
		level_popup.visible = false
	)

func _setup_shop_modal() -> void:
	btn_coins.pressed.connect(func():
		_open_shop()
	)
	btn_close_shop.pressed.connect(func():
		_close_shop()
	)

	# Packs de Monedas
	btn_pack_daily.pressed.connect(func():
		if gm:
			gm.add_coins(50)
			_update_shop_balance()
	)
	btn_pack_ad.pressed.connect(func():
		if gm:
			gm.add_coins(100)
			_update_shop_balance()
	)
	btn_pack_bag.pressed.connect(func():
		if gm:
			gm.add_coins(500)
			_update_shop_balance()
	)
	btn_pack_chest.pressed.connect(func():
		if gm:
			gm.add_coins(2500)
			_update_shop_balance()
	)

	# Pociones
	btn_pot_energy.pressed.connect(func():
		if gm and gm.spend_coins(25):
			gm.energy = 100.0
			gm.show_floating_text.emit("⚡ ¡Energía al 100%!", Vector2(540, 900), Color(1, 0.9, 0.2))
			_update_shop_balance()
	)
	btn_pot_hygiene.pressed.connect(func():
		if gm and gm.spend_coins(20):
			gm.hygiene = 100.0
			gm.show_floating_text.emit("🧼 ¡Higiene al 100%!", Vector2(540, 900), Color(0.3, 0.9, 1.0))
			_update_shop_balance()
	)
	btn_pot_mega.pressed.connect(func():
		if gm and gm.spend_coins(50):
			gm.hunger = 100.0
			gm.energy = 100.0
			gm.fun = 100.0
			gm.hygiene = 100.0
			gm.show_floating_text.emit("🌟 ¡Poción Suprema Usada!", Vector2(540, 900), Color(1, 0.4, 1.0))
			_update_shop_balance()
	)

func _open_shop() -> void:
	_update_shop_balance()
	shop_popup.visible = true
	var panel = shop_popup.get_node("Panel")
	panel.scale = Vector2(0.7, 0.7)
	panel.pivot_offset = panel.size / 2.0
	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _close_shop() -> void:
	var panel = shop_popup.get_node("Panel")
	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2(0.7, 0.7), 0.15).set_ease(Tween.EASE_IN)
	tween.finished.connect(func():
		shop_popup.visible = false
	)

func _update_shop_balance() -> void:
	if gm and shop_balance_label:
		shop_balance_label.text = "Saldo: " + str(gm.coins) + " 🪙"


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
