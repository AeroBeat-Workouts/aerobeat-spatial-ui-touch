@tool
extends RefCounted
class_name AeroSpatialUiTouchProviderConfig

const DEFAULT_PROVIDER_LANE := "touch"
const DEFAULT_POINTER_ID_PREFIX := "touch_"
const DEFAULT_DRAG_THRESHOLD_PIXELS := 12.0

var contract_owner_package := "aerobeat-input-core"
var shared_helper_owner_package := "aerobeat-spatial-ui-core"
var extraction_phase := "phase_2_first_touch_provider_extraction"
var pointer_id_prefix := DEFAULT_POINTER_ID_PREFIX
var drag_threshold_pixels := DEFAULT_DRAG_THRESHOLD_PIXELS
var host_surface := ""
var target_resolution := "rect_target_specs"
var enable_runtime_diagnostics := false

func to_boundary_snapshot() -> Dictionary:
	return {
		"provider_lane": DEFAULT_PROVIDER_LANE,
		"contract_owner_package": contract_owner_package,
		"shared_helper_owner_package": shared_helper_owner_package,
		"extraction_phase": extraction_phase,
		"pointer_id_prefix": pointer_id_prefix,
		"drag_threshold_pixels": drag_threshold_pixels,
		"host_surface": host_surface,
		"target_resolution": target_resolution,
		"enable_runtime_diagnostics": enable_runtime_diagnostics,
	}

func to_runtime_context() -> Dictionary:
	return {
		"pointer_id_prefix": pointer_id_prefix,
		"drag_threshold_pixels": drag_threshold_pixels,
		"host_surface": host_surface,
		"target_resolution": target_resolution,
		"enable_runtime_diagnostics": enable_runtime_diagnostics,
	}
