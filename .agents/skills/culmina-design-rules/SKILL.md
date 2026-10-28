---
name: culmina-design-rules
description: Preserve code-backed Culmina product, time, scientific-data and persistence meaning during a focused design task or review.
---

# Culmina product and data rules

Use when a UI task affects product meaning, scientific inputs, missing data or persistence. Start from [AGENTS](../../../AGENTS.md), the affected screen/ViewModel and domain service; current code supplies behavior, while the user supplies task scope.

- Culmina plans astrophotography and records outcomes; it does not control cameras or mounts. Preserve that boundary and avoid invented quality scores.
- Trace nightly calculations through `lib/domain/services/` and time models through `lib/domain/models/`. Keep UTC instants separate from civil evening dates and site-zone/DST presentation. A placeholder location is not a chosen observing site.
- Unknown is not zero. Retain units, source/freshness and theoretical versus empirical storage meaning. Relative stacking gain is not absolute SNR; AF/MF describes focusing and supplies no numeric focus measurement.
- Preserve Capture Plan assumptions, calibration policies, exposure/filter groups and fit reasons. Follow actual camera-class validation rather than hiding inconvenient inputs.
- Fit, working draft, explicitly saved plan and recorded result are distinct. Trace state through `lib/presentation/viewmodels/` and actual confirmation/caller behavior; keep Save/Discard/Cancel and failure recovery.
- Core planning, catalog and local records must remain usable offline. Preserve cache timestamps and missing/stale weather distinctions. Label illustrative fixtures as examples.
- Support Light, Dark and Field Red using `lib/core/theme/` and the field filter in `lib/main.dart`. Inspect pairing/readability in the intended theme; source colors alone do not establish accessibility acceptance.

Use `design/reference/atlas/` only as historical visual evidence and identify its captured state. It supplies neither current implementation requirements nor approval for a new direction. The `design/reference/` website documents the system with browser specimens; these do not establish native behavior.

Report the affected invariant, owning source/caller, change or review finding, checks and remaining limits. Keep unrelated findings separate from the requested implementation.
