---
name: culmina-design-components
description: Choose and compose existing Culmina form, navigation and data-display components. Use for screen composition, component reuse or component documentation.
---

# Culmina components

Read `docs/design/WORKFLOW.md`, then only the group needed below. Component contracts live in `docs/DESIGN_SYSTEM.md` sections 6–7a and in their actual Flutter implementations.

## Form elements

For exact APIs, choice semantics and confirmation outcomes, read [form contracts](references/forms.md) when this category is involved.

- Theme-backed fields and buttons: `lib/core/theme/app_theme.dart`, `app_button_styles.dart`.
- Coordinates and domain inputs: `lib/presentation/shared/coordinate_input.dart`, `site_form_input.dart`, `target_form_input.dart`, `rig_input_text.dart`.
- Editing and confirmation: `unsaved_plan_prompt.dart`, `confirmation_patterns.dart`, `delete_patterns.dart`.
- One primary action per decision context. Keep Save/Discard/Cancel distinctions and dirty drafts. Do not replace a task with an interrupting dialog merely to simplify layout.
- Choose by selection semantics: radio/segments for one of a few short mutually exclusive options; a select/searchable picker for a larger or long-label single choice; checkboxes for independent multiple choices; a switch for an immediately applied binary setting. Option count alone never turns single choice into multiple choice.

## Navigation

For slots, callbacks and absent-site behavior, read [navigation contracts](references/navigation.md) when this category is involved.

- `lib/presentation/navigation/app_shell.dart`: Tonight, Logbook, Library, Settings.
- `detail_scaffold.dart`: the existing detail template.
- `context_line.dart`, `site_label.dart`, `plan_night_phrase.dart`: place and selected-night context.
- Keep the tab named Tonight. The page title follows the selected plan night under AM03-T.
- Preserve navigation state and Back behavior. A browser concept may demonstrate destination details locally; label simulated screens and do not claim production routing exists.

## Data display

For status/state inputs, controlled disclosure and scientific display variants, read [display contracts](references/data-display.md) when this category is involved.

- `status_block.dart`: fit word, reason, required time and usable time.
- `plan_state.dart`, `change_mark.dart`: saved/draft state and changes.
- `collapsible_section.dart`, `section_header.dart`, `info_row.dart`: progressive disclosure and grouping.
- `night_text.dart`, `night_time_formatter.dart`, `opportunity_text.dart` and `lib/core/utils/quantity_text.dart`: units and time semantics.
- `lib/presentation/widgets/altitude_chart_widget.dart`, `capture_plan/stacking_gain_graph.dart`: existing science-backed graphics. Do not recreate a new scoring system for a visual concept.
- Tonight source: `lib/presentation/screens/tonight/tonight_home_screen.dart`. Read its current child order and conditional states, not only historical comments.

## Composition and documentation

Current production Home groups: context → night's conditions → due result when present → current plan and its action → candidates. The current owner brief targets an Android phone: one content column, a top app bar, compact navigation and reachable primary actions. The browser canvas may widen; the phone composition must remain a phone. Preserve the approved visual direction rather than copying the incumbent application appearance.

The owner's 2026-10-19 browser review adds a reversible plan-first/conditions-first comparison and a separate Plan page. Plan-first is the lab's recommendation for returning to an existing plan; it is not a silent Flutter adoption. Plan editing follows the actual planner's fit/context/target/rig/blocks/estimates/Details/Save contracts. Read `docs/design/PLAN_CONCEPT_REVIEW_2026_10_19.md` for source links and the prototype boundary.

Inspect loading, no-site, missing target/equipment, unavailable weather, saved/changed and error states relevant to the surface. Unknown is never zero.

The local browser catalogue (`design/home-lab/`, Design code → Components) includes working button states, fields, radio/checkbox/switch, fit and saved-state labels, a collapsible section and ContextLine analogues. The full ten documented component contracts are included there. They are HTML analogues; check real Flutter widgets before claiming production acceptance.

When changing a shared contract, document: purpose; anatomy; variants; states; inputs; interaction; accessibility; when not to use; real adopter and check. Update the canonical component section rather than starting another component catalogue.
