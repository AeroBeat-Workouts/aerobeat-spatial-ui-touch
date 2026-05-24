extends GutTest

const HARNESS_SCENE := preload("res://scenes/touch_provider_verification_harness.tscn")

func test_touch_provider_verification_harness_shows_packaged_provider_and_contract_truth() -> void:
	var harness = HARNESS_SCENE.instantiate()
	add_child_autofree(harness)
	await get_tree().process_frame
	await get_tree().process_frame

	var initial_snapshot: Dictionary = harness.describe_hud_snapshot()
	assert_true(bool(initial_snapshot.get("packaged_provider_active", false)))
	assert_eq(str(initial_snapshot.get("provider_runtime_seam", "")), "repo_packaged_provider")
	assert_string_contains(str(initial_snapshot.get("provider_runtime_source", "")), "src/providers/touch/aero_spatial_ui_touch_provider.gd")
	assert_eq(str(initial_snapshot.get("verification_status", "")), "unverified")
	assert_eq(str(initial_snapshot.get("source_variant", "")), "screen_touch")

	assert_true(harness.publish_touch_press(Vector2(0.20, 0.20), Vector2(200.0, 200.0), true))
	assert_true(harness.publish_touch_drag(Vector2(0.70, 0.20), Vector2(700.0, 200.0), Vector2(500.0, 0.0)))
	assert_true(harness.publish_touch_press(Vector2.ZERO, Vector2(900.0, 900.0), false))

	var snapshot: Dictionary = harness.describe_hud_snapshot()
	assert_eq(str(snapshot.get("phase", "")), "press_end")
	assert_eq(str(snapshot.get("target_path", "")), "Root/PrimaryActionButton")
	assert_eq(str(snapshot.get("verification_status", "")), "unverified")
	assert_eq(str(snapshot.get("state_phase", "not-empty")), "")
	assert_eq(str(snapshot.get("last_release_target_path", "")), "Root/PrimaryActionButton")
	assert_string_contains(str(snapshot.get("last_projected_hit_summary", "")), "owner=Root/PrimaryActionButton")

	var status_text: String = str(harness.get_node("Margin/Content/Status").text)
	assert_string_contains(status_text, "Touch provider verification harness")
	assert_string_contains(status_text, "packaged provider seam:")
	assert_string_contains(status_text, "repo_packaged_provider")
	assert_string_contains(status_text, "runtime source:")
	assert_string_contains(status_text, "source variant:")
	assert_string_contains(status_text, "screen_touch")
	assert_string_contains(status_text, "phase:")
	assert_string_contains(status_text, "press_end")
	assert_string_contains(status_text, "verification status:")
	assert_string_contains(status_text, "unverified")
	assert_string_contains(status_text, "last_release_target_path = Root/PrimaryActionButton")
