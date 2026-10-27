> **Historical navigation copy — not active instructions.** Link destinations are rebased from `docs/design/NOTION_APPLE_STUDY_2026_10_19.md`. Content and acceptance statements retain their original date/scope. [Immutable original](../../../docs/design/NOTION_APPLE_STUDY_2026_10_19.md) · [Navigation index](../../../NAVIGATION.md). Original SHA-256: `17e481d6108bab241f0ffa132281e06037ff4cb38f765b4279d0fd23f2cec46d`.

# Notion / Apple and the Hybrid family — 2026-10-19

Owner brief: fix the video-guidance gaps, study Notion's current typography/design/elements and Apple design, then create variations of the preferred Hybrid Notion + Journal. This extends the local lab; it does not adopt a production redesign.

## Observed references

The public [Notion homepage](https://www.notion.com/) and [Apple homepage](https://www.apple.com/) were opened and visually inspected at a 1280 px browser width. Computed styles are recorded in [the observation JSON](../../../../../../design/home-lab/evidence/notion-apple-observations.json). These are dated browser observations, not official design-token specifications. A CSS font stack names candidates; it does not prove which face shaped every glyph on every platform.

| Surface | Typography observed | Elements and hierarchy observed | Culmina interpretation |
| --- | --- | --- | --- |
| Notion marketing site | `NotionInter, Inter, -apple-system, ...`; sampled hero 96/100 px, weight 600, tracking -4.6 px; sample supporting copy 14/20 px | White canvas, strong typography, thin boundaries and compact navigation. Sample CTA radius 8 px; primary blue and pale-blue secondary actions | Use local Inter for Page; an open document rhythm, labels aligned with values, restrained borders. Scale headings down for an operational app; retain neutral actions per the owner's direction |
| Notion product, documented by [Notion Help](https://www.notion.com/help/customize-and-style-your-content) | Default / Serif / Mono choices; text density and page-width controls | Text/block organization, toggle lists and optional callouts with removable icons | Serif in the night heading only; leave functional body/numerals sans. Progressive disclosure preserves useful detail without turning Home into a document editor |
| Apple marketing site | `SF Pro Text` body/action stack; `SF Pro Display` sampled heading 56/60 px, weight 600 | Strong separation of feature sections; clear primary/secondary actions. Sample CTA 17 px, 11 × 21 px padding, 980 px pill radius | Soft uses quieter grouped surfaces, comfortable controls and clearer typography. Promotional imagery and marketing-scale typography do not belong on the planner's Home |
| [Apple typography resources](https://developer.apple.com/fonts/) | SF Pro is the Apple-platform system family; New York is its serif companion | Optical sizing and text/display roles support legibility | Use existing local Onest/Manrope + Source Serif 4 for this cross-platform study. No Apple font assets were downloaded or embedded |

The current sites also use coloured accents and prominent visual marketing material. The owner's restrained-colour preference remains the constraint for Culmina. Exact brand colours, proprietary fonts and advertising layouts are not imported into the app.

## Component-level choices

These comparisons resolve actual Home decisions rather than surveying every possible component.

| Decision | Alternatives considered | Chosen translation and states |
| --- | --- | --- |
| Place/night context | Notion-like low-chrome inline actions; Apple's stronger grouped-control separation | Page uses a thin-boundary context row; Soft uses separated rounded actions. Both retain independent place/night callbacks. Without a site the lab and native trial hide the night choice; selecting a date changes the selected-night title |
| Conditions | Document rows on one canvas; individually framed cards; one grouped list | Page/Desk retain open rows; Soft groups the three conditions in one surface. No card per measurement. Missing forecast stays Unknown with a recovery action, not a zero-cloud value |
| Primary versus secondary action | Filled + tonal pair from public sites; neutral filled primary with secondary text/outline | Keep one Open planner primary in the plan context. Details remain row actions. Failing/disabled/loading states retain names and useful geometry; fit and saved-state labels remain separate |
| Optional detail | Notion toggle lists; permanently expanded detail; interrupting modal | Existing CollapsibleSection for secondary native content. Controlled mode supplies both open/onToggle; state and summary remain clear. Browser dialogs demonstrate local interactions only |
| Rounded shape | Notion's modest CTA corners; Apple's pill actions; current Culmina radius 6 | Original/Page/Desk keep plan radius 6; Soft explores 14 and pill actions. These are explicit proposal tokens, not an approved theme migration |

## Four related variants

| Variant | Body / night heading | Composition and useful comparison |
| --- | --- | --- |
| Hybrid, original | Manrope / Source Serif 4 | Preserves the owner's established favourite for direct comparison |
| Hybrid · Page | Inter / Source Serif 4 | Closest to a Notion document: aligned labels and open sections, plan introduced by a thin boundary. Wide view remains a readable single column |
| Hybrid · Soft | Onest / Source Serif 4 | Apple-informed grouping: quiet background, one white conditions group, comfortable rounded context/actions and a separate plan surface |
| Hybrid · Desk | Manrope / Source Serif 4 | Workbench rhythm: clear horizontal context boundaries and aligned measurements; wide view gives the plan more room beside conditions |

The default rail contains this four-member family. “All concepts” retains all ten historical/current comparisons. Previous/next, direct choice and wide mode respect the active collection. Font override replaces the serif heading as well, so font and composition can still be compared independently. All variants share the same fixture and state controls.

## Gap repairs and traceability

The [original video audit](VIDEO_GUIDANCE_AUDIT_2026_10_19.md) is a dated assessment. This section records its subsequent repairs without rewriting historical findings.

| Finding | Implemented repair | Verification |
| --- | --- | --- |
| F1: incomplete token usage metadata | All 13 proposal roles now have usage descriptions; foreground/background pairings are explicit; field surface alias is corrected. All 35 native palette roles have specific usage descriptions, including scientific chart roles | `python design/home-lab/scripts/check_inventory.py --self-test`; inspect Colours catalogue |
| F2: duplicate geometry and stale source risk | JSON spacing and production-radius values are consumed as CSS custom properties; each concept's plan radius consumes proposalRadius. Other responsive chrome remains an explicit CSS layout concern. Added read-only source/semantic checker with named stale/missing sources | Checker verifies hashes/full text and coverage; browser computed-style check verifies the actual geometry consumers. Checker self-test deliberately corrupts metadata in memory to confirm detection |
| F3: component API/state map too implicit | Three on-demand references under the component skill: forms, navigation and data display. They identify APIs, required/optional properties, slots, combinations, source ownership and adopters/checks | Skill validation and reference inspection; actual APIs inspected before writing |
| F4: no applied skill trial | Added `test/presentation/design_system/skill_application_test.dart`, an isolated composition of actual ContextLine, PlanStateLabel, StatusBlock and controlled CollapsibleSection | Native widget trial covers three themes × 100/200% text, missing/measured input, distinct saved state, callbacks and disclosure. Execution result is recorded in the completion evidence |

Trial task: show selected place/night, show an unknown fit until input exists, preserve a changed saved plan, expose optional details and a planner action. Rules skill chose Unknown and the persistence/fit separation; navigation reference chose ContextLine; display reference chose StatusBlock/PlanStateLabel and the controlled disclosure pair; tokens/typography/spacing skills chose actual AppTheme/AppPalette/AppSpacing. The test inspects real instances, expected words, token colours, callback effects, disclosure lifecycle and layout exceptions. No astronomy, database or production navigation is simulated as real application behavior.

This is one traceable application trial, not evidence that every agent host automatically selects or follows skills. The workflow continues to require relevant skills to be explicitly read when host discovery is absent.

## Verification record

See [repair and extension evidence](../../../../../../design/home-lab/evidence/HYBRID_REFINEMENT.md) for final commands, browser observations, captures and limitations. The source snapshot stays read-only: run the checker before relying on it, and regenerate deliberately when relevant sources change. Do not treat a displayed date or a passing aesthetic detector as proof of freshness or system conformance.
