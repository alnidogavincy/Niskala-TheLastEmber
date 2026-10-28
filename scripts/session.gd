extends Node

signal changed
var checkpoint := Vector2(220, 510)
var lit: Array[int] = []
var won := false
var boss_dead := false
var has_save := false
var music_volume := 0.6
var effects_volume := 0.8
const SAVE := "user://niskala_v1.json"

func _ready() -> void:
	var bindings := {"left": [KEY_A, KEY_LEFT], "right": [KEY_D, KEY_RIGHT], "jump": [KEY_SPACE], "attack": [KEY_J], "pause": [KEY_ESCAPE]}
	for action in bindings:
		InputMap.add_action(action)
		for key in bindings[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)
	load_save()

func new_game() -> void:
	checkpoint = Vector2(220, 510)
	lit.clear()
	won = false
	boss_dead = false
	has_save = true
	save_game()

func light_altar(id: int, pos: Vector2) -> void:
	if id in lit:
		return
	lit.append(id)
	checkpoint = pos
	save_game()
	changed.emit()

func save_game() -> void:
	var f := FileAccess.open(SAVE, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"version": 1, "checkpoint": [checkpoint.x, checkpoint.y], "lit": lit, "won": won, "boss_dead": boss_dead, "has_save": has_save, "music": music_volume, "effects": effects_volume}))

func load_save() -> void:
	if not FileAccess.file_exists(SAVE):
		return
	var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
	if not data is Dictionary or data.get("version") != 1:
		return
	var cp = data.get("checkpoint", [220, 510])
	if cp is Array and cp.size() == 2 and cp[0] is float and cp[1] is float:
		checkpoint = Vector2(clampf(cp[0], 100, 14900), clampf(cp[1], 100, 640))
	lit.clear()
	for id in data.get("lit", []):
		if int(id) in [0, 1, 2] and not int(id) in lit:
			lit.append(int(id))
	won = bool(data.get("won", false))
	boss_dead = bool(data.get("boss_dead", false))
	has_save = bool(data.get("has_save", false))
	music_volume = clampf(float(data.get("music", 0.6)), 0, 1)
	effects_volume = clampf(float(data.get("effects", 0.8)), 0, 1)

func release_inputs() -> void:
	for action in ["left", "right", "jump", "attack"]:
		Input.action_release(action)
