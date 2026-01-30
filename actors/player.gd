extends CharacterBody3D

@export var head: Node3D
@export_range(0, 180, 0.001, "radians_as_degrees") var max_pitch_degrees: float = deg_to_rad(60)
@export var head_max_rotation_units: Vector2 = Vector2.ZERO

@export var move_speed = 5.0
@export var sensitivity: float = 0.003

var rotation_accumulation := Vector2.ZERO


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_accumulation -= event.relative * sensitivity


func _head_rotation() -> void:
	if head_max_rotation_units.x > 0:
			# rotate the body
		rotate_y(clamp(rotation_accumulation.x, -head_max_rotation_units.x, head_max_rotation_units.x))
	else:
		rotate_y(rotation_accumulation.x)
	if head_max_rotation_units.y > 0:
		head.rotate_x(clamp(rotation_accumulation.y, -head_max_rotation_units.y, head_max_rotation_units.y))
	else:
		head.rotate_x(rotation_accumulation.y)
		head.rotation.x = clamp(head.rotation.x, -max_pitch_degrees, max_pitch_degrees)
	rotation_accumulation = Vector2.ZERO


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	_head_rotation()
	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

	move_and_slide()
