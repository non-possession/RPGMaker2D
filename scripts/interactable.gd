extends Area2D

signal player_entered(interactable: Area2D)
signal player_exited(interactable: Area2D)

var data: Dictionary = {}
var base_color := Color(0.9, 0.82, 0.38, 0.35)
var locked_color := Color(0.45, 0.48, 0.5, 0.18)
var rect_size := Vector2(40, 28)
var game_state: Node
var debug_visible := false
var focus_visible := false
var pulse_time := 0.0

func setup(next_data: Dictionary, next_game_state: Node, size := Vector2(40, 28)) -> void:
	data = next_data
	game_state = next_game_state
	rect_size = size
	name = str(data.get("id", "Interactable"))
	collision_layer = 0
	collision_mask = 2
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = rect_size
	shape.shape = rectangle
	add_child(shape)
	queue_redraw()

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	pulse_time += delta
	if _should_draw_hint():
		queue_redraw()

func _draw() -> void:
	var available: bool = game_state == null or game_state.can_interact(data)
	if debug_visible:
		var color := base_color if available else locked_color
		draw_rect(Rect2(-rect_size * 0.5, rect_size), color, true)
		draw_rect(Rect2(-rect_size * 0.5, rect_size), Color(0.95, 0.9, 0.65, 0.45), false, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(-rect_size.x * 0.45, 4), str(data.get("id", "?")), HORIZONTAL_ALIGNMENT_LEFT, rect_size.x, 12, Color(0.98, 0.94, 0.65, 0.9))
	if _should_draw_hint():
		_draw_hint_marker()

func set_debug_visible(next_visible: bool) -> void:
	debug_visible = next_visible
	queue_redraw()

func set_focus_visible(next_visible: bool) -> void:
	if focus_visible == next_visible:
		return
	focus_visible = next_visible
	queue_redraw()

func _should_draw_hint() -> bool:
	if game_state == null:
		return false
	if game_state.is_completed(str(data.get("id", ""))):
		return false
	return game_state.can_interact(data)

func _draw_hint_marker() -> void:
	var alpha := 0.45 + sin(pulse_time * 3.0) * 0.12
	var radius := 6.0 if focus_visible else 4.0
	var marker_y := -rect_size.y * 0.5 - 8.0
	var color := Color(1.0, 0.82, 0.42, alpha + (0.22 if focus_visible else 0.0))
	draw_circle(Vector2(0, marker_y), radius, color)
	draw_arc(Vector2(0, marker_y), radius + 3.0, 0.0, TAU, 24, Color(1.0, 0.86, 0.54, 0.28 if focus_visible else 0.16), 1.0)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_entered.emit(self)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_exited.emit(self)
