# 《最后一间教室》Godot 原型实现计划 v0.1

本文把已通过的原型设计转成可直接开工的 Godot 工程方案。目标是先做出一条可玩的垂直切片，再逐步替换美术和扩展事件。

## 技术范围

引擎：Godot 4.x。

第一版类型：

- 单场景 2D 叙事探索原型。
- 一间教室地图。
- 四向移动。
- 固定调查点。
- 文本框叙事。
- 状态解锁。
- 测绘表进度。
- 固定点拍照。
- 局部显影。

明确不做：

- 自由拍照系统。
- 背包系统。
- 多地图校园。
- NPC 行走系统。
- 战斗、经济、多结局。
- 第一版人物插图。

## 目录结构

```text
project.godot
scenes/
  main.tscn
  player.tscn
  ui/
    dialogue_box.tscn
    interaction_prompt.tscn
    survey_progress.tscn
scripts/
  main.gd
  player.gd
  game_state.gd
  interactable.gd
  interaction_controller.gd
  dialogue_box.gd
  survey_progress.gd
  photo_flash.gd
data/
  names.gd
  interactions.gd
  dialogues.gd
  survey_items.gd
assets/
  placeholders/
    classroom/
    characters/
    ui/
    overlays/
  sprites/
  audio/
  portraits/
docs/
  design/
```

说明：

- `data/*.gd` 第一版用 GDScript 常量字典，避免引入 JSON 解析和资源编辑复杂度。
- `assets/portraits/` 预留但第一版为空。
- 占位图优先放在 `assets/placeholders/`，后续替换到 `assets/sprites/` 或同等正式目录。

## 场景节点结构

```text
Main (Node2D)
├── GameState (Node)
├── ClassroomRoot (Node2D)
│   ├── Background (Node2D)
│   │   ├── Floor
│   │   ├── Walls
│   │   ├── Blackboard
│   │   ├── Desks
│   │   ├── Windows
│   │   └── Cabinet
│   ├── MemoryOverlayRoot (Node2D)
│   │   ├── OverlayBlackboardSurface
│   │   ├── OverlayPlaceDisturbance
│   │   ├── OverlayPaperPlaneEmotion
│   │   ├── OverlayFatherPhoto
│   │   ├── OverlayBlackboardPhoto
│   │   ├── OverlayGirlMemory
│   │   └── OverlayFinalClassroom
│   ├── Interactables (Node2D)
│   │   ├── A1SurveyForm
│   │   ├── A2Blackboard
│   │   ├── A3Desk
│   │   ├── A4Award
│   │   ├── A5ClosureNotice
│   │   ├── A6SchoolSign
│   │   ├── A7PaperPlane
│   │   ├── A8ArchiveCabinet
│   │   ├── A9WindowCrack
│   │   ├── A10BlackboardPhoto
│   │   ├── A11EssayFragment
│   │   └── A12FinalPhoto
│   └── Player
├── Camera2D
└── UI (CanvasLayer)
    ├── DialogueBox
    ├── InteractionPrompt
    ├── SurveyProgress
    └── PhotoFlash
```

第一版背景可不用 TileMap，直接用 `ColorRect`/`Sprite2D`/简单 `Polygon2D` 色块搭出教室。若后续需要 tile 化，再引入 TileMap。

## 核心系统

### GameState

职责：

- 保存所有 flags。
- 保存测绘表进度。
- 暴露 `has_flag()`、`set_flag()`、`can_interact()`。
- 统一保存命名占位配置。

第一版命名配置：

```gdscript
const NAMES := {
  "place": "A地",
  "school": "B校",
  "protagonist": "小李",
  "girl": "何小满",
  "father": "老李",
}
```

核心 flags：

```text
survey_started
blackboard_surface_memory_seen
school_closure_seen
place_disturbance_seen
paper_plane_emotion_seen
father_record_seen
window_crack_seen
friend_paths_seen
girl_memory_seen
final_photo_ready
ending_seen
```

### Player

职责：

- 四向移动。
- 禁止移动：对话播放、显影、拍照闪光期间。
- 与 `InteractionController` 配合，按确认键触发当前最近可交互物。

输入建议：

- `ui_up/down/left/right` 或自定义 `move_up/down/left/right`。
- `interact`：确认/调查。
- `advance_dialogue`：可与 `interact` 共用。

### Interactable

每个调查点使用同一脚本和配置。

字段：

```text
id
label
prompt
required_flags
disabled_prompt
set_flags
dialogue_id
overlay_id
survey_items
photo_required
enabled_initially
```

行为：

