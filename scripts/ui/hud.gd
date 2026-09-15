extends CanvasLayer
class_name HUD

## Controlador del HUD y Sistema de Interfaz Avanzado
## Maneja barras de estado, nivel, monedas, dock de cuartos, inventario de comida y mercado.

@onready var level_label: Label = $TopBar/VBox/HeaderRow/LevelContainer/LevelLabel
@onready var xp_bar: ProgressBar = $TopBar/VBox/HeaderRow/LevelContainer/XPBar
@onready var btn_coins: Button = $TopBar/VBox/HeaderRow/BtnCoins
@onready var coins_label: Label = $TopBar/VBox/HeaderRow/BtnCoins/HBox/CoinsLabel
@onready var btn_diamonds: Button = $TopBar/VBox/HeaderRow/BtnDiamonds
@onready var diamonds_label: Label = $TopBar/VBox/HeaderRow/BtnDiamonds/HBox/DiamondsLabel

# Modal de Tienda de Diamantes y Monedas
@onready var shop_popup: Control = $ShopPopup
@onready var shop_coins_balance: Label = $ShopPopup/Panel/Margin/VBox/HeaderRow/BalanceContainer/CoinsBalanceLabel
@onready var shop_diamonds_balance: Label = $ShopPopup/Panel/Margin/VBox/HeaderRow/BalanceContainer/DiamondsBalanceLabel
@onready var btn_close_shop: Button = $ShopPopup/Panel/Margin/VBox/HeaderRow/BtnCloseShop

# IAP Diamantes
@onready var btn_iap_50: Button = $ShopPopup/Panel/Margin/VBox/Scroll/ContentVBox/IapGrid/BtnIap50
@onready var btn_iap_300: Button = $ShopPopup/Panel/Margin/VBox/Scroll/ContentVBox/IapGrid/BtnIap300
@onready var btn_iap_1000: Button = $ShopPopup/Panel/Margin/VBox/Scroll/ContentVBox/IapGrid/BtnIap1000

# Canje Diamantes por Monedas
@onready var btn_exch_250: Button = $ShopPopup/Panel/Margin/VBox/Scroll/ContentVBox/ExchangeGrid/BtnExch250
@onready var btn_exch_1000: Button = $ShopPopup/Panel/Margin/VBox/Scroll/ContentVBox/ExchangeGrid/BtnExch1000
@onready var btn_exch_3500: Button = $ShopPopup/Panel/Margin/VBox/Scroll/ContentVBox/ExchangeGrid/BtnExch3500

# Pociones
@onready var btn_pot_energy: Button = $ShopPopup/Panel/Margin/VBox/Scroll/ContentVBox/PotionsGrid/BtnPotEnergy
@onready var btn_pot_hygiene: Button = $ShopPopup/Panel/Margin/VBox/Scroll/ContentVBox/PotionsGrid/BtnPotHygiene
@onready var btn_pot_mega: Button = $ShopPopup/Panel/Margin/VBox/Scroll/ContentVBox/PotionsGrid/BtnPotMega

# Recompensas
@onready var btn_pack_daily: Button = $ShopPopup/Panel/Margin/VBox/Scroll/ContentVBox/RewardsGrid/BtnDaily
@onready var btn_pack_ad: Button = $ShopPopup/Panel/Margin/VBox/Scroll/ContentVBox/RewardsGrid/BtnAd

var iap_confirm_popup: Control = null
var current_iap_pack: Dictionary = {}

# Modal de Mercado de Comidas
@onready var food_market_popup: Control = $FoodMarketPopup
@onready var market_balance_label: Label = $FoodMarketPopup/Panel/Margin/VBox/HeaderRow/BalanceLabel
@onready var btn_close_market: Button = $FoodMarketPopup/Panel/Margin/VBox/HeaderRow/BtnCloseMarket
@onready var market_grid: VBoxContainer = $FoodMarketPopup/Panel/Margin/VBox/Scroll/MarketGrid

@onready var stats_grid: HBoxContainer = $TopBar/VBox/StatsGrid
@onready var hunger_bar: ProgressBar = $TopBar/VBox/StatsGrid/HungerContainer/HungerBar
@onready var energy_bar: ProgressBar = $TopBar/VBox/StatsGrid/EnergyContainer/EnergyBar
@onready var fun_bar: ProgressBar = $TopBar/VBox/StatsGrid/FunContainer/FunBar
@onready var hygiene_bar: ProgressBar = $TopBar/VBox/StatsGrid/HygieneContainer/HygieneBar

@onready var hunger_label: Label = $TopBar/VBox/StatsGrid/HungerContainer/Label
@onready var energy_label: Label = $TopBar/VBox/StatsGrid/EnergyContainer/Label
@onready var fun_label: Label = $TopBar/VBox/StatsGrid/FunContainer/Label
@onready var hygiene_label: Label = $TopBar/VBox/StatsGrid/HygieneContainer/Label

# Barra dinámica de proteínas
var protein_container: VBoxContainer = null
var protein_bar: ProgressBar = null
var protein_label: Label = null

# Modal de Ficha Técnica / Detalles de Comida
var food_details_popup: Control = null
var details_icon_label: Label = null
var details_title_label: Label = null
var details_desc_label: Label = null
var details_stats_label: Label = null
var details_buy_btn: Button = null
var current_inspected_food: Dictionary = {}

# Botón y Modal de Ajustes / Configuración
@onready var btn_settings: Button = $TopBar/VBox/HeaderRow/BtnSettings
var settings_popup: Control = null
var btn_toggle_sfx: Button = null
var btn_toggle_music: Button = null
var btn_toggle_vib: Button = null
var confirm_reset_popup: Control = null

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
@onready var btn_toothbrush: Button = $ActionDrawers/BathDrawer/Margin/HBox/BtnToothbrush
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
	_setup_protein_ui()
	_setup_food_details_popup()

	if gm:
		gm.stat_changed.connect(_on_stat_changed)
		gm.coins_changed.connect(_on_coins_changed)
		gm.diamonds_changed.connect(_on_diamonds_changed)
		gm.xp_changed.connect(_on_xp_changed)
		gm.level_up.connect(_on_level_up)
		gm.room_changed.connect(_on_room_changed)
		if gm.has_signal("food_inventory_changed"):
			gm.food_inventory_changed.connect(_refresh_kitchen_inventory)
		
		# Inicializar UI
		_update_stat_ui("hunger", gm.hunger, gm.MAX_STAT)
		_update_stat_ui("protein", gm.protein, gm.MAX_STAT)
		_update_stat_ui("energy", gm.energy, gm.MAX_STAT)
		_update_stat_ui("fun", gm.fun, gm.MAX_STAT)
		_update_stat_ui("hygiene", gm.hygiene, gm.MAX_STAT)
		_on_coins_changed(gm.coins)
		_on_diamonds_changed(gm.diamonds)
		_on_xp_changed(gm.xp, gm.get_xp_needed(), gm.level)

	_setup_dock_buttons()
	_setup_action_drawers()
	_setup_shop_modal()
	_setup_food_market()
	_setup_settings_modal()
	_setup_scroll_support()
	_update_room_view(gm.current_room if gm else "dormitorio")

	if btn_settings:
		btn_settings.pressed.connect(_open_settings_modal)

