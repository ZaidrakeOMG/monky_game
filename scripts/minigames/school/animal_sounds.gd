extends Control

## Minijuego educativo "Animales y Sonidos" para La Escuelita de Wonky.
## Los niños escuchan el sonido de un animal, observan las ilustraciones y aprenden jugando.

const UI := preload("res://scripts/ui/wonder_ui.gd")

const ANIMALS := {
	"perro": {
		"name": "PERRO",
		"sound": "res://audio/sfx/school/perro.ogg",
		"icon": "res://imagenes/escuela/animales/perro.png",
		"onomatopoeia": "¡GUAU, GUAU!",
		"color": Color("#FFB26B")
	},
	"gato": {
		"name": "GATO",
		"sound": "res://audio/sfx/school/gato.ogg",
		"icon": "res://imagenes/escuela/animales/gato.png",
		"onomatopoeia": "¡MIAU, MIAU!",
		"color": Color("#FF8B8B")
	},
	"vaca": {
		"name": "VACA",
		"sound": "res://audio/sfx/school/vaca.ogg",
		"icon": "res://imagenes/escuela/animales/vaca.png",
		"onomatopoeia": "¡MUUU, MUUU!",
		"color": Color("#6BCB77")
	},
	"pato": {
		"name": "PATO",
		"sound": "res://audio/sfx/school/pato.ogg",
		"icon": "res://imagenes/escuela/animales/pato.png",
		"onomatopoeia": "¡CUAK, CUAK!",
		"color": Color("#FFD93D")
	},
	"oveja": {
		"name": "OVEJA",
		"sound": "res://audio/sfx/school/oveja.ogg",
		"icon": "res://imagenes/escuela/animales/oveja.png",
		"onomatopoeia": "¡BEEE, BEEE!",
		"color": Color("#B983FF")
	},
	"gallo": {
		"name": "GALLO",
		"sound": "res://audio/sfx/school/gallo.ogg",
		"icon": "res://imagenes/escuela/animales/gallo.png",
		"onomatopoeia": "¡KIKIRIKÍ!",
		"color": Color("#FF6B6B")
	}
}

var gm: Node = null
var current_target: String = ""
var is_round_transition: bool = false
var stars_earned: int = 0
var audio_cache: Dictionary = {}

var audio_player: AudioStreamPlayer = null
var sfx_feedback_player: AudioStreamPlayer = null
var coins_label: Label = null
var stars_label: Label = null
var speaker_button: Button = null
var banner_label: Label = null
var cards_grid: GridContainer = null
var card_buttons: Array[Button] = []

func _ready() -> void:
	gm = get_tree().root.get_node_or_null("GameManager")
	set_meta("wonder_custom", true)
	if AudioManager:
		AudioManager.set_music_volume_db(-18.0, 0.4)
	_preload_audio()
	_build_ui()
	_start_new_round()

func _exit_tree() -> void:
	if AudioManager:
		AudioManager.set_music_volume_db(AudioManager.DEFAULT_MUSIC_DB, 0.4)

func _preload_audio() -> void:
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = "Master"
	audio_player.volume_db = 2.0
	audio_player.finished.connect(_on_animal_sound_finished)
	add_child(audio_player)

	sfx_feedback_player = AudioStreamPlayer.new()
	sfx_feedback_player.bus = "Master"
	add_child(sfx_feedback_player)

	for key in ANIMALS:
		var sound_path: String = ANIMALS[key]["sound"]
		if ResourceLoader.exists(sound_path):
			audio_cache[key] = load(sound_path)

