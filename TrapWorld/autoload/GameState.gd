extends Node
## Local-first player profile & progress, per GDD section 10 (Save/Progress)
## and section 2 step 03 (Guest/Device ID init). Persists to user://save.json.

const SAVE_PATH := "user://save.json"

var guest_id: String = ""
var first_launch: bool = true
var onboarding_done: bool = false

# progress = { "unlocked": [1], "completed": { "1": {"deaths": int, "best_time": float} } }
var progress: Dictionary = {"unlocked": [1], "completed": {}}

# settings per GDD 3.9
var settings: Dictionary = {"music": 0.8, "sfx": 0.8, "vibration": true}

# transient, chosen right before entering Gameplay scene
var current_playing_level: int = 1

func _ready() -> void:
	load_state()

func load_state() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		guest_id = _generate_guest_id()
		save_state()
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		guest_id = _generate_guest_id()
		return
	var text := f.get_as_text()
	f.close()
	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		guest_id = _generate_guest_id()
		return
	guest_id = data.get("guest_id", _generate_guest_id())
	first_launch = data.get("first_launch", true)
	onboarding_done = data.get("onboarding_done", false)
	progress = data.get("progress", progress)
	settings = data.get("settings", settings)
	if not progress.has("unlocked"):
		progress["unlocked"] = [1]
	if not progress.has("completed"):
		progress["completed"] = {}

func save_state() -> void:
	var data := {
		"guest_id": guest_id,
		"first_launch": first_launch,
		"onboarding_done": onboarding_done,
		"progress": progress,
		"settings": settings,
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data, "\t"))
		f.close()

func _generate_guest_id() -> String:
	return "guest_%d_%d" % [Time.get_unix_time_from_system(), randi() % 100000]

func mark_first_launch_seen() -> void:
	first_launch = false
	onboarding_done = true
	save_state()

func is_level_unlocked(level_id: int) -> bool:
	return progress["unlocked"].has(level_id)

func is_level_completed(level_id: int) -> bool:
	return progress["completed"].has(str(level_id))

func unlock_level(level_id: int) -> void:
	if not progress["unlocked"].has(level_id):
		progress["unlocked"].append(level_id)

func complete_level(level_id: int, deaths: int, time_sec: float) -> void:
	var key := str(level_id)
	var prev: Dictionary = progress["completed"].get(key, {})
	var best_time: float = prev.get("best_time", time_sec)
	var best_deaths: int = prev.get("best_deaths", deaths)
	progress["completed"][key] = {
		"deaths": deaths,
		"time": time_sec,
		"best_time": min(best_time, time_sec),
		"best_deaths": min(best_deaths, deaths),
	}
	unlock_level(level_id + 1)
	current_playing_level = level_id
	save_state()

func get_continue_level() -> int:
	var unlocked: Array = progress["unlocked"]
	var highest := 1
	for id in unlocked:
		if id > highest:
			highest = id
	return highest

func has_any_progress() -> bool:
	return progress["completed"].size() > 0
