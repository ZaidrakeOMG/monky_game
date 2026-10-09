extends SceneTree

## Run with --script res://tests/capture.gd -- SCENE OUTPUT [METHOD] [WIDTH] [HEIGHT].
## Uses the real renderer; no screenshots are synthesized. Use an isolated XDG_DATA_HOME.
func _initialize() -> void:
	_capture.call_deferred()

func _capture() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		push_error("Expected scene and output PNG path")
		quit(2)
		return
	if args.size() >= 5:
		root.size = Vector2i(int(args[3]), int(args[4]))
	var scene := load(args[0]) as PackedScene
	if scene == null:
		quit(2)
		return
	var instance := scene.instantiate()
	root.add_child(instance)
	current_scene = instance
	for i in range(35):
		await process_frame
	if args.size() > 2 and not args[2].is_empty():
		if instance.has_method(args[2]):
			instance.call(args[2])
		else:
			instance.get_node("HUD").call(args[2])
		for i in range(35):
			await process_frame
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png(args[1])
	var stats := {"scene": args[0], "node_count": Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
		"resource_count": Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT),
		"static_memory_bytes": Performance.get_monitor(Performance.MEMORY_STATIC),
		"window": [root.size.x, root.size.y], "engine": Engine.get_version_info().string}
	var file := FileAccess.open(args[1] + ".json", FileAccess.WRITE)
	file.store_string(JSON.stringify(stats, "\t"))
	file.close()
	instance.queue_free()
	current_scene = null
	root.get_node("AudioManager").stop_all()
	await create_timer(0.15).timeout
	quit(0 if result == OK else 1)
