
extends RefCounted
class_name BossCombat

var boss: BoarBoss

var is_attacking := false
var cooldowns := {
	"tusk_swing": 0.0,
	"ground_slam": 0.0,
	"charge": 0.0
}

var attack_settings := {
	"tusk_swing": {
		"damage": 20.0,
		"range": 2.5,
		"cooldown": 3.0,
		"hit_delay": 0.45
	},
	"ground_slam": {
		"damage": 30.0,
		"range": 4.0,
		"cooldown": 6.0,
		"hit_delay": 0.9
	},
	"charge": {
		"damage": 25.0,
		"range": 3.0,
		"cooldown": 5.0,
		"hit_delay": 0.5
	}
}


func _init(owner: BoarBoss) -> void:
	boss = owner


func update(delta: float) -> void:
	for attack_name in cooldowns:
		cooldowns[attack_name] = maxf(
			cooldowns[attack_name] - delta,
			0.0
		)


func can_attack(attack_name: String) -> bool:
	if is_attacking:
		return false

	if cooldowns[attack_name] > 0.0:
		return false

	return true


func use_attack(attack_name: String) -> void:
	if not can_attack(attack_name):
		return

	if boss.target == null:
		return

	is_attacking = true

	var settings: Dictionary = attack_settings[attack_name]
	cooldowns[attack_name] = settings["cooldown"]

	boss.velocity.x = 0.0
	boss.velocity.z = 0.0

	boss.play_boss_animation(attack_name)

	await boss.get_tree().create_timer(
		settings["hit_delay"]
	).timeout

	if not is_instance_valid(boss) or boss.is_dead:
		return

	_apply_damage(
		settings["damage"],
		settings["range"]
	)

	var animation := boss.boss_sprite

	if animation.animation == attack_name:
		await animation.animation_finished

	if is_instance_valid(boss) and not boss.is_dead:
		is_attacking = false


func _apply_damage(amount: float, attack_range: float) -> void:
	if boss.target == null or not is_instance_valid(boss.target):
		return

	var distance := boss.global_position.distance_to(
		boss.target.global_position
	)

	if distance > attack_range:
		return

	var target_node := boss.target

	if target_node.has_method("take_damage"):
		target_node.take_damage(amount)
	elif target_node.has_node("HealthComponent"):
		var health = target_node.get_node("HealthComponent")
		health.take_damage(amount)


func stop() -> void:
	is_attacking = false
