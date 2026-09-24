extends Control

const ThreadCard = preload("res://scripts/ui/components/thread_card.gd")
const ModCard = preload("res://scripts/ui/components/mod_card.gd")
const BlockPanel = preload("res://scripts/ui/components/block_panel.gd")
const Tokens = preload("res://scripts/ui/design_tokens.gd")

const INK := Tokens.INK
const SIDEBAR := Tokens.SIDEBAR
const SURFACE := Tokens.SURFACE
const SURFACE_RAISED := Tokens.SURFACE_RAISED
const LINE := Tokens.LINE
const TEXT := Tokens.TEXT
const MUTED := Tokens.MUTED
const CYAN := Tokens.CYAN
const BLUE := Tokens.BLUE
const AMBER := Tokens.AMBER

var current_page := "home"
var selected_discussion_id := ""
var selected_mod_id := ""
var discussion_category := ""
var discussion_category_values: Array[String] = [""]
var mod_category := ""
var discussion_query := ""
var mod_query := ""
var ime_draft := ""

var page_content: VBoxContainer
var page_scroll: ScrollContainer
var outer_margin: MarginContainer
var app_row: HBoxContainer
var sidebar_shell: PanelContainer
var main_container: VBoxContainer
var header_container: HBoxContainer
var language_panel: PanelContainer
var mobile_navigation: HBoxContainer
var metric_grid: GridContainer
var home_discussion_grid: GridContainer
var discussion_filters: BoxContainer
var mod_filters: BoxContainer
var discussion_results: GridContainer
var mod_results: GridContainer
var discussion_count_label: Label
var mod_count_label: Label
var status_label: Label
var toast_label: Label
var toast_timer: Timer
var idle_fps_timer: Timer
var ime_editor: TextEdit
var ime_count_label: Label
var performance_label: Label
var page_kicker_label: Label
var page_title_label: Label
var guest_label: Label
var guest_note_label: Label
var brand_note_label: Label
var sidebar_explore_label: Label
var world_preview_label: Label
var world_title_label: Label
var world_status_label: Label
var connect_button: Button
var hero_block_plaque: PanelContainer
var navigation_buttons: Dictionary = {}
var mobile_navigation_buttons: Dictionary = {}
var language_buttons: Dictionary = {}
var language_group: ButtonGroup
var last_mouse_position := Vector2(-10000.0, -10000.0)
var last_layout_class := ""

func _ready() -> void:
	theme = load("res://themes/plyra_theme.tres")
	_build_shell()
	I18n.language_changed.connect(_on_language_changed)
	AppServices.community.content_changed.connect(_on_community_content_changed)
	get_viewport().size_changed.connect(_on_viewport_resized)
	_sync_responsive_layout()
	_render_page()

func _build_shell() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = INK
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	outer_margin = MarginContainer.new()
	outer_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer_margin.add_theme_constant_override("margin_left", 22)
	outer_margin.add_theme_constant_override("margin_right", 22)
	outer_margin.add_theme_constant_override("margin_top", 18)
	outer_margin.add_theme_constant_override("margin_bottom", 15)
	add_child(outer_margin)

	app_row = HBoxContainer.new()
	app_row.add_theme_constant_override("separation", 20)
	outer_margin.add_child(app_row)
	_build_sidebar(app_row)
	_build_main(app_row)
	_sync_chrome()

func _build_sidebar(parent: HBoxContainer) -> void:
	sidebar_shell = PanelContainer.new()
	sidebar_shell.custom_minimum_size.x = 222
	sidebar_shell.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sidebar_shell.add_theme_stylebox_override("panel", _surface_box(SIDEBAR, Color("344661"), 2, 14, 3))
	parent.add_child(sidebar_shell)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 14)
	sidebar_shell.add_child(stack)

	var brand_row := HBoxContainer.new()
	brand_row.add_theme_constant_override("separation", 11)
	stack.add_child(brand_row)
	var brand_mark := PanelContainer.new()
	brand_mark.custom_minimum_size = Vector2(42, 42)
	brand_mark.add_theme_stylebox_override("panel", _surface_box(Color("10253c"), CYAN, 2, 0, 2))
	brand_row.add_child(brand_mark)
	var mark := _label("P", 22, CYAN)
	mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	brand_mark.add_child(mark)
	var brand_name := VBoxContainer.new()
	brand_name.add_theme_constant_override("separation", 0)
	brand_row.add_child(brand_name)
	brand_name.add_child(_label("PLYRA", 16, TEXT))
	brand_name.add_child(_label("COMMUNITY", 9, CYAN))

	brand_note_label = _label(I18n.text("brand_subtitle"), 10, MUTED, true)
	brand_note_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(brand_note_label)

	var divider := HSeparator.new()
	divider.add_theme_color_override("separator", LINE)
	stack.add_child(divider)
	sidebar_explore_label = _label(I18n.text("sidebar_explore"), 10, MUTED)
	stack.add_child(sidebar_explore_label)

	var nav_stack := VBoxContainer.new()
	nav_stack.add_theme_constant_override("separation", 5)
	stack.add_child(nav_stack)
	for page in ["home", "discussions", "mods", "settings"]:
		var nav_button := Button.new()
		nav_button.custom_minimum_size.y = 43
		nav_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		nav_button.focus_mode = Control.FOCUS_ALL
		nav_button.pressed.connect(_show_page.bind(page))
		nav_stack.add_child(nav_button)
		navigation_buttons[page] = nav_button

	var flexible_space := Control.new()
	flexible_space.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(flexible_space)

	var world_card := PanelContainer.new()
	world_card.add_theme_stylebox_override("panel", _surface_box(Color("102033"), Color("21405c"), 2, 11, 2))
	stack.add_child(world_card)
	var world_stack := VBoxContainer.new()
	world_stack.add_theme_constant_override("separation", 7)
	world_card.add_child(world_stack)
	world_preview_label = _label("✦  " + I18n.text("preview_badge"), 10, CYAN)
	world_title_label = _label(I18n.text("home_note_title"), 12, TEXT, true)
	world_status_label = _label(I18n.text("status_offline"), 10, MUTED)
	world_stack.add_child(world_preview_label)
	world_stack.add_child(world_title_label)
	world_stack.add_child(world_status_label)

	var identity := HBoxContainer.new()
	identity.add_theme_constant_override("separation", 10)
	stack.add_child(identity)
	var avatar := PanelContainer.new()
	avatar.custom_minimum_size = Vector2(36, 36)
	avatar.add_theme_stylebox_override("panel", _surface_box(Color("1c2b43"), LINE, 2, 0, 1))
	identity.add_child(avatar)
	var avatar_mark := _label("G", 14, AMBER)
	avatar_mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	avatar_mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	avatar.add_child(avatar_mark)
	var identity_text := VBoxContainer.new()
	identity_text.add_theme_constant_override("separation", 1)
	identity_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity.add_child(identity_text)
	guest_label = _label(I18n.text("guest_mode"), 11, TEXT)
	identity_text.add_child(guest_label)
	guest_note_label = _label(I18n.text("github_soon"), 9, MUTED, true)
	identity_text.add_child(guest_note_label)

