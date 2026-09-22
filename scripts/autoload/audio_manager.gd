extends Node

## AudioManager (Autoload / Singleton)
## Sistema central de audio para efectos de sonido (SFX) y música.
## Maneja pool de canales concurrentes, música ambiental en bucle con fade-in/out,
## volumen dinámico según el estado de Wonky (noche/día) y enlaces automáticos a eventos.

const SFX_PATHS: Dictionary = {
	"buy": "res://audio/sfx/ui/buy_success.ogg",
	"click": "res://audio/sfx/ui/ui_click.wav",
	"coins": "res://audio/sfx/ui/coins_collect.ogg",
	"drink": "res://audio/sfx/ui/drink_sip.wav",
	"eat": "res://audio/sfx/ui/eat_chew.wav",
	"equip": "res://audio/sfx/ui/equip_item.ogg",
	"fruit_catch": "res://audio/sfx/ui/fruit_catch.ogg",
	"game_over": "res://audio/sfx/ui/game_over.ogg",
	"jump": "res://audio/sfx/ui/jump.ogg",
	"level_up": "res://audio/sfx/ui/level_up.ogg",
	"light_switch": "res://audio/sfx/ui/light_switch.mp3",
	"pet": "res://audio/sfx/ui/pet_happy.wav",
	"pop": "res://audio/sfx/ui/ui_pop.wav",
	"poop_clean": "res://audio/sfx/ui/poop_clean.wav",
	"potion": "res://audio/sfx/ui/potion_drink.wav",
	"reject": "res://audio/sfx/ui/reject_full.wav",
	"shower": "res://audio/sfx/ui/shower_water.ogg",
	"snore": "res://audio/sfx/ui/sleep_snore.wav",
	"soap": "res://audio/sfx/ui/soap_bubbles.wav",
	"sparkle": "res://audio/sfx/ui/sparkle_clean.ogg",
	"toothbrush": "res://audio/sfx/ui/toothbrush_scrub.wav"
}

const MUSIC_PATHS: Dictionary = {
	"main": "res://audio/music/music_main.ogg",
	"main2": "res://audio/music/music_main2.ogg",
	"main3": "res://audio/music/music_main3.ogg"
}

const PLAYLIST: Array[String] = ["main", "main2", "main3"]
var _playlist_idx: int = 0

const POOL_SIZE: int = 8
const DEFAULT_MUSIC_DB: float = -6.0
const SLEEP_MUSIC_DB: float = -14.0

var _sfx_streams: Dictionary = {}
var _music_streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _current_player_idx: int = 0

var _loop_player: AudioStreamPlayer = null
var _eat_player: AudioStreamPlayer = null
var _snore_player: AudioStreamPlayer = null
var _music_player: AudioStreamPlayer = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_init_players()
	_preload_streams()
	_connect_game_signals()
	
	# Iniciar música ambiental suave al arrancar
	call_deferred("_start_default_music")

func _init_players() -> void:
	# Pool para efectos normales
	for i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.name = "SFXPlayer_" + str(i)
		p.bus = "Master"
		add_child(p)
		_players.append(p)
		
	# Reproductor dedicado para sonidos continuos (ej. regadera de agua)
	_loop_player = AudioStreamPlayer.new()
	_loop_player.name = "LoopPlayer"
	_loop_player.bus = "Master"
	add_child(_loop_player)

	# Reproductor dedicado para masticar/comer
	_eat_player = AudioStreamPlayer.new()
	_eat_player.name = "EatPlayer"
	_eat_player.bus = "Master"
	add_child(_eat_player)

	# Reproductor dedicado para ronquidos suaves
	_snore_player = AudioStreamPlayer.new()
	_snore_player.name = "SnorePlayer"
	_snore_player.bus = "Master"
	add_child(_snore_player)

	# Reproductor dedicado para la música de fondo
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	_music_player.bus = "Master"
	_music_player.finished.connect(_on_music_finished)
	add_child(_music_player)

func _preload_streams() -> void:
	for sfx_key in SFX_PATHS:
		var path: String = SFX_PATHS[sfx_key]
		if ResourceLoader.exists(path):
			var stream = load(path)
			if stream:
				_sfx_streams[sfx_key] = stream
				
	for music_key in MUSIC_PATHS:
		var path: String = MUSIC_PATHS[music_key]
		if ResourceLoader.exists(path):
			var stream = load(path)
			if stream:
				# Si hay playlist de múltiples pistas, dejamos loop = false para rotación automática al terminar
				if stream is AudioStreamOggVorbis:
					stream.loop = false
				elif stream is AudioStreamMP3:
					stream.loop = false
				_music_streams[music_key] = stream

