
extends CombatSystem
class_name PlayerCombat

var player: Player
var anim_handler: AnimationHandler
var player_input: PlayerInput
var locomotion: PlayerLocomotion

@export_group("Attacks")
@export var melee_attack: AttackData
@export var range_attack: AttackData

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 10.0

@onready var camera: Camera3D = $"../../Camera3D"
@onready var projectile_spawn_pos: Marker3D = $"../../ProjectileSpawnPos"
var charge_time := 0.0

@onready var melee_hitbox: Area3D = $"../../HitBox"
@onready var melee_shape: CollisionShape3D = $"../../HitBox/HitBoxShape"

var hitbox_active := false

func start(owner: Player) -> void:
	player = owner
	anim_handler = player.anim_player
	player_input = player.player_input
	locomotion = player.player_locomotion

	melee_hitbox.monitoring = true
	deactivate_hitbox()

	anim_handler.frame_changed.connect(_on_attack_frame_changed)
	anim_handler.action_finished.connect(_on_action_finished)
	melee_hitbox.body_entered.connect(_on_enemy_detect)

func input_check() -> void:
	if is_attacking:
		return

	if player_input.melee_attack:
		start_attack(melee_attack)

	if player_input.range_attack_hold:
		charge_time += get_process_delta_time()
		if anim_handler.current_action != "range_hold":
			anim_handler.play_action("range_hold", false)
	
	if player_input.range_attack_release:
		var final_charge := charge_time
		charge_time = 0.0
		anim_handler.play_action("range_release", true)
		spawn_projectile(final_charge)

func update_hitbox_position() -> void:
	var direction = locomotion.facing_direction
	melee_hitbox.position = direction * 0.8

func play_attack_animation(animation_name: StringName) -> void:
	anim_handler.play_action(animation_name, true)

func _on_attack_frame_changed(frame: int) -> void:
	if not is_attacking or current_attack == null:
		return

	if anim_handler.hand.animation != current_attack.animation_name:
		return

	var should_be_active := (
		frame >= current_attack.active_start_frame
		and frame <= current_attack.active_end_frame
	)

	if should_be_active and not hitbox_active:
		activate_hitbox()

	elif not should_be_active and hitbox_active:
		deactivate_hitbox()

func activate_hitbox() -> void:
	melee_shape.set_deferred("disabled", false)
	hitbox_active = true

func deactivate_hitbox() -> void:
	melee_shape.set_deferred("disabled", true)
	hitbox_active = false

func _on_action_finished() -> void:
	deactivate_hitbox()
	finish_attack()

func _on_enemy_detect(enemy: Enemy):
	enemy.take_damage(melee_attack.damage)

func spawn_projectile(final_charge: float) -> void:
	var projectile := projectile_scene.instantiate() as Projectile
	player.get_tree().current_scene.add_child(projectile)

	var mouse_pos := player.get_viewport().get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_direction := camera.project_ray_normal(mouse_pos)

	var plane := Plane(Vector3.UP, projectile_spawn_pos.global_position.y)
	var target_pos = plane.intersects_ray(ray_origin, ray_direction)

	if target_pos == null:
		projectile.queue_free()
		return

	var direction: Vector3 = (target_pos - projectile_spawn_pos.global_position).normalized()

	projectile.global_position = projectile_spawn_pos.global_position
	projectile.look_at(projectile.global_position + direction, Vector3.UP)

	projectile.attack_data = range_attack
	projectile.charge_time = final_charge
	projectile.linear_velocity = direction * projectile_speed
