class_name ModEntry
extends RefCounted

const ID_PATTERN := "^[A-Za-z0-9._-]{1,200}$"
const HASH_PATTERN := "^[A-Fa-f0-9]{64}$"

static func normalize(raw: Dictionary) -> Dictionary:
	var normalized := raw.duplicate(true)
	normalized.merge({
		"id": str(raw.get("id", "")),
		"name": str(raw.get("name", "")),
		"description": str(raw.get("description", "")),
		"author": str(raw.get("author", "")),
		"version": str(raw.get("version", "")),
		"type": str(raw.get("type", "")),
		"target": str(raw.get("target", "")),
		"plyra_compatibility": str(raw.get("plyraCompatibility", raw.get("plyra_compatibility", ""))),
		"license": str(raw.get("license", "")),
		"source_url": str(raw.get("sourceUrl", raw.get("source_url", ""))),
		"download_url": str(raw.get("downloadUrl", raw.get("download_url", ""))),
		"sha256": str(raw.get("sha256", "")),
		"demo_only": bool(raw.get("demo_only", false))
	}, true)
	return normalized

static func is_valid_registry_entry(raw: Dictionary) -> bool:
	var entry := normalize(raw)
	for field in ["id", "name", "description", "author", "version", "type", "target", "plyra_compatibility", "license"]:
		if str(entry[field]).strip_edges().is_empty():
			return false
	if not _matches_pattern(entry["id"], ID_PATTERN):
		return false
	if not _is_https_url(entry["source_url"]) or not _is_https_url(entry["download_url"]):
		return false
	return _matches_pattern(entry["sha256"], HASH_PATTERN)

static func _is_https_url(value: String) -> bool:
	var url := value.strip_edges()
	return url.begins_with("https://") and not url.contains("@") and url.length() <= 2048

static func _matches_pattern(value: String, pattern: String) -> bool:
	var regex := RegEx.new()
	if regex.compile(pattern) != OK:
		return false
	var result := regex.search(value)
	return result != null and result.get_string() == value
