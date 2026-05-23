# Phase 2 First Touch Provider Extraction

**Status:** Stub / not implemented yet

This document exists so the bootstrap repo already names the next truthful implementation seam.

## Intended extraction scope

The first real extraction slice should move only reusable touch lifecycle/runtime semantics out of the current proof host, including:

- active touch pointer state
- press owner continuity across drag/release
- drag lifecycle publication ordering
- off-surface release continuation using prior projected data
- explicit canceled-touch publication policy
- provider-readable runtime diagnostics for touch semantics

## Explicit non-goals for Phase 2

The first extraction should **not** move:

- camera/world ray acquisition
- physics hit acquisition setup
- `PanelInputSurface` scene assumptions
- proof-scene composition/debug UI
- canonical contract semantics owned by `aerobeat-input-core`
- shared projection/resolver/helper ownership already assigned to `aerobeat-spatial-ui-core`

## Semantic packet to prove when implementation lands

When the real extraction lands, the implementation/tests should prove at minimum:

- `press_end.target_path` remains the original press owner
- hover truth and press/drag owner truth remain separate
- `drag_end` publishes before `press_end`
- ordinary release-outside remains `press_end`, not `cancel`, when continuity exists
- explicit canceled touch publishes `cancel`
- `pointer_id` policy is stable for `touch_<index>`
- `source_variant == "screen_touch"`
- `surface_type == "hybrid_3d_gui"`
- `verification_status == "unverified"`
