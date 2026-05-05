extends Node2D

const PlayerScene = preload("res://scenes/player.tscn")
const DialogueScene = preload("res://scenes/ui/dialogue_box.tscn")
const PromptScene = preload("res://scenes/ui/interaction_prompt.tscn")
const SurveyScene = preload("res://scenes/ui/survey_progress.tscn")
const InteractableScript = preload("res://scripts/interactable.gd")
const GameStateScript = preload("res://scripts/game_state.gd")
const InteractionControllerScript = preload("res://scripts/interaction_controller.gd")
const PhotoFlashScript = preload("res://scripts/photo_flash.gd")
const DebugHudScript = preload("res://scripts/debug_hud.gd")
const UiToastScript = preload("res://scripts/ui_toast.gd")
const EndingCardScript = preload("res://scripts/ending_card.gd")
const AudioControllerScript = preload("res://scripts/audio_controller.gd")
const Interactions = preload("res://data/interactions.gd")
const Names = preload("res://data/names.gd")

const BG01_PATH := "res://assets/sprites/classroom/bg01_main_classroom_reality.png"
const BG03_PATH := "res://assets/sprites/classroom/bg03_final_classroom_memory.png"
const BLACKBOARD_ROUGH_PATH := "res://assets/sprites/classroom/obj02_blackboard_state_rough.png"
const BLACKBOARD_PHOTO_PATH := "res://assets/sprites/classroom/obj02_blackboard_state_photo.png"
const BLACKBOARD_FINAL_PATH := "res://assets/sprites/classroom/obj02_blackboard_state_final.png"
const OBJ05_PATH := "res://assets/sprites/objects/obj05_paper_plane_broken_pencil.png"
const OBJ06_PATH := "res://assets/sprites/objects/obj06_archive_father_record.png"
const OBJ08_PATH := "res://assets/sprites/objects/obj08_essay_fragment.png"

@export var use_generated_classroom_background := false
@export var use_generated_memory_background := false
@export var use_generated_blackboard_states := false

var game_state: Node
var player: Node
var controller: Node
var overlays := {}
var completion_markers := {}
var runtime_asset_sprites := {}
var debug_markers_visible := false
var audio_controller: Node

func _ready() -> void:
	_create_game_state()
	_create_classroom()
	_create_audio()
	_create_player()
	_create_ui_and_controller()
	_create_interactables()
	if bool(get_meta("skip_intro_for_qa", false)):
		player.set_input_locked(false)
	else:
		_play_intro()

func _process(_delta: float) -> void:
	_handle_dev_shortcuts()

func _handle_dev_shortcuts() -> void:
	if _consume_key(KEY_F5, "f5_down"):
		get_tree().reload_current_scene()
	if controller != null and _consume_key(KEY_F6, "f6_down"):
		controller.call("debug_complete_next")
	if controller != null and _consume_key(KEY_F7, "f7_down"):
		controller.call("debug_teleport_next")
	if _consume_key(KEY_F4, "f4_down"):
		debug_markers_visible = not debug_markers_visible
		_set_debug_markers_visible(debug_markers_visible)

func _consume_key(keycode: Key, meta_key: String) -> bool:
	if Input.is_key_pressed(keycode):
		if not has_meta(meta_key):
			set_meta(meta_key, true)
			return true
	elif has_meta(meta_key):
		remove_meta(meta_key)
	return false

func _create_game_state() -> void:
	game_state = Node.new()
	game_state.name = "GameState"
	game_state.set_script(GameStateScript)
	add_child(game_state)

func _create_classroom() -> void:
	var root := Node2D.new()
	root.name = "ClassroomRoot"
	add_child(root)
	var background := Node2D.new()
	background.name = "Background"
	root.add_child(background)
	var using_generated_background := _try_add_generated_background(background)
	if not using_generated_background:
		_create_placeholder_background(background)
	else:
		_create_generated_mode_anchor_props(background)
	_create_generated_blackboard_states(background)
	_create_atmosphere(root)
	var completion_root := Node2D.new()
	completion_root.name = "CompletionMarkers"
	root.add_child(completion_root)
	_create_completion_markers(completion_root)
	var collision_root := Node2D.new()
	collision_root.name = "Collision"
	root.add_child(collision_root)
	_create_classroom_collision(collision_root, using_generated_background)
	var overlay_root := Node2D.new()
	overlay_root.name = "MemoryOverlayRoot"
	root.add_child(overlay_root)
	_create_overlays(overlay_root)
	var camera := Camera2D.new()
	camera.name = "Camera2D"
	camera.position = Vector2(440, 270)
	camera.enabled = true
	add_child(camera)