func _build_ui() -> void:
	# Fondo cálido de salón de clases / pizarra
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#20382E") # Verde pizarra escolar clásico
	add_child(bg)

	var frame_vignette := TextureRect.new()
	frame_vignette.texture = UI.gradient(Color(0.08, 0.16, 0.12, 0.85), Color(0.12, 0.22, 0.18, 0.35))
	frame_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame_vignette)

	# Borde decorativo de madera enmarcando la pizarra
	var board_frame := Panel.new()
	board_frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	board_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var frame_st := StyleBoxFlat.new()
	frame_st.bg_color = Color(0, 0, 0, 0)
	frame_st.border_color = Color("#8B5226")
	frame_st.set_border_width_all(20)
	frame_st.set_corner_radius_all(24)
	board_frame.add_theme_stylebox_override("panel", frame_st)
	add_child(board_frame)

	# Margen de contenido principal
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_top", 60)
	margin.add_theme_constant_override("margin_bottom", 60)
	add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 24)
	layout.alignment = BoxContainer.ALIGNMENT_BEGIN
	margin.add_child(layout)

	# 1. Cabecera superior: Volver, Título y Cartera
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 18)
	layout.add_child(header)

	var btn_back := Button.new()
	btn_back.text = "‹"
	btn_back.custom_minimum_size = Vector2(96, 96)
	btn_back.add_theme_font_size_override("font_size", 64)
	btn_back.focus_mode = Control.FOCUS_NONE
	var back_st := StyleBoxFlat.new()
	back_st.bg_color = Color("#5C351B")
	back_st.border_color = Color("#F5B942")
	back_st.set_border_width_all(3)
	back_st.set_corner_radius_all(20)
	btn_back.add_theme_stylebox_override("normal", back_st)
	btn_back.add_theme_stylebox_override("hover", back_st)
	btn_back.add_theme_stylebox_override("pressed", back_st)
	UIEffects.bind_button(btn_back)
	btn_back.pressed.connect(_on_back_pressed)
	header.add_child(btn_back)

	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_theme_constant_override("separation", -4)
	header.add_child(title_box)

	var main_title := Label.new()
	main_title.text = "ANIMALES Y SONIDOS"
	main_title.add_theme_font_size_override("font_size", 42)
	main_title.add_theme_color_override("font_color", Color("#FFF7E2"))
	main_title.add_theme_color_override("font_outline_color", Color("#26170F"))
	main_title.add_theme_constant_override("outline_size", 6)
	title_box.add_child(main_title)

	var sub_title := Label.new()
	sub_title.text = "LA ESCUELITA DE WONKY"
	sub_title.add_theme_font_size_override("font_size", 22)
	sub_title.add_theme_color_override("font_color", Color("#E4C386"))
	title_box.add_child(sub_title)

	# Cartera y estrellas
	var stats_box := HBoxContainer.new()
	stats_box.add_theme_constant_override("separation", 14)
	header.add_child(stats_box)

	var stars_panel := PanelContainer.new()
	var stars_st := StyleBoxFlat.new()
	stars_st.bg_color = Color("#1D2B24", 0.90)
	stars_st.border_color = Color("#F5B942")
	stars_st.set_border_width_all(2)
	stars_st.set_corner_radius_all(18)
	stars_st.content_margin_left = 16
	stars_st.content_margin_right = 16
	stars_panel.add_theme_stylebox_override("panel", stars_st)
	stats_box.add_child(stars_panel)

	stars_label = Label.new()
	stars_label.text = "⭐ 0"
	stars_label.add_theme_font_size_override("font_size", 28)
	stars_label.add_theme_color_override("font_color", Color("#FFE599"))
	stars_panel.add_child(stars_label)

	var coins_panel := PanelContainer.new()
	var coins_st := StyleBoxFlat.new()
	coins_st.bg_color = Color("#321C12", 0.92)
	coins_st.border_color = Color("#F5B942")
	coins_st.set_border_width_all(2)
	coins_st.set_corner_radius_all(18)
	coins_st.content_margin_left = 16
	coins_st.content_margin_right = 16
	coins_panel.add_theme_stylebox_override("panel", coins_st)
	stats_box.add_child(coins_panel)

	coins_label = Label.new()
	coins_label.text = "🪙 " + str(gm.coins if gm else 0)
	coins_label.add_theme_font_size_override("font_size", 28)
	coins_label.add_theme_color_override("font_color", Color("#FFF0C8"))
	coins_panel.add_child(coins_label)

	# 2. Estación interactiva de audio (Altavoz gigante)
	var sound_card := PanelContainer.new()
	sound_card.custom_minimum_size.y = 380
	sound_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sc_style := StyleBoxFlat.new()
	sc_style.bg_color = Color("#162820", 0.95)
	sc_style.border_color = Color("#D9A84E")
	sc_style.set_border_width_all(3)
	sc_style.set_corner_radius_all(28)
	sc_style.shadow_color = Color(0, 0, 0, 0.40)
	sc_style.shadow_size = 8
	sound_card.add_theme_stylebox_override("panel", sc_style)
	layout.add_child(sound_card)

	var sound_inner := VBoxContainer.new()
	sound_inner.alignment = BoxContainer.ALIGNMENT_CENTER
	sound_inner.add_theme_constant_override("separation", 16)
	sound_card.add_child(sound_inner)

	banner_label = Label.new()
	banner_label.text = "¡Escucha con atención! ¿Quién hace este sonido?"
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.add_theme_font_size_override("font_size", 30)
	banner_label.add_theme_color_override("font_color", Color("#FFF9EA"))
	banner_label.add_theme_color_override("font_outline_color", Color("#191008"))
	banner_label.add_theme_constant_override("outline_size", 5)
	sound_inner.add_child(banner_label)

	speaker_button = Button.new()
	speaker_button.custom_minimum_size = Vector2(210, 210)
	speaker_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	speaker_button.focus_mode = Control.FOCUS_NONE
	var spk_style := StyleBoxFlat.new()
	spk_style.bg_color = Color("#5A3018")
	spk_style.border_color = Color("#F5B942")
	spk_style.set_border_width_all(4)
	spk_style.set_corner_radius_all(105)
	spk_style.shadow_color = Color(0.96, 0.72, 0.26, 0.45)
	spk_style.shadow_size = 12
	speaker_button.add_theme_stylebox_override("normal", spk_style)
	speaker_button.add_theme_stylebox_override("hover", spk_style)
	speaker_button.add_theme_stylebox_override("pressed", spk_style)
	UIEffects.bind_button(speaker_button)
	speaker_button.pressed.connect(_play_target_sound)
	sound_inner.add_child(speaker_button)

	var spk_icon := Label.new()
	spk_icon.text = "🔊"
	spk_icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	spk_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	spk_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	spk_icon.add_theme_font_size_override("font_size", 84)
	spk_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	speaker_button.add_child(spk_icon)

	var spk_hint := Label.new()
	spk_hint.text = "Toca el altavoz para volver a escuchar"
	spk_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	spk_hint.add_theme_font_size_override("font_size", 22)
	spk_hint.add_theme_color_override("font_color", Color("#B0CDBC"))
	sound_inner.add_child(spk_hint)

	# 3. Cuadrícula de opciones: 4 tarjetas de animales (2x2)
	cards_grid = GridContainer.new()
	cards_grid.columns = 2
	cards_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cards_grid.add_theme_constant_override("h_separation", 28)
	cards_grid.add_theme_constant_override("v_separation", 28)
	layout.add_child(cards_grid)

	for i in range(4):
		var card := _create_animal_card(i)
		cards_grid.add_child(card)
		card_buttons.append(card)

