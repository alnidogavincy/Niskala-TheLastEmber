extends CharacterBody2D

signal health_changed(value: int)
signal died
@export var speed := 280.0
@export var jump_velocity := -690.0
@export var max_health := 5
@export var damage := 1
@export var attack_cooldown := 0.38
var health := 5
var face := 1.0
var invulnerable := 0.0
var coyote := 0.0
var jump_buffer := 0.0
var cooldown := 0.0
var attack_time := 0.0
var dead := false
var age := 0.0
var footsteps := 0.0
var hit_ids: Array[int] = []
var body_art: AnimatedSprite2D
var hitbox: Area2D
var animator: AnimationPlayer
var camera: Camera2D

func _ready() -> void:
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1
	var shape := CollisionShape2D.new()
	var capsule := CapsuleShape2D.new()
	capsule.radius = 18
	capsule.height = 74
	shape.shape = capsule
	shape.position.y = -38
	add_child(shape)
	body_art = AnimatedSprite2D.new()
	body_art.name = "Visual"
	var frames := SpriteFrames.new()
	frames.add_animation("idle")
	frames.add_frame("idle", preload("res://assets/nara.png"))
	frames.add_animation("run")
	frames.set_animation_speed("run", 10)
	var sheet := preload("res://assets/nara_run.png")
	for i in range(4):
		var frame := AtlasTexture.new()
		frame.atlas = sheet
		frame.region = Rect2(i * sheet.get_width() / 4.0, 0, sheet.get_width() / 4.0, sheet.get_height())
		frames.add_frame("run", frame)
	body_art.sprite_frames = frames
	body_art.play("idle")
	body_art.scale = Vector2(0.091, 0.091)
	body_art.position = Vector2(-8, -65)
	add_child(body_art)
	animator = AnimationPlayer.new()
	add_child(animator)
	var library := AnimationLibrary.new()
	for state in ["idle", "run", "jump", "fall", "attack", "hurt", "death"]:
		var anim := Animation.new()
		anim.length = 0.48 if state == "run" else 0.8
		anim.loop_mode = Animation.LOOP_LINEAR if state in ["idle", "run"] else Animation.LOOP_NONE
		var track := anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(track, NodePath("Visual:rotation"))
		var tilt := 0.035 if state == "idle" else 0.1
		if state == "attack": tilt = 0.25
		if state == "death": tilt = 1.4
		anim.track_insert_key(track, 0, -tilt)
		anim.track_insert_key(track, anim.length * 0.5, tilt)
		anim.track_insert_key(track, anim.length, 0.0)
		library.add_animation(state, anim)
	animator.add_animation_library("", library)
	hitbox = Area2D.new()
	hitbox.collision_layer = 0
	hitbox.collision_mask = 4
	var hit_shape := CollisionShape2D.new()
	var hit_rect := RectangleShape2D.new()
	hit_rect.size = Vector2(100, 100)
	hit_shape.shape = hit_rect
	hitbox.add_child(hit_shape)
	add_child(hitbox)
	camera = Camera2D.new()
	camera.position = Vector2(140, -260)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5
	camera.limit_left = 0
	camera.limit_right = 15360
	camera.limit_top = -150
	camera.limit_bottom = 820
	add_child(camera)

func _physics_process(delta: float) -> void:
	age += delta
	if dead:
		return
	invulnerable = maxf(0, invulnerable - delta)
	cooldown = maxf(0, cooldown - delta)
	attack_time = maxf(0, attack_time - delta)
	coyote = 0.12 if is_on_floor() else maxf(0, coyote - delta)
	jump_buffer = 0.14 if Input.is_action_just_pressed("jump") else maxf(0, jump_buffer - delta)
	var direction := Input.get_axis("left", "right")
	velocity.x = move_toward(velocity.x, direction * speed, 2200 * delta)
	velocity.y = minf(1100, velocity.y + 1500 * delta)
	if direction != 0:
		face = signf(direction)
	if jump_buffer > 0 and coyote > 0:
		velocity.y = jump_velocity
		jump_buffer = 0
		coyote = 0
		Sound.effect("jump")
	if Input.is_action_just_released("jump") and velocity.y < -220:
		velocity.y = -220
	if Input.is_action_just_pressed("attack") and cooldown <= 0:
		cooldown = attack_cooldown
		attack_time = 0.22
		hit_ids.clear()
		Sound.effect("attack")
	hitbox.position = Vector2(face * 64, -48)
	if attack_time > 0:
		for target in hitbox.get_overlapping_bodies():
			if target.has_method("take_damage") and not target.get_instance_id() in hit_ids:
				hit_ids.append(target.get_instance_id())
				target.take_damage(damage, global_position)
	move_and_slide()
	body_art.flip_h = face < 0
	body_art.modulate.a = 0.4 if invulnerable > 0 and sin(age * 40) > 0 else 1.0
	var state := "idle"
	if not is_on_floor(): state = "jump" if velocity.y < 0 else "fall"
	elif absf(velocity.x) > 20: state = "run"
	if attack_time > 0: state = "attack"
	if invulnerable > 0.85: state = "hurt"
	if animator.current_animation != state: animator.play(state)
	body_art.play("run" if state == "run" else "idle")
	body_art.scale = Vector2.ONE * (130.0 / preload("res://assets/nara_run.png").get_height() if state == "run" else 0.091)
	body_art.position.y = -65 + (sin(age * 19) * 3 if state == "run" else sin(age * 3) * 1.2)
	if state == "run":
		footsteps -= delta
		if footsteps <= 0:
			Sound.effect("step")
			footsteps = 0.3
	if global_position.y > 900:
		die()
	queue_redraw()

func take_damage(amount: int, source: Vector2) -> void:
	if dead or invulnerable > 0:
		return
	health = maxi(0, health - amount)
	health_changed.emit(health)
	invulnerable = 1.1
	velocity = Vector2(signf(global_position.x - source.x) * 260, -260)
	Sound.effect("hurt")
	if health <= 0: die()

func die() -> void:
	if dead: return
	dead = true
	health = 0
	health_changed.emit(0)
	animator.play("death")
	Sound.effect("hurt")
	await get_tree().create_timer(0.8).timeout
	died.emit()

func _draw() -> void:
	if attack_time > 0:
		var origin := Vector2(0, -48)
		var offset := 0.0 if face > 0 else PI
		draw_arc(origin, 82, offset - 1.1, offset + 1.1, 24, Color(1, 0.67, 0.23, 0.9), 12, true)
		draw_arc(origin, 92, offset - 0.9, offset + 0.9, 24, Color(1, 0.94, 0.7, 0.8), 3, true)