func _connect_game_signals() -> void:
	if GameManager:
		if not GameManager.level_up.is_connected(_on_level_up):
			GameManager.level_up.connect(_on_level_up)
		if not GameManager.accessory_unlocked.is_connected(_on_accessory_unlocked):
			GameManager.accessory_unlocked.connect(_on_accessory_unlocked)
		if not GameManager.accessory_equipped.is_connected(_on_accessory_equipped):
			GameManager.accessory_equipped.connect(_on_accessory_equipped)
		if not GameManager.monky_state_changed.is_connected(_on_monky_state_changed):
			GameManager.monky_state_changed.connect(_on_monky_state_changed)

func _start_default_music() -> void:
	if GameManager and GameManager.music_enabled:
		if not PLAYLIST.is_empty():
			_playlist_idx = randi() % PLAYLIST.size()
			play_music(PLAYLIST[_playlist_idx])

# ==================== MÉTODOS DE MÚSICA ====================

func _on_music_finished() -> void:
	if GameManager and GameManager.music_enabled:
		play_next_track()

func play_next_track(fade_sec: float = 1.0) -> void:
	if PLAYLIST.is_empty():
		return
	_playlist_idx = (_playlist_idx + 1) % PLAYLIST.size()
	play_music(PLAYLIST[_playlist_idx], DEFAULT_MUSIC_DB, fade_sec)

func play_music(music_key: String = "main", target_db: float = DEFAULT_MUSIC_DB, fade_sec: float = 1.0) -> void:
	if not is_instance_valid(_music_player):
		return
	if not GameManager or not GameManager.music_enabled:
		return
	if not _music_streams.has(music_key):
		return
		
	var stream: AudioStream = _music_streams[music_key]
	
	if _music_player.playing and _music_player.stream == stream:
		return
		
	var idx := PLAYLIST.find(music_key)
	if idx != -1:
		_playlist_idx = idx
		
	_music_player.stream = stream
	_music_player.volume_db = -40.0
	_music_player.play()
	
	var tween := create_tween()
	tween.tween_property(_music_player, "volume_db", target_db, fade_sec)

func stop_music(fade_sec: float = 0.8) -> void:
	if not is_instance_valid(_music_player) or not _music_player.playing:
		return
	var tween := create_tween()
	tween.tween_property(_music_player, "volume_db", -40.0, fade_sec)
	tween.finished.connect(func():
		if is_instance_valid(_music_player):
			_music_player.stop()
	)

func set_music_volume_db(target_db: float, duration: float = 0.5) -> void:
	if not is_instance_valid(_music_player) or not _music_player.playing:
		return
	var tween := create_tween()
	tween.tween_property(_music_player, "volume_db", target_db, duration)

func set_music_enabled(enabled: bool) -> void:
	if not enabled:
		stop_music(0.3)
	else:
		if is_instance_valid(_music_player):
			if not _music_player.playing and not PLAYLIST.is_empty():
				play_music(PLAYLIST[_playlist_idx], DEFAULT_MUSIC_DB, 0.8)

func set_sfx_enabled(enabled: bool) -> void:
	if not enabled:
		stop_shower()
		stop_eat()
		stop_snore()
		for p in _players:
			if is_instance_valid(p) and p.playing:
				p.stop()

# ==================== MÉTODOS PÚBLICOS SFX ====================

