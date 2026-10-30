# Typography

Revision: AFTER-DARK-1.0. Exact **design decisions**, informed by Notion's title/body/metadata hierarchy (S01, S24; C04–C06, C13), not a claim to recover its font or text sizes. Use the existing bundled **Geist** family. Do not substitute Inter merely because the reference resembles it. Verify Geist availability in Figma before F01; if missing, report that dependency instead of silently changing the family.

All sizes and line heights below are logical px, weights are numeric, tracking is px. Text always grows vertically. “Wrap” means no fixed line count or ellipsis for essential content. Numeric values use tabular lining figures; prose uses proportional figures. Units stay with their number where possible. No uppercase transformation.

| Existing role | Family | Size | Weight | Line height | Tracking | Wrapping / numeric rule | Planned Figma Text Style |
| --- | --- | ---: | ---: | ---: | ---: | --- | --- |
| AppTextTheme.homeHeading | Geist | 28 | 600 | 34 | -0.4 | Wrap night/date heading | After/AFTER-DARK-1.0/Text/homeHeading |
| AppTextTheme.nightHeading | Geist | 24 | 600 | 30 | -0.3 | Wrap viewed-night heading | After/AFTER-DARK-1.0/Text/nightHeading |
| AppTextTheme.answerHeading | Geist | 24 | 600 | 32 | -0.3 | Wrap scientific answer; tabular numbers | After/AFTER-DARK-1.0/Text/answerHeading |
| AppTextTheme.screenTitle | Geist | 20 | 600 | 26 | -0.2 | App bar may grow for two lines | After/AFTER-DARK-1.0/Text/screenTitle |
| AppTextTheme.sectionHeading | Geist | 18 | 600 | 24 | -0.2 | Wrap; trailing count moves below | After/AFTER-DARK-1.0/Text/sectionHeading |
| AppTextTheme.sectionSubject | Geist | 16 | 600 | 22 | 0 | Wrap subject within a section | After/AFTER-DARK-1.0/Text/sectionSubject |
| AppTextTheme.itemTitle | Geist | 16 | 500 | 22 | 0 | Wrap record title, never truncate target identity | After/AFTER-DARK-1.0/Text/itemTitle |
| AppTextTheme.rowTitle | Geist | 15 | 500 | 22 | 0 | Wrap actionable row label | After/AFTER-DARK-1.0/Text/rowTitle |
| AppTextTheme.value | Geist | 16 | 600 | 24 | 0 | Tabular; wrap units/explanation naturally | After/AFTER-DARK-1.0/Text/value |
| AppTextTheme.body | Geist | 15 | 400 | 22 | 0 | Wrap explanatory prose | After/AFTER-DARK-1.0/Text/body |
| AppTextTheme.support | Geist | 14 | 400 | 20 | 0 | Wrap secondary explanation | After/AFTER-DARK-1.0/Text/support |
| AppTextTheme.caption | Geist | 13 | 400 | 18 | 0 | Wrap metadata; tabular when timestamp/value | After/AFTER-DARK-1.0/Text/caption |
| AppTextTheme.dense | Geist | 12 | 400 | 16 | 0 | Axis/table labels only; tabular values | After/AFTER-DARK-1.0/Text/dense |
| AppTextTheme.navigationLabel | Geist | 12 | 500 | 16 | 0 | Wrap to two lines; grow bar as necessary | After/AFTER-DARK-1.0/Text/navigationLabel |
| AppTextTheme.homePlanHeading | Geist | 14 | 500 | 20 | 0 | Wrap saved-plan group label | After/AFTER-DARK-1.0/Text/homePlanHeading |
| AppTextTheme.homeTarget | Geist | 20 | 600 | 28 | -0.2 | Full target identity; alias on a secondary line | After/AFTER-DARK-1.0/Text/homeTarget |
| AppTextTheme.homeWordmark | Geist | 20 | 600 | 26 | -0.2 | Reserved for a real Culmina wordmark, not a pilot decoration | After/AFTER-DARK-1.0/Text/homeWordmark |
| AppTextTheme.homeWelcome | Geist | 28 | 600 | 34 | -0.4 | Welcome heading only; outside pilot composition | After/AFTER-DARK-1.0/Text/homeWelcome |

Color is bound separately to semantic tokens; it is not baked into a text style. Keep existing role names even when geometry matches. Buttons use rowTitle; selected tabs use navigationLabel; section captions use caption.

## Resolve current geometry overrides deliberately

[AppTextTheme](../../lib/core/theme/app_text_theme.dart) currently merges AppTextGeometry onto a base role. After must not accidentally carry over those numeric overrides. For the pilots, the following is the exact target resolution contract; Figma uses the resulting named style, not a second locally modified style.

| Current geometry/use | After resolution |
| --- | --- |
| answer, answerNeutralTracking | answerHeading |
| fitVerdict | sectionSubject |
| fitValue, fitMeasure | value, caption respectively |
| fitExplanation, weatherDescription, reading, supporting | body |
| formLabel, standard | rowTitle for controls; body for prose |
| explanatory, contextCaption, timelineDate, badge | caption |
| tableValue | caption with tabular figures |
| chartLabel, chartCaption, calendarCaption | dense |
| calendarCell | caption with tabular figures |
| calendarHeading, compactHeading, summaryTitle | sectionHeading |
| dialogTitle | screenTitle |
| compact | Preserve the named role above without an extra geometry override |

Other AppTextGeometry uses are **not covered** by the pilot contract. F01 must flag a newly encountered use before inventing a style. AppTextTheme.inherited remains an implementation mechanism, not an authorable Figma style.

At 375 px, numeric pairs may stack when content cannot fit. At increased text scale the values must grow, not shrink to fit; test with a 200% text specimen in F01. A text specimen is a static design check, not evidence of native accessibility. Negative signs, decimal separators, dates, GMT offsets and +1-day markers remain intact.
