extends Node3D


func _ready() -> void:
	if SaveManager.has_pending_save():
		SaveManager.apply_pending_save()

	elif SaveManager.new_game_requested:
		var day_manager := get_tree().get_first_node_in_group(
            "day_cycle_manager"
		) as DayCycleManager

		if day_manager != null:
			SaveManager.initialize_new_game(
				day_manager.current_day
			)
