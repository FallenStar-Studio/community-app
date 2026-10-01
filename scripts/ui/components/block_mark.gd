extends Control
## A small static block arch. No texture, shader or frame-by-frame animation.
const Tokens = preload("res://scripts/ui/design_tokens.gd")
const CELLS := [Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(0, 2), Vector2i(1, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(0, 3), Vector2i(4, 3), Vector2i(0, 4), Vector2i(4, 4)]

func _ready() -> void:
	custom_minimum_size = Vector2(36, 36)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	var step := floorf(minf(size.x, size.y) / 5.0)
	var origin := (size - Vector2(step * 5.0, step * 5.0)) / 2.0
	for cell: Vector2i in CELLS:
		var block := Rect2(origin + Vector2(cell) * step, Vector2.ONE * (step - 1.0))
		draw_rect(Rect2(block.position + Vector2(1, 1), block.size), Tokens.SHADOW)
		draw_rect(block, Tokens.CYAN)
