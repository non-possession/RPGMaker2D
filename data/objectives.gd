extends RefCounted

static func current_objective(game_state: Node) -> String:
	if game_state == null:
		return "查看讲台上的测绘表。"
	if game_state.has_flag("ending_seen"):
		return "测绘完成。最终照片已保存。"
	if game_state.has_flag("final_photo_ready"):
		return "在教室中央拍摄最终现状。"
	if game_state.has_flag("friend_paths_seen"):
		return "查看中排课桌里的作文本碎页。"
	if game_state.has_flag("window_crack_seen"):
		return "回到黑板，拍照复查字迹。"
	if game_state.has_flag("father_record_seen"):
		return "登记右侧窗边墙体裂缝。"
	if game_state.has_flag("paper_plane_emotion_seen"):
		return "检查左侧档案柜里的旧记录。"
	if game_state.has_flag("place_disturbance_seen"):
		return "查看左下角的纸飞机和断铅笔。"
	if game_state.has_flag("blackboard_surface_memory_seen") and game_state.has_flag("school_closure_seen"):
		return "调查右侧墙上的旧地图/校名牌。"
	if game_state.has_flag("survey_started"):
		return "完成第一批测绘：黑板、课桌、奖状、撤并通知。"
	return "查看讲台上的测绘表。"
