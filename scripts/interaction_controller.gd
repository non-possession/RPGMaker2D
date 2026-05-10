extends Node

const MemoryEvents = preload("res://data/memory_events.gd")

var game_state: Node
var dialogue_box: Control
var interaction_prompt: Control
var survey_progress: Control
var photo_flash: Control
var memory_event_player: Control
var ui_toast: Control
var ending_card: Control
var audio_controller: Node
var player: Node
var overlays: Dictionary = {}
var completion_markers: Dictionary = {}
var runtime_asset_sprites: Dictionary = {}
var nearby: Array[Area2D] = []
var input_locked := false
var focused_interactable: Area2D
const DEBUG_ORDER := ["A1", "A2", "A3", "A4", "A5", "A6", "A7", "A8", "A9", "A10", "A11", "A12"]

func setup(deps: Dictionary) -> void:
	game_state = deps["game_state"]
	dialogue_box = deps["dialogue_box"]
	interaction_prompt = deps["interaction_prompt"]
	survey_progress = deps["survey_progress"]
	photo_flash = deps["photo_flash"]
	memory_event_player = deps.get("memory_event_player", null)
	ui_toast = deps["ui_toast"]
	ending_card = deps["ending_card"]
	audio_controller = deps.get("audio_controller", null)
	player = deps["player"]
	overlays = deps.get("overlays", {})
	completion_markers = deps.get("completion_markers", {})
	runtime_asset_sprites = deps.get("runtime_asset_sprites", {})
	game_state.flag_changed.connect(_on_state_changed)
	game_state.survey_changed.connect(_on_survey_changed)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	survey_progress.setup(game_state)

func register_interactable(interactable: Area2D) -> void:
	interactable.player_entered.connect(_on_interactable_entered)
	interactable.player_exited.connect(_on_interactable_exited)

func _process(_delta: float) -> void:
	_update_prompt()
	if input_locked or dialogue_box.is_playing:
		return
	if Input.is_action_just_pressed("interact"):
		var current := _current_interactable()
		if current != null and game_state.can_interact(current.data):
			_trigger(current)

func _current_interactable() -> Area2D:
	return _nearest_interactable(true)

func _nearest_interactable(require_open: bool) -> Area2D:
	var best: Area2D = null
	var best_distance := INF
	for item in nearby:
		if not is_instance_valid(item):
			continue
		if game_state.is_completed(str(item.data.get("id", ""))):
			continue
		var is_open: bool = game_state.can_interact(item.data)
		if require_open and not is_open:
			continue
		if not require_open and is_open:
			continue
		var distance: float = player.global_position.distance_to(item.global_position)
		if distance < best_distance:
			best_distance = distance
			best = item
	return best

func _trigger(interactable: Area2D) -> void:
	input_locked = true
	player.set_input_locked(true)
	var data: Dictionary = interactable.data
	_run_interaction_sequence(data)

func _run_interaction_sequence(data: Dictionary) -> void:
	var overlay_id := str(data.get("overlay_id", ""))
	if data.get("photo_required", false) or not overlay_id.is_empty():
		_set_cinematic_focus(true)
	if audio_controller != null and audio_controller.has_method("play_interaction"):
		audio_controller.call("play_interaction", str(data.get("id", "")), data)
	if data.get("photo_required", false):
		photo_flash.play_flash("测绘照片记录")
		await get_tree().create_timer(0.58).timeout
	else:
		await get_tree().create_timer(_pre_dialogue_pause(data)).timeout
	await _play_memory_event(str(data.get("memory_event_id", "")))
	_play_overlay(overlay_id)
	if not overlay_id.is_empty():
		await get_tree().create_timer(0.16).timeout
	dialogue_box.play(str(data.get("dialogue_id", "")), game_state)

func _pre_dialogue_pause(data: Dictionary) -> float:
	match str(data.get("id", "")):
		"A7", "A8", "A11":
			return 0.24
		"A12":
			return 0.42
		_:
			return 0.08

func _play_memory_event(memory_event_id: String) -> void:
	if memory_event_id.is_empty() or memory_event_player == null:
		return
	if not MemoryEvents.EVENTS.has(memory_event_id):
		return
	memory_event_player.call("play_event", memory_event_id, MemoryEvents.EVENTS[memory_event_id], {"manage_input": false})
	await memory_event_player.memory_event_finished

func _finish_interaction(dialogue_id: String) -> void:
	for item in nearby:
		if is_instance_valid(item) and item.data.get("dialogue_id", "") == dialogue_id:
			_apply_interaction(item.data)
			break

func _apply_interaction(data: Dictionary) -> void:
	game_state.set_flags(data.get("set_flags", []))
	game_state.complete_survey_items(data.get("survey_items", []))
	game_state.mark_completed(str(data.get("id", "")))
	_show_completion_marker(str(data.get("id", "")))
	if audio_controller != null and audio_controller.has_method("play_completion"):
		audio_controller.call("play_completion", str(data.get("id", "")))
	_update_runtime_asset_state(str(data.get("id", "")))
	if ui_toast != null:
		ui_toast.show_toast("已记录：%s" % data.get("label", "调查点"))
	if str(data.get("id", "")) == "A12" and ending_card != null:
		ending_card.show_card()
	_set_cinematic_focus(false)
	for item in get_tree().get_nodes_in_group("interactables"):
		item.queue_redraw()
	input_locked = false
	player.set_input_locked(false)
	_update_prompt()

