extends Control

const TITLE_SCENE_PATH := "res://scenes/title_screen.tscn"

var panel: Panel
var title_label: Label
var body_label: Label
var return_button: Button

func _process(_delta: float) -> void:
	if visible and Input.is_action_just_pressed("interact"):
		_return_to_title()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	modulate.a = 0.0
	panel = Panel.new()
	panel.position = Vector2(282, 132)
	panel.size = Vector2(396, 218)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.07, 0.062, 0.052, 0.92)
	panel_style.border_color = Color(0.72, 0.62, 0.44, 0.72)
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
	title_label = Label.new()
	title_label.text = "测绘完成"
	title_label.position = Vector2(26, 28)
	title_label.size = Vector2(344, 32)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.add_theme_color_override("font_color", Color(0.92, 0.78, 0.52))
	panel.add_child(title_label)
	body_label = Label.new()
	body_label.text = "最终照片已保存。\n这间教室仍会被拆除，\n但它不再只是表格上的一个地址。"
	body_label.position = Vector2(42, 72)
	body_label.size = Vector2(312, 82)
	body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	body_label.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	body_label.add_theme_font_size_override("font_size", 16)
	body_label.add_theme_color_override("font_color", Color(0.88, 0.84, 0.74))
	body_label.add_theme_constant_override("line_spacing", 4)
	panel.add_child(body_label)
	return_button = Button.new()
	return_button.name = "ReturnTitleButton"
	return_button.text = "返回标题"
	return_button.position = Vector2(122, 166)
	return_button.size = Vector2(152, 32)
	return_button.focus_mode = Control.FOCUS_NONE
	return_button.pressed.connect(_return_to_title)
	panel.add_child(return_button)

func show_card() -> void:
	visible = true
	modulate.a = 0.0
	panel.scale = Vector2(0.98, 0.98)
	var tween := create_tween()
	tween.tween_interval(0.15)
	tween.tween_property(self, "modulate:a", 1.0, 0.45)
	tween.parallel().tween_property(panel, "scale", Vector2.ONE, 0.45)

func _return_to_title() -> void:
	get_tree().change_scene_to_file(TITLE_SCENE_PATH)
