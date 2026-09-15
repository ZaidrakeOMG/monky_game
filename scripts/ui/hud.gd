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
@onready var protein_bar: ProgressBar = $TopBar/VBox/StatsGrid/ProteinContainer/ProteinBar
@onready var energy_bar: ProgressBar = $TopBar/VBox/StatsGrid/EnergyContainer/EnergyBar
@onready var fun_bar: ProgressBar = $TopBar/VBox/StatsGrid/FunContainer/FunBar
@onready var hygiene_bar: ProgressBar = $TopBar/VBox/StatsGrid/HygieneContainer/HygieneBar

@onready var hunger_label: Label = $TopBar/VBox/StatsGrid/HungerContainer/Label
@onready var protein_label: Label = $TopBar/VBox/StatsGrid/ProteinContainer/Label
@onready var energy_label: Label = $TopBar/VBox/StatsGrid/EnergyContainer/Label
@onready var fun_label: Label = $TopBar/VBox/StatsGrid/FunContainer/Label
@onready var hygiene_label: Label = $TopBar/VBox/StatsGrid/HygieneContainer/Label

@onready var protein_container: VBoxContainer = $TopBar/VBox/StatsGrid/ProteinContainer

# Modal de Ficha Técnica / Detalles de Comida
var food_details_popup: Control = null
var details_icon_texture: TextureRect = null
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
var ui_refresh_accumulator: float = 0.0
var shop_refresh_accumulator: float = 0.0

const UI_ICON := {
	"hunger": "res://imagenes/opt/hud/hambre.png",
	"protein": "res://imagenes/opt/hud/proteina.png",
	"energy": "res://imagenes/opt/hud/sueno.png",
	"fun": "res://imagenes/opt/hud/diversion.png",
	"hygiene": "res://imagenes/opt/hud/higiene.png",
	"coin": "res://imagenes/opt/hud/moneda.png",
	"diamond": "res://imagenes/opt/hud/diamante.png",
	"level": "res://imagenes/opt/hud/nivel.png",
	"settings": "res://imagenes/opt/navegacion/configuracion.png",
	"plus": "res://imagenes/opt/navegacion/mas.png",
	"close": "res://imagenes/opt/navegacion/cerrar.png",
	"info": "res://imagenes/opt/navegacion/informacion.png",
	"market": "res://imagenes/opt/navegacion/mercado.png",
	"bed": "res://imagenes/opt/navegacion/habitacion.png",
	"kitchen": "res://imagenes/opt/navegacion/cocina.png",
	"bath": "res://imagenes/opt/navegacion/bano.png",
	"play": "res://imagenes/opt/navegacion/juegos.png",
	"sleep": "res://imagenes/opt/dormitorio/dormir.png",
	"wake": "res://imagenes/opt/dormitorio/despertar.png",
	"toothbrush": "res://imagenes/opt/bano/cepillo_dientes.png",
	"soap": "res://imagenes/opt/bano/jabon.png",
	"shower": "res://imagenes/opt/bano/ducha.png",
	"ball": "res://imagenes/opt/juegos/pelota.png",
	"minigames": "res://imagenes/opt/juegos/minijuegos.png",
	"daily": "res://imagenes/opt/tienda/regalo_diario.png",
	"ad": "res://imagenes/opt/tienda/anuncio.png",
	"coins_pack": "res://imagenes/opt/tienda/monedas_pack.png",
	"diamonds_pack": "res://imagenes/opt/tienda/diamantes_pack.png",
	"sound_on": "res://imagenes/opt/configuracion/sonido_on.png",
	"sound_off": "res://imagenes/opt/configuracion/sonido_off.png",
	"music_on": "res://imagenes/opt/configuracion/musica_on.png",
	"music_off": "res://imagenes/opt/configuracion/musica_off.png",
	"vibration_on": "res://imagenes/opt/configuracion/vibracion_on.png",
	"vibration_off": "res://imagenes/opt/configuracion/vibracion_off.png",
	"reset": "res://imagenes/opt/configuracion/reiniciar.png",
	"quit": "res://imagenes/opt/configuracion/salir.png"
}

func _ready() -> void:
	gm = get_tree().root.get_node_or_null("GameManager")
	_setup_visual_assets()
	_setup_protein_ui()
	_setup_food_details_popup()
	_style_sleep_bar()
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

func _process(delta: float) -> void:
	# Actualizaciones visuales limitadas para evitar trabajo innecesario en Android.
	ui_refresh_accumulator += delta
	if ui_refresh_accumulator >= 0.25:
		ui_refresh_accumulator = 0.0
		_update_sleep_button()

	if shop_popup and shop_popup.visible:
		shop_refresh_accumulator += delta
		if shop_refresh_accumulator >= 1.0:
			shop_refresh_accumulator = 0.0
			_update_shop_timers()