func _build_main(parent: HBoxContainer) -> void:
	main_container = VBoxContainer.new()
	main_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.add_theme_constant_override("separation", 12)
	parent.add_child(main_container)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 18)
	header.custom_minimum_size.y = 58
	header_container = header
	main_container.add_child(header)
	var titles := VBoxContainer.new()
	titles.add_theme_constant_override("separation", 1)
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titles.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(titles)
	page_kicker_label = _label("PLYRA / COMMUNITY", 9, CYAN)
	titles.add_child(page_kicker_label)
	page_title_label = _label("", 24, TEXT)
	titles.add_child(page_title_label)

	language_panel = PanelContainer.new()
	language_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	language_panel.add_theme_stylebox_override("panel", _surface_box(Color("101a2c"), LINE, 2, 3, 1))
	header.add_child(language_panel)
	var language_row := HBoxContainer.new()
	language_row.add_theme_constant_override("separation", 2)
	language_panel.add_child(language_row)
	language_group = ButtonGroup.new()
	for code in ["en", "zh"]:
		var language_button := Button.new()
		language_button.text = "EN" if code == "en" else "中文"
		language_button.custom_minimum_size = Vector2(48, 34)
		language_button.toggle_mode = true
		language_button.button_group = language_group
		language_button.toggled.connect(_on_language_toggled.bind(code))
		language_row.add_child(language_button)
		language_buttons[code] = language_button

	connect_button = _button(I18n.text("account_connect"), true)
	connect_button.custom_minimum_size = Vector2(148, 40)
	connect_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	connect_button.pressed.connect(_start_github_sign_in)
	header.add_child(connect_button)

	var divider := HSeparator.new()
	divider.add_theme_color_override("separator", Color("1e2c42"))
	main_container.add_child(divider)

	mobile_navigation = HBoxContainer.new()
	mobile_navigation.add_theme_constant_override("separation", 4)
	main_container.add_child(mobile_navigation)
	for page in ["home", "discussions", "mods", "settings"]:
		var nav_button := Button.new()
		nav_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nav_button.custom_minimum_size.y = 40
		nav_button.focus_mode = Control.FOCUS_ALL
		nav_button.pressed.connect(_show_page.bind(page))
		mobile_navigation.add_child(nav_button)
		mobile_navigation_buttons[page] = nav_button

	page_scroll = ScrollContainer.new()
	page_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_container.add_child(page_scroll)

	var page_margin := MarginContainer.new()
	page_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_margin.add_theme_constant_override("margin_left", 1)
	page_margin.add_theme_constant_override("margin_right", 8)
	page_margin.add_theme_constant_override("margin_top", 7)
	page_margin.add_theme_constant_override("margin_bottom", 8)
	page_scroll.add_child(page_margin)

	page_content = VBoxContainer.new()
	page_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_content.add_theme_constant_override("separation", 14)
	page_margin.add_child(page_content)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 10)
	main_container.add_child(footer)
	status_label = _label(I18n.text("footer_local"), 9, MUTED)
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(status_label)
	toast_label = _label("", 10, CYAN)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	footer.add_child(toast_label)

	toast_timer = Timer.new()
	toast_timer.one_shot = true
	toast_timer.wait_time = 3.2
	toast_timer.timeout.connect(func() -> void: toast_label.text = "")
	add_child(toast_timer)

	idle_fps_timer = Timer.new()
	idle_fps_timer.one_shot = true
	idle_fps_timer.wait_time = 8.0
	idle_fps_timer.timeout.connect(_return_to_idle_fps)
	add_child(idle_fps_timer)

	var perf_timer := Timer.new()
	perf_timer.wait_time = 1.0
	perf_timer.timeout.connect(_update_performance)
	add_child(perf_timer)
	perf_timer.start()

func _show_page(page: String) -> void:
	current_page = page
	selected_discussion_id = ""
	selected_mod_id = ""
	_render_page()

func _on_language_toggled(pressed: bool, code: String) -> void:
	if pressed:
		I18n.set_language(code)

func _on_language_changed(_code: String) -> void:
	_sync_chrome()
	_render_page()

