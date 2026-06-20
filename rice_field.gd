extends RigidBody2D

@export var type = "RiceField"

signal interacted_with
@export_enum("dry", "stage1", "stage2", "harvested", "watered") var stage: String = "dry"

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
		$ButtonUI.emit_signal("start_animation", true)
		$GrowTimer.start(5)
		$AnimatedSprite2D.play(stage)
	elif stage == "stage2":
		stage = "harvested"
		$AnimatedSprite2D.play("watered")
		$ButtonUI.emit_signal("start_animation", false)
		$GrowTimer.start(10)


func _on_grow_timer_timeout() -> void:
	if stage == "watered":
		stage = "stage1"
		$GrowTimer.start(5)
	elif stage == "stage1":
		stage = "stage2"
		$GrowTimer.start(5)
	elif stage == "stage2":
		$ButtonUI.emit_signal("change_animation", "Done")
	elif stage == "harvested":
		stage = "dry"
		$ButtonUI.emit_signal("change_animation", "Water")
		$ButtonUI.emit_signal("start_animation", true)
		
	$AnimatedSprite2D.play(stage)
