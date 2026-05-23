@tool
extends Resource
class_name AeroSpatialUiTouchProviderConfig

const EXTRACTION_PHASE := "phase_1_touch_bootstrap_boundary_truth"

var host_surface: NodePath = NodePath()
var target_resolution := "rect_target_specs"
var pointer_id_prefix := "touch_"
var drag_threshold := 12.0
var enable_runtime_diagnostics := false

func to_boundary_snapshot() -> Dictionary:
	return {
		"provider_lane": "touch",
		"extraction_phase": EXTRACTION_PHASE,
		"host_surface": host_surface,
		"target_resolution": target_resolution,
		"pointer_id_prefix": pointer_id_prefix,
		"drag_threshold": drag_threshold,
		"enable_runtime_diagnostics": enable_runtime_diagnostics,
		"contract_owner_package": "aerobeat-input-core",
		"shared_helper_owner_package": "aerobeat-spatial-ui-core",
	}
