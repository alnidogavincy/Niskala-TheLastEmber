extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	for i in range(20): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://builds/menu-preview.png")
	main.start_game(false)
	for i in range(100): await physics_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://builds/game-preview.png")
	main.world.player.position = Vector2(13500, 620)
	for i in range(100): await physics_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://builds/boss-preview.png")
	main.world.player.position = Vector2(220, 620)
	for e in get_nodes_in_group("enemies"): e.queue_free()
	DisplayServer.window_set_size(Vector2i(1600, 720))
	for button in main.hud.controls: button.visibility_mode = TouchScreenButton.VISIBILITY_ALWAYS
	for i in range(30): await physics_frame
	var right: TouchScreenButton = main.hud.controls[1]
	var jump: TouchScreenButton = main.hud.controls[2]
	var attack: TouchScreenButton = main.hud.controls[3]
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.pressed = true
	touch.position = right.position + Vector2(40, 40)
	root.push_input(touch, true)
	await physics_frame
	var multitouch_ok := Input.is_action_pressed("right")
	var jump_event := InputEventScreenTouch.new()
	jump_event.index = 1
	jump_event.pressed = true
	jump_event.position = jump.position + Vector2(40, 40)
	root.push_input(jump_event, true)
	var attack_event := InputEventScreenTouch.new()
	attack_event.index = 2
	attack_event.pressed = true
	attack_event.position = attack.position + Vector2(40, 40)
	root.push_input(attack_event, true)
	multitouch_ok = multitouch_ok and Input.is_action_pressed("jump") and Input.is_action_pressed("attack")
	print("MULTITOUCH_SIMULTANEOUS=", multitouch_ok)
	for i in range(10): await physics_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://builds/touch-20x9-preview.png")
	for event in [touch, jump_event, attack_event]:
		event.pressed = false
		root.push_input(event, true)
	print("TOUCH_RELEASE=", not Input.is_action_pressed("right") and not Input.is_action_pressed("jump") and not Input.is_action_pressed("attack"))
	var start := Time.get_ticks_usec()
	for i in range(180): await process_frame
	print("RENDER_BENCHMARK_FPS=", 180000000.0 / (Time.get_ticks_usec() - start))
	main.queue_free()
	await process_frame
	quit()
