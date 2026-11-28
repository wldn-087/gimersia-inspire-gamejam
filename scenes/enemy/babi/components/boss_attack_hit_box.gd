
extends Area3D
class_name BossAttackHitbox

@onready var hitbox_shape: CollisionShape3D = $CollisionShape3D

var current_attack: AttackData
var hit_targets: Dictionary = {}


func _ready() -> void:
	monitoring = true
	hitbox_shape.disabled = true

	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func activate(attack: AttackData) -> void:
	if attack == null:
		return

	current_attack = attack
	hit_targets.clear()

	hitbox_shape.set_deferred("disabled", false)


func deactivate() -> void:
	hitbox_shape.set_deferred("disabled", true)

	current_attack = null
	hit_targets.clear()


func _on_body_entered(body: Node3D) -> void:
	apply_damage(body)


func _on_area_entered(area: Area3D) -> void:
	apply_damage(area)


func apply_damage(target: Node) -> void:
	if current_attack == null:
		return

	if not is_instance_valid(target):
		return

	var target_id := target.get_instance_id()

	if hit_targets.has(target_id):
		return

	var health: HealthComponent = null

	if target is Player:
		health = target.health_component

	elif target is Lahan:
		health = target.health_component

	if health == null:
		return

	hit_targets[target_id] = true
	health.take_damage(current_attack.damage)

	if target is Player:
		target.player_locomotion.apply_knockback(global_position, current_attack.knockback)

	print(
		"[Boss] Hit: ",
		target.name,
		" | Damage: ",
		current_attack.damage,
		" | Knockback: ",
		current_attack.knockback
	)
