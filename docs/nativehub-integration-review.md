# NativeHub integration review / NativeHub 融合评估

Reviewed on 2026-09-30. Reference: [J-x-Z/native_hub](https://github.com/J-x-Z/native_hub), commit `0e30b0e7b73b3d7a4c21027eced89fe330c37db7`.

评估日期：2026-09-30。参考仓库与版本如上。本次已检查源码；未运行 NativeHub 的附带二进制，未验证其 README 中的平台与功能声明。

## Decision / 结论

Keep the independent Godot 4 client. Adapt NativeHub's useful interaction patterns and service boundaries to Control scenes and GDScript. Directly embedding its Rust/egui views would introduce a second UI runtime and does not provide a clear benefit for the present community client. A shared Rust library can be reconsidered when both projects need the same tested API/authentication core.

保留独立的 Godot 4 客户端，将 NativeHub 有价值的交互结构和服务边界应用到 Control 场景与 GDScript。直接嵌入 Rust/egui 界面会增加第二套 UI 运行环境，当前社区客户端尚无明确收益。两项目确实需要同一套经过验证的 API/授权核心时，再评估共享 Rust 库。

This is an integration assessment, not a completed UI redesign or authenticated client release. No NativeHub source code has been copied into the Godot app.

本文为融合评估，不表示界面重构或已授权客户端已经完成。尚未向 Godot 应用复制 NativeHub 源码。

## Reuse map / 可复用内容

| NativeHub evidence / 源码证据 | Godot adaptation / Godot 对应实现 | State / 状态 |
|---|---|---|
| `src/engine/mod.rs`: operations interface; `src/backend.rs`: action/event bridge | Keep API work in `GitHubDiscussionClient` and `AppServices`; views consume normalized `DiscussionEntry`/`ModEntry`. / API 留在服务层，界面使用规范化模型。 | Existing boundary; no Rust bridge required. / 已有边界，无需 Rust 桥接。 |
| `src/modules/auth.rs`: device-code request and polling states | Independently implement pending, slow-down, denied, expired and cancellation states in `GitHubAuthProvider`. / 在授权服务中独立实现等待、减速、拒绝、到期和取消。 | Planned. Client ID registration is complete; login is still a stub. / 规划；Client ID 已注册，登录仍是占位实现。 |
| `src/context.rs`, `src/backend.rs`: system keyring storage | Define a token-store interface; use platform credential storage only after platform validation. / 建立令牌存储接口，平台验证后接入安全存储。 | Planned. Never copy or import NativeHub/gh account tokens. / 规划；不复制或导入 NativeHub/gh 的账号令牌。 |
| `src/ui/app.rs`: side panels, central reading view and tabs | Desktop: category rail plus a linear thread list and resizable reading pane. Phone: list and reader on separate screens. / 桌面采用分类栏、线性帖子列表和可调宽度阅读区；手机采用列表、阅读分屏页面。 | Proposed next UI iteration. / 建议用于下一轮界面迭代。 |
| `src/ui/components.rs`: corner emphasis and strong pressed feedback | Native Control buttons with square StyleBoxFlat borders, a distinct focus ring, a left selection strip and a small press offset. / 使用直角描边、独立焦点框、选中侧边条和小幅按压位移。 | Pattern review complete; component migration pending. / 结构评估完成，组件移植待做。 |
| `src/ui/style.rs`, `src/i18n/strings.rs`: dark/cyan palette and keyed translations | Maintain shared Theme/design tokens and English/Simplified Chinese strings, with layout-specific minimum widths. / 统一 Theme、设计 Token 与中英文文案，按布局定义最小宽度。 | Existing Godot mechanisms; further consolidation planned. / Godot 已有对应机制，下一步进一步统一。 |
| `src/ui/image_loader.rs`: asynchronous loading state and cache | A bounded HTTPS image service with timeout, size limits, failure placeholders and repaint only when content changes. / 有界 HTTPS 图片服务，包含超时、大小上限、失败占位，仅在内容变化时更新。 | Planned; its Rust loader is not directly imported. / 规划，尚未导入 Rust 加载器。 |

## Issues to address before code reuse / 源码复用前需要处理的问题

- NativeHub uses REST models for repositories, files, Issues and PRs. No Discussions GraphQL implementation was found. Issue comments are a different API from Discussion comments. / NativeHub 的现有 REST 模型面向仓库、文件、Issue 和 PR；未发现 Discussions GraphQL 实现。Issue 评论与 Discussion 评论不能混用。
- Its Device Flow requests `repo user read:org`. Plyra's public community client should review a narrower permission request. Access to public Discussions with an OAuth App requires `public_repo`, which also permits broader public-repository operations. / 原 Device Flow 请求 `repo user read:org`；Plyra 应重新审阅权限。OAuth App 读取公开 Discussions 需要 `public_repo`，该权限也允许更广泛的公开仓库操作。
- `src/ui/app.rs` calls `ctx.request_repaint()` every frame, even though particles and CRT effects are commented out. `SystemStatusBar` explicitly uses fake metrics. / 即使粒子和 CRT 效果已注释，主界面仍每帧请求重绘；状态栏明确使用模拟指标。Plyra 应显示真实内容状态，保持静止页面低占用。
- `src/ui/repo_browser.rs` truncates descriptions using `&repo.description[..60]`, a byte index that may split a UTF-8 character. A port must use character-aware truncation or layout ellipsis. / 摘要按字节位置截断，可能切进中文等 UTF-8 字符；移植时应使用字符级处理或布局省略。
- NativeHub includes an Android build workflow, but its desktop layout and system-font lookup are not evidence that Android Chinese input, text rendering or reading works. / 仓库已有 Android 构建 workflow，但桌面布局与系统字体查找不能证明 Android 中文输入、文字显示或阅读已通过验收。
- `LICENSE` and `Cargo.toml` state GPL-3.0; the README says MIT. The Godot app has no chosen source license. Resolve the conflicting declarations before direct source copying. / 实际 LICENSE 与 Cargo 声明 GPL-3.0，README 却写 MIT；Godot 仓库尚未选择源码许可证。直接复制源码前应先统一这些声明。

## Concrete next UI iteration / 下一轮界面的具体方向

The community's primary view should begin with discussions. Use a compact title/tool strip, readable list rows, visible categories and a persistent selected item. Keep art as a small community cover or reading attachment. Counts belong beside the relevant section labels. Expose network/source/login state with ordinary text; keep project-development descriptions in About/help content.

社区主界面从讨论开始：紧凑标题和工具栏、清楚可读的列表行、可见分类、持久选中状态。艺术创作作为小型社区封面或阅读附件；数量放在对应分区标题旁。网络、来源与登录状态用普通文案表达；项目开发说明进入关于或帮助内容。

Desktop minimums should reserve a 180–220 px category rail, at least 340 px for a list, and at least 420 px for a reader when a split view fits. Below the combined minimum, use a single reading/list pane. On phones use one list column, a separate reader and a compact bottom navigation. Make reading text about 15–16 px at scale 1 with clear line spacing. These are proposed design tokens, not verified measurements of the current UI.

桌面分类栏建议 180–220 px，列表至少 340 px，双栏阅读区至少 420 px；不足合计最小宽度时切换为单个列表或阅读区。手机采用单列列表、独立阅读页和紧凑底部导航。正文在 1 倍缩放下建议约 15–16 px，保持清晰行距。以上是待实现的设计 Token，不是当前界面已经验证的尺寸。

Both language modes must use native wrapping and selection. Verify mixed Chinese/English titles, unbroken URLs, IME composition, a software keyboard and real empty/error states before describing the new layout as ready.

两种语言均使用原生换行与选中功能。新布局需要验证中英文混排标题、连续 URL、输入法组字、软键盘，以及真实空列表和错误状态，才能描述为可用。
