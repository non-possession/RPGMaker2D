# 资产生成与接入 Pipeline v0.1

本文把 v0.1 阶段已经验证过的“生成资产 -> 整理 -> 接入 -> 验收”流程固化下来，后续新背景、道具、人物插画、真实音频都按同一套记录方式推进。

## 总原则

- 先保留 Godot 原生占位和安全回退，再接入外部资产。
- 原图、运行时图、接入说明、验收记录必须能互相追溯。
- 新资产不直接改剧情顺序；先替换表现层，再评估是否扩展玩法。
- 任何可读文字、真实姓名、照片细节都要先降噪，避免玩家误以为是谜题答案。

## 目录约定

| 类型 | 路径 | 用途 |
| --- | --- | --- |
| 原始生成图 | `assets/originals/generated/` | 保存未经裁剪或仅轻处理的生成输出。 |
| 运行时图片 | `assets/sprites/` | 保存 Godot 直接加载的透明图、整图背景、sprite sheet。 |
| 真实音频原件 | `assets/audio/source/` | 保存外部下载或录制的原始音频；若许可证不允许提交，只放元数据记录。 |
| 运行时音频 | `assets/audio/ch1/` | 保存裁剪、降噪、响度处理后的游戏内音频。 |
| v0.2 方向记录 | `docs/design/v0.2-direction.zh.md` | 记录高层方向、叙事边界、父亲线和何小满线。 |
| 接入说明 | `docs/design/generated-asset-integration-v0.1.zh.md` | 记录资产开关、坐标校准、手动检查点。 |
| v0.2 比例规范 | `docs/design/first-space-scale-v0.2.zh.md` | 记录第一空间分层、尺寸、碰撞和道具贴合标准。 |
| 资产索引 | `assets/ASSET_INDEX.md` | 记录每个资产 ID、运行路径、状态和来源备注。 |

## 命名规则

资产 ID 使用“类型 + 序号 + 可选状态”：

- `BG01`：主空间背景。
- `OBJ02-A`：同一物件的不同状态。
- `CH01`：角色小人或角色 sprite sheet。
- `POR01`：人物对话插画。
- `SFX01`：短音效。
- `AMB01`：环境底噪。

运行时文件名使用小写英文和下划线，例如：

```text
assets/sprites/portraits/por01_protagonist_neutral.png
assets/audio/ch1/amb01_empty_classroom_loop.ogg
```

## v0.2-A 尺寸基准

v0.2-A 继续使用 `960x540` 逻辑视口，暂不要求生产 `1920x1080` 源图。新增或替换资产时，必须先按 `docs/design/first-space-scale-v0.2.zh.md` 校准比例。

| 项目 | 标准尺寸 | Pipeline 要求 |
| --- | --- | --- |
| 主角站立高度 | `56px` | 角色动画帧统一画布和脚底 pivot，不用缩放制造走路变化。 |
| 单人课桌 | `72x42px` | 用于重点调查桌、作文本、旧文具等局部道具承载。 |
| 双人课桌 | `112x44px` | v0.2 主推荐桌型；`128x44px` 只作为特殊上限。 |
| 最小可通行走道 | `64px` | 仅保证可通过，不作为主要调查动线。 |
| 舒适调查走道 | `80-96px` | 主要动线优先采用，保障调查空间的可信互动感。 |

所有可调查道具必须记录其依附对象，例如“纸飞机贴桌脚”“作文本在抽屉口”“花名册压在档案柜/桌面上”，不能只作为独立漂浮贴片接入。

## 标准流程

1. 从 `docs/design/asset-production-brief-v0.1.zh.md` 或新需求里确认资产目标。
2. 生成、下载或录制原始素材，并记录来源、日期、许可证、提示词或搜索词。
3. 原始素材放入 `assets/originals/generated/` 或 `assets/audio/source/`。
4. 处理运行时版本：裁剪、透明背景、降噪、响度、尺寸统一。
5. 运行时文件放入 `assets/sprites/` 或 `assets/audio/ch1/`。
6. 在 `assets/ASSET_INDEX.md` 增加资产 ID、路径、状态、来源摘要。
7. 在接入说明里记录开关、节点坐标、碰撞/交互校准和手动检查点。
8. 跑自动 smoke test，再做一次实际窗口检查。

## 人物插画接入

对话立绘不直接写死在 UI 里，统一通过 `data/portraits.gd` 配置。

每个 portrait 配置至少包含：

- `display_name`：用于人工识别。
- `path`：正式图路径；为空时自动使用 fallback。
- `fallback_initial`：正式图未到位时显示的字。
- `tint`：fallback 色块。

正式人物插画建议放在：

```text
assets/sprites/portraits/
```

新增人物时，同时更新：

- `data/portraits.gd`
- `data/dialogues.gd` 里的 `portrait_id`
- `scripts/tools/portrait_config_smoke_test.gd`
- `assets/ASSET_INDEX.md`

## 真实音频接入

每条真实音频必须记录：

- 来源站点和下载 URL。
- 作者/库名。
- 许可证名称。
- 是否需要署名。
- 是否允许商业/再分发。
- 本项目内的运行时路径。
- 处理动作：裁剪、降噪、循环点、响度调整。

优先替换顺序：

1. `AMB01` 教室空房间底噪。
2. `SFX01` 快门声。
3. `SFX02` 旧纸/档案柜摩擦声。

真实音频进入工程后，仍需通过 `scripts/tools/audio_safety_smoke_test.gd`，避免音量压过文本。

## 验收命令

```bash
/usr/local/bin/godot --headless --path . --script res://scripts/tools/flow_smoke_test.gd
/usr/local/bin/godot --headless --path . --script res://scripts/tools/first_space_scale_smoke_test.gd
/usr/local/bin/godot --headless --path . --script res://scripts/tools/player_motion_visual_smoke_test.gd
/usr/local/bin/godot --headless --path . --script res://scripts/tools/memory_event_smoke_test.gd
/usr/local/bin/godot --headless --path . --script res://scripts/tools/portrait_config_smoke_test.gd
/usr/local/bin/godot --headless --path . --script res://scripts/tools/asset_pipeline_smoke_test.gd
```

预期：

```text
FLOW_SMOKE_TEST_OK
FIRST_SPACE_SCALE_SMOKE_TEST_OK
PLAYER_MOTION_VISUAL_SMOKE_TEST_OK
MEMORY_EVENT_SMOKE_TEST_OK
PORTRAIT_CONFIG_SMOKE_TEST_OK
ASSET_PIPELINE_SMOKE_TEST_OK
```
