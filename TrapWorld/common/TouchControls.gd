extends CanvasLayer
class_name TouchControls
## On-screen HUD controls per GDD 3.5: ◀ ▶ on the left, JUMP on the right.
## Drives the same InputMap actions as keyboard (see InputSetup) so Player.gd
## never needs to know whether input came from touch or keys.
##
## Each control is drawn as a small styled button, but the actual tap target
## is a much bigger invisible Button sitting behind it (fingers are wider
## than a 112px box) - per user feedback that the touch points felt too
## small on a real phone. The visible buttons stay exactly where they were.

const UITheme = preload("res://common/UITheme.gd")

func _ready() -> void:
	layer = 10

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 28)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_child(root)

	var ARROW_SIZE := 112
	var ZONE_H := 240

	var left_zone := _make_zone(Vector2(150, ZONE_H))
	left_zone.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	left_zone.position = Vector2(-19, -10 - ZONE_H)
	root.add_child(left_zone)

	var left_btn := _make_btn("<", ARROW_SIZE)
	left_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left_btn.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	left_btn.position = Vector2(0, -(ARROW_SIZE + 10))
	root.add_child(left_btn)

	var right_zone := _make_zone(Vector2(150, ZONE_H))
	right_zone.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	right_zone.position = Vector2(107, -10 - ZONE_H)
	root.add_child(right_zone)

	var right_btn := _make_btn(">", ARROW_SIZE)
	right_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right_btn.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	right_btn.position = Vector2(ARROW_SIZE + 14, -(ARROW_SIZE + 10))
	root.add_child(right_btn)

	var jump_zone := _make_zone(Vector2(240, ZONE_H + 30))
	jump_zone.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	jump_zone.position = Vector2(-240, -260)
	root.add_child(jump_zone)

	var jump_btn := _make_btn("JUMP", 120)
	jump_btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	jump_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	jump_btn.position = Vector2(-120, -110)
	root.add_child(jump_btn)

	_wire(left_zone, "move_left")
	_wire(right_zone, "move_right")
	_wire(jump_zone, "jump")

## Bigger invisible tap target: same Button/action-wiring machinery as the
## visible controls, just fully transparent so only its hit area shows up.
func _make_zone(size: Vector2) -> Button:
	var b := Button.new()
	b.custom_minimum_size = size
	b.flat = true
	b.focus_mode = Control.FOCUS_NONE
	b.self_modulate = Color(1, 1, 1, 0)
	return b

func _make_btn(text: String, size: int = 90) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(size, size)
	b.add_theme_font_size_override("font_size", 28)
	b.add_theme_stylebox_override("normal", UITheme.button_style(Color(0, 0, 0, 0.35)))
	b.add_theme_stylebox_override("hover", UITheme.button_style(Color(0, 0, 0, 0.45)))
	b.add_theme_stylebox_override("pressed", UITheme.button_style(UITheme.ACCENT_YELLOW.darkened(0.1)))
	b.add_theme_color_override("font_color", UITheme.TEXT_WHITE)
	b.add_theme_color_override("font_pressed_color", Color(0.15, 0.08, 0.02))
	b.focus_mode = Control.FOCUS_NONE
	return b

func _wire(btn: Button, action: String) -> void:
	btn.button_down.connect(func(): Input.action_press(action))
	btn.button_up.connect(func(): Input.action_release(action))
