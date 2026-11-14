extends Node
class_name AmbienceController

@export var phase_timer: PhaseTimer
@export var sun: DirectionalLight3D
@export var world_env: WorldEnvironment

@export_group("PREP (terang)")
@export var prep_light_energy: float = 1.0
@export var prep_ambient_energy: float = 1.0
@export var prep_light_color: Color = Color(1.0, 0.97, 0.9)

@export_group("COMBAT (biru)")
@export var combat_light_energy: float = 0.4
@export var combat_ambient_energy: float = 0.5
@export var combat_light_color: Color = Color(0.3, 0.45, 1.0)       # cahaya biru
@export var combat_sky_top_color: Color = Color(0.02, 0.04, 0.2)    # biru tua
@export var combat_sky_horizon_color: Color = Color(0.05, 0.1, 0.3)
@export var combat_ground_color: Color = Color(0.02, 0.03, 0.12)

@export var transition_duration: float = 1.5

var _tween: Tween
var _sky_mat: ProceduralSkyMaterial
var _orig_top: Color
var _orig_horizon: Color
var _orig_ground_horizon: Color
var _orig_ground_bottom: Color

func _ready() -> void:
	if phase_timer == null or sun == null or world_env == null or world_env.environment == null:
		push_error("AmbienceController: phase_timer / sun / world_env / environment belum di-set!")
		return

	var env: Environment = world_env.environment
	if env.sky and env.sky.sky_material is ProceduralSkyMaterial:
		_sky_mat = env.sky.sky_material as ProceduralSkyMaterial
		# simpan warna asli untuk fase PREP
		_orig_top = _sky_mat.sky_top_color
		_orig_horizon = _sky_mat.sky_horizon_color
		_orig_ground_horizon = _sky_mat.ground_horizon_color
		_orig_ground_bottom = _sky_mat.ground_bottom_color
	else:
		push_warning("AmbienceController: Sky bukan ProceduralSkyMaterial, langit hanya digelapkan lewat energy.")

	phase_timer.phase_changed.connect(_on_phase_changed)

func _on_phase_changed(new_phase: String) -> void:
	var is_prep: bool = new_phase == "PREP"
	print("[Ambience] ", new_phase)

	var env: Environment = world_env.environment
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_parallel(true)

	# Cahaya
	_tween.tween_property(sun, "light_energy",
		prep_light_energy if is_prep else combat_light_energy, transition_duration)
	_tween.tween_property(sun, "light_color",
		prep_light_color if is_prep else combat_light_color, transition_duration)
	_tween.tween_property(env, "ambient_light_energy",
		prep_ambient_energy if is_prep else combat_ambient_energy, transition_duration)

	# Langit
	if _sky_mat:
		_tween.tween_property(_sky_mat, "sky_top_color",
			_orig_top if is_prep else combat_sky_top_color, transition_duration)
		_tween.tween_property(_sky_mat, "sky_horizon_color",
			_orig_horizon if is_prep else combat_sky_horizon_color, transition_duration)
		_tween.tween_property(_sky_mat, "ground_horizon_color",
			_orig_ground_horizon if is_prep else combat_sky_horizon_color, transition_duration)
		_tween.tween_property(_sky_mat, "ground_bottom_color",
			_orig_ground_bottom if is_prep else combat_ground_color, transition_duration)
	else:
		_tween.tween_property(env, "background_energy_multiplier",
			1.0 if is_prep else 0.15, transition_duration)
