extends CanvasLayer
## GDD 3.3: PLAY/CONTINUE as the main CTA, LEVELS + SETTINGS below,
## version/network badge in the corner.

const UITheme = preload("res://common/UITheme.gd")

func _ready() -> void:
	add_child(UITheme.fullscreen_bg())

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var version_label := UITheme.body_label("v0.1.0 MVP - OFFLINE", 14, UITheme.TEXT_MUTED)
	version_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	version_label.position = Vector2(16, 12)
	root.add_child(version_label)

	var center := VBoxContainer.new()
	center.set_anchors_preset(Control.PRESET_CENTER)
	center.position = Vector2(-160, -170)
	center.custom_minimum_size = Vector2(320, 340)
	center.add_theme_constant_override("separation", 18)
	root.add_child(center)

	center.add_child(UITheme.title_label("TRAP WORLD", 42))

	var play_label := "CONTINUE" if GameState.has_any_progress() else "PLAY"
	var play_btn := UITheme.primary_button(play_label)
	play_btn.pressed.connect(func():
		GameState.current_playing_level = GameState.get_continue_level()
		get_tree().change_scene_to_file("res://scenes/Gameplay.tscn")
	)
	center.add_child(play_btn)

	var levels_btn := UITheme.secondary_button("LEVELS")
	levels_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn"))
	center.add_child(levels_btn)

	var settings_btn := UITheme.secondary_button("SETTINGS")
	settings_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Settings.tscn"))
	center.add_child(settings_btn)
