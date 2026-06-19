extends Area2D

@export var speed = 400
@export var player = 1

var screen_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right_player%s" % player):
		velocity.x += 1
	if Input.is_action_pressed("move_left_player%s" % player):
		velocity.x -= 1
	if Input.is_action_pressed("move_down_player%s" % player):
		velocity.y += 1
	if Input.is_action_pressed("move_up_player%s" % player):
		velocity.y -= 1
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play("Walking")
	elif $AnimatedSprite2D.animation != "Idle":
		$AnimatedSprite2D.play("Idle")
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
