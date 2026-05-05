# 生成资产接入说明 v0.1

本文记录第一批生成资产接入 Godot 原型的工程开关和验证步骤。

## 当前接入策略

默认仍使用 Godot 色块占位背景，保证原型随时可运行。

生成资产通过 `scripts/main.gd` 中的导出开关启用：

- `use_generated_classroom_background`
- `use_generated_memory_background`
- `use_generated_blackboard_states`

这三个开关默认关闭。图片不存在时，即使开关打开，也会安全回退，不会让项目崩溃。

## 路径约定

### BG01 主教室现实层

目标路径：

```text
assets/sprites/classroom/bg01_main_classroom_reality.png
```

接入方式：

- 将图片放入上述路径。
- 在 `Main` 节点上打开 `use_generated_classroom_background`。
- 打开后，色块教室背景不会再绘制，避免生成图被色块盖住。
- 交互点、碰撞、氛围层、纸签、UI 仍沿用现有逻辑。

### BG03 最终教室复原显影层

目标路径：

```text
assets/sprites/classroom/bg03_final_classroom_memory.png
```

接入方式：

- 将图片放入上述路径。
- 在 `Main` 节点上打开 `use_generated_memory_background`。
- A12 最终显影时会尝试在现有显影覆盖层里显示该图。

注意：

- 如果使用 `960x540` 整图作为最终显影层，后续可能需要微调 `Sprite2D.position`。
- 当前代码默认把它放在 `Vector2(400, 210)`，因为显影父节点是从 `Vector2(80, 60)` 开始的覆盖区域。

### OBJ02 黑板三状态

目标路径：

```text
assets/sprites/classroom/obj02_blackboard_state_rough.png
assets/sprites/classroom/obj02_blackboard_state_photo.png
assets/sprites/classroom/obj02_blackboard_state_final.png
```

当前接入状态：

- 已预留 `use_generated_blackboard_states` 开关。
- 图片存在且开关打开时，会加载三张黑板状态图。
- 默认显示 rough 状态。
- A10 完成后切换到 photo 状态。
- A12 完成后切换到 final 状态。

v1 注意：

- 当前 OBJ02 v1 已接入，但 photo/final 状态存在偏清晰的人名式文字。
- 后续若进入美术精修，应重生成一版“字迹可感知但不可明确阅读”的黑板状态。

## 接入后验证

每次放入图片或开启开关后，至少执行：

```bash
/usr/local/bin/godot --headless --path . --quit-after 5
/usr/local/bin/godot --headless --path . --script res://scripts/tools/flow_smoke_test.gd
```

预期：

```text
FLOW_SMOKE_TEST_OK
```

手动检查：

- BG01 没有被色块遮挡。
- 玩家仍能在桌椅之间移动。
- A1-A12 的提示点仍大致贴近物件。
- 纸签没有飘到明显错误的位置。
- 对话框、测绘表、拍照取景框不遮挡关键画面。
- A12 最终显影没有改变教室布局。

## BG01 v1 校准记录

已完成第一轮接入后校准：

- A4 墙上奖状移动到 BG01 左上墙面奖状位置。
- A5 撤并通知移动到黑板右侧墙面通知位置。
- A6 旧地图/校名牌移动到黑板右侧竖牌位置。
- A9 窗边裂缝移动到右上窗边墙面区域。
- 生成背景模式下新增的测绘表、纸飞机、作文本、裂缝锚点已同步调整。
- 生成背景模式下的桌椅/档案柜碰撞体已按 BG01 的桌椅列位置重建。

## 第二批道具 v1 校准记录

已完成 OBJ05/OBJ06/OBJ08 接入后的第一轮位置校准：

- A7 纸飞机/断铅笔：交互区保持在西南角道具组，完成纸签移到左上，避免遮住纸飞机和铅笔。
- A8 档案柜/花名册/旧照片：交互区收窄到新道具本体，完成纸签移到左上，避免压住旧照片。
- A11 作文本碎页：交互区收窄到中间课桌上的作文本，完成纸签移到右下，避免遮挡“我的家乡……”。

后续如果替换 BG01 v2，需要重新检查：

- A1/A3/A7/A11 是否仍贴合桌面或角落道具。
- A4/A5/A6/A9 是否仍贴合墙面物件。
- 课桌碰撞是否仍给玩家留出可通行过道。

## 第三批表现 v1 收束记录

本轮先不继续扩张新美术资产数量，而是补上原型最缺的表现层反馈。

已完成：

- 新增 `scripts/audio_controller.gd`，用程序化 WAV 生成占位音频，不依赖外部音频文件。
- 主场景启动后创建 `AudioController`，正常运行时播放极低音量的教室风声/空房间底噪。
- 交互触发时按事件类型播放不同反馈：
  - 普通调查：旧纸/记录声。
  - 拍照事件 A5/A10/A12：快门和短促高频反馈。
  - 显影事件：低饱和的记忆泛起音。
  - A8 档案柜：抽屉卡住/铁皮摩擦感。
  - A12 结尾：更长但克制的收束音。
- Headless 自动验证下保留音频节点，但跳过实际 WAV 生成和播放，避免测试环境音频后端产生清理 warning。

验证：

```bash
/usr/local/bin/godot --headless --path . --script res://scripts/tools/flow_smoke_test.gd
/usr/local/bin/godot --headless --path . --quit-after 5
```

预期：

```text
FLOW_SMOKE_TEST_OK
```

第三批后续美术 v2 目标：

- OBJ02 黑板 photo/final 状态需要重生成或精修为“可感知有字，但不可被玩家逐字阅读”。保留粉笔灰、擦痕、年代感，避免清晰人名和大段可读句子抢走叙事节奏。
- OBJ06 档案/花名册也需要降低姓名可读性：保留“旧记录存在”“少年老李可被辨认”的信息，不让花名册文字变成玩家误以为必须阅读的谜题。
- 若后续换入真实音频，替换方向应遵守 `docs/design/asset-plan-v0.1.zh.md` 的音频禁止项：不恐怖、不煽情钢琴铺满、不用强旋律压过文本。

## 下一步工程任务

## CH01 主角小人

目标路径：

```text
assets/sprites/characters/ch01_surveyor_player_sheet.png
```

接入方式：

- 将 sprite sheet 放入上述路径。
- `player.gd` 会自动检测该文件。
- 文件存在时，会隐藏当前 `Polygon2D` 色块身体，改用 `Sprite2D` 显示。
- 默认 sheet 规格为 3 列 x 4 行。

默认排列：

```text
第 0 行：向下，待机/行走1/行走2
第 1 行：向左，待机/行走1/行走2
第 2 行：向右，待机/行走1/行走2
第 3 行：向上，待机/行走1/行走2
```

如果实际生成 sheet 排列不同，调整 `Player` 节点上的：

- `generated_sprite_hframes`
- `generated_sprite_vframes`

或修改 `player.gd` 中的 `_sprite_row_for_direction()`。

## 下一步工程任务

1. 接入 BG01 后，微调交互点位置和纸签偏移。
2. 接入 CH01 后，检查 sprite sheet 行列和碰撞盒比例。
3. 接入 OBJ02 后，检查 A10/A12 的黑板状态切换。
4. 接入 BG03 后，检查最终显影是否需要全屏覆盖而不是局部覆盖。
