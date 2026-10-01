# Visual QA · Godot prototype

Date: 2026-09-25  
Host: macOS, Apple Silicon  
Engine: Godot 4.7.2 stable, standard build

The first sections below are historical checks of the September 25 UI. The September 30 migration section records the current interface and supersedes its homepage/hero and eight-second idle descriptions.

前几节为 9 月 25 日界面的历史检查。本文后面的 9 月 30 日移植验收记录当前界面，替代早期首页横幅和八秒静止描述。

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

## 2026-09-30 – 2026-10-01 UI migration / UI 移植验收

| Check / 检查 | Result / 结果 |
|---|---|
| Native migration / 原生移植 | Control category rail, selectable single list, resizable desktop reader and separate phone reader; graphite/soft-white square Theme, ice-blue focus/selection and account modal. Global Settings opens directly from the header. No NativeHub or JVAV source copied. / 分类栏、单列列表、可调桌面阅读区、手机独立阅读页；石墨黑/柔白直角主题、冰蓝焦点/选中及账号弹窗。页头独立设置入口直接打开设置页；未复制 NativeHub 或 JVAV 源码。 |
| Layout geometry / 布局几何 | **499 passed, 0 failed** at ten widths from 320 to 1360 px, both languages and all three pages. Includes direct global Settings, language controls confined to Settings, reader minimums, source separation, valid empty registry, safe text and motion suspension. / 十种宽度、两种语言及三个页面的 **499 项通过、0 项失败**，含独立设置入口、设置内语言按钮、阅读区、来源区分、空注册表、文本及动画暂停。 |
| Data/adapters / 数据与适配器 | Existing **33 passed, 0 failed**. / 原有 **33 项通过、0 项失败**。 |
| Export / 导出 | macOS universal release exported, `codesign --verify --deep --strict` passed; `lipo -archs` reports x86_64 and arm64. Tests/tools/export artifacts excluded from the application resource pack. / 通用包已导出并通过签名校验，包含两种架构；测试、工具及导出产物不进入应用资源包。 |
| Text and interaction / 文字与交互 | Actual macOS 1200×800 and 360×780 windows inspected; English/Chinese mixed titles, scrolling, MOD compatibility/license fields, local images and phone bottom navigation display correctly. / 实际窗口检查混排标题、滚动、MOD 字段、图片和手机导航，显示正常。 |
| Input / 输入 | Mixed Chinese/English paste and Latin typing verified in the exported TextEdit. Native IME composition/candidate popup was **not** observed, so full macOS IME verification remains pending. / 导出包 TextEdit 已确认混排粘贴和拉丁字母输入；未观察到原生输入法组字/候选窗，完整 macOS 输入法验收仍未完成。 |
| Live sources / 真实来源 | Exported client displays the two published guest-feed Discussions and five categories; the successful live registry stays at zero entries. Demo mode uses separately labelled fixtures and does not initiate public requests. / 导出客户端显示两条真实游客 Feed 讨论和五个分类；真实注册表保持零条；独立 Demo 模式显式标注样例并且不发起公开请求。 |
| Background / 背景 | Native 2D block core, 112 orbital blocks and angular rails are visible in the page/header and Settings preview. Actual Settings switches between Adaptive, Continuous and Off. Adaptive/off processing and focus suspension are covered by checks. / 原生 2D 方块核心、112 个轨道方块与几何轨道在页面/页头及设置预览可见；实际设置已切换自适应、持续和关闭模式，暂停及焦点处理纳入检查。 |
| Cloud environment / 云环境 | Deferred after the user's assessment request. Setup cancelled before starting; no Plyra environment created or published. Existing Actions now includes layout checks. / 根据用户评估要求暂缓，启动 Setup 前已取消；未创建或发布 Plyra 环境，现有 Actions 加入布局检查。 |

### Before orbital background / 加入轨道背景之前

Apple M4, exported macOS release, public-discussion page at 1200×800, no input focus and no ongoing interaction. Six `ps` CPU-time/RSS readings two seconds apart measured **0.06 CPU seconds over 10.061 wall seconds**, about **0.60% of one CPU core**, with **298.42–298.47 MiB RSS**. This is a short idle sample, not a comparative benchmark. Settings telemetry in the earlier 360×780 inspection displayed a 10 FPS cap and 11.6 MiB engine video memory. GPU utilization percentage has not been measured and cannot be inferred from the memory figure.

Apple M4，1200×800 的 macOS 导出包，公开讨论页，无输入焦点或持续交互。以两秒间隔读取六次进程 CPU 时间/RSS：**10.061 秒内使用 0.06 CPU 秒**，约为**单个核心的 0.60%**，RSS **298.42–298.47 MiB**。这是短时静止样本，不是对照基准。此前 360×780 的设置页检查显示 10 FPS 上限及 11.6 MiB 引擎显存；尚未测得 GPU 使用率，不能由显存数值推算。

### 2026-10-01 background resource samples / 背景资源样本

Apple M4, exported macOS release, 1200×800 public-discussion page after five idle seconds; no typing or scrolling during each sample. Six process CPU-time/RSS readings two seconds apart. Motion was selected through actual Settings; the window was activated for each sample.

Apple M4，最终 macOS 导出包，1200×800 公开讨论页，静止五秒后采样；采样期间无输入和滚动，以两秒间隔读取六次进程 CPU 时间/RSS。动态模式通过实际设置选择，每次采样前激活窗口。

| Mode / 模式 | CPU time / CPU 时间 | Mean of one core / 单核平均 | Resident memory / 驻留内存 |
|---|---|---|---|
| Adaptive, frozen / 自适应已冻结 | 0.04 s over 10.062 s | **0.40%** | **303.97 MiB** |
| Continuous, 15 FPS idle cap / 持续动态，15 FPS 静止上限 | 0.65 s over 10.068 s | **6.46%** | **304.73 MiB** |

These are short samples from one Mac session, not a general benchmark or a comparison against JVAV's web renderer. Adaptive remains the default. GPU utilization was not measured; engine video memory is not GPU utilization. No Android energy/thermal measurements were performed.

以上是一次 Mac 会话中的短时样本，不代表普遍基准，也不是与 JVAV 网页渲染的对照。默认保持自适应。未测得 GPU 使用率，引擎显存不代表 GPU 使用率；尚未测量 Android 功耗或温度。

Language remains under Settings → Language / 语言; Settings itself has an always-visible independent header entry. Language and motion preferences are saved locally. CLI previews and automated checks do not change saved preferences; search/input drafts remain session-only. GitHub login, app-originated posting/commenting, authenticated live GraphQL, Android keyboard/IME/devices and Windows/Linux builds still require the later stages. The macOS prototype remains ad-hoc signed, not notarized.

语言入口位于设置内，设置本身使用页头独立入口。语言和背景动态保存本地偏好；CLI 预览和自动检查不改变已保存的偏好，搜索及输入草稿只保留本次会话。GitHub 登录、应用内发帖/评论、真实授权 GraphQL、Android 键盘/输入法/设备及 Windows/Linux 构建仍需后续阶段；macOS 包仍为本地 ad-hoc 签名原型，未公证。
