extends Control

var viewfinder: Control
var flash: ColorRect
var caption: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	viewfinder = Control.new()
	viewfinder.name = "Viewfinder"
	viewfinder.set_anchors_preset(Control.PRESET_FULL_RECT)
	viewfinder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	viewfinder.visible = false
	add_child(viewfinder)
	var top_bar := _bar(Vector2(0, 0), Vector2(960, 54))
	var bottom_bar := _bar(Vector2(0, 486), Vector2(960, 54))
	var left_bar := _bar(Vector2(0, 54), Vector2(68, 432))
	var right_bar := _bar(Vector2(892, 54), Vector2(68, 432))
	viewfinder.add_child(top_bar)
	viewfinder.add_child(bottom_bar)
	viewfinder.add_child(left_bar)
	viewfinder.add_child(right_bar)
	_frame_line(Vector2(132, 92), Vector2(696, 2))
	_frame_line(Vector2(132, 446), Vector2(696, 2))
	_frame_line(Vector2(132, 92), Vector2(2, 356))
	_frame_line(Vector2(826, 92), Vector2(2, 356))
	caption = Label.new()
	caption.name = "Caption"
	caption.text = "测绘照片记录"
	caption.position = Vector2(640, 454)
	caption.size = Vector2(244, 28)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	caption.add_theme_font_size_override("font_size", 16)
	caption.add_theme_color_override("font_color", Color(0.95, 0.9, 0.66, 0.94))
	viewfinder.add_child(caption)
	flash = ColorRect.new()
	flash.name = "Flash"
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.color = Color(1, 1, 1, 0)
	add_child(flash)

func play_flash(caption_text := "测绘照片记录") -> void:
	caption.text = caption_text
	viewfinder.visible = true
	viewfinder.modulate.a = 0.0
	flash.color = Color(1, 1, 1, 0.0)
	var tween := create_tween()
	tween.tween_property(viewfinder, "modulate:a", 1.0, 0.12)
	tween.tween_interval(0.18)
	tween.tween_property(flash, "color:a", 0.92, 0.055)
	tween.tween_property(flash, "color:a", 0.0, 0.32)
	tween.tween_interval(0.14)
	tween.tween_property(viewfinder, "modulate:a", 0.0, 0.38)
	tween.tween_callback(func(): viewfinder.visible = false)

func _bar(position: Vector2, size: Vector2) -> ColorRect:
	var rect := ColorRect.new()
	rect.position = position
	rect.size = size
	rect.color = Color(0.015, 0.014, 0.012, 0.82)
	return rect

func _frame_line(position: Vector2, size: Vector2) -> void:
	var line := ColorRect.new()
	line.position = position
	line.size = size
	line.color = Color(0.96, 0.88, 0.55, 0.95)
	viewfinder.add_child(line)
