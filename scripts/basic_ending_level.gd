extends Level


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var elevator: Elevator = get_tree().get_first_node_in_group(Constants.ELEVATOR_GROUP)
	elevator.reset()
	await get_tree().create_timer(0.5).timeout
	elevator.open_elevator()
