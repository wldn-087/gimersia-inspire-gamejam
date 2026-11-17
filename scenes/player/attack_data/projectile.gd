extends RigidBody3D
class_name Projectile

@export var attack_data: AttackData
@export var charge_time: float = 0.0

func _on_body_entered(body: Node) -> void:
	if body is Enemy:
		body.take_damage(attack_data.get_damage(charge_time))

	if body is not Player:
		queue_free()
