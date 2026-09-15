extends CanvasLayer
class_name HUD

## Controlador del HUD y Sistema de Interfaz Avanzado
## Maneja barras de estado, nivel, monedas, dock de cuartos, inventario de comida y mercado.

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

# Modal de Mercado de Comidas
@onready var food_market_popup: Control = $FoodMarketPopup
@onready var market_balance_label: Label = $FoodMarketPopup/Panel/Margin/VBox/HeaderRow/BalanceLabel
@onready var btn_close_market: Button = $FoodMarketPopup/Panel/Margin/VBox/HeaderRow/BtnCloseMarket
@onready var market_grid: VBoxContainer = $FoodMarketPopup/Panel/Margin/VBox/Scroll/MarketGrid

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
@onready var action_drawers: Control = $ActionDrawers
@onready var kitchen_drawer: PanelContainer = $ActionDrawers/KitchenDrawer
@onready var food_scroll: ScrollContainer = $ActionDrawers/KitchenDrawer/Margin/FoodScroll
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
		if gm.has_signal("food_inventory_changed"):
			gm.food_inventory_changed.connect(_refresh_kitchen_inventory)
		
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
	_setup_food_market()
	_setup_scroll_support()
	_update_room_view(gm.current_room if gm else "dormitorio")

func _setup_scroll_support() -> void:
	if food_scroll:
		food_scroll.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_LEFT:
					food_scroll.scroll_horizontal = maxi(0, food_scroll.scroll_horizontal - 120)
				elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN or event.button_index == MOUSE_BUTTON_WHEEL_RIGHT:
					food_scroll.scroll_horizontal += 120
		)

func _setup_dock_buttons() -> void:
	btn_bed.pressed.connect(func(): _select_room("dormitorio"))
	btn_kitchen.pressed.connect(func(): _select_room("cocina"))
	btn_bath.pressed.connect(func(): _select_room("baño"))
	btn_play.pressed.connect(func(): _select_room("sala de juegos"))

func _select_room(r_name: String) -> void:
	if gm:
		gm.change_room(r_name)

func _setup_action_drawers() -> void:
	var empty_panel = StyleBoxEmpty.new()
	kitchen_drawer.add_theme_stylebox_override("panel", empty_panel)
	bath_drawer.add_theme_stylebox_override("panel", empty_panel)
	bed_drawer.add_theme_stylebox_override("panel", empty_panel)
	play_drawer.add_theme_stylebox_override("panel", empty_panel)

	var ball_style = _create_card_style(Color(1.0, 0.92, 0.78), Color(0.88, 0.62, 0.25))
	var game_style = _create_card_style(Color(0.92, 0.88, 1.0), Color(0.65, 0.5, 0.9))
	var soap_style = _create_card_style(Color(0.85, 0.96, 1.0), Color(0.3, 0.75, 0.9))
	var shower_style = _create_card_style(Color(0.85, 0.9, 1.0), Color(0.4, 0.6, 0.95))
	var lamp_style = _create_card_style(Color(0.88, 0.88, 0.98), Color(0.5, 0.5, 0.85))

	_refresh_kitchen_inventory()

	# Configurar acciones de baño
	btn_soap.custom_minimum_size = Vector2(250, 180)
	btn_soap.text = "🧼\n\nEnjabonar"
	btn_soap.add_theme_font_size_override("font_size", 26)
	btn_soap.add_theme_color_override("font_color", Color(0.15, 0.35, 0.5))
	btn_soap.add_theme_stylebox_override("normal", soap_style)
	btn_soap.pressed.connect(func():
		_spawn_draggable("soap")
	)

	btn_shower.custom_minimum_size = Vector2(250, 180)
	btn_shower.text = "🚿\n\nEnjuagar"
	btn_shower.add_theme_font_size_override("font_size", 26)
	btn_shower.add_theme_color_override("font_color", Color(0.15, 0.3, 0.55))
	btn_shower.add_theme_stylebox_override("normal", shower_style)
	btn_shower.pressed.connect(func():
		_spawn_draggable("shower")
	)

	# Configurar acciones de dormitorio
	btn_lamp.custom_minimum_size = Vector2(320, 180)
	btn_lamp.text = "🌙\n\nDormir"
	btn_lamp.add_theme_font_size_override("font_size", 28)
	btn_lamp.add_theme_color_override("font_color", Color(0.25, 0.2, 0.45))
	btn_lamp.add_theme_stylebox_override("normal", lamp_style)
	btn_lamp.pressed.connect(func():
		if gm:
			gm.toggle_sleep()
			btn_lamp.text = "☀️\n\nDespertar" if gm.is_sleeping else "🌙\n\nDormir"
	)

	# Configurar acciones de juego
	btn_ball.custom_minimum_size = Vector2(250, 180)
	btn_ball.text = "⚽\n\nLanzar Pelota"
	btn_ball.add_theme_font_size_override("font_size", 26)
	btn_ball.add_theme_color_override("font_color", Color(0.4, 0.25, 0.1))
	btn_ball.add_theme_stylebox_override("normal", ball_style)
	btn_ball.pressed.connect(func():
		_spawn_bouncing_ball()
	)

	btn_game.custom_minimum_size = Vector2(250, 180)
	btn_game.text = "🎮\n\nMinijuegos"
	btn_game.add_theme_font_size_override("font_size", 26)
	btn_game.add_theme_color_override("font_color", Color(0.3, 0.18, 0.5))
	btn_game.add_theme_stylebox_override("normal", game_style)
	btn_game.pressed.connect(func():
		get_tree().change_scene_to_file.call_deferred("res://scenes/minigames/minigames_menu.tscn")
	)

	btn_close_level.pressed.connect(func():
		level_popup.visible = false
	)

