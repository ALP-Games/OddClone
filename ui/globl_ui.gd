extends CanvasLayer

@onready var level_end_prompt: Control = $LevelEndPrompt
@onready var level_won_text: Label = $LevelEndPrompt/LevelWonText
@onready var level_lost: Label = $LevelEndPrompt/LevelLost


func disable_level_end() -> void:
	level_end_prompt.visible = false


func enable_level_won() -> void:
	level_end_prompt.visible = true
	level_won_text.visible = true
	level_lost.visible = false


func enable_level_lost() -> void:
	level_end_prompt.visible = true
	level_won_text.visible = false
	level_lost.visible = true