func _create_animal_card(index: int) -> Button:
	var btn := Button.new()
	btn.name = "AnimalCard_" + str(index)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size = Vector2(440, 480)
	btn.focus_mode = Control.FOCUS_NONE

	var c_style := StyleBoxFlat.new()
	c_style.bg_color = Color("#FAF3E0")
	c_style.border_color = Color("#8B5226")
	c_style.set_border_width_all(4)
	c_style.set_corner_radius_all(26)
	c_style.shadow_color = Color(0, 0, 0, 0.35)
	c_style.shadow_size = 8
	btn.add_theme_stylebox_override("normal", c_style)
	btn.add_theme_stylebox_override("hover", c_style)
	btn.add_theme_stylebox_override("pressed", c_style)
	UIEffects.bind_button(btn)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 12)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(vbox)

	var icon_rect := TextureRect.new()
	icon_rect.name = "AnimalIcon"
	icon_rect.custom_minimum_size = Vector2(330, 330)
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(icon_rect)

	var name_label := Label.new()
	name_label.name = "AnimalName"
	name_label.text = "ANIMAL"
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 34)
	name_label.add_theme_color_override("font_color", Color("#4A2613"))
	name_label.add_theme_color_override("font_outline_color", Color("#FAF3E0"))
	name_label.add_theme_constant_override("outline_size", 6)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_label)

	btn.pressed.connect(func(): _on_card_selected(btn))
	return btn

func _start_new_round() -> void:
	is_round_transition = false
	banner_label.text = "¡Escucha con atención! ¿Quién hace este sonido?"
	banner_label.add_theme_color_override("font_color", Color("#FFF9EA"))

	var all_keys: Array = ANIMALS.keys()
	all_keys.shuffle()
	current_target = str(all_keys[0])

	# Seleccionar 4 candidatos (1 correcto + 3 distractores)
	var choices: Array = [current_target]
	for k in all_keys:
		if k != current_target and choices.size() < 4:
			choices.append(k)
	choices.shuffle()

	# Configurar las 4 tarjetas
	for i in range(4):
		var card: Button = card_buttons[i]
		var animal_id: String = str(choices[i])
		var data: Dictionary = ANIMALS[animal_id]

		card.set_meta("animal_id", animal_id)
		card.disabled = false
		card.modulate = Color.WHITE

		var default_style := StyleBoxFlat.new()
		default_style.bg_color = Color("#FAF3E0")
		default_style.border_color = Color("#8B5226")
		default_style.set_border_width_all(4)
		default_style.set_corner_radius_all(26)
		card.add_theme_stylebox_override("normal", default_style)
		card.add_theme_stylebox_override("hover", default_style)

		var icon := card.find_child("AnimalIcon", true, false) as TextureRect
		if icon:
			if ResourceLoader.exists(data["icon"]):
				icon.texture = load(data["icon"]) as Texture2D

		var lbl := card.find_child("AnimalName", true, false) as Label
		if lbl:
			lbl.text = str(data["name"])

	# Reproducir el sonido del animal automáticamente tras una pequeña pausa
	get_tree().create_timer(0.4).timeout.connect(func():
		if is_inside_tree() and not is_round_transition:
			_play_target_sound()
	)

