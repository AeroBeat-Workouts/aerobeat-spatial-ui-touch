extends GutTest

const HARNESS_SCRIPT := preload("res://tests/support/touch_provider_test_harness.gd")

func test_drag_threshold_and_release_order_preserve_owner_truth() -> void:
	var harness = HARNESS_SCRIPT.new()
	var runtime = await harness.spawn(self, 12.0)
	var provider = runtime["provider"]
	var adapter = runtime["adapter"]
	var surface = runtime["surface"]
	var events: Array = runtime["events"]

	var press_hit := harness.build_hit(surface, Vector2(0.20, 0.20), Vector2(200.0, 200.0))
	assert_true(provider.publish_input_event(adapter, surface, harness.make_touch_press(0, Vector2(200.0, 200.0), true), press_hit))

	var small_drag_hit := harness.build_hit(surface, Vector2(0.205, 0.20), Vector2(205.0, 200.0))
	assert_true(provider.publish_input_event(adapter, surface, harness.make_touch_drag(0, Vector2(205.0, 200.0), Vector2(5.0, 0.0)), small_drag_hit))
	assert_eq(str(events[1].phase), "press_hold")
	assert_eq(str(events[1].target_path), "Root/PrimaryActionButton")

	var drag_begin_hit := harness.build_hit(surface, Vector2(0.24, 0.20), Vector2(240.0, 200.0))
	assert_true(provider.publish_input_event(adapter, surface, harness.make_touch_drag(0, Vector2(240.0, 200.0), Vector2(35.0, 0.0)), drag_begin_hit))
	assert_eq(str(events[2].phase), "drag_begin")
	assert_eq(str(events[2].target_path), "Root/PrimaryActionButton")

	var drag_move_hit := harness.build_hit(surface, Vector2(0.70, 0.20), Vector2(700.0, 200.0))
	assert_true(provider.publish_input_event(adapter, surface, harness.make_touch_drag(0, Vector2(700.0, 200.0), Vector2(460.0, 0.0)), drag_move_hit))
	assert_eq(str(events[3].phase), "drag_move")
	assert_eq(str(events[3].target_path), "Root/PrimaryActionButton")
	assert_eq(str(events[3].raw_metadata.get("live_target_path", "")), "Root/SecondaryActionButton")
	assert_eq(str(events[3].raw_metadata.get("published_target_path", "")), "Root/PrimaryActionButton")

	assert_true(provider.publish_input_event(adapter, surface, harness.make_touch_press(0, Vector2(900.0, 900.0), false), harness.build_off_surface_hit(Vector2(900.0, 900.0))))
	var phases := harness.event_phases(events)
	assert_eq(phases, ["press_begin", "press_hold", "drag_begin", "drag_move", "drag_end", "press_end"])
	assert_eq(str(events[4].target_path), "Root/PrimaryActionButton")
	assert_eq(str(events[5].target_path), "Root/PrimaryActionButton")

	var state: Dictionary = provider.describe_runtime_state()
	assert_eq(str(state.get("last_published_phase", "")), "press_end")
	assert_eq(str(state.get("last_release_target_path", "")), "Root/PrimaryActionButton")
