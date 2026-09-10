extends Area2D

var activeSprite: Sprite2D

var clicking: bool = false
var aiming: bool = false

signal aimingSignal(aiming: bool)

var activeTargets: Array[RigidBody2D]
var activeTarget: RigidBody2D

#region input
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Aim"):
		EnableAim()
	elif event.is_action_released("Aim"):
		DisableAim()

func EnableAim() -> void:
	clicking = true
	aimingSignal.emit(clicking)

func DisableAim() -> void:
	clicking = false
	aimingSignal.emit(clicking)
#endregion

func _physics_process(delta: float) -> void:
	position = get_global_mouse_position()
	#if clicking != aiming:
		#print("ODD: clicking-aiming mismatch")
		#if aiming == false:
			#DisableAim()
		#else:
			#EnableAim()
	
	if aiming == true:
		if activeTargets.size() == 0:
			activeTarget = null
		elif activeTargets.size() == 1:
			activeTarget = activeTargets[0]
		else:
			activeTarget = _find_closest_target()

func _find_closest_target() -> RigidBody2D:
	var sortedTargets: Array[RigidBody2D] = activeTargets
	var targetDistances: Array[float]
	targetDistances.resize(sortedTargets.size())
	
	for i in range(sortedTargets.size()):
		targetDistances[i] = position.distance_to(sortedTargets[i].global_position)
		pass
	
	sortedTargets.sort_custom(func(a, b):
		return targetDistances.find(a) < targetDistances.find(b)
	)
	
	return sortedTargets[0]

func _on_body_entered(body: Node2D) -> void:
	activeTargets.append(body)

func _on_body_exited(body: Node2D) -> void:
	activeTargets.erase(body)