func _create_placeholder_background(background: Node2D) -> void:
	_rect(background, "Floor", Vector2(80, 60), Vector2(720, 420), Color(0.34, 0.33, 0.29))
	_rect(background, "NorthWall", Vector2(80, 60), Vector2(720, 42), Color(0.44, 0.45, 0.4))
	_rect(background, "SouthWall", Vector2(80, 438), Vector2(720, 42), Color(0.28, 0.29, 0.27))
	_rect(background, "WestWall", Vector2(80, 60), Vector2(34, 420), Color(0.3, 0.31, 0.29))
	_rect(background, "EastWindows", Vector2(752, 120), Vector2(32, 250), Color(0.47, 0.53, 0.55))
	_rect(background, "Blackboard", Vector2(260, 82), Vector2(300, 54), Color(0.09, 0.22, 0.17))
	_chalk_line(background, Vector2(286, 100), Vector2(98, 3), Color(0.75, 0.8, 0.7, 0.55))
	_chalk_line(background, Vector2(410, 101), Vector2(66, 3), Color(0.75, 0.8, 0.7, 0.5))
	_chalk_line(background, Vector2(323, 119), Vector2(140, 2), Color(0.75, 0.8, 0.7, 0.42))
	_label(background, "黑板涂写", Vector2(358, 88), Vector2(104, 22), 13, Color(0.83, 0.88, 0.78, 0.75))
	_rect(background, "TeacherDesk", Vector2(218, 386), Vector2(120, 42), Color(0.34, 0.22, 0.14))
	_label(background, "测绘表", Vector2(246, 397), Vector2(70, 22), 13, Color(0.9, 0.78, 0.55, 0.86))
	_rect(background, "Cabinet", Vector2(112, 118), Vector2(88, 86), Color(0.25, 0.25, 0.24))
	_label(background, "档案柜", Vector2(129, 148), Vector2(58, 22), 13, Color(0.76, 0.74, 0.68, 0.82))
	_rect(background, "AwardPaper", Vector2(132, 82), Vector2(66, 34), Color(0.66, 0.55, 0.35))
	_label(background, "奖状", Vector2(145, 89), Vector2(42, 22), 12, Color(0.18, 0.14, 0.08, 0.86))
	_rect(background, "ClosureNotice", Vector2(610, 122), Vector2(88, 52), Color(0.7, 0.68, 0.58))
	_label(background, "撤并通知", Vector2(624, 139), Vector2(70, 22), 12, Color(0.2, 0.18, 0.14, 0.86))
	_rect(background, "SchoolPlaque", Vector2(596, 82), Vector2(92, 28), Color(0.2, 0.2, 0.18))
	_label(background, "%s · %s" % [Names.NAMES["place"], Names.NAMES["school"]], Vector2(601, 88), Vector2(84, 18), 11, Color(0.72, 0.67, 0.48, 0.9))
	_rect(background, "PaperPlane", Vector2(142, 342), Vector2(44, 18), Color(0.68, 0.68, 0.62))
	_label(background, "纸飞机", Vector2(130, 362), Vector2(64, 20), 12, Color(0.8, 0.78, 0.7, 0.78))
	_chalk_line(background, Vector2(761, 288), Vector2(3, 74), Color(0.18, 0.16, 0.14, 0.7))
	_chalk_line(background, Vector2(757, 328), Vector2(22, 3), Color(0.18, 0.16, 0.14, 0.66))
	_label(background, "裂缝", Vector2(718, 306), Vector2(46, 20), 12, Color(0.24, 0.2, 0.16, 0.84))
	for row in range(3):
		for col in range(3):
			_rect(background, "Desk_%d_%d" % [row, col], Vector2(235 + col * 130, 210 + row * 58), Vector2(72, 34), Color(0.35, 0.24, 0.16))
	_label(background, "作文本碎页", Vector2(370, 267), Vector2(84, 20), 12, Color(0.78, 0.72, 0.62, 0.78))

