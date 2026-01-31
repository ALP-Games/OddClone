class_name Player extends CharacterBody3D

@export var head: Node3D
@export var raycast: RayCast3D
@export_range(0, 180, 0.001, "radians_as_degrees") var max_pitch_degrees: float = deg_to_rad(60)
@export var head_max_rotation_units: Vector2 = Vector2.ZERO


@export var move_speed: float = 5.0
@export var sensitivity: float = 0.003

@export_group("Shoot Sounds")
@export var shoot_sounds: Array[AudioStreamWAV]

@export_group("Footsteps")
@export var footstep_interval: float = 2.5
@export var footstep_sounds: Array[AudioStreamOggVorbis]

@onready var shoot_sound: AudioStreamPlayer = $ShootSound
@onready var gameplay_ui: Control = $CanvasLayer/GameplayUI
@onready var footstep_player: AudioStreamPlayer3D = $FootstepPlayer

@onready var AnimP: AnimationPlayer = $CanvasLayer/GameplayUI/AnimationPlayer

var controls_disabled := false
var rotation_accumulation := Vector2.ZERO
var _elapsed_footstep	: float = 0.0


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	raycast.enabled = false


func on_level_end(_won: bool) -> void:
	gameplay_ui.visible = false
	controls_disabled = true


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
	
	if not controls_disabled:
		_head_rotation()
		
		if Input.is_action_just_pressed("shoot"):
			var sound_index := randi_range(0, shoot_sounds.size() - 1)
			shoot_sound.stream = shoot_sounds[sound_index]
			shoot_sound.play()
			raycast.force_raycast_update()
			
			AnimP.play("Bang")
			var collider := raycast.get_collider()
			if collider:
				(collider as NPC).get_shot()
			
			#print("Shot - ", collider.name)

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
	else:
		velocity = Vector3.ZERO

	
	var xz_plane_velocity := velocity
	xz_plane_velocity -= xz_plane_velocity.project(Vector3.UP)
	_elapsed_footstep += xz_plane_velocity.length() * delta
	if _elapsed_footstep >= footstep_interval:
		_elapsed_footstep -= footstep_interval
		var footstep_sound_index := randi_range(0, footstep_sounds.size() - 1)
		footstep_player.stream = footstep_sounds[footstep_sound_index]
		footstep_player.play()
	
	move_and_slide()
