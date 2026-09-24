extends PanelContainer
## Reusable 2D cut-corner frame. Content remains native, interactive Control nodes.

const Tokens = preload("res://scripts/ui/design_tokens.gd")

var fill_color := Tokens.SURFACE
var edge_color := Tokens.LINE
var inset := Tokens.SPACE_4
var depth := 2
var cut_size := 8
var edge_width := Tokens.BORDER_THIN

func _ready() -> void:
	resized.connect(_on_resized)
	_apply_content_inset()
	queue_redraw()

func configure(fill: Color, edge: Color, padding: int = Tokens.SPACE_4, shadow_depth: int = 2, chamfer: int = 8, border_width: int = Tokens.BORDER_THIN) -> void:
	fill_color = fill
	edge_color = edge
	inset = padding
	depth = shadow_depth
	cut_size = chamfer
	edge_width = border_width
	_apply_content_inset()
	queue_redraw()

func _apply_content_inset() -> void:
	var empty_style := StyleBoxFlat.new()
	empty_style.bg_color = Color(0, 0, 0, 0)
	empty_style.border_color = Color(0, 0, 0, 0)
	empty_style.set_border_width_all(0)
	empty_style.set_corner_radius_all(0)
	empty_style.content_margin_left = inset
	empty_style.content_margin_right = inset
	empty_style.content_margin_top = inset
	empty_style.content_margin_bottom = inset
	add_theme_stylebox_override("panel", empty_style)

func _draw() -> void:
	if size.x < 2 or size.y < 2:
		return
	if depth > 0:
		draw_colored_polygon(_polygon(size, Vector2(2, 3)), Tokens.SHADOW)
	draw_colored_polygon(_polygon(size, Vector2.ZERO), fill_color)
	var outline := _polygon(size, Vector2.ZERO)
	outline.append(outline[0])
	draw_polyline(outline, edge_color, float(edge_width), false)
	if size.x > cut_size * 3:
		draw_line(Vector2(cut_size + 2, 1), Vector2(size.x - cut_size - 2, 1), Color(Tokens.TEXT, 0.08), 1.0, false)

func _polygon(extent: Vector2, offset: Vector2) -> PackedVector2Array:
	var cut := minf(float(cut_size), minf(extent.x, extent.y) * 0.16)
	return PackedVector2Array([
		Vector2(cut, 0) + offset,
		Vector2(extent.x - cut, 0) + offset,
		Vector2(extent.x, cut) + offset,
		Vector2(extent.x, extent.y - cut) + offset,
		Vector2(extent.x - cut, extent.y) + offset,
		Vector2(cut, extent.y) + offset,
		Vector2(0, extent.y - cut) + offset,
		Vector2(0, cut) + offset
	])

func _on_resized() -> void:
	queue_redraw()
