extends Button

const Tokens = preload("res://scripts/ui/design_tokens.gd")

signal open_requested(record: Dictionary)

var record: Dictionary = {}

func _ready() -> void:
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	focus_mode = Control.FOCUS_ALL
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_stylebox_override("normal", _card_style(Tokens.SURFACE, Color("435b7a"), 3, 2))
	add_theme_stylebox_override("hover", _card_style(Color("162741"), Tokens.CYAN, 5, 6))
	add_theme_stylebox_override("pressed", _card_style(Color("1d4059"), Tokens.CYAN, 0, 3))
	add_theme_stylebox_override("focus", Tokens.focus_ring())
	pressed.connect(func() -> void: open_requested.emit(record))

func setup(value: Dictionary) -> void:
	record = value
	custom_minimum_size = Vector2(Tokens.CARD_MIN_WIDTH, 166)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", Tokens.SPACE_3)
	margin.add_theme_constant_override("margin_right", Tokens.SPACE_3)
	margin.add_theme_constant_override("margin_top", Tokens.SPACE_3)
	margin.add_theme_constant_override("margin_bottom", Tokens.SPACE_3)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(margin)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", Tokens.SPACE_2)
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(stack)
	var meta := HBoxContainer.new()
	meta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	meta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(meta)
	var category := _tag(I18n.field(record, "category"), Tokens.CYAN, 88)
	meta.add_child(category)
	meta.add_spacer(false)
	var source_color := Tokens.AMBER if bool(record.get("is_demo", true)) else Tokens.CYAN
	meta.add_child(_tag(I18n.source_label(record), source_color))

	var heading := _label(I18n.field(record, "title"), 16, Color("eef5ff"), true)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(heading)
	var excerpt_text := I18n.field(record, "body").replace("\n", " ")
	var excerpt := _label(excerpt_text, 11, Color("aab8cd"), true)
	excerpt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	excerpt.max_lines_visible = 2
	excerpt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(excerpt)
	stack.add_spacer(false)
	var divider := HSeparator.new()
	divider.add_theme_color_override("separator", Color("42536a"))
	stack.add_child(divider)
	var footer := _label("%s  ·  %s  ·  %s" % [I18n.field(record, "author"), record.get("updated_at", ""), I18n.text("comment_count") % int(record.get("comment_count", 0))], 9, Color("8191aa"), true)
	footer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_child(footer)

func _label(copy: String, font_size: int, color: Color, wrap: bool = false) -> Label:
	var label := Label.new()
	label.text = copy
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if wrap else TextServer.AUTOWRAP_OFF
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _tag(copy: String, color: Color, min_width: int = 48) -> PanelContainer:
	var tag := PanelContainer.new()
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tag.custom_minimum_size.x = min_width
	tag.add_theme_stylebox_override("panel", Tokens.panel(Color("102238"), Color(color, 0.68), 4, 0))
	var label := _label(copy, 8, color, true)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.custom_minimum_size.x = maxf(0.0, float(min_width - 12))
	tag.add_child(label)
	return tag

func _card_style(fill: Color, border: Color, depth: int, left_edge: int) -> StyleBoxFlat:
	var style := Tokens.panel(fill, border, 5, depth)
	style.border_width_left = left_edge
	style.border_width_bottom = 3 if depth > 0 else 1
	return style
