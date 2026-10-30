extends RefCounted
class_name UITheme
## Warm orange/brown "Level Devil"-style palette (per user reference
## screenshot), replacing the earlier dark hell/lava mockup theme. Swap
## StyleBox colors here once final pixel-art assets are dropped in;
## gameplay code never needs to change.

const BG_DARK := Color(0.20, 0.13, 0.07)
const BG_PANEL := Color(0.16, 0.10, 0.06, 0.92)
const ACCENT_YELLOW := Color(1.0, 0.79, 0.24)
const ACCENT_RED := Color(0.85, 0.2, 0.15)
const PANEL_BORDER := Color(0.55, 0.35, 0.15)
const TEXT_WHITE := Color(0.96, 0.95, 0.93)
const TEXT_MUTED := Color(0.70, 0.60, 0.48)
const GROUND_COLOR := Color(0.42, 0.29, 0.13)
const SKY_COLOR := Color(0.42, 0.29, 0.13)
const ROOM_COLOR := Color(0.86, 0.64, 0.36)
const DOOR_COLOR := Color(0.80, 0.80, 0.77)
const PROGRESS_DOT := Color(0.16, 0.10, 0.06)
const LAVA_COLOR := Color(0.85, 0.28, 0.05)
const TRAP_COLOR := Color(0.9, 0.85, 0.85)
const PLAYER_COLOR := Color(0.95, 0.95, 0.95)

## Centered rounded-rect outline (world or UI space, CCW/CW agnostic) used by
## RoomBackdrop and LevelDoor so both share one rounding style.
static func rounded_rect_points(size: Vector2, radius: float, segments: int = 6) -> PackedVector2Array:
	var r: float = clamp(radius, 0.0, min(size.x, size.y) / 2.0)
	var hw := size.x / 2.0
	var hh := size.y / 2.0
	var corners := [
		Vector2(hw - r, -hh + r),
		Vector2(hw - r, hh - r),
		Vector2(-hw + r, hh - r),
		Vector2(-hw + r, -hh + r),
	]
	var start_angles := [-PI / 2.0, 0.0, PI / 2.0, PI]
	var pts := PackedVector2Array()
	for c in 4:
		var center: Vector2 = corners[c]
		var start_angle: float = start_angles[c]
		for s in segments + 1:
			var a: float = start_angle + (PI / 2.0) * (float(s) / segments)
			pts.append(center + Vector2(cos(a), sin(a)) * r)
	return pts

static func panel_style(bg: Color = BG_PANEL, border: Color = PANEL_BORDER) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(10)
	sb.set_border_width_all(2)
	sb.border_color = border
	sb.set_content_margin_all(16)
	return sb

static func button_style(bg: Color, hover: bool = false) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg.lightened(0.12) if hover else bg
	sb.set_corner_radius_all(8)
	sb.set_content_margin_all(14)
	return sb

static func primary_button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_color_override("font_color", Color(0.15, 0.08, 0.02))
	b.add_theme_color_override("font_hover_color", Color(0.15, 0.08, 0.02))
	b.add_theme_font_size_override("font_size", 30)
	b.add_theme_stylebox_override("normal", button_style(ACCENT_YELLOW))
	b.add_theme_stylebox_override("hover", button_style(ACCENT_YELLOW, true))
	b.add_theme_stylebox_override("pressed", button_style(ACCENT_YELLOW.darkened(0.1)))
	b.add_theme_stylebox_override("disabled", button_style(Color(0.3, 0.3, 0.3)))
	b.custom_minimum_size = Vector2(0, 64)
	return b

static func secondary_button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_color_override("font_color", TEXT_WHITE)
	b.add_theme_font_size_override("font_size", 22)
	b.add_theme_stylebox_override("normal", button_style(Color(0.2, 0.11, 0.11)))
	b.add_theme_stylebox_override("hover", button_style(Color(0.28, 0.15, 0.15)))
	b.add_theme_stylebox_override("pressed", button_style(Color(0.16, 0.08, 0.08)))
	b.custom_minimum_size = Vector2(0, 52)
	return b

static func title_label(text: String, size: int = 48) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override("font_color", ACCENT_YELLOW)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_constant_override("outline_size", 6)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

static func body_label(text: String, size: int = 20, color: Color = TEXT_WHITE) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_size_override("font_size", size)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

static func fullscreen_bg(color: Color = BG_DARK) -> ColorRect:
	var r := ColorRect.new()
	r.color = color
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r
