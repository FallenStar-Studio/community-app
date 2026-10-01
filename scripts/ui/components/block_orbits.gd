extends Control
## Independently drawn 2D orbital blocks, informed by the JVAV background's visual idea.
## Bounded geometry, no shader/3D/bloom/network. Frozen adaptive/off modes stop processing.
const Tokens = preload("res://scripts/ui/design_tokens.gd")
const ORBIT_BLOCKS := 112
const UPDATE_INTERVAL := 1.0 / 15.0
var variant := "background"
var motion_mode := "adaptive"
var _idle := false
var _focused := true
var _phase := 0.0
var _elapsed := 0.0
var _core: Array[Vector2i] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	add_to_group("plyra_orbits")
	for y in range(-5, 6):
		for x in range(-5, 6):
			if x * x + y * y <= 27:
				_core.append(Vector2i(x, y))
	resized.connect(queue_redraw)
	get_window().focus_exited.connect(_on_focus_exited)
	get_window().focus_entered.connect(_on_focus_entered)
	_focused = get_window().has_focus()
	_sync_processing()

func set_motion_mode(mode: String) -> void:
	motion_mode = mode if mode in ["adaptive", "continuous", "off"] else "adaptive"
	_sync_processing()
	queue_redraw()

func set_idle(idle: bool) -> void:
	_idle = idle
	_sync_processing()

func _on_focus_exited() -> void:
	_focused = false
	_sync_processing()

func _on_focus_entered() -> void:
	_focused = true
	_sync_processing()

func _sync_processing() -> void:
	set_process(_focused and motion_mode != "off" and (motion_mode == "continuous" or not _idle))

func _process(delta: float) -> void:
	_phase += delta * 0.16
	_elapsed += delta
	if _elapsed >= UPDATE_INTERVAL:
		_elapsed = 0.0
		queue_redraw()

func _draw() -> void:
	if size.x < 16 or size.y < 16:
		return
	var preview := variant == "preview"
	var banner := variant == "banner"
	var alpha := 0.82 if preview else (0.56 if banner else 0.46)
	var phone := size.x < Tokens.PHONE_BREAKPOINT
	var center := Vector2(size.x * 0.5, size.y * 0.53) if preview else (Vector2(size.x * (0.56 if phone else 0.54), size.y * 0.5) if banner else Vector2(size.x * (0.72 if phone else 0.34), size.y * (0.86 if phone else 0.76)))
	var radius := minf(size.x * 0.40, size.y * 0.8) if preview else (minf(size.x * (0.16 if phone else 0.22), 92.0) if banner else minf(size.x * 0.25, 310.0))
	var tilt := -0.20
	var grid := 32.0 if preview else 64.0
	for x in range(0, int(size.x), int(grid)):
		draw_line(Vector2(x, 0), Vector2(x, size.y), Color(Tokens.LINE, alpha * 0.08), 1)
	for y in range(0, int(size.y), int(grid)):
		draw_line(Vector2(0, y), Vector2(size.x, y), Color(Tokens.LINE, alpha * 0.08), 1)
	var tile := maxf(2.0, radius / 14.0)
	var breath := 0.91 + 0.09 * sin(_phase * 0.8)
	for cell: Vector2i in _core:
		var origin := center + Vector2(cell) * tile
		var lighting := clampf(0.70 - float(cell.x) * 0.09 - float(cell.y) * 0.04, 0.18, 0.95)
		var color := Tokens.TEXT.lerp(Tokens.CYAN, 0.6) if cell.x < -2 else Tokens.CYAN
		draw_rect(Rect2(origin.round(), Vector2.ONE * maxf(2.0, tile - 2.0)), Color(color, alpha * lighting * breath))
	# Sparse angular rails make the orbital silhouette readable without bloom.
	for band: float in [0.74, 0.96, 1.08]:
		for index in 48:
			var angle := float(index) * TAU / 48.0
			var a := Vector2(cos(angle) * radius * band, sin(angle) * radius * band * 0.29).rotated(tilt)
			var b := Vector2(cos(angle + TAU / 48.0) * radius * band, sin(angle + TAU / 48.0) * radius * band * 0.29).rotated(tilt)
			draw_line((center + a).round(), (center + b).round(), Color(Tokens.CYAN, alpha * 0.30), 1)
	for index in ORBIT_BLOCKS:
		var angle := float(index) * TAU / ORBIT_BLOCKS + _phase * (0.5 if index % 3 == 0 else 1.0)
		var band := 0.65 + float(index % 4) * 0.12
		var point := Vector2(cos(angle) * radius * band, sin(angle) * radius * band * 0.29).rotated(tilt)
		var origin := center + point
		var block_size := 3.0 if banner else (5.0 if index % 5 == 0 else 3.0)
		var color := Tokens.AMBER if index % 9 == 0 else Tokens.CYAN
		draw_rect(Rect2(origin.round(), Vector2.ONE * block_size), Color(color, alpha * breath))
	if not banner:
		for index in 24:
			var origin := Vector2(fmod(float(index * 197 + 31), size.x), fmod(float(index * 131 + 73), size.y))
			var width := 4.0 if index % 4 == 0 else 2.0
			draw_rect(Rect2(origin, Vector2.ONE * width), Color(Tokens.CYAN, alpha * 0.24))
