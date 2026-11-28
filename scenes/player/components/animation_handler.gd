extends Node
class_name AnimationHandler

signal action_finished
signal frame_changed(frame: int)

var is_dead := false
@export var body: AnimatedSprite3D

var on_action := false

func _ready() -> void:
	body.frame_changed.connect(_on_frame_changed)
	body.animation_finished.connect(_on_animation_finished)
	
func initialize(player: Player) -> void:
	player.health_component.hurt.connect(hurt)
	player.health_component.died.connect(_on_player_died)

func hurt() -> void:
	body_anim_play("hurt", true)

func _on_player_died() -> void:
	body_anim_play("dead", true)
	is_dead = true

func body_anim_play(animation_name: String, is_action = false) -> void:
	if is_dead:
		return
	on_action = is_action
	body.play(animation_name)

func _on_frame_changed() -> void:
	frame_changed.emit(body.frame)

func _on_animation_finished() -> void:
	if not on_action || body.animation == "dead":
		return

	body.play("idle")
	on_action = false
	action_finished.emit()
