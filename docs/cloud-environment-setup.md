# Cloud environment decision / 云环境评估

Reviewed on 2026-09-30 against the [official Cloud environments guide](https://learn.chatgpt.com/docs/environments/cloud-environments) and this project's actual dependencies.

评估日期：2026-09-30，已对照官方文档和当前项目的实际依赖。

## Decision: defer / 结论：暂缓启用

Continue local Godot development and the existing GitHub Actions checks. No Plyra cloud environment has been created or published. The repository-selection dialog was cancelled before starting Setup; no cloud secrets or additional repository permissions were configured.

继续使用本机 Godot 开发和已有 GitHub Actions 检查。尚未创建或发布 Plyra 云环境；在启动 Setup 之前已取消仓库选择窗口，没有配置云端密钥或新增仓库权限。

| Current need / 当前需求 | Suitable execution / 合适的执行位置 |
|---|---|
| Native Control UI, actual macOS layout, text selection and IME / 原生 UI、macOS 实际排版、文本选中和输入法 | Local Mac / 本机 Mac |
| Data models, resource import, layout geometry / 数据模型、资源导入、布局几何 | Local Godot plus existing Actions / 本机 Godot 加已有 Actions |
| Android keyboard and device rendering/performance / Android 键盘、设备渲染与性能 | Android device or emulator, still pending / Android 设备或模拟器，仍待验收 |
| Long background coding while the Mac sleeps, multiple contributors needing identical dependencies / 本机休眠期间长时间开发、多人统一依赖 | A future cloud environment can help / 后续云环境可提供收益 |

The new Setup workflow can install dependencies and capture a prepared environment for isolated future tasks. Its current guide lists computer/browser use as unsupported. These capabilities are useful for asynchronous source work, but they do not validate the local UI, macOS IME or an Android keyboard. For this UI migration, the local toolchain already meets the requirements, so the extra environment has limited immediate value.

新版 Setup 可安装依赖并保存准备好的环境，供后续隔离任务使用。当前指南将电脑/浏览器操作列为未支持。它适合异步源码开发，但不能验证本机 UI、macOS 输入法或 Android 键盘。本轮 UI 移植的本地工具链已经够用，新增环境的即时收益有限。

## Repository scope if needed later / 后续启用时的仓库范围

Use **only `FallenStar-Studio/community-app`** for client development. It includes the Godot project, service interfaces, fixtures and checks. `community` supplies a guest JSON feed over HTTPS; `mod-registry` supplies reviewed JSON metadata. Neither must be checked out to edit or run the client. Keep the repositories separate and check out another repository only for a task that changes that repository's own content or workflow.

客户端开发只需选择 **`FallenStar-Studio/community-app`**：Godot 工程、服务接口、样例和检查脚本都在这里。`community` 通过 HTTPS 提供游客 JSON Feed，`mod-registry` 提供审核后的 JSON 元数据；编辑或运行客户端无需检出它们。保持仓库各自独立，任务确实要修改某个仓库的内容或 workflow 时，再处理那个仓库。

`J-x-Z/native_hub` is a design reference, not a runtime or build dependency. No Rust/egui environment is needed for the Godot UI.

`J-x-Z/native_hub` 是设计参考，不是运行或构建依赖；Godot UI 无需准备 Rust/egui 环境。

If asynchronous development later justifies it, create one private **Only me** environment from **Settings → Codex Cloud → Environments**. Pin the standard Godot version and download already used in `.github/workflows/godot-validation.yml`, then run:

后续有异步开发需求时，可从上述入口创建一个私有 **Only me** 环境。固定标准版 Godot 版本及已有 workflow 的下载来源，然后运行：

```sh
godot --version
godot --headless --path . --editor --quit
godot --headless --path . --script res://scripts/tests/test_runner.gd
godot --headless --path . res://scripts/tests/ui_layout_checks.tscn -- --demo
```

Review the actual tool-download hosts and public-content HTTPS hosts during Setup. Public reads need no administrator token or Client Secret. OAuth Client ID `Ov23li9j7XtBsvn6LMck` is already public client configuration; Setup does not create GitHub OAuth identities.

Setup 时按实际工具下载和公开内容请求核对联网域名。公开读取无需管理员 Token 或 Client Secret。OAuth Client ID 已属于公开客户端配置；Setup 不负责创建 GitHub OAuth 身份。

The client remains independently runnable regardless of this decision. A Codex development environment does not provide a community server, database, public app hosting, or Android/macOS device QA.

无论是否启用云开发环境，客户端均可独立运行。Codex 开发环境不提供社区服务器、数据库、公开应用托管或 Android/macOS 设备验收。
