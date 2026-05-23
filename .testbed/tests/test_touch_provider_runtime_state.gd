extends GutTest

const MANIFEST_SCRIPT := preload("res://../src/providers/touch/aero_spatial_ui_touch_manifest.gd")
const BOUNDARY_DOC_PATH := "res://../docs/phase-1-boundary-freeze.md"

func test_runtime_state_bootstrap_keeps_manifest_truthful_and_inert():
	var summary: Dictionary = MANIFEST_SCRIPT.ownership_summary()
	assert_eq(summary.get("provider_lane"), "touch")
	assert_eq(summary.get("contract_owner_package"), "aerobeat-input-core")
	assert_eq(summary.get("shared_helper_owner_package"), "aerobeat-spatial-ui-core")
	assert_true(summary.get("owns_concrete_provider_behavior", false))
	assert_false(summary.get("owns_contract_definition", true))
	assert_false(summary.get("owns_native_2d_bridge", true))
	assert_false(summary.get("owns_shared_helper_layer", true))
	assert_false(summary.get("owns_proof_host_world_hit_acquisition", true))
	assert_eq(summary.get("bootstrap_status"), "boundary_only_no_runtime_implementation_yet")

	var boundary_doc := FileAccess.get_file_as_string(BOUNDARY_DOC_PATH)
	assert_string_contains(boundary_doc, "touch pointer lifecycle/runtime state")
	assert_string_contains(boundary_doc, "proof-host camera ray creation or world-hit acquisition")
