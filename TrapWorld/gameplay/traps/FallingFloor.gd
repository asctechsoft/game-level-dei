extends TrapBase
## Falling Floor (GDD 6): looks like normal ground. Stepping on it starts a
## short delay, then it drops away, exposing the pit below (Player dies via
## the level's bottomless-pit Area2D, not via this node).

const Layers = preload("res://common/Layers.gd")
const UITheme = preload("res://common/UITheme.gd")

var width: float = 160.0
var height: float = 60.0
var fall_delay: float = 0.45

var _col: CollisionShape2D
var _visual: ColorRect
var _start_pos: Vector2
var _falling := false

func setup(def: Dictionary) -> void:
	super.setup(def)
	width = float(def.get("w", width))
	height = float(def.get("h", height))
	fall_delay = float(def.get("delay", fall_delay))

func _ready() -> void:
	_start_pos = position

	var body := StaticBody2D.new()
	body.collision_layer = Layers.GROUND
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, height)
	_col = CollisionShape2D.new()
	_col.shape = shape
	_col.position = Vector2(width / 2.0, height / 2.0)
	body.add_child(_col)
	add_child(body)

	_visual = ColorRect.new()
	_visual.color = UITheme.GROUND_COLOR
	_visual.size = Vector2(width, height)
	add_child(_visual)

	var sensor := Area2D.new()
	sensor.collision_layer = 0
	sensor.collision_mask = Layers.PLAYER
	var s_shape := RectangleShape2D.new()
	s_shape.size = Vector2(width, 12)
	var s_col := CollisionShape2D.new()
	s_col.shape = s_shape
	s_col.position = Vector2(width / 2.0, -4)
	sensor.add_child(s_col)
	sensor.body_entered.connect(_on_step)
	add_child(sensor)

func _on_step(body: Node) -> void:
	if fired or _falling:
		return
	if body.is_in_group("player"):
		fire()

func fire() -> void:
	if fired:
		return
	super.fire()
	_falling = true
	var t := get_tree().create_timer(fall_delay)
	t.timeout.connect(_start_fall)

func _start_fall() -> void:
	if not is_inside_tree():
		return
	_col.set_deferred("disabled", true)
	var tw := create_tween()
	tw.tween_property(self, "position:y", position.y + 500, 0.4)
	tw.tween_callback(func(): _visual.visible = false)

func reset() -> void:
	super.reset()
	_falling = false
	position = _start_pos
	_col.disabled = false
	_visual.visible = true
