extends Node3D
class_name EnemySpawner
## Spawn musuh acak di dalam pagar (poligon dari titik-titik sudut pagar),
## dengan syarat jarak minimal dari lahan. Tanpa collision.
## Batas jumlah: per jenis (SpawnEntry.max_alive) dan total (max_total).

signal enemy_spawned(enemy: Enemy)

const LAHAN_GROUP: Lahan
const MAX_TRIES: int = 30   # percobaan cari titik valid sebelum menyerah

@export var entries: Array[SpawnEntry] = []
@export var max_total: int = 10
@export var spawn_interval: float = 3.0
@export var auto_start: bool = true

## Node induk pagar (mis. FencesParent). Posisi tiap anaknya dipakai sebagai
## titik batas. Minimal 3 anak. Pagar otomatis tertutup.
@export var fence: Node3D
## true = batas diambil dari "selimut" terluar semua anak (urutan anak bebas,
## tapi bagian pagar yang menjorok ke dalam ikut terhitung area).
## false = batas mengikuti urutan anak sesuai keliling pagar.
@export var use_convex_hull: bool = true
## Node tempat musuh dimasukkan. Kosong = parent dari spawner.
@export var container: Node

@export_group("Jarak dari lahan")
@export var min_lahan_distance: float = 8.0
@export var max_lahan_distance: float = 0.0   # 0 = tanpa batas jauh

var _counts: Dictionary = {}   # SpawnEntry -> jumlah hidup
var _total: int = 0
var _timer: Timer

var _poly: PackedVector2Array = PackedVector2Array()   # pagar di bidang XZ
var _bounds_min: Vector2
var _bounds_max: Vector2
var _spawn_y: float = 0.0


func _ready() -> void:
	if not _build_fence():
		return
	_timer = Timer.new()
	_timer.wait_time = spawn_interval
	_timer.timeout.connect(spawn_one)
	add_child(_timer)
	if auto_start:
		_timer.start()


func start() -> void:
	if _timer: _timer.start()


func stop() -> void:
	if _timer: _timer.stop()


func spawn_one() -> void:
	if _total >= max_total:
		return

	var entry: SpawnEntry = _pick_entry()
	if entry == null:
		return

	var pos: Vector3
	var found: bool = false
	for i in MAX_TRIES:
		var p := Vector3(
			randf_range(_bounds_min.x, _bounds_max.x),
			_spawn_y,
			randf_range(_bounds_min.y, _bounds_max.y))
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

	(container if container != null else get_parent()).add_child(enemy)
	enemy.global_position = pos

	_counts[entry] = _counts.get(entry, 0) + 1
	_total += 1
	enemy.tree_exiting.connect(_on_enemy_removed.bind(entry), CONNECT_ONE_SHOT)
	enemy_spawned.emit(enemy)


func _on_enemy_removed(entry: SpawnEntry) -> void:
	_counts[entry] = maxi(_counts.get(entry, 0) - 1, 0)
	_total = maxi(_total - 1, 0)


# Pilih acak dari jenis yang belum penuh.
func _pick_entry() -> SpawnEntry:
	var open: Array[SpawnEntry] = []
	for e in entries:
		if e != null and e.scene != null and _counts.get(e, 0) < e.max_alive:
			open.append(e)
	return open.pick_random() if not open.is_empty() else null


# Baca titik sudut pagar sekali saja saat mulai.
func _build_fence() -> bool:
	if fence == null:
		push_error("EnemySpawner: isi 'fence' dengan node yang berisi titik-titik pagar.")
		return false
	var y_sum: float = 0.0
	var count: int = 0
	for c in fence.get_children():
		if c is Node3D:
			_poly.append(Vector2(c.global_position.x, c.global_position.z))
			y_sum += c.global_position.y
			count += 1
	if count < 3:
		push_error("EnemySpawner: pagar butuh minimal 3 anak Node3D.")
		return false
	_spawn_y = y_sum / count
	if use_convex_hull:
		_poly = Geometry2D.convex_hull(_poly)
	_bounds_min = _poly[0]
	_bounds_max = _poly[0]
	for v in _poly:
		_bounds_min = _bounds_min.min(v)
		_bounds_max = _bounds_max.max(v)
	return true


func _in_fence(p: Vector3) -> bool:
	return Geometry2D.is_point_in_polygon(Vector2(p.x, p.z), _poly)


# Cek jarak ke lahan terdekat. Tanpa lahan di scene = selalu valid.
func _lahan_ok(pos: Vector3) -> bool:
	var lahan: Array[Node] = get_tree().get_nodes_in_group(LAHAN_GROUP)
	if lahan.is_empty():
		return true
	var nearest: float = INF
	for n in lahan:
		if n is Node3D:
			nearest = minf(nearest, pos.distance_squared_to(n.global_position))
	if nearest < min_lahan_distance * min_lahan_distance:
		return false
	if max_lahan_distance > 0.0 and nearest > max_lahan_distance * max_lahan_distance:
		return false
	return true
