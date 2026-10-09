extends Node

## GameManager (Autoload / Singleton)
## Controla las estadísticas globales, nivel, monedas, inventario de comida y persistencia.

signal stat_changed(stat_name: String, current_value: float, max_value: float)
signal coins_changed(current_coins: int)
signal diamonds_changed(current_diamonds: int)
signal xp_changed(current_xp: float, max_xp: float, level: int)
signal level_up(new_level: int)
signal room_changed(room_name: String)
signal monky_state_changed(new_state: String)
signal show_floating_text(text: String, global_pos: Vector2, color: Color)
signal food_inventory_changed()
signal poop_spawned(pos: Vector2)
signal poop_removed()
signal accessory_equipped(category: String, item_id: String)
signal accessory_unlocked(item_id: String)
signal save_failed(error: int)
signal settings_changed()
signal record_changed(game_id: String, score: int)

const SaveStore = preload("res://scripts/core/safe_save.gd")
const GAME_IDS := ["fruit", "flappy", "jump", "runner"]
const POTIONS := {"energy": [80, 4], "hygiene": [60, 3], "mega": [200, 10]}
const EXCHANGES := {10: 250, 30: 1000, 80: 3500}
var records: Dictionary = {}
var reduced_effects: bool = false
var save_path: String = SAVE_PATH
var _save_template := ConfigFile.new()
var _save_read_only: bool = false
var _transaction_busy: bool = false
var _run_serial: int = 0
var _run_sessions: Dictionary = {}
var _loading_save: bool = false

const SAVE_PATH := "user://monky_save.cfg"
const MAX_STAT := 100.0
const SLEEP_DURATION_SEC := 3600.0 # 1 hora exacta de sueño en tiempo real para 100% de energía

var poop_count: int = 0
var sfx_enabled: bool = true:
	set(val):
		sfx_enabled = val
		var am = get_tree().root.get_node_or_null("AudioManager") if is_inside_tree() else null
		if am and am.has_method("set_sfx_enabled"):
			am.set_sfx_enabled(val)

var music_enabled: bool = true:
	set(val):
		music_enabled = val
		var am = get_tree().root.get_node_or_null("AudioManager") if is_inside_tree() else null
		if am and am.has_method("set_music_enabled"):
			am.set_music_enabled(val)

var vibration_enabled: bool = true
var last_daily_reward_time: int = 0
var last_ad_reward_time: int = 0

var unlocked_accessories: Array = []
var equipped_accessories: Dictionary = {
	"hat": "none_hat",
	"glasses": "none_glasses",
	"clothes": "none_clothes"
}

# Nivel y Experiencia (Curva móvil balanceada)
var level: int = 1:
	set(val):
		level = maxi(1, val)
		xp_changed.emit(xp, get_xp_needed(), level)

var xp: float = 0.0:
	set(val):
		xp = maxf(0.0, val) if is_finite(val) else 0.0
		while xp >= get_xp_needed():
			xp -= get_xp_needed()
			level += 1
			level_up.emit(level)
			add_coins(level * 5)
			add_diamonds(1)
		xp_changed.emit(xp, get_xp_needed(), level)

func get_xp_needed() -> float:
	return 120.0 * pow(float(level), 1.35) + 180.0

# Estadísticas de Monky (0 a 100)
var hunger: float = 100.0:
	set(val):
		var next_value := clampf(val, 0.0, MAX_STAT) if is_finite(val) else hunger
		if is_equal_approx(hunger, next_value):
			return
		hunger = next_value
		stat_changed.emit("hunger", hunger, MAX_STAT)

var protein: float = 100.0:
	set(val):
		var next_value := clampf(val, 0.0, MAX_STAT) if is_finite(val) else protein
		if is_equal_approx(protein, next_value):
			return
		protein = next_value
		stat_changed.emit("protein", protein, MAX_STAT)

var energy: float = 100.0:
	set(val):
		var next_value := clampf(val, 0.0, MAX_STAT) if is_finite(val) else energy
		if is_equal_approx(energy, next_value):
			return
		var was_tired := energy <= 15.0
		energy = next_value
		stat_changed.emit("energy", energy, MAX_STAT)
		if energy <= 0.0 and not is_sleeping:
			monky_state_changed.emit("tired")
		elif was_tired and energy > 15.0 and not is_sleeping and current_room != "dormitorio":
			monky_state_changed.emit("idle")

var fun: float = 100.0:
	set(val):
		var next_value := clampf(val, 0.0, MAX_STAT) if is_finite(val) else fun
		if is_equal_approx(fun, next_value):
			return
		fun = next_value
		stat_changed.emit("fun", fun, MAX_STAT)

var hygiene: float = 100.0:
	set(val):
		var next_value := clampf(val, 0.0, MAX_STAT) if is_finite(val) else hygiene
		if is_equal_approx(hygiene, next_value):
			return
		hygiene = next_value
		stat_changed.emit("hygiene", hygiene, MAX_STAT)

