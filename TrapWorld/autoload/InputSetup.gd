extends Node
## Registers unified input actions at runtime so keyboard (desktop testing)
## and on-screen touch buttons (Android) both drive the same actions.

func _ready() -> void:
	_bind("move_left", [KEY_LEFT, KEY_A])
	_bind("move_right", [KEY_RIGHT, KEY_D])
	_bind("jump", [KEY_SPACE, KEY_UP, KEY_W])
	_bind("pause_action", [KEY_ESCAPE])

func _bind(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)
