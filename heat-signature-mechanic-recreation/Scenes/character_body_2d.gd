extends CharacterBody2D


const SPEED = 300.0

func _physics_process(delta: float) -> void:
	var JoyAxisL: Vector2 = Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
	var JoyAxisR: Vector2 = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
	
	look_at(position + JoyAxisR)
	
	velocity = JoyAxisL * SPEED
	move_and_slide()
