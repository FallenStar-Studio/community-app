# Plyra Community App

**English · 简体中文**

Plyra Community App is an independent Godot client prototype for browsing Plyra community discussions and a MOD metadata catalog. The interface uses Godot 4 `Control` nodes and a reusable block-native theme. It does not require Plyra Compositor, Plyra World, Steam, a persistent community server, or a database.

Plyra Community App 是一个独立运行的 Godot 客户端原型，用于浏览 Plyra 社区讨论和 MOD 元数据目录。界面基于 Godot 4 `Control` 节点与可复用的方块风格 Theme。它不依赖 Plyra Compositor、Plyra World、Steam、常驻社区服务器或数据库。

## Status / 当前状态

| Area | Implemented / 已实现 | Planned or unverified / 规划或未验证 |
|---|---|---|
| Client / 客户端 | Godot 4.7.2 prototype; macOS app export; square block UI with a category rail, list and resizable reader; separate phone reading page; English/Simplified Chinese; explicit local Demo mode. / Godot 4.7.2 原型、macOS 导出、直角方块界面、分类栏/列表/可调阅读区、手机独立阅读页、中英文与显式本地 Demo 模式。 | Android, Windows and Linux exports and device/platform QA. / Android、Windows、Linux 导出及设备/平台验收。 |
| Public content / 公开内容 | Verified guest HTTP reads from the live Discussions feed and MOD registry; GraphQL category/list/detail adapters; visible source labels; local mock fallback; API error handling. / 已验证真实 Discussions Feed 与 MOD 注册表的游客 HTTP 读取；已实现 GraphQL 分类、列表和详情适配器、来源标识、本地 Mock 回退及 API 错误处理。 | Live authenticated GraphQL reads are not yet verified against an authorized account. / 尚未通过已授权账号验证实时 GraphQL 读取。 |
| GitHub account / GitHub 账号 | Organization-owned OAuth App registered; public Client ID configured; Device Flow entry verified; auth provider interface and sign-in entry point. / 组织 OAuth App 已注册、公开 Client ID 已配置、Device Flow 入口已验证，已有授权服务接口与登录入口。 | Client-side Device Flow, token handling, posting and commenting are not implemented or tested. / 客户端 Device Flow、令牌处理、发帖与评论尚未实现或测试。 |
| MODs / MOD | Read-only metadata display. / 只读元数据展示。 | Registry submissions are reviewed by pull request. This client does not install MODs. / 通过 Pull Request 审核注册表条目；本客户端不安装 MOD。 |
| Plyra ecosystem / Plyra 生态 | The community client is a standalone prototype. / 社区客户端为独立原型。 | Plyra Compositor, Plyra World and a released MOD ecosystem are not represented as released products. / Plyra Compositor、Plyra World 和 MOD 生态尚未正式发布。 |

## Run / 运行

Install Godot 4.7.2 stable (standard build, not .NET), import `project.godot`, and run the main scene. Or run:

安装 Godot 4.7.2 stable（标准版，无需 .NET），导入 `project.godot` 并运行主场景。也可执行：

```sh
godot --path .
```

To open the bundled offline preview / 打开内置离线演示：

```sh
godot --path . -- --demo --lang=zh
godot --path . --resolution 360x780 -- --demo --lang=en --page=mods
```

You can also change the content source in Settings. A successfully loaded empty public registry stays empty; the three local sample MODs appear only as clearly marked demo/fallback content. Phone-width previews on macOS are layout checks, not Android device verification.

也可在设置中切换内容来源。成功载入的空公开注册表保持为空；三条本地 MOD 样例只作为明确标注的演示/回退内容出现。macOS 手机宽度预览用于排版检查，不代表已完成 Android 设备验收。

Language selection and background motion are in Settings and saved locally. Native 2D block orbits default to Adaptive, freezing after four idle seconds. Continuous (15 FPS idle cap) and Off are optional; motion pauses when the window loses focus. `--motion=adaptive|continuous|off` previews without saving.

语言切换及背景动态放在设置中，保存本地偏好。原生 2D 方块轨道默认自适应，静止四秒后冻结；可选持续动态（静止上限 15 FPS）或关闭，窗口失去焦点时暂停。`--motion=adaptive|continuous|off` 仅预览，不保存。

Settings has an independent top-right entry. The graphite/soft-white theme uses ice-blue selected blocks and visible geometric orbits, with no rounded dashboard or 3D scene.

设置使用右上角独立入口。石墨黑/柔白主题结合冰蓝选中方块及可见几何轨道，采用原生直角模块。

The bundled demo content remains available offline. Public feed and MOD registry requests are enabled and target the organization repositories; live data replaces demo content for each source after a successful response. OAuth sign-in is not implemented. Never put a personal access token, administrator token, or client secret in this client.

本地演示内容可离线使用。公开 Feed 与 MOD 注册表请求已启用并指向组织仓库；对应请求成功后，该数据源显示实时内容。OAuth 登录尚未实现。不得将个人访问令牌、管理员令牌或 Client Secret 写入客户端。

## Project layout / 项目结构

- `scripts/models/` — discussion and MOD data models / 讨论与 MOD 数据模型
- `scripts/services/` — demo, GitHub feed, Discussions and authorization adapters / 演示、GitHub Feed、Discussions 与授权适配器
- `scripts/ui/`, `scenes/`, `themes/` — reusable Control views and design tokens / 可复用 Control 视图与设计 Token
- `data/demo/`, `data/registry/` — local demo fixtures / 本地演示数据
- `scripts/tests/` — headless data, adapter and bilingual layout checks / 无界面数据、适配器和双语布局检查

See [GitHub integration](docs/github-integration.md), [architecture](docs/architecture.md), and [verification report](TEST-REPORT.md).

See [Block UI / 方块界面](docs/block-native-ui.md) and [NativeHub integration review / NativeHub 融合评估](docs/nativehub-integration-review.md). The interaction patterns are independently implemented in Godot; no NativeHub Rust/egui source was copied. [Cloud environment assessment / 云环境评估](docs/cloud-environment-setup.md) recommends local development for now; no cloud environment is published.

See [JVAV background review / JVAV 背景融合评估](docs/jvav-integration-review.md) for the independent 2D adaptation and excluded network/game modules.

界面交互结构已在 Godot 中独立实现，未复制 NativeHub 的 Rust/egui 源码。云环境评估结论为当前继续本机开发，尚未发布云环境。

See the organization repositories for the community itself and the separately maintained MOD registry: [Plyra Community](https://github.com/FallenStar-Studio/community), [Plyra MOD Registry](https://github.com/FallenStar-Studio/mod-registry).

## License / 许可证

No license has been selected yet. Public visibility does not grant reuse rights. / 尚未指定许可证。仓库公开不代表授予复用权利。
