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
@onready var market_grid: GridContainer = $FoodMarketPopup/Panel/Margin/VBox/Scroll/MarketGrid

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

const STICKER_SHADER: Shader = preload("res://resources/ui_sticker.gdshader")

const UI_ICON := {
	"hunger": "res://imagenes/ui_polished/hud/hambre.png",
	"protein": "res://imagenes/ui_polished/hud/proteina.png",
	"energy": "res://imagenes/ui_polished/hud/sueno.png",
	"fun": "res://imagenes/ui_polished/hud/diversion.png",
	"hygiene": "res://imagenes/ui_polished/hud/higiene.png",
	"coin": "res://imagenes/ui_polished/hud/moneda.png",
	"diamond": "res://imagenes/ui_polished/hud/diamante.png",
	"level": "res://imagenes/ui_polished/hud/nivel.png",
	"settings": "res://imagenes/ui_polished/navegacion/configuracion.png",
	"plus": "res://imagenes/ui_polished/navegacion/mas.png",
	"close": "res://imagenes/ui_polished/navegacion/cerrar.png",
	"info": "res://imagenes/ui_polished/navegacion/informacion.png",
	"market": "res://imagenes/ui_polished/navegacion/mercado.png",
	"bed": "res://imagenes/ui_polished/navegacion/habitacion.png",
	"kitchen": "res://imagenes/ui_polished/navegacion/cocina.png",
	"bath": "res://imagenes/ui_polished/navegacion/bano.png",
	"play": "res://imagenes/ui_polished/navegacion/juegos.png",
	"sleep": "res://imagenes/ui_polished/dormitorio/dormir.png",
	"wake": "res://imagenes/ui_polished/dormitorio/despertar.png",
	"toothbrush": "res://imagenes/ui_polished/bano/cepillo_dientes.png",
	"soap": "res://imagenes/ui_polished/bano/jabon.png",
	"shower": "res://imagenes/ui_polished/bano/ducha.png",
	"ball": "res://imagenes/ui_polished/juegos/pelota.png",
	"minigames": "res://imagenes/ui_polished/juegos/minijuegos.png",
	"daily": "res://imagenes/ui_polished/tienda/regalo_diario.png",
	"ad": "res://imagenes/ui_polished/tienda/anuncio.png",
	"coins_pack": "res://imagenes/ui_polished/tienda/monedas_pack.png",
	"diamonds_pack": "res://imagenes/ui_polished/tienda/diamantes_pack.png",
	"sound_on": "res://imagenes/ui_polished/configuracion/sonido_on.png",
	"sound_off": "res://imagenes/ui_polished/configuracion/sonido_off.png",
	"music_on": "res://imagenes/ui_polished/configuracion/musica_on.png",
	"music_off": "res://imagenes/ui_polished/configuracion/musica_off.png",
	"vibration_on": "res://imagenes/ui_polished/configuracion/vibracion_on.png",
	"vibration_off": "res://imagenes/ui_polished/configuracion/vibracion_off.png",
	"reset": "res://imagenes/ui_polished/configuracion/reiniciar.png",
	"quit": "res://imagenes/ui_polished/configuracion/salir.png"
}

const V6_ART := {
	"settings_frame": "res://imagenes/ui_polished/v6/settings_frame_v6.png",
	"market_frame": "res://imagenes/ui_polished/v6/market_frame.png",
	"shop_frame": "res://imagenes/ui_polished/v6/shop_frame.png",
	"food_tile": "res://imagenes/ui_polished/v6/food_tile.png",
	"food_details": "res://imagenes/ui_polished/v6/food_details_frame.png",
	"shop_gem": "res://imagenes/ui_polished/v6/shop_tile_gem.png",
	"shop_coin": "res://imagenes/ui_polished/v6/shop_tile_coin.png",
	"shop_potion": "res://imagenes/ui_polished/v6/shop_tile_potion.png",
	"shop_reward": "res://imagenes/ui_polished/v6/shop_tile_reward.png",
	"kitchen_base": "res://imagenes/ui_polished/v6/kitchen_shelf.png",
	"bath_base": "res://imagenes/ui_polished/v6/bath_bubbles.png",
	"bed_base": "res://imagenes/ui_polished/v6/bed_cloud.png",
	"play_base": "res://imagenes/ui_polished/v6/play_mat.png"
}

# Arte V7 suministrado por el usuario. Esta colección sustituye paneles genéricos
# por piezas ilustradas hechas específicamente para el universo de Wonky.
const V7_ART := {
	"shop_main": "res://imagenes/ui_custom_v7/tienda_principal.png",
	"food_shelf": "res://imagenes/ui_custom_v7/estante_comida.png",
	"food_crate": "res://imagenes/ui_custom_v7/cajon_comida.png",
	"coin_stand": "res://imagenes/ui_custom_v7/puesto_monedas.png",
	"diamond_stand": "res://imagenes/ui_custom_v7/puesto_diamantes.png",
	"potion_shelf": "res://imagenes/ui_custom_v7/estante_pociones.png",
	"potion_energy": "res://imagenes/ui_custom_v7/pocion_energia.png",
	"potion_hygiene": "res://imagenes/ui_custom_v7/pocion_higiene.png",
	"potion_supreme": "res://imagenes/ui_custom_v7/pocion_suprema.png",
	"title_sign": "res://imagenes/ui_custom_v7/letrero_madera.png",
	"bar_frame": "res://imagenes/ui_custom_v7/barra_marco.png",
	"bar_fill": "res://imagenes/ui_custom_v7/barra_relleno.png",
	"window_frame": "res://imagenes/ui_custom_v7/marco_ventana.png"
}

var custom_stat_bars: Dictionary = {}
var custom_xp_bar: TextureProgressBar = null

func _ready() -> void:
	gm = get_tree().root.get_node_or_null("GameManager")
	_setup_atmosphere_overlays()
	_setup_visual_assets()
	_setup_protein_ui()
	_setup_food_details_popup()
	_style_sleep_bar()
	# V7 hotfix: las texturas de barra tienen un tamaño nativo muy grande.
	# Se mantienen desactivadas en el HUD principal hasta montarlas con recorte/NinePatch.
	# _setup_custom_stat_bars()
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
		_set_image_button(btn_lamp, str(UI_ICON["wake"]), 124, Vector2(320, 205), "Despertar  %02d:%02d" % [mins, secs], 24)
	elif gm.energy <= 0.0:
		_set_image_button(btn_lamp, str(UI_ICON["sleep"]), 124, Vector2(320, 205), "Dormir · Agotado", 24)
	else:
		_set_image_button(btn_lamp, str(UI_ICON["sleep"]), 124, Vector2(320, 205), "Dormir", 25)

func _setup_protein_ui() -> void:
	# Cinco medidores claros y respirados. El icono manda; el texto sólo acompaña.
	if stats_grid:
		stats_grid.add_theme_constant_override("separation", 18)

	for bar in [hunger_bar, protein_bar, energy_bar, fun_bar, hygiene_bar]:
		if bar:
			bar.custom_minimum_size = Vector2(150, 18)
			bar.show_percentage = false

	for label in [hunger_label, protein_label, energy_label, fun_label, hygiene_label]:
		if label:
			label.add_theme_font_size_override("font_size", 16)
			label.add_theme_color_override("font_color", Color("#FFF9EA"))
			label.add_theme_color_override("font_outline_color", Color("#26160F"))
			label.add_theme_constant_override("outline_size", 4)

	if xp_bar:
		xp_bar.custom_minimum_size = Vector2(190, 14)
		xp_bar.show_percentage = false

func _sticker_material(outline_px: float = 7.0, shadow_y: float = 5.0) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = STICKER_SHADER
	material.set_shader_parameter("outline_color", Color("#1D140F"))
	material.set_shader_parameter("outline_size", outline_px)
	material.set_shader_parameter("shadow_offset", Vector2(0.0, shadow_y))
	material.set_shader_parameter("shadow_color", Color(0.03, 0.02, 0.02, 0.30))
	return material

func _apply_sticker(node: CanvasItem, outline_px: float = 7.0, shadow_y: float = 5.0) -> void:
	# Los PNG principales ya tienen contorno físico uniforme. Evita doble borde borroso.
	if node:
		node.material = null

func _style_caption(label: Label, font_size: int, color: Color = Color.WHITE) -> void:
	if not label:
		return
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color("#19100C"))
	label.add_theme_constant_override("outline_size", 7)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.30))
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 3)

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


