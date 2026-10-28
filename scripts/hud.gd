extends CanvasLayer

signal pause_requested
var health_label: Label
var objective: Label
var zone: Label
var altar_label: Label
var boss_label: Label
var boss_bar: ProgressBar
var progress: ProgressBar
var controls: Array[TouchScreenButton] = []
var root: Control
var level: Node2D
var status_panel: PanelContainer
var pause_button: Button

func _ready() -> void:
	layer = 10
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var bar := PanelContainer.new()
	status_panel = bar
	bar.position = Vector2(28, 24)
	bar.add_theme_stylebox_override("panel", Art.panel(Color(0.025, 0.1, 0.12, 0.88)))
	root.add_child(bar)
	var col := VBoxContainer.new()
	bar.add_child(col)
	col.add_child(Art.text("NARA  /  PENJAGA BARA", 13, Color("acc5b7")))
	health_label = Art.text("◆ ◆ ◆ ◆ ◆", 27, Color("f6c780"))
	col.add_child(health_label)
	altar_label = Art.text("ALTAR  0 / 3", 14)
	col.add_child(altar_label)
	zone = Art.text("HUTAN BARA SUNYI", 15, Color("f1dcab"))
	zone.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	zone.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	zone.position.y = 30
	root.add_child(zone)
	progress = ProgressBar.new()
	progress.show_percentage = false
	progress.custom_minimum_size = Vector2(240, 3)
	progress.position = Vector2(520, 60)
	progress.size = Vector2(240, 3)
	progress.add_theme_stylebox_override("background", Art.thin_bar(Color("244744")))
	progress.add_theme_stylebox_override("fill", Art.thin_bar(Color("d2b776")))
	root.add_child(progress)
	var pause := Art.button("Ⅱ", func(): pause_requested.emit())
	pause_button = pause
	pause.custom_minimum_size = Vector2(56, 50)
	pause.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	pause.position = Vector2(-84, 24)
	root.add_child(pause)
	objective = Art.text("", 17)
	objective.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	objective.add_theme_color_override("font_shadow_color", Color("092d30"))
	objective.add_theme_constant_override("shadow_offset_y", 2)
	objective.add_theme_constant_override("shadow_outline_size", 5)
	objective.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	objective.offset_top = -80
	objective.offset_bottom = -40
	root.add_child(objective)
	boss_label = Art.text("PENUNGGU AKAR", 16, Color("f4cb80"))
	boss_label.position = Vector2(490, 90)
	boss_label.size.x = 300
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(boss_label)
	boss_bar = ProgressBar.new()
	boss_bar.position = Vector2(440, 120)
	boss_bar.size = Vector2(400, 10)
	boss_bar.show_percentage = false
	boss_bar.add_theme_stylebox_override("background", Art.thin_bar(Color("244744")))
	boss_bar.add_theme_stylebox_override("fill", Art.thin_bar(Color("e0aa65")))
	root.add_child(boss_bar)
	for action in ["left", "right", "jump", "attack"]:
		var touch := TouchScreenButton.new()
		touch.action = action
		touch.visibility_mode = TouchScreenButton.VISIBILITY_TOUCHSCREEN_ONLY
		var shape := CircleShape2D.new()
		shape.radius = 40
		touch.shape = shape
		touch.texture_normal = load("res://assets/touch_" + action + ".svg")
		touch.texture_pressed = touch.texture_normal
		touch.shape_centered = true
		add_child(touch)
		controls.append(touch)
	get_viewport().size_changed.connect(layout)
	layout()
	Session.changed.connect(update_altars)
	update_altars()

func bind(world: Node2D) -> void:
	level = world
	level.player.health_changed.connect(update_health)
	update_health(level.player.health)

func update_health(value: int) -> void:
	health_label.text = "◆ ".repeat(value) + "◇ ".repeat(5 - value)

func update_altars() -> void:
	altar_label.text = "ALTAR  %d / 3" % Session.lit.size()

func layout() -> void:
	var size := get_viewport().get_visible_rect().size
	var margin := 28.0
	var right_margin := 28.0
	if OS.has_feature("android"):
		var safe := DisplayServer.get_display_safe_area()
		var screen := DisplayServer.screen_get_size()
		if screen.x > 0:
			margin = maxf(margin, float(safe.position.x) * size.x / screen.x + 16)
			right_margin = maxf(right_margin, float(screen.x - safe.end.x) * size.x / screen.x + 16)
	controls[0].position = Vector2(margin + 10, size.y - 122)
	controls[1].position = Vector2(margin + 112, size.y - 122)
	controls[2].position = Vector2(size.x - right_margin - 188, size.y - 122)
	controls[3].position = Vector2(size.x - right_margin - 86, size.y - 172)
	status_panel.position.x = margin
	pause_button.offset_left = -right_margin - 56
	pause_button.offset_right = -right_margin
	progress.position.x = size.x / 2 - 120
	boss_label.position.x = size.x / 2 - 150
	boss_bar.position.x = size.x / 2 - 200

func _process(_delta: float) -> void:
	if not is_instance_valid(level) or not is_instance_valid(level.player): return
	var x: float = level.player.position.x
	progress.value = x / 15360.0 * 100
	var title := "01  /  TEPI HUTAN" if x < 4500 else "02  /  RERUNTUHAN AKAR"
	if x > 12500: title = "03  /  GERBANG KUNO"
	zone.text = title
	if x < 1050:
		objective.text = "Dekati altar untuk menyalakan bara dan menyimpan perjalanan."
	elif x < 2200:
		objective.text = "Tombol panah: gerak dan lompat. Tombol api: serangan bara." if OS.has_feature("android") else "A / D  Bergerak     SPACE  Lompat     J  Serangan bara"
	elif x > 13000 and not Session.boss_dead:
		objective.text = "Perhatikan cahaya tanah. Lompat menghindar, serang saat ia pulih."
	elif Session.boss_dead:
		objective.text = "Nyalakan ketiga altar, lalu masuki gerbang cahaya."
	else:
		objective.text = "Ikuti cahaya. Temukan altar berikutnya."
	var visible_boss: bool = is_instance_valid(level.boss) and level.boss.active
	boss_bar.visible = visible_boss
	boss_label.visible = visible_boss
	if visible_boss:
		boss_bar.value = float(level.boss.health) / level.boss.max_health * 100
