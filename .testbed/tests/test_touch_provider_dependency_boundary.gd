extends GutTest

const RUNTIME_BOUNDARY := preload("res://../src/providers/touch/aero_spatial_ui_touch_runtime_boundary.gd")
const README_PATH := "res://../README.md"

func test_dependency_boundary_pins_existing_owners_without_reclaiming_host_seams() -> void:
	var dependencies: Dictionary = RUNTIME_BOUNDARY.describe_dependencies()
	assert_eq(dependencies.get("contract_owner_package"), "aerobeat-input-core")
	assert_eq(dependencies.get("shared_helper_owner_package"), "aerobeat-spatial-ui-core")
	assert_eq(dependencies.get("provider_lane"), "touch")

	var helper_expectations := PackedStringArray(dependencies.get("helper_dependency_expectations", PackedStringArray()))
	assert_true(helper_expectations.has("HybridSubViewportInputAdapter"))
	assert_true(helper_expectations.has("AeroSpatialProjectionHelper"))
	assert_true(helper_expectations.has("AeroSpatialRectTargetResolver"))

	var non_goals: PackedStringArray = RUNTIME_BOUNDARY.describe_non_goals()
	assert_true(non_goals.has("no canonical interaction contract types"))
	assert_true(non_goals.has("no native 2D bridge logic"))
	assert_true(non_goals.has("no shared helper-layer ownership"))
	assert_true(non_goals.has("no proof-host camera ray/world-hit acquisition ownership"))

	var extracted_slice: Dictionary = RUNTIME_BOUNDARY.describe_extracted_slice()
	assert_true(extracted_slice.get("implements_touch_runtime_behavior", false))
	assert_false(extracted_slice.get("owns_world_hit_acquisition", true))
	assert_false(extracted_slice.get("owns_contract_definition", true))

	var readme := FileAccess.get_file_as_string(README_PATH)
	assert_string_contains(readme, "aerobeat-input-core")
	assert_string_contains(readme, "aerobeat-spatial-ui-core")
	assert_string_contains(readme, "touch lifecycle/runtime semantics")
	assert_string_contains(readme, "world-hit acquisition")
