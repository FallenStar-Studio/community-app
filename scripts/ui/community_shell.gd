extends Control
## Content-first native Control shell. Network and normalized models stay in services.
const Tokens = preload("res://scripts/ui/design_tokens.gd")
const ListItem = preload("res://scripts/ui/components/list_item.gd")
const MarkdownText = preload("res://scripts/ui/components/markdown_text.gd")
const BlockMark = preload("res://scripts/ui/components/block_mark.gd")
const BlockOrbits = preload("res://scripts/ui/components/block_orbits.gd")

var current_page := "discussions"
var selected_discussion_id := ""
var selected_mod_id := ""
var discussion_category := ""
var mod_category := ""
var discussion_query := ""
var mod_query := ""
var ime_draft := ""
var _reader_open := false
var _layout_class := ""
var _connected_service: CommunityService
var _page_column: VBoxContainer
var _list_stack: VBoxContainer
var _reader_stack: VBoxContainer
var _rail_categories: VBoxContainer
var _category_picker: OptionButton
var _category_values: Array[String] = []
var _count_label: Label
var _source_label: Label
var _query_edit: LineEdit
var _ime_count: Label
var _performance_label: Label
var _status_timer: Timer
var _idle_timer: Timer
var _toast_timer: Timer
var _toast_label: Label
var _nav_buttons: Dictionary = {}
var _list_buttons: Array[Button] = []
var _last_mouse_position := Vector2(-10000, -10000)
var _account_modal: Control

func _ready() -> void:
	theme = load("res://themes/plyra_theme.tres")
	OS.low_processor_usage_mode = true
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--lang="):
			I18n.set_language(arg.trim_prefix("--lang="), false)
		elif arg.begins_with("--page="):
			var page := arg.trim_prefix("--page=")
			if page in ["discussions", "mods", "settings"]:
				current_page = page
		elif arg.begins_with("--motion="):
			UiPreferences.set_background_motion(arg.trim_prefix("--motion="), false)
	I18n.language_changed.connect(_on_language_changed)
	UiPreferences.appearance_changed.connect(_on_appearance_changed)
	AppServices.community_service_changed.connect(_on_service_changed)
	_connect_service()
	get_viewport().size_changed.connect(_on_viewport_resized)
	_idle_timer = Timer.new()
	_idle_timer.one_shot = true
	_idle_timer.wait_time = 4.0
	_idle_timer.timeout.connect(_on_idle_timeout)
	add_child(_idle_timer)
	_status_timer = Timer.new()
	_status_timer.wait_time = 1.0
	_status_timer.timeout.connect(_update_telemetry)
	add_child(_status_timer)
	_status_timer.start()
	_toast_timer = Timer.new()
	_toast_timer.one_shot = true
	_toast_timer.wait_time = 5.0
	_toast_timer.timeout.connect(_hide_toast)
	add_child(_toast_timer)
	_rebuild_shell()
	_wake_rendering()

func _connect_service() -> void:
	if _connected_service != null and _connected_service.content_changed.is_connected(_on_content_changed):
		_connected_service.content_changed.disconnect(_on_content_changed)
	_connected_service = AppServices.community
	_connected_service.content_changed.connect(_on_content_changed)

func _rebuild_shell() -> void:
	for child: Node in get_children():
		if not child is Timer:
			remove_child(child)
			child.queue_free()
	_nav_buttons.clear()
	_list_buttons.clear()
	_list_stack = null
	_reader_stack = null
	_category_picker = null
	_rail_categories = null
	_performance_label = null
	_query_edit = null
	_layout_class = _get_layout_class()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Tokens.INK
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var field := BlockOrbits.new()
	field.name = "AmbientBlocks"
	field.motion_mode = UiPreferences.background_motion
	field.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(field)
	var margin := MarginContainer.new()
	margin.name = "WindowMargin"
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var inset := 12 if _is_phone() else 16
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, inset)
	add_child(margin)
	var shell := _vbox(12)
	margin.add_child(shell)
	_build_header(shell)
	_source_label = _label("", 11, Tokens.MUTED, true)
	_source_label.name = "ContentProvenance"
	shell.add_child(_source_label)
	var work_row := HBoxContainer.new()
	work_row.name = "Workspace"
	work_row.add_theme_constant_override("separation", 12)
	work_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shell.add_child(work_row)
	if not _is_phone():
		_build_rail(work_row)
	_page_column = _vbox(10)
	_page_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_page_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	work_row.add_child(_page_column)
	if _is_phone():
		_build_bottom_nav(shell)
	_toast_label = _label("", 12, Tokens.AMBER, true)
	_toast_label.visible = false
	shell.add_child(_toast_label)
	_build_page()
	_update_source()

