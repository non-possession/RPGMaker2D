extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	for path in [
		"res://docs/design/asset-pipeline-v0.1.zh.md",
		"res://docs/design/v0.2-direction.zh.md",
		"res://docs/design/first-space-scale-v0.2.zh.md",
		"res://docs/roadmap/v0.2-implementation-slices.zh.md",
		"res://docs/design/generated-asset-integration-v0.1.zh.md",
		"res://docs/design/asset-production-brief-v0.1.zh.md",
		"res://assets/ASSET_INDEX.md",
		"res://data/portraits.gd",
		"res://data/memory_events.gd",
		"res://scripts/memory_event_player.gd",
		"res://scripts/tools/first_space_scale_smoke_test.gd",
		"res://scripts/tools/player_motion_visual_smoke_test.gd",
		"res://scripts/tools/memory_event_smoke_test.gd",
	]:
		_assert(FileAccess.file_exists(path), "%s exists" % path)
	for path in [
		"res://assets/originals/generated",
		"res://assets/sprites",
		"res://assets/sprites/classroom",
		"res://assets/sprites/objects",
		"res://assets/sprites/characters",
	]:
		_assert(DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(path)), "%s directory exists" % path)
	for path in [
		"res://assets/sprites/classroom/bg01_main_classroom_reality.png",
		"res://assets/sprites/classroom/bg03_final_classroom_memory.png",
		"res://assets/sprites/classroom/obj02_blackboard_state_rough.png",
		"res://assets/sprites/classroom/obj02_blackboard_state_photo.png",
		"res://assets/sprites/classroom/obj02_blackboard_state_final.png",
		"res://assets/sprites/characters/ch01_surveyor_player_sheet.png",
		"res://assets/sprites/characters/ch01_surveyor_player_sheet_v02.png",
		"res://assets/sprites/objects/obj05_paper_plane_broken_pencil.png",
		"res://assets/sprites/objects/obj06_archive_father_record.png",
		"res://assets/sprites/objects/obj08_essay_fragment.png",
	]:
		_assert(FileAccess.file_exists(path), "%s runtime asset exists" % path)
	var index_text := FileAccess.get_file_as_string("res://assets/ASSET_INDEX.md")
	for token in ["BG01", "BG03", "OBJ02-A", "OBJ02-B", "OBJ02-C", "CH01", "ch01_surveyor_player_sheet_v02.png", "OBJ05", "OBJ06", "OBJ08", "PORTRAIT-CONFIG", "AUDIO-PROC", "Player standing height", "Single desk", "Double desk"]:
		_assert(index_text.contains(token), "asset index tracks %s" % token)
	var pipeline_text := FileAccess.get_file_as_string("res://docs/design/asset-pipeline-v0.1.zh.md")
	for token in ["data/portraits.gd", "assets/audio/source/", "scripts/tools/audio_safety_smoke_test.gd", "first_space_scale_smoke_test.gd", "player_motion_visual_smoke_test.gd", "memory_event_smoke_test.gd", "56px", "72x42px", "112x44px", "80-96px"]:
		_assert(pipeline_text.contains(token), "asset pipeline documents %s" % token)
	var scale_text := FileAccess.get_file_as_string("res://docs/design/first-space-scale-v0.2.zh.md")
	for token in ["960x540", "56px", "72x42px", "112x44px", "64px", "80-96px", "脚底 pivot", "可控分层", "入口建立整体感", "视觉显著性", "场景内显影"]:
		_assert(scale_text.contains(token), "v0.2 scale spec documents %s" % token)
	var direction_text := FileAccess.get_file_as_string("res://docs/design/v0.2-direction.zh.md")
	for token in ["调查互动感", "像素风", "父亲线", "何小满线", "A12-final", "不解决主角", "安静收束", "未被命名的亲近", "校园卡", "南方城市名占位", "摩托", "后座第一视角", "父亲背影", "升学去向", "转出记录：缺页", "小主角的手", "不明确说破", "0.5-1", "场景文字残影", "不模拟手机 UI", "复用 A8/A11", "8-12", "工作 UI 退暗"]:
		_assert(direction_text.contains(token), "v0.2 direction documents %s" % token)
	var slices_text := FileAccess.get_file_as_string("res://docs/roadmap/v0.2-implementation-slices.zh.md")
	for token in ["Slice 1", "回忆事件基础系统", "Slice 2", "A8 父亲事件样板", "Slice 3", "A11 何小满", "Slice 4", "A12-final", "Slice 5", "第一空间可控分层重构", "物件位置", "可站热点"]:
		_assert(slices_text.contains(token), "v0.2 implementation slices document %s" % token)
	if failures.is_empty():
		print("ASSET_PIPELINE_SMOKE_TEST_OK")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