func _update_sleep_button() -> void:
	if not gm or not btn_lamp:
		return
	if gm.is_sleeping:
		var missing_energy: float = gm.MAX_STAT - gm.energy
		var seconds_remaining: int = maxi(0, int((missing_energy / gm.MAX_STAT) * gm.SLEEP_DURATION_SEC))
		var mins: int = seconds_remaining / 60
		var secs: int = seconds_remaining % 60
		_set_button_icon(btn_lamp, str(UI_ICON["wake"]), "Despertar\n(%02d:%02d)" % [mins, secs], 92)
	elif gm.energy <= 0.0:
		_set_button_icon(btn_lamp, str(UI_ICON["sleep"]), "A dormir\nAgotado", 92)
	else:
		_set_button_icon(btn_lamp, str(UI_ICON["sleep"]), "Dormir\n1 hora", 92)

func _setup_protein_ui() -> void:
	for bar in [hunger_bar, protein_bar, energy_bar, fun_bar, hygiene_bar]:
		if bar:
			bar.custom_minimum_size.y = 52
	for label in [hunger_label, protein_label, energy_label, fun_label, hygiene_label]:
		if label:
			label.add_theme_font_size_override("font_size", 25)
	if xp_bar:
		xp_bar.custom_minimum_size.y = 32

func _load_ui_texture(path: String) -> Texture2D:
	if path != "" and ResourceLoader.exists(path):
		return load(path)
	return null

func _set_button_icon(button: Button, image_path: String, label_text: String, icon_width: int = 72) -> void:
	if not button:
		return
	button.text = label_text
	button.icon = _load_ui_texture(image_path)
	button.expand_icon = true
	button.add_theme_constant_override("icon_max_width", icon_width)
	button.add_theme_constant_override("h_separation", 10)

func _replace_label_icon(label_node: Label, image_path: String, size_px: float) -> void:
	if not label_node or not label_node.get_parent():
		return
	var parent := label_node.get_parent()
	var icon_name := label_node.name + "Image"
	if parent.has_node(icon_name):
		label_node.visible = false
		return
	var tex := TextureRect.new()
	tex.name = icon_name
	tex.texture = _load_ui_texture(image_path)
	tex.custom_minimum_size = Vector2(size_px, size_px)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	parent.add_child(tex)
	parent.move_child(tex, label_node.get_index())
	label_node.visible = false

func _add_stat_icon(container: VBoxContainer, label_node: Label, image_path: String) -> void:
	if not container or not label_node:
		return
	if container.has_node("StatHeader"):
		return
	var header := HBoxContainer.new()
	header.name = "StatHeader"
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_theme_constant_override("separation", 6)
	container.add_child(header)
	container.move_child(header, 0)
	label_node.reparent(header)
	var tex := TextureRect.new()
	tex.texture = _load_ui_texture(image_path)
	tex.custom_minimum_size = Vector2(38, 38)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	header.add_child(tex)
	header.move_child(tex, 0)

