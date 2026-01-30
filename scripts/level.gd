class_name Level extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var npcs := get_tree().get_nodes_in_group(Constants.NPC_GROUP)
	var bad_npc_index := randi_range(0, npcs.size() - 1)
	(npcs[bad_npc_index] as NPC).convert_to_target()
