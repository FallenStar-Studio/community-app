class_name GitHubAuthProvider
extends Node

signal authorization_changed(is_authorized: bool)

## Public-client authorization seam. Device Flow is intentionally disabled until
## a GitHub OAuth App Client ID and a permission review are supplied.
var client_id := ""
var _access_token := ""

func configure(value: String) -> void:
	client_id = value.strip_edges()

func is_authorized() -> bool:
	return not _access_token.is_empty()

func access_token() -> String:
	return _access_token

func start_sign_in() -> Dictionary:
	if client_id.is_empty():
		return {"ok": false, "code": "oauth_not_configured"}
	return {"ok": false, "code": "device_flow_not_implemented"}

func sign_out() -> void:
	_access_token = ""
	authorization_changed.emit(false)
