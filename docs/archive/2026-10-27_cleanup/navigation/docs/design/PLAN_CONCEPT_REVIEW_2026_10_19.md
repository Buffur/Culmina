> **Historical navigation copy — not active instructions.** Link destinations are rebased from `docs/design/PLAN_CONCEPT_REVIEW_2026_10_19.md`. Content and acceptance statements retain their original date/scope. [Immutable original](../../../docs/design/PLAN_CONCEPT_REVIEW_2026_10_19.md) · [Navigation index](../../../NAVIGATION.md). Original SHA-256: `fd59d5d1f157158ae18585bda64a9e4cb2e7a8b30f286c68bb6b1f3da99c13a7`.

# Hybrid Home and Plan review — 2026-10-19

Owner request: assess the main Hybrid using the additional official design-system sources, remove the unwanted outline/shadow from Your plan, create a Plan page grounded in the project, and evaluate plan before weather. Scope remains the local browser design lab. No Flutter screen, calculation, database, dependency or release criterion was changed.

## Source-backed assessment

The original UI Collective guidance, Notion/Journal direction and [earlier product research](../../../../../design/REFERENCE_RESEARCH.md) remain relevant. These official sources add rationale; they do not replace those references or select a platform's entire visual language.

| Official source actually retrieved | Documented guidance, paraphrased | Interpretation for this concept |
| --- | --- | --- |
| [Apple HIG: Layout](https://developer.apple.com/design/human-interface-guidelines/layout) | Put important content early in reading order; group related content with spacing, shapes or separators; adapt to text size | A returning user's existing plan and next action deserve an early position. Preserve meaningful DOM order and reflow at 200% text |
| [Apple HIG: Disclosure controls](https://developer.apple.com/design/human-interface-guidelines/disclosure-controls) | Keep frequently needed controls visible and reveal relevant secondary detail progressively; descriptive labels explain disclosure | Exposure/count and applicable camera records stay easy to reach. Detailed budgets, rig specifications and assumptions remain one disclosure away |
| [Fluent 2: Layout](https://fluent2.microsoft.design/layout) | Proximity and whitespace can communicate groups without added lines or graphics | Remove the plan's decorative edge and let heading, spacing, target and the primary action define the group |
| [Fluent 2: Card](https://fluent2.microsoft.design/components/web/react/core/card/usage) | Cards group one object and its related actions; use consistent patterns; a whole-card action is one possible behavior | A card is optional here. Keep explicit actions and avoid turning the entire plan summary into a competing clickable target |
| [Spectrum: Attention hierarchy](https://spectrum.adobe.com/foundations/attention-hierarchy) | Emphasis should be selective; competing high-attention objects reduce clarity | Let the current plan/Open planner lead on Home and Save plan lead in the editor. Keep weather and technical depth quieter |
| [Spectrum: Containers](https://spectrum.adobe.com/foundations/layout-and-structure/containers) | Spacing is the least emphatic way to separate concepts; fills, borders and shadows have distinct purposes | Use an open plan section, without a border, shadow or tinted card. Preserve functional input boundaries and keyboard focus cues |

Apple's platform-specific Liquid Glass and macOS disclosure-button conventions are not general requirements for this cross-platform preview. Fluent and Spectrum do not ban cards or shadows globally. The open grouping here also follows the owner's explicit preference.

Tools: Context7 resolved and queried the official Apple HIG and Fluent 2 documentation; Firecrawl mapped all three official sites before retrieving the six focused pages above. Spectrum's official design site was not resolved by Context7 after two relevant queries; unrelated messaging SDK results and implementation repositories were not substituted for it. The official Spectrum pages were retrieved directly through Firecrawl. [Source retrieval index](../../../../../../design/home-lab/evidence/plan-source-index.json) records the successful URLs/statuses. This is a focused review, not an exhaustive three-system knowledge base.

## Recommendation: plan before conditions

For a returning user with a saved plan, recommend **selected context → current plan and action → night's conditions → any due result → candidates**. That makes the task visible before supporting evidence. On wide layouts the plan occupies the leading column and conditions the secondary column; DOM order remains plan-first.

For an empty plan or missing site, the immediate job changes: help choose the context/target/rig, keep the missing-input reason explicit and leave relevant conditions reachable. Do not claim a positive fit from missing input. A past result can also deserve attention, but it remains a separate secondary task in this proposal.

This priority is our task-based synthesis, not a rule in any source that “plans always precede weather”. The browser control **Plan → conditions / Conditions → plan** makes both arrangements reviewable. Current Flutter Tonight still renders `_NightCard`, `_ResultDue`, then `_PlanCard`; no production order or F17 criterion was amended.

Further useful refinements, if selected later: keep Home as a compact summary, use the same target/night wording on every destination, and review the chosen composition with actual native fonts and widget states before production adoption. No additional product feature or global redesign follows from this review.

## What caused the unwanted edge

Before this change, the main Hybrid's `.plan-section` had a top border from the Journal-derived rule and a 6 px radius from the shared proposal-radius consumer. Computed browser inspection showed a rounded top border and `box-shadow: none`. It was not a shadow on the section.

All four Hybrid plan summaries now have no border, radius, shadow, outline or contrasting container fill. Grouping uses existing spacing and typography. This applies only to the section; keyboard focus indicators and functional control borders remain intact. Soft's conditions group can still use its proposed radius.

## Plan page: project mapping

The separate [Plan preview](../../../../../../design/home-lab/plan.html) opens from each Home concept's Open planner action, carrying its variant, theme, font, text scale, selected site/night and target.

| Existing project contract | Browser translation |
| --- | --- |
| `lib/presentation/screens/home/home_screen.dart`, PlanStatus and StatusBlock | Answer first: fit word, reason and needed/usable relationship. Unknown/missing inputs remain neutral |
| ContextLine and PlanNightPhrase | Site and civil evening selection; one site-zone caption; no night selector without a site. Different selected dates stay explicitly selected-night examples |
| Target/rig summaries and camera-class contracts | Target and rig are separate inputs. Rig type selects ISO versus gain; no per-block technical ISO/gain switch. Unknown class does not infer a camera from the running platform |
| `capture_plan_widget.dart`, `capture_block_dialog.dart` | Add/edit/remove planned Light/Dark/Flat/Bias blocks; exposure supports decimal and fractional seconds; frame count, filter, applicable ISO/gain and WB remain explicit. Optional AF/MF/tint and astro binning are in Details. Block Add/Apply differs from Save plan |
| CaptureBudgetSummary, PlannerSections | Visible integration, window time needed, total time, estimated storage and ideal relative stacking gain. Budget breakdown, rig specifications and assumptions remain behind factual disclosure summaries |
| PlanStateLabel and save/error behavior | Saved and Saved · changed differ from fit. Save plan stays visible; missing input or an active block edit has a reason. Failed save preserves latest edits and offers retry |
| UnsavedChoice and in-plan Undo | Back offers Save/Discard/Cancel when edits would be lost. Block removal offers Undo; unrelated edits and Save invalidate that preview Undo rather than restoring an old whole-plan snapshot |

The page is HTML, not a Flutter implementation. Its calculations are limited, labelled fixture arithmetic: planned frame durations, explicit per-frame/setup overheads, explicit file size and ideal √N for comparable light groups. Known exposure/filter/sensitivity/binning identify groups; unrecorded sensitivity never merges blocks as if it were a measured zero. No astronomical window, forecast, weather gate, calibration-library compatibility, acquired count, sensor physics or absolute SNR is calculated. These limitations and assumptions are visible in the preview.

Save writes only the lab's dedicated `culmina-plan-preview-v1` localStorage entry. Reload restores it; returning to Home shows that saved example's target/rig and estimated time. Draft changes require Apply and Save; failed saves retain them. The gallery Reset clears only the lab's own sample/preferences. No application database or user equipment catalogue is accessed.

## Verification

See [Plan and Home verification](../../../../../../design/home-lab/evidence/PLAN_PREVIEW.md) for exact commands, current browser evidence, captures and limitations. The review does not claim native acceptance, device testing or production scientific equivalence.

## Android format correction

The owner rejected the desktop/web composition. Their functional-reference brief clarifies that existing functions and workflows must inform the approved design, without copying the incumbent app's appearance. This supersedes the earlier desktop Plan layout. The restrained Hybrid base, Journal night heading, plan-first comparison and borderless Your plan remain.

- Preview host: browser. Design target: compact Android phone. The maximum 412 CSS-pixel viewport is a preview convention, not an Android density conversion or a tablet acceptance claim.
- App structure: Android status/gesture-bar mock, top app bar with Back and field mode, independently scrolling single-column content, persistent Save. Lab theme, scale and fixture controls sit outside the app.
- Block editing: a dedicated phone screen with top Cancel, one-column fields and bottom Apply. Apply still updates the draft; Save records the entire sample. Existing validation, optional records, dirty prompt, Undo and failed-save retry remain.
- Home: single-screen mode no longer becomes a desktop sidebar/two-column dashboard. Its four destinations remain in the bottom navigation, with scrolling content above them.
- The production planner was checked for AppBar, PlanStatus and bottom Save contracts in `lib/presentation/screens/home/home_screen.dart`. It remains the functional reference. No Flutter source was changed.

Research: Context7 resolved the official Android Developers collection, but its two focused layout queries returned mostly unrelated API snippets, insufficient for layout decisions. Firecrawl then retrieved [Android Layout basics](https://developer.android.com/design/ui/mobile/guides/layout-and-content/layout-basics), HTTP 200, page updated 2026-10-05: respect safe areas and keyboards, keep key actions reachable, align related elements, limit competing actions and consider orientation/form factors. These are paraphrases; the particular phone preview layout is our implementation decision. This supplements the video, Notion/Google, Apple HIG, Fluent 2 and Spectrum sources.

[Android verification](../../../../../../design/home-lab/evidence/ANDROID_PREVIEW.md) supersedes desktop layout acceptance in the earlier Plan record. HTML fields approximate the visual treatment; native Material pickers, predictive Back, actual system/IME insets and Flutter font scaling still require emulator/device implementation and checks.
