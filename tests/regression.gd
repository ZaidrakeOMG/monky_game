extends SceneTree

var checks: int = 0
var failures: int = 0
var _scene_checks_finished: bool = false
var gm: Node
var test_dir := "user://monky-regression"

func _initialize() -> void:
	if OS.get_environment("MONKY_TEST_MODE") != "1" or not "monky-ci-" in ProjectSettings.globalize_path("user://"):
		push_error("Use python tools/run_checks.py; tests require an isolated monky-ci- save directory.")
		quit(2)
		return
	_run.call_deferred()

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		print("ASSERTION FAILED: ", description)
	else:
		print("PASS: ", description)

func _run() -> void:
	gm = root.get_node("GameManager")
	gm.set_process(false)
	gm.decay_timer.stop()
	root.get_node("AudioManager").set_music_enabled(false)
	DirAccess.make_dir_recursive_absolute(test_dir)
	gm.save_path = test_dir + "/wallet.cfg"
	gm._save_read_only = false
	gm.coins = 500
	gm.diamonds = 25
	gm.food_inventory = {"apple": 3}
	gm.records = {}
	gm.level = 1
	gm.xp = 0.0
	# Emociones calculadas sin gráficos, independientes de la tasa de cuadros.
	check(WonkyMood.choose_mood({}, false) == "happy", "healthy Wonky is happy")
	check(WonkyMood.choose_mood({"hunger": 25.0, "fun": 70.0}, false) == "food", "hunger routes to kitchen")
	check(WonkyMood.choose_mood({"energy": 20.0, "hunger": 30.0}, false) == "rest", "most urgent need wins")
	check(WonkyMood.choose_mood({"poop": true}, false) == "bath", "cleaning hint reuses dirty reaction art")
	check(WonkyMood.choose_mood({"hunger": 0.0}, true) == "sleeping", "sleep mode supersedes urgent needs")
	check(gm.save_game(), "save candidate is written and validated")
	check(gm.buy_food("apple", 2), "valid food purchase")
	check(gm.coins == 484 and gm.get_food_quantity("apple") == 5, "food and wallet committed together")
	check(not gm.buy_food("apple", -2), "negative purchase rejected")
	check(not gm.buy_food("apple", 0), "zero purchase rejected")
	check(not gm.buy_food("missing", 1), "unknown food rejected")
	check(not gm.buy_food("apple", 1000), "unbounded quantity rejected")
	check(not gm.spend_coins(-10) and not gm.spend_diamonds(-2), "negative spending cannot mint currency")
	check(gm.coins == 484 and gm.diamonds == 25, "invalid requests do not change wallet")
	check(not gm.can_afford(100, 26), "both currencies validated before payment")
	check(not gm.can_afford(-1, 0), "negative catalog price rejected")
	var stored: String = gm.save_path
	gm.save_path = test_dir + "/missing-parent/wallet.cfg"
	var before: int = gm.coins
	var quantity: int = gm.get_food_quantity("apple")
	check(not gm.buy_food("apple", 1), "disk write failure rejects purchase")
	check(gm.coins == before and gm.get_food_quantity("apple") == quantity, "failed write leaves live state unchanged")
	gm.save_path = stored
	gm.unlocked_accessories = AccessoryCatalog.get_default_unlocked_ids()
	check(gm.unlock_accessory("hat_cap_red"), "accessory purchase succeeds")
	before = gm.coins
	check(gm.unlock_accessory("hat_cap_red") and gm.coins == before, "owned accessory is not charged twice")
	check(not gm.equip_accessory("glasses", "hat_cap_red"), "wrong equipment category rejected")
	check(not gm.unlock_accessory("clothes_heroe_nocturno"), "damaged outfit cannot be activated")
	check(gm.is_accessory_unlocked("clothes_heroe_nocturno"), "damaged outfit ownership is preserved")
	gm.energy = 100.0
	check(not gm.buy_potion("energy") and gm.coins == before, "full-stat potion does not charge")
	check(not gm.buy_potion("invalid") and gm.coins == before, "invalid potion does not charge")
	gm.energy = 10.0
	check(gm.buy_potion("energy") and gm.energy == 100.0, "potion grants its effect with payment")
	check(not gm.exchange_diamonds(1, 99999), "unknown exchange rejected")
	check(gm.exchange_diamonds(10, 250), "catalog exchange committed")
	gm.last_daily_reward_time = 0
	check(gm.claim_daily_reward(), "daily reward saved")
	before = gm.coins
	check(not gm.claim_daily_reward() and gm.coins == before, "daily reward cannot be collected twice")
	for game in ["fruit", "flappy", "jump", "runner"]:
		var token: String = gm.begin_run(game)
		check(gm.settle_run(token, 120, 4), game + " reward persisted")
		before = gm.coins
		check(gm.settle_run(token, 120, 4) and gm.coins == before, game + " duplicate settlement is idempotent")
		check(gm.get_record(game) == 120, game + " persistent record")
		var lower: String = gm.begin_run(game)
		check(gm.settle_run(lower, 20, 0) and gm.get_record(game) == 120, game + " record never decreases")
	var runner: String = gm.begin_run("runner")
	check(gm.settle_run(runner, 600, 3), "Runner first game over checkpoint")
	before = gm.coins
	check(gm.resume_run(runner), "one scene-authorized continuation")
	check(gm.settle_run(runner, 900, 5) and gm.coins == before + 3, "Runner revival pays only incremental coins and bonus")
	check(gm.save_game(), "save with records")
	var saved_coins: int = gm.coins
	gm.coins = 0
	gm.records = {}
	gm.load_game()
	check(gm.coins == saved_coins and gm.get_record("runner") == 900, "save round trip restores wallet and records")
	check(FileAccess.file_exists(stored + ".bak"), "last good backup exists")
	var corrupt_path := test_dir + "/corrupt-probe.cfg"
	gm._build_save_config().save(corrupt_path + ".bak")
	var damaged := FileAccess.open(corrupt_path, FileAccess.WRITE)
	damaged.store_string("[broken")
	damaged.close()
	print("EXPECTED_CORRUPTION_BEGIN")
	var recovery: Dictionary = SafeSave.load_config(corrupt_path, gm._validate_save)
	print("EXPECTED_CORRUPTION_END")
	check(recovery.error == OK and recovery.recovered, "truncated primary recovers from validated backup")
	var invalid := ConfigFile.new()
	invalid.set_value("game", "coins", "bad-type")
	check(not gm._validate_save(invalid), "wrong save types rejected before assigning properties")
	invalid.set_value("game", "coins", 3)
	invalid.set_value("stats", "energy", NAN)
	check(not gm._validate_save(invalid), "nonfinite save stats rejected")
	_test_persistence_edges()
	await _test_scenes()
	check(_scene_checks_finished, "all scene checks reached their completion marker")
	await _test_audio()
	check(not root.get_node("SceneRouter").go("res://missing-scene.tscn"), "missing scene fails without blocking the game")
	check(not root.get_node("SceneRouter").busy, "router unlocks on loading error")
	gm.save_path = stored
	gm._save_read_only = true # test shutdown must not write any production save
	print("MONKY_REGRESSION: %d checks, %d failures" % [checks, failures])
	root.get_node("AudioManager").stop_all()
	await create_timer(0.1).timeout
	quit(0 if failures == 0 else 1)