func _build_header(parent: VBoxContainer) -> void:
	var frame := _panel(Tokens.SIDEBAR, Tokens.TEXT, 10, 3)
	frame.name = "Header"
	parent.add_child(frame)
	var field := BlockOrbits.new()
	field.name = "HeaderOrbits"
	field.variant = "banner"
	field.motion_mode = UiPreferences.background_motion
	frame.add_child(field)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10 if _is_phone() else 14)
	frame.add_child(row)
	var mark := BlockMark.new()
	mark.custom_minimum_size = Vector2(32, 32) if _is_phone() else Vector2(36, 36)
	row.add_child(mark)
	var brand := _vbox(0)
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(brand)
	brand.add_child(_label("PLYRA", 22 if not _is_phone() else 18, Tokens.TEXT))
	brand.add_child(_label("COMMUNITY / 01" if not _is_phone() else "COMMUNITY", 9, Tokens.MUTED))
	var settings := _button(I18n.text("nav_settings"))
	settings.name = "GlobalSettings"
	settings.toggle_mode = true
	settings.custom_minimum_size = Vector2(58, 44)
	settings.add_theme_stylebox_override("normal", Tokens.panel(Tokens.SIDEBAR, Tokens.TEXT, 10, 2))
	settings.pressed.connect(_show_page.bind("settings"))
	row.add_child(settings)
	_nav_buttons["settings"] = settings
	var guest := _button(I18n.text("guest_short"))
	guest.name = "Account"
	guest.custom_minimum_size = Vector2(52, 44)
	guest.pressed.connect(_show_account)
	row.add_child(guest)

func _build_rail(parent: HBoxContainer) -> void:
	var frame := _panel(Tokens.SIDEBAR, Tokens.LINE_QUIET, 10, 2)
	frame.name = "CategoryRail"
	frame.custom_minimum_size.x = Tokens.RAIL_WIDTH
	parent.add_child(frame)
	var rail := _vbox(8)
	frame.add_child(rail)
	rail.add_child(_label("COMMUNITY", 10, Tokens.MUTED))
	for page: String in ["discussions", "mods"]:
		var navigation := _button(I18n.text("nav_" + page))
		navigation.name = "Nav_" + page
		navigation.alignment = HORIZONTAL_ALIGNMENT_LEFT
		navigation.toggle_mode = true
		_apply_selection_style(navigation)
		navigation.pressed.connect(_show_page.bind(page))
		rail.add_child(navigation)
		_nav_buttons[page] = navigation
	rail.add_child(_rule())
	_rail_categories = _vbox(5)
	rail.add_child(_rail_categories)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rail.add_child(spacer)
	var art_frame := _panel(Tokens.INK, Tokens.LINE, 0, 0)
	art_frame.custom_minimum_size.y = 104
	rail.add_child(art_frame)
	var art := TextureRect.new()
	art.texture = load("res://assets/images/plyra-world-hero.png")
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.clip_contents = true
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_frame.add_child(art)
	rail.add_child(_label(I18n.text("art_label"), 10, Tokens.CYAN))
	rail.add_child(_label("FallenStar-Studio", 11, Tokens.MUTED))

func _build_bottom_nav(parent: VBoxContainer) -> void:
	var row := HBoxContainer.new()
	row.name = "BottomNavigation"
	row.add_theme_constant_override("separation", 6)
	parent.add_child(row)
	for page: String in ["discussions", "mods"]:
		var button := _button(I18n.text("nav_" + page))
		button.name = "Nav_" + page
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.toggle_mode = true
		_apply_selection_style(button)
		button.pressed.connect(_show_page.bind(page))
		row.add_child(button)
		_nav_buttons[page] = button