func _set_image_button(button: Button, image_path: String, icon_width: int = 110, minimum_size: Vector2 = Vector2(180, 150), label_text: String = "", label_size: int = 22) -> void:
	## La ilustración ES el botón. El texto vive debajo de la ilustración, sin tarjeta.
	## Esto conserva el estilo limpio pero evita iconos "flotando" sin explicación.
	if not button:
		return

	button.text = ""
	button.icon = null
	button.expand_icon = false
	button.custom_minimum_size = minimum_size
	button.focus_mode = Control.FOCUS_NONE
	button.flat = true
	button.clip_contents = false

	var empty := StyleBoxEmpty.new()
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state, empty)

	var art := button.get_node_or_null("ButtonArt") as TextureRect
	if not art:
		art = TextureRect.new()
		art.name = "ButtonArt"
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		art.anchor_left = 0.5
		art.anchor_right = 0.5
		art.anchor_top = 0.0
		art.anchor_bottom = 0.0
		button.add_child(art)

	art.texture = _load_ui_texture(image_path)
	if art.material == null:
		_apply_sticker(art, 10.0, 5.5)
	if not art.has_meta("wonky_art_pivot"):
		art.set_meta("wonky_art_pivot", true)
		art.resized.connect(func(): art.pivot_offset = art.size * 0.5)
	var top_space: float = 4.0 if label_text != "" else maxf(0.0, (minimum_size.y - float(icon_width)) * 0.5)
	art.offset_left = -float(icon_width) * 0.5
	art.offset_right = float(icon_width) * 0.5
	art.offset_top = top_space
	art.offset_bottom = top_space + float(icon_width)

	var caption := button.get_node_or_null("ButtonLabel") as Label
	if label_text != "":
		if not caption:
			caption = Label.new()
			caption.name = "ButtonLabel"
			caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
			caption.anchor_left = 0.0
			caption.anchor_right = 1.0
			caption.anchor_top = 1.0
			caption.anchor_bottom = 1.0
			caption.offset_left = -10.0
			caption.offset_right = -10.0
			caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			button.add_child(caption)
		caption.visible = true
		caption.offset_top = -42.0
		caption.offset_bottom = -2.0
		caption.text = label_text
		_style_caption(caption, label_size)
	else:
		if caption:
			caption.visible = false

	_bind_image_button_feedback(button)

func _update_image_button_label(button: Button, label_text: String, label_size: int = 22) -> void:
	if not button:
		return
	var caption := button.get_node_or_null("ButtonLabel") as Label
	if not caption:
		# Mantiene la ilustración existente y crea sólo el pie de texto.
		caption = Label.new()
		caption.name = "ButtonLabel"
		caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
		caption.anchor_left = 0.0
		caption.anchor_right = 1.0
		caption.anchor_top = 1.0
		caption.anchor_bottom = 1.0
		caption.offset_left = -10.0
		caption.offset_right = -10.0
		caption.offset_top = -42.0
		caption.offset_bottom = -2.0
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		button.add_child(caption)
	caption.visible = true
	caption.text = label_text
	_style_caption(caption, label_size)