func _process(_delta: float) -> void:
	# Cuenta regresiva en vivo del tiempo de sueño de 1h
	if gm and btn_lamp:
		if gm.is_sleeping:
			var missing_energy: float = gm.MAX_STAT - gm.energy
			var seconds_remaining: int = maxi(0, int((missing_energy / gm.MAX_STAT) * gm.SLEEP_DURATION_SEC))
			var mins = seconds_remaining / 60
			var secs = seconds_remaining % 60
			btn_lamp.text = "☀️\n\nDespertar\n(%02d:%02d)" % [mins, secs]
		elif gm.energy <= 0.0:
			btn_lamp.text = "🌙\n\n¡A Dormir!\n(Agotado 🥱)"
		else:
			btn_lamp.text = "🌙\n\nDormir\n(1 hora)"

	# Actualizar temporizadores de recompensas de la tienda en vivo si está abierta
	if shop_popup and shop_popup.visible:
		_update_shop_timers()

func _setup_protein_ui() -> void:
	# Las 4 barras clásicas se mantienen limpias y amplias en TopBar
	pass

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
	var brush_style = _create_card_style(Color(0.95, 0.9, 1.0), Color(0.6, 0.45, 0.85))
	var soap_style = _create_card_style(Color(0.85, 0.96, 1.0), Color(0.3, 0.75, 0.9))
	var shower_style = _create_card_style(Color(0.85, 0.9, 1.0), Color(0.4, 0.6, 0.95))
	var lamp_style = _create_card_style(Color(0.88, 0.88, 0.98), Color(0.5, 0.5, 0.85))

	_refresh_kitchen_inventory()

	# Configurar acciones de baño
	if btn_toothbrush:
		btn_toothbrush.custom_minimum_size = Vector2(250, 180)
		btn_toothbrush.text = "🪥\n\nCepillar"
		btn_toothbrush.add_theme_font_size_override("font_size", 26)
		btn_toothbrush.add_theme_color_override("font_color", Color(0.35, 0.2, 0.5))
		btn_toothbrush.add_theme_stylebox_override("normal", brush_style)
		btn_toothbrush.pressed.connect(func():
			_spawn_draggable("toothbrush")
		)

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
	btn_lamp.text = "🌙\n\nDormir\n(1 hora)"
	btn_lamp.add_theme_font_size_override("font_size", 26)
	btn_lamp.add_theme_color_override("font_color", Color(0.25, 0.2, 0.45))
	btn_lamp.add_theme_stylebox_override("normal", lamp_style)
	btn_lamp.pressed.connect(func():
		if gm:
			gm.toggle_sleep()
	)

	# Configurar acciones de juego
	btn_ball.custom_minimum_size = Vector2(250, 180)
	btn_ball.text = "⚽\n\nLanzar Pelota"
	btn_ball.add_theme_font_size_override("font_size", 26)
	btn_ball.add_theme_color_override("font_color", Color(0.4, 0.25, 0.1))
	btn_ball.add_theme_stylebox_override("normal", ball_style)
	btn_ball.pressed.connect(func():
		if gm and gm.energy <= 0.0:
			gm.show_floating_text.emit("¡Sin energía! 🥱 Lleva a Monky a su cuarto a dormir 🛏️", Vector2(540, 850), Color(1.0, 0.45, 0.35))
			return
		_spawn_bouncing_ball()
	)

	btn_game.custom_minimum_size = Vector2(250, 180)
	btn_game.text = "🎮\n\nMinijuegos"
	btn_game.add_theme_font_size_override("font_size", 26)
	btn_game.add_theme_color_override("font_color", Color(0.3, 0.18, 0.5))
	btn_game.add_theme_stylebox_override("normal", game_style)
	btn_game.pressed.connect(func():
		if gm and gm.energy <= 0.0:
			gm.show_floating_text.emit("¡Monky está agotado! 🥱💤 Debe dormir en su cama 🛏️", Vector2(540, 850), Color(1.0, 0.45, 0.35))
			return
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

	# Botón 1: Abrir Mercado de Comidas
	var market_btn = Button.new()
	market_btn.custom_minimum_size = Vector2(200, 200)
	market_btn.text = "🛒\n\nMercado\n(Comprar)"
	market_btn.add_theme_font_size_override("font_size", 24)
	market_btn.add_theme_color_override("font_color", Color(0.1, 0.45, 0.25))
	market_btn.add_theme_stylebox_override("normal", _create_card_style(Color(0.85, 0.98, 0.88), Color(0.3, 0.75, 0.45)))
	market_btn.pressed.connect(_open_food_market)
	food_items_grid.add_child(market_btn)

	# Botón 2: Ficha de Nutrición / Proteínas
	var info_btn = Button.new()
	info_btn.custom_minimum_size = Vector2(200, 200)
	var p_val = int(gm.protein) if gm else 100
	info_btn.text = "🥩\n\nProteínas\n(" + str(p_val) + "%)"
	info_btn.add_theme_font_size_override("font_size", 24)
	info_btn.add_theme_color_override("font_color", Color(0.5, 0.2, 0.1))
	info_btn.add_theme_stylebox_override("normal", _create_card_style(Color(1.0, 0.9, 0.85), Color(0.85, 0.45, 0.3)))
	info_btn.pressed.connect(func():
		var first_food = gm.FOOD_CATALOG[0] if (gm and not gm.FOOD_CATALOG.is_empty()) else {}
		_open_food_details(first_food)
	)
	food_items_grid.add_child(info_btn)

	var catalog = gm.FOOD_CATALOG if gm else []
	var food_style = _create_card_style(Color(1.0, 0.96, 0.88), Color(0.8, 0.65, 0.4))

	var any_food_owned = false
	for food in catalog:
		var qty: int = gm.get_food_quantity(food.id) if gm else 0
		if qty > 0:
			any_food_owned = true
			
			# Tarjetas grandes y bonitas (200x200)
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
		desc_lbl.text = "+" + str(int(food.get("hunger", 15))) + "🍖  +" + str(int(food.get("protein", 10))) + "🥩  •  En nevera: " + str(qty)
		desc_lbl.add_theme_font_size_override("font_size", 24)
		desc_lbl.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95))
		vbox.add_child(desc_lbl)

		# Botón Detalles ℹ️
		var d_btn = Button.new()
		d_btn.custom_minimum_size = Vector2(130, 80)
		d_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		d_btn.text = "ℹ️ Info"
		d_btn.add_theme_font_size_override("font_size", 24)
		d_btn.add_theme_stylebox_override("normal", _create_card_style(Color(0.25, 0.35, 0.6), Color(1, 1, 1, 0.5)))
		d_btn.pressed.connect(func():
			_open_food_details(food)
		)
		hbox.add_child(d_btn)

		# Botón Comprar ➕
		var buy_btn = Button.new()
		buy_btn.custom_minimum_size = Vector2(190, 80)
		buy_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		buy_btn.text = "➕ " + str(food.price) + " 🪙"
		buy_btn.add_theme_font_size_override("font_size", 28)
		buy_btn.add_theme_stylebox_override("normal", _create_card_style(Color(0.2, 0.65, 0.35), Color(1, 1, 1, 0.6)))
		buy_btn.pressed.connect(func():
			if gm and gm.buy_food(food.id, 1):
				_update_market_balance()
				desc_lbl.text = "+" + str(int(food.get("hunger", 15))) + "🍖  +" + str(int(food.get("protein", 10))) + "🥩  •  En nevera: " + str(gm.get_food_quantity(food.id))
		)
		hbox.add_child(buy_btn)

		market_grid.add_child(item_card)

