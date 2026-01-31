class_name OfficeLayout extends Node3D


@onready var animation_player: AnimationPlayer = $office_layout/Lift/AnimationPlayer
@onready var elevator_jingle: AudioStreamPlayer3D = $ElevatorJingle
@onready var elevator_door_open: AudioStreamPlayer3D = $ElevatorDoorOpen


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.2).timeout
	elevator_jingle.play()
	await get_tree().create_timer(0.5).timeout
	elevator_door_open.play()
	animation_player.play("lift_door")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
