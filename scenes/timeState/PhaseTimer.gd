
extends Node
class_name PhaseTimer

signal phase_changed(new_phase: String)
signal phase_finished(phase: Phase)

enum Phase {
	PREP,
	COMBAT,
	RESTING
}

var current_phase: Phase = Phase.PREP

@export var prep_duration: float = 60.0
@export var combat_duration: float = 90.0
@export var auto_start: bool = false

@onready var timer: Timer = $Timer
@onready var timer_label: Label = $CanvasLayer/Label


func _ready() -> void:
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)

	if auto_start:
		start_phase(Phase.PREP)


func _process(_delta: float) -> void:
	if not timer.is_stopped():
		_update_label(timer.time_left)


func start_phase(phase: Phase, duration: float = -1.0) -> void:
	current_phase = phase

	var phase_duration := duration

	if phase_duration < 0.0:
		phase_duration = prep_duration if phase == Phase.PREP else combat_duration

	timer.start(phase_duration)

	var phase_name := _get_phase_name(phase)
	phase_changed.emit(phase_name)

	_update_label(phase_duration)


func set_phase(phase: Phase) -> void:
	current_phase = phase
	timer.stop()

	phase_changed.emit(_get_phase_name(phase))
	_update_label(0.0)


func stop_timer() -> void:
	timer.stop()
	_update_label(0.0)


func _get_phase_name(phase: Phase) -> String:
	match phase:
		Phase.PREP:
			return "PREP"
		Phase.COMBAT:
			return "COMBAT"
		Phase.RESTING:
			return "RESTING"

	return "UNKNOWN"


func _on_timer_timeout() -> void:
	phase_finished.emit(current_phase)


func _update_label(time_left: float) -> void:
	timer_label.text = str(ceili(time_left))
