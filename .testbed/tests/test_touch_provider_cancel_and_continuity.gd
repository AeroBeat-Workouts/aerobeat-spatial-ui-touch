extends GutTest

const RUNTIME_BOUNDARY := preload("res://../src/providers/touch/aero_spatial_ui_touch_runtime_boundary.gd")
const EXTRACTION_DOC_PATH := "res://../docs/phase-2-first-touch-provider-extraction.md"

func test_cancel_and_continuity_scope_is_frozen_at_boundary_level():
	var extracted_slice: Dictionary = RUNTIME_BOUNDARY.describe_extracted_slice()
	assert_true(extracted_slice.get("owns_touch_press_drag_release_continuity", false))
	assert_true(extracted_slice.get("owns_off_surface_release_continuation", false))
	assert_true(extracted_slice.get("owns_canceled_touch_publication_policy", false))
	assert_false(extracted_slice.get("implements_touch_runtime_behavior", true))

	var extraction_doc := FileAccess.get_file_as_string(EXTRACTION_DOC_PATH)
	assert_string_contains(extraction_doc, "off-surface release continuation using prior projected data")
	assert_string_contains(extraction_doc, "explicit canceled touch publishes `cancel`")
