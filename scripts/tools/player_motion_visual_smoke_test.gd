extends SceneTree

const OUT_DIR := "res://docs/qa/screenshots"

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var main_scene: Node = load("res://scenes/main.tscn").instantiate()
	main_scene.set_meta("skip_intro_for_qa", true)
	root.add_child(main_scene)
	await _wait_frames(8)
	var player: Node = main_scene.get_node("Player")
	var generated_sprite: Sprite2D = player.get_node_or_null("GeneratedPlayerSprite")
	_assert(generated_sprite != null, "generated player sprite exists")
	if generated_sprite != null:
		var baseline_position := generated_sprite.position
		var baseline_scale := generated_sprite.scale
		var baseline_centered := generated_sprite.centered
		var frame_metrics := []
		for direction in [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2.UP]:
			player.set("last_direction", direction)
			for moving in [false, true]:
				player.call("_update_generated_sprite", moving)
				frame_metrics.append({
					"direction": direction,
					"moving": moving,
					"frame": generated_sprite.frame,
					"position": generated_sprite.position,
					"scale": generated_sprite.scale,
					"centered": generated_sprite.centered,
				})
		for item in frame_metrics:
			_assert(item["position"] == baseline_position, "generated sprite position is stable across frames")
			_assert(item["scale"] == baseline_scale, "generated sprite scale is stable across frames")
			_assert(item["centered"] == baseline_centered, "generated sprite centered flag is stable across frames")
	player.global_position = Vector2(438, 300)
	await _wait_frames(4)
	await _save_viewport("player_motion_baseline_v0_2.png")
	main_scene.queue_free()
	await process_frame
	if failures.is_empty():
		print("PLAYER_MOTION_VISUAL_SMOKE_TEST_OK")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _save_viewport(filename: String) -> void:
	if DisplayServer.get_name() == "headless":
		print("PLAYER_MOTION_SCREENSHOT_SKIPPED headless display: %s" % filename)
		return
	var texture := root.get_viewport().get_texture()
	if texture == null:
		print("PLAYER_MOTION_SCREENSHOT_SKIPPED texture unavailable: %s" % filename)
		return
	var image := texture.get_image()
	if image == null:
		print("PLAYER_MOTION_SCREENSHOT_SKIPPED viewport image unavailable: %s" % filename)
		return
	var output_path := "%s/%s" % [OUT_DIR, filename]
	var err := image.save_png(output_path)
	if err != OK:
		print("PLAYER_MOTION_SCREENSHOT_SKIPPED failed to save: %s" % output_path)

func _wait_frames(count: int) -> void:
	for _i in range(count):
		await process_frame

func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
