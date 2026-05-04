extends Control

var panel: Panel
var label: Label
var active_tween: Tween

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	panel = Panel.new()
	panel.position = Vector2(338, 54)
	panel.size = Vector2(284, 42)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.07, 0.065, 0.055, 0.9)
	panel_style.border_color = Color(0.68, 0.58, 0.42, 0.68)
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
	label.position = Vector2(12, 8)
	label.size = Vector2(260, 26)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", Color(0.91, 0.86, 0.7))
	panel.add_child(label)

func show_toast(text: String) -> void:
	if active_tween != null:
		active_tween.kill()
	label.text = text
	visible = true
	modulate.a = 0.0
	active_tween = create_tween()
	active_tween.tween_property(self, "modulate:a", 1.0, 0.12)
	active_tween.tween_interval(1.1)
	active_tween.tween_property(self, "modulate:a", 0.0, 0.35)
	active_tween.tween_callback(func(): visible = false)
