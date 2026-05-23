# Phase 1 Boundary Freeze

This repo is now frozen as the **touch-driven spatial UI provider bootstrap lane** in the AeroBeat spatial UI family.

## What this repo owns

`aerobeat-spatial-ui-touch` is the home of the future concrete provider layer for touch interaction on projected/world-space UI surfaces.

That touch provider lane is expected to own:

- touch pointer lifecycle/runtime state for spatial UI hosts
- touch press ownership, drag ownership, and release continuity for projected spatial surfaces
- off-surface continuation using prior projected state when continuity exists
- explicit canceled-touch publication policy
- provider-readable runtime diagnostics for touch semantics

## What this repo does **not** own

This Phase 1 bootstrap explicitly prevents the repo from drifting into other ownership lanes.

It does **not** own:

- the canonical interaction contract
- event taxonomy, event classes, or the interaction bus
- the native 2D bridge path
- shared cross-provider spatial helper ownership
- proof-host camera ray creation or world-hit acquisition from `aerobeat-ui-kit-community`
- scene-specific proof-host composition from `aerobeat-ui-kit-community`

## Dependency truth

This repo sits on top of:

- `aerobeat-input-core` — canonical contract owner
- `aerobeat-spatial-ui-core` — shared helper-layer owner

Those dependencies are represented in `.testbed/addons.jsonc`, while the runtime provider files under `src/providers/touch/` establish the concrete touch-lane boundary.

## Phase progression

- **Phase 1:** boundary freeze and truthful bootstrap scaffolding
- **Phase 2:** first real extracted touch-provider slice

The Phase 2 extraction plan lives in `docs/phase-2-first-touch-provider-extraction.md`. That future extraction should move reusable touch lifecycle/runtime semantics only, while keeping world-hit acquisition, proof-scene composition, and canonical contract ownership outside this repo.
