class_name AccessoryCatalog
extends RefCounted

## Catálogo de accesorios y ropas para Wonky.
## Define metadatos, precios, rutas de texturas y posicionamiento para cada item.

const CATEGORIES: Array[String] = ["hat", "glasses", "clothes"]

const CATEGORY_NAMES: Dictionary = {
	"hat": "Sombreros",
	"glasses": "Lentes",
	"clothes": "Ropa"
}

const CATEGORY_ICONS: Dictionary = {
	"hat": "res://imagenes/accesorios/hat_cap_red.png",
	"glasses": "res://imagenes/accesorios/glasses_sunglasses.png",
	"clothes": "res://imagenes/accesorios/clothes_stripes.png"
}

const ITEMS: Dictionary = {
	# ==================== SOMBREROS / GORRAS ====================
	"none_hat": {
		"id": "none_hat",
		"name": "Sin Sombrero",
		"category": "hat",
		"price_coins": 0,
		"price_diamonds": 0,
		"texture_path": "res://imagenes/accesorios/none.png",
		"slot_texture": "",
		"offset": Vector2(0, 0),
		"scale": Vector2(1, 1),
		"unlocked_default": true
	},
	"hat_nightcap": {
		"id": "hat_nightcap",
		"name": "Gorro Dormilón",
		"category": "hat",
		"price_coins": 0,
		"price_diamonds": 0,
		"texture_path": "res://imagenes/accesorios/hat_nightcap.png",
		"slot_texture": "res://imagenes/accesorios/hat_nightcap.png",
		"offset": Vector2(0, -210),
		"scale": Vector2(1.05, 1.05),
		"unlocked_default": true
	},
	"hat_cap_red": {
		"id": "hat_cap_red",
		"name": "Gorra Sport Roja",
		"category": "hat",
		"price_coins": 100,
		"price_diamonds": 0,
		"texture_path": "res://imagenes/accesorios/hat_cap_red.png",
		"slot_texture": "res://imagenes/accesorios/hat_cap_red.png",
		"offset": Vector2(0, -200),
		"scale": Vector2(1.0, 1.0),
		"unlocked_default": false
	},
	"hat_chef": {
		"id": "hat_chef",
		"name": "Gorro de Chef",
		"category": "hat",
		"price_coins": 150,
		"price_diamonds": 0,
		"texture_path": "res://imagenes/accesorios/hat_chef.png",
		"slot_texture": "res://imagenes/accesorios/hat_chef.png",
		"offset": Vector2(0, -225),
		"scale": Vector2(1.0, 1.0),
		"unlocked_default": false
	},
	"hat_top_hat": {
		"id": "hat_top_hat",
		"name": "Sombrero de Copa",
		"category": "hat",
		"price_coins": 250,
		"price_diamonds": 0,
		"texture_path": "res://imagenes/accesorios/hat_top_hat.png",
		"slot_texture": "res://imagenes/accesorios/hat_top_hat.png",
		"offset": Vector2(0, -220),
		"scale": Vector2(1.0, 1.0),
		"unlocked_default": false
	},
	"hat_crown": {
		"id": "hat_crown",
		"name": "Corona Real",
		"category": "hat",
		"price_coins": 0,
		"price_diamonds": 20,
		"texture_path": "res://imagenes/accesorios/hat_crown.png",
		"slot_texture": "res://imagenes/accesorios/hat_crown.png",
		"offset": Vector2(0, -215),
		"scale": Vector2(1.0, 1.0),
		"unlocked_default": false
	},

	# ==================== GAFAS / LENTES ====================
	"none_glasses": {
		"id": "none_glasses",
		"name": "Sin Lentes",
		"category": "glasses",
		"price_coins": 0,
		"price_diamonds": 0,
		"texture_path": "res://imagenes/accesorios/none.png",
		"slot_texture": "",
		"offset": Vector2(0, 0),
		"scale": Vector2(1, 1),
		"unlocked_default": true
	},
	"glasses_nerd": {
		"id": "glasses_nerd",
		"name": "Gafas Clásicas",
		"category": "glasses",
		"price_coins": 0,
		"price_diamonds": 0,
		"texture_path": "res://imagenes/accesorios/glasses_nerd.png",
		"slot_texture": "res://imagenes/accesorios/glasses_nerd.png",
		"offset": Vector2(-6, -62),
		"scale": Vector2(1.0, 1.0),
		"unlocked_default": true
	},
	"glasses_sunglasses": {
		"id": "glasses_sunglasses",
		"name": "Lentes de Sol",
		"category": "glasses",
		"price_coins": 120,
		"price_diamonds": 0,
		"texture_path": "res://imagenes/accesorios/glasses_sunglasses.png",
		"slot_texture": "res://imagenes/accesorios/glasses_sunglasses.png",
		"offset": Vector2(-6, -62),
		"scale": Vector2(1.0, 1.0),
		"unlocked_default": false
	},
	"glasses_monocle": {
		"id": "glasses_monocle",
		"name": "Monóculo de Oro",
		"category": "glasses",
		"price_coins": 0,
		"price_diamonds": 15,
		"texture_path": "res://imagenes/accesorios/glasses_monocle.png",
		"slot_texture": "res://imagenes/accesorios/glasses_monocle.png",
		"offset": Vector2(-6, -62),
		"scale": Vector2(1.0, 1.0),
		"unlocked_default": false
	},

	# ==================== ROPA / TRAJES COMPLETOS ====================
	# La ropa ya NO se dibuja como PNG superpuesto. Cada traje apunta a un
	# set completo de animaciones de Wonky ya vestido.
	"none_clothes": {
		"id": "none_clothes",
		"name": "Sin Ropa",
		"category": "clothes",
		"price_coins": 0,
		"price_diamonds": 0,
		"texture_path": "res://imagenes/accesorios/none.png",
		"slot_texture": "",
		"outfit_id": "",
		"unlocked_default": true
	},
	"clothes_heroe_nocturno": {
		"id": "clothes_heroe_nocturno",
		"name": "Héroe Nocturno",
		"category": "clothes",
		"price_coins": 0,
		"price_diamonds": 0,
		"texture_path": "res://assets/wonky/trajes/heroe_nocturno/pensando/frame_001.png",
		"slot_texture": "",
		"outfit_id": "heroe_nocturno",
		"unlocked_default": true
	}
}

