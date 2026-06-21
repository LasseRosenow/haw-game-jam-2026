extends RigidBody2D

signal interacted_with(holding_item: bool, interactor: Area2D)

@export_enum("empty", "cooking", "finished") var state: String = "empty"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_interacted_with(holding_item: bool, interactor: Area2D) -> void:
	print("Somebody interacted with the fishing walkway :D")
	print(holding_item)
	print(interactor)

	if 	state == "empty":
		state = "cooking"
		$ButtonUI.emit_signal("change_animation", "Wait")
		$ButtonUI.emit_signal("start_animation", true)
		$Timer.start(4)

	if state == "cooking":
		pass

	if state == "finished":
		state = "empty"
		$ButtonUI.emit_signal("start_animation", false)
		interactor.get_new_item("cooked_rice")

func _on_timer_timeout() -> void:
	print("Cooking finished")
	state = "finished"
	$ButtonUI.emit_signal("change_animation", "Done")
