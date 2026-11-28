
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

# Menandakan timer Combat sudah selesai.
var _combat_timer_finished: bool = false

func _ready() -> void:
	add_to_group("day_cycle_manager")
	
	if phase_timer == null or enemy_spawner == null:
		push_error("DayCycleManager: Referensi belum lengkap.")
		return

	phase_timer.phase_finished.connect(_on_phase_finished)
	enemy_spawner.enemy_count_changed.connect(_on_enemy_count_changed)

	if SaveManager.has_pending_save():
		return

	start_day(starting_day)


func start_day(day: int) -> void:
	var config := _find_day_config(day)

	if config == null:
		push_error("DayConfig untuk hari %d tidak ditemukan." % day)
		return

	current_day = day
	current_config = config

	day_changed.emit(current_day)
	update_plant_growth(current_config)
	
	if current_config.preparation_duration > 0.0:
		_start_preparation()
	else:
		_start_night()


func _find_day_config(day: int) -> DayConfig:
	for config in day_configs:
		if config != null and config.day_number == day:
			return config

	return null

func update_plant_growth(config: DayConfig) -> void:
	if config == null: return

	for lahan in get_tree().get_nodes_in_group("saveable_plants"):
		if is_instance_valid(lahan) and lahan.has_method("apply_growth_stage"):
			lahan.apply_growth_stage(config.plant_growth_stage)


func _start_preparation() -> void:
	current_phase = Phase.PREPARATION
	phase_changed.emit(current_phase)

	phase_timer.start_phase(
		PhaseTimer.Phase.PREP,
		current_config.preparation_duration
	)


func _start_night() -> void:
	current_phase = Phase.COMBAT
	_combat_timer_finished = false

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

	print("Hari %d selesai. Pemain dapat beristirahat." % current_day)


func _on_phase_finished(phase: PhaseTimer.Phase) -> void:
	if phase == PhaseTimer.Phase.PREP:
		_start_night()

	elif phase == PhaseTimer.Phase.COMBAT:
		_combat_timer_finished = true

		# Tidak ada musuh baru yang di-spawn setelah timer selesai.
		enemy_spawner.stop()

		_check_rest_condition()


func _on_enemy_count_changed(count: int) -> void:
	print("Musuh tersisa: ", count)

	if current_phase == Phase.COMBAT:
		_check_rest_condition()


func _check_rest_condition() -> void:
	if current_phase != Phase.COMBAT:
		return

	if not _combat_timer_finished:
		return

	if enemy_spawner.alive_count > 0:
		return

	_start_rest()


func request_rest() -> void:
	if current_phase != Phase.RESTING:
		return

	if current_day >= 10:
		return
		
	var next_day = current_day + 1
	
	if not SaveManager.save_next_day(next_day):
		push_error("Gagal menyimpan progress.")
		return

	start_day(next_day)
