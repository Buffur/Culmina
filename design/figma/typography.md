# Typography

Revision: AFTER-DARK-1.2. Exact **design decisions**, informed by Notion's title/body/metadata hierarchy (S01, S24; C04–C06, C13), not a claim to recover its font or text sizes. Use the existing bundled **Geist** family. Do not substitute Inter merely because the reference resembles it. Geist was verified in F01 and is retained by explicit owner instruction. Revision 1.1 reconstructs title/row/card hierarchy from S01/S24; its metrics are estimates, not recovered Notion source styles.

All sizes and line heights below are logical px, weights are numeric, tracking is px. Text always grows vertically. “Wrap” means no fixed line count or ellipsis for essential content. Numeric values use tabular lining figures; prose uses proportional figures. Units stay with their number where possible. No uppercase transformation.

## Current new-screen role resolver — 2026-11-04

This resolver applies to every new Dark redesign screen, superseding the former pilot-only applicability. Select by semantic job, not by the old role name alone. The retained base styles below are not competing defaults.

| Semantic job | Current style / metrics | Boundary |
| --- | --- | --- |
| Parent section / group title | screenTitle, Geist 20/26 SemiBold 600 | Includes Fits, Night ahead, Conditions, Capture plan and Estimate parent titles. |
| Nested record, detail or disclosure title | nestedTitle, Geist 18/26 Medium 500, tracking 0 | Named style `After/AFTER-DARK-1.2/Text/nestedTitle`; replaces the same unbound Medium recipe without pixel changes. |
| Explicit command label | actionLabel, 15/24 SemiBold 600 | Ordinary selectable rows/entered values remain rowTitle Regular. |
| Metric label / numeric value / evidence | body 15/24 / value 16/24 SemiBold / caption 13/18 | Preserve scientific role, units and qualifications. |
| Ordinary field, chooser option, prose | rowTitle / body / caption as below | Do not turn fields into nested headings. |
| Page identity, scientific answer, axes, metadata | Matching named role below | Keep homeHeading, answerHeading, dense and timestamps distinct. |

The 14px sectionHeading and 18px Regular itemTitle remain for explicitly named base/legacy uses; neither is the default parent/nested title in a new screen. nestedTitle is a Figma presentation role, not a claimed Dart member. [Current authoring profile](AUTHORING_PROFILE.md) resolves component selection; original style IDs remain unchanged.

## Retained base roles

| Existing role | Family | Size | Weight | Line height | Tracking | Wrapping / numeric rule | Planned Figma Text Style |
| --- | --- | ---: | ---: | ---: | ---: | --- | --- |
| AppTextTheme.homeHeading | Geist | 36 | 600 | 42 | 0 | Wrap night/date heading | After/AFTER-DARK-1.2/Text/homeHeading |
| AppTextTheme.nightHeading | Geist | 24 | 600 | 30 | -0.3 | Wrap viewed-night heading | After/AFTER-DARK-1.2/Text/nightHeading |
| AppTextTheme.answerHeading | Geist | 24 | 600 | 32 | -0.3 | Wrap scientific answer; tabular numbers | After/AFTER-DARK-1.2/Text/answerHeading |
| AppTextTheme.screenTitle | Geist | 20 | 600 | 26 | -0.2 | App bar may grow for two lines | After/AFTER-DARK-1.2/Text/screenTitle |
| AppTextTheme.sectionHeading | Geist | 14 | 400 | 20 | 0 | Wrap; trailing count moves below | After/AFTER-DARK-1.2/Text/sectionHeading |
| AppTextTheme.sectionSubject | Geist | 16 | 600 | 22 | 0 | Wrap subject within a section | After/AFTER-DARK-1.2/Text/sectionSubject |
| AppTextTheme.itemTitle | Geist | 18 | 400 | 26 | 0 | Wrap record title, never truncate target identity | After/AFTER-DARK-1.2/Text/itemTitle |
| AppTextTheme.rowTitle | Geist | 15 | 400 | 24 | 0 | Wrap actionable row label | After/AFTER-DARK-1.2/Text/rowTitle |
| After actionLabel (Figma role) | Geist | 15 | 600 | 24 | 0 | Wrap explicit button label; preserve target | After/AFTER-DARK-1.2/Text/actionLabel |
| AppTextTheme.value | Geist | 16 | 600 | 24 | 0 | Tabular; wrap units/explanation naturally | After/AFTER-DARK-1.2/Text/value |
| AppTextTheme.body | Geist | 15 | 400 | 24 | 0 | Wrap explanatory prose | After/AFTER-DARK-1.2/Text/body |
| AppTextTheme.support | Geist | 14 | 400 | 20 | 0 | Wrap secondary explanation | After/AFTER-DARK-1.2/Text/support |
| AppTextTheme.caption | Geist | 13 | 400 | 18 | 0 | Wrap metadata; tabular when timestamp/value | After/AFTER-DARK-1.2/Text/caption |
| AppTextTheme.dense | Geist | 12 | 400 | 16 | 0 | Axis/table labels only; tabular values | After/AFTER-DARK-1.2/Text/dense |
| AppTextTheme.navigationLabel | Geist | 12 | 500 | 16 | 0 | Wrap to two lines; grow bar as necessary | After/AFTER-DARK-1.2/Text/navigationLabel |
| AppTextTheme.homePlanHeading | Geist | 14 | 500 | 20 | 0 | Wrap saved-plan group label | After/AFTER-DARK-1.2/Text/homePlanHeading |
| AppTextTheme.homeTarget | Geist | 20 | 600 | 28 | -0.2 | Full target identity; alias on a secondary line | After/AFTER-DARK-1.2/Text/homeTarget |
| AppTextTheme.homeWordmark | Geist | 20 | 600 | 26 | -0.2 | Reserved for a real Culmina wordmark, not a pilot decoration | After/AFTER-DARK-1.2/Text/homeWordmark |
| AppTextTheme.homeWelcome | Geist | 28 | 600 | 34 | -0.4 | Welcome heading only; outside pilot composition | After/AFTER-DARK-1.2/Text/homeWelcome |

