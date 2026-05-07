extends Control

const TITLE_SCENE_PATH := "res://scenes/title_screen.tscn"

signal menu_toggled(open: bool)

var player: Node
var controller: Node
var audio_controller: Node
var panel: Panel
var volume_slider: HSlider
var fullscreen_button: Button
var status_label: Label
var is_open := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false
	_build_ui()

func setup(next_player: Node, next_controller: Node, next_audio_controller: Node) -> void:
	player = next_player
	controller = next_controller
	audio_controller = next_audio_controller
	_apply_volume(0.75)
	_refresh_fullscreen_label()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if is_open:
			close_menu()
		elif _can_open():
			open_menu()

func open_menu() -> void:
	is_open = true
	visible = true
	modulate.a = 0.0
	if player != null and player.has_method("set_input_locked"):
		player.call("set_input_locked", true)
	if controller != null:
		controller.input_locked = true
	menu_toggled.emit(true)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.12)

func close_menu() -> void:
	is_open = false
	visible = false
	if player != null and player.has_method("set_input_locked"):
		player.call("set_input_locked", false)
	if controller != null:
		controller.input_locked = false
	menu_toggled.emit(false)

func _can_open() -> bool:
	if controller == null:
		return true
	if controller.input_locked:
		return false
	if controller.dialogue_box != null and controller.dialogue_box.is_playing:
		return false
	return true

func _build_ui() -> void:
	var shade := ColorRect.new()
	shade.name = "Shade"
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.018, 0.014, 0.66)
	add_child(shade)
	panel = Panel.new()
	panel.name = "Panel"
	panel.position = Vector2(318, 122)
	panel.size = Vector2(324, 296)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.075, 0.065, 0.95)
	style.border_color = Color(0.72, 0.63, 0.47, 0.72)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	var title := _label("设置", Vector2(24, 20), Vector2(120, 28), 20, Color(0.94, 0.78, 0.48, 0.95))
	panel.add_child(title)
	status_label = _label("", Vector2(24, 52), Vector2(260, 22), 13, Color(0.72, 0.68, 0.58, 0.82))
	panel.add_child(status_label)
	var volume_label := _label("音量", Vector2(24, 88), Vector2(64, 24), 15, Color(0.9, 0.86, 0.76, 0.9))
	panel.add_child(volume_label)
	volume_slider = HSlider.new()
	volume_slider.name = "VolumeSlider"
	volume_slider.position = Vector2(92, 88)
	volume_slider.size = Vector2(194, 24)
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step = 0.05
	volume_slider.value = 0.75
	volume_slider.value_changed.connect(_apply_volume)
	panel.add_child(volume_slider)
	fullscreen_button = _button("切换窗口", Vector2(24, 132), Vector2(276, 34))
	fullscreen_button.pressed.connect(_toggle_fullscreen)
	panel.add_child(fullscreen_button)
	var title_button := _button("返回标题", Vector2(24, 176), Vector2(276, 34))
	title_button.pressed.connect(_return_to_title)
	panel.add_child(title_button)
	var quit_button := _button("退出", Vector2(24, 220), Vector2(276, 34))
	quit_button.pressed.connect(func(): get_tree().quit())
	panel.add_child(quit_button)
	var close_button := _button("继续", Vector2(24, 260), Vector2(276, 28))
	close_button.pressed.connect(close_menu)
	panel.add_child(close_button)

func _label(text: String, position: Vector2, size: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = position
	label.size = size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _button(text: String, position: Vector2, size: Vector2) -> Button:
	var button := Button.new()
	button.text = text
	button.position = position
	button.size = size
	button.focus_mode = Control.FOCUS_NONE
	return button

func _apply_volume(value: float) -> void:
	var db := linear_to_db(max(value, 0.001))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)
	if status_label != null:
		status_label.text = "音量 %d%%" % int(round(value * 100.0))

func _toggle_fullscreen() -> void:
	var mode := DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	_refresh_fullscreen_label()

func _refresh_fullscreen_label() -> void:
	if fullscreen_button == null:
		return
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		fullscreen_button.text = "切换窗口"
	else:
		fullscreen_button.text = "切换全屏"

func _return_to_title() -> void:
	get_tree().change_scene_to_file(TITLE_SCENE_PATH)
