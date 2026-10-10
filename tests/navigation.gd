extends SceneTree

var failures: int = 0
var transitions: int = 0
var completed: bool = false
var router: Node

func _initialize() -> void:
	if OS.get_environment("MONKY_TEST_MODE") != "1" or not "monky-ci-" in ProjectSettings.globalize_path("user://"):
		push_error("Use python tools/run_checks.py; tests require an isolated monky-ci- save directory.")
		quit(2)
		return
	_run.call_deferred()

func require(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		print("ASSERTION FAILED: ", label)
	else:
		print("PASS: ", label)

func wait_for_scene(path: String) -> bool:
	var deadline := Time.get_ticks_msec() + 10000
	while Time.get_ticks_msec() < deadline:
		if current_scene != null and current_scene.scene_file_path == path and not router.busy:
			transitions += 1
			return true
		await process_frame
	return false

func _run() -> void:
	router = root.get_node("SceneRouter")
	var gm := root.get_node("GameManager")
	gm.sfx_enabled = false
	gm.music_enabled = false
	DirAccess.remove_absolute("user://save.cfg") # isolated test user directory only
	var boot := load(ProjectSettings.get_setting("application/run/main_scene")) as PackedScene
	var initial := boot.instantiate()
	root.add_child(initial)
	current_scene = initial
	require(await wait_for_scene("res://scenes/Intro/intro.tscn"), "real boot loader reaches intro")
	if current_scene != null and current_scene.has_method("_on_video_finished"):
		current_scene._on_video_finished()
	require(await wait_for_scene("res://scenes/main.tscn"), "intro skip reaches main via threaded router")
	var hud := current_scene.get_node("HUD")
	require(hud.mood_widget != null, "Wonky mood reacts on main screen")
	hud._on_mood_action("food")
	require(gm.current_room == "cocina", "food reaction navigates to real kitchen")
	hud._on_mood_action("play")
	require(gm.current_room == "sala de juegos", "play reaction navigates to real game room")
	hud.btn_game.pressed.emit()
	require(router.busy, "games button starts the guarded asynchronous loader")
	require(await wait_for_scene("res://scenes/minigames/minigames_menu.tscn"), "actual games button reaches menu")
	for name in ["fruit_catcher", "flappy_monky", "monky_jump", "wonky_runner", "minigames_menu"]:
		var path := "res://scenes/minigames/%s.tscn" % name
		require(router.go(path), "navigation accepted: " + name)
		require(not router.go("res://scenes/main.tscn"), "concurrent navigation rejected")
		require(await wait_for_scene(path), "navigation finished: " + name)
	require(router.go("res://scenes/main.tscn"), "return home accepted")
	require(await wait_for_scene("res://scenes/main.tscn"), "return home finished")
	require(router._progress == 100.0 and not router.busy, "real load completes at 100 percent and unlocks input")
	if current_scene != null:
		current_scene.queue_free()
		current_scene = null
	root.get_node("AudioManager").stop_all()
	await create_timer(0.15).timeout
	print("MONKY_NAVIGATION: %d transitions, %d failures" % [transitions, failures])
	quit(0 if failures == 0 else 1)
