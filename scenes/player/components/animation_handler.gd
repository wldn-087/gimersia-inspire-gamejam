extends Node
class_name AnimationHandler

signal action_finished
signal frame_changed(frame: int)

@export var body: AnimatedSprite3D
@export var hand: AnimatedSprite3D

var on_action := false

func _ready() -> void:
	hand.frame_changed.connect(_on_hand_frame_changed)
	hand.animation_finished.connect(_on_hand_animation_finished)

func body_anim_play(animation_name: StringName) -> void:
	body.play(animation_name)

func play_action(action_name: StringName, is_action: bool) -> void:
	on_action = is_action
	hand.play(action_name)

func _on_hand_frame_changed() -> void:
	frame_changed.emit(hand.frame)

func _on_hand_animation_finished() -> void:
	if not on_action:
		return

	hand.play("idle")
	on_action = false
	action_finished.emit()
