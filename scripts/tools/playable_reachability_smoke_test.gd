extends SceneTree

const Objectives = preload("res://data/objectives.gd")

const EXPECTED_OBJECTIVES := {
	"A1": "查看讲台上的测绘表。",
	"A2": "完成第一批测绘：黑板、课桌、奖状、撤并通知。",
	"A3": "完成第一批测绘：黑板、课桌、奖状、撤并通知。",
	"A4": "完成第一批测绘：黑板、课桌、奖状、撤并通知。",
	"A5": "完成第一批测绘：黑板、课桌、奖状、撤并通知。",
	"A6": "调查右侧墙上的旧地图/校名牌。",
	"A7": "查看左下角的纸飞机和断铅笔。",
	"A8": "检查左侧档案柜里的旧记录。",
	"A9": "登记右侧窗边墙体裂缝。",
	"A10": "回到黑板，拍照复查字迹。",
	"A11": "查看中排课桌里的作文本碎页。",
	"A12": "在教室中央拍摄最终现状。",
}

var failures: Array[String] = []
var main_scene: Node
var game_state: Node
var controller: Node
var player: Node
var dialogue_box: Control
var interaction_prompt: Control

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	main_scene = load("res://scenes/main.tscn").instantiate()
	main_scene.set_meta("skip_intro_for_qa", true)
	root.add_child(main_scene)
	await _wait_frames(8)
	game_state = main_scene.get_node("GameState")
	controller = main_scene.get_node("InteractionController")
	player = main_scene.get_node("Player")
	dialogue_box = main_scene.get_node("UI/DialogueBox")
	interaction_prompt = main_scene.get_node("UI/InteractionPrompt")
	_assert(game_state != null, "GameState exists")
	_assert(controller != null, "InteractionController exists")
	_assert(player != null, "Player exists")
	_assert(dialogue_box != null, "DialogueBox exists")
	_assert(interaction_prompt != null, "InteractionPrompt exists")

	for id in controller.DEBUG_ORDER:
		await _complete_by_playable_trigger(id)

	var ending_card: Control = main_scene.get_node("UI/EndingCard")
	_assert(ending_card != null and ending_card.visible, "ending card visible after playable route")
	_assert(game_state.has_flag("ending_seen"), "ending flag set after playable route")
	_cleanup_scene()
	await _wait_frames(4)

	if failures.is_empty():
		print("PLAYABLE_REACHABILITY_SMOKE_TEST_OK")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _complete_by_playable_trigger(id: String) -> void:
	var target = controller.call("_find_interactable_by_id", id)
	_assert(target != null, "%s interactable exists" % id)
	if target == null:
		return
	_assert(Objectives.current_objective(game_state) == EXPECTED_OBJECTIVES[id], "%s objective points to current task" % id)
	_assert(game_state.can_interact(target.data), "%s is open before playable trigger" % id)
	player.global_position = target.data.get("approach_position", target.global_position)
	await _wait_physics_frames(8)
	await _wait_frames(2)
	var current = controller.call("_current_interactable")
	_assert(current == target, "%s becomes focused at playable approach position, got %s" % [id, _interactable_id(current)])
	_assert(interaction_prompt.visible, "%s shows interaction prompt when focused" % id)
	_assert(_prompt_text_contains(target.data), "%s prompt names its target" % id)
	_assert(_prompt_text_fits(), "%s prompt text fits the prompt box" % id)
	if current != target:
		return
	controller.call("_trigger", current)
	await _advance_dialogue_until_completed(id)
	_assert(game_state.is_completed(id), "%s completed via playable trigger" % id)
	_assert(not bool(controller.input_locked), "%s unlocks input after dialogue" % id)
	_assert(not bool(player.input_locked), "%s unlocks player after dialogue" % id)
	if id == "A12":
		_assert(Objectives.current_objective(game_state) == "测绘完成。最终照片已保存。", "final objective is closed after playable route")

func _advance_dialogue_until_completed(id: String) -> void:
	var guard := 0
	while guard < 360 and not dialogue_box.is_playing:
		await process_frame
		guard += 1
	_assert(dialogue_box.is_playing, "%s starts dialogue after trigger" % id)
	while guard < 560 and dialogue_box.is_playing:
		dialogue_box.advance()
		await _wait_frames(2)
		guard += 1
	await _wait_frames(8)
	_assert(guard < 560, "%s dialogue completes without timeout" % id)

func _cleanup_scene() -> void:
	if main_scene == null:
		return
	var audio := main_scene.get_node_or_null("AudioController")
	if audio != null:
		audio.set("audio_enabled", false)
		for child in audio.get_children():
			if child is AudioStreamPlayer:
				child.stop()
				child.stream = null
	for tween in get_processed_tweens():
		tween.kill()
	main_scene.queue_free()

func _wait_frames(count: int) -> void:
	for _i in range(count):
		await process_frame

func _wait_physics_frames(count: int) -> void:
	for _i in range(count):
		await physics_frame

func _interactable_id(item) -> String:
	if item == null:
		return "-"
	return str(item.data.get("id", "?"))

func _prompt_text_contains(data: Dictionary) -> bool:
	if interaction_prompt == null:
		return false
	var label_node: Label = interaction_prompt.get("label")
	if label_node == null:
		return false
	var label_text := label_node.text
	return label_text.contains(str(data.get("prompt", ""))) and label_text.contains(str(data.get("label", "")))

func _prompt_text_fits() -> bool:
	var label_node: Label = interaction_prompt.get("label")
	if label_node == null:
		return false
	var font := label_node.get_theme_font("font")
	var font_size := label_node.get_theme_font_size("font_size")
	var text_width := font.get_string_size(label_node.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	return text_width <= label_node.size.x

func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
