extends Node2D
## GDD 3.5-3.8: gameplay HUD, on-screen controls, death flash, pause and
## level-complete overlays. Orchestrates LevelBuilder; holds no trap logic.

const LevelBuilder = preload("res://gameplay/LevelBuilder.gd")
const TouchControls = preload("res://common/TouchControls.gd")
const UITheme = preload("res://common/UITheme.gd")

var builder: LevelBuilder
var level_id: int
var hud: CanvasLayer
var death_flash: ColorRect
var pause_overlay: Control
var dots_row: HBoxContainer
var deaths_total: int = 0

func _ready() -> void:
	level_id = GameState.current_playing_level
	var data: Dictionary = LevelCatalog.get_level_data(level_id)

	_build_backdrop()
	add_child(TouchControls.new())
	_build_hud()
	_build_death_flash()

	builder = LevelBuilder.new()
	add_child(builder)
	builder.player_died.connect(_on_player_died)
	builder.level_completed.connect(_on_level_completed)
	builder.trap_progress.connect(_on_trap_progress)
	builder.build(data)

func _build_backdrop() -> void:
	var layer := CanvasLayer.new()
	layer.layer = -10
	layer.add_child(UITheme.fullscreen_bg(UITheme.SKY_COLOR))
	add_child(layer)

## Level Devil-style top bar: small PAUSE/RESTART icon buttons in the
## top-left corner, a row of trap-progress dots centered at the top.
func _build_hud() -> void:
	hud = CanvasLayer.new()
	hud.layer = 15
	add_child(hud)

	var corner := HBoxContainer.new()
	corner.set_anchors_preset(Control.PRESET_TOP_LEFT)
	corner.position = Vector2(20, 14)
	corner.add_theme_constant_override("separation", 10)
	hud.add_child(corner)

	var pause_btn := UITheme.secondary_button("II")
	pause_btn.custom_minimum_size = Vector2(48, 48)
	pause_btn.pressed.connect(_open_pause)
	corner.add_child(pause_btn)

	var restart_btn := UITheme.secondary_button("R")
	restart_btn.custom_minimum_size = Vector2(48, 48)
	restart_btn.pressed.connect(_restart_now)
	corner.add_child(restart_btn)

	dots_row = HBoxContainer.new()
	dots_row.set_anchors_preset(Control.PRESET_CENTER_TOP)
	dots_row.position = Vector2(-60, 20)
	dots_row.add_theme_constant_override("separation", 8)
	hud.add_child(dots_row)

func _on_trap_progress(fired: int, total: int) -> void:
	for c in dots_row.get_children():
		c.queue_free()
	var count: int = max(total, 1)
	for i in count:
		var dot := PanelContainer.new()
		dot.custom_minimum_size = Vector2(18, 18)
		var filled: bool = i < fired
		var sb := StyleBoxFlat.new()
		sb.bg_color = UITheme.PROGRESS_DOT if filled else Color(0, 0, 0, 0)
		sb.border_color = UITheme.PROGRESS_DOT
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(3)
		dot.add_theme_stylebox_override("panel", sb)
		dots_row.add_child(dot)

func _restart_now() -> void:
	builder.restart_level()
	deaths_total = 0
	_on_trap_progress(0, builder.traps.size())

func _build_death_flash() -> void:
	var flash_layer := CanvasLayer.new()
	flash_layer.layer = 20
	death_flash = ColorRect.new()
	death_flash.color = Color(0, 0, 0, 0)
	death_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	death_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_layer.add_child(death_flash)
	add_child(flash_layer)

func _on_player_died(total: int) -> void:
	deaths_total = total
	if GameState.settings.get("vibration", true):
		Input.vibrate_handheld(60)
	var tw := create_tween()
	tw.tween_property(death_flash, "color", Color(0.7, 0, 0, 0.55), 0.1)
	tw.tween_property(death_flash, "color", Color(0, 0, 0, 0), 0.35)

func _open_pause() -> void:
	if pause_overlay:
		pause_overlay.visible = true
	else:
		pause_overlay = _make_pause_overlay()
		hud.add_child(pause_overlay)
	get_tree().paused = true

func _make_pause_overlay() -> Control:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.process_mode = Node.PROCESS_MODE_ALWAYS

	var bg := UITheme.fullscreen_bg(Color(0, 0, 0, 0.65))
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(bg)

	var panel := PanelContainer.new()
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	panel.add_theme_stylebox_override("panel", UITheme.panel_style())
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-160, -150)
	panel.custom_minimum_size = Vector2(320, 300)
	root.add_child(panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 14)
	panel.add_child(vb)

	vb.add_child(UITheme.title_label("PAUSE", 30))

	var resume := UITheme.primary_button("RESUME")
	resume.pressed.connect(func():
		get_tree().paused = false
		pause_overlay.visible = false
	)
	vb.add_child(resume)

	var restart := UITheme.secondary_button("RESTART")
	restart.pressed.connect(func():
		get_tree().paused = false
		pause_overlay.visible = false
		_restart_now()
	)
	vb.add_child(restart)

	var settings_btn := UITheme.secondary_button("SETTINGS")
	settings_btn.pressed.connect(func():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/Settings.tscn")
	)
	vb.add_child(settings_btn)

	var exit_btn := UITheme.secondary_button("EXIT TO LEVELS")
	exit_btn.pressed.connect(func():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn")
	)
	vb.add_child(exit_btn)

	return root

func _on_level_completed(deaths: int, time_sec: float) -> void:
	GameState.complete_level(level_id, deaths, time_sec)
	_show_complete_overlay(deaths, time_sec)

func _show_complete_overlay(deaths: int, time_sec: float) -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(UITheme.fullscreen_bg(Color(0, 0, 0, 0.75)))

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UITheme.panel_style())
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-180, -160)
	panel.custom_minimum_size = Vector2(360, 320)
	root.add_child(panel)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	panel.add_child(vb)

	vb.add_child(UITheme.title_label("LEVEL COMPLETE", 24))
	vb.add_child(UITheme.body_label("Deaths: %d" % deaths, 20))
	vb.add_child(UITheme.body_label("Time: %.1fs" % time_sec, 20))

	var has_next: bool = LevelCatalog.get_level_meta(level_id + 1).size() > 0
	var next_btn := UITheme.primary_button("NEXT LEVEL" if has_next else "ALL LEVELS DONE")
	next_btn.disabled = not has_next
	next_btn.pressed.connect(func():
		GameState.current_playing_level = level_id + 1
		get_tree().change_scene_to_file("res://scenes/Gameplay.tscn")
	)
	vb.add_child(next_btn)

	var replay_btn := UITheme.secondary_button("REPLAY")
	replay_btn.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/Gameplay.tscn")
	)
	vb.add_child(replay_btn)

	var levels_btn := UITheme.secondary_button("LEVEL SELECT")
	levels_btn.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn")
	)
	vb.add_child(levels_btn)

	hud.add_child(root)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_action"):
		_open_pause()
