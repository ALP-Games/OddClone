extends Level

@export var min_distance_far := 12.0
@export var max_distance_close := 7.0

@onready var pov_transition: ColorRect = %PovTransition
@onready var pov_transition_material: ShaderMaterial = pov_transition.material
@onready var other_player: Node3D = %Player

var executioner: Player
var process_funcs: Array[Callable]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pov_transition_material.set_shader_parameter("fade", 0.0)
	await get_tree().create_timer(0.5).timeout
	executioner = get_tree().get_first_node_in_group(Constants.PLAYER_GROUP)
	executioner.disable_shoot = true
	process_funcs.append(_fade_pov)
	var elevator: Elevator = get_tree().get_first_node_in_group(Constants.ELEVATOR_GROUP)
	elevator.reset()
	await get_tree().create_timer(0.5).timeout
	elevator.open_elevator()


# TODO: track player y distance to target -> enable function to make character walk to cutsene start pos
# Start cutsene when start position reached

# TODO: shader fade can work based on y distance, check this


func _process(_delta: float) -> void:
	# maybe this should be an array again?
	for process_func: Callable in process_funcs:
		process_func.call()


func _check_transition_pos_reached() -> void:
	var distance := other_player.global_position.z - executioner.get_interpolated_pos().z
	if distance <= max_distance_close:
		# TODO: change state
		pass


func _fade_pov() -> void:
	var distance := executioner.get_interpolated_pos().z - other_player.global_position.z
	#var distance := other_player.global_position.distance_to(executioner.get_interpolated_pos())
	var fade_progress: float = 1.0 - (min(min_distance_far, distance) - max_distance_close) / (min_distance_far - max_distance_close)
	pov_transition_material.set_shader_parameter("fade", lerp(0.0, 1.0, fade_progress))
