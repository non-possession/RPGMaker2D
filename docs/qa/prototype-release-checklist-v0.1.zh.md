# 《最后一间教室》v0.1 原型收束检查清单

本文用于判断当前 Godot 原型是否已经可以作为“AI agent + AI 辅助美术资源 + 外部素材流程”的阶段性展示版本。它不是新需求池，而是封版前的把关依据。

## 结论

当前 v0.1 可以作为内部展示原型：

- 项目启动先进入最小标题页，玩家按 `E/Enter` 后进入教室流程。
- A1-A12 主线闭环完整。
- 核心动线从测绘表、黑板、墙面、角落、档案柜、窗边，再回到黑板和最终照片，空间回看感成立。
- 美术资产已经覆盖主教室、主角小人、黑板三状态、纸飞机/断铅笔、档案/旧照片、作文本碎页、最终显影。
- `OBJ02` 和 `OBJ06` 的文字可读性已降噪，当前更接近“信息痕迹”而不是文字谜题。
- 程序化占位音频已接入，可支撑环境底噪、调查反馈、快门、显影和结尾收束。
- 对话、拍照、显影的触发顺序已做一轮节奏收束。

## 自动验证

每次封版前执行：

```bash
/usr/local/bin/godot --headless --path . --script res://scripts/tools/title_screen_smoke_test.gd
/usr/local/bin/godot --headless --path . --script res://scripts/tools/flow_smoke_test.gd
/usr/local/bin/godot --headless --path . --script res://scripts/tools/visual_feedback_smoke_test.gd
/usr/local/bin/godot --headless --path . --script res://scripts/tools/playable_reachability_smoke_test.gd
/usr/local/bin/godot --headless --path . --script res://scripts/tools/audio_safety_smoke_test.gd
/usr/local/bin/godot --headless --path . --script res://scripts/tools/display_config_smoke_test.gd
/usr/local/bin/godot --headless --path . --script res://scripts/tools/settings_menu_smoke_test.gd
```

可视截图检查需要图形渲染：

```bash
/usr/local/bin/godot --path . --script res://scripts/tools/capture_qa_screenshots.gd
```

截图会输出到本地 `docs/qa/screenshots/`，该目录不纳入 Git。

注意：当前项目使用固定 960x540 逻辑视口和 `canvas_items` stretch。脚本截图主要用于检查逻辑视口布局；真实宽屏窗口外框仍需要人工或 OS 级截图辅助确认。

预期：

```text
TITLE_SCREEN_SMOKE_TEST_OK
FLOW_SMOKE_TEST_OK
VISUAL_FEEDBACK_SMOKE_TEST_OK
PLAYABLE_REACHABILITY_SMOKE_TEST_OK
AUDIO_SAFETY_SMOKE_TEST_OK
DISPLAY_CONFIG_SMOKE_TEST_OK
SETTINGS_MENU_SMOKE_TEST_OK
```

已覆盖：

- 主场景可实例化。
- 标题页可实例化，项目启动场景指向 `res://scenes/title_screen.tscn`。
- `GameState`、`InteractionController`、`AudioController`、玩家、UI 关键节点存在。
- 生成背景、生成主角、第二批道具、黑板三状态、最终显影在对应资产存在时正常接入。
- A1-A12 按顺序可达、可触发、可完成。
- flags、测绘项、完成纸签、结尾卡正常。
- A5/A10/A12 保持拍照反馈事件。
- 真实触发路径下，拍照取景框/快门闪光和显影层会进入可见状态。
- 玩家进入交互热区后，可通过正常触发路径按顺序完成 A1-A12。
- 程序化音频峰值、RMS 和默认音量低于安全阈值。
- 显示配置保持全屏、960x540 设计视口、`canvas_items` 和 `keep` 比例保护。
- 设置菜单可开关、可调整主音量，并在打开时锁定玩家和交互输入。
- 结尾目标收束为“测绘完成。最终照片已保存。”，不再暗示未实现的车辆返回交互。

## 手动展示路径

展示时建议按正常路径游玩，不使用 F6/F7：

1. 标题页按 `E/Enter` 开始测绘。
2. 开场车内文本，听到 `A地`、`B校` 钩子。
3. A1 展开测绘表，建立工作距离感。
4. A2/A3/A4/A5 完成第一批测绘，让童年浅层记忆和撤并通知形成第一层反差。
5. A6 旧校名牌触发地点扰动。
6. A7 纸飞机/断铅笔被对讲机打断，验证“情绪被工作理性收起”。
7. A8 档案柜回收父亲借读钩子。
8. A9 窗边裂缝把工作记录和内心裂缝叠在一起。
9. A10 回到黑板拍照复查，验证黑板 v2 是否只保留文字痕迹。
10. A11 作文本碎页进入何小满线。
11. A12 最后一张照片，最终显影和结尾卡完成闭环。

## 展示版验收点

- 玩家不需要知道调试快捷键也能完成流程。
- 标题页能说明这是一个独立 demo，而不是直接从调试场景开始。
- 左上当前目标始终能提示下一步，但不剧透下一层记忆。
- 交互提示不会遮挡对话框。
- 拍照事件先出现取景框/快门，再进入文本。
- 对话提示不会过早出现，情绪句有短暂停顿。
- 完成纸签不会挡住纸飞机、档案、作文本等关键道具。
- 黑板和档案文字不可逐字阅读，但能看出“曾经有人写过/记录过”。
- 结尾卡出现后，目标文案不再引导玩家寻找未实现的出口或车辆。

## 已知限制

- 名称仍是占位：`A地`、`B校`、`小李`、`何小满`、`老李`。
- 程序化音频只是占位，不代表最终音色。
- 没有人物立绘，只保留了后续添加人物插图的 UI 空间和数据接口方向。
- 第一版没有主菜单、存档、设置、暂停菜单。
- 没有正式导出包，本阶段以 Godot 工程运行展示为准。
- 宽屏/窄屏窗口比例需要按 `docs/qa/display-aspect-checklist-v0.1.zh.md` 做人工签收；脚本截图只能稳定验证 960x540 逻辑视口。

## 下一轮候选项

- 完成 P0.2 人工窗口比例签收。
- 用真实环境声替换程序化占位音频。
- 准备 macOS 导出构建。