- 玩家进入 Area2D 后，通知 `InteractionController`。
- 若满足 `required_flags`，显示 `prompt`。
- 若不满足但有 `disabled_prompt`，显示轻提示。
- 触发后播放 dialogue、设置 flags、推进测绘表、播放 overlay/photo flash。

### InteractionController

职责：

- 维护玩家附近可交互物列表。
- 选择最近且优先级最高的交互物。
- 更新 `InteractionPrompt`。
- 在对话或演出中锁定输入。

### DialogueBox

职责：

- 显示多段文本。
- 支持 `speaker_id`、`speaker_name`、`portrait_id` 字段。
- 第一版 `portrait_id` 为空，头像区域默认隐藏。
- 支持变量替换，如 `{school}` -> `B校`。

对话数据结构：

```gdscript
{
  "id": "a1_survey_form",
  "lines": [
    {"speaker_id": "system", "portrait_id": "", "text": "测绘记录表已展开。"},
    {"speaker_id": "system", "portrait_id": "", "text": "任务：拍摄现状照片，标记结构损坏，登记遗留物。"},
    {"speaker_id": "protagonist", "portrait_id": "", "text": "先把该拍的拍完。"}
  ]
}
```

### SurveyProgress

第一版显示 5 项：

- 现状照片
- 遗留物登记
- 墙面附着物
- 结构损坏
- 最终照片

行为：

- 调查点完成时，设置对应 item 完成。
- UI 可以常驻角落，也可以按键/事件短暂弹出。
- 视觉要像工作表，不像成就任务栏。

### PhotoFlash

职责：

- A10/A12 拍照时播放短暂白闪。
- 可选显示极简取景框。
- 不做自由取景。

### MemoryOverlayRoot

职责：

- 管理 OV01-OV07 的显影层。
- 提供 `play_overlay(overlay_id)`。
- 第一版可用半透明色块、文字残影、局部 Sprite2D。
- 显影结束后可保留某些状态，也可淡出；由事件定义。

### DebugHUD 与开发快捷键

职责：

- 显示当前可交互点、附近交互点、已触发 flags、测绘表状态。
- 用于手动验收 A1-A12 时快速定位事件链问题。

快捷键：

- `F3`：显示/隐藏 DebugHUD。
- `F5`：重载当前场景。
- `F6`：强制完成下一个未完成事件。
- `F7`：传送到下一个可触发事件点；如果当前没有可触发事件，则传送到下一个未完成事件点附近。

这些能力仅用于开发验证，不属于正式玩家体验。

## 数据配置

### names.gd

集中配置占位名，供对话变量替换。

### interactions.gd

定义 A1-A12。

示例：

```gdscript
const INTERACTIONS := {
  "A1": {
    "label": "测绘表",
    "prompt": "登记",
    "required_flags": [],
    "disabled_prompt": "",
    "set_flags": ["survey_started"],
    "dialogue_id": "a1_survey_form",
    "overlay_id": "",
    "survey_items": [],
    "photo_required": false,
    "enabled_initially": true
  },
  "A2": {
    "label": "黑板涂写",
    "prompt": "调查",
    "required_flags": ["survey_started"],
    "disabled_prompt": "",
    "set_flags": ["blackboard_surface_memory_seen"],
    "dialogue_id": "a2_blackboard_surface",
    "overlay_id": "overlay_blackboard_surface",
    "survey_items": [],
    "photo_required": false,
    "enabled_initially": false
  }
}
```

### dialogues.gd

按 `prototype-script-v0.1.zh.md` 中的章节文本拆分。

命名建议：

- `intro_vehicle`
- `a1_survey_form`
- `a2_blackboard_surface`
- `a3_old_desk`
- `a4_award`
- `a5_closure_notice`
- `a6_place_disturbance`
- `a7_paper_plane`
- `a8_father_record`
- `a9_window_crack`
- `a10_blackboard_photo`
- `a11_girl_memory`
- `a12_final_photo`

### survey_items.gd

```gdscript
const SURVEY_ITEMS := {
  "current_photo": "现状照片",
  "left_items": "遗留物登记",
  "wall_items": "墙面附着物",
  "structure_damage": "结构损坏",
  "final_photo": "最终照片"
}
```

推进映射：

- A3/A7/A8 -> `left_items`
- A4/A5/A6 -> `wall_items`
- A9 -> `structure_damage`
- A10 -> `current_photo`
- A12 -> `final_photo`

## 事件解锁规则

