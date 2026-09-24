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
	# Los trajes se detectan automáticamente desde:
	# res://imagenes/ropa/trajes/<nombre_traje>/<animacion>/*.png
	"none_clothes": {
		"id": "none_clothes",
		"name": "Sin Ropa",
		"category": "clothes",
		"price_coins": 0,
		"price_diamonds": 0,
		"texture_path": "res://imagenes/accesorios/none.png",
		"slot_texture": "",
		"outfit_id": "",
		"outfit_dir": "",
		"unlocked_default": true
	}

}


const AUTO_OUTFIT_DIR := "res://imagenes/ropa/trajes"
const OUTFIT_PREFIX := "clothes_outfit__"


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


static func _resource_name(entry: String) -> String:
	if entry.ends_with(".remap"):
		return entry.substr(0, entry.length() - 6)
	return entry


static func _png_files(dir_path: String) -> Array[String]:
	var result: Array[String] = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return result

	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if not dir.current_is_dir():
			var resource_name := _resource_name(entry)
			if resource_name.to_lower().ends_with(".png"):
				var path := dir_path.path_join(resource_name)
				if ResourceLoader.exists(path):
					result.append(path)
		entry = dir.get_next()
	dir.list_dir_end()

	result.sort_custom(func(a: String, b: String): return a.naturalnocasecmp_to(b) < 0)
	return result


static func _first_png(dir_path: String) -> String:
	var files := _png_files(dir_path)
	if files.is_empty():
		return ""
	return files[0]


static func _load_outfit_metadata(base_dir: String) -> Dictionary:
	for filename in ["traje.json", "outfit.json"]:
		var path := base_dir.path_join(filename)
		if FileAccess.file_exists(path):
			var file := FileAccess.open(path, FileAccess.READ)
			if file:
				var parsed = JSON.parse_string(file.get_as_text())
				if parsed is Dictionary:
					return parsed
	return {}


static func _find_preview(base_dir: String) -> String:
	for filename in ["preview.png", "vista_previa.png", "icon.png", "icono.png"]:
		var path := base_dir.path_join(filename)
		if ResourceLoader.exists(path):
			return path

	var thinking := _first_png(base_dir.path_join("pensando"))
	if thinking != "":
		return thinking

	var dir := DirAccess.open(base_dir)
	if dir == null:
		return ""
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if dir.current_is_dir() and not entry.begins_with("."):
			var candidate := _first_png(base_dir.path_join(entry))
			if candidate != "":
				dir.list_dir_end()
				return candidate
		entry = dir.get_next()
	dir.list_dir_end()
	return ""


static func _has_animation_frames(base_dir: String) -> bool:
	var dir := DirAccess.open(base_dir)
	if dir == null:
		return false
	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if dir.current_is_dir() and not entry.begins_with(".") and not entry.begins_with("_"):
			if not _png_files(base_dir.path_join(entry)).is_empty():
				dir.list_dir_end()
				return true
		entry = dir.get_next()
	dir.list_dir_end()
	return false


static func _build_outfit(folder_name: String) -> Dictionary:
	var base_dir := AUTO_OUTFIT_DIR.path_join(folder_name)
	if not _has_animation_frames(base_dir):
		return {}

	var metadata := _load_outfit_metadata(base_dir)
	var item_id := OUTFIT_PREFIX + _safe_id(folder_name)
	var preview := _find_preview(base_dir)
	if preview == "":
		preview = "res://imagenes/accesorios/none.png"

	return {
		"id": item_id,
		"name": str(metadata.get("name", metadata.get("nombre", _pretty_name(folder_name)))),
		"category": "clothes",
		"price_coins": int(metadata.get("price_coins", metadata.get("monedas", 0))),
		"price_diamonds": int(metadata.get("price_diamonds", metadata.get("diamantes", 0))),
		"texture_path": preview,
		"slot_texture": "",
		"outfit_id": folder_name,
		"outfit_dir": base_dir,
		"unlocked_default": bool(metadata.get("unlocked_default", metadata.get("desbloqueado", true)))
	}


static func _get_auto_outfits() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var dir := DirAccess.open(AUTO_OUTFIT_DIR)
	if dir == null:
		return result

	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if dir.current_is_dir() and not entry.begins_with(".") and not entry.begins_with("_"):
			var item := _build_outfit(entry)
			if not item.is_empty():
				result.append(item)
		entry = dir.get_next()
	dir.list_dir_end()

	result.sort_custom(func(a: Dictionary, b: Dictionary): return str(a.get("name", "")).naturalnocasecmp_to(str(b.get("name", ""))) < 0)
	return result


static func get_item(item_id: String) -> Dictionary:
	if ITEMS.has(item_id):
		return ITEMS[item_id]

	# Compatibilidad con la primera versión de Héroe Nocturno.
	if item_id == "clothes_heroe_nocturno":
		var legacy := _build_outfit("traje_nocturno")
		if not legacy.is_empty():
			return legacy

	if item_id.begins_with(OUTFIT_PREFIX):
		for item in _get_auto_outfits():
			if str(item.get("id", "")) == item_id:
				return item
	return {}


static func normalize_item_id(item_id: String) -> String:
	if item_id == "clothes_heroe_nocturno":
		var legacy_id := OUTFIT_PREFIX + _safe_id("traje_nocturno")
		if not get_item(legacy_id).is_empty():
			return legacy_id
	return item_id


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
		result.append_array(_get_auto_outfits())
	return result


static func get_default_unlocked_ids() -> Array[String]:
	var result: Array[String] = []
	for item_id in ITEMS:
		var item: Dictionary = ITEMS[item_id]
		if item.get("unlocked_default", false):
			result.append(item_id)
	for item in _get_auto_outfits():
		if item.get("unlocked_default", false):
			result.append(str(item.get("id", "")))
	return result