# Modal de Ficha Técnica de Alimentos
func _setup_food_details_popup() -> void:
	food_details_popup = Control.new()
	food_details_popup.name = "FoodDetailsPopup"
	food_details_popup.visible = false
	food_details_popup.z_index = 80
	food_details_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(food_details_popup)

	var backdrop = ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0, 0, 0, 0.7)
	food_details_popup.add_child(backdrop)

	var panel = PanelContainer.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(860, 800)
	panel.size = Vector2(860, 800)
	panel.position = Vector2(110, 560)
	panel.add_theme_stylebox_override("panel", _create_card_style(Color(0.16, 0.14, 0.24, 0.98), Color(0.85, 0.7, 0.35)))
	food_details_popup.add_child(panel)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_bottom", 32)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)

	# Header con navegación y botón cerrar
	var header_row = HBoxContainer.new()
	header_row.add_theme_constant_override("separation", 12)
	vbox.add_child(header_row)

	var prev_food_btn = Button.new()
	prev_food_btn.custom_minimum_size = Vector2(60, 60)
	prev_food_btn.text = "◀️"
	prev_food_btn.add_theme_font_size_override("font_size", 24)
	prev_food_btn.pressed.connect(func():
		_navigate_food_details(-1)
	)
	header_row.add_child(prev_food_btn)

	var title_top = Label.new()
	title_top.text = "📋 TABLA NUTRICIONAL REAL"
	title_top.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_top.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_top.add_theme_font_size_override("font_size", 30)
	title_top.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
	header_row.add_child(title_top)

	var next_food_btn = Button.new()
	next_food_btn.custom_minimum_size = Vector2(60, 60)
	next_food_btn.text = "▶️"
	next_food_btn.add_theme_font_size_override("font_size", 24)
	next_food_btn.pressed.connect(func():
		_navigate_food_details(1)
	)
	header_row.add_child(next_food_btn)

	var close_btn = Button.new()
	close_btn.custom_minimum_size = Vector2(60, 60)
	close_btn.text = "❌"
	close_btn.add_theme_font_size_override("font_size", 28)
	close_btn.pressed.connect(_close_food_details)
	header_row.add_child(close_btn)

	# Icono y Nombre
	var food_header = HBoxContainer.new()
	food_header.add_theme_constant_override("separation", 24)
	food_header.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(food_header)

	details_icon_label = Label.new()
	details_icon_label.text = "🐟"
	details_icon_label.add_theme_font_size_override("font_size", 80)
	food_header.add_child(details_icon_label)

	var name_box = VBoxContainer.new()
	name_box.alignment = BoxContainer.ALIGNMENT_CENTER
	details_title_label = Label.new()
	details_title_label.text = "Pescado (Proteínas)"
	details_title_label.add_theme_font_size_override("font_size", 34)
	details_title_label.add_theme_color_override("font_color", Color(1, 1, 1))
	name_box.add_child(details_title_label)
	food_header.add_child(name_box)

	# Valores Nutricionales Reales
	var stats_box = PanelContainer.new()
	stats_box.add_theme_stylebox_override("panel", _create_card_style(Color(0.22, 0.2, 0.3), Color(0.4, 0.4, 0.55)))
	var stats_margin = MarginContainer.new()
	stats_margin.add_theme_constant_override("margin_left", 20)
	stats_margin.add_theme_constant_override("margin_right", 20)
	stats_margin.add_theme_constant_override("margin_top", 14)
	stats_margin.add_theme_constant_override("margin_bottom", 14)
	stats_box.add_child(stats_margin)

	details_stats_label = Label.new()
	details_stats_label.text = "🥩 Proteína Real: 24.0g (+45%)\n🔥 Calorías: 175 kcal (+12%)\n🍖 Saciedad: +35%   |   ⭐ XP: +8 XP"
	details_stats_label.add_theme_font_size_override("font_size", 24)
	details_stats_label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	details_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_margin.add_child(details_stats_label)
	vbox.add_child(stats_box)

	# Nutrientes Clave y Descripción
	details_desc_label = Label.new()
	details_desc_label.text = "Descripción nutricional..."
	details_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details_desc_label.add_theme_font_size_override("font_size", 22)
	details_desc_label.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95))
	vbox.add_child(details_desc_label)

	# Botón comprar / acción rápida
	details_buy_btn = Button.new()
	details_buy_btn.custom_minimum_size = Vector2(0, 76)
	details_buy_btn.text = "🛒 Comprar por 22 🪙"
	details_buy_btn.add_theme_font_size_override("font_size", 28)
	details_buy_btn.add_theme_stylebox_override("normal", _create_card_style(Color(0.2, 0.65, 0.35), Color(1, 1, 1, 0.6)))
	details_buy_btn.pressed.connect(func():
		if gm and not current_inspected_food.is_empty():
			if gm.buy_food(current_inspected_food.id, 1):
				_update_food_details_view()
	)
	vbox.add_child(details_buy_btn)
	
	# Asegurar que inicie oculto
	food_details_popup.visible = false

