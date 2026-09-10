extends Area2D

@onready var pathCrosshair: Sprite2D = $Sprite2D
@onready var crosshair: Sprite2D = $"../Crosshair"

var activeSprite: Sprite2D

var aiming: bool = false
signal aimingSignal(aiming: bool)

@export var activeAim: GradientTexture2D
@export var inactiveAim: GradientTexture2D

#region input
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Aim"):
		EnableAim()
	if event.is_action_released("Aim"):
		DisableAim()

func EnableAim() -> void:
	aiming = true
	aimingSignal.emit(true)
	activeSprite.texture = activeAim

func DisableAim() -> void:
	aiming = false
	aimingSignal.emit(false)
	activeSprite.texture = inactiveAim
#endregion

func _ready() -> void:
	activeSprite = crosshair
	DisableAim()

func _process(delta: float) -> void:
	pass