func _sync_chrome() -> void:
	var phone := _viewport_width() < 600
	var tiny_phone := _viewport_width() < 420
	for page in navigation_buttons:
		var button: Button = navigation_buttons[page]
		var marker: String = {"home": "⌂", "discussions": "▤", "mods": "⬡", "settings": "⚙"}[page]
		button.text = "   %s   %s" % [marker, I18n.text("nav_" + str(page))]
		button.tooltip_text = I18n.text("nav_" + str(page))
		button.add_theme_stylebox_override("normal", _nav_box(page == current_page))
		button.add_theme_stylebox_override("hover", _nav_box(page == current_page, true))
		button.add_theme_stylebox_override("pressed", _nav_box(true, true, true))
		button.add_theme_stylebox_override("focus", Tokens.focus_ring())
		button.add_theme_color_override("font_color", CYAN if page == current_page else MUTED)
	for page in mobile_navigation_buttons:
		var button: Button = mobile_navigation_buttons[page]
		button.text = _compact_nav_title(str(page))
		button.tooltip_text = I18n.text("nav_" + str(page))
		button.add_theme_stylebox_override("normal", _nav_box(page == current_page))
		button.add_theme_stylebox_override("hover", _nav_box(page == current_page, true))
		button.add_theme_stylebox_override("pressed", _nav_box(true, true, true))
		button.add_theme_stylebox_override("focus", Tokens.focus_ring())
		button.add_theme_color_override("font_color", CYAN if page == current_page else MUTED)
		button.add_theme_font_size_override("font_size", 10 if tiny_phone else 11)
	for code in language_buttons:
		var language_button: Button = language_buttons[code]
		language_button.button_pressed = I18n.language_code == code
		language_button.add_theme_stylebox_override("normal", _language_box(I18n.language_code == code))
		language_button.add_theme_stylebox_override("hover", _language_box(true))
		language_button.add_theme_stylebox_override("pressed", _language_box(true))
		language_button.add_theme_stylebox_override("focus", Tokens.focus_ring())
		language_button.add_theme_color_override("font_color", TEXT if I18n.language_code == code else MUTED)
	if guest_label != null:
		brand_note_label.text = I18n.text("brand_subtitle")
		sidebar_explore_label.text = I18n.text("sidebar_explore")
		world_preview_label.text = "✦  " + I18n.text("preview_badge")
		world_title_label.text = I18n.text("home_note_title")
		world_status_label.text = I18n.text("status_offline")
		guest_label.text = I18n.text("guest_mode")
		guest_note_label.text = I18n.text("github_soon")
		connect_button.text = I18n.text("account_connect")
		page_kicker_label.text = I18n.text("breadcrumb_" + current_page)
		page_title_label.text = _current_page_title()
		page_title_label.tooltip_text = page_title_label.text
		var content_status: Dictionary = AppServices.community.content_status()
		status_label.text = I18n.status_label(str(content_status.get("code", "offline_demo")))
		connect_button.text = I18n.text("account_connect")
		connect_button.tooltip_text = connect_button.text
		var long_title := page_title_label.text.length() > 34
		page_title_label.add_theme_font_size_override("font_size", 18 if phone else (20 if long_title else 23))
		page_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		page_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if header_container != null:
			header_container.custom_minimum_size.y = (68 if phone else 82) if long_title else (54 if phone else 58)
		status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if phone else TextServer.AUTOWRAP_OFF
		status_label.max_lines_visible = 2 if phone else 1

func _compact_nav_title(page: String) -> String:
	var english := {"home": "HOME", "discussions": "TALK", "mods": "MOD", "settings": "SET"}
	var chinese := {"home": "首页", "discussions": "讨论", "mods": "MOD", "settings": "设置"}
	return str((chinese if I18n.language_code == "zh" else english)[page])

func _current_page_title() -> String:
	if current_page == "discussions" and not selected_discussion_id.is_empty():
		return I18n.field(AppServices.community.get_discussion(selected_discussion_id), "title")
	if current_page == "mods" and not selected_mod_id.is_empty():
		return I18n.field(AppServices.community.get_mod(selected_mod_id), "name")
	return I18n.text("page_" + current_page)

func _render_page() -> void:
	_clear_page()
	_sync_chrome()
	match current_page:
		"home":
			_render_home()
		"discussions":
			_render_discussion_detail() if not selected_discussion_id.is_empty() else _render_discussions()
		"mods":
			_render_mod_detail() if not selected_mod_id.is_empty() else _render_mods()
		"settings":
			_render_settings()
	if page_scroll != null:
		page_scroll.scroll_vertical = 0

