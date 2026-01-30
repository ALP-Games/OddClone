extends Node

@export var levels: Array[PackedScene]

var _current_level_id = 0

var _current_level: Level = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _enter_tree() -> void:
	get_tree().root.child_entered_tree.connect(func(node: Node):
		if node is Level:
			_current_level = node
			node.ready.connect(_level_init, CONNECT_ONE_SHOT))


func _level_init() -> void:
	_current_level.level_won.connect(_level_won)
	_current_level.level_lost.connect(_level_lost)


func _on_level_end() -> void:
	#get_tree().unload_current_scene()
	# need to pause level or load some intermediate scene or something
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _level_won() -> void:
	_on_level_end()
	GloblUi.enable_level_won()


func _level_lost() -> void:
	_on_level_end()
	GloblUi.enable_level_lost()
