extends GutTest

const HARNESS_SCRIPT := preload("res://tests/support/touch_provider_test_harness.gd")
const MANIFEST_SCRIPT := preload("res://../src/providers/touch/aero_spatial_ui_touch_manifest.gd")

func test_runtime_state_reports_owner_hover_and_manifest_truth() -> void:
	var harness = HARNESS_SCRIPT.new()
	var runtime = await harness.spawn(self)
	var provider = runtime["provider"]
	var adapter = runtime["adapter"]
	var surface = runtime["surface"]

	var press_hit := harness.build_hit(surface, Vector2(0.20, 0.20), Vector2(200.0, 200.0))
	assert_true(provider.publish_input_event(adapter, surface, harness.make_touch_press(0, Vector2(200.0, 200.0), true), press_hit))

	var drag_hit := harness.build_hit(surface, Vector2(0.70, 0.20), Vector2(700.0, 200.0))
	assert_true(provider.publish_input_event(adapter, surface, harness.make_touch_drag(0, Vector2(700.0, 200.0), Vector2(500.0, 0.0)), drag_hit))

	var state: Dictionary = provider.describe_runtime_state()
	assert_eq(int(state.get("active_pointer_count", -1)), 1)
	assert_eq(str(state.get("last_pointer_id", "")), "touch_0")
	assert_eq(str(state.get("last_published_phase", "")), "drag_begin")
	assert_eq(str(state.get("last_live_target_path", "")), "Root/SecondaryActionButton")
	assert_true(bool(state.get("last_surface_hover_hit", false)))

	var active_state: Dictionary = state.get("active_touch_state", {})
	var pointer_state: Dictionary = active_state.get("touch_0", {})
	assert_eq(str(pointer_state.get("owner_target_path", NodePath())), "Root/PrimaryActionButton")
	assert_eq(str(pointer_state.get("live_target_path", NodePath())), "Root/SecondaryActionButton")
	assert_true(bool(pointer_state.get("drag_started", false)))

	var projected_data: Dictionary = state.get("last_projected_data", {})
	var raw_metadata: Dictionary = projected_data.get("raw_metadata", {})
	assert_eq(str(raw_metadata.get("owner_target_path", "")), "Root/PrimaryActionButton")
	assert_eq(str(raw_metadata.get("hover_target_path", "")), "Root/SecondaryActionButton")
	assert_eq(str(raw_metadata.get("host_surface", "")), "PanelInputSurface")
	assert_eq(str(raw_metadata.get("target_resolution", "")), "rect_target_specs")

	var summary: Dictionary = MANIFEST_SCRIPT.ownership_summary()
	assert_true(summary.get("implements_touch_runtime_behavior", false))
	assert_eq(summary.get("expected_source_variant"), "screen_touch")
	assert_eq(summary.get("expected_surface_type"), "hybrid_3d_gui")
	assert_eq(summary.get("expected_verification_status"), "unverified")