func _bind_image_button_feedback(button: Button) -> void:
	if not button or button.has_meta("wonky_image_button_fx"):
		return
	button.set_meta("wonky_image_button_fx", true)
	button.resized.connect(func():
		button.pivot_offset = button.size * 0.5
	)
	button.button_down.connect(func():
		_tween_image_button(button, Vector2(0.88, 0.88), 0.07)
	)
	button.button_up.connect(func():
		var tween := create_tween()
		tween.tween_property(button, "scale", Vector2(1.06, 1.06), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(button, "scale", Vector2.ONE, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)
	button.mouse_exited.connect(func():
		if not button.button_pressed:
			_tween_image_button(button, Vector2.ONE, 0.08)
	)

func _tween_image_button(button: Button, target_scale: Vector2, duration: float) -> void:
	if not is_instance_valid(button):
		return
	var tween := create_tween()
	tween.tween_property(button, "scale", target_scale, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _set_button_badge(button: Button, badge_text: String, font_size: int = 22) -> void:
	# Insignia pequeña arriba a la derecha; no tapa el nombre inferior.
	if not button:
		return
	var badge := button.get_node_or_null("ImageBadge") as Label
	if not badge:
		badge = Label.new()
		badge.name = "ImageBadge"
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge.anchor_left = 1.0
		badge.anchor_right = 1.0
		badge.anchor_top = 0.0
		badge.anchor_bottom = 0.0
		badge.offset_left = -88.0
		badge.offset_top = 4.0
		badge.offset_right = -4.0
		badge.offset_bottom = 44.0
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge.add_theme_color_override("font_color", Color.WHITE)
		badge.add_theme_color_override("font_outline_color", Color(0.12, 0.08, 0.08, 0.95))
		badge.add_theme_constant_override("outline_size", 6)
		button.add_child(badge)
	badge.add_theme_font_size_override("font_size", font_size)
	badge.text = badge_text

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
	_apply_sticker(tex, 8.0, 3.5)
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
	header.add_theme_constant_override("separation", 5)
	container.add_child(header)
	container.move_child(header, 0)
	label_node.reparent(header)

	var tex := TextureRect.new()
	tex.texture = _load_ui_texture(image_path)
	tex.custom_minimum_size = Vector2(46, 46)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_sticker(tex, 8.0, 3.5)
	header.add_child(tex)
	header.move_child(tex, 0)


func _setup_atmosphere_overlays() -> void:
	# Oscurece sólo los bordes superior/inferior con degradados; no crea una barra ni tapa el escenario.
	var top_vignette := TextureRect.new()
	top_vignette.name = "TopVignette"
	top_vignette.texture = _load_ui_texture("res://imagenes/ui_polished/top_vignette.png")
	top_vignette.position = Vector2(0, 0)
	top_vignette.size = Vector2(1080, 330)
	top_vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	top_vignette.stretch_mode = TextureRect.STRETCH_SCALE
	top_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top_vignette)
	move_child(top_vignette, 0)

	var bottom_vignette := TextureRect.new()
	bottom_vignette.name = "BottomVignette"
	bottom_vignette.texture = _load_ui_texture("res://imagenes/ui_polished/bottom_vignette.png")
	bottom_vignette.position = Vector2(0, 1400)
	bottom_vignette.size = Vector2(1080, 520)
	bottom_vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bottom_vignette.stretch_mode = TextureRect.STRETCH_SCALE
	bottom_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bottom_vignette)
	move_child(bottom_vignette, 1)

func _setup_visual_assets() -> void:
	# Cabecera.
	level_label.text = "NIV. 1"
	level_label.add_theme_color_override("font_color", Color.WHITE)
	level_label.add_theme_color_override("font_outline_color", Color("#17100C"))
	level_label.add_theme_constant_override("outline_size", 5)

	var level_parent := level_label.get_parent()
	if level_parent and not level_parent.has_node("LevelHeader"):
		var level_header := HBoxContainer.new()
		level_header.name = "LevelHeader"
		level_header.alignment = BoxContainer.ALIGNMENT_BEGIN
		level_header.add_theme_constant_override("separation", 6)
		level_parent.add_child(level_header)
		level_parent.move_child(level_header, 0)
		level_label.reparent(level_header)
		var level_icon := TextureRect.new()
		level_icon.texture = _load_ui_texture(str(UI_ICON["level"]))
		level_icon.custom_minimum_size = Vector2(34, 34)
		level_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		level_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_apply_sticker(level_icon, 8.0, 3.5)
		level_header.add_child(level_icon)
		level_header.move_child(level_icon, 0)

	var coins_icon := get_node_or_null("TopBar/VBox/HeaderRow/BtnCoins/HBox/CoinsIcon") as Label
	var coins_plus := get_node_or_null("TopBar/VBox/HeaderRow/BtnCoins/HBox/PlusBadge") as Label
	var diamonds_icon := get_node_or_null("TopBar/VBox/HeaderRow/BtnDiamonds/HBox/DiamondsIcon") as Label
	var diamonds_plus := get_node_or_null("TopBar/VBox/HeaderRow/BtnDiamonds/HBox/PlusBadge") as Label
	_replace_label_icon(coins_icon, str(UI_ICON["coin"]), 42)
	_replace_label_icon(coins_plus, str(UI_ICON["plus"]), 28)
	_replace_label_icon(diamonds_icon, str(UI_ICON["diamond"]), 42)
	_replace_label_icon(diamonds_plus, str(UI_ICON["plus"]), 28)
	for currency_label in [coins_label, diamonds_label]:
		if currency_label:
			currency_label.add_theme_color_override("font_outline_color", Color("#17100C"))
			currency_label.add_theme_constant_override("outline_size", 5)
	_set_image_button(btn_settings, str(UI_ICON["settings"]), 58, Vector2(82, 72))

	# Indicadores superiores.
	_add_stat_icon(hunger_label.get_parent() as VBoxContainer, hunger_label, str(UI_ICON["hunger"]))
	_add_stat_icon(protein_label.get_parent() as VBoxContainer, protein_label, str(UI_ICON["protein"]))
	_add_stat_icon(energy_label.get_parent() as VBoxContainer, energy_label, str(UI_ICON["energy"]))
	_add_stat_icon(fun_label.get_parent() as VBoxContainer, fun_label, str(UI_ICON["fun"]))
	_add_stat_icon(hygiene_label.get_parent() as VBoxContainer, hygiene_label, str(UI_ICON["hygiene"]))

	# Dock: imagen limpia + nombre debajo. Sin cajas.
	_set_image_button(btn_bed, str(UI_ICON["bed"]), 132, Vector2(230, 178), "Dormitorio", 24)
	_set_image_button(btn_kitchen, str(UI_ICON["kitchen"]), 132, Vector2(230, 178), "Cocina", 24)
	_set_image_button(btn_bath, str(UI_ICON["bath"]), 132, Vector2(230, 178), "Baño", 24)
	_set_image_button(btn_play, str(UI_ICON["play"]), 132, Vector2(230, 178), "Juegos", 24)

	room_title.add_theme_font_size_override("font_size", 28)
	room_title.add_theme_color_override("font_color", Color.WHITE)
	room_title.add_theme_color_override("font_outline_color", Color("#17100C"))
	room_title.add_theme_constant_override("outline_size", 6)

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
	# Organización invisible: los controles se ven como ilustraciones con su nombre debajo.
	var empty_panel := StyleBoxEmpty.new()
	kitchen_drawer.add_theme_stylebox_override("panel", empty_panel)
	bath_drawer.add_theme_stylebox_override("panel", empty_panel)
	bed_drawer.add_theme_stylebox_override("panel", empty_panel)
	play_drawer.add_theme_stylebox_override("panel", empty_panel)

	_refresh_kitchen_inventory()

	if btn_toothbrush:
		_set_image_button(btn_toothbrush, str(UI_ICON["toothbrush"]), 142, Vector2(270, 220), "Cepillar", 27)
		btn_toothbrush.tooltip_text = "Cepillar dientes"
		btn_toothbrush.pressed.connect(func(): _spawn_draggable("toothbrush"))

	if btn_soap:
		_set_image_button(btn_soap, str(UI_ICON["soap"]), 142, Vector2(270, 220), "Enjabonar", 27)
		btn_soap.tooltip_text = "Enjabonar"
		btn_soap.pressed.connect(func(): _spawn_draggable("soap"))

	if btn_shower:
		_set_image_button(btn_shower, str(UI_ICON["shower"]), 142, Vector2(270, 220), "Ducha", 27)
		btn_shower.tooltip_text = "Enjuagar"
		btn_shower.pressed.connect(func(): _spawn_draggable("shower"))

	if btn_lamp:
		_set_image_button(btn_lamp, str(UI_ICON["sleep"]), 124, Vector2(320, 205), "Dormir", 25)
		_update_sleep_button()
		btn_lamp.pressed.connect(func():
			if gm:
				gm.toggle_sleep()
				_update_sleep_button()
		)

	# Sala de juegos: se elimina la pelota por completo. Minijuegos queda como acción principal.
	if btn_ball:
		btn_ball.visible = false
		btn_ball.custom_minimum_size = Vector2.ZERO

	var play_hbox := play_drawer.get_node_or_null("Margin/HBox") as HBoxContainer
	if play_hbox:
		play_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		play_hbox.add_theme_constant_override("separation", 0)

	if btn_game:
		_set_image_button(btn_game, str(UI_ICON["minigames"]), 230, Vector2(480, 290), "MINIJUEGOS", 32)
		btn_game.tooltip_text = "Abrir minijuegos"
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

	# Mercado y nutrición siguen siendo iconos, ahora con nombre visible.
	var market_btn := Button.new()
	_set_image_button(market_btn, str(UI_ICON["market"]), 112, Vector2(190, 190), "Mercado", 22)
	market_btn.tooltip_text = "Mercado"
	market_btn.pressed.connect(_open_food_market)
	food_items_grid.add_child(market_btn)

	var info_btn := Button.new()
	var p_val: int = int(gm.protein) if gm else 100
	_set_image_button(info_btn, str(UI_ICON["protein"]), 108, Vector2(190, 190), "Nutrición", 22)
	_set_button_badge(info_btn, str(p_val) + "%", 21)
	info_btn.tooltip_text = "Información de nutrición"
	info_btn.pressed.connect(func():
		var first_food: Dictionary = gm.FOOD_CATALOG[0] if (gm and not gm.FOOD_CATALOG.is_empty()) else {}
		_open_food_details(first_food)
	)
	food_items_grid.add_child(info_btn)

	var catalog = gm.FOOD_CATALOG if gm else []
	var any_food_owned: bool = false

	for food in catalog:
		var qty: int = gm.get_food_quantity(food.id) if gm else 0
		if qty <= 0:
			continue
		any_food_owned = true
		var card := Button.new()
		_set_image_button(card, str(food.get("image", "")), 112, Vector2(190, 190), str(food.name), 21)
		_set_button_badge(card, "x" + str(qty), 22)
		card.tooltip_text = str(food.name) + " · Cantidad: " + str(qty)
		card.pressed.connect(func(): _spawn_draggable("food", food))
		food_items_grid.add_child(card)

	if not any_food_owned:
		var empty_lbl := Label.new()
		empty_lbl.text = "Nevera vacía · toca Mercado"
		empty_lbl.add_theme_font_size_override("font_size", 25)
		empty_lbl.add_theme_color_override("font_color", Color.WHITE)
		empty_lbl.add_theme_color_override("font_outline_color", Color(0.08, 0.06, 0.12, 0.9))
		empty_lbl.add_theme_constant_override("outline_size", 6)
		empty_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		food_items_grid.add_child(empty_lbl)

func _decorate_panel_with_frame(panel: PanelContainer, texture_path: String) -> void:
	if not panel:
		return
	panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	var old := panel.get_node_or_null("V6Frame")
	if old:
		old.queue_free()
	var frame := TextureRect.new()
	frame.name = "V6Frame"
	frame.texture = _load_ui_texture(texture_path)
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_SCALE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(frame)
	panel.move_child(frame, 0)

func _decorate_button_with_art(button: Button, frame_path: String, icon_path: String, button_text: String, icon_width: int = 62, font_size: int = 22) -> void:
	# V7: producto ilustrado. Ya no usamos el icono de Button + texto lateral,
	# porque se parecía demasiado a un menú de aplicación.
	if not button:
		return
	button.text = ""
	button.icon = null
	button.expand_icon = false
	button.focus_mode = Control.FOCUS_NONE
	button.flat = true
	button.clip_contents = false
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state, StyleBoxEmpty.new())

	var old_bg := button.get_node_or_null("V6ButtonBG")
	if old_bg:
		old_bg.queue_free()

	var bg := button.get_node_or_null("V7ProductBG") as TextureRect
	if not bg:
		bg = TextureRect.new()
		bg.name = "V7ProductBG"
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bg.show_behind_parent = true
		button.add_child(bg)
	bg.texture = _load_ui_texture(frame_path)

	var icon := button.get_node_or_null("V7ProductIcon") as TextureRect
	if icon_path != "":
		if not icon:
			icon = TextureRect.new()
			icon.name = "V7ProductIcon"
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.anchor_left = 0.5
			icon.anchor_right = 0.5
			icon.anchor_top = 0.0
			icon.anchor_bottom = 0.0
			button.add_child(icon)
		icon.visible = true
		icon.texture = _load_ui_texture(icon_path)
		var iw := float(icon_width)
		icon.offset_left = -iw * 0.5
		icon.offset_right = iw * 0.5
		icon.offset_top = 20.0
		icon.offset_bottom = 20.0 + iw
	else:
		if icon:
			icon.visible = false

	var caption := button.get_node_or_null("V7ProductLabel") as Label
	if not caption:
		caption = Label.new()
		caption.name = "V7ProductLabel"
		caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
		caption.anchor_left = 0.05
		caption.anchor_right = 0.95
		caption.anchor_top = 0.58
		caption.anchor_bottom = 0.98
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_child(caption)
	caption.text = button_text
	caption.add_theme_font_size_override("font_size", font_size)
	caption.add_theme_color_override("font_color", Color("#FFF8E7"))
	caption.add_theme_color_override("font_outline_color", Color("#3B1D12"))
	caption.add_theme_constant_override("outline_size", 5)

	_bind_image_button_feedback(button)

func _style_v6_section(label: Label, color: Color) -> void:
	if not label:
		return
	label.add_theme_font_size_override("font_size", 25)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color("#3A281F"))
	label.add_theme_constant_override("outline_size", 4)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _add_v7_title_sign(panel: Control, title_label: Label, title_text: String, y_pos: float = 16.0) -> void:
	if not panel:
		return
	var old := panel.get_node_or_null("V7TitleSign")
	if old:
		old.queue_free()
	var old_text := panel.get_node_or_null("V7TitleText")
	if old_text:
		old_text.queue_free()

	var sign := TextureRect.new()
	sign.name = "V7TitleSign"
	sign.texture = _load_ui_texture(str(V7_ART["title_sign"]))
	sign.position = Vector2(190, y_pos)
	sign.size = Vector2(620, 310)
	sign.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sign.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sign.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(sign)
	panel.move_child(sign, mini(1, panel.get_child_count() - 1))

	if title_label:
		title_label.visible = false

	var sign_text := Label.new()
	sign_text.name = "V7TitleText"
	sign_text.position = Vector2(245, y_pos + 92)
	sign_text.size = Vector2(510, 82)
	sign_text.text = title_text
	sign_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sign_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	sign_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_style_caption(sign_text, 36, Color("#FFF8E7"))
	sign_text.add_theme_color_override("font_outline_color", Color("#4A2417"))
	sign_text.add_theme_constant_override("outline_size", 6)
	panel.add_child(sign_text)
	panel.move_child(sign_text, mini(2, panel.get_child_count() - 1))


