extends Enemy
class_name BoarBoss

@onready var boss_sprite: AnimatedSprite3D = $Visual/AnimatedSprite3D

var boss_ai: BossAI
var boss_locomotion: BossLocomotion
var boss_combat: BossCombat


func _on_ready() -> void:
	max_health = 750.0
	move_speed = 3.0
	stop_distance = 1.5
	damage = 25.0
	attack_range = 2.5
	attack_cooldown = 5.0
	reset_health()

	boss_locomotion = BossLocomotion.new(self)

	boss_combat = BossCombat.new(self)
	add_child(boss_combat)

	boss_ai = BossAI.new(self, boss_locomotion, boss_combat)

	boss_sprite.play("idle")


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	boss_ai.update(delta)
	move_and_slide()


func _on_death() -> void:
	velocity = Vector3.ZERO

	if boss_ai:
		boss_ai.stop()


func _on_depleted() -> void:
	velocity = Vector3.ZERO
	_on_death()

	died.emit(self)

	if boss_sprite.sprite_frames.has_animation("dead"):
		boss_sprite.play("dead")
		await boss_sprite.animation_finished

	queue_free()


func play_boss_animation(animation_name: StringName) -> void:
	if boss_sprite.sprite_frames.has_animation(animation_name):
		if boss_sprite.animation != animation_name:
			boss_sprite.play(animation_name)
