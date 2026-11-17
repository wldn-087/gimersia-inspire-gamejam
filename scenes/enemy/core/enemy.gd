extends CharacterBody3D
class_name Enemy
## Orkestrator musuh. Logika detail ada di komponen:
##   EnemyHealth, EnemyVisual, EnemyMovement, EnemyCombat
## Turunan cukup override hook di bagian "Hook" di bawah.

signal died(enemy: Enemy)

@export var max_health: float = 20.0
@export var move_speed: float = 3.0
@export var stop_distance: float = 1.0

@export_group("Vision")
@export var sight_radius: float = 8.0         # radius pengelihatan musuh
@export var lose_sight_delay: float = 0.75    # jeda sebelum menyerah setelah player keluar vision
@export var aggro_on_player: bool = true      # false = abaikan player (khusus lahan)

@export_group("Attack")
@export var damage: float = 10.0
@export var attack_range: float = 1.5        # dipakai deteksi default (jarak angka)
@export var attack_cooldown: float = 1.0
@export var attack_hit_delay: float = 0.3    # jeda dari mulai animasi sampai damage kena
@export var attack_duration: float = 0.5     # total lama state menyerang

@onready var sprite: AnimatedSprite3D = $Visual/AnimatedSprite3D

var target: Node3D

var _health: EnemyHealth
var _visual: EnemyVisual
var _movement: EnemyMovement
var _combat: EnemyCombat
var _targeting: EnemyTargeting

# Properti read-only supaya kode lama (player, UI, dll) tetap bisa baca ini.
var health: float:
	get: return _health.current
var is_dead: bool:
	get: return _health.is_dead
var attacking: bool:
	get: return _combat.attacking
var facing_left: bool:
	get: return _visual.facing_left


func _ready() -> void:
	add_to_group("enemy")

	_health = EnemyHealth.new(max_health)
	_health.depleted.connect(_on_depleted)
	_visual = EnemyVisual.new(self, sprite)
	_movement = EnemyMovement.new(self)
	_combat = EnemyCombat.new(self)
	_targeting = EnemyTargeting.new(self)

	_on_ready()


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	_targeting.update(delta)

	if not is_on_floor():
		velocity += get_gravity() * delta

	_combat.tick(delta)

	if _combat.attacking:
		_movement.stop()
	else:
		_movement.update(delta)
		_combat.try_attack()

	move_and_slide()


# ---------- API publik ----------

func take_damage(amount: float) -> void:
	print("enemy get attcked")
	_health.take_damage(amount)


func die() -> void:
	_health.kill()


func play_anim(anim_name: String) -> void:
	_visual.play_anim(anim_name)


# Isi ulang darah sesuai max_health saat ini. Panggil di _on_ready()
# setelah mengubah max_health.
func reset_health() -> void:
	_health.reset(max_health)


# ---------- Hook: bisa di-override oleh turunan ----------

func _on_ready() -> void:
	pass


# Cara mengecek target dalam jangkauan. Default: jarak angka.
func _is_target_in_range() -> bool:
	if target == null:
		return false
	return global_position.distance_to(target.global_position) <= attack_range


# Isi serangan. Dipanggil saat hit_delay selesai.
func _perform_attack() -> void:
	if target and target.has_method("take_damage"):
		target.take_damage(damage)


func _on_death() -> void:
	pass


# Bisa di-override turunan (misalnya untuk memindahkan AttackArea)
func _on_facing_changed(_left: bool) -> void:
	pass


# ---------- Internal ----------

func _on_depleted() -> void:
	velocity = Vector3.ZERO
	_on_death()
	died.emit(self)
	await _visual.play_death()
	queue_free()


func _find_player(node: Node) -> Player:
	if node is Player:
		return node
	for child in node.get_children():
		var found: Player = _find_player(child)
		if found:
			return found
	return null
