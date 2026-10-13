extends SceneTree
## Real renderer captures, never generated mockups. All saves are disposable.
var pictures: int = 0
var failures: int = 0
var output: String = "res://reports/screenshots/"

func _initialize() -> void:
	if OS.get_environment("MONKY_TEST_MODE") != "1" or not "monky-ci-" in ProjectSettings.globalize_path("user://"):
		push_error("Visual capture requires an isolated test directory.")
		quit(2)
		return
	_run.call_deferred()

func mount_scene(path: String) -> Node:
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("Cannot capture scene: " + path)
		failures += 1
		return null
	var scene := packed.instantiate()
	root.add_child(scene)
	current_scene = scene
	return scene

func dispose(scene: Node) -> void:
	current_scene = null
	scene.queue_free()
	await process_frame
	await process_frame

func capture(label: String) -> void:
	await create_timer(0.45).timeout
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	if image == null or image.is_empty() or image.save_png(output + label + ".png") != OK:
		push_error("Renderer capture failed: " + label)
		failures += 1
		return
	pictures += 1
	var metadata := {"capture": label, "engine": Engine.get_version_info().string, "width": image.get_width(), "height": image.get_height(), "scene": current_scene.scene_file_path, "controls": []}
	for control in current_scene.find_children("*", "Control", true, false):
		if control.is_visible_in_tree() and (control is Button or control is Label):
			var rect: Rect2 = control.get_global_rect()
			metadata.controls.append({"node": str(current_scene.get_path_to(control)), "text": control.text, "x": rect.position.x, "y": rect.position.y, "width": rect.size.x, "height": rect.size.y})
	var file := FileAccess.open(output + label + ".json", FileAccess.WRITE)
	if file == null:
		failures += 1
	else:
		file.store_string(JSON.stringify(metadata, "  "))
		file.close()
	print("CAPTURE: ", label, " ", image.get_size())

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	var gm := root.get_node("GameManager")
	gm.sfx_enabled = false
	gm.music_enabled = false
	gm.reduced_effects = true
	root.size = Vector2i(540, 960)
	var menu := mount_scene("res://scenes/minigames/minigames_menu.tscn")
	if menu == null:
		quit(1)
		return
	await capture("01-menu-540x960")
	root.size = Vector2i(420, 932)
	await capture("02-menu-alto-420x932")
	root.size = Vector2i(360, 640)
	await capture("03-menu-pequeno-360x640")
	await dispose(menu)
	root.size = Vector2i(540, 960)
	var flappy := mount_scene("res://scenes/minigames/flappy_monky.tscn")
	if flappy != null:
		await capture("04-flappy-inicio")
		flappy._on_jump()
		flappy.spawn_timer.stop()
		flappy.set_physics_process(false)
		flappy.set_process(false)
		flappy._spawn_pipe_obstacle()
		flappy.pipes_container.get_child(0).position.x = 730
		await capture("05-flappy-tubos")
		flappy._show_pause()
		await capture("06-flappy-pausa")
		flappy._resume()
		flappy.score = 7
		flappy.coins_earned = 3
		flappy._trigger_game_over()
		await capture("07-flappy-resultado")
		await dispose(flappy)
	var fruit := mount_scene("res://scenes/minigames/fruit_catcher.tscn")
	if fruit != null:
		await capture("08-fruta-instrucciones")
		fruit._start_sheet.primary_button.pressed.emit()
		fruit.spawn_timer.stop()
		fruit.set_physics_process(false)
		for index in range(5):
			fruit._spawn_falling_item()
			var item: Area2D = fruit._active_items[index]
			item.position = Vector2(160 + index * 180, 420 + (index % 3) * 290)
			item.set_meta("data", fruit.FRUIT_TYPES[index])
			item.get_node("Sprite").texture = fruit._fruit_textures[fruit.FRUIT_TYPES[index].image]
		await capture("09-fruta-partida")
		fruit._show_pause()
		await capture("10-fruta-pausa")
		fruit._resume()
		fruit.score = 80
		fruit.coins_earned = 2
		fruit.lives = 0
		fruit._trigger_game_over()
		await capture("11-fruta-resultado")
		await dispose(fruit)
	var main := mount_scene("res://scenes/main.tscn")
	if main != null:
		await capture("12-mascota")
		var hud := main.get_node("HUD")
		hud.btn_coins.pressed.emit()
		await capture("13-tienda")
		hud._close_shop()
		await create_timer(0.4).timeout
		hud.btn_settings.pressed.emit()
		await capture("14-ajustes")
		await dispose(main)
	root.get_node("AudioManager").stop_all()
	if pictures != 14:
		failures += 1
	print("WONKY_RENDER: %d captures, %d failures" % [pictures, failures])
	quit(0 if failures == 0 else 1)
