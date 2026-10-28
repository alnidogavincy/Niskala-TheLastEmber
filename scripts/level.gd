extends Node2D

signal completed
signal respawning
var player: CharacterBody2D
var boss: CharacterBody2D
var time := 0.0
var portal: Area2D
var portal_art: Sprite2D
var enemy_specs: Array[Dictionary] = []
const FLOOR_Y := 640.0
const ALTARS := [Vector2(780, 640), Vector2(7420, 640), Vector2(14660, 640)]

func _ready() -> void:
	build_background()
	build_terrain()
	for i in range(3):
		var altar := preload("res://scenes/altar.tscn").instantiate()
		altar.altar_id = i
		altar.position = ALTARS[i]
		add_child(altar)
	for i in range(4, 51, 2):
		var x := i * 256.0 + 110
		if absf(x - 7420) < 300: continue
		var floor_height := 512.0 if i in [6, 13, 20, 27, 34, 41, 48, 10, 18, 30, 38, 45] else FLOOR_Y
		enemy_specs.append({"kind": "wisp" if i % 6 == 0 else "root", "pos": Vector2(x, floor_height - 65 if i % 6 == 0 else floor_height)})
	spawn_enemies()
	spawn_player()
	portal = Area2D.new()
	portal.position = Vector2(15010, FLOOR_Y)
	portal.collision_layer = 0
	portal.collision_mask = 2
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(100, 200)
	collider.shape = shape
	collider.position.y = -100
	portal.add_child(collider)
	add_child(portal)
	portal_art = Sprite2D.new()
	portal_art.texture = Art.prop(true)
	portal_art.scale = Vector2.ONE * 0.34
	portal_art.position.y = -167
	portal.add_child(portal_art)
	portal.body_entered.connect(func(body):
		if body == player and Session.lit.size() == 3 and Session.boss_dead:
			Session.won = true
			Session.save_game()
			Sound.effect("portal")
			completed.emit()
	)
	Sound.music("forest")

func build_background() -> void:
	var vista := Parallax2D.new()
	vista.name = "FarForest"
	vista.scroll_scale = Vector2(0.12, 0.1)
	vista.repeat_size = Vector2(3379.2, 0)
	vista.z_index = -20
	add_child(vista)
	for i in range(2):
		var sprite := Sprite2D.new()
		sprite.texture = preload("res://assets/forest.png")
		sprite.centered = false
		sprite.scale = Vector2(1.1, 1.1)
		sprite.position = Vector2(i * 1536 * 1.1, -200)
		sprite.z_index = -20
		if i % 2: sprite.flip_h = true
		vista.add_child(sprite)
	var ruins := Parallax2D.new()
	ruins.name = "AncientRuins"
	ruins.scroll_scale = Vector2(0.35, 0.2)
	ruins.repeat_size = Vector2(2400, 0)
	ruins.z_index = -15
	add_child(ruins)
	for i in range(2):
		var ruin := Sprite2D.new()
		ruin.texture = Art.prop(true)
		ruin.scale = Vector2.ONE * 0.4
		ruin.position = Vector2(750 + i * 1200, 380)
		ruin.modulate = Color(0.2, 0.48, 0.45, 0.4)
		ruins.add_child(ruin)
	var mist := Parallax2D.new()
	mist.name = "DriftingMist"
	mist.scroll_scale = Vector2(0.55, 0.3)
	mist.repeat_size = Vector2(1600, 0)
	mist.autoscroll = Vector2(9, 0)
	mist.z_index = -10
	add_child(mist)
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color(0.42, 0.8, 0.72, 0.13), Color(0.42, 0.8, 0.72, 0)])
	var mist_texture := GradientTexture2D.new()
	mist_texture.gradient = gradient
	mist_texture.width = 512
	mist_texture.height = 128
	mist_texture.fill = GradientTexture2D.FILL_RADIAL
	mist_texture.fill_from = Vector2(0.5, 0.5)
	mist_texture.fill_to = Vector2(1, 0.5)
	for i in range(3):
		var cloud := Sprite2D.new()
		cloud.texture = mist_texture
		cloud.scale = Vector2(2.3, 1.8)
		cloud.position = Vector2(i * 550, 430 + i * 40)
		mist.add_child(cloud)
	var canopy := Parallax2D.new()
	canopy.name = "NearCanopy"
	canopy.scroll_scale = Vector2(1.15, 0.3)
	canopy.repeat_size = Vector2(1536, 0)
	canopy.z_index = 5
	add_child(canopy)
	var leaves := Sprite2D.new()
	leaves.texture = preload("res://assets/canopy.png")
	leaves.centered = false
	leaves.position.y = -250
	canopy.add_child(leaves)

