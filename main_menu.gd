extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


func _on_audio_stream_player_finished() -> void:
	$AudioStreamPlayer.play(0.0)


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://Credits.tscn")
