# AeroBeat Spatial UI Touch

`aerobeat-spatial-ui-touch` is the AeroBeat repo for the **touch-driven spatial UI provider** lane.

This package now owns the first truthful extracted slice of reusable touch lifecycle/runtime behavior for projected spatial UI surfaces. The repo keeps touch pointer continuity, off-surface release continuation, cancel policy, and provider runtime diagnostics local to this package while leaving proof-host world-hit acquisition and proof-scene composition outside the repo.

## Current status

This repository now contains:

- concrete touch provider runtime behavior under `src/providers/touch/`
- boundary docs that freeze repo ownership for touch lifecycle/runtime semantics only
- package/runtime manifests that pin dependency and non-goal truth
- provider-local semantic tests for press/release, drag ordering, cancel handling, runtime state, and dependency boundaries
- a `.testbed/` workbench manifest that points at the canonical contract and shared helper owners

The current implementation is intentionally narrow:

- **included now:** touch lifecycle/runtime semantics, owner continuity, off-surface release continuation, canceled-touch publication, provider runtime diagnostics, a provider-owned human verification harness, and packaged shared-helper composition
- **still intentionally excluded:** world-hit acquisition, proof-host composition/debug UI, canonical contract ownership, and shared helper ownership changes

## Planned responsibility boundary

`aerobeat-spatial-ui-touch` owns reusable touch-specific spatial UI provider behavior such as:

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

- **Type:** Spatial UI provider package
- **License:** Mozilla Public License 2.0 (MPL 2.0)
- **Dependency truth:**
  - `aerobeat-input-core` owns the canonical UI interaction contract
  - `aerobeat-spatial-ui-core` owns shared spatial-provider helper scaffolding
  - `gut` drives repo-local validation

## Runtime files

The concrete provider surface lives under:

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

This bootstrap step now restores both:

- external dependencies (`aerobeat-input-core`, `aerobeat-spatial-ui-core`, `gut`)
- this repo's own package mount under `res://addons/aerobeat-spatial-ui-touch/` via the local-root GodotEnv symlink entry in `.testbed/addons.jsonc`

If you want the canonical workspace refresh path instead of calling `godotenv` directly, run:

```bash
/home/derrick/.openclaw/workspace/scripts/godotenv-sync --repo /home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-touch/.testbed
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

## Provider-owned human verification harness

The repo-local human harness lives at:

- `.testbed/scenes/touch_provider_verification_harness.tscn`
- `.testbed/scripts/touch_provider_verification_harness.gd`

It is intentionally provider-owned and limited in scope. The harness proves that this repo's packaged touch provider runtime is the seam in use, that it publishes through the canonical Aero input contract path, and that it reports truthful provider-owned runtime state such as active owner/live target continuity and last release ownership.

What it does **not** own:

- world-hit acquisition
- hybrid proof-scene composition
- downstream integration proof
- contract-definition or verification-status policy ownership

To inspect it manually from the repo root:

```bash
godot --editor --path .testbed
```

Then open `res://scenes/touch_provider_verification_harness.tscn` in the hidden testbed project.

## Validation notes

- `.testbed/addons.jsonc` is the committed dev/test dependency manifest, including the repo's own local-root self-mount entry for `aerobeat-spatial-ui-touch`.
- `docs/phase-1-boundary-freeze.md` records the ownership line.
- `docs/phase-2-first-touch-provider-extraction.md` records the extracted slice and parity truth.
- `docs/phase-3-touch-provider-manual-verification-packet.md` records the provider-harness packet and downstream boundary.
- Provider-local tests pin semantic goals such as press/release continuity, drag ordering, cancel handling, runtime state, dependency truth, and the provider-owned verification harness HUD/readout.
- `source_variant == "screen_touch"`, `surface_type == "hybrid_3d_gui"`, and `verification_status == "unverified"` remain required runtime truth.
- Consumer proof in `aerobeat-ui-kit-community` remains mandatory downstream.
- To catch installed-addon path regressions, refresh the hidden testbed from the manifest, verify `.testbed/addons/aerobeat-spatial-ui-touch/` exists, then run the installed-addon smoke script so the packaged provider path is exercised end-to-end.
