extends Node
class_name DayCycleManager

enum Phase {
	TUTORIAL,
	PREPARATION,
	COMBAT,
	RESTING,
	MORNING_EVENT
}

@export var day_configs: Array[DayConfig]

var current_day: int = 1
var current_phase: Phase
var phase_timer: float = 0.0

var current_config: DayConfig


func start_day(day: int) -> void:
	current_day = day

	if day < 1 or day > day_configs.size():
		return

	current_config = day_configs[day - 1]

	if current_config.day_number == 1:
		change_phase(Phase.TUTORIAL)
	elif current_config.preparation_duration <= 0:
		change_phase(Phase.COMBAT)
	else:
		change_phase(Phase.PREPARATION)


func change_phase(new_phase: Phase) -> void:
	current_phase = new_phase
	phase_timer = 0.0


func _process(delta: float) -> void:
	phase_timer += delta

	match current_phase:
		Phase.PREPARATION:
			if phase_timer >= current_config.preparation_duration:
				change_phase(Phase.COMBAT)

		Phase.COMBAT:
			if can_finish_combat():
				pass

func can_finish_combat() -> bool:
	return (
		phase_timer >= current_config.combat_min_duration
		and get_alive_enemy_count() == 0
	)


func get_alive_enemy_count() -> int:
	# Nantinya dihubungkan dengan EnemySpawner.
	return 0