```text
Start -> intro_vehicle -> enter classroom

A1:
  set survey_started
  unlock A2/A3/A4/A5

A2:
  requires survey_started
  set blackboard_surface_memory_seen

A5:
  requires survey_started
  set school_closure_seen

A6:
  requires blackboard_surface_memory_seen + school_closure_seen
  set place_disturbance_seen

A7:
  requires place_disturbance_seen
  set paper_plane_emotion_seen

A8:
  requires paper_plane_emotion_seen
  set father_record_seen

A9:
  requires father_record_seen
  set window_crack_seen

A10:
  requires window_crack_seen
  set friend_paths_seen
  photo flash

A11:
  requires friend_paths_seen
  set girl_memory_seen
  set final_photo_ready

A12:
  requires final_photo_ready
  set ending_seen
  photo flash
  play final overlay
```

## 第一批垂直切片

### Slice 1：空项目 + 教室可走

目标：

- 初始化 Godot 项目。
- 创建主场景。
- 用色块搭出教室。
- 主角可四向移动，有碰撞边界。

验收：

- 运行后进入教室。
- 玩家不能走出墙外。
- 摄像机能跟随或固定显示完整教室。

### Slice 2：交互框架 + A1

目标：

- 实现 `GameState`、`Interactable`、`InteractionController`、`InteractionPrompt`。
- 放置 A1 测绘表。
- 触发 A1 文本，设置 `survey_started`。

验收：

- 靠近 A1 显示“登记”。
- 按确认键显示 A1 对话。
- 对话期间不能移动。
- 对话结束后 `survey_started = true`。

### Slice 3：文本框 + 对话数据

目标：

- 实现 `DialogueBox`。
- 从 `dialogues.gd` 读取文本。
- 支持 speaker、portrait_id 留白、变量替换。

验收：

- 可逐句推进。
- `{school}` 等变量能替换为 `B校`。
- `portrait_id` 为空时不显示头像区域。

### Slice 4：第一批调查 A2/A3/A4/A5

目标：

- A1 后解锁 A2/A3/A4/A5。
- A2 播放浅层童年记忆文本和 overlay。
- A3/A4/A5 播放基础调查文本。
- A5 设置 `school_closure_seen`。

验收：

- A1 前 A2/A3/A4/A5 不可触发或只有轻提示。
- A1 后可触发。
- A2 后 `blackboard_surface_memory_seen = true`。
- A5 后 `school_closure_seen = true`。

### Slice 5：中段解锁 A6/A7/A8

目标：

- 完成 A2+A5 后解锁 A6。
- A6 后解锁 A7。
- A7 后解锁 A8。
- A8 显示父亲花名册/旧照片文本。

验收：

- A6 不会过早触发。
- A7 情绪事件播放后设置 `paper_plane_emotion_seen`。
- A8 后设置 `father_record_seen`。

### Slice 6：后段 A9/A10/A11/A12 + 结尾

目标：

- A8 后解锁 A9，A9 后解锁 A10，A10 后解锁 A11，A11 后解锁 A12。
- A10/A12 播放拍照闪光。
- A12 播放最终显影和结尾文本。

验收：

- 状态链正确。
- 最终照片只在 `final_photo_ready` 后可触发。
- A12 后 `ending_seen = true`。

## 最小测试计划

手动验证：

- 新游戏完整跑通 A1-A12。
- 任意未解锁调查点不会提前触发核心文本。
- 对话期间移动被锁定。
- 拍照闪光只在 A10/A12 出现。
- 结尾后无法重复触发关键事件，或重复触发不会破坏状态。

脚本级验证：

- `GameState.has_flag()` 和 `set_flag()` 正常。
- `can_interact(interaction)` 能正确处理 required flags。
- 测绘表 item 设置不重复、不丢失。
- 对话变量替换正常。

视觉验证：

- 所有提示文字不遮挡主角。
- 文本框可读。
- 低分辨率下中文显示清晰。
- 显影层不会遮住交互提示和文本框。

## 第一版完成定义

第一版 Godot 原型完成时，应该满足：

- 玩家能从开场进入教室。
- 能移动、调查、阅读文本。
- A1-A12 事件按状态顺序解锁。
- 测绘表进度能推进。
- A2/A6/A7/A8/A10/A11/A12 至少有占位显影或视觉反馈。
- A10/A12 有固定点拍照反馈。
- 命名从统一配置读取。
- 对话数据保留 `portrait_id`，但第一版不显示人物插图。
- 整体可在 10-15 分钟内完整游玩。

## 实施顺序建议

1. 初始化 Godot 项目与基础目录。
2. 创建 `main.tscn`、`player.tscn` 和色块教室。
3. 实现玩家移动与碰撞。
4. 实现 A1 交互闭环。
5. 实现文本数据和变量替换。
6. 实现 A2-A5。
7. 实现测绘表进度。
8. 实现 A6-A8。
9. 实现显影层管理。
10. 实现 A9-A12 和结尾。
11. 补音效、过渡、占位美术清理。
