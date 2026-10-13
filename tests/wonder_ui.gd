extends SceneTree
## Run only through tools/run_checks.py with its disposable user directory.
var failures: int = 0

func _initialize() -> void:
	if OS.get_environment("MONKY_TEST_MODE") != "1" or not "monky-ci-" in ProjectSettings.globalize_path("user://"):
		push_error("Run python tools/run_checks.py; an isolated save directory is required.")
		quit(2)
		return
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		print("ASSERTION FAILED: ", message)
	else:
		print("PASS: ", message)

func mount_scene(path: String) -> Node:
	var packed := load(path) as PackedScene
	if packed == null:
		check(false, "scene loads: " + path)
		return null
	var scene := packed.instantiate()
	root.add_child(scene)
	current_scene = scene
	return scene

func release_scene(scene: Node) -> void:
	current_scene = null
	scene.queue_free()

func _run() -> void:
	var gm := root.get_node("GameManager")
	gm.sfx_enabled = false
	gm.music_enabled = false
	gm.reduced_effects = true
	var initial_coins: int = gm.coins
	var menu := mount_scene("res://scenes/minigames/minigames_menu.tscn")
	await process_frame
	await process_frame
	check(menu != null and menu.has_method("_build"), "arcade script compiles and instantiates")
	if menu != null:
		var games := menu.find_child("Games", true, false)
		check(games != null and games.get_child_count() == 4, "four game cards remain reachable")
		if games != null:
			for card in games.get_children():
				check(card is Button and card.size.x > 0 and card.size.y >= 300, "large card: " + str(card.name))
				check(card.global_position.x >= 0 and card.global_position.x + card.size.x <= 1081, "card fits portrait width")
				check(card.pressed.get_connections().size() == 1 and card.focus_mode != Control.FOCUS_NONE, "card has a single action and keyboard focus")
		release_scene(menu)
	await process_frame
	var flappy := mount_scene("res://scenes/minigames/flappy_monky.tscn")
	await process_frame
	if flappy != null:
		flappy._spawn_pipe_obstacle()
		var art_nodes := flappy.get_node("PipesContainer").find_children("GreenPipeArt", "NinePatchRect", true, false)
		check(art_nodes.size() == 2, "both pipe halves use the supplied art")
		check(flappy.get_node("PipesContainer").find_children("RimCollision", "CollisionShape2D", true, false).size() == 2, "rim hitboxes follow both openings")
		flappy._on_jump()
		flappy._show_pause()
		var before: Vector2 = flappy.player.position
		await create_timer(0.12).timeout
		check(flappy.player.position == before and flappy.spawn_timer.paused, "Flappy pause freezes real physics frames and spawning")
		flappy._pause_sheet.primary_button.pressed.emit()
		check(not flappy.spawn_timer.paused and not flappy._paused, "Flappy resume button works without restarting")
		release_scene(flappy)
	await process_frame
	var fruit := mount_scene("res://scenes/minigames/fruit_catcher.tscn")
	await process_frame
	if fruit != null:
		check(fruit._waiting and fruit.spawn_timer.is_stopped(), "fruit waits for explicit start")
		fruit._start_sheet.primary_button.pressed.emit()
		fruit._spawn_falling_item()
		check(not fruit._waiting and fruit._active_items.size() == 1, "start button begins fruit gameplay")
		var apple: Area2D = fruit._active_items[0]
		apple.set_meta("data", fruit.FRUIT_TYPES[0])
		fruit._on_basket_area_entered(apple)
		check(fruit.score == 10 and not apple.get_meta("active"), "a real fruit collision awards points once")
		fruit._on_basket_area_entered(apple)
		check(fruit.score == 10, "a consumed fruit cannot award duplicate points")
		fruit._spawn_falling_item()
		fruit._show_pause()
		var falling: Vector2 = fruit._active_items[0].position
		await create_timer(0.12).timeout
		check(fruit._active_items[0].position == falling and fruit.spawn_timer.paused, "fruit pause freezes real physics frames")
		fruit._on_basket_area_entered(fruit._active_items[0])
		check(fruit.score == 10 and fruit.lives == 3, "paused collisions cannot change points or lives")
		fruit._pause_sheet.primary_button.pressed.emit()
		fruit.start_game()
		check(fruit._waiting and fruit._active_items.is_empty() and fruit.score == 0, "fruit restart resets pool, score and onboarding")
		release_scene(fruit)
	await process_frame
	check(gm.coins == initial_coins, "visual initialization and a 10-point fruit run grant no extra coins")
	root.get_node("AudioManager").stop_all()
	print("WONKY_VISUAL: %d failures" % failures)
	quit(0 if failures == 0 else 1)
