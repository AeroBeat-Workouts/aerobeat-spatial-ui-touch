@tool
extends RefCounted
class_name AeroSpatialUiTouchRuntimeBoundary

static func describe_non_goals() -> PackedStringArray:
	return PackedStringArray([
		"no canonical interaction contract types",
		"no native 2D bridge logic",
		"no shared helper-layer ownership",
		"no proof-host camera ray/world-hit acquisition ownership",
		"no proof-scene composition ownership",
	])

static func describe_dependencies() -> Dictionary:
	return {
		"contract_owner_package": "aerobeat-input-core",
		"shared_helper_owner_package": "aerobeat-spatial-ui-core",
		"provider_lane": "touch",
		"helper_dependency_expectations": PackedStringArray([
			"HybridSubViewportInputAdapter",
			"AeroSpatialProjectionHelper",
			"AeroSpatialRectTargetResolver",
		]),
	}

static func describe_extracted_slice() -> Dictionary:
	return {
		"owns_touch_pointer_runtime_state": true,
		"owns_touch_press_drag_release_continuity": true,
		"owns_off_surface_release_continuation": true,
		"owns_canceled_touch_publication_policy": true,
		"owns_provider_runtime_diagnostics": true,
		"owns_interaction_summary_snapshot": true,
		"owns_verification_probe_snapshot": true,
		"owns_contract_definition": false,
		"owns_native_2d_bridge": false,
		"owns_world_hit_acquisition": false,
		"implements_touch_runtime_behavior": true,
	}
