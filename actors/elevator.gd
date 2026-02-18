class_name Elevator extends Node3D

signal elevator_user_entered(body: Node3D)

signal elevator_closed
signal elevator_opening
signal elevator_opened
signal elevator_arrived


@export var arrival_delay: float = 0.2
@export var delay_after_jingle: float = 0.5


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var elevator_jingle: AudioStreamPlayer3D = $ElevatorJingle
@onready var elevator_working: AudioStreamPlayer = $ElevatorWorking
@onready var elevator_arrive_sound: AudioStreamPlayer = $ElevatorArrive

@onready var elevator_exit_area: Area3D = $ElevatorExitArea
@onready var elevator_enter_area: Area3D = $ElevatorEnterArea

@onready var exit_block_collision_shape: CollisionShape3D = $ExitBlock/ExitBlockCollisionShape


var _arrive_queue_timer: WeakRef

# TODO: add more states
enum ElevatorState{
	CLOSED,
	OPEN,
	WORKING,
	TRANSITIVE
}

var _elevator_state := ElevatorState.CLOSED:
	set(state):
		_elevator_state = state
		match _elevator_state:
			ElevatorState.CLOSED:
				elevator_closed.emit()
			ElevatorState.OPEN:
				elevator_opened.emit()


# TODO: functions to instantly set elevator states functionality (like after restart)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	elevator_enter_area.body_entered.connect(func(node: Node3D)->void:elevator_user_entered.emit(node))
	elevator_exit_area.body_exited.connect(func(_n)->void:close_elevator())


func reset() -> void:
	animation_player.play("RESET")
	_elevator_state = ElevatorState.CLOSED
	disable_open_on_enter()
	exit_block_collision_shape.disabled = true
	# maybe need to stop more sounds
	elevator_working.stop()
	elevator_arrive_sound.stop()
	if _arrive_queue_timer and _arrive_queue_timer.get_ref() and \
	(_arrive_queue_timer.get_ref() as SceneTreeTimer).timeout.is_connected(_elevator_arrive):
		(_arrive_queue_timer.get_ref() as SceneTreeTimer).timeout.disconnect(_elevator_arrive)


func elevator_work(time: float) -> void:
	# has to be closed first
	_elevator_state = ElevatorState.WORKING
	var extended_camera: ExtendedCamera = get_viewport().get_camera_3d()
	extended_camera.set_shake(0.025)
	extended_camera.enable_shake(0.005, 0.05)
	elevator_working.play()
	_elevator_queue_arrive(time)


func _elevator_arrive() -> void:
	elevator_working.stop()
	elevator_arrive_sound.play()
	var camera = get_viewport().get_camera_3d()
	if is_instance_of(camera, ExtendedCamera):
		camera.enable_shake(0.05, 0.10)
		camera.disable_shake()
	await get_tree().create_timer(arrival_delay).timeout
	elevator_jingle.play()
	await get_tree().create_timer(delay_after_jingle).timeout
	_elevator_state = ElevatorState.CLOSED
	elevator_arrived.emit()
	#open_elevator()


func _elevator_queue_arrive(time: float) -> void:
	_arrive_queue_timer = weakref(get_tree().create_timer(time))
	(_arrive_queue_timer.get_ref() as SceneTreeTimer).timeout.connect(_elevator_arrive, CONNECT_ONE_SHOT)


func open_elevator() -> void:
	if _elevator_state == ElevatorState.OPEN:
		return
	if _elevator_state == ElevatorState.WORKING:
		elevator_arrived.connect(open_elevator, CONNECT_ONE_SHOT)
	elif _elevator_state == ElevatorState.TRANSITIVE and animation_player.is_playing():
		animation_player.animation_finished.connect(func(_anim)->void:open_elevator(), CONNECT_ONE_SHOT)
	else:
		animation_player.play("elevator_open")
		elevator_opening.emit()
		animation_player.animation_finished.connect(func(_anim)->void:_elevator_state = ElevatorState.OPEN, CONNECT_ONE_SHOT)
		_elevator_state = ElevatorState.TRANSITIVE


func close_elevator() -> void:
	if _elevator_state == ElevatorState.CLOSED:
		return
	if animation_player.is_playing():
		animation_player.animation_finished.connect(func(_anim)->void:close_elevator(), CONNECT_ONE_SHOT)
	else:
		animation_player.play("elevator_close")
		animation_player.animation_finished.connect(func(_anim)->void:_elevator_state = ElevatorState.CLOSED, CONNECT_ONE_SHOT)
		_elevator_state = ElevatorState.TRANSITIVE


func check_elevator() -> Array[Node3D]:
	return elevator_enter_area.get_overlapping_bodies()


func enable_open_on_enter() -> void:
	if not elevator_enter_area.body_entered.is_connected(_elevator_user_enter):
		elevator_enter_area.body_entered.connect(_elevator_user_enter)
	#if elevator_enter_area.get_overlapping_bodies().size() > 0:
		#open_elevator()


func disable_open_on_enter() -> void:
	if elevator_enter_area.body_entered.is_connected(_elevator_user_enter):
		elevator_enter_area.body_entered.disconnect(_elevator_user_enter)


func disable_exit_block(disable: bool) -> void:
	exit_block_collision_shape.disabled = disable


func _elevator_user_enter(_user: Node3D) -> void:
	open_elevator()