func _setup_visual_assets() -> void:
	# Cabecera.
	level_label.text = "NIV. 1"
	var level_parent := level_label.get_parent()
	if level_parent and not level_parent.has_node("LevelHeader"):
		var level_header := HBoxContainer.new()
		level_header.name = "LevelHeader"
		level_header.alignment = BoxContainer.ALIGNMENT_BEGIN
		level_header.add_theme_constant_override("separation", 8)
		level_parent.add_child(level_header)
		level_parent.move_child(level_header, 0)
		level_label.reparent(level_header)
		var level_icon := TextureRect.new()
		level_icon.texture = _load_ui_texture(str(UI_ICON["level"]))
		level_icon.custom_minimum_size = Vector2(38, 38)
		level_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		level_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		level_header.add_child(level_icon)
		level_header.move_child(level_icon, 0)

	var coins_icon := get_node_or_null("TopBar/VBox/HeaderRow/BtnCoins/HBox/CoinsIcon") as Label
	var coins_plus := get_node_or_null("TopBar/VBox/HeaderRow/BtnCoins/HBox/PlusBadge") as Label
	var diamonds_icon := get_node_or_null("TopBar/VBox/HeaderRow/BtnDiamonds/HBox/DiamondsIcon") as Label
	var diamonds_plus := get_node_or_null("TopBar/VBox/HeaderRow/BtnDiamonds/HBox/PlusBadge") as Label
	_replace_label_icon(coins_icon, str(UI_ICON["coin"]), 42)
	_replace_label_icon(coins_plus, str(UI_ICON["plus"]), 30)
	_replace_label_icon(diamonds_icon, str(UI_ICON["diamond"]), 42)
	_replace_label_icon(diamonds_plus, str(UI_ICON["plus"]), 30)
	_set_button_icon(btn_settings, str(UI_ICON["settings"]), "", 52)

	# Barras de estado con imágenes reales.
	_add_stat_icon(hunger_label.get_parent() as VBoxContainer, hunger_label, str(UI_ICON["hunger"]))
	_add_stat_icon(protein_label.get_parent() as VBoxContainer, protein_label, str(UI_ICON["protein"]))
	_add_stat_icon(energy_label.get_parent() as VBoxContainer, energy_label, str(UI_ICON["energy"]))
	_add_stat_icon(fun_label.get_parent() as VBoxContainer, fun_label, str(UI_ICON["fun"]))
	_add_stat_icon(hygiene_label.get_parent() as VBoxContainer, hygiene_label, str(UI_ICON["hygiene"]))

	# Navegación principal.
	_set_button_icon(btn_bed, str(UI_ICON["bed"]), "Dormitorio", 76)
	_set_button_icon(btn_kitchen, str(UI_ICON["kitchen"]), "Cocina", 76)
	_set_button_icon(btn_bath, str(UI_ICON["bath"]), "Baño", 76)
	_set_button_icon(btn_play, str(UI_ICON["play"]), "Juegos", 76)

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

	if btn_toothbrush:
		btn_toothbrush.custom_minimum_size = Vector2(250, 180)
		_set_button_icon(btn_toothbrush, str(UI_ICON["toothbrush"]), "Cepillar", 88)
		btn_toothbrush.add_theme_font_size_override("font_size", 26)
		btn_toothbrush.add_theme_color_override("font_color", Color(0.35, 0.2, 0.5))
		btn_toothbrush.add_theme_stylebox_override("normal", brush_style)
		btn_toothbrush.pressed.connect(func(): _spawn_draggable("toothbrush"))

	if btn_soap:
		btn_soap.custom_minimum_size = Vector2(250, 180)
		_set_button_icon(btn_soap, str(UI_ICON["soap"]), "Enjabonar", 88)
		btn_soap.add_theme_font_size_override("font_size", 26)
		btn_soap.add_theme_color_override("font_color", Color(0.15, 0.35, 0.5))
		btn_soap.add_theme_stylebox_override("normal", soap_style)
		btn_soap.pressed.connect(func(): _spawn_draggable("soap"))

	if btn_shower:
		btn_shower.custom_minimum_size = Vector2(250, 180)
		_set_button_icon(btn_shower, str(UI_ICON["shower"]), "Enjuagar", 88)
		btn_shower.add_theme_font_size_override("font_size", 26)
		btn_shower.add_theme_color_override("font_color", Color(0.15, 0.3, 0.55))
		btn_shower.add_theme_stylebox_override("normal", shower_style)
		btn_shower.pressed.connect(func(): _spawn_draggable("shower"))

	if btn_lamp:
		btn_lamp.custom_minimum_size = Vector2(340, 180)
		btn_lamp.add_theme_font_size_override("font_size", 26)
		btn_lamp.add_theme_color_override("font_color", Color(0.25, 0.2, 0.45))
		btn_lamp.add_theme_stylebox_override("normal", lamp_style)
		_update_sleep_button()
		btn_lamp.pressed.connect(func():
			if gm:
				gm.toggle_sleep()
				_update_sleep_button()
		)

	if btn_ball:
		btn_ball.custom_minimum_size = Vector2(250, 180)
		_set_button_icon(btn_ball, str(UI_ICON["ball"]), "Lanzar pelota", 88)
		btn_ball.add_theme_font_size_override("font_size", 26)
		btn_ball.add_theme_color_override("font_color", Color(0.4, 0.25, 0.1))
		btn_ball.add_theme_stylebox_override("normal", ball_style)
		btn_ball.pressed.connect(func():
			if gm and gm.energy <= 0.0:
				gm.show_floating_text.emit("Sin energía. Lleva a Monky a dormir.", Vector2(540, 850), Color(1.0, 0.45, 0.35))
				return
			_spawn_bouncing_ball()
		)

	if btn_game:
		btn_game.custom_minimum_size = Vector2(300, 190)
		_set_button_icon(btn_game, str(UI_ICON["minigames"]), "", 150)
		btn_game.add_theme_stylebox_override("normal", game_style)
		btn_game.pressed.connect(_open_minigames_menu)

	if btn_close_level:
		btn_close_level.pressed.connect(func(): level_popup.visible = false)


func _open_minigames_menu() -> void:
	var menu_path := "res://scenes/minigames/minigames_menu.tscn"
	if not ResourceLoader.exists(menu_path):
		push_error("No se encontró el menú de minijuegos: " + menu_path)
		return
	var err := get_tree().change_scene_to_file(menu_path)
	if err != OK:
		push_error("No se pudo abrir el menú de minijuegos. Error: " + str(err))

