# Block-native UI / 方块原生界面

Implemented in Godot 4.7.2 on 2026-09-30–10-01. The design follows Plyra's dark/ice-blue palette and block-world artwork, with independently implemented interaction patterns informed by NativeHub and the user-provided Komi reference. It does not copy their source, branding or layout.

2026-09-30–10-01 使用 Godot 4.7.2 实现。沿用 Plyra 的深色、冰蓝色和方块世界视觉；参考 NativeHub 交互结构及用户提供的 Komi 图片，独立实现界面，不复制其源码、品牌或具体布局。

## Layout / 布局

The initial page is discussions. A compact header replaces the large homepage banner and three statistic cards. Counts appear next to the relevant section heading. Artwork is a small sidebar cover or a reader attachment.

默认直接进入讨论。紧凑页头替代原首页大横幅和三张统计卡；数量显示在对应分区标题旁。艺术图片用于小型侧栏封面或阅读附件。

Language selection is in **Settings → Language / 语言**, with English and 简体中文 choices. Content pages have no language-switch buttons in their header.

语言切换位于 **设置 → 语言 / Language**，提供 English 与简体中文；内容页页头不放置语言切换按钮。

Settings has its own always-visible button in the top-right header. It opens the dedicated page in one action and is separate from the community rail and phone bottom navigation. The latter contains only Discussions and MODs.

设置使用页头右上角始终可见的独立按钮，一次点击直接打开独立设置页，脱离社区侧栏与手机底部导航；后两者仅包含讨论和 MOD。

## Theme language / 主题语言

Graphite black and neutral charcoal separate the background, navigation and reading surfaces. Soft white text and header/reader edges establish hierarchy. Ice cyan is concentrated on selected navigation, selected card edges, focus and primary actions; amber is reserved for Demo provenance and small orbital accents. Unselected navigation has quiet divider edges rather than a box around every item. Heavy headings, square corners and short offset shadows give modules a physical block structure.

石墨黑与中性炭灰区分背景、导航、阅读面。柔白文字及页头/阅读区边缘建立层级。冰蓝集中用于选中导航、条目边缘、焦点和主要操作，琥珀色用于 Demo 来源及少量轨道点缀。未选中导航使用轻分隔线，减少逐项套框。较重标题、直角和短距离错层阴影体现实体方块模块。

Language and background-motion preferences are saved in `user://preferences.cfg` by `UiPreferences`. Search and input-preview drafts remain session-only. The `--lang` / `--motion` preview arguments and automated layout checks do not save preferences.

`UiPreferences` 将语言及背景动态偏好保存到 `user://preferences.cfg`。搜索和输入预览草稿仍仅在本次运行中保留；`--lang` / `--motion` 预览参数及自动布局检查不保存偏好。

| Viewport width / 视口宽度 | Structure / 结构 |
|---|---|
| `< 760 px` | Single list, category dropdown, separate reader with Back, bottom navigation / 单列列表、分类下拉、带返回按钮的独立阅读页、底部导航 |
| `760–1099 px` | Category/navigation rail plus a single list or reader pane / 分类导航栏加单个列表或阅读区 |
| `≥ 1100 px` | 204 px rail, resizable split with list ≥ 340 px and reader ≥ 420 px / 204 px 侧栏、可调双栏，列表至少 340 px、阅读区至少 420 px |

Control containers assign widths and native text layout wraps mixed-language content. Search updates entries without replacing the LineEdit, preserving its focus and composition node. List buttons measure their content height after wrapping instead of squeezing labels into a fixed-height cell. Selection persists with a cyan border and thick left strip; focus, hover and pressed styles are distinct.

Control 容器分配宽度，原生文本布局处理混排换行。搜索只更新条目，不替换 LineEdit，从而保留焦点和组字节点。列表按钮在换行后计算内容高度，不把文字挤进固定高度单元。选中状态使用冰蓝描边和加粗左侧条；焦点、悬停、按下均有独立样式。

## Reusable assets / 可复用资源

