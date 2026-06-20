extends Node2D

signal start_animation(enable: bool)
signal change_animation(animation: String)

func _on_change_animation(animation: String) -> void:
	$ButtonsUI.animation = animation

func _on_start_animation(enable: bool) -> void:
	if enable:
		$ButtonAnimation.play("Hovering")
		$ButtonsUI.show()
	else:
		$ButtonsUI.hide()
