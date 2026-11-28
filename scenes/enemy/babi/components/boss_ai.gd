
extends RefCounted
class_name BossAI

var boss: BoarBoss
var locomotion: BossLocomotion
var combat: BossCombat

var think_timer := 0.0
var think_interval := 0.25


func _init(
	owner: BoarBoss,
	movement: BossLocomotion,
	attack: BossCombat
) -> void:
	boss = owner
	locomotion = movement
	combat = attack


func update(delta: float) -> void:
	combat.update(delta)

	if boss.target == null:
		locomotion.stop()
		return

	if combat.is_attacking:
		locomotion.stop()
		return

	if locomotion.is_charging:
		return

	think_timer -= delta

	if think_timer > 0.0:
		return

	think_timer = think_interval

	var distance := boss.global_position.distance_to(
		boss.target.global_position
	)

	_choose_action(distance)


func _choose_action(distance: float) -> void:
	if distance <= 2.5:
		locomotion.stop()

		if combat.can_attack("tusk_swing"):
			combat.use_attack("tusk_swing")
		elif combat.can_attack("ground_slam"):
			combat.use_attack("ground_slam")

	elif distance <= 4.0:
		locomotion.stop()

		if combat.can_attack("ground_slam"):
			combat.use_attack("ground_slam")
		else:
			locomotion.move_to_target()

	else:
		if combat.can_attack("charge"):
			locomotion.start_charge()
			combat.use_attack("charge")
		else:
			locomotion.move_to_target()


func stop() -> void:
	locomotion.stop()
	combat.stop()
