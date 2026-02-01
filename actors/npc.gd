class_name NPC extends CharacterBody3D

@export var face: SpriteWithEffect
@export var head: SpriteWithEffect
@export var body: SpriteWithEffect

@export var good_color: Color = Color("a3d29d")
@export var clanker_color: Color = Color(0.937, 0.0, 0.0, 1.0)

@export var animation_cycle_speed := 0.5
@export var animation_cycle_offset_max := 0.4
@export var disintegrate_time := 0.5
@export_group("Body")
@export var normal_frame_first := 0
@export var normal_frame_last := 2
@export var bad_animation_frame := 3


@onready var body_frame_cycle: Timer = $BodyFrameCycle
@onready var disintegrate_timer: Timer = $DisintegrateTimer


var _is_clanker: bool = false


func _ready() -> void:
	_select_random_frame()
	var cycle_offset := randf_range(0.0, animation_cycle_offset_max)
	get_tree().create_timer(cycle_offset).timeout.connect(func():
		body_frame_cycle.start(animation_cycle_speed)
		body_frame_cycle.timeout.connect(_select_random_frame)
		)
	disintegrate_timer.one_shot = true
	set_process(false)


func _select_random_frame() -> void:
	var max_index := normal_frame_last
	var frame_index := body.animation_frame
	if _is_clanker:
		max_index += 1
	while frame_index == body.animation_frame:
		frame_index = randi_range(normal_frame_first, max_index)
	if frame_index > normal_frame_last:
		body.animation_frame = bad_animation_frame
	else:
		body.animation_frame = frame_index
	#body.


func convert_to_target() -> void:
	#head.modulate = Color.RED
	_is_clanker = true


func get_shot() -> void:
	var level: Level = get_tree().get_first_node_in_group(Constants.LEVEL_GROUP)
	level.npc_shot(_is_clanker)
	disintegrate_timer.start(disintegrate_time)
	
	var disintegrate_color := good_color
	if _is_clanker:
		disintegrate_color = clanker_color
	face.set_material_color(disintegrate_color)
	body.set_material_color(disintegrate_color)
	head.set_material_color(disintegrate_color)
	set_process(true)
#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	#move_and_slide()

func _process(_delta: float) -> void:
	var dissolve := disintegrate_timer.time_left / disintegrate_time
	face.set_dissolve(dissolve)
	body.set_dissolve(dissolve)
	head.set_dissolve(dissolve)

#func _physics_process(delta: float) -> void:
	#
	#if not is_on_floor():
		#velocity += get_gravity() * delta
	#
	#move_and_slide()
