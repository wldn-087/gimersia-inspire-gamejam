extends Area3D
class_name Lahan

@export var save_id := 0

@onready var health_component: HealthComponent = $HealthComponent
@onready var plant: Node3D = $Plant

@export_group("Plant Growth")
@export var growth_textures: Array[Texture2D] = []
var plant_mesh: MeshInstance3D

var current_growth_stage := 0

func _ready() -> void:
	add_to_group("saveable_plants")
	
	health_component.died.connect(_on_lahan_died)
	plant_mesh = $Plant/Plane_057
	
func apply_growth_stage(stage: int) -> void:
	if growth_textures.is_empty():
		return

	if plant_mesh == null:
		push_warning("Lahan: Plant Mesh belum diatur.")
		return

	if plant_mesh.mesh == null:
		push_warning("Lahan: Mesh tanaman belum diatur.")
		return
	current_growth_stage = clampi(stage, 0, growth_textures.size() - 1)
	print(current_growth_stage)

	var texture = growth_textures[current_growth_stage]

	for surface in range(plant_mesh.mesh.get_surface_count()):
		var material = plant_mesh.get_active_material(surface)

		if material is ShaderMaterial:
			var new_material = material.duplicate() as ShaderMaterial

			new_material.set_shader_parameter("albedo_texture", texture)

			plant_mesh.set_surface_override_material(surface, new_material)

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