Color is bound separately to semantic tokens; it is not baked into a text style. Keep existing role names even when geometry matches. Explicit buttons use actionLabel; ordinary controls use rowTitle; selected tabs use navigationLabel; section captions use caption.

### Owner action emphasis — 2026-11-04

Explicit task buttons use rowTitle geometry (15/24) with Geist SemiBold (600), bound to the actionLabel Figma style. This is a presentation role, not a claim that Dart already has an actionLabel API. It applies to the Action catalog's interaction/busy/disabled variants and the named Tonight/Plan commands, including Open planner and Save plan. It does not change the shared rowTitle style: chooser rows, entered values, captions and scientific labels retain their semantic weight. Keep existing button colors and targets; do not bold every actionable row. Historically, this adoption added the nineteenth style to the original 18; the subsequent nestedTitle addition is resolved above. Live inventory, verification and adoption status belong to WORKFLOW.

## Resolve current geometry overrides deliberately

[AppTextTheme](../../lib/core/theme/app_text_theme.dart) currently merges AppTextGeometry onto a base role. After must not accidentally carry over those numeric overrides. For the pilots, the following is the exact target resolution contract; Figma uses the resulting named style, not a second locally modified style.

| Current geometry/use | After resolution |
| --- | --- |
| answer, answerNeutralTracking | answerHeading |
| fitVerdict | screenTitle for a standalone parent answer; nestedTitle inside a saved-plan group |
| fitValue, fitMeasure | value, caption respectively |
| fitExplanation, weatherDescription, reading, supporting | body |
| formLabel, standard | rowTitle for controls; body for prose |
| explanatory, contextCaption, timelineDate, badge | caption |
| tableValue | caption with tabular figures |
| chartLabel, chartCaption, calendarCaption | dense |
| calendarCell | caption with tabular figures |
| calendarHeading, compactHeading, summaryTitle | screenTitle for parent groups; nestedTitle for nested records/details; retained sectionHeading only for an explicitly quiet base/legacy label |
| dialogTitle | screenTitle |
| compact | Preserve the named role above without an extra geometry override |

Other AppTextGeometry uses are **not covered** by the pilot contract. F01 must flag a newly encountered use before inventing a style. AppTextTheme.inherited remains an implementation mechanism, not an authorable Figma style.

At 375 px, numeric pairs may stack when content cannot fit. At increased text scale the values must grow, not shrink to fit; record text-scaling scope in the relevant task; F01 excluded 200% QA. A text specimen is a static design check, not evidence of native accessibility. Negative signs, decimal separators, dates, GMT offsets and +1-day markers remain intact.

The 1.1 row/body size is calibrated to Geist: 15 px regular with a 24 px line height approximates the S01 row widths more closely than 16 px Geist. This is font compensation from screenshots, not a claim that Notion uses 15 px Geist.

## Historical adoption scope — local top-down Longread hierarchy, 2026-11-01

The owner explicitly adopted a section-first hierarchy for the existing Tonight Your plan and Plan Capture plan / Estimate TEST groups. Their section titles use the existing screenTitle geometry (20/26, weight 600) and primary ink. Nested record names and disclosure titles use itemTitle geometry (18/26) with a local Geist Medium (500) override; descriptions retain caption (13/18 regular, secondary ink). These are local text overrides, not shared style edits or a new global type scale. The three sections are changed only where they already exist; Capture and Estimate are not added to Tonight.

Within Tonight Your plan, the nested Fits verdict follows the 18px title tier and its needed/usable figures use the existing 16/24 value role, keeping both below the section title. Plan's separate accepted Fits block is preserved. Estimate retains its 15px metric labels, 16px semibold values and 13px evidence captions beneath the stronger section heading. Complete wording, scientific scope, state labels and actions remain unchanged. See [workflow](WORKFLOW.md) for actual checks and outstanding unrelated QA findings.

### Historical subsequent hierarchy rollout — 2026-11-01

The owner then authorized corrections from the whole-system review. The section-first recipe now also governs both Night ahead groups, the named Discover block, current Plan Fits and current working Fits/Capture/Estimate specimens. Night/Moon/Weather and detail titles use the nested tier; field labels, table cells, timestamps and scientific answer emphasis retain their distinct roles. Catalog Section and SkyDarkness headings use screenTitle; Choice group labels and Disclosure titles use itemTitle with the explicit Medium override. Thus sectionHeading's retained 14px style is not the parent-title choice for these adopted blocks. The shared 18 style definitions and 94 variables are not rewritten. Earlier specimens are recoverably archived; prior entries above record their original scope.
