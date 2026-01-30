class_name Level extends Node

signal level_won
signal level_lost


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group(Constants.LEVEL_GROUP)
	var npcs := get_tree().get_nodes_in_group(Constants.NPC_GROUP)
	var bad_npc_index := randi_range(0, npcs.size() - 1)
	(npcs[bad_npc_index] as NPC).convert_to_target()


func npc_shot(enemy: bool) -> void:
	if enemy:
		level_won.emit()
	else:
		level_lost.emit()
