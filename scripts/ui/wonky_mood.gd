extends Button
class_name WonkyMood

## Una sola burbuja de emociones: pinturas existentes, sin emojis de fuente
## ni recompensas ficticias. Solo cambia cuando cambian necesidades reales.
signal action_requested(mood: String)

const ART := {
	"happy": "res://imagenes/ui_polished/reacciones/feliz.png",
	"food": "res://imagenes/ui_polished/reacciones/triste.png",
	"rest": "res://imagenes/ui_polished/reacciones/cansado.png",
	"bath": "res://imagenes/ui_polished/reacciones/sucio.png",
	"play": "res://imagenes/ui_polished/reacciones/corazon.png",
	"sleeping": "res://imagenes/ui_polished/reacciones/cansado.png"
}
const CAPTIONS := {
	"happy": "¡HOLA!", "food": "¡COMIDA!", "rest": "¡SUEÑO!",
	"bath": "¡BAÑO!", "play": "¡JUGAR!", "sleeping": "¡DESPIERTA!"
}
const HINTS := {
	"happy": "Tócame para darme cariño",
	"food": "Ir a la cocina", "rest": "Ir al dormitorio",
	"bath": "Ir al baño", "play": "Ir a los juegos",
	"sleeping": "Despertar a Wonky"
}

var gm: Node = null
var current_mood: String = ""
var _icon: TextureRect
var _caption: Label
var _art_cache: Dictionary = {}

## Prioriza la necesidad MÁS urgente y evita cambios por pequeñas oscilaciones.
static func choose_mood(stats: Dictionary, sleeping: bool) -> String:
	if sleeping:
		return "sleeping"
	var needs := {
		"food": minf(float(stats.get("hunger", 100.0)), float(stats.get("protein", 100.0))),
		"rest": float(stats.get("energy", 100.0)),
		"bath": float(stats.get("hygiene", 100.0)),
		"play": float(stats.get("fun", 100.0))
	}
	if bool(stats.get("poop", false)):
		needs["bath"] = minf(float(needs["bath"]), 35.0)
	var selected := "happy"
	var lowest := 48.0
	for need in ["food", "rest", "bath", "play"]:
		if float(needs[need]) < lowest:
			selected = need
			lowest = float(needs[need])
	return selected

func _ready() -> void:
	flat = false
	clip_contents = false
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#FFF2C7")
	normal.border_color = Color("#B97C42")
	normal.set_border_width_all(4)
	normal.set_corner_radius_all(34)
	normal.shadow_color = Color(0.16, 0.08, 0.02, 0.32)
	normal.shadow_size = 10
	add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("#FFF8E8")
	add_theme_stylebox_override("hover", hover)
	var down := normal.duplicate() as StyleBoxFlat
	down.bg_color = Color("#F8DA9B")
	add_theme_stylebox_override("pressed", down)

	_icon = TextureRect.new()
	_icon.name = "EmotionArt"
	_icon.position = Vector2(12, 12)
	_icon.size = Vector2(130, 128)
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_icon)
	_caption = Label.new()
	_caption.name = "MoodCaption"
	_caption.position = Vector2(145, 32)
	_caption.size = Vector2(140, 96)
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_caption.add_theme_font_size_override("font_size", 29)
	_caption.add_theme_color_override("font_color", Color("#673F2C"))
	_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_caption)
	pressed.connect(func(): action_requested.emit(current_mood))

func setup(manager: Node) -> void:
	gm = manager
	gm.stat_changed.connect(func(_name: String, _value: float, _max: float): refresh())
	gm.monky_state_changed.connect(func(_state: String): refresh())
	gm.poop_spawned.connect(func(_pos: Vector2): refresh())
	gm.poop_removed.connect(refresh)
	refresh()

func refresh() -> void:
	if gm == null:
		return
	var mood := choose_mood({
		"hunger": gm.hunger, "protein": gm.protein, "energy": gm.energy,
		"hygiene": gm.hygiene, "fun": gm.fun, "poop": gm.poop_count > 0
	}, gm.is_sleeping)
	if mood == current_mood:
		return
	var old_mood := current_mood
	current_mood = mood
	_caption.text = CAPTIONS[mood]
	tooltip_text = HINTS[mood]
	if not _art_cache.has(mood):
		_art_cache[mood] = load(ART[mood]) as Texture2D
	_icon.texture = _art_cache[mood]
	if old_mood != "" and not gm.reduced_effects:
		pivot_offset = size * 0.5
		# Tween local: la clase de emoción no importa UIEffects durante el
		# arranque de SceneTree, antes de registrar AudioManager.
		if has_meta("_mood_pop_tween"):
			var previous: Tween = get_meta("_mood_pop_tween")
			if previous != null and previous.is_valid():
				previous.kill()
		var pop := create_tween()
		set_meta("_mood_pop_tween", pop)
		pop.tween_property(self, "scale", Vector2.ONE * 1.05, 0.12).set_trans(Tween.TRANS_BACK)
		pop.tween_property(self, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_QUAD)
