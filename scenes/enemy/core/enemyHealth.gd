extends RefCounted
class_name EnemyHealth

signal depleted
signal health_changed(current: float, max: float)

var max_health: float
var current: float
var is_dead: bool = false


func _init(p_max_health: float) -> void:
	max_health = p_max_health
	current = p_max_health


func reset(p_max_health: float) -> void:
	max_health = p_max_health
	current = p_max_health
	health_changed.emit(current, max_health)


func take_damage(amount: float) -> void:
	if is_dead:
		return

	current = maxf(current - amount, 0.0)
	health_changed.emit(current, max_health)

	if current <= 0.0:
		kill()


func kill() -> void:
	if is_dead:
		return

	is_dead = true
	depleted.emit()