func _setup_food_market() -> void:
	if not food_market_popup:
		return
	var panel := food_market_popup.get_node_or_null("Panel") as PanelContainer
	var title := food_market_popup.get_node_or_null("Panel/Margin/VBox/HeaderRow/Title") as Label
	if panel:
		_decorate_panel_with_frame(panel, str(V7_ART["window_frame"]))
		var old_sign := panel.get_node_or_null("V7TitleSign")
		if old_sign: old_sign.queue_free()
		var old_text := panel.get_node_or_null("V7TitleText")
		if old_text: old_text.queue_free()
		var old_shelf := panel.get_node_or_null("V7FoodShelf")
		if old_shelf: old_shelf.queue_free()

	if panel and not panel.has_node("V8MarketTitle"):
		var board_title := Label.new()
		board_title.name = "V8MarketTitle"
		board_title.position = Vector2(170, 34)
		board_title.size = Vector2(620, 90)
		board_title.text = "MERCADITO DE WONKY"
		board_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		board_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_style_caption(board_title, 31, Color("#FFF2CC"))
		board_title.add_theme_color_override("font_outline_color", Color("#4A2417"))
		panel.add_child(board_title)

	var margin := food_market_popup.get_node_or_null("Panel/Margin") as MarginContainer
	if margin:
		margin.add_theme_constant_override("margin_left", 64)
		margin.add_theme_constant_override("margin_right", 64)
		margin.add_theme_constant_override("margin_top", 176)
		margin.add_theme_constant_override("margin_bottom", 64)

	var header := food_market_popup.get_node_or_null("Panel/Margin/VBox/HeaderRow") as HBoxContainer
	if header:
		header.custom_minimum_size.y = 96
		header.add_theme_constant_override("separation", 10)

	if title:
		title.visible = false

	if market_balance_label:
		market_balance_label.add_theme_font_size_override("font_size", 20)
		market_balance_label.add_theme_color_override("font_color", Color("#6A3A22"))
	if btn_close_market:
		_set_image_button(btn_close_market, str(UI_ICON["close"]), 48, Vector2(62, 62))
		btn_close_market.pressed.connect(_close_food_market)

	if market_grid:
		market_grid.columns = 2
		market_grid.add_theme_constant_override("h_separation", 18)
		market_grid.add_theme_constant_override("v_separation", 22)

func _open_food_market() -> void:
	if not food_market_popup:
		return
	_populate_market_grid()
	_update_market_balance()
	food_market_popup.visible = true
	var panel = food_market_popup.get_node("Panel")
	panel.scale = Vector2(0.82, 0.82)
	panel.pivot_offset = panel.size / 2.0
	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _close_food_market() -> void:
	if not food_market_popup:
		return
	var panel = food_market_popup.get_node("Panel")
	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2(0.84, 0.84), 0.14).set_ease(Tween.EASE_IN)
	tween.finished.connect(func(): food_market_popup.visible = false)

func _update_market_balance() -> void:
	if gm and market_balance_label:
		market_balance_label.text = "MONEDAS  " + str(gm.coins)


func _populate_market_grid() -> void:
	if not market_grid:
		return
	for child in market_grid.get_children():
		child.queue_free()

	var catalog = gm.FOOD_CATALOG if gm else []
	for food in catalog:
		var item := Control.new()
		item.custom_minimum_size = Vector2(390, 300)
		item.mouse_filter = Control.MOUSE_FILTER_PASS

		var crate := TextureRect.new()
		crate.texture = _load_ui_texture(str(V7_ART["food_crate"]))
		crate.set_anchors_preset(Control.PRESET_FULL_RECT)
		crate.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		crate.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		crate.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item.add_child(crate)

		var food_tex := TextureRect.new()
		food_tex.texture = _load_ui_texture(str(food.get("image", "")))
		food_tex.position = Vector2(112, 25)
		food_tex.size = Vector2(166, 166)
		food_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		food_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		food_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item.add_child(food_tex)

		var name_lbl := Label.new()
		name_lbl.position = Vector2(48, 188)
		name_lbl.size = Vector2(294, 40)
		name_lbl.text = str(food.name).to_upper()
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 22)
		name_lbl.add_theme_color_override("font_color", Color("#FFF6DC"))
		name_lbl.add_theme_color_override("font_outline_color", Color("#4B281A"))
		name_lbl.add_theme_constant_override("outline_size", 5)
		item.add_child(name_lbl)

		var price_row := HBoxContainer.new()
		price_row.position = Vector2(139, 232)
		price_row.size = Vector2(120, 38)
		price_row.alignment = BoxContainer.ALIGNMENT_CENTER
		price_row.add_theme_constant_override("separation", 6)
		item.add_child(price_row)

		var coin := TextureRect.new()
		coin.texture = _load_ui_texture(str(UI_ICON["coin"]))
		coin.custom_minimum_size = Vector2(31, 31)
		coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		price_row.add_child(coin)

		var price_lbl := Label.new()
		price_lbl.text = str(food.price)
		price_lbl.add_theme_font_size_override("font_size", 22)
		price_lbl.add_theme_color_override("font_color", Color("#6A3318"))
		price_lbl.add_theme_color_override("font_outline_color", Color("#FFF1C9"))
		price_lbl.add_theme_constant_override("outline_size", 3)
		price_row.add_child(price_lbl)

		var qty: int = gm.get_food_quantity(food.id) if gm else 0
		var qty_lbl := Label.new()
		qty_lbl.position = Vector2(290, 30)
		qty_lbl.size = Vector2(70, 34)
		qty_lbl.text = "x" + str(qty)
		qty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		qty_lbl.add_theme_font_size_override("font_size", 19)
		qty_lbl.add_theme_color_override("font_color", Color.WHITE)
		qty_lbl.add_theme_color_override("font_outline_color", Color("#3C2117"))
		qty_lbl.add_theme_constant_override("outline_size", 5)
		item.add_child(qty_lbl)

		# El cajón entero compra; la "i" abre la ficha sin comprar.
		var buy_hit := Button.new()
		buy_hit.set_anchors_preset(Control.PRESET_FULL_RECT)
		buy_hit.flat = true
		buy_hit.focus_mode = Control.FOCUS_NONE
		buy_hit.tooltip_text = "Comprar " + str(food.name)
		for state in ["normal", "hover", "pressed", "focus", "disabled"]:
			buy_hit.add_theme_stylebox_override(state, StyleBoxEmpty.new())
		buy_hit.pressed.connect(func():
			if gm and gm.buy_food(food.id, 1):
				_update_market_balance()
				qty_lbl.text = "x" + str(gm.get_food_quantity(food.id))
		)
		item.add_child(buy_hit)
		_bind_image_button_feedback(buy_hit)

		var info_btn := Button.new()
		info_btn.position = Vector2(30, 28)
		info_btn.size = Vector2(58, 58)
		_set_image_button(info_btn, str(UI_ICON["info"]), 36, Vector2(58, 58))
		info_btn.tooltip_text = "Información"
		info_btn.pressed.connect(func(): _open_food_details(food))
		item.add_child(info_btn)

		market_grid.add_child(item)