var coins: int = 50:
	set(val):
		if coins == maxi(0, val):
			return
		coins = maxi(0, val)
		coins_changed.emit(coins)

var diamonds: int = 5:
	set(val):
		if diamonds == maxi(0, val):
			return
		diamonds = maxi(0, val)
		diamonds_changed.emit(diamonds)

# Catálogo oficial de comidas con propiedades nutricionales reales (gramos, calorías y nutrientes clave)
const FOOD_CATALOG := [
	{
		"id": "fish",
		"name": "Pescado",
		"icon": "",
		"image": "res://imagenes/opt/alimentos/pescado.png",
		"category": "Proteínas",
		"protein_g": 24.0,
		"calories_kcal": 175,
		"protein": 45.0, # Aporte a la barra
		"hunger": 35.0,
		"energy": 12.0,
		"price": 22,
		"xp": 8.0,
		"nutrients": "Omega 3, Fósforo, Vitamina D, Vitamina B12",
		"desc": "Altísima proteína magra de fácil digestión (24g por porción). Sus ácidos grasos Omega 3 mantienen el corazón sano y el plumaje brillante."
	},
	{
		"id": "egg",
		"name": "Huevo Duro",
		"icon": "",
		"image": "res://imagenes/opt/alimentos/huevo.png",
		"category": "Proteínas",
		"protein_g": 6.5,
		"calories_kcal": 78,
		"protein": 35.0,
		"hunger": 22.0,
		"energy": 10.0,
		"price": 14,
		"xp": 6.0,
		"nutrients": "Albúmina, Colina, Hierro, Luteína",
		"desc": "Proteína con el valor biológico más alto en la naturaleza (100%). Contiene todos los 9 aminoácidos esenciales para construir masa muscular."
	},
	{
		"id": "milk",
		"name": "Leche",
		"icon": "",
		"image": "res://imagenes/opt/alimentos/leche.png",
		"category": "Bebidas",
		"protein_g": 8.2,
		"calories_kcal": 122,
		"protein": 22.0,
		"hunger": 18.0,
		"energy": 10.0,
		"price": 12,
		"xp": 5.0,
		"nutrients": "Caseína, Calcio, Vitamina D, Potasio",
		"desc": "Fuente clásica de caseína y suero lácteo. Aporta calcio biodisponible para fortalecer huesos y pico."
	},
	{
		"id": "burger",
		"name": "Hamburguesa",
		"icon": "",
		"image": "res://imagenes/opt/alimentos/hamburguesa.png",
		"category": "Comidas",
		"protein_g": 18.5,
		"calories_kcal": 380,
		"protein": 28.0,
		"hunger": 45.0,
		"energy": 8.0,
		"price": 30,
		"xp": 8.0,
		"nutrients": "Proteína Bovina, Hierro Hemo, Zinc",
		"desc": "Carne de res con alto aporte proteico y de saciedad, aunque moderadamente alta en grasas y calorías."
	},
	{
		"id": "pizza",
		"name": "Pizza",
		"icon": "",
		"image": "res://imagenes/opt/alimentos/pizza.png",
		"category": "Comidas",
		"protein_g": 11.5,
		"calories_kcal": 285,
		"protein": 18.0,
		"hunger": 40.0,
		"energy": 6.0,
		"price": 26,
		"xp": 7.0,
		"nutrients": "Queso Mozzarella, Carbohidratos Complejos",
		"desc": "Proteína láctea proveniente del queso fundido, combinada con carbohidratos que sacian el apetito rápidamente."
	},
	{
		"id": "banana",
		"name": "Plátano",
		"icon": "",
		"image": "res://imagenes/opt/alimentos/platano.png",
		"category": "Frutas",
		"protein_g": 1.3,
		"calories_kcal": 105,
		"protein": 5.0,
		"hunger": 20.0,
		"energy": 18.0,
		"price": 10,
		"xp": 5.0,
		"nutrients": "Potasio, Vitamina B6, Magnesio",
		"desc": "Baja en proteínas pero altísima en potasio y glucosa natural. Ideal para reponer energía antes de jugar."
	},
	{
		"id": "apple",
		"name": "Manzana",
		"icon": "",
		"image": "res://imagenes/opt/alimentos/manzana.png",
		"category": "Frutas",
		"protein_g": 0.5,
		"calories_kcal": 52,
		"protein": 3.0,
		"hunger": 15.0,
		"energy": 5.0,
		"price": 8,
		"xp": 4.0,
		"nutrients": "Pectina (Fibra), Vitamina C, Quercetina",
		"desc": "Aporte de proteína casi nulo (0.5g), pero excelente en fibra prebiótica para la salud digestiva de Monky."
	},
	{
		"id": "strawberry",
		"name": "Fresa",
		"icon": "",
		"image": "res://imagenes/opt/alimentos/fresa.png",
		"category": "Frutas",
		"protein_g": 0.8,
		"calories_kcal": 33,
		"protein": 3.0,
		"hunger": 12.0,
		"energy": 4.0,
		"price": 8,
		"xp": 3.0,
		"nutrients": "Vitamina C, Ácido Fólico, Manganeso",
		"desc": "Fruta ligera con bajo contenido proteico. Su principal virtud es la concentración de antioxidantes y vitamina C."
	},
	{
		"id": "watermelon",
		"name": "Sandía",
		"icon": "",
		"image": "res://imagenes/opt/alimentos/sandia.png",
		"category": "Frutas",
		"protein_g": 0.6,
		"calories_kcal": 30,
		"protein": 2.0,
		"hunger": 25.0,
		"energy": 6.0,
		"price": 15,
		"xp": 6.0,
		"nutrients": "Licopeno, Citrulina, 92% Agua",
		"desc": "Cero grasas y mínima proteína. Compuesta mayoritariamente por agua pura e hidratación celular."
	},
	{
		"id": "juice",
		"name": "Jugo Natural",
		"icon": "",
		"image": "res://imagenes/opt/alimentos/jugo.png",
		"category": "Bebidas",
		"protein_g": 0.5,
		"calories_kcal": 95,
		"protein": 2.0,
		"hunger": 14.0,
		"energy": 16.0,
		"price": 12,
		"xp": 5.0,
		"nutrients": "Vitamina C, Fructosa Natural",
		"desc": "Zumo exprimido de frutas. Proporciona hidratación y energía inmediata con mínima presencia de proteínas."
	},
	{
		"id": "cookie",
		"name": "Galleta",
		"icon": "",
		"image": "res://imagenes/opt/alimentos/galleta.png",
		"category": "Dulces",
		"protein_g": 1.8,
		"calories_kcal": 160,
		"protein": 3.0,
		"hunger": 16.0,
		"energy": 8.0,
		"price": 10,
		"xp": 4.0,
		"nutrients": "Carbohidratos Simples, Grasas Dulces",
		"desc": "Golosina horneada. Proteína residual de harina de trigo. Proporciona placer pero escaso valor nutricional."
	},
	{
		"id": "cake",
		"name": "Pastel",
		"icon": "",
		"image": "res://imagenes/opt/alimentos/pastel.png",
		"category": "Dulces",
		"protein_g": 3.2,
		"calories_kcal": 260,
		"protein": 4.0,
		"hunger": 35.0,
		"energy": 10.0,
		"price": 32,
		"xp": 9.0,
		"nutrients": "Azúcares, Grasas Lácteas",
		"desc": "Postre festivo. Aporte proteico bajo derivado del huevo/leche de la masa, pero muy alto en azúcares."
	}
]