func _build_page() -> void:
	_status_timer.stop()
	_clear(_page_column)
	_list_stack = null
	_reader_stack = null
	_category_picker = null
	_query_edit = null
	_performance_label = null
	_list_buttons.clear()
	for page: String in _nav_buttons:
		_nav_buttons[page].set_pressed_no_signal(page == current_page)
	var heading := HBoxContainer.new()
	heading.add_theme_constant_override("separation", 10)
	_page_column.add_child(heading)
	var title := _label(I18n.text("nav_" + current_page), Tokens.TEXT_TITLE, Tokens.TEXT)
	heading.add_child(title)
	var rule := _rule()
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	heading.add_child(rule)
	_count_label = _label("", 11, Tokens.MUTED)
	_count_label.size_flags_horizontal = Control.SIZE_SHRINK_END
	_count_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	heading.add_child(_count_label)
	if current_page != "settings":
		var refresh := _button(I18n.text("source_refresh"))
		refresh.name = "Refresh"
		refresh.custom_minimum_size.y = 36
		refresh.disabled = AppServices.demo_mode
		refresh.pressed.connect(_refresh)
		heading.add_child(refresh)
	if _rail_categories != null:
		_build_categories(_rail_categories, false)
	if current_page == "settings":
		_status_timer.start()
		_build_settings()
		return
	if _layout_class == "wide":
		var split := HSplitContainer.new()
		split.name = "ListReaderSplit"
		split.size_flags_vertical = Control.SIZE_EXPAND_FILL
		split.add_theme_constant_override("separation", 12)
		split.split_offset = -100
		_page_column.add_child(split)
		var list_column := _vbox(8)
		list_column.custom_minimum_size.x = Tokens.LIST_MIN_WIDTH
		split.add_child(list_column)
		_build_list_column(list_column)
		var reader := _make_reader(split)
		reader.custom_minimum_size.x = Tokens.READER_MIN_WIDTH
	else:
		if _reader_open and not _selected_record().is_empty():
			_make_reader(_page_column)
		else:
			var list_column := _vbox(8)
			list_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
			_page_column.add_child(list_column)
			_build_list_column(list_column)
	_update_results()

func _build_list_column(parent: VBoxContainer) -> void:
	_query_edit = LineEdit.new()
	_query_edit.name = "Search"
	_query_edit.custom_minimum_size.y = Tokens.CONTROL_MIN_HEIGHT
	_query_edit.placeholder_text = I18n.text("search_mods" if current_page == "mods" else "search_discussions")
	_query_edit.text = mod_query if current_page == "mods" else discussion_query
	_query_edit.clear_button_enabled = true
	_query_edit.text_changed.connect(_on_query_changed)
	parent.add_child(_query_edit)
	if _is_phone():
		_category_picker = OptionButton.new()
		_category_picker.name = "CategoryFilter"
		_category_picker.custom_minimum_size.y = Tokens.CONTROL_MIN_HEIGHT
		_category_picker.clip_text = true
		_category_picker.item_selected.connect(_on_category_picked)
		parent.add_child(_category_picker)
		_build_categories(null, true)
	var scroll := _scroll()
	scroll.name = "EntryListScroll"
	parent.add_child(scroll)
	_list_stack = _vbox(10)
	_list_stack.name = "EntryList"
	_list_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_list_stack)

func _make_reader(parent: Control) -> PanelContainer:
	var frame := _panel(Tokens.SURFACE, Tokens.LINE_QUIET, 14 if _is_phone() else 22, 3)
	var reader_style := frame.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	reader_style.border_width_top = 3
	reader_style.border_color = Tokens.TEXT
	reader_style.border_width_left = 0
	reader_style.border_width_right = 0
	reader_style.border_width_bottom = 0
	frame.add_theme_stylebox_override("panel", reader_style)
	frame.name = "Reader"
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(frame)
	var scroll := _scroll()
	scroll.name = "ReaderScroll"
	frame.add_child(scroll)
	_reader_stack = _vbox(14)
	_reader_stack.name = "ReaderContent"
	_reader_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_reader_stack)
	return frame

