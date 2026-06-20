extends CharacterBody2D

@export var speed = 80
@export var target: Node2D = null
@export var disable_movement: bool = false
@export var type = "Item"
@export var item_type: String = "default"
@export var ever_picked_up: bool = false

signal new_target(target: Node2D)

# Water detection
@onready var feet: Area2D = $WaterDetector
func _is_on_water() -> bool:
	return feet.has_overlapping_bodies()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.animation = item_type

func _physics_process(_delta: float) -> void:
	if disable_movement and !ever_picked_up:
		ever_picked_up = true
	
	if disable_movement or not _is_on_water():
		return

	var nav_path = to_local($Agent.get_next_path_position()).normalized()
	velocity = nav_path * speed
	var random_y = randi() % 50 - 15
	var random_x = randi() % 75 - 25
	velocity.y += random_y * _delta
	velocity.x += random_x * _delta
	move_and_slide()

func _on_new_target(target: Node2D) -> void:
	print("Received new target signal")
	if target == null:
		print("Target was null")
		disable_movement = true
		$CollisionShape2D.set_deferred("disabled", true)
		call_deferred("set_collision_mask_value", 2, false)
	else:
		$Agent.target_position = target.position
		disable_movement = false
		$CollisionShape2D.set_deferred("disabled", false)
		call_deferred("set_collision_mask_value", 2, true)
