extends CanvasLayer

@onready var dialogue_container: Control = %DialogueContainer
@onready var dialogue_label: Label = %DialogueLabel
@onready var face_animation_player: AnimationPlayer = %FaceAnimationPlayer

@onready var mumble_timer: Timer = $MumbleTimer


var _current_dialogue: DialogueRes = null
var _char_overflow: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialogue_container.visible = false
	dialogue_label.visible_characters = 0
	set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_char_overflow += (_current_dialogue.characters_over_time * delta)
	var current_chars := floorf(_char_overflow)
	_char_overflow -= current_chars
	dialogue_label.visible_characters += (current_chars as int)
	if dialogue_label.visible_ratio >= 1.0:
		face_animation_player.play("FaceFinish")
		mumble_timer.stop()
		set_process(false)
		await get_tree().create_timer(_current_dialogue.stay_after_finish).timeout
		dialogue_container.visible = false


func display_dialogue(dialogue: DialogueRes) -> void:
	_current_dialogue = dialogue
	set_process(false)
	dialogue_label.visible_characters = 0
	face_animation_player.play("FaceIdle")
	dialogue_container.visible = true
	_char_overflow = 0.0
	await get_tree().create_timer(dialogue.wait_before_start).timeout
	face_animation_player.play("FaceTalk")
	mumble_timer.start()
	dialogue_label.text = dialogue.dialogue_text
	set_process(true)
