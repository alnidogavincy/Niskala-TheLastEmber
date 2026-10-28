class_name Art
extends RefCounted

static func region(rect: Rect2) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = preload("res://assets/forest_atlas.png")
	texture.region = rect
	return texture

static func creature(kind: String) -> Texture2D:
	match kind:
		"root": return region(Rect2(770, 50, 440, 510))
		"wisp": return region(Rect2(30, 620, 540, 590))
		"boss": return region(Rect2(575, 580, 670, 665))
	return preload("res://assets/nara.png")

static func prop(portal: bool) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = preload("res://assets/props.png")
	texture.region = Rect2(520, 0, 1016, 1024) if portal else Rect2(0, 300, 520, 724)
	return texture

static func thin_bar(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(3)
	return style

static func panel(color: Color = Color("143638"), border: Color = Color("537571")) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style

static func text(value: String, size: int, color: Color = Color("e9eddb")) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label

static func button(value: String, callback: Callable) -> Button:
	var b := Button.new()
	b.text = value
	b.custom_minimum_size = Vector2(280, 54)
	b.add_theme_font_size_override("font_size", 20)
	b.add_theme_stylebox_override("normal", panel())
	b.add_theme_stylebox_override("hover", panel(Color("285653"), Color("e9ba73")))
	b.add_theme_stylebox_override("focus", panel(Color("285653"), Color("e9ba73")))
	b.add_theme_stylebox_override("pressed", panel(Color("41675c")))
	b.pressed.connect(callback)
	return b
