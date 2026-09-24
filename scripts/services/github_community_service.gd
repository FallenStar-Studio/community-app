class_name GitHubCommunityService
extends CommunityService

const DemoService = preload("res://scripts/services/demo_community_service.gd")
const LIMIT := 300

var _demo: CommunityService
var _discussions: Array[Dictionary] = []
var _categories: Array[Dictionary] = []
var _mods: Array[Dictionary] = []
var _live_discussions_loaded := false
var _live_feed_loaded := false
var _live_categories_loaded := false
var _live_mods_loaded := false
var _status := {"source": "demo", "code": "offline_demo", "message": "Showing bundled demo content."}
var _discussion_by_id: Dictionary = {}

func _init() -> void:
	_demo = DemoService.new()

func service_label() -> String:
	if _live_discussions_loaded:
		return "GitHub Discussions"
	if _live_feed_loaded:
		return "GitHub public feed"
	return "Local demo fallback"

func content_status() -> Dictionary:
	return _status.duplicate(true)

func uses_live_discussions() -> bool:
	return _live_feed_loaded or _live_discussions_loaded

func uses_live_mods() -> bool:
	return _live_mods_loaded

func list_categories() -> Array[Dictionary]:
	if not _live_categories_loaded:
		return _demo.list_categories()
	return _categories.duplicate(true)

func list_discussions(category: String = "", query: String = "") -> Array[Dictionary]:
	var source: Array[Dictionary] = _discussions if uses_live_discussions() else _demo.list_discussions()
	return _filter_discussions(source, category, query)

func get_discussion(id: String) -> Dictionary:
	if _discussion_by_id.has(id):
		return _discussion_by_id[id].duplicate(true)
	if uses_live_discussions():
		for record in _discussions:
			if str(record.get("id", "")) == id:
				return record.duplicate(true)
		return {}
	return _demo.get_discussion(id)

func list_mods(mod_type: String = "", query: String = "") -> Array[Dictionary]:
	var source: Array[Dictionary] = _mods if _live_mods_loaded else _demo.list_mods()
	return _filter_records(source, mod_type, query)

func get_mod(id: String) -> Dictionary:
	if _live_mods_loaded:
		for record in _mods:
			if str(record.get("id", "")) == id:
				return record.duplicate(true)
		return {}
	return _demo.get_mod(id)

func accept_public_feed(payload: Dictionary) -> Dictionary:
	if int(payload.get("schemaVersion", 0)) != 1:
		return _reject_feed("unsupported_schema", "Public feed schema version is not supported.")
	var posts: Variant = payload.get("posts", null)
	var categories: Variant = payload.get("categories", [])
	if not posts is Array or not categories is Array:
		return _reject_feed("invalid_feed", "Public feed is missing categories or posts.")
	if posts.size() > LIMIT or categories.size() > 25:
		return _reject_feed("feed_too_large", "Public feed exceeds the supported entry limit.")
	var normalized_posts: Array[Dictionary] = []
	var ids: Dictionary = {}
	for raw: Variant in posts:
		if not raw is Dictionary:
			continue
		var entry := _normalize_github_discussion(raw, "github_feed")
		if entry.is_empty() or ids.has(entry["id"]):
			continue
		ids[entry["id"]] = true
		normalized_posts.append(entry)
	var normalized_categories := _normalize_categories(categories)
	_live_feed_loaded = true
	_live_discussions_loaded = true
	_live_categories_loaded = true
	_discussions = normalized_posts
	_categories = normalized_categories
	_rebuild_discussion_index()
	_status = {"source": "github_feed", "code": "live_feed", "message": "Loaded the public GitHub feed."}
	content_changed.emit()
	return {"ok": true, "count": _discussions.size()}

func accept_mod_registry(raw_entries: Variant) -> Dictionary:
	if not raw_entries is Array:
		return _reject_feed("invalid_registry", "MOD registry must be a JSON array.")
	if raw_entries.size() > LIMIT:
		return _reject_feed("registry_too_large", "MOD registry exceeds the supported entry limit.")
	var normalized: Array[Dictionary] = []
	var seen: Dictionary = {}
	for raw_mod: Variant in raw_entries:
		if not raw_mod is Dictionary or not ModEntry.is_valid_registry_entry(raw_mod):
			return _reject_feed("invalid_registry_entry", "MOD registry contains an invalid record.")
		var entry := ModEntry.normalize(raw_mod)
		if seen.has(entry["id"]):
			return _reject_feed("duplicate_registry_id", "MOD registry contains a duplicate ID.")
		seen[entry["id"]] = true
		entry["source"] = "github_registry"
		entry["is_demo"] = false
		entry["demo_only"] = false
		normalized.append(entry)
	_mods = normalized
	_live_mods_loaded = true
	content_changed.emit()
	return {"ok": true, "count": _mods.size()}