func _build_categories(parent: VBoxContainer, compact: bool) -> void:
	if parent != null:
		_clear(parent)
	if current_page == "settings":
		return
	var categories: Array[Dictionary] = []
	if current_page == "mods":
		var seen: Dictionary = {}
		for record: Dictionary in AppServices.community.list_mods():
			var kind := str(record.get("type", ""))
			if not kind.is_empty() and not seen.has(kind):
				seen[kind] = true
				categories.append({"value": kind, "label": I18n.field(record, "type")})
	else:
		for category: Dictionary in AppServices.community.list_categories():
			categories.append({"value": str(category.get("value", category.get("name", ""))), "label": I18n.field(category, "name")})
	var active := mod_category if current_page == "mods" else discussion_category
	var values: Array[String] = [""]
	for category: Dictionary in categories:
		values.append(str(category["value"]))
	if not values.has(active):
		active = ""
		if current_page == "mods":
			mod_category = ""
		else:
			discussion_category = ""
	if compact:
		_category_picker.clear()
		_category_values = values
		_category_picker.add_item(I18n.text("filter_all"))
		for category: Dictionary in categories:
			_category_picker.add_item(str(category["label"]))
		_category_picker.select(maxi(values.find(active), 0))
	else:
		parent.add_child(_label(I18n.text("mod_types" if current_page == "mods" else "topics"), 10, Tokens.MUTED))
		categories.push_front({"value": "", "label": I18n.text("filter_all")})
		for category: Dictionary in categories:
			var button := _button(str(category["label"]))
			button.name = "Category_" + str(category["value"]).validate_node_name()
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.custom_minimum_size.y = 38
			button.add_theme_font_size_override("font_size", 12)
			button.toggle_mode = true
			_apply_selection_style(button)
			button.button_pressed = str(category["value"]) == active
			button.pressed.connect(_choose_category.bind(str(category["value"])))
			parent.add_child(button)

func _update_results() -> void:
	if current_page == "settings":
		return
	var is_mod := current_page == "mods"
	var entries := AppServices.community.list_mods(mod_category, mod_query) if is_mod else AppServices.community.list_discussions(discussion_category, discussion_query)
	var live := AppServices.community.uses_live_mods() if is_mod else AppServices.community.uses_live_discussions()
	_count_label.text = str(entries.size())
	_count_label.tooltip_text = I18n.text(("mod_count_live" if live else "mod_count") if is_mod else ("discussion_count_live" if live else "discussion_count_demo")) % entries.size()
	if _list_stack != null:
		_clear(_list_stack)
		_list_buttons.clear()
		var selected := selected_mod_id if is_mod else selected_discussion_id
		if _layout_class == "wide" and not _has_id(entries, selected):
			selected = str(entries[0]["id"]) if not entries.is_empty() else ""
			if is_mod:
				selected_mod_id = selected
			else:
				selected_discussion_id = selected
		for record: Dictionary in entries:
			var item := ListItem.new()
			item.setup(record, is_mod)
			item.set_pressed_no_signal(str(record["id"]) == selected)
			item.open_requested.connect(_open_record)
			_list_stack.add_child(item)
			_list_buttons.append(item)
		if entries.is_empty():
			var body_key := "empty_registry" if is_mod and live and mod_query.is_empty() and mod_category.is_empty() else ("empty_mod_body" if is_mod else "empty_discussion_body")
			_empty(_list_stack, I18n.text("empty_mod_title" if is_mod else "empty_discussion_title"), I18n.text(body_key))
	if _reader_stack != null:
		_render_reader()

func _render_reader() -> void:
	_clear(_reader_stack)
	var record := _selected_record()
	if _layout_class != "wide":
		var back := _button(I18n.text("back_list"))
		back.name = "BackToList"
		back.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		back.pressed.connect(func() -> void:
			_reader_open = false
			_build_page())
		_reader_stack.add_child(back)
	if record.is_empty():
		_empty(_reader_stack, I18n.text("read_mod" if current_page == "mods" else "read_discussion"), I18n.text("reader_hint"))
		return
	var is_mod := current_page == "mods"
	var provenance := I18n.source_label(record)
	var category := I18n.field(record, "type" if is_mod else "category")
	_reader_stack.add_child(_label(category.to_upper() + "  /  " + provenance, 11, Tokens.AMBER if bool(record.get("is_demo", false)) else Tokens.CYAN, true))
	_reader_stack.add_child(_label(I18n.field(record, "name" if is_mod else "title"), 24 if _is_phone() else 27, Tokens.TEXT, true))
	_reader_stack.add_child(_label(I18n.field(record, "author") + "  ·  " + str(record.get("version" if is_mod else "updated_at", "")), 12, Tokens.MUTED, true))
	_reader_stack.add_child(_rule())
	if is_mod:
		_render_mod(record)
	else:
		_render_discussion(record)
	var scroll := _reader_stack.get_parent() as ScrollContainer
	if scroll != null:
		scroll.scroll_vertical = 0