# Inventario de Comida del Jugador (Nevera)
var food_inventory: Dictionary = {
	"apple": 3,
	"egg": 2,
	"milk": 2,
	"banana": 1,
	"fish": 1
}

# Estado actual
var current_room: String = "dormitorio"
var is_sleeping: bool = false
var decay_timer: Timer
var sleep_update_accumulator: float = 0.0

func _ready() -> void:
	load_game()
	_migrate_legacy_records()
	_setup_decay_timer()
	_setup_checkpoint()


func _process(delta: float) -> void:
	# En Android evitamos emitir cambios de UI 60 veces por segundo.
	# Acumulamos el tiempo y actualizamos el sueño 4 veces por segundo.
	if is_sleeping and energy < MAX_STAT:
		sleep_update_accumulator += delta
		if sleep_update_accumulator >= 0.25:
			var elapsed: float = sleep_update_accumulator
			sleep_update_accumulator = 0.0
			var recovery_rate: float = (MAX_STAT / SLEEP_DURATION_SEC) * elapsed
			energy = minf(MAX_STAT, energy + recovery_rate)
	else:
		sleep_update_accumulator = 0.0

func _setup_decay_timer() -> void:
	decay_timer = Timer.new()
	decay_timer.wait_time = 3.0
	decay_timer.autostart = true
	decay_timer.timeout.connect(_on_decay_tick)
	add_child(decay_timer)

func _setup_checkpoint() -> void:
	var checkpoint := Timer.new()
	checkpoint.wait_time = 30.0
	checkpoint.timeout.connect(save_game)
	checkpoint.autostart = true
	add_child(checkpoint)

func _report_save_error(error: int) -> void:
	save_failed.emit(error)
	push_warning("No se pudo guardar la partida. Error: %d" % error)
	show_floating_text.emit("No se pudo guardar. No se confirmó la compra.", Vector2(540, 850), Color(1, 0.55, 0.4))

func _on_decay_tick() -> void:
	if is_sleeping:
		hunger -= 0.08
		protein -= 0.06
	else:
		hunger -= 0.22
		protein -= 0.18
		energy -= 0.12
		fun -= 0.20
		hygiene -= 0.10

func add_xp(amount: float) -> void:
	xp += amount

func get_food_quantity(food_id: String) -> int:
	return food_inventory.get(food_id, 0)

