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

const SAVE_PATH := "user://monky_save.cfg"
const MAX_STAT := 100.0

# Nivel y Experiencia
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
			add_coins(level * 10)
		xp_changed.emit(xp, get_xp_needed(), level)

func get_xp_needed() -> float:
	return float(level * 50 + 50)

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

# Catálogo de comidas
const FOOD_CATALOG := [
	{"id": "apple", "name": "Manzana", "icon": "🍎", "hunger": 15.0, "price": 0, "xp": 10.0},
	{"id": "cookie", "name": "Galleta", "icon": "🍪", "hunger": 20.0, "price": 5, "xp": 15.0},
	{"id": "milk", "name": "Leche", "icon": "🥛", "hunger": 25.0, "price": 8, "xp": 20.0},
	{"id": "pizza", "name": "Pizza", "icon": "🍕", "hunger": 40.0, "price": 15, "xp": 30.0},
	{"id": "cake", "name": "Pastel", "icon": "🍰", "hunger": 50.0, "price": 25, "xp": 45.0},
	{"id": "ice_cream", "name": "Helado", "icon": "🍦", "hunger": 35.0, "price": 12, "xp": 25.0}
]

# Estado actual
var current_room: String = "dormitorio"
var is_sleeping: bool = false
var decay_timer: Timer

func _ready() -> void:
	load_game()
	_setup_decay_timer()

func _setup_decay_timer() -> void:
	decay_timer = Timer.new()
	decay_timer.wait_time = 3.0 # Cada 3 segundos se actualizan necesidades
	decay_timer.autostart = true
	decay_timer.timeout.connect(_on_decay_tick)
	add_child(decay_timer)

func _on_decay_tick() -> void:
	if is_sleeping:
		# Si duerme, recupera energía
		energy += 2.5
		hunger -= 0.1
	else:
		# Pérdida pasiva natural con el tiempo
		hunger -= 0.25
		energy -= 0.15
		fun -= 0.2
		hygiene -= 0.12

func add_xp(amount: float) -> void:
	xp += amount

# Métodos de interacción
func feed_item(food: Dictionary) -> bool:
	if food.price > 0 and coins < food.price:
		show_floating_text.emit("¡Faltan monedas!", Vector2(540, 1000), Color(1, 0.3, 0.3))
		return false

	if food.price > 0:
		spend_coins(food.price)

	hunger += food.hunger
	add_xp(food.xp)
	monky_state_changed.emit("eating")
	show_floating_text.emit("+" + str(int(food.hunger)) + " 🍎", Vector2(540, 950), Color(0.3, 1.0, 0.4))
	return true

func clean(amount: float = 25.0) -> void:
	hygiene += amount
	add_xp(15.0)
	monky_state_changed.emit("happy")
	show_floating_text.emit("+" + str(int(amount)) + " 🧼", Vector2(540, 950), Color(0.3, 0.8, 1.0))

func play_with_monky(amount: float = 20.0) -> void:
	fun += amount
	energy -= 2.0
	hunger -= 1.5
	add_xp(10.0)
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

