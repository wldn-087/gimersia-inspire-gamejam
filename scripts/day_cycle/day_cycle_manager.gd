
extends Node
class_name DayCycleManager

signal phase_changed(new_phase: Phase)
signal day_changed(day: int)
signal rest_available_changed(available: bool)
signal morning_event_started

enum Phase {
	TUTORIAL,
	PREPARATION,
	COMBAT,
	RESTING,
	MORNING_EVENT
}

@export_group("Day Configuration")
@export var day_configs: Array[DayConfig]
@export var starting_day: int = 1
@export var start_immediately: bool = true

@export_group("References")
@export var phase_timer: PhaseTimer
@export var enemy_spawner: EnemySpawner

@export_group("UI")
@export var day_label: Label
@export var phase_label: Label
@export var status_label: Label

@export_group("Rest Settings")
@export var rest_transition_duration: float = 3.0

var current_day: int = 1
var current_phase: Phase = Phase.PREPARATION
var current_config: DayConfig

var combat_time_finished: bool = false
var can_rest: bool = false
var is_advancing_day: bool = false


func _ready() -> void:
	if phase_timer == null:
		push_error("DayCycleManager: PhaseTimer belum dihubungkan.")
		return

	phase_timer.phase_finished.connect(_on_phase_finished)

	if enemy_spawner != null:
		enemy_spawner.enemy_count_changed.connect(_on_enemy_count_changed)

	if start_immediately:
		start_day(starting_day)


func start_day(day: int) -> void:
	var config := _find_day_config(day)

	if config == null:
		push_error("DayCycleManager: DayConfig untuk Day %d tidak ditemukan." % day)
		return

	current_day = day
	current_config = config

	combat_time_finished = false
	_set_can_rest(false)

	day_changed.emit(current_day)

	if current_day == 1:
		change_phase(Phase.TUTORIAL)
		_start_combat()
	elif current_config.preparation_duration <= 0.0:
		change_phase(Phase.COMBAT)
		_start_combat()
	else:
		change_phase(Phase.PREPARATION)
		phase_timer.start_phase(
			PhaseTimer.Phase.PREP,
			current_config.preparation_duration
		)

	update_ui()


func _find_day_config(day: int) -> DayConfig:
	for config in day_configs:
		if config != null and config.day_number == day:
			return config

	return null


func change_phase(new_phase: Phase) -> void:
	current_phase = new_phase

	phase_changed.emit(new_phase)
	update_ui()


func _start_combat() -> void:
	combat_time_finished = false
	_set_can_rest(false)

	if current_phase != Phase.TUTORIAL:
		change_phase(Phase.COMBAT)

	phase_timer.start_phase(
		PhaseTimer.Phase.COMBAT,
		current_config.combat_min_duration
	)

	if enemy_spawner != null:
		enemy_spawner.apply_day_config(current_config)
		enemy_spawner.start()


func _on_phase_finished(phase: PhaseTimer.Phase) -> void:
	if phase == PhaseTimer.Phase.PREP:
		_start_combat()

	elif phase == PhaseTimer.Phase.COMBAT:
		combat_time_finished = true

		if enemy_spawner != null:
			enemy_spawner.stop()

		check_rest_condition()


func _on_enemy_count_changed(_count: int) -> void:
	check_rest_condition()


func check_rest_condition() -> void:
	if current_phase != Phase.COMBAT and current_phase != Phase.TUTORIAL:
		return

	if not combat_time_finished:
		return

	if enemy_spawner != null and enemy_spawner.alive_count > 0:
		update_ui()
		return

	_set_can_rest(true)
	update_ui()


func _set_can_rest(value: bool) -> void:
	if can_rest == value:
		return

	can_rest = value
	rest_available_changed.emit(can_rest)


func request_rest() -> void:
	if not can_rest or is_advancing_day:
		return

	_advance_day()


func _advance_day() -> void:
	is_advancing_day = true

	_set_can_rest(false)

	if enemy_spawner != null:
		enemy_spawner.stop()

	phase_timer.stop_timer()

	change_phase(Phase.RESTING)

	# Ubah ambience kembali ke suasana pagi.
	phase_timer.set_visual_phase("PREP")

	await get_tree().create_timer(rest_transition_duration).timeout

	change_phase(Phase.MORNING_EVENT)
	morning_event_started.emit()

	current_day += 1
	is_advancing_day = false

	start_day(current_day)


func update_ui() -> void:
	if day_label != null:
		day_label.text = "DAY %02d" % current_day

	if phase_label != null:
		match current_phase:
			Phase.TUTORIAL:
				phase_label.text = "TUTORIAL"

			Phase.PREPARATION:
				phase_label.text = "PREPARATION"

			Phase.COMBAT:
				phase_label.text = "COMBAT"

			Phase.RESTING:
				phase_label.text = "RESTING"

			Phase.MORNING_EVENT:
				phase_label.text = "MORNING EVENT"

	if status_label != null:
		if can_rest:
			status_label.text = "All enemies defeated! Return to your hut and rest."
		elif current_phase == Phase.COMBAT or current_phase == Phase.TUTORIAL:
			var count := 0

			if enemy_spawner != null:
				count = enemy_spawner.alive_count

			status_label.text = "Enemies remaining: %d" % count

		elif current_phase == Phase.PREPARATION:
			status_label.text = "Prepare your farm before night falls."

		elif current_phase == Phase.RESTING:
			status_label.text = "Resting..."

		else:
			status_label.text = ""
