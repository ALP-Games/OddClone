extends Level

@export var min_distance_far := 12.0
@export var max_distance_close := 7.0
@export var executioner_move_speed := 2.5

@onready var pov_transition: ColorRect = %PovTransition
@onready var pov_transition_material: ShaderMaterial = pov_transition.material
@onready var other_player: Node3D = %Player

@onready var executioner_animation: Sprite3D = %Executioner
@onready var ending_animation_player: AnimationPlayer = %EndingAnimationPlayer

@onready var other_pov_body: Node3D = %OtherPovBody
@onready var other_head: Node3D = %OtherHead
@onready var other_pov_camera: Camera3D = %OtherPovCamera


var player: Player
var process_funcs: Array[Callable]
var physics_process_funcs: Array[Callable]
#var physics_process_funcs

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pov_transition_material.set_shader_parameter("fade", 0.0)
	await get_tree().create_timer(0.5).timeout
	player = get_tree().get_first_node_in_group(Constants.PLAYER_GROUP)
	other_pov_body.global_rotation = player.global_rotation + (Vector3.UP * PI)
	other_head.rotation = player.head.rotation
	# TODO:
	# do we hijack control at some point?
	# we can try that a bit later for sure
	player.disable_shoot = true
	process_funcs.append(_fade_pov)
	process_funcs.append(_check_transition_pos_reached)
	var elevator: Elevator = get_tree().get_first_node_in_group(Constants.ELEVATOR_GROUP)
	await get_tree().create_timer(0.5).timeout
	elevator.disable_exit_block(true)
	elevator.open_elevator()
	elevator.enable_open_on_enter()


func _process(delta: float) -> void:
	# maybe this should be an array again?
	for process_func: Callable in process_funcs:
		process_func.call(delta)


func _physics_process(delta: float) -> void:
	for physics_process_func: Callable in physics_process_funcs:
		physics_process_func.call(delta)


func _check_transition_pos_reached(_delta: float) -> void:
	var distance := player.get_interpolated_pos().z - other_player.global_position.z
	if distance <= max_distance_close:
		# TODO: fix NPC rotation
		var npcs := get_tree().get_nodes_in_group(Constants.NPC_GROUP)
		for npc: NPC in npcs:
			npc._player = other_player
		# we can probably reparent the camera here already
		player.controls_disabled = true
		player.footstep_interval = 1.0
		process_funcs.erase(_check_transition_pos_reached)
		physics_process_funcs.append(_update_executioner_position)



func _update_executioner_position(delta: float) -> void:
	var diff := (executioner_animation.global_position - player.global_position) * Vector3(1.0, 0.0, 1.0)
	var distance := diff.length()
	if is_zero_approx(distance):
		player.velocity = Vector3.ZERO
		#get_viewport().get_camera_3d().current
		pov_transition.visible = false
		other_pov_camera.current = true
		var previous_rot := other_pov_body.global_rotation
		other_pov_body.get_parent().remove_child(other_pov_body)
		other_player.add_child(other_pov_body)
		other_pov_body.position = Vector3.ZERO
		other_pov_body.global_rotation = previous_rot
		
		physics_process_funcs.erase(_update_executioner_position)
		player.visible = false
		executioner_animation.visible = true
		ending_animation_player.play("level_animation")
		return
	var dir := diff.normalized()
	# distance - how much in total we need to move
	# distance to cover in a frame distance / delta
	var add_move: float = min(executioner_move_speed, distance / delta)
	player.velocity = dir * add_move


func _fade_pov(_delta: float) -> void:
	var distance := player.get_interpolated_pos().z - other_player.global_position.z
	#var distance := other_player.global_position.distance_to(player.get_interpolated_pos())
	var fade_progress: float = 1.0 - (min(min_distance_far, distance) - max_distance_close) / (min_distance_far - max_distance_close)
	pov_transition_material.set_shader_parameter("fade", lerp(0.0, 1.0, fade_progress))
