@tool
class_name SpriteWithEffect extends Sprite3D

@export var animation_frame := frame:
	set(value):
		animation_frame = value
		frame = value
		if is_node_ready():
			_update_material_frame()
@export var animation_vframes := vframes:
	set(value):
		animation_vframes = value
		vframes = value
		if is_node_ready():
			_update_material_vframes()


@onready var _effect_material: ShaderMaterial = material_override


func _update_material_frame() -> void:
	print("Frame y coord - ", frame_coords.y)
	_effect_material.set_shader_parameter("y_offset", frame_coords.y)


func _update_material_vframes() -> void:
	_effect_material.set_shader_parameter("vframes", vframes)


func set_material_color(color: Color) -> void:
	_effect_material.set_shader_parameter("glow_color", color)


func set_dissolve(dissolve: float) -> void:
	_effect_material.set_shader_parameter("dissolve", dissolve)


func set_material_texture(texture: CompressedTexture2D) -> void:
	_effect_material.set_shader_parameter("albedo_texture", texture)


func _ready() -> void:
	if not Engine.is_editor_hint():
		material_override = material_override.duplicate(true)
		_effect_material = material_override
	_update_material_frame()
	_update_material_vframes()
