extends Node2D
class_name LevelBuilder
## Data-driven level engine (GDD sections 9/23): takes a level JSON dict and
## instances platforms, traps and the door. Godot only executes what the JSON
## describes; adding new levels never needs new gameplay code.

const Layers = preload("res://common/Layers.gd")
const UITheme = preload("res://common/UITheme.gd")
const RoomBackdrop = preload("res://gameplay/RoomBackdrop.gd")
const HiddenSpike = preload("res://gameplay/traps/HiddenSpike.gd")
const FallingFloor = preload("res://gameplay/traps/FallingFloor.gd")
const FakeFloor = preload("res://gameplay/traps/FakeFloor.gd")
const FallingBlock = preload("res://gameplay/traps/FallingBlock.gd")
const MovingWall = preload("res://gameplay/traps/MovingWall.gd")
const FakeDoorTrap = preload("res://gameplay/traps/FakeDoorTrap.gd")
const ReverseControlTrap = preload("res://gameplay/traps/ReverseControlTrap.gd")

signal player_died(total_deaths: int)
signal level_completed(deaths: int, time_sec: float)
signal trap_progress(fired: int, total: int)

var player: Player
var door: LevelDoor
var camera: CameraRig
var traps: Array = []
var completed_ids: Dictionary = {}
var spawn_pos: Vector2 = Vector2(100, 480)
var door_original_pos: Vector2 = Vector2.ZERO
var deaths: int = 0
var elapsed: float = 0.0
var level_finished := false
var _timing := false

func build(level_data: Dictionary) -> void:
	var spawn_arr: Array = level_data.get("spawn", [100, 480])
	spawn_pos = Vector2(float(spawn_arr[0]), float(spawn_arr[1]))

	var level_width: float = float(level_data.get("level_width", 1400))
	var bounds: Rect2 = _compute_room_bounds(level_data, level_width)

	var backdrop := RoomBackdrop.new()
	add_child(backdrop)
	backdrop.set_bounds(bounds)

	_build_ground(level_data.get("platforms", []))
	door = _build_door(level_data.get("door", {"x": 900, "y": 560}))
	_build_traps(level_data.get("traps", []))
	_build_pit(level_width)

	player = Player.new()
	add_child(player)
	player.global_position = spawn_pos
	player.died.connect(_on_player_died)

	for t in traps:
		if "player_ref" in t:
			t.player_ref = player
		if "door" in t:
			t.door = door

	camera = CameraRig.new()
	add_child(camera)
	camera.fit_to(bounds, get_viewport_rect().size)
	camera.make_current()

	door_original_pos = door.position
	_timing = true
	trap_progress.emit(0, traps.size())

## Frames the whole level as one static "room" (Level Devil style, no
## scrolling), with equal left/right margin and equal top/bottom margin.
## The vertical box is built symmetrically around the ground band itself
## (same headroom above and below) so the extra slack CameraRig.fit_to()
## adds to reach the viewport's aspect ratio stays centered on the ground,
## instead of piling up on one side.
func _compute_room_bounds(level_data: Dictionary, level_width: float) -> Rect2:
	var min_x: float = 0.0
	var max_x: float = 0.0
	var ground_top: float = 560.0
	var ground_bottom: float = 620.0
	var has_platform := false

	for p in level_data.get("platforms", []):
		var px: float = float(p.get("x", 0))
		var py: float = float(p.get("y", 560))
		min_x = min(min_x, px)
		max_x = max(max_x, px + float(p.get("w", 200)))
		ground_top = min(ground_top, py)
		ground_bottom = max(ground_bottom, py + float(p.get("h", 60)))
		has_platform = true

	if not has_platform:
		max_x = level_width

	var d: Dictionary = level_data.get("door", {"x": 900, "y": 560})
	max_x = max(max_x, float(d.get("x", 900)) + 80.0)

	var h_margin := 60.0
	var v_headroom := 260.0  # room for the tallest trap (moving_wall) plus a jump, same on both sides
	min_x -= h_margin
	max_x += h_margin
	var min_y: float = ground_top - v_headroom
	var max_y: float = ground_bottom + v_headroom
	return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)

func _build_ground(platforms: Array) -> void:
	for p in platforms:
		var w: float = float(p.get("w", 200))
		var h: float = float(p.get("h", 60))
		var body := StaticBody2D.new()
		body.collision_layer = Layers.GROUND
		var shape := RectangleShape2D.new()
		shape.size = Vector2(w, h)
		var col := CollisionShape2D.new()
		col.shape = shape
		col.position = Vector2(w / 2.0, h / 2.0)
		body.add_child(col)
		var visual := ColorRect.new()
		visual.color = UITheme.GROUND_COLOR
		visual.size = Vector2(w, h)
		body.add_child(visual)
		body.position = Vector2(float(p.get("x", 0)), float(p.get("y", 560)))
		add_child(body)

func _build_door(d: Dictionary) -> LevelDoor:
	var door_node := LevelDoor.new()
	door_node.position = Vector2(float(d.get("x", 900)), float(d.get("y", 560)))
	add_child(door_node)
	door_node.reached.connect(_on_door_reached)
	return door_node

func _build_pit(level_width: float) -> void:
	var pit := Area2D.new()
	pit.collision_layer = 0
	pit.collision_mask = Layers.PLAYER
	var shape := RectangleShape2D.new()
	shape.size = Vector2(level_width + 600, 100)
	var col := CollisionShape2D.new()
	col.shape = shape
	pit.add_child(col)
	pit.position = Vector2(level_width / 2.0, 900)
	pit.body_entered.connect(func(b):
		if b.is_in_group("player"):
			b.die()
	)
	add_child(pit)

func _build_traps(defs: Array) -> void:
	for def in defs:
		var trap: TrapBase
		match String(def.get("type", "")):
			"hidden_spike":
				trap = HiddenSpike.new()
			"falling_floor":
				trap = FallingFloor.new()
			"fake_floor":
				trap = FakeFloor.new()
			"falling_block":
				trap = FallingBlock.new()
			"moving_wall":
				trap = MovingWall.new()
			"fake_door":
				trap = FakeDoorTrap.new()
			"reverse_control":
				trap = ReverseControlTrap.new()
			_:
				continue
		trap.setup(def)
		trap.position = Vector2(float(def.get("x", 0)), float(def.get("y", 560)))
		add_child(trap)
		trap.triggered.connect(_on_trap_triggered)
		traps.append(trap)

func _on_trap_triggered(id: String) -> void:
	completed_ids[id] = true
	trap_progress.emit(completed_ids.size(), traps.size())

func _process(delta: float) -> void:
	if level_finished or player == null:
		return
	if _timing:
		elapsed += delta
	for t in traps:
		if t.poll_trigger(player, completed_ids):
			t.fire()

func _on_player_died() -> void:
	deaths += 1
	player_died.emit(deaths)
	await get_tree().create_timer(0.4).timeout
	_reset_level_state()

func _reset_level_state() -> void:
	for t in traps:
		t.reset()
	completed_ids.clear()
	trap_progress.emit(0, traps.size())
	if door:
		door.position = door_original_pos
	if player:
		player.reset_at(spawn_pos)

func _on_door_reached() -> void:
	if level_finished:
		return
	level_finished = true
	_timing = false
	player.set_physics_process(false)
	Sfx.play_complete()
	level_completed.emit(deaths, elapsed)

func restart_level() -> void:
	deaths = 0
	elapsed = 0.0
	level_finished = false
	_timing = true
	_reset_level_state()
