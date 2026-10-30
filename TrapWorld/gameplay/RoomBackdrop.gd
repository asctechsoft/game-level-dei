extends Node2D
class_name RoomBackdrop
## Draws the level's "room" as a rounded, bordered rectangle behind the
## ground/traps/player (Level Devil style reference), plus a few faint
## scattered decorations, so the playable area reads as one distinct panel
## against the darker outside-room backdrop instead of blending into it.

const UITheme = preload("res://common/UITheme.gd")

const RADIUS := 32.0
const BORDER := 18.0
const DECOR_COUNT := 7

var _size: Vector2 = Vector2.ZERO

func set_bounds(bounds: Rect2) -> void:
	_size = bounds.size
	position = bounds.get_center()
	queue_redraw()

func _draw() -> void:
	if _size == Vector2.ZERO:
		return
	draw_colored_polygon(UITheme.rounded_rect_points(_size, RADIUS), UITheme.PANEL_BORDER)
	var inner_size: Vector2 = _size - Vector2(BORDER, BORDER) * 2.0
	draw_colored_polygon(UITheme.rounded_rect_points(inner_size, max(RADIUS - BORDER, 0.0)), UITheme.ROOM_COLOR)
	_draw_decor()

## Faint scattered flower/gear blobs purely for background texture - a
## deterministic pseudo-random scatter (seeded from the room size) so a
## given level always shows the same layout on reload.
func _draw_decor() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(_size.x) * 7919 + int(_size.y)
	var color: Color = UITheme.ROOM_COLOR.darkened(0.12)
	var margin := 70.0
	for i in DECOR_COUNT:
		var cx := rng.randf_range(-_size.x / 2.0 + margin, _size.x / 2.0 - margin)
		var cy := rng.randf_range(-_size.y / 2.0 + margin, _size.y / 2.0 - margin)
		_draw_flower(Vector2(cx, cy), rng.randf_range(9.0, 15.0), color)

func _draw_flower(center: Vector2, r: float, color: Color) -> void:
	var petal_r := r * 0.55
	for p in 6:
		var a := TAU * p / 6.0
		draw_circle(center + Vector2(cos(a), sin(a)) * r * 0.6, petal_r, color)
	draw_circle(center, petal_r * 0.9, color)
