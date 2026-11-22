extends Node
class_name DayCycleManager

signal phase_changed(new_phase: Phase)
signal day_changed(day: int)

enum Phase {
	PREPARATION,
	COMBAT,
	RESTING
}

@export_group("Day Configuration")
@export var day_configs: Array[DayConfig] = []
@export var starting_day: int = 1

@export_group("References")
@export var phase_timer: PhaseTimer
@export var enemy_spawner: EnemySpawner

var current_day: int = 1
var current_phase: Phase = Phase.PREPARATION
var current_config: DayConfig


func _ready() -> void:
	if phase_timer == null or enemy_spawner == null:
		push_error("DayCycleManager: Referensi belum lengkap.")
		return

	phase_timer.phase_finished.connect(_on_phase_finished)

	start_day(starting_day)


func start_day(day: int) -> void:
	var config := _find_day_config(day)

	if config == null:
		push_error("DayConfig untuk hari %d tidak ditemukan." % day)
		return

	current_day = day
	current_config = config

	day_changed.emit(current_day)

	if current_config.preparation_duration > 0.0:
		_start_preparation()
	else:
		_start_night()


func _find_day_config(day: int) -> DayConfig:
	for config in day_configs:
		if config != null and config.day_number == day:
			return config

	return null


func _start_preparation() -> void:
	current_phase = Phase.PREPARATION
	phase_changed.emit(current_phase)

	phase_timer.start_phase(
		PhaseTimer.Phase.PREP,
		current_config.preparation_duration
	)


func _start_night() -> void:
	current_phase = Phase.COMBAT
	phase_changed.emit(current_phase)

	enemy_spawner.apply_day_config(current_config)
	enemy_spawner.start()

	phase_timer.start_phase(
		PhaseTimer.Phase.COMBAT,
		current_config.combat_min_duration
	)


func _start_rest() -> void:
	enemy_spawner.stop()

	current_phase = Phase.RESTING
	phase_changed.emit(current_phase)

	phase_timer.set_phase(PhaseTimer.Phase.RESTING)


func _on_phase_finished(phase: PhaseTimer.Phase) -> void:
	if phase == PhaseTimer.Phase.PREP:
		_start_night()

	elif phase == PhaseTimer.Phase.COMBAT:
		_start_rest()


func request_rest() -> void:
	if current_phase != Phase.RESTING:
		return

	start_day(current_day + 1)