func _render_discussion(record: Dictionary) -> void:
	var image_path := str(record.get("image", ""))
	if image_path.begins_with("res://assets/images/") and ResourceLoader.exists(image_path):
		var image := TextureRect.new()
		image.name = "PostImage"
		image.texture = load(image_path)
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.custom_minimum_size.y = 160 if _is_phone() else 200
		_reader_stack.add_child(image)
	var body := MarkdownText.new()
	body.name = "PostBody"
	body.setup(I18n.field(record, "body"))
	_reader_stack.add_child(body)
	_reader_stack.add_child(_rule())
	_reader_stack.add_child(_label(I18n.text("comments_replies"), 17, Tokens.TEXT, true))
	var comments: Array = record.get("comments", [])
	if comments.is_empty():
		_reader_stack.add_child(_label(I18n.text("no_comments"), 14, Tokens.MUTED, true))
	for comment: Variant in comments:
		if comment is Dictionary:
			_add_comment(comment, false)
			for reply: Variant in comment.get("replies", []):
				if reply is Dictionary:
					_add_comment(reply, true)
	_reader_stack.add_child(_label(I18n.text("reply_notice"), 12, Tokens.MUTED, true))
	var url := str(record.get("url", ""))
	if not url.is_empty():
		var open := _button(I18n.text("open_github"), true)
		open.name = "OpenDiscussionOnGitHub"
		open.pressed.connect(_open_url.bind(url))
		_reader_stack.add_child(open)

func _add_comment(record: Dictionary, reply: bool) -> void:
	var frame := _panel(Tokens.SIDEBAR, Tokens.LINE, 12, 0)
	if reply:
		var indent := MarginContainer.new()
		indent.add_theme_constant_override("margin_left", 14)
		_reader_stack.add_child(indent)
		indent.add_child(frame)
	else:
		_reader_stack.add_child(frame)
	var copy := _vbox(6)
	frame.add_child(copy)
	copy.add_child(_label(I18n.field(record, "author") + "  /  " + I18n.source_label(record), 11, Tokens.CYAN, true))
	var body := MarkdownText.new()
	body.setup(I18n.field(record, "body"))
	copy.add_child(body)

func _render_mod(record: Dictionary) -> void:
	_reader_stack.add_child(_label(I18n.field(record, "description"), 16, Tokens.TEXT, true))
	for field: String in ["target", "plyra_compatibility", "license"]:
		var frame := _panel(Tokens.SIDEBAR, Tokens.LINE, 10, 0)
		var copy := _vbox(3)
		frame.add_child(copy)
		copy.add_child(_label(I18n.text("compatibility" if field == "plyra_compatibility" else field).to_upper(), 10, Tokens.CYAN))
		copy.add_child(_label(I18n.field(record, field), 14, Tokens.TEXT, true))
		_reader_stack.add_child(frame)
	_reader_stack.add_child(_label(I18n.text("source_verification"), 17, Tokens.TEXT, true))
	for field: String in ["source_url", "download_url", "sha256"]:
		_reader_stack.add_child(_label(I18n.text(field), 11, Tokens.MUTED))
		var value := str(record.get(field, ""))
		var copy := RichTextLabel.new()
		copy.fit_content = true
		copy.scroll_active = false
		copy.selection_enabled = true
		copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		copy.add_theme_font_size_override("normal_font_size", 13)
		copy.text = value if not value.is_empty() else I18n.text("not_provided")
		_reader_stack.add_child(copy)
	var source := str(record.get("source_url", ""))
	if not bool(record.get("is_demo", false)) and source.begins_with("https://"):
		var open := _button(I18n.text("open_github"))
		open.pressed.connect(_open_url.bind(source))
		_reader_stack.add_child(open)
	_reader_stack.add_child(_label(I18n.text("mod_safety_body"), 12, Tokens.MUTED, true))
	if bool(record.get("is_demo", false)):
		_reader_stack.add_child(_label(I18n.text("demo_no_download"), 11, Tokens.AMBER))

