extends Node
class_name PlayerLocomotion

var player: Player
var input_handler : PlayerInput

var current_speed = 0.0
var move_dir : Vector3
var target_velocity: Vector3

func start(owner: Player):
	player = owner
	input_handler = player.player_input

func move(delta: float):
	var move_input = input_handler.movement_input
	move_dir = Vector3(move_input.x, 0, move_input.y).normalized()
	
	if input_handler.is_running():
		current_speed = player.run_speed
	else:
		current_speed = player.move_speed
	
	target_velocity = move_dir * current_speed
	
	var current_velocity := Vector3(player.velocity.x, 0.0, player.velocity.z)
	
	if move_dir != Vector3.ZERO:
		current_velocity = current_velocity.move_toward(target_velocity, player.acceleration * delta)
	else:
		current_velocity = current_velocity.move_toward(target_velocity, player.decceleration * delta)
	
	player.velocity.x = current_velocity.x
	player.velocity.z = current_velocity.z
