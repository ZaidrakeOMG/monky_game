extends Control
## Portrait arcade hub. Native Containers keep every game reachable on small phones.
## Supports both Classic Arcade and La Escuelita educational minigames.

const UI := preload("res://scripts/ui/wonder_ui.gd")
const Art := preload("res://scripts/ui/wonder_assets.gd")

const GAMES := [
	{"id": "flappy", "title": "FLAPPY", "subtitle": "Entre tubos y cielos mágicos", "scene": "flappy_monky", "icon": "res://imagenes/ui_polished/minijuegos/flappy.png", "color": Color("8bf0bc")},
	{"id": "fruit", "title": "ATRAPA LA FRUTA", "subtitle": "Mueve la canasta. Evita las bombas.", "scene": "fruit_catcher", "icon": "res://imagenes/ui_polished/minijuegos/fruit_catcher.png", "color": Color("ffd36b")},
	{"id": "jump", "title": "WONKY JUMP", "subtitle": "Un salto más alto, un nuevo récord.", "scene": "monky_jump", "icon": "res://imagenes/ui_polished/minijuegos/monky_jump.png", "color": Color("b7b4ff")},
	{"id": "runner", "title": "WONKY RUN", "subtitle": "Corre, esquiva y reúne monedas.", "scene": "wonky_runner", "icon": "res://imagenes/runner/cover.png", "color": Color("ffb89c")}
]

const SCHOOL_GAMES := [
	{"id": "animal_sounds", "title": "ANIMALES", "subtitle": "¿Quién hace este sonido? Escucha, aprende y diviértete.", "scene": "school/animal_sounds", "icon": "res://imagenes/escuela/animales/perro.png", "color": Color("#FFB26B"), "eyebrow": "SONIDOS Y DIBUJOS"},
	{"id": "colors", "title": "COLORES", "subtitle": "¿De qué color es cada dibujo? Taller de pintura.", "scene": "school/animal_sounds", "icon": "res://imagenes/escuela/animales/pato.png", "color": Color("#6BCB77"), "eyebrow": "ARTE INFANTIL", "locked": true},
	{"id": "counting", "title": "CONTAR", "subtitle": "Cuenta frutas y objetos con Wonky.", "scene": "school/animal_sounds", "icon": "res://imagenes/opt/hud/manzana.png", "color": Color("#4D96FF"), "eyebrow": "NÚMEROS", "locked": true}
]

var gm: Node = null
var coins_label: Label = null
var _sub_wordmark: Label = null
var _tagline: Label = null
var _note: Label = null
var _cards_container: VBoxContainer = null
var _tab_arcade_btn: Button = null
var _tab_school_btn: Button = null
var _active_tab: String = "arcade"

func _ready() -> void:
	gm = get_tree().root.get_node_or_null("GameManager")
	set_meta("wonder_custom", true)
	_build()
	_update_coins()
	if gm != null:
		gm.coins_changed.connect(_coins_changed)

