# Architecture boundary / 架构边界

## Current implementation / 当前实现

- `DiscussionEntry` and `ModEntry` normalize app-facing data. `ModEntry` validates HTTPS source/download metadata and a SHA-256 digest; it never executes or installs packages.
- `DiscussionEntry` 与 `ModEntry` 规范化界面使用的数据。`ModEntry` 校验 HTTPS 来源/下载元数据和 SHA-256 摘要；它不会执行或安装软件包。
- `CommunityService` is the stable view-facing interface. `DemoCommunityService` reads bundled fixtures; `GitHubCommunityService` combines those fixtures with validated feed/API responses and preserves source provenance.
- `CommunityService` 是稳定的 UI 数据接口。`DemoCommunityService` 读取随应用附带的样例；`GitHubCommunityService` 将这些样例与经过校验的 Feed/API 响应组合，并保留内容来源。
- `GitHubDiscussionClient` owns HTTP and GraphQL transport. `AppServices` is the composition root. Scenes and reusable Control components render data but do not construct API requests.
- `GitHubDiscussionClient` 负责 HTTP 与 GraphQL 请求；`AppServices` 作为服务组合入口。场景和可复用 Control 组件只展示数据，不直接构造 API 请求。
- Public unauthenticated browsing uses a generated static JSON feed. Authenticated GraphQL queries are gated behind the auth provider, which is currently a stub. Write mutations are not implemented.
- 游客通过生成的静态 JSON Feed 浏览公开内容。需要授权的 GraphQL 查询由授权服务控制，但当前授权服务仍是占位实现。发帖和评论 mutation 尚未实现。
- Presentation uses Godot Control nodes, shared Theme styles, design tokens and modular scenes. The prototype is a lightweight 2D application with GL Compatibility; no 3D world, compositor hook or background polling is used.
- 展示层使用 Godot Control 节点、共享 Theme 样式、设计 Token 与模块化场景。原型采用 GL Compatibility 轻量 2D 配置，不含 3D 世界、合成器接口或后台轮询。

## Intended boundaries / 设计边界

- Keep account authorization and external content sources behind service interfaces.
- 账号授权和外部内容来源必须位于服务接口之后。
- Keep the Community client independently launchable; integration with Plyra Desktop or Plyra World must remain optional.
- Community 客户端应可独立启动；与 Plyra Desktop、Plyra World 的集成保持可选。
- The `FallenStar-Studio/community` repository owns public discussion text and the generated guest feed. The separate `FallenStar-Studio/mod-registry` repository owns reviewed MOD metadata. Neither requires a persistent application server or database.
- `FallenStar-Studio/community` 仓库保存公开讨论和生成后的游客 Feed；独立的 `FallenStar-Studio/mod-registry` 仓库保存经过审核的 MOD 元数据。两者都不需要常驻应用服务器或数据库。
- Plyra Compositor, Plyra World and a released MOD ecosystem remain future work and are not prerequisites or released products.
- Plyra Compositor、Plyra World 和正式发布的 MOD 生态都属于未来规划，不是客户端前置条件或已发布产品。
