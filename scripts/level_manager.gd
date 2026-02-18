extends Node

@export var levels: Array[PackedScene] # maybe need resource for level instead of a scene
@export var player_scene: PackedScene
@export var elevator_scene: PackedScene
@export var await_time_after_objective := 1.0

var _current_level_id = 0

var _current_level: Level = null

var _player_instance: Player = null
var _elevator_instance: Elevator = null

var _level_restarting = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalUi.button_next_level.pressed.connect(_next_level)
	GlobalUi.button_restart.pressed.connect(_restart_level)
	_elevator_instance = elevator_scene.instantiate()
	get_tree().root.add_child.call_deferred(_elevator_instance)


func _enter_tree() -> void:
	get_tree().root.child_entered_tree.connect(func(node: Node):
		if node is Level:
			_current_level = node
			node.ready.connect(_level_init, CONNECT_ONE_SHOT))


func _level_init() -> void:
	GlobalUi.disable_level_end()
	_current_level.level_end.connect(_on_level_end)
	if _player_instance and get_tree().get_node_count_in_group(Constants.PLAYER_GROUP) > 1:
		_player_instance.queue_free()
	elif not get_tree().get_first_node_in_group(Constants.PLAYER_GROUP) or _level_restarting:
		var spawn_pos: Node3D = get_tree().get_first_node_in_group(Constants.P_SPAWNER_GROUP)
		_player_instance = player_scene.instantiate()
		get_tree().root.add_child.call_deferred(_player_instance)
		_player_instance.ready.connect(func()->void:
			_player_instance.global_position = spawn_pos.global_position,
			CONNECT_ONE_SHOT)
	_level_restarting = false


func _next_level() -> void:
	_current_level_id = wrapi(_current_level_id + 1, 0, levels.size())
	get_tree().change_scene_to_packed(levels[_current_level_id])


func _restart_level() -> void:
	_player_instance.queue_free()
	_elevator_instance.reset()
	get_tree().reload_current_scene.call_deferred()
	_level_restarting = true


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
	if _player_instance:
		_player_instance.on_level_end(false)
