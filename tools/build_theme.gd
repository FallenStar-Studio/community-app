extends SceneTree
const Tokens = preload("res://scripts/ui/design_tokens.gd")
func _initialize() -> void:
	var result := ResourceSaver.save(Tokens.make_theme(), "res://themes/plyra_theme.tres")
	if result != OK:
		push_error("Theme generation failed: %s" % result)
	quit(0 if result == OK else 1)
