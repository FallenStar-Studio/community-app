# Cloud Environment Setup / 云开发环境配置

Reviewed on 2026-09-30 against the current [official Cloud environments guide](https://learn.chatgpt.com/docs/environments/cloud-environments).

于 2026-09-30 对照新版官方 Cloud environments 指南核查。本轮完成配置方案准备，尚未创建或发布云环境。

## Benefit and boundary / 收益与边界

The current setup workflow inspects selected repositories, installs and checks dependencies, and records an Install script and Start skill. Publishing captures a prepared filesystem for isolated future tasks. It can reduce repeated tool installation and keep development working while the local computer sleeps.

新版 Setup 会检查选中的仓库、安装并核验依赖，可记录 Install script 与 Start skill。发布后，后续任务使用已准备的文件系统创建独立工作区，可减少反复安装工具的时间，并在本机休眠时继续开发。

For Plyra, use this for GDScript import checks, data/model checks, registry validation and source changes. The guide currently lists computer/browser use as unsupported. Setup therefore cannot replace the local logged-in Edge workflow for GitHub application administration. macOS IME and Android keyboard, rendering and device performance still need the corresponding local OS/device checks. This is a development environment; the Community app does not gain a server or runtime dependency.

Plyra 可以将 GDScript 资源导入检查、数据模型检查、注册表校验和源码工作放到云环境。指南当前将电脑/浏览器操作列为未支持，所以 Setup 不能替代本地已登录 Edge 的 GitHub 应用管理。macOS 输入法、Android 键盘、渲染和设备性能仍需在对应系统或设备检查。此环境用于开发，社区应用不会因此增加服务器或运行时依赖。

## Suggested onboarding input / 建议直接交给 Setup 的要求

Open **Settings > Codex Cloud > Environments > Create environment** (or **Work in > Cloud > Select environment > Create environment**). Select the three existing repositories:

打开上述配置入口，选取现有三个仓库：

- `FallenStar-Studio/community-app`
- `FallenStar-Studio/community`
- `FallenStar-Studio/mod-registry`

Keep environment access **Only me**. The public `J-x-Z/native_hub` repository is an optional reference checkout, not a dependency to embed in the Godot app.

环境访问设置为 **Only me**。公开的 `J-x-Z/native_hub` 可作为可选参考源码，不作为 Godot 应用的嵌入依赖。

Paste this setup brief / 可粘贴的配置要求：

> Prepare a Godot 4.7.2 standard development environment for these existing Plyra repositories. Use the engine version and official download already recorded in community-app/.github/workflows/godot-validation.yml. Import community-app's project resources headlessly and run its existing scripts/tests/test_runner.gd. Install Node.js to run mod-registry/scripts/validate-registry.mjs. Determine checkout paths from the actual workspace. Record the working installation commands and startup instructions in Install script and Start skill. Preserve the independent Godot Control/GDScript architecture and local demo fixtures. Public feed and registry reads should be tested without an administrator token or Client Secret. Do not claim OAuth sign-in, posting, commenting, Android input, macOS IME or device performance is validated by headless checks. Report tools, versions, commands, successes and remaining blockers before publishing the environment.

> 为三个现有 Plyra 仓库准备 Godot 4.7.2 标准版开发环境。使用 community-app/.github/workflows/godot-validation.yml 记录的引擎版本和官方下载。无界面导入 community-app 资源并运行现有 scripts/tests/test_runner.gd。安装 Node.js，运行 mod-registry/scripts/validate-registry.mjs。从实际工作区确定各仓库路径。将可用安装命令与启动说明保存为 Install script 和 Start skill。保持独立的 Godot Control/GDScript 架构和本地样例数据。使用游客身份检查公开 Feed 和注册表，不提供管理员 Token 或 Client Secret。无界面检查不能代表 OAuth 登录、发帖、评论、Android 输入、macOS 输入法或设备性能已验证。发布环境前报告工具、版本、命令、成功项及剩余阻碍。

OAuth Client ID `Ov23li9j7XtBsvn6LMck` is already public configuration in community-app. Setup does not issue GitHub Client IDs. User access tokens must not be put into exported assets or checked-in environment files.

OAuth Client ID `Ov23li9j7XtBsvn6LMck` 已作为公开配置保存在 community-app。Setup 不签发 GitHub Client ID。用户访问令牌不能进入导出资源或提交到仓库的环境文件。

## Existing commands / 已有命令

Run from the community-app checkout / 从 community-app 工作目录运行：

```sh
godot --version
godot --headless --path . --editor --quit
godot --headless --path . --script res://scripts/tests/test_runner.gd
```

Run from the mod-registry checkout / 从 mod-registry 工作目录运行：

```sh
node scripts/validate-registry.mjs
```

Feed checks require `raw.githubusercontent.com`; GitHub API work requires `api.github.com`, and Device Flow uses `github.com`. Review the destination hosts against the actual download/workflow commands during Setup. Network allowlisting supplies connectivity, not GitHub authorization.

Feed 检查需要 `raw.githubusercontent.com`，GitHub API 使用 `api.github.com`，Device Flow 使用 `github.com`。Setup 应根据实际下载和 workflow 命令核对目标域名。网络白名单提供连通性，不提供 GitHub 授权。
