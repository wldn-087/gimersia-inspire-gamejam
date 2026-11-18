extends Node
class_name CombatSystem

var current_attack: AttackData
var is_attacking := false

func start_attack(attack: AttackData) -> void:
	if is_attacking or attack == null:
		return

	current_attack = attack
	is_attacking = true

	play_attack_animation(attack.animation_name)

func play_attack_animation(_animation_name: StringName) -> void:
	pass

func finish_attack() -> void:
	is_attacking = false
	current_attack = null
