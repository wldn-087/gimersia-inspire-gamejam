extends RefCounted
class_name EnemyCombat
## Komponen serangan: cooldown, jeda hit, dan durasi state menyerang.
## Cara cek jangkauan & isi serangan tetap di-override lewat hook di Enemy.

var attacking: bool = false

var _enemy: Enemy
var _cooldown_left: float = 0.0


func _init(enemy: Enemy) -> void:
	_enemy = enemy


func tick(delta: float) -> void:
	_cooldown_left -= delta


func try_attack() -> void:
	if _cooldown_left > 0.0 or not _enemy._is_target_in_range():
		return
	_start_attack()


func _start_attack() -> void:
	attacking = true
	_cooldown_left = _enemy.attack_cooldown
	_enemy.play_anim("attack")

	await _enemy.get_tree().create_timer(_enemy.attack_hit_delay).timeout
	if not is_instance_valid(_enemy) or _enemy.is_dead:
		return
	if _enemy._is_target_in_range(): 
		print("ATTACK")  # kalau player sempat menghindar, serangan meleset
		_enemy._perform_attack()

	var remaining: float = maxf(_enemy.attack_duration - _enemy.attack_hit_delay, 0.0)
	await _enemy.get_tree().create_timer(remaining).timeout
	attacking = false
