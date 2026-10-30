extends CanvasLayer
## GDD 3.2: 3 short pages (Move / Jump / warning), Skip always available,
## shown once. Marks GameState.onboarding_done so Splash never routes here
## again.

const UITheme = preload("res://common/UITheme.gd")

var pages := [
	{"title": "MOVE", "body": "Dung < > hoac ban phim de di chuyen."},
	{"title": "JUMP", "body": "Cham JUMP hoac phim Space de nhay."},
	{"title": "COI CHUNG", "body": "Dung tin moi thu ban thay."},
]
var index := 0
var title_label: Label
var body_label: Label
var next_btn: Button

func _ready() -> void:
	add_child(UITheme.fullscreen_bg())

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var skip_btn := UITheme.secondary_button("SKIP")
	skip_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	skip_btn.position = Vector2(-140, 20)
	skip_btn.pressed.connect(_finish)
	root.add_child(skip_btn)

	var center := VBoxContainer.new()
	center.set_anchors_preset(Control.PRESET_CENTER)
	center.position = Vector2(-220, -120)
	center.custom_minimum_size = Vector2(440, 240)
	center.add_theme_constant_override("separation", 20)
	root.add_child(center)

	title_label = UITheme.title_label("", 34)
	center.add_child(title_label)

	body_label = UITheme.body_label("", 20)
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	center.add_child(body_label)

	next_btn = UITheme.primary_button("NEXT")
	next_btn.pressed.connect(_advance)
	center.add_child(next_btn)

	_refresh()

func _refresh() -> void:
	var p: Dictionary = pages[index]
	title_label.text = p["title"]
	body_label.text = p["body"]
	next_btn.text = "START" if index == pages.size() - 1 else "NEXT"

func _advance() -> void:
	if index >= pages.size() - 1:
		_finish()
		return
	index += 1
	_refresh()

func _finish() -> void:
	GameState.mark_first_launch_seen()
	get_tree().change_scene_to_file("res://scenes/Home.tscn")
