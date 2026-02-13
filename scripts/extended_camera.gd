class_name ExtendedCamera extends Camera3D


var process_functions: Array[Callable]

var _shake_decay := 0.05
var _current_shake_amount := 0.0

var _shake_amount := 0.0


func enable_shake(intensisty: float, shake_decay: float) -> void:
	_shake_amount = intensisty
	_shake_decay = shake_decay
	_current_shake_amount = _shake_amount
	if process_functions.count(_add_shake) < 1:
		process_functions.append(_add_shake)
	if process_functions.count(_process_camera_shake) < 1: 
		process_functions.append(_process_camera_shake)


func disable_shake() -> void:
	_shake_amount = 0.0
	process_functions.erase(_add_shake)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	for function: Callable in process_functions:
		function.call(delta)


func _process_camera_shake(delta: float) -> void:
	if _current_shake_amount > 0.0:
		_current_shake_amount = max(_current_shake_amount - _shake_decay * delta, 0.0)
		
		var offset := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * _current_shake_amount
		var camera := get_viewport().get_camera_3d()
		camera.position.x = offset.x
		camera.position.y = offset.y
	else:
		var camera := get_viewport().get_camera_3d()
		camera.position = Vector3.ZERO
		process_functions.erase(_process_camera_shake)


func _add_shake(_delta: float) -> void:
	_current_shake_amount = _shake_amount


#func _physics_process(delta: float) -> void:
	#shake(0.3)


#func shake(intensity: float) -> void:
	#shake_amount = max(shake_amount, intensity)