func accept_graphql_categories(payload: Dictionary) -> Dictionary:
	var repo: Dictionary = payload.get("repository", {})
	if repo.is_empty():
		return _reject_feed("repository_not_found", "GitHub returned no community repository.")
	var connection: Dictionary = repo.get("discussionCategories", {})
	_categories = _normalize_categories(connection.get("nodes", []))
	_live_categories_loaded = true
	_status = {"source": "github", "code": "live_api", "message": "Loaded categories from GitHub Discussions."}
	content_changed.emit()
	return {"ok": true, "count": _categories.size()}

func accept_graphql_discussions(payload: Dictionary) -> Dictionary:
	var repo: Dictionary = payload.get("repository", {})
	if repo.is_empty():
		return _reject_feed("repository_not_found", "GitHub returned no community repository.")
	var connection: Dictionary = repo.get("discussions", {})
	var nodes: Variant = connection.get("nodes", [])
	if not nodes is Array:
		return _reject_feed("invalid_response", "GitHub discussion response has no list.")
	_discussions.clear()
	for raw: Variant in nodes:
		if raw is Dictionary:
			var entry := _normalize_github_discussion(raw, "github")
			if not entry.is_empty():
				_discussions.append(entry)
	_live_discussions_loaded = true
	_live_feed_loaded = false
	_rebuild_discussion_index()
	_status = {"source": "github", "code": "live_api", "message": "Loaded Discussions directly from GitHub."}
	content_changed.emit()
	return {"ok": true, "count": _discussions.size(), "page_info": connection.get("pageInfo", {})}

func accept_graphql_detail(payload: Dictionary) -> Dictionary:
	var repo: Dictionary = payload.get("repository", {})
	var raw: Variant = repo.get("discussion", null)
	if not raw is Dictionary:
		return {"ok": false, "code": "discussion_not_found", "message": "Discussion was not found."}
	var entry := _normalize_github_discussion(raw, "github")
	if entry.is_empty():
		return {"ok": false, "code": "invalid_response", "message": "GitHub returned an invalid discussion."}
	_discussion_by_id[entry["id"]] = entry
	var found := false
	for index in _discussions.size():
		if str(_discussions[index].get("id", "")) == str(entry["id"]):
			_discussions[index] = entry
			found = true
			break
	if not found:
		_discussions.append(entry)
	content_changed.emit()
	return {"ok": true, "discussion": entry.duplicate(true), "page_info": entry.get("comments_page_info", {})}

func set_failure(failure: Dictionary) -> void:
	var code := str(failure.get("code", "request_failed"))
	_status = {"source": "demo", "code": code, "message": str(failure.get("message", "GitHub request failed."))}
	content_changed.emit()

func refresh() -> Dictionary:
	return {"ok": false, "code": "manual_refresh_required", "message": "Use AppServices.refresh_community() to request the configured feed."}

func _normalize_github_discussion(raw: Dictionary, source: String) -> Dictionary:
	var category_data: Dictionary = raw.get("category", {}) if raw.get("category", {}) is Dictionary else {}
	var author_data: Dictionary = raw.get("author", {}) if raw.get("author", {}) is Dictionary else {}
	var raw_comments: Variant = raw.get("comments", [])
	var comments: Array = []
	var comment_count := int(raw.get("commentCount", raw.get("comment_count", 0)))
	var page_info: Dictionary = {}
	if raw_comments is Dictionary:
		comment_count = int(raw_comments.get("totalCount", comment_count))
		page_info = raw_comments.get("pageInfo", {})
		raw_comments = raw_comments.get("nodes", [])
	if raw_comments is Array:
		for comment: Variant in raw_comments:
			if comment is Dictionary:
				comments.append(_normalize_comment(comment, source))
	var category_name := str(category_data.get("name", raw.get("category", "General")))
	var number := int(raw.get("number", raw.get("databaseId", 0)))
	var record := {
		"id": str(raw.get("id", raw.get("node_id", "github-%d" % number))),
		"number": number,
		"title": str(raw.get("title", "")),
		"category": category_name,
		"category_en": category_name,
		"category_zh": _category_chinese_label(category_name),
		"kind": "discussion",
		"author": str(author_data.get("login", raw.get("author", "Community member"))),
		"author_en": str(author_data.get("login", raw.get("author", "Community member"))),
		"updated_at": str(raw.get("updatedAt", raw.get("updated_at", ""))),
		"body": str(raw.get("bodyText", raw.get("body", ""))),
		"body_en": str(raw.get("bodyText", raw.get("body", ""))),
		"url": str(raw.get("url", "")),
		"image": "",
		"comment_count": comment_count,
		"comments": comments,
		"comments_page_info": page_info,
		"source": source,
		"is_demo": false
	}
	if record["title"].is_empty() or record["id"].is_empty():
		return {}
	return DiscussionEntry.normalize(record)

