# Plyra Community App

**English · 简体中文**

Plyra Community App is an independent Godot client prototype for browsing Plyra community discussions and a MOD metadata catalog. The interface uses Godot 4 `Control` nodes and a reusable block-native theme. It does not require Plyra Compositor, Plyra World, Steam, a persistent community server, or a database.

Plyra Community App 是一个独立运行的 Godot 客户端原型，用于浏览 Plyra 社区讨论和 MOD 元数据目录。界面基于 Godot 4 `Control` 节点与可复用的方块风格 Theme。它不依赖 Plyra Compositor、Plyra World、Steam、常驻社区服务器或数据库。

## Status / 当前状态

| Area | Implemented / 已实现 | Planned or unverified / 规划或未验证 |
|---|---|---|
| Client / 客户端 | Godot 4.7.2 prototype; macOS app export; English/Simplified Chinese UI; bundled demo discussions and MOD cards. / Godot 4.7.2 原型、macOS 应用导出、英语/简体中文界面、本地演示讨论与 MOD 卡片。 | Android, Windows and Linux exports and device/platform QA. / Android、Windows、Linux 导出及设备/平台验收。 |
| Public content / 公开内容 | HTTP adapters for the community JSON feed and MOD registry; GraphQL response normalization; visible demo/live source labels; local mock fallback; API error handling. / 已实现社区 JSON Feed 与 MOD 注册表 HTTP 适配、GraphQL 响应解析、演示/线上来源标识、本地 Mock 回退和 API 错误处理。 | The community repositories and live requests are not configured until their public bootstrap is complete. / 社区仓库公开初始化完成前，不会启用线上请求。 |
| GitHub account / GitHub 账号 | Auth provider interface and sign-in entry point. / 授权服务接口与登录入口。 | Device Flow, token handling, posting and commenting are not implemented or tested. / Device Flow、令牌处理、发帖与评论尚未实现或测试。 |
| MODs / MOD | Read-only metadata display. / 只读元数据展示。 | Registry submissions are reviewed by pull request. This client does not install MODs. / 通过 Pull Request 审核注册表条目；本客户端不安装 MOD。 |
| Plyra ecosystem / Plyra 生态 | The community client is a standalone prototype. / 社区客户端为独立原型。 | Plyra Compositor, Plyra World and a released MOD ecosystem are not represented as released products. / Plyra Compositor、Plyra World 和 MOD 生态尚未正式发布。 |

## Run / 运行

Install Godot 4.7.2 stable (standard build, not .NET), import `project.godot`, and run the main scene. Or run:

安装 Godot 4.7.2 stable（标准版，无需 .NET），导入 `project.godot` 并运行主场景。也可执行：

```sh
godot --path .
```

The bundled demo content remains available offline. Current repository settings enable the public feed after bootstrap; OAuth remains disabled until configured. Never put a personal access token, administrator token, or client secret in this client.

本地演示内容可离线使用。公开 Feed 在仓库初始化后启用；OAuth 仍需配置。不得将个人访问令牌、管理员令牌或 Client Secret 写入客户端。

## Project layout / 项目结构

- `scripts/models/` — discussion and MOD data models / 讨论与 MOD 数据模型
- `scripts/services/` — demo, GitHub feed, Discussions and authorization adapters / 演示、GitHub Feed、Discussions 与授权适配器
- `scripts/ui/`, `scenes/`, `themes/` — reusable Control views and design tokens / 可复用 Control 视图与设计 Token
- `data/demo/`, `data/registry/` — local demo fixtures / 本地演示数据
- `scripts/tests/` — headless data and adapter checks / 无界面数据与适配器检查

See [GitHub integration](docs/github-integration.md), [architecture](docs/architecture.md), and [verification report](TEST-REPORT.md).

See the organization repositories for the community itself and the separately maintained MOD registry: [Plyra Community](https://github.com/FallenStar-Studio/community), [Plyra MOD Registry](https://github.com/FallenStar-Studio/mod-registry).

## License / 许可证

No license has been selected yet. Public visibility does not grant reuse rights. / 尚未指定许可证。仓库公开不代表授予复用权利。
