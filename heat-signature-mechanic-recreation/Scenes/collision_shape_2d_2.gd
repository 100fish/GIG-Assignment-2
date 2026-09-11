extends CollisionShape2D

var player: CharacterBody2D
@onready var aim: CollisionShape2D = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#player = get_tree().get_first_node_in_group("Player")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	player = get_tree().get_first_node_in_group("Player")
	#look_at(player.position)
	
	position = player.global_position.lerp(aim.global_position, .5)
	
	pass
