@tool
extends RefCounted
class_name AeroSpatialUiTouchProvider

const PROJECTION_HELPER_SCRIPT := preload("res://addons/aerobeat-spatial-ui-core/src/helpers/providers/aero_spatial_projection_helper.gd")
const RECT_TARGET_RESOLVER_SCRIPT_PATH := "res://addons/aerobeat-spatial-ui-core/src/helpers/providers/aero_spatial_rect_target_resolver.gd"
const INTERACTION_TYPES := preload("res://addons/aerobeat-input-core/src/ui/ui_interaction_types.gd")

const PROVIDER_LANE := "touch"
const CONTRACT_OWNER_PACKAGE := "aerobeat-input-core"
const SHARED_HELPER_OWNER_PACKAGE := "aerobeat-spatial-ui-core"
const DEFAULT_POINTER_ID_PREFIX := "touch_"
const DEFAULT_DRAG_THRESHOLD_PIXELS := 12.0

var pointer_id_prefix := DEFAULT_POINTER_ID_PREFIX
var drag_threshold_pixels := DEFAULT_DRAG_THRESHOLD_PIXELS
var host_surface := ""
var target_resolution := "rect_target_specs"

var _projection_helper = PROJECTION_HELPER_SCRIPT.new()
var _target_resolver = null
var _active_touch_state: Dictionary = {}
var _last_projected_data: Dictionary = {}
var _last_live_target_path: NodePath = NodePath()
var _last_surface_hover_hit := false
var _last_release_target_path := ""
var _last_forwarded_panel_event := ""
var _last_published_phase := ""
var _last_pointer_id: StringName = StringName()
var _last_touch_index := -1

func _init(config = null) -> void:
	_target_resolver = _build_target_resolver()
	if config != null:
		apply_config(config)
	else:
		var config_script = load(_config_script_path())
		if config_script != null:
			apply_config(config_script.new())

func apply_config(config) -> void:
	if config == null:
		return
	pointer_id_prefix = str(config.get("pointer_id_prefix", pointer_id_prefix)) if config is Dictionary else str(config.pointer_id_prefix)
	drag_threshold_pixels = float(config.get("drag_threshold_pixels", drag_threshold_pixels)) if config is Dictionary else float(config.drag_threshold_pixels)
	host_surface = str(config.get("host_surface", host_surface)) if config is Dictionary else str(config.host_surface)
	target_resolution = str(config.get("target_resolution", target_resolution)) if config is Dictionary else str(config.target_resolution)

func describe_boundary() -> Dictionary:
	return {
		"provider_lane": PROVIDER_LANE,
		"contract_owner_package": CONTRACT_OWNER_PACKAGE,
		"shared_helper_owner_package": SHARED_HELPER_OWNER_PACKAGE,
		"implements_runtime_behavior": true,
		"extracts_touch_provider_runtime": true,
		"extracts_hybrid_proof_logic": true,
		"owns_touch_provider_runtime": true,
		"owns_world_hit_acquisition": false,
		"owns_native_2d_bridge": false,
		"owns_contract_definition": false,
		"owns_shared_helper_layer": false,
		"expected_source_variant": "screen_touch",
		"expected_surface_type": "hybrid_3d_gui",
		"expected_verification_status": "unverified",
	}

func describe_runtime_state() -> Dictionary:
	var owner_summary := _describe_active_owner_state()
	return {
		"pointer_id_prefix": pointer_id_prefix,
		"drag_threshold_pixels": drag_threshold_pixels,
		"active_pointer_count": _active_touch_state.size(),
		"active_pointer_ids": PackedStringArray(_active_touch_state.keys()),
		"active_touch_state": _active_touch_state.duplicate(true),
		"active_pointer_id": owner_summary.get("pointer_id", ""),
		"active_owner_target_path": owner_summary.get("owner_target_path", NodePath()),
		"active_live_target_path": owner_summary.get("live_target_path", NodePath()),
		"active_drag_started": owner_summary.get("drag_started", false),
		"has_active_owner": owner_summary.get("has_active_owner", false),
		"has_active_live_target": owner_summary.get("has_active_live_target", false),
		"last_pointer_id": _last_pointer_id,
		"last_touch_index": _last_touch_index,
		"last_published_phase": _last_published_phase,
		"last_live_target_path": _last_live_target_path,
		"last_surface_hover_hit": _last_surface_hover_hit,
		"last_release_target_path": _last_release_target_path,
		"last_forwarded_panel_event": _last_forwarded_panel_event,
		"last_projected_data": _last_projected_data.duplicate(true),
	}

