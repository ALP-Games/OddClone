## Base of a Component module.
## Used to create Nodes that expand parent node functionality.
class_name Component
extends Node


static func core() -> ComponentCore:
	assert(false, "core function must be overriden by component!")
	return null


func _enter_tree() -> void:
	get_parent().set_meta(core().name(), self)


func _exit_tree() -> void:
	get_parent().remove_meta(core().name())
