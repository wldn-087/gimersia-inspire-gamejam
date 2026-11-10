extends Node
class_name PlayerInput

var movement_input : Vector2

func _physics_process(delta: float) -> void:
	movement_input = Input.get_vector("left", "right", "forward", "backward")

func is_running():
	return Input.is_action_pressed("run")
