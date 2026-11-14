extends Node
class_name PhaseTimer

signal phase_changed(new_phase: String)
signal combat_finished

enum Phase { PREP, COMBAT }
var current_phase: Phase = Phase.PREP

@export var prep_duration: float = 60.0
@export var combat_duration: float = 90.0
@export var auto_start: bool = true

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

func start_phase(phase: Phase) -> void:
	current_phase = phase
	var duration: float = prep_duration if phase == Phase.PREP else combat_duration

	timer.start(duration)
	phase_changed.emit("PREP" if phase == Phase.PREP else "COMBAT")
	_update_label(duration)

# PREP (60 -> 0) => COMBAT (90 -> 0) => kirim signal => PREP lagi
func _on_timer_timeout() -> void:
	if current_phase == Phase.PREP:
		timer_label.add_theme_color_override("font_color",Color.WHITE)
		start_phase(Phase.COMBAT)
	else:
		timer_label.add_theme_color_override("font_color",Color.BLACK)
		combat_finished.emit()
		start_phase(Phase.PREP)

func _update_label(time_left: float) -> void:
	timer_label.text = str(ceili(time_left))
