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
	var game_state: Node = main_scene.get_node("GameState")
	var controller: Node = main_scene.get_node("InteractionController")
	var flash: Control = main_scene.get_node("UI/PhotoFlash")
	var survey: Control = main_scene.get_node("UI/SurveyProgress")
	_assert(controller != null, "InteractionController exists")
	_assert(flash != null, "PhotoFlash exists")
	_assert(survey != null, "SurveyProgress exists")

	var a1 = controller.call("_find_interactable_by_id", "A1")
	var a2 = controller.call("_find_interactable_by_id", "A2")
	var a5 = controller.call("_find_interactable_by_id", "A5")
	_assert(a1 != null and a2 != null and a5 != null, "feedback test interactables exist")
	controller.call("_apply_interaction", a1.data)
	await process_frame

	controller.call("_trigger", a2)
	await create_timer(0.12).timeout
	var blackboard_overlay = controller.overlays.get("overlay_blackboard_surface")
	_assert(blackboard_overlay != null and blackboard_overlay.visible, "overlay becomes visible on real trigger")
	_assert(float(blackboard_overlay.modulate.a) > 0.0, "overlay fades in on real trigger")
	_assert(float(survey.modulate.a) < 0.95, "survey panel dims during overlay feedback")
	controller.call("_apply_interaction", a2.data)
	await create_timer(0.24).timeout
	_assert(float(survey.modulate.a) > 0.95, "survey panel restores after overlay interaction")

	controller.call("_trigger", a5)
	await create_timer(0.18).timeout
	var viewfinder := flash.get_node_or_null("Viewfinder")
	var flash_rect := flash.get_node_or_null("Flash")
	_assert(viewfinder != null and viewfinder.visible, "photo viewfinder visible on real trigger")
	_assert(viewfinder != null and float(viewfinder.modulate.a) > 0.0, "photo viewfinder fades in")
	_assert(flash_rect != null, "photo flash rect exists")
	_assert(float(survey.modulate.a) < 0.95, "survey panel dims during photo feedback")
	await create_timer(1.2).timeout
	main_scene.queue_free()
	await process_frame

	if failures.is_empty():
		print("VISUAL_FEEDBACK_SMOKE_TEST_OK")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
