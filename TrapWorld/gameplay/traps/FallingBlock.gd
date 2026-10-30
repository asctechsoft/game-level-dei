extends TrapBase
## Falling Block (GDD 6): drops from off-screen above onto the path once
## triggered (often chained after another trap via trap_completed).

const Layers = preload("res://common/Layers.gd")
const UITheme = preload("res://common/UITheme.gd")

var drop_distance: float = 420.0
var speed: float = 900.0
var _start_pos: Vector2
var _hazard: Area2D
var _visual: ColorRect

func setup(def: Dictionary) -> void:
	super.setup(def)
	drop_distance = float(def.get("drop_distance", drop_distance))
	speed = float(def.get("speed", speed))

func _ready() -> void:
	_start_pos = position

	_visual = ColorRect.new()
	_visual.color = UITheme.TRAP_COLOR.darkened(0.15)
	_visual.size = Vector2(48, 48)
	_visual.position = Vector2(-24, -24)
	_visual.visible = false
	add_child(_visual)

	_hazard = Area2D.new()
	_hazard.collision_layer = Layers.HAZARD
	_hazard.collision_mask = Layers.PLAYER
	_hazard.monitoring = false
	var shape := RectangleShape2D.new()
	shape.size = Vector2(44, 44)
	var col := CollisionShape2D.new()
	col.shape = shape
	_hazard.add_child(col)
	_hazard.body_entered.connect(_on_hit)
	add_child(_hazard)

func _on_hit(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("die"):
		body.die()

func fire() -> void:
	if fired:
		return
	super.fire()
	_visual.visible = true
	_hazard.monitoring = true
	var tw := create_tween()
	tw.tween_property(self, "position:y", position.y + drop_distance, drop_distance / speed)

func reset() -> void:
	super.reset()
	position = _start_pos
	_visual.visible = false
	_hazard.monitoring = false
