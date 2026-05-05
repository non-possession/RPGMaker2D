extends SceneTree

const OUT_DIR := "res://docs/qa/screenshots"
const CAPTURE_SIZES := [
	{"suffix": "default_960x540", "size": Vector2i(960, 540)},
	{"suffix": "wide_1280x540", "size": Vector2i(1280, 540)},
]

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	for item in CAPTURE_SIZES:
		var suffix := str(item["suffix"])
		var size: Vector2i = item["size"]
		root.size = size
		await process_frame
		await _capture_scene("res://scenes/title_screen.tscn", "title_screen_%s.png" % suffix, 6)
		await _capture_scene("res://scenes/main.tscn", "main_intro_%s.png" % suffix, 12)
	if failures.is_empty():
		print("QA_SCREENSHOT_CAPTURE_OK")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _capture_scene(scene_path: String, filename: String, frames: int) -> void:
	var scene: Node = load(scene_path).instantiate()
	root.add_child(scene)
	for _i in range(frames):
		await process_frame
	var texture := root.get_viewport().get_texture()
	if texture == null:
		failures.append("viewport texture unavailable: %s" % scene_path)
		scene.queue_free()
		await process_frame
		return
	var image := texture.get_image()
	if image == null:
		failures.append("viewport image unavailable: %s" % scene_path)
		scene.queue_free()
		await process_frame
		return
	var output_path := "%s/%s" % [OUT_DIR, filename]
	var err := image.save_png(output_path)
	if err != OK:
		failures.append("failed to save screenshot: %s" % output_path)
	scene.queue_free()
	await process_frame
