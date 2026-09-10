extends RigidBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _get_fucking_domed() -> void:
	collision_shape_2d.disabled = true
