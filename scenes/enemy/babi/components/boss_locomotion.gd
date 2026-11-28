
extends RefCounted
class_name BossLocomotion

var boss: BoarBoss

var move_speed := 3.0
var charge_speed := 12.0
var charge_duration := 0.8

var is_charging := false
var charge_direction := Vector3.ZERO
var charge_timer := 0.0


func _init(owner: BoarBoss) -> void:
	boss = owner


func update(delta: float) -> void:
	if is_charging:
		_update_charge(delta)


func move_to_target() -> void:
	if boss.target == null:
		stop()
		boss.play_boss_animation("idle")
		return

	var direction := boss.target.global_position - boss.global_position
	direction.y = 0.0

	if direction.length() < 0.1:
		stop()
		return

	direction = direction.normalized()

	boss.velocity.x = direction.x * move_speed
	boss.velocity.z = direction.z * move_speed

	_face_direction(direction)
	boss.play_boss_animation("walk")


func start_charge() -> void:
	if is_charging or boss.target == null:
		return

	charge_direction = boss.target.global_position - boss.global_position
	charge_direction.y = 0.0
	charge_direction = charge_direction.normalized()

	charge_timer = charge_duration
	is_charging = true

	_face_direction(charge_direction)
	boss.play_boss_animation("charge")


func _update_charge(delta: float) -> void:
	charge_timer -= delta

	boss.velocity.x = charge_direction.x * charge_speed
	boss.velocity.z = charge_direction.z * charge_speed

	if charge_timer <= 0.0:
		is_charging = false
		stop()
		boss.play_boss_animation("idle")


func stop() -> void:
	boss.velocity.x = 0.0
	boss.velocity.z = 0.0


func _face_direction(direction: Vector3) -> void:
	if absf(direction.x) > 0.1:
		boss._visual.set_facing(direction.x < 0.0)
