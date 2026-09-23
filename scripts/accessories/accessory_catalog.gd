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

	# ==================== ROPA / TRAJES ====================
	"none_clothes": {
		"id": "none_clothes",
		"name": "Sin Ropa",
		"category": "clothes",
		"price_coins": 0,
		"price_diamonds": 0,
		"texture_path": "res://imagenes/accesorios/none.png",
		"slot_texture": "",
		"offset": Vector2(0, 0),
		"scale": Vector2(1, 1),
		"unlocked_default": true
	},
	"clothes_pajamas": {
		"id": "clothes_pajamas",
		"name": "Pijama Estrellado",
		"category": "clothes",
		"price_coins": 0,
		"price_diamonds": 0,
		"texture_path": "res://imagenes/accesorios/clothes_pajamas.png",
		"slot_texture": "res://imagenes/accesorios/clothes_pajamas.png",
		"offset": Vector2(0, 100),
		"scale": Vector2(1.0, 1.0),
		"unlocked_default": true
	},
	"clothes_stripes": {
		"id": "clothes_stripes",
		"name": "Camiseta a Rayas",
		"category": "clothes",
		"price_coins": 150,
		"price_diamonds": 0,
		"texture_path": "res://imagenes/accesorios/clothes_stripes.png",
		"slot_texture": "res://imagenes/accesorios/clothes_stripes.png",
		"offset": Vector2(0, 100),
		"scale": Vector2(1.0, 1.0),
		"unlocked_default": false
	},
	"clothes_tuxedo": {
		"id": "clothes_tuxedo",
		"name": "Esmoquin Elegante",
		"category": "clothes",
		"price_coins": 300,
		"price_diamonds": 0,
		"texture_path": "res://imagenes/accesorios/clothes_tuxedo.png",
		"slot_texture": "res://imagenes/accesorios/clothes_tuxedo.png",
		"offset": Vector2(0, 100),
		"scale": Vector2(1.0, 1.0),
		"unlocked_default": false
	},
	"clothes_tshirt_red": {
		"id": "clothes_tshirt_red",
		"name": "Camiseta Estrella",
		"category": "clothes",
		"price_coins": 100,
		"price_diamonds": 0,
		"texture_path": "res://imagenes/accesorios/clothes_tshirt_red.png",
		"slot_texture": "res://imagenes/accesorios/clothes_tshirt_red.png",
		"offset": Vector2(0, 100),
		"scale": Vector2(1.0, 1.0),
		"unlocked_default": true
	},
	"clothes_hoodie": {
		"id": "clothes_hoodie",
		"name": "Sudadera Turquesa",
		"category": "clothes",
		"price_coins": 200,
		"price_diamonds": 0,
		"texture_path": "res://imagenes/accesorios/clothes_hoodie.png",
		"slot_texture": "res://imagenes/accesorios/clothes_hoodie.png",
		"offset": Vector2(0, 100),
		"scale": Vector2(1.0, 1.0),
		"unlocked_default": false
	},
	"clothes_superhero": {
		"id": "clothes_superhero",
		"name": "Capa Heroica",
		"category": "clothes",
		"price_coins": 0,
		"price_diamonds": 25,
		"texture_path": "res://imagenes/accesorios/clothes_superhero.png",
		"slot_texture": "res://imagenes/accesorios/clothes_superhero.png",
		"offset": Vector2(0, 100),
		"scale": Vector2(1.0, 1.0),
		"unlocked_default": false
	}
}

const AUTO_SUIT_DIR: String = "res://imagenes/ropa/trajes"
const AUTO_SUIT_PREFIX: String = "clothes_auto__"

static func _auto_suit_id_from_filename(filename: String) -> String:
	var base := filename.get_basename().to_lower()
	var safe := ""
	for ch in base:
		if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9") or ch == "_":
			safe += ch
		elif ch == " " or ch == "-":
			safe += "_"
	return AUTO_SUIT_PREFIX + safe

static func _auto_suit_name(filename: String) -> String:
	var base := filename.get_basename().replace("_", " ").replace("-", " ").strip_edges()
	if base.is_empty():
		return "Traje"
	return base.capitalize()

static func _get_auto_suits() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var dir := DirAccess.open(AUTO_SUIT_DIR)
	if dir == null:
		return result
	dir.list_dir_begin()
	var filename := dir.get_next()
	while filename != "":
		if not dir.current_is_dir():
			var lower := filename.to_lower()
			if lower.ends_with(".png"):
				var path := AUTO_SUIT_DIR.path_join(filename)
				result.append({
					"id": _auto_suit_id_from_filename(filename),
					"name": _auto_suit_name(filename),
					"category": "clothes",
					"price_coins": 0,
					"price_diamonds": 0,
					"texture_path": path,
					"slot_texture": path,
					"offset": Vector2.ZERO,
					"scale": Vector2.ONE,
					"unlocked_default": true,
					"auto_suit": true
				})
		filename = dir.get_next()
	dir.list_dir_end()
	result.sort_custom(func(a: Dictionary, b: Dictionary): return str(a.get("name", "")) < str(b.get("name", "")))
	return result

static func get_item(item_id: String) -> Dictionary:
	if ITEMS.has(item_id):
		return ITEMS[item_id]
	if item_id.begins_with(AUTO_SUIT_PREFIX):
		for item in _get_auto_suits():
			if str(item.get("id", "")) == item_id:
				return item
	return {}

static func get_items_by_category(category: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item_id in ITEMS:
		var item: Dictionary = ITEMS[item_id]
		if item.get("category", "") == category:
			result.append(item)
	if category == "clothes":
		result.append_array(_get_auto_suits())
	return result

static func get_default_unlocked_ids() -> Array[String]:
	var result: Array[String] = []
	for item_id in ITEMS:
		var item: Dictionary = ITEMS[item_id]
		if item.get("unlocked_default", false):
			result.append(item_id)
	for item in _get_auto_suits():
		if item.get("unlocked_default", false):
			result.append(str(item.get("id", "")))
	return result
