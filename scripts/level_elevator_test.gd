extends Level


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
	
	if player == null:
		get_tree().root.child_entered_tree.connect(_look_for_player)
	else:
		_init_player(player)
	
	var office: OfficeLayout = get_tree().get_first_node_in_group(Constants.OFFICE_GROUP)
	#office.elevator_arrive()
	
	await get_tree().create_timer(1.0).timeout
	#var extended_camera: ExtendedCamera = get_viewport().get_camera_3d()
	#extended_camera.set_shake(0.05)
	#extended_camera.enable_shake(0.01, 0.05)
	office.elevator_work()
	await get_tree().create_timer(5.0).timeout
	office.elevator_arrive()
	#extended_camera.enable_shake(0.05, 0.10)
	#extended_camera.disable_shake()
