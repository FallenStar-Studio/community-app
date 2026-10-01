extends RefCounted
## Shared Block-native design tokens for the standalone client and future Plyra UI reuse.

const INK := Color("0b0c0f")
const SIDEBAR := Color("111318")
const SURFACE := Color("191c22")
const SURFACE_RAISED := Color("262b33")
const LINE := Color("717984")
const LINE_QUIET := Color("343a44")
const TEXT := Color("f1f2ed")
const MUTED := Color("a3a9b2")
const CYAN := Color("89e5f5")
const BLUE := CYAN
const AMBER := Color("e6bd80")
const SHADOW := Color("020305")

const SPACE_1 := 4
const SPACE_2 := 8
const SPACE_3 := 12
const SPACE_4 := 16
const SPACE_5 := 24

const BORDER_THIN := 1
const BORDER_ACTIVE := 3
const CORNER_BLOCK := 0
const METRIC_MIN_WIDTH := 176
const CARD_MIN_WIDTH := 260
const CONTROL_MIN_HEIGHT := 44
const RAIL_WIDTH := 204
const LIST_MIN_WIDTH := 340
const READER_MIN_WIDTH := 420
const PHONE_BREAKPOINT := 760
const SPLIT_BREAKPOINT := 1100

const TEXT_CAPTION := 11
const TEXT_BODY := 15
const TEXT_TITLE := 23
const TEXT_DISPLAY := 28

static func panel(fill: Color = SURFACE, edge: Color = LINE, padding: int = SPACE_4, depth: int = 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = edge
	style.set_border_width_all(BORDER_THIN)
	style.set_corner_radius_all(CORNER_BLOCK)
	style.content_margin_left = padding
	style.content_margin_right = padding
	style.content_margin_top = padding
	style.content_margin_bottom = padding
	if depth > 0:
		style.shadow_color = SHADOW
		style.shadow_size = 1
		style.shadow_offset = Vector2(depth, depth)
	return style

static func focus_ring() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.border_color = CYAN
	style.set_border_width_all(BORDER_ACTIVE)
	style.set_corner_radius_all(CORNER_BLOCK)
	style.content_margin_left = 2
	style.content_margin_right = 2
	style.content_margin_top = 2
	style.content_margin_bottom = 2
	return style

static func make_theme() -> Theme:
	var result := Theme.new()
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Helvetica Neue", "Noto Sans", "PingFang SC", "Noto Sans CJK SC"])
	font.font_weight = 400
	result.default_font = font
	result.default_font_size = TEXT_BODY
	var heading_font := FontVariation.new()
	heading_font.base_font = font
	heading_font.variation_embolden = 0.5
	result.set_type_variation("Heading", "Label")
	result.set_font("font", "Heading", heading_font)
	var normal := panel(SURFACE, LINE, 10, 2)
	var hover := panel(SURFACE_RAISED, CYAN, 10, 2)
	var pressed := panel(CYAN, CYAN, 10)
	pressed.content_margin_left = 12
	pressed.content_margin_top = 12
	pressed.content_margin_right = 8
	pressed.content_margin_bottom = 8
	var disabled := panel(SIDEBAR, LINE_QUIET, 10)
	var input := panel(INK, LINE, 10)
	var input_focus := panel(INK, CYAN, 10)
	input_focus.set_border_width_all(BORDER_ACTIVE)
	for control_type in ["Button", "OptionButton", "MenuButton"]:
		result.set_stylebox("normal", control_type, normal)
		result.set_stylebox("hover", control_type, hover)
		result.set_stylebox("pressed", control_type, pressed)
		result.set_stylebox("disabled", control_type, disabled)
		result.set_stylebox("focus", control_type, focus_ring())
		result.set_color("font_color", control_type, TEXT)
		result.set_color("font_hover_color", control_type, TEXT)
		result.set_color("font_pressed_color", control_type, INK)
		result.set_color("font_disabled_color", control_type, MUTED)
		result.set_font_size("font_size", control_type, 13)
	for control_type in ["LineEdit", "TextEdit"]:
		result.set_stylebox("normal", control_type, input)
		result.set_stylebox("focus", control_type, input_focus)
		result.set_color("font_color", control_type, TEXT)
		result.set_color("font_placeholder_color", control_type, MUTED)
		result.set_color("caret_color", control_type, CYAN)
		result.set_color("selection_color", control_type, Color("325662"))
	result.set_stylebox("panel", "PanelContainer", panel())
	result.set_color("font_color", "Label", TEXT)
	result.set_color("default_color", "RichTextLabel", TEXT)
	result.set_font_size("normal_font_size", "RichTextLabel", TEXT_BODY)
	result.set_font("normal_font", "RichTextLabel", font)
	result.set_font("bold_font", "RichTextLabel", heading_font)
	result.set_constant("line_separation", "RichTextLabel", 6)
	result.set_stylebox("panel", "PopupMenu", panel(SIDEBAR, TEXT, 10, 3))
	result.set_stylebox("hover", "PopupMenu", panel(SURFACE_RAISED, CYAN, 5))
	result.set_color("font_color", "PopupMenu", TEXT)
	result.set_color("font_hover_color", "PopupMenu", CYAN)
	result.set_font_size("font_size", "PopupMenu", 14)
	for control_type in ["HScrollBar", "VScrollBar"]:
		result.set_stylebox("scroll", control_type, panel(INK, INK, 2))
		result.set_stylebox("grabber", control_type, panel(LINE, LINE, 3))
		result.set_stylebox("grabber_highlight", control_type, panel(CYAN, CYAN, 3))
		result.set_stylebox("grabber_pressed", control_type, panel(TEXT, TEXT, 3))
	return result
