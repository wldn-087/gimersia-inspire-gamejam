
extends Area3D
class_name RestArea

@export var day_cycle: DayCycleManager
@export var prompt_label: Label3D

var player_nearby: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if prompt_label != null:
		prompt_label.hide()


func _process(_delta: float) -> void:
	if not player_nearby or day_cycle == null:
		_hide_prompt()
		return

	if not day_cycle.can_rest:
		_hide_prompt()
		return

	if prompt_label != null:
		prompt_label.text = "Press E to Rest"
		prompt_label.show()

	if Input.is_action_just_pressed("interact"):
		day_cycle.request_rest()


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		player_nearby = true


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		player_nearby = false
		_hide_prompt()


func _hide_prompt() -> void:
	if prompt_label != null:
		prompt_label.hide()