func get_food_by_id(food_id: String) -> Dictionary:
	for food in FOOD_CATALOG:
		if food.id == food_id:
			return food
	return {}

func buy_food(food_id: String, amount: int = 1) -> bool:
	var item := get_food_by_id(food_id)
	if item.is_empty() or amount <= 0 or amount > 999:
		return false
	var cost: int = int(item.price) * amount
	if cost < 0 or coins < cost:
		show_floating_text.emit("¡Faltan monedas!", Vector2(540, 850), Color(1, 0.4, 0.4))
		return false
	var inventory := food_inventory.duplicate(true)
	inventory[food_id] = get_food_quantity(food_id) + amount
	if not _commit_transaction({"coins": coins - cost, "food_inventory": inventory}):
		return false
	AudioManager.play_buy()
	show_floating_text.emit("¡Compraste " + str(item.name) + "!", Vector2(540, 850), Color(0.3, 1, 0.4))
	return true

func can_eat_food() -> bool:
	return hunger < MAX_STAT or protein < MAX_STAT

func feed_item(food: Dictionary) -> bool:
	food = get_food_by_id(str(food.get("id", "")))
	if food.is_empty():
		return false
	var id: String = food.id
	if get_food_quantity(id) <= 0 or not can_eat_food():
		show_floating_text.emit("Comida agotada o Monky está lleno", Vector2(540, 950), Color(1, 0.8, 0.2))
		return false
	var inventory := food_inventory.duplicate(true)
	inventory[id] = get_food_quantity(id) - 1
	var updates := _progression_updates(float(food.get("xp", 4.0)))
	updates.merge({"food_inventory": inventory, "hunger": minf(MAX_STAT, hunger + float(food.hunger)),
		"protein": minf(MAX_STAT, protein + float(food.protein)), "energy": minf(MAX_STAT, energy + float(food.energy))})
	if not _commit_transaction(updates):
		return false
	monky_state_changed.emit("eating")
	show_floating_text.emit("Comida +%d%% · Proteína +%d%%" % [food.hunger, food.protein], Vector2(540, 950), Color(0.3, 1, 0.4))
	return true

func clean(amount: float = 25.0) -> void:
	if str(current_room).to_lower() != "baño":
		return
	hygiene += amount
	add_xp(1.0)
	monky_state_changed.emit("happy")


func brush_teeth_action(amount: float = 15.0) -> void:
	if str(current_room).to_lower() != "baño":
		return
	# El cepillado da frescura bucal. El guardado se hace al soltar la herramienta.
	hygiene = minf(MAX_STAT, hygiene + amount * 0.3)
	add_xp(0.5)
	monky_state_changed.emit("happy")


func wash_body(amount: float = 50.0) -> void:
	if str(current_room).to_lower() != "baño":
		return
	# El baño completo con jabón y agua deja a Monky 100% limpio
	hygiene = minf(MAX_STAT, hygiene + amount)
	add_xp(4.0)
	monky_state_changed.emit("happy")
	save_game()

func play_with_monky(amount: float = 20.0) -> void:
	fun += amount
	energy -= 3.0 # Cansancio progresivo por interacción activa
	hygiene -= 2.5 # Se ensucia jugando
	hunger -= 1.0
	protein -= 0.8
	add_xp(3.0)
	monky_state_changed.emit("happy")

func toggle_sleep() -> void:
	if AudioManager:
		AudioManager.play_light_switch()
	is_sleeping = !is_sleeping
	if is_sleeping:
		monky_state_changed.emit("sleeping")
		show_floating_text.emit("Durmiendo (1h de recuperación)", Vector2(540, 850), Color(0.6, 0.8, 1.0))
	else:
		monky_state_changed.emit("idle")
		# Al despertar, Monky hace popis y se despierta necesitando baño
		hygiene = maxf(0.0, hygiene - 15.0)
		spawn_poop()
		show_floating_text.emit("¡Monky hizo popis al despertar!", Vector2(540, 850), Color(0.8, 0.55, 0.2))
	save_game()

func spawn_poop(custom_pos = null) -> void:
	if poop_count >= 6:
		return
	poop_count = mini(poop_count + 1, 6)
	var spawn_x = randf_range(260.0, 420.0) if randf() < 0.5 else randf_range(660.0, 820.0)
	var spawn_y = randf_range(1360.0, 1480.0)
	var pos = custom_pos if custom_pos != null else Vector2(spawn_x, spawn_y)
	poop_spawned.emit(pos)
	save_game()

func remove_poop() -> void:
	poop_count = maxi(0, poop_count - 1)
	poop_removed.emit()
	save_game()

func clear_all_poop_after_bath() -> int:
	# La popó ya no se limpia tocándola. Sólo desaparece cuando Wonky recibe
	# un baño/enjuague completo dentro del baño.
	if str(current_room).to_lower() != "baño":
		return 0
	var removed := poop_count
	if removed <= 0:
		return 0
	poop_count = 0
	poop_removed.emit()
	save_game()
	return removed


