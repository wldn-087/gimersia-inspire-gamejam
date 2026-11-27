
extends Interactable
class_name Chicken

@export_group("References")
@export var day_cycle_manager: DayCycleManager

@onready var chicken: AnimatedSprite3D = $AnimatedSprite3D

@export_group("Egg")
@export var heal_amount: float = 25.0
@onready var egg_animation: AnimationPlayer = $AnimationPlayer

var has_egg: bool = false
var _last_produced_day: int = -1


func _ready() -> void:
	prompt_text = "[E] Ambil Telur"
	super._ready()

	if day_cycle_manager == null:
		push_error("Chicken: DayCycleManager belum dihubungkan.")
		return

	day_cycle_manager.day_changed.connect(_on_day_changed)

	# Menangani kondisi ketika ayam baru siap setelah hari dimulai.
	_on_day_changed(day_cycle_manager.current_day)


func _on_day_changed(day: int) -> void:
	if day == _last_produced_day:
		return

	_last_produced_day = day

	# Telur yang belum diambil tidak akan ditumpuk.
	if has_egg:
		return

	has_egg = true
	interaction_enabled = true
	chicken.play("has_egg")
	egg_animation.play("floating")

	print("Ayam menghasilkan telur pada hari ", day)


func interact() -> void:
	if not has_egg:
		return

	var player := get_tree().get_first_node_in_group("player") as Player

	if player == null:
		push_warning("Chicken: Player tidak ditemukan.")
		return

	var health_component := player.get_node_or_null(
		"Components/HealthComponent"
	) as HealthComponent

	if health_component == null:
		push_warning("Chicken: HealthComponent tidak ditemukan.")
		return

	# Telur tidak dikonsumsi jika HP penuh atau pemain sudah mati.
	if health_component.current_health <= 0.0:
		return

	health_component.heal(heal_amount)

	has_egg = false
	interaction_enabled = false
	chicken.play("normal")
	egg_animation.play("pop")

	print("Telur digunakan. Player mendapatkan ", heal_amount, " HP.")
