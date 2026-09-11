extends RigidBody2D

const DEAD_CUCE = preload("uid://bqd2f3023fr7y")
const GLOWING_HOOK = preload("uid://ofra3c15l3yl")
const INACTIVE_AIM = preload("uid://dxcjajh5yfpl1")
const CUCE = preload("uid://ctakoia833ek4")

@onready var body: Sprite2D = $Body
@onready var target: Sprite2D = $Target

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _change_targeted(targeted: bool) -> void:
	if targeted == true:
		target.texture = GLOWING_HOOK
	else:
		target.texture = INACTIVE_AIM

func _get_hit(playerPos: Vector2, hitForce: float) -> void:
	apply_impulse(playerPos.direction_to(position) * hitForce)
	body.texture = DEAD_CUCE
	_change_targeted(false)
	
	collision_shape_2d.disabled = true
