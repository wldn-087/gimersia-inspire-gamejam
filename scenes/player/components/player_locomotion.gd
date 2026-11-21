extends Node
class_name PlayerLocomotion

var player: Player
var input_handler : PlayerInput
var anim_player: AnimationHandler

var current_speed = 0.0
var move_dir : Vector3
var target_velocity: Vector3

var facing_direction := Vector3.RIGHT

func start(owner: Player):
	player = owner
	input_handler = player.player_input
	anim_player = player.anim_player

func gravity(delta: float):
	if player.is_on_floor():
		player.velocity.y = -0.2
	else:
		player.velocity.y -= 40.0 * delta

func move(delta: float):
	gravity(delta)
	var move_input = input_handler.movement_input
	move_dir = Vector3(move_input.x, 0, move_input.y).normalized()
	var current_velocity := player.velocity
	
	if input_handler.is_running():
		current_speed = player.run_speed
	else:
		current_speed = player.move_speed
	
	target_velocity = move_dir * current_speed
	
	if move_dir != Vector3.ZERO:
		facing_direction = move_dir
		current_velocity = current_velocity.move_toward(target_velocity, player.acceleration * delta)
		anim_player.body_anim_play("walk" if !input_handler.is_running() else "run")
		if move_dir.x < 0:
			anim_player.body.flip_h = true
		if move_dir.x > 0:
			anim_player.body.flip_h = false
	else:
		current_velocity = current_velocity.move_toward(target_velocity, player.decceleration * delta)
		anim_player.body_anim_play("idle")
	
	player.velocity.x = current_velocity.x
	player.velocity.z = current_velocity.z
