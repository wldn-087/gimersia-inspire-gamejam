extends Node
class_name AmbienceController

@export var phase_timer: PhaseTimer
@export var sun: DirectionalLight3D
@export var world_env: WorldEnvironment

@export_group("PREP (terang)")
@export var prep_light_energy: float = 1.0
@export var prep_ambient_energy: float = 1.0
@export var prep_sky_energy: float = 1.0

@export_group("COMBAT (gelap)")
@export var combat_light_energy: float = 0.1
@export var combat_ambient_energy: float = 0.3
@export var combat_sky_energy: float = 0.1

@export var transition_duration: float = 1.5

var _tween: Tween

func _ready() -> void:
	if phase_timer == null or sun == null or world_env == null or world_env.environment == null:
		push_error("AmbienceController: phase_timer / sun / world_env / environment belum di-set!")
		return
	phase_timer.phase_changed.connect(_on_phase_changed)

func _on_phase_changed(new_phase: String) -> void:
	var is_prep: bool = new_phase == "PREP"
	print("[Ambience] ", new_phase)

	var env: Environment = world_env.environment
	if _tween and _tween.is_valid():
		_tween.kill()

	_tween = create_tween().set_parallel(true)
	_tween.tween_property(sun, "light_energy",
		prep_light_energy if is_prep else combat_light_energy, transition_duration)
	_tween.tween_property(env, "ambient_light_energy",
		prep_ambient_energy if is_prep else combat_ambient_energy, transition_duration)
	_tween.tween_property(env, "background_energy_multiplier",
		prep_sky_energy if is_prep else combat_sky_energy, transition_duration)
