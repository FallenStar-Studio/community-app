extends SceneTree

const DemoService = preload("res://scripts/services/demo_community_service.gd")
const GitHubCommunityServiceImpl = preload("res://scripts/services/github_community_service.gd")
const GitHubAuthProviderImpl = preload("res://scripts/services/github_auth_provider.gd")
const GitHubDiscussionClientImpl = preload("res://scripts/services/github_discussion_client.gd")

var _passed := 0
var _failed := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var service = DemoService.new()
	var discussions := service.list_discussions()
	_check(discussions.size() >= 4, "demo discussion fixture count")
	_check(discussions.all(func(entry: Dictionary) -> bool: return entry.get("source") == "demo" and bool(entry.get("is_demo", false))), "demo discussions carry visible provenance")
	_check(service.list_categories().size() >= 4, "demo discussion categories are available")
	_check(service.get_discussion("demo-announcement-001").has("comments"), "discussion detail and comments")
	_check(service.list_discussions("开发日志", "").size() == 1, "discussion category filter")
	_check(service.list_discussions("全部", "输入区").size() == 1, "case-insensitive body search")
	_check(service.get_discussion("does-not-exist").is_empty(), "unknown discussion is empty")
	var mods := service.list_mods()
	_check(mods.size() == 3, "demo MOD fixture count")
	_check(service.list_mods("桌面主题", "").size() == 1, "MOD category filter")
	_check(service.list_mods("全部", "下载地址").size() == 1, "MOD description search")
	_check(mods.all(func(entry: Dictionary) -> bool: return bool(entry["demo_only"])), "all registry cards are explicitly demo data")
	_check(mods.all(func(entry: Dictionary) -> bool: return str(entry["download_url"]).is_empty() and str(entry["sha256"]).is_empty()), "demo MOD records have no fake download or digest")

	var real_entry := {
		"id": "valid-real-shape",
		"name": "Shape check",
		"description": "Used only in a local unit test.",
		"author": "Test",
		"version": "1.0.0",
		"type": "theme",
		"target": "Desktop",
		"plyraCompatibility": ">=0.1",
		"license": "MIT",
		"sourceUrl": "https://github.com/example/project",
		"downloadUrl": "https://github.com/example/project/releases/download/v1/file.zip",
		"sha256": "a".repeat(64)
	}
	_check(ModEntry.is_valid_registry_entry(real_entry), "MOD metadata validation accepts complete HTTPS entries")
	var credential_url := real_entry.duplicate(true)
	credential_url["sourceUrl"] = "https://user@example.com/file"
	_check(not ModEntry.is_valid_registry_entry(credential_url), "MOD URLs reject embedded credentials")
	var broken_hash := real_entry.duplicate(true)
	broken_hash["sha256"] = "not-a-hash"
	_check(not ModEntry.is_valid_registry_entry(broken_hash), "MOD metadata validation rejects bad SHA-256")

	_check(FileAccess.file_exists("res://assets/images/plyra-demo-banner.png"), "local image fixture exists")
	var texture := load("res://assets/images/plyra-demo-banner.png")
	_check(texture is Texture2D, "Godot loads the bundled PNG image")
	var repository_config: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://config/community_repository.json"))
	_check(repository_config is Dictionary and str(repository_config.get("mod_registry_url", "")).contains("FallenStar-Studio/mod-registry/main/mods.json"), "MOD registry uses its separate public repository")

	var github_service := GitHubCommunityServiceImpl.new()
	var empty_feed_result := github_service.accept_public_feed({"schemaVersion": 1, "categories": [], "posts": [], "discussionPageInfo": {"hasNextPage": false}})
	_check(bool(empty_feed_result.get("ok", false)), "empty GitHub feed is valid data")
	_check(github_service.uses_live_discussions() and github_service.list_discussions().is_empty(), "empty live feed does not fall back to mock discussions")
	_check(github_service.list_categories().is_empty(), "empty live category list does not fall back to mock categories")
	_check(not github_service.uses_live_mods() and github_service.list_mods().size() == 3, "unavailable MOD feed preserves demo MOD fallback")

	var graphql_categories := github_service.accept_graphql_categories({"repository": {"discussionCategories": {"nodes": [{"id": "cat-1", "name": "General", "slug": "general", "description": "Open discussion", "emoji": "💬"}]}}})
	_check(bool(graphql_categories.get("ok", false)) and github_service.list_categories().size() == 1, "GraphQL category payload normalizes")
	var graphql_posts := github_service.accept_graphql_discussions({"repository": {"discussions": {"totalCount": 1, "pageInfo": {"hasNextPage": false}, "nodes": [{
		"id": "D_1", "databaseId": 7, "number": 7, "title": "Real topic", "bodyText": "From GitHub", "updatedAt": "2026-09-25",
		"url": "https://github.com/FallenStar-Studio/community/discussions/7", "author": {"login": "maintainer"}, "category": {"id": "cat-1", "name": "General"},
		"comments": {"totalCount": 1}
	}]}}})
	_check(bool(graphql_posts.get("ok", false)) and github_service.uses_live_discussions(), "GraphQL discussion list normalizes")
	_check(github_service.list_discussions("General", "real").size() == 1, "GitHub discussion filters by API category and text")
	var detail := github_service.accept_graphql_detail({"repository": {"discussion": {
		"id": "D_1", "databaseId": 7, "number": 7, "title": "Real topic", "bodyText": "From GitHub", "updatedAt": "2026-09-25",
		"author": {"login": "maintainer"}, "category": {"name": "General"},
		"comments": {"totalCount": 1, "pageInfo": {"hasNextPage": false, "endCursor": null}, "nodes": [{"bodyText": "Real comment", "author": {"login": "reader"}, "createdAt": "2026-09-25"}]}
	}}})
	_check(bool(detail.get("ok", false)), "GitHub discussion detail normalizes")
	_check(github_service.get_discussion("D_1").get("comments", []).size() == 1, "GitHub comments are available in discussion detail")
	_check(github_service.get_discussion("D_1").get("source") == "github", "GitHub discussion is visibly marked as live")
	_check(not github_service.accept_public_feed({"schemaVersion": 99, "categories": [], "posts": []}).get("ok", true), "unsupported feed schema is rejected")
	_check(bool(github_service.accept_mod_registry([]).get("ok", false)) and github_service.uses_live_mods() and github_service.list_mods().is_empty(), "empty MOD registry does not fall back to demo entries")
	_check(not github_service.accept_mod_registry([{"id": "invalid"}]).get("ok", true), "malformed MOD registry entry is rejected")

	var auth_provider := GitHubAuthProviderImpl.new()
	root.add_child(auth_provider)
	_check(str(auth_provider.start_sign_in().get("code", "")) == "oauth_not_configured", "GitHub sign-in stays unavailable without OAuth Client ID")
	var github_client := GitHubDiscussionClientImpl.new()
	root.add_child(github_client)
	github_client.configure({"owner": "FallenStar-Studio", "repository": "community", "requests_enabled": false}, auth_provider)
	var last_client_result: Dictionary = {}
	github_client.request_completed.connect(func(operation: String, ok: bool, _payload: Dictionary, failure: Dictionary) -> void:
		last_client_result.clear()
		last_client_result["operation"] = operation
		last_client_result["ok"] = ok
		last_client_result["code"] = failure.get("code", "")
	)
	github_client.fetch_public_feed()
	_check(last_client_result.get("code", "") == "repository_pending", "GitHub requests are gated until repository bootstrap")

	print("Test result: %d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)

func _check(condition: bool, description: String) -> void:
	if condition:
		_passed += 1
		print("PASS: %s" % description)
	else:
		_failed += 1
		push_error("FAIL: %s" % description)
