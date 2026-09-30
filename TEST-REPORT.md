# Visual QA · Godot prototype

Date: 2026-09-25  
Host: macOS, Apple Silicon  
Engine: Godot 4.7.2 stable, standard build

## Verified in the exported app

| Check | Result |
|---|---|
| GDScript parse and asset import | Pass; Godot headless editor scan/import completed without script errors. |
| Headless data/security and GitHub adapter checks | Pass; 33 passed, 0 failed. This includes feed/API normalization, empty-feed behavior, comment provenance, registry validation and request gating. |
| macOS export and launch | Pass; the exported app launched as a universal x86_64 + arm64 bundle. Bundle ID: `org.plyra.community`. |
| English / Chinese switch | Pass; the home, discussion list, discussion detail, MOD list and MOD detail were inspected in both languages. Sample titles, bodies, authors, categories and MOD metadata switch with the UI. |
| Artwork integration | Pass; the home hero uses a new project-bundled voxel forest and waterfall illustration derived from the reference image's mood and palette. |
| Discussion / MOD content | Pass; local demo cards, filters, detail views, long text and the bundled article image render in the packaged app. |
| Public GitHub data adapters | Pass; the Godot HTTP client fetched the live community feed (2 Discussions, 5 GitHub categories) and the separate live MOD registry (0 entries). This verifies guest-feed and empty-registry reads, not authenticated GraphQL access. |
| Live-data UI | Pass; the refreshed macOS app displayed both real public-feed Discussions and the valid empty MOD registry without inserting demo cards into either successful live result. |
| Long mixed-language title | Pass; the discussion detail header now wraps long English/Chinese titles and keeps the language switch and account button within the desktop window. |
| Idle frame pacing | Pass; after 8 seconds without input, the app returns to a 10 FPS cap. Mouse movement, keyboard and touch input raise the cap to 60 FPS. |

## Idle resource sample

After leaving the exported app idle for about 8 seconds, Godot telemetry showed 10 FPS, 4.59 ms/frame and 22.3 MiB video memory. A fresh `top -l 6 -s 2 -pid <app-pid>` sample reported 0.0–5.2% process CPU (about 4.1% average across six readings) and about 338 MiB resident memory.

This is one short macOS session, not a comparative benchmark. GPU utilization percentage was not measured: macOS `powermetrics` required superuser privileges, and the Godot video-memory figure is not GPU utilization.

## Still pending

- Native macOS Chinese IME composition, candidate windows and long-form input remain unverified; the Settings page only provides a local input area.
- Android export and device checks (IME, soft keyboard, touch, long reading and images) are not yet done. Windows and Linux exports have not been built.
- GitHub feed and MOD registry HTTP adapters were verified against the public repositories. The live Discussions detail page showed its published bilingual body and zero comments. GraphQL read-query normalization is covered with local payload tests, but has not been verified against an authorized live account. OAuth Device Flow and app-originated posting/commenting are not implemented; no client write operations were tested.
- The macOS bundle is ad-hoc signed and not notarized; it is for local prototype use.

Bundled demo fixtures remain available for offline mode, failed requests and automated tests. In the verified online run, the two displayed Discussions came from the GitHub public feed and the MOD page showed zero entries from the valid live registry response. MOD source/download URLs and hashes are empty; nothing in the prototype downloads or installs MODs.

## 2026-09-30 OAuth registration / OAuth 注册核验

- With user confirmation, registered **Plyra Community** under **FallenStar-Studio**. Client ID: `Ov23li9j7XtBsvn6LMck`. Verified Device Flow enabled and access-token expiration active (8 hours). No client secret was generated. / 经用户确认，在组织下注册应用；已核验 Device Flow 与 8 小时访问令牌到期设置。未生成 Client Secret。
- `POST https://github.com/login/device/code`, using the public Client ID and no requested scopes, returned HTTP 200 with the expected code/URL/expiry/interval fields. The code was not authorized or polled; no access token was obtained. Device and user codes were not retained in the report. / 公开 Client ID 请求设备验证码接口返回 HTTP 200 及预期字段；未请求 scope，未授权或轮询，未获得访问令牌。报告未保存设备码或用户验证码。
- Configured the public Client ID in the Godot project and corrected English/Chinese account status and sign-in messages to distinguish registered configuration from the unimplemented login flow. / 已写入公开 Client ID，并修正中英文授权状态与登录提示，明确区分注册配置和未实现的登录流程。
- Re-ran Godot resource import and the existing headless suite: **33 passed, 0 failed**. Re-exported the macOS universal prototype. These checks do not verify interactive login or platform input. / 再次导入 Godot 资源并运行现有无界面检查：**33 通过、0 失败**；重新导出 macOS 通用原型。这些检查不能代表交互式登录或平台输入已经验证。
- Client-side Device Flow, access-token storage/refresh, authenticated GraphQL browsing, posting and commenting remain unimplemented or unverified as recorded above. / 客户端 Device Flow、令牌存储/刷新、授权 GraphQL 浏览、发帖与评论仍按上文记载处于未实现或未验证状态。
- NativeHub source integration was assessed; no source was copied, no broad UI restructuring was performed and no Rust extension was added. The Cloud Environment Setup brief was prepared; no cloud environment was created or published. / 已评估 NativeHub 融合，未复制源码、未进行大规模界面重构、未增加 Rust 扩展；已准备 Cloud Environment Setup 配置要求，尚未创建或发布云环境。
