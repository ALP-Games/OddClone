class_name Level extends Node3D

# maybe okay to have won and lost signals?
signal level_end(won: bool)
#signal level_won
#signal level_lost

@export var elevator_travel_time: float = 7.0
@export var glitches: bool = true
@export var glitch_step: int = 5
@export_subgroup("Starting glitch period")
@export var starting_glitch_period_min: int = 20
@export var starting_glitch_period_max: int = 25
@export_subgroup("End glitch period")
@export var end_glitch_period_min: int = 2
@export var end_glitch_period_max: int = 4

@export var _level_intro_dialogue: DialogueRes = null

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
	if player == null:
		get_tree().root.child_entered_tree.connect(_look_for_player)
	else:
		_init_player(player)
	
	if _level_intro_dialogue:
		DialogueLayer.display_dialogue(_level_intro_dialogue)
	
	await get_tree().create_timer(0.5).timeout
	var elevator: Elevator = get_tree().get_first_node_in_group(Constants.ELEVATOR_GROUP)
	elevator.elevator_arrive()


func _look_for_player(node: Node) -> void:
	if node is Player:
		node.ready.connect(func()->void:_init_player(node), CONNECT_ONE_SHOT)
	get_tree().root.child_entered_tree.disconnect(_look_for_player)


func _init_player(player: Player) -> void:
	player.level_start_init()
	level_end.connect(player.on_level_end)


func _update_npc_glitch_ranged(npc: NPC) -> void:
	npc.normal_frames_min = max(starting_glitch_period_min - (glitch_step * _shown_glitches), end_glitch_period_min)
	npc.normal_frames_max = max(starting_glitch_period_max - (glitch_step * _shown_glitches), end_glitch_period_max)


func npc_shot(enemy: bool) -> void:
	if enemy:
		# TODO: if enemy -> tell to go to the elevator to finish
		# emit level_end in the elevator if victory
		var elevator: Elevator = get_tree().get_first_node_in_group(Constants.ELEVATOR_GROUP)
		var player: Player = get_tree().get_first_node_in_group(Constants.PLAYER_GROUP)
		player.disable_shoot = true
		elevator.disable_open_on_enter()
		elevator.open_elevator()
		if elevator.check_elevator().size() > 0:
			# TODO: display job well done text
			_on_level_beaten()
		else:
			# TODO: display job done and return to elevator
			elevator.elevator_user_entered.connect(func(_node)->void:_on_level_beaten(), CONNECT_ONE_SHOT)
	else:
		# if non enemy was shot emit level_end false
		# TODO: display level failed dialogue
		level_end.emit(enemy)


func _on_level_beaten() -> void:
	var elevator: Elevator = get_tree().get_first_node_in_group(Constants.ELEVATOR_GROUP)
	elevator.close_elevator()
	elevator.elevator_closed.connect(func()->void:
		elevator.elevator_work()
		await get_tree().create_timer(elevator_travel_time).timeout
		#elevator.elevator_arrive()
		#await get_tree().create_timer(2.0).timeout
		level_end.emit(true)
	, CONNECT_ONE_SHOT)