func _setup_food_details_popup() -> void:
	food_details_popup = Control.new()
	food_details_popup.name = "FoodDetailsPopup"
	food_details_popup.visible = false
	food_details_popup.z_index = 80
	food_details_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(food_details_popup)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.04, 0.025, 0.03, 0.66)
	food_details_popup.add_child(backdrop)

	var panel := PanelContainer.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(860, 800)
	panel.size = Vector2(860, 800)
	panel.position = Vector2(110, 555)
	panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	food_details_popup.add_child(panel)

	var frame := TextureRect.new()
	frame.texture = _load_ui_texture(str(V7_ART["window_frame"]))
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_SCALE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(frame)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 45)
	margin.add_theme_constant_override("margin_right", 45)
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_bottom", 52)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	var header_row := HBoxContainer.new()
	header_row.add_theme_constant_override("separation", 8)
	header_row.custom_minimum_size.y = 86
	vbox.add_child(header_row)

	var prev_food_btn := Button.new()
	prev_food_btn.custom_minimum_size = Vector2(90, 64)
	_set_image_button(prev_food_btn, "res://imagenes/ui_polished/navegacion/atras.png", 46, Vector2(90, 64))
	prev_food_btn.tooltip_text = "Anterior"
	prev_food_btn.pressed.connect(func(): _navigate_food_details(-1))
	header_row.add_child(prev_food_btn)

	var title_top := Label.new()
	title_top.text = "LA DESPENSA DE WONKY"
	title_top.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_top.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_top.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_style_caption(title_top, 29, Color("#FFF8DC"))
	header_row.add_child(title_top)

	var next_food_btn := Button.new()
	next_food_btn.custom_minimum_size = Vector2(90, 64)
	next_food_btn.text = "›"
	next_food_btn.flat = true
	next_food_btn.add_theme_font_size_override("font_size", 48)
	next_food_btn.add_theme_color_override("font_color", Color("#FFF8DC"))
	next_food_btn.add_theme_color_override("font_outline_color", Color("#3C2A20"))
	next_food_btn.add_theme_constant_override("outline_size", 4)
	next_food_btn.pressed.connect(func(): _navigate_food_details(1))
	header_row.add_child(next_food_btn)

	var close_btn := Button.new()
	close_btn.custom_minimum_size = Vector2(70, 64)
	_set_image_button(close_btn, str(UI_ICON["close"]), 46, Vector2(70, 64))
	close_btn.pressed.connect(_close_food_details)
	header_row.add_child(close_btn)

	var food_header := HBoxContainer.new()
	food_header.add_theme_constant_override("separation", 22)
	food_header.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(food_header)

	details_icon_texture = TextureRect.new()
	details_icon_texture.custom_minimum_size = Vector2(135, 135)
	details_icon_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	details_icon_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_apply_sticker(details_icon_texture, 8.0, 4.0)
	food_header.add_child(details_icon_texture)

	var name_box := VBoxContainer.new()
	name_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_box.alignment = BoxContainer.ALIGNMENT_CENTER
	details_title_label = Label.new()
	details_title_label.text = "Pescado"
	details_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_style_caption(details_title_label, 32, Color("#5B3D2C"))
	name_box.add_child(details_title_label)
	food_header.add_child(name_box)

	var stats_box := PanelContainer.new()
	var stats_style := StyleBoxFlat.new()
	stats_style.bg_color = Color("#FFF0B8")
	stats_style.border_color = Color("#6B4933")
	stats_style.set_border_width_all(4)
	stats_style.set_corner_radius_all(24)
	stats_box.add_theme_stylebox_override("panel", stats_style)
	var stats_margin := MarginContainer.new()
	stats_margin.add_theme_constant_override("margin_left", 20)
	stats_margin.add_theme_constant_override("margin_right", 20)
	stats_margin.add_theme_constant_override("margin_top", 12)
	stats_margin.add_theme_constant_override("margin_bottom", 12)
	stats_box.add_child(stats_margin)

	details_stats_label = Label.new()
	details_stats_label.add_theme_font_size_override("font_size", 21)
	details_stats_label.add_theme_color_override("font_color", Color("#5B4332"))
	details_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_margin.add_child(details_stats_label)
	vbox.add_child(stats_box)

	details_desc_label = Label.new()
	details_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details_desc_label.add_theme_font_size_override("font_size", 20)
	details_desc_label.add_theme_color_override("font_color", Color("#6D5441"))
	details_desc_label.custom_minimum_size.y = 150
	vbox.add_child(details_desc_label)

	details_buy_btn = Button.new()
	details_buy_btn.custom_minimum_size = Vector2(360, 70)
	details_buy_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_decorate_button_with_art(details_buy_btn, str(V6_ART["shop_coin"]), str(UI_ICON["coin"]), "COMPRAR", 46, 22)
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
	_decorate_button_with_art(details_buy_btn, str(V6_ART["shop_coin"]), str(UI_ICON["coin"]), str(f.get("price", 10)) + " MONEDAS  ·  COMPRAR", 46, 21)

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
	# Herramientas de baño: sólo se pueden crear dentro del baño.
	if type in ["toothbrush", "soap", "shower"]:
		if not gm or str(gm.current_room).to_lower() != "baño":
			if gm:
				gm.show_floating_text.emit("Ve al baño para usar esto", Vector2(540, 1180), Color(0.55, 0.85, 1.0))
			return

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


func _make_category_art(parent: VBoxContainer, node_name: String, texture_path: String, height: float = 185.0) -> void:
	var existing := parent.get_node_or_null(node_name)
	if existing:
		return
	var art := TextureRect.new()
	art.name = node_name
	art.texture = _load_ui_texture(texture_path)
	art.custom_minimum_size = Vector2(0, height)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(art)


func _decorate_shop_slot(button: Button, icon_path: String, top_text: String, bottom_text: String, icon_width: int = 78) -> void:
	if not button:
		return
	button.text = ""
	button.icon = null
	button.expand_icon = false
	button.focus_mode = Control.FOCUS_NONE
	button.flat = true
	button.clip_contents = false
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state, StyleBoxEmpty.new())

	var old_bg := button.get_node_or_null("V7ProductBG")
	if old_bg:
		old_bg.queue_free()
	var old_icon := button.get_node_or_null("V7ProductIcon")
	if old_icon:
		old_icon.queue_free()
	var old_label := button.get_node_or_null("V7ProductLabel")
	if old_label:
		old_label.queue_free()

	var bg := TextureRect.new()
	bg.name = "V8SlotBG"
	bg.texture = _load_ui_texture(str(V7_ART["food_crate"]))
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.show_behind_parent = true
	button.add_child(bg)

	var icon := TextureRect.new()
	icon.name = "V8SlotIcon"
	icon.texture = _load_ui_texture(icon_path)
	icon.anchor_left = 0.5
	icon.anchor_right = 0.5
	icon.offset_left = -float(icon_width) * 0.5
	icon.offset_right = float(icon_width) * 0.5
	icon.offset_top = 22.0
	icon.offset_bottom = 22.0 + float(icon_width)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(icon)

	var title := Label.new()
	title.name = "V8SlotTitle"
	title.anchor_left = 0.05
	title.anchor_right = 0.95
	title.anchor_top = 0.55
	title.anchor_bottom = 0.73
	title.text = top_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 19)
	title.add_theme_color_override("font_color", Color("#5A2D1B"))
	title.add_theme_color_override("font_outline_color", Color("#FFF0C8"))
	title.add_theme_constant_override("outline_size", 3)
	button.add_child(title)

	var sub := Label.new()
	sub.name = "V8SlotSub"
	sub.anchor_left = 0.05
	sub.anchor_right = 0.95
	sub.anchor_top = 0.72
	sub.anchor_bottom = 0.96
	sub.text = bottom_text
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.add_theme_font_size_override("font_size", 16)
	sub.add_theme_color_override("font_color", Color("#7A4A30"))
	button.add_child(sub)
	_bind_image_button_feedback(button)


