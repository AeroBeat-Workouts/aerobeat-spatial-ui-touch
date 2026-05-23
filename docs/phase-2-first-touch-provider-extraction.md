# Phase 2 First Touch Provider Extraction

**Status:** Implemented for slice 1

This document records the first truthful extracted slice of touch-provider behavior now owned by `aerobeat-spatial-ui-touch`.

## Extracted scope now owned here

The implemented slice moves reusable touch lifecycle/runtime semantics out of the proof host, including:

- active touch pointer state
- press owner continuity across drag/release
- drag lifecycle publication ordering through `HybridSubViewportInputAdapter`
- off-surface release continuation using prior projected data
- explicit canceled-touch publication policy
- provider-readable runtime diagnostics for touch semantics
- provider-owned projected-data / target-resolution helper entrypoints that consumer probes can delegate through without re-owning the seam locally

## Explicit non-goals preserved

This first extraction still does **not** move:

- camera/world ray acquisition
- physics hit acquisition setup
- `PanelInputSurface` scene assumptions
- proof-scene composition/debug UI
- canonical contract semantics owned by `aerobeat-input-core`
- shared projection/resolver/helper ownership already assigned to `aerobeat-spatial-ui-core`

## Semantic packet proved by slice 1

The current implementation/tests prove at minimum:

- `press_end.target_path` remains the original press owner
- hover truth and press/drag owner truth remain separate
- `drag_end` publishes before `press_end`
- ordinary release-outside remains `press_end`, not `cancel`, when continuity exists
- explicit canceled touch publishes `cancel`
- off-surface press without a live target does not publish
- `pointer_id` policy is stable for `touch_<index>`
- `source_variant == "screen_touch"`
- `surface_type == "hybrid_3d_gui"`
- `verification_status == "unverified"`

## Runtime boundary summary

The provider package now owns touch lifecycle/runtime semantics only. It composes through the existing owners instead of reclaiming their responsibilities:

- `aerobeat-input-core` continues to own canonical contract/event semantics and `HybridSubViewportInputAdapter`
- `aerobeat-spatial-ui-core` continues to own shared projected-data shaping and rect-target resolution helpers
- `aerobeat-ui-kit-community` remains the owner of world-hit acquisition, proof-scene composition, and downstream installed-addon verification