func _build_settings() -> void:
	var scroll := _scroll()
	_page_column.add_child(scroll)
	var stack := _vbox(12)
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(stack)
	var language := _settings_section(stack, I18n.text("language"))
	var language_row := HBoxContainer.new()
	language_row.name = "LanguagePreference"
	language_row.add_theme_constant_override("separation", 8)
	language.add_child(language_row)
	var language_group := ButtonGroup.new()
	for code: String in ["en", "zh"]:
		var language_button := _button("English" if code == "en" else "简体中文")
		language_button.name = "Language_" + code
		language_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		language_button.toggle_mode = true
		language_button.button_group = language_group
		_apply_selection_style(language_button)
		language_button.button_pressed = I18n.language_code == code
		language_button.pressed.connect(I18n.set_language.bind(code))
		language_row.add_child(language_button)
	var motion := _settings_section(stack, I18n.text("background_motion"))
	var motion_picker := OptionButton.new()
	motion_picker.name = "BackgroundMotionChoice"
	motion_picker.custom_minimum_size.y = Tokens.CONTROL_MIN_HEIGHT
	for mode: String in UiPreferences.MOTION_MODES:
		motion_picker.add_item(I18n.text("motion_" + mode))
	motion_picker.select(UiPreferences.MOTION_MODES.find(UiPreferences.background_motion))
	motion_picker.item_selected.connect(func(index: int) -> void: UiPreferences.set_background_motion(UiPreferences.MOTION_MODES[index]))
	motion.add_child(motion_picker)
	motion.add_child(_label(I18n.text("motion_note"), 12, Tokens.MUTED, true))
	var preview_frame := _panel(Tokens.INK, Tokens.LINE, 0, 0)
	preview_frame.custom_minimum_size.y = 148
	motion.add_child(preview_frame)
	var preview := BlockOrbits.new()
	preview.name = "BackgroundPreview"
	preview.variant = "preview"
	preview.motion_mode = UiPreferences.background_motion
	preview_frame.add_child(preview)
	motion.add_child(_label(I18n.text("background_preview"), 10, Tokens.CYAN))
	var source := _settings_section(stack, I18n.text("content_source"))
	var picker := OptionButton.new()
	picker.name = "ContentSourceChoice"
	picker.custom_minimum_size.y = Tokens.CONTROL_MIN_HEIGHT
	picker.add_item(I18n.text("source_public"))
	picker.add_item(I18n.text("source_demo"))
	picker.select(1 if AppServices.demo_mode else 0)
	picker.item_selected.connect(func(index: int) -> void: AppServices.set_demo_mode(index == 1))
	source.add_child(picker)
	source.add_child(_label(I18n.text("source_demo_note" if AppServices.demo_mode else "source_public_note"), 13, Tokens.MUTED, true))
	var account := _settings_section(stack, I18n.text("github_connection"))
	account.add_child(_label(I18n.text("auth_setup_pending"), 14, Tokens.TEXT, true))
	account.add_child(_label(I18n.text("account_body"), 13, Tokens.MUTED, true))
	var github := _button(I18n.text("open_github"))
	github.pressed.connect(_open_url.bind("https://github.com/FallenStar-Studio/community/discussions"))
	account.add_child(github)
	var input := _settings_section(stack, I18n.text("ime_title"))
	input.add_child(_label(I18n.text("ime_body"), 13, Tokens.MUTED, true))
	var editor := TextEdit.new()
	editor.name = "InputPreview"
	editor.custom_minimum_size.y = 156
	editor.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	editor.placeholder_text = I18n.text("ime_placeholder")
	editor.text = ime_draft
	editor.text_changed.connect(func() -> void:
		ime_draft = editor.text
		if is_instance_valid(_ime_count):
			_ime_count.text = I18n.text("characters") % ime_draft.length())
	input.add_child(editor)
	_ime_count = _label(I18n.text("characters") % ime_draft.length(), 11, Tokens.CYAN, true)
	input.add_child(_ime_count)
	var telemetry := _settings_section(stack, I18n.text("performance_title"))
	_performance_label = _label("", 12, Tokens.CYAN, true)
	telemetry.add_child(_performance_label)
	telemetry.add_child(_label(I18n.text("performance_note"), 12, Tokens.MUTED, true))
	_update_telemetry()
	var about := _settings_section(stack, I18n.text("app_about"))
	about.add_child(_label(I18n.text("app_about_body"), 13, Tokens.MUTED, true))

func _settings_section(parent: VBoxContainer, title: String) -> VBoxContainer:
	var frame := _panel(Tokens.SURFACE, Tokens.LINE, 16, 2)
	parent.add_child(frame)
	var stack := _vbox(10)
	frame.add_child(stack)
	stack.add_child(_label(title, 18, Tokens.TEXT, true))
	return stack

