extends Node2D

@export var speed_increase_ratio: float = 0.90
@export var lives: int = 3
@export var highscore: int = 0
@export var success_base_points: int = 100

var speed_increasd_blabla = 1.0

signal failed_task
signal success_task(rate: float)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Music.play(0.0)
	_on_timer_timeout()

func update_highscore(addition: int) -> void:
	highscore += addition
	$Highscore.text = "Highscore: %s" % highscore

func remove_live() -> void:
	$Lives.get_node("%s" % lives).hide()
	lives -= 1
	
	if lives == 0:
		var game_over = preload("res://GameOver.tscn").instantiate()
		game_over.set_highscore(highscore)
		get_tree().change_scene_to_node(game_over)
	elif lives == 2:
		$Music.stream = AudioStreamWAV.load_from_file("res://audio/MainFaster.wav")
		$Music.play(0.0)
	elif lives == 1:
		$Music.stream = AudioStreamWAV.load_from_file("res://audio/MainFastest.wav")		
		$Music.play(0.0)
		
func _on_failed_task() -> void:
	update_highscore(-50)
	remove_live()


func _on_success_task(rate: float) -> void:
	update_highscore(success_base_points * rate)
	$Timer.wait_time *= speed_increase_ratio
	speed_increasd_blabla *= speed_increase_ratio

func _on_music_finished() -> void:
	$Music.play(0.0)

func _on_timer_timeout() -> void:
	var slot_to_check = randi() % 3 + 1
	
	var node = get_node("Slot%s" % slot_to_check)
	if node.get_children().size() == 0:
		print("Slot was free, filling")
		
		var wants_id = randi() % 10 + 1
		var wants = "sushi"
		
		if wants_id == 1:
			wants = "fish"
		elif wants_id == 2:
			wants = "rice"
		elif wants_id == 3 or wants_id == 4:
			wants = "cooked_rice"
		elif wants_id == 5 or wants_id == 6:
			wants = "cut_fish"
		else:
			wants = "sushi"
		
		var customer: RigidBody2D = preload("res://customer.tscn").instantiate()
		customer.set_up_customer(wants, 850 * speed_increasd_blabla)
		customer.position = node.position
		customer.scale.x *= 2
		customer.scale.y *= 2
		node.add_child(customer)
	else:
		print("Tried to add customer but slot was filled")