func _create_generated_mode_anchor_props(background: Node2D) -> void:
	var props := Node2D.new()
	props.name = "GeneratedModeAnchorProps"
	background.add_child(props)
	_rect(props, "SurveyClipboard", Vector2(244, 394), Vector2(48, 34), Color(0.72, 0.66, 0.5, 0.92))
	_rect(props, "SurveyPaper", Vector2(250, 398), Vector2(36, 24), Color(0.84, 0.8, 0.66, 0.92))
	_chalk_line(props, Vector2(255, 404), Vector2(24, 2), Color(0.28, 0.25, 0.2, 0.6))
	_chalk_line(props, Vector2(255, 411), Vector2(20, 2), Color(0.28, 0.25, 0.2, 0.45))
	_label(props, "测绘表", Vector2(238, 430), Vector2(64, 18), 11, Color(0.82, 0.72, 0.52, 0.86))
	if not _try_add_object_sprite(props, OBJ05_PATH, "Obj05PaperPlaneBrokenPencil", Vector2(168, 350)):
		_rect(props, "AnchorPaperPlane", Vector2(142, 342), Vector2(44, 18), Color(0.74, 0.72, 0.64, 0.86))
		_label(props, "纸飞机", Vector2(130, 362), Vector2(64, 20), 11, Color(0.78, 0.72, 0.56, 0.78))
	_try_add_object_sprite(props, OBJ06_PATH, "Obj06ArchiveFatherRecord", Vector2(142, 160))
	if not _try_add_object_sprite(props, OBJ08_PATH, "Obj08EssayFragment", Vector2(410, 282)):
		_rect(props, "AnchorEssayFragment", Vector2(374, 268), Vector2(46, 28), Color(0.72, 0.66, 0.52, 0.82))
		_label(props, "作文本", Vector2(366, 296), Vector2(62, 18), 11, Color(0.78, 0.72, 0.56, 0.78))
	_chalk_line(props, Vector2(760, 82), Vector2(3, 76), Color(0.1, 0.08, 0.06, 0.58))
	_chalk_line(props, Vector2(753, 118), Vector2(24, 3), Color(0.1, 0.08, 0.06, 0.5))
	_label(props, "裂缝", Vector2(724, 122), Vector2(46, 20), 11, Color(0.28, 0.22, 0.14, 0.72))

func _create_classroom_collision(collision_root: Node2D, using_generated_background: bool) -> void:
	_static_rect(collision_root, "NorthBoundary", Vector2(80, 50), Vector2(720, 28))
	_static_rect(collision_root, "SouthBoundary", Vector2(80, 468), Vector2(720, 28))
	_static_rect(collision_root, "WestBoundary", Vector2(62, 60), Vector2(28, 420))
	_static_rect(collision_root, "EastBoundary", Vector2(790, 60), Vector2(28, 420))
	if using_generated_background:
		_static_rect(collision_root, "GeneratedCabinetCollision", Vector2(54, 82), Vector2(122, 145))
		var generated_desks := [
			Vector2(278, 204), Vector2(462, 204), Vector2(644, 204),
			Vector2(278, 288), Vector2(462, 288), Vector2(644, 288),
			Vector2(278, 372), Vector2(462, 372), Vector2(644, 372),
		]
		for index in range(generated_desks.size()):
			_static_rect(collision_root, "GeneratedDeskCollision_%02d" % index, generated_desks[index], Vector2(82, 34))
		return
	_static_rect(collision_root, "TeacherDeskCollision", Vector2(218, 386), Vector2(120, 42))
	_static_rect(collision_root, "CabinetCollision", Vector2(112, 118), Vector2(88, 86))
	for row in range(3):
		for col in range(3):
			_static_rect(collision_root, "DeskCollision_%d_%d" % [row, col], Vector2(235 + col * 130, 210 + row * 58), Vector2(72, 28))

func _try_add_generated_background(parent: Node2D) -> bool:
	if not use_generated_classroom_background:
		return false
	if not _asset_file_exists(BG01_PATH):
		return false
	var sprite := Sprite2D.new()
	sprite.name = "GeneratedClassroomBackground"
	sprite.texture = load(BG01_PATH)
	sprite.position = Vector2(480, 270)
	parent.add_child(sprite)
	return true

func _create_generated_blackboard_states(parent: Node2D) -> void:
	runtime_asset_sprites["blackboard_rough"] = _try_add_generated_blackboard_state(parent, BLACKBOARD_ROUGH_PATH, "GeneratedBlackboardRough", true)
	runtime_asset_sprites["blackboard_photo"] = _try_add_generated_blackboard_state(parent, BLACKBOARD_PHOTO_PATH, "GeneratedBlackboardPhoto", false)
	runtime_asset_sprites["blackboard_final"] = _try_add_generated_blackboard_state(parent, BLACKBOARD_FINAL_PATH, "GeneratedBlackboardFinal", false)

