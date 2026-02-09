class_name Level extends Node3D

# maybe okay to have won and lost signals?
signal level_end(won: bool)
#signal level_won
#signal level_lost

@export var glitches: bool = true
@export var glitch_step: int = 5
@export_subgroup("Starting glitch period")
@export var starting_glitch_period_min: int = 20
@export var starting_glitch_period_max: int = 25
@export_subgroup("End glitch period")
@export var end_glitch_period_min: int = 2
@export var end_glitch_period_max: int = 4


var _shown_glitches: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group(Constants.LEVEL_GROUP)
	if glitches:
		var npcs := get_tree().get_nodes_in_group(Constants.NPC_GROUP)
		var bad_npc_index := randi_range(0, npcs.size() - 1)
		var bad_npc: NPC = npcs[bad_npc_index]
		_update_npc_glitch_ranged(bad_npc)
		bad_npc.glitch_shown.connect(func() -> void:
			_shown_glitches += 1
			_update_npc_glitch_ranged(bad_npc)
			)
		bad_npc.convert_to_target()
		for npc_index in npcs.size():
			(npcs[npc_index] as NPC).got_shot.connect(npc_shot.bind(npc_index == bad_npc_index))
	
	var player: Player = get_tree().get_first_node_in_group(Constants.PLAYER_GROUP)
	level_end.connect(player.on_level_end)


func _update_npc_glitch_ranged(npc: NPC) -> void:
	npc.normal_frames_min = max(starting_glitch_period_min - (glitch_step * _shown_glitches), end_glitch_period_min)
	npc.normal_frames_max = max(starting_glitch_period_max - (glitch_step * _shown_glitches), end_glitch_period_max)


func npc_shot(enemy: bool) -> void:
	# TODO: if enemy -> tell to go to the elevator to finish
	# emit level_end in the elevator if victory
	# if non enemy was shot emit level_end false
	level_end.emit(enemy)
	#if enemy:
		#level_won.emit()
	#else:
		#level_lost.emit()
