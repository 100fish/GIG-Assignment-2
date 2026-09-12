extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

enum AimState
{
	Inactive,
	Aiming,
	Locked,
	Attacking
}
var attacking: bool = false

var aimState: AimState = AimState.Inactive
@onready var aim: Area2D = $"../Aim"

@export var defaultSpeed: float = 300
@export var attackSpeedMultiplier: float = 20
@export var Speed = 300.0
@export var timeSlow: float = .2

@onready var upper_player: Node2D = $UpperPlayer

var targetPosition: Vector2
var lockedTarget: RigidBody2D
@onready var rayCast: RayCast2D = $RayCast2D

@onready var crosshair: Sprite2D = $UpperPlayer/Crosshair
@onready var pathCrosshair: Sprite2D = $UpperPlayer/PathCrosshair
@onready var vignette: TextureRect = $Camera2D/CanvasLayer/TextureRect

const CROSSHAIR = preload("uid://daybbr8incccg")
const PATH_CROSSHAIR = preload("uid://bgtm5f35mu8co")
const INACTIVE_AIM = preload("uid://dxcjajh5yfpl1")
const VIGNETTE = preload("uid://bk5n6t8gahvyo")

#region state machine
func _set_aimstate(newState: AimState) -> void:
	if aimState == newState:
		return
	
	if newState == AimState.Inactive && aim.clicking == true:
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
			print("State: Inactive")
			_aimstate_inactive_enter()
		AimState.Aiming:
			print("State: Aiming")
			_aimstate_aiming_enter()
		AimState.Locked:
			print("State: Locked")
			_aimstate_locked_enter()
		AimState.Attacking:	
			print("State: Attacking")
			_aimstate_attacking_enter()

func _aimstate_inactive_exit():
	pass

func _aimstate_aiming_exit():
	
	aim.aiming = false;
	crosshair.texture = INACTIVE_AIM
	vignette.texture = INACTIVE_AIM
	
	Engine.time_scale = 1

func _aimstate_locked_exit():
	aim.aiming = false;
	pathCrosshair.texture = INACTIVE_AIM
	vignette.texture = INACTIVE_AIM
	
	Engine.time_scale = 1

func _aimstate_attacking_exit():
	if attacking:
		Speed /= attackSpeedMultiplier
		lockedTarget._get_hit(global_position, 20)
		animation_player.play("CameraShake", -1, 8)

func _aimstate_inactive_enter():
	pass

func _aimstate_aiming_enter():
	aim.aiming = true;
	crosshair.texture = CROSSHAIR
	vignette.texture = VIGNETTE
	
	Engine.time_scale = timeSlow

func _aimstate_locked_enter():
	aim.aiming = true;
	pathCrosshair.texture = PATH_CROSSHAIR
	vignette.texture = VIGNETTE
	
	Engine.time_scale = timeSlow


func _aimstate_attacking_enter():
	attacking = true
	
	Speed *= attackSpeedMultiplier
	lockedTarget = aim.activeTarget
	
	rayCast.target_position = lockedTarget.global_position
	
	if rayCast.is_colliding():
		print("Hi raycast hit")
		attacking = false
		_set_aimstate(AimState.Inactive)
	else:
		print("No raycast no hit")

#endregion

func _physics_process(_delta: float) -> void:	
	match aimState:
		AimState.Inactive:
			targetPosition = get_global_mouse_position()
			_turn_and_move()
		AimState.Aiming:
			if aim.activeTarget != null:
				if position.distance_to(aim.activeTarget.position) < 600:
					targetPosition = aim.activeTarget.position
					_set_aimstate(AimState.Locked)
			
			targetPosition = get_global_mouse_position()
			_turn_and_move()
		AimState.Locked:
			if aim.activeTarget == null:
				_set_aimstate(AimState.Aiming)
				return
			
			targetPosition = aim.activeTarget.position
			
			pathCrosshair.global_position = targetPosition.lerp(position,.5)
			pathCrosshair.scale = (Vector2(targetPosition.distance_to(position) / 70, 1))
			
			if position.distance_to(targetPosition) > 600:
				_set_aimstate(AimState.Aiming)
			_turn_and_move()
		AimState.Attacking:
			targetPosition = lockedTarget.position
			
			_attack_and_move()

func _turn_and_move() -> void:
	upper_player.look_at(targetPosition)
	
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = direction * Speed
	move_and_slide()

func _attack_and_move() -> void:
	upper_player.look_at(lockedTarget.position)
	
	var direction = position.direction_to(targetPosition)
	velocity = direction * Speed
	move_and_slide()
	
	if position.distance_to(targetPosition) < 100:
		_set_aimstate(AimState.Inactive)

func _on_aim_area_entered(area: Area2D) -> void:
	targetPosition = area.global_position
	aimState = AimState.Locked


func _on_aim_aiming_signal(aiming: bool) -> void:
	match aimState:
		AimState.Inactive:
			if aiming == true:
				_set_aimstate(AimState.Aiming)
			elif aiming == false:
				print("BAD: Clicking up while in Inactive shouldn't be possible")
		AimState.Aiming:
			if aiming == true:
				print("BAD: Clicking down while in Aimstate shouldn't be possible")
			elif aiming == false:
				_set_aimstate(AimState.Inactive)
		AimState.Locked:
			if aiming == true:
				print("BAD: Clicking down while in Lockstate shouldn't be possible")
			elif aiming == false:
				_set_aimstate(AimState.Attacking)
		AimState.Attacking:
			if aiming == true:
				print("Good: Nothing can be done while attacking")
			elif aiming == false:
				print("Good: Nothing can be done while attacking")
