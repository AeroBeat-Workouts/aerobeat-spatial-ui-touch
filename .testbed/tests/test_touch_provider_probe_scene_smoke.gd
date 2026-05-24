extends GutTest

const HARNESS_SCRIPT := preload("res://tests/support/touch_provider_test_harness.gd")
const PROBE_FIXTURE_SCENE := preload("res://scenes/touch_provider_probe_fixture.tscn")

func test_provider_probe_fixture_scene_reads_verification_probe_snapshot() -> void:
	var harness = HARNESS_SCRIPT.new()
	var runtime = await harness.spawn(self)
	var provider = runtime["provider"]
	var adapter = runtime["adapter"]
	var surface = runtime["surface"]
	var events: Array = runtime["events"]

	var fixture = PROBE_FIXTURE_SCENE.instantiate()
	add_child_autofree(fixture)
	fixture.bind_runtime(provider, events)
	await get_tree().process_frame

	var press_hit := harness.build_hit(surface, Vector2(0.20, 0.20), Vector2(200.0, 200.0))
	assert_true(provider.publish_input_event(adapter, surface, harness.make_touch_press(0, Vector2(200.0, 200.0), true), press_hit))

	var drag_hit := harness.build_hit(surface, Vector2(0.70, 0.20), Vector2(700.0, 200.0))
	assert_true(provider.publish_input_event(adapter, surface, harness.make_touch_drag(0, Vector2(700.0, 200.0), Vector2(500.0, 0.0)), drag_hit))

	fixture.bind_runtime(provider, events)
	fixture.refresh_probe()

	var probe: Dictionary = fixture.current_probe_snapshot()
	assert_eq(str(probe.get("owner_target_label", "")), "PrimaryActionButton")
	assert_eq(str(probe.get("live_target_label", "")), "SecondaryActionButton")
	assert_eq(str(probe.get("state_phase", "")), "drag_begin")

	var transcript: PackedStringArray = fixture.transcript_lines()
	assert_eq(transcript, PackedStringArray(["press_begin", "drag_begin"]))
	assert_string_contains(fixture.get_node("Column/FixtureLabel").text, "owner=PrimaryActionButton")
	assert_string_contains(fixture.get_node("Column/ProbePanel/Margin/Column/SummaryLabel").text, "verification: unverified")
