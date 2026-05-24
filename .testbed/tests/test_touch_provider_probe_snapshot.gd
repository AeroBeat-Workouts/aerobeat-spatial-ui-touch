extends GutTest

const HARNESS_SCRIPT := preload("res://tests/support/touch_provider_test_harness.gd")
const MANIFEST_SCRIPT := preload("res://../src/providers/touch/aero_spatial_ui_touch_manifest.gd")

func test_probe_snapshot_exposes_provider_owned_manual_verification_truth() -> void:
	var harness = HARNESS_SCRIPT.new()
	var runtime = await harness.spawn(self)
	var provider = runtime["provider"]
	var adapter = runtime["adapter"]
	var surface = runtime["surface"]

	var press_hit := harness.build_hit(surface, Vector2(0.20, 0.20), Vector2(200.0, 200.0))
	assert_true(provider.publish_input_event(adapter, surface, harness.make_touch_press(0, Vector2(200.0, 200.0), true), press_hit))

	var drag_hit := harness.build_hit(surface, Vector2(0.70, 0.20), Vector2(700.0, 200.0))
	assert_true(provider.publish_input_event(adapter, surface, harness.make_touch_drag(0, Vector2(700.0, 200.0), Vector2(500.0, 0.0)), drag_hit))

	var probe: Dictionary = provider.describe_verification_probe()
	assert_true(bool(MANIFEST_SCRIPT.ownership_summary().get("supports_verification_probe_snapshot", false)))
	assert_eq(int(probe.get("active_pointer_count", -1)), 1)
	assert_eq(str(probe.get("active_pointer_id", "")), "touch_0")
	assert_true(bool(probe.get("is_touch_active", false)))
	assert_eq(str(probe.get("state_phase", "")), "drag_begin")
	assert_eq(str(probe.get("last_published_phase", "")), "drag_begin")
	assert_eq(str(probe.get("owner_target_path", NodePath())), "Root/PrimaryActionButton")
	assert_eq(str(probe.get("owner_target_label", "")), "PrimaryActionButton")
	assert_eq(str(probe.get("live_target_path", NodePath())), "Root/SecondaryActionButton")
	assert_eq(str(probe.get("live_target_label", "")), "SecondaryActionButton")
	assert_eq(str(probe.get("preferred_target_path", NodePath())), "Root/PrimaryActionButton")
	assert_eq(str(probe.get("preferred_target_label", "")), "PrimaryActionButton")
	assert_true(bool(probe.get("has_active_owner", false)))
	assert_true(bool(probe.get("has_active_live_target", false)))
	assert_eq(str(probe.get("source_variant", "")), "screen_touch")
	assert_eq(str(probe.get("surface_type", "")), "hybrid_3d_gui")
	assert_eq(str(probe.get("verification_status", "")), "unverified")
	assert_string_contains(str(probe.get("last_forwarded_panel_event", "")), "owner PrimaryActionButton")

	var projected_data: Dictionary = probe.get("last_projected_data", {})
	var raw_metadata: Dictionary = projected_data.get("raw_metadata", {})
	assert_eq(str(raw_metadata.get("owner_target_path", "")), "Root/PrimaryActionButton")
	assert_eq(str(raw_metadata.get("hover_target_path", "")), "Root/SecondaryActionButton")
	assert_eq(str(raw_metadata.get("published_target_path", "")), "Root/PrimaryActionButton")


func test_probe_snapshot_retains_release_feedback_without_promoting_verification_status() -> void:
	var harness = HARNESS_SCRIPT.new()
	var runtime = await harness.spawn(self)
	var provider = runtime["provider"]
	var adapter = runtime["adapter"]
	var surface = runtime["surface"]

	var press_hit := harness.build_hit(surface, Vector2(0.20, 0.20), Vector2(200.0, 200.0))
	assert_true(provider.publish_input_event(adapter, surface, harness.make_touch_press(0, Vector2(200.0, 200.0), true), press_hit))
	assert_true(provider.publish_input_event(adapter, surface, harness.make_touch_press(0, Vector2(900.0, 900.0), false), harness.build_off_surface_hit(Vector2(900.0, 900.0))))

	var probe: Dictionary = provider.describe_verification_probe()
	assert_false(bool(probe.get("is_touch_active", true)))
	assert_eq(int(probe.get("active_pointer_count", -1)), 0)
	assert_eq(str(probe.get("state_phase", "not-empty")), "")
	assert_eq(str(probe.get("last_published_phase", "")), "press_end")
	assert_eq(str(probe.get("last_release_target_path", "")), "Root/PrimaryActionButton")
	assert_eq(str(probe.get("verification_status", "")), "unverified")
	assert_string_contains(str(probe.get("last_forwarded_panel_event", "")), "publish touch release #0")
