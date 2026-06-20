extends RigidBody2D

@export var type = "RiceField"

signal interacted_with
@export_enum("dry", "stage1", "stage2", "watered") var stage: String = "dry"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ButtonUI.emit_signal("change_animation", "Water")
	$ButtonUI.emit_signal("start_animation", true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_interacted_with() -> void:
	print("Somebody interacted with the rice field :D")
	if stage == "dry":
		stage = "watered"
		$ButtonUI.emit_signal("change_animation", "Wait")
		$GrowTimer.start(5)
	
	$AnimatedSprite2D.play(stage)


func _on_grow_timer_timeout() -> void:
	if stage == "watered":
		stage = "stage1"
		$GrowTimer.start(5)
	elif stage == "stage1":
		stage = "stage2"
		$GrowTimer.start(5)
	elif stage == "stage2":
		$ButtonUI.emit_signal("change_animation", "Done")

	$AnimatedSprite2D.play(stage)
