
extends Enemy
class_name BoarBoss

@export_group("Boss Attacks")
@export var attacks: Array[AttackData] = []

@onready var boss_sprite: AnimatedSprite3D = $Visual/AnimatedSprite3D

@onready var charge_hitbox: BossAttackHitbox = $AttackHitBoxes/ChargeHitbox
@onready var tusk_hitbox: BossAttackHitbox = $AttackHitBoxes/TuskHitbox
@onready var ground_slam_hitbox: BossAttackHitbox = $AttackHitBoxes/GroundSlamHitBox

var boss_ai: BossAI
var boss_locomotion: BossLocomotion
var boss_combat: BossCombat

var tusk_base_x: float
var ground_slam_base_x: float


func _on_ready() -> void:
	max_health = 750.0
	reset_health()

	target = null

	tusk_base_x = absf(tusk_hitbox.hitbox_shape.position.x)
	ground_slam_base_x = absf(ground_slam_hitbox.hitbox_shape.position.x)

	boss_locomotion = BossLocomotion.new(self)

	boss_combat = BossCombat.new(self, attacks)
	add_child(boss_combat)

	boss_ai = BossAI.new(
		self,
		boss_locomotion,
		boss_combat
	)

	if attacks.is_empty():
		push_warning("[Boss] No AttackData assigned.")

	play_boss_animation(&"idle")


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	boss_ai.update(delta)
	move_and_slide()


func stop_horizontal_movement() -> void:
	velocity.x = 0.0
	velocity.z = 0.0


func play_boss_animation(animation_name: StringName) -> void:
	if not boss_sprite.sprite_frames.has_animation(animation_name):
		return

	if boss_sprite.animation != animation_name:
		boss_sprite.play(animation_name)


func get_attack_hitbox(hitbox_name: StringName) -> BossAttackHitbox:
	match hitbox_name:
		&"ChargeHitbox":
			return charge_hitbox
		&"TuskHitbox":
			return tusk_hitbox
		&"GroundSlamHitbox":
			return ground_slam_hitbox

	push_warning("[Boss] Unknown hitbox: " + str(hitbox_name))
	return null


func _on_facing_changed(left: bool) -> void:
	var direction := -1.0 if left else 1.0

	tusk_hitbox.hitbox_shape.position.x = tusk_base_x * direction
	ground_slam_hitbox.hitbox_shape.position.x = ground_slam_base_x * direction


func _on_death() -> void:
	stop_horizontal_movement()

	if boss_ai != null:
		boss_ai.stop()


func _on_depleted() -> void:
	stop_horizontal_movement()

	if boss_ai != null:
		boss_ai.stop()

	died.emit(self)

	if boss_sprite.sprite_frames.has_animation(&"dead"):
		boss_sprite.play(&"dead")
		await boss_sprite.animation_finished

	queue_free()
