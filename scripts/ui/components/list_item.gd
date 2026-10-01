extends Button
## Native list module: grows with wrapped Chinese/English text.
const Tokens = preload("res://scripts/ui/design_tokens.gd")
signal open_requested(record: Dictionary)
var record: Dictionary = {}
var is_mod := false
var stack: VBoxContainer

func setup(value: Dictionary, mod_entry: bool = false) -> void:
	record = value
	is_mod = mod_entry
	name = "Entry_" + str(record.get("id", "entry")).validate_node_name()
	toggle_mode = true
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(0, 148)
	add_theme_stylebox_override("normal", Tokens.panel(Tokens.SURFACE, Tokens.LINE, 0, 2))
	add_theme_stylebox_override("hover", Tokens.panel(Tokens.SURFACE_RAISED, Tokens.CYAN, 0, 3))
	var selected := Tokens.panel(Tokens.SURFACE_RAISED, Tokens.CYAN, 0, 3)
	selected.set_border_width_all(2)
	selected.border_width_left = 5
	add_theme_stylebox_override("pressed", selected)
	add_theme_color_override("font_pressed_color", Tokens.TEXT)
	add_theme_stylebox_override("focus", Tokens.focus_ring())
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)
	stack = VBoxContainer.new()
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_theme_constant_override("separation", 8)
	margin.add_child(stack)
	var meta := HBoxContainer.new()
	meta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	meta.add_theme_constant_override("separation", 6)
	stack.add_child(meta)
	meta.add_child(_label(I18n.field(record, "type" if is_mod else "category"), 11, Tokens.CYAN, true))
	meta.add_child(_label(I18n.source_label(record), 10, Tokens.AMBER if bool(record.get("is_demo", true)) else Tokens.MUTED))
	stack.add_child(_label(I18n.field(record, "name" if is_mod else "title"), 18, Tokens.TEXT, true))
	var preview := I18n.field(record, "description" if is_mod else "body").replace("\n", " ").replace("#", "").replace("**", "")
	var description := _label(preview, 13 if is_mod else 12, Tokens.MUTED, true)
	description.max_lines_visible = 3 if is_mod else 2
	stack.add_child(description)
	var footer_text := "%s  ·  %s" % [I18n.field(record, "author"), I18n.field(record, "version") if is_mod else I18n.text("comment_count") % int(record.get("comment_count", 0))]
	stack.add_child(_label(footer_text, 11, Tokens.MUTED, true))
	stack.minimum_size_changed.connect(_sync_height)
	resized.connect(_sync_height)
	pressed.connect(func() -> void: open_requested.emit(record))
	call_deferred("_sync_height")

func _sync_height() -> void:
	if is_instance_valid(stack):
		var wanted := maxf(148.0, stack.get_combined_minimum_size().y + 28.0)
		if not is_equal_approx(wanted, custom_minimum_size.y):
			custom_minimum_size.y = wanted

func _label(copy: String, font_size: int, color: Color, wrap: bool = false) -> Label:
	var label := Label.new()
	label.text = copy
	if font_size >= 18:
		label.theme_type_variation = "Heading"
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL if wrap else Control.SIZE_SHRINK_BEGIN
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if wrap else TextServer.AUTOWRAP_OFF
	return label
