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
		"implements_touch_runtime_behavior": true,
		"supports_verification_probe_snapshot": true,
		"expected_source_variant": "screen_touch",
		"expected_surface_type": "hybrid_3d_gui",
		"expected_verification_status": "unverified",
	}
