---
name: culmina-design-typography
description: Apply Culmina text roles and compare licensed font candidates with Latin and Ukrainian specimens. Use for font selection, type scales and readable data typography.
---

# Culmina typography

Status: active task guidance, reconciled 2026-10-24. Read `docs/design/BASELINE.md` first for the adopted Hybrid/native sources and later refinements; `docs/VERIFICATION_POLICY.md` owns checks. Skills cannot authorize new scope.

Read `docs/design/WORKFLOW.md` and `lib/core/theme/app_typography.dart`. Geist is the adopted production UI family. Source Serif 4 is used by the named editorial/answer roles at opsz 14. Material-role and named Hybrid scales coexist; read actual call sites. Other lab families are historical candidates.

## Semantic scale

| Role | Production size / line height | Weight | Purpose |
| --- | --- | --- | --- |
| `headlineSmall` | 24 / 32 | 400 | In-page screen heading, allowed to wrap |
| `titleLarge` | 20 / 28 | 600 | Screen/detail titles |
| `titleMedium` | 16 / 24 | 600 | Section heading / answer |
| `titleSmall` | 14 / 20 | 600 | Subgroup |
| `bodyLarge` | 16 / 24 | 400 | Prominent content |
| `bodyMedium` | 16 / 24 | 400 | Regular body / values |
| `bodySmall` | 13 / 20 | 400 | Metadata with adequate contrast |
| `labelLarge` | 14 / 20 | 500 | Actions |

The full scale remains in code. Map by role, not by arbitrarily choosing H1–H6 sizes. CSS pixels in a browser specimen do not prove Flutter sp behavior.

## Adopted named Hybrid roles

`AppTypography` owns screenTitle, sectionHeading, sectionSubject, itemTitle, rowTitle, value, body, caption, dense, support, home roles and the serif headings. These coexist with `AppTypography.scale`; do not substitute the old generic table for a named role. Current exact sizes/line heights/weights/tracking are documented in DESIGN_SYSTEM §3 and the implementation, including the 20/600 Home plan heading and 18/500 target. Root navigation uses Roboto 11; calendar exceptions are explicit in HybridTokens. Browser CSS pixels are not proof of Flutter scaling.

## Historical candidate comparisons

| Family | Intended comparison | Useful sample |
| --- | --- | --- |
| Inter | Neutral workspace, Paper default | Tonight · Night of Oct 19 |
| Roboto | Familiar Google-like functional UI, Focus default | Your plan · Open planner |
| Manrope | Slightly warmer geometric alternative | Ніч спостереження · Обрати ціль |
| IBM Plex Sans | Distinctive, compact labels and scientific values | 120 × 60 s · 2 h · 3.6 GB |
| Source Serif 4 | Journal headings only, paired with Inter body | A little more time under the stars |
| Open Sans | Widely used open forms; compare long labels | Forecast unavailable · Прогноз недоступний |
| Noto Sans | Neutral multilingual option | Іі Її Єє Ґґ · Unknown |
| Source Sans 3 | Humanist compact alternative; Folio | Night conditions · Умови ночі |
| Geist | Precise UI option; Line | Needed 2 h 15 min · Usable 4 h 15 min |
| Onest | Softer functional alternative; Calm | Open planner · Переглянути план |
| Golos Text | Cyrillic and information density | Ніч спостереження · План зйомки |

Compare the same content and composition before attributing improvement to a font. The lab includes a dedicated specimen section and an independent font override. Source Serif 4 is an optional editorial comparison, not a blanket serif UI.

`design/home-lab/fonts/sources.json` records official source URLs, licences, hashes, subsets and the Google Fonts `popularity` field at the recorded date. Treat that field as service metadata, not a quality score or installation share. The current Google Fonts DM Sans was excluded because it lacks Cyrillic subsets. Refresh assets through `design/home-lab/scripts/sync_fonts.py` only when a font refresh is requested.

Historical preference (2026-10-19): Paper-like base with Journal's night section, initially compared with Manrope. That early candidate is superseded for production by the adopted Geist / Source Serif 4 final Hybrid reference; see BASELINE. Preserve its font assets/licences as reference.

## Selection checks

- Check Ukrainian І і Ї ї Є є Ґ ґ, punctuation, degree/multiplication/minus signs, 0/O and 1/I/l. Do not infer glyph support from a family name; inspect the bundled font and browser output.
- Use tabular numerals for comparable measurements and times, without making all text monospace.
- The base Material scale has a 12 sp floor, with current bodyMedium 16 and bodySmall 13. Named Hybrid roles have their own hierarchy; documented compact navigation/calendar exceptions are smaller and must not become a general minimum. Test 200% text, long names and errors; never shrink important copy to fit.
- Self-host files in a production adoption and retain their actual licences. The lab font collection remains separate; the adopted native fonts and licences are already bundled under assets/fonts and pubspec.
- Font choice, weight, wrapping and spacing interact. Record the proposed pair and fallback, then verify actual widgets before production adoption.

Historical browser comparison: the Notion/Apple refinement used Inter for Hybrid Page, Onest for Soft and Manrope for Desk, each with Source Serif 4 only in the night heading. The study recorded NotionInter/Inter on Notion and SF Pro Text/Display on Apple. These observed CSS stacks are not licences or a guarantee of the rendered glyph face. Use the local candidates; read `docs/design/NOTION_APPLE_STUDY_2026_10_19.md` when comparing these references.

Historical earlier port: the original Hybrid (`blend`, browser revision `20261020-hybrid7`) uses opt-in `tokens.json.hybridRefinement` roles: 16 px body/data, 14 px support/actions and 13 px metadata, multiplied by text scale. Display headings retain their established sizes; this is a selective readability refinement, not a global font-size increase or a Flutter scale change. See `docs/design/HYBRID_REFINEMENT_2026_10_20.md` for theme/200% evidence.
