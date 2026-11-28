
extends CombatSystem
class_name BossCombat

const CHARGE_ANIMATION: StringName = &"charge"
const RUN_ATTACK_ANIMATION: StringName = &"run_attack"
const SLIDE_ANIMATION: StringName = &"slide"

const CHARGE_SPEED: float = 9.0
const SLIDE_DECELERATION: float = 12.0
const SLIDE_MIN_SPEED: float = 0.2

const RUN_ATTACK_MAX_DURATION: float = 1.2
const RUN_ATTACK_MAX_DISTANCE: float = 8.0

var attack_cooldown_timer: float = 0.0

var boss: BoarBoss
var attacks: Array[AttackData] = []

var is_charge_running: bool = false
var is_sliding: bool = false

var charge_direction: Vector3 = Vector3.ZERO
var charge_start_position: Vector3 = Vector3.ZERO

var active_hitbox: BossAttackHitbox

var sequence_id: int = 0


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


# ==================================================
# COOLDOWN
# ==================================================

func _update_cooldowns(delta: float) -> void:
	if attack_cooldown_timer > 0.0:
		attack_cooldown_timer = maxf(
			attack_cooldown_timer - delta,
			0.0
		)


# ==================================================
# MOVEMENT
# ==================================================

func _update_charge_movement(delta: float) -> void:
	if is_charge_running:
		boss.velocity.x = charge_direction.x * CHARGE_SPEED
		boss.velocity.z = charge_direction.z * CHARGE_SPEED

	elif is_sliding:
		var horizontal_velocity := Vector3(
			boss.velocity.x,
			0.0,
			boss.velocity.z
		)

		horizontal_velocity = horizontal_velocity.move_toward(
			Vector3.ZERO,
			SLIDE_DECELERATION * delta
		)

		boss.velocity.x = horizontal_velocity.x
		boss.velocity.z = horizontal_velocity.z

		if horizontal_velocity.length() <= SLIDE_MIN_SPEED:
			boss.velocity.x = 0.0
			boss.velocity.z = 0.0


func _stop_attack_movement() -> void:
	boss.velocity.x = 0.0
	boss.velocity.z = 0.0


# ==================================================
# ATTACK SELECTION
# ==================================================

func try_attack(_distance: float = 0.0) -> bool:
	if is_attacking:
		return false

	if attack_cooldown_timer > 0.0:
		return false

	var selected_attack: AttackData = select_attack()

	if selected_attack == null:
		return false

	start_attack(selected_attack)
	return true


func select_attack() -> AttackData:
	if boss.target == null:
		return null

	if not is_instance_valid(boss.target):
		return null

	if attack_cooldown_timer > 0.0:
		return null

	var available_attacks: Array[AttackData] = []

	var distance: float = boss.global_position.distance_to(
		boss.target.global_position
	)

	for attack in attacks:
		if attack == null:
			continue

		# Lahan hanya bisa diserang menggunakan Tusk Swing.
		if boss.target is Lahan:
			if attack.attack_name != &"tusk_swing":
				continue

		# Periksa jarak serangan.
		if distance > attack.attack_range:
			continue

		available_attacks.append(attack)

	if available_attacks.is_empty():
		return null

	return available_attacks.pick_random()


# ==================================================
# ATTACK EXECUTION
# ==================================================

func start_attack(attack: AttackData) -> void:
	if is_attacking or attack == null:
		return

	if attack_cooldown_timer > 0.0:
		return

	if boss.get_attack_hitbox(attack.hitbox_name) == null:
		push_warning(
			"[Boss] Invalid hitbox for attack: " + str(attack.attack_name)
		)
		return

	current_attack = attack
	is_attacking = true

	sequence_id += 1
	var current_sequence := sequence_id

	print("[Boss] Attack triggered: ", attack.attack_name)

	if attack.attack_name == &"charge_attack":
		await _execute_charge_attack(current_sequence, attack)
	else:
		await _execute_normal_attack(current_sequence, attack)


# ==================================================
# CHARGE ATTACK
# ==================================================