func describe_interaction_summary() -> Dictionary:
	var owner_summary := _describe_active_owner_state()
	var owner_target_path: NodePath = owner_summary.get("owner_target_path", NodePath())
	var live_target_path: NodePath = owner_summary.get("live_target_path", NodePath())
	var preferred_target_path: NodePath = owner_target_path if owner_target_path != NodePath() else live_target_path
	var has_active_pointer := not _active_touch_state.is_empty()
	var active_phase: String = _last_published_phase if has_active_pointer else ""
	return {
		"is_touch_active": has_active_pointer,
		"active_pointer_count": _active_touch_state.size(),
		"active_pointer_id": owner_summary.get("pointer_id", ""),
		"preferred_target_path": preferred_target_path,
		"preferred_target_label": _path_label(preferred_target_path),
		"owner_target_path": owner_target_path,
		"owner_target_label": _path_label(owner_target_path),
		"live_target_path": live_target_path,
		"live_target_label": _path_label(live_target_path),
		"state_phase": active_phase,
		"has_active_owner": owner_summary.get("has_active_owner", false),
		"has_active_live_target": owner_summary.get("has_active_live_target", false),
		"last_release_target_path": _last_release_target_path,
		"last_forwarded_panel_event": _last_forwarded_panel_event,
	}

func reset_runtime_state() -> void:
	_active_touch_state = {}
	_last_projected_data = {}
	_last_live_target_path = NodePath()
	_last_surface_hover_hit = false
	_last_release_target_path = ""
	_last_forwarded_panel_event = ""
	_last_published_phase = ""
	_last_pointer_id = StringName()
	_last_touch_index = -1

func resolve_target_for_hit(surface, projected_hit: Dictionary) -> Dictionary:
	return _resolve_target_for_hit(surface, projected_hit)

func resolve_target_path_for_hit(surface, projected_hit: Dictionary) -> NodePath:
	var resolution_result := resolve_target_for_hit(surface, projected_hit)
	return resolution_result.get("target_path", NodePath())

func build_projected_data_for_hit(
	surface,
	projected_hit: Dictionary,
	context: Dictionary = {},
	previous_projected: Dictionary = {},
	owner_target_path: NodePath = NodePath(),
	live_target_path: NodePath = NodePath()
) -> Dictionary:
	var has_hit: bool = bool(projected_hit.get("hit", false))
	var resolution_result: Dictionary = resolve_target_for_hit(surface, projected_hit) if has_hit else {"target_path": NodePath(), "raw_metadata": {}}
	var resolved_live_target_path: NodePath = live_target_path if live_target_path != NodePath() else resolution_result.get("target_path", NodePath())
	return _build_projected_data(
		surface,
		projected_hit,
		previous_projected,
		owner_target_path,
		resolved_live_target_path,
		resolution_result.get("raw_metadata", {}).duplicate(true),
		context
	)

func publish_input_event(
	adapter,
	surface,
	event: InputEvent,
	projected_hit: Dictionary,
	context: Dictionary = {}
) -> bool:
	if adapter == null or surface == null or event == null or not surface.is_configured():
		return false

	if event is InputEventScreenTouch:
		return _publish_screen_touch_event(adapter, surface, event, projected_hit, context)
	if event is InputEventScreenDrag:
		return _publish_screen_drag_event(adapter, surface, event, projected_hit, context)
	return false

