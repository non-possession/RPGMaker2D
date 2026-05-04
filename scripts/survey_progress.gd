extends Control

const SurveyItems = preload("res://data/survey_items.gd")
const Objectives = preload("res://data/objectives.gd")

var game_state: Node
var panel: Panel
var label: Label
var expanded := false

func _ready() -> void:
	panel = Panel.new()
	panel.position = Vector2(18, 18)
	panel.size = Vector2(250, 98)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.07, 0.073, 0.065, 0.86)
	panel_style.border_color = Color(0.62, 0.58, 0.48, 0.58)
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.corner_radius_top_left = 4
	panel_style.corner_radius_top_right = 4
	panel_style.corner_radius_bottom_left = 4
	panel_style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)
	label = Label.new()
	label.position = Vector2(12, 10)
	label.size = Vector2(226, 74)
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.88, 0.85, 0.76))
	label.add_theme_constant_override("line_spacing", 3)
	label.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	panel.add_child(label)
	visible = false

func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_TAB):
		if not has_meta("tab_down"):
			set_meta("tab_down", true)
			expanded = not expanded
			refresh()
	elif has_meta("tab_down"):
		remove_meta("tab_down")

func setup(next_game_state: Node) -> void:
	game_state = next_game_state
	visible = true
	refresh()

func refresh() -> void:
	if game_state == null or label == null:
		return
	var lines := ["当前目标", Objectives.current_objective(game_state)]
	if not expanded:
		lines.append("")
		lines.append("Tab 展开测绘表  %d/5" % _completed_count())
		panel.size = Vector2(250, 98)
		label.size = Vector2(226, 74)
		label.add_theme_font_size_override("font_size", 14)
		label.text = "\n".join(lines)
		return
	lines.append("")
	lines.append("测绘记录")
	for key in SurveyItems.SURVEY_ITEMS.keys():
		var mark := "已" if game_state.survey_items.get(key, false) else "未"
		lines.append("%s %s" % [mark, SurveyItems.SURVEY_ITEMS[key]])
	panel.size = Vector2(250, 210)
	label.size = Vector2(226, 186)
	label.add_theme_font_size_override("font_size", 14)
	label.text = "\n".join(lines)

func _completed_count() -> int:
	var count := 0
	for key in SurveyItems.SURVEY_ITEMS.keys():
		if game_state.survey_items.get(key, false):
			count += 1
	return count
