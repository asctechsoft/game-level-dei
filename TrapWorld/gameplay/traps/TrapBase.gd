extends Node2D
class_name TrapBase
## Shared trigger/state machine for every trap type in GDD section 6/23.
## initial_state is always "hidden"; fire() reveals/activates the trap exactly
## once, reset() restores it after death per section 19 ("trạng thái level
## reset nhanh về trạng thái ban đầu").

signal triggered(id: String)

var trap_id: String = ""
var trap_type: String = ""
var trigger_def: Dictionary = {}
var fired: bool = false

func setup(def: Dictionary) -> void:
	trap_id = def.get("id", "")
	trap_type = def.get("type", "")
	trigger_def = def.get("trigger", {})

## Centrally polled each frame by LevelBuilder for position/chain triggers.
## Contact-based traps (falling_floor) return false here and fire themselves
## from an Area2D signal instead.
func poll_trigger(player: Node2D, completed_ids: Dictionary) -> bool:
	if fired:
		return false
	match String(trigger_def.get("type", "")):
		"player_x":
			return player.global_position.x >= float(trigger_def.get("value", 0))
		"trap_completed":
			return completed_ids.has(String(trigger_def.get("target", "")))
		_:
			return false

func fire() -> void:
	if fired:
		return
	fired = true
	triggered.emit(trap_id)

func reset() -> void:
	fired = false
