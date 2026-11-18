extends RefCounted
class_name EnemyMovement
## Komponen gerak. Default: mengejar target sampai masuk jangkauan serang.
## Hanya mengubah velocity.x/z; gravitasi & move_and_slide tetap di Enemy.

var _enemy: Enemy


func _init(enemy: Enemy) -> void:
	_enemy = enemy


func stop() -> void:
	_enemy.velocity.x = 0.0
	_enemy.velocity.z = 0.0


func update(_delta: float) -> void:
	var target: Node3D = _enemy.target

	if target == null:
		stop()
		_enemy.play_anim("idle")
		return

	# Sudah dalam jangkauan serang: berhenti (serangan diurus EnemyCombat)
	if _enemy._is_target_in_range():
		stop()
		_enemy._visual.face_target(target)
		if not _enemy.attacking:
			_enemy.play_anim("idle")
		return

	# Di luar jangkauan: kejar
	var to_target: Vector3 = target.global_position - _enemy.global_position
	to_target.y = 0.0
	var dir: Vector3 = to_target.normalized()
	_enemy.velocity.x = dir.x * _enemy.move_speed
	_enemy.velocity.z = dir.z * _enemy.move_speed
	_enemy._visual.face_target(target)
	_enemy.play_anim("walk")
