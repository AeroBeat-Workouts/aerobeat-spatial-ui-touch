extends GutTest

const PROVIDER_SCRIPT_PATH := "res://../src/providers/touch/aero_spatial_ui_touch_provider.gd"
const EXTRACTION_DOC_PATH := "res://../docs/phase-2-first-touch-provider-extraction.md"

func test_press_release_semantics_are_named_but_not_claimed_as_implemented():
	var provider = load(PROVIDER_SCRIPT_PATH).new()
	var boundary: Dictionary = provider.describe_boundary()
	assert_eq(boundary.get("provider_lane"), "touch")
	assert_true(boundary.get("owns_touch_provider_runtime", false))
	assert_false(boundary.get("implements_runtime_behavior", true))
	assert_eq(boundary.get("expected_source_variant"), "screen_touch")
	assert_eq(boundary.get("expected_surface_type"), "hybrid_3d_gui")
	assert_eq(boundary.get("expected_verification_status"), "unverified")

	var extraction_doc := FileAccess.get_file_as_string(EXTRACTION_DOC_PATH)
	assert_string_contains(extraction_doc, "press_end.target_path")
	assert_string_contains(extraction_doc, "ordinary release-outside remains `press_end`, not `cancel`, when continuity exists")
