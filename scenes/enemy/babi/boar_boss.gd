
extends Enemy
class_name BoarBoss

@export_group("Boss Attacks")
@export var attacks: Array[AttackData] = []

@onready var boss_sprite: AnimatedSprite3D = $Visual/AnimatedSprite3D
@onready var attack_hitbox: BossAttackHitbox = $AttackHitbox

var boss_ai: BossAI
var boss_locomotion: BossLocomotion
var boss_combat: BossCombat


func _on_ready() -> void:
	reset_health()
	target = null

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