func _build() -> void:
	var backdrop := TextureRect.new()
	backdrop.texture = Art.background("flappy")
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	UI.full_rect(backdrop, self)
	var veil := TextureRect.new()
	veil.texture = UI.gradient(Color(0.035, 0.08, 0.17, 0.65), Color(0.035, 0.075, 0.15, 0.98))
	UI.full_rect(veil, self)
	var margin := MarginContainer.new()
	add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_right"]:
		margin.add_theme_constant_override(side, 48)
	margin.add_theme_constant_override("margin_top", 80)
	margin.add_theme_constant_override("margin_bottom", 48)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 20)
	margin.add_child(layout)

	# Cabecera superior
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 24)
	layout.add_child(header)

	var back := Button.new()
	back.name = "BtnBack"
	back.text = "‹"
	back.tooltip_text = "Volver con Wonky"
	back.custom_minimum_size = Vector2(112, 112)
	back.add_theme_font_size_override("font_size", 72)
	UI.button(back)
	header.add_child(back)
	back.pressed.connect(_back)

	var wordmark := VBoxContainer.new()
	wordmark.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wordmark.add_theme_constant_override("separation", -8)
	header.add_child(wordmark)
	wordmark.add_child(UI.text("WONKY", 68))
	_sub_wordmark = UI.text("A R C A D E", 26, UI.MINT)
	wordmark.add_child(_sub_wordmark)

	var wallet := PanelContainer.new()
	wallet.custom_minimum_size.x = 220
	wallet.add_theme_stylebox_override("panel", UI.panel(UI.INK, Color("a48b55"), 28, 20))
	header.add_child(wallet)

	var wallet_row := HBoxContainer.new()
	wallet_row.add_theme_constant_override("separation", 12)
	wallet.add_child(wallet_row)

	var coin := TextureRect.new()
	coin.texture = UI.texture("res://imagenes/opt/hud/moneda.png")
	coin.custom_minimum_size = Vector2(50, 50)
	coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	wallet_row.add_child(coin)

	coins_label = UI.text("0", 38, UI.GOLD)
	coins_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wallet_row.add_child(coins_label)

	# Selector de pestañas: [ Arcade ] y [ La Escuelita ]
	var tabs_row := HBoxContainer.new()
	tabs_row.name = "CategoryTabs"
	tabs_row.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs_row.add_theme_constant_override("separation", 20)
	tabs_row.custom_minimum_size.y = 74
	layout.add_child(tabs_row)

	_tab_arcade_btn = Button.new()
	_tab_arcade_btn.text = "🕹️  ARCADE"
	_tab_arcade_btn.custom_minimum_size = Vector2(460, 68)
	_tab_arcade_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tab_arcade_btn.add_theme_font_size_override("font_size", 28)
	_tab_arcade_btn.focus_mode = Control.FOCUS_NONE
	tabs_row.add_child(_tab_arcade_btn)
	_tab_arcade_btn.pressed.connect(func(): _switch_tab("arcade"))

	_tab_school_btn = Button.new()
	_tab_school_btn.text = "🏫  LA ESCUELITA"
	_tab_school_btn.custom_minimum_size = Vector2(460, 68)
	_tab_school_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tab_school_btn.add_theme_font_size_override("font_size", 28)
	_tab_school_btn.focus_mode = Control.FOCUS_NONE
	tabs_row.add_child(_tab_school_btn)
	_tab_school_btn.pressed.connect(func(): _switch_tab("school"))

	_tagline = UI.text("Tu próxima aventura empieza aquí.", 34, UI.MUTED)
	layout.add_child(_tagline)

	var scroll := ScrollContainer.new()
	scroll.name = "GamesScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	layout.add_child(scroll)

	_cards_container = VBoxContainer.new()
	_cards_container.name = "Games"
	_cards_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cards_container.add_theme_constant_override("separation", 24)
	scroll.add_child(_cards_container)

	# Población inicial con Arcade (esperado por tests de regresión y UI)
	for index in range(GAMES.size()):
		_cards_container.add_child(_card(GAMES[index], index == 0))

	_note = UI.text("4 aventuras · tus monedas y récords, en un solo lugar", 27, UI.MUTED)
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(_note)

	_style_tab_button(_tab_arcade_btn, true)
	_style_tab_button(_tab_school_btn, false)
	back.grab_focus()

func _style_tab_button(btn: Button, is_active: bool) -> void:
	if not btn:
		return
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(20)
	if is_active:
		sb.bg_color = Color("#5C351B")
		sb.border_color = Color("#F5B942")
		sb.set_border_width_all(3)
		sb.shadow_color = Color(0.96, 0.72, 0.26, 0.35)
		sb.shadow_size = 6
		btn.add_theme_color_override("font_color", Color("#FFF0C8"))
	else:
		sb.bg_color = Color("#172635", 0.75)
		sb.border_color = Color("#3B5066", 0.5)
		sb.set_border_width_all(2)
		btn.add_theme_color_override("font_color", Color("#8FA7BF"))
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb)
	btn.add_theme_stylebox_override("pressed", sb)

func _switch_tab(tab_name: String) -> void:
	if _active_tab == tab_name and _cards_container.get_child_count() > 0:
		return
	_active_tab = tab_name
	if AudioManager:
		AudioManager.play_pop()

	_style_tab_button(_tab_arcade_btn, _active_tab == "arcade")
	_style_tab_button(_tab_school_btn, _active_tab == "school")

	for child in _cards_container.get_children():
		child.queue_free()

	if _active_tab == "arcade":
		_sub_wordmark.text = "A R C A D E"
		_sub_wordmark.add_theme_color_override("font_color", UI.MINT)
		_tagline.text = "Tu próxima aventura empieza aquí."
		_note.text = "4 aventuras · tus monedas y récords, en un solo lugar"
		for index in range(GAMES.size()):
			_cards_container.add_child(_card(GAMES[index], index == 0))
	else:
		_sub_wordmark.text = "L A   E S C U E L I T A"
		_sub_wordmark.add_theme_color_override("font_color", Color("#FFD36B"))
		_tagline.text = "Aprende jugando con Wonky · Sonidos, colores y dibujos."
		_note.text = "Aprende con dibujos y sonidos · ¡Gana monedas y estrellas para Wonky!"
		for index in range(SCHOOL_GAMES.size()):
			_cards_container.add_child(_card(SCHOOL_GAMES[index], index == 0))

