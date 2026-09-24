extends Node

const CommunitySource = preload("res://scripts/services/github_community_service.gd")
const AuthProvider = preload("res://scripts/services/github_auth_provider.gd")
const DiscussionClient = preload("res://scripts/services/github_discussion_client.gd")

var community: CommunityService
var auth: GitHubAuthProvider
var github_client: GitHubDiscussionClient
var repository_config: Dictionary = {}

func _ready() -> void:
	community = CommunitySource.new()
	auth = AuthProvider.new()
	github_client = DiscussionClient.new()
	add_child(auth)
	add_child(github_client)
	repository_config = _load_repository_config()
	auth.configure(str(repository_config.get("oauth_client_id", "")))
	github_client.configure(repository_config, auth)
	github_client.request_completed.connect(_on_github_request_completed)
	if not bool(repository_config.get("repository_ready", false)):
		community.set_failure({"code": "repository_pending", "message": "Waiting for GitHub repository bootstrap."})
	if bool(repository_config.get("requests_enabled", false)):
		refresh_community()

func set_community_service(service: CommunityService) -> void:
	community = service

func service_status() -> String:
	return community.service_label() if community != null else "Service unavailable"

func repository_label() -> String:
	var repo := "%s/%s" % [repository_config.get("owner", ""), repository_config.get("repository", "")]
	return "%s · %s" % [repo, "ready" if bool(repository_config.get("repository_ready", false)) else "pending setup"]

func refresh_community() -> void:
	if github_client == null:
		return
	github_client.fetch_mod_registry()
	if auth != null and auth.is_authorized():
		github_client.fetch_categories()
		github_client.fetch_discussions()
	else:
		github_client.fetch_public_feed()

func fetch_discussion_detail(record: Dictionary) -> void:
	if github_client == null or auth == null or not auth.is_authorized():
		return
	var number := int(record.get("number", 0))
	if number > 0:
		github_client.fetch_discussion_detail(number)

func _load_repository_config() -> Dictionary:
	const path := "res://config/community_repository.json"
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}

func _on_github_request_completed(operation: String, ok: bool, payload: Dictionary, failure: Dictionary) -> void:
	if not ok:
		community.set_failure(failure)
		return
	match operation:
		"guest_feed":
			var result: Dictionary = community.accept_public_feed(payload)
			if not bool(result.get("ok", false)):
				community.set_failure(result)
		"mod_registry":
			var result: Dictionary = community.accept_mod_registry(payload.get("entries", []))
			if not bool(result.get("ok", false)):
				community.set_failure(result)
		"categories":
			var result: Dictionary = community.accept_graphql_categories(payload)
			if not bool(result.get("ok", false)):
				community.set_failure(result)
			else:
				github_client.fetch_discussions()
		"discussions":
			var result: Dictionary = community.accept_graphql_discussions(payload)
			if not bool(result.get("ok", false)):
				community.set_failure(result)
		"discussion_detail":
			var result: Dictionary = community.accept_graphql_detail(payload)
			if not bool(result.get("ok", false)):
				community.set_failure(result)
