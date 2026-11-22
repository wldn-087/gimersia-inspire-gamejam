extends Node3D
class_name EnemySpawner

signal enemy_spawned(enemy: Enemy)
signal enemy_count_changed(count: int)

const MAX_TRIES: int = 30

@export var entries: Array[SpawnEntry] = []
@export var max_total: int = 10
@export var spawn_interval: float = 3.0
@export var auto_start: bool = false

@export var fence: Node3D
@export var use_convex_hull: bool = true
@export var container: Node

@export_group("Jarak dari lahan")
@export var min_lahan_distance: float = 8.0
@export var max_lahan_distance: float = 0.0

var _counts: Dictionary = {}
var _total: int = 0
var _timer: Timer

var _worm_weight: float = 1.0
var _rat_weight: float = 1.0
var _other_weight: float = 1.0

var _poly: PackedVector2Array = PackedVector2Array()
var _bounds_min: Vector2
var _bounds_max: Vector2
var _spawn_y: float = 0.0

var alive_count: int:
	get:
		return _total


func _ready() -> void:
	if not _build_fence():
		return

	_timer = Timer.new()
	_timer.one_shot = false
	_timer.wait_time = spawn_interval
	_timer.timeout.connect(spawn_one)
	add_child(_timer)

	enemy_count_changed.emit(_total)

	if auto_start:
		start()


func start() -> void:
	if _timer == null:
		return

	if _timer.is_stopped():
		_timer.start()


func stop() -> void:
	if _timer != null:
		_timer.stop()


func apply_day_config(config: DayConfig) -> void:
	if config == null:
		return

	_worm_weight = maxf(config.worm_spawn_weight, 0.0)
	_rat_weight = maxf(config.rat_spawn_weight, 0.0)

	var speed := maxf(config.spawn_rate_speed, 0.01)
	var interval := config.spawn_rate / speed

	if _timer != null:
		_timer.wait_time = maxf(interval, 0.1)


func spawn_one() -> void:
	if _total >= max_total:
		return

	var entry := _pick_entry()

	if entry == null:
		return

	var pos: Vector3
	var found := false

	for i in MAX_TRIES:
		var p := Vector3(
			randf_range(_bounds_min.x, _bounds_max.x),
			_spawn_y,
			randf_range(_bounds_min.y, _bounds_max.y)
		)

		if _in_fence(p) and _lahan_ok(p):
			pos = p
			found = true
			break

	if not found:
		return

	var enemy := entry.scene.instantiate() as Enemy

	if enemy == null:
		push_warning("EnemySpawner: scene bukan turunan Enemy.")
		return

	var parent_node := container if container != null else get_parent()
	parent_node.add_child(enemy)

	enemy.global_position = pos

	_counts[entry] = _counts.get(entry, 0) + 1
	_total += 1

	enemy.tree_exiting.connect(
		_on_enemy_removed.bind(entry),
		CONNECT_ONE_SHOT
	)

	enemy_spawned.emit(enemy)
	enemy_count_changed.emit(_total)


func _on_enemy_removed(entry: SpawnEntry) -> void:
	_counts[entry] = maxi(_counts.get(entry, 0) - 1, 0)
	_total = maxi(_total - 1, 0)

	enemy_count_changed.emit(_total)


func _pick_entry() -> SpawnEntry:
	var available: Array[SpawnEntry] = []
	var total_weight := 0.0

	for entry in entries:
		if entry == null or entry.scene == null:
			continue

		if _counts.get(entry, 0) >= entry.max_alive:
			continue

		var weight := _get_entry_weight(entry)

		if weight <= 0.0:
			continue

		available.append(entry)
		total_weight += weight

	if available.is_empty() or total_weight <= 0.0:
		return null

	var roll := randf() * total_weight

	for entry in available:
		roll -= _get_entry_weight(entry)

		if roll <= 0.0:
			return entry

	return available.back()


func _get_entry_weight(entry: SpawnEntry) -> float:
	match entry.enemy_type:
		SpawnEntry.EnemyType.WORM:
			return _worm_weight

		SpawnEntry.EnemyType.RAT:
			return _rat_weight

		SpawnEntry.EnemyType.OTHER:
			return _other_weight

	return 0.0


func _build_fence() -> bool:
	if fence == null:
		push_error("EnemySpawner: isi referensi fence.")
		return false

	var y_sum := 0.0
	var count := 0

	for child in fence.get_children():
		if child is Node3D:
			_poly.append(
				Vector2(
					child.global_position.x,
					child.global_position.z
				)
			)

			y_sum += child.global_position.y
			count += 1

	if count < 3:
		push_error("EnemySpawner: pagar membutuhkan minimal 3 titik Node3D.")
		return false

	_spawn_y = y_sum / count

	if use_convex_hull:
		_poly = Geometry2D.convex_hull(_poly)

	if _poly.size() < 3:
		push_error("EnemySpawner: polygon pagar tidak valid.")
		return false

	_bounds_min = _poly[0]
	_bounds_max = _poly[0]

	for point in _poly:
		_bounds_min = _bounds_min.min(point)
		_bounds_max = _bounds_max.max(point)

	return true


func _in_fence(pos: Vector3) -> bool:
	return Geometry2D.is_point_in_polygon(
		Vector2(pos.x, pos.z),
		_poly
	)


func _lahan_ok(pos: Vector3) -> bool:
	var lahan_nodes := get_tree().get_nodes_in_group("lahan")

	if lahan_nodes.is_empty():
		return true

	var nearest := INF

	for node in lahan_nodes:
		if node is Node3D:
			nearest = minf(
				nearest,
				pos.distance_squared_to(node.global_position)
			)

	if nearest < min_lahan_distance * min_lahan_distance:
		return false

	if max_lahan_distance > 0.0:
		if nearest > max_lahan_distance * max_lahan_distance:
			return false

	return true
