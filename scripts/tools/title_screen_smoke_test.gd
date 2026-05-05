extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var title_scene: Node = load("res://scenes/title_screen.tscn").instantiate()
	root.add_child(title_scene)
	await process_frame
	await process_frame
	_assert(title_scene.get_node_or_null("TitleContent") != null, "title content exists")
	_assert(title_scene.get_node_or_null("TitleContent/Title") != null, "title label exists")
	_assert(title_scene.get_node_or_null("TitleContent/StartHint") != null, "start hint exists")
	_assert(ProjectSettings.get_setting("application/run/main_scene") == "res://scenes/title_screen.tscn", "project starts at title screen")
	title_scene.queue_free()
	if failures.is_empty():
		print("TITLE_SCREEN_SMOKE_TEST_OK")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
