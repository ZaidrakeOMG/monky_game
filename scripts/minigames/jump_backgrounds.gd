extends Node2D

## Fondos continuos para Wonky Jump.
## Coloca las imágenes consecutivas en: res://imagenes/jump/fondos/
## Nómbralas 01_..., 02_..., 03_... para controlar el orden.
##
## IMPORTANTE:
## Ya NO cambia una textura por otra. Todas se apilan verticalmente y
## se desplazan como una sola tira para que parezca que Wonky realmente sube.

@export var fondos_dir: String = "res://imagenes/jump/fondos"

## Cuánto se mueve el escenario respecto a la subida real del jugador/cámara.
## Menor = cada imagen dura MÁS. 0.24 hace que un fondo de 1920 px necesite
## aproximadamente 8000 px de subida del juego para recorrer una pantalla.
@export_range(0.08, 0.60, 0.01) var velocidad_fondo: float = 0.24

## Pequeño empalme entre imágenes para evitar líneas transparentes/negro.
@export_range(0.0, 12.0, 0.5) var empalme_px: float = 4.0

## Cuando llega al último fondo, se queda ahí en lugar de volver al primero.
@export var ultimo_fondo_infinito: bool = true

## Tamaño de referencia del minijuego vertical. Si la ventana cambia,
## también intentamos usar el tamaño real del viewport.
@export var tamano_referencia: Vector2 = Vector2(1080.0, 1920.0)

var _camara: Camera2D
var _player: Node2D
var _sprites: Array[Sprite2D] = []
var _y_inicio: float = 0.0
var _max_altura: float = 0.0
var _alto_segmento: float = 1920.0
var _tamano_pantalla: Vector2 = Vector2(1080.0, 1920.0)
var _inicializado := false

func _ready() -> void:
	z_index = -100
	_camara = get_parent().get_node_or_null("Camera2D") as Camera2D
	_player = get_parent().get_node_or_null("Player") as Node2D
	_tamano_pantalla = _obtener_tamano_pantalla()
	_alto_segmento = _tamano_pantalla.y

	if _camara:
		_y_inicio = _camara.global_position.y
	elif _player:
		_y_inicio = _player.global_position.y
	else:
		_y_inicio = global_position.y

	_cargar_y_crear_tira()
	_actualizar_posicion_tira()
	_inicializado = true

func _process(_delta: float) -> void:
	if not _inicializado:
		return

	# El contenedor acompaña a la cámara. El movimiento visual de los fondos
	# ocurre dentro del contenedor, a una velocidad menor para alargar cada zona.
	if _camara:
		global_position = _camara.global_position

	var y_actual := _obtener_y_referencia()
	var altura := maxf(0.0, _y_inicio - y_actual)
	_max_altura = maxf(_max_altura, altura)
	_actualizar_posicion_tira()

func _actualizar_posicion_tira() -> void:
	if _sprites.is_empty():
		return

	var desplazamiento := _max_altura * velocidad_fondo

	# Cuando el jugador llega al último escenario, lo dejamos centrado y
	# permanece ahí para cualquier altura posterior.
	if ultimo_fondo_infinito and _sprites.size() > 1:
		var max_desplazamiento := float(_sprites.size() - 1) * _alto_segmento
		desplazamiento = minf(desplazamiento, max_desplazamiento)

	for i in range(_sprites.size()):
		# i=0 empieza centrado. Los siguientes están exactamente encima.
		# Al subir, toda la tira baja de forma continua; nunca hay un salto/corte.
		_sprites[i].position = Vector2(
			0.0,
			-float(i) * (_alto_segmento - empalme_px) + desplazamiento
		)

func _obtener_y_referencia() -> float:
	if _camara:
		return _camara.global_position.y
	if _player:
		return _player.global_position.y
	return global_position.y

func _cargar_y_crear_tira() -> void:
	_limpiar_sprites()

	var rutas: Array[String] = []
	_recolectar_imagenes(fondos_dir, rutas)
	rutas.sort()

	if rutas.is_empty():
		push_warning("[JumpBackgrounds] No se encontraron fondos en: " + fondos_dir)
		return

	for ruta in rutas:
		var recurso := load(ruta)
		if not (recurso is Texture2D):
			continue

		var sprite := Sprite2D.new()
		sprite.texture = recurso as Texture2D
		sprite.centered = true
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		sprite.z_index = -100
		_ajustar_sprite_a_pantalla(sprite)
		add_child(sprite)
		_sprites.append(sprite)

	print("[JumpBackgrounds] Tira continua creada con ", _sprites.size(), " fondos.")
	print("[JumpBackgrounds] velocidad_fondo=", velocidad_fondo,
		" | subida aprox. por imagen=", int(_alto_segmento / maxf(0.01, velocidad_fondo)), " px")

func _ajustar_sprite_a_pantalla(sprite: Sprite2D) -> void:
	if sprite.texture == null:
		return

	var tex_size := sprite.texture.get_size()
	if tex_size.x <= 0.0 or tex_size.y <= 0.0:
		return

	# 'Cover' sin deformar: llena la pantalla conservando proporción.
	var factor := maxf(_tamano_pantalla.x / tex_size.x, _tamano_pantalla.y / tex_size.y)
	sprite.scale = Vector2.ONE * factor

	# Todos los centros quedan separados por exactamente una altura de pantalla.
	# Si las imágenes son 9:16 (como las que generamos), encajan naturalmente.

func _recolectar_imagenes(carpeta: String, salida: Array[String]) -> void:
	var dir := DirAccess.open(carpeta)
	if dir == null:
		push_warning("[JumpBackgrounds] No existe la carpeta: " + carpeta)
		return

	dir.list_dir_begin()
	var nombre := dir.get_next()
	while nombre != "":
		if nombre != "." and nombre != "..":
			var ruta := carpeta.path_join(nombre)
			if dir.current_is_dir():
				_recolectar_imagenes(ruta, salida)
			else:
				var ext := nombre.get_extension().to_lower()
				if ext in ["png", "jpg", "jpeg", "webp"]:
					salida.append(ruta)
		nombre = dir.get_next()
	dir.list_dir_end()

func _limpiar_sprites() -> void:
	for sprite in _sprites:
		if is_instance_valid(sprite):
			sprite.queue_free()
	_sprites.clear()

func _obtener_tamano_pantalla() -> Vector2:
	var visible := get_viewport_rect().size
	if visible.x > 100.0 and visible.y > 100.0:
		return visible
	return tamano_referencia
