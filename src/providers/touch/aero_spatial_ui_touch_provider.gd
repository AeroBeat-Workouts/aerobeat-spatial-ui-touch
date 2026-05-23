@tool
extends RefCounted
class_name AeroSpatialUiTouchProvider

const PROVIDER_CONFIG_SCRIPT := preload("res://../src/providers/touch/aero_spatial_ui_touch_provider_config.gd")

var config

func _init(provider_config = null) -> void:
	config = provider_config if provider_config != null else PROVIDER_CONFIG_SCRIPT.new()

func describe_boundary() -> Dictionary:
	return {
		"provider_lane": "touch",
		"contract_owner_package": "aerobeat-input-core",
		"shared_helper_owner_package": "aerobeat-spatial-ui-core",
		"implements_runtime_behavior": false,
		"bootstrap_status": "boundary_only_no_touch_runtime_implementation_yet",
		"owns_touch_provider_runtime": true,
		"owns_contract_definition": false,
		"owns_native_2d_bridge": false,
		"owns_shared_helper_layer": false,
		"owns_world_hit_acquisition": false,
		"expected_source_variant": "screen_touch",
		"expected_surface_type": "hybrid_3d_gui",
		"expected_verification_status": "unverified",
	}