func _refresh_kitchen_inventory() -> void:
	if not food_items_grid:
		return
	for child in food_items_grid.get_children():
		child.queue_free()

	var market_btn := Button.new()
	market_btn.custom_minimum_size = Vector2(210, 200)
	_set_button_icon(market_btn, str(UI_ICON["market"]), "Mercado\nComprar", 82)
	market_btn.add_theme_font_size_override("font_size", 24)
	market_btn.add_theme_color_override("font_color", Color(0.1, 0.45, 0.25))
	market_btn.add_theme_stylebox_override("normal", _create_card_style(Color(0.85, 0.98, 0.88), Color(0.3, 0.75, 0.45)))
	market_btn.pressed.connect(_open_food_market)
	food_items_grid.add_child(market_btn)

	var info_btn := Button.new()
	info_btn.custom_minimum_size = Vector2(210, 200)
	var p_val: int = int(gm.protein) if gm else 100
	_set_button_icon(info_btn, str(UI_ICON["protein"]), "Proteína\n" + str(p_val) + "%", 82)
	info_btn.add_theme_font_size_override("font_size", 24)
	info_btn.add_theme_color_override("font_color", Color(0.5, 0.2, 0.1))
	info_btn.add_theme_stylebox_override("normal", _create_card_style(Color(1.0, 0.9, 0.85), Color(0.85, 0.45, 0.3)))
	info_btn.pressed.connect(func():
		var first_food: Dictionary = gm.FOOD_CATALOG[0] if (gm and not gm.FOOD_CATALOG.is_empty()) else {}
		_open_food_details(first_food)
	)
	food_items_grid.add_child(info_btn)

	var catalog = gm.FOOD_CATALOG if gm else []
	var food_style = _create_card_style(Color(1.0, 0.96, 0.88), Color(0.8, 0.65, 0.4))
	var any_food_owned: bool = false

	for food in catalog:
		var qty: int = gm.get_food_quantity(food.id) if gm else 0
		if qty <= 0:
			continue
		any_food_owned = true
		var card := Button.new()
		card.custom_minimum_size = Vector2(210, 200)
		card.text = str(food.name) + "\nCantidad: " + str(qty)
		card.icon = _load_ui_texture(str(food.get("image", "")))
		card.expand_icon = true
		card.add_theme_constant_override("icon_max_width", 88)
		card.add_theme_constant_override("h_separation", 8)
		card.add_theme_font_size_override("font_size", 24)
		card.add_theme_color_override("font_color", Color(0.35, 0.22, 0.12))
		card.add_theme_stylebox_override("normal", food_style)
		card.pressed.connect(func(): _spawn_draggable("food", food))
		food_items_grid.add_child(card)

	if not any_food_owned:
		var empty_lbl := Label.new()
		empty_lbl.text = "Nevera vacía. Toca Mercado para comprar comida."
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
		market_balance_label.text = "Saldo: " + str(gm.coins) + " monedas"

