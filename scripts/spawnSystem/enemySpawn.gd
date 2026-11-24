
extends Node3D
class_name EnemySpawner

signal enemy_spawned(enemy: Enemy)
signal enemy_count_changed(count: int)

@export_group("Enemy")
@export var enemy_scenes: Array[PackedScene] = []
@export var max_total: int = 10

@export_group("Spawn Points")
@export var spawn_points: Array[Node3D] = []
@export var spawn_radius: float = 5.0

@export_group("Spawn Settings")
@export var spawn_interval: float = 3.0
@export var auto_start: bool = false
@export var container: Node

var _timer: Timer
var _alive_count: int = 0

var alive_count: int:
	get:
		return _alive_count


func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = spawn_interval
	_timer.timeout.connect(spawn_one)
	add_child(_timer)

	if auto_start:
		start()


func start() -> void:
	if _timer.is_stopped():
		_timer.start()


func stop() -> void:
	_timer.stop()


func apply_day_config(config: DayConfig) -> void:
	if config == null:
		return

	var speed := maxf(config.spawn_rate_speed, 0.01)
	_timer.wait_time = maxf(config.spawn_rate / speed, 0.1)


func spawn_one() -> void:
	if _alive_count >= max_total:
		return

	if enemy_scenes.is_empty() or spawn_points.is_empty():
		return

	var valid_scenes: Array[PackedScene] = []

	for scene in enemy_scenes:
		if scene != null:
			valid_scenes.append(scene)

	var valid_points: Array[Node3D] = []

	for point in spawn_points:
		if is_instance_valid(point):
			valid_points.append(point)

	if valid_scenes.is_empty() or valid_points.is_empty():
		return

	var selected_scene: PackedScene = valid_scenes.pick_random()
	var selected_point: Node3D = valid_points.pick_random()

	var enemy := selected_scene.instantiate() as Enemy

	if enemy == null:
		push_warning("EnemySpawner: Scene bukan turunan Enemy.")
		return

	var angle := randf_range(0.0, TAU)
	var distance := sqrt(randf()) * spawn_radius

	var offset := Vector3(
		cos(angle) * distance,
		0.0,
		sin(angle) * distance
	)

	var parent_node := container if container != null else get_parent()

	parent_node.add_child(enemy)
	print("enemy spawned")
	enemy.global_position = selected_point.global_position + offset

	_alive_count += 1

	enemy.tree_exiting.connect(_on_enemy_removed, CONNECT_ONE_SHOT)

	enemy_spawned.emit(enemy)
	enemy_count_changed.emit(_alive_count)


func _on_enemy_removed() -> void:
	_alive_count = maxi(_alive_count - 1, 0)
	enemy_count_changed.emit(_alive_count)
