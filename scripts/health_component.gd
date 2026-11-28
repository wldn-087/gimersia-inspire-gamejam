extends Node
class_name HealthComponent

signal health_changed(current_health: float, max_health: float)
signal hurt
signal died

const DEFAULT_MAX_HEALTH: float = 100.0

@export var max_health: float = DEFAULT_MAX_HEALTH
var current_health: float

var damage_resistance := 0.0

func _ready() -> void:
	current_health = max_health

func take_damage(amount: float) -> void:
	var final_damage = amount * (1.0 - damage_resistance)

	current_health = maxf(current_health - final_damage, 0.0)
	health_changed.emit(current_health, max_health)
	hurt.emit()
	if current_health <= 0.0:
		died.emit()

func heal(amount: float) -> void:
	if current_health <= 0:
		return
		
	current_health = clamp(current_health + amount, 0.0, max_health)
	health_changed.emit(current_health, max_health)
	
