extends Node2D

## Continuous strip with a bounded residency window. Art order, cover scale,
## slow parallax (0.24), overlap and final-background behavior are preserved.
@export var fondos_dir: String = "res://imagenes/jump/fondos"
@export_range(0.08, 0.60, 0.01) var velocidad_fondo: float = 0.24
@export_range(0.0, 12.0, 0.5) var empalme_px: float = 4.0
@export var ultimo_fondo_infinito: bool = true
@export var tamano_referencia := Vector2(1080.0, 1920.0)

var _camara: Camera2D
var _paths: Array[String] = []
var _tiles: Dictionary = {}
var _max_altura: float = 0.0
var _y_inicio: float = 960.0
var _current_index: int = -1
var _stride: float = 1916.0

func _ready() -> void:
	z_index = -100
	_camara = get_parent().get_node_or_null("Camera2D") as Camera2D
	_collect(fondos_dir)
	_paths.sort()
	_stride = maxf(1.0, tamano_referencia.y - empalme_px)
	reset_strip()

func reset_strip() -> void:
	_y_inicio = _camara.global_position.y if _camara else 960.0
	_max_altura = 0.0
	_current_index = -1
	_update_strip()

func _process(_delta: float) -> void:
	if _camara:
		_max_altura = maxf(_max_altura, _y_inicio - _camara.global_position.y)
	_update_strip()

func _update_strip() -> void:
	if _paths.is_empty():
		return
	if _camara:
		global_position = _camara.global_position
	var travel := _max_altura * velocidad_fondo
	if ultimo_fondo_infinito:
		travel = minf(travel, (_paths.size() - 1) * _stride)
	var index := maxi(0, int(floor(travel / _stride)))
	if index != _current_index:
		_current_index = index
		_refresh_window(index)
	for key in _tiles:
		var sprite: Sprite2D = _tiles[key]
		sprite.position = Vector2(0, -int(key) * _stride + travel)

func _refresh_window(index: int) -> void:
	# Release old textures BEFORE bringing new ones in. At most four live tiles.
	var first := maxi(0, index - 1)
	var last := index + 2
	if ultimo_fondo_infinito:
		last = mini(last, _paths.size() - 1)
	for key in _tiles.keys():
		if int(key) < first or int(key) > last:
			_tiles[key].free()
			_tiles.erase(key)
	for tile_index in range(first, last + 1):
		if _tiles.has(tile_index):
			continue
		var texture := load(_paths[tile_index % _paths.size()]) as Texture2D
		if texture == null:
			continue
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		var factor := maxf(tamano_referencia.x / texture.get_width(), tamano_referencia.y / texture.get_height())
		sprite.scale = Vector2.ONE * factor
		add_child(sprite)
		_tiles[tile_index] = sprite

func _collect(folder: String) -> void:
	# ResourceLoader preserves original names in exported PCK files, unlike raw DirAccess enumeration.
	for entry in ResourceLoader.list_directory(folder):
		var path := folder.path_join(entry)
		if entry.ends_with("/"):
			_collect(path)
		elif entry.get_extension().to_lower() in ["png", "jpg", "jpeg", "webp"]:
			_paths.append(path)
