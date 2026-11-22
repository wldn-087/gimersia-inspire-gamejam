extends Interactable
class_name RestSpot

@export var day_cycle_manager: DayCycleManager


func _ready() -> void:
	prompt_text = "[E] Istirahat"
	super._ready()


func interact() -> void:
	if day_cycle_manager == null:
		push_warning("RestSpot: DayCycleManager belum dihubungkan.")
		return

	if day_cycle_manager.current_phase != DayCycleManager.Phase.RESTING:
		return

	day_cycle_manager.request_rest()
