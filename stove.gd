extends RigidBody2D

signal interacted_with(holding_item: bool, interactor: Area2D)
var player: Area2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _reset():
	player.freeze = false
	player = null
	$ButtonUI.emit_signal("start_animation", false)
	
func _on_timer_timeout() -> void:
	print("Fishing: Player failed :(")
	_reset()

func _on_interacted_with(holding_item: bool, interactor: Area2D) -> void:
	print("Somebody interacted with the fishing walkway :D")
	print(holding_item)
	print(interactor)
	
	player = interactor
	# player.freeze = true
	
	player.get_new_item("cooked_rice")
