extends CharacterBody2D

const PLAYER_SHEET_PATH := "res://assets/sprites/characters/ch01_surveyor_player_sheet.png"
const TARGET_VISUAL_HEIGHT := 56.0
const GENERATED_VISIBLE_HEIGHT := 54.0
const GENERATED_VISIBLE_BOTTOM_Y := 59.0
const GENERATED_VISIBLE_CENTER_X := 24.0

@export var speed := 110.0
@export var generated_sprite_hframes := 3
@export var generated_sprite_vframes := 4

var input_locked := false
var walk_time := 0.0
var visual_height_px := TARGET_VISUAL_HEIGHT
var generated_sprite: Sprite2D
var using_generated_sprite := false
var last_direction := Vector2.DOWN

func _ready() -> void:
	add_to_group("player")
	_try_use_generated_sprite()

func _physics_process(_delta: float) -> void:
	if input_locked:
		velocity = Vector2.ZERO
		move_and_slide()
		_update_visuals(_delta, Vector2.ZERO)
		return
	var direction := _movement_vector()
	velocity = direction * speed
	move_and_slide()
	_update_visuals(_delta, direction)

func set_input_locked(locked: bool) -> void:
	input_locked = locked

func _movement_vector() -> Vector2:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	direction.x += int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A))
	direction.y += int(Input.is_key_pressed(KEY_S)) - int(Input.is_key_pressed(KEY_W))
	return direction.normalized() if direction.length() > 1.0 else direction

func _update_visuals(delta: float, direction: Vector2) -> void:
	var moving := direction.length() > 0.05
	if moving:
		walk_time += delta * 9.0
		last_direction = direction
	else:
		walk_time = lerpf(walk_time, 0.0, min(delta * 12.0, 1.0))
	if using_generated_sprite:
		_update_generated_sprite(moving)
		return
	var bob := sin(walk_time) * 1.2 if moving else 0.0
	_set_node_y("Body", bob)
	_set_node_y("Head", bob)
	_set_node_y("Hair", bob)
	_set_node_y("Bag", bob)
	_set_node_y("LeftFoot", -bob)
	_set_node_y("RightFoot", bob)
	if moving:
		scale.x = -1.0 if direction.x < -0.1 else 1.0

func _try_use_generated_sprite() -> void:
	if not ResourceLoader.exists(PLAYER_SHEET_PATH) and not FileAccess.file_exists(PLAYER_SHEET_PATH):
		return
	var texture: Texture2D = load(PLAYER_SHEET_PATH)
	if texture == null:
		return
	using_generated_sprite = true
	generated_sprite = Sprite2D.new()
	generated_sprite.name = "GeneratedPlayerSprite"
	generated_sprite.texture = texture
	generated_sprite.hframes = generated_sprite_hframes
	generated_sprite.vframes = generated_sprite_vframes
	var frame_size := Vector2(
		float(texture.get_width()) / float(generated_sprite_hframes),
		float(texture.get_height()) / float(generated_sprite_vframes)
	)
	var visual_scale := TARGET_VISUAL_HEIGHT / GENERATED_VISIBLE_HEIGHT
	generated_sprite.centered = false
	generated_sprite.scale = Vector2(visual_scale, visual_scale)
	generated_sprite.position = Vector2(-GENERATED_VISIBLE_CENTER_X * visual_scale, -GENERATED_VISIBLE_BOTTOM_Y * visual_scale)
	add_child(generated_sprite)
	move_child(generated_sprite, 1)
	for node_name in ["Body", "Head", "Hair", "Bag", "LeftFoot", "RightFoot"]:
		var node := get_node_or_null(node_name)
		if node != null:
			node.visible = false
	_update_generated_sprite(false)

func _update_generated_sprite(moving: bool) -> void:
	if generated_sprite == null:
		return
	scale.x = 1.0
	var row := _sprite_row_for_direction(last_direction)
	var frame_col := 0
	if moving:
		frame_col = 1 + (int(floor(walk_time * 1.8)) % 2)
	generated_sprite.frame = row * generated_sprite_hframes + frame_col

func _sprite_row_for_direction(direction: Vector2) -> int:
	if abs(direction.x) > abs(direction.y):
		return 2 if direction.x > 0.0 else 1
	return 3 if direction.y < 0.0 else 0

func _set_node_y(node_name: String, y: float) -> void:
	var node := get_node_or_null(node_name)
	if node != null:
		node.position.y = y
