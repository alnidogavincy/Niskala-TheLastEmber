extends SceneTree
var failures := 0
func check(ok: bool, label: String) -> void:
	print("PASS " if ok else "FAIL ", label)
	if not ok: failures += 1
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	check(is_instance_valid(main.menu), "main menu")
	main.start_game(false)
	await process_frame
	await physics_frame
	var level: Node = main.world
	var player: Node = level.player
	for i in range(90): await physics_frame
	check(player.is_on_floor(), "player lands on native TileMap collision")
	check(player.health == 5, "starts with five health")
	var start_x: float = player.position.x
	Input.action_press("right")
	for i in range(40): await physics_frame
	Input.action_release("right")
	check(player.position.x > start_x + 100, "InputMap movement")
	Input.action_press("jump")
	await physics_frame
	await physics_frame
	check(player.velocity.y < -500, "jump impulse")
	Input.action_release("jump")
	for i in range(70): await physics_frame
	player.take_damage(1, player.position - Vector2(20, 0))
	player.take_damage(1, player.position - Vector2(20, 0))
	check(player.health == 4, "damage invulnerability")
	var target: Node = get_nodes_in_group("enemies")[0]
	target.position = Vector2(1180, 640)
	target.set_physics_process(false)
	player.position = Vector2(1080, 640)
	player.velocity = Vector2.ZERO
	player.face = 1.0
	player.invulnerable = 3
	for i in range(5): await physics_frame
	Input.action_press("attack")
	for i in range(4): await physics_frame
	Input.action_release("attack")
	check(target.health == target.max_health - 1, "native Area2D melee hit")
	for i in range(8): await physics_frame
	check(target.health == target.max_health - 1, "one hit per swing")
	player.position = Vector2(780, 630)
	for i in range(8): await physics_frame
	var session := root.get_node("Session")
	check(0 in session.lit, "altar activation")
	check(player.health == 5, "altar heals")
	session.save_game()
	var saved_cp: Vector2 = session.checkpoint
	session.checkpoint = Vector2.ZERO
	session.load_save()
	check(session.checkpoint == saved_cp, "checkpoint save and load")
	check(not session.boss_dead, "portal initially locked")
	main.pause_game()
	check(paused, "pause")
	main.close_dialog()
	check(not paused and not Input.is_action_pressed("right"), "resume releases input")
	player.die()
	await create_timer(1.1).timeout
	check(level.player != player and level.player.health == 5, "death restores player at checkpoint")
	check(0 in session.lit, "death preserves altar")
	var boss: Node = level.boss
	level.player.position = boss.position + Vector2(-180, 0)
	level.player.invulnerable = 0
	boss.phase = 0
	boss.timer = 0
	boss.next_attack = 0
	boss.boss_tick(0.1, level.player)
	check(boss.phase == 1 and boss.timer > 1, "boss telegraphs slam")
	boss.boss_tick(1.2, level.player)
	check(level.player.health == 4, "ground slam damages grounded player")
	boss.boss_tick(0.4, level.player)
	check(boss.phase == 3 and boss.timer > 2, "boss recovery window")
	boss.phase = 1
	boss.timer = 0
	boss.next_attack = 1
	boss.boss_tick(0.1, level.player)
	check(get_nodes_in_group("waves").size() == 1, "boss launches root wave")
	boss.take_damage(30, Vector2.ZERO)
	await process_frame
	check(session.boss_dead, "boss defeat persists")
	session.light_altar(1, Vector2(7340, 630))
	session.light_altar(2, Vector2(14580, 630))
	level.player.position = Vector2(15010, 630)
	for i in range(5): await physics_frame
	check(session.won, "three altars and boss unlock victory")
	check(is_instance_valid(main.overlay), "victory interface")
	paused = false
	session.new_game()
	root.get_node("Sound").shutdown()
	main.queue_free()
	await process_frame
	await create_timer(0.15).timeout
	print("SMOKE_RESULT failures=", failures)
	quit(failures)
