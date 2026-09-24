class_name GitHubDiscussionClient
extends Node

signal request_completed(operation: String, ok: bool, payload: Dictionary, failure: Dictionary)

const GRAPHQL_URL := "https://api.github.com/graphql"

var owner_login := ""
var repository := ""
var guest_feed_url := ""
var mod_registry_url := ""
var requests_enabled := false
var repository_ready := false
var auth_provider: GitHubAuthProvider

const CATEGORY_QUERY := """
query PlyraCategories($owner: String!, $name: String!) {
  repository(owner: $owner, name: $name) {
    id
    nameWithOwner
    discussionCategories(first: 25) {
      nodes { id name slug description emoji isAnswerable }
    }
  }
  rateLimit { remaining resetAt }
}
"""

const DISCUSSIONS_QUERY := """
query PlyraDiscussions($owner: String!, $name: String!, $categoryId: ID, $after: String) {
  repository(owner: $owner, name: $name) {
    id
    nameWithOwner
    discussions(first: 30, after: $after, categoryId: $categoryId,
      orderBy: {field: UPDATED_AT, direction: DESC}) {
      totalCount
      pageInfo { hasNextPage endCursor }
      nodes {
        id
        databaseId
        number
        title
        bodyText
        url
        createdAt
        updatedAt
        author { login }
        category { id name slug }
        comments(first: 0) { totalCount }
      }
    }
  }
  rateLimit { remaining resetAt }
}
"""

const DISCUSSION_DETAIL_QUERY := """
query PlyraDiscussion($owner: String!, $name: String!, $number: Int!, $after: String) {
  repository(owner: $owner, name: $name) {
    discussion(number: $number) {
      id
      databaseId
      number
      title
      bodyText
      url
      createdAt
      updatedAt
      author { login }
      category { id name slug }
      comments(first: 100, after: $after) {
        totalCount
        pageInfo { hasNextPage endCursor }
        nodes {
          id
          bodyText
          createdAt
          author { login }
          replies(first: 50) {
            nodes { id bodyText createdAt author { login } }
            pageInfo { hasNextPage endCursor }
          }
        }
      }
    }
  }
  rateLimit { remaining resetAt }
}
"""

func configure(config: Dictionary, provider: GitHubAuthProvider) -> void:
	owner_login = str(config.get("owner", "")).strip_edges()
	repository = str(config.get("repository", "")).strip_edges()
	guest_feed_url = str(config.get("guest_feed_url", "")).strip_edges()
	mod_registry_url = str(config.get("mod_registry_url", "")).strip_edges()
	requests_enabled = bool(config.get("requests_enabled", false))
	repository_ready = bool(config.get("repository_ready", false))
	auth_provider = provider

func fetch_public_feed() -> void:
	if not _configured():
		_emit_failure("guest_feed", "repository_not_configured", "Community repository has not been initialized yet.")
		return
	if not requests_enabled:
		_emit_failure("guest_feed", "repository_pending", "Guest feed requests are paused until community repository setup is approved.")
		return
	if not repository_ready:
		_emit_failure("guest_feed", "repository_pending", "Community repository setup is not complete.")
		return
	if guest_feed_url.is_empty():
		_emit_failure("guest_feed", "feed_not_configured", "Public guest feed URL is not configured.")
		return
	if not guest_feed_url.begins_with("https://"):
		_emit_failure("guest_feed", "invalid_feed_url", "Guest feed must use HTTPS.")
		return
	_get_json("guest_feed", guest_feed_url)

func fetch_mod_registry() -> void:
	if not _configured() or not requests_enabled or not repository_ready:
		_emit_failure("mod_registry", "repository_pending", "MOD registry requests are paused until repository setup is complete.")
		return
	if mod_registry_url.is_empty() or not mod_registry_url.begins_with("https://"):
		_emit_failure("mod_registry", "feed_not_configured", "MOD registry URL is missing or is not HTTPS.")
		return
	_get_json("mod_registry", mod_registry_url)

func _get_json(operation: String, url: String) -> void:
	var request := HTTPRequest.new()
	request.timeout = 20.0
	add_child(request)
	request.request_completed.connect(_on_json_get_completed.bind(operation, request))
	var err := request.request(url, PackedStringArray(["Accept: application/json", "User-Agent: PlyraCommunity/0.1"]))
	if err != OK:
		request.queue_free()
		_emit_failure(operation, "network_error", "Could not start the public content request (%s)." % error_string(err))

func fetch_categories() -> void:
	_graphql("categories", CATEGORY_QUERY, {"owner": owner_login, "name": repository})

func fetch_discussions(category_id: String = "", after: String = "") -> void:
	_graphql("discussions", DISCUSSIONS_QUERY, {
		"owner": owner_login,
		"name": repository,
		"categoryId": category_id if not category_id.is_empty() else null,
		"after": after if not after.is_empty() else null
	})

