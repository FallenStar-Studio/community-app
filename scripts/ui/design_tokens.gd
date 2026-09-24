extends RefCounted
## Shared Block-native design tokens for the standalone client and future Plyra UI reuse.

const INK := Color("080d18")
const SIDEBAR := Color("0d1525")
const SURFACE := Color("111d31")
const SURFACE_RAISED := Color("172640")
const LINE := Color("293c5a")
const TEXT := Color("eef5ff")
const MUTED := Color("9aa9bf")
const CYAN := Color("41d7f5")
const BLUE := Color("438dff")
const AMBER := Color("ffbd70")
const SHADOW := Color(0.01, 0.025, 0.055, 0.68)

const SPACE_1 := 4
const SPACE_2 := 8
const SPACE_3 := 12
const SPACE_4 := 16
const SPACE_5 := 22

const BORDER_THIN := 2
const BORDER_ACTIVE := 2
const CORNER_BLOCK := 0
const METRIC_MIN_WIDTH := 176
const CARD_MIN_WIDTH := 260
const CONTROL_MIN_HEIGHT := 40

const TEXT_CAPTION := 10
const TEXT_BODY := 13
const TEXT_TITLE := 24
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
		style.shadow_size = depth
		style.shadow_offset = Vector2(2, 3)
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
