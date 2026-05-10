extends SceneTree

const OUT_DIR := "res://docs/qa/screenshots/player_motion_v0_2"

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(960, 540))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var main_scene: Node = load("res://scenes/main.tscn").instantiate()
	main_scene.set_meta("skip_intro_for_qa", true)
	root.add_child(main_scene)
	await _wait_frames(12)
	var player: Node = main_scene.get_node("Player")
	var generated_sprite: Sprite2D = player.get_node_or_null("GeneratedPlayerSprite")
	_assert(generated_sprite != null, "generated player sprite exists")
	player.global_position = Vector2(438, 300)
	player.set("input_locked", true)
	player.set_physics_process(false)
	if generated_sprite != null:
		await _capture_pose(player, generated_sprite, "down_idle", 0, 0)
		for i in range(8):
			await _capture_pose(player, generated_sprite, "right_walk_%02d" % i, 2, 1 + (i % 2))
		for i in range(8):
			await _capture_pose(player, generated_sprite, "left_walk_%02d" % i, 1, 1 + (i % 2))
		for i in range(8):
			await _capture_pose(player, generated_sprite, "up_walk_%02d" % i, 3, 1 + (i % 2))
		await _capture_motion(player, "right_motion", Vector2.RIGHT, 72)
	main_scene.queue_free()
	await _wait_frames(3)
	if failures.is_empty():
		print("PLAYER_MOTION_FRAME_CAPTURE_OK")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _capture_pose(player: Node, generated_sprite: Sprite2D, filename: String, row: int, col: int) -> void:
	generated_sprite.frame = row * generated_sprite.hframes + col
	await _wait_frames(2)
	await RenderingServer.frame_post_draw
	await _save_viewport("%s.png" % filename)
	print("%s frame=%s pos=%s scale=%s" % [filename, generated_sprite.frame, generated_sprite.position, generated_sprite.scale])

func _capture_motion(player: Node, prefix: String, direction: Vector2, frame_count: int) -> void:
	player.global_position = Vector2(360, 300)
	var delta := 1.0 / 60.0
	for i in range(frame_count):
		player.global_position += direction * player.get("speed") * delta
		player.global_position = player.global_position.round()
		player.set("last_direction", direction)
		player.set("walk_time", float(i) * delta)
		player.call("_update_generated_sprite", true)
		await _wait_frames(1)
		await RenderingServer.frame_post_draw
		await _save_viewport("%s_%02d.png" % [prefix, i])
		var sprite: Sprite2D = player.get_node("GeneratedPlayerSprite")
		print("%s_%02d global=%s frame=%s pos=%s scale=%s" % [prefix, i, player.global_position, sprite.frame, sprite.position, sprite.scale])

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

func _wait_frames(count: int) -> void:
	for _i in range(count):
		await process_frame

func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
