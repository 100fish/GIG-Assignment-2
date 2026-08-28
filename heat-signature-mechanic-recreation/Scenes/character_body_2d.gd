extends CharacterBody2D


const SPEED = 300.0

@export var controller: bool = false

@onready var upper_player: Node2D = $UpperPlayer

var cursorPosition: Vector2

#func _input(event: InputEvent) -> void:
	
	#if event is InputEventMouseMotion:
		#cursorPosition = event.global_position
		
	#if event.is_action_pressed("Aim"):
		#pass

#func _process(delta: float) -> void:
	#sprite_2d.position = to_local(cursorPosition)

func _physics_process(delta: float) -> void:
	if(controller):
		var JoyAxisL = Input.get_vector("Left", "Right", "Up", "Down")
		var JoyAxisR: Vector2 = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
		
		look_at(position + JoyAxisR)
		
		velocity = JoyAxisL * SPEED
		move_and_slide()
	else:
		
		if Input.is_action_pressed("Aim"):
			pass
		
		var Direction = Input.get_vector("Left", "Right", "Up", "Down")
		
		upper_player.look_at(get_global_mouse_position())
		
		velocity = Direction * SPEED
		move_and_slide()