func _render_home() -> void:
	var hero_panel = _block_panel(Color("0b1728"), Color("3b7596"), 0, 4, 12, 2)
	hero_panel.custom_minimum_size = Vector2(0, 184 if _viewport_width() >= 600 else 164)
	hero_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_content.add_child(hero_panel)
	var hero := Control.new()
	hero.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero.clip_contents = true
	hero_panel.add_child(hero)
	var artwork := TextureRect.new()
	artwork.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	artwork.texture = load("res://assets/images/plyra-world-hero.png")
	artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero.add_child(artwork)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.035, 0.075, 0.56)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero.add_child(shade)
	var hero_margin := MarginContainer.new()
	hero.add_child(hero_margin)
	hero_margin_full(hero_margin, 20, 12)
	var hero_stack := VBoxContainer.new()
	hero_stack.add_theme_constant_override("separation", 6)
	hero_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero_stack.custom_maximum_size.x = 570
	hero_stack.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hero_margin.add_child(hero_stack)
	hero_stack.add_child(_label("✦  " + I18n.text("hero_eyebrow"), 10, CYAN))
	var hero_title := _label(I18n.text("hero_title"), 27 if _viewport_width() >= 600 else 22, TEXT, true)
	hero_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hero_stack.add_child(hero_title)
	var hero_body := _label(I18n.text("hero_body_compact" if _viewport_width() < 600 else "hero_body"), 11 if _viewport_width() < 600 else 12, Color("d5e0f4"), true)
	hero_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hero_stack.add_child(hero_body)
	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 7)
	hero_stack.add_child(action_row)
	var explore := _button(I18n.text("hero_primary"), true)
	explore.pressed.connect(_show_page.bind("discussions"))
	explore.custom_minimum_size.y = 36
	action_row.add_child(explore)
	var browse := _button(I18n.text("hero_secondary"))
	browse.pressed.connect(_show_page.bind("mods"))
	browse.custom_minimum_size.y = 36
	action_row.add_child(browse)

	hero_block_plaque = _block_panel(Color(0.025, 0.07, 0.12, 0.92), Color(0.25, 0.78, 0.9, 0.94), 10, 4, 8, 2)
	hero_block_plaque.anchor_left = 1.0
	hero_block_plaque.anchor_right = 1.0
	hero_block_plaque.anchor_top = 0.5
	hero_block_plaque.anchor_bottom = 0.5
	hero_block_plaque.offset_left = -190
	hero_block_plaque.offset_right = -18
	hero_block_plaque.offset_top = -49
	hero_block_plaque.offset_bottom = 49
	hero_block_plaque.visible = _content_width() >= 820
	hero.add_child(hero_block_plaque)
	var plaque_stack := VBoxContainer.new()
	plaque_stack.add_theme_constant_override("separation", 4)
	hero_block_plaque.add_child(plaque_stack)
	plaque_stack.add_child(_label(I18n.text("plaque_block"), 9, CYAN))
	plaque_stack.add_child(_label(I18n.text("plaque_title"), 13, TEXT, true))
	plaque_stack.add_child(_label(I18n.text("plaque_caption"), 8, AMBER, true))

	metric_grid = GridContainer.new()
	metric_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	metric_grid.add_theme_constant_override("h_separation", 9)
	metric_grid.add_theme_constant_override("v_separation", 7)
	page_content.add_child(metric_grid)
	_add_metric(metric_grid, "%02d" % AppServices.community.list_discussions().size(), I18n.text("metric_discussions"), CYAN)
	_add_metric(metric_grid, "%02d" % AppServices.community.list_mods().size(), I18n.text("metric_mods"), AMBER)
	_add_metric(metric_grid, "∞", I18n.text("metric_mode"), Color("9edbb5"))
	_update_responsive_grids()

	_section_heading(I18n.text("home_latest"), I18n.text("view_all"), func() -> void: _show_page("discussions"))
	home_discussion_grid = GridContainer.new()
	home_discussion_grid.columns = _grid_columns()
	home_discussion_grid.add_theme_constant_override("h_separation", 12)
	home_discussion_grid.add_theme_constant_override("v_separation", 12)
	page_content.add_child(home_discussion_grid)
	var latest := AppServices.community.list_discussions("", "")
	for index in mini(2, latest.size()):
		_add_thread_card(latest[index], home_discussion_grid)
	if latest.is_empty():
		page_content.add_child(_empty_state(I18n.text("empty_discussion_title"), I18n.text("empty_discussion_body")))
	if _viewport_width() < 600:
		page_content.move_child(metric_grid, page_content.get_child_count() - 1)

	var note := _panel()
	page_content.add_child(note)
	var note_row := HBoxContainer.new()
	note_row.add_theme_constant_override("separation", 13)
	note.add_child(note_row)
	var accent := ColorRect.new()
	accent.color = AMBER
	accent.custom_minimum_size = Vector2(4, 52)
	note_row.add_child(accent)
	var note_copy := VBoxContainer.new()
	note_copy.add_theme_constant_override("separation", 4)
	note_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	note_row.add_child(note_copy)
	note_copy.add_child(_label(I18n.text("home_note_title"), 14, TEXT))
	note_copy.add_child(_label(I18n.text("home_note_body"), 12, MUTED, true))

func _render_discussions() -> void:
	_add_page_intro(I18n.text("intro_discussions"))
	discussion_filters = BoxContainer.new()
	discussion_filters.vertical = _viewport_width() < 640
	discussion_filters.add_theme_constant_override("separation", 9)
	page_content.add_child(discussion_filters)
	var search := LineEdit.new()
	search.placeholder_text = I18n.text("search_discussions")
	search.clear_button_enabled = true
	search.text = discussion_query
	search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search.custom_minimum_size = Vector2(210, 44)
	search.text_changed.connect(_on_discussion_search)
	discussion_filters.add_child(search)
	var category := OptionButton.new()
	category.custom_minimum_size = Vector2(184, 44)
	discussion_category_values = [""]
	category.add_item(I18n.text("filter_all"))
	for category_entry in AppServices.community.list_categories():
		var value := str(category_entry.get("value", category_entry.get("name", "")))
		if value.is_empty():
			continue
		discussion_category_values.append(value)
		var english_name := str(category_entry.get("name_en", category_entry.get("name", value)))
		category.add_item(I18n.category_label(english_name))
	category.select(maxi(0, discussion_category_values.find(discussion_category)))
	category.item_selected.connect(_on_discussion_category.bind(discussion_category_values))
	discussion_filters.add_child(category)
	_sync_filter_children(discussion_filters)
	discussion_count_label = _label("", 10, MUTED)
	page_content.add_child(discussion_count_label)
	discussion_results = GridContainer.new()
	discussion_results.columns = _grid_columns()
	discussion_results.add_theme_constant_override("h_separation", 12)
	discussion_results.add_theme_constant_override("v_separation", 12)
	page_content.add_child(discussion_results)
	_refresh_discussion_cards()

func _refresh_discussion_cards() -> void:
	if discussion_results == null or not is_instance_valid(discussion_results):
		return
	_clear_container(discussion_results)
	var entries := AppServices.community.list_discussions(discussion_category, discussion_query)
	var count_key := "discussion_count_live" if AppServices.community.uses_live_discussions() else "discussion_count_demo"
	discussion_count_label.text = I18n.text(count_key) % entries.size()
	if entries.is_empty():
		discussion_results.add_child(_empty_state(I18n.text("empty_discussion_title"), I18n.text("empty_discussion_body")))
		return
	for entry in entries:
		_add_thread_card(entry, discussion_results)

