extends RigidBody2D

signal interacted_with(holding_item: bool, interactor: Area2D)
var player: Area2D = null

func is_interactable(item_type: String) -> bool:
	return item_type == "fish"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _reset() -> void:
	$ButtonUI.emit_signal("start_animation", false)
	$Timer.stop()
	player = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player != null:
		if not Input.is_action_pressed("pickup_player%s" % player.player):
			print("Failed to continue pressing :(")
			$Cutting.stop()
			player.get_new_item("fish")
			_reset()

func _on_interacted_with(holding_item: bool, interactor: Area2D) -> void:
	print("Somebody interacted with the cutting board :D")
	print(holding_item)
	print(interactor)
	
	if player == null:
		player = interactor
		interactor.consume_item()
		$ButtonUI.emit_signal("change_animation", "ProgressBar")
		$ButtonUI.emit_signal("start_animation", true)
		$Cutting.play(0.0)
		$Timer.start(4)

func _on_timer_timeout() -> void:
	$ButtonUI.emit_signal("start_animation", false)
	player.get_new_item("cut_fish")
	_reset()
