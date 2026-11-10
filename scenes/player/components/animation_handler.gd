extends Node
class_name AnimationHandler

@export var body : AnimatedSprite3D
@export var hand: AnimatedSprite3D

var on_action := false

func body_anim_play(animation_name : String):
	body.play(animation_name)

func play_action(action_name: String, is_action: bool):
	hand.play(action_name)
	on_action = is_action

func _on_should_be_hand_animation_finished() -> void:
	if !on_action: return
	hand.play("idle")
	on_action = false
