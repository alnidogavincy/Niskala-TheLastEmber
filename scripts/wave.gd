extends Area2D
var direction := 1.0
var life := 2.0
func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var c := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(40, 45)
	c.shape = shape
	add_child(c)
	body_entered.connect(func(body):
		if body.has_method("take_damage"): body.take_damage(1, global_position)
	)
func _physics_process(delta: float) -> void:
	position.x += direction * 300 * delta
	life -= delta
	if life < 0: queue_free()
	queue_redraw()
func _draw() -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(-22, 20), Vector2(-12, -30), Vector2(2, -8), Vector2(13, -38), Vector2(24, 20)]), Color("bca76a"))
