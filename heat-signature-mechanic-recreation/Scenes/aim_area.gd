extends Area2D

var activeSprite: Sprite2D

var clicking: bool = false
var aiming: bool = false

signal aimingSignal(aiming: bool)

var activeTargets: Array[RigidBody2D]
var activeTarget: RigidBody2D

@onready var circle: CollisionShape2D = $Circle
@onready var square: CollisionShape2D = $Square
@onready var crosshair: Sprite2D = $"../LowerPlayer/UpperPlayer/Crosshair"
@onready var path_crosshair: Node2D = $"../LowerPlayer/UpperPlayer/PathCrosshair"

@onready var player: CharacterBody2D = $"../LowerPlayer"

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

func _physics_process(_delta: float) -> void:
	if activeTarget != null:
		activeTarget._change_targeted(false)
	circle.global_position = get_global_mouse_position()
	square.global_position = player.global_position.lerp(player.position + 600 * player.global_position.direction_to(circle.global_position),.5)
	square.look_at(player.global_position)
	square.scale = (Vector2(crosshair.global_position.distance_to(player.position) / 20, 4))
	
	if aiming == true:
		if activeTargets.size() == 0:
			activeTarget = null
		elif activeTargets.size() == 1:
			activeTarget = activeTargets[0]
			activeTarget._change_targeted(true)
		else:
			activeTarget = _find_closest_target()
			activeTarget._change_targeted(true)

func _find_closest_target() -> RigidBody2D:
	var targetDistances: Array[float]
	targetDistances.resize(activeTargets.size())
	
	for i in range(activeTargets.size()):
		targetDistances[i] = circle.global_position.distance_to(activeTargets[i].global_position)
		pass
	
	var combined: Array = []
	for i in activeTargets.size():
		combined.append({
			"body": activeTargets[i],
			"value": targetDistances[i]
		})
	
	combined.sort_custom(func(a, b): 
		return a["value"] < b["value"]
	)
	
	var sorted_bodies: Array[RigidBody2D] = []
	for pair in combined:
		sorted_bodies.append(pair["body"])
		
	return sorted_bodies[0]

func _on_body_entered(body: Node2D) -> void:
	activeTargets.append(body)

func _on_body_exited(body: Node2D) -> void:
	activeTargets.erase(body)
