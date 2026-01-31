class_name OfficeLayout extends Node3D


@onready var animation_player: AnimationPlayer = $office_layout/Lift/AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODO: play some kind of lift arrive sound
	await get_tree().create_timer(0.5).timeout
	# TODO: elevator doors open
	animation_player.play("lift_door")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
