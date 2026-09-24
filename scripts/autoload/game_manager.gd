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
		xp = val
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
		if energy <= 0.0 and not is_sleeping:
			monky_state_changed.emit("tired")
		elif energy > 15.0 and not is_sleeping and current_room != "dormitorio":
			monky_state_changed.emit("idle")

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

var diamonds: int = 5:
	set(val):
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
var time_http_req: HTTPRequest = null
var sleep_update_accumulator: float = 0.0

func _ready() -> void:
	load_game()
	_setup_decay_timer()
	_setup_network_time_check()

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
		if AudioManager:
			AudioManager.play_buy()
		show_floating_text.emit("¡Compraste " + item_data.name + "!", Vector2(540, 850), Color(0.3, 1.0, 0.4))
		return true
	else:
		show_floating_text.emit("¡Faltan monedas!", Vector2(540, 850), Color(1, 0.4, 0.4))
		return false

func can_eat_food() -> bool:
	return hunger < MAX_STAT or protein < MAX_STAT

func feed_item(food: Dictionary) -> bool:
	var f_id = food.get("id", "")
	var current_qty = get_food_quantity(f_id)
	if current_qty <= 0:
		show_floating_text.emit("¡Comida agotada! Compra en el mercado", Vector2(540, 950), Color(1, 0.4, 0.4))
		return false

	if not can_eat_food():
		show_floating_text.emit("¡Monky está lleno!", Vector2(540, 950), Color(1, 0.8, 0.2))
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
	show_floating_text.emit("Comida +" + str(int(h_val)) + "%  Proteína +" + str(int(p_val)) + "%", Vector2(540, 950), Color(0.3, 1.0, 0.4))
	save_game()
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
	coins += amount
	show_floating_text.emit("+" + str(amount) + " monedas", Vector2(540, 850), Color(1.0, 0.9, 0.2))

func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		return true
	return false

func add_diamonds(amount: int) -> void:
	diamonds += amount
	show_floating_text.emit("+" + str(amount) + " diamantes", Vector2(540, 850), Color(0.3, 0.8, 1.0))

func spend_diamonds(amount: int) -> bool:
	if diamonds >= amount:
		diamonds -= amount
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
	config.save(SAVE_PATH)

func load_game() -> void:
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)
	if err != OK:
		unlocked_accessories = AccessoryCatalog.get_default_unlocked_ids()
		return

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
	xp = config.get_value("game", "xp", 0.0)
	current_room = config.get_value("game", "current_room", "dormitorio")
	is_sleeping = config.get_value("game", "is_sleeping", false)
	poop_count = config.get_value("game", "poop_count", 0)
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
	unlocked_accessories = config.get_value("customization", "unlocked_accessories", default_unlocked)
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
			print("[AntiCheat] Timestamp menor al guardado. Bloqueando avance.")
			show_floating_text.emit("¡Hora del celular alterada!", Vector2(540, 700), Color(1, 0.3, 0.3))
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

# Métodos de Accesorios / Ropas
func is_accessory_unlocked(item_id: String) -> bool:
	return item_id in unlocked_accessories

func unlock_accessory(item_id: String) -> bool:
	var item: Dictionary = AccessoryCatalog.get_item(item_id)
	if item.is_empty():
		return false
	if is_accessory_unlocked(item_id):
		return true
	
	var p_coins: int = int(item.get("price_coins", 0))
	var p_diamonds: int = int(item.get("price_diamonds", 0))
	
	if p_coins > 0:
		if coins < p_coins:
			return false
		coins -= p_coins
		coins_changed.emit(coins)
	if p_diamonds > 0:
		if diamonds < p_diamonds:
			return false
		diamonds -= p_diamonds
		diamonds_changed.emit(diamonds)
	
	unlocked_accessories.append(item_id)
	accessory_unlocked.emit(item_id)
	save_game()
	return true

func equip_accessory(category: String, item_id: String) -> void:
	if not is_accessory_unlocked(item_id):
		return
	equipped_accessories[category] = item_id
	accessory_equipped.emit(category, item_id)
	save_game()

func get_equipped_accessory(category: String) -> String:
	return str(equipped_accessories.get(category, "none_" + category))

func reset_game_data() -> void:
	hunger = 100.0
	protein = 100.0
	energy = 100.0
	fun = 100.0
	hygiene = 100.0
	coins = 50
	diamonds = 5
	level = 1
	xp = 0.0
	current_room = "dormitorio"
	is_sleeping = false
	poop_count = 0
	last_daily_reward_time = 0
	last_ad_reward_time = 0
	food_inventory = {
		"apple": 3,
		"egg": 2,
		"milk": 2,
		"banana": 1,
		"fish": 1
	}
	unlocked_accessories = AccessoryCatalog.get_default_unlocked_ids()
	equipped_accessories = {
		"hat": "none_hat",
		"glasses": "none_glasses",
		"clothes": "none_clothes"
	}
	save_game()
	food_inventory_changed.emit()
	room_changed.emit(current_room)
	for cat in ["hat", "glasses", "clothes"]:
		accessory_equipped.emit(cat, equipped_accessories[cat])

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()