func _publish_screen_touch_event(
	adapter,
	surface,
	event: InputEventScreenTouch,
	projected_hit: Dictionary,
	context: Dictionary
) -> bool:
	var pointer_id := _resolve_pointer_id(event.index, context)
	var previous_state: Dictionary = _active_touch_state.get(pointer_id, {})
	var previous_projected: Dictionary = previous_state.get("projected_data", {})
	var previous_owner: NodePath = previous_state.get("owner_target_path", NodePath())
	_last_pointer_id = pointer_id
	_last_touch_index = event.index

	if event.canceled:
		if previous_projected.is_empty():
			return false
		_publish_projected_phase(adapter, INTERACTION_TYPES.PHASE_CANCEL, pointer_id, previous_projected, {
			"source_type": INTERACTION_TYPES.SOURCE_TYPE_TOUCH,
			"source_variant": INTERACTION_TYPES.SOURCE_VARIANT_SCREEN_TOUCH,
			"button": INTERACTION_TYPES.BUTTON_CONTACT,
			"primary": event.index == 0,
			"pressed": false,
			"raw_event_class": &"InputEventScreenTouch",
			"raw_metadata": {"index": event.index, "canceled": true}
		})
		_active_touch_state.erase(pointer_id)
		_last_projected_data = previous_projected.duplicate(true)
		_last_published_phase = str(INTERACTION_TYPES.PHASE_CANCEL)
		_last_forwarded_panel_event = "publish touch cancel #%d" % event.index
		return true

	var has_hit: bool = bool(projected_hit.get("hit", false))
	var target_resolution_result: Dictionary = _resolve_target_for_hit(surface, projected_hit)
	var live_target_path: NodePath = target_resolution_result.get("target_path", NodePath()) if has_hit else NodePath()
	var resolution_metadata: Dictionary = target_resolution_result.get("raw_metadata", {}).duplicate(true) if has_hit else {}
	_last_surface_hover_hit = has_hit
	_last_live_target_path = live_target_path

	if event.pressed and (not has_hit or live_target_path == NodePath()):
		return false
	if not event.pressed and not has_hit and previous_projected.is_empty():
		return false

	var owner_target_path := previous_owner
	if event.pressed:
		owner_target_path = live_target_path
	var projected_data := _build_projected_data(
		surface,
		projected_hit,
		previous_projected,
		owner_target_path,
		live_target_path,
		resolution_metadata,
		context
	)
	adapter.publish_from_input_event(event, projected_data, {"pointer_id": pointer_id})
	_last_projected_data = projected_data.duplicate(true)
	_last_published_phase = str(INTERACTION_TYPES.PHASE_PRESS_BEGIN if event.pressed else INTERACTION_TYPES.PHASE_PRESS_END)

	if event.pressed:
		_active_touch_state[pointer_id] = {
			"projected_data": projected_data.duplicate(true),
			"owner_target_path": owner_target_path,
			"live_target_path": live_target_path,
			"press_surface_position": projected_data.get("surface_position", Vector2.ZERO),
			"drag_started": false,
		}
	else:
		_last_release_target_path = str(projected_data.get("target_path", NodePath()))
		_active_touch_state.erase(pointer_id)

	_last_forwarded_panel_event = "publish touch %s #%d -> %.0f, %.0f • %s" % [
		"press" if event.pressed else "release",
		event.index,
		Vector2(projected_data.get("surface_position", Vector2.ZERO)).x,
		Vector2(projected_data.get("surface_position", Vector2.ZERO)).y,
		_path_label(projected_data.get("target_path", NodePath()))
	]
	return true

func _publish_screen_drag_event(
	adapter,
	surface,
	event: InputEventScreenDrag,
	projected_hit: Dictionary,
	context: Dictionary
) -> bool:
	var pointer_id := _resolve_pointer_id(event.index, context)
	var previous_state: Dictionary = _active_touch_state.get(pointer_id, {})
	if previous_state.is_empty():
		return false

	var previous_projected: Dictionary = previous_state.get("projected_data", {})
	var owner_target_path: NodePath = previous_state.get("owner_target_path", NodePath())
	var press_surface_position: Vector2 = previous_state.get("press_surface_position", Vector2.ZERO)
	var drag_started := bool(previous_state.get("drag_started", false))
	var has_hit: bool = bool(projected_hit.get("hit", false))
	var target_resolution_result: Dictionary = _resolve_target_for_hit(surface, projected_hit)
	var live_target_path: NodePath = target_resolution_result.get("target_path", NodePath()) if has_hit else NodePath()
	var resolution_metadata: Dictionary = target_resolution_result.get("raw_metadata", {}).duplicate(true) if has_hit else {}
	_last_pointer_id = pointer_id
	_last_touch_index = event.index
	_last_surface_hover_hit = has_hit
	_last_live_target_path = live_target_path

	var projected_data := _build_projected_data(
		surface,
		projected_hit,
		previous_projected,
		owner_target_path,
		live_target_path,
		resolution_metadata,
		context
	)
	adapter.publish_from_input_event(event, projected_data, {"pointer_id": pointer_id})
	var drag_phase: StringName = INTERACTION_TYPES.PHASE_PRESS_HOLD
	var drag_distance := Vector2(projected_data.get("surface_position", Vector2.ZERO)).distance_to(press_surface_position)
	if drag_started:
		drag_phase = INTERACTION_TYPES.PHASE_DRAG_MOVE
	elif drag_distance >= drag_threshold_pixels:
		drag_started = true
		drag_phase = INTERACTION_TYPES.PHASE_DRAG_BEGIN
	_active_touch_state[pointer_id] = {
		"projected_data": projected_data.duplicate(true),
		"owner_target_path": owner_target_path,
		"live_target_path": live_target_path,
		"press_surface_position": press_surface_position,
		"drag_started": drag_started,
	}
	_last_projected_data = projected_data.duplicate(true)
	_last_published_phase = str(drag_phase)
	_last_forwarded_panel_event = "publish touch drag #%d -> %.0f, %.0f • owner %s • hover %s" % [
		event.index,
		Vector2(projected_data.get("surface_position", Vector2.ZERO)).x,
		Vector2(projected_data.get("surface_position", Vector2.ZERO)).y,
		_path_label(owner_target_path),
		_path_label(live_target_path)
	]
	return true