func add_coins(amount: int) -> void:
	if amount <= 0:
		return
	coins += amount
	show_floating_text.emit("+" + str(amount) + " monedas", Vector2(540, 850), Color(1.0, 0.9, 0.2))

func spend_coins(amount: int) -> bool:
	if amount <= 0 or coins < amount:
		return false
	return _commit_transaction({"coins": coins - amount})

func add_diamonds(amount: int) -> void:
	if amount <= 0:
		return
	diamonds += amount
	show_floating_text.emit("+" + str(amount) + " diamantes", Vector2(540, 850), Color(0.3, 0.8, 1.0))

func spend_diamonds(amount: int) -> bool:
	if amount <= 0 or diamonds < amount:
		return false
	return _commit_transaction({"diamonds": diamonds - amount})

func change_room(room_name: String) -> void:
	if not room_name in ["dormitorio", "cocina", "baño", "sala de juegos"] or current_room == room_name:
		return
	current_room = room_name
	room_changed.emit(room_name)

# Guardar y Cargar Partida con Protección Anti-Cheat
func _build_save_config() -> ConfigFile:
	var config := ConfigFile.new()
	config.parse(_save_template.encode_to_text())
	config.set_value("stats", "hunger", hunger)
	config.set_value("stats", "protein", protein)
	config.set_value("stats", "energy", energy)
	config.set_value("stats", "fun", fun)
	config.set_value("stats", "hygiene", hygiene)
	config.set_value("game", "coins", coins)
	config.set_value("game", "diamonds", diamonds)
	config.set_value("game", "level", level)
	config.set_value("game", "xp", xp)
	config.set_value("game", "current_room", current_room)
	config.set_value("game", "is_sleeping", is_sleeping)
	config.set_value("game", "poop_count", poop_count)
	config.set_value("game", "last_timestamp", Time.get_unix_time_from_system())
	config.set_value("game", "last_daily_reward_time", last_daily_reward_time)
	config.set_value("game", "last_ad_reward_time", last_ad_reward_time)
	config.set_value("inventory", "foods", food_inventory)
	config.set_value("customization", "unlocked_accessories", unlocked_accessories)
	config.set_value("customization", "equipped_accessories", equipped_accessories)
	config.set_value("settings", "sfx", sfx_enabled)
	config.set_value("settings", "music", music_enabled)
	config.set_value("settings", "vibration", vibration_enabled)
	config.set_value("meta", "schema_version", 2)
	config.set_value("records", "best", records)
	config.set_value("settings", "reduced_effects", reduced_effects)
	return config

func save_game() -> bool:
	if _transaction_busy or _loading_save:
		return false
	if _save_read_only:
		return false
	var config := _build_save_config()
	var error := SaveStore.write_config(config, save_path, _validate_save)
	if error != OK:
		_report_save_error(error)
		return false
	_save_template = config
	return true

