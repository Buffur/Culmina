> **Historical navigation copy — not active instructions.** Link destinations are rebased from `docs/design/HYBRID_COLOR_SEPARATION_2026_10_22.md`. Content and acceptance statements retain their original date/scope. [Immutable original](../../../docs/design/HYBRID_COLOR_SEPARATION_2026_10_22.md) · [Navigation index](../../../NAVIGATION.md). Original SHA-256: `2dce1102518224c78e55001bd4ca53ced1361d0128cd6c2fd7128597f4e11605`.

# Home section separation and Radix Weather trial — 2026-10-22

Scope: original Hybrid web only. Owner's marked Home boundary is fixed. Weather Light/Dark now previews one sourced palette, Radix Gray + Blue; no palette rollout to Plan, Moon/Night, Home or Field. Existing fonts, layout, scientific values, units, unknowns and interactions remain. No dependencies, React/shadcn installation, Flutter changes, commit or push.

## Confirmed Home defect

In the desktop-wide studio, `catalog.css`'s `.wide .home-body[data-order="plan-first"]>.conditions` reset the top margin to **0px**. The preceding section rule's 16px margin lost the cascade; a #2F2F2F line on #191919 was also too faint. The actual title began just **17px** after Open planner, merging two information groups.

`hybrid-refinement.css` now explicitly separates adjacent Plan/Conditions groups in either order: **24px margin + 1px border-control rule + 24px top padding**. Measured button-to-heading gap is **49px**, at 375/412 CSS px in Light/Dark. No shadow or extra card wrapper. Other Hybrid variants are untouched.

[Before Dark](../../../../../../design/home-lab/evidence/color-separation-2026-10-22/home-before-dark-375.png) · [After Dark](../../../../../../design/home-lab/evidence/color-separation-2026-10-22/home-after-dark-375.png) · [After Light](../../../../../../design/home-lab/evidence/color-separation-2026-10-22/home-after-light-375.png)

## Analysis of the supplied colour advice

The useful recommendation is a single role-based source, tried on one real data screen before wider adoption. Radix's official documentation supports Gray with any accent, and separates background, component-state, border and text roles. Its scale steps are design guidance, not a blanket WCAG contrast certificate. The other suggested galleries/editors can help choose a direction visually; their values were not mixed into this trial. There is no claim that Notion uses Radix or that these are Notion/Linear product tokens.

Source: [Radix composition](https://www.radix-ui.com/colors/docs/palette-composition/composing-a-palette), [scale use cases](https://www.radix-ui.com/colors/docs/palette-composition/understanding-the-scale). Context7 resolve/query was used, then the actual official sRGB source values were verified. Copied values are unchanged, pinned to upstream revision **dbdb85470547c7d34b9001f48fddb08ded335979**. [Provenance and exact values](../../../../../../design/home-lab/colors/radix/provenance.json) · [MIT notice](../../../../../../design/home-lab/colors/radix/LICENSE).

## Applied Weather roles

Only `.weather-radix` phone samples in Light/Dark consume these aliases. Conditions toggles that class when changing views; the comparison page applies it only to `#weather-phone`. Defaults remain outside Weather. All values below are opaque (alpha 1); no new colour mixing, opacity washes or chart gradients are introduced.

| Role | Radix step | Light | Dark |
| --- | --- | --- | --- |
| Canvas | Gray 1 | #FCFCFC | #111111 |
| Subtle surface | Gray 2 | #F9F9F9 | #191919 |
| Raised/recessed component surface | Gray 3 | #F0F0F0 | #222222 |
| Main text | Gray 12 | #202020 | #EEEEEE |
| Supporting/provenance/unknown | Gray 11 | #646464 | #B4B4B4 |
| Decorative separator | Gray 6 | #D9D9D9 | #3A3A3A |
| Necessary control border | Gray 9 | #8D8D8D | #6E6E6E |
| Selection base | Blue 3 | #E6F4FE | #0D2847 |
| Selected hour fill / text | Blue 5 / 12 | #C2E5FF / #113264 | #004074 / #C2E6FF |
| Action, selected tab, links, primary series/icons | Blue 11 | #0D74CE | #70B8FF |
| On-action text | Gray 1 | #FCFCFC | #111111 |
| Dew/gust secondary series and cloud series | Gray 11 | #646464 | #B4B4B4 |
| Warning text | Amber 12 Light / 11 Dark | #4F3422 | #FFCA16 |
| Operation error | Red 11 | #CE2C31 | #FF9592 |

Blue means action/data emphasis, not good weather. Temperature/dew and wind/gust retain solid/dashed lines and filled/hollow points; cloud is neutral. Missing values still break paths. Amber is for labelled warnings such as stale data, not temperature quality. Gray9 is chosen for necessary boundaries because the more subtle Gray7/8 roles are not automatically 3:1. Source values are not darkened by hand.

An actual check caught **Amber11 on Gray1 Light = 4.494:1**. It was replaced with unchanged **Amber12**, giving **11.084:1**, rather than rounding the failure up or altering the source shade. Existing red/black Field rules are excluded from this stylesheet.

Open [Weather Light](http://127.0.0.1:4173/conditions.html?view=weather&variant=blend&theme=light&scale=1) or [Weather Dark](http://127.0.0.1:4173/conditions.html?view=weather&variant=blend&theme=dark&scale=1). Both existing A/B presentations use the trial. [Component comparison](http://127.0.0.1:4173/hybrid-studies.html?theme=dark&weather=charts&width=375#weather-comparison) labels the palette trial explicitly.

## Bounded verification

- Actual Home 375/412 Light/Dark: visible rule, 49px separation, no phone overflow. Reverse Conditions→Plan order also passes. Rendered captures were personally viewed.
- Weather A/B Light/Dark: palette-only class toggle produces identical metric text, widths, heights and type sizes. Existing layout/data are preserved. Actual screen captures and the whole chart component were personally viewed.
- Final sampled normal-text minimum: **4.645:1 Light**, **8.087:1 Dark**. Chart-line colours: **4.645:1 Light**, **8.982:1 Dark**. Necessary control boundaries: **3.235:1 Light**, **3.703:1 Dark**. Decorative separators are not claimed as control boundaries. These are bounded pair checks, not whole-product certification.
- Slider keyboard selection, 412px partial-data paths, absence of root overflow, palette removal on Moon/Night tabs and red/black Field regression pass. No page errors observed. Preview on existing port 4173 was reused; all browser work used an isolated session.
- [Initial QA](../../../../../../design/home-lab/evidence/color-separation-2026-10-22/initial-qa.json) retains the Amber11 failure and a harness HEX-parsing error for the dark control border. [Corrected contrast/reverse-order result](../../../../../../design/home-lab/evidence/color-separation-2026-10-22/contrast-recheck.json) passes. The harness correction did not require changing the control colour.
- Syntax and scoped whitespace checks pass. No full tests/builds/device work were needed for these presentation changes.

Files: `hybrid-refinement.css` (boundary), `weather-radix.css` + `colors/radix/` (sourced palette), Conditions view-class/import, study Weather class/import/caption. The earlier component-study palette table is the preceding candidate; this note supersedes only its Weather Light/Dark values. Await owner review before any wider palette rollout.