func _card(data: Dictionary, featured: bool) -> Button:
	var card := Button.new()
	card.name = "Game_" + str(data.id)
	card.custom_minimum_size.y = 430 if featured else 300
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.clip_contents = true
	card.tooltip_text = str(data.title) + " · " + str(data.subtitle)
	card.focus_mode = Control.FOCUS_ALL
	UI.button(card)
	card.add_theme_stylebox_override("normal", UI.panel(Color("243f54"), data.color, 32, 0))

	var is_locked: bool = bool(data.get("locked", false))
	if is_locked:
		card.pressed.connect(func():
			if AudioManager:
				AudioManager.play_pop()
		)
	else:
		card.pressed.connect(_open.bind("res://scenes/minigames/" + str(data.scene) + ".tscn"))

	var picture := TextureRect.new()
	if str(data.id) in ["flappy", "fruit", "jump", "runner"]:
		picture.texture = Art.background(str(data.id))
	else:
		picture.texture = UI.gradient(Color(0.08, 0.20, 0.16, 0.95), Color(0.04, 0.10, 0.08, 0.95))
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	UI.full_rect(picture, card)
	picture.offset_left = 10
	picture.offset_right = -10
	picture.offset_top = 10
	picture.offset_bottom = -10

	var wash := TextureRect.new()
	wash.texture = UI.gradient(Color(0.04, 0.10, 0.19, 0.96), Color(0.04, 0.10, 0.19, 0.40), true)
	UI.full_rect(wash, card)
	wash.offset_left = 10
	wash.offset_right = -10
	wash.offset_top = 10
	wash.offset_bottom = -10

	var icon := TextureRect.new()
	icon.texture = UI.texture(str(data.icon))
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	card.add_child(icon)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.anchor_left = 0.70
	icon.anchor_right = 1.0
	icon.anchor_bottom = 1.0
	icon.offset_top = 20
	icon.offset_right = -20
	icon.offset_bottom = -20

	var eyebrow_text: String = str(data.get("eyebrow", "CIELOS MÁGICOS" if featured else "AVENTURA"))
	var eyebrow := UI.text(eyebrow_text, 25, data.color)
	card.add_child(eyebrow)
	eyebrow.position = Vector2(32, 26)

	var heading := UI.text(str(data.title), 72 if featured else 48)
	card.add_child(heading)
	heading.position = Vector2(30, 65)
	heading.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.35))
	heading.add_theme_constant_override("shadow_offset_y", 4)

	var description := UI.text(str(data.subtitle), 28, UI.MUTED)
	card.add_child(description)
	description.position = Vector2(34, 187 if featured else 128)
	description.size = Vector2(640, 72)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	if not is_locked and str(data.id) in ["flappy", "fruit", "jump", "runner"]:
		var record_value: int = int(gm.get_record(str(data.id))) if gm != null else 0
		var record := UI.text("RÉCORD  " + str(record_value), 29, data.color)
		card.add_child(record)
		record.anchor_top = 1.0
		record.anchor_bottom = 1.0
		record.offset_left = 34
		record.offset_top = -77
		record.offset_bottom = -34
	elif not is_locked:
		var badge := UI.text("DIDÁCTICO · SONIDOS", 26, Color("#FFE29A"))
		card.add_child(badge)
		badge.anchor_top = 1.0
		badge.anchor_bottom = 1.0
		badge.offset_left = 34
		badge.offset_top = -77
		badge.offset_bottom = -34

	var cta := PanelContainer.new()
	card.add_child(cta)
	cta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cta.anchor_top = 1.0
	cta.anchor_bottom = 1.0
	cta.offset_left = 380
	cta.offset_right = 650
	cta.offset_top = -98
	cta.offset_bottom = -26
	cta.add_theme_stylebox_override("panel", UI.panel(data.color if not is_locked else Color("#455A64"), data.color, 24, 12))
	var cta_label := UI.text("PRONTO" if is_locked else "JUGAR  ›", 32, UI.INK if not is_locked else Color("#B0BEC5"))
	cta_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cta.add_child(cta_label)
	return card

func _coins_changed(_value: int) -> void:
	_update_coins()

func _update_coins() -> void:
	coins_label.text = str(gm.coins) if gm != null else "0"

func _open(path: String) -> void:
	if not SceneRouter.busy:
		SceneRouter.go(path)

func _back() -> void:
	if SceneRouter.busy:
		return
	if gm != null:
		gm.change_room("sala de juegos")
	_open("res://scenes/main.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_back()
		get_viewport().set_input_as_handled()
