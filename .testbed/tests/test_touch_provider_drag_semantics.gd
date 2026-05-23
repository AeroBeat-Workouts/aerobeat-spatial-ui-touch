extends GutTest

const CONFIG_SCRIPT := preload("res://../src/providers/touch/aero_spatial_ui_touch_provider_config.gd")
const EXTRACTION_DOC_PATH := "res://../docs/phase-2-first-touch-provider-extraction.md"

func test_drag_semantics_scaffold_records_touch_defaults_only():
	var config = CONFIG_SCRIPT.new()
	var snapshot: Dictionary = config.to_boundary_snapshot()
	assert_eq(snapshot.get("provider_lane"), "touch")
	assert_eq(snapshot.get("pointer_id_prefix"), "touch_")
	assert_eq(snapshot.get("target_resolution"), "rect_target_specs")
	assert_gt(float(snapshot.get("drag_threshold", 0.0)), 0.0)
	assert_eq(snapshot.get("extraction_phase"), "phase_1_touch_bootstrap_boundary_truth")

	var extraction_doc := FileAccess.get_file_as_string(EXTRACTION_DOC_PATH)
	assert_string_contains(extraction_doc, "drag lifecycle publication ordering")
	assert_string_contains(extraction_doc, "`drag_end` publishes before `press_end`")
