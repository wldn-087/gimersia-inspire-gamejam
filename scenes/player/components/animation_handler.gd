extends Node
class_name AnimationHandler

signal action_finished
signal frame_changed(frame: int)

var health_component : HealthComponent

@export var body: AnimatedSprite3D

var on_action := false

func _ready() -> void:
	body.frame_changed.connect(_on_frame_changed)
	body.animation_finished.connect(_on_animation_finished)
	
func initialize(player: Player) -> void:
	player.health_component.hurt.connect(hurt)
	player.health_component.died.connect(_on_player_died)
	health_component = player.health_component

func hurt() -> void:
	print("Player hurt")
	if health_component.current_health <= 0.0:
		return
	body_anim_play("hurt", false)

func _on_player_died() -> void:
	body_anim_play("dead", false)

func body_anim_play(animation_name: String, is_action = false) -> void:
	on_action = is_action
	body.play(animation_name)

func _on_frame_changed() -> void:
	frame_changed.emit(body.frame)

func _on_animation_finished() -> void:
	if not on_action:
		return

	body.play("idle")
	on_action = false
	action_finished.emit()