func _play_overlay(overlay_id: String) -> void:
	if overlay_id.is_empty() or not overlays.has(overlay_id):
		return
	var overlay = overlays[overlay_id]
	overlay.visible = true
	overlay.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.28)
	tween.tween_interval(1.45)
	if overlay_id != "overlay_final_classroom":
		tween.tween_property(overlay, "modulate:a", 0.0, 0.9)

func _show_completion_marker(id: String) -> void:
	if not completion_markers.has(id):
		return
	var marker = completion_markers[id]
	if marker == null:
		return
	marker.visible = true
	marker.modulate.a = 0.0
	marker.scale = Vector2(0.9, 0.9)
	var tween := create_tween()
	tween.tween_property(marker, "modulate:a", 1.0, 0.18)
	tween.parallel().tween_property(marker, "scale", Vector2.ONE, 0.18)

func _update_runtime_asset_state(id: String) -> void:
	match id:
		"A10":
			_show_single_runtime_asset(["blackboard_rough", "blackboard_photo", "blackboard_final"], "blackboard_photo")
		"A12":
			_show_single_runtime_asset(["blackboard_rough", "blackboard_photo", "blackboard_final"], "blackboard_final")

func _show_single_runtime_asset(keys: Array[String], active_key: String) -> void:
	for key in keys:
		if not runtime_asset_sprites.has(key):
			continue
		var sprite = runtime_asset_sprites[key]
		if sprite != null and is_instance_valid(sprite):
			sprite.visible = key == active_key

func _set_cinematic_focus(active: bool) -> void:
	if survey_progress != null and survey_progress.has_method("set_cinematic_focus"):
		survey_progress.call("set_cinematic_focus", active)

func _update_prompt() -> void:
	var current := _current_interactable()
	if input_locked or dialogue_box.is_playing:
		_set_focused_interactable(null)
		interaction_prompt.hide_prompt()
		return
	if current != null:
		_set_focused_interactable(current)
		interaction_prompt.show_prompt(_prompt_text_for(current.data), true)
		return
	var locked := _nearest_interactable(false)
	if locked != null:
		_set_focused_interactable(null)
		var disabled_prompt := str(locked.data.get("disabled_prompt", ""))
		if not disabled_prompt.is_empty():
			interaction_prompt.show_prompt(disabled_prompt, false)
			return
	_set_focused_interactable(null)
	interaction_prompt.hide_prompt()

func _prompt_text_for(data: Dictionary) -> String:
	var action := str(data.get("prompt", "调查"))
	var label := str(data.get("label", ""))
	if label.is_empty() or action.contains(label):
		return action
	return "%s：%s" % [action, label]

func _set_focused_interactable(next_interactable: Area2D) -> void:
	if focused_interactable == next_interactable:
		return
	if is_instance_valid(focused_interactable) and focused_interactable.has_method("set_focus_visible"):
		focused_interactable.call("set_focus_visible", false)
	focused_interactable = next_interactable
	if is_instance_valid(focused_interactable) and focused_interactable.has_method("set_focus_visible"):
		focused_interactable.call("set_focus_visible", true)

func _on_interactable_entered(interactable: Area2D) -> void:
	if not nearby.has(interactable):
		nearby.append(interactable)

func _on_interactable_exited(interactable: Area2D) -> void:
	nearby.erase(interactable)
	if focused_interactable == interactable:
		_set_focused_interactable(null)

func _on_dialogue_finished(dialogue_id: String) -> void:
	_finish_interaction(dialogue_id)

func _on_state_changed(_flag: String) -> void:
	_update_prompt()
	survey_progress.refresh()

func _on_survey_changed() -> void:
	survey_progress.refresh()

func debug_current_label() -> String:
	var current := _current_interactable()
	if current == null:
		return "-"
	return "%s %s" % [current.data.get("id", "?"), current.data.get("label", "?")]

func debug_nearby_labels() -> Array[String]:
	var labels: Array[String] = []
	for item in nearby:
		if is_instance_valid(item):
			labels.append("%s:%s" % [item.data.get("id", "?"), "open" if game_state.can_interact(item.data) else "locked"])
	return labels

func debug_complete_next() -> void:
	for id in DEBUG_ORDER:
		if not game_state.is_completed(id):
			var target := _find_interactable_by_id(id)
			if target != null:
				_apply_interaction(target.data)
			return

func debug_teleport_next() -> void:
	var fallback: Area2D = null
	for id in DEBUG_ORDER:
		if game_state.is_completed(id):
			continue
		var target := _find_interactable_by_id(id)
		if target == null:
			continue
		if fallback == null:
			fallback = target
		if game_state.can_interact(target.data):
			_teleport_player_near(target)
			return
	if fallback != null:
		_teleport_player_near(fallback)

func debug_next_pending_label() -> String:
	for id in DEBUG_ORDER:
		if not game_state.is_completed(id):
			var target := _find_interactable_by_id(id)
			if target != null:
				var state := "open" if game_state.can_interact(target.data) else "locked"
				return "%s %s (%s)" % [id, target.data.get("label", "?"), state]
	return "done"

func _find_interactable_by_id(id: String) -> Area2D:
	for item in get_tree().get_nodes_in_group("interactables"):
		if is_instance_valid(item) and item.data.get("id", "") == id:
			return item
	return null

func _teleport_player_near(target: Area2D) -> void:
	player.global_position = target.data.get("approach_position", target.global_position)
	nearby.clear()
	_update_prompt()
