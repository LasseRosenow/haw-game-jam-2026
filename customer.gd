extends RigidBody2D

@export var wanted_food: String = "default"
@export var anger_limit: float = 100.0
@export var current_anger: float = 0.0
@export var npc_version: int = 1

signal interacted_with(holding_item: bool, interactor: Area2D)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func set_up_customer(wanted_food: String, anger_limit: int)  -> void:
	self.wanted_food = wanted_food
	self.anger_limit = anger_limit
	self.npc_version = randi() % 2 + 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	current_anger += 1.0
	# Shader magic stuff
	$AnimatedSprite2D.material.set_shader_parameter("red_amount", clampf(current_anger / anger_limit, 0.0, 0.95))

	if current_anger >= anger_limit:
		$Explosion.show()
		$AnimationPlayer.play("explosion")
		$ExplosionSound.play(0.0)
		$Timer.stop()
		await $ExplosionSound.finished
		self.queue_free()
		
func _on_interacted_with(holding_item: bool, interactor: Area2D) -> void:
	if !holding_item:
		return
		
	if interactor.holding_item.item_type == wanted_food:
		$Timer.stop()
		interactor.consume_item()
		$Yipeeee.play(0.0)
		await $Yipeeee.finished
		self.queue_free()
	
