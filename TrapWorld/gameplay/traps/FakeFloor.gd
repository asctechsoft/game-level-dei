extends TrapBase
## Fake Floor (GDD 6): looks solid; as the player approaches (player_x
## trigger) the collider drops out instantly so the player falls through,
## while the tile itself visibly crumbles and falls away rather than just
## popping out of existence.

const Layers = preload("res://common/Layers.gd")
const UITheme = preload("res://common/UITheme.gd")

var width: float = 140.0
var height: float = 60.0
var _col: CollisionShape2D
var _visual: ColorRect
var _start_pos: Vector2

func setup(def: Dictionary) -> void:
	super.setup(def)
	width = float(def.get("w", width))
	height = float(def.get("h", height))

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

func fire() -> void:
	if fired:
		return
	super.fire()
	_col.set_deferred("disabled", true)
	var tw := create_tween()
	tw.tween_property(self, "position:y", position.y + 500, 0.4)
	tw.tween_callback(func(): _visual.visible = false)

func reset() -> void:
	super.reset()
	_col.disabled = false
	position = _start_pos
	_visual.visible = true