func _setup_shop_modal() -> void:
	var panel := shop_popup.get_node_or_null("Panel") as PanelContainer
	var title_lbl := shop_popup.get_node_or_null("Panel/Margin/VBox/HeaderRow/Title") as Label
	if panel:
		_decorate_panel_with_frame(panel, str(V7_ART["window_frame"]))
		# V8: el marco ya tiene una placa superior; no usamos el letrero colgante
		# gigante que desacomodaba el contenido.
		var old_sign := panel.get_node_or_null("V7TitleSign")
		if old_sign: old_sign.queue_free()
		var old_text := panel.get_node_or_null("V7TitleText")
		if old_text: old_text.queue_free()

	# Título centrado sobre la placa de madera del marco.
	if panel and not panel.has_node("V8ShopTitle"):
		var board_title := Label.new()
		board_title.name = "V8ShopTitle"
		board_title.position = Vector2(190, 35)
		board_title.size = Vector2(620, 90)
		board_title.text = "TIENDA DE WONKY"
		board_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		board_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_style_caption(board_title, 34, Color("#FFF2CC"))
		board_title.add_theme_color_override("font_outline_color", Color("#4A2417"))
		panel.add_child(board_title)

	var margin := shop_popup.get_node_or_null("Panel/Margin") as MarginContainer
	if margin:
		margin.add_theme_constant_override("margin_left", 58)
		margin.add_theme_constant_override("margin_right", 58)
		margin.add_theme_constant_override("margin_top", 180)
		margin.add_theme_constant_override("margin_bottom", 58)

	var header := shop_popup.get_node_or_null("Panel/Margin/VBox/HeaderRow") as HBoxContainer
	if header:
		header.custom_minimum_size.y = 96
		header.add_theme_constant_override("separation", 12)

	if title_lbl:
		title_lbl.visible = false

	if shop_coins_balance:
		shop_coins_balance.add_theme_font_size_override("font_size", 19)
		shop_coins_balance.add_theme_color_override("font_color", Color("#6B391F"))
	if shop_diamonds_balance:
		shop_diamonds_balance.add_theme_font_size_override("font_size", 19)
		shop_diamonds_balance.add_theme_color_override("font_color", Color("#2471A3"))
	if btn_close_shop:
		_set_image_button(btn_close_shop, str(UI_ICON["close"]), 48, Vector2(62, 62))

	var content := shop_popup.get_node_or_null("Panel/Margin/VBox/Scroll/ContentVBox") as VBoxContainer
	if content:
		content.add_theme_constant_override("separation", 16)

		# Quitar el puesto gigante repetido de V7 y usar una portada compacta.
		var old_hero := content.get_node_or_null("V7ShopHero")
		if old_hero:
			old_hero.queue_free()
		if not content.has_node("V8ShopHero"):
			var hero := TextureRect.new()
			hero.name = "V8ShopHero"
			hero.texture = _load_ui_texture(str(V7_ART["shop_main"]))
			hero.custom_minimum_size = Vector2(0, 220)
			hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
			content.add_child(hero)
			content.move_child(hero, 0)

	var sec_iap := shop_popup.get_node_or_null("Panel/Margin/VBox/Scroll/ContentVBox/SecIapTitle") as Label
	var sec_exch := shop_popup.get_node_or_null("Panel/Margin/VBox/Scroll/ContentVBox/SecExchangeTitle") as Label
	var sec_pots := shop_popup.get_node_or_null("Panel/Margin/VBox/Scroll/ContentVBox/SecPotionsTitle") as Label
	var sec_rew := shop_popup.get_node_or_null("Panel/Margin/VBox/Scroll/ContentVBox/SecRewardsTitle") as Label
	if sec_iap: sec_iap.text = "DIAMANTES"
	if sec_exch: sec_exch.text = "MONEDAS"
	if sec_pots: sec_pots.text = "POCIONES"
	if sec_rew: sec_rew.text = "REGALOS"
	_style_v6_section(sec_iap, Color("#2689C8"))
	_style_v6_section(sec_exch, Color("#B46B1B"))
	_style_v6_section(sec_pots, Color("#7D49AF"))
	_style_v6_section(sec_rew, Color("#CF5574"))

	for grid_path in [
		"Panel/Margin/VBox/Scroll/ContentVBox/IapGrid",
		"Panel/Margin/VBox/Scroll/ContentVBox/ExchangeGrid",
		"Panel/Margin/VBox/Scroll/ContentVBox/PotionsGrid"
	]:
		var grid := shop_popup.get_node_or_null(grid_path) as GridContainer
		if grid:
			grid.columns = 3
			grid.add_theme_constant_override("h_separation", 12)
			grid.add_theme_constant_override("v_separation", 12)

	# Cada producto ahora es un cajón de tienda con un icono claro; dejamos de
	# repetir tres puestos completos de diamantes/monedas.
	_decorate_shop_slot(btn_iap_50, str(UI_ICON["diamond"]), "50 DIAMANTES", "$0.99 USD", 72)
	_decorate_shop_slot(btn_iap_300, str(UI_ICON["diamond"]), "300 DIAMANTES", "$2.99 USD", 82)
	_decorate_shop_slot(btn_iap_1000, str(UI_ICON["diamond"]), "1000 DIAMANTES", "$7.99 USD", 92)
	_decorate_shop_slot(btn_exch_250, str(UI_ICON["coin"]), "+250 MONEDAS", "10 DIAMANTES", 72)
	_decorate_shop_slot(btn_exch_1000, str(UI_ICON["coin"]), "+1000 MONEDAS", "30 DIAMANTES", 82)
	_decorate_shop_slot(btn_exch_3500, str(UI_ICON["coin"]), "+3500 MONEDAS", "80 DIAMANTES", 92)
	_decorate_shop_slot(btn_pot_energy, str(V7_ART["potion_energy"]), "ENERGÍA 100%", "80 MON. / 4 DIAM.", 86)
	_decorate_shop_slot(btn_pot_hygiene, str(V7_ART["potion_hygiene"]), "HIGIENE 100%", "60 MON. / 3 DIAM.", 86)
	_decorate_shop_slot(btn_pot_mega, str(V7_ART["potion_supreme"]), "SUPREMA", "200 MON. / 10 DIAM.", 86)
	_decorate_shop_slot(btn_pack_daily, str(UI_ICON["daily"]), "REGALO DIARIO", "+20 MON. +1 DIAM.", 82)
	_decorate_shop_slot(btn_pack_ad, str(UI_ICON["ad"]), "VER VIDEO", "+15 MONEDAS", 82)

	for b in [btn_iap_50, btn_iap_300, btn_iap_1000, btn_exch_250, btn_exch_1000, btn_exch_3500, btn_pot_energy, btn_pot_hygiene, btn_pot_mega]:
		if b:
			b.custom_minimum_size = Vector2(275, 205)
	for b in [btn_pack_daily, btn_pack_ad]:
		if b:
			b.custom_minimum_size = Vector2(420, 205)

	if btn_coins: btn_coins.pressed.connect(_open_shop)
	if btn_diamonds: btn_diamonds.pressed.connect(_open_shop)
	if btn_close_shop: btn_close_shop.pressed.connect(_close_shop)
	if btn_iap_50: btn_iap_50.pressed.connect(func(): _prompt_iap_purchase(50, 0.99, "Bolsita de Gemas"))
	if btn_iap_300: btn_iap_300.pressed.connect(func(): _prompt_iap_purchase(300, 2.99, "Cofre de Gemas"))
	if btn_iap_1000: btn_iap_1000.pressed.connect(func(): _prompt_iap_purchase(1000, 7.99, "Bóveda de Gemas"))
	if btn_exch_250: btn_exch_250.pressed.connect(func(): _exchange_diamonds_for_coins(10, 250))
	if btn_exch_1000: btn_exch_1000.pressed.connect(func(): _exchange_diamonds_for_coins(30, 1000))
	if btn_exch_3500: btn_exch_3500.pressed.connect(func(): _exchange_diamonds_for_coins(80, 3500))
	if btn_pot_energy: btn_pot_energy.pressed.connect(func(): _buy_potion("energy", 80, 4))
	if btn_pot_hygiene: btn_pot_hygiene.pressed.connect(func(): _buy_potion("hygiene", 60, 3))
	if btn_pot_mega: btn_pot_mega.pressed.connect(func(): _buy_potion("mega", 200, 10))
	if btn_pack_daily: btn_pack_daily.pressed.connect(_claim_daily_reward)
	if btn_pack_ad: btn_pack_ad.pressed.connect(_claim_ad_reward)
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

	# Recompensa Diaria (24 Horas)
	if btn_pack_daily:
		var daily_label := btn_pack_daily.get_node_or_null("V8SlotSub") as Label
		if gm.last_daily_reward_time == 0 or (now - gm.last_daily_reward_time) >= 86400:
			if daily_label:
				daily_label.text = "+20 MON. +1 DIAM. · ¡RECLAMAR!"
			else:
				_set_button_icon(btn_pack_daily, str(UI_ICON["daily"]), "Recompensa diaria\n+20 monedas  +1 diamante\nRECLAMAR", 62)
			btn_pack_daily.modulate = Color.WHITE
		else:
			var wait_sec: int = maxi(0, 86400 - (now - gm.last_daily_reward_time))
			var h: int = wait_sec / 3600
			var m: int = (wait_sec % 3600) / 60
			var s: int = wait_sec % 60
			if daily_label:
				daily_label.text = "LISTO EN %02dh %02dm %02ds" % [h, m, s]
			else:
				_set_button_icon(btn_pack_daily, str(UI_ICON["daily"]), "Recompensa diaria\nEn %02dh %02dm %02ds\nESPERA" % [h, m, s], 62)
			btn_pack_daily.modulate = Color(0.72, 0.72, 0.72, 1.0)

	# Anuncio (2 minutos)
	if btn_pack_ad:
		var ad_label := btn_pack_ad.get_node_or_null("V8SlotSub") as Label
		if gm.last_ad_reward_time == 0 or (now - gm.last_ad_reward_time) >= 120:
			if ad_label:
				ad_label.text = "+15 MONEDAS · ¡VER!"
			else:
				_set_button_icon(btn_pack_ad, str(UI_ICON["ad"]), "Ver anuncio\n+15 monedas\nVER VIDEO", 62)
			btn_pack_ad.modulate = Color.WHITE
		else:
			var wait_sec: int = maxi(0, 120 - (now - gm.last_ad_reward_time))
			var m: int = wait_sec / 60
			var s: int = wait_sec % 60
			if ad_label:
				ad_label.text = "VER VIDEO\nESPERA %02d:%02d" % [m, s]
			else:
				_set_button_icon(btn_pack_ad, str(UI_ICON["ad"]), "Ver anuncio\nEspera %02d:%02d\nESPERA" % [m, s], 62)
			btn_pack_ad.modulate = Color(0.72, 0.72, 0.72, 1.0)

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


func _setup_custom_stat_bars() -> void:
	# Barras dibujadas: usamos las dos imágenes suministradas en lugar del widget
	# visual por defecto. El ProgressBar original se conserva sólo como lógica.
	var definitions := {
		"hunger": [hunger_bar, Color("#FF725E")],
		"protein": [protein_bar, Color("#D94A43")],
		"energy": [energy_bar, Color("#7768F2")],
		"fun": [fun_bar, Color("#FFC93D")],
		"hygiene": [hygiene_bar, Color("#36C9E8")]
	}
	for stat_name in definitions.keys():
		var original: ProgressBar = definitions[stat_name][0]
		if not original:
			continue
		original.visible = false
		var parent := original.get_parent()
		var pretty := TextureProgressBar.new()
		pretty.name = "V7_" + str(stat_name).capitalize() + "Bar"
		pretty.custom_minimum_size = Vector2(150, 28)
		pretty.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pretty.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pretty.min_value = 0.0
		pretty.max_value = original.max_value
		pretty.value = original.value
		pretty.texture_progress = _load_ui_texture(str(V7_ART["bar_fill"]))
		pretty.texture_over = _load_ui_texture(str(V7_ART["bar_frame"]))
		pretty.tint_progress = definitions[stat_name][1]
		pretty.tint_over = Color.WHITE
		parent.add_child(pretty)
		parent.move_child(pretty, original.get_index())
		custom_stat_bars[stat_name] = pretty

	if xp_bar:
		xp_bar.visible = false
		var parent_xp := xp_bar.get_parent()
		custom_xp_bar = TextureProgressBar.new()
		custom_xp_bar.name = "V7_XPBar"
		custom_xp_bar.custom_minimum_size = Vector2(190, 24)
		custom_xp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		custom_xp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		custom_xp_bar.min_value = 0.0
		custom_xp_bar.max_value = xp_bar.max_value
		custom_xp_bar.value = xp_bar.value
		custom_xp_bar.texture_progress = _load_ui_texture(str(V7_ART["bar_fill"]))
		custom_xp_bar.texture_over = _load_ui_texture(str(V7_ART["bar_frame"]))
		custom_xp_bar.tint_progress = Color("#FFD64A")
		parent_xp.add_child(custom_xp_bar)
		parent_xp.move_child(custom_xp_bar, xp_bar.get_index())

