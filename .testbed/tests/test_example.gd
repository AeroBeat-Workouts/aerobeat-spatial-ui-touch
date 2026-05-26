extends GutTest

const INSTALLED_TOUCH_PACKAGE_ROOT := "res://addons/aerobeat-spatial-ui-touch"
const PROVIDER_SCRIPT_PATH := INSTALLED_TOUCH_PACKAGE_ROOT + "/src/providers/touch/aero_spatial_ui_touch_provider.gd"
const PROVIDER_CONFIG_SCRIPT_PATH := INSTALLED_TOUCH_PACKAGE_ROOT + "/src/providers/touch/aero_spatial_ui_touch_provider_config.gd"
const RUNTIME_BOUNDARY_SCRIPT_PATH := INSTALLED_TOUCH_PACKAGE_ROOT + "/src/providers/touch/aero_spatial_ui_touch_runtime_boundary.gd"
const MANIFEST_SCRIPT_PATH := INSTALLED_TOUCH_PACKAGE_ROOT + "/src/providers/touch/aero_spatial_ui_touch_manifest.gd"
const BOUNDARY_DOC_PATH := INSTALLED_TOUCH_PACKAGE_ROOT + "/docs/phase-1-boundary-freeze.md"
const EXTRACTION_DOC_PATH := INSTALLED_TOUCH_PACKAGE_ROOT + "/docs/phase-2-first-touch-provider-extraction.md"

func before_all():
	gut.p("Starting Spatial UI Touch bootstrap tests...")

func after_all():
	gut.p("Finished Spatial UI Touch bootstrap tests.")

func test_plugin_manifest_structure():
	var manifest_path = INSTALLED_TOUCH_PACKAGE_ROOT + "/plugin.cfg"
	assert_true(FileAccess.file_exists(manifest_path), "plugin.cfg should exist at the repo root")

	var config = ConfigFile.new()
	assert_eq(config.load(manifest_path), OK, "plugin.cfg should load")
	assert_eq(config.get_value("plugin", "name", ""), "AeroBeat Spatial UI Touch")
	assert_eq(
		config.get_value("plugin", "description", ""),
		"Touch-driven spatial UI provider addon bootstrap for AeroBeat."
	)

func test_touch_bootstrap_surface_exists():
	assert_true(FileAccess.file_exists(PROVIDER_SCRIPT_PATH), "provider script should exist")
	assert_true(FileAccess.file_exists(PROVIDER_CONFIG_SCRIPT_PATH), "config script should exist")
	assert_true(FileAccess.file_exists(RUNTIME_BOUNDARY_SCRIPT_PATH), "runtime boundary script should exist")
	assert_true(FileAccess.file_exists(MANIFEST_SCRIPT_PATH), "manifest script should exist")
	assert_true(FileAccess.file_exists(BOUNDARY_DOC_PATH), "Phase 1 boundary doc should exist")
	assert_true(FileAccess.file_exists(EXTRACTION_DOC_PATH), "Phase 2 stub doc should exist")
