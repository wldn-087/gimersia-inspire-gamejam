extends Area3D
class_name Lahan

@onready var health_component: HealthComponent = $HealthComponent

func _ready() -> void:
	# Hubungkan sinyal 'died' ke fungsi _on_lahan_died
	health_component.died.connect(_on_lahan_died)

func _on_lahan_died() -> void:
	print("Lahan hancur!")
