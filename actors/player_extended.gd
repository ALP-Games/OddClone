class_name PlayerExtended extends Player

@onready var executioner: Sprite3D = $Executioner
@onready var reset_after_step: Timer = $ResetAfterStep


func get_interpolated_pos() -> Vector3:
	return _interpolated_position


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	raycast.enabled = false
	shot_timer.one_shot = true
	reset_after_step.timeout.connect(func():executioner.frame = 2)


func level_start_init() -> void:
	AnimP.play("ready")
	gameplay_ui.disable_ui(false)
	controls_disabled = false
	disable_shoot = false


func on_npc_shot() -> void:
	disable_shoot = true
	#gameplay_ui.disable_ui(true)
	await get_tree().create_timer(1.5).timeout
	AnimP.play("holster")


func on_level_end(won: bool) -> void:
	if not won:
		controls_disabled = true
	#gameplay_ui.disable_ui(true)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_accumulation -= event.relative * sensitivity
		
#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		#rotation_accumulation -= event.relative * sensitivity


func _head_rotation() -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: 
		return
	if head_max_rotation_units.x > 0:
			# rotate the body
		body.rotate_y(clamp(rotation_accumulation.x, -head_max_rotation_units.x, head_max_rotation_units.x))
	else:
		body.rotate_y(rotation_accumulation.x)
	if head_max_rotation_units.y > 0:
		head.rotate_x(clamp(rotation_accumulation.y, -head_max_rotation_units.y, head_max_rotation_units.y))
	else:
		head.rotate_x(rotation_accumulation.y)
		head.rotation.x = clamp(head.rotation.x, -max_pitch_degrees, max_pitch_degrees)
	rotation_accumulation = Vector2.ZERO


func _process_shoot() -> void:
	if not Input.is_action_just_pressed("shoot"):
		return
	elif Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:  # capture for web on click
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		return
	elif is_zero_approx(shot_timer.time_left):
		var sound_index := randi_range(0, shoot_sounds.size() - 1)
		shoot_sound.stream = shoot_sounds[sound_index]
		shoot_sound.play()
		raycast.force_raycast_update()
		shot_timer.start(shot_delay)
		
		AnimP.play("Bang")
		var collider := raycast.get_collider()
		if collider is NPC:
			on_npc_shot()
			(collider as NPC).get_shot()


func _process(_delta: float) -> void:
	_interpolated_position = get_global_transform_interpolated().origin


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if not controls_disabled:
		if reset_after_step.is_stopped():
			reset_after_step.start()
		_process_controls()
	
	_process_footstep(delta)
	
	move_and_slide()


func _process_footstep(delta: float) -> void:
	var play_footstep := false
	if executioner.frame == 2 and reset_after_step.is_stopped():
		_elapsed_footstep = 0.0
		play_footstep = true
	else:
		# TODO: implement character step frames
		var xz_plane_velocity := velocity
		xz_plane_velocity -= xz_plane_velocity.project(Vector3.UP)
		_elapsed_footstep += xz_plane_velocity.length() * delta
		if _elapsed_footstep >= footstep_interval:
			_elapsed_footstep -= footstep_interval
			play_footstep = true
	
	if play_footstep:
		match executioner.frame:
			0:
				executioner.frame = 1
			1:
				executioner.frame = 2
			2:
				executioner.frame = 0
		
		var current_footstep_sound := footstep_player.stream
		while current_footstep_sound == footstep_player.stream:
			var footstep_sound_index := randi_range(0, footstep_sounds.size() - 1)
			current_footstep_sound = footstep_sounds[footstep_sound_index]
		footstep_player.stream = current_footstep_sound
		footstep_player.play()


func _process_controls() -> void:
	_head_rotation()
	if no_movement:
		return
	
	if not disable_shoot:
		_process_shoot()
		
		#print("Shot - ", collider.name)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		reset_after_step.stop()
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)
