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

Next authorization work requires an OAuth App Client ID with Device Flow enabled. A native client must not contain a Client Secret, administrator token, or personal access token. For public-repository Discussions, GitHub documents the OAuth `public_repo` scope; evaluate GitHub App user authorization if a narrower permission model is required. Tokens should remain in the authorization service, never in UI scenes or content config.

下一阶段需要启用 Device Flow 的 OAuth App Client ID。原生客户端不得包含 Client Secret、管理员令牌或个人访问令牌。GitHub 文档说明，访问公开仓库 Discussions 需要 OAuth `public_repo` scope；若需更细粒度权限，应评估 GitHub App 用户授权。令牌应由授权服务管理，不能进入 UI 场景或内容配置。

## Configuration / 配置

`config/community_repository.json` contains public repository coordinates and URLs only. `repository_ready` and `requests_enabled` should only be enabled after both public repositories and the feed workflow are available. There is no server or database.

`config/community_repository.json` 仅保存公开仓库信息与 URL。只有在两个公开仓库和 Feed workflow 都就绪后，才应启用 `repository_ready` 与 `requests_enabled`。项目不使用服务器或数据库。

Relevant GitHub documentation:

- [Discussions GraphQL API](https://docs.github.com/en/graphql/guides/using-the-graphql-api-for-discussions)
- [OAuth scopes](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/scopes-for-oauth-apps)
- [Device Flow](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/authorizing-oauth-apps-using-the-device-flow)
