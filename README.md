# Culmina (AstroPlan)

Culmina (earlier builds: Astro Planner) is an Android-focused Flutter/Dart application for planning
astrophotography sessions. It helps you choose a target, night, site and rig,
build a realistic capture plan, and understand whether it fits the available
imaging opportunity.

Core planning works offline. Weather and location services enrich the plan,
while calculations, assumptions, units and data provenance remain visible.

## Current status

Culmina is in post-roadmap refinement toward its first GitHub release; release readiness is not
claimed. The current Stage, blockers, device checks, owner actions and the next allowed action are
kept only in [Refinement Progress](docs/refinement/PROGRESS.md), so this README does not repeat them.

## What the application includes

- **Planning:** a fit-first planner, night selection with time-zone handling,
  target visibility, darkness, Moon and imaging-opportunity calculations,
  plus weather freshness and missing-data states.
- **Targets:** an offline catalog of 164 objects from OpenNGC, designation and
  common-name search with aliases, and custom targets.
- **Sites and rigs:** saved sites, explicit GPS/map selection, optional elevation
  and manual Bortle/SQM; camera types, equipment specifications and a per-plan
  tracking override that preserves the rig's default.
- **Capture plans:** light, dark, flat, bias and dark-flat blocks; contextual
  ISO/gain and binning fields; calibration inheritance and mismatch warnings;
  overheads, calibration policies and applicable in-camera noise reduction in
  the budget and fit.
- **Metadata-assisted rig entry:** "Add from a photo" for supported DNG, JPEG
  and HEIC files, with provenance, review and confirmation before saving.
- **Supporting workflows:** saved-plan snapshots, the existing execution/results
  workflow, Logbook, portable session export, and local backup/restore.
- **Presentation:** light, dark and red field themes, progressive disclosure,
  and automated accessibility/layout checks.

The approved product direction is:

```text
Site / Rig / Target → Night & Opportunity → Capture Plan → Fit → Save
                                                               ↓
                                              Image outside the app → Result / Logbook
```

The dedicated live tracker's UI was retired in Stage 8 (S8.4); its existing records stay
readable. See [Product Direction](docs/refinement/PRODUCT_DIRECTION.md).

Scientific outputs keep their limits explicit: unknown values remain unknown,
thresholds are preferences, and √N describes relative stacking gain rather than
absolute physical SNR. The product has no composite sky score, planetarium,
sky-navigation or camera/mount-control scope.

## Development

The repository's CI configuration pins **Flutter 3.47.4**;
[pubspec.yaml](pubspec.yaml) requires **Dart ^3.13.3**. Use the Android toolchain
and a connected Android device or emulator to run the application. iOS is deferred.

```sh
flutter pub get
flutter devices
flutter run -d <device-id>
```

The application uses Provider with screen-scoped ViewModels, `go_router`, and
SQLite through Drift (**schema v25**; see [the data model](docs/DATA_MODEL.md)). Presentation, domain logic and data access
are separated; astronomy calculations remain independent of Flutter UI code.

Run the full quality gate with:

```sh
dart run tool/check.dart
```

It checks encoding, formatting, static analysis, unit/widget tests and host E2E.
Device validation and opt-in real metadata samples are separate evidence; a host
pass does not substitute for them. Current results and their limitations live in
[Refinement Progress](docs/refinement/PROGRESS.md). Verification requirements and
evidence-reuse rules are defined in [CLAUDE.md](CLAUDE.md).

For Android signing, bundles and release checks, follow
[RELEASE.md](docs/RELEASE.md).

## Documentation

The [documentation map](docs/README.md) says what to read first and where each kind of fact
lives. Start with the active refinement sources:

- [Progress](docs/refinement/PROGRESS.md) — current stage, blockers, validation
  evidence and next allowed action.
- [Final completion roadmap](docs/refinement/FINAL_COMPLETION_ROADMAP.md) — the approved
  execution queue to the first release (owner, 2026-10-18): Tasks F01–F26 and gates G1–G4.
- [Post-roadmap plan](docs/refinement/POST_ROADMAP_PLAN.md) — the research/owner-decision
  registers, workflow rules and the earlier Stages 12–17, now the roadmap's aliases.
- [Product direction](docs/refinement/PRODUCT_DIRECTION.md) — planning-first
  workflow and product constraints.

Supporting references:

- [Feature status](docs/FEATURE_STATUS.md), [architecture](docs/ARCHITECTURE.md)
  and [data model](docs/DATA_MODEL.md).
- [Decisions](docs/DECISIONS.md), [scientific integrity](docs/SCIENTIFIC_INTEGRITY.md)
  and [technical debt](docs/TECH_DEBT.md).
- [Design system](docs/DESIGN_SYSTEM.md) and [test plan](docs/TEST_PLAN.md).
- [Privacy policy](docs/privacy/index.md), [compliance](docs/COMPLIANCE.md),
  [license](LICENSE) and [catalog attribution](assets/catalog/OPENNGC_NOTICE.txt).

**License exception.** The app is GPL-3.0. Its Android build includes Google Play services
location (through `geolocator`), so the licensors add:

> Additional permission under GNU GPL version 3 section 7: if you modify this program, or any
> covered work, by linking or combining it with the Google Play services libraries (or a modified
> version of those libraries), containing parts covered by the terms of the Android Software
> Development Kit License, the licensors of this program grant you additional permission to convey
> the resulting work.

Earlier roadmaps and audits are historical evidence, not the active task queue.
Agent guidance is in [CLAUDE.md](CLAUDE.md), with supporting rules and skills in
`.agents/`.
