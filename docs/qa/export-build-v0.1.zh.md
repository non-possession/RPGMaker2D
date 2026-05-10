# 《最后一间教室》v0.1 导出构建记录

本文记录 P2.2：macOS 本机可运行包的导出准备、命令和验收状态。

## 当前目标

- 先提供 macOS 导出 preset。
- 优先导出本机可运行 `.app`。
- 若本机缺少 Godot 导出模板，则记录为阻塞，不用工程运行冒充导出包。

## 导出配置

- preset 文件：`export_presets.cfg`
- preset 名称：`macOS`
- 目标路径：`builds/mac/TheLastClassroom.app`
- 资源过滤：导出所有运行资源，排除 `docs/qa/screenshots/*`。
- 代码签名：关闭。当前只作为本机调试/展示包，不做分发签名或 notarization。

## 导出前验证

```bash
/usr/local/bin/godot --headless --path . --script res://scripts/tools/title_screen_smoke_test.gd
/usr/local/bin/godot --headless --path . --script res://scripts/tools/flow_smoke_test.gd
/usr/local/bin/godot --headless --path . --script res://scripts/tools/settings_menu_smoke_test.gd
```

预期：

```text
TITLE_SCREEN_SMOKE_TEST_OK
FLOW_SMOKE_TEST_OK
SETTINGS_MENU_SMOKE_TEST_OK
```

## 导出命令

```bash
mkdir -p builds/mac
/usr/local/bin/godot --headless --path . --export-debug macOS builds/mac/TheLastClassroom.app
```

## 当前状态

- 日期：2026-05-07
- 结论：macOS debug `.app` 已成功导出；导出包 GUI 人工完整流程验收已通过。

已完成：

- 已新增 `export_presets.cfg`，提供 `macOS` preset。
- 已创建本地导出目录 `builds/mac/`，并将 `builds/` 加入 `.gitignore`。
- 已启用 `textures/vram_compression/import_etc2_astc=true`，解决 universal/arm64 导出的 ETC2/ASTC 配置错误。
- 导出前 `TITLE_SCREEN_SMOKE_TEST_OK` 和 `SETTINGS_MENU_SMOKE_TEST_OK` 已通过。
- 用户已安装 Godot 4.6.2.stable 导出模板，`macos.zip` 已在 Godot 期望路径中。
- 2026-05-10 用户已完成 `.app` GUI 人工验收，确认效果与工程内启动一致。

导出尝试结果：

```text
Export completed successfully.
```

导出产物：

- 路径：`builds/mac/TheLastClassroom.app`
- 大小：约 204MB
- `builds/` 已加入 `.gitignore`，不提交导出产物。

导出包无窗口启动检查：

```bash
"builds/mac/TheLastClassroom.app/Contents/MacOS/The Last Classroom Prototype" --headless --quit-after 5 --log-file /private/tmp/lastclassroom-export.log
```

结果：

```text
exit code 0
```

注意：未指定 `--log-file` 直接 headless 运行时，导出模板在写 `user://logs` 阶段崩溃；当前以显式日志路径作为 CLI smoke 检查方式。GUI 人工验收仍应直接打开 `.app`。

## 验收

- [x] `.app` 能生成。
- [x] `.app` 能从标题页进入。
- [x] `.app` 能完成 A1-A12。
- [x] 设置菜单可调音量、切换窗口/全屏、返回标题或退出。

## 问题记录

```text
- [severity: low] 导出包 CLI 检查：直接 headless 运行导出二进制会在写默认 `user://logs` 时崩溃；加 `--log-file /private/tmp/lastclassroom-export.log` 后可正常退出。GUI 验收不受此命令行日志问题代表。
```
