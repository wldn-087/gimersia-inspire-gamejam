
extends Enemy
class_name BoarBoss

const WHITE_FLASH_SHADER = preload("res://assets/shader/white_flash.gdshader")

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

var white_material: ShaderMaterial

signal health_changed(current_health: float, max_health: float)

func _on_ready() -> void:
	max_health = 750.0
	reset_health()
	_health.health_changed.connect(func(current: float, maximum: float):
		health_changed.emit(current, maximum)
	)
	
	target = null

	tusk_base_x = absf(tusk_hitbox.hitbox_shape.position.x)
	ground_slam_base_x = absf(ground_slam_hitbox.hitbox_shape.position.x)

	setup_white_material()

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

	tusk_hitbox.position.x = -1.16 if left else 1.16
	ground_slam_hitbox.position.x = -0.5 if left else 0.5


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


# ========================================
# WHITE FLASH
# ========================================

func setup_white_material() -> void:
	white_material = ShaderMaterial.new()
	white_material.shader = WHITE_FLASH_SHADER

	boss_sprite.material_override = white_material

	boss_sprite.frame_changed.connect(_update_sprite_texture)
	boss_sprite.animation_changed.connect(_update_sprite_texture)

	_update_sprite_texture()


func _update_sprite_texture() -> void:
	if white_material == null:
		return

	var texture = boss_sprite.sprite_frames.get_frame_texture(
		boss_sprite.animation,
		boss_sprite.frame
	)

	white_material.set_shader_parameter("sprite_texture", texture)


func set_white_amount(amount: float) -> void:
	if white_material == null:
		return

	white_material.set_shader_parameter(
		"white_amount",
		clampf(amount, 0.0, 1.0)
	)


func enable_white_override() -> void:
	set_white_amount(1.0)


func disable_white_override() -> void:
	set_white_amount(0.0)


func flash_white(duration: float = 0.12) -> void:
	if white_material == null:
		return

	var tween := create_tween()

	set_white_amount(1.0)

	tween.tween_method(
		set_white_amount,
		1.0,
		0.0,
		duration
	)

func take_damage(amount: float) -> void:
	flash_white()
	super.take_damage(amount)
