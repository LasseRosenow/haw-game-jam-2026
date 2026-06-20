extends CharacterBody2D

@export var speed = 3000
@export var target: Node2D = null

signal new_target(target: Node2D)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !$Agent.is_target_reached():
		var nav_path = to_local($Agent.get_next_path_position()).normalized()
		velocity = nav_path * speed * delta
		move_and_slide()

func _on_new_target(target: Node2D) -> void:
	print("Recieved new target signal")
	$Agent.target_position = target.position
	
