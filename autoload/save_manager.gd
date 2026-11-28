
extends Node

const SAVE_PATH = "user://savegame.json"
const SAVE_VERSION = 1

var pending_save: Dictionary = {}
var new_game_requested: bool = false


# ==================================================
# FILE MANAGEMENT
# ==================================================

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func write_save(data: Dictionary) -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		push_error("SaveManager: Gagal membuka file save.")
		return false

	file.store_string(JSON.stringify(data, "\t"))
	file.close()

	print("SaveManager: Save berhasil ditulis.")
	return true


func read_save() -> Dictionary:
	if not has_save():
		push_warning("SaveManager: File save tidak ditemukan.")
		return {}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		push_error("SaveManager: Gagal membuka file save.")
		return {}

	var content := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(content)

	if error != OK:
		push_error(
			"SaveManager: JSON tidak valid: %s" %
			json.get_error_message()
		)
		return {}

	if not json.data is Dictionary:
		push_error("SaveManager: Format save tidak valid.")
		return {}

	var data: Dictionary = json.data
	var version := int(data.get("save_version", 0))

	if version != SAVE_VERSION:
		push_error("SaveManager: Versi save tidak kompatibel.")
		return {}

	return data


# ==================================================
# MAIN MENU
# ==================================================

func prepare_continue() -> bool:
	var data := read_save()

	if data.is_empty():
		return false

	pending_save = data
	new_game_requested = false

	return true


func request_new_game() -> void:
	pending_save.clear()
	new_game_requested = true

	if has_save():
		var path := ProjectSettings.globalize_path(SAVE_PATH)
		var error := DirAccess.remove_absolute(path)

		if error != OK:
			push_error("SaveManager: Gagal menghapus save lama.")
			new_game_requested = false


# ==================================================
# COLLECT PLANT DATA
# ==================================================

func collect_plants_data() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var plants := get_tree().get_nodes_in_group("saveable_plants")

	var used_ids: Dictionary = {}

	for plant in plants:
		var plant_id := str(plant.get("save_id"))

		if plant_id.is_empty():
			push_error("SaveManager: Lahan memiliki ID kosong.")
			return []

		if used_ids.has(plant_id):
			push_error("SaveManager: ID lahan duplikat: " + plant_id)
			return []

		if not plant.has_method("get_save_data"):
			push_error("SaveManager: Lahan tidak memiliki get_save_data().")
			return []

		used_ids[plant_id] = true

		result.append({
			"id": plant_id,
			"data": plant.get_save_data()
		})

	return result


# ==================================================
# SAVE GAME
# ==================================================

func save_next_day(next_day: int) -> bool:
	var player := get_tree().get_first_node_in_group("player")

	if player == null:
		push_error("SaveManager: Player tidak ditemukan.")
		return false

	if not player.has_method("get_save_data"):
		push_error("SaveManager: Player tidak memiliki get_save_data().")
		return false

	var plants_data := collect_plants_data()

	var data := {
		"save_version": SAVE_VERSION,
		"current_day": next_day,
		"player": player.get_save_data(),
		"plants": plants_data
	}

	return write_save(data)


# ==================================================
# CREATE NEW GAME SAVE
# ==================================================

func initialize_new_game(starting_day: int) -> bool:
	var success := save_next_day(starting_day)

	if success:
		new_game_requested = false

	return success


# ==================================================
# FIND PLANTS BY ID
# ==================================================

func get_plant_lookup() -> Dictionary:
	var lookup: Dictionary = {}
	var plants := get_tree().get_nodes_in_group("saveable_plants")

	for plant in plants:
		var plant_id := str(plant.get("save_id"))

		if plant_id.is_empty():
			continue

		if lookup.has(plant_id):
			push_error("SaveManager: ID lahan duplikat: " + plant_id)
			continue

		lookup[plant_id] = plant

	return lookup


# ==================================================
# APPLY SAVE DATA
# ==================================================

func apply_pending_save() -> bool:
	if pending_save.is_empty():
		return false

	var player := get_tree().get_first_node_in_group("player")

	if player == null:
		push_error("SaveManager: Player tidak ditemukan.")
		return false

	var player_data: Dictionary = pending_save.get("player", {})

	if not player.has_method("apply_save_data"):
		push_error("SaveManager: Player tidak memiliki apply_save_data().")
		return false

	player.apply_save_data(player_data)

	var plant_lookup := get_plant_lookup()
	var plants_data: Array = pending_save.get("plants", [])

	for entry in plants_data:
		var plant_id := str(entry.get("id", ""))

		if not plant_lookup.has(plant_id):
			push_warning("SaveManager: Lahan tidak ditemukan: " + plant_id)
			continue

		var plant = plant_lookup[plant_id]
		var plant_data: Dictionary = entry.get("data", {})

		if plant.has_method("apply_save_data"):
			plant.apply_save_data(plant_data)

	var day_manager := get_tree().get_first_node_in_group("day_cycle_manager") as DayCycleManager

	if day_manager == null:
		push_error("SaveManager: DayCycleManager tidak ditemukan.")
		return false

	var saved_day := int(pending_save.get("current_day", 1))

	day_manager.start_day(saved_day)

	print("SaveManager: Continue ke hari ", saved_day)

	pending_save.clear()

	return true

func has_pending_save() -> bool:
	return not pending_save.is_empty()

func debug_get_save_path() -> void:
	print("Save location: ", ProjectSettings.globalize_path(SAVE_PATH))
