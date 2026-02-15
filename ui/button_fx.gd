class_name ButtonFx extends Button

const CLICK_SOUND_PLAYER := preload("uid://c22k3qngnrhet")
const HOVER_SOUND_PLAYER = preload("uid://cygit0p25c757")

var click_sound_scene := CLICK_SOUND_PLAYER
var hover_sound_scene := HOVER_SOUND_PLAYER 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_down.connect(func():_play_sound(click_sound_scene, 0.3))
	mouse_entered.connect(_on_hover)




func _on_hover() -> void:
	if disabled:
		return
	_play_sound(hover_sound_scene)


func _play_sound(sound_scene: PackedScene, time_offset: float = 0.0) -> void:
	var audio_player_instance = sound_scene.instantiate() as AudioStreamPlayer
	get_tree().root.add_child(audio_player_instance)
	audio_player_instance.play(time_offset)
	audio_player_instance.finished.connect(func():audio_player_instance.queue_free(), CONNECT_ONE_SHOT)