- `scripts/ui/design_tokens.gd`: graphite/white/cyan colors; square corners; 1 px normal borders, 2 px selected cards / 3 px focus edges; 4/8/12/16/24 px spacing; 44 px touch targets; font and pane minimums. / 石墨/柔白/冰蓝颜色、直角、1 px 常规描边、2 px 选中条目/3 px 焦点边缘、间距、44 px 触控高度及字体和分区最小尺寸。
- `themes/plyra_theme.tres`: shared native styles for Button, OptionButton, inputs, labels, popup menus and scrollbars. Regenerate with `godot --headless --path . --script res://tools/build_theme.gd`. / 共用原生组件 Theme，可用该命令从 Token 重新生成。
- `components/list_item.gd`: one selectable discussion/MOD module with source, wrapped title, preview and metadata. / 共用讨论和 MOD 条目，含来源、标题、摘要与元数据。
- `components/markdown_text.gd`: native selectable text with headings, bold, bullet lists, literal code blocks and HTTPS links. It is a small Markdown subset; tables and remote inline images are not supported. Untrusted text is never treated as BBCode or executed. / 原生可选中文本，支持标题、粗体、列表、字面代码块和 HTTPS 链接；仅为 Markdown 子集，暂不支持表格和远程行内图片，不执行外部文本或 BBCode。
- `components/block_mark.gd`: small static procedural block arch; no animation or texture dependency. / 静态程序化方块拱形标记，无动画或贴图依赖。
- `components/block_orbits.gd`: independently drawn 2D block core, 112 orbital blocks and a faint grid. Used as ambient decoration, desktop header and Settings preview; ignores pointer input. Inspired by JVAV's orbital visual idea, with no JavaScript or Three.js dependency. / 独立绘制的 2D 方块核心、112 个轨道方块和微弱网格，用于背景、桌面页头与设置预览，不截获指针；借鉴 JVAV 的轨道视觉思路，无 JavaScript 或 Three.js 依赖。
- Account modal uses the same Theme and square panels and explains the pending sign-in status. / 账号弹窗沿用相同直角规范，说明登录尚待实现。

No 3D nodes, Rust extension, shader, bloom or fake metrics are introduced. Background motion is under Settings: **Adaptive** (default) freezes after four idle seconds; **Continuous** draws at most 15 times per second and uses a 15 FPS idle cap; **Off** retains static decoration. Every mode stops animation processing when the window loses focus. Low processor mode limits redraws, interaction wakes the 60 FPS cap, and Adaptive/Off use a 10 FPS idle cap. Settings alone updates engine telemetry once per second. System CPU samples are recorded separately in TEST-REPORT.md; engine video-memory figures are not GPU-utilization percentages.

未引入 3D 节点、Rust 扩展、Shader、Bloom 或模拟指标。设置提供三种背景模式：默认**自适应**静止四秒后冻结，**持续动态**每秒最多重绘 15 次并采用 15 FPS 静止上限，**关闭**保留静态装饰；失去窗口焦点时均停止动画处理。启用低处理器占用模式，交互时上限为 60 FPS，自适应/关闭静止时为 10；仅设置页每秒更新遥测。系统 CPU 实测另见验收报告，显存数值不等同于 GPU 使用率。

## Sources and verification / 来源与验证

Settings switches between public GitHub content and explicitly offline Local Demo. In-flight public responses update the retained GitHub adapter while Demo stays selected. Discussion and registry statuses are independent. Empty successful live responses stay empty. Shared service/model interfaces remain outside the UI; no token or secret is introduced.

设置可切换 GitHub 公开内容和显式离线 Demo。选择 Demo 后，进行中的公开响应只更新保留的 GitHub 适配器；讨论和注册表状态分别显示。成功的空响应保持为空。服务和模型接口仍与 UI 分离，没有引入 Token 或 Secret。

The layout checks cover 320, 360, 390, 759, 760, 900, 1099, 1100, 1200 and 1360 px in English and Chinese for Discussions, MODs and Settings. They check geometry, direct global Settings, separate phone reading, selection, empty registry behavior, search-node retention, safe text, language fallback and background suspension. The macOS exported app is also inspected interactively. This is not Android keyboard/IME/device validation, authenticated GraphQL validation, or proof of implemented posting/commenting.

布局检查覆盖上述十种宽度、两种语言和讨论/MOD/设置三种页面，检查几何尺寸、手机独立阅读、选中状态、空注册表、搜索节点、文本安全与翻译回退；另在 macOS 导出包中检查实际交互。它不代表 Android 键盘/输入法/设备、已授权 GraphQL 或发帖/评论已经完成验收。
