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
	var settings_menu: Control = main_scene.get_node("UI/SettingsMenu")
	var player: Node = main_scene.get_node("Player")
	var controller: Node = main_scene.get_node("InteractionController")
	_assert(settings_menu != null, "SettingsMenu exists")
	_assert(settings_menu.visible == false, "settings menu starts hidden")
	settings_menu.call("open_menu")
	await process_frame
	_assert(settings_menu.visible, "settings menu opens")
	_assert(bool(settings_menu.get("is_open")), "settings menu open state is true")
	_assert(controller.input_locked, "settings menu locks interaction input")
	_assert(player.input_locked, "settings menu locks player input")
	var slider: HSlider = settings_menu.get_node("Panel/VolumeSlider")
	_assert(slider != null, "volume slider exists")
	slider.value = 0.5
	await process_frame
	var master_db := AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	_assert(master_db < -5.0 and master_db > -7.0, "volume slider updates master bus")
	settings_menu.call("close_menu")
	await process_frame
	_assert(not settings_menu.visible, "settings menu closes")
	_assert(not bool(settings_menu.get("is_open")), "settings menu open state is false")
	_assert(not controller.input_locked, "settings menu unlocks interaction input")
	_assert(not player.input_locked, "settings menu unlocks player input")
	if failures.is_empty():
		print("SETTINGS_MENU_SMOKE_TEST_OK")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
