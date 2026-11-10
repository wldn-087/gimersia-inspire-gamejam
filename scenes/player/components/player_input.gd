extends Node
class_name PlayerInput

var movement_input : Vector2
var melee_attack: bool
var range_attack_hold: bool
var range_attack_release: bool

func _physics_process(delta: float) -> void:
	movement_input = Input.get_vector("left", "right", "forward", "backward")
	attack_input()

func is_running():
	return Input.is_action_pressed("run")

func attack_input():
	melee_attack = Input.is_action_just_released("attack_melee")
	range_attack_hold = Input.is_action_just_pressed("attack_range")
	range_attack_release = Input.is_action_just_released("attack_range")
	
