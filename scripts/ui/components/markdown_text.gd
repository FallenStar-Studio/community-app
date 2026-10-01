extends RichTextLabel
## Safe, small Markdown reader. User text is added as text, never interpreted as BBCode.
const Tokens = preload("res://scripts/ui/design_tokens.gd")
var _inline := RegEx.new()

func setup(markdown: String) -> void:
	bbcode_enabled = false
	selection_enabled = true
	fit_content = true
	scroll_active = false
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_theme_font_size_override("normal_font_size", Tokens.TEXT_BODY)
	add_theme_constant_override("line_separation", 6)
	_inline.compile("\\*\\*([^*]+)\\*\\*|\\[([^\\]]+)\\]\\((https://[^\\s)]+)\\)")
	clear()
	var in_code := false
	for line: String in markdown.split("\n"):
		if line.begins_with("```"):
			in_code = not in_code
			add_text("\n")
			continue
		if in_code:
			push_color(Tokens.CYAN)
			add_text(line + "\n")
			pop()
			continue
		var level := 0
		while level < line.length() and level < 6 and line[level] == "#":
			level += 1
		if level > 0 and line.length() > level and line[level] == " ":
			push_font_size(24 if level == 1 else (20 if level == 2 else 17))
			push_bold()
			_append_inline(line.substr(level + 1))
			pop()
			pop()
			add_text("\n\n")
		else:
			var display_line := "• " + line.substr(2) if line.begins_with("- ") or line.begins_with("* ") else line
			_append_inline(display_line)
			add_text("\n")
	if not meta_clicked.is_connected(_open_link):
		meta_clicked.connect(_open_link)

func _append_inline(copy: String) -> void:
	var cursor := 0
	for match_result: RegExMatch in _inline.search_all(copy):
		add_text(copy.substr(cursor, match_result.get_start() - cursor))
		if not match_result.get_string(1).is_empty():
			push_bold()
			add_text(match_result.get_string(1))
			pop()
		else:
			var url := match_result.get_string(3)
			if _safe_url(url):
				push_meta(url)
				push_color(Tokens.CYAN)
				push_underline()
				add_text(match_result.get_string(2))
				pop()
				pop()
				pop()
			else:
				add_text(match_result.get_string())
		cursor = match_result.get_end()
	add_text(copy.substr(cursor))

func _safe_url(url: String) -> bool:
	return url.begins_with("https://") and not url.substr(8).get_slice("/", 0).contains("@") and not url.contains("\n")

func _open_link(value: Variant) -> void:
	var url := str(value)
	if _safe_url(url):
		OS.shell_open(url)
