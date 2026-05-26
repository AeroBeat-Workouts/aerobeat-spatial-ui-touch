extends GutTest

const HARNESS_SCRIPT := preload("res://tests/support/touch_provider_test_harness.gd")
const MANIFEST_SCRIPT := preload("res://addons/aerobeat-spatial-ui-touch/src/providers/touch/aero_spatial_ui_touch_manifest.gd")

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
	assert_eq(str(state.get("active_pointer_id", "")), "touch_0")
	assert_eq(str(state.get("active_owner_target_path", NodePath())), "Root/PrimaryActionButton")
	assert_eq(str(state.get("active_live_target_path", NodePath())), "Root/SecondaryActionButton")
	assert_true(bool(state.get("active_drag_started", false)))
	assert_true(bool(state.get("has_active_owner", false)))
	assert_true(bool(state.get("has_active_live_target", false)))
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

	var interaction_summary: Dictionary = provider.describe_interaction_summary()
	assert_true(bool(interaction_summary.get("is_touch_active", false)))
	assert_eq(int(interaction_summary.get("active_pointer_count", -1)), 1)
	assert_eq(str(interaction_summary.get("active_pointer_id", "")), "touch_0")
	assert_eq(str(interaction_summary.get("preferred_target_path", NodePath())), "Root/PrimaryActionButton")
	assert_eq(str(interaction_summary.get("preferred_target_label", "")), "PrimaryActionButton")
	assert_eq(str(interaction_summary.get("owner_target_label", "")), "PrimaryActionButton")
	assert_eq(str(interaction_summary.get("live_target_label", "")), "SecondaryActionButton")
	assert_eq(str(interaction_summary.get("state_phase", "")), "drag_begin")

	var summary: Dictionary = MANIFEST_SCRIPT.ownership_summary()
	assert_true(summary.get("implements_touch_runtime_behavior", false))
	assert_eq(summary.get("expected_source_variant"), "screen_touch")
	assert_eq(summary.get("expected_surface_type"), "hybrid_3d_gui")
	assert_eq(summary.get("expected_verification_status"), "unverified")


func test_interaction_summary_clears_after_release_but_retains_release_feedback() -> void:
	var harness = HARNESS_SCRIPT.new()
	var runtime = await harness.spawn(self)
	var provider = runtime["provider"]
	var adapter = runtime["adapter"]
	var surface = runtime["surface"]

	var press_hit := harness.build_hit(surface, Vector2(0.20, 0.20), Vector2(200.0, 200.0))
	assert_true(provider.publish_input_event(adapter, surface, harness.make_touch_press(0, Vector2(200.0, 200.0), true), press_hit))
	assert_true(provider.publish_input_event(adapter, surface, harness.make_touch_press(0, Vector2(900.0, 900.0), false), harness.build_off_surface_hit(Vector2(900.0, 900.0))))

	var interaction_summary: Dictionary = provider.describe_interaction_summary()
	assert_false(bool(interaction_summary.get("is_touch_active", true)))
	assert_eq(int(interaction_summary.get("active_pointer_count", -1)), 0)
	assert_eq(str(interaction_summary.get("state_phase", "not-empty")), "")
	assert_eq(str(interaction_summary.get("preferred_target_path", NodePath())), "")
	assert_eq(str(interaction_summary.get("preferred_target_label", "not-none")), "none")
	assert_eq(str(interaction_summary.get("last_release_target_path", "")), "Root/PrimaryActionButton")
	assert_string_contains(str(interaction_summary.get("last_forwarded_panel_event", "")), "publish touch release #0")


func test_provider_exposes_packaged_probe_helpers_for_target_resolution_and_projected_data() -> void:
	var harness = HARNESS_SCRIPT.new()
	var runtime = await harness.spawn(self)
	var provider = runtime["provider"]
	var surface = runtime["surface"]

	var primary_hit := harness.build_hit(surface, Vector2(0.20, 0.20), Vector2(200.0, 200.0))
	assert_eq(str(provider.resolve_target_path_for_hit(surface, primary_hit)), "Root/PrimaryActionButton")

	var projected_data: Dictionary = provider.build_projected_data_for_hit(
		surface,
		primary_hit,
		{"host_surface": "PanelInputSurface", "target_resolution": "rect_target_specs"},
		{},
		NodePath("Root/PrimaryActionButton")
	)
	var raw_metadata: Dictionary = projected_data.get("raw_metadata", {})
	assert_eq(str(projected_data.get("target_path", NodePath())), "Root/PrimaryActionButton")
	assert_eq(str(raw_metadata.get("published_target_path", "")), "Root/PrimaryActionButton")
	assert_eq(str(raw_metadata.get("live_target_path", "")), "Root/PrimaryActionButton")
	assert_eq(str(raw_metadata.get("owner_target_path", "")), "Root/PrimaryActionButton")
	assert_eq(str(raw_metadata.get("host_surface", "")), "PanelInputSurface")
	assert_eq(str(raw_metadata.get("target_resolution", "")), "rect_target_specs")
