extends GutTest

const HARNESS_SCRIPT := preload("res://tests/support/touch_provider_test_harness.gd")
const RUNTIME_BOUNDARY := preload("res://../src/providers/touch/aero_spatial_ui_touch_runtime_boundary.gd")

func test_cancel_and_entry_policy_match_first_extraction_truth() -> void:
	var harness = HARNESS_SCRIPT.new()
	var runtime = await harness.spawn(self)
	var provider = runtime["provider"]
	var adapter = runtime["adapter"]
	var surface = runtime["surface"]
	var events: Array = runtime["events"]

	assert_false(provider.publish_input_event(
		adapter,
		surface,
		harness.make_touch_press(0, Vector2(950.0, 950.0), true),
		harness.build_off_surface_hit(Vector2(950.0, 950.0))
	))
	assert_eq(events.size(), 0)

	var press_hit := harness.build_hit(surface, Vector2(0.20, 0.20), Vector2(200.0, 200.0))
	assert_true(provider.publish_input_event(adapter, surface, harness.make_touch_press(0, Vector2(200.0, 200.0), true), press_hit))

	var cancel := harness.make_touch_press(0, Vector2(205.0, 205.0), false, true)
	assert_true(provider.publish_input_event(adapter, surface, cancel, harness.build_off_surface_hit(Vector2(205.0, 205.0))))
	assert_eq(harness.event_phases(events), ["press_begin", "cancel"])
	assert_eq(str(events[1].target_path), "Root/PrimaryActionButton")

	var state: Dictionary = provider.describe_runtime_state()
	assert_eq(int(state.get("active_pointer_count", -1)), 0)
	assert_eq(str(state.get("last_published_phase", "")), "cancel")

	var extracted_slice: Dictionary = RUNTIME_BOUNDARY.describe_extracted_slice()
	assert_true(extracted_slice.get("owns_touch_press_drag_release_continuity", false))
	assert_true(extracted_slice.get("owns_off_surface_release_continuation", false))
	assert_true(extracted_slice.get("owns_canceled_touch_publication_policy", false))
	assert_true(extracted_slice.get("implements_touch_runtime_behavior", false))
