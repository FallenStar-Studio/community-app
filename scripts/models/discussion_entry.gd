class_name DiscussionEntry
extends RefCounted

static func normalize(raw: Dictionary) -> Dictionary:
	var normalized := raw.duplicate(true)
	normalized.merge({
		"id": str(raw.get("id", "")),
		"title": str(raw.get("title", "")),
		"category": str(raw.get("category", "General")),
		"kind": str(raw.get("kind", "discussion")),
		"author": str(raw.get("author", "Community member")),
		"updated_at": str(raw.get("updated_at", "")),
		"body": str(raw.get("body", "")),
		"image": str(raw.get("image", "")),
		"comment_count": int(raw.get("comment_count", 0)),
		"comments": raw.get("comments", []),
		"source": str(raw.get("source", "demo")),
		"is_demo": bool(raw.get("is_demo", raw.get("source", "demo") == "demo"))
	}, true)
	return normalized

static func is_valid(raw: Dictionary) -> bool:
	for field in ["id", "title", "category", "author", "body"]:
		if not raw.has(field) or str(raw[field]).strip_edges().is_empty():
			return false
	return str(raw["id"]).length() <= 200 and str(raw["title"]).length() <= 300
