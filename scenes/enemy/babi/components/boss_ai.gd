
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

	# Jangan ganggu velocity saat charge atau slide.
	if combat.is_charge_running or combat.is_sliding:
		return

	if boss.target == null or not is_instance_valid(boss.target):
		locomotion.stop()
		boss.play_boss_animation(&"idle")
		return

	# Serangan biasa dan charge preparation menghentikan locomotion.
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

	if boss.target != null and not is_instance_valid(boss.target):
		boss.target = null

	var player: Player = boss._find_player(
		boss.get_tree().current_scene
	)

	# Player sedang menjadi target.
	if boss.target is Player:
		if player == null:
			boss.target = _find_nearest_plant()
		elif _flat_distance_to(player) > PLAYER_LEASH_RANGE:
			boss.target = _find_nearest_plant()

		return

	# Player masuk radius aggro.
	if player != null:
		if _flat_distance_to(player) <= PLAYER_AGGRO_RANGE:
			boss.target = player
			return

	# Tidak ada target, cari tanaman.
	if boss.target == null:
		boss.target = _find_nearest_plant()


func _find_nearest_plant() -> Node3D:
	var nearest: Node3D = null
	var nearest_distance := INF

	for node in boss.get_tree().get_nodes_in_group("saveable_plants"):
		if not node is Node3D:
			continue

		var plant := node as Node3D
		var distance := _flat_distance_to(plant)

		if distance < nearest_distance:
			nearest_distance = distance
			nearest = plant

	return nearest


func _flat_distance_to(node: Node3D) -> float:
	var offset := node.global_position - boss.global_position
	offset.y = 0.0

	return offset.length()


func stop() -> void:
	locomotion.stop()
	combat.stop()
