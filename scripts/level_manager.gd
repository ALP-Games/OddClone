extends Node

@export var levels: Array[PackedScene] # maybe need resource for level instead of a scene
@export var player_scene: PackedScene
@export var await_time_after_objective := 1.0

var _current_level_id = 0

var _current_level: Level = null

var _player_instance: Player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalUi.button_next_level.pressed.connect(_next_level)
	GlobalUi.button_restart.pressed.connect(_restart_level)
	pass


func _enter_tree() -> void:
	get_tree().root.child_entered_tree.connect(func(node: Node):
		if node is Level:
			_current_level = node
			node.ready.connect(_level_init, CONNECT_ONE_SHOT))


func _level_init() -> void:
	GlobalUi.disable_level_end()
	_current_level.level_end.connect(_on_level_end)
	if _player_instance and get_tree().get_nodes_in_group(Constants.PLAYER_GROUP).size() > 1:
		_player_instance.queue_free()
	if not get_tree().get_first_node_in_group(Constants.PLAYER_GROUP):
		var spawn_pos: Node3D = get_tree().get_first_node_in_group(Constants.P_SPAWNER_GROUP)
		_player_instance = player_scene.instantiate()
		get_tree().root.add_child.call_deferred(_player_instance)
		_player_instance.ready.connect(func()->void:
			_player_instance.global_position = spawn_pos.global_position,
			CONNECT_ONE_SHOT)


func _next_level() -> void:
	_current_level_id = wrapi(_current_level_id + 1, 0, levels.size())
	get_tree().change_scene_to_packed(levels[_current_level_id])


func _restart_level() -> void:
	get_tree().reload_current_scene()


func _on_level_end(won: bool) -> void:
	if won:
		_level_won()
	else:
		await get_tree().create_timer(await_time_after_objective).timeout
		_level_lost()


func _level_won() -> void:
	#GlobalUi.enable_level_won()
	_next_level()


func _level_lost() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GlobalUi.enable_level_lost()
