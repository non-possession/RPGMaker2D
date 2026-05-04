extends Node

const Names = preload("res://data/names.gd")

signal flag_changed(flag: String)
signal survey_changed()

var flags: Dictionary = {}
var completed_interactions: Dictionary = {}
var survey_items: Dictionary = {}

func _ready() -> void:
	for key in ["current_photo", "left_items", "wall_items", "structure_damage", "final_photo"]:
		survey_items[key] = false

func has_flag(flag: String) -> bool:
	return flags.get(flag, false)

func set_flag(flag: String) -> void:
	if flag.is_empty() or has_flag(flag):
		return
	flags[flag] = true
	flag_changed.emit(flag)

func set_flags(next_flags: Array) -> void:
	for flag in next_flags:
		set_flag(str(flag))

func can_interact(data: Dictionary) -> bool:
	if data.get("one_shot", true) and completed_interactions.get(data.get("id", ""), false):
		return false
	for flag in data.get("required_flags", []):
		if not has_flag(str(flag)):
			return false
	return true

func mark_completed(id: String) -> void:
	completed_interactions[id] = true

func is_completed(id: String) -> bool:
	return completed_interactions.get(id, false)

func complete_survey_items(items: Array) -> void:
	var changed := false
	for item in items:
		var key := str(item)
		if survey_items.has(key) and not survey_items[key]:
			survey_items[key] = true
			changed = true
	if changed:
		survey_changed.emit()

func format_text(text: String) -> String:
	var result := text
	for key in Names.NAMES.keys():
		result = result.replace("{" + key + "}", str(Names.NAMES[key]))
	return result
