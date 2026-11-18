extends RefCounted
class_name EnemyVisual
## Komponen tampilan: animasi dan arah hadap sprite.

const FACING_DEADZONE: float = 0.1

var facing_left: bool = false

var _enemy: Enemy
var _sprite: AnimatedSprite3D


func _init(enemy: Enemy, sprite: AnimatedSprite3D) -> void:
	_enemy = enemy
	_sprite = sprite


func play_anim(anim_name: String) -> void:
	if _sprite and _sprite.sprite_frames.has_animation(anim_name) and _sprite.animation != anim_name:
		_sprite.play(anim_name)


# Menunggu animasi "die" selesai (kalau ada). Pakai: await visual.play_death()
func play_death() -> void:
	if _sprite and _sprite.sprite_frames.has_animation("die"):
		_sprite.play("die")
		await _sprite.animation_finished


func face_target(target: Node3D) -> void:
	if target == null:
		return
	var dx: float = target.global_position.x - _enemy.global_position.x
	if abs(dx) > FACING_DEADZONE:
		set_facing(dx < 0.0)


func set_facing(left: bool) -> void:
	if left == facing_left:
		return
	facing_left = left
	_sprite.flip_h = left   # kalau sprite terbalik, ganti jadi: _sprite.flip_h = not left
	_enemy._on_facing_changed(left)