func play_sfx(sfx_key: String, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if not GameManager or not GameManager.sfx_enabled:
		return
		
	if not _sfx_streams.has(sfx_key):
		if ResourceLoader.exists(sfx_key):
			var direct_stream = load(sfx_key)
			if direct_stream:
				_play_on_pool(direct_stream, volume_db, pitch_scale)
		return
		
	var stream: AudioStream = _sfx_streams[sfx_key]
	_play_on_pool(stream, volume_db, pitch_scale)

func _play_on_pool(stream: AudioStream, volume_db: float, pitch_scale: float) -> void:
	var player := _players[_current_player_idx]
	_current_player_idx = (_current_player_idx + 1) % POOL_SIZE
	
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()

# ==================== SHORTCUTS DE EFECTOS ====================

func play_buy() -> void:
	play_sfx("buy", 0.0, randf_range(0.98, 1.02))

func play_pop() -> void:
	play_sfx("pop", 0.0, randf_range(0.95, 1.05))

func play_click() -> void:
	play_sfx("click", 0.0, randf_range(0.95, 1.05))

func play_coins() -> void:
	play_sfx("coins", 0.0, randf_range(0.95, 1.05))

func play_eat() -> void:
	start_eat()

func start_eat() -> void:
	if not GameManager or not GameManager.sfx_enabled:
		return
	if _sfx_streams.has("eat") and _eat_player != null:
		if not _eat_player.playing:
			_eat_player.stream = _sfx_streams["eat"]
			_eat_player.volume_db = 1.0
			_eat_player.pitch_scale = randf_range(0.96, 1.04)
			_eat_player.play()

func stop_eat() -> void:
	if _eat_player != null and _eat_player.playing:
		_eat_player.stop()

func play_equip() -> void:
	play_sfx("equip", 0.0, randf_range(0.98, 1.05))

func play_fruit_catch() -> void:
	play_sfx("fruit_catch", 0.0, randf_range(0.95, 1.05))

func play_game_over() -> void:
	play_sfx("game_over", -8.0, 1.0)

func play_jump() -> void:
	play_sfx("jump", -1.0, randf_range(0.95, 1.05))

func play_level_up() -> void:
	play_sfx("level_up", 0.5, 1.0)

func play_light_switch() -> void:
	play_sfx("light_switch", 0.0, randf_range(0.97, 1.03))

func play_sparkle() -> void:
	play_sfx("sparkle", 1.0, randf_range(0.98, 1.04))

func play_soap() -> void:
	play_sfx("soap", -2.0, randf_range(0.92, 1.08))

func play_toothbrush() -> void:
	play_sfx("toothbrush", -3.0, randf_range(0.95, 1.05))

func start_shower() -> void:
	if not GameManager or not GameManager.sfx_enabled:
		return
	if _sfx_streams.has("shower") and _loop_player != null:
		var stream = _sfx_streams["shower"]
		if stream is AudioStreamOggVorbis:
			stream.loop = true
		elif stream is AudioStreamMP3:
			stream.loop = true
		_loop_player.stream = stream
		_loop_player.volume_db = -1.0
		if not _loop_player.playing:
			_loop_player.play()

func stop_shower() -> void:
	if _loop_player != null and _loop_player.playing:
		_loop_player.stop()

func play_drink() -> void:
	play_sfx("drink", 0.0, randf_range(0.96, 1.04))

func play_pet() -> void:
	play_sfx("pet", -1.0, randf_range(0.95, 1.06))

func play_potion() -> void:
	play_sfx("potion", 0.0, 1.0)

func play_poop_clean() -> void:
	play_sfx("poop_clean", 0.0, randf_range(0.95, 1.05))

func play_reject() -> void:
	play_sfx("reject", 0.0, randf_range(0.97, 1.03))

func start_snore() -> void:
	if not GameManager or not GameManager.sfx_enabled:
		return
	if _sfx_streams.has("snore") and is_instance_valid(_snore_player):
		var stream = _sfx_streams["snore"]
		if stream is AudioStreamWAV:
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		_snore_player.stream = stream
		_snore_player.volume_db = -4.0
		if not _snore_player.playing:
			_snore_player.play()

func stop_snore() -> void:
	if is_instance_valid(_snore_player) and _snore_player.playing:
		_snore_player.stop()

# ==================== CALLBACKS AUTOMÁTICOS ====================

func _on_level_up(_new_lvl: int) -> void:
	play_level_up()

func _on_accessory_unlocked(_item_id: String) -> void:
	play_buy()

func _on_accessory_equipped(_cat: String, _item_id: String) -> void:
	play_equip()

func _on_monky_state_changed(state: String) -> void:
	if state == "sleeping":
		# Muffle/atenuar música suavemente durante el sueño e iniciar ronquidos
		set_music_volume_db(SLEEP_MUSIC_DB, 1.5)
		start_snore()
	elif state == "idle" or state == "happy":
		# Restaurar volumen normal y detener ronquidos
		stop_snore()
		if is_instance_valid(_music_player) and _music_player.volume_db < DEFAULT_MUSIC_DB:
			set_music_volume_db(DEFAULT_MUSIC_DB, 1.0)
