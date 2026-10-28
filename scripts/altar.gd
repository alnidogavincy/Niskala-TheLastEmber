extends Area2D

@export var altar_id := 0
var age := 0.0
var lit := false
var visual: Sprite2D

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var collider := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 75
	collider.shape = shape
	collider.position.y = -40
	add_child(collider)
	lit = altar_id in Session.lit
	visual = Sprite2D.new()
	visual.texture = Art.prop(false)
	visual.scale = Vector2.ONE * 0.22
	visual.position.y = -78
	add_child(visual)
	body_entered.connect(_entered)

func _entered(body: Node2D) -> void:
	if not body.is_in_group("player") or lit: return
	lit = true
	Session.light_altar(altar_id, position + Vector2(-80, -5))
	body.health = body.max_health
	body.health_changed.emit(body.health)
	Sound.effect("altar")

func _process(delta: float) -> void:
	age += delta
	visual.modulate = Color.WHITE if lit else Color(0.4, 0.7, 0.65)
	queue_redraw()

func _draw() -> void:
	var glow := Color("ffc976") if lit else Color("71d6c1")
	for i in range(4):
		draw_circle(Vector2(0, -70), 28 - i * 5, Color(glow, 0.035 + i * 0.025))
