class_name OfficeLayout extends Node3D


@onready var animation_player: AnimationPlayer = $office_layout/Lift/AnimationPlayer
@onready var elevator_jingle: AudioStreamPlayer3D = $ElevatorJingle
@onready var elevator_door_open: AudioStreamPlayer3D = $ElevatorDoorOpen

@export var arrival_delay: float = 0.2
@export var delay_after_jingle: float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(arrival_delay).timeout
	elevator_jingle.play()
	await get_tree().create_timer(delay_after_jingle).timeout
	elevator_door_open.play()
	animation_player.play("lift_door")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
