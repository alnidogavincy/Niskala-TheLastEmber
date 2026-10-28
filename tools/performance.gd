extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	main.start_game(false)
	for i in range(90): await process_frame
	for size in [Vector2i(1280, 720), Vector2i(1600, 720)]:
		DisplayServer.window_set_size(size)
		for i in range(30): await process_frame
		var start := Time.get_ticks_usec()
		var cpu := 0.0
		for i in range(180):
			await process_frame
			cpu += Performance.get_monitor(Performance.TIME_PROCESS)
		print("PERF ", size, " fps=", 180000000.0 / (Time.get_ticks_usec() - start), " cpu_ms=", cpu / 180 * 1000, " drawcalls=", Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	main.queue_free()
	await process_frame
	quit()
