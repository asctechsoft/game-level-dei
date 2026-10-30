extends TrapBase
## Moving Wall (GDD 6): charges toward the player when triggered, holds
## briefly, then retracts so the level stays completable after a successful
## dodge.

const Layers = preload("res://common/Layers.gd")
const UITheme = preload("res://common/UITheme.gd")

var travel: float = 260.0
var speed: float = 520.0
var _start_pos: Vector2
var _hazard: Area2D

func setup(def: Dictionary) -> void:
	super.setup(def)
	travel = float(def.get("travel", travel))
	speed = float(def.get("speed", speed))

func _ready() -> void:
	_start_pos = position

	var visual := ColorRect.new()
	visual.color = UITheme.ACCENT_RED.darkened(0.15)
	visual.size = Vector2(36, 140)
	visual.position = Vector2(-18, -140)
	add_child(visual)

	_hazard = Area2D.new()
	_hazard.collision_layer = Layers.HAZARD
	_hazard.collision_mask = Layers.PLAYER
	_hazard.monitoring = false
	var shape := RectangleShape2D.new()
	shape.size = Vector2(32, 136)
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2(0, -70)
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
	_hazard.monitoring = true
	var dur: float = travel / speed
	var tw := create_tween()
	tw.tween_property(self, "position:x", _start_pos.x + travel, dur)
	tw.tween_interval(0.3)
	tw.tween_property(self, "position:x", _start_pos.x, dur)
	tw.tween_callback(func(): _hazard.monitoring = false)

func reset() -> void:
	super.reset()
	position = _start_pos
	_hazard.monitoring = false
