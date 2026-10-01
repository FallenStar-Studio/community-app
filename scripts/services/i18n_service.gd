extends Node

signal language_changed(language_code: String)

var language_code := "en"

func _ready() -> void:
	language_code = UiPreferences.language_code

const COPY := {
	"nav_home": ["Home", "首页"],
	"nav_discussions": ["Discussions", "社区讨论"],
	"nav_mods": ["MOD Library", "MOD 目录"],
	"nav_settings": ["Settings", "设置"],
	"sidebar_explore": ["EXPLORE", "探索"],
	"sidebar_workspace": ["YOUR SPACE", "你的空间"],
	"brand_subtitle": ["COMMUNITY FOR WORLDS IN PROGRESS", "为正在构建的世界而生"],
	"preview_badge": ["LOCAL PREVIEW", "本地预览"],
	"guest_mode": ["Guest mode", "游客模式"],
	"github_soon": ["Guest access · sign-in is not configured", "游客浏览 · 登录尚未配置"],
	"page_home": ["A place for worlds in progress", "为构建中的世界而生"],
	"page_discussions": ["Community discussions", "社区讨论"],
	"page_mods": ["MOD Library", "MOD 目录"],
	"page_settings": ["Settings & preview", "设置与预览"],
	"breadcrumb_home": ["PLYRA / COMMUNITY", "PLYRA / 社区"],
	"breadcrumb_discussions": ["COMMUNITY / DISCUSSIONS", "社区 / 讨论"],
	"breadcrumb_mods": ["PLYRA / MOD REGISTRY", "PLYRA / MOD 注册表"],
	"breadcrumb_settings": ["APP / PREFERENCES", "应用 / 偏好设置"],
	"account_connect": ["Connect account", "连接账号"],
	"hero_eyebrow": ["A COMMUNITY, BUILT INTO YOUR WORLD", "让社区，成为世界的一部分"],
	"hero_title": ["Make room for\nwhat comes next.", "为下一段创造\n留出空间。"],
	"hero_body": ["Follow the ideas, builds and people shaping Plyra — in one calm, independent space.", "在一个独立、自在的空间里，关注塑造 Plyra 的创意、作品与创作者。"],
	"hero_body_compact": ["Ideas, builds and creators shaping Plyra.", "关注 Plyra 的创意、作品与创作者。"],
	"hero_primary": ["Explore discussions", "浏览社区讨论"],
	"hero_secondary": ["Browse MODs", "探索 MOD 目录"],
	"plaque_block": ["BLOCK / 01", "方块 / 01"],
	"plaque_title": ["PLYRA COMMUNITY", "PLYRA 社区"],
	"plaque_caption": ["WORLDS IN PROGRESS", "构建中的世界"],
	"metric_discussions": ["COMMUNITY DISCUSSIONS", "社区讨论"],
	"metric_mods": ["CREATOR MODS", "创作者 MOD"],
	"metric_mode": ["SERVERLESS BY DESIGN", "无需常驻服务器"],
	"home_latest": ["Latest conversations", "最近的讨论"],
	"view_all": ["View all", "查看全部"],
	"home_note_title": ["A lighter home for the Plyra community", "为 Plyra 社区打造的轻量空间"],
	"home_note_body": ["A reusable Godot interface, ready to grow from a local preview into the community layer for Plyra Desktop and Plyra World.", "以可复用的 Godot 界面为基础，从本地预览逐步成长为 Plyra Desktop 与 Plyra World 的社区层。"],
	"local_sample": ["Local sample", "本地样例"],
	"intro_discussions": ["Browse ideas, development notes and creator questions. Every entry is marked as local demo content or GitHub content.", "浏览创意、开发动态和创作者提问。每条内容都会标明来自本地演示或 GitHub。"],
	"intro_mods": ["A curated directory for community-made themes, tools and world assets.", "收录社区创作的主题、工具与世界资源。"],
	"intro_settings": ["A standalone client. Once enabled, GitHub requests are limited to community content; search stays local.", "独立社区客户端。启用接入后，GitHub 请求仅用于社区内容；搜索只在本地执行。"],
	"search_discussions": ["Search discussions, authors or topics…", "搜索讨论、作者或主题…"],
	"search_mods": ["Search MODs, creators or categories…", "搜索 MOD、创作者或类别…"],
	"filter_all": ["All topics", "全部分类"],
	"category_announcement": ["Announcements", "官方公告"],
	"category_devlog": ["Devlogs", "开发日志"],
	"category_help": ["Help & guides", "使用帮助"],
	"category_ideas": ["Ideas", "点子交流"],
	"discussion_count": ["%d discussions", "%d 条讨论"],
	"discussion_count_demo": ["%d demo discussions", "%d 条演示讨论"],
	"discussion_count_live": ["%d GitHub discussions", "%d 条 GitHub 讨论"],
	"mod_count": ["%d sample MODs", "%d 条 MOD 样例"],
	"mod_count_live": ["%d registry entries", "%d 条注册表条目"],
	"empty_discussion_title": ["No discussions found", "没有找到讨论"],
	"empty_discussion_body": ["Try another search or choose all topics.", "试试其他关键词，或选择全部分类。"],
	"empty_mod_title": ["No MODs found", "没有找到 MOD"],
	"empty_mod_body": ["Try another search or category.", "试试其他关键词或分类。"],
	"demo_tag": ["DEMO", "演示"],
	"github_tag": ["GITHUB", "GitHub 内容"],
	"github_feed_tag": ["PUBLIC FEED", "公开 Feed"],
	"github_registry_tag": ["REGISTRY", "注册表"],
	"comments_replies": ["Comments & replies", "评论与回复"],
	"comment_count": ["%d comments", "%d 条评论"],
	"demo_post": ["Demo post", "演示帖子"],
	"demo_comment": ["Demo comment", "演示评论"],
	"back_discussions": ["←  All discussions", "←  返回讨论列表"],
	"back_mods": ["←  Back to MOD library", "←  返回 MOD 目录"],
	"reply_button": ["Reply to discussion", "回复这条讨论"],
	"reply_notice": ["Creating posts and comments is not implemented or tested yet.", "发帖与评论尚未实现，也未经过测试。"],
	"no_comments": ["No comments yet.", "暂无评论。"],
	"mod_safety_title": ["A curated index, not an installer", "精选索引，而非安装器"],
	"mod_safety_body": ["The directory only reads published metadata. This client does not download or install MODs.", "目录只读取已发布的元数据；本客户端不会下载或安装 MOD。"],
	"demo_no_download": ["DEMO · NO DOWNLOAD", "演示 · 无下载"],
	"mod_details": ["Details", "条目详情"],
	"source_verification": ["Source & verification", "来源与校验"],
	"source_url": ["Source URL", "源代码地址"],
	"download_url": ["Download URL", "下载地址"],
	"sha256": ["SHA-256", "SHA-256"],
	"not_provided": ["Not provided", "未提供"],
	"author": ["Author", "作者"],
	"version": ["Version", "版本"],
	"target": ["For", "目标组件"],
	"compatibility": ["Compatibility", "兼容性"],
	"license": ["License", "许可证"],
	"download_unavailable": ["Downloads unavailable", "下载尚未开放"],
	"github_connection": ["GitHub connection", "GitHub 连接"],
	"authorization": ["Authorization", "授权"],
	"not_connected": ["Guest · Not signed in", "游客 · 尚未登录"],
	"auth_setup_pending": ["Client ID configured · Sign-in implementation pending", "Client ID 已配置 · 登录实现待完成"],
	"content_source": ["Content source", "内容来源"],
	"online_repository": ["Online repository", "线上仓库"],
	"not_configured": ["FallenStar-Studio/community · pending setup", "FallenStar-Studio/community · 等待初始化"],
	"github_guide": ["Sign in with GitHub", "使用 GitHub 登录"],
	"refresh_content": ["Refresh community content", "刷新社区内容"],
	"refresh_requested": ["Refresh requested.", "已请求刷新。"],
	"connected_as": ["Connected as GitHub user", "已连接 GitHub 账号"],
	"status_live_feed": ["Public GitHub feed", "GitHub 公开 Feed"],
	"status_live_api": ["Live GitHub Discussions API", "GitHub Discussions 实时 API"],
	"status_live_registry": ["Public MOD registry", "公开 MOD 注册表"],
	"status_demo_fallback": ["Local demo fallback · no live data was loaded", "本地演示回退 · 尚未载入实时数据"],
	"status_pending": ["Waiting for repository setup approval", "等待仓库初始化确认"],
	"status_network_error": ["Network unavailable · showing local demo data", "网络不可用 · 显示本地演示数据"],
	"status_permission_error": ["GitHub access is missing · showing local demo data", "缺少 GitHub 权限 · 显示本地演示数据"],
	"status_rate_limit": ["GitHub rate limit reached · showing cached data", "GitHub 请求已限流 · 显示缓存数据"],
	"status_empty": ["GitHub returned an empty discussion list", "GitHub 讨论列表为空"],
	"status_other_error": ["GitHub request failed · showing local demo data", "GitHub 请求失败 · 显示本地演示数据"],
	"ime_title": ["Chinese & English input", "中英文输入体验"],
	"ime_body": ["Type or paste text here. It stays in this app session and is never saved or sent.", "可在此输入或粘贴文本。内容仅保留在当前应用中，不会保存或发送。"],
	"ime_placeholder": ["Try Chinese IME composition, candidates and long-form editing…", "试试中文输入法、候选词与长文本编辑…"],
	"characters": ["%d characters · session only", "%d 个字符 · 仅本次运行保留"],
	"appearance_title": ["Visual language & reusable UI", "视觉体系与可复用界面"],
	"appearance_body": ["Graphite blocks · GL Compatibility · native Godot Control UI", "石墨方块主题 · GL Compatibility · 原生 Godot Control 界面"],
	"appearance_components": ["Shared Theme · modular cards · reusable scenes", "统一 Theme · 模块化卡片 · 可复用场景"],
	"performance_title": ["Lightweight rendering & engine telemetry", "轻量渲染与引擎遥测"],
	"performance_note": ["Engine memory is not the same as system GPU utilization.", "引擎显存指标不等同于系统 GPU 利用率。"],
	"fps_line": ["FPS %d  ·  %.2f ms/frame  ·  VRAM %.1f MiB", "FPS %d  ·  %.2f 毫秒/帧  ·  显存 %.1f MiB"],
	"no_demo_discussions": ["No demo discussions are available.", "暂无演示讨论。"],
	"no_demo_comments": ["No demo comments yet.", "暂无演示评论。"],
	"image_caption": ["Plyra world · community artwork", "Plyra 世界 · 社区视觉创作"],
	"footer_local": ["LOCAL PREVIEW  ·  Bundled sample content", "本地预览 · 项目内置演示内容"],
	"toast_github": ["GitHub OAuth is not configured yet. Guest content remains available.", "GitHub OAuth 尚未配置。你仍可使用游客内容。"],
	"toast_device_flow_pending": ["OAuth App registered. Device Flow is not implemented yet; guest browsing is available.", "OAuth App 已注册，Device Flow 尚未实现；目前可使用游客浏览。"],
	"toast_write": ["This demo cannot publish to GitHub.", "当前演示版本不会向 GitHub 发布内容。"],
	"status_guest": ["Browsing as guest", "当前为游客浏览"],
	"status_offline": ["Offline-ready preview", "离线可浏览预览版"],
	"mod_type_theme": ["Desktop theme", "桌面主题"],
	"mod_type_widget": ["Desktop widget", "桌面小组件"],
	"mod_type_world": ["World asset", "世界资源"],
	"topics": ["TOPICS", "讨论分类"],
	"mod_types": ["MOD TYPES", "MOD 类型"],
	"read_discussion": ["Select a discussion to read", "选择一条讨论开始阅读"],
	"read_mod": ["Select a MOD to inspect", "选择一个 MOD 查看详情"],
	"reader_hint": ["Choose an entry from the list. Drag the divider to adjust the reading width.", "从列表中选择内容，拖动分隔线可调整阅读区宽度。"],
	"open_github": ["Open on GitHub ↗", "在 GitHub 打开 ↗"],
	"source_public": ["Public GitHub content", "GitHub 公开内容"],
	"source_demo": ["Local Demo · offline", "本地 Demo · 离线"],
	"source_demo_note": ["Bundled sample content. Nothing is published or downloaded.", "项目内置样例，不会发布或下载内容。"],
	"source_public_note": ["Guest feed from community; MOD metadata from mod-registry. Search runs locally.", "游客 Feed 来自 community，MOD 元数据来自 mod-registry；搜索在本地完成。"],
	"source_demo_status": ["LOCAL DEMO · offline sample content", "本地 DEMO · 离线样例内容"],
	"source_loading": ["Loading public content… · entries marked DEMO are local samples", "正在载入公开内容… · 标记 DEMO 的条目为本地样例"],
	"source_cached_error": ["GitHub request failed · keeping loaded content", "GitHub 请求失败 · 保留已载入内容"],
	"empty_registry": ["The live registry has no accepted MODs yet. You can preview sample entries in Settings → Local Demo.", "真实注册表暂无已收录 MOD。可在设置中切换“本地 Demo”查看样例。"],
	"language": ["Language / 语言", "语言 / Language"],
	"guest_short": ["Guest", "游客"],
	"back_list": ["← List", "← 列表"],
	"read_label": ["READING", "阅读区"],
	"close": ["Close", "关闭"],
	"account_title": ["GitHub account", "GitHub 账号"],
	"account_body": ["You can browse public content as a guest. The OAuth App is registered; in-app sign-in, posting and commenting are still pending. Use GitHub in your browser to participate.", "可使用游客身份浏览公开内容。OAuth App 已注册，应用内登录、发帖和评论仍待实现。参与讨论请在浏览器中使用 GitHub。"],
	"read_more": ["READ →", "阅读 →"],
	"app_about": ["ABOUT PLYRA", "关于 PLYRA"],
	"app_about_body": ["An independent Godot community client prototype. Plyra Compositor, World and the MOD ecosystem are still in development.", "独立运行的 Godot 社区客户端原型。Plyra Compositor、World 与 MOD 生态仍在开发中。"],
	"art_label": ["PLYRA / WORLD ART", "PLYRA / 世界视觉"],
	"source_retry": ["Retry", "重试"],
	"source_refresh": ["Refresh", "刷新"],
	"background_motion": ["Background motion", "背景动态"],
	"motion_adaptive": ["Adaptive · pause when idle", "自适应 · 静止后暂停"],
	"motion_continuous": ["Continuous · 15 FPS idle cap", "持续动态 · 静止上限 15 FPS"],
	"motion_off": ["Off · static background", "关闭 · 静态背景"],
	"motion_note": ["Subtle 2D block orbits. Adaptive freezes after four idle seconds. Continuous motion uses more resources; all motion pauses when the window loses focus.", "轻微的 2D 方块轨道。自适应模式在静止四秒后冻结；持续动态会增加占用，窗口失去焦点时暂停。"],
	"background_preview": ["BLOCK ORBITS / PREVIEW", "方块轨道 / 预览"]
}

