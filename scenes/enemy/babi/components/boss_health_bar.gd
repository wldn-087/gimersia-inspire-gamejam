extends CanvasLayer
class_name BossHealthBar

@export var boss: BoarBoss

@onready var health_bar: TextureProgressBar = $TextureProgressBar
@onready var boss_name: Label = $Label


func _ready() -> void:
	hide()

	if boss == null:
		push_warning("Boss belum dihubungkan.")
		return

	show_boss(boss)


func show_boss(target_boss: BoarBoss) -> void:
	boss = target_boss

	health_bar.max_value = boss.max_health
	health_bar.value = boss.health

	boss_name.text = "BABI HUTAN"

	boss.health_changed.connect(_on_health_changed)
	boss.died.connect(_on_boss_died)

	show()


func _on_health_changed(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current


func _on_boss_died(_boss: Enemy) -> void:
	hide()
	boss = null
