# Phase 3 Touch Provider Manual-Verification Packet

**Status:** Provider-repo harness slice implemented; downstream `aerobeat-ui-kit-community` proof remains separate

This document defines the **next executable touch completion slice after the interaction-summary seam** and the concrete manual-verification/test-scene packet needed to prove `aerobeat-spatial-ui-touch` beyond pure code tests.

It is intentionally a durable planning/execution artifact, not runtime code.

## Baseline truth entering this packet

Phase 2 is already closed as the first truthful extraction slice for the touch provider lane.

That means `aerobeat-spatial-ui-touch` now already owns:

- touch pointer runtime state
- press/drag/release continuity
- off-surface release continuation
- explicit canceled-touch publication policy
- provider runtime diagnostics
- interaction-summary snapshots
- packaged projected-data / target-resolution helper delegation

It does **not** own:

- canonical contract semantics from `aerobeat-input-core`
- shared helper ownership from `aerobeat-spatial-ui-core`
- world-hit acquisition
- proof-scene composition
- live verification-status promotion beyond the current upstream `unverified` truth for `screen_touch` + `hybrid_3d_gui`

## Exact proposed next slice

## Phase 3: provider-owned verification probe seam + scene packet

The next truthful provider-owned runtime seam after `describe_interaction_summary()` is a **provider-owned verification probe snapshot seam** that packages the minimum runtime truth a scene or QA probe needs **without** forcing consumer hosts to restitch provider meaning from raw bus traffic and multiple provider dictionaries.

### Proposed runtime seam

Recommended new public seam in `aerobeat-spatial-ui-touch`:

- `describe_verification_probe()` or equivalently named `describe_probe_snapshot()`

### Why this is the next truthful seam

`describe_interaction_summary()` is enough for concise host status text, but it is too lossy for manual verification and too easy for consumer repos to reinterpret incorrectly.

A manual verification scene still needs stable access to:

- the current active pointer id
- owner target path/label
- live target path/label
- preferred target path/label
- active phase
- last release target path
- last forwarded provider event text
- last published phase
- last projected/raw metadata relevant to host-vs-provider ownership
- conservative verification truth (`screen_touch`, `hybrid_3d_gui`, `unverified`)
- terminal-event truth that a human can compare against the visible scene result

That bundle is still **provider-owned runtime truth**. It does not move contract ownership, helper ownership, world-hit acquisition, or proof composition.

### What the new seam should contain

The probe snapshot should be a stable, scene-readable packet made from provider-owned truth only. Recommended fields:

- `active_pointer_count`
- `active_pointer_id`
- `is_touch_active`
- `state_phase`
- `last_published_phase`
- `owner_target_path`
- `owner_target_label`
- `live_target_path`
- `live_target_label`
- `preferred_target_path`
- `preferred_target_label`
- `has_active_owner`
- `has_active_live_target`
- `last_release_target_path`
- `last_forwarded_panel_event`
- `last_projected_data`
- `source_variant` expected by the provider lane (`screen_touch`)
- `surface_type` expected by the provider lane (`hybrid_3d_gui`)
- `verification_status` expected by upstream truth (`unverified`)

This seam should be **read-only descriptive runtime truth**. It should not publish events, mutate adapter state, or absorb any host-local ray/world-hit responsibilities.

## What must remain host-local

The following seams must remain outside `aerobeat-spatial-ui-touch` in this slice.

### `aerobeat-ui-kit-community` must continue to own

1. **World-hit acquisition**
   - `Camera3D.project_ray_origin(...)`
   - `Camera3D.project_ray_normal(...)`
   - `PhysicsRayQueryParameters3D.create(...)`
   - `direct_space_state.intersect_ray(...)`
   - panel-mesh / `PanelInputSurface` assumptions

2. **Proof-scene composition**
   - the 3D hybrid proof host
   - scene wiring for `PanelViewport`, `PanelInputSurface`, and authored panel content
   - proof-scene overlay/debug composition

3. **Human QA affordances tied to the proof host**
   - any host-local transcript panel or debug labels showing actual downstream state
   - any host-local control for provoking hard-to-reproduce paths such as a synthetic cancel button for the active pointer
   - any host-local framing needed so Derrick can actually touch the real hybrid proof scene