func load_game() -> void:
	var result := SaveStore.load_config(save_path, _validate_save)
	var config: ConfigFile = result.config
	_save_template = config
	if int(config.get_value("meta", "schema_version", 1)) > 2:
		_save_read_only = true
		push_warning("Esta partida pertenece a una versión más nueva. Se conserva sin sobrescribir.")
		return
	_save_read_only = result.error == ERR_FILE_CORRUPT
	if result.error != OK:
		unlocked_accessories = AccessoryCatalog.get_default_unlocked_ids()
		if _save_read_only:
			push_warning("Partida y respaldo dañados: se preservan los archivos, no se sobrescriben.")
		return
	_loading_save = true
	if result.recovered:
		push_warning("Partida recuperada desde respaldo válido.")
	records = config.get_value("records", "best", {}).duplicate(true)
	reduced_effects = config.get_value("settings", "reduced_effects", false)

	sfx_enabled = config.get_value("settings", "sfx", true)
	music_enabled = config.get_value("settings", "music", true)
	vibration_enabled = config.get_value("settings", "vibration", true)

	hunger = config.get_value("stats", "hunger", 100.0)
	protein = config.get_value("stats", "protein", 100.0)
	energy = config.get_value("stats", "energy", 100.0)
	fun = config.get_value("stats", "fun", 100.0)
	hygiene = config.get_value("stats", "hygiene", 100.0)
	coins = config.get_value("game", "coins", 50)
	diamonds = config.get_value("game", "diamonds", 5)
	level = config.get_value("game", "level", 1)
	xp = minf(float(config.get_value("game", "xp", 0.0)), get_xp_needed() - 0.001)
	current_room = config.get_value("game", "current_room", "dormitorio")
	is_sleeping = config.get_value("game", "is_sleeping", false)
	poop_count = clampi(int(config.get_value("game", "poop_count", 0)), 0, 6)
	last_daily_reward_time = config.get_value("game", "last_daily_reward_time", 0)
	last_ad_reward_time = config.get_value("game", "last_ad_reward_time", 0)
	food_inventory = config.get_value("inventory", "foods", {
		"apple": 3,
		"egg": 2,
		"milk": 2,
		"banana": 1,
		"fish": 1
	})
	
	var default_unlocked: Array = AccessoryCatalog.get_default_unlocked_ids()
	unlocked_accessories = Array(config.get_value("customization", "unlocked_accessories", default_unlocked))
	for def_id in default_unlocked:
		if not def_id in unlocked_accessories:
			unlocked_accessories.append(def_id)
			
	equipped_accessories = config.get_value("customization", "equipped_accessories", {
		"hat": "none_hat",
		"glasses": "none_glasses",
		"clothes": "none_clothes"
	})

	# Migra ropa antigua del sistema superpuesto que ya no existe en el catálogo.
	var equipped_clothes_id: String = str(equipped_accessories.get("clothes", "none_clothes"))
	if AccessoryCatalog.get_item(equipped_clothes_id).is_empty():
		equipped_accessories["clothes"] = "none_clothes"

	var last_time: int = config.get_value("game", "last_timestamp", 0)
	if last_time > 0:
		var current_time: int = int(Time.get_unix_time_from_system())
		var elapsed_seconds: int = current_time - last_time
		if elapsed_seconds < 0:
			# Anti-Cheat: El usuario atrasó el reloj de su dispositivo
			print("[Reloj] Hora anterior al guardado; no se aplica progreso fuera de línea.")
			show_floating_text.emit("El reloj cambió; progreso fuera de línea pausado", Vector2(540, 700), Color(1, 0.3, 0.3))
		elif elapsed_seconds > 0:
			if is_sleeping:
				# Recuperación en 1 hora (3600 segundos)
				var energy_gained: float = (float(elapsed_seconds) / SLEEP_DURATION_SEC) * MAX_STAT
				energy = minf(MAX_STAT, energy + energy_gained)
				var passed_ticks: float = minf(float(elapsed_seconds) / 10.0, 2880.0)
				hunger -= passed_ticks * 0.08
				protein -= passed_ticks * 0.06
				hygiene = maxf(0.0, hygiene - 15.0)
				if poop_count == 0:
					poop_count = 1
			else:
				var passed_ticks: float = minf(float(elapsed_seconds) / 10.0, 2880.0)
				hunger -= passed_ticks * 0.20
				protein -= passed_ticks * 0.16
				energy -= passed_ticks * 0.15
				fun -= passed_ticks * 0.20
				hygiene -= passed_ticks * 0.10

	_loading_save = false
	_migrate_legacy_records()

# Métodos de Accesorios / Ropas
func is_accessory_unlocked(item_id: String) -> bool:
	return item_id in unlocked_accessories

func unlock_accessory(item_id: String) -> bool:
	var item := AccessoryCatalog.get_item(item_id)
	if item.is_empty() or not AccessoryCatalog.is_available(item_id):
		return false
	if is_accessory_unlocked(item_id):
		return true
	var cost_coins := int(item.get("price_coins", 0))
	var cost_diamonds := int(item.get("price_diamonds", 0))
	if not can_afford(cost_coins, cost_diamonds):
		return false
	var owned := unlocked_accessories.duplicate()
	owned.append(item_id)
	if not _commit_transaction({"coins": coins - cost_coins,
		"diamonds": diamonds - cost_diamonds, "unlocked_accessories": owned}):
		return false
	accessory_unlocked.emit(item_id)
	return true

func equip_accessory(category: String, item_id: String) -> bool:
	var item := AccessoryCatalog.get_item(item_id)
	if item.is_empty() or item.get("category", "") != category:
		return false
	if not is_accessory_unlocked(item_id) or not AccessoryCatalog.is_available(item_id):
		return false
	if get_equipped_accessory(category) == item_id:
		return true
	var equipment := equipped_accessories.duplicate(true)
	equipment[category] = item_id
	if not _commit_transaction({"equipped_accessories": equipment}):
		return false
	accessory_equipped.emit(category, item_id)
	return true

func get_equipped_accessory(category: String) -> String:
	return str(equipped_accessories.get(category, "none_" + category))

func reset_game_data() -> bool:
	# Explicit, confirmed reset still obeys write-before-mutate semantics.
	var config := _build_save_config()
	var defaults := {"stats": {"hunger": 100.0, "protein": 100.0, "energy": 100.0, "fun": 100.0, "hygiene": 100.0},
		"game": {"coins": 50, "diamonds": 5, "level": 1, "xp": 0.0, "current_room": "dormitorio",
			"is_sleeping": false, "poop_count": 0, "last_daily_reward_time": 0, "last_ad_reward_time": 0,
			"last_timestamp": Time.get_unix_time_from_system()},
		"inventory": {"foods": {"apple": 3, "egg": 2, "milk": 2, "banana": 1, "fish": 1}},
		"customization": {"unlocked_accessories": AccessoryCatalog.get_default_unlocked_ids(),
			"equipped_accessories": {"hat": "none_hat", "glasses": "none_glasses", "clothes": "none_clothes"}},
		"records": {"best": {}}}
	for section in defaults:
		for key in defaults[section]:
			config.set_value(section, key, defaults[section][key])
	config.set_value("meta", "legacy_records_imported", true)
	var error := SaveStore.write_config(config, save_path, _validate_save)
	if error != OK:
		_report_save_error(error)
		return false
	_run_sessions.clear()
	load_game()
	food_inventory_changed.emit()
	room_changed.emit(current_room)
	poop_removed.emit()
	for category in AccessoryCatalog.CATEGORIES:
		accessory_equipped.emit(category, get_equipped_accessory(category))
	return true

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()