func text(key: String) -> String:
	var pair: Array = COPY.get(key, [key, key])
	return str(pair[1] if language_code == "zh" else pair[0])

func field(record: Dictionary, key: String) -> String:
	var suffix := "_zh" if language_code == "zh" else "_en"
	var localized_key := key + suffix
	if record.has(localized_key) and not str(record[localized_key]).is_empty():
		return str(record[localized_key])
	var raw := str(record.get(key, ""))
	if not raw.is_empty():
		return raw
	return str(record.get(key + ("_en" if language_code == "zh" else "_zh"), ""))

func category_label(name: String, code: String = "") -> String:
	var language := code if not code.is_empty() else language_code
	var english_to_chinese := {
		"Announcements": "官方公告",
		"General": "综合交流",
		"Ideas & Feedback": "创意与反馈",
		"Development": "开发动态",
		"Help & Support": "帮助与支持",
		"Devlogs": "开发日志",
		"Help & guides": "使用帮助",
		"Ideas": "点子交流"
	}
	var chinese_to_english := {
		"官方公告": "Announcements",
		"综合交流": "General",
		"创意与反馈": "Ideas & Feedback",
		"开发动态": "Development",
		"开发日志": "Devlogs",
		"帮助与支持": "Help & Support",
		"使用帮助": "Help & guides",
		"点子交流": "Ideas"
	}
	if language == "zh":
		return str(english_to_chinese.get(name, name))
	return str(chinese_to_english.get(name, name))

