
extends Node
class_name PlayerLocomotion

var player: Player
var input_handler: PlayerInput
var anim_player: AnimationHandler

var current_speed := 0.0
var move_dir := Vector3.ZERO
var target_velocity := Vector3.ZERO

var facing_direction := Vector3.RIGHT

@export var dash_duration := 0.2

var is_dashing := false
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_remaining_distance := 0.0


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

	if anim_player.on_action:
		is_dashing = false
		player.velocity.x = 0.0
		player.velocity.z = 0.0
		return

	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer = maxf(dash_cooldown_timer - delta, 0.0)

	var move_input = input_handler.movement_input
	move_dir = Vector3(move_input.x, 0.0, move_input.y).normalized()

	if input_handler.is_dashing():
		start_dash()

	if update_dash(delta):
		return

	var current_velocity := player.velocity

	if input_handler.is_running():
		current_speed = player.run_speed
	else:
		current_speed = player.move_speed

	target_velocity = move_dir * current_speed * player._speed

	if move_dir != Vector3.ZERO:
		facing_direction = move_dir
		current_velocity = current_velocity.move_toward(
			target_velocity,
			player.acceleration * delta
		)

		anim_player.body_anim_play(
			"walk" if not input_handler.is_running() else "run"
		)

		if move_dir.x < 0.0:
			anim_player.body.flip_h = true
		elif move_dir.x > 0.0:
			anim_player.body.flip_h = false
	else:
		current_velocity = current_velocity.move_toward(
			Vector3.ZERO,
			player.decceleration * delta
		)

		anim_player.body_anim_play("idle")

	player.velocity.x = current_velocity.x
	player.velocity.z = current_velocity.z


func start_dash() -> void:
	if is_dashing or dash_cooldown_timer > 0.0:
		return

	facing_direction = facing_direction.normalized()

	is_dashing = true
	dash_timer = dash_duration
	dash_remaining_distance = player._dash_range
	dash_cooldown_timer = player._dash_cooldown


func update_dash(delta: float) -> bool:
	if not is_dashing:
		return false

	dash_timer -= delta

	var dash_speed = player._dash_range / dash_duration
	var distance_this_frame = minf(
		dash_speed * delta,
		dash_remaining_distance
	)

	if delta > 0.0:
		player.velocity.x = facing_direction.x * distance_this_frame / delta
		player.velocity.z = facing_direction.z * distance_this_frame / delta

	dash_remaining_distance -= distance_this_frame

	if dash_remaining_distance <= 0.001 or dash_timer <= 0.0:
		is_dashing = false
		player.velocity.x = 0.0
		player.velocity.z = 0.0

	return true
