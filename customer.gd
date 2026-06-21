extends RigidBody2D

@export var wanted_food: String = "default"
@export var anger_limit: float = 1000.0
@export var current_anger: float = 0.0
@export var npc_version: int = 1

signal interacted_with(holding_item: bool, interactor: Area2D)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func set_up_customer(wanted_food: String, anger_limit: int)  -> void:
	$AnimatedSprite2D.material.set_shader_parameter("red_amount", 0.0)
	self.wanted_food = wanted_food
	self.anger_limit = anger_limit
	self.npc_version = randi() % 2 + 1
	$Item.animation = wanted_food
	$AnimatedSprite2D.animation = "%s" % self.npc_version

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	current_anger += 1.0
	# Shader magic stuff
	$AnimatedSprite2D.material.set_shader_parameter("red_amount", clampf(current_anger / anger_limit, 0.0, 0.75))

	if current_anger >= anger_limit:
		$Explosion.show()
		$AnimationPlayer.play("explosion")
		$ExplosionSound.play(0.0)
		$Timer.stop()
		$Item.hide()
		$Bubble.hide()
		await $AnimationPlayer.animation_finished
		self.hide()
		get_parent().get_parent().emit_signal("failed_task")
		await $ExplosionSound.finished
		self.queue_free()
		
func _on_interacted_with(holding_item: bool, interactor: Area2D) -> void:
	if !holding_item:
		return
		
	if interactor.holding_item.item_type == wanted_food:
		$AnimatedSprite2D.material.set_shader_parameter("red_amount", 0.0)
		$Timer.stop()
		$Bubble.hide()
		$Item.hide()
		interactor.consume_item()
		$Yipeeee.play(0.0)
		get_parent().get_parent().emit_signal("success_task", 1.0 - (current_anger/anger_limit))
		await $Yipeeee.finished
		self.queue_free()
	
