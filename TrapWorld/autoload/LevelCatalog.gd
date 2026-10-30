extends Node
## Data-driven level manifest + loader. Local Starter Pack per GDD section 8.
## A future remote pack would extend/replace entries here without any
## gameplay code changes (Godot only executes what the JSON describes).

const MANIFEST_PATH := "res://data/manifest.json"
const LEVELS_DIR := "res://data/levels/"

var manifest: Array = []
var _level_cache: Dictionary = {}

func _ready() -> void:
	_load_manifest()

func _load_manifest() -> void:
	var f := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if f == null:
		push_error("LevelCatalog: manifest not found at %s" % MANIFEST_PATH)
		return
	var data = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(data) == TYPE_DICTIONARY and data.has("levels"):
		manifest = data["levels"]

func get_level_list() -> Array:
	return manifest

func get_level_meta(level_id: int) -> Dictionary:
	for entry in manifest:
		if int(entry.get("id", -1)) == level_id:
			return entry
	return {}

func get_max_level_id() -> int:
	var max_id := 0
	for entry in manifest:
		max_id = max(max_id, int(entry.get("id", 0)))
	return max_id

func get_level_data(level_id: int) -> Dictionary:
	if _level_cache.has(level_id):
		return _level_cache[level_id]
	var meta := get_level_meta(level_id)
	var file_name: String = meta.get("file", "level_%03d.json" % level_id)
	var path := LEVELS_DIR + file_name
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("LevelCatalog: level file not found %s" % path)
		return {}
	var data = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(data) != TYPE_DICTIONARY:
		push_error("LevelCatalog: invalid JSON in %s" % path)
		return {}
	_level_cache[level_id] = data
	return data
