extends Area2D
class_name LevelDoor
## Goal per GDD 3.7/section 18-H. Builds its own placeholder visual so
## LevelBuilder only needs to set position; swap the ColorRect for real art
## later without touching gameplay logic.

const UITheme = preload("res://common/UITheme.gd")
const Layers = preload("res://common/Layers.gd")

signal reached

func _ready() -> void:
	collision_layer = 0
	collision_mask = Layers.PLAYER
	body_entered.connect(_on_body_entered)

	var shape := RectangleShape2D.new()
	shape.size = Vector2(56, 96)
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2(0, -48)
	add_child(col)

	var visual := Polygon2D.new()
	visual.color = UITheme.DOOR_COLOR
	visual.polygon = UITheme.rounded_rect_points(Vector2(48, 90), 10.0)
	visual.position = Vector2(0, -45)
	add_child(visual)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		reached.emit()