func _show_page(page: String) -> void:
	current_page = page
	_reader_open = false
	_build_page()
	_update_source()
	_wake_rendering()

func _choose_category(value: String) -> void:
	if current_page == "mods":
		mod_category = value
	else:
		discussion_category = value
	_reader_open = false
	_build_page()

func _on_category_picked(index: int) -> void:
	if index >= 0 and index < _category_values.size():
		_choose_category(_category_values[index])

func _on_query_changed(value: String) -> void:
	if current_page == "mods":
		mod_query = value
	else:
		discussion_query = value
	_update_results()

func _open_record(record: Dictionary) -> void:
	if current_page == "mods":
		selected_mod_id = str(record["id"])
	else:
		selected_discussion_id = str(record["id"])
		AppServices.fetch_discussion_detail(record)
	_reader_open = true
	if _layout_class == "wide":
		for button: Button in _list_buttons:
			button.set_pressed_no_signal(str(button.record["id"]) == str(record["id"]))
		_render_reader()
	else:
		_build_page()

func _selected_record() -> Dictionary:
	return AppServices.community.get_mod(selected_mod_id) if current_page == "mods" else AppServices.community.get_discussion(selected_discussion_id)

func _has_id(records: Array[Dictionary], id: String) -> bool:
	for record: Dictionary in records:
		if str(record["id"]) == id:
			return true
	return false

func _refresh() -> void:
	AppServices.refresh_community()
	_show_toast(I18n.text("refresh_requested"))
	_update_source()

func _update_source() -> void:
	if not is_instance_valid(_source_label):
		return
	if AppServices.demo_mode:
		_source_label.text = I18n.text("source_demo_status")
		_source_label.add_theme_color_override("font_color", Tokens.AMBER)
		return
	var status := AppServices.community.mod_content_status() if current_page == "mods" else AppServices.community.content_status()
	var code := str(status.get("code", "offline_demo"))
	var live := AppServices.community.uses_live_mods() if current_page == "mods" else AppServices.community.uses_live_discussions()
	if code == "offline_demo":
		_source_label.text = I18n.text("source_loading")
	elif live and code not in ["live_api", "live_feed", "live_registry", "empty_response"]:
		_source_label.text = I18n.text("source_cached_error") + "  /  " + code
	else:
		_source_label.text = I18n.status_label(code)
	_source_label.add_theme_color_override("font_color", Tokens.CYAN if live else Tokens.AMBER)

func _on_content_changed() -> void:
	_update_source()
	if current_page == "settings":
		return
	if _rail_categories != null:
		_build_categories(_rail_categories, false)
	if _category_picker != null:
		_build_categories(null, true)
	_update_results()
	_wake_rendering()

func _on_service_changed() -> void:
	_connect_service()
	selected_discussion_id = ""
	selected_mod_id = ""
	discussion_category = ""
	mod_category = ""
	_reader_open = false
	_rebuild_shell()

func _on_language_changed(_code: String) -> void:
	_rebuild_shell()
	_wake_rendering()

func _on_appearance_changed() -> void:
	get_tree().call_group("plyra_orbits", "set_motion_mode", UiPreferences.background_motion)
	_wake_rendering()

func _on_idle_timeout() -> void:
	Engine.max_fps = 15 if UiPreferences.background_motion == "continuous" else 10
	get_tree().call_group("plyra_orbits", "set_idle", true)

func _on_viewport_resized() -> void:
	if _layout_class != _get_layout_class():
		_rebuild_shell()
	_wake_rendering()

func _get_layout_class() -> String:
	var width := get_viewport_rect().size.x
	return "phone" if width < Tokens.PHONE_BREAKPOINT else ("wide" if width >= Tokens.SPLIT_BREAKPOINT else "compact")

func _is_phone() -> bool:
	return _layout_class == "phone"

