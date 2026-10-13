extends Control
## Portrait arcade hub. Native Containers keep every game reachable on small phones.

const UI := preload("res://scripts/ui/wonder_ui.gd")
const Art := preload("res://scripts/ui/wonder_assets.gd")
const GAMES := [
	{"id": "flappy", "title": "FLAPPY", "subtitle": "Entre tubos y cielos mágicos", "scene": "flappy_monky", "icon": "res://imagenes/ui_polished/minijuegos/flappy.png", "color": Color("8bf0bc")},
	{"id": "fruit", "title": "ATRAPA LA FRUTA", "subtitle": "Mueve la canasta. Evita las bombas.", "scene": "fruit_catcher", "icon": "res://imagenes/ui_polished/minijuegos/fruit_catcher.png", "color": Color("ffd36b")},
	{"id": "jump", "title": "WONKY JUMP", "subtitle": "Un salto más alto, un nuevo récord.", "scene": "monky_jump", "icon": "res://imagenes/ui_polished/minijuegos/monky_jump.png", "color": Color("b7b4ff")},
	{"id": "runner", "title": "WONKY RUN", "subtitle": "Corre, esquiva y reúne monedas.", "scene": "wonky_runner", "icon": "res://imagenes/runner/cover.png", "color": Color("ffb89c")}
]
var gm: Node
var coins_label: Label
var _opening: bool = false

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
	backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVER
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
	layout.add_theme_constant_override("separation", 24)
	margin.add_child(layout)
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
	wordmark.add_child(UI.text("A R C A D E", 26, UI.MINT))
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
	layout.add_child(UI.text("Tu próxima aventura empieza aquí.", 36, UI.MUTED))
	var scroll := ScrollContainer.new()
	scroll.name = "GamesScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	layout.add_child(scroll)
	var cards := VBoxContainer.new()
	cards.name = "Games"
	cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards.add_theme_constant_override("separation", 24)
	scroll.add_child(cards)
	for index in range(GAMES.size()):
		cards.add_child(_card(GAMES[index], index == 0))
	var note := UI.text("4 aventuras · tus monedas y récords, en un solo lugar", 27, UI.MUTED)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(note)
	back.grab_focus()

func _card(data: Dictionary, featured: bool) -> Button:
	var card := Button.new()
	card.name = "Game_" + str(data.id)
	card.custom_minimum_size.y = 430 if featured else 300
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.clip_contents = true
	card.tooltip_text = str(data.title) + " · " + str(data.subtitle)
	UI.button(card)
	card.add_theme_stylebox_override("normal", UI.panel(Color("243f54"), data.color, 32, 0))
	card.pressed.connect(_open.bind("res://scenes/minigames/" + str(data.scene) + ".tscn"))
	var picture := TextureRect.new()
	picture.texture = Art.background(str(data.id))
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVER
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
	icon.anchor_left = 0.73
	icon.anchor_right = 1.0
	icon.anchor_bottom = 1.0
	icon.offset_top = 24
	icon.offset_right = -20
	icon.offset_bottom = -24
	var eyebrow := UI.text("CIELOS MÁGICOS" if featured else "AVENTURA", 25, data.color)
	card.add_child(eyebrow)
	eyebrow.position = Vector2(32, 26)
	var heading := UI.text(str(data.title), 92 if featured else 48)
	card.add_child(heading)
	heading.position = Vector2(30, 65)
	heading.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.35))
	heading.add_theme_constant_override("shadow_offset_y", 4)
	var description := UI.text(str(data.subtitle), 30, UI.MUTED)
	card.add_child(description)
	description.position = Vector2(34, 187 if featured else 128)
	description.size = Vector2(660, 72)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var record_value: int = int(gm.get_record(str(data.id))) if gm != null else 0
	var record := UI.text("RÉCORD  " + str(record_value), 29, data.color)
	card.add_child(record)
	record.anchor_top = 1.0
	record.anchor_bottom = 1.0
	record.offset_left = 34
	record.offset_top = -77
	record.offset_bottom = -34
	var cta := PanelContainer.new()
	card.add_child(cta)
	cta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cta.anchor_top = 1.0
	cta.anchor_bottom = 1.0
	cta.offset_left = 380
	cta.offset_right = 650
	cta.offset_top = -98
	cta.offset_bottom = -26
	cta.add_theme_stylebox_override("panel", UI.panel(data.color, data.color, 24, 12))
	var cta_label := UI.text("JUGAR  ›", 32, UI.INK)
	cta_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cta.add_child(cta_label)
	return card

func _coins_changed(_value: int) -> void:
	_update_coins()

func _update_coins() -> void:
	coins_label.text = str(gm.coins) if gm != null else "0"

func _open(path: String) -> void:
	if _opening:
		return
	_opening = SceneRouter.go(path)

func _back() -> void:
	if _opening:
		return
	if gm != null:
		gm.change_room("sala de juegos")
	_open("res://scenes/main.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_back()
		get_viewport().set_input_as_handled()
