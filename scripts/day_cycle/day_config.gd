extends Resource
class_name DayConfig

@export_group("Day")
@export var day_number: int

@export_group("Timer")
@export var preparation_duration: float = 45.0
@export var combat_min_duration: float = 90.0

@export_group("Enemy Stats")
@export var enemy_health_multiplier: float = 1.0
@export var enemy_damage_multiplier: float = 1.0
@export var enemy_aggressiveness: float = 1.0

@export_group("Spawn Settings")
@export var spawn_rate: float = 5.0
@export var spawn_rate_speed: float = 1.0

@export_group("Spawn Weight")
@export var worm_spawn_weight: float = 1.0
@export var rat_spawn_weight: float = 1.0
