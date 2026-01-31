extends Node

@export var levels: Array[PackedScene]

var _current_level_id = 0

var _current_level: Level = null

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


func _next_level() -> void:
	_current_level_id = wrapi(_current_level_id + 1, 0, levels.size())
	get_tree().change_scene_to_packed(levels[_current_level_id])


func _restart_level() -> void:
	get_tree().reload_current_scene()


func _on_level_end(won: bool) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if won:
		_level_won()
	else:
		_level_lost()


func _level_won() -> void:
	GlobalUi.enable_level_won()


func _level_lost() -> void:
	GlobalUi.enable_level_lost()