func _style_sleep_bar() -> void:
	# Medidores tipo juguete: crema, tinta oscura y relleno vivo. Sin aspecto de widget estándar.
	var palette := {
		hunger_bar: Color("#FF7056"),
		protein_bar: Color("#D9564B"),
		energy_bar: Color("#7569EE"),
		fun_bar: Color("#FFC72F"),
		hygiene_bar: Color("#45C7D8")
	}

	for bar in palette.keys():
		if not bar:
			continue
		var track := StyleBoxFlat.new()
		track.bg_color = Color("#FFF7E7")
		track.border_color = Color("#2C1A12")
		track.set_border_width_all(3)
		track.set_corner_radius_all(9)
		track.shadow_color = Color(0.07, 0.04, 0.02, 0.26)
		track.shadow_size = 3
		track.shadow_offset = Vector2(0, 2)

		var fill := StyleBoxFlat.new()
		fill.bg_color = palette[bar]
		fill.set_corner_radius_all(7)
		bar.add_theme_stylebox_override("background", track)
		bar.add_theme_stylebox_override("fill", fill)
		bar.custom_minimum_size.y = 18

	if xp_bar:
		var xp_track := StyleBoxFlat.new()
		xp_track.bg_color = Color("#FFF7E7")
		xp_track.border_color = Color("#2C1A12")
		xp_track.set_border_width_all(3)
		xp_track.set_corner_radius_all(8)
		var xp_fill := StyleBoxFlat.new()
		xp_fill.bg_color = Color("#FFD34D")
		xp_fill.set_corner_radius_all(6)
		xp_bar.add_theme_stylebox_override("background", xp_track)
		xp_bar.add_theme_stylebox_override("fill", xp_fill)
		xp_bar.custom_minimum_size.y = 14

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
		target_bar.value = value

	var pretty := custom_stat_bars.get(stat_name, null) as TextureProgressBar
	if pretty:
		pretty.max_value = max_val
		var tween := create_tween()
		tween.tween_property(pretty, "value", value, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	if target_label:
		match stat_name:
			"hunger":
				target_label.text = "HAMBRE  " + str(int(value)) + "%"
			"protein":
				target_label.text = "PROTEÍNA  " + str(int(value)) + "%"
			"energy":
				target_label.text = "SUEÑO  " + str(int(value)) + "%"
			"fun":
				target_label.text = "JUEGO  " + str(int(value)) + "%"
			"hygiene":
				target_label.text = "HIGIENE  " + str(int(value)) + "%"

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
	if custom_xp_bar:
		custom_xp_bar.max_value = max_xp
		var tween := create_tween()
		tween.tween_property(custom_xp_bar, "value", cur_xp, 0.22)

func _on_level_up(new_level: int) -> void:
	level_popup_label.text = "¡Monky ha alcanzado el Nivel " + str(new_level) + "!\nHas ganado " + str(new_level * 5) + " monedas y 1 diamante de bonificación."
	level_popup.visible = true
	var tween = create_tween()
	level_popup.scale = Vector2(0.5, 0.5)
	level_popup.pivot_offset = level_popup.size / 2.0
	tween.tween_property(level_popup, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_room_changed(room_name: String) -> void:
	_update_room_view(room_name)

	# Si el jugador sale del baño, cualquier herramienta de higiene activa se
	# elimina inmediatamente. Así jabón/ducha/cepillo no funcionan en otros cuartos.
	if str(room_name).to_lower() != "baño":
		var scene_root = get_tree().current_scene
		if scene_root:
			for child in scene_root.get_children():
				if child is DraggableItem and child.item_type in ["toothbrush", "soap", "shower"]:
					child.queue_free()

func _set_nav_active(button: Button, active: bool) -> void:
	if not button:
		return
	button.modulate = Color.WHITE
	var glow := button.get_node_or_null("SelectionBlob") as TextureRect
	if not glow:
		glow = TextureRect.new()
		glow.name = "SelectionBlob"
		glow.texture = _load_ui_texture("res://imagenes/ui_polished/nav_blob.png")
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		glow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		glow.anchor_left = 0.5
		glow.anchor_right = 0.5
		glow.offset_left = -112.0
		glow.offset_right = 112.0
		glow.offset_top = -4.0
		glow.offset_bottom = 150.0
		button.add_child(glow)
		button.move_child(glow, 0)
	glow.visible = active
	var art := button.get_node_or_null("ButtonArt") as TextureRect
	if art:
		art.scale = Vector2(1.12, 1.12) if active else Vector2.ONE
	var caption := button.get_node_or_null("ButtonLabel") as Label
	if caption:
		caption.add_theme_color_override("font_color", Color("#FFE46D") if active else Color("#FFF9EA"))
		caption.add_theme_color_override("font_outline_color", Color("#22130D"))
		caption.add_theme_constant_override("outline_size", 6)

func _update_room_view(room_name: String) -> void:
	var key := room_name.to_lower()
	room_title.text = key.to_upper()

	kitchen_drawer.visible = (key == "cocina")
	bath_drawer.visible = (key == "baño")
	bed_drawer.visible = (key == "dormitorio")
	play_drawer.visible = (key == "sala de juegos" or key == "juegos")

	# Los iconos permanecen a color; el cuarto activo se reconoce por tamaño y título dorado.
	_set_nav_active(btn_bed, key == "dormitorio")
	_set_nav_active(btn_kitchen, key == "cocina")
	_set_nav_active(btn_bath, key == "baño")
	_set_nav_active(btn_play, key == "sala de juegos" or key == "juegos")

	if key == "dormitorio":
		_update_sleep_button()

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

func _settings_row_style(accent: Color = Color("#62C8FF"), soft: Color = Color("#EAF8FF")) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = soft
	style.border_color = accent.lightened(0.12)
	style.set_border_width_all(3)
	style.set_corner_radius_all(30)
	style.shadow_color = Color(0.20, 0.12, 0.08, 0.16)
	style.shadow_size = 5
	return style

func _add_settings_toggle_row(parent: VBoxContainer, title_text: String, subtitle_text: String, icon_path: String, pressed_action: Callable) -> Button:
	var accent := Color("#55BFF4")
	var soft := Color("#E8F7FF")
	if title_text == "Música":
		accent = Color("#A58BFF")
		soft = Color("#F0ECFF")
	elif title_text == "Vibración":
		accent = Color("#FFB052")
		soft = Color("#FFF1DF")

	var row := PanelContainer.new()
	row.custom_minimum_size = Vector2(0, 126)
	row.add_theme_stylebox_override("panel", _settings_row_style(accent, soft))
	parent.add_child(row)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	row.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 17)
	margin.add_child(hbox)

	# Icono grande, sin cuadro: mantiene el look de juguete del resto del juego.
	var icon := TextureRect.new()
	icon.texture = _load_ui_texture(icon_path)
	icon.custom_minimum_size = Vector2(76, 76)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(icon)

	var labels := VBoxContainer.new()
	labels.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labels.alignment = BoxContainer.ALIGNMENT_CENTER
	labels.add_theme_constant_override("separation", 3)
	hbox.add_child(labels)

	var title := Label.new()
	title.text = title_text
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("#4F382B"))
	title.add_theme_color_override("font_outline_color", Color(1,1,1,0.85))
	title.add_theme_constant_override("outline_size", 3)
	labels.add_child(title)

	var subtitle := Label.new()
	subtitle.text = subtitle_text
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color("#8B6E5B"))
	labels.add_child(subtitle)

	var toggle := Button.new()
	toggle.custom_minimum_size = Vector2(132, 62)
	toggle.focus_mode = Control.FOCUS_NONE
	toggle.add_theme_font_size_override("font_size", 21)
	toggle.set_meta("settings_accent", accent)
	toggle.pressed.connect(pressed_action)
	hbox.add_child(toggle)
	return toggle


func _add_settings_icon_toggle(parent: HBoxContainer, title_text: String, on_icon: String, off_icon: String, accent: Color, pressed_action: Callable) -> Button:
	var button := Button.new()
	button.set_meta("icon_on", on_icon)
	button.set_meta("icon_off", off_icon)
	button.set_meta("settings_accent", accent)
	_set_image_button(button, on_icon, 112, Vector2(220, 205), title_text, 24)

	# V8: sin círculo/halo genérico detrás. La ilustración queda limpia y el
	# estado aparece como una pequeña etiqueta debajo.
	var state := Label.new()
	state.name = "StateBadge"
	state.mouse_filter = Control.MOUSE_FILTER_IGNORE
	state.anchor_left = 0.5
	state.anchor_right = 0.5
	state.anchor_top = 1.0
	state.anchor_bottom = 1.0
	state.offset_left = -76.0
	state.offset_right = 76.0
	state.offset_top = -24.0
	state.offset_bottom = 6.0
	state.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	state.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	state.add_theme_font_size_override("font_size", 16)
	state.add_theme_color_override("font_outline_color", Color("#FFF4D8"))
	state.add_theme_constant_override("outline_size", 3)
	button.add_child(state)

	button.pressed.connect(pressed_action)
	parent.add_child(button)
	return button