func _execute_charge_attack(
	current_sequence: int,
	attack: AttackData
) -> void:
	_deactivate_hitbox()
	_stop_attack_movement()

	# Phase 1: Charge preparation.
	var finished := await _play_and_wait(CHARGE_ANIMATION)

	if not _is_sequence_valid(current_sequence):
		return

	if not finished:
		_finish_current_attack()
		return

	# Tentukan arah charge.
	charge_direction = _get_charge_direction()
	charge_start_position = boss.global_position

	# Phase 2: Run Attack.
	is_charge_running = true

	boss.play_boss_animation(RUN_ATTACK_ANIMATION)
	_activate_hitbox(attack)

	var elapsed: float = 0.0

	while (
		elapsed < RUN_ATTACK_MAX_DURATION
		and _get_charge_distance() < RUN_ATTACK_MAX_DISTANCE
	):
		if not _is_sequence_valid(current_sequence):
			return

		await boss.get_tree().physics_frame
		elapsed += 1.0 / float(
			Engine.physics_ticks_per_second
		)

	_deactivate_hitbox()

	if not _is_sequence_valid(current_sequence):
		return

	# Phase 3: Slide.
	is_charge_running = false
	is_sliding = true

	boss.play_boss_animation(SLIDE_ANIMATION)

	# Tunggu sampai momentum charge habis.
	while true:
		if not _is_sequence_valid(current_sequence):
			return

		var horizontal_speed := Vector2(
			boss.velocity.x,
			boss.velocity.z
		).length()

		if horizontal_speed <= SLIDE_MIN_SPEED:
			break

		await boss.get_tree().physics_frame

	is_sliding = false
	_stop_attack_movement()

	_finish_current_attack()


# ==================================================
# NORMAL ATTACK
# ==================================================

func _execute_normal_attack(
	current_sequence: int,
	attack: AttackData
) -> void:
	_deactivate_hitbox()
	_stop_attack_movement()

	var finished := await _play_and_wait(attack.animation_name)

	if not _is_sequence_valid(current_sequence):
		return

	_deactivate_hitbox()

	if not finished:
		push_warning(
			"[Boss] Animation not found: " + str(attack.animation_name)
		)

	_finish_current_attack()


# ==================================================
# CHARGE UTILITIES
# ==================================================

func _get_charge_direction() -> Vector3:
	if boss.target == null or not is_instance_valid(boss.target):
		return Vector3.RIGHT

	var direction: Vector3 = (
		boss.target.global_position - boss.global_position
	)

	direction.y = 0.0

	if direction.length_squared() < 0.001:
		return Vector3.RIGHT

	return direction.normalized()


func _get_charge_distance() -> float:
	var offset: Vector3 = (
		boss.global_position - charge_start_position
	)

	offset.y = 0.0

	return offset.length()


# ==================================================
# ANIMATION
# ==================================================

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

	var frame: int = boss.boss_sprite.frame

	var should_be_active: bool = (
		frame >= current_attack.active_start_frame
		and frame <= current_attack.active_end_frame
	)

	if should_be_active:
		_activate_hitbox(current_attack)
	else:
		_deactivate_hitbox()


# ==================================================
# HITBOX
# ==================================================

func _activate_hitbox(attack: AttackData) -> void:
	var requested_hitbox: BossAttackHitbox = (
		boss.get_attack_hitbox(attack.hitbox_name)
	)

	if requested_hitbox == null:
		return

	if active_hitbox == requested_hitbox:
		return

	_deactivate_hitbox()

	active_hitbox = requested_hitbox
	active_hitbox.activate(attack)


func _deactivate_hitbox() -> void:
	if active_hitbox == null:
		return

	if is_instance_valid(active_hitbox):
		active_hitbox.deactivate()

	active_hitbox = null


# ==================================================
# ATTACK CONTROL
# ==================================================

func _is_sequence_valid(expected_sequence: int) -> bool:
	return (
		is_instance_valid(boss)
		and not boss.is_dead
		and is_attacking
		and sequence_id == expected_sequence
	)


func _finish_current_attack() -> void:
	_deactivate_hitbox()

	is_charge_running = false
	is_sliding = false

	# Cooldown dimulai setelah seluruh serangan selesai.
	if current_attack != null:
		attack_cooldown_timer = current_attack.cooldown

	print(
		"[Boss] Attack finished. Cooldown: ",
		attack_cooldown_timer
	)

	finish_attack()


func stop() -> void:
	sequence_id += 1

	_deactivate_hitbox()

	is_charge_running = false
	is_sliding = false

	if is_instance_valid(boss):
		boss.stop_horizontal_movement()

	finish_attack()