func fetch_discussion_detail(number: int, after: String = "") -> void:
	if number < 1:
		_emit_failure("discussion_detail", "invalid_discussion_number", "Discussion number must be positive.")
		return
	_graphql("discussion_detail", DISCUSSION_DETAIL_QUERY, {
		"owner": owner_login,
		"name": repository,
		"number": number,
		"after": after if not after.is_empty() else null
	})

func _graphql(operation: String, query: String, variables: Dictionary) -> void:
	if not _configured():
		_emit_failure(operation, "repository_not_configured", "Community repository has not been initialized yet.")
		return
	if not requests_enabled:
		_emit_failure(operation, "repository_pending", "GitHub requests are paused until community repository setup is approved.")
		return
	if not bool(_repository_config_ready()):
		_emit_failure(operation, "repository_pending", "Community repository setup is not complete.")
		return
	if auth_provider == null or not auth_provider.is_authorized():
		_emit_failure(operation, "auth_required", "GitHub GraphQL Discussions requires an authorized account.")
		return
	var request := HTTPRequest.new()
	request.timeout = 20.0
	add_child(request)
	request.request_completed.connect(_on_graphql_completed.bind(operation, request))
	var headers := PackedStringArray([
		"Accept: application/vnd.github+json",
		"Content-Type: application/json",
		"User-Agent: PlyraCommunity/0.1",
		"Authorization: Bearer %s" % auth_provider.access_token()
	])
	var body := JSON.stringify({"query": query, "variables": variables})
	var err := request.request(GRAPHQL_URL, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		request.queue_free()
		_emit_failure(operation, "network_error", "Could not start the GitHub request (%s)." % error_string(err))

func _on_json_get_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, operation: String, request: HTTPRequest) -> void:
	request.queue_free()
	if result != HTTPRequest.RESULT_SUCCESS:
		_emit_failure(operation, "network_error", "Public content request failed (%s)." % result)
		return
	if response_code == 403 or response_code == 429:
		_emit_failure(operation, "rate_limited", "GitHub temporarily limited access to public content.")
		return
	if response_code < 200 or response_code >= 300:
		_emit_failure(operation, "http_error", "Public content returned HTTP %d." % response_code)
		return
	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	if operation == "mod_registry":
		if not parsed is Array:
			_emit_failure(operation, "invalid_response", "MOD registry did not contain a JSON array.")
			return
		request_completed.emit(operation, true, {"entries": parsed}, {})
	else:
		if not parsed is Dictionary:
			_emit_failure(operation, "invalid_response", "Public feed did not contain a JSON object.")
			return
		request_completed.emit(operation, true, parsed, {})

func _on_graphql_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, operation: String, request: HTTPRequest) -> void:
	request.queue_free()
	if result != HTTPRequest.RESULT_SUCCESS:
		_emit_failure(operation, "network_error", "GitHub request failed (%s)." % result)
		return
	var response_text := body.get_string_from_utf8()
	var parsed: Variant = JSON.parse_string(response_text)
	if not parsed is Dictionary:
		_emit_failure(operation, "invalid_response", "GitHub returned an invalid JSON response.")
		return
	if response_code == 401:
		_emit_failure(operation, "not_authenticated", "GitHub authorization is missing or expired.")
		return
	if response_code == 403 or response_code == 429:
		var remaining := _header_value(headers, "x-ratelimit-remaining")
		var code := "rate_limited" if response_code == 429 or remaining == "0" else "permission_denied"
		_emit_failure(operation, code, "GitHub denied the request (HTTP %d)." % response_code)
		return
	if response_code == 404:
		_emit_failure(operation, "repository_not_found", "The configured community repository or discussion was not found.")
		return
	if response_code < 200 or response_code >= 300:
		_emit_failure(operation, "http_error", "GitHub returned HTTP %d." % response_code)
		return
	var errors: Array = parsed.get("errors", [])
	if not errors.is_empty():
		var message := str(errors[0].get("message", "GitHub GraphQL request failed."))
		var lower := message.to_lower()
		if lower.contains("resource not accessible") or lower.contains("permission") or lower.contains("forbidden"):
			_emit_failure(operation, "permission_denied", message)
		else:
			_emit_failure(operation, "graphql_error", message)
		return
	var payload: Dictionary = parsed.get("data", {})
	if payload.is_empty():
		_emit_failure(operation, "empty_response", "GitHub returned no community data.")
		return
	request_completed.emit(operation, true, payload, {})

func _configured() -> bool:
	return not owner_login.is_empty() and not repository.is_empty()

func _repository_config_ready() -> bool:
	return repository_ready

func _header_value(headers: PackedStringArray, key: String) -> String:
	for line in headers:
		var parts := line.split(":", false, 1)
		if parts.size() == 2 and parts[0].strip_edges().to_lower() == key.to_lower():
			return parts[1].strip_edges()
	return ""

func _emit_failure(operation: String, code: String, message: String) -> void:
	request_completed.emit(operation, false, {}, {"code": code, "message": message})