func _normalize_comment(raw: Dictionary, source: String) -> Dictionary:
	var author_data: Dictionary = raw.get("author", {}) if raw.get("author", {}) is Dictionary else {}
	var replies_data: Dictionary = raw.get("replies", {}) if raw.get("replies", {}) is Dictionary else {}
	var replies: Array = []
	for reply: Variant in replies_data.get("nodes", []):
		if reply is Dictionary:
			var reply_author: Dictionary = reply.get("author", {}) if reply.get("author", {}) is Dictionary else {}
			var reply_body := str(reply.get("bodyText", reply.get("body", "")))
			replies.append({"author": str(reply_author.get("login", "Community member")), "author_en": str(reply_author.get("login", "Community member")), "body": reply_body, "body_en": reply_body, "source": source, "is_demo": false})
	var body := str(raw.get("bodyText", raw.get("body", "")))
	var author := str(author_data.get("login", raw.get("author", "Community member")))
	return {"author": author, "author_en": author, "body": body, "body_en": body, "created_at": str(raw.get("createdAt", "")), "replies": replies, "source": source, "is_demo": false}

func _normalize_categories(raw_categories: Array) -> Array[Dictionary]:
	var output: Array[Dictionary] = []
	var seen: Dictionary = {}
	for raw: Variant in raw_categories:
		if not raw is Dictionary:
			continue
		var name := str(raw.get("name", raw.get("value", "")))
		if name.is_empty() or seen.has(name):
			continue
		seen[name] = true
		output.append({"value": name, "id": str(raw.get("id", "")), "name": name, "name_en": name, "name_zh": _category_chinese_label(name), "description": str(raw.get("description", "")), "emoji": str(raw.get("emoji", ""))})
	return output

func _category_chinese_label(name: String) -> String:
	var labels := {
		"Announcements": "官方公告",
		"General": "综合交流",
		"Ideas & Feedback": "创意与反馈",
		"Development": "开发动态",
		"Help & Support": "帮助与支持"
	}
	return str(labels.get(name, name))

func _rebuild_discussion_index() -> void:
	_discussion_by_id.clear()
	for entry in _discussions:
		_discussion_by_id[str(entry.get("id", ""))] = entry.duplicate(true)
		if int(entry.get("number", 0)) > 0:
			_discussion_by_id[str(entry.get("number", 0))] = entry.duplicate(true)

func _filter_discussions(records: Array[Dictionary], category: String, query: String) -> Array[Dictionary]:
	var output: Array[Dictionary] = []
	var needle := query.strip_edges().to_lower()
	for record in records:
		if not category.is_empty() and str(record.get("category", "")) != category:
			continue
		var searchable := "%s %s %s %s" % [record.get("title", ""), record.get("body", ""), record.get("author", ""), record.get("category", "")]
		if not needle.is_empty() and not searchable.to_lower().contains(needle):
			continue
		output.append(record.duplicate(true))
	return output

func _filter_records(records: Array[Dictionary], category: String, query: String) -> Array[Dictionary]:
	var output: Array[Dictionary] = []
	var needle := query.strip_edges().to_lower()
	for record in records:
		var record_category := str(record.get("type", ""))
		if not category.is_empty() and category != "全部" and record_category != category:
			continue
		var searchable := "%s %s %s %s" % [record.get("name", ""), record.get("description", ""), record.get("author", ""), record_category]
		if not needle.is_empty() and not searchable.to_lower().contains(needle):
			continue
		output.append(record.duplicate(true))
	return output

func _reject_feed(code: String, message: String) -> Dictionary:
	return {"ok": false, "code": code, "message": message}
