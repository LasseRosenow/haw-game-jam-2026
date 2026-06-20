extends Area2D

signal interacted_with
@export_enum("dry", "stage1", "stage2", "watered") var stage: String = "dry"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_interacted_with() -> void:
	print("Somebody interacted with the rice field :D")
	if stage == "dry":
		stage = "watered"
	
	$AnimatedSprite2D.play(stage)
