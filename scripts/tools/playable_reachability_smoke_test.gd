extends SceneTree

var failures: Array[String] = []
var main_scene: Node
var game_state: Node
var controller: Node
var player: Node
var dialogue_box: Control

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
	_assert(game_state != null, "GameState exists")
	_assert(controller != null, "InteractionController exists")
	_assert(player != null, "Player exists")
	_assert(dialogue_box != null, "DialogueBox exists")

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
	_assert(game_state.can_interact(target.data), "%s is open before playable trigger" % id)
	player.global_position = target.global_position
	await _wait_physics_frames(8)
	await _wait_frames(2)
	var current = controller.call("_current_interactable")
	_assert(current == target, "%s becomes focused at playable approach position, got %s" % [id, _interactable_id(current)])
	if current != target:
		return
	controller.call("_trigger", current)
	await _advance_dialogue_until_completed(id)
	_assert(game_state.is_completed(id), "%s completed via playable trigger" % id)
	_assert(not bool(controller.input_locked), "%s unlocks input after dialogue" % id)
	_assert(not bool(player.input_locked), "%s unlocks player after dialogue" % id)

func _advance_dialogue_until_completed(id: String) -> void:
	var guard := 0
	while guard < 180 and not dialogue_box.is_playing:
		await process_frame
		guard += 1
	_assert(dialogue_box.is_playing, "%s starts dialogue after trigger" % id)
	while guard < 260 and dialogue_box.is_playing:
		dialogue_box.advance()
		await _wait_frames(2)
		guard += 1
	await _wait_frames(8)
	_assert(guard < 260, "%s dialogue completes without timeout" % id)

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

func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
