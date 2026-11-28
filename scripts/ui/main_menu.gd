extends Control

const SKALA_NORMAL := Vector2(0.5, 0.5)
const SKALA_TEKAN := Vector2(0.625, 0.625)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var daftar_tombol: Array[TextureButton] = [
		$NewGameButton,
		$ContinueButton,
		$QuitButton
	]
	
	for tombol in daftar_tombol:
		# Pindahkan poros ke tengah tombol tanpa menggeser posisinya di layar
		tombol.pivot_offset = tombol.size / 2.0
		tombol.position -= tombol.pivot_offset * (Vector2.ONE - tombol.scale)
		
		# Sambungkan efek membesar dan mengecil secara otomatis
		tombol.button_down.connect(_animasi_skala.bind(tombol, SKALA_TEKAN))
		tombol.button_up.connect(_animasi_skala.bind(tombol, SKALA_NORMAL))


func _animasi_skala(tombol: TextureButton, target_skala: Vector2) -> void:
	var tween := create_tween()
	tween.tween_property(tombol, "scale", target_skala, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_new_game_button_pressed() -> void:
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://scenes/percobaan.tscn")


func _on_continue_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()
