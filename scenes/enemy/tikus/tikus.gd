extends Enemy
class_name EnemyTikus

@export var area_offset: float = 0.7

@onready var attack_area: Area3D = $AreaAttack   # sesuaikan dengan nama node kamu

var _facing_dir: Vector3 = Vector3.RIGHT
var _area_y: float

func _on_ready() -> void:
	var shape_node: Node3D = attack_area.get_child(0)
	_area_y = shape_node.position.y   # simpan tinggi shape
	shape_node.position = Vector3.ZERO  # buang offset X dan Z
	attack_area.position.y = _area_y

	_area_y = attack_area.position.y
	max_health = 20.0
	reset_health()   # dulu: health = max_health (sekarang health read-only)
	move_speed = 4.5
	damage = 3.0
	attack_cooldown = 0.8
	attack_hit_delay = 0.25
	attack_duration = 0.5
	#print("Area pos: ", attack_area.position, " | Shape pos: ", attack_area.get_child(0).position)

func _physics_process(delta: float) -> void:
	_update_attack_area()
	super(delta)

func _update_attack_area() -> void:
	if is_dead or attacking:
		return
	if target != null:
		var dir: Vector3 = target.global_position - global_position
		dir.y = 0.0
		if dir.length() > 0.05:
			_facing_dir = dir.normalized()
	attack_area.position = Vector3(_facing_dir.x * area_offset, _area_y, _facing_dir.z * area_offset)

func _is_target_in_range() -> bool:
	return target != null and attack_area.get_overlapping_bodies().has(target)

func _perform_attack() -> void:
	if target and target.has_method("take_damage"):
		target.take_damage(damage)
