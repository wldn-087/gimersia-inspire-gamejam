extends RefCounted
class_name EnemyHealth
## Komponen darah musuh. Tidak tahu apa-apa soal gerak/animasi.

signal depleted

var max_health: float
var current: float
var is_dead: bool = false


func _init(p_max_health: float) -> void:
	max_health = p_max_health
	current = p_max_health


func reset(p_max_health: float) -> void:
	max_health = p_max_health
	current = p_max_health


func take_damage(amount: float) -> void:
	if is_dead:
		return
	current -= amount
	if current <= 0.0:
		kill()


func kill() -> void:
	if is_dead:
		return
	is_dead = true
	depleted.emit()
