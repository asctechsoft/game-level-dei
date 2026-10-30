extends Camera2D
class_name CameraRig
## Static per-level "room" camera, Level Devil style: no scrolling, no
## follow. Each level's whole play area is framed and centered once at
## level start via fit_to(), computed from that level's own content bounds
## so every level can be a different size and still read as one neat boxed
## room.

const MIN_ZOOM := 0.4
const MAX_ZOOM := 1.5
## Zooms out a bit further than an exact fit so the player, ground and door
## read at a smaller, less "zoomed-in" scale on screen (per user feedback
## that the character/platform/goal looked oversized at a tight fit).
const ZOOM_OUT_FACTOR := 0.72

func fit_to(bounds: Rect2, viewport_size: Vector2) -> void:
	position_smoothing_enabled = false
	var zoom_x: float = viewport_size.x / bounds.size.x
	var zoom_y: float = viewport_size.y / bounds.size.y
	var z: float = clamp(min(zoom_x, zoom_y) * ZOOM_OUT_FACTOR, MIN_ZOOM, MAX_ZOOM)
	zoom = Vector2(z, z)
	global_position = bounds.get_center()
