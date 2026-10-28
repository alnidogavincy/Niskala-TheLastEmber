extends Node

var world: Node2D
var hud: CanvasLayer
var menu: CanvasLayer
var overlay: CanvasLayer
var elapsed := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().auto_accept_quit = false
	var theme := Theme.new()
	theme.default_font = preload("res://assets/Nunito.ttf")
	ThemeDB.fallback_font = theme.default_font
	show_menu()

func clear_game() -> void:
	get_tree().paused = false
	Session.release_inputs()
	if is_instance_valid(world): world.queue_free()
	if is_instance_valid(hud): hud.queue_free()
	if is_instance_valid(menu): menu.queue_free()
	if is_instance_valid(overlay): overlay.queue_free()

func show_menu() -> void:
	clear_game()
	Sound.music("forest")
	menu = preload("res://scenes/menu.tscn").instantiate()
	add_child(menu)
	var screen := Control.new()
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.add_child(screen)
	var bg := TextureRect.new()
	bg.texture = preload("res://assets/forest.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(bg)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.055, 0.065, 0.6)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(shade)
	var portrait := TextureRect.new()
	portrait.texture = preload("res://assets/nara.png")
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.anchor_left = 0.55
	portrait.anchor_right = 0.95
	portrait.anchor_top = 0.15
	portrait.anchor_bottom = 0.94
	screen.add_child(portrait)
	var column := VBoxContainer.new()
	column.position = Vector2(100, 92)
	column.add_theme_constant_override("separation", 14)
	screen.add_child(column)
	column.add_child(Art.text("S E B U A H   P E R J A L A N A N   T E R A K H I R", 13, Color("b4d0bd")))
	var logo := TextureRect.new()
	logo.texture = preload("res://assets/logo.svg")
	logo.custom_minimum_size = Vector2(480, 125)
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	column.add_child(logo)
	column.add_child(Art.text("T H E   L A S T   E M B E R", 21, Color("efc986")))
	var intro := Art.text("Ketika hutan melupakan cahaya,\nsatu bara masih menyala.", 19, Color("c2d0c4"))
	intro.custom_minimum_size.y = 74
	column.add_child(intro)
	column.add_child(Art.button("Mulai perjalanan  →", func(): start_game(false)))
	var resume := Art.button("Lanjutkan", func(): start_game(true))
	resume.disabled = not Session.has_save or Session.won
	column.add_child(resume)
	column.add_child(Art.button("Pengaturan audio", show_settings))
	if not OS.has_feature("android"):
		column.add_child(Art.button("Keluar", quit_game))
	var hint := "Tombol layar: gerak, lompat, dan serangan bara" if OS.has_feature("android") else "A/D  Bergerak  ·  SPACE  Lompat  ·  J  Serang"
	var footer := Art.text("BAB I   /   HUTAN BARA SUNYI                                      " + hint, 13, Color("b2c4b8"))
	footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_left = 100
	footer.offset_top = -42
	screen.add_child(footer)

func start_game(resume: bool) -> void:
	clear_game()
	if not resume: Session.new_game()
	elapsed = 0
	world = preload("res://scenes/level.tscn").instantiate()
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(world)
	hud = preload("res://scenes/hud.tscn").instantiate()
	add_child(hud)
	hud.bind(world)
	hud.pause_requested.connect(pause_game)
	world.respawning.connect(func(): hud.bind(world))
	world.completed.connect(show_victory)

func dialog(title: String, subtitle: String) -> VBoxContainer:
	if is_instance_valid(overlay): overlay.queue_free()
	overlay = CanvasLayer.new()
	overlay.layer = 30
	add_child(overlay)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(root)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.045, 0.055, 0.92)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 20)
	center.add_child(col)
	var heading := Art.text(title, 40, Color("f1ce8c"))
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(heading)
	var body := Art.text(subtitle, 18)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(body)
	return col

func pause_game() -> void:
	if is_instance_valid(overlay) or not is_instance_valid(world): return
	Session.release_inputs()
	get_tree().paused = true
	var col := dialog("Bara masih menyala", "Perjalanan dijeda.")
	col.add_child(Art.button("Lanjutkan", close_dialog))
	col.add_child(Art.button("Pengaturan audio", show_settings))
	col.add_child(Art.button("Menu utama", show_menu))

func close_dialog() -> void:
	Session.release_inputs()
	get_tree().paused = false
	if is_instance_valid(overlay):
		overlay.queue_free()
		overlay = null

func show_settings() -> void:
	var col := dialog("Suara hutan", "Atur suasana perjalanan Anda.")
	for kind in ["Musik", "Efek suara"]:
		col.add_child(Art.text(kind, 19))
		var slider := HSlider.new()
		slider.min_value = 0
		slider.max_value = 1
		slider.step = 0.05
		slider.value = Session.music_volume if kind == "Musik" else Session.effects_volume
		slider.custom_minimum_size = Vector2(360, 32)
		slider.value_changed.connect(func(value):
			if kind == "Musik": Session.music_volume = value
			else: Session.effects_volume = value
			Sound.apply_volume()
			Session.save_game()
		)
		col.add_child(slider)
	col.add_child(Art.button("Kembali", close_dialog))

func show_victory() -> void:
	get_tree().paused = true
	Session.release_inputs()
	var col := dialog("Cahaya kembali pulang", "HUTAN BARA SUNYI — SELESAI\n\nTiga altar menyala. Sang penunggu telah beristirahat.\nBara terakhir kini menjadi awal yang baru.")
	col.add_child(Art.button("Main lagi", func(): start_game(false)))
	col.add_child(Art.button("Menu utama", show_menu))

func _process(delta: float) -> void:
	if is_instance_valid(world) and not get_tree().paused: elapsed += delta

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if Session.won and is_instance_valid(world):
			show_menu()
			return
		if is_instance_valid(overlay): close_dialog()
		else: pause_game()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		Session.release_inputs()
		pause_game()
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game()
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		pause_game()

func quit_game() -> void:
	Sound.shutdown()
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()
