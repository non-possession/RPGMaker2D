extends Control

const MAIN_SCENE_PATH := "res://scenes/main.tscn"
const BG01_PATH := "res://assets/sprites/classroom/bg01_main_classroom_reality.png"

var starting := false
var content: Control
var hint_label: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_create_background()
	_create_content()

func _process(_delta: float) -> void:
	if starting:
		return
	if Input.is_action_just_pressed("interact"):
		_start_game()
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _create_background() -> void:
	if ResourceLoader.exists(BG01_PATH) or FileAccess.file_exists(BG01_PATH):
		var sprite := Sprite2D.new()
		sprite.name = "DimClassroomBackground"
		sprite.texture = load(BG01_PATH)
		sprite.position = Vector2(480, 270)
		sprite.modulate = Color(0.44, 0.42, 0.38, 0.62)
		add_child(sprite)
	else:
		var fallback := ColorRect.new()
		fallback.name = "FallbackBackground"
		fallback.set_anchors_preset(Control.PRESET_FULL_RECT)
		fallback.color = Color(0.08, 0.075, 0.065, 1.0)
		add_child(fallback)
	var shade := ColorRect.new()
	shade.name = "QuietShade"
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.018, 0.014, 0.5)
	add_child(shade)
	var window_light := ColorRect.new()
	window_light.name = "WindowMemoryLight"
	window_light.position = Vector2(588, 106)
	window_light.size = Vector2(92, 362)
	window_light.color = Color(0.95, 0.74, 0.42, 0.08)
	add_child(window_light)

func _create_content() -> void:
	content = Control.new()
	content.name = "TitleContent"
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(content)
	var title := Label.new()
	title.name = "Title"
	title.text = "最后一间教室"
	title.position = Vector2(96, 126)
	title.size = Vector2(500, 58)
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(0.92, 0.82, 0.62, 0.96))
	content.add_child(title)
	var subtitle := Label.new()
	subtitle.name = "Subtitle"
	subtitle.text = "v0.1 原型"
	subtitle.position = Vector2(102, 190)
	subtitle.size = Vector2(240, 30)
	subtitle.add_theme_font_size_override("font_size", 17)
	subtitle.add_theme_color_override("font_color", Color(0.78, 0.73, 0.62, 0.8))
	content.add_child(subtitle)
	var line := ColorRect.new()
	line.name = "Divider"
	line.position = Vector2(100, 238)
	line.size = Vector2(300, 1)
	line.color = Color(0.78, 0.66, 0.45, 0.52)
	content.add_child(line)
	var body := Label.new()
	body.name = "Body"
	body.text = "一名测绘人员来到即将拆除的乡村旧校舍。\n他本来只是记录现状，直到某些名字开始重新变得具体。"
	body.position = Vector2(100, 262)
	body.size = Vector2(560, 84)
	body.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	body.add_theme_font_size_override("font_size", 18)
	body.add_theme_color_override("font_color", Color(0.9, 0.86, 0.76, 0.86))
	body.add_theme_constant_override("line_spacing", 5)
	content.add_child(body)
	hint_label = Label.new()
	hint_label.name = "StartHint"
	hint_label.text = "E / Enter  开始测绘"
	hint_label.position = Vector2(100, 382)
	hint_label.size = Vector2(260, 30)
	hint_label.add_theme_font_size_override("font_size", 18)
	hint_label.add_theme_color_override("font_color", Color(0.94, 0.78, 0.48, 0.92))
	content.add_child(hint_label)
	var exit_hint := Label.new()
	exit_hint.name = "ExitHint"
	exit_hint.text = "Esc 退出"
	exit_hint.position = Vector2(100, 420)
	exit_hint.size = Vector2(160, 24)
	exit_hint.add_theme_font_size_override("font_size", 13)
	exit_hint.add_theme_color_override("font_color", Color(0.72, 0.68, 0.58, 0.72))
	content.add_child(exit_hint)
	var tween := create_tween().set_loops()
	tween.tween_property(hint_label, "modulate:a", 0.45, 0.9)
	tween.tween_property(hint_label, "modulate:a", 1.0, 0.9)

func _start_game() -> void:
	starting = true
	hint_label.text = "正在进入教室……"
	var tween := create_tween()
	tween.tween_property(content, "modulate:a", 0.0, 0.32)
	tween.tween_callback(func(): get_tree().change_scene_to_file(MAIN_SCENE_PATH))
