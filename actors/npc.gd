class_name NPC extends CharacterBody3D

@export var head: Sprite3D


var _is_clanker: bool = false


func convert_to_target() -> void:
	head.modulate = Color.RED
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
