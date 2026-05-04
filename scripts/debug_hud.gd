extends Control

var game_state: Node
var controller: Node
var panel: Panel
var label: Label
var enabled := false

func _ready() -> void:
	panel = Panel.new()
	panel.position = Vector2(700, 12)
	panel.size = Vector2(248, 308)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.02, 0.025, 0.025, 0.78)
	panel_style.border_color = Color(0.42, 0.55, 0.55, 0.48)
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)
	label = Label.new()
	label.position = Vector2(10, 8)
	label.size = Vector2(228, 290)
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color(0.78, 0.9, 0.88))
	label.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	panel.add_child(label)

func setup(next_game_state: Node, next_controller: Node) -> void:
	game_state = next_game_state
	controller = next_controller
	visible = enabled
	_refresh()

func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_F3):
		if not has_meta("f3_down"):
			set_meta("f3_down", true)
			enabled = not enabled
			visible = enabled
	elif has_meta("f3_down"):
		remove_meta("f3_down")
	if enabled:
		_refresh()

func _refresh() -> void:
	if game_state == null or controller == null or label == null:
		return
	var flags: Array = game_state.flags.keys()
	flags.sort()
	var current: String = str(controller.call("debug_current_label"))
	var nearby: Array = controller.call("debug_nearby_labels")
	var next_pending: String = str(controller.call("debug_next_pending_label"))
	var survey_lines: Array[String] = []
	for key in game_state.survey_items.keys():
		var mark := "Y" if game_state.survey_items[key] else "-"
		survey_lines.append("%s:%s" % [key, mark])
	label.text = "DEBUG F3\nF5 reset  F6 +event  F7 warp\nCurrent: %s\nNext: %s\nNearby: %s\nFlags:\n%s\nSurvey:\n%s" % [
		current,
		next_pending,
		", ".join(nearby),
		"\n".join(flags),
		"\n".join(survey_lines),
	]
