extends SceneTree

const Interactions = preload("res://data/interactions.gd")
const Objectives = preload("res://data/objectives.gd")

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main_scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main_scene)
	await process_frame
	await process_frame
	var game_state: Node = main_scene.get_node("GameState")
	var controller: Node = main_scene.get_node("InteractionController")
	var audio_controller: Node = main_scene.get_node("AudioController")
	var player: Node = main_scene.get_node("Player")
	var ending_card: Control = main_scene.get_node("UI/EndingCard")
	var flash: Control = main_scene.get_node("UI/PhotoFlash")
	_assert(game_state != null, "GameState exists")
	_assert(controller != null, "InteractionController exists")
	_assert(audio_controller != null, "AudioController exists")
	_assert(audio_controller.get_node_or_null("AmbientPlayer") != null, "ambient audio player exists")
	_assert(player != null, "Player exists")
	_assert(ending_card != null, "EndingCard exists")
	_assert(flash != null, "PhotoFlash exists")
	if FileAccess.file_exists("res://assets/sprites/characters/ch01_surveyor_player_sheet.png"):
		var generated_player := player.get_node_or_null("GeneratedPlayerSprite")
		_assert(generated_player != null, "generated player sprite is used when CH01 exists")
	if main_scene.use_generated_classroom_background:
		var bg_node := main_scene.get_node_or_null("ClassroomRoot/Background/GeneratedClassroomBackground")
		_assert(bg_node != null, "generated BG01 node exists when enabled")
		var anchor_props := main_scene.get_node_or_null("ClassroomRoot/Background/GeneratedModeAnchorProps")
		_assert(anchor_props != null, "generated mode anchor props exist")
		if FileAccess.file_exists("res://assets/sprites/objects/obj05_paper_plane_broken_pencil.png"):
			var obj05 := main_scene.get_node_or_null("ClassroomRoot/Background/GeneratedModeAnchorProps/Obj05PaperPlaneBrokenPencil")
			_assert(obj05 != null, "OBJ05 runtime sprite exists when asset is present")
		if FileAccess.file_exists("res://assets/sprites/objects/obj06_archive_father_record.png"):
			var obj06 := main_scene.get_node_or_null("ClassroomRoot/Background/GeneratedModeAnchorProps/Obj06ArchiveFatherRecord")
			_assert(obj06 != null, "OBJ06 runtime sprite exists when asset is present")
		if FileAccess.file_exists("res://assets/sprites/objects/obj08_essay_fragment.png"):
			var obj08 := main_scene.get_node_or_null("ClassroomRoot/Background/GeneratedModeAnchorProps/Obj08EssayFragment")
			_assert(obj08 != null, "OBJ08 runtime sprite exists when asset is present")
	if main_scene.use_generated_blackboard_states:
		var blackboard_rough = main_scene.runtime_asset_sprites.get("blackboard_rough")
		_assert(blackboard_rough != null and blackboard_rough.visible, "generated rough blackboard visible initially")
	if main_scene.use_generated_memory_background:
		var memory_bg := main_scene.get_node_or_null("ClassroomRoot/MemoryOverlayRoot/OverlayFinalClassroom/GeneratedFinalMemoryBackground")
		_assert(memory_bg != null, "generated BG03 node exists when enabled")
	for id in controller.DEBUG_ORDER:
		var target = controller.call("_find_interactable_by_id", id)
		_assert(target != null, "%s interactable exists" % id)
		if target == null:
			continue
		_assert(game_state.can_interact(target.data), "%s can interact when reached in order" % id)
		controller.call("_apply_interaction", target.data)
		await process_frame
		_assert(game_state.is_completed(id), "%s marked completed" % id)
		var marker = controller.completion_markers.get(id)
		_assert(marker != null and marker.visible, "%s completion marker visible" % id)
		if target.data.get("photo_required", false):
			_assert(target.data.get("prompt", "").contains("拍") or id == "A5", "%s photo event prompt is photo-like" % id)
		if id == "A10" and main_scene.use_generated_blackboard_states:
			var blackboard_photo = main_scene.runtime_asset_sprites.get("blackboard_photo")
			_assert(blackboard_photo != null and blackboard_photo.visible, "generated photo blackboard visible after A10")
		if id == "A12" and main_scene.use_generated_blackboard_states:
			var blackboard_final = main_scene.runtime_asset_sprites.get("blackboard_final")
			_assert(blackboard_final != null and blackboard_final.visible, "generated final blackboard visible after A12")
	_validate_final_state(game_state, ending_card)
	if failures.is_empty():
		print("FLOW_SMOKE_TEST_OK")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _validate_final_state(game_state: Node, ending_card: Control) -> void:
	for flag in [
		"survey_started",
		"blackboard_surface_memory_seen",
		"school_closure_seen",
		"place_disturbance_seen",
		"paper_plane_emotion_seen",
		"father_record_seen",
		"window_crack_seen",
		"friend_paths_seen",
		"girl_memory_seen",
		"final_photo_ready",
		"ending_seen",
	]:
		_assert(game_state.has_flag(flag), "flag set: %s" % flag)
	for item in ["current_photo", "left_items", "wall_items", "structure_damage", "final_photo"]:
		_assert(game_state.survey_items.get(item, false), "survey item completed: %s" % item)
	_assert(ending_card.visible, "ending card visible after A12")
	_assert(Objectives.current_objective(game_state) == "测绘完成。最终照片已保存。", "final objective is closed")
	_assert(Interactions.INTERACTIONS["A5"].get("photo_required", false), "A5 triggers photo feedback")
	_assert(Interactions.INTERACTIONS["A10"].get("photo_required", false), "A10 triggers photo feedback")
	_assert(Interactions.INTERACTIONS["A12"].get("photo_required", false), "A12 triggers photo feedback")

func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
