class_name CharacterMover extends Component

@export var move_speed: float = 5.0


@onready var parent: CharacterBody3D = get_parent()


static func core() -> ComponentCore:
	return ComponentCore.new(CharacterMover)


func move(input_dir: Vector2) -> void:
	var direction := parent.transform.basis * Vector3(input_dir.x, 0, input_dir.y)
	if direction:
		parent.velocity.x = direction.x * move_speed
		parent.velocity.z = direction.z * move_speed
	else:
		parent.velocity.x = move_toward(parent.velocity.x, 0, move_speed)
		parent.velocity.z = move_toward(parent.velocity.z, 0, move_speed)

## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