const AUTO_SUIT_DIR: String = "res://imagenes/ropa/trajes"
const PIECE_SUIT_PREFIX: String = "clothes_suit__"

const PIECE_ALIASES: Dictionary = {
	"cape": ["capa.png", "cape.png"],
	"body": ["cuerpo.png", "body.png"],
	"arms": ["brazos.png", "arms.png"],
	"feet": ["pies.png", "feet.png", "botas.png", "boots.png"],
	"mask": ["mascara.png", "mask.png"],
	"hat": ["sombrero.png", "hat.png", "casco.png", "helmet.png"]
}

static func _safe_id(value: String) -> String:
	var base := value.to_lower()
	var safe := ""
	for ch in base:
		if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9") or ch == "_":
			safe += ch
		elif ch == " " or ch == "-":
			safe += "_"
	return safe

static func _pretty_name(folder_name: String) -> String:
	var text := folder_name.replace("_", " ").replace("-", " ").strip_edges()
	if text.is_empty():
		return "Traje"
	return text.capitalize()

static func _first_existing(base_dir: String, candidates: Array) -> String:
	for filename in candidates:
		var path := base_dir.path_join(str(filename))
		if FileAccess.file_exists(path):
			return path
	return ""

static func _load_suit_metadata(base_dir: String) -> Dictionary:
	var meta_path := base_dir.path_join("traje.json")
	if not FileAccess.file_exists(meta_path):
		meta_path = base_dir.path_join("suit.json")
	if not FileAccess.file_exists(meta_path):
		return {}

	var file := FileAccess.open(meta_path, FileAccess.READ)
	if file == null:
		return {}

	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {}

static func _build_piece_suit(folder_name: String) -> Dictionary:
	var base_dir := AUTO_SUIT_DIR.path_join(folder_name)
	var parts: Dictionary = {}

	for part_name in PIECE_ALIASES:
		var path := _first_existing(base_dir, PIECE_ALIASES[part_name])
		if path != "":
			parts[part_name] = path

	if parts.is_empty():
		return {}

	var metadata := _load_suit_metadata(base_dir)
	var preview := _first_existing(base_dir, ["preview.png", "vista_previa.png", "icon.png", "icono.png"])
	if preview == "":
		for preferred in ["body", "arms", "mask", "cape", "feet", "hat"]:
			if parts.has(preferred):
				preview = str(parts[preferred])
				break

	return {
		"id": PIECE_SUIT_PREFIX + _safe_id(folder_name),
		"name": str(metadata.get("name", metadata.get("nombre", _pretty_name(folder_name)))),
		"category": "clothes",
		"price_coins": int(metadata.get("price_coins", metadata.get("monedas", 0))),
		"price_diamonds": int(metadata.get("price_diamonds", metadata.get("diamantes", 0))),
		"texture_path": preview,
		"slot_texture": "",
		"offset": Vector2.ZERO,
		"scale": Vector2.ONE,
		"unlocked_default": bool(metadata.get("unlocked_default", metadata.get("desbloqueado", true))),
		"piece_suit": true,
		"suit_dir": base_dir,
		"parts": parts
	}

static func _get_piece_suits() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var dir := DirAccess.open(AUTO_SUIT_DIR)
	if dir == null:
		return result

	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if dir.current_is_dir() and not entry.begins_with(".") and not entry.begins_with("_"):
			var item := _build_piece_suit(entry)
			if not item.is_empty():
				result.append(item)
		entry = dir.get_next()
	dir.list_dir_end()

	result.sort_custom(func(a: Dictionary, b: Dictionary): return str(a.get("name", "")) < str(b.get("name", "")))
	return result

static func get_item(item_id: String) -> Dictionary:
	if ITEMS.has(item_id):
		return ITEMS[item_id]
	if item_id.begins_with(PIECE_SUIT_PREFIX):
		for item in _get_piece_suits():
			if str(item.get("id", "")) == item_id:
				return item
	return {}

static func get_outfit_id(item_id: String) -> String:
	var item: Dictionary = get_item(item_id)
	return str(item.get("outfit_id", ""))

static func get_items_by_category(category: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item_id in ITEMS:
		var item: Dictionary = ITEMS[item_id]
		if item.get("category", "") == category:
			result.append(item)
	if category == "clothes":
		result.append_array(_get_piece_suits())
	return result

static func get_default_unlocked_ids() -> Array[String]:
	var result: Array[String] = []
	for item_id in ITEMS:
		var item: Dictionary = ITEMS[item_id]
		if item.get("unlocked_default", false):
			result.append(item_id)
	for item in _get_piece_suits():
		if item.get("unlocked_default", false):
			result.append(str(item.get("id", "")))
	return result
