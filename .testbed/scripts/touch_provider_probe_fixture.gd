extends Control

@onready var probe_panel: Control = get_node("Column/ProbePanel") as Control
@onready var fixture_label: Label = get_node("Column/FixtureLabel") as Label

func bind_runtime(provider, transcript_events: Array = []) -> void:
	if probe_panel != null and probe_panel.has_method("bind_provider"):
		probe_panel.bind_provider(provider, transcript_events)
	_refresh_fixture_copy()

func refresh_probe() -> void:
	if probe_panel != null and probe_panel.has_method("refresh_from_provider"):
		probe_panel.refresh_from_provider()
	_refresh_fixture_copy()

func current_probe_snapshot() -> Dictionary:
	if probe_panel != null and probe_panel.has_method("current_probe_snapshot"):
		return probe_panel.current_probe_snapshot()
	return {}

func transcript_lines() -> PackedStringArray:
	if probe_panel != null and probe_panel.has_method("current_transcript_lines"):
		return probe_panel.current_transcript_lines()
	return PackedStringArray()

func _refresh_fixture_copy() -> void:
	var probe: Dictionary = current_probe_snapshot()
	fixture_label.text = "fixture targets owner=%s live=%s phase=%s" % [
		str(probe.get("owner_target_label", "none")),
		str(probe.get("live_target_label", "none")),
		str(probe.get("state_phase", "")),
	]