func _navigate_food_details(dir: int) -> void:
	if not gm or gm.FOOD_CATALOG.is_empty():
		return
	var catalog = gm.FOOD_CATALOG
	var cur_idx = 0
	for i in range(catalog.size()):
		if catalog[i].id == current_inspected_food.get("id", ""):
			cur_idx = i
			break
	var next_idx = (cur_idx + dir) % catalog.size()
	if next_idx < 0:
		next_idx += catalog.size()
	current_inspected_food = catalog[next_idx]
	_update_food_details_view()

func _open_food_details(food_data: Dictionary) -> void:
	if food_data.is_empty() and gm and not gm.FOOD_CATALOG.is_empty():
		food_data = gm.FOOD_CATALOG[0]
	current_inspected_food = food_data
	_update_food_details_view()
	food_details_popup.visible = true
	var panel = food_details_popup.get_node("Panel")
	panel.scale = Vector2(0.7, 0.7)
	panel.pivot_offset = panel.size / 2.0
	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _update_food_details_view() -> void:
	if current_inspected_food.is_empty():
		return
	var f = current_inspected_food
	details_icon_label.text = f.get("icon", "🍎")
	details_title_label.text = f.get("name", "Comida") + "  (" + f.get("category", "General") + ")"
	
	var prot_g = f.get("protein_g", 0.0)
	var prot_bar = int(f.get("protein", 0))
	var cals = int(f.get("calories_kcal", 0))
	var energy_gain = int(f.get("energy", 0))
	var h_val = int(f.get("hunger", 15))
	var xp_val = int(f.get("xp", 4))
	var qty = gm.get_food_quantity(f.id) if gm else 0
	var nutrients = f.get("nutrients", "")

	details_stats_label.text = "🥩 Proteína Real: " + str(prot_g) + "g (+" + str(prot_bar) + "%)\n🔥 Calorías: " + str(cals) + " kcal (Energía: +" + str(energy_gain) + "%)\n🍖 Saciedad: +" + str(h_val) + "%   |   ⭐ XP: +" + str(xp_val) + "   |   En nevera: " + str(qty)
	
	var desc_text = f.get("desc", "")
	if nutrients != "":
		desc_text += "\n\n🧪 Nutrientes Clave: " + nutrients
	details_desc_label.text = desc_text
	details_buy_btn.text = "🛒 Comprar 1 unidad (" + str(f.get("price", 10)) + " 🪙)"

func _close_food_details() -> void:
	if not food_details_popup:
		return
	var panel = food_details_popup.get_node("Panel")
	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2(0.7, 0.7), 0.15).set_ease(Tween.EASE_IN)
	tween.finished.connect(func():
		food_details_popup.visible = false
	)

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
	# Estilos del Panel y Cabecera de la Tienda
	var panel = shop_popup.get_node_or_null("Panel")
	if panel:
		panel.add_theme_stylebox_override("panel", _create_card_style(Color(0.14, 0.12, 0.22, 0.98), Color(1.0, 0.85, 0.35)))

	var title_lbl = shop_popup.get_node_or_null("Panel/Margin/VBox/HeaderRow/Title")
	if title_lbl:
		title_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.3))

	if shop_coins_balance:
		shop_coins_balance.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
	if shop_diamonds_balance:
		shop_diamonds_balance.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0))

	if btn_close_shop:
		btn_close_shop.add_theme_stylebox_override("normal", _create_card_style(Color(0.28, 0.22, 0.36), Color(0.6, 0.5, 0.7)))

	var sec_iap = shop_popup.get_node_or_null("Panel/Margin/VBox/Scroll/ContentVBox/SecIapTitle")
	if sec_iap:
		sec_iap.add_theme_color_override("font_color", Color(0.45, 0.9, 1.0))

	var sec_exch = shop_popup.get_node_or_null("Panel/Margin/VBox/Scroll/ContentVBox/SecExchangeTitle")
	if sec_exch:
		sec_exch.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))

	var sec_pots = shop_popup.get_node_or_null("Panel/Margin/VBox/Scroll/ContentVBox/SecPotionsTitle")
	if sec_pots:
		sec_pots.add_theme_color_override("font_color", Color(1.0, 0.55, 0.88))

	var sec_rew = shop_popup.get_node_or_null("Panel/Margin/VBox/Scroll/ContentVBox/SecRewardsTitle")
	if sec_rew:
		sec_rew.add_theme_color_override("font_color", Color(0.5, 1.0, 0.6))

	# Estilos de Packs IAP (Diamantes)
	if btn_iap_50:
		btn_iap_50.add_theme_stylebox_override("normal", _create_card_style(Color(0.22, 0.16, 0.38), Color(0.5, 0.8, 1.0)))
		btn_iap_50.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	if btn_iap_300:
		btn_iap_300.add_theme_stylebox_override("normal", _create_card_style(Color(0.28, 0.18, 0.48), Color(0.6, 0.9, 1.0)))
		btn_iap_300.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	if btn_iap_1000:
		btn_iap_1000.add_theme_stylebox_override("normal", _create_card_style(Color(0.35, 0.20, 0.58), Color(1.0, 0.7, 0.95)))
		btn_iap_1000.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))

	# Estilos de Canje por Monedas
	if btn_exch_250:
		btn_exch_250.add_theme_stylebox_override("normal", _create_card_style(Color(0.24, 0.22, 0.12), Color(1.0, 0.8, 0.3)))
		btn_exch_250.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	if btn_exch_1000:
		btn_exch_1000.add_theme_stylebox_override("normal", _create_card_style(Color(0.3, 0.26, 0.14), Color(1.0, 0.85, 0.35)))
		btn_exch_1000.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	if btn_exch_3500:
		btn_exch_3500.add_theme_stylebox_override("normal", _create_card_style(Color(0.38, 0.3, 0.15), Color(1.0, 0.9, 0.4)))
		btn_exch_3500.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))

	# Estilos de Pociones Mágicas
	if btn_pot_energy:
		btn_pot_energy.add_theme_stylebox_override("normal", _create_card_style(Color(0.75, 0.55, 0.12), Color(1.0, 0.85, 0.35)))
		btn_pot_energy.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))

	if btn_pot_hygiene:
		btn_pot_hygiene.add_theme_stylebox_override("normal", _create_card_style(Color(0.18, 0.55, 0.72), Color(0.45, 0.85, 1.0)))
		btn_pot_hygiene.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))

	if btn_pot_mega:
		btn_pot_mega.add_theme_stylebox_override("normal", _create_card_style(Color(0.68, 0.22, 0.72), Color(1.0, 0.65, 0.95)))
		btn_pot_mega.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))

	# Estilos de Recompensas
	if btn_pack_daily:
		btn_pack_daily.add_theme_stylebox_override("normal", _create_card_style(Color(0.85, 0.45, 0.18), Color(1.0, 0.75, 0.35)))
		btn_pack_daily.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))

	if btn_pack_ad:
		btn_pack_ad.add_theme_stylebox_override("normal", _create_card_style(Color(0.45, 0.3, 0.75), Color(0.75, 0.55, 0.98)))
		btn_pack_ad.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))

	# Conexiones de apertura y cierre
	if btn_coins:
		btn_coins.pressed.connect(_open_shop)
	if btn_diamonds:
		btn_diamonds.pressed.connect(_open_shop)
	if btn_close_shop:
		btn_close_shop.pressed.connect(_close_shop)

	# Conexiones IAP Diamantes ($ USD)
	if btn_iap_50:
		btn_iap_50.pressed.connect(func(): _prompt_iap_purchase(50, 0.99, "Bolsita de Gemas"))
	if btn_iap_300:
		btn_iap_300.pressed.connect(func(): _prompt_iap_purchase(300, 2.99, "Cofre de Gemas"))
	if btn_iap_1000:
		btn_iap_1000.pressed.connect(func(): _prompt_iap_purchase(1000, 7.99, "Bóveda de Gemas"))

	# Conexiones Canje Diamantes -> Monedas
	if btn_exch_250:
		btn_exch_250.pressed.connect(func(): _exchange_diamonds_for_coins(10, 250))
	if btn_exch_1000:
		btn_exch_1000.pressed.connect(func(): _exchange_diamonds_for_coins(30, 1000))
	if btn_exch_3500:
		btn_exch_3500.pressed.connect(func(): _exchange_diamonds_for_coins(80, 3500))

	# Conexiones Pociones
	if btn_pot_energy:
		btn_pot_energy.pressed.connect(func(): _buy_potion("energy", 80, 4))
	if btn_pot_hygiene:
		btn_pot_hygiene.pressed.connect(func(): _buy_potion("hygiene", 60, 3))
	if btn_pot_mega:
		btn_pot_mega.pressed.connect(func(): _buy_potion("mega", 200, 10))

	# Conexiones Recompensas
	if btn_pack_daily:
		btn_pack_daily.pressed.connect(_claim_daily_reward)
	if btn_pack_ad:
		btn_pack_ad.pressed.connect(_claim_ad_reward)

	_setup_iap_confirm_popup()

