extends CanvasLayer
## GDD 3.9: Music, SFX, Vibration. Language deferred ("về sau").

const UITheme = preload("res://common/UITheme.gd")

func _ready() -> void:
	add_child(UITheme.fullscreen_bg())

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_CENTER)
	root.position = Vector2(-210, -190)
	root.custom_minimum_size = Vector2(420, 380)
	add_child(root)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UITheme.panel_style())
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 16)
	panel.add_child(vb)

	vb.add_child(UITheme.title_label("SETTINGS", 30))
	vb.add_child(_slider_row("MUSIC", "music", "Master"))
	vb.add_child(_slider_row("SFX", "sfx", "SFX"))

	var vib_row := HBoxContainer.new()
	vib_row.add_theme_constant_override("separation", 12)
	var vib_lbl := UITheme.body_label("VIBRATION", 18)
	vib_lbl.custom_minimum_size = Vector2(140, 0)
	vib_row.add_child(vib_lbl)
	var vib_check := CheckBox.new()
	vib_check.button_pressed = GameState.settings.get("vibration", true)
	vib_check.toggled.connect(func(v):
		GameState.settings["vibration"] = v
		GameState.save_state()
	)
	vib_row.add_child(vib_check)
	vb.add_child(vib_row)

	var back_btn := UITheme.primary_button("BACK")
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/Home.tscn"))
	vb.add_child(back_btn)

func _slider_row(label_text: String, key: String, bus_name: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var lbl := UITheme.body_label(label_text, 18)
	lbl.custom_minimum_size = Vector2(90, 0)
	row.add_child(lbl)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = GameState.settings.get(key, 0.8)
	slider.custom_minimum_size = Vector2(220, 0)
	slider.value_changed.connect(func(v):
		GameState.settings[key] = v
		var idx := AudioServer.get_bus_index(bus_name)
		if idx != -1:
			AudioServer.set_bus_volume_db(idx, linear_to_db(max(v, 0.0001)))
		GameState.save_state()
	)
	row.add_child(slider)
	return row
