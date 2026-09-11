extends CanvasLayer
class_name HUD

## Controlador de la Interfaz de Usuario (HUD)
## Conecta barras de necesidades, monedas y botones de navegación de habitaciones.

@onready var hunger_bar: ProgressBar = $TopBar/VBox/StatsContainer/HungerContainer/HungerBar
@onready var energy_bar: ProgressBar = $TopBar/VBox/StatsContainer/EnergyContainer/EnergyBar
@onready var fun_bar: ProgressBar = $TopBar/VBox/StatsContainer/FunContainer/FunBar
@onready var hygiene_bar: ProgressBar = $TopBar/VBox/StatsContainer/HygieneContainer/HygieneBar
@onready var coins_label: Label = $TopBar/VBox/CoinsContainer/CoinsLabel

@onready var room_title_label: Label = $BottomBar/VBox/NavContainer/RoomTitleLabel
@onready var btn_left: Button = $BottomBar/VBox/NavContainer/BtnLeft
@onready var btn_right: Button = $BottomBar/VBox/NavContainer/BtnRight
@onready var action_button: Button = $BottomBar/VBox/ActionButton

const ROOMS: Array[String] = ["Dormitorio", "Cocina", "Baño", "Sala de Juegos"]
var current_room_index: int = 0

func _ready() -> void:
	# Conexión con GameManager
	if GameManager:
		GameManager.stat_changed.connect(_on_stat_changed)
		GameManager.coins_changed.connect(_on_coins_changed)
		GameManager.room_changed.connect(_on_room_changed)
		
		# Inicializar valores en pantalla
		_update_stat_ui("hunger", GameManager.hunger, GameManager.MAX_STAT)
		_update_stat_ui("energy", GameManager.energy, GameManager.MAX_STAT)
		_update_stat_ui("fun", GameManager.fun, GameManager.MAX_STAT)
		_update_stat_ui("hygiene", GameManager.hygiene, GameManager.MAX_STAT)
		_on_coins_changed(GameManager.coins)

	btn_left.pressed.connect(_on_btn_left_pressed)
	btn_right.pressed.connect(_on_btn_right_pressed)
	action_button.pressed.connect(_on_action_button_pressed)

	_update_room_display()

func _on_stat_changed(stat_name: String, current_value: float, max_value: float) -> void:
	_update_stat_ui(stat_name, current_value, max_value)

func _update_stat_ui(stat_name: String, value: float, max_val: float) -> void:
	var target_bar: ProgressBar = null
	match stat_name:
		"hunger":
			target_bar = hunger_bar
		"energy":
			target_bar = energy_bar
		"fun":
			target_bar = fun_bar
		"hygiene":
			target_bar = hygiene_bar

	if target_bar:
		target_bar.max_value = max_val
		var tween = create_tween()
		tween.tween_property(target_bar, "value", value, 0.25)

func _on_coins_changed(new_coins: int) -> void:
	coins_label.text = str(new_coins)

func _on_btn_left_pressed() -> void:
	current_room_index = (current_room_index - 1 + ROOMS.size()) % ROOMS.size()
	_update_room_display()

func _on_btn_right_pressed() -> void:
	current_room_index = (current_room_index + 1) % ROOMS.size()
	_update_room_display()

func _update_room_display() -> void:
	var room_name = ROOMS[current_room_index]
	room_title_label.text = room_name.to_upper()

	# Cambiar texto del botón de acción según el cuarto
	match current_room_index:
		0: # Dormitorio
			action_button.text = "💡 Luz / Dormir"
		1: # Cocina
			action_button.text = "🍎 Alimentar"
		2: # Baño
			action_button.text = "🧼 Bañar"
		3: # Sala de Juegos
			action_button.text = "⚽ Jugar"

	if GameManager:
		GameManager.change_room(room_name.to_lower())

func _on_action_button_pressed() -> void:
	if not GameManager:
		return

	match current_room_index:
		0: # Dormitorio
			GameManager.toggle_sleep()
		1: # Cocina
			GameManager.feed(20.0)
		2: # Baño
			GameManager.clean(25.0)
		3: # Sala de Juegos
			GameManager.play_with_monky(20.0)
			GameManager.add_coins(5)

func _on_room_changed(room_name: String) -> void:
	for i in range(ROOMS.size()):
		if ROOMS[i].to_lower() == room_name.to_lower():
			current_room_index = i
			room_title_label.text = ROOMS[i].to_upper()
			break