func _style_settings_toggle(button: Button, enabled: bool) -> void:
	if not button:
		return
	var art := button.get_node_or_null("ButtonArt") as TextureRect
	if art:
		var icon_path: String = str(button.get_meta("icon_on", "")) if enabled else str(button.get_meta("icon_off", ""))
		art.texture = _load_ui_texture(icon_path)
		art.modulate = Color.WHITE if enabled else Color(0.72, 0.72, 0.72, 1.0)

	var state := button.get_node_or_null("StateBadge") as Label
	if state:
		state.text = "ACTIVO" if enabled else "APAGADO"
		state.add_theme_color_override("font_color", Color("#2E9E5B") if enabled else Color("#81766F"))


func _setup_settings_modal() -> void:
	settings_popup = Control.new()
	settings_popup.name = "SettingsPopup"
	settings_popup.visible = false
	settings_popup.z_index = 85
	settings_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(settings_popup)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.035, 0.025, 0.04, 0.72)
	backdrop.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			_close_settings_modal()
	)
	settings_popup.add_child(backdrop)

	# Marco ilustrado centrado. Evitamos el letrero colgante grande que en V7
	# terminaba atravesando el contenido.
	var panel := PanelContainer.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(860, 1040)
	panel.size = Vector2(860, 1040)
	panel.position = Vector2(110, 440)
	panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	settings_popup.add_child(panel)

	var frame := TextureRect.new()
	frame.texture = _load_ui_texture(str(V7_ART["window_frame"]))
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_SCALE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(frame)

	# El propio marco ya trae una placa de madera arriba; ponemos el título ahí.
	var title := Label.new()
	title.anchor_left = 0.0
	title.anchor_right = 1.0
	title.offset_left = 150.0
	title.offset_right = -150.0
	title.offset_top = 38.0
	title.offset_bottom = 112.0
	title.text = "AJUSTES"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_style_caption(title, 35, Color("#FFF4D5"))
	title.add_theme_color_override("font_outline_color", Color("#4A2417"))
	panel.add_child(title)

	var btn_close := Button.new()
	btn_close.anchor_left = 1.0
	btn_close.anchor_right = 1.0
	btn_close.offset_left = -102.0
	btn_close.offset_right = -36.0
	btn_close.offset_top = 42.0
	btn_close.offset_bottom = 108.0
	_set_image_button(btn_close, str(UI_ICON["close"]), 52, Vector2(66, 66))
	btn_close.pressed.connect(_close_settings_modal)
	panel.add_child(btn_close)

	var content := VBoxContainer.new()
	content.position = Vector2(82, 178)
	content.size = Vector2(696, 760)
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 20)
	panel.add_child(content)

	var intro := Label.new()
	intro.text = "SONIDO Y RESPUESTA"
	intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro.add_theme_font_size_override("font_size", 23)
	intro.add_theme_color_override("font_color", Color("#6B3E29"))
	content.add_child(intro)

	var toggles := HBoxContainer.new()
	toggles.alignment = BoxContainer.ALIGNMENT_CENTER
	toggles.add_theme_constant_override("separation", 12)
	toggles.custom_minimum_size.y = 220
	content.add_child(toggles)

	btn_toggle_sfx = _add_settings_icon_toggle(toggles, "Sonido", str(UI_ICON["sound_on"]), str(UI_ICON["sound_off"]), Color("#52BDEB"), func():
		if gm:
			gm.sfx_enabled = !gm.sfx_enabled
			gm.save_game()
			_update_settings_ui()
	)
	btn_toggle_music = _add_settings_icon_toggle(toggles, "Música", str(UI_ICON["music_on"]), str(UI_ICON["music_off"]), Color("#9D7CF2"), func():
		if gm:
			gm.music_enabled = !gm.music_enabled
			gm.save_game()
			_update_settings_ui()
	)
	btn_toggle_vib = _add_settings_icon_toggle(toggles, "Vibración", str(UI_ICON["vibration_on"]), str(UI_ICON["vibration_off"]), Color("#F5A449"), func():
		if gm:
			gm.vibration_enabled = !gm.vibration_enabled
			gm.save_game()
			_update_settings_ui()
	)

	var divider := Label.new()
	divider.text = "★   •   ★   •   ★"
	divider.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	divider.add_theme_font_size_override("font_size", 22)
	divider.add_theme_color_override("font_color", Color("#E4AA2F"))
	content.add_child(divider)

	var game_title := Label.new()
	game_title.text = "MI PARTIDA"
	game_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_title.add_theme_font_size_override("font_size", 23)
	game_title.add_theme_color_override("font_color", Color("#6B3E29"))
	content.add_child(game_title)

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 70)
	actions.custom_minimum_size.y = 220
	content.add_child(actions)

	var btn_reset := Button.new()
	_set_image_button(btn_reset, str(UI_ICON["reset"]), 118, Vector2(245, 205), "Reiniciar", 24)
	btn_reset.tooltip_text = "Empezar una partida nueva"
	btn_reset.pressed.connect(_open_confirm_reset)
	actions.add_child(btn_reset)

	var btn_quit := Button.new()
	_set_image_button(btn_quit, str(UI_ICON["quit"]), 118, Vector2(245, 205), "Salir", 24)
	btn_quit.tooltip_text = "Salir del juego"
	btn_quit.pressed.connect(func():
		if gm:
			gm.save_game()
		get_tree().quit()
	)
	actions.add_child(btn_quit)

	var hint := Label.new()
	hint.text = "Toca un icono para cambiar su estado"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 17)
	hint.add_theme_color_override("font_color", Color("#8B6956"))
	content.add_child(hint)

	_update_settings_ui()

func _update_settings_ui() -> void:
	if not gm:
		return
	_style_settings_toggle(btn_toggle_sfx, gm.sfx_enabled)
	_style_settings_toggle(btn_toggle_music, gm.music_enabled)
	_style_settings_toggle(btn_toggle_vib, gm.vibration_enabled)

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

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.08, 0.05, 0.06, 0.64)
	confirm_reset_popup.add_child(backdrop)

	var panel := PanelContainer.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(800, 540)
	panel.size = Vector2(800, 540)
	panel.position = Vector2(140, 690)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#FFF1E8")
	panel_style.border_color = Color("#EE8E72")
	panel_style.set_border_width_all(5)
	panel_style.set_corner_radius_all(34)
	panel_style.shadow_color = Color(0.15, 0.07, 0.05, 0.34)
	panel_style.shadow_size = 12
	panel.add_theme_stylebox_override("panel", panel_style)
	confirm_reset_popup.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 38)
	margin.add_theme_constant_override("margin_right", 38)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 22)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox)

	var reset_icon := TextureRect.new()
	reset_icon.texture = _load_ui_texture(str(UI_ICON["reset"]))
	reset_icon.custom_minimum_size = Vector2(82, 82)
	reset_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	reset_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_apply_sticker(reset_icon, 9.0, 4.0)
	vbox.add_child(reset_icon)

	var title := Label.new()
	title.text = "¿REINICIAR A WONKY?"
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color("#7D4332"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var desc := Label.new()
	desc.text = "Se borrarán monedas, comida, nivel y estadísticas.\nWonky volverá a empezar desde el Nivel 1."
	desc.add_theme_font_size_override("font_size", 22)
	desc.add_theme_color_override("font_color", Color("#8C6A5B"))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(desc)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 18)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	var btn_cancel := Button.new()
	btn_cancel.custom_minimum_size = Vector2(280, 82)
	btn_cancel.text = "Cancelar"
	btn_cancel.add_theme_font_size_override("font_size", 26)
	btn_cancel.add_theme_color_override("font_color", Color("#5F554F"))
	btn_cancel.add_theme_stylebox_override("normal", _create_card_style(Color("#F1ECE7"), Color("#C9BDB5")))
	btn_cancel.pressed.connect(func():
		confirm_reset_popup.visible = false
	)
	hbox.add_child(btn_cancel)

	var btn_confirm := Button.new()
	btn_confirm.custom_minimum_size = Vector2(300, 82)
	_set_button_icon(btn_confirm, str(UI_ICON["reset"]), "Sí, reiniciar", 42)
	btn_confirm.add_theme_font_size_override("font_size", 26)
	btn_confirm.add_theme_color_override("font_color", Color("#7D342E"))
	btn_confirm.add_theme_stylebox_override("normal", _create_card_style(Color("#FFD6CE"), Color("#E77B70")))
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
			gm.show_floating_text.emit("Wonky volvió a empezar", Vector2(540, 850), Color(0.4, 1.0, 0.5))
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
