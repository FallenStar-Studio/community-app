extends CommunityService

const DISCUSSIONS_PATH := "res://data/demo/discussions.json"
const MODS_PATH := "res://data/registry/mods.json"

var _discussions: Array[Dictionary] = []
var _mods: Array[Dictionary] = []

func _init() -> void:
	_discussions = _load_entries(DISCUSSIONS_PATH, true)
	_mods = _load_entries(MODS_PATH, false)

func service_label() -> String:
	return "本地演示数据"

func list_discussions(category: String = "", query: String = "") -> Array[Dictionary]:
	return _filter_records(_discussions, category, query)

func get_discussion(id: String) -> Dictionary:
	for record in _discussions:
		if record["id"] == id:
			return record.duplicate(true)
	return {}

func list_categories() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var seen: Dictionary = {}
	for record in _discussions:
		var value := str(record.get("category", "General"))
		if seen.has(value):
			continue
		seen[value] = true
		result.append({
			"value": value,
			"name": value,
			"name_en": str(record.get("category_en", value)),
			"name_zh": value
		})
	return result

func list_mods(mod_type: String = "", query: String = "") -> Array[Dictionary]:
	return _filter_records(_mods, mod_type, query)

func get_mod(id: String) -> Dictionary:
	for record in _mods:
		if record["id"] == id:
			return record.duplicate(true)
	return {}

func _filter_records(records: Array[Dictionary], category: String, query: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var needle := query.strip_edges().to_lower()
	for record in records:
		var record_category := str(record.get("category", record.get("type", "")))
		if not category.is_empty() and category != "全部" and record_category != category:
			continue
		var searchable := "%s %s %s %s %s %s %s %s" % [
			record.get("title", record.get("name", "")),
			record.get("title_en", record.get("name_en", "")),
			record.get("body", record.get("description", "")),
			record.get("body_en", record.get("description_en", "")),
			record.get("author", ""),
			record.get("author_en", ""),
			record_category,
			record.get("category_en", record.get("type_en", ""))
		]
		if not needle.is_empty() and not searchable.to_lower().contains(needle):
			continue
		result.append(record.duplicate(true))
	return result

func _load_entries(path: String, is_discussion: bool) -> Array[Dictionary]:
	var output: Array[Dictionary] = []
	if not FileAccess.file_exists(path):
		push_warning("Demo data file not found: %s" % path)
		return output
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Array:
		push_warning("Demo data must be a JSON array: %s" % path)
		return output
	var seen: Dictionary = {}
	for raw: Variant in parsed:
		if not raw is Dictionary:
			continue
		var valid := DiscussionEntry.is_valid(raw) if is_discussion else bool(raw.get("demo_only", false))
		if not valid:
			continue
		var record := DiscussionEntry.normalize(raw) if is_discussion else ModEntry.normalize(raw)
		if is_discussion:
			record["source"] = "demo"
			record["is_demo"] = true
			for comment: Variant in record.get("comments", []):
				if comment is Dictionary:
					comment["source"] = "demo"
					comment["is_demo"] = true
		if seen.has(record["id"]):
			continue
		seen[record["id"]] = true
		output.append(record)
	return output