func _publish_projected_phase(
	adapter,
	phase: StringName,
	pointer_id: StringName,
	projected_data: Dictionary,
	overrides: Dictionary
) -> void:
	adapter.publish_projected_phase(phase, pointer_id, projected_data, overrides)

func _describe_active_owner_state() -> Dictionary:
	if _active_touch_state.is_empty():
		return {
			"pointer_id": "",
			"owner_target_path": NodePath(),
			"live_target_path": NodePath(),
			"drag_started": false,
			"has_active_owner": false,
			"has_active_live_target": false,
		}
	var pointer_id = _active_touch_state.keys()[0]
	var pointer_state: Dictionary = _active_touch_state.get(pointer_id, {})
	var owner_target_path: NodePath = pointer_state.get("owner_target_path", NodePath())
	var live_target_path: NodePath = pointer_state.get("live_target_path", NodePath())
	return {
		"pointer_id": str(pointer_id),
		"owner_target_path": owner_target_path,
		"live_target_path": live_target_path,
		"drag_started": bool(pointer_state.get("drag_started", false)),
		"has_active_owner": owner_target_path != NodePath(),
		"has_active_live_target": live_target_path != NodePath(),
	}

func _build_target_resolver():
	var resolver_script = load(RECT_TARGET_RESOLVER_SCRIPT_PATH)
	if resolver_script == null:
		push_error("AeroSpatialUiTouchProvider could not load packaged rect-target resolver: %s" % RECT_TARGET_RESOLVER_SCRIPT_PATH)
		return null
	return resolver_script.new()

func _resolve_target_for_hit(surface, projected_hit: Dictionary) -> Dictionary:
	if _target_resolver == null:
		return {"target_path": NodePath(), "raw_metadata": {"resolution_mode": "rect_target_specs"}}
	var resolution_result = _target_resolver.resolve_target(surface, projected_hit)
	if resolution_result == null:
		return {"target_path": NodePath(), "raw_metadata": {"resolution_mode": "rect_target_specs"}}
	return {
		"target_path": resolution_result.target_path,
		"raw_metadata": resolution_result.raw_metadata.duplicate(true),
	}

func _build_projected_data(
	surface,
	projected_hit: Dictionary,
	previous_projected: Dictionary,
	owner_target_path: NodePath,
	live_target_path: NodePath,
	resolution_metadata: Dictionary,
	context: Dictionary
) -> Dictionary:
	var published_target_path: NodePath = owner_target_path if owner_target_path != NodePath() else live_target_path
	var extra_raw_metadata := resolution_metadata.duplicate(true)
	extra_raw_metadata["host_surface"] = _resolve_host_surface(surface, context)
	extra_raw_metadata["target_resolution"] = _resolve_target_resolution(surface, context)
	extra_raw_metadata["live_target_path"] = str(live_target_path)
	extra_raw_metadata["published_target_path"] = str(published_target_path)
	extra_raw_metadata["hover_target_path"] = str(live_target_path)
	extra_raw_metadata["owner_target_path"] = str(owner_target_path)
	extra_raw_metadata["pointer_id"] = str(_last_pointer_id)
	return _projection_helper.build_projected_data(
		surface,
		projected_hit,
		previous_projected if not previous_projected.is_empty() else _last_projected_data,
		published_target_path,
		live_target_path,
		extra_raw_metadata
	)

func _resolve_pointer_id(index: int, context: Dictionary) -> StringName:
	if context.has("pointer_id"):
		return StringName(context.get("pointer_id", ""))
	var prefix := str(context.get("pointer_id_prefix", pointer_id_prefix))
	return StringName("%s%d" % [prefix, index])

func _resolve_host_surface(surface, context: Dictionary) -> String:
	if context.has("host_surface"):
		return str(context.get("host_surface", ""))
	if host_surface != "":
		return host_surface
	return str(surface.metadata.get("host_surface", ""))

func _resolve_target_resolution(surface, context: Dictionary) -> String:
	if context.has("target_resolution"):
		return str(context.get("target_resolution", ""))
	if target_resolution != "":
		return target_resolution
	return str(surface.metadata.get("target_resolution", "rect_target_specs"))

func _config_script_path() -> String:
	var script_path := String(get_script().resource_path)
	return script_path.get_base_dir().path_join("aero_spatial_ui_touch_provider_config.gd")

func _path_label(path: Variant) -> String:
	if path is NodePath and path == NodePath():
		return "none"
	var path_text := str(path)
	if path_text == "":
		return "none"
	return path_text.get_file()
