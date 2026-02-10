class_name OfficeLayout extends Node3D

signal elevator_user_entered(body: Node3D)

signal elevator_closed
signal elevator_opened

@onready var animation_player: AnimationPlayer = $office_layout/Lift/AnimationPlayer
@onready var elevator_jingle: AudioStreamPlayer3D = $ElevatorJingle

@onready var elevator_exit_area: Area3D = $ElevatorExitArea
@onready var elevator_enter_area: Area3D = $ElevatorEnterArea

@export var arrival_delay: float = 0.2
@export var delay_after_jingle: float = 0.5

enum ElevatorState{
	CLOSED,
	OPEN,
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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	elevator_enter_area.body_entered.connect(func(node: Node3D)->void:elevator_user_entered.emit(node))
	elevator_enter_area.body_entered.connect(func(_n)->void:open_evelvator())
	elevator_exit_area.body_exited.connect(func(_n)->void:close_elevator())
	await get_tree().create_timer(arrival_delay).timeout
	elevator_jingle.play()
	await get_tree().create_timer(delay_after_jingle).timeout
	open_evelvator()


func open_evelvator() -> void:
	if _elevator_state == ElevatorState.OPEN:
		return
	if animation_player.is_playing():
		animation_player.animation_finished.connect(func(_anim)->void:open_evelvator(), CONNECT_ONE_SHOT)
	else:
		animation_player.play("elevator_open")
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