func _open_shop() -> void:
	_update_shop_balance()
	_update_shop_timers()
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
	if not gm:
		return
	if shop_coins_balance:
		shop_coins_balance.text = str(gm.coins) + " 🪙"
	if shop_diamonds_balance:
		shop_diamonds_balance.text = str(gm.diamonds) + " 💎"

func _update_shop_timers() -> void:
	if not gm:
		return
	var now: int = int(Time.get_unix_time_from_system())

	# Recompensa Diaria (24 Horas = 86,400 seg)
	if btn_pack_daily:
		if gm.last_daily_reward_time == 0 or (now - gm.last_daily_reward_time) >= 86400:
			btn_pack_daily.text = "🎁 Recompensa Diaria\n+20 🪙  +1 💎\n[¡RECLAMAR!]"
			btn_pack_daily.modulate = Color(1.0, 1.0, 1.0)
		else:
			var wait_sec: int = maxi(0, 86400 - (now - gm.last_daily_reward_time))
			var h: int = wait_sec / 3600
			var m: int = (wait_sec % 3600) / 60
			var s: int = wait_sec % 60
			btn_pack_daily.text = "🎁 Recompensa Diaria\n⏳ En %02dh %02dm %02ds\n[ESPERA]" % [h, m, s]
			btn_pack_daily.modulate = Color(0.7, 0.7, 0.7)

	# Anuncio (2 Minutos = 120 seg)
	if btn_pack_ad:
		if gm.last_ad_reward_time == 0 or (now - gm.last_ad_reward_time) >= 120:
			btn_pack_ad.text = "🎬 Ver Anuncio\n+15 🪙\n[VER VIDEO]"
			btn_pack_ad.modulate = Color(1.0, 1.0, 1.0)
		else:
			var wait_sec: int = maxi(0, 120 - (now - gm.last_ad_reward_time))
			var m: int = wait_sec / 60
			var s: int = wait_sec % 60
			btn_pack_ad.text = "🎬 Ver Anuncio\n⏳ Espera %02d:%02d\n[ESPERA]" % [m, s]
			btn_pack_ad.modulate = Color(0.7, 0.7, 0.7)

func _claim_daily_reward() -> void:
	if not gm:
		return
	var now: int = int(Time.get_unix_time_from_system())
	if gm.last_daily_reward_time == 0 or (now - gm.last_daily_reward_time) >= 86400:
		gm.last_daily_reward_time = now
		gm.add_coins(20)
		gm.add_diamonds(1)
		gm.save_game()
		_update_shop_balance()
		_update_shop_timers()
		gm.show_floating_text.emit("🎁 ¡Recompensa Diaria: +20🪙 +1💎!", Vector2(540, 850), Color(1.0, 0.85, 0.2))
	else:
		var wait_sec: int = maxi(0, 86400 - (now - gm.last_daily_reward_time))
		var h: int = wait_sec / 3600
		var m: int = (wait_sec % 3600) / 60
		gm.show_floating_text.emit("⏳ Vuelve en %02dh %02dm" % [h, m], Vector2(540, 850), Color(1.0, 0.6, 0.3))

