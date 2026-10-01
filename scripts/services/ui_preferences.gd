extends Node
## Local appearance preferences only. Never stores drafts, account data or tokens.
signal appearance_changed
const PATH := "user://preferences.cfg"
const MOTION_MODES := ["adaptive", "continuous", "off"]
var language_code := "en"
var background_motion := "adaptive"

func _ready() -> void:
	var preferences := ConfigFile.new()
	preferences.load(PATH)
	var locale := "zh" if OS.get_locale_language() == "zh" else "en"
	language_code = "zh" if str(preferences.get_value("ui", "language", locale)) == "zh" else "en"
	var motion := str(preferences.get_value("ui", "background_motion", "adaptive"))
	background_motion = motion if motion in MOTION_MODES else "adaptive"

func set_language(code: String) -> void:
	language_code = "zh" if code == "zh" else "en"
	_save("language", language_code)

func set_background_motion(mode: String, persist: bool = true) -> void:
	var next := mode if mode in MOTION_MODES else "adaptive"
	if persist:
		_save("background_motion", next)
	if next == background_motion:
		return
	background_motion = next
	appearance_changed.emit()

func _save(key: String, value: String) -> void:
	var preferences := ConfigFile.new()
	preferences.load(PATH)
	preferences.set_value("ui", key, value)
	var result := preferences.save(PATH)
	if result != OK:
		push_warning("Could not save appearance preference: %s" % error_string(result))
