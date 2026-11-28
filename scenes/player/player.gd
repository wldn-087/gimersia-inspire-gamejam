extends CharacterBody3D
class_name Player

@onready var player_input: PlayerInput = $Components/PlayerInput
@onready var player_locomotion: PlayerLocomotion = $Components/PlayerLocomotion
@onready var anim_player: AnimationHandler = $Components/AnimationHandler
@onready var player_combat: PlayerCombat = $Components/PlayerCombat
@onready var health_component: HealthComponent = $Components/HealthComponent

@export_group("Movemnet")
@export var move_speed = 5.0
@export var run_speed = 8.0
@export var acceleration = 18.0
@export var decceleration = 25.0

@export_group("Stat Multiplier")
@export var _damage := 1.0
@export var _speed := 1.0
@export var _dash_range := 3.0
@export var _dash_cooldown := 1.0
@export_range(0.0, 0.8, 0.05) var _resistance := 0.0

func _ready() -> void:
	player_locomotion.start(self)
	player_combat.start(self)
	anim_player.initialize(self)
	health_component.damage_resistance = _resistance

func _physics_process(delta: float) -> void:
	player_locomotion.move(delta)
	player_combat.input_check()
	player_combat.update_hitbox_position()
	move_and_slide()

func get_save_data() -> Dictionary:
	return {
		"health": health_component.current_health,
		"max_health": health_component.max_health,
		"damage": _damage,
		"dash_range": _dash_range,
		"dash_cooldown": _dash_cooldown,
		"speed": _speed,
		"resistance": _resistance
	}

func apply_save_data(data:Dictionary):
	health_component.max_health = float(data.get("max_health", health_component.max_health))
	health_component.current_health = clamp(float(data.get("health", health_component.current_health)), 0.0, health_component.max_health)
	health_component.damage_resistance = _resistance
	_damage = float(data.get("damage", _damage))
	_dash_range = float(data.get("dash_range", _dash_range))
	_dash_cooldown = float(data.get("dash_cooldown", _dash_cooldown))
	_speed = float(data.get("speed", _speed))
	_resistance = clampf(float(data.get("resistance", _resistance)), 0.0, 0.8)
