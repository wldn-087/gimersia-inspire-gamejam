
extends CombatSystem
class_name BossCombat

const CHARGE_ANIMATION: StringName = &"charge"
const RUN_ATTACK_ANIMATION: StringName = &"run_attack"
const SLIDE_ANIMATION: StringName = &"slide"

const CHARGE_SPEED: float = 9.0
const SLIDE_DECELERATION: float = 18.0

var boss: BoarBoss
var attacks: Array[AttackData] = []
var cooldowns: Dictionary = {}

var is_charge_running := false
var is_sliding := false

var charge_direction := Vector3.ZERO
var hitbox_active := false

var sequence_id := 0


func _init(
	owner: BoarBoss,
	configured_attacks: Array[AttackData]
) -> void:
	boss = owner

	for attack in configured_attacks:
		if attack != null:
			attacks.append(attack)

	boss.boss_sprite.frame_changed.connect(_on_frame_changed)


func update(delta: float) -> void:
	_update_cooldowns(delta)
	_update_charge_movement(delta)


func _update_cooldowns(delta: float) -> void:
	for attack_name in cooldowns.keys():
		cooldowns[attack_name] = maxf(
			float(cooldowns[attack_name]) - delta,
			0.0
		)


func _update_charge_movement(delta: float) -> void:
	if is_charge_running:
		boss.velocity.x = charge_direction.x * CHARGE_SPEED
		boss.velocity.z = charge_direction.z * CHARGE_SPEED

	elif is_sliding:
		boss.velocity.x = move_toward(
			boss.velocity.x,
			0.0,
			SLIDE_DECELERATION * delta
		)

		boss.velocity.z = move_toward(
			boss.velocity.z,
			0.0,
			SLIDE_DECELERATION * delta
		)


func try_attack(distance: float) -> bool:
	if is_attacking:
		return false

	var available_attacks: Array[AttackData] = []

	for attack in attacks:
		var cooldown_left := float(
			cooldowns.get(attack.attack_name, 0.0)
		)

		if cooldown_left > 0.0:
			continue

		if distance > attack.attack_range:
			continue

		available_attacks.append(attack)

	if available_attacks.is_empty():
		return false

	var selected_attack: AttackData = available_attacks.pick_random()

	cooldowns[selected_attack.attack_name] = selected_attack.cooldown

	start_attack(selected_attack)
	return true


func start_attack(attack: AttackData) -> void:
	if is_attacking or attack == null:
		return

	current_attack = attack
	is_attacking = true

	sequence_id += 1
	var current_sequence := sequence_id

	print("[Boss] Attack triggered: ", attack.attack_name)

	if attack.attack_name == &"charge_attack":
		await _execute_charge_attack(current_sequence)
	else:
		await _execute_normal_attack(current_sequence, attack)


func _execute_charge_attack(current_sequence: int) -> void:
	# Phase 1: Charge preparation.
	_set_hitbox_active(false)
	boss.stop_horizontal_movement()

	var finished := await _play_and_wait(CHARGE_ANIMATION)

	if not finished:
		_finish_current_attack()
		return

	if not _is_sequence_valid(current_sequence):
		return

	# Lock direction before running.
	charge_direction = _get_charge_direction()

	# Phase 2: Run attack.
	is_charge_running = true
	_set_hitbox_active(true)

	finished = await _play_and_wait(RUN_ATTACK_ANIMATION)

	if not _is_sequence_valid(current_sequence):
		return

	_set_hitbox_active(false)
	is_charge_running = false

	if not finished:
		boss.stop_horizontal_movement()
		_finish_current_attack()
		return

	# Phase 3: Slide.
	is_sliding = true

	finished = await _play_and_wait(SLIDE_ANIMATION)

	if not _is_sequence_valid(current_sequence):
		return

	is_sliding = false
	boss.stop_horizontal_movement()

	_finish_current_attack()


func _execute_normal_attack(
	current_sequence: int,
	attack: AttackData
) -> void:
	_set_hitbox_active(false)

	var finished := await _play_and_wait(attack.animation_name)

	if not _is_sequence_valid(current_sequence):
		return

	_set_hitbox_active(false)

	if not finished:
		push_warning(
			"[Boss] Animation not found: " + str(attack.animation_name)
		)

	_finish_current_attack()


func _get_charge_direction() -> Vector3:
	if boss.target == null or not is_instance_valid(boss.target):
		return Vector3.RIGHT

	var direction := boss.target.global_position - boss.global_position
	direction.y = 0.0

	if direction.length_squared() < 0.001:
		return Vector3.RIGHT

	return direction.normalized()


func _play_and_wait(animation_name: StringName) -> bool:
	if not is_instance_valid(boss):
		return false

	if not boss.boss_sprite.sprite_frames.has_animation(animation_name):
		push_warning(
			"[Boss] Missing animation: " + str(animation_name)
		)
		return false

	boss.boss_sprite.play(animation_name)
	await boss.boss_sprite.animation_finished

	return is_instance_valid(boss)


func _on_frame_changed() -> void:
	if not is_attacking or current_attack == null:
		return

	if is_charge_running or is_sliding:
		return

	if boss.boss_sprite.animation != current_attack.animation_name:
		return

	var frame := boss.boss_sprite.frame

	var should_be_active := (
		frame >= current_attack.active_start_frame
		and frame <= current_attack.active_end_frame
	)

	_set_hitbox_active(should_be_active)


func _set_hitbox_active(active: bool) -> void:
	if hitbox_active == active:
		return

	hitbox_active = active

	if active:
		boss.attack_hitbox.activate(current_attack)
	else:
		boss.attack_hitbox.deactivate()


func _is_sequence_valid(expected_sequence: int) -> bool:
	return (
		is_instance_valid(boss)
		and not boss.is_dead
		and is_attacking
		and sequence_id == expected_sequence
	)


func _finish_current_attack() -> void:
	_set_hitbox_active(false)

	is_charge_running = false
	is_sliding = false

	finish_attack()


func stop() -> void:
	# Invalidasi proses async yang masih menunggu animasi.
	sequence_id += 1

	_set_hitbox_active(false)

	is_charge_running = false
	is_sliding = false

	if is_instance_valid(boss):
		boss.stop_horizontal_movement()

	finish_attack()
