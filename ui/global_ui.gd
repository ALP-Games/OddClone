extends CanvasLayer

@export var unpause_button: Button

@onready var level_end_prompt: Control = $LevelEndPrompt
@onready var black_rect: ColorRect = %BlackRect
@onready var seethrough_rect: TextureRect = %SeeThroughRect
@onready var level_won_text: Label = $LevelEndPrompt/LevelWonText
@onready var level_lost: Label = $LevelEndPrompt/LevelLost
@onready var button_next_level: Button = $LevelEndPrompt/ButtonNextLevel
@onready var button_restart: Button = $LevelEndPrompt/ButtonRestart

@onready var pause_menu: Control = $PauseMenu


func _ready() -> void:
	disable_level_end()
	black_rect.visible = false
	black_rect.modulate.a = 0.0
	pause_menu.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	unpause_button.pressed.connect(_toggle_pause_menu)
	LevelManager.level_loaded.connect(
		func(): get_tree().paused = false)
	#animation_player.play("TextAppear")
	


func enable_pause_menu() -> void:
	pause_menu.visible = true


func disable_level_end() -> void:
	level_end_prompt.visible = false
	for child: Control in level_end_prompt.get_children():
		child.visible = false


func enable_level_won() -> void:
	seethrough_rect.visible = true
	level_end_prompt.visible = true
	level_won_text.visible = true
	button_next_level.visible = true


const GENERAL_FAILURE_03 = preload("uid://dl3w1rkxnhc3q")


func enable_level_lost() -> void:
	level_end_prompt.visible = true
	# TODO:
	# Start fade to black here
	const FADE_IN_TIME := 1.0
	black_rect.visible = true
	black_rect.modulate.a = 0.0
	var fade_tween := create_tween()
	fade_tween.tween_property(black_rect, "modulate:a", 1.0, FADE_IN_TIME)
	await fade_tween.finished
	# after fade to black is finished
	# Display failure dialogue
	# This failure cannot be slow
	# If we making it slow, it can only be slow the first time
	# Second time around it has to be fast
	
	# This part is a little bit hacky
	# Maybe this should be enabled from the level manager (basically game manager side)
	# But right now it does not really matter
	DialogueLayer.display_dialogue(GENERAL_FAILURE_03)
	#var previous_layer
	DialogueLayer.layer = layer + 1
	DialogueLayer.mumbling_noises.process_mode = Node.PROCESS_MODE_ALWAYS
	await DialogueLayer.dialogue_spoken
	await get_tree().process_frame
	DialogueLayer.mumbling_noises.finished.connect(func():
		DialogueLayer.mumbling_noises.process_mode = Node.PROCESS_MODE_INHERIT
		, CONNECT_ONE_SHOT)
	
	level_lost.visible = true
	button_restart.visible = true
	
	pause_menu.visible = false
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _toggle_pause_menu() -> void:
	var enabling := not pause_menu.visible
	get_tree().paused = enabling
	pause_menu.visible = enabling
	if enabling:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(_delta: float) -> void:
	if level_end_prompt.visible:
		return
	if Input.is_action_just_pressed("pause"):
		_toggle_pause_menu()