func _populate_market_grid() -> void:
	if not market_grid:
		return
	for child in market_grid.get_children():
		child.queue_free()

	var catalog = gm.FOOD_CATALOG if gm else []
	for food in catalog:
		var item_card := PanelContainer.new()
		item_card.custom_minimum_size = Vector2(0, 150)
		item_card.add_theme_stylebox_override("panel", _create_card_style(Color(0.18, 0.15, 0.26, 0.95), Color(0.7, 0.55, 0.3)))

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 22)
		margin.add_theme_constant_override("margin_right", 22)
		margin.add_theme_constant_override("margin_top", 14)
		margin.add_theme_constant_override("margin_bottom", 14)
		item_card.add_child(margin)

		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 18)
		margin.add_child(hbox)

		var food_tex := TextureRect.new()
		food_tex.texture = _load_ui_texture(str(food.get("image", "")))
		food_tex.custom_minimum_size = Vector2(112, 112)
		food_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		food_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hbox.add_child(food_tex)

		var vbox := VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 5)
		hbox.add_child(vbox)

		var name_lbl := Label.new()
		name_lbl.text = str(food.name) + "  (" + str(food.category) + ")"
		name_lbl.add_theme_font_size_override("font_size", 29)
		name_lbl.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
		vbox.add_child(name_lbl)

		var qty: int = gm.get_food_quantity(food.id) if gm else 0
		var desc_lbl := Label.new()
		desc_lbl.text = "Comida +" + str(int(food.get("hunger", 15))) + "%   Proteína +" + str(int(food.get("protein", 10))) + "%   En nevera: " + str(qty)
		desc_lbl.add_theme_font_size_override("font_size", 22)
		desc_lbl.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95))
		vbox.add_child(desc_lbl)

		var d_btn := Button.new()
		d_btn.custom_minimum_size = Vector2(138, 82)
		d_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_set_button_icon(d_btn, str(UI_ICON["info"]), "Info", 46)
		d_btn.add_theme_font_size_override("font_size", 22)
		d_btn.add_theme_stylebox_override("normal", _create_card_style(Color(0.25, 0.35, 0.6), Color(1, 1, 1, 0.5)))
		d_btn.pressed.connect(func(): _open_food_details(food))
		hbox.add_child(d_btn)

		var buy_btn := Button.new()
		buy_btn.custom_minimum_size = Vector2(190, 82)
		buy_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_set_button_icon(buy_btn, str(UI_ICON["coin"]), str(food.price), 44)
		buy_btn.add_theme_font_size_override("font_size", 27)
		buy_btn.add_theme_stylebox_override("normal", _create_card_style(Color(0.2, 0.65, 0.35), Color(1, 1, 1, 0.6)))
		buy_btn.pressed.connect(func():
			if gm and gm.buy_food(food.id, 1):
				_update_market_balance()
				desc_lbl.text = "Comida +" + str(int(food.get("hunger", 15))) + "%   Proteína +" + str(int(food.get("protein", 10))) + "%   En nevera: " + str(gm.get_food_quantity(food.id))
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

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0, 0, 0, 0.7)
	food_details_popup.add_child(backdrop)

	var panel := PanelContainer.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(860, 800)
	panel.size = Vector2(860, 800)
	panel.position = Vector2(110, 560)
	panel.add_theme_stylebox_override("panel", _create_card_style(Color(0.16, 0.14, 0.24, 0.98), Color(0.85, 0.7, 0.35)))
	food_details_popup.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_bottom", 32)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)

	var header_row := HBoxContainer.new()
	header_row.add_theme_constant_override("separation", 12)
	vbox.add_child(header_row)

	var prev_food_btn := Button.new()
	prev_food_btn.custom_minimum_size = Vector2(110, 60)
	prev_food_btn.text = "Anterior"
	prev_food_btn.add_theme_font_size_override("font_size", 20)
	prev_food_btn.pressed.connect(func(): _navigate_food_details(-1))
	header_row.add_child(prev_food_btn)

	var title_top := Label.new()
	title_top.text = "TABLA NUTRICIONAL"
	title_top.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_top.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_top.add_theme_font_size_override("font_size", 30)
	title_top.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
	header_row.add_child(title_top)

	var next_food_btn := Button.new()
	next_food_btn.custom_minimum_size = Vector2(110, 60)
	next_food_btn.text = "Siguiente"
	next_food_btn.add_theme_font_size_override("font_size", 20)
	next_food_btn.pressed.connect(func(): _navigate_food_details(1))
	header_row.add_child(next_food_btn)

	var close_btn := Button.new()
	close_btn.custom_minimum_size = Vector2(70, 60)
	_set_button_icon(close_btn, str(UI_ICON["close"]), "", 46)
	close_btn.pressed.connect(_close_food_details)
	header_row.add_child(close_btn)

	var food_header := HBoxContainer.new()
	food_header.add_theme_constant_override("separation", 24)
	food_header.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(food_header)

	details_icon_texture = TextureRect.new()
	details_icon_texture.custom_minimum_size = Vector2(120, 120)
	details_icon_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	details_icon_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	food_header.add_child(details_icon_texture)

	var name_box := VBoxContainer.new()
	name_box.alignment = BoxContainer.ALIGNMENT_CENTER
	details_title_label = Label.new()
	details_title_label.text = "Pescado (Proteínas)"
	details_title_label.add_theme_font_size_override("font_size", 34)
	details_title_label.add_theme_color_override("font_color", Color(1, 1, 1))
	name_box.add_child(details_title_label)
	food_header.add_child(name_box)

	var stats_box := PanelContainer.new()
	stats_box.add_theme_stylebox_override("panel", _create_card_style(Color(0.22, 0.2, 0.3), Color(0.4, 0.4, 0.55)))
	var stats_margin := MarginContainer.new()
	stats_margin.add_theme_constant_override("margin_left", 20)
	stats_margin.add_theme_constant_override("margin_right", 20)
	stats_margin.add_theme_constant_override("margin_top", 14)
	stats_margin.add_theme_constant_override("margin_bottom", 14)
	stats_box.add_child(stats_margin)

	details_stats_label = Label.new()
	details_stats_label.text = "Proteína real: 24.0 g (+45%)\nCalorías: 175 kcal (Energía +12%)\nSaciedad: +35%   |   XP: +8"
	details_stats_label.add_theme_font_size_override("font_size", 24)
	details_stats_label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	details_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_margin.add_child(details_stats_label)
	vbox.add_child(stats_box)

	details_desc_label = Label.new()
	details_desc_label.text = "Descripción nutricional..."
	details_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details_desc_label.add_theme_font_size_override("font_size", 22)
	details_desc_label.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95))
	vbox.add_child(details_desc_label)

	details_buy_btn = Button.new()
	details_buy_btn.custom_minimum_size = Vector2(0, 82)
	_set_button_icon(details_buy_btn, str(UI_ICON["market"]), "Comprar por 22 monedas", 50)
	details_buy_btn.add_theme_font_size_override("font_size", 26)
	details_buy_btn.add_theme_stylebox_override("normal", _create_card_style(Color(0.2, 0.65, 0.35), Color(1, 1, 1, 0.6)))
	details_buy_btn.pressed.connect(func():
		if gm and not current_inspected_food.is_empty():
			if gm.buy_food(current_inspected_food.id, 1):
				_update_food_details_view()
	)
	vbox.add_child(details_buy_btn)
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
	if details_icon_texture:
		details_icon_texture.texture = _load_ui_texture(str(f.get("image", "")))
	details_title_label.text = str(f.get("name", "Comida")) + "  (" + str(f.get("category", "General")) + ")"

	var prot_g = f.get("protein_g", 0.0)
	var prot_bar: int = int(f.get("protein", 0))
	var cals: int = int(f.get("calories_kcal", 0))
	var energy_gain: int = int(f.get("energy", 0))
	var h_val: int = int(f.get("hunger", 15))
	var xp_val: int = int(f.get("xp", 4))
	var qty: int = gm.get_food_quantity(f.id) if gm else 0
	var nutrients: String = str(f.get("nutrients", ""))

	details_stats_label.text = "Proteína real: " + str(prot_g) + " g (+" + str(prot_bar) + "%)\nCalorías: " + str(cals) + " kcal (Energía +" + str(energy_gain) + "%)\nSaciedad: +" + str(h_val) + "%   |   XP: +" + str(xp_val) + "   |   En nevera: " + str(qty)

	var desc_text: String = str(f.get("desc", ""))
	if nutrients != "":
		desc_text += "\n\nNutrientes clave: " + nutrients
	details_desc_label.text = desc_text
	_set_button_icon(details_buy_btn, str(UI_ICON["market"]), "Comprar 1 unidad (" + str(f.get("price", 10)) + " monedas)", 50)

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
		gm.show_floating_text.emit("¡Patea o lanza la pelota a Monky!", Vector2(540, 720), Color(1, 0.85, 0.2))

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
		title_lbl.text = "TIENDA EXCLUSIVA"
		title_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.3))

	_set_button_icon(btn_close_shop, str(UI_ICON["close"]), "", 44)
	_set_button_icon(btn_iap_50, str(UI_ICON["diamonds_pack"]), "50 Diamantes\n$0.99 USD", 58)
	_set_button_icon(btn_iap_300, str(UI_ICON["diamonds_pack"]), "300 Diamantes\n$2.99 USD", 58)
	_set_button_icon(btn_iap_1000, str(UI_ICON["diamonds_pack"]), "1,000 Diamantes\n$7.99 USD", 58)
	_set_button_icon(btn_exch_250, str(UI_ICON["coins_pack"]), "+250 Monedas\nCosto: 10 diamantes", 58)
	_set_button_icon(btn_exch_1000, str(UI_ICON["coins_pack"]), "+1,000 Monedas\nCosto: 30 diamantes", 58)
	_set_button_icon(btn_exch_3500, str(UI_ICON["coins_pack"]), "+3,500 Monedas\nCosto: 80 diamantes", 58)
	_set_button_icon(btn_pot_energy, str(UI_ICON["energy"]), "Poción energía 100% — 80 monedas / 4 diamantes", 52)
	_set_button_icon(btn_pot_hygiene, str(UI_ICON["hygiene"]), "Poción higiene 100% — 60 monedas / 3 diamantes", 52)
	_set_button_icon(btn_pot_mega, str(UI_ICON["level"]), "Poción suprema — 200 monedas / 10 diamantes", 52)
	_set_button_icon(btn_pack_daily, str(UI_ICON["daily"]), "Recompensa diaria\n+20 monedas  +1 diamante", 62)
	_set_button_icon(btn_pack_ad, str(UI_ICON["ad"]), "Ver anuncio\n+15 monedas", 62)

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
		shop_coins_balance.text = str(gm.coins) + " monedas"
	if shop_diamonds_balance:
		shop_diamonds_balance.text = str(gm.diamonds) + " diamantes"

