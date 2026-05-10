extends SceneTree

const Dialogues = preload("res://data/dialogues.gd")
const Portraits = preload("res://data/portraits.gd")

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
	var dialogue_box: Control = main_scene.get_node("UI/DialogueBox")
	_assert(game_state != null, "GameState exists")
	_assert(dialogue_box != null, "DialogueBox exists")
	for portrait_id in ["protagonist", "father", "mother", "girl"]:
		var config := Portraits.get_portrait(portrait_id)
		_assert(not config.is_empty(), "%s portrait config exists" % portrait_id)
		_assert(not str(config.get("fallback_initial", "")).is_empty(), "%s fallback initial exists" % portrait_id)
		var image_path := str(config.get("path", ""))
		if not image_path.is_empty():
			_assert(ResourceLoader.exists(image_path), "%s portrait path exists" % portrait_id)
	_validate_dialogue_ids()
	dialogue_box.call("play", "a1_survey_form", game_state)
	await process_frame
	_assert(not dialogue_box.get_node("Panel/PortraitPanel").visible, "system line keeps portrait hidden")
	dialogue_box.call("advance")
	await process_frame
	dialogue_box.call("advance")
	await process_frame
	var portrait_panel: Control = dialogue_box.get_node("Panel/PortraitPanel")
	var portrait_label: Label = dialogue_box.get_node("Panel/PortraitPanel/PortraitLabel")
	_assert(portrait_panel.visible, "protagonist line shows portrait panel")
	_assert(portrait_label.text == "李", "protagonist fallback initial is used")
	if failures.is_empty():
		print("PORTRAIT_CONFIG_SMOKE_TEST_OK")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _validate_dialogue_ids() -> void:
	for dialogue_id in Dialogues.DIALOGUES.keys():
		for line in Dialogues.DIALOGUES[dialogue_id]:
			var portrait_id := str(line.get("portrait_id", ""))
			if not portrait_id.is_empty():
				_assert(not Portraits.get_portrait(portrait_id).is_empty(), "%s uses configured portrait %s" % [dialogue_id, portrait_id])

func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
