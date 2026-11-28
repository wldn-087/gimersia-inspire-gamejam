extends CombatSystem
class_name BossCombat

var boss: BoarBoss
var attacks: Array[AttackData] = []
var cooldowns: Dictionary = {}


func _init(owner: BoarBoss) -> void:
	boss = owner
	_create_attacks()


func update(delta: float) -> void:
	for attack_name in cooldowns.keys():
		cooldowns[attack_name] = maxf(
			float(cooldowns[attack_name]) - delta,
			0.0
		)


func try_attack(distance: float) -> bool:
	if is_attacking:
		return false

	var available_attacks: Array[AttackData] = []

	for attack in attacks:
		var cooldown_left := float(cooldowns.get(attack.attack_name, 0.0))

		if cooldown_left <= 0.0 and distance <= attack.attack_range:
			available_attacks.append(attack)

	if available_attacks.is_empty():
		return false

	var selected_attack: AttackData = available_attacks.pick_random()
	cooldowns[selected_attack.attack_name] = selected_attack.cooldown

	start_attack(selected_attack)
	return true


func start_attack(attack: AttackData) -> void:
	if is_attacking or attack == null:
		return

	super.start_attack(attack)

	if not boss.boss_sprite.sprite_frames.has_animation(attack.animation_name):
		finish_attack()
		return

	await boss.boss_sprite.animation_finished

	if is_instance_valid(boss) and is_attacking:
		finish_attack()


func play_attack_animation(animation_name: StringName) -> void:
	if boss.boss_sprite.sprite_frames.has_animation(animation_name):
		boss.boss_sprite.play(animation_name)
	print("[Boss] Attack triggered: ", animation_name)


func stop() -> void:
	finish_attack()


func _create_attacks() -> void:
	var tusk_swing := AttackData.new()
	tusk_swing.attack_name = &"tusk_swing"
	tusk_swing.animation_name = &"tusk_swing"
	tusk_swing.attack_range = 2.5
	tusk_swing.damage = 20.0
	tusk_swing.cooldown = 3.0
	attacks.append(tusk_swing)

	var ground_slam := AttackData.new()
	ground_slam.attack_name = &"ground_slam"
	ground_slam.animation_name = &"ground_slam"
	ground_slam.attack_range = 4.0
	ground_slam.damage = 30.0
	ground_slam.cooldown = 6.0
	attacks.append(ground_slam)
