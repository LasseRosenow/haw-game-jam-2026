extends CharacterBody2D

@export var speed = 80
@export var target: Node2D = null
@export var disable_movement: bool = false
@export var type = "Item"

signal new_target(target: Node2D)

# Water detection
@onready var feet: Area2D = $WaterDetector
func _is_on_water() -> bool:
	return feet.has_overlapping_bodies()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(_delta: float) -> void:
	if disable_movement or not _is_on_water():
		return

	if not $Agent.is_target_reached():
		var nav_path = to_local($Agent.get_next_path_position()).normalized()
		velocity = nav_path * speed 
		move_and_slide()


func _on_new_target(target: Node2D) -> void:
	print("Received new target signal")
	if target == null:
		disable_movement = true
		$CollisionShape2D.set_deferred("disabled", true)
		call_deferred("set_collision_mask_value", 2, false)
	else:
		$Agent.target_position = target.position
		disable_movement = false
		$CollisionShape2D.set_deferred("disabled", false)
		call_deferred("set_collision_mask_value", 2, true)
