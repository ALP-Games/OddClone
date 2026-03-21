extends CanvasLayer

const MUMBLE_PER_CHARACTERS = 8
const MUMBLE_CONSTANT = 60 / MUMBLE_PER_CHARACTERS

signal dialogue_spoken
signal transition_ended

@onready var dialogue_container: Control = %DialogueContainer
@onready var dialogue_label: Label = %DialogueLabel
@onready var face_animation_player: AnimationPlayer = %FaceAnimationPlayer

@onready var mumbling_noises: AudioStreamPlayer = %MumblingNoises
@onready var mumble_timer := Timer.new()
@onready var after_finish := Timer.new()

@onready var dialogue_middle: Control = %DialogueMiddle
@onready var dialogue_bottom: Control = %DialogueBottom


@onready var _starting_layer := layer

enum TransState {
	NONE,
	FADE_IN,
	FADE_OUT
}

enum Position {
	MIDDLE,
	BOTTOM
}

var _trans_state := TransState.NONE:
	set(value):
		if value == TransState.NONE and value != _trans_state:
			transition_ended.emit()
		_trans_state = value

var _current_dialogue: DialogueRes = null
var _char_overflow: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(after_finish)
	add_child(mumble_timer)
	mumble_timer.wait_time = 0.15
	mumble_timer.timeout.connect(mumbling_noises.play)
	dialogue_container.visible = false
	dialogue_label.visible_characters = 0
	set_process(false)
	process_mode = Node.PROCESS_MODE_PAUSABLE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dialogue_label.visible_ratio >= 1.0:
		_on_dialogue_spoken()
		after_finish.start(_current_dialogue.stay_after_finish)
		after_finish.timeout.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)
		return
	_char_overflow += (_current_dialogue.characters_over_time * delta)
	var current_chars := floorf(_char_overflow)
	_char_overflow -= current_chars
	dialogue_label.visible_characters += (current_chars as int)


func dialogue_in_progress() -> bool:
	return dialogue_container.visible and dialogue_label.visible_ratio < 1.0


func finish_dialogue() -> void:
	dialogue_label.visible_ratio = 1.0


func interrupt_dialogue() -> void:
	_on_dialogue_spoken()
	after_finish.start(1.0)
	if not after_finish.timeout.is_connected(_on_dialogue_finished):
		after_finish.timeout.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)


func kill_dialogue() -> void:
	_on_dialogue_spoken()
	dialogue_container.visible = false
	set_process(false)


func _on_dialogue_spoken() -> void:
	face_animation_player.play("FaceFinish")
	mumble_timer.stop()
	set_process(false)
	dialogue_spoken.emit()


func _on_dialogue_finished() -> void:
	_trans_state = TransState.FADE_OUT
	const FADE_OUT_TIME = 0.1
	var fade_out_tween := create_tween()
	fade_out_tween.tween_property(dialogue_container, "modulate:a", 0.0, FADE_OUT_TIME).set_ease(Tween.EASE_OUT)
	fade_out_tween.tween_callback(func()->void:
		_trans_state = TransState.NONE
		dialogue_container.visible = false
		)


func display_dialogue(dialogue: DialogueRes, position: Position = Position.BOTTOM) -> void:
	if _trans_state != TransState.NONE:
		transition_ended.connect(func()->void:
			display_dialogue(dialogue)
			,CONNECT_ONE_SHOT)
		return
	layer = _starting_layer
	if after_finish.timeout.is_connected(_on_dialogue_finished):
		after_finish.timeout.disconnect(_on_dialogue_finished)
		
	dialogue_container.get_parent().remove_child(dialogue_container)
	match position:
		Position.MIDDLE:
			dialogue_middle.add_child(dialogue_container)
		Position.BOTTOM:
			dialogue_bottom.add_child(dialogue_container)
	
	_current_dialogue = dialogue
	set_process(false)
	dialogue_label.visible_characters = 0
	face_animation_player.play("FaceIdle")
	dialogue_container.modulate.a = 1.0
	dialogue_container.visible = true
	_char_overflow = 0.0
	await get_tree().create_timer(dialogue.wait_before_start).timeout
	face_animation_player.play("FaceTalk") # speed for this could be set
	mumble_timer.wait_time = (60 / dialogue.characters_over_time) / MUMBLE_CONSTANT
	mumble_timer.start()
	dialogue_label.text = dialogue.dialogue_text
	set_process(true)
