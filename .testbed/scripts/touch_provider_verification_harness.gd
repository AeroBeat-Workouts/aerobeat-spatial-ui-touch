extends Control

const HARNESS_SCRIPT := preload("res://tests/support/touch_provider_test_harness.gd")

@onready var status_label: RichTextLabel = get_node_or_null("Margin/Content/Status") as RichTextLabel

var _harness = HARNESS_SCRIPT.new()
var _runtime: Dictionary = {}
var _last_event = null

func _ready() -> void:
	await _boot_runtime()
	_refresh_status()

func _boot_runtime() -> void:
	_runtime = await _harness.attach_runtime(self)
	var bus = _runtime.get("bus")
	if bus != null and not bus.interaction_event.is_connected(_on_interaction_event):
		bus.interaction_event.connect(_on_interaction_event)

func describe_hud_snapshot() -> Dictionary:
	var provider = _runtime.get("provider", null)
	return _harness.describe_harness_snapshot(provider, _last_event)

func publish_touch_press(surface_uv: Vector2, screen_position: Vector2, pressed: bool, index := 0, canceled := false) -> bool:
	var event := _harness.make_touch_press(index, screen_position, pressed, canceled)
	var projected_hit: Dictionary = _harness.build_hit(_runtime.get("surface"), surface_uv, screen_position) if pressed else _harness.build_off_surface_hit(screen_position)
	return _publish_event(event, projected_hit)

func publish_touch_drag(surface_uv: Vector2, screen_position: Vector2, relative: Vector2, index := 0) -> bool:
	return _publish_event(
		_harness.make_touch_drag(index, screen_position, relative),
		_harness.build_hit(_runtime.get("surface"), surface_uv, screen_position)
	)

func publish_touch_cancel(screen_position: Vector2, index := 0) -> bool:
	return _publish_event(
		_harness.make_touch_press(index, screen_position, false, true),
		_harness.build_off_surface_hit(screen_position)
	)

func _publish_event(event: InputEvent, projected_hit: Dictionary) -> bool:
	var provider = _runtime.get("provider", null)
	var adapter = _runtime.get("adapter", null)
	var surface = _runtime.get("surface", null)
	if provider == null or adapter == null or surface == null:
		return false
	var published: bool = provider.publish_input_event(adapter, surface, event, projected_hit, {
		"host_surface": "PanelInputSurface",
		"target_resolution": "rect_target_specs",
	})
	_refresh_status()
	return published

func _on_interaction_event(event) -> void:
	_last_event = event
	_refresh_status()

func _refresh_status() -> void:
	if status_label == null:
		return
	var snapshot := describe_hud_snapshot()
	var lines := [
		"[b]Touch provider verification harness[/b]",
		"[color=#cbd5e1]provider lane:[/color] %s" % snapshot.get("provider_lane", "touch"),
		"[color=#cbd5e1]packaged provider active:[/color] %s" % str(snapshot.get("packaged_provider_active", false)),
		"[color=#cbd5e1]packaged provider seam:[/color] %s" % snapshot.get("provider_runtime_seam", "missing"),
		"[color=#cbd5e1]runtime source:[/color] %s" % snapshot.get("provider_runtime_source", "missing"),
		"[color=#cbd5e1]source variant:[/color] %s" % snapshot.get("source_variant", "waiting"),
		"[color=#cbd5e1]phase:[/color] %s" % snapshot.get("phase", "waiting"),
		"[color=#cbd5e1]target path:[/color] %s" % _path_label(snapshot.get("target_path", "")),
		"[color=#cbd5e1]verification status:[/color] %s" % snapshot.get("verification_status", "waiting"),
		"[color=#cbd5e1]verification notes:[/color] %s" % snapshot.get("verification_notes", "No normalized interaction published yet."),
		"",
		"[b]touch runtime snapshot[/b]",
		"active_pointer_id = %s" % snapshot.get("active_pointer_id", "none"),
		"is_touch_active = %s" % str(snapshot.get("is_touch_active", false)),
		"state_phase = %s" % snapshot.get("state_phase", ""),
		"owner_target_path = %s" % _path_label(snapshot.get("owner_target_path", "")),
		"live_target_path = %s" % _path_label(snapshot.get("live_target_path", "")),
		"preferred_target_path = %s" % _path_label(snapshot.get("preferred_target_path", "")),
		"last_release_target_path = %s" % _path_label(snapshot.get("last_release_target_path", "")),
		"last_forwarded_panel_event = %s" % snapshot.get("last_forwarded_panel_event", "waiting for projected touch input"),
		"last_projected_hit = %s" % snapshot.get("last_projected_hit_summary", "waiting for projected touch input"),
	]
	status_label.text = "\n".join(lines)

func _path_label(path: Variant) -> String:
	var path_text := str(path)
	if path_text == "":
		return "none"
	if path is NodePath and path == NodePath():
		return "none"
	return path_text
