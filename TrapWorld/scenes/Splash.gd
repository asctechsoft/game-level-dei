extends CanvasLayer
## GDD 2 step 01 / 3.1: brief splash, then route to Onboarding (first launch)
## or Home. GameState.load_state() already ran in its own _ready() before
## any scene exists, so onboarding_done is reliable here.

const UITheme = preload("res://common/UITheme.gd")

func _ready() -> void:
	add_child(UITheme.fullscreen_bg())

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var title := UITheme.title_label("TRAP WORLD", 50)
	title.set_anchors_preset(Control.PRESET_CENTER)
	title.position = Vector2(-220, -50)
	title.custom_minimum_size = Vector2(440, 80)
	root.add_child(title)

	var sub := UITheme.body_label("Dung tin moi thu ban thay...", 18, UITheme.TEXT_MUTED)
	sub.set_anchors_preset(Control.PRESET_CENTER)
	sub.position = Vector2(-220, 30)
	sub.custom_minimum_size = Vector2(440, 40)
	root.add_child(sub)

	await get_tree().create_timer(1.1).timeout
	_route()

func _route() -> void:
	if GameState.onboarding_done:
		get_tree().change_scene_to_file("res://scenes/Home.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/Onboarding.tscn")
