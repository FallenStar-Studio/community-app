extends Node
## Layout checks requested for the bilingual desktop/phone migration.
## Headless geometry does not validate a platform IME or Android keyboard.
const Shell = preload("res://scenes/community_shell.tscn")
const MarkdownText = preload("res://scripts/ui/components/markdown_text.gd")
const GitHubSource = preload("res://scripts/services/github_community_service.gd")
const BlockOrbits = preload("res://scripts/ui/components/block_orbits.gd")
var _passed := 0
var _failed := 0
var root: Window

func _ready() -> void:
	root = get_tree().root
	call_deferred("_run")

func _run() -> void:
	AppServices.set_demo_mode(true)
	UiPreferences.set_background_motion("off", false)
	for width: int in [320, 360, 390, 759, 760, 900, 1099, 1100, 1200, 1360]:
		root.size = Vector2i(width, 800)
		for language: String in ["en", "zh"]:
			I18n.set_language(language, false)
			for page: String in ["discussions", "mods", "settings"]:
				var shell = Shell.instantiate()
				shell.current_page = page
				root.add_child(shell)
				await _settle()
				var label := "%d / %s / %s" % [width, language, page]
				var margin := shell.get_node("WindowMargin") as Control
				_check(margin.get_combined_minimum_size().x <= width + 1, label + " fits horizontally")
				_check(margin.get_combined_minimum_size().y <= 800, label + " fits vertically")
				var settings := shell.find_child("GlobalSettings", true, false) as Button
				_check(settings != null and settings.visible and shell.find_child("Header", true, false).is_ancestor_of(settings), label + " has direct global Settings")
				_check(shell.find_child("Nav_settings", true, false) == null, label + " keeps Settings separate from community navigation")
				if page != "settings":
					_check(shell.find_child("LanguagePreference", true, false) == null, label + " keeps language controls out of content pages")
					_check(shell._list_buttons.size() > 0, label + " displays demo entries")
					if width < 760:
						_check(shell.find_child("BottomNavigation", true, false) != null and shell.find_child("CategoryRail", true, false) == null, label + " uses phone navigation")
						var entry: Dictionary = AppServices.community.list_mods()[0] if page == "mods" else AppServices.community.list_discussions()[0]
						shell._open_record(entry)
						await _settle()
						_check(shell.find_child("BackToList", true, false) != null and shell.find_child("EntryList", true, false) == null, label + " opens a separate reader")
						_check(margin.get_combined_minimum_size().x <= width + 1, label + " reader fits horizontally")
					elif width >= 1100:
						_check(shell.find_child("ListReaderSplit", true, false) != null, label + " has a resizable split reader")
						_check(shell._list_buttons[0].button_pressed, label + " preserves selection")
					else:
						_check(shell.find_child("ListReaderSplit", true, false) == null, label + " uses a single pane")
					shell._show_account()
					await _settle()
					var frame := shell.find_child("AccountDialogFrame", true, false) as Control
					_check(frame != null and frame.size.x <= width - 24, label + " account dialog fits")
				else:
					_check(shell.find_child("LanguagePreference", true, false) != null, label + " includes language in settings")
					var editor := shell.find_child("InputPreview", true, false) as TextEdit
					editor.text = "中文输入 / English / 方块 UI"
					editor.text_changed.emit()
					_check(shell.ime_draft == editor.text, label + " retains mixed input in this session")
				root.remove_child(shell)
				shell.queue_free()
				await get_tree().process_frame
	root.size = Vector2i(1200, 800)
	var shell = Shell.instantiate()
	root.add_child(shell)
	await _settle()
	var search: LineEdit = shell._query_edit
	shell.find_child("GlobalSettings", true, false).pressed.emit()
	await _settle()
	_check(shell.current_page == "settings" and shell.find_child("LanguagePreference", true, false) != null, "global Settings opens directly in one action")
	shell._show_page("discussions")
	await _settle()
	search = shell._query_edit
	search.text = "no-such-讨论-123"
	search.text_changed.emit(search.text)
	await _settle()
	_check(is_instance_valid(search) and search == shell._query_edit, "search retains its input node while filtering")
	_check(shell._list_buttons.is_empty() and shell.selected_discussion_id.is_empty(), "empty search clears wide-reader selection")
	var live := GitHubSource.new()
	live.accept_public_feed({"schemaVersion": 1, "categories": [], "posts": []})
	live.accept_mod_registry([])
	AppServices.demo_mode = false
	AppServices.set_community_service(live)
	shell._show_page("mods")
	await _settle()
	_check(shell._list_buttons.is_empty(), "empty live registry never invents demo MOD rows")
	_check(shell._source_label.text == I18n.text("status_live_registry"), "registry success has its own live status")
	live.set_failure({"operation": "mod_registry", "code": "network_error"})
	await _settle()
	_check(live.content_status().get("code") == "live_feed", "MOD network errors do not overwrite the discussion status")
	_check(shell._source_label.text.contains(I18n.text("source_cached_error")), "MOD request error keeps valid loaded registry data")
	var markdown := MarkdownText.new()
	root.add_child(markdown)
	markdown.setup("## 混排 English\n**Strong** [GitHub](https://github.com/FallenStar-Studio/community)\n[color=red]literal text[/color]")
	await _settle()
	_check(markdown.get_parsed_text().contains("[color=red]literal text[/color]"), "untrusted BBCode remains literal")
	_check(markdown.get_parsed_text().contains("Strong GitHub"), "basic Markdown has native readable text")
	I18n.set_language("zh", false)
	_check(I18n.field({"body_en": "English-only reply / 混排"}, "body") == "English-only reply / 混排", "missing translation falls back to available copy")
	var orbits := BlockOrbits.new()
	orbits.motion_mode = "off"
	root.add_child(orbits)
	_check(not orbits.is_processing(), "off background has no process loop")
	orbits.motion_mode = "adaptive"
	orbits.set_idle(true)
	orbits._on_focus_entered()
	_check(not orbits.is_processing(), "adaptive background freezes when idle")
	orbits.set_idle(false)
	_check(orbits.is_processing(), "adaptive background wakes on interaction")
	orbits.set_motion_mode("continuous")
	orbits.set_idle(true)
	_check(orbits.is_processing(), "continuous mode is explicitly available")
	orbits._on_focus_exited()
	_check(not orbits.is_processing(), "background pauses when the window loses focus")
	orbits.queue_free()
	markdown.queue_free()
	root.remove_child(shell)
	shell.queue_free()
	await get_tree().process_frame
	print("UI layout result: %d passed, %d failed" % [_passed, _failed])
	get_tree().quit(1 if _failed > 0 else 0)

func _settle() -> void:
	for _frame in 5:
		await get_tree().process_frame

func _check(ok: bool, label: String) -> void:
	if ok:
		_passed += 1
	else:
		_failed += 1
		push_error("FAIL: " + label)