4. **Installed-addon consumer proof**
   - proving the hidden testbed is exercising the installed touch package under `res://addons/...`
   - proving the host is still the owner of hit acquisition while the provider owns lifecycle/runtime semantics

### `aerobeat-input-core` must continue to own

- canonical phase taxonomy
- event object structure
- verification-status truth source
- `HybridSubViewportInputAdapter`

### `aerobeat-spatial-ui-core` must continue to own

- `AeroSpatialProjectionHelper`
- `AeroSpatialRectTargetResolver`
- `AeroSpatialSurfaceDescriptor`
- any shared helper used by both mouse and touch lanes

## Proposed test-scene ownership split

## Reusable touch test scene ownership: `aerobeat-spatial-ui-touch`

If a **reusable** touch-provider test scene is added, it should live in `aerobeat-spatial-ui-touch`, but it must stay narrowly provider-focused.

### What that reusable scene may own

A provider-local reusable scene may own:

- provider-readable labels/panels for owner/live/preferred target truth
- an event/probe dashboard fed only by provider public APIs and bus output
- a minimal target fixture used to exercise owner-vs-hover separation
- scene-level smoke checks for the touch package itself

### What that reusable scene may not own

It may **not** own:

- 3D proof-host composition
- camera ray generation
- physics hit sourcing
- `PanelInputSurface` world-hit assumptions
- consumer-proof UX specific to `aerobeat-ui-kit-community`

### Recommended provider-repo files

Recommended future file destinations in `aerobeat-spatial-ui-touch`:

- `.testbed/scenes/touch_provider_probe_panel.tscn`
- `.testbed/scripts/touch_provider_probe_panel.gd`
- `.testbed/scenes/touch_provider_probe_fixture.tscn`

These should be small provider fixtures, not the real downstream hybrid proof host.

## Downstream proof scene ownership: `aerobeat-ui-kit-community`

All **real hybrid proof-scene** changes for manual validation belong in `aerobeat-ui-kit-community`.

### Recommended downstream files

Recommended future file destinations in `aerobeat-ui-kit-community`:

- `.testbed/qa_probes/hybrid_touch_provider_manual_probe.tscn`
- `.testbed/qa_probes/hybrid_touch_provider_manual_probe.gd`

The probe should instance or wrap the existing hybrid proof scene rather than relocating that proof composition into the touch repo.

### Downstream proof scene responsibilities

The downstream probe should:

- render the real hybrid 3D proof host
- accept real screen touch input on the actual host machine
- keep the existing host-local world-hit path intact
- display the provider-owned probe snapshot live
- display recent emitted contract phases from the interaction bus
- show owner target vs live hover target simultaneously
- show verification-status truth without promoting it
- show the last release target path
- make off-surface release behavior visible
- make owner-vs-hover divergence visible by allowing a drag from `PrimaryActionButton` toward `SecondaryActionButton`

## Exact human verification steps the scene should enable

The packet should enable Derrick to run one downstream scene and perform the following checks by hand.

## Setup

1. Open `aerobeat-ui-kit-community/.testbed` in Godot.
2. Run the dedicated manual probe scene for touch.
3. Ensure the scene shows:
   - the hybrid proof panel
   - provider probe snapshot fields
   - a recent-event transcript
   - visible labels for owner target, live target, preferred target, state phase, last release target, and verification status
4. Keep auto-rotation disabled or absent for stable touch aiming.

## Manual pass 1 — press begin on the primary target

1. Touch `PrimaryActionButton` once.
2. Verify the probe shows:
   - `active_pointer_id == touch_0`
   - `is_touch_active == true`
   - `state_phase == press_begin`
   - owner/live/preferred target all resolve to `PrimaryActionButton`
   - transcript includes `press_begin`
   - `source_variant == screen_touch`
   - `surface_type == hybrid_3d_gui`
   - `verification_status == unverified`

## Manual pass 2 — below-threshold hold stays hold

1. Touch `PrimaryActionButton`.
2. Move slightly without exceeding the configured drag threshold.
3. Verify the probe shows:
   - `state_phase == press_hold`
   - owner target remains `PrimaryActionButton`
   - no `drag_begin` yet appears in the transcript

