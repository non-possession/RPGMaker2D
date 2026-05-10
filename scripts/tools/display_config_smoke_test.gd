extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_assert(ProjectSettings.get_setting("display/window/size/viewport_width") == 960, "viewport width stays 960")
	_assert(ProjectSettings.get_setting("display/window/size/viewport_height") == 540, "viewport height stays 540")
	_assert(ProjectSettings.get_setting("display/window/size/mode") == 3, "window starts fullscreen")
	_assert(ProjectSettings.get_setting("display/window/stretch/mode") == "canvas_items", "stretch mode uses canvas_items")
	_assert(ProjectSettings.get_setting("display/window/stretch/aspect") == "keep", "stretch aspect preserves 16:9")
	_assert(ProjectSettings.get_setting("rendering/2d/snap/snap_2d_transforms_to_pixel") == true, "2D transforms snap to pixels")
	_assert(ProjectSettings.get_setting("rendering/2d/snap/snap_2d_vertices_to_pixel") == true, "2D vertices snap to pixels")
	if failures.is_empty():
		print("DISPLAY_CONFIG_SMOKE_TEST_OK")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