func _render_discussion_detail() -> void:
	var record := AppServices.community.get_discussion(selected_discussion_id)
	if record.is_empty():
		selected_discussion_id = ""
		_render_discussions()
		return
	var back := _button(I18n.text("back_discussions"))
	back.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	back.pressed.connect(func() -> void:
		selected_discussion_id = ""
		_render_page()
	)
	page_content.add_child(back)
	var meta_row := HBoxContainer.new()
	meta_row.add_theme_constant_override("separation", 8)
	page_content.add_child(meta_row)
	meta_row.add_child(_pill(I18n.field(record, "category"), CYAN))
	meta_row.add_child(_pill(I18n.source_label(record), AMBER if bool(record.get("is_demo", true)) else CYAN))
	page_content.add_child(_label("%s  ·  %s  ·  %s" % [I18n.field(record, "author"), record.get("updated_at", ""), I18n.text("comment_count") % int(record.get("comment_count", 0))], 11, MUTED, true))

	var article := _panel()
	page_content.add_child(article)
	var article_body := VBoxContainer.new()
	article_body.add_theme_constant_override("separation", 16)
	article.add_child(article_body)
	article_body.add_child(_label(I18n.source_label(record), 10, AMBER if bool(record.get("is_demo", true)) else CYAN))
	var body := RichTextLabel.new()
	body.bbcode_enabled = false
	body.selection_enabled = true
	body.fit_content = true
	body.scroll_active = false
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.text = I18n.field(record, "body")
	body.add_theme_font_size_override("normal_font_size", 15)
	body.add_theme_color_override("default_color", Color("dce6f5"))
	body.add_theme_constant_override("line_separation", 8)
	article_body.add_child(body)
	var image_path := str(record.get("image", ""))
	if not image_path.is_empty() and ResourceLoader.exists(image_path):
		var media := TextureRect.new()
		media.custom_minimum_size = Vector2(0, 220)
		media.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		media.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		media.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		media.texture = load(image_path)
		article_body.add_child(media)
		article_body.add_child(_label(I18n.text("image_caption"), 9, MUTED))

	page_content.add_child(_label(I18n.text("comments_replies"), 20, TEXT))
	var comments: Array = record.get("comments", [])
	if comments.is_empty():
		page_content.add_child(_empty_state(I18n.text("no_comments"), ""))
	for comment: Variant in comments:
		if comment is Dictionary:
			_add_comment(comment)
	var reply := _button(I18n.text("reply_button"), true)
	reply.pressed.connect(_on_reply_requested)
	page_content.add_child(reply)
	page_content.add_child(_label(I18n.text("reply_notice"), 10, MUTED))

func _render_mods() -> void:
	_add_page_intro(I18n.text("intro_mods"))
	var safety := _panel()
	page_content.add_child(safety)
	var safety_row := HBoxContainer.new()
	safety_row.add_theme_constant_override("separation", 11)
	safety.add_child(safety_row)
	var safety_dot := _label("◈", 18, AMBER)
	safety_row.add_child(safety_dot)
	var safety_copy := VBoxContainer.new()
	safety_copy.add_theme_constant_override("separation", 3)
	safety_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	safety_copy_row(safety_copy)
	safety_row.add_child(safety_copy)

	mod_filters = BoxContainer.new()
	mod_filters.vertical = _viewport_width() < 640
	mod_filters.add_theme_constant_override("separation", 9)
	page_content.add_child(mod_filters)
	var search := LineEdit.new()
	search.placeholder_text = I18n.text("search_mods")
	search.clear_button_enabled = true
	search.text = mod_query
	search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search.custom_minimum_size = Vector2(210, 44)
	search.text_changed.connect(_on_mod_search)
	mod_filters.add_child(search)
	var mod_types: Array[String] = [""]
	for entry in AppServices.community.list_mods():
		var category := str(entry.get("type", ""))
		if not mod_types.has(category):
			mod_types.append(category)
	var category_select := OptionButton.new()
	category_select.custom_minimum_size = Vector2(184, 44)
	for category in mod_types:
		category_select.add_item(I18n.text("filter_all") if category.is_empty() else _localized_mod_type(category))
	category_select.select(maxi(0, mod_types.find(mod_category)))
	category_select.item_selected.connect(_on_mod_category.bind(mod_types))
	mod_filters.add_child(category_select)
	_sync_filter_children(mod_filters)
	mod_count_label = _label("", 10, MUTED)
	page_content.add_child(mod_count_label)
	mod_results = GridContainer.new()
	mod_results.columns = _grid_columns()
	mod_results.add_theme_constant_override("h_separation", 12)
	mod_results.add_theme_constant_override("v_separation", 12)
	page_content.add_child(mod_results)
	_refresh_mod_cards()

func _refresh_mod_cards() -> void:
	if mod_results == null or not is_instance_valid(mod_results):
		return
	_clear_container(mod_results)
	var entries := AppServices.community.list_mods(mod_category, mod_query)
	mod_count_label.text = I18n.text("mod_count_live" if AppServices.community.uses_live_mods() else "mod_count") % entries.size()
	if entries.is_empty():
		mod_results.add_child(_empty_state(I18n.text("empty_mod_title"), I18n.text("empty_mod_body")))
		return
	for entry in entries:
		var card = ModCard.new()
		card.setup(entry)
		mod_results.add_child(card)
		card.open_requested.connect(_open_mod)

func _render_mod_detail() -> void:
	var record := AppServices.community.get_mod(selected_mod_id)
	if record.is_empty():
		selected_mod_id = ""
		_render_mods()
		return
	var back := _button(I18n.text("back_mods"))
	back.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	back.pressed.connect(func() -> void:
		selected_mod_id = ""
		_render_page()
	)
	page_content.add_child(back)
	_add_page_intro(I18n.field(record, "description"))
	var tags := HBoxContainer.new()
	tags.add_theme_constant_override("separation", 8)
	page_content.add_child(tags)
	tags.add_child(_pill(I18n.field(record, "type"), CYAN))
	var is_demo := bool(record.get("demo_only", record.get("is_demo", true)))
	tags.add_child(_pill(I18n.text("demo_no_download") if is_demo else I18n.source_label(record), AMBER if is_demo else CYAN))

	var details := _panel()
	page_content.add_child(details)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 13)
	details.add_child(stack)
	stack.add_child(_label(I18n.text("mod_details"), 16, TEXT))
	for pair in [
		["author", "author"],
		["version", "version"],
		["target", "target"],
		["compatibility", "plyra_compatibility"],
		["license", "license"]
	]:
		_add_detail_row(stack, I18n.text(str(pair[0])), I18n.field(record, str(pair[1])))

	var links := _panel()
	page_content.add_child(links)
	var link_stack := VBoxContainer.new()
	link_stack.add_theme_constant_override("separation", 8)
	links.add_child(link_stack)
	link_stack.add_child(_label(I18n.text("source_verification"), 15, TEXT))
	_add_detail_row(link_stack, I18n.text("source_url"), str(record.get("source_url", "")) if not str(record.get("source_url", "")).is_empty() else I18n.text("not_provided"))
	_add_detail_row(link_stack, I18n.text("download_url"), str(record.get("download_url", "")) if not str(record.get("download_url", "")).is_empty() else I18n.text("not_provided"))
	_add_detail_row(link_stack, I18n.text("sha256"), str(record.get("sha256", "")) if not str(record.get("sha256", "")).is_empty() else I18n.text("not_provided"))
	var unavailable := _button(I18n.text("download_unavailable"))
	unavailable.disabled = true
	link_stack.add_child(unavailable)

