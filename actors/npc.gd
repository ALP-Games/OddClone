class_name NPC extends CharacterBody3D

signal got_shot
signal glitch_shown

@export var face: SpriteWithEffect
@export var head: SpriteWithEffect
@export var body: SpriteWithEffect


@export var good_color: Color = Color("a3d29d")
@export var clanker_color: Color = Color(0.937, 0.0, 0.0, 1.0)

@export_range(0.0, 1.0, 0.01) var face_glitch_chance := 0.5
@export var normal_frames_min: int = 5
@export var normal_frames_max: int = 13
@export var animation_cycle_speed := 0.5
@export var animation_cycle_offset_max := 0.4
@export var disintegrate_time := 0.5
@export_group("Faces")
@export var normal_face_frame_count := 4
@export var glitched_face_frame_count := 5
@export var normal_face: CompressedTexture2D
@export var glitched_face: CompressedTexture2D
@export_group("Body")
@export var normal_body_frame_count := 2
@export var glitched_body_frame_count := 2
@export var normal_body: CompressedTexture2D
@export var glitched_body: CompressedTexture2D


@onready var body_frame_cycle: Timer = $BodyFrameCycle
#@onready var face_frame_cycle: Timer = $FaceFrameCycle
@onready var disintegrate_timer: Timer = $DisintegrateTimer


var _is_clanker: bool = false
var _glitch_period: int = 0
var _normal_frames_elapsed: int = 0 

var _player: Player
var _process_functions: Array[Callable]


func _ready() -> void:
	_select_random_frame()
	var cycle_offset := randf_range(0.0, animation_cycle_offset_max)
	get_tree().create_timer(cycle_offset).timeout.connect(func():
		body_frame_cycle.start(animation_cycle_speed)
		body_frame_cycle.timeout.connect(_select_random_frame)
		)
	disintegrate_timer.one_shot = true
	_process_functions.append(_query_for_player)
	#set_process(false)


func _select_random_frame() -> void:
	if _is_clanker and _normal_frames_elapsed >= _glitch_period:
		var face_frame_count := normal_face_frame_count
		var body_frame_count := normal_body_frame_count
		if glitched_face and randf() > face_glitch_chance:
			face.set_material_texture(glitched_face)
			face_frame_count = glitched_face_frame_count
		else:
			body.set_material_texture(glitched_body)
			body_frame_count = glitched_body_frame_count
		_sprite_select_random_frame(face, face_frame_count)
		_sprite_select_random_frame(body, body_frame_count)
		_normal_frames_elapsed = 0
		glitch_shown.emit()
		_roll_new_glitch_period()
		return
	elif _is_clanker:
		face.set_material_texture(normal_face)
		body.set_material_texture(normal_body)
	_sprite_select_random_frame(face, normal_face_frame_count)
	_sprite_select_random_frame(body, normal_body_frame_count)
	_normal_frames_elapsed += 1


func _roll_new_glitch_period() -> void:
	_glitch_period = randi_range(normal_frames_min, normal_frames_max)


func _sprite_select_random_frame(sprite: SpriteWithEffect, max_frame_index: int) -> void:
	var frame_index := sprite.animation_frame
	while frame_index == sprite.animation_frame:
		frame_index = randi_range(0, max_frame_index)
	sprite.animation_frame = frame_index


func convert_to_target() -> void:
	#head.modulate = Color.RED
	_is_clanker = true
	_roll_new_glitch_period()


func get_shot() -> void:
	got_shot.emit()
	disintegrate_timer.start(disintegrate_time)
	
	var disintegrate_color := good_color
	if _is_clanker:
		disintegrate_color = clanker_color
	face.set_material_color(disintegrate_color)
	body.set_material_color(disintegrate_color)
	head.set_material_color(disintegrate_color)
	#set_process(true)
	_process_functions.append(func(_delta:float)->void:
		var dissolve := disintegrate_timer.time_left / disintegrate_time
		face.set_dissolve(dissolve)
		body.set_dissolve(dissolve)
		head.set_dissolve(dissolve)
		)
#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	#move_and_slide()


func _query_for_player(_delta: float) -> void:
	var result := get_tree().get_first_node_in_group(Constants.PLAYER_GROUP)
	if result == null:
		return
	_player = result
	_process_functions.erase(_query_for_player)
	_process_functions.append(_face_player)


func _face_player(_delta: float) -> void:
	var look_pos := _player.get_interpolated_pos()
	look_pos.y = global_position.y
	look_at(look_pos)


func _process(delta: float) -> void:
	for function: Callable in _process_functions:
		function.call(delta)
	

#func _physics_process(delta: float) -> void:
	#
	#if not is_on_floor():
		#velocity += get_gravity() * delta
	#
	#move_and_slide()