func _try_add_generated_blackboard_state(parent: Node2D, path: String, sprite_name: String, initially_visible: bool) -> Sprite2D:
	if not use_generated_blackboard_states:
		return null
	if not _asset_file_exists(path):
		return null
	var sprite := Sprite2D.new()
	sprite.name = sprite_name
	sprite.texture = load(path)
	sprite.position = Vector2(410, 109)
	sprite.visible = initially_visible
	parent.add_child(sprite)
	return sprite

func _try_add_object_sprite(parent: Node2D, path: String, sprite_name: String, position: Vector2) -> bool:
	if not _asset_file_exists(path):
		return false
	var sprite := Sprite2D.new()
	sprite.name = sprite_name
	sprite.texture = load(path)
	sprite.position = position
	parent.add_child(sprite)
	return true

func _create_atmosphere(parent: Node2D) -> void:
	var atmosphere := Node2D.new()
	atmosphere.name = "Atmosphere"
	parent.add_child(atmosphere)
	_rect(atmosphere, "RoomVignetteTop", Vector2(80, 60), Vector2(720, 34), Color(0.08, 0.08, 0.07, 0.18))
	_rect(atmosphere, "RoomVignetteLeft", Vector2(80, 60), Vector2(28, 420), Color(0.06, 0.06, 0.055, 0.16))
	_rect(atmosphere, "WindowColdLightA", Vector2(590, 132), Vector2(164, 34), Color(0.62, 0.72, 0.74, 0.12))
	_rect(atmosphere, "WindowColdLightB", Vector2(520, 224), Vector2(232, 26), Color(0.62, 0.72, 0.74, 0.09))
	_rect(atmosphere, "WindowColdLightC", Vector2(610, 322), Vector2(142, 22), Color(0.62, 0.72, 0.74, 0.08))
	var dust_points := [
		Vector2(604, 150), Vector2(642, 158), Vector2(700, 171), Vector2(548, 232),
		Vector2(620, 244), Vector2(696, 236), Vector2(658, 330), Vector2(716, 344),
		Vector2(324, 112), Vector2(465, 119), Vector2(180, 356), Vector2(404, 278),
	]
	for index in range(dust_points.size()):
		var dust := ColorRect.new()
		dust.name = "Dust_%02d" % index
		dust.position = dust_points[index]
		dust.size = Vector2(2, 2)
		dust.color = Color(0.82, 0.78, 0.62, 0.18)
		atmosphere.add_child(dust)

func _create_overlays(parent: Node2D) -> void:
	overlays["overlay_blackboard_surface"] = _overlay(parent, "OverlayBlackboardSurface", Vector2(245, 78), Vector2(330, 76), Color(0.9, 0.66, 0.28, 0.42), "田野的风 / 放学后的笑声")
	overlays["overlay_place_disturbance"] = _overlay(parent, "OverlayPlaceDisturbance", Vector2(560, 80), Vector2(150, 90), Color(0.08, 0.09, 0.11, 0.62), "这个地名\n不是空的")
	overlays["overlay_paper_plane_emotion"] = _overlay(parent, "OverlayPaperPlaneEmotion", Vector2(105, 320), Vector2(140, 90), Color(0.06, 0.065, 0.07, 0.62), "纸飞机\n断铅笔\n说不清的湿意")
	overlays["overlay_father_photo"] = _overlay(parent, "OverlayFatherPhoto", Vector2(115, 120), Vector2(140, 105), Color(0.82, 0.64, 0.32, 0.54), "旧照片\n少年老李\n眼睛很亮")
	overlays["overlay_blackboard_photo"] = _overlay(parent, "OverlayBlackboardPhoto", Vector2(250, 80), Vector2(320, 68), Color(0.96, 0.9, 0.56, 0.38), "以后都要去大城市")
	overlays["overlay_girl_memory"] = _overlay(parent, "OverlayGirlMemory", Vector2(330, 220), Vector2(130, 86), Color(0.9, 0.58, 0.26, 0.46), "我的家乡……\n何小满")
	overlays["overlay_final_classroom"] = _overlay(parent, "OverlayFinalClassroom", Vector2(80, 60), Vector2(720, 420), Color(0.9, 0.68, 0.38, 0.38), "最终照片\n这间教室曾经不是空的")
	_try_add_generated_memory_background(overlays["overlay_final_classroom"])
	var final_overlay: ColorRect = overlays["overlay_final_classroom"]
	_rect(final_overlay, "FinalLightA", Vector2(482, 54), Vector2(54, 380), Color(1.0, 0.86, 0.48, 0.16))
	_rect(final_overlay, "FinalLightB", Vector2(552, 54), Vector2(38, 380), Color(1.0, 0.86, 0.48, 0.11))
	_label(final_overlay, "粉笔灰在光里浮着", Vector2(360, 90), Vector2(190, 24), 13, Color(0.54, 0.36, 0.18, 0.82))

