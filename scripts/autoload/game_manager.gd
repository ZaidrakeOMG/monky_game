extends Node

## GameManager (Autoload / Singleton)
## Controla las estadísticas globales, nivel, monedas, inventario de comida y persistencia.

signal stat_changed(stat_name: String, current_value: float, max_value: float)
signal coins_changed(current_coins: int)
signal xp_changed(current_xp: float, max_xp: float, level: int)
signal level_up(new_level: int)
signal room_changed(room_name: String)
signal monky_state_changed(new_state: String)
signal show_floating_text(text: String, global_pos: Vector2, color: Color)
signal food_inventory_changed()

const SAVE_PATH := "user://monky_save.cfg"
const MAX_STAT := 100.0

# Nivel y Experiencia (Curva móvil balanceada)
var level: int = 1:
	set(val):
		level = maxi(1, val)
		xp_changed.emit(xp, get_xp_needed(), level)

var xp: float = 0.0:
	set(val):
		xp = val
		while xp >= get_xp_needed():
			xp -= get_xp_needed()
			level += 1
			level_up.emit(level)
			add_coins(level * 5)
		xp_changed.emit(xp, get_xp_needed(), level)

func get_xp_needed() -> float:
	return 120.0 * pow(float(level), 1.35) + 180.0

# Estadísticas de Monky (0 a 100)
var hunger: float = 100.0:
	set(val):
		hunger = clampf(val, 0.0, MAX_STAT)
		stat_changed.emit("hunger", hunger, MAX_STAT)

var energy: float = 100.0:
	set(val):
		energy = clampf(val, 0.0, MAX_STAT)
		stat_changed.emit("energy", energy, MAX_STAT)

var fun: float = 100.0:
	set(val):
		fun = clampf(val, 0.0, MAX_STAT)
		stat_changed.emit("fun", fun, MAX_STAT)

var hygiene: float = 100.0:
	set(val):
		hygiene = clampf(val, 0.0, MAX_STAT)
		stat_changed.emit("hygiene", hygiene, MAX_STAT)

var coins: int = 50:
	set(val):
		coins = maxi(0, val)
		coins_changed.emit(coins)

# Catálogo oficial de comidas del Mercado
const FOOD_CATALOG := [
	{"id": "apple", "name": "Manzana", "icon": "🍎", "hunger": 15.0, "price": 8, "xp": 4.0, "category": "Frutas"},
	{"id": "banana", "name": "Plátano", "icon": "🍌", "hunger": 18.0, "price": 10, "xp": 5.0, "category": "Frutas"},
	{"id": "strawberry", "name": "Fresa", "icon": "🍓", "hunger": 12.0, "price": 8, "xp": 3.0, "category": "Frutas"},
	{"id": "watermelon", "name": "Sandía", "icon": "🍉", "hunger": 25.0, "price": 15, "xp": 6.0, "category": "Frutas"},
	{"id": "cookie", "name": "Galleta", "icon": "🍪", "hunger": 20.0, "price": 12, "xp": 4.0, "category": "Dulces"},
	{"id": "donut", "name": "Dona", "icon": "🍩", "hunger": 22.0, "price": 14, "xp": 5.0, "category": "Dulces"},
	{"id": "ice_cream", "name": "Helado", "icon": "🍦", "hunger": 30.0, "price": 20, "xp": 6.0, "category": "Dulces"},
	{"id": "cake", "name": "Pastel", "icon": "🍰", "hunger": 45.0, "price": 35, "xp": 9.0, "category": "Dulces"},
	{"id": "milk", "name": "Leche", "icon": "🥛", "hunger": 20.0, "price": 10, "xp": 4.0, "category": "Bebidas"},
	{"id": "juice", "name": "Jugo", "icon": "🧃", "hunger": 22.0, "price": 12, "xp": 5.0, "category": "Bebidas"},
	{"id": "pizza", "name": "Pizza", "icon": "🍕", "hunger": 35.0, "price": 25, "xp": 7.0, "category": "Comidas"},
	{"id": "burger", "name": "Hamburguesa", "icon": "🍔", "hunger": 40.0, "price": 30, "xp": 8.0, "category": "Comidas"}
]

# Inventario de Comida del Jugador (Nevera)
var food_inventory: Dictionary = {
	"apple": 3,
	"cookie": 2,
	"milk": 2,
	"banana": 1,
	"pizza": 1
}

# Estado actual
var current_room: String = "dormitorio"
var is_sleeping: bool = false
var decay_timer: Timer

func _ready() -> void:
	load_game()
	_setup_decay_timer()

func _setup_decay_timer() -> void:
	decay_timer = Timer.new()
	decay_timer.wait_time = 3.0
	decay_timer.autostart = true
	decay_timer.timeout.connect(_on_decay_tick)
	add_child(decay_timer)

