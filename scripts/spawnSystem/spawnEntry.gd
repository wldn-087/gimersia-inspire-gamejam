extends Resource
class_name SpawnEntry
## Satu jenis musuh yang boleh di-spawn, beserta batas jumlahnya.

@export var scene: PackedScene       # mis. ulat.tscn
@export var max_alive: int = 5       # batas musuh jenis ini yang hidup bersamaan
