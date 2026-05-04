extends Control

var panel: Panel
var label: Label

func _ready() -> void:
	visible = false
	panel = Panel.new()
	panel.position = Vector2(310, 374)
	panel.size = Vector2(340, 38)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.06, 0.055, 0.05, 0.84)
	panel_style.border_color = Color(0.82, 0.7, 0.48, 0.62)
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
	label.position = Vector2(10, 7)
	label.size = Vector2(320, 24)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.94, 0.88, 0.66))
	label.clip_text = true
	panel.add_child(label)

func show_prompt(text: String, actionable := true) -> void:
	label.text = ("[E] " if actionable else "") + text
	visible = true

func hide_prompt() -> void:
	visible = false
