extends RefCounted

const PORTRAITS := {
	"protagonist": {
		"display_name": "小李",
		"path": "",
		"fallback_initial": "李",
		"tint": Color(0.28, 0.34, 0.36),
	},
	"father": {
		"display_name": "老李",
		"path": "",
		"fallback_initial": "父",
		"tint": Color(0.34, 0.28, 0.22),
	},
	"mother": {
		"display_name": "母亲",
		"path": "",
		"fallback_initial": "母",
		"tint": Color(0.34, 0.27, 0.3),
	},
	"girl": {
		"display_name": "何小满",
		"path": "",
		"fallback_initial": "满",
		"tint": Color(0.38, 0.28, 0.2),
	},
}

static func get_portrait(id: String) -> Dictionary:
	return PORTRAITS.get(id, {})
