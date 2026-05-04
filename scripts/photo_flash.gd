extends Control

var viewfinder: Control
var flash: ColorRect
var caption: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	viewfinder = Control.new()
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
	caption.text = "PHOTO RECORDING"
	caption.position = Vector2(692, 458)
	caption.size = Vector2(190, 24)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	caption.add_theme_font_size_override("font_size", 12)
	caption.add_theme_color_override("font_color", Color(0.88, 0.86, 0.76, 0.84))
	viewfinder.add_child(caption)
	flash = ColorRect.new()
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.color = Color(1, 1, 1, 0)
	add_child(flash)

func play_flash(caption_text := "PHOTO RECORDING") -> void:
	caption.text = caption_text
	viewfinder.visible = true
	viewfinder.modulate.a = 0.0
	flash.color = Color(1, 1, 1, 0.0)
	var tween := create_tween()
	tween.tween_property(viewfinder, "modulate:a", 1.0, 0.08)
	tween.tween_interval(0.08)
	tween.tween_property(flash, "color:a", 0.85, 0.05)
	tween.tween_property(flash, "color:a", 0.0, 0.25)
	tween.parallel().tween_property(viewfinder, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): viewfinder.visible = false)

func _bar(position: Vector2, size: Vector2) -> ColorRect:
	var rect := ColorRect.new()
	rect.position = position
	rect.size = size
	rect.color = Color(0.02, 0.02, 0.018, 0.72)
	return rect

func _frame_line(position: Vector2, size: Vector2) -> void:
	var line := ColorRect.new()
	line.position = position
	line.size = size
	line.color = Color(0.9, 0.86, 0.68, 0.78)
	viewfinder.add_child(line)
