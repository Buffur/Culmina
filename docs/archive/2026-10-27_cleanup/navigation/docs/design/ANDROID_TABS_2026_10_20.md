> **Historical navigation copy — not active instructions.** Link destinations are rebased from `docs/design/ANDROID_TABS_2026_10_20.md`. Content and acceptance statements retain their original date/scope. [Immutable original](../../../docs/design/ANDROID_TABS_2026_10_20.md) · [Navigation index](../../../NAVIGATION.md). Original SHA-256: `89c156ee6d0168b85e530b5fb7daf861a17ce8d3968705cd66c001db756a9168`.

# Android prototype: compact Weather and the remaining tabs

Owner request, 2026-10-20: keep Weather as a widget on Home, replace its cloud headline with a useful compact summary, soften the sky gradient and try colours; begin Logbook, Library and Settings while preserving the existing product's functions. This extends the established Hybrid Notion + Journal browser prototype. It does not adopt a Flutter design or launch a native roadmap task.

## Presentation and entry points

- **Weather** is one tappable row: eligible dark-time temperature range and maximum wind, followed by a short example/status line. Cloud extrema, rain, gusts, dew and coverage remain on Weather. Unavailable is never zero; missing cloud does not discard known temperature. There is no observing score.
- **Sky rail** interpolates smoothly in Oklab between muted colour knots, with eased intermediate stops. Dusk is the initial experiment; Slate and Ink are selectable outside the phone. The exact dark bracket, Moon lanes, five-minute cursor and fixed 24-hour UTC night are unchanged. Colour is presentation, not measured brightness. Field mode remains red/black in all three selections.
- **Navigation**: Home's Logbook/Library/Settings buttons open `workspace.html?tab=logbook|library|settings`. The workspace keeps a 412 px Android phone, independently scrolling content, app-bar Back and root bottom navigation. Browser Back invokes the current detail/editor's Back and retains its discard guard; actual Android gestures/IME/TalkBack remain unverified.
- **Result entry**: Home's labelled M33 example opens the actual Logbook result editor. Saving it removes that example's outstanding-result row on returning Home. It replaces the previous nonpersistent M42 dialog; it does not claim an actual production reminder.

## Functional slice and source boundary

| Destination | Interactive behaviour | Functional reference |
| --- | --- | --- |
| Logbook | Upcoming/Past, stable search, state/target/site/night filters, immutable saved-plan detail, Completed/Partly/Not done, frame validation, notes, Save/Cancel, delete/Undo, recorded integration by target and compatible groups | `lib/presentation/screens/logbook/`, `lib/presentation/screens/execution/results_screen.dart`, `sessions_viewmodel.dart`, `target_progress.dart` |
| Library | Rigs/Targets/Sites, search, record details, inline Add/Edit, camera-class and sensor/optics fields, J2000 RA/Dec, coordinate/zone validation, delete/Undo; six real catalogue objects read-only | `lib/presentation/screens/library/`, `screens/equipment/`, `screens/target/`, `screens/sites/`, their shared input validators and `assets/catalog/catalog_v2.json` |
| Settings | Appearance/System/field/text/units, explicit planning Save/Cancel, existing gates and optional timing assumptions, local privacy preference, actual preview-settings JSON download and checked/confirmed restore, About/data attribution | `lib/presentation/screens/settings/`, `lib/domain/models/planning_preferences.dart`, `lib/core/units/display_units.dart`, `screens/about/` |

Each module has a separate `culmina-{logbook|library|settings}-preview-v1` key. Corrupt data is reported and preserved; replacement needs an explicit action. Failed saves preserve edits and offer Retry. Library management never changes an active plan or historical snapshot. Result edits change the result only. Settings never recalculate or rewrite the Plan preview. The owner's `127.0.0.1` checkpoint was not used for automated mutations: checks used a fresh `localhost` browser profile.

This is a useful first prototype of the three destinations, not a claim of complete native parity. Production session sharing/export, device metadata import, GPS/maps, real weather, whole-database `.astroplan` backup/restore and runtime scientific calculations remain production functions; this browser does not pretend to execute them. Optional rig values remain unknown rather than inferred. Snapshot optics explicitly labelled illustrative are fixtures, not measurements. Preview-settings JSON is explicitly not an app backup. Screen-specific limits and sources are in the module evidence below.

## Implementation and evidence

- Shared shell: `design/home-lab/workspace.{html,js,css}`; module pairs `logbook`, `library`, `settings`.
- [Integrated verification and CLI dispositions](../../../../../../design/home-lab/evidence/TABS_PREVIEW.md).
- Module reports: [Logbook](../../../../../../design/home-lab/evidence/TABS_LOGBOOK.md), [Library](../../../../../../design/home-lab/evidence/TABS_LIBRARY.md), [Settings](../../../../../../design/home-lab/evidence/TABS_SETTINGS.md).
- Source and colour research from [WORKFLOW](../../../../../design/WORKFLOW.md) and the earlier [quality refinement](QUALITY_REFINEMENT_2026_10_20.md) remain preserved. This owner amendment supersedes only expanded Home Weather and the previous sky-palette treatment.

Preview server: `python design/home-lab/scripts/serve_preview.py --port 4173`; it serves the lab on loopback with `Cache-Control: no-store`. Current entrypoints and relative module imports use `20261020-tabs2`.