func _update_shop_timers() -> void:
	if not gm:
		return
	var now: int = int(Time.get_unix_time_from_system())

	# Recompensa Diaria (24 Horas = 86,400 seg)
	if btn_pack_daily:
		if gm.last_daily_reward_time == 0 or (now - gm.last_daily_reward_time) >= 86400:
			_set_button_icon(btn_pack_daily, str(UI_ICON["daily"]), "Recompensa diaria\n+20 monedas  +1 diamante\nRECLAMAR", 62)
			btn_pack_daily.modulate = Color(1.0, 1.0, 1.0)
		else:
			var wait_sec: int = maxi(0, 86400 - (now - gm.last_daily_reward_time))
			var h: int = wait_sec / 3600
			var m: int = (wait_sec % 3600) / 60
			var s: int = wait_sec % 60
			_set_button_icon(btn_pack_daily, str(UI_ICON["daily"]), "Recompensa diaria\nEn %02dh %02dm %02ds\nESPERA" % [h, m, s], 62)
			btn_pack_daily.modulate = Color(0.7, 0.7, 0.7)

	# Anuncio (2 Minutos = 120 seg)
	if btn_pack_ad:
		if gm.last_ad_reward_time == 0 or (now - gm.last_ad_reward_time) >= 120:
			_set_button_icon(btn_pack_ad, str(UI_ICON["ad"]), "Ver anuncio\n+15 monedas\nVER VIDEO", 62)
			btn_pack_ad.modulate = Color(1.0, 1.0, 1.0)
		else:
			var wait_sec: int = maxi(0, 120 - (now - gm.last_ad_reward_time))
			var m: int = wait_sec / 60
			var s: int = wait_sec % 60
			_set_button_icon(btn_pack_ad, str(UI_ICON["ad"]), "Ver anuncio\nEspera %02d:%02d\nESPERA" % [m, s], 62)
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
		gm.show_floating_text.emit("Recompensa diaria: +20 monedas +1 diamante", Vector2(540, 850), Color(1.0, 0.85, 0.2))
	else:
		var wait_sec: int = maxi(0, 86400 - (now - gm.last_daily_reward_time))
		var h: int = wait_sec / 3600
		var m: int = (wait_sec % 3600) / 60
		gm.show_floating_text.emit("Vuelve en %02dh %02dm" % [h, m], Vector2(540, 850), Color(1.0, 0.6, 0.3))

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
		gm.show_floating_text.emit("Video completado: +15 monedas", Vector2(540, 850), Color(0.4, 1.0, 0.6))
	else:
		var wait_sec: int = maxi(0, 120 - (now - gm.last_ad_reward_time))
		var m: int = wait_sec / 60
		var s: int = wait_sec % 60
		gm.show_floating_text.emit("Espera %02d:%02d" % [m, s], Vector2(540, 850), Color(1.0, 0.6, 0.3))