## Updates are written as one candidate before live state/signals are touched.
## Keeps callers from deducting one currency before checking the other.
func can_afford(coin_cost: int, diamond_cost: int) -> bool:
	return coin_cost >= 0 and diamond_cost >= 0 and coins >= coin_cost and diamonds >= diamond_cost

func _commit_transaction(updates: Dictionary) -> bool:
	if _transaction_busy or _save_read_only:
		return false
	var fields := {
		"coins": ["game", "coins"], "diamonds": ["game", "diamonds"],
		"level": ["game", "level"], "xp": ["game", "xp"],
		"food_inventory": ["inventory", "foods"],
		"unlocked_accessories": ["customization", "unlocked_accessories"],
		"equipped_accessories": ["customization", "equipped_accessories"],
		"last_daily_reward_time": ["game", "last_daily_reward_time"],
		"records": ["records", "best"], "reduced_effects": ["settings", "reduced_effects"]}
	for stat in ["hunger", "protein", "energy", "fun", "hygiene"]:
		fields[stat] = ["stats", stat]
	var config := _build_save_config()
	for key in updates:
		if not fields.has(key):
			return false
		config.set_value(fields[key][0], fields[key][1], updates[key])
	if not _validate_save(config):
		return false
	_transaction_busy = true
	var error := SaveStore.write_config(config, save_path, _validate_save)
	if error != OK:
		_transaction_busy = false
		_report_save_error(error)
		return false
	var old_level := level
	var old_energy := energy
	set_block_signals(true)
	for key in updates:
		set(key, updates[key])
	set_block_signals(false)
	_save_template = config
	for key in updates:
		match key:
			"coins": coins_changed.emit(coins)
			"diamonds": diamonds_changed.emit(diamonds)
			"food_inventory": food_inventory_changed.emit()
			"hunger", "protein", "energy", "fun", "hygiene": stat_changed.emit(key, get(key), MAX_STAT)
			"reduced_effects": settings_changed.emit()
	if updates.has("xp") or updates.has("level"):
		xp_changed.emit(xp, get_xp_needed(), level)
	if level > old_level:
		level_up.emit(level)
	if old_energy <= 15.0 and energy > 15.0 and not is_sleeping:
		monky_state_changed.emit("idle")
	_transaction_busy = false
	return true

func buy_potion(kind: String) -> bool:
	if not POTIONS.has(kind):
		return false
	var stats: Array = [kind] if kind != "mega" else ["hunger", "protein", "energy", "fun", "hygiene"]
	var changed := false
	var updates := {}
	for stat in stats:
		changed = changed or float(get(stat)) < MAX_STAT
		updates[stat] = MAX_STAT
	if not changed:
		show_floating_text.emit("Ya está al máximo. No se realizó ningún cobro.", Vector2(540, 850), Color(1, 0.8, 0.3))
		return false
	if coins >= int(POTIONS[kind][0]):
		updates.coins = coins - int(POTIONS[kind][0])
	elif diamonds >= int(POTIONS[kind][1]):
		updates.diamonds = diamonds - int(POTIONS[kind][1])
	else:
		return false
	return _commit_transaction(updates)

func exchange_diamonds(gem_cost: int, coin_gain: int) -> bool:
	if not EXCHANGES.has(gem_cost) or int(EXCHANGES[gem_cost]) != coin_gain or diamonds < gem_cost:
		return false
	return _commit_transaction({"diamonds": diamonds - gem_cost, "coins": coins + coin_gain})

func claim_daily_reward() -> bool:
	var now := int(Time.get_unix_time_from_system())
	if last_daily_reward_time != 0 and now - last_daily_reward_time < 86400:
		return false
	return _commit_transaction({"last_daily_reward_time": now, "coins": coins + 20, "diamonds": diamonds + 1})

func get_record(game_id: String) -> int:
	return maxi(0, int(records.get(game_id, 0)))

func _migrate_legacy_records() -> void:
	if _save_template.get_value("meta", "legacy_records_imported", false):
		return
	_save_template.set_value("meta", "legacy_records_imported", true)
	for entry in [["jump", "user://monky_jump_score.cfg", "score", "best"],
		["runner", "user://wonky_runner.cfg", "runner", "best_score"]]:
		var legacy := ConfigFile.new()
		if legacy.load(entry[1]) == OK:
			var value: Variant = legacy.get_value(entry[2], entry[3], 0)
			if value is int and value >= 0:
				records[entry[0]] = maxi(get_record(entry[0]), value)

