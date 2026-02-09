extends AudioStreamPlayer3D

@export var start_offset: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play(randf() * start_offset)
