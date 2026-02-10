class_name GameplayUI extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var croshair: Label = $Croshair


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("shoot")


func disable_ui(disable: bool) -> void:
	croshair.visible = not disable
