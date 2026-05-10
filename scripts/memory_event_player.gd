extends Control

signal memory_event_finished(event_id: String)

var survey_progress: Control
var player: Node
var is_playing := false
var active_tweens: Array[Tween] = []

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

func setup(deps: Dictionary) -> void:
	survey_progress = deps.get("survey_progress", null)
	player = deps.get("player", null)

func play_event(event_id: String, event_data: Dictionary, options := {}) -> void:
	if is_playing:
		return
	is_playing = true
	visible = true
	_clear()
	var manage_input: bool = bool(options.get("manage_input", true))
	if manage_input and player != null and player.has_method("set_input_locked"):
		player.call("set_input_locked", true)
	if survey_progress != null and survey_progress.has_method("set_cinematic_focus"):
		survey_progress.call("set_cinematic_focus", true)
	for block in event_data.get("blocks", []):
		_spawn_block(block)
	for text_data in event_data.get("texts", []):
		_spawn_text(text_data)
	await get_tree().create_timer(float(event_data.get("duration", 0.9))).timeout
	await _fade_out()
	if survey_progress != null and survey_progress.has_method("set_cinematic_focus"):
		survey_progress.call("set_cinematic_focus", false)
	if manage_input and player != null and player.has_method("set_input_locked"):
		player.call("set_input_locked", false)
	_clear()
	visible = false
	is_playing = false
	memory_event_finished.emit(event_id)

func _spawn_text(data: Dictionary) -> void:
	var label := Label.new()
	label.name = "MemoryText"
	label.text = str(data.get("text", ""))
	label.position = data.get("position", Vector2.ZERO)
	label.size = data.get("size", Vector2(180, 24))
	label.modulate = Color(0.92, 0.84, 0.64, 0.0)
	label.add_theme_font_size_override("font_size", int(data.get("font_size", 14)))
	label.add_theme_color_override("font_color", Color(0.92, 0.84, 0.64, 0.82))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.clip_text = true
	add_child(label)
	_fade_fragment(label, float(data.get("delay", 0.0)), float(data.get("hold", 0.52)), 0.82)

func _spawn_block(data: Dictionary) -> void:
	var block := ColorRect.new()
	block.name = str(data.get("name", "MemoryBlock"))
	block.position = data.get("position", Vector2.ZERO)
	block.size = data.get("size", Vector2(80, 40))
	var color: Color = data.get("color", Color(0.8, 0.6, 0.3, 0.16))
	block.color = Color(color.r, color.g, color.b, 0.0)
	add_child(block)
	_fade_color_rect(block, color.a, float(data.get("delay", 0.0)), float(data.get("hold", 0.5)))

func _fade_fragment(node: CanvasItem, delay: float, hold: float, alpha: float) -> void:
	var tween := create_tween()
	active_tweens.append(tween)
	tween.tween_interval(delay)
	tween.tween_property(node, "modulate:a", alpha, 0.18)
	tween.tween_interval(hold)
	tween.tween_property(node, "modulate:a", 0.0, 0.34)

func _fade_color_rect(rect: ColorRect, alpha: float, delay: float, hold: float) -> void:
	var tween := create_tween()
	active_tweens.append(tween)
	tween.tween_interval(delay)
	tween.tween_property(rect, "color:a", alpha, 0.18)
	tween.tween_interval(hold)
	tween.tween_property(rect, "color:a", 0.0, 0.34)

func _fade_out() -> void:
	var tween := create_tween()
	active_tweens.append(tween)
	for child in get_children():
		if child is CanvasItem:
			tween.parallel().tween_property(child, "modulate:a", 0.0, 0.18)
	await tween.finished

func _clear() -> void:
	for tween in active_tweens:
		if tween != null:
			tween.kill()
	active_tweens.clear()
	for child in get_children():
		child.queue_free()
