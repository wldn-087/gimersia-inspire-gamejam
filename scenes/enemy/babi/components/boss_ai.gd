extends RefCounted
class_name BossAI

const PLAYER_AGGRO_RANGE: float = 5.0
const PLAYER_LEASH_RANGE: float = 20.0
const TARGET_UPDATE_INTERVAL: float = 0.2

var boss: BoarBoss
var locomotion: BossLocomotion
var combat: BossCombat

var target_timer := 0.0


func _init(
	owner: BoarBoss,
	movement: BossLocomotion,
	attack: BossCombat
) -> void:
	boss = owner
	locomotion = movement
	combat = attack


func update(delta: float) -> void:
	combat.update(delta)
	_update_target(delta)

	if boss.target == null:
		locomotion.stop()
		boss.play_boss_animation("idle")
		return

	if combat.is_attacking:
		locomotion.stop()
		return

	var distance := _flat_distance_to(boss.target)

	if combat.try_attack(distance):
		locomotion.stop()
		return

	locomotion.move_to_target()


func _update_target(delta: float) -> void:
	target_timer -= delta
	if target_timer > 0.0:
		return
	target_timer = TARGET_UPDATE_INTERVAL

	var player: Player = boss._find_player(boss.get_tree().current_scene)

	if boss.target is Player:
		if not is_instance_valid(boss.target):
			boss.target = _find_nearest_plant()
		elif player == null:
			boss.target = _find_nearest_plant()
		elif _flat_distance_to(player) > PLAYER_LEASH_RANGE:
			boss.target = _find_nearest_plant()
		return

	if player != null and _flat_distance_to(player) <= PLAYER_AGGRO_RANGE:
		boss.target = player
		return

	if boss.target == null or not is_instance_valid(boss.target):
		boss.target = _find_nearest_plant()


func _find_nearest_plant() -> Node3D:
	var nearest: Node3D = null
	var nearest_distance := INF

	for node in boss.get_tree().get_nodes_in_group("saveable_plants"):
		if not (node is Node3D):
			continue

		var distance := _flat_distance_to(node)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = node

	return nearest


func _flat_distance_to(node: Node3D) -> float:
	var offset := node.global_position - boss.global_position
	offset.y = 0.0
	return offset.length()


func stop() -> void:
	locomotion.stop()
	combat.stop()
