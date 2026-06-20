extends Area2D

@export var speed = 400
@export var player = 1
@export var interact_body: CharacterBody2D
@export var holding_item: CharacterBody2D

var screen_size: Vector2
signal pickup

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:#
	var velocity = Vector2.ZERO
	
	# Input processing
	if Input.is_action_pressed("move_right_player%s" % player):
		velocity.x += 1
	if Input.is_action_pressed("move_left_player%s" % player):
		velocity.x -= 1
	if Input.is_action_pressed("move_down_player%s" % player):
		velocity.y += 1
	if Input.is_action_pressed("move_up_player%s" % player):
		velocity.y -= 1
	if Input.is_action_just_pressed("pickup_player%s" % player):
		if self.holding_item != null:
			print("dropped")
			self.holding_item.emit_signal("new_target", get_parent().get_node("Target"))
			self.holding_item = null
		elif self.interact_body == null:
			print("Tried to pick up but there was no object")
		else:
			print("Pickup up :)")
			self.holding_item = interact_body
			self.holding_item.emit_signal("new_target", null)
		
		
	# Sprite Processing
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play("Walking")
		$AnimatedSprite2D.flip_h = 0 >= velocity.x 
	elif $AnimatedSprite2D.animation != "Idle":
		$AnimatedSprite2D.play("Idle")
	
	# Position Updating
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	# Holding Item handling
	if self.holding_item:
		self.holding_item.position += velocity * delta

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Item":
		print("Item Pickup Range")
		self.interact_body = body
		print("assigned")

func _on_body_exited(body: Node2D) -> void:
	if interact_body == body:
		self.interact_body = null
		print("Left range")
