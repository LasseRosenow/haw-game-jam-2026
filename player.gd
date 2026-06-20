extends Area2D

const MAX_SPEED = 400

@export var speed = MAX_SPEED
@export var player = 1
@export var interact_body: CharacterBody2D
@export var holding_item: CharacterBody2D
@export var interactable_node: RigidBody2D
@export var freeze: bool = false

var wetness: float = 0.0
var holding_item_og_zlayer: int
var screen_size: Vector2

# Water detection
@onready var feet: Area2D = $WaterDetector
func _is_on_water() -> bool:
	return feet.has_overlapping_bodies()

@export var ground_y: float = 600.0   # Y at the bottom, no blue
@export var top_y: float = 100.0      # Y at the top, full blue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size

func pickup_item(item: Node2D) -> void:
	item.global_position = self.global_position
	holding_item_og_zlayer = item.z_index
	item.z_index = self.z_index + 1
	self.holding_item = item
	self.holding_item.emit_signal("new_target", null)

func drop_item(item: Node2D) -> void:
	self.holding_item.emit_signal("new_target", get_parent().get_node("Target"))
	item.z_index = holding_item_og_zlayer
	self.holding_item = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:#
	var velocity = Vector2.ZERO
	
	if freeze:
		return
	
	# Update the players speed based on wettness
	speed = (MAX_SPEED - MAX_SPEED * (0.5 * wetness))
		
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
		$ButtonUI.emit_signal("start_animation", false)
		if self.interactable_node != null:
			print("emitting signal to node")
			self.interactable_node.emit_signal("interacted_with", holding_item != null, self)
		elif self.holding_item != null:
			print("dropped")
			self.drop_item(self.holding_item)
		elif self.interact_body == null:
			print("Tried to pick up but there was no object")
		else:
			print("Pickup up :)")
			self.pickup_item(self.interact_body)
		
	# Sprite Processing
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		
		$AnimatedSprite2D.flip_h = 0 >= velocity.x 
		if _is_on_water():
			$AnimatedSprite2D.play("Swimming")
			if $WaterSound.stream_paused:
				$WaterSound.stream_paused = false
				$WalkSound.stream_paused = true
		else:
			if $WalkSound.stream_paused:
				$WaterSound.stream_paused = true
				$WalkSound.stream_paused = false
			if velocity.y == 0.0:
				$AnimatedSprite2D.play("WalkingSideways")
			else:
				$AnimatedSprite2D.play("Walking")
	else:
		$WaterSound.stream_paused = true
		$WalkSound.stream_paused = true
		if _is_on_water():
			$AnimatedSprite2D.play("Floating")
		else:
			$AnimatedSprite2D.frame = 0
			$AnimatedSprite2D.stop()
	
	# Position Updating
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	# Holding Item handling
	if self.holding_item:
		self.holding_item.position += velocity * delta

	# Shader magic stuff
	$AnimatedSprite2D.material.set_shader_parameter("blue_amount", clampf(wetness, 0.0, 0.35))

func _on_body_entered(body: Node2D) -> void:
	print(body.name)
	if  body.name.contains("Item"):
		print("Item Pickup Range")
		self.interact_body = body
		$ButtonUI.emit_signal("change_animation", "Enter%s" % player)
		$ButtonUI.emit_signal("start_animation", true)
		print("assigned")
	elif body.name.contains("RiceField"):
		print("Entered RiceField")
		self.interactable_node = body
	elif body.name.contains("FishingWalkway"):
		print("Entered Fishing Walkway")
		self.interactable_node = body
		$ButtonUI.emit_signal("change_animation", "Enter%s" % player)
		$ButtonUI.emit_signal("start_animation", true)


func _on_body_exited(body: Node2D) -> void:
	print("Leaving %s" % body.name)
	$ButtonUI.emit_signal("start_animation", false)
	if interact_body == body:
		self.interact_body = null
		print("Left range")
	elif interactable_node == body:
		self.interactable_node = null
		print("Left Rice or Fishing")

func _on_wet_cooldown_timeout() -> void:
		# Detect if the player is on water or land
	if _is_on_water():
		if wetness <= 1.0:
			wetness += 0.3
	else:
		if wetness > 0.0:
			wetness -= 0.05