func _on_decay_tick() -> void:
	if is_sleeping:
		energy += 2.0
		hunger -= 0.1
	else:
		hunger -= 0.25
		energy -= 0.15
		fun -= 0.2
		hygiene -= 0.12

func add_xp(amount: float) -> void:
	xp += amount

func get_food_quantity(food_id: String) -> int:
	return food_inventory.get(food_id, 0)

func buy_food(food_id: String, amount: int = 1) -> bool:
	var item_data: Dictionary = {}
	for item in FOOD_CATALOG:
		if item.id == food_id:
			item_data = item
			break
	if item_data.is_empty():
		return false

	var total_cost = item_data.price * amount
	if spend_coins(total_cost):
		food_inventory[food_id] = food_inventory.get(food_id, 0) + amount
		food_inventory_changed.emit()
		save_game()
		show_floating_text.emit("¡Compraste " + item_data.name + "! " + item_data.icon, Vector2(540, 850), Color(0.3, 1.0, 0.4))
		return true
	else:
		show_floating_text.emit("¡Faltan monedas! 🪙", Vector2(540, 850), Color(1, 0.4, 0.4))
		return false

func feed_item(food: Dictionary) -> bool:
	var f_id = food.get("id", "")
	var current_qty = get_food_quantity(f_id)
	if current_qty <= 0:
		show_floating_text.emit("¡Comida agotada! Compra en el mercado 🛒", Vector2(540, 950), Color(1, 0.4, 0.4))
		return false

	food_inventory[f_id] = current_qty - 1
	food_inventory_changed.emit()

	hunger += food.get("hunger", 18.0)
	add_xp(food.get("xp", 4.0))
	monky_state_changed.emit("eating")
	show_floating_text.emit("+" + str(int(food.get("hunger", 18.0))) + " 🍎", Vector2(540, 950), Color(0.3, 1.0, 0.4))
	save_game()
	return true

func clean(amount: float = 25.0) -> void:
	hygiene += amount
	add_xp(4.0)
	monky_state_changed.emit("happy")
	show_floating_text.emit("+" + str(int(amount)) + " 🧼", Vector2(540, 950), Color(0.3, 0.8, 1.0))

func play_with_monky(amount: float = 20.0) -> void:
	fun += amount
	energy -= 1.5
	hunger -= 1.0
	add_xp(3.0)
	monky_state_changed.emit("happy")

func toggle_sleep() -> void:
	is_sleeping = !is_sleeping
	if is_sleeping:
		monky_state_changed.emit("sleeping")
	else:
		monky_state_changed.emit("idle")

func add_coins(amount: int) -> void:
	coins += amount
	show_floating_text.emit("+" + str(amount) + " 🪙", Vector2(540, 850), Color(1.0, 0.9, 0.2))

func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		return true
	return false

func change_room(room_name: String) -> void:
	current_room = room_name
	room_changed.emit(room_name)

# Guardar y Cargar Partida
func save_game() -> void:
	var config := ConfigFile.new()
	config.set_value("stats", "hunger", hunger)
	config.set_value("stats", "energy", energy)
	config.set_value("stats", "fun", fun)
	config.set_value("stats", "hygiene", hygiene)
	config.set_value("game", "coins", coins)
	config.set_value("game", "level", level)
	config.set_value("game", "xp", xp)
	config.set_value("game", "current_room", current_room)
	config.set_value("game", "last_timestamp", Time.get_unix_time_from_system())
	config.set_value("inventory", "foods", food_inventory)
	config.save(SAVE_PATH)

func load_game() -> void:
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)
	if err != OK:
		return

	hunger = config.get_value("stats", "hunger", 100.0)
	energy = config.get_value("stats", "energy", 100.0)
	fun = config.get_value("stats", "fun", 100.0)
	hygiene = config.get_value("stats", "hygiene", 100.0)
	coins = config.get_value("game", "coins", 50)
	level = config.get_value("game", "level", 1)
	xp = config.get_value("game", "xp", 0.0)
	current_room = config.get_value("game", "current_room", "dormitorio")
	food_inventory = config.get_value("inventory", "foods", {
		"apple": 3,
		"cookie": 2,
		"milk": 2,
		"banana": 1,
		"pizza": 1
	})

	var last_time: int = config.get_value("game", "last_timestamp", 0)
	if last_time > 0:
		var current_time: int = Time.get_unix_time_from_system()
		var elapsed_seconds: int = current_time - last_time
		if elapsed_seconds > 0:
			var passed_ticks: float = minf(float(elapsed_seconds) / 10.0, 2880.0)
			hunger -= passed_ticks * 0.2
			energy -= passed_ticks * 0.15
			fun -= passed_ticks * 0.2
			hygiene -= passed_ticks * 0.1

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()
