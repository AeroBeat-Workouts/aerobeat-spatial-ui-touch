extends SceneTree

const INSTALLED_TOUCH_PACKAGE_ROOT := "res://addons/aerobeat-spatial-ui-touch"
const INSTALLED_TOUCH_PROVIDER_SCRIPT_PATH := INSTALLED_TOUCH_PACKAGE_ROOT + "/src/providers/touch/aero_spatial_ui_touch_provider.gd"
const INSTALLED_TOUCH_CONFIG_SCRIPT_PATH := INSTALLED_TOUCH_PACKAGE_ROOT + "/src/providers/touch/aero_spatial_ui_touch_provider_config.gd"
const INSTALLED_CORE_SURFACE_DESCRIPTOR_SCRIPT := preload("res://addons/aerobeat-spatial-ui-core/src/helpers/surfaces/aero_spatial_surface_descriptor.gd")
const INSTALLED_CORE_PROJECTION_HELPER_SCRIPT := preload("res://addons/aerobeat-spatial-ui-core/src/helpers/providers/aero_spatial_projection_helper.gd")

class AdapterRecorder:
	extends RefCounted

	var published_events: Array = []

	func publish_from_input_event(event: InputEvent, projected_data: Dictionary = {}, overrides: Dictionary = {}) -> bool:
		published_events.append({
			"event": event,
			"projected_data": projected_data.duplicate(true),
			"overrides": overrides.duplicate(true),
		})
		return true

func _init() -> void:
	var failures: Array[String] = []
	var required_paths := [
		INSTALLED_TOUCH_PROVIDER_SCRIPT_PATH,
		INSTALLED_TOUCH_CONFIG_SCRIPT_PATH,
	]

	for script_path in required_paths:
		if not ResourceLoader.exists(script_path):
			failures.append("missing installed addon script: %s" % script_path)
			continue
		var script = load(script_path)
		if script == null:
			failures.append("failed to load installed addon script: %s" % script_path)

	if failures.is_empty():
		var config = load(INSTALLED_TOUCH_CONFIG_SCRIPT_PATH).new()
		config.drag_threshold_pixels = 12.0
		config.host_surface = "PanelInputSurface"
		config.target_resolution = "rect_target_specs"
		var provider = load(INSTALLED_TOUCH_PROVIDER_SCRIPT_PATH).new(config)
		var adapter := AdapterRecorder.new()
		var projection_helper = INSTALLED_CORE_PROJECTION_HELPER_SCRIPT.new()
		var surface = INSTALLED_CORE_SURFACE_DESCRIPTOR_SCRIPT.new().configure({
			"surface_id": &"installed_touch_surface",
			"surface_path": NodePath("/root/PanelInputSurface"),
			"viewport_path": NodePath("/root/PanelViewport"),
			"surface_pixel_size": Vector2(1000.0, 1000.0),
			"authored_rect_normalized": Rect2(0.0, 0.0, 1.0, 1.0),
			"target_specs": [
				{
					"target_key": "primary",
					"target_name": "Primary Action Button",
					"target_path": NodePath("Root/PrimaryActionButton"),
					"rect": Rect2(100.0, 100.0, 200.0, 200.0),
				}
			],
			"metadata": {
				"host_surface": "PanelInputSurface",
				"target_resolution": "rect_target_specs",
				"surface_size": Vector2(2.93, 1.577),
			}
		})
		var hit = projection_helper.build_surface_hit(surface, Vector2(0.2, 0.2), {
			"screen_position": Vector2(320.0, 240.0),
			"world_position": Vector3(0.2, 0.2, 0.0),
			"world_normal": Vector3.UP,
			"world_direction": Vector3.FORWARD,
		})

		var press := InputEventScreenTouch.new()
		press.index = 0
		press.position = Vector2(320.0, 240.0)
		press.pressed = true

		if not provider.publish_input_event(adapter, surface, press, hit):
			failures.append("installed touch provider did not publish press")
		elif adapter.published_events.size() != 1:
			failures.append("installed touch provider published unexpected event count: %d" % adapter.published_events.size())
		else:
			var published: Dictionary = adapter.published_events[0]
			var projected: Dictionary = published.get("projected_data", {})
			if str(projected.get("target_path", NodePath())) != "Root/PrimaryActionButton":
				failures.append("installed touch provider returned unexpected target path: %s" % str(projected.get("target_path", NodePath())))
			var raw_metadata: Dictionary = projected.get("raw_metadata", {})
			if str(raw_metadata.get("published_target_path", "")) != "Root/PrimaryActionButton":
				failures.append("installed touch provider raw metadata reported unexpected published_target_path: %s" % str(raw_metadata.get("published_target_path", "")))
			if str(raw_metadata.get("host_surface", "")) != "PanelInputSurface":
				failures.append("installed touch provider raw metadata reported unexpected host_surface: %s" % str(raw_metadata.get("host_surface", "")))
			if str(raw_metadata.get("target_resolution", "")) != "rect_target_specs":
				failures.append("installed touch provider raw metadata reported unexpected target_resolution: %s" % str(raw_metadata.get("target_resolution", "")))
			var probe: Dictionary = provider.describe_verification_probe()
			if str(probe.get("source_variant", "")) != "screen_touch":
				failures.append("installed touch provider reported unexpected source_variant: %s" % str(probe.get("source_variant", "")))
			if str(probe.get("surface_type", "")) != "hybrid_3d_gui":
				failures.append("installed touch provider reported unexpected surface_type: %s" % str(probe.get("surface_type", "")))
			if str(probe.get("verification_status", "")) != "unverified":
				failures.append("installed touch provider reported unexpected verification_status: %s" % str(probe.get("verification_status", "")))
			if str(probe.get("preferred_target_path", NodePath())) != "Root/PrimaryActionButton":
				failures.append("installed touch provider reported unexpected preferred_target_path: %s" % str(probe.get("preferred_target_path", NodePath())))

	if failures.is_empty():
		print("Installed-addon package smoke passed for aerobeat-spatial-ui-touch")
		quit(0)
		return

	for failure in failures:
		push_error(failure)
	quit(1)