func begin_run(game_id: String) -> String:
	if not game_id in GAME_IDS:
		return ""
	_run_serial += 1
	var token := "%s:%d" % [game_id, _run_serial]
	# Only the current run can be settled; stale callbacks cannot collect again.
	_run_sessions.clear()
	_run_sessions[token] = {"game": game_id, "settled": false, "paid_score": 0, "paid_coins": 0, "paid_xp": 0.0, "care_awarded": false}
	return token

func settle_run(token: String, score: int, collected: int) -> bool:
	if not _run_sessions.has(token) or score < 0 or collected < 0:
		return false
	var session: Dictionary = _run_sessions[token]
	if session.settled:
		return true
	var game_id: String = session.game
	var divisor: int = {"fruit": 40, "flappy": 5, "jump": 30, "runner": 300}[game_id]
	var factor: float = {"fruit": 0.1, "flappy": 0.8, "jump": 0.15, "runner": 1.0 / 115.0}[game_id]
	var xp_gain := minf(float(score) * factor, 24.0 if game_id == "runner" else 20.0)
	var new_level := level
	var new_xp := xp + maxf(0.0, xp_gain - float(session.paid_xp)) + (0.0 if session.care_awarded else 3.0)
	var coin_gain := maxi(0, collected - int(session.paid_coins)) + maxi(0, int(float(score) / divisor) - int(float(session.paid_score) / divisor))
	var diamond_gain := 0
	while new_xp >= 120.0 * pow(float(new_level), 1.35) + 180.0:
		new_xp -= 120.0 * pow(float(new_level), 1.35) + 180.0
		new_level += 1
		coin_gain += new_level * 5
		diamond_gain += 1
	var best := records.duplicate(true)
	best[game_id] = maxi(get_record(game_id), score)
	var updates := {"coins": coins + coin_gain, "diamonds": diamonds + diamond_gain,
		"records": best, "level": new_level, "xp": new_xp,
		"fun": minf(MAX_STAT, fun + (0.0 if session.care_awarded else (28.0 if game_id == "runner" else 100.0)))}
	if not session.care_awarded:
		updates.merge({"hygiene": maxf(0.0, hygiene - (2.5 if game_id == "runner" else 10.5)), "energy": maxf(0.0, energy - 3.0),
			"hunger": maxf(0.0, hunger - 1.0), "protein": maxf(0.0, protein - 0.8)})
	if not _commit_transaction(updates):
		return false
	session.settled = true
	session.paid_score = score
	session.paid_coins = collected
	session.paid_xp = xp_gain
	session.care_awarded = true
	record_changed.emit(game_id, get_record(game_id))
	return true

func _validate_save(config: ConfigFile) -> bool:
	var schema: Variant = config.get_value("meta", "schema_version", 1)
	if not schema is int or schema < 1:
		return false
	for section in ["game", "stats", "inventory", "customization", "settings", "records"]:
		if not config.has_section(section):
			continue
		for key in config.get_section_keys(section):
			var value: Variant = config.get_value(section, key)
			if section == "stats" or key in ["xp", "last_timestamp"]:
				if not (value is int or value is float) or not is_finite(float(value)):
					return false
			elif key in ["coins", "diamonds", "level", "poop_count", "last_daily_reward_time", "last_ad_reward_time"]:
				if not value is int or value < 0:
					return false
			elif key in ["sfx", "music", "vibration", "is_sleeping", "reduced_effects"]:
				if not value is bool:
					return false
			elif key in ["foods", "best"]:
				if not value is Dictionary:
					return false
				for id in value:
					if not id is String or not value[id] is int or value[id] < 0:
						return false
			elif key == "equipped_accessories":
				if not value is Dictionary:
					return false
				for id in value:
					if not id is String or not value[id] is String:
						return false
			elif key == "unlocked_accessories":
				if not (value is Array or value is PackedStringArray):
					return false
				for id in value:
					if not id is String:
						return false
			elif key == "current_room" and not value is String:
				return false
	return config.has_section("game")

func resume_run(token: String) -> bool:
	if not _run_sessions.has(token) or not _run_sessions[token].settled:
		return false
	_run_sessions[token].settled = false
	return true

func _progression_updates(amount: float) -> Dictionary:
	var next_level := level
	var next_xp := xp + maxf(0.0, amount)
	var next_coins := coins
	var next_diamonds := diamonds
	while next_xp >= 120.0 * pow(float(next_level), 1.35) + 180.0:
		next_xp -= 120.0 * pow(float(next_level), 1.35) + 180.0
		next_level += 1
		next_coins += next_level * 5
		next_diamonds += 1
	return {"level": next_level, "xp": next_xp, "coins": next_coins, "diamonds": next_diamonds}
