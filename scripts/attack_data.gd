extends Resource
class_name AttackData

@export var attack_name: StringName
@export var animation_name: StringName

@export_group("Timing")
@export var active_start_frame: int = 2
@export var active_end_frame: int = 3
@export var recovery_frame: int = 5

@export_group("Damage")
@export var damage: float = 10.0
@export var cooldown: float = 0.8

@export_group("Projectile")
@export var charge_damage: bool = false
@export var max_charge_time: float = 2.0
@export var max_damage: float = 30.0

func get_damage(charge_time: float = 0.0) -> float:
	if not charge_damage:
		return damage

	var charge := clampf(charge_time / max_charge_time, 0.0, 1.0)
	return lerpf(damage, max_damage, charge)
