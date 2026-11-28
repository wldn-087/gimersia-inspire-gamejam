
extends CombatSystem
class_name PlayerCombat

var player: Player
var anim_handler: AnimationHandler
var player_input: PlayerInput

@export_group("Attacks")
@export var melee_attack: AttackData

@onready var melee_hitbox: Area3D = $"../../HitBox"
@onready var melee_shape: CollisionShape3D = $"../../HitBox/HitBoxShape"

var hitbox_active := false

func start(owner: Player) -> void:
	player = owner
	anim_handler = player.anim_player
	player_input = player.player_input

	melee_hitbox.monitoring = true
	deactivate_hitbox()

	anim_handler.frame_changed.connect(_on_attack_frame_changed)
	anim_handler.action_finished.connect(_on_action_finished)
	melee_hitbox.body_entered.connect(_on_enemy_detect)

func input_check() -> void:
	if is_attacking:
		return

	if player_input.attack_input():
		start_attack(melee_attack)

func update_hitbox_position() -> void:
	melee_hitbox.position.x = -0.695 if anim_handler.body.flip_h else 0.695

func play_attack_animation(animation_name: StringName) -> void:
	anim_handler.body_anim_play("attack", true)

func _on_attack_frame_changed(frame: int) -> void:
	if not is_attacking or current_attack == null:
		return

	if anim_handler.body.animation != current_attack.animation_name:
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

func _on_enemy_detect(body: Node3D) -> void:
	if not body.is_in_group("enemy"):
		return

	if not body.has_method("take_damage"):
		return

	body.call(
		"take_damage",
		melee_attack.damage * player._damage
	)
