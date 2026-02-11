extends Node

@export var min_distance_far := 12.0
@export var max_distance_close := 7.0

@onready var pov_transition: ColorRect = %PovTransition
@onready var player: Node3D = %Player


var executioner: Player = null
var pov_transition_material: ShaderMaterial = null

var process_func: Callable = _query_for_player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pov_transition_material = pov_transition.material
	pov_transition_material.set_shader_parameter("fade", 0.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	process_func.call()


func _query_for_player() -> void:
	executioner = get_tree().get_first_node_in_group(Constants.PLAYER_GROUP)
	if executioner:
		process_func = _fade_pov


func _fade_pov() -> void:
	var distance := player.global_position.distance_to(executioner.get_interpolated_pos())
	var fade_progress: float = 1.0 - (min(min_distance_far, distance) - max_distance_close) / (min_distance_far - max_distance_close)
	pov_transition_material.set_shader_parameter("fade", lerp(0.0, 1.0, fade_progress))
