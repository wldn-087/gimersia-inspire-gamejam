
extends Interactable
class_name RestSpot

@export var day_cycle_manager: DayCycleManager

func _ready() -> void:
	prompt_text = "[E] Istirahat"
	super._ready()
	
	day_cycle_manager.phase_changed.connect(_on_phase_changed)

	_update_interaction()


func _on_phase_changed(_new_phase: DayCycleManager.Phase) -> void:
	_update_interaction()


func _update_interaction() -> void:
	interaction_enabled = (
		day_cycle_manager != null
		and day_cycle_manager.current_phase == DayCycleManager.Phase.RESTING
	)



func interact() -> void:
	if day_cycle_manager == null:
		push_warning("RestSpot: DayCycleManager belum dihubungkan.")
		return

	if day_cycle_manager.current_phase != DayCycleManager.Phase.RESTING:
		return

	day_cycle_manager.request_rest()
