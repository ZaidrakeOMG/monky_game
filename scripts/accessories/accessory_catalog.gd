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
		"texture_path": "res://assets/wonky/trajes/heroe_nocturno/preview.png",
		"slot_texture": "",
		"outfit_id": "heroe_nocturno",
		"unlocked_default": true
	}
}


static func get_item(item_id: String) -> Dictionary:
	if ITEMS.has(item_id):
		return ITEMS[item_id]
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
	return result

static func get_default_unlocked_ids() -> Array[String]:
	var result: Array[String] = []
	for item_id in ITEMS:
		var item: Dictionary = ITEMS[item_id]
		if item.get("unlocked_default", false):
			result.append(item_id)
	return result
