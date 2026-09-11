extends Node

## GameManager (Autoload / Singleton)
## Controla las estadísticas globales de Monky, el paso del tiempo, las monedas y el guardado.

signal stat_changed(stat_name: String, current_value: float, max_value: float)
signal coins_changed(current_coins: int)
signal room_changed(room_name: String)
signal monky_state_changed(new_state: String)

const SAVE_PATH := "user://monky_save.cfg"
const MAX_STAT := 100.0

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
		# Si duerme, recupera energía y no pierde tanta diversión
		energy += 2.0
		hunger -= 0.1
	else:
		# Pérdida pasiva natural con el tiempo
		hunger -= 0.3
		energy -= 0.2
		fun -= 0.25
		hygiene -= 0.15

# Métodos de interacción
func feed(amount: float = 20.0) -> void:
	hunger += amount
	monky_state_changed.emit("eating")

func clean(amount: float = 25.0) -> void:
	hygiene += amount
	monky_state_changed.emit("happy")

func play_with_monky(amount: float = 20.0) -> void:
	fun += amount
	energy -= 3.0
	hunger -= 2.0
	monky_state_changed.emit("happy")

func toggle_sleep() -> void:
	is_sleeping = !is_sleeping
	if is_sleeping:
		monky_state_changed.emit("sleeping")
	else:
		monky_state_changed.emit("idle")

func add_coins(amount: int) -> void:
	coins += amount

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
	config.set_value("game", "current_room", current_room)
	config.set_value("game", "last_timestamp", Time.get_unix_time_from_system())
	config.save(SAVE_PATH)

func load_game() -> void:
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)
	if err != OK:
		# Primera vez: valores por defecto
		return

	hunger = config.get_value("stats", "hunger", 100.0)
	energy = config.get_value("stats", "energy", 100.0)
	fun = config.get_value("stats", "fun", 100.0)
	hygiene = config.get_value("stats", "hygiene", 100.0)
	coins = config.get_value("game", "coins", 50)
	current_room = config.get_value("game", "current_room", "dormitorio")

	# Simulación de tiempo transcurrido fuera del juego
	var last_time: int = config.get_value("game", "last_timestamp", 0)
	if last_time > 0:
		var current_time: int = Time.get_unix_time_from_system()
		var elapsed_seconds: int = current_time - last_time
		if elapsed_seconds > 0:
			# Decaimiento por tiempo desconectado (máximo 8 horas de impacto)
			var passed_ticks = min(elapsed_seconds / 10, 2880)
			hunger -= passed_ticks * 0.2
			energy -= passed_ticks * 0.15
			fun -= passed_ticks * 0.2
			hygiene -= passed_ticks * 0.1

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()

