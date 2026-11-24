
extends Area3D
class_name Interactable

@export_group("Interaction")
@export var prompt_text: String = "Interact"
@export var interaction_enabled: bool = true

@onready var prompt_label: Label3D = $Label3D

var player_in_range: bool = false


func _ready() -> void:
	prompt_label.text = prompt_text
	prompt_label.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if not interaction_enabled or not player_in_range:
		return

	if Input.is_action_just_pressed("interact"):
		interact()
		get_viewport().set_input_as_handled()


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		prompt_label.visible = interaction_enabled


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		prompt_label.visible = false


func interact() -> void:
	pass
