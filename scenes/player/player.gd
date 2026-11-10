extends CharacterBody3D
class_name Player

@onready var player_input: PlayerInput = $Components/PlayerInput
@onready var player_locomotion: PlayerLocomotion = $Components/PlayerLocomotion
@onready var anim_player: AnimationHandler = $Components/AnimationHandler
@onready var player_combat: PlayerCombat = $Components/PlayerCombat

@export_group("Movemnet")
@export var move_speed = 5.0
@export var run_speed = 8.0
@export var acceleration = 18.0
@export var decceleration = 25.0

func _ready() -> void:
	player_locomotion.start(self)
	player_combat.start(self)

func _physics_process(delta: float) -> void:
	player_locomotion.move(delta)
	player_combat.input_check()
	move_and_slide()
	
