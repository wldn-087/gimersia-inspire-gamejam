extends Node
class_name HealthComponent

signal health_changed(current_health: float, max_health: float)
signal died

const DEFAULT_MAX_HEALTH: float = 100.0

@export var max_health: float = DEFAULT_MAX_HEALTH
var current_health: float

func _ready() -> void:
	current_health = max_health

func take_damage(amount: float) -> void:
	if current_health <= 0:
		return
	
	current_health = clamp(current_health - amount, 0.0, max_health)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		died.emit()

func heal(amount: float) -> void:
	if current_health <= 0:
		return
		
	current_health = clamp(current_health + amount, 0.0, max_health)
	health_changed.emit(current_health, max_health)
	
