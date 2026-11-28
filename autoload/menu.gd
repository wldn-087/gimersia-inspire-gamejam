extends Control

const GAME_SCENE = "res://scenes/main_game.tscn"


func _ready() -> void:
	$VBoxContainer/ContinueButton.disabled = not SaveManager.has_save()


func _on_continue_pressed() -> void:
	if not SaveManager.prepare_continue():
		print("Save tidak tersedia.")
		return

	get_tree().change_scene_to_file(GAME_SCENE)


func _on_new_game_pressed() -> void:
	SaveManager.request_new_game()

	if SaveManager.new_game_requested:
		get_tree().change_scene_to_file(GAME_SCENE)
