extends CharacterBody2D

enum AimState
{
	Inactive,
	Aiming,
	Locked,
	Attacking
}
var aimState: AimState = AimState.Inactive
@onready var aim: Area2D = $UpperPlayer/Aim

@export var defaultSpeed: float = 300
@export var attackSpeedMultiplier: float = 30
var Speed = 300.0

@export var controller: bool = false

@onready var upper_player: Node2D = $UpperPlayer

var targetPosition: Vector2

#func _input(event: InputEvent) -> void:
	
	#if event is InputEventMouseMotion:
		#targetPosition = event.global_position
		
	#if event.is_action_pressed("Aim"):
		#pass

#func _process(delta: float) -> void:
	#sprite_2d.position = to_local(targetPosition)

#region state machine
func _set_aimstate(newState: AimState) -> void:
	if aimState == newState:
		return
	
	if newState == AimState.Inactive && aim.aiming == true:
		newState = AimState.Aiming
	
	match aimState:
		AimState.Inactive:
			_aimstate_inactive_exit()
		AimState.Aiming:
			_aimstate_aiming_exit()
		AimState.Locked:
			_aimstate_locked_exit()
		AimState.Attacking:
			_aimstate_attacking_exit()
	
	aimState = newState
	
	match aimState:
		AimState.Inactive:
			_aimstate_inactive_enter()
		AimState.Aiming:
			_aimstate_aiming_enter()
		AimState.Locked:
			_aimstate_locked_enter()
		AimState.Attacking:
			_aimstate_attacking_enter()

func _aimstate_inactive_exit():
	pass

func _aimstate_aiming_exit():
	pass

func _aimstate_locked_exit():
	pass

func _aimstate_attacking_exit():
	Speed /= attackSpeedMultiplier

func _aimstate_inactive_enter():
	pass

func _aimstate_aiming_enter():
	pass

func _aimstate_locked_enter():
	pass

func _aimstate_attacking_enter():
	Speed *= attackSpeedMultiplier

#endregion

func _physics_process(_delta: float) -> void:
	match aimState:
		AimState.Inactive:
			targetPosition = get_global_mouse_position()
			_turn_and_move()
		AimState.Aiming:
			targetPosition = get_global_mouse_position()
			_turn_and_move()
		AimState.Locked:
			if position.distance_to(targetPosition) > 350:
				_set_aimstate(AimState.Inactive)
			_turn_and_move()
		AimState.Attacking:
			_attack_and_move()

func _turn_and_move() -> void:
	upper_player.look_at(targetPosition)
	
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = direction * Speed
	move_and_slide()

func _attack_and_move() -> void:
	upper_player.look_at(targetPosition)
	
	var direction = position.direction_to(targetPosition)
	velocity = direction * Speed
	move_and_slide()
	
	if position.distance_to(targetPosition) < 100:
		_set_aimstate(AimState.Inactive)

func _on_aim_area_entered(area: Area2D) -> void:
	targetPosition = area.global_position
	aimState = AimState.Locked


func _on_aim_aiming_signal(aiming: bool) -> void:
	if aiming:
		_set_aimstate(AimState.Aiming)
	elif aimState == AimState.Locked:
		_set_aimstate(AimState.Attacking)
	else:
		_set_aimstate(AimState.Inactive)