func _claim_ad_reward() -> void:
	if not gm:
		return
	var now: int = int(Time.get_unix_time_from_system())
	if gm.last_ad_reward_time == 0 or (now - gm.last_ad_reward_time) >= 120:
		gm.last_ad_reward_time = now
		gm.add_coins(15)
		gm.save_game()
		_update_shop_balance()
		_update_shop_timers()
		gm.show_floating_text.emit("🎬 ¡Video completado: +15 🪙!", Vector2(540, 850), Color(0.4, 1.0, 0.6))
	else:
		var wait_sec: int = maxi(0, 120 - (now - gm.last_ad_reward_time))
		var m: int = wait_sec / 60
		var s: int = wait_sec % 60
		gm.show_floating_text.emit("⏳ Espera %02d:%02d" % [m, s], Vector2(540, 850), Color(1.0, 0.6, 0.3))

func _exchange_diamonds_for_coins(gem_cost: int, coin_gain: int) -> void:
	if not gm:
		return
	if gm.spend_diamonds(gem_cost):
		gm.add_coins(coin_gain)
		gm.save_game()
		_update_shop_balance()
		gm.show_floating_text.emit("✨ ¡Canje exitoso! +" + str(coin_gain) + " 🪙", Vector2(540, 850), Color(1.0, 0.85, 0.2))
	else:
		gm.show_floating_text.emit("❌ Necesitas " + str(gem_cost) + " 💎", Vector2(540, 850), Color(1.0, 0.4, 0.4))

func _buy_potion(pot_type: String, coin_cost: int, gem_cost: int) -> void:
	if not gm:
		return
	var paid: bool = false
	var payment_msg: String = ""

	if gm.spend_coins(coin_cost):
		paid = true
		payment_msg = " (-" + str(coin_cost) + " 🪙)"
	elif gm.spend_diamonds(gem_cost):
		paid = true
		payment_msg = " (-" + str(gem_cost) + " 💎)"

	if not paid:
		gm.show_floating_text.emit("❌ Requiere " + str(coin_cost) + " 🪙 ó " + str(gem_cost) + " 💎", Vector2(540, 850), Color(1.0, 0.4, 0.4))
		return

	match pot_type:
		"energy":
			gm.energy = 100.0
			gm.show_floating_text.emit("⚡ ¡Energía al 100%!" + payment_msg, Vector2(540, 900), Color(1.0, 0.9, 0.2))
		"hygiene":
			gm.hygiene = 100.0
			gm.show_floating_text.emit("🧼 ¡Higiene al 100%!" + payment_msg, Vector2(540, 900), Color(0.3, 0.9, 1.0))
		"mega":
			gm.hunger = 100.0
			gm.protein = 100.0
			gm.energy = 100.0
			gm.fun = 100.0
			gm.hygiene = 100.0
			gm.show_floating_text.emit("🌟 ¡Poción Suprema Usada!" + payment_msg, Vector2(540, 900), Color(1.0, 0.4, 1.0))

	gm.save_game()
	_update_shop_balance()

# Modal IAP Simulado para Comprar Diamantes
func _setup_iap_confirm_popup() -> void:
	iap_confirm_popup = Control.new()
	iap_confirm_popup.name = "IapConfirmPopup"
	iap_confirm_popup.visible = false
	iap_confirm_popup.z_index = 90
	iap_confirm_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(iap_confirm_popup)

	var backdrop = ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0, 0, 0, 0.8)
	backdrop.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			iap_confirm_popup.visible = false
	)
	iap_confirm_popup.add_child(backdrop)

	var panel = PanelContainer.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(800, 520)
	panel.size = Vector2(800, 520)
	panel.position = Vector2(140, 700)
	panel.add_theme_stylebox_override("panel", _create_card_style(Color(0.16, 0.12, 0.25, 0.98), Color(0.4, 0.85, 1.0)))
	iap_confirm_popup.add_child(panel)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_bottom", 32)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	vbox.add_theme_constant_override("separation", 24)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox)

	var title = Label.new()
	title.name = "Title"
	title.text = "💳 TIENDA OFICIAL (IAP SIMULADO)"
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var desc = Label.new()
	desc.name = "Desc"
	desc.text = "¿Deseas adquirir este paquete de Diamantes?"
	desc.add_theme_font_size_override("font_size", 24)
	desc.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(desc)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	var btn_cancel = Button.new()
	btn_cancel.custom_minimum_size = Vector2(280, 80)
	btn_cancel.text = "❌ Cancelar"
	btn_cancel.add_theme_font_size_override("font_size", 28)
	btn_cancel.add_theme_stylebox_override("normal", _create_card_style(Color(0.3, 0.3, 0.4), Color(0.6, 0.6, 0.7)))
	btn_cancel.pressed.connect(func():
		iap_confirm_popup.visible = false
	)
	hbox.add_child(btn_cancel)

	var btn_confirm = Button.new()
	btn_confirm.name = "BtnConfirm"
	btn_confirm.custom_minimum_size = Vector2(280, 80)
	btn_confirm.text = "💳 Comprar"
	btn_confirm.add_theme_font_size_override("font_size", 28)
	btn_confirm.add_theme_stylebox_override("normal", _create_card_style(Color(0.18, 0.6, 0.35), Color(0.4, 0.95, 0.55)))
	btn_confirm.pressed.connect(func():
		if gm and not current_iap_pack.is_empty():
			var gems = current_iap_pack.get("gems", 0)
			var price = current_iap_pack.get("price", 0.0)
			gm.add_diamonds(gems)
			gm.save_game()
			_update_shop_balance()
			gm.show_floating_text.emit("💎 ¡+" + str(gems) + " Diamantes Comprados!", Vector2(540, 800), Color(0.4, 0.9, 1.0))
		iap_confirm_popup.visible = false
	)
	hbox.add_child(btn_confirm)
	vbox.add_child(hbox)

func _prompt_iap_purchase(gems: int, price: float, pack_name: String) -> void:
	current_iap_pack = {
		"gems": gems,
		"price": price,
		"name": pack_name
	}
	if not iap_confirm_popup:
		return
	var desc = iap_confirm_popup.get_node_or_null("Panel/Margin/VBox/Desc")
	if desc:
		desc.text = "Paquete: " + pack_name + "\nRecibes: 💎 " + str(gems) + " Diamantes\nPrecio: $" + str(price) + " USD\n\n¿Confirmar transacción simulada?"
	var btn_conf = iap_confirm_popup.get_node_or_null("Panel/Margin/VBox/HBox/BtnConfirm")
	if btn_conf:
		btn_conf.text = "💳 Pagar $" + str(price)
	
	iap_confirm_popup.visible = true
	var panel = iap_confirm_popup.get_node("Panel")
	panel.scale = Vector2(0.6, 0.6)
	panel.pivot_offset = panel.size / 2.0
	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_stat_changed(stat_name: String, current_value: float, max_value: float) -> void:
	_update_stat_ui(stat_name, current_value, max_value)

