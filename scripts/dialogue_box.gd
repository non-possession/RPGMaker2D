extends Control

const Dialogues = preload("res://data/dialogues.gd")
const Portraits = preload("res://data/portraits.gd")

signal dialogue_finished(dialogue_id: String)

var panel: Panel
var portrait_panel: Panel
var portrait_texture: TextureRect
var portrait_fallback: ColorRect
var portrait_label: Label
var speaker_label: Label
var text_label: Label
var hint_label: Label
var current_lines: Array = []
var current_index := 0
var current_id := ""
var game_state: Node
var is_playing := false
var input_cooldown := 0.0
var panel_tween: Tween

func _ready() -> void:
	visible = false
	panel = Panel.new()
	panel.name = "Panel"
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_left = 36
	panel.offset_right = -36
	panel.offset_top = -174
	panel.offset_bottom = -24
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.075, 0.065, 0.92)
	panel_style.border_color = Color(0.72, 0.63, 0.47, 0.72)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.corner_radius_top_left = 4
	panel_style.corner_radius_top_right = 4
	panel_style.corner_radius_bottom_left = 4
	panel_style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)
	portrait_panel = Panel.new()
	portrait_panel.name = "PortraitPanel"
	portrait_panel.position = Vector2(20, 20)
	portrait_panel.size = Vector2(82, 104)
	var portrait_style := StyleBoxFlat.new()
	portrait_style.bg_color = Color(0.14, 0.13, 0.12, 0.74)
	portrait_style.border_color = Color(0.58, 0.52, 0.42, 0.58)
	portrait_style.border_width_left = 1
	portrait_style.border_width_top = 1
	portrait_style.border_width_right = 1
	portrait_style.border_width_bottom = 1
	portrait_style.corner_radius_top_left = 3
	portrait_style.corner_radius_top_right = 3
	portrait_style.corner_radius_bottom_left = 3
	portrait_style.corner_radius_bottom_right = 3
	portrait_panel.add_theme_stylebox_override("panel", portrait_style)
	portrait_panel.visible = false
	panel.add_child(portrait_panel)
	portrait_texture = TextureRect.new()
	portrait_texture.name = "PortraitTexture"
	portrait_texture.position = Vector2(6, 6)
	portrait_texture.size = Vector2(70, 92)
	portrait_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	portrait_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_texture.visible = false
	portrait_panel.add_child(portrait_texture)
	portrait_fallback = ColorRect.new()
	portrait_fallback.name = "PortraitFallback"
	portrait_fallback.position = Vector2(6, 6)
	portrait_fallback.size = Vector2(70, 92)
	portrait_fallback.color = Color(0.22, 0.2, 0.18)
	portrait_fallback.visible = false
	portrait_panel.add_child(portrait_fallback)
	portrait_label = Label.new()
	portrait_label.name = "PortraitLabel"
	portrait_label.text = ""
	portrait_label.position = Vector2(8, 38)
	portrait_label.size = Vector2(66, 28)
	portrait_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portrait_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	portrait_label.add_theme_font_size_override("font_size", 18)
	portrait_label.add_theme_color_override("font_color", Color(0.88, 0.82, 0.68))
	portrait_panel.add_child(portrait_label)
	speaker_label = Label.new()
	speaker_label.position = Vector2(22, 14)
	speaker_label.size = Vector2(220, 26)
	speaker_label.add_theme_font_size_override("font_size", 16)
	speaker_label.add_theme_color_override("font_color", Color(0.92, 0.78, 0.54))
	panel.add_child(speaker_label)
	text_label = Label.new()
	text_label.position = Vector2(22, 46)
	text_label.size = Vector2(820, 86)
	text_label.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	text_label.add_theme_font_size_override("font_size", 18)
	text_label.add_theme_color_override("font_color", Color(0.94, 0.91, 0.84))
	text_label.add_theme_constant_override("line_spacing", 5)
	panel.add_child(text_label)
	hint_label = Label.new()
	hint_label.text = "E / Enter 继续"
	hint_label.position = Vector2(710, 124)
	hint_label.size = Vector2(160, 24)
	hint_label.add_theme_font_size_override("font_size", 12)
	hint_label.add_theme_color_override("font_color", Color(0.72, 0.69, 0.62))
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint_label.modulate.a = 0.0
	panel.add_child(hint_label)

