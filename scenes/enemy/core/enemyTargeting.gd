extends RefCounted
class_name EnemyTargeting
## Komponen pemilihan target.
## Aturan: player terlihat (dalam sight_radius) -> kejar player.
## Player keluar vision -> tunggu lose_sight_delay, lalu cari target cadangan
## (lahan terdekat). Kalau belum ada lahan, target = null (musuh idle).

const CHECK_INTERVAL: float = 0.2
const FALLBACK_GROUP: StringName = &"lahan"   # nanti: beri node lahan group ini

var _enemy: Enemy
var _player: Node3D
var _timer: float
var _lost_time: float = 0.0


func _init(enemy: Enemy) -> void:
	_enemy = enemy
	# offset acak supaya banyak musuh tidak mengecek di frame yang sama
	_timer = randf() * CHECK_INTERVAL


func update(delta: float) -> void:
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = CHECK_INTERVAL
	_retarget()


func _retarget() -> void:
	# Target lama sudah dihapus dari scene (mis. player mati)
	if _enemy.target != null and not is_instance_valid(_enemy.target):
		_enemy.target = null

	if _enemy.aggro_on_player:
		var player: Node3D = _get_player()
		if player != null and _in_sight(player):
			_enemy.target = player
			_lost_time = 0.0
			return

		# Sedang mengejar player tapi sudah keluar vision: beri jeda dulu
		if player != null and _enemy.target == player:
			_lost_time += CHECK_INTERVAL
			if _lost_time < _enemy.lose_sight_delay:
				return

	_lost_time = 0.0
	_enemy.target = _nearest_in_group(FALLBACK_GROUP)


func _in_sight(node: Node3D) -> bool:
	var r: float = _enemy.sight_radius
	return _enemy.global_position.distance_squared_to(node.global_position) <= r * r


func _get_player() -> Node3D:
	if _player == null or not is_instance_valid(_player):
		_player = _enemy._find_player(_enemy.get_tree().current_scene)
	return _player


# Target cadangan (lahan): yang terdekat dari musuh. Kosong = null.
func _nearest_in_group(group: StringName) -> Node3D:
	var best: Node3D = null
	var best_dist: float = INF
	for node in _enemy.get_tree().get_nodes_in_group(group):
		if not (node is Node3D):
			continue
		var d: float = _enemy.global_position.distance_squared_to(node.global_position)
		if d < best_dist:
			best_dist = d
			best = node
	return best
