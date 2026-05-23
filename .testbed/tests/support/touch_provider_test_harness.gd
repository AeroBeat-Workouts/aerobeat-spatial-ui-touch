extends RefCounted

const BUS_SCRIPT := preload("res://addons/aerobeat-input-core/src/ui/ui_interaction_bus.gd")
const ADAPTER_SCRIPT := preload("res://addons/aerobeat-input-core/src/ui/adapters/hybrid_subviewport_input_adapter.gd")
const SURFACE_DESCRIPTOR_SCRIPT := preload("res://addons/aerobeat-spatial-ui-core/src/helpers/surfaces/aero_spatial_surface_descriptor.gd")
const PROJECTION_HELPER_SCRIPT := preload("res://addons/aerobeat-spatial-ui-core/src/helpers/providers/aero_spatial_projection_helper.gd")
const PROVIDER_SCRIPT := preload("res://../src/providers/touch/aero_spatial_ui_touch_provider.gd")
const CONFIG_SCRIPT := preload("res://../src/providers/touch/aero_spatial_ui_touch_provider_config.gd")

const SURFACE_ID: StringName = &"hybrid_touch"
const TARGET_PATH := NodePath("Root/PrimaryActionButton")
const SECONDARY_TARGET_PATH := NodePath("Root/SecondaryActionButton")
const PRIMARY_TARGET_RECT := Rect2(100.0, 100.0, 200.0, 200.0)
const SECONDARY_TARGET_RECT := Rect2(650.0, 100.0, 200.0, 200.0)

var _projection_helper = PROJECTION_HELPER_SCRIPT.new()

func spawn(test_case: GutTest, threshold := 12.0) -> Dictionary:
	var host := Node.new()
	host.name = "HarnessHost"
	var bus = BUS_SCRIPT.new()
	bus.name = "Bus"
	host.add_child(bus)
	var adapter = ADAPTER_SCRIPT.new()
	adapter.name = "Adapter"
	adapter.bus_path = NodePath("../Bus")
	adapter.surface_id = SURFACE_ID
	adapter.surface_type = &"hybrid_3d_gui"
	adapter.surface_pixel_size = Vector2(1000.0, 1000.0)
	adapter.drag_threshold_pixels = threshold
	host.add_child(adapter)
	test_case.add_child_autofree(host)
	await test_case.get_tree().process_frame

	var events: Array = []
	bus.interaction_event.connect(func(event): events.append(event))

	var config = CONFIG_SCRIPT.new()
	config.drag_threshold_pixels = threshold
	config.host_surface = "PanelInputSurface"
	config.target_resolution = "rect_target_specs"
	var provider = PROVIDER_SCRIPT.new(config)
	return {
		"host": host,
		"bus": bus,
		"adapter": adapter,
		"provider": provider,
		"surface": _build_surface(),
		"events": events,
	}

func build_hit(surface, authored_uv: Vector2, screen_position: Vector2 = Vector2.ZERO) -> Dictionary:
	var panel_uv := authored_uv
	return _projection_helper.build_surface_hit(surface, panel_uv, {
		"screen_position": screen_position,
		"world_position": Vector3(authored_uv.x, authored_uv.y, 0.0),
		"world_normal": Vector3.UP,
		"world_direction": Vector3.FORWARD,
		"surface_size": surface.metadata.get("surface_size", Vector2.ZERO),
	})

func build_off_surface_hit(screen_position: Vector2 = Vector2.ZERO) -> Dictionary:
	return {
		"hit": false,
		"screen_position": screen_position,
		"world_direction": Vector3.FORWARD,
	}

func make_touch_press(index: int, screen_position: Vector2, pressed := true, canceled := false) -> InputEventScreenTouch:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = screen_position
	event.pressed = pressed
	event.canceled = canceled
	return event

func make_touch_drag(index: int, screen_position: Vector2, relative: Vector2, pressure := 1.0, velocity := Vector2.ZERO) -> InputEventScreenDrag:
	var event := InputEventScreenDrag.new()
	event.index = index
	event.position = screen_position
	event.relative = relative
	event.pressure = pressure
	event.velocity = velocity if velocity != Vector2.ZERO else relative
	return event

func event_phases(events: Array) -> Array[String]:
	var phases: Array[String] = []
	for event in events:
		phases.append(str(event.phase))
	return phases

func _build_surface():
	var surface = SURFACE_DESCRIPTOR_SCRIPT.new()
	surface.configure({
		"surface_id": SURFACE_ID,
		"surface_path": NodePath("/root/PanelInputSurface"),
		"viewport_path": NodePath("/root/PanelViewport"),
		"surface_pixel_size": Vector2(1000.0, 1000.0),
		"authored_rect_normalized": Rect2(0.0, 0.0, 1.0, 1.0),
		"target_specs": [
			{
				"target_key": "primary",
				"target_name": "Primary Action Button",
				"target_path": TARGET_PATH,
				"rect": PRIMARY_TARGET_RECT,
			},
			{
				"target_key": "secondary",
				"target_name": "Secondary Action Button",
				"target_path": SECONDARY_TARGET_PATH,
				"rect": SECONDARY_TARGET_RECT,
			}
		],
		"metadata": {
			"host_surface": "PanelInputSurface",
			"target_resolution": "rect_target_specs",
			"surface_size": Vector2(2.93, 1.577),
		},
	})
	return surface
