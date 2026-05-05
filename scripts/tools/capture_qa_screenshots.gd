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
		await _capture_a2_overlay("a2_overlay_%s.png" % suffix)
		await _capture_a5_photo("a5_photo_%s.png" % suffix)
		await _capture_a12_final("a12_final_%s.png" % suffix)
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

func _capture_a2_overlay(filename: String) -> void:
	var scene: Node = await _instantiate_main_for_capture()
	var controller: Node = scene.get_node("InteractionController")
	var dialogue_box: Control = scene.get_node("UI/DialogueBox")
	dialogue_box.visible = false
	dialogue_box.is_playing = false
	var a1 = controller.call("_find_interactable_by_id", "A1")
	var a2 = controller.call("_find_interactable_by_id", "A2")
	controller.call("_apply_interaction", a1.data)
	await process_frame
	controller.call("_trigger", a2)
	await create_timer(0.22).timeout
	await _save_viewport(filename)
	await create_timer(2.4).timeout
	_cleanup_capture_scene(scene)
	scene.queue_free()
	await process_frame

func _capture_a5_photo(filename: String) -> void:
	var scene: Node = await _instantiate_main_for_capture()
	var controller: Node = scene.get_node("InteractionController")
	var dialogue_box: Control = scene.get_node("UI/DialogueBox")
	dialogue_box.visible = false
	dialogue_box.is_playing = false
	var a1 = controller.call("_find_interactable_by_id", "A1")
	var a5 = controller.call("_find_interactable_by_id", "A5")
	controller.call("_apply_interaction", a1.data)
	await process_frame
	controller.call("_trigger", a5)
	await create_timer(0.36).timeout
	await _save_viewport(filename)
	await create_timer(0.8).timeout
	_cleanup_capture_scene(scene)
	scene.queue_free()
	await process_frame

func _capture_a12_final(filename: String) -> void:
	var scene: Node = await _instantiate_main_for_capture()
	var controller: Node = scene.get_node("InteractionController")
	var dialogue_box: Control = scene.get_node("UI/DialogueBox")
	dialogue_box.visible = false
	dialogue_box.is_playing = false
	for id in ["A1", "A2", "A3", "A4", "A5", "A6", "A7", "A8", "A9", "A10", "A11"]:
		var target = controller.call("_find_interactable_by_id", id)
		controller.call("_apply_interaction", target.data)
		await process_frame
	var a12 = controller.call("_find_interactable_by_id", "A12")
	controller.call("_trigger", a12)
	await create_timer(0.9).timeout
	await _save_viewport(filename)
	await create_timer(2.8).timeout
	_cleanup_capture_scene(scene)
	scene.queue_free()
	await process_frame

func _instantiate_main_for_capture() -> Node:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	for _i in range(12):
		await process_frame
	_mute_capture_audio(scene)
	return scene

func _mute_capture_audio(scene: Node) -> void:
	var audio := scene.get_node_or_null("AudioController")
	if audio == null:
		return
	audio.set("audio_enabled", false)
	for child in audio.get_children():
		if child is AudioStreamPlayer:
			child.stop()
			child.stream = null

func _cleanup_capture_scene(scene: Node) -> void:
	_mute_capture_audio(scene)
	for tween in get_processed_tweens():
		tween.kill()

func _save_viewport(filename: String) -> void:
	var texture := root.get_viewport().get_texture()
	if texture == null:
		failures.append("viewport texture unavailable: %s" % filename)
		return
	var image := texture.get_image()
	if image == null:
		failures.append("viewport image unavailable: %s" % filename)
		return
	var output_path := "%s/%s" % [OUT_DIR, filename]
	var err := image.save_png(output_path)
	if err != OK:
		failures.append("failed to save screenshot: %s" % output_path)
