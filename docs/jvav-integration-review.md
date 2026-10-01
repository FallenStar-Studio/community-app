# JVAV integration review / JVAV 融合评估

Reviewed 2026-09-30: [J-x-Z/jvav](https://github.com/J-x-Z/jvav), commit `dfbb3e926bb3f73a213f3e79512614fbea2727ca`. Source was inspected without running its JavaScript or games. No LICENSE file was found in this revision; no source or assets were copied.

2026-09-30 检查上述版本，只阅读源码，未运行其 JavaScript 或游戏。该版本未发现 LICENSE 文件；本轮未复制源码或资源。

| Module / 模块 | Source design / 原实现 | Plyra decision / Plyra 处理 |
|---|---|---|
| `saturn_bg.js` | Three.js sphere/rings, 100,000 particles, WebGL high-performance preference, UnrealBloomPass, continuous requestAnimationFrame. / 球体与环、十万粒子、WebGL、Bloom 及持续重绘。 | Independently adapt the orbital silhouette, layered rotation and subtle breathing into native Godot 2D blocks. / 将轨道轮廓、分层转动和轻微呼吸独立改写为 Godot 原生 2D 方块。 |
| `presence.js` | Public EMQX MQTT broker, shared presence topic, five-second heartbeats. / 公共 MQTT 服务、共享在线状态主题和五秒心跳。 | Omitted; public-broker presence does not establish authenticated GitHub identity. / 不接入；公共服务在线状态不能代表经过授权的 GitHub 身份。 |
| `live_canvas.js` | Shared drawing through MQTT over WebSockets. / 通过 MQTT WebSocket 共享画布。 | Omitted; this iteration needs read-only community browsing and adds no external realtime service. / 不接入；本轮社区浏览无需新增外部实时服务。 |
| Site/game scripts / 网站与游戏脚本 | Web-specific DOM and game logic. / 网页 DOM 及游戏逻辑。 | Omitted; no web runtime, remote scripts or unrelated game subsystem. / 不引入网页运行时、远程脚本或无关游戏系统。 |

## Implemented adaptation / 已实现的改写

`scripts/ui/components/block_orbits.gd` draws a fixed block core, 112 orbital blocks, a faint grid and static stars. It is an interactive-UI-safe decoration: clipping is local and pointer events pass through. Instances are used behind the page, in the compact desktop header and in the Settings preview. Normal content surfaces stay opaque for reading.

该 Control 绘制固定方块核心、112 个轨道方块、微弱网格和静态星点，局部裁切且不截获指针。用于页面背景、紧凑桌面页头和设置预览；正文表面保持不透明，保证阅读。

- **Adaptive / 自适应**: default; four idle seconds freeze animation and disable component processing. / 默认静止四秒后冻结，并停止组件处理。
- **Continuous / 持续动态**: optional; background redraw limited to 15 Hz, with a 15 FPS idle cap. / 主动可选，背景重绘上限 15 Hz，静止帧率上限 15。
- **Off / 关闭**: static decoration; no animation processing. / 静态装饰，不处理动画。
- All animation processing pauses on focus loss. Language and motion preferences are saved by `UiPreferences`; preview CLI arguments and checks do not save them. / 失去窗口焦点时暂停所有动画处理；语言及动态偏好由 `UiPreferences` 保存，CLI 预览参数和检查不保存。

No 3D renderer, shader, bloom pass, particle system, Rust extension, remote asset or MQTT connection is added. Current checks and short macOS CPU samples are in [TEST-REPORT.md](../TEST-REPORT.md); Android/GPU-utilization validation remains pending.

未新增 3D 渲染、Shader、Bloom、粒子系统、Rust 扩展、远程资源或 MQTT 连接。当前检查和 macOS 短时 CPU 实测见验收报告，Android 与 GPU 使用率验收仍待后续完成。