## Manual pass 3 — drag across targets preserves owner but changes live hover

1. Touch `PrimaryActionButton`.
2. Drag far enough to cross the threshold.
3. Continue dragging toward `SecondaryActionButton`.
4. Verify the probe shows:
   - transcript includes `drag_begin`, then `drag_move`
   - `owner_target_label == PrimaryActionButton`
   - `live_target_label == SecondaryActionButton` once hovering over the secondary target
   - `preferred_target_label` stays aligned with the owner/captured target, not the live hover target

## Manual pass 4 — release after drag ends against the press owner

1. Start on `PrimaryActionButton`.
2. Drag beyond threshold.
3. Release either over `SecondaryActionButton` or off the panel entirely.
4. Verify the probe shows:
   - transcript order includes `drag_end` before `press_end`
   - both terminal events still target `PrimaryActionButton`
   - the visible proof-scene action completes against the primary target
   - `last_release_target_path` still points to `PrimaryActionButton`

## Manual pass 5 — off-surface release stays release, not cancel

1. Touch `PrimaryActionButton`.
2. Drag or move off the panel.
3. Release outside the panel.
4. Verify the probe shows:
   - ordinary completion still ends with `press_end`
   - the transcript does **not** substitute `cancel`
   - `last_release_target_path` remains the original press owner

## Manual pass 6 — cancel path is observable without changing truth claims

Real canceled touch delivery may be hard to trigger reliably on every desktop/touch setup.

So the downstream probe should optionally include a **host-local cancel trigger** for the currently active touch pointer.

1. Begin a touch on `PrimaryActionButton`.
2. Use the probe's cancel trigger while that touch is active.
3. Verify the probe shows:
   - transcript includes `cancel`
   - active touch count clears to zero
   - the provider does not relabel the result as `press_end`
   - `verification_status` still remains `unverified`

This cancel trigger is a **manual proof aid**, not a promotion of live-touch verification truth.

## Automated tests that should accompany this scene work

The next slice should land with both provider-repo tests and downstream consumer tests.

## Provider-repo tests to add in `aerobeat-spatial-ui-touch`

### 1. Probe snapshot contract test

Recommended file:

- `.testbed/tests/test_touch_provider_probe_snapshot.gd`

Required assertions:

- the provider exposes the new probe snapshot seam
- the probe snapshot includes owner/live/preferred target fields
- the probe snapshot carries `last_release_target_path`
- the probe snapshot carries `last_forwarded_panel_event`
- the probe snapshot preserves `source_variant == screen_touch`
- the probe snapshot preserves `surface_type == hybrid_3d_gui`
- the probe snapshot preserves `verification_status == unverified`

### 2. Probe snapshot owner-vs-hover separation test

This may live in the same file or in runtime-state coverage.

Required assertions:

- press on primary target
- drag over secondary target
- probe snapshot reports:
  - owner target = primary
  - live target = secondary
  - preferred target remains aligned with the captured/owner truth

### 3. Probe scene smoke test

Recommended file:

- `.testbed/tests/test_touch_provider_probe_scene_smoke.gd`

Required assertions:

- provider-local probe scene instantiates in the hidden testbed
- scene reads probe snapshot from the provider instead of reconstructing state locally
- scene updates displayed owner/live/phase text after synthetic press/drag/release input

## Downstream consumer tests to add in `aerobeat-ui-kit-community`

### 1. Manual-probe scene smoke test

Recommended file:

- `.testbed/tests/test_hybrid_touch_manual_probe_scene.gd`

Required assertions:

- the manual probe scene instantiates
- it wraps the hybrid proof host rather than re-owning provider semantics
- it can read the provider-owned probe snapshot from the installed touch package

### 2. Installed-addon probe delegation proof

Recommended file:

- `.testbed/tests/test_hybrid_touch_probe_snapshot_flow.gd`

Required assertions:

- the downstream host reads the probe snapshot from `res://addons/aerobeat-spatial-ui-touch/...`
- the host still owns `_screen_position_to_panel_hit(...)`
- the host does not recreate provider state locally to produce the manual probe readout