func _refresh_kitchen_inventory() -> void:
	if not food_items_grid:
		return
	for child in food_items_grid.get_children():
		child.queue_free()

	# Botón para abrir el Mercado de Comidas
	var market_btn = Button.new()
	market_btn.custom_minimum_size = Vector2(200, 200)
	market_btn.text = "🛒\n\nMercado\n(Comprar)"
	market_btn.add_theme_font_size_override("font_size", 24)
	market_btn.add_theme_color_override("font_color", Color(0.1, 0.45, 0.25))
	market_btn.add_theme_stylebox_override("normal", _create_card_style(Color(0.85, 0.98, 0.88), Color(0.3, 0.75, 0.45)))
	market_btn.pressed.connect(_open_food_market)
	food_items_grid.add_child(market_btn)

	var catalog = gm.FOOD_CATALOG if gm else []
	var food_style = _create_card_style(Color(1.0, 0.96, 0.88), Color(0.8, 0.65, 0.4))

	var any_food_owned = false
	for food in catalog:
		var qty: int = gm.get_food_quantity(food.id) if gm else 0
		# SOLO mostrar alimentos que el jugador tiene en existencias (qty > 0)
		if qty > 0:
			any_food_owned = true
			var card = Button.new()
			card.custom_minimum_size = Vector2(200, 200)
			card.text = food.icon + "\n\n" + food.name + "\n(" + str(qty) + ")"
			card.add_theme_font_size_override("font_size", 26)
			card.add_theme_color_override("font_color", Color(0.35, 0.22, 0.12))
			card.add_theme_stylebox_override("normal", food_style)
			card.pressed.connect(func():
				_spawn_draggable("food", food)
			)
			food_items_grid.add_child(card)

	if not any_food_owned:
		var empty_lbl = Label.new()
		empty_lbl.text = "👈 ¡Nevera vacía! Toca Mercado para comprar comida"
		empty_lbl.add_theme_font_size_override("font_size", 26)
		empty_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
		empty_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		food_items_grid.add_child(empty_lbl)

func _setup_food_market() -> void:
	if not food_market_popup:
		return
	btn_close_market.pressed.connect(_close_food_market)

func _open_food_market() -> void:
	if not food_market_popup:
		return
	_populate_market_grid()
	_update_market_balance()
	food_market_popup.visible = true
	var panel = food_market_popup.get_node("Panel")
	panel.scale = Vector2(0.7, 0.7)
	panel.pivot_offset = panel.size / 2.0
	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _close_food_market() -> void:
	if not food_market_popup:
		return
	var panel = food_market_popup.get_node("Panel")
	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2(0.7, 0.7), 0.15).set_ease(Tween.EASE_IN)
	tween.finished.connect(func():
		food_market_popup.visible = false
	)

func _update_market_balance() -> void:
	if gm and market_balance_label:
		market_balance_label.text = "Saldo: " + str(gm.coins) + " 🪙"

