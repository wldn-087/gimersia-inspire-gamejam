extends Area3D
class_name Lahan

@export var save_id := 0

@onready var health_component: HealthComponent = $HealthComponent

func _ready() -> void:
	add_to_group("saveable_plants")
	
	health_component.died.connect(_on_lahan_died)
	
func get_save_data() -> Dictionary:
	return {
		"health": health_component.current_health,
		"max_health": health_component.max_health
	}

func apply_save_data(data:Dictionary):
	health_component.max_health = float(data.get("max_health", health_component.max_health))
	health_component.current_health = clamp(float(data.get("health", health_component.current_health)), 0.0, health_component.max_health)


func _on_lahan_died() -> void:
	print("Lahan hancur!")
