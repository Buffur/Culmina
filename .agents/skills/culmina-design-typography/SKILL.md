---
name: culmina-design-typography
description: Apply Culmina text roles and compare licensed font candidates with Latin and Ukrainian specimens. Use for font selection, type scales and readable data typography.
---

# Culmina typography

Read `docs/design/WORKFLOW.md` and `lib/core/theme/app_typography.dart`. The existing Material-role scale is production truth; families in the browser lab are proposals.

## Semantic scale

| Role | Production size / line height | Weight | Purpose |
| --- | --- | --- | --- |
| `headlineSmall` | 24 / 32 | 400 | In-page screen heading, allowed to wrap |
| `titleLarge` | 20 / 28 | 600 | Screen/detail titles |
| `titleMedium` | 16 / 24 | 600 | Section heading / answer |
| `titleSmall` | 14 / 20 | 600 | Subgroup |
| `bodyLarge` | 16 / 24 | 400 | Prominent content |
| `bodyMedium` | 14 / 20 | 400 | Regular body / values |
| `bodySmall` | 12 / 16 | 400 | Metadata with adequate contrast |
| `labelLarge` | 14 / 20 | 500 | Actions |

The full scale remains in code. Map by role, not by arbitrarily choosing H1–H6 sizes. CSS pixels in a browser specimen do not prove Flutter sp behavior.

## Candidate families, not an adoption decision

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

Owner preference (2026-10-19): compare a Paper-like base with Journal's The night ahead section. The lab's Hybrid uses Manrope for the main UI and Source Serif 4 only for that section heading. This is a concept preference, not production adoption.

## Selection checks

- Check Ukrainian І і Ї ї Є є Ґ ґ, punctuation, degree/multiplication/minus signs, 0/O and 1/I/l. Do not infer glyph support from a family name; inspect the bundled font and browser output.
- Use tabular numerals for comparable measurements and times, without making all text monospace.
- Keep 12 as the existing minimum; retain a clear 14/16 body hierarchy. Test 200% text, long names and errors; never shrink important copy to fit.
- Self-host files in a production adoption and retain their actual licences. The lab font files and licences are isolated from Flutter assets and pubspec.
- Font choice, weight, wrapping and spacing interact. Record the proposed pair and fallback, then verify actual widgets before production adoption.

The Notion/Apple refinement uses Inter for Hybrid Page, Onest for Soft and Manrope for Desk, each with Source Serif 4 only in the night heading. The current Notion homepage declares NotionInter/Inter; Apple declares SF Pro Text/Display. These observed CSS stacks are not licences or a guarantee of the rendered glyph face. Use the local candidates; read `docs/design/NOTION_APPLE_STUDY_2026_10_19.md` when comparing these references.

The original Hybrid (`blend`, browser revision `20261020-hybrid7`) uses opt-in `tokens.json.hybridRefinement` roles: 16 px body/data, 14 px support/actions and 13 px metadata, multiplied by text scale. Display headings retain their established sizes; this is a selective readability refinement, not a global font-size increase or a Flutter scale change. See `docs/design/HYBRID_REFINEMENT_2026_10_20.md` for theme/200% evidence.