func _populate_market_grid() -> void:
	if not market_grid:
		return
	for child in market_grid.get_children():
		child.queue_free()

	var catalog = gm.FOOD_CATALOG if gm else []
	for food in catalog:
		var item_card = PanelContainer.new()
		item_card.custom_minimum_size = Vector2(0, 130)
		item_card.add_theme_stylebox_override("panel", _create_card_style(Color(0.18, 0.15, 0.26, 0.95), Color(0.7, 0.55, 0.3)))

		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 24)
		margin.add_theme_constant_override("margin_right", 24)
		margin.add_theme_constant_override("margin_top", 16)
		margin.add_theme_constant_override("margin_bottom", 16)
		item_card.add_child(margin)

		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 20)
		margin.add_child(hbox)

		var icon_lbl = Label.new()
		icon_lbl.text = food.icon
		icon_lbl.add_theme_font_size_override("font_size", 70)
		hbox.add_child(icon_lbl)

		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 6)
		hbox.add_child(vbox)

		var name_lbl = Label.new()
		name_lbl.text = food.name + "  (" + food.category + ")"
		name_lbl.add_theme_font_size_override("font_size", 30)
		name_lbl.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
		vbox.add_child(name_lbl)

		var qty = gm.get_food_quantity(food.id) if gm else 0
		var desc_lbl = Label.new()
		desc_lbl.text = "+" + str(int(food.hunger)) + "% Hambre | +" + str(int(food.xp)) + " XP   •   En nevera: " + str(qty)
		desc_lbl.add_theme_font_size_override("font_size", 24)
		desc_lbl.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95))
		vbox.add_child(desc_lbl)

		var buy_btn = Button.new()
		buy_btn.custom_minimum_size = Vector2(210, 80)
		buy_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		buy_btn.text = "➕ " + str(food.price) + " 🪙"
		buy_btn.add_theme_font_size_override("font_size", 28)
		buy_btn.add_theme_stylebox_override("normal", _create_card_style(Color(0.2, 0.65, 0.35), Color(1, 1, 1, 0.6)))
		buy_btn.pressed.connect(func():
			if gm and gm.buy_food(food.id, 1):
				_update_market_balance()
				desc_lbl.text = "+" + str(int(food.hunger)) + "% Hambre | +" + str(int(food.xp)) + " XP   •   En nevera: " + str(gm.get_food_quantity(food.id))
		)
		hbox.add_child(buy_btn)

		market_grid.add_child(item_card)

func _create_card_style(bg_col: Color, border_col: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_col
	style.border_color = border_col
	style.set_border_width_all(3)
	style.set_corner_radius_all(22)
	style.shadow_color = Color(0, 0, 0, 0.25)
	style.shadow_size = 5
	return style

func _spawn_bouncing_ball() -> void:
	var scene_root = get_tree().current_scene
	if not scene_root:
		return
	for child in scene_root.get_children():
		if child.name.begins_with("BouncingBall") or child.has_method("_check_monky_collision"):
			child.queue_free()
	var ball_scene = preload("res://scenes/monky/bouncing_ball.tscn")
	var ball = ball_scene.instantiate()
	scene_root.add_child(ball)
	ball.global_position = Vector2(540, 850)
	if gm:
		gm.show_floating_text.emit("⚽ ¡Patea o lanza la pelota a Monky!", Vector2(540, 720), Color(1, 0.85, 0.2))

func _spawn_draggable(type: String, data: Dictionary = {}) -> void:
	var scene_root = get_tree().current_scene
	if not scene_root:
		return
	for child in scene_root.get_children():
		if child.name.begins_with("DraggableItem") or child.has_method("finish_and_destroy"):
			child.queue_free()
	var draggable_scene = preload("res://scenes/monky/draggable_item.tscn")
	var item = draggable_scene.instantiate()
	scene_root.add_child(item)
	item.global_position = get_viewport().get_mouse_position()
	item.setup(type, data)

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
			gm.add_coins(25)
			_update_shop_balance()
	)
	btn_pack_ad.pressed.connect(func():
		if gm:
			gm.add_coins(50)
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
	tween.tween_property(panel, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

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
	_update_shop_balance()
	_update_market_balance()

func _on_xp_changed(cur_xp: float, max_xp: float, lvl: int) -> void:
	level_label.text = "⭐ NIV. " + str(lvl)
	xp_bar.max_value = max_xp
	xp_bar.value = cur_xp

func _on_level_up(new_level: int) -> void:
	level_popup_label.text = "¡Monky ha alcanzado el Nivel " + str(new_level) + "!\nHas ganado " + str(new_level * 5) + " 🪙 de bonificación."
	level_popup.visible = true
	var tween = create_tween()
	level_popup.scale = Vector2(0.5, 0.5)
	level_popup.pivot_offset = level_popup.size / 2.0
	tween.tween_property(level_popup, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

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
