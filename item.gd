extends CharacterBody2D

@export var speed = 3000
@export var target: Node2D = null
@export var disable_movement: bool = false

signal new_target(target: Node2D)

# Water detection
@onready var feet: Area2D = $WaterDetector
func _is_on_water() -> bool:
	return feet.has_overlapping_bodies()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !$Agent.is_target_reached() and !disable_movement:
		var nav_path = to_local($Agent.get_next_path_position()).normalized()
		velocity = nav_path * speed * delta
		move_and_slide()

func _on_new_target(target: Node2D) -> void:
	print("Recieved new target signal")
	if target == null:
		disable_movement = true
		$CollisionShape2D.disabled = true
		self.set_collision_mask_value(2, false)
	else:
		$Agent.target_position = target.position
		disable_movement = false
		$CollisionShape2D.disabled = false
		self.set_collision_mask_value(2, true)
	
