> **Historical navigation copy — not active instructions.** Link destinations are rebased from `docs/design/QUALITY_COLOR_GUIDANCE_2026_10_20.md`. Content and acceptance statements retain their original date/scope. [Immutable original](../../../docs/design/QUALITY_COLOR_GUIDANCE_2026_10_20.md) · [Navigation index](../../../NAVIGATION.md). Original SHA-256: `222a8b5571425453a617df20f7509c79e8d9e5ff2311aedceabfd81855381969`.

# Quality brief colour guidance — 2026-10-20

Status: **browser-prototype only** (Android phone preview in `design/home-lab/`). Nothing here is a Flutter token, an approved production change or a change to `lib/core/theme/`. Production adoption needs the owner's selection and actual-widget validation under `CLAUDE.md` V1–V8.

## Decision

The approved Hybrid Notion + Journal palette stays neutral: `text-primary/secondary/tertiary`, `border-*`, `surface-*`, `selection`, `error` are unchanged and remain the default for every control, heading and series. Colour is added in exactly three places where it carries information that grey cannot:

1. **Sky state** (Home, Night, Moon): a continuous day → twilight → dark gradient.
2. **Moon lanes**: Moon above horizon vs Moon-free dark.
3. **Weather caution**: a dew-margin flag and stale/offline notices.

No new hue is introduced. Every value below is an existing `AppPalette` chart/caution value, or a value interpolated between two existing ones (marked *derived*).

## Browser variables (defined in `design/home-lab/night.css`)

| Variable | Light | Dark | Field (red only) | Source / use |
| --- | --- | --- | --- | --- |
| `--sky-day` | `#B3E5FC` | `#37474F` | `#660000` | `chartDay` (light, dark). Field: new red-only step, equals existing `fieldTextDisabled` value. Daylight |
| `--sky-civil` | `#96B5E4` | `#2D3F72` | `#4D0000` | *Derived* midway between `chartDay` and `chartTwilight`. Civil twilight (−6° … 0°) |
| `--sky-nautical` | `#7986CB` | `#1A237E` | `#3A0000` | `chartTwilight` (light, dark); field uses the existing `chartDay` red. Nautical twilight (−12° … −6°) |
| `--sky-astro` | `#4E5476` | `#0E1245` | `#1C0000` | *Derived* between `chartTwilight` and `chartDark`; field is the existing `chartTwilight` red. Astronomical twilight (−18° … −12°) |
| `--sky-dark` | `#212121` | `#000000` | `#000000` | `chartDark` (`black87` over white in light). Sun below the −18° limit |
| `--moon-up` | `#607D8B` | `#B0BEC5` | `#990000` | `moon` / `chartMoon`. Lane for Moon above horizon |
| `--moon-free` | `#37352F` | `#EBEBEA` | `#FF0000` | Alias of `text-primary` per theme, named so the lane keeps its meaning if text colour changes. Lane for Moon-free dark |
| `--wx-caution` | `#9A5B00` | `#FFB74D` | `#FF0000` | Existing `caution`. Dew-point-near-air flag; stale/offline notices |

Luminance steps down monotonically from day to dark in all three themes, so the ramp reads in greyscale. Field mode uses brightness only; never add hue to it.

## Rules for use

- **Meaning, not decoration.** Sky colours appear only inside the sky band and its legend swatches. Never use them for buttons, headings, cards or backgrounds.
- **Never colour alone** ([WCAG 2.2 SC 1.4.1](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html): colour must not be the only means of conveying information; pair it with shape, text or position). Each colour here is paired with a second cue:
  - the explicit **dark interval** is a solid bracket (⊔ with end ticks) drawn under the gradient;
  - **Moon above horizon** is a thin bar in the upper lane; **Moon-free dark** is a full-height bar in the lower lane, so lane position and thickness differ even in greyscale;
  - **dew flag** is a short bar under the hour *and* a legend entry *and* part of the hour's accessible name; the stale/offline notices state their condition in words.
- **Gradient honesty.** Event times (sunset, civil/nautical/astronomical dusk and dawn) are the data. Colour blends for at most 10 minutes either side of each boundary (30 % of a short segment) purely so the band reads as continuous. It is not measured sky brightness and is stated as such under the band. The legend lists only categories present on the viewed night.
- **Outline the band.** The pale ends of the ramp (light `--sky-day`, dark-theme `--sky-dark`) are close to their surface, so the band carries a 1 px `border-control` outline. Graphic boundaries should reach 3:1 where they must be recognised; ramp steps are labelled in the legend and do not need to.
- **No semantic reuse.** Do not use `--moon-up` for cloud, `--wx-caution` for fit verdicts, or sky colours for status. Fit and persistence states keep `status-*` / `state-*` from the token skill.
- **Series stay neutral.** Cloud bars, temperature (solid) and dew point (dashed) use `text-primary` / `text-secondary` and line style, not hue.

## Limits

- Contrast ratios for the new browser pairs were **not measured** in this change; the outline rule above is the design intent, and field mode's lower secondary contrast is the documented exception in `docs/DESIGN_SYSTEM.md`.
- Material 3 colour-role and Apple HIG chart pages were requested but returned no body text to the fetch tool, so they are **not cited as verified**. Only the WCAG 1.4.1 page was read.
- The values are a prototype proposal. Mapping them to `AppPalette` (new roles vs reusing `chart*`) is an open production decision.