func _show_account() -> void:
	if is_instance_valid(_account_modal):
		return
	_account_modal = Control.new()
	_account_modal.name = "AccountDialog"
	_account_modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_account_modal)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.025, 0.035, 0.9)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_account_modal.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_account_modal.add_child(center)
	var frame := _panel(Tokens.SURFACE_RAISED, Tokens.CYAN, 20, 4)
	frame.name = "AccountDialogFrame"
	frame.custom_minimum_size.x = mini(480, int(get_viewport_rect().size.x) - 32)
	frame.mouse_filter = Control.MOUSE_FILTER_STOP
	center.add_child(frame)
	var copy := _vbox(16)
	frame.add_child(copy)
	copy.add_child(_label(I18n.text("account_title"), 23, Tokens.TEXT, true))
	copy.add_child(_label(I18n.text("account_body"), 15, Tokens.TEXT, true))
	var actions := _vbox(8) if _is_phone() else HBoxContainer.new()
	copy.add_child(actions)
	var open := _button(I18n.text("open_github"), true)
	open.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	open.pressed.connect(func() -> void:
		_open_url("https://github.com/FallenStar-Studio/community/discussions")
		_close_account())
	actions.add_child(open)
	var close := _button(I18n.text("close"))
	close.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	close.pressed.connect(_close_account)
	actions.add_child(close)
	close.grab_focus()

func _close_account() -> void:
	if is_instance_valid(_account_modal):
		_account_modal.queue_free()
		_account_modal = null

func _open_url(url: String) -> void:
	if url.begins_with("https://") and not url.substr(8).get_slice("/", 0).contains("@"):
		OS.shell_open(url)

func _show_toast(copy: String) -> void:
	_toast_label.text = copy
	_toast_label.visible = true
	_toast_timer.start()

func _hide_toast() -> void:
	if is_instance_valid(_toast_label):
		_toast_label.visible = false

func _update_telemetry() -> void:
	if not is_instance_valid(_performance_label):
		return
	var fps := int(Engine.get_frames_per_second())
	var process_ms := Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	var video_mb := Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0
	_performance_label.text = I18n.text("fps_line") % [fps, process_ms, video_mb]

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_close_account()
	if event is InputEventMouseMotion:
		if event.position.distance_to(_last_mouse_position) < 1:
			return
		_last_mouse_position = event.position
	_wake_rendering()

func _wake_rendering() -> void:
	Engine.max_fps = 60
	if is_inside_tree():
		get_tree().call_group("plyra_orbits", "set_idle", false)
	if _idle_timer != null:
		_idle_timer.start()

func _button(copy: String, accent: bool = false) -> Button:
	var button := Button.new()
	button.text = copy
	button.custom_minimum_size.y = Tokens.CONTROL_MIN_HEIGHT
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if accent:
		button.add_theme_stylebox_override("normal", Tokens.panel(Tokens.CYAN, Tokens.CYAN, 10, 2))
		button.add_theme_color_override("font_color", Tokens.INK)
	return button

func _apply_selection_style(button: Button) -> void:
	var normal := Tokens.panel(Tokens.SIDEBAR, Tokens.LINE_QUIET, 10)
	normal.set_border_width_all(0)
	normal.border_width_bottom = 1
	button.add_theme_stylebox_override("normal", normal)
	var selected := Tokens.panel(Tokens.CYAN, Tokens.CYAN, 10, 3)
	selected.border_width_left = 5
	selected.border_width_bottom = 3
	button.add_theme_stylebox_override("pressed", selected)
	button.add_theme_color_override("font_pressed_color", Tokens.INK)

func _label(copy: String, font_size: int, color: Color, wrap: bool = false) -> Label:
	var label := Label.new()
	label.text = copy
	if font_size >= 18:
		label.theme_type_variation = "Heading"
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if wrap:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

func _panel(fill: Color, edge: Color, padding: int, depth: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", Tokens.panel(fill, edge, padding, depth))
	return panel

func _vbox(separation: int) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", separation)
	return box

func _scroll() -> ScrollContainer:
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.follow_focus = true
	return scroll

func _rule() -> HSeparator:
	var line := HSeparator.new()
	var stroke := StyleBoxFlat.new()
	stroke.bg_color = Tokens.LINE_QUIET
	stroke.set_content_margin_all(1)
	line.add_theme_stylebox_override("separator", stroke)
	return line

func _empty(parent: VBoxContainer, title: String, body: String) -> void:
	var frame := _panel(Tokens.SIDEBAR, Tokens.LINE, 18, 0)
	parent.add_child(frame)
	var stack := _vbox(10)
	frame.add_child(stack)
	stack.add_child(_label(title, 19, Tokens.TEXT, true))
	stack.add_child(_label(body, 14, Tokens.MUTED, true))

func _clear(parent: Node) -> void:
	for child: Node in parent.get_children():
		parent.remove_child(child)
		child.queue_free()
