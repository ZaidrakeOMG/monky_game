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
const SLEEP_DURATION_SEC := 3600.0 # 1 hora exacta de sueño en tiempo real para 100% de energía

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

var protein: float = 100.0:
	set(val):
		protein = clampf(val, 0.0, MAX_STAT)
		stat_changed.emit("protein", protein, MAX_STAT)

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

# Catálogo oficial de comidas con propiedades nutricionales reales (gramos, calorías y nutrientes clave)
const FOOD_CATALOG := [
	{
		"id": "fish",
		"name": "Pescado",
		"icon": "🐟",
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
		"icon": "🥚",
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
		"icon": "🥛",
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
		"icon": "🍔",
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
		"icon": "🍕",
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
		"icon": "🍌",
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
		"icon": "🍎",
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
		"icon": "🍓",
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
		"icon": "🍉",
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
		"icon": "🧃",
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
		"icon": "🍪",
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
		"icon": "🍰",
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
var time_http_req: HTTPRequest = null

func _ready() -> void:
	load_game()
	_setup_decay_timer()
	_setup_network_time_check()

func _process(delta: float) -> void:
	# Recuperación precisa en tiempo real durante el sueño (1h = 3600 seg para 100%)
	if is_sleeping and energy < MAX_STAT:
		var recovery_rate: float = (MAX_STAT / SLEEP_DURATION_SEC) * delta
		energy = minf(MAX_STAT, energy + recovery_rate)

func _setup_decay_timer() -> void:
	decay_timer = Timer.new()
	decay_timer.wait_time = 3.0
	decay_timer.autostart = true
	decay_timer.timeout.connect(_on_decay_tick)
	add_child(decay_timer)

func _setup_network_time_check() -> void:
	time_http_req = HTTPRequest.new()
	add_child(time_http_req)
	time_http_req.request_completed.connect(_on_network_time_received)
	time_http_req.request("https://www.google.com", PackedStringArray(), HTTPClient.METHOD_HEAD)

func _on_network_time_received(_result: int, _response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	pass

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
	var item_data: Dictionary = get_food_by_id(food_id)
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

func can_eat_food() -> bool:
	return hunger < MAX_STAT or protein < MAX_STAT

func feed_item(food: Dictionary) -> bool:
	var f_id = food.get("id", "")
	var current_qty = get_food_quantity(f_id)
	if current_qty <= 0:
		show_floating_text.emit("¡Comida agotada! Compra en el mercado 🛒", Vector2(540, 950), Color(1, 0.4, 0.4))
		return false

	if not can_eat_food():
		show_floating_text.emit("¡Monky está lleno! 😋", Vector2(540, 950), Color(1, 0.8, 0.2))
		return false

	food_inventory[f_id] = current_qty - 1
	food_inventory_changed.emit()

	var h_val = food.get("hunger", 18.0)
	var p_val = food.get("protein", 10.0)
	var e_val = food.get("energy", 0.0)

	hunger += h_val
	protein += p_val
	if e_val > 0.0:
		energy += e_val
	add_xp(food.get("xp", 4.0))
	monky_state_changed.emit("eating")
	show_floating_text.emit("+" + str(int(h_val)) + "🍖  +" + str(int(p_val)) + "🥩", Vector2(540, 950), Color(0.3, 1.0, 0.4))
	save_game()
	return true

func clean(amount: float = 25.0) -> void:
	hygiene += amount
	add_xp(4.0)
	monky_state_changed.emit("happy")
	show_floating_text.emit("+" + str(int(amount)) + " 🧼", Vector2(540, 950), Color(0.3, 0.8, 1.0))

func play_with_monky(amount: float = 20.0) -> void:
	fun += amount
	energy -= 3.0 # Cansancio progresivo por interacción activa
	hunger -= 1.0
	protein -= 0.8
	add_xp(3.0)
	monky_state_changed.emit("happy")

func toggle_sleep() -> void:
	is_sleeping = !is_sleeping
	if is_sleeping:
		monky_state_changed.emit("sleeping")
		show_floating_text.emit("💤 Durmiendo (1h recuperación)", Vector2(540, 850), Color(0.6, 0.8, 1.0))
	else:
		monky_state_changed.emit("idle")
	save_game()

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

# Guardar y Cargar Partida con Protección Anti-Cheat
func save_game() -> void:
	var config := ConfigFile.new()
	config.set_value("stats", "hunger", hunger)
	config.set_value("stats", "protein", protein)
	config.set_value("stats", "energy", energy)
	config.set_value("stats", "fun", fun)
	config.set_value("stats", "hygiene", hygiene)
	config.set_value("game", "coins", coins)
	config.set_value("game", "level", level)
	config.set_value("game", "xp", xp)
	config.set_value("game", "current_room", current_room)
	config.set_value("game", "is_sleeping", is_sleeping)
	config.set_value("game", "last_timestamp", Time.get_unix_time_from_system())
	config.set_value("inventory", "foods", food_inventory)
	config.save(SAVE_PATH)

func load_game() -> void:
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)
	if err != OK:
		return

	hunger = config.get_value("stats", "hunger", 100.0)
	protein = config.get_value("stats", "protein", 100.0)
	energy = config.get_value("stats", "energy", 100.0)
	fun = config.get_value("stats", "fun", 100.0)
	hygiene = config.get_value("stats", "hygiene", 100.0)
	coins = config.get_value("game", "coins", 50)
	level = config.get_value("game", "level", 1)
	xp = config.get_value("game", "xp", 0.0)
	current_room = config.get_value("game", "current_room", "dormitorio")
	is_sleeping = config.get_value("game", "is_sleeping", false)
	food_inventory = config.get_value("inventory", "foods", {
		"apple": 3,
		"egg": 2,
		"milk": 2,
		"banana": 1,
		"fish": 1
	})

	var last_time: int = config.get_value("game", "last_timestamp", 0)
	if last_time > 0:
		var current_time: int = Time.get_unix_time_from_system()
		var elapsed_seconds: int = current_time - last_time
		if elapsed_seconds < 0:
			# Anti-Cheat: El usuario atrasó el reloj de su dispositivo
			print("[AntiCheat] Timestamp menor al guardado. Bloqueando avance.")
			show_floating_text.emit("⚠️ ¡Hora del celular alterada!", Vector2(540, 700), Color(1, 0.3, 0.3))
		elif elapsed_seconds > 0:
			if is_sleeping:
				# Recuperación en 1 hora (3600 segundos)
				var energy_gained: float = (float(elapsed_seconds) / SLEEP_DURATION_SEC) * MAX_STAT
				energy = minf(MAX_STAT, energy + energy_gained)
				var passed_ticks: float = minf(float(elapsed_seconds) / 10.0, 2880.0)
				hunger -= passed_ticks * 0.08
				protein -= passed_ticks * 0.06
			else:
				var passed_ticks: float = minf(float(elapsed_seconds) / 10.0, 2880.0)
				hunger -= passed_ticks * 0.20
				protein -= passed_ticks * 0.16
				energy -= passed_ticks * 0.15
				fun -= passed_ticks * 0.20
				hygiene -= passed_ticks * 0.10

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()