func play(dialogue_id: String, next_game_state: Node) -> void:
	current_id = dialogue_id
	game_state = next_game_state
	current_lines = Dialogues.DIALOGUES.get(dialogue_id, [])
	current_index = 0
	is_playing = true
	input_cooldown = 0.24
	visible = true
	modulate.a = 0.0
	if panel_tween != null:
		panel_tween.kill()
	panel_tween = create_tween()
	panel_tween.tween_property(self, "modulate:a", 1.0, 0.14)
	_show_current_line()

func _process(delta: float) -> void:
	if not is_playing:
		return
	if input_cooldown > 0.0:
		input_cooldown = max(0.0, input_cooldown - delta)
		if input_cooldown == 0.0:
			_reveal_hint()
		return
	if Input.is_action_just_pressed("interact"):
		advance()

func advance() -> void:
	current_index += 1
	if current_index >= current_lines.size():
		visible = false
		is_playing = false
		dialogue_finished.emit(current_id)
		return
	_show_current_line()

func _show_current_line() -> void:
	if current_lines.is_empty():
		text_label.text = ""
		speaker_label.text = ""
		return
	var line: Dictionary = current_lines[current_index]
	var speaker := str(line.get("speaker_name", line.get("speaker_id", "")))
	var text := str(line.get("text", ""))
	var portrait_id := str(line.get("portrait_id", ""))
	if game_state != null:
		speaker = game_state.format_text(speaker)
		text = game_state.format_text(text)
	_apply_portrait(portrait_id)
	if portrait_panel.visible:
		speaker_label.position = Vector2(122, 14)
		text_label.position = Vector2(122, 46)
		text_label.size = Vector2(720, 86)
	else:
		speaker_label.position = Vector2(22, 14)
		text_label.position = Vector2(22, 46)
		text_label.size = Vector2(820, 86)
	speaker_label.text = speaker
	text_label.text = text
	hint_label.modulate.a = 0.0
	input_cooldown = _line_lock_duration(speaker, text)
	text_label.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(text_label, "modulate:a", 1.0, 0.1)

func _apply_portrait(portrait_id: String) -> void:
	portrait_panel.visible = not portrait_id.is_empty()
	portrait_texture.visible = false
	portrait_texture.texture = null
	portrait_fallback.visible = false
	portrait_label.text = ""
	if portrait_id.is_empty():
		return
	var config := Portraits.get_portrait(portrait_id)
	var image_path := str(config.get("path", ""))
	if not image_path.is_empty():
		var loaded_texture := load(image_path)
		if loaded_texture is Texture2D:
			portrait_texture.texture = loaded_texture
			portrait_texture.visible = true
			return
	portrait_fallback.color = config.get("tint", Color(0.22, 0.2, 0.18))
	portrait_fallback.visible = true
	portrait_label.text = str(config.get("fallback_initial", portrait_id.substr(0, 1)))

func _line_lock_duration(speaker: String, text: String) -> float:
	var base := 0.18
	if speaker == "旁白":
		base = 0.28
	elif speaker == "系统":
		base = 0.14
	elif speaker == "对讲机":
		base = 0.2
	var length_pause: float = min(0.62, float(text.length()) * 0.012)
	if text.ends_with("。") or text.ends_with("……"):
		length_pause += 0.08
	return clamp(base + length_pause, 0.22, 0.92)

func _reveal_hint() -> void:
	var tween := create_tween()
	tween.tween_property(hint_label, "modulate:a", 1.0, 0.12)