func _exchange_diamonds_for_coins(gem_cost: int, coin_gain: int) -> void:
	if not gm:
		return
	if gm.spend_diamonds(gem_cost):
		gm.add_coins(coin_gain)
		gm.save_game()
		_update_shop_balance()
		gm.show_floating_text.emit("Canje exitoso: +" + str(coin_gain) + " monedas", Vector2(540, 850), Color(1.0, 0.85, 0.2))
	else:
		gm.show_floating_text.emit("Necesitas " + str(gem_cost) + " diamantes", Vector2(540, 850), Color(1.0, 0.4, 0.4))

func _buy_potion(pot_type: String, coin_cost: int, gem_cost: int) -> void:
	if not gm:
		return
	var paid: bool = false
	var payment_msg: String = ""

	if gm.spend_coins(coin_cost):
		paid = true
		payment_msg = " (-" + str(coin_cost) + " monedas)"
	elif gm.spend_diamonds(gem_cost):
		paid = true
		payment_msg = " (-" + str(gem_cost) + " diamantes)"

	if not paid:
		gm.show_floating_text.emit("Requiere " + str(coin_cost) + " monedas o " + str(gem_cost) + " diamantes", Vector2(540, 850), Color(1.0, 0.4, 0.4))
		return

	match pot_type:
		"energy":
			gm.energy = 100.0
			gm.show_floating_text.emit("Energía al 100%" + payment_msg, Vector2(540, 900), Color(1.0, 0.9, 0.2))
		"hygiene":
			gm.hygiene = 100.0
			gm.show_floating_text.emit("Higiene al 100%" + payment_msg, Vector2(540, 900), Color(0.3, 0.9, 1.0))
		"mega":
			gm.hunger = 100.0
			gm.protein = 100.0
			gm.energy = 100.0
			gm.fun = 100.0
			gm.hygiene = 100.0
			gm.show_floating_text.emit("Poción suprema usada" + payment_msg, Vector2(540, 900), Color(1.0, 0.4, 1.0))

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
	title.text = "TIENDA OFICIAL (IAP SIMULADO)"
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
	hbox.name = "HBox"
	hbox.add_theme_constant_override("separation", 20)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	var btn_cancel = Button.new()
	btn_cancel.custom_minimum_size = Vector2(280, 80)
	_set_button_icon(btn_cancel, str(UI_ICON["close"]), "Cancelar", 44)
	btn_cancel.add_theme_font_size_override("font_size", 28)
	btn_cancel.add_theme_stylebox_override("normal", _create_card_style(Color(0.3, 0.3, 0.4), Color(0.6, 0.6, 0.7)))
	btn_cancel.pressed.connect(func():
		iap_confirm_popup.visible = false
	)
	hbox.add_child(btn_cancel)

	var btn_confirm = Button.new()
	btn_confirm.name = "BtnConfirm"
	btn_confirm.custom_minimum_size = Vector2(280, 80)
	_set_button_icon(btn_confirm, str(UI_ICON["diamond"]), "Comprar", 44)
	btn_confirm.add_theme_font_size_override("font_size", 28)
	btn_confirm.add_theme_stylebox_override("normal", _create_card_style(Color(0.18, 0.6, 0.35), Color(0.4, 0.95, 0.55)))
	btn_confirm.pressed.connect(func():
		if gm and not current_iap_pack.is_empty():
			var gems = current_iap_pack.get("gems", 0)
			var price = current_iap_pack.get("price", 0.0)
			gm.add_diamonds(gems)
			gm.save_game()
			_update_shop_balance()
			gm.show_floating_text.emit("+" + str(gems) + " diamantes comprados", Vector2(540, 800), Color(0.4, 0.9, 1.0))
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
		desc.text = "Paquete: " + pack_name + "\nRecibes: " + str(gems) + " diamantes\nPrecio: $" + str(price) + " USD\n\n¿Confirmar transacción simulada?"
	var btn_conf: Button = iap_confirm_popup.get_node_or_null("Panel/Margin/VBox/HBox/BtnConfirm") as Button
	if btn_conf:
		_set_button_icon(btn_conf, str(UI_ICON["diamond"]), "Pagar $" + str(price), 44)
	
	iap_confirm_popup.visible = true
	var panel = iap_confirm_popup.get_node("Panel")
	panel.scale = Vector2(0.6, 0.6)
	panel.pivot_offset = panel.size / 2.0
	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _style_sleep_bar() -> void:
	# Barra de sueño/energía con estilo redondeado y tonos nocturnos.
	var sleep_background := StyleBoxFlat.new()
	sleep_background.bg_color = Color("#211D38")
	sleep_background.corner_radius_top_left = 10
	sleep_background.corner_radius_top_right = 10
	sleep_background.corner_radius_bottom_left = 10
	sleep_background.corner_radius_bottom_right = 10
	sleep_background.border_width_left = 2
	sleep_background.border_width_top = 2
	sleep_background.border_width_right = 2
	sleep_background.border_width_bottom = 2
	sleep_background.border_color = Color("#7868B8")

	var sleep_fill := StyleBoxFlat.new()
	sleep_fill.bg_color = Color("#9B8CFF")
	sleep_fill.corner_radius_top_left = 8
	sleep_fill.corner_radius_top_right = 8
	sleep_fill.corner_radius_bottom_left = 8
	sleep_fill.corner_radius_bottom_right = 8

	energy_bar.add_theme_stylebox_override("background", sleep_background)
	energy_bar.add_theme_stylebox_override("fill", sleep_fill)
	energy_bar.custom_minimum_size.y = 52
	energy_label.add_theme_color_override("font_color", Color("#E9E4FF"))
	energy_label.add_theme_font_size_override("font_size", 25)


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
					target_label.text = "HAMBRE " + str(int(value)) + "%"
				"protein":
					target_label.text = "PROTEÍNA " + str(int(value)) + "%"
				"energy":
					target_label.text = "SUEÑO " + str(int(value)) + "%"
				"fun":
					target_label.text = "DIVERSIÓN " + str(int(value)) + "%"
				"hygiene":
					target_label.text = "HIGIENE " + str(int(value)) + "%"

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
	level_label.text = "NIV. " + str(lvl)
	xp_bar.max_value = max_xp
	xp_bar.value = cur_xp

func _on_level_up(new_level: int) -> void:
	level_popup_label.text = "¡Monky ha alcanzado el Nivel " + str(new_level) + "!\nHas ganado " + str(new_level * 5) + " monedas y 1 diamante de bonificación."
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
	title.text = "AJUSTES Y OPCIONES"
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.3))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var btn_close = Button.new()
	btn_close.custom_minimum_size = Vector2(70, 70)
	_set_button_icon(btn_close, str(UI_ICON["close"]), "", 46)
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
	_set_button_icon(btn_reset, str(UI_ICON["reset"]), "Reiniciar mascota (borrar datos)", 52)
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
	_set_button_icon(btn_quit, str(UI_ICON["quit"]), "Salir del juego", 54)
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
	version_lbl.text = "Wonky Virtual Pet • v1.3 Android"
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
		_set_button_icon(btn_toggle_sfx, str(UI_ICON["sound_on"] if sfx_on else UI_ICON["sound_off"]), "Efectos de sonido: " + ("ACTIVADOS" if sfx_on else "SILENCIADOS"), 52)
		var bg_c = Color(0.2, 0.6, 0.35) if sfx_on else Color(0.35, 0.3, 0.4)
		var bd_c = Color(0.4, 0.9, 0.55) if sfx_on else Color(0.6, 0.55, 0.65)
		btn_toggle_sfx.add_theme_stylebox_override("normal", _create_card_style(bg_c, bd_c))

	if btn_toggle_music:
		var mus_on = gm.music_enabled
		_set_button_icon(btn_toggle_music, str(UI_ICON["music_on"] if mus_on else UI_ICON["music_off"]), "Música de fondo: " + ("ACTIVADA" if mus_on else "SILENCIADA"), 52)
		var bg_c = Color(0.35, 0.3, 0.7) if mus_on else Color(0.35, 0.3, 0.4)
		var bd_c = Color(0.65, 0.55, 0.95) if mus_on else Color(0.6, 0.55, 0.65)
		btn_toggle_music.add_theme_stylebox_override("normal", _create_card_style(bg_c, bd_c))

	if btn_toggle_vib:
		var vib_on = gm.vibration_enabled
		_set_button_icon(btn_toggle_vib, str(UI_ICON["vibration_on"] if vib_on else UI_ICON["vibration_off"]), "Vibración háptica: " + ("ACTIVADA" if vib_on else "DESACTIVADA"), 52)
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
	title.text = "¿REINICIAR MASCOTA?"
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
	_set_button_icon(btn_cancel, str(UI_ICON["close"]), "Cancelar", 44)
	btn_cancel.add_theme_font_size_override("font_size", 28)
	btn_cancel.add_theme_stylebox_override("normal", _create_card_style(Color(0.3, 0.3, 0.4), Color(0.6, 0.6, 0.7)))
	btn_cancel.pressed.connect(func():
		confirm_reset_popup.visible = false
	)
	hbox.add_child(btn_cancel)

	var btn_confirm = Button.new()
	btn_confirm.custom_minimum_size = Vector2(280, 80)
	_set_button_icon(btn_confirm, str(UI_ICON["reset"]), "Sí, reiniciar", 44)
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
			gm.show_floating_text.emit("Mascota reiniciada desde cero", Vector2(540, 850), Color(0.4, 1.0, 0.5))
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
