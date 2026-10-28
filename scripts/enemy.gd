extends CharacterBody2D

signal defeated
@export_enum("root", "wisp", "boss") var kind := "root"
@export var max_health := 3
@export var speed := 65.0
var health := 3
var home := Vector2.ZERO
var direction := -1.0
var age := 0.0
var flash := 0.0
var phase := 0
var timer := 1.5
var next_attack := 0
var active := false
var art: Sprite2D
var hurt_area: Area2D
var floor_probe: RayCast2D

func _ready() -> void:
	add_to_group("enemies")
	collision_layer = 4
	collision_mask = 1
	home = position
	if kind == "boss": max_health = 24
	if kind == "wisp": max_health = 2
	health = max_health
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(110, 140) if kind == "boss" else Vector2(45, 50)
	shape.position.y = -rect.size.y / 2
	shape.shape = rect
	add_child(shape)
	art = Sprite2D.new()
	art.texture = Art.creature(kind)
	var size := 230.0 if kind == "boss" else 87.0
	art.scale = Vector2.ONE * size / art.texture.get_height()
	art.position.y = -size / 2 + 5
	add_child(art)
	hurt_area = Area2D.new()
	hurt_area.collision_layer = 0
	hurt_area.collision_mask = 2
	var contact := CollisionShape2D.new()
	contact.shape = rect
	contact.position = shape.position
	hurt_area.add_child(contact)
	add_child(hurt_area)
	floor_probe = RayCast2D.new()
	floor_probe.collision_mask = 1
	floor_probe.target_position = Vector2(0, 60)
	add_child(floor_probe)

func _physics_process(delta: float) -> void:
	age += delta
	flash = maxf(0, flash - delta)
	var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
	if not is_instance_valid(player): return
	if absf(player.position.x - position.x) > 1000: return
	if kind == "boss":
		boss_tick(delta, player)
	elif kind == "wisp":
		position.x = home.x + sin(age * 0.8) * 100
		position.y = home.y + sin(age * 1.8) * 32
	else:
		floor_probe.position = Vector2(direction * 45, -20)
		floor_probe.force_raycast_update()
		if absf(position.x - home.x) > 115: direction = signf(home.x - position.x)
		if is_on_floor() and not floor_probe.is_colliding(): direction *= -1
		if is_on_wall(): direction *= -1
		velocity.x = direction * speed
		velocity.y += 1500 * delta
		move_and_slide()
	art.flip_h = direction > 0
	art.rotation = sin(age * 5) * 0.04
	art.modulate = Color(2, 1.5, 0.8) if flash > 0 else Color.WHITE
	for body in hurt_area.get_overlapping_bodies():
		if body.has_method("take_damage"): body.take_damage(1, global_position)
	queue_redraw()

func boss_tick(delta: float, player: CharacterBody2D) -> void:
	active = absf(player.position.x - position.x) < 650
	if not active: return
	direction = signf(player.position.x - position.x)
	timer -= delta
	if timer > 0: return
	match phase:
		0:
			phase = 1
			timer = 1.1
		1:
			phase = 2
			timer = 0.35
			Sound.effect("slam")
			if next_attack == 0:
				if absf(player.position.x - position.x) < 230 and player.position.y > position.y - 95:
					player.take_damage(1, position)
			else:
				get_parent().spawn_root_wave(position + Vector2(direction * 80, -25), direction)
		2:
			phase = 3
			timer = 2.2
		3:
			phase = 0
			timer = 0.7
			next_attack = 1 - next_attack

func take_damage(amount: int, _source: Vector2) -> void:
	if health <= 0: return
	health -= amount
	flash = 0.18
	Sound.effect("hit")
	if health <= 0:
		defeated.emit()
		queue_free()

func _draw() -> void:
	if kind != "boss":
		if health < max_health:
			draw_rect(Rect2(-25, -100, 50, 4), Color("203939"))
			draw_rect(Rect2(-25, -100, 50.0 * health / max_health, 4), Color("ecc27e"))
		return
	if phase == 1:
		var width := 460.0 if next_attack == 0 else 170.0
		draw_rect(Rect2(-width / 2, -10, width, 10), Color(1, 0.4, 0.1, 0.5 + sin(age * 18) * 0.2))
		draw_circle(Vector2(0, -120), 25 + sin(age * 15) * 6, Color(1, 0.7, 0.2, 0.4))
	if phase == 2 and next_attack == 0:
		draw_arc(Vector2.ZERO, 200, PI, TAU, 32, Color(1, 0.7, 0.25, 0.8), 12, true)