func _play_target_sound() -> void:
	if not current_target.is_empty() and audio_cache.has(current_target):
		if AudioManager:
			# Atenuar aún más la música mientras suena el animal (ducking para máxima claridad)
			AudioManager.set_music_volume_db(-26.0, 0.15)
		audio_player.stream = audio_cache[current_target]
		audio_player.play()

		# Pulso de animación en el botón altavoz
		var tw := create_tween()
		tw.tween_property(speaker_button, "scale", Vector2(1.15, 1.15), 0.12).set_trans(Tween.TRANS_QUAD)
		tw.tween_property(speaker_button, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BOUNCE)

func _on_animal_sound_finished() -> void:
	if is_inside_tree() and AudioManager:
		# Restaurar al volumen suave de la escuelita (-18.0 dB)
		AudioManager.set_music_volume_db(-18.0, 0.35)

func _on_card_selected(card: Button) -> void:
	if is_round_transition:
		return

	var chosen_id: String = str(card.get_meta("animal_id", ""))
	if chosen_id == current_target:
		_handle_correct(card)
	else:
		_handle_incorrect(card)

func _handle_correct(card: Button) -> void:
	is_round_transition = true
	stars_earned += 1
	stars_label.text = "⭐ " + str(stars_earned)

	# Recompensa al jugador
	if gm:
		gm.add_coins(10)
		gm.add_xp(5)
		gm.save_game()
		coins_label.text = "🪙 " + str(gm.coins)

	# Sonido festivo de victoria
	if ResourceLoader.exists("res://audio/sfx/ui/buy_success.ogg"):
		sfx_feedback_player.stream = load("res://audio/sfx/ui/buy_success.ogg")
		sfx_feedback_player.play()

	# Tarjeta iluminada y festejando
	var target_data: Dictionary = ANIMALS[current_target]
	var win_style := StyleBoxFlat.new()
	win_style.bg_color = Color("#E3FFDA")
	win_style.border_color = Color("#2E9E5B")
	win_style.set_border_width_all(6)
	win_style.set_corner_radius_all(26)
	win_style.shadow_color = Color(0.2, 0.8, 0.4, 0.5)
	win_style.shadow_size = 14
	card.add_theme_stylebox_override("normal", win_style)
	card.add_theme_stylebox_override("hover", win_style)

	banner_label.text = "¡EXCELENTE! " + str(target_data["onomatopoeia"])
	banner_label.add_theme_color_override("font_color", Color("#7BF8A6"))

	# Salto de animación en la tarjeta ganadora
	var tw := create_tween()
	tw.tween_property(card, "scale", Vector2(1.08, 1.08), 0.15).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(card, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BOUNCE)

	# Transición a la siguiente ronda
	get_tree().create_timer(1.8).timeout.connect(func():
		if is_inside_tree():
			_start_new_round()
	)

func _handle_incorrect(card: Button) -> void:
	# Wobble suave y motivador
	var tw := create_tween()
	tw.tween_property(card, "rotation", deg_to_rad(4.0), 0.08)
	tw.tween_property(card, "rotation", deg_to_rad(-4.0), 0.08)
	tw.tween_property(card, "rotation", 0.0, 0.08)

	banner_label.text = "¡Casi! Escucha el sonido otra vez 🐾"
	banner_label.add_theme_color_override("font_color", Color("#FFD97D"))

	# Sonido suave de reintento
	if AudioManager:
		AudioManager.play_pop()

	# Re-reproducir sonido para que el niño compare
	get_tree().create_timer(0.3).timeout.connect(func():
		if is_inside_tree() and not is_round_transition:
			_play_target_sound()
	)

func _on_back_pressed() -> void:
	if audio_player and audio_player.playing:
		audio_player.stop()
	if AudioManager:
		AudioManager.set_music_volume_db(AudioManager.DEFAULT_MUSIC_DB, 0.4)
	if not SceneRouter.busy:
		SceneRouter.go("res://scenes/minigames/minigames_menu.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
		get_viewport().set_input_as_handled()
