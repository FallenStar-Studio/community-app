class_name CommunityService
extends RefCounted

signal content_changed

## Stable model-facing interface. A GitHub/Pages adapter can replace the demo service without changing scenes.

func service_label() -> String:
	return "Community service"

func list_discussions(_category: String = "", _query: String = "") -> Array[Dictionary]:
	return []

func list_categories() -> Array[Dictionary]:
	return []

func get_discussion(_id: String) -> Dictionary:
	return {}

func list_mods(_type: String = "", _query: String = "") -> Array[Dictionary]:
	return []

func get_mod(_id: String) -> Dictionary:
	return {}

func refresh() -> Dictionary:
	return {"ok": false, "message": "Service is not configured."}

func uses_live_discussions() -> bool:
	return false

func uses_live_mods() -> bool:
	return false

func content_status() -> Dictionary:
	return {"source": "demo", "code": "offline_demo"}

func accept_public_feed(_payload: Dictionary) -> Dictionary:
	return {"ok": false, "code": "unsupported", "message": "This service does not accept public feeds."}

func accept_graphql_categories(_payload: Dictionary) -> Dictionary:
	return {"ok": false, "code": "unsupported", "message": "This service does not accept GitHub categories."}

func accept_graphql_discussions(_payload: Dictionary) -> Dictionary:
	return {"ok": false, "code": "unsupported", "message": "This service does not accept GitHub Discussions."}

func accept_graphql_detail(_payload: Dictionary) -> Dictionary:
	return {"ok": false, "code": "unsupported", "message": "This service does not accept GitHub discussion details."}

func set_failure(_failure: Dictionary) -> void:
	pass