func _test_scenes() -> void:
	for path in ["res://scenes/main.tscn", "res://scenes/minigames/minigames_menu.tscn",
		"res://scenes/minigames/fruit_catcher.tscn", "res://scenes/minigames/flappy_monky.tscn",
		"res://scenes/minigames/monky_jump.tscn", "res://scenes/minigames/wonky_runner.tscn"]:
		var scene := load(path) as PackedScene
		check(scene != null, "load " + path)
		if scene == null:
			continue
		var instance := scene.instantiate()
		root.add_child(instance)
		current_scene = instance
		await process_frame
		await physics_frame
		if path.ends_with("main.tscn"):
			var hud := instance.get_node("HUD")
			check(hud.mood_widget != null and hud.mood_widget.current_mood != "", "illustrated mood guide is live")
			check(hud.mood_widget.get_node_or_null("EmotionArt") != null, "real reaction asset is displayed")
			check(hud.settings_popup == null and not hud._shop_ready, "expensive modal setup is deferred")
			hud.btn_coins.pressed.emit()
			check(hud._shop_ready and hud.shop_popup.visible, "wallet button opens lazy shop on first use")
			check(hud.btn_iap_50.disabled and hud.btn_pack_ad.disabled and not hud.btn_pack_ad.visible, "fake ad and IAP actions stay hidden and disabled")
			hud._close_shop()
			hud._open_shop()
			await create_timer(0.25).timeout
			check(hud.shop_popup.visible, "close/open race cannot hide reopened shop")
			hud.btn_settings.pressed.emit()
			check(hud.settings_popup != null, "settings header button opens settings")
			gm.reduced_effects = true
			hud.btn_settings.button_down.emit()
			hud.btn_settings.button_up.emit()
			await process_frame
			check(hud.btn_settings.scale == Vector2.ONE, "reduced effects avoids press tween allocations")
			gm.reduced_effects = false
			hud._open_food_market()
			hud._open_wardrobe_modal()
			hud._select_wardrobe_tab("clothes")
			await process_frame
			check(hud.wardrobe_grid.get_child_count() == 2, "wardrobe clothes tab renders safe fallback")
		elif path.ends_with("fruit_catcher.tscn"):
			for i in range(100):
				instance._spawn_falling_item()
			check(instance.items_container.get_child_count() == 16, "fruit pool is bounded to 16 nodes")
			var fruit: Area2D = instance._active_items[0]
			instance._on_basket_area_entered(fruit)
			var first_score: int = instance.score
			var first_lives: int = instance.lives
			instance._on_basket_area_entered(fruit)
			check(instance.score == first_score and instance.lives == first_lives, "same fruit collision only resolves once")
			check(instance.combo_bonus(4) == 0 and instance.combo_bonus(5) == 10 and instance.combo_bonus(10) == 20, "combo bonus only every five fruits")
			instance._reset_combo()
			var score_before_combo: int = instance.score
			for _index in range(5):
				instance._on_fruit_caught(Vector2(540, 900), 10)
			check(instance.combo == 5 and instance.score == score_before_combo + 60, "real five-fruit combo grants 10 bonus points")
			instance._reset_combo()
			check(instance.combo == 0 and not instance._combo_badge.visible, "streak reset hides visual feedback")
			instance._trigger_game_over()
		elif path.ends_with("flappy_monky.tscn"):
			check(instance._free_pipes.size() == instance.PIPE_POOL_SIZE, "Flappy obstacle pool is prepared ahead of gameplay")
			check(instance.pipes_container.get_child_count() == instance.PIPE_POOL_SIZE, "Flappy does not allocate new obstacles while playing")
			var tap := InputEventScreenTouch.new()
			tap.position = Vector2(700, 1050)
			tap.pressed = true
			instance._input(tap)
			check(instance.is_game_started and instance.velocity_y == instance.JUMP_VELOCITY, "real touchscreen press starts an immediate flap")
			instance.velocity_y = 17.0
			var copy := InputEventMouseButton.new()
			copy.device = InputEvent.DEVICE_ID_EMULATION
			copy.position = Vector2(700, 1050)
			copy.button_index = MOUSE_BUTTON_LEFT
			copy.pressed = true
			instance._input(copy)
			check(instance.velocity_y == 17.0, "emulated mouse copy cannot double-flap")
			var native_mouse := InputEventMouseButton.new()
			native_mouse.device = InputEvent.DEVICE_ID_MOUSE
			native_mouse.position = Vector2(700, 1050)
			native_mouse.button_index = MOUSE_BUTTON_LEFT
			native_mouse.pressed = true
			instance._input(native_mouse)
			check(instance.velocity_y == instance.JUMP_VELOCITY, "physical mouse remains responsive for desktop")
			for _index in range(25):
				instance._spawn_pipe_obstacle()
			check(instance._active_pipes.size() == instance.PIPE_POOL_SIZE and instance.pipes_container.get_child_count() == instance.PIPE_POOL_SIZE, "Flappy spawning stays within 5 reusable pairs")
			var pair: Node2D = instance._active_pipes[0]
			var coin := pair.get_node("Coin") as Area2D
			instance._on_player_area_entered(coin)
			var first_coins: int = instance.coins_earned
			instance._on_player_area_entered(coin)
			check(first_coins == instance.coins_earned and not coin.visible, "Flappy coin is collected only once without deleting pooled nodes")
			instance._recycle_pipe(pair)
			check(instance._free_pipes.size() == 1, "Flappy recycles old obstacle immediately")
			instance._spawn_pipe_obstacle()
			check(instance._active_pipes.size() == instance.PIPE_POOL_SIZE and not (instance._active_pipes[instance._active_pipes.size() - 1].get_node("Coin") as Area2D).get_meta("consumed"), "respawned Flappy obstacle restores its coin")
			instance.score = 2
			instance._trigger_game_over()
			check(instance._reward_saved, "Flappy game over stores reward")
		elif path.ends_with("monky_jump.tscn"):
			var strip := instance.get_node("BackgroundStrip")
			check(strip._paths.size() == 16, "Jump discovers all 16 existing backgrounds")
			for index in range(16):
				strip._max_altura = index * 8000.0
				strip._update_strip()
				check(strip._tiles.size() <= 4, "Jump keeps at most four background textures at zone %d" % index)
			strip.reset_strip()
			check(strip._max_altura == 0.0 and strip._tiles.has(0), "Jump restart returns to first background")
			instance.score = 2
			instance._trigger_game_over()
			check(instance._reward_saved, "Jump game over stores reward")
		elif path.ends_with("wonky_runner.tscn"):
			for i in range(100):
				instance._spawn_item("coin", 1, 0.0)
			check(instance.active_items.size() <= 64, "Runner active objects are bounded")
			instance._jump()
			instance._toggle_pause()
			var y: float = instance.player.position.y
			await create_timer(0.1, true).timeout
			check(is_equal_approx(y, instance.player.position.y), "Runner pause freezes in-flight jump tween")
			instance._toggle_pause()
			instance.score = 600.0
			instance.coins_collected = 3
			instance._trigger_game_over()
			check(instance.rewards_given, "Runner saves before showing game over")
			instance._revive()
			check(not instance.is_game_over and instance.revive_used, "Runner real one-time revive remains playable")
			instance._trigger_game_over()
			instance._revive()
			check(instance.is_game_over, "second Runner revive is rejected")
		instance.queue_free()
		current_scene = null
		await process_frame
		await process_frame

	_scene_checks_finished = true