func _render_settings() -> void:
	_add_page_intro(I18n.text("intro_settings"))
	var auth := _panel()
	page_content.add_child(auth)
	var auth_stack := VBoxContainer.new()
	auth_stack.add_theme_constant_override("separation", 10)
	auth.add_child(auth_stack)
	auth_stack.add_child(_label(I18n.text("github_connection"), 16, TEXT))
	var auth_status := I18n.text("connected_as") if AppServices.auth.is_authorized() else I18n.text("not_connected")
	var content_status: Dictionary = AppServices.community.content_status()
	_add_status_row(auth_stack, I18n.text("authorization"), auth_status)
	_add_status_row(auth_stack, I18n.text("content_source"), I18n.status_label(str(content_status.get("code", "offline_demo"))))
	_add_status_row(auth_stack, I18n.text("online_repository"), AppServices.repository_label())
	var guide := _button(I18n.text("github_guide"))
	guide.pressed.connect(_start_github_sign_in)
	auth_stack.add_child(guide)
	var refresh := _button(I18n.text("refresh_content"))
	refresh.pressed.connect(func() -> void:
		AppServices.refresh_community()
		var ready := bool(AppServices.repository_config.get("requests_enabled", false)) and bool(AppServices.repository_config.get("repository_ready", false))
		_show_toast(I18n.status_label("repository_pending") if not ready else I18n.text("refresh_requested"))
	)
	auth_stack.add_child(refresh)

	var input_panel := _panel()
	page_content.add_child(input_panel)
	var input_stack := VBoxContainer.new()
	input_stack.add_theme_constant_override("separation", 9)
	input_panel.add_child(input_stack)
	input_stack.add_child(_label(I18n.text("ime_title"), 16, TEXT))
	input_stack.add_child(_label(I18n.text("ime_body"), 11, MUTED, true))
	ime_editor = TextEdit.new()
	ime_editor.custom_minimum_size = Vector2(0, 128)
	ime_editor.placeholder_text = I18n.text("ime_placeholder")
	ime_editor.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	ime_editor.virtual_keyboard_enabled = true
	ime_editor.text = ime_draft
	ime_editor.text_changed.connect(_on_ime_text_changed)
	input_stack.add_child(ime_editor)
	ime_count_label = _label(I18n.text("characters") % ime_draft.length(), 10, MUTED)
	input_stack.add_child(ime_count_label)

	var appearance := _panel()
	page_content.add_child(appearance)
	var appearance_stack := VBoxContainer.new()
	appearance_stack.add_theme_constant_override("separation", 6)
	appearance.add_child(appearance_stack)
	appearance_stack.add_child(_label(I18n.text("appearance_title"), 15, TEXT))
	appearance_stack.add_child(_label(I18n.text("appearance_body"), 11, MUTED))
	appearance_stack.add_child(_label(I18n.text("appearance_components"), 10, MUTED))

	var telemetry := _panel()
	page_content.add_child(telemetry)
	var telemetry_stack := VBoxContainer.new()
	telemetry_stack.add_theme_constant_override("separation", 7)
	telemetry.add_child(telemetry_stack)
	telemetry_stack.add_child(_label(I18n.text("performance_title"), 15, TEXT))
	performance_label = _label("", 11, CYAN, true)
	telemetry_stack.add_child(performance_label)
	telemetry_stack.add_child(_label(I18n.text("performance_note"), 9, MUTED, true))
	_update_performance()

func _add_page_intro(copy: String) -> void:
	page_content.add_child(_label(copy, 13, MUTED, true))

func _add_metric(parent: Control, value: String, title: String, color: Color) -> void:
	var panel = _block_panel(Color("111d31"), Color("435b7a"), 9, 2, 7, 2)
	panel.custom_minimum_size = Vector2(Tokens.METRIC_MIN_WIDTH, 62)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 9)
	panel.add_child(row)
	var number := _label(value, 24, color)
	number.custom_minimum_size.x = 36
	row.add_child(number)
	var copy := VBoxContainer.new()
	copy.alignment = BoxContainer.ALIGNMENT_CENTER
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var metric_label := _label(title, 10, MUTED, true)
	metric_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	metric_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.add_child(metric_label)
	row.add_child(copy)

func _section_heading(title: String, action_text: String, action: Callable) -> void:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_label(title, 19, TEXT))
	row.add_spacer(false)
	var button := Button.new()
	button.text = action_text + "  →"
	button.flat = true
	button.add_theme_color_override("font_color", CYAN)
	button.add_theme_stylebox_override("normal", _surface_box(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 2, 7))
	button.add_theme_stylebox_override("hover", _surface_box(Color("142a40"), CYAN, 2, 7, 2))
	button.add_theme_stylebox_override("pressed", _surface_box(Color("1d3850"), CYAN, 2, 7, 0))
	button.add_theme_stylebox_override("focus", Tokens.focus_ring())
	button.custom_minimum_size.y = 34
	button.pressed.connect(action)
	row.add_child(button)
	page_content.add_child(row)

func _add_thread_card(record: Dictionary, parent: Node = null) -> void:
	var card = ThreadCard.new()
	card.setup(record)
	(parent if parent != null else page_content).add_child(card)
	card.open_requested.connect(_open_discussion)

