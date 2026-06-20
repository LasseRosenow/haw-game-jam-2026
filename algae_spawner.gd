extends Node2D
var speed = 80
var current_algae: Node2D = null

func _ready() -> void:
	$AlgaeTimer.start(2)

func _on_algae_timer_timeout() -> void:
	if current_algae != null:
		return
		
	var item = preload("res://item.tscn").instantiate()
	item.item_type = "algae"
	item.scale.x = 3.0
	item.scale.y = 3.0
	item.position = self.position
	item.name = "Item%s" % Time.get_unix_time_from_system()
	#Awful
	get_parent().add_child(item)
	
	var new_time = randi() % 10 + 4
	$AlgaeTimer.start(new_time)
