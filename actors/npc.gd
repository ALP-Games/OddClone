class_name NPC extends CharacterBody3D

@export var head: Sprite3D
@export var body: Sprite3D

@export var animation_cycle_speed := 0.5
@export var animation_cycle_offset_max := 0.4
@export_group("Body")
@export var normal_frame_first := 0
@export var normal_frame_last := 2
@export var bad_animation_frame := 3


@onready var body_frame_cycle: Timer = $BodyFrameCycle


var _is_clanker: bool = false


func _ready() -> void:
	_select_random_frame()
	var cycle_offset := randf_range(0.0, animation_cycle_offset_max)
	get_tree().create_timer(cycle_offset).timeout.connect(func():
		body_frame_cycle.start(animation_cycle_speed)
		body_frame_cycle.timeout.connect(_select_random_frame)
		)


func _select_random_frame() -> void:
	var max_index := normal_frame_last
	var frame_index := body.frame
	if _is_clanker:
		max_index += 1
	while frame_index == body.frame:
		frame_index = randi_range(normal_frame_first, max_index)
	if frame_index > normal_frame_last:
		body.frame = bad_animation_frame
	else:
		body.frame = frame_index
	#body.


func convert_to_target() -> void:
	#head.modulate = Color.RED
	_is_clanker = true


func get_shot() -> void:
	var level: Level = get_tree().get_first_node_in_group(Constants.LEVEL_GROUP)
	level.npc_shot(_is_clanker)
#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	#move_and_slide()


#func _physics_process(delta: float) -> void:
	#
	#if not is_on_floor():
		#velocity += get_gravity() * delta
	#
	#move_and_slide()
