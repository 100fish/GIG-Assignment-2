extends Sprite2D
@onready var player: CharacterBody2D = $"../LowerPlayer"

func _process(delta: float) -> void:
	position = player.global_position
