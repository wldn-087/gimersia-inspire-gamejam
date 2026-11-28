
extends RefCounted
class_name BossLocomotion

var boss: BoarBoss


func _init(owner: BoarBoss) -> void:
	boss = owner


func move_to_target() -> void:
	if boss.target == null or not is_instance_valid(boss.target):
		stop()
		boss.play_boss_animation(&"idle")
		return

	var direction := boss.target.global_position - boss.global_position
	direction.y = 0.0

	var distance := direction.length()

	if distance <= boss.stop_distance:
		stop()
		boss._visual.face_target(boss.target)
		boss.play_boss_animation(&"idle")
		return

	direction = direction.normalized()

	boss.velocity.x = direction.x * boss.move_speed
	boss.velocity.z = direction.z * boss.move_speed

	boss._visual.face_target(boss.target)
	boss.play_boss_animation(&"walk")


func stop() -> void:
	boss.stop_horizontal_movement()
