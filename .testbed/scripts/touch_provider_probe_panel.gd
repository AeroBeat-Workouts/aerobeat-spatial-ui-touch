extends Control

const DEFAULT_PROBE := {
	"active_pointer_id": "",
	"is_touch_active": false,
	"state_phase": "",
	"owner_target_label": "none",
	"live_target_label": "none",
	"preferred_target_label": "none",
	"last_release_target_path": "",
	"source_variant": "screen_touch",
	"surface_type": "hybrid_3d_gui",
	"verification_status": "unverified",
	"last_forwarded_panel_event": "",
}

@onready var summary_label: Label = get_node("Margin/Column/SummaryLabel") as Label
@onready var transcript_label: RichTextLabel = get_node("Margin/Column/TranscriptLabel") as RichTextLabel

var _provider = null
var _recent_transcript: Array[String] = []

func bind_provider(provider, transcript_events: Array = []) -> void:
	_provider = provider
	set_recent_transcript(transcript_events)
	refresh_from_provider()

func set_recent_transcript(transcript_events: Array) -> void:
	_recent_transcript.clear()
	for entry in transcript_events:
		if entry == null:
			continue
		if entry is String:
			_recent_transcript.append(entry)
		elif entry is Dictionary:
			_recent_transcript.append(str(entry.get("phase", entry)))
		else:
			_recent_transcript.append(str(entry.phase))
	_refresh_transcript()

func append_event(event) -> void:
	if event == null:
		return
	_recent_transcript.append(str(event.phase))
	if _recent_transcript.size() > 12:
		_recent_transcript = _recent_transcript.slice(_recent_transcript.size() - 12, _recent_transcript.size())
	_refresh_transcript()

func refresh_from_provider() -> void:
	var probe := current_probe_snapshot()
	summary_label.text = _format_probe(probe)
	_refresh_transcript()

func current_probe_snapshot() -> Dictionary:
	if _provider != null and _provider.has_method("describe_verification_probe"):
		return _provider.describe_verification_probe()
	return DEFAULT_PROBE.duplicate(true)

func current_transcript_lines() -> PackedStringArray:
	return PackedStringArray(_recent_transcript)

func _refresh_transcript() -> void:
	var lines := PackedStringArray()
	for entry in _recent_transcript:
		lines.append("• %s" % entry)
	transcript_label.text = "[b]Transcript[/b]\n%s" % ("\n".join(lines) if not lines.is_empty() else "• none")

func _format_probe(probe: Dictionary) -> String:
	return "\n".join([
		"probe snapshot",
		"pointer: %s" % str(probe.get("active_pointer_id", "")),
		"touch active: %s" % str(probe.get("is_touch_active", false)),
		"phase: %s" % str(probe.get("state_phase", "")),
		"owner: %s" % str(probe.get("owner_target_label", "none")),
		"live: %s" % str(probe.get("live_target_label", "none")),
		"preferred: %s" % str(probe.get("preferred_target_label", "none")),
		"last release: %s" % str(probe.get("last_release_target_path", "")),
		"source: %s" % str(probe.get("source_variant", "")),
		"surface: %s" % str(probe.get("surface_type", "")),
		"verification: %s" % str(probe.get("verification_status", "")),
		"forwarded: %s" % str(probe.get("last_forwarded_panel_event", "")),
	])
