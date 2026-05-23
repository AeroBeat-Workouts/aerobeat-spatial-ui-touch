@tool
extends RefCounted
class_name AeroSpatialUiTouchManifest

const PROVIDER_LANE := "touch"
const CONTRACT_OWNER_PACKAGE := "aerobeat-input-core"
const SHARED_HELPER_OWNER_PACKAGE := "aerobeat-spatial-ui-core"

static func ownership_summary() -> Dictionary:
	return {
		"provider_lane": PROVIDER_LANE,
		"contract_owner_package": CONTRACT_OWNER_PACKAGE,
		"shared_helper_owner_package": SHARED_HELPER_OWNER_PACKAGE,
		"owns_concrete_provider_behavior": true,
		"owns_contract_definition": false,
		"owns_native_2d_bridge": false,
		"owns_shared_helper_layer": false,
		"owns_proof_host_world_hit_acquisition": false,
		"bootstrap_status": "boundary_only_no_runtime_implementation_yet",
	}
