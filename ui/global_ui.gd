extends CanvasLayer

@export var unpause_button: Button

@onready var level_end_prompt: Control = $LevelEndPrompt
@onready var black_rect: TextureRect = $LevelEndPrompt/BlackRect
@onready var level_won_text: Label = $LevelEndPrompt/LevelWonText
@onready var level_lost: Label = $LevelEndPrompt/LevelLost
@onready var button_next_level: Button = $LevelEndPrompt/ButtonNextLevel
@onready var button_restart: Button = $LevelEndPrompt/ButtonRestart

@onready var pause_menu: Control = $PauseMenu


func _ready() -> void:
	disable_level_end()
	pause_menu.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	unpause_button.pressed.connect(_toggle_pause_menu)


func enable_pause_menu() -> void:
	pause_menu.visible = true


func disable_level_end() -> void:
	level_end_prompt.visible = false
	for child: Control in level_end_prompt.get_children():
		child.visible = false


func enable_level_won() -> void:
	black_rect.visible = true
	level_end_prompt.visible = true
	level_won_text.visible = true
	button_next_level.visible = true


func enable_level_lost() -> void:
	black_rect.visible = true
	level_end_prompt.visible = true
	level_lost.visible = true
	button_restart.visible = true


func _toggle_pause_menu() -> void:
	var enabling := not pause_menu.visible
	get_tree().paused = enabling
	pause_menu.visible = enabling
	if enabling:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		_toggle_pause_menu()
