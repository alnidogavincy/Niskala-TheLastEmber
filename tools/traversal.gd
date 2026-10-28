extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	main.start_game(false)
	await process_frame
	var level: Node = main.world
	for e in get_nodes_in_group("enemies"): e.queue_free()
	var player: Node = level.player
	var ticks := 0
	var deaths := 0
	player.died.connect(func(): deaths += 1)
	Input.action_press("right")
	while is_instance_valid(player) and player.position.x < 14900 and ticks < 8000:
		if player.is_on_wall() and player.is_on_floor(): Input.action_press("jump")
		else: Input.action_release("jump")
		await physics_frame
		ticks += 1
	var ok: bool = is_instance_valid(player) and player.position.x >= 14900
	print("TRAVERSAL_RESULT passed=", ok, " ticks=", ticks, " x=", player.position.x if is_instance_valid(player) else -1)
	Input.action_release("right")
	Input.action_release("jump")
	main.queue_free()
	await process_frame
	quit(0 if ok else 1)
