# Rooftop Relay / 屋顶信使

A short 2D platform game set above Shenzhen after dark. Deliver three lost letters to the glowing mailbox, cross the gaps between rooftops, and avoid the spinning ventilation fans.

一款发生在深圳夜色屋顶上的短篇 2D 平台游戏。收集三封遗失的信，跨越楼顶间隙，避开旋转的通风扇，最后把信送进发光的邮箱。

![Rooftop Relay title screen](screenshot-title.png)

## Play / 操作

- Move: Left/Right arrows or A/D
- Jump: Space, W, or Up arrow
- Deliver all three letters at the mailbox to finish.
- Touching a fan costs one heart and returns you to the latest checkpoint. Three hearts are available; press **R** after game over to try again.
- 移动：左右方向键或 A/D；跳跃：空格、W 或上方向键。
- 收集三封信后抵达邮箱即可通关。碰到风扇会失去一颗心并回到最近的检查点；三颗心耗尽后按 **R** 重开。

## Run in Godot / 在 Godot 中运行

Open `project.godot` with Godot 4.3 or later (developed with Godot 4.7.2), then press **F6** to run the main scene or **F5** to run the project.

用 Godot 4.3 或更高版本打开 `project.godot`（本项目使用 Godot 4.7.2 制作），按 **F6** 运行当前主场景，或按 **F5** 运行项目。

## Run checks / 运行检查

```sh
godot --headless --path . --script res://tests/test_game_state.gd
godot --headless --path . --script res://tests/test_player_movement.gd
godot --headless --path . --script res://tests/test_main_flow.gd
```

## Web export / 网页导出

Use the **Compatibility** renderer and install the matching Godot export templates. In **Project → Export**, add a **Web** preset and export to `build/index.html`. Package the full `build/` directory as a ZIP for an HTML game upload. Single-threaded Web export is recommended for broad browser compatibility.

使用 **Compatibility** 渲染器并安装匹配版本的 Godot 导出模板。在 **Project → Export** 中添加 **Web** 预设，导出到 `build/index.html`。将整个 `build/` 目录打包成 ZIP 后作为 HTML 游戏上传。建议使用单线程网页导出以提高浏览器兼容性。

The generated `rooftop-relay-web.zip` is kept out of source control; rebuild it from the Web preset when preparing a release. / 网页发布包 `rooftop-relay-web.zip` 不纳入源码版本控制；发布时请用 Web 预设重新导出并打包。

## Credits / 说明

All visuals are drawn procedurally in GDScript. No external assets are required. / 所有画面均由 GDScript 程序绘制，无需外部素材。
