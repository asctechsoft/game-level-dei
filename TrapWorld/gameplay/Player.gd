extends CharacterBody2D
class_name Player
## Movement/Jump/Gravity/Collision all run client-side per GDD section 7
## ("Không gửi Jump/Movement/Collision lên server"). Reads the unified
## InputMap actions so keyboard (desktop) and on-screen buttons (Android)
## behave identically.

const Layers = preload("res://common/Layers.gd")
const CHAR_TEXTURE = preload("res://assets/img_nhan_vat.png")

signal died

const SPEED := 260.0
const JUMP_VELOCITY := -560.0
const GRAVITY := 1500.0
const MAX_FALL_SPEED := 1100.0

const STEP_INTERVAL := 0.26

var is_dead := false
var facing_dir := 1
var reversed_controls := false
var _step_timer := 0.0

var visual: Node2D

func _ready() -> void:
	add_to_group("player")
	collision_layer = Layers.PLAYER
	collision_mask = Layers.GROUND
	_build_visual()

## Player sprite is the user's own character art (assets/img_nhan_vat.png),
## scaled to a fixed on-screen height and foot-anchored to the collider's
## bottom so it stands on the ground the same way the old placeholder did.
func _build_visual() -> void:
	var shape := CapsuleShape2D.new()
	shape.radius = 14
	shape.height = 44
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)

	var body := Node2D.new()
	body.name = "Visual"
	add_child(body)
	visual = body

	var sprite := Sprite2D.new()
	sprite.texture = CHAR_TEXTURE
	const TARGET_HEIGHT := 74.0
	var tex_size: Vector2 = CHAR_TEXTURE.get_size()
	var s: float = TARGET_HEIGHT / tex_size.y
	sprite.scale = Vector2(s, s)
	sprite.position = Vector2(0, 22.0 - TARGET_HEIGHT / 2.0)
	body.add_child(sprite)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	var dir := Input.get_axis("move_left", "move_right")
	if reversed_controls:
		dir = -dir
	velocity.x = dir * SPEED
	if dir != 0:
		facing_dir = 1 if dir > 0 else -1
		visual.scale.x = facing_dir

	if not is_on_floor():
		velocity.y = min(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)
	elif Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		Sfx.play_jump()

	if is_on_floor() and dir != 0:
		_step_timer -= delta
		if _step_timer <= 0.0:
			_step_timer = STEP_INTERVAL
			Sfx.play_step()
	else:
		_step_timer = 0.0

	move_and_slide()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	set_physics_process(false)
	Sfx.play_death()
	died.emit()

func reset_at(spawn_pos: Vector2) -> void:
	is_dead = false
	reversed_controls = false
	velocity = Vector2.ZERO
	global_position = spawn_pos
	set_physics_process(true)
	visible = true

## Once triggered, controls stay reversed for the rest of this level attempt
## (per user feedback: reverting after a few seconds felt like it was
## randomly flip-flopping between normal and reversed) - it only clears on
## death/restart via reset_at().
func apply_reverse(_duration: float = 0.0) -> void:
	reversed_controls = true
