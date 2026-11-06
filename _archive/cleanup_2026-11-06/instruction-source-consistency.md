# Design instruction and source correspondence

Read-only review of the current working tree, 2026-11-06. The theme and several shared components are locally modified; this records current source, not a released baseline or approval of those changes. No runtime or visual tests were run.

## Confirmed stale facts

1. `.agents/skills/culmina-design-spacing/SKILL.md:9` says `md=16`, `gutter=20`, `section=28`; `lib/core/theme/app_spacing.dart:13,39,42` defines 12, 24 and 32 respectively. Line 13 of the skill says small/menu/large radii are 6/8/12; `lib/core/theme/app_radius.dart:5,8,11` defines 8/12/20. These specific numbers conflict with the instruction to read actual definitions and could direct an agent to reintroduce obsolete geometry.
2. The same skill at line 10 and `.agents/skills/culmina-design-components/references/data-display.md:7` claim `DocumentSection` default padding is 16 dp. `lib/presentation/shared/document_section.dart:16` uses `AppSpacing.sm`, currently 8 dp (`app_spacing.dart:12`). Its 8 dp corner statement still agrees with `AppRadius.small` at present. Named `padding` can override the default; do not infer each caller's padding from it.
3. `.agents/skills/culmina-design-tokens/references/semantic-map.md:20,28` claims the weather view uses the selected-hour fill/text/rule tokens. Those three properties are defined in `lib/core/theme/hybrid_tokens.dart:61-67`, but a search of `lib/presentation/` found no callers of their names. The current view exposes selection through its chart controls and semantics (`lib/presentation/widgets/weather_hybrid_view.dart:802-812,852-875,903-927`). The map's precise caller assertion should not be treated as a live fact; this observation does not assess the design or accessibility of the current selection.

## Guidance consistent with inspected source

- The typography skill's Geist and named-role guidance is supported by `lib/core/theme/hybrid_tokens.dart:40`, `lib/core/theme/app_typography.dart:13`, `lib/core/theme/app_text_theme.dart:135-140`, and `lib/core/theme/app_theme.dart:273-288`; Source Serif 4 is declared at `pubspec.yaml:69`. A search found no `AppTypography.` references in `lib/presentation/`. This is a bounded source check, not a glyph, scaling or accessibility test.
- The tokens skill generally directs agents to inspect actual theme roles and callers instead of prescribing historic hex colors. `lib/core/theme/app_theme.dart:26,84,183,264-288` installs theme values and the field root filter is used in `lib/main.dart:364`. The semantic map remains useful only after checking the stale caller above.
- The components and rules skills primarily direct source/caller inspection, preserve unknown and scientific meaning, and separate host evidence from acceptance. No conflicting fixed color values were found in their SKILL.md files. The referenced component table's snapshot claims beyond the sampled rows were not comprehensively revalidated.

## Limits and implications

These findings identify source-document inconsistencies, not authorization to alter the product or instructions. A future instruction-maintenance task should reconcile the existing owners rather than create a duplicate rule; actual desired geometry and the status of the dirty UI work are not established here. Static source and text search do not establish Flutter rendering, behavioral equivalence, accessibility, or performance. This report did not assess the five skills against external agent guidance; that comparison is handled separately.

## Applied factual maintenance after the read-only review

The four current owners were reconciled against the inspected source: spacing SKILL, component data-display reference, semantic role map, and docs/DESIGN_SYSTEM.md. Exact pre-edit copies are recorded in instruction-followup-before-manifest.json. The first two now name the actual spacing/radius and constructor APIs rather than repeating numeric snapshots; the caller map no longer asserts selected-hour token adoption without a presentation caller. The implementation index now links palette owners and the installed AppTextTheme.afterDark/afterDarkScale resolver, which AppTheme currently installs for all three appearances; it no longer presents legacy palette/type/app-bar tables as current production values. No visual value, runtime code, configuration, test or scientific constraint was changed. Prior findings above describe the pre-maintenance text.
