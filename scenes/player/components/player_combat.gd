extends Node
class_name PlayerCombat

var player: Player
var anim_handler: AnimationHandler
var player_input: PlayerInput

var is_attacking: bool

func start(owner: Player):
	player = owner
	anim_handler = player.anim_player
	player_input = player.player_input
	
func input_check():
	if is_attacking: return
	if player_input.melee_attack:
		print("Player is melee attack")
		anim_handler.play_action("melee_attack", true)
	if player_input.range_attack_hold:
		print("Player is hold range attack")
		anim_handler.play_action("range_hold", false)
	if player_input.range_attack_release:
		print("Player is release range attack")
		anim_handler.play_action("range_release", true)
