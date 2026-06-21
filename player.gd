extends Area2D

const MAX_SPEED = 200

@export var speed = MAX_SPEED
@export var player = 1
@export var interact_body: CharacterBody2D
@export var holding_item: CharacterBody2D
@export var interactable_node: RigidBody2D
@export var freeze: bool = false

var wetness: float = 0.0
var holding_item_og_zlayer: int
var screen_size: Vector2

# Fishing Walkway detection
@onready var fishing_feet: Area2D = $FishingWalkwayDetector
func _is_on_fishing_walkway() -> bool:
	return fishing_feet.has_overlapping_areas()

# Water detection
@onready var water_feet: Area2D = $WaterDetector
func _is_on_water() -> bool:
	return water_feet.has_overlapping_bodies() and not _is_on_fishing_walkway()

@export var ground_y: float = 600.0   # Y at the bottom, no blue
@export var top_y: float = 100.0      # Y at the top, full blue

var override_animation = false

func set_animation(animation: String) -> void:
	override_animation = true
	$AnimatedSprite2D.play(animation)
	
func reset_animation() -> void:
	override_animation = false
	$AnimatedSprite2D.play("Idle")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	$AnimatedSprite2D.play("Walking")
	$PlayerTag.animation = "%s" % player
	
func get_new_item(item_type: String) -> void:
	var item = preload("res://item.tscn").instantiate()
	item.item_type = item_type
	item.scale.x = 3.0
	item.scale.y = 3.0
	item.name = "Item%s" % Time.get_unix_time_from_system()
	#Awful
	get_parent().get_parent().add_child(item)
	pickup_item(item)
	get_parent().add_child(item)

func consume_item() -> void:
	self.holding_item.queue_free()
	self.holding_item = null

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
	if not override_animation:
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
				else: if velocity.y < 0.0:
					$AnimatedSprite2D.play("WalkingUpwards")
				else: if velocity.y > 0.0:
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
	elif body.name.contains("Customer"):
		print("Next to customer")
		self.interactable_node = body
	elif body.name.contains("FishingWalkway"):
		print("Entered Fishing Walkway")
		self.interactable_node = body
		$ButtonUI.emit_signal("change_animation", "Enter%s" % player)
		$ButtonUI.emit_signal("start_animation", true)
	elif body.name.contains("Stove"):
		print("Entered Stove")
		if body.is_interactable(holding_item.item_type if holding_item != null else ""):
			self.interactable_node = body
			$ButtonUI.emit_signal("change_animation", "Enter%s" % player)
			$ButtonUI.emit_signal("start_animation", true)
	elif body.name.contains("CuttingBoard"):
		print("Entered Cutting Board")
		if body.is_interactable(holding_item.item_type if holding_item != null else ""):
			self.interactable_node = body
			$ButtonUI.emit_signal("change_animation", "Enter%s" % player)
			$ButtonUI.emit_signal("start_animation", true)
	elif body.name.contains("SushiBoard"):
		print("Entered Sushi Board")
		if body.is_interactable(holding_item.item_type if holding_item != null else ""):
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