func _add_comment(comment: Dictionary) -> void:
	var panel := _panel()
	page_content.add_child(panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	panel.add_child(stack)
	stack.add_child(_label("%s  ·  %s" % [I18n.field(comment, "author"), I18n.source_label(comment)], 11, CYAN))
	stack.add_child(_label(I18n.field(comment, "body"), 13, Color("d9e4f2"), true))
	for reply: Variant in comment.get("replies", []):
		if reply is Dictionary:
			stack.add_child(_label("↳ %s  ·  %s  ·  %s" % [I18n.field(reply, "author"), I18n.source_label(reply), I18n.field(reply, "body")], 11, MUTED, true))

func _add_detail_row(parent: VBoxContainer, title: String, value: String) -> void:
	var row := BoxContainer.new()
	row.vertical = _content_width() < 520
	row.add_theme_constant_override("separation", 5 if row.vertical else 15)
	parent.add_child(row)
	var title_label := _label(title, 10, MUTED)
	title_label.custom_minimum_size.x = 0 if row.vertical else 122
	row.add_child(title_label)
	var value_label := _label(value, 12, Color("dce6f5"), true)
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(value_label)

func _add_status_row(parent: VBoxContainer, title: String, value: String) -> void:
	var row := BoxContainer.new()
	row.vertical = _content_width() < 520
	row.add_theme_constant_override("separation", 4 if row.vertical else 13)
	parent.add_child(row)
	var title_label := _label(title, 10, MUTED)
	title_label.custom_minimum_size.x = 0 if row.vertical else 118
	row.add_child(title_label)
	var value_label := _label(value, 11, Color("dce6f5"), true)
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(value_label)

func _pill(copy: String, color: Color) -> PanelContainer:
	var pill = _block_panel(Color("102238"), Color(color, 0.74), 5, 1, 4, 1)
	var tag := _label(copy, 9, color, true)
	tag.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pill.add_child(tag)
	return pill

func _panel() -> PanelContainer:
	return _block_panel(SURFACE, Color("3b5271"), 14, 2, 8, 2)

func _block_panel(fill: Color, edge: Color, padding: int, depth: int, chamfer: int, border_width: int) -> PanelContainer:
	var panel = BlockPanel.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.configure(fill, edge, padding, depth, chamfer, border_width)
	return panel

func _empty_state(title: String, detail: String) -> PanelContainer:
	var panel := _panel()
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 6)
	panel.add_child(stack)
	stack.add_child(_label(title, 15, TEXT))
	if not detail.is_empty():
		stack.add_child(_label(detail, 11, MUTED, true))
	return panel

func _button(copy: String, primary: bool = false) -> Button:
	var button := Button.new()
	button.text = copy
	button.custom_minimum_size.y = 42
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_stylebox_override("normal", _button_box(primary, false))
	button.add_theme_stylebox_override("hover", _button_box(primary, true))
	button.add_theme_stylebox_override("pressed", _button_box(primary, true, true))
	button.add_theme_stylebox_override("disabled", _button_box(false, false))
	button.add_theme_stylebox_override("focus", Tokens.focus_ring())
	button.add_theme_color_override("font_color", Color("061320") if primary else TEXT)
	button.add_theme_color_override("font_hover_color", TEXT if primary else CYAN)
	return button

func _label(copy: String, font_size: int = 14, color: Color = TEXT, wrap: bool = false) -> Label:
	var label := Label.new()
	label.text = copy
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if wrap else TextServer.AUTOWRAP_OFF
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL if wrap else Control.SIZE_SHRINK_BEGIN
	return label

func _surface_box(fill: Color, border: Color, _radius: int, inset: int, depth: int = 0) -> StyleBoxFlat:
	return Tokens.panel(fill, border, inset, depth)

func _nav_box(active: bool, hovered: bool = false, pressed: bool = false) -> StyleBoxFlat:
	var fill := Color("17314e") if active else Color("13253a") if hovered else Color(0, 0, 0, 0)
	var border := Color("28516b") if active else Color("31516d") if hovered else Color(0, 0, 0, 0)
	var style := _surface_box(Color("1d4059") if pressed else fill, border, 2, 8, 0 if pressed else (3 if active or hovered else 0))
	if active:
		style.border_width_left = 4
		style.border_color = CYAN
	return style

func _language_box(active: bool) -> StyleBoxFlat:
	var style := _surface_box(Color("1a3654") if active else Color(0, 0, 0, 0), Color("42c8e6") if active else Color("20334d"), 2, 4, 1 if active else 0)
	if active:
		style.border_width_bottom = 3
	return style

func _button_box(primary: bool, hovered: bool, pressed: bool = false) -> StyleBoxFlat:
	if primary:
		var primary_fill := Color("28bedb") if pressed else Color("78e7f4") if hovered else Color("45d8ef")
		var primary_style := _surface_box(primary_fill, Color("a5f2ff") if hovered else Color("6ce6f5"), 2, 10, 0 if pressed else (4 if hovered else 2))
		primary_style.border_width_bottom = 1 if pressed else 4
		return primary_style
	var fill := Color("1f4058") if pressed else Color("1c3553") if hovered else Color("172640")
	var secondary_style := _surface_box(fill, Color("80cce0") if hovered else Color("526887"), 2, 10, 0 if pressed else (4 if hovered else 2))
	secondary_style.border_width_bottom = 1 if pressed else 4
	return secondary_style

func _grid_columns() -> int:
	return 2 if _content_width() >= 680 else 1

func _metric_columns() -> int:
	var width := _content_width()
	return 3 if width >= 760 else 2 if width >= 470 else 1

func _viewport_width() -> float:
	return float(get_window().size.x)

func _content_width() -> float:
	var width := _viewport_width()
	var outer_inset := 12.0 if width < 600 else 18.0 if width < 960 else 22.0
	var sidebar_and_gap := 240.0 if width >= 960 else 0.0
	return maxf(0.0, width - outer_inset * 2.0 - sidebar_and_gap - 9.0)

func _layout_class() -> String:
	var width := _viewport_width()
	return "phone" if width < 600 else "tablet" if width < 960 else "desktop"