func _update_stat_ui(stat_name: String, value: float, max_val: float) -> void:
	var target_bar: ProgressBar = null
	var target_label: Label = null

	match stat_name:
		"hunger":
			target_bar = hunger_bar
			target_label = hunger_label
		"protein":
			target_bar = protein_bar
			target_label = protein_label
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
			match stat_name:
				"hunger":
					target_label.text = "🍎 " + str(int(value)) + "%"
				"protein":
					target_label.text = "🥩 " + str(int(value)) + "%"
				"energy":
					target_label.text = "⚡ " + str(int(value)) + "%"
				"fun":
					target_label.text = "⚽ " + str(int(value)) + "%"
				"hygiene":
					target_label.text = "🧼 " + str(int(value)) + "%"

func _on_coins_changed(new_coins: int) -> void:
	if coins_label:
		coins_label.text = str(new_coins)
	_update_shop_balance()
	_update_market_balance()

func _on_diamonds_changed(new_diamonds: int) -> void:
	if diamonds_label:
		diamonds_label.text = str(new_diamonds)
	_update_shop_balance()

func _on_xp_changed(cur_xp: float, max_xp: float, lvl: int) -> void:
	level_label.text = "⭐ NIV. " + str(lvl)
	xp_bar.max_value = max_xp
	xp_bar.value = cur_xp

func _on_level_up(new_level: int) -> void:
	level_popup_label.text = "¡Monky ha alcanzado el Nivel " + str(new_level) + "!\nHas ganado " + str(new_level * 5) + " 🪙 y +1 💎 de bonificación."
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

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if iap_confirm_popup and iap_confirm_popup.visible:
			iap_confirm_popup.visible = false
		elif confirm_reset_popup and confirm_reset_popup.visible:
			confirm_reset_popup.visible = false
		elif settings_popup and settings_popup.visible:
			_close_settings_modal()
		elif food_details_popup and food_details_popup.visible:
			food_details_popup.visible = false
		elif food_market_popup and food_market_popup.visible:
			_close_food_market()
		elif shop_popup and shop_popup.visible:
			_close_shop()
		else:
			_open_settings_modal()

# Modal de Ajustes y Configuración del Juego
func _setup_settings_modal() -> void:
	settings_popup = Control.new()
	settings_popup.name = "SettingsPopup"
	settings_popup.visible = false
	settings_popup.z_index = 85
	settings_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(settings_popup)

	var backdrop = ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0, 0, 0, 0.75)
	backdrop.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			_close_settings_modal()
	)
	settings_popup.add_child(backdrop)

	var panel = PanelContainer.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(880, 920)
	panel.size = Vector2(880, 920)
	panel.position = Vector2(100, 500)
	panel.add_theme_stylebox_override("panel", _create_card_style(Color(0.15, 0.12, 0.22, 0.98), Color(1.0, 0.85, 0.35)))
	settings_popup.add_child(panel)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_bottom", 32)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 18)
	margin.add_child(vbox)

	# Cabecera
	var header = HBoxContainer.new()
	var title = Label.new()
	title.text = "⚙️ AJUSTES Y OPCIONES"
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.3))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var btn_close = Button.new()
	btn_close.custom_minimum_size = Vector2(70, 70)
	btn_close.text = "✖️"
	btn_close.add_theme_font_size_override("font_size", 28)
	btn_close.add_theme_stylebox_override("normal", _create_card_style(Color(0.28, 0.22, 0.36), Color(0.6, 0.5, 0.7)))
	btn_close.pressed.connect(_close_settings_modal)
	header.add_child(btn_close)
	vbox.add_child(header)

	# Separador visual
	var sep = HSeparator.new()
	vbox.add_child(sep)

	# Opción 1: Sonido SFX
	btn_toggle_sfx = Button.new()
	btn_toggle_sfx.custom_minimum_size = Vector2(0, 85)
	btn_toggle_sfx.add_theme_font_size_override("font_size", 28)
	btn_toggle_sfx.pressed.connect(func():
		if gm:
			gm.sfx_enabled = !gm.sfx_enabled
			gm.save_game()
			_update_settings_ui()
	)
	vbox.add_child(btn_toggle_sfx)

	# Opción 2: Música de Fondo
	btn_toggle_music = Button.new()
	btn_toggle_music.custom_minimum_size = Vector2(0, 85)
	btn_toggle_music.add_theme_font_size_override("font_size", 28)
	btn_toggle_music.pressed.connect(func():
		if gm:
			gm.music_enabled = !gm.music_enabled
			gm.save_game()
			_update_settings_ui()
	)
	vbox.add_child(btn_toggle_music)

	# Opción 3: Vibración Háptica
	btn_toggle_vib = Button.new()
	btn_toggle_vib.custom_minimum_size = Vector2(0, 85)
	btn_toggle_vib.add_theme_font_size_override("font_size", 28)
	btn_toggle_vib.pressed.connect(func():
		if gm:
			gm.vibration_enabled = !gm.vibration_enabled
			gm.save_game()
			_update_settings_ui()
	)
	vbox.add_child(btn_toggle_vib)

	# Opción 4: Reiniciar Mascota
	var btn_reset = Button.new()
	btn_reset.custom_minimum_size = Vector2(0, 85)
	btn_reset.text = "🔄 Reiniciar Mascota (Borrar Datos)"
	btn_reset.add_theme_font_size_override("font_size", 26)
	btn_reset.add_theme_color_override("font_color", Color(1.0, 0.9, 0.8))
	btn_reset.add_theme_stylebox_override("normal", _create_card_style(Color(0.65, 0.35, 0.2), Color(0.9, 0.55, 0.3)))
	btn_reset.pressed.connect(func():
		_open_confirm_reset()
	)
	vbox.add_child(btn_reset)

	# Opción 6: Salir del Juego
	var btn_quit = Button.new()
	btn_quit.custom_minimum_size = Vector2(0, 95)
	btn_quit.text = "🚪 Salir del Juego"
	btn_quit.add_theme_font_size_override("font_size", 30)
	btn_quit.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	btn_quit.add_theme_stylebox_override("normal", _create_card_style(Color(0.8, 0.22, 0.22), Color(1.0, 0.5, 0.5)))
	btn_quit.pressed.connect(func():
		if gm:
			gm.save_game()
		get_tree().quit()
	)
	vbox.add_child(btn_quit)

	# Pie de información de versión
	var version_lbl = Label.new()
	version_lbl.text = "Wonky / Monky Virtual Pet • v1.2.0\nPair Programming with DeepMind Antigravity"
	version_lbl.add_theme_font_size_override("font_size", 20)
	version_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.75))
	version_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(version_lbl)

	_setup_confirm_reset_popup()
	_update_settings_ui()

