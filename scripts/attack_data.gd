extends Resource
class_name AttackData

@export var attack_name: StringName
@export var animation_name: StringName

@export_group("Range")
@export var attack_range: float = 2.5

@export_group("Timing")
@export var active_start_frame: int = 2
@export var active_end_frame: int = 3
@export var recovery_frame: int = 5

@export_group("Damage")
@export var damage: float = 10.0
@export var cooldown: float = 0.8

@export_group("Hitbox")
@export var hitbox_name: StringName
