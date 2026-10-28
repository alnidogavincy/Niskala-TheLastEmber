extends Node
var music_player: AudioStreamPlayer
var ambience: AudioStreamPlayer
var current := ""
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	ambience = AudioStreamPlayer.new()
	ambience.stream = load("res://assets/audio/ambience.wav")
	add_child(ambience)
	ambience.play()
	apply_volume()
func music(track: String) -> void:
	if current == track: return
	current = track
	music_player.stream = load("res://assets/audio/" + track + ".wav")
	music_player.play()
	apply_volume()
func apply_volume() -> void:
	if not is_instance_valid(music_player): return
	music_player.volume_db = linear_to_db(maxf(0.0001, Session.music_volume * 0.55))
	ambience.volume_db = linear_to_db(maxf(0.0001, Session.effects_volume * 0.25))
func effect(kind: String) -> void:
	var voice := AudioStreamPlayer.new()
	voice.stream = load("res://assets/audio/" + kind + ".wav")
	voice.volume_db = linear_to_db(maxf(0.0001, Session.effects_volume * 0.5))
	add_child(voice)
	voice.finished.connect(voice.queue_free)
	voice.play()

func shutdown() -> void:
	for child in get_children():
		if child is AudioStreamPlayer:
			child.stop()
			child.stream = null