func build_terrain() -> void:
	var source := TileSetAtlasSource.new()
	var image := preload("res://assets/forest_atlas.png").get_image().get_region(Rect2i(22, 165, 700, 420))
	image.resize(256, 154, Image.INTERPOLATE_LANCZOS)
	source.texture = ImageTexture.create_from_image(image)
	source.texture_region_size = Vector2i(256, 154)
	source.create_tile(Vector2i.ZERO)
	var tiles := TileSet.new()
	tiles.tile_size = Vector2i(256, 128)
	tiles.add_physics_layer()
	tiles.set_physics_layer_collision_layer(0, 1)
	tiles.add_source(source, 0)
	var data := source.get_tile_data(Vector2i.ZERO, 0)
	data.texture_origin = Vector2i(0, -13)
	data.add_collision_polygon(0)
	data.set_collision_polygon_points(0, 0, PackedVector2Array([Vector2(-128, -64), Vector2(128, -64), Vector2(128, 48), Vector2(-128, 48)]))
	var terrain := TileMapLayer.new()
	terrain.name = "Terrain"
	terrain.tile_set = tiles
	add_child(terrain)
	var decoration := TileMapLayer.new()
	decoration.name = "DistantRuins"
	decoration.tile_set = tiles
	decoration.collision_enabled = false
	decoration.modulate = Color(0.28, 0.5, 0.45, 0.45)
	decoration.z_index = -5
	add_child(decoration)
	var gaps := [6, 13, 20, 27, 34, 41, 48]
	for x in range(60):
		if not x in gaps:
			terrain.set_cell(Vector2i(x, 5), 0, Vector2i.ZERO)
			terrain.set_cell(Vector2i(x, 6), 0, Vector2i.ZERO)
		else:
			terrain.set_cell(Vector2i(x, 4), 0, Vector2i.ZERO)
		if x % 5 == 0:
			decoration.set_cell(Vector2i(x, 3), 0, Vector2i.ZERO)
	for x in [10, 18, 30, 38, 45]:
		terrain.set_cell(Vector2i(x, 4), 0, Vector2i.ZERO)

func spawn_enemies() -> void:
	for old in get_tree().get_nodes_in_group("enemies"):
		old.queue_free()
	for spec in enemy_specs:
		if spec.pos.x < Session.checkpoint.x - 200: continue
		var enemy := preload("res://scenes/enemy.tscn").instantiate()
		enemy.kind = spec.kind
		enemy.position = spec.pos
		add_child(enemy)
	if not Session.boss_dead:
		boss = preload("res://scenes/boss.tscn").instantiate()
		boss.position = Vector2(13840, FLOOR_Y)
		add_child(boss)
		boss.defeated.connect(func():
			Session.boss_dead = true
			Session.save_game()
			Session.changed.emit()
			Sound.music("forest")
		)

func spawn_player() -> void:
	player = preload("res://scenes/player.tscn").instantiate()
	player.position = Session.checkpoint
	add_child(player)
	player.died.connect(restart_checkpoint)

func restart_checkpoint() -> void:
	Session.release_inputs()
	player.queue_free()
	await get_tree().process_frame
	for wave in get_tree().get_nodes_in_group("waves"): wave.queue_free()
	spawn_enemies()
	spawn_player()
	respawning.emit()
	Sound.music("forest")

func spawn_root_wave(pos: Vector2, direction: float) -> void:
	var wave := Area2D.new()
	wave.set_script(preload("res://scripts/wave.gd"))
	wave.position = pos
	wave.direction = direction
	wave.add_to_group("waves")
	add_child(wave)

func _process(delta: float) -> void:
	time += delta
	if not is_instance_valid(player): return
	if is_instance_valid(boss) and boss.active:
		Sound.music("boss")
	portal_art.modulate = Color.WHITE if Session.lit.size() == 3 and Session.boss_dead else Color(0.4, 0.65, 0.6)
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(player): return
	var cx: float = player.camera.get_screen_center_position().x
	# Four depth bands: painted vista, drifting mist, midground ruins, foreground vines.
	for i in range(28):
		var x := fposmod(i * 157.0 - cx * 0.14, 1800) + cx - 900
		var y := 190 + sin(i * 6.3 + time * 0.4) * 180
		draw_circle(Vector2(x, y), 2 + sin(time + i), Color(0.9, 0.9, 0.5, 0.4))
	for i in range(9):
		var x := fposmod(i * 290.0 - cx * 0.3 + time * 8, 2300) + cx - 1100
		draw_circle(Vector2(x, 730), 180, Color(0.3, 0.7, 0.65, 0.025))
	var center := Vector2(15010, 530)
	var unlocked := Session.lit.size() == 3 and Session.boss_dead
	var color := Color("f6ce83") if unlocked else Color("4caa9d")
	for i in range(7):
		var x := center.x - 70 + i * 23
		draw_line(Vector2(x, 450), Vector2(x, 630), Color(color, (0.15 if unlocked else 0.04) + sin(time * 2 + i) * 0.03), 13)