### 3. Transcript parity proof

This may extend the existing touch consumer tests.

Required assertions:

- touch press produces `press_begin`
- below-threshold move stays `press_hold`
- drag produces `drag_begin` / `drag_move`
- release after drag produces `drag_end` before `press_end`
- off-surface ordinary release stays `press_end`
- cancel remains explicit and separate

## Why this slice is the next honest one

The repo already has the semantic runtime slice and a concise interaction summary.

What is still missing for believable completion is a durable verification packet that:

- gives scenes a stable provider-owned runtime readout
- proves that readout in a provider-local reusable fixture
- proves the real downstream hybrid host can show the same truth while still owning world-hit acquisition
- lets Derrick manually exercise press/hold/drag/release/cancel behavior on actual touch hardware without claiming more than `unverified`

That is the smallest truthful next slice after the interaction-summary seam.

## Explicit non-goals for this slice

This slice must **not**:

- move any contract semantics out of `aerobeat-input-core`
- move any shared helper ownership out of `aerobeat-spatial-ui-core`
- move world-hit acquisition out of `aerobeat-ui-kit-community`
- move proof-scene composition out of `aerobeat-ui-kit-community`
- promote `verification_status` above `unverified`
- add multi-touch gesture ownership, pinch, rotate, or gesture recognition work

## Execution order for the future implementation bead

1. Add the provider-owned probe snapshot seam in `aerobeat-spatial-ui-touch`.
2. Add provider-local probe scene fixture(s) in `aerobeat-spatial-ui-touch`.
3. Add provider-local automated tests for the probe seam/scene.
4. Add the host-local manual probe scene in `aerobeat-ui-kit-community`.
5. Add downstream automated tests proving installed-addon delegation and transcript parity.
6. Perform the human manual pass on actual touch hardware.
7. Keep `verification_status == unverified` unless upstream truth is intentionally changed by a separate validated contract decision.

## Risks and decision points

### 1. Naming the new public seam

Decision needed:

- `describe_verification_probe()`
- or `describe_probe_snapshot()`

Recommendation: choose the name that most clearly communicates "read-only runtime truth for QA/probes" and avoid names that imply contract ownership.

### 2. How the cancel path is exercised manually

Risk:

- true OS-delivered canceled touch may be difficult to reproduce consistently

Recommendation:

- keep a host-local cancel trigger in the downstream manual probe scene
- do not treat that as a verification-status upgrade

### 3. Whether to reuse the exact UI-kit panel content in the provider repo

Risk:

- copying the real proof panel into the touch repo would blur ownership

Recommendation:

- the touch repo owns only a generic provider fixture scene
- `aerobeat-ui-kit-community` owns the real hybrid proof panel and manual probe composition

### 4. Multi-pointer pressure

Risk:

- adding multi-touch ownership checks here could widen scope and delay the usable manual packet

Recommendation:

- keep the first manual packet single-pointer focused (`touch_0`) and defer multi-touch isolation to a later slice

## Files inspected for this packet

- `docs/phase-1-boundary-freeze.md`
- `docs/phase-2-first-touch-provider-extraction.md`
- `README.md`
- `src/providers/touch/aero_spatial_ui_touch_provider.gd`
- `src/providers/touch/aero_spatial_ui_touch_runtime_boundary.gd`
- `.testbed/tests/support/touch_provider_test_harness.gd`
- `.testbed/tests/test_touch_provider_dependency_boundary.gd`
- `.testbed/tests/test_touch_provider_runtime_state.gd`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core/docs/ui-interaction-contract-v1.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/docs/notes/2026-05-23-phase-5-touch-provider-readiness.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/docs/notes/2026-05-23-phase-5-touch-provider-first-extraction-packet.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/docs/notes/2026-05-23-phase-5-touch-provider-parity-test-packet.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/scripts/glass_shader_gui_3d_test.gd`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/tests/test_hybrid_touch_release_path.gd`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/tests/test_hybrid_touch_provider_parity.gd`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/tests/test_hybrid_packaged_touch_provider_flow.gd`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/qa_probes/desktop_truth_hover_probe.gd`
