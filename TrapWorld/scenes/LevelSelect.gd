extends CanvasLayer
## GDD 3.4: grid by chapter. Completed levels open, current level highlighted,
## future levels locked/disabled.

const UITheme = preload("res://common/UITheme.gd")

func _ready() -> void:
	add_child(UITheme.fullscreen_bg())

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_bottom", 26)
	root.add_child(margin)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 16)
	margin.add_child(vb)

	var header := HBoxContainer.new()
	vb.add_child(header)
	header.add_child(UITheme.title_label("CHAPTER 1 - TUTORIAL HELL", 24))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	var back_btn := UITheme.secondary_button("BACK")
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Home.tscn"))
	header.add_child(back_btn)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb.add_child(scroll)

	var grid := GridContainer.new()
	grid.columns = 8
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(grid)

	var continue_level := GameState.get_continue_level()
	for meta in LevelCatalog.get_level_list():
		grid.add_child(_make_level_button(meta, continue_level))

func _make_level_button(meta: Dictionary, continue_level: int) -> Button:
	var id: int = int(meta.get("id", 0))
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(84, 84)
	btn.add_theme_font_size_override("font_size", 22)

	var unlocked := GameState.is_level_unlocked(id)
	var completed := GameState.is_level_completed(id)
	btn.text = str(id) + ("\n[x]" if completed else "")

	var base_color: Color
	var font_color := UITheme.TEXT_WHITE
	if id == continue_level and unlocked:
		base_color = UITheme.ACCENT_YELLOW
		font_color = Color(0.15, 0.08, 0.02)
	elif completed:
		base_color = Color(0.35, 0.16, 0.12)
	else:
		base_color = Color(0.2, 0.13, 0.13)

	btn.add_theme_stylebox_override("normal", UITheme.button_style(base_color))
	btn.add_theme_stylebox_override("hover", UITheme.button_style(base_color, true))
	btn.add_theme_stylebox_override("disabled", UITheme.button_style(Color(0.14, 0.11, 0.11)))
	btn.add_theme_color_override("font_color", font_color)
	btn.add_theme_color_override("font_disabled_color", UITheme.TEXT_MUTED)
	btn.disabled = not unlocked
	btn.focus_mode = Control.FOCUS_NONE

	if unlocked:
		btn.pressed.connect(func():
			GameState.current_playing_level = id
			get_tree().change_scene_to_file("res://scenes/Gameplay.tscn")
		)
	return btn