func _try_add_generated_memory_background(parent: Node) -> void:
	if not use_generated_memory_background:
		return
	if not _asset_file_exists(BG03_PATH):
		return
	var sprite := Sprite2D.new()
	sprite.name = "GeneratedFinalMemoryBackground"
	sprite.texture = load(BG03_PATH)
	sprite.position = Vector2(400, 210)
	sprite.modulate.a = 0.82
	parent.add_child(sprite)

func _asset_file_exists(path: String) -> bool:
	return ResourceLoader.exists(path) or FileAccess.file_exists(path)

func _create_audio() -> void:
	audio_controller = Node.new()
	audio_controller.name = "AudioController"
	audio_controller.set_script(AudioControllerScript)
	add_child(audio_controller)

func _create_player() -> void:
	player = PlayerScene.instantiate()
	player.position = Vector2(185, 408)
	add_child(player)

func _create_ui_and_controller() -> void:
	var ui := CanvasLayer.new()
	ui.name = "UI"
	add_child(ui)
	var dialogue = DialogueScene.instantiate()
	ui.add_child(dialogue)
	var prompt = PromptScene.instantiate()
	ui.add_child(prompt)
	var survey = SurveyScene.instantiate()
	ui.add_child(survey)
	var flash := Control.new()
	flash.name = "PhotoFlash"
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.set_script(PhotoFlashScript)
	ui.add_child(flash)
	var toast := Control.new()
	toast.name = "UIToast"
	toast.set_anchors_preset(Control.PRESET_FULL_RECT)
	toast.set_script(UiToastScript)
	ui.add_child(toast)
	var ending_card := Control.new()
	ending_card.name = "EndingCard"
	ending_card.set_anchors_preset(Control.PRESET_FULL_RECT)
	ending_card.set_script(EndingCardScript)
	ui.add_child(ending_card)
	controller = Node.new()
	controller.name = "InteractionController"
	controller.set_script(InteractionControllerScript)
	add_child(controller)
	controller.call("setup", {
		"game_state": game_state,
		"dialogue_box": dialogue,
		"interaction_prompt": prompt,
		"survey_progress": survey,
		"photo_flash": flash,
		"ui_toast": toast,
		"ending_card": ending_card,
		"player": player,
		"overlays": overlays,
		"completion_markers": completion_markers,
		"runtime_asset_sprites": runtime_asset_sprites,
		"audio_controller": audio_controller,
	})
	var debug_hud := Control.new()
	debug_hud.name = "DebugHUD"
	debug_hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	debug_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	debug_hud.set_script(DebugHudScript)
	ui.add_child(debug_hud)
	debug_hud.call("setup", game_state, controller)

func _create_interactables() -> void:
	var root := Node2D.new()
	root.name = "Interactables"
	add_child(root)
	for id in Interactions.INTERACTIONS.keys():
		var data: Dictionary = Interactions.INTERACTIONS[id].duplicate(true)
		data["id"] = id
		var area := Area2D.new()
		area.set_script(InteractableScript)
		area.position = data.get("position", Vector2.ZERO)
		root.add_child(area)
		area.call("setup", data, game_state, data.get("size", Vector2(48, 34)))
		area.add_to_group("interactables")
		controller.register_interactable(area)

func _set_debug_markers_visible(next_visible: bool) -> void:
	for item in get_tree().get_nodes_in_group("interactables"):
		if is_instance_valid(item) and item.has_method("set_debug_visible"):
			item.call("set_debug_visible", next_visible)

