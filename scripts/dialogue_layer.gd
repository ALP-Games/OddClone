extends CanvasLayer

@onready var dialogue_container: Control = %DialogueContainer
@onready var dialogue_label: Label = %DialogueLabel
@onready var face_animation_player: AnimationPlayer = %FaceAnimationPlayer

@onready var mumble_timer: Timer = $MumbleTimer
@onready var after_finish: Timer = $AfterFinish


var _current_dialogue: DialogueRes = null
var _char_overflow: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialogue_container.visible = false
	dialogue_label.visible_characters = 0
	set_process(false)
	process_mode = Node.PROCESS_MODE_PAUSABLE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dialogue_label.visible_ratio >= 1.0:
		face_animation_player.play("FaceFinish")
		mumble_timer.stop()
		set_process(false)
		after_finish.start(_current_dialogue.stay_after_finish)
		after_finish.timeout.connect(on_dialogue_finished, CONNECT_ONE_SHOT)
		return
	_char_overflow += (_current_dialogue.characters_over_time * delta)
	var current_chars := floorf(_char_overflow)
	_char_overflow -= current_chars
	dialogue_label.visible_characters += (current_chars as int)


func dialogue_in_progress() -> bool:
	return dialogue_container.visible and dialogue_label.visible_ratio < 1.0


func finish_dialogue() -> void:
	dialogue_label.visible_ratio = 1.0


func on_dialogue_finished() -> void:
	dialogue_container.visible = false


func display_dialogue(dialogue: DialogueRes) -> void:
	if after_finish.timeout.is_connected(on_dialogue_finished):
		after_finish.timeout.disconnect(on_dialogue_finished)
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
	print("Process set to true")
	set_process(true)
