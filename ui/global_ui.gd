extends CanvasLayer

@onready var level_end_prompt: Control = $LevelEndPrompt
@onready var black_rect: TextureRect = $LevelEndPrompt/BlackRect
@onready var level_won_text: Label = $LevelEndPrompt/LevelWonText
@onready var level_lost: Label = $LevelEndPrompt/LevelLost
@onready var button_next_level: Button = $LevelEndPrompt/ButtonNextLevel
@onready var button_restart: Button = $LevelEndPrompt/ButtonRestart


func _ready() -> void:
	disable_level_end()


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