func _sync_responsive_layout() -> void:
	var width := _viewport_width()
	var compact := width < 960
	var phone := width < 600
	var tiny_phone := width < 420
	last_layout_class = _layout_class()
	sidebar_shell.visible = not compact
	mobile_navigation.visible = compact
	connect_button.visible = not phone
	page_kicker_label.visible = not phone
	if outer_margin != null:
		var inset := 12 if phone else 18 if compact else 22
		outer_margin.add_theme_constant_override("margin_left", inset)
		outer_margin.add_theme_constant_override("margin_right", inset)
		outer_margin.add_theme_constant_override("margin_top", 11 if phone else 16 if compact else 18)
		outer_margin.add_theme_constant_override("margin_bottom", 10 if phone else 14)
	if app_row != null:
		app_row.add_theme_constant_override("separation", 0 if compact else 18)
	if main_container != null:
		main_container.add_theme_constant_override("separation", 8 if phone else 10 if compact else 12)
	if header_container != null:
		header_container.add_theme_constant_override("separation", 8 if phone else 14 if compact else 18)
		header_container.custom_minimum_size.y = 54 if phone else 58
	if mobile_navigation != null:
		mobile_navigation.add_theme_constant_override("separation", 3 if tiny_phone else 5)
	if discussion_filters != null and is_instance_valid(discussion_filters):
		discussion_filters.vertical = _content_width() < 520
		_sync_filter_children(discussion_filters)
	if mod_filters != null and is_instance_valid(mod_filters):
		mod_filters.vertical = _content_width() < 520
		_sync_filter_children(mod_filters)
	if hero_block_plaque != null and is_instance_valid(hero_block_plaque):
		hero_block_plaque.visible = _content_width() >= 820
	_update_responsive_grids()
	_sync_chrome()

func _update_responsive_grids() -> void:
	if metric_grid != null and is_instance_valid(metric_grid):
		metric_grid.columns = _metric_columns()
	if home_discussion_grid != null and is_instance_valid(home_discussion_grid):
		home_discussion_grid.columns = _grid_columns()
	if discussion_results != null and is_instance_valid(discussion_results):
		discussion_results.columns = _grid_columns()
	if mod_results != null and is_instance_valid(mod_results):
		mod_results.columns = _grid_columns()

func _sync_filter_children(container: BoxContainer) -> void:
	var children := container.get_children()
	for index in range(children.size()):
		var control := children[index] as Control
		if index == 0 or container.vertical:
			control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		else:
			control.size_flags_horizontal = Control.SIZE_SHRINK_END

func _on_viewport_resized() -> void:
	call_deferred("_apply_responsive_resize")

func _apply_responsive_resize() -> void:
	var previous_class := last_layout_class
	_sync_responsive_layout()
	if previous_class != last_layout_class and page_content != null and is_instance_valid(page_content):
		_render_page()

func _on_discussion_search(value: String) -> void:
	discussion_query = value
	_refresh_discussion_cards()

func _on_mod_search(value: String) -> void:
	mod_query = value
	_refresh_mod_cards()

func _on_discussion_category(index: int, values: Array[String]) -> void:
	discussion_category = values[index]
	_refresh_discussion_cards()

func _on_mod_category(index: int, values: Array) -> void:
	mod_category = str(values[index])
	_refresh_mod_cards()

func _localized_mod_type(value: String) -> String:
	match value:
		"桌面主题": return I18n.text("mod_type_theme")
		"桌面小组件": return I18n.text("mod_type_widget")
		"世界资源": return I18n.text("mod_type_world")
		_: return value

func _open_discussion(record: Dictionary) -> void:
	selected_discussion_id = str(record.get("id", ""))
	if not bool(record.get("is_demo", true)):
		AppServices.fetch_discussion_detail(record)
	_render_page()

func _start_github_sign_in() -> void:
	var result: Dictionary = AppServices.auth.start_sign_in()
	_show_toast(I18n.auth_error_label(str(result.get("code", "oauth_not_configured"))))

func _on_reply_requested() -> void:
	if not AppServices.auth.is_authorized():
		_start_github_sign_in()
	else:
		_show_toast(I18n.text("toast_write"))

func _on_community_content_changed() -> void:
	if page_content != null and is_instance_valid(page_content):
		_render_page()

func _open_mod(record: Dictionary) -> void:
	selected_mod_id = str(record.get("id", ""))
	_render_page()

func _show_toast(copy: String) -> void:
	toast_label.text = copy
	toast_timer.start()

func _on_ime_text_changed() -> void:
	ime_draft = ime_editor.text
	ime_count_label.text = I18n.text("characters") % ime_draft.length()

func _update_performance() -> void:
	if performance_label == null or not is_instance_valid(performance_label):
		return
	var fps := Engine.get_frames_per_second()
	var process_ms := float(Performance.get_monitor(Performance.TIME_PROCESS)) * 1000.0
	var video_mb := float(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)) / (1024.0 * 1024.0)
	performance_label.text = I18n.text("fps_line") % [fps, process_ms, video_mb]

func _input(event: InputEvent) -> void:
	var active_input := false
	if event is InputEventMouseMotion:
		var pointer := (event as InputEventMouseMotion).position
		active_input = pointer.distance_to(last_mouse_position) >= 2.0
		last_mouse_position = pointer
	else:
		active_input = event is InputEventMouseButton or event is InputEventKey or event is InputEventScreenTouch or event is InputEventScreenDrag
	if active_input:
		Engine.max_fps = 60
		if idle_fps_timer != null:
			idle_fps_timer.start()

func _return_to_idle_fps() -> void:
	Engine.max_fps = 10

func _clear_page() -> void:
	performance_label = null
	if ime_editor != null and is_instance_valid(ime_editor):
		ime_draft = ime_editor.text
	ime_editor = null
	ime_count_label = null
	if page_content == null:
		return
	for child in page_content.get_children():
		page_content.remove_child(child)
		child.queue_free()
	discussion_results = null
	mod_results = null
	discussion_count_label = null
	mod_count_label = null
	metric_grid = null
	home_discussion_grid = null
	discussion_filters = null
	mod_filters = null
	hero_block_plaque = null

func _clear_container(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func hero_margin_full(container: Control, horizontal: int, vertical: int) -> void:
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.add_theme_constant_override("margin_left", horizontal)
	container.add_theme_constant_override("margin_right", horizontal)
	container.add_theme_constant_override("margin_top", vertical)
	container.add_theme_constant_override("margin_bottom", vertical)

func safety_copy_row(parent: VBoxContainer) -> void:
	parent.add_child(_label(I18n.text("mod_safety_title"), 12, TEXT))
	parent.add_child(_label(I18n.text("mod_safety_body"), 10, MUTED, true))
