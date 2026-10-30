extends TrapBase
## Hidden Spike (GDD 6): invisible + non-lethal until the player crosses
## trigger_x, then the spikes pop up and stay hazardous. Optional "travel"/
## "speed" in the level def make it slide back and forth once fired instead
## of sitting still, same as MovingWall - most levels leave travel at 0.

const Layers = preload("res://common/Layers.gd")
const SPIKE_TEXTURE = preload("res://assets/img_đinh_gai.png")

var width: float = 40.0
var height: float = 50.0
var travel: float = 0.0
var speed: float = 120.0
var visual: Sprite2D
var hazard_area: Area2D
var _start_pos: Vector2
var _move_tween: Tween

func setup(def: Dictionary) -> void:
	super.setup(def)
	width = float(def.get("w", width))
	height = float(def.get("h", height))
	travel = float(def.get("travel", travel))
	speed = float(def.get("speed", speed))

func _ready() -> void:
	_start_pos = position

	visual = Sprite2D.new()
	visual.texture = SPIKE_TEXTURE
	var tex_size: Vector2 = SPIKE_TEXTURE.get_size()
	var s: float = height / tex_size.y
	visual.scale = Vector2(s, s)
	visual.visible = false
	add_child(visual)

	hazard_area = Area2D.new()
	hazard_area.collision_layer = Layers.HAZARD
	hazard_area.collision_mask = Layers.PLAYER
	hazard_area.monitoring = false
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width * 0.55, height * 0.75)
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2(0, height * 0.1)
	hazard_area.add_child(col)
	hazard_area.body_entered.connect(_on_hazard_entered)
	add_child(hazard_area)

func _on_hazard_entered(body: Node) -> void:
	if body.is_in_group("player") and body.has_method("die"):
		body.die()

func fire() -> void:
	if fired:
		return
	super.fire()
	visual.visible = true
	hazard_area.monitoring = true
	if travel > 0.0:
		var dur: float = travel / speed
		_move_tween = create_tween()
		_move_tween.set_loops()
		_move_tween.tween_property(self, "position:x", _start_pos.x + travel, dur)
		_move_tween.tween_property(self, "position:x", _start_pos.x, dur)

func reset() -> void:
	super.reset()
	if _move_tween:
		_move_tween.kill()
		_move_tween = null
	position = _start_pos
	visual.visible = false
	hazard_area.monitoring = false
