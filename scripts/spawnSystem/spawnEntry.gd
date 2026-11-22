extends Resource
class_name SpawnEntry

enum EnemyType {
	WORM,
	RAT,
	OTHER
}

@export var scene: PackedScene
@export var max_alive: int = 5
@export var enemy_type: EnemyType = EnemyType.OTHER
