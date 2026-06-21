extends RigidBody2D

signal interacted_with(holding_item: bool, interactor: Area2D)
var player: Area2D = null

var has_fish = false
var has_rice = false
var currently_working_item = null

func is_interactable(item_type: String) -> bool:
	return item_type == "cut_fish" or item_type == "cooked_rice"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$RequestFishTooltip.emit_signal("change_animation", "CutFish")
	$RequestRiceTooltip.emit_signal("change_animation", "CookedRice")
	$RequestFishTooltip.emit_signal("start_animation", !has_fish)
	$RequestRiceTooltip.emit_signal("start_animation", !has_rice)
	
func _next_stage() -> void:
	$RequestFishTooltip.emit_signal("start_animation", !has_fish)
	$RequestRiceTooltip.emit_signal("start_animation", !has_rice)
	$ButtonUI.emit_signal("start_animation", false)
	$Timer.stop()
	player.reset_animation()
	player = null

func _reset() -> void:
	$RequestFishTooltip.emit_signal("start_animation", true)
	$RequestRiceTooltip.emit_signal("start_animation", true)
	$ButtonUI.emit_signal("start_animation", false)
	$Timer.stop()
	player.reset_animation()
	player = null
	has_fish = false
	has_rice = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player != null:
		if not Input.is_action_pressed("pickup_player%s" % player.player):
			print("Failed to continue pressing :(")
			player.get_new_item(currently_working_item)
			player.reset_animation()
			_next_stage()

func _on_interacted_with(holding_item: bool, interactor: Area2D) -> void:
	print("Somebody interacted with the cutting board :D")
	print(holding_item)
	print(interactor)
	
	if player == null:
		player = interactor
		currently_working_item = player.holding_item.item_type
		interactor.consume_item()
		player.set_animation("Cutting")
		$ButtonUI.emit_signal("change_animation", "ProgressBar")
		$ButtonUI.emit_signal("start_animation", true)
		$RequestFishTooltip.emit_signal("start_animation", false)
		$RequestRiceTooltip.emit_signal("start_animation", false)
		$Timer.start(4)

func _on_timer_timeout() -> void:
	$ButtonUI.emit_signal("start_animation", false)
	
	match currently_working_item:
		"cut_fish": has_fish = true
		"cooked_rice": has_rice = true
	
	if has_fish and has_rice:
		print("Get SUSHI!!!!!")
		player.get_new_item("sushi")
		_reset()
	else:
		_next_stage()