func _test_audio() -> void:
	var audio := root.get_node("AudioManager")
	gm.music_enabled = true
	audio.play_music("main", -6.0, 0.02)
	audio.stop_music(0.05)
	gm.music_enabled = false
	gm.music_enabled = true
	audio.play_music("main2", -6.0, 0.01)
	await create_timer(0.15).timeout
	check(audio._music_player.playing, "stale fade-out cannot stop newly requested track")
	check(audio._music_streams.size() <= 1, "only current music track retained in cache")
	gm.music_enabled = false
	await create_timer(0.35).timeout
	check(not audio._music_player.playing, "music mute finishes cleanly")

func _test_persistence_edges() -> void:
	var stored: String = gm.save_path
	var snapshot: ConfigFile = gm._build_save_config()
	gm.hunger = 0.0
	gm.protein = 0.0
	gm.food_inventory = {"apple": 2}
	gm.save_path = test_dir + "/missing-parent/feed.cfg"
	check(not gm.feed_item({"id": "apple"}), "feeding rejects failed save")
	check(gm.hunger == 0.0 and gm.get_food_quantity("apple") == 2, "failed feed preserves food and stats")
	var before: int = gm.coins
	check(not gm.reset_game_data() and gm.coins == before, "failed confirmed reset does not erase live progress")
	gm.save_path = stored
	check(gm.feed_item({"id": "apple", "hunger": 999999, "xp": 999999}), "food ID resolves canonical catalog")
	check(gm.hunger == 15.0 and gm.get_food_quantity("apple") == 1, "caller cannot forge nutritional rewards")
	check(not gm.feed_item({"id": "unknown"}), "unknown food is not consumed")
	var invalid := ConfigFile.new()
	invalid.set_value("game", "coins", "wrong type")
	check(SafeSave.write_config(invalid, test_dir + "/invalid-write.cfg", gm._validate_save) == ERR_INVALID_DATA, "save utility rejects invalid candidate")
	gm.save_path = test_dir + "/unrecoverable.cfg"
	invalid.save(gm.save_path)
	invalid.save(gm.save_path + ".bak")
	gm.load_game()
	var digest := FileAccess.get_sha256(gm.save_path)
	check(gm._save_read_only and not gm.save_game(), "both invalid saves switch to read-only")
	check(not gm.buy_food("apple") and FileAccess.get_sha256(gm.save_path) == digest, "read-only preserves unrecoverable files")
	var future := snapshot
	future.set_value("meta", "schema_version", 99)
	gm.save_path = test_dir + "/future.cfg"
	future.save(gm.save_path)
	gm.load_game()
	check(gm._save_read_only and not gm.save_game(), "future schema is not downgraded")
	future.set_value("meta", "schema_version", "invalid")
	check(not gm._validate_save(future), "schema version rejects wrong type")
	future.set_value("meta", "schema_version", 2)
	gm.save_path = stored
	future.save(stored)
	gm.load_game()
	var legacy_jump := ConfigFile.new()
	legacy_jump.set_value("score", "best", 12345)
	legacy_jump.save("user://monky_jump_score.cfg")
	var legacy_runner := ConfigFile.new()
	legacy_runner.set_value("runner", "best_score", 34567)
	legacy_runner.save("user://wonky_runner.cfg")
	gm._save_template.erase_section_key("meta", "legacy_records_imported")
	gm._migrate_legacy_records()
	check(gm.get_record("jump") == 12345 and gm.get_record("runner") == 34567, "legacy Jump and Runner records migrate by maximum")
	check(gm.save_game(), "migrated records persist")
	gm._save_template.set_value("future_feature", "opaque", "preserved")
	check(gm.save_game(), "unknown metadata round trip")
	var roundtrip := ConfigFile.new()
	roundtrip.load(stored)
	check(roundtrip.get_value("future_feature", "opaque", "") == "preserved", "unrecognized save sections are preserved")
	check(gm.reset_game_data(), "confirmed reset can be saved")
	check(gm.coins == 50 and gm.diamonds == 5 and gm.records.is_empty(), "reset restores defaults and clears all four records")
	gm._migrate_legacy_records()
	check(gm.records.is_empty(), "explicit reset does not re-import deleted records")
	gm.coins = 500
	gm.diamonds = 25
	gm.save_game()