func _update_settings_ui() -> void:
	if not gm:
		return
	if btn_toggle_sfx:
		var sfx_on = gm.sfx_enabled
		btn_toggle_sfx.text = "🔊 Efectos de Sonido: " + ("ACTIVADOS" if sfx_on else "SILENCIADOS")
		var bg_c = Color(0.2, 0.6, 0.35) if sfx_on else Color(0.35, 0.3, 0.4)
		var bd_c = Color(0.4, 0.9, 0.55) if sfx_on else Color(0.6, 0.55, 0.65)
		btn_toggle_sfx.add_theme_stylebox_override("normal", _create_card_style(bg_c, bd_c))

	if btn_toggle_music:
		var mus_on = gm.music_enabled
		btn_toggle_music.text = "🎵 Música de Fondo: " + ("ACTIVADA" if mus_on else "SILENCIADA")
		var bg_c = Color(0.35, 0.3, 0.7) if mus_on else Color(0.35, 0.3, 0.4)
		var bd_c = Color(0.65, 0.55, 0.95) if mus_on else Color(0.6, 0.55, 0.65)
		btn_toggle_music.add_theme_stylebox_override("normal", _create_card_style(bg_c, bd_c))

	if btn_toggle_vib:
		var vib_on = gm.vibration_enabled
		btn_toggle_vib.text = "📳 Vibración Háptica: " + ("ACTIVADA" if vib_on else "DESACTIVADA")
		var bg_c = Color(0.7, 0.5, 0.2) if vib_on else Color(0.35, 0.3, 0.4)
		var bd_c = Color(0.95, 0.75, 0.3) if vib_on else Color(0.6, 0.55, 0.65)
		btn_toggle_vib.add_theme_stylebox_override("normal", _create_card_style(bg_c, bd_c))

func _open_settings_modal() -> void:
	if not settings_popup:
		return
	_update_settings_ui()
	settings_popup.visible = true
	var panel = settings_popup.get_node("Panel")
	panel.scale = Vector2(0.7, 0.7)
	panel.pivot_offset = panel.size / 2.0
	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _close_settings_modal() -> void:
	if not settings_popup:
		return
	var panel = settings_popup.get_node("Panel")
	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2(0.7, 0.7), 0.15).set_ease(Tween.EASE_IN)
	tween.finished.connect(func():
		settings_popup.visible = false
	)

func _setup_confirm_reset_popup() -> void:
	confirm_reset_popup = Control.new()
	confirm_reset_popup.name = "ConfirmResetPopup"
	confirm_reset_popup.visible = false
	confirm_reset_popup.z_index = 95
	confirm_reset_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(confirm_reset_popup)

	var backdrop = ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0, 0, 0, 0.8)
	confirm_reset_popup.add_child(backdrop)

	var panel = PanelContainer.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(800, 520)
	panel.size = Vector2(800, 520)
	panel.position = Vector2(140, 700)
	panel.add_theme_stylebox_override("panel", _create_card_style(Color(0.2, 0.1, 0.12, 0.98), Color(0.95, 0.3, 0.3)))
	confirm_reset_popup.add_child(panel)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_bottom", 32)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 24)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox)

	var title = Label.new()
	title.text = "⚠️ ¿REINICIAR MASCOTA?"
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var desc = Label.new()
	desc.text = "Esta acción borrará todas las monedas, comidas, nivel y estadísticas acumuladas para empezar desde el Nivel 1.\n\n¿Estás completamente seguro?"
	desc.add_theme_font_size_override("font_size", 24)
	desc.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(desc)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	var btn_cancel = Button.new()
	btn_cancel.custom_minimum_size = Vector2(280, 80)
	btn_cancel.text = "❌ Cancelar"
	btn_cancel.add_theme_font_size_override("font_size", 28)
	btn_cancel.add_theme_stylebox_override("normal", _create_card_style(Color(0.3, 0.3, 0.4), Color(0.6, 0.6, 0.7)))
	btn_cancel.pressed.connect(func():
		confirm_reset_popup.visible = false
	)
	hbox.add_child(btn_cancel)

	var btn_confirm = Button.new()
	btn_confirm.custom_minimum_size = Vector2(280, 80)
	btn_confirm.text = "🗑️ Sí, Reiniciar"
	btn_confirm.add_theme_font_size_override("font_size", 28)
	btn_confirm.add_theme_stylebox_override("normal", _create_card_style(Color(0.85, 0.25, 0.25), Color(1.0, 0.5, 0.5)))
	btn_confirm.pressed.connect(func():
		if gm:
			gm.reset_game_data()
			_update_stat_ui("hunger", gm.hunger, gm.MAX_STAT)
			_update_stat_ui("protein", gm.protein, gm.MAX_STAT)
			_update_stat_ui("energy", gm.energy, gm.MAX_STAT)
			_update_stat_ui("fun", gm.fun, gm.MAX_STAT)
			_update_stat_ui("hygiene", gm.hygiene, gm.MAX_STAT)
			_on_coins_changed(gm.coins)
			_on_xp_changed(gm.xp, gm.get_xp_needed(), gm.level)
			_refresh_kitchen_inventory()
			gm.show_floating_text.emit("¡Mascota reiniciada desde cero! 🐣", Vector2(540, 850), Color(0.4, 1.0, 0.5))
		confirm_reset_popup.visible = false
		_close_settings_modal()
	)
	hbox.add_child(btn_confirm)
	vbox.add_child(hbox)

func _open_confirm_reset() -> void:
	if not confirm_reset_popup:
		return
	confirm_reset_popup.visible = true
	var panel = confirm_reset_popup.get_node("Panel")
	panel.scale = Vector2(0.6, 0.6)
	panel.pivot_offset = panel.size / 2.0
	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
