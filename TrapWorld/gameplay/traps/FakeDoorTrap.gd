extends TrapBase
## Fake Door (GDD 6): as the player nears the goal, the door slides/teleports
## to a new spot, forcing them to keep going. LevelBuilder assigns `door` and
## resets its position centrally on death.

var door: Node2D
var shift: Vector2 = Vector2(220, 0)

func setup(def: Dictionary) -> void:
	super.setup(def)
	var off: Array = def.get("shift", [220, 0])
	shift = Vector2(float(off[0]), float(off[1]))

func fire() -> void:
	if fired or door == null:
		return
	super.fire()
	var target: Vector2 = door.position + shift
	var tw := door.create_tween()
	tw.tween_property(door, "position", target, 0.35)
