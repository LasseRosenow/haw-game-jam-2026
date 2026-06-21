extends Node2D

@export var type = "FishingWalkway"

signal interacted_with(holding_item: bool, interactor: Area2D)
var counter = 0
var player: Area2D = null
var expected_key_index = 0

const BUTTON_KEYS := ["Left", "Right", "Up", "Down"]
const INPUT_KEYS := ["move_left_player", "move_right_player", "move_up_player", "move_down_player"]

func random_key_index() -> int:
	return randi() % BUTTON_KEYS.size()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player != null:
		if Input.is_action_pressed("%s%s" % [INPUT_KEYS[expected_key_index], player.player]):
			print("Fishing: Correct Key Pressed!")
			_next_button_task()

func _next_button_task():
	if counter < 3:
		expected_key_index = random_key_index()
		counter += 1
		$ButtonUI.emit_signal("change_animation", "%s%s" % [BUTTON_KEYS[expected_key_index], player.player])
		$ButtonUI.emit_signal("start_animation", true)
		$Timer.start(1)
	else:
		$Timer.stop()
		$FishingSound.play(0.0)
		player.get_new_item("fish")
		_reset()
		
func _reset():
	counter = 0
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
	player.freeze = true
	
	if counter == 0:
		_next_button_task()
