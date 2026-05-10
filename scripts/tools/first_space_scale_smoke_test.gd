extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main_scene: Node = load("res://scenes/main.tscn").instantiate()
	main_scene.set_meta("skip_intro_for_qa", true)
	root.add_child(main_scene)
	await process_frame
	await process_frame
	var player: Node = main_scene.get_node("Player")
	var collision_root: Node = main_scene.get_node("ClassroomRoot/Collision")
	var anchor_props: Node = main_scene.get_node("ClassroomRoot/Background/GeneratedModeAnchorProps")
	_assert(player != null, "Player exists")
	_assert(collision_root != null, "collision root exists")
	_assert(anchor_props != null, "generated anchor props exist")
	_assert(int(player.get("visual_height_px")) == 56, "player visual height baseline is 56px")
	var generated_sprite := player.get_node_or_null("GeneratedPlayerSprite")
	if generated_sprite != null:
		_assert(not generated_sprite.centered, "generated player sprite uses foot-pivot top-left drawing")
		var visual_scale: float = float(generated_sprite.scale.y)
		_assert(absf(54.0 * visual_scale - 56.0) < 0.01, "generated player visible pixels scale to 56px")
		_assert(absf(generated_sprite.position.y + 59.0 * visual_scale) < 0.01, "generated player visible feet align to player origin")
		_assert(absf(generated_sprite.position.x + 24.0 * visual_scale) < 0.01, "generated player visible center aligns to player origin")
	for name in [
		"GeneratedBlackboardCollision",
		"GeneratedCabinetCollision",
		"GeneratedAwardCollision",
		"GeneratedClosureNoticeCollision",
		"GeneratedSchoolPlaqueCollision",
		"GeneratedWindowWallCollision",
	]:
		_assert(collision_root.get_node_or_null(name) != null, "%s exists" % name)
	for index in range(9):
		var desk := collision_root.get_node_or_null("GeneratedDeskCollision_%02d" % index)
		_assert(desk != null, "generated desk collision %02d exists" % index)
		if desk != null:
			_assert(_rect_size(desk) == Vector2(112, 44), "generated desk collision %02d uses 112x44 v0.2 double desk size" % index)
	_assert(_rect_size(collision_root.get_node("GeneratedBlackboardCollision")) == Vector2(322, 70), "blackboard collision blocks wall object")
	_assert(_rect_size(collision_root.get_node("GeneratedWindowWallCollision")) == Vector2(48, 302), "window wall collision blocks right wall")
	for name in ["Obj05GroundAttachment", "Obj06CabinetAttachment", "Obj08DeskAttachment"]:
		var attachment := anchor_props.get_node_or_null(name)
		_assert(attachment != null, "%s exists" % name)
		if attachment != null:
			_assert(attachment.get_node_or_null("ContactShadow") != null, "%s has contact shadow" % name)
	_assert(anchor_props.get_node_or_null("Obj08DeskAttachment/DrawerLip") != null, "essay fragment has drawer lip attachment")
	_assert(anchor_props.get_node_or_null("Obj05GroundAttachment/DeskLegHint") != null, "paper plane has desk leg attachment")
	_assert(anchor_props.get_node_or_null("Obj06CabinetAttachment/OpenRecordSurface") != null, "father record has cabinet support attachment")
	main_scene.queue_free()
	await process_frame
	if failures.is_empty():
		print("FIRST_SPACE_SCALE_SMOKE_TEST_OK")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _rect_size(body: Node) -> Vector2:
	if body == null:
		return Vector2.ZERO
	var shape_node: CollisionShape2D = body.get_node_or_null("CollisionShape2D")
	if shape_node == null or not (shape_node.shape is RectangleShape2D):
		return Vector2.ZERO
	var rectangle: RectangleShape2D = shape_node.shape
	return rectangle.size

func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