func _create_completion_markers(parent: Node2D) -> void:
	for id in Interactions.INTERACTIONS.keys():
		var data: Dictionary = Interactions.INTERACTIONS[id]
		var marker := Node2D.new()
		marker.name = "Completion_%s" % id
		marker.position = data.get("position", Vector2.ZERO) + _completion_marker_offset(id)
		marker.visible = false
		parent.add_child(marker)
		var paper := ColorRect.new()
		paper.name = "PaperTag"
		paper.position = Vector2(-18, -10)
		paper.size = Vector2(36, 20)
		paper.color = Color(0.78, 0.7, 0.54, 0.86)
		marker.add_child(paper)
		var line := ColorRect.new()
		line.name = "Tape"
		line.position = Vector2(-10, -13)
		line.size = Vector2(20, 5)
		line.color = Color(0.92, 0.86, 0.65, 0.74)
		marker.add_child(line)
		var text := Label.new()
		text.name = "Text"
		text.text = _completion_marker_text(id, data)
		text.position = Vector2(-17, -9)
		text.size = Vector2(34, 18)
		text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		text.add_theme_font_size_override("font_size", 10)
		text.add_theme_color_override("font_color", Color(0.18, 0.14, 0.1, 0.92))
		text.clip_text = true
		marker.add_child(text)
		completion_markers[id] = marker

func _completion_marker_text(id: String, data: Dictionary) -> String:
	if id == "A9":
		return "危险"
	if id == "A1":
		return "表"
	if data.get("photo_required", false):
		return "照片"
	if not data.get("survey_items", []).is_empty():
		return "记录"
	return "已看"

func _completion_marker_offset(id: String) -> Vector2:
	match id:
		"A1":
			return Vector2(44, -28)
		"A2", "A10":
			return Vector2(126, -32)
		"A4":
			return Vector2(40, -24)
		"A5", "A6":
			return Vector2(54, -28)
		"A8":
			return Vector2(-38, -54)
		"A9":
			return Vector2(-34, -50)
		"A11":
			return Vector2(52, 30)
		"A7":
			return Vector2(-28, -28)
		"A12":
			return Vector2(76, -50)
		_:
			return Vector2(38, -26)

func _play_intro() -> void:
	var dialogue = get_node("UI/DialogueBox")
	player.set_input_locked(true)
	if audio_controller != null and audio_controller.has_method("play_intro"):
		audio_controller.call("play_intro")
	dialogue.dialogue_finished.connect(func(id):
		if id == "intro_vehicle":
			player.set_input_locked(false)
	, CONNECT_ONE_SHOT)
	dialogue.play("intro_vehicle", game_state)

func _rect(parent: Node, rect_name: String, position: Vector2, size: Vector2, color: Color) -> ColorRect:
	var rect := ColorRect.new()
	rect.name = rect_name
	rect.position = position
	rect.size = size
	rect.color = color
	parent.add_child(rect)
	return rect

func _chalk_line(parent: Node, position: Vector2, size: Vector2, color: Color) -> ColorRect:
	return _rect(parent, "DetailLine", position, size, color)

func _label(parent: Node, text: String, position: Vector2, size: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = position
	label.size = size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.clip_text = true
	parent.add_child(label)
	return label

func _static_rect(parent: Node, body_name: String, position: Vector2, size: Vector2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = body_name
	body.position = position + size * 0.5
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = size
	shape.shape = rectangle
	body.add_child(shape)
	parent.add_child(body)
	return body

func _overlay(parent: Node, overlay_name: String, position: Vector2, size: Vector2, color: Color, caption := "") -> ColorRect:
	var rect := _rect(parent, overlay_name, position, size, color)
	var border_top := _rect(rect, "MemoryBorderTop", Vector2.ZERO, Vector2(size.x, 2), Color(1.0, 0.86, 0.48, 0.72))
	var border_bottom := _rect(rect, "MemoryBorderBottom", Vector2(0, size.y - 2), Vector2(size.x, 2), Color(1.0, 0.86, 0.48, 0.52))
	border_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	border_bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not caption.is_empty():
		var label := Label.new()
		label.text = caption
		label.position = Vector2(8, 8)
		label.size = size - Vector2(16, 16)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
		label.add_theme_font_size_override("font_size", 13)
		label.add_theme_color_override("font_color", Color(0.96, 0.88, 0.66, 0.86))
		label.add_theme_constant_override("line_spacing", 3)
		rect.add_child(label)
	rect.visible = false
	rect.modulate.a = 0.0
	return rect
