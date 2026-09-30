# GitHub integration / GitHub 接入状态

This document records the current implementation. It does not imply that sign-in or write operations are ready.

本文记录当前实现状态，不表示登录或写入功能已经可用。

## Read paths / 读取路径

- **Guest discussion feed:** `GitHubDiscussionClient` downloads `docs/feed.json` from `FallenStar-Studio/community` over HTTPS. GitHub Actions generates it from the repository's actual Discussions. The service maps category, title, body, author, URL and comment count, and labels the entries as GitHub feed content. An empty live feed stays empty; it is not silently replaced with demos.
- **游客讨论 Feed：** `GitHubDiscussionClient` 通过 HTTPS 下载 `FallenStar-Studio/community` 的 `docs/feed.json`。GitHub Actions 根据仓库中的真实 Discussions 生成此文件。服务映射分类、标题、正文、作者、链接和评论数，并标为 GitHub Feed 内容。线上列表为空时仍显示空列表，不会悄悄替换成演示内容。
- **MOD registry:** the app downloads the read-only JSON array from `FallenStar-Studio/mod-registry`. Invalid records are rejected; the bundled demo catalog remains available if the registry cannot be loaded.
- **MOD 注册表：** 客户端从 `FallenStar-Studio/mod-registry` 下载只读 JSON 数组。无效记录会被拒绝；无法读取注册表时保留本地演示目录。
- **Authenticated Discussions:** the GraphQL client contains category, first-page list, and discussion-detail queries. These require a currently authorized user. The detail query requests up to 100 comments and 50 replies per comment; additional-page UI is not wired yet.
- **已授权 Discussions：** GraphQL 客户端已包含分类、首屏列表和帖子详情查询，但需要有效的用户授权。详情查询最多读取 100 条评论、每条评论 50 条回复；尚未接入更多分页界面。

The HTTP/GraphQL adapter handles network failures, malformed JSON, HTTP errors, permission errors, and rate limits. Data-source badges distinguish GitHub, public-feed and demo records. A failed request preserves the bundled demo content for the affected source.

HTTP/GraphQL 适配器会处理网络失败、JSON 格式错误、HTTP 错误、权限错误和限流。来源标签会区分 GitHub API、公开 Feed 与演示数据。请求失败时，相应数据源保留本地演示内容。

## Authorization and writes / 授权与写入

`GitHubAuthProvider` is currently an interface stub. It has no Device Flow, token exchange, persistence, or refresh implementation. Creating discussions, comments, and replies from the app is not implemented. No write operation has been tested. The UI must continue to describe those actions as unavailable.

`GitHubAuthProvider` 目前只是接口占位，尚未实现 Device Flow、令牌交换、持久化或刷新。客户端内创建讨论、评论和回复的功能尚未实现，任何写入操作都没有经过测试。界面必须继续明确显示这些功能暂不可用。

The organization-owned **Plyra Community** OAuth App was registered on 2026-09-30 with user confirmation. Its public Client ID is `Ov23li9j7XtBsvn6LMck`; Device Flow and access-token expiration are enabled. The registered callback is `http://127.0.0.1:53682/oauth/callback` (Device Flow does not use the callback). No client secret was generated. Registration does not authorize an account or make sign-in available in this prototype.

经用户确认，组织所属的 **Plyra Community** OAuth App 已于 2026-09-30 注册。公开 Client ID 为 `Ov23li9j7XtBsvn6LMck`，已启用 Device Flow 与访问令牌到期。登记回调为 `http://127.0.0.1:53682/oauth/callback`（Device Flow 不使用回调）。未生成 Client Secret。应用注册不会授权任何账号，也不表示原型已支持登录。

Next authorization work must implement Device Flow polling, cancellation, expiration, identity validation and scoped user consent. A native client must not contain a Client Secret, administrator token, or personal access token. For public-repository Discussions, GitHub documents the OAuth `public_repo` scope, which also grants broader access to public repositories; evaluate GitHub App user authorization if a narrower permission model is required. Tokens should remain in the authorization service, never in UI scenes or content config. Access-token expiration must be handled before a successful login is described as ready.

下一步需要实现 Device Flow 轮询、取消、到期处理、身份校验和用户权限确认。原生客户端不得包含 Client Secret、管理员令牌或个人访问令牌。GitHub 文档说明，访问公开仓库 Discussions 需要 OAuth `public_repo` scope，该权限也涵盖更广泛的公开仓库操作；若需更细粒度权限，应评估 GitHub App 用户授权。令牌应由授权服务管理，不能进入 UI 场景或内容配置。只有实现访问令牌到期处理后，才能将成功登录描述为可用。

## Configuration / 配置

`config/community_repository.json` contains public repository coordinates, URLs and the non-secret OAuth Client ID only. `repository_ready` and `requests_enabled` should only be enabled after both public repositories and the feed workflow are available. There is no server or database.

`config/community_repository.json` 仅保存公开仓库信息、URL 与非秘密的 OAuth Client ID。只有在两个公开仓库和 Feed workflow 都就绪后，才应启用 `repository_ready` 与 `requests_enabled`。项目不使用服务器或数据库。

Relevant GitHub documentation:

- [Discussions GraphQL API](https://docs.github.com/en/graphql/guides/using-the-graphql-api-for-discussions)
- [OAuth scopes](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/scopes-for-oauth-apps)
- [OAuth authorization and Device Flow](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/authorizing-oauth-apps)
