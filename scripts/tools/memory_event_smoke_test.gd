extends SceneTree

const MemoryEvents = preload("res://data/memory_events.gd")

var failures: Array[String] = []
var finished_id := ""

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main_scene: Node = load("res://scenes/main.tscn").instantiate()
	main_scene.set_meta("skip_intro_for_qa", true)
	root.add_child(main_scene)
	await _wait_frames(8)
	var memory_player: Control = main_scene.get_node("UI/MemoryEventPlayer")
	var player: Node = main_scene.get_node("Player")
	var survey: Control = main_scene.get_node("UI/SurveyProgress")
	_assert(memory_player != null, "MemoryEventPlayer exists")
	if memory_player != null:
		memory_player.memory_event_finished.connect(func(event_id: String): finished_id = event_id)
		memory_player.call("play_event", "slice1_test", MemoryEvents.EVENTS["slice1_test"])
		await _wait_frames(8)
		_assert(bool(memory_player.get("is_playing")), "memory event reports playing state")
		_assert(bool(player.get("input_locked")), "memory event locks player input")
		_assert(float(survey.modulate.a) < 0.95, "memory event dims survey UI")
		_assert(memory_player.get_child_count() >= 2, "memory event spawns visual fragments")
		await memory_player.memory_event_finished
		_assert(finished_id == "slice1_test", "memory event emits finished callback")
		_assert(not bool(player.get("input_locked")), "memory event restores player input")
		_assert(not bool(memory_player.get("is_playing")), "memory event clears playing state")
		await process_frame
		_assert(memory_player.get_child_count() == 0, "memory event clears fragments")
		memory_player.call("play_event", "a8_father_record", MemoryEvents.EVENTS["a8_father_record"])
		await _wait_frames(8)
		_assert(bool(player.get("input_locked")), "A8 memory event locks player input")
		_assert(memory_player.get_child_count() >= 4, "A8 memory event spawns layered roster and motorcycle fragments")
		await memory_player.memory_event_finished
		await process_frame
		_assert(not bool(player.get("input_locked")), "A8 memory event restores player input")
	main_scene.queue_free()
	await process_frame
	if failures.is_empty():
		print("MEMORY_EVENT_SMOKE_TEST_OK")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _wait_frames(count: int) -> void:
	for _i in range(count):
		await process_frame

func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
