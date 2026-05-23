# AeroBeat Spatial UI Touch

`aerobeat-spatial-ui-touch` is the AeroBeat repo for the **touch-driven spatial UI provider** lane.

This package is the dedicated bootstrap repo for reusable touch lifecycle/runtime behavior on projected spatial UI surfaces. It is intentionally still in the bootstrap phase: the repo now owns the touch-lane package boundary, docs, manifests, and test scaffolding, but it does **not** yet claim that the extracted touch provider implementation has landed.

## Current status

This repository now contains:

- explicit touch-lane package scaffolding under `src/providers/touch/`
- boundary docs that freeze repo ownership for touch lifecycle/runtime work only
- inert manifest/runtime/config guardrails that pin dependency and non-goal truth
- test scaffolding that names the required touch semantic slices up front
- a `.testbed/` workbench manifest that points at the canonical contract and shared helper owners

The current bootstrap is intentionally narrow:

- **included now:** package identity, dependency truth, runtime-boundary placeholders, manifest metadata, and named semantic test scaffolding
- **deferred on purpose:** real touch lifecycle/provider behavior, world-hit acquisition, proof-host composition, and any contract/helper ownership changes

## Planned responsibility boundary

`aerobeat-spatial-ui-touch` is intended to own reusable touch-specific spatial UI provider behavior such as:

- touch pointer runtime state for projected spatial surfaces
- press/drag/release owner continuity for touch input
- off-surface continuation using prior projected state when continuity exists
- canceled-touch publication policy
- provider-local runtime diagnostics for touch semantics

It is **not** intended to become:

- a second contract-definition repo
- the owner of the canonical interaction taxonomy or bus
- the home of the native 2D bridge path
- the owner of shared cross-provider spatial helpers
- the owner of proof-host camera ray/world-hit acquisition
- a proof-scene composition repo

## Repository details

- **Type:** Spatial UI provider bootstrap
- **License:** Mozilla Public License 2.0 (MPL 2.0)
- **Dependency truth:**
  - `aerobeat-input-core` owns the canonical UI interaction contract
  - `aerobeat-spatial-ui-core` owns shared spatial-provider helper scaffolding
  - `gut` drives repo-local validation

## Runtime files

The bootstrap provider surface lives under:

- `src/providers/touch/aero_spatial_ui_touch_provider.gd`
- `src/providers/touch/aero_spatial_ui_touch_provider_config.gd`
- `src/providers/touch/aero_spatial_ui_touch_runtime_boundary.gd`
- `src/providers/touch/aero_spatial_ui_touch_manifest.gd`

Key repo-local docs:

- `docs/phase-1-boundary-freeze.md`
- `docs/phase-2-first-touch-provider-extraction.md`

## GodotEnv development flow

This repo follows the AeroBeat GodotEnv package convention.

- Canonical dev/test manifest: `.testbed/addons.jsonc`
- Installed dev/test addons: `.testbed/addons/`
- GodotEnv cache: `.testbed/.addons/`
- Hidden workbench project: `.testbed/project.godot`
- Repo-local unit tests: `.testbed/tests/`

The repo root remains the package boundary for downstream consumers. Direct development, smoke checks, and unit validation happen from the hidden `.testbed/` workbench.

### Restore dev/test dependencies

From the repo root:

```bash
cd .testbed
godotenv addons install
```

### Open the workbench

From the repo root:

```bash
godot --editor --path .testbed
```

### Import smoke check

From the repo root:

```bash
godot --headless --path .testbed --import
```

### Run unit tests

From the repo root:

```bash
godot --headless --path .testbed --script addons/gut/gut_cmdln.gd \
  -gdir=res://tests \
  -ginclude_subdirs \
  -gexit
```

## Validation notes

- `.testbed/addons.jsonc` is the committed dev/test dependency manifest.
- `docs/phase-1-boundary-freeze.md` records the ownership line.
- `docs/phase-2-first-touch-provider-extraction.md` is currently a stub for the first real extraction slice.
- The named tests intentionally pin semantic goals such as press/release continuity, drag ordering, cancel handling, runtime state, and dependency truth before implementation starts.
- `source_variant == "screen_touch"`, `surface_type == "hybrid_3d_gui"`, and `verification_status == "unverified"` remain part of the expected future semantic packet.
- Consumer proof in `aerobeat-ui-kit-community` still remains mandatory after this bootstrap.