func source_label(record: Dictionary) -> String:
	match str(record.get("source", "demo")):
		"github":
			return text("github_tag")
		"github_feed":
			return text("github_feed_tag")
		"github_registry":
			return text("github_registry_tag")
		_:
			return text("demo_tag")

func status_label(code: String) -> String:
	match code:
		"live_feed":
			return text("status_live_feed")
		"live_api":
			return text("status_live_api")
		"live_registry":
			return text("status_live_registry")
		"repository_pending", "repository_not_configured":
			return text("status_pending")
		"network_error", "http_error", "invalid_response", "invalid_feed":
			return text("status_network_error")
		"permission_denied", "not_authenticated", "auth_required":
			return text("status_permission_error")
		"rate_limited":
			return text("status_rate_limit")
		"empty_response":
			return text("status_empty")
		"offline_demo":
			return text("status_demo_fallback")
		_:
			return text("status_other_error")

func auth_error_label(code: String) -> String:
	match code:
		"oauth_not_configured":
			return text("toast_github")
		"device_flow_not_implemented":
			return text("toast_device_flow_pending")
		_:
			return text("status_permission_error")

func set_language(code: String, persist: bool = true) -> void:
	var next := "zh" if code == "zh" else "en"
	if persist:
		UiPreferences.set_language(next)
	if next == language_code:
		return
	language_code = next
	language_changed.emit(language_code)
