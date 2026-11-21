extends Node
class_name AnimationHandler

signal action_finished
signal frame_changed(frame: int)

@export var body: AnimatedSprite3D

var on_action := false

func _ready() -> void:
	body.frame_changed.connect(_on_frame_changed)
	body.animation_finished.connect(_on_animation_finished)

func body_anim_play(animation_name: StringName, is_action = false) -> void:
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
