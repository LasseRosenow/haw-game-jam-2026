extends RigidBody2D

@export var type = "RiceField"

signal interacted_with(holding_item: bool, interactor: Area2D)
@export_enum("dry", "stage1", "stage2", "harvested", "watered") var stage: String = "dry"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ButtonUI.emit_signal("change_animation", "Water")
	$ButtonUI.emit_signal("start_animation", true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_interacted_with(holding_item: bool, interactor: Area2D) -> void:
	print("Somebody interacted with the rice field :D")
	print(holding_item)
	print(interactor)
	if stage == "dry":
		stage = "watered"
		$ButtonUI.emit_signal("change_animation", "Wait")
		$ButtonUI.emit_signal("start_animation", true)
		$GrowTimer.start(5)
		$AnimatedSprite2D.play(stage)
	elif stage == "stage2" and !holding_item:
		stage = "harvested"
		$Harvest.start(2)
		interactor.freeze = true
		$Cutting.play(0)
		await $Harvest.timeout
		$Cutting.stop()
		interactor.freeze = false
		var item = preload("res://item.tscn").instantiate()
		item.item_type = "rice"
		item.scale.x = 3.0
		item.scale.y = 3.0
		item.name = "Item%s" % Time.get_unix_time_from_system()
		#Awful
		get_parent().get_parent().add_child(item)
		interactor.pickup_item(item)
		$AnimatedSprite2D.play("watered")
		$ButtonUI.emit_signal("start_animation", false)
		$GrowTimer.start(10)


func _on_grow_timer_timeout() -> void:
	if stage == "watered":
		stage = "stage1"
		$GrowTimer.start(5)
	elif stage == "stage1":
		stage = "stage2"
		$GrowTimer.start(5)
	elif stage == "stage2":
		$ButtonUI.emit_signal("change_animation", "Done")
	elif stage == "harvested":
		stage = "dry"
		$ButtonUI.emit_signal("change_animation", "Water")
		$ButtonUI.emit_signal("start_animation", true)
		
	$AnimatedSprite2D.play(stage)
