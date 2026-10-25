# Culmina (formerly AstroPlan) — Design System

Status: active shared visual/interaction reference, reconciled 2026-10-24 against `94cebfb` for the known stale instructions below. [design/BASELINE](design/BASELINE.md) maps the final approved Hybrid/Geist reference, current native sources and later P-1–P-6, TD-120/TD-121 and identity changes. [VERIFICATION_POLICY](VERIFICATION_POLICY.md) owns checks; current authorization is in [PROGRESS](refinement/PROGRESS.md).

Sections retain Stage 5–9 contract/adoption provenance; dated colour/geometry observations are not a second token authority. Read actual theme/components and later approved refinements before applying them. CA-OD1 is no longer an open branding decision (DECISIONS D1); owner acceptance of later delivery is a separate question. Historical update logs below remain unchanged.

## Read by task

This is an indexed reference. For a focused production fix or review, locate the heading/anchor and read the relevant current section with its native definition/caller; do not load the whole file by default. [WORKFLOW](design/WORKFLOW.md#read-the-needed-contract) owns the reading route and work modes. Sections 8–9 and the dated appendix retain adoption/history and are read only when the task needs that provenance.

| Surface | Start here |
| --- | --- |
| Weather hour selection or token mapping | [§2 Colour](#2-colour) |
| Local Plan typography | [§3 Type scale](#3-type-scale-apptypographyscale) |
| Screen gutter, component padding or touch targets | [§4 Spacing](#4-spacing-and-radius) |
| Tonight site/night control | [Context line](#context-line) |
| Other controls/data display | Only the named §6/§7a subsection |

## 1. Principles

- **Answer first, then detail** (PRODUCT_DIRECTION §5.1–§5.2). The type scale and text roles exist
  so the answer reads first and supporting text recedes (08 §7: "nearly all text is white").
- **Clean, minimalist, information-dense, functional** (`.agents/rules/05-ui-design.md`), in the
  Notion-inspired direction, which is a direction and not a restriction (PRODUCT_DIRECTION §5.10).
- **Field use** (`IA_WIREFRAMES.md` §3): targets of at least 48 dp, 200 % text, red mode one tap
  away, red or black only in red mode.
- **Tokens only** (CLAUDE.md trap 12): `lib/presentation` never names an unapproved colour or shrink-wraps a tap target; the base
  text scale stays at least 12 sp, with explicit source-derived compact Hybrid exceptions (`presentation_style_rules_test.dart`). A new colour token
  goes into all three palettes.
- **Rules applied throughout the app, not screen by screen** (08 §27, "Design System"): tokens
  change through the theme; shared components are adopted by the Stage that redesigns a screen.

## 2. Colour

### 2.1 Text roles (`AppPalette`)

| Role | Use | Light | Dark | Field |
| --- | --- | --- | --- | --- |
| `textPrimary` | The answer, values, headings | `#37352F` | `#EBEBEA` | `#FF0000` |
| `textSecondary` | Labels, supporting text | `#5A5955` | `#A5A5A3` | `#AA0000` |
| `textTertiary` | Captions, metadata (zone captions, sources, ages) | `#6E6D69` | `#8F8F8D` | `#880000` |
| `textDisabled` | Inactive controls only | `#A3A29F` | `#6B6B69` | `#660000` |

- **Contrast (light, dark):** primary, secondary and tertiary are WCAG AA (at least 4.5:1) on the
  background, the surface and the raised surface. Worst cases: light 11.4, 6.5 and 4.8; dark 12.8,
  6.2 and 4.7.
- **The step:** each role's worst-case contrast is at least **1.3 times** the next role's, so the
  hierarchy is visible, not only the size. Disabled is below tertiary and exempt from AA (WCAG
  1.4.3 excludes inactive controls).
- **Field mode:** the roles step down in brightness (red only). Secondary and tertiary are below
  AA on purpose, for dark-adapted eyes (ARCHITECTURE B16); contrast is not asserted there.
- **The colour scheme follows the roles:** `onSurface` = primary (so default text is the primary
  role), `onSurfaceVariant` = secondary, and in light and dark `secondary` = secondary.
- **Emphasis also comes from size and weight** (§3): the lower roles pair with the smaller styles.
- Tested by `test/core/theme/design_tokens_test.dart`.

### 2.2 Surfaces

| Level | Token | Light | Dark | Field | Used by |
| --- | --- | --- | --- | --- | --- |
| Background | `scaffoldBackgroundColor` | `#FFFFFF` | `#191919` | `#000000` | Screens |
| Surface | `colorScheme.surface` | `#F7F7F5` | `#202020` | `#000000` | Theme surface; field grouping uses `cardColor` / `AppColors.fieldSurface` (`#110000`) |
| Raised | `AppPalette.surfaceRaised` = `colorScheme.surfaceContainerHigh` | `#FFFFFF` | `#252525` | `#1A0000` | Dialogs, date pickers (Material reads `surfaceContainerHigh`) |
| Border | `AppPalette.border` | `#E9E9E7` | `#2F2F2F` | `#330000` | Card outlines, dividers |

Additional native Hybrid roles live in `lib/core/theme/hybrid_tokens.dart`, installed alongside AppPalette by `AppTheme._withTokens`. `surfaceSubtle` supplies the selected root-navigation surface (`lib/presentation/navigation/app_shell.dart`) and the approved Concept B document groups (`lib/presentation/shared/document_section.dart`); `surfaceSunken` supplies recessed Moon-lane tracks and the Moon-up legend well (`lib/presentation/widgets/night_browser_sections.dart`). These are existing production roles, not browser-only proposals or aliases for raised overlays. In field mode `surfaceSubtle` is the dark-red grouping surface while `colorScheme.surface` remains black. Read values from the theme definitions.

Existing outlined cards retain their border and small radius. The owner-approved [Concept B document groups](design/CONCEPT_B_IMPLEMENTATION_2026_10_24.md) use `DocumentSection`: flat semantic `surfaceSubtle`, no elevation or outline, 8 dp radius and 16 dp default padding. They group existing controls without adding an interaction. A local Material paints existing ink/focus feedback above the group surface; no clipping or semantic merging is added. Logbook joins lazy month slices into continuous groups.

The [whole-app 100% completion](design/CONCEPT_B_COMPLETION_100_2026_10_24.md) extends this anatomy to all nine Library children, seven Plan choosers/editors/candidates, Logbook detail/Progress and five Settings children. Group reading/editing tasks rather than individual facts. Joined list/source fragments retain lazy layout; top-level groups own their 16 dp separation, so remove superseded leading spacers. On a 375 dp phone, 20 dp gutters and 16 dp inner padding leave 303 dp: sensor/optics/coordinate pairs stack at that width, candidate selectors use full-width rows, and range endpoint labels wrap. Immediate Appearance/Privacy settings, staged Planning Save/Cancel, draft Apply and explicit Save plan retain their distinct ownership. Restore carries the current Appearance and Field theme/filter into its standalone root. Full 200%/TalkBack and owner acceptance remain pending; passing retained regressions does not close CBA-02/03/04/06.

**Selected container** (light): `colorScheme.secondaryContainer` = the border grey `#E9E9E7` with
`onSecondaryContainer` = primary text, for selected segments and the navigation bar's indicator.
Material would derive it from `secondary`, and black on the darker secondary is only 2.99:1 (the
route sweep caught it on Settings' segmented control). Dark keeps Material's derivation (black on
`#A5A5A3`, AA). Tested: text on the selected container is AA in light and dark.

### 2.3 Control border and error (S5.2)

| Token | Light | Dark | Field | Rule |
| --- | --- | --- | --- | --- |
| `AppPalette.controlBorder` = `colorScheme.outline` | `#8F8E8A` | `#6F6F6D` | `#880000` | A control's boundary (a field's line, an outlined button). At least 3:1 on every surface in light and dark (WCAG 1.4.11). In field mode brighter than a card border, so controls stay visible (UX-39) |
| `colorScheme.outlineVariant` | `#E9E9E7` | `#2F2F2F` | `#330000` | Decorative outlines (chips), as the card border |
| `colorScheme.error` / `onError` | `#B00020` / white | `#F28B82` / `#191919` | `#FF0000` / black | AA as text on every surface, and text on it is AA |

- **Why `outline` is set:** Material falls back to `onBackground` for `outline` and
  `outlineVariant`, so every field's underline and every chip border was black in light and white
  in dark. That was the prominent underline of 08 §6.
- **`FitText`'s neutral** ("needs input") was drawn in `outline`. It is now the secondary text
  role, so it stays AA with the quieter outline (`fit_status_test.dart` asserts AA).

### 2.4 Other tokens

`AppPalette` also holds the night-event, Moon, chart and Bortle colours (TASK 12.4) and `caution`
(S1.9).

The current native night-browser timeline and legend (`lib/presentation/widgets/night_browser_sections.dart`) read `HybridTokens.skyDay/skyCivil/skyNautical/skyAstronomical/skyDark` and `moonUp/moonFree`; lane position, thickness and text retain meaning beyond colour. The altitude chart (`lib/presentation/widgets/altitude_chart_widget.dart`) still reads AppPalette chart bands and `chartMoon`. They are different presentation roles, not a blanket migration from AppPalette.

Current Weather (`lib/presentation/widgets/weather_hybrid_view.dart`) uses `HybridTokens.selectedHourFill/selectedHourText/selectedHourRule` for its selected hour axis, `caution` for the dew-margin heuristic, and `weatherNotice` for aging/stale, unknown-gap and offline-cache notices. `hourBackground/hourText` and `weatherCaution` remain defined but have no presentation callers at this baseline. Do not infer adoption from a token's name or replace freshness/unknown text with colour.

The Culmina mark's colours (owner, 2026-10-23) are generated with its geometry by
`tool/culmina_mark.py` into `lib/presentation/shared/culmina_mark_geometry.dart`
(`CulminaMarkColors.light`, `.dark`, `.field`): the surface decides them, as in the splash and the
lockup with the name. The launcher icon keeps its own refreshed dark field in every theme.

### 2.5 Status and state tokens (S5.4)

The following table describes AppPalette's fit tokens and `PlanState.tone` helper (`lib/presentation/shared/plan_state.dart`), not the compact badges' colour map.

| Token | Light | Dark | Field | Used for |
| --- | --- | --- | --- | --- |
| `statusFits` | `#37352F` | `#EBEBEA` | `#FF0000` | Fits |
| `statusTight` | `#754600` | `#FFCA70` | `#FF0000` | Tight: a caution, at least as prominent as Fits (S1.9) |
| `statusDoesNotFit` | `#B00020` | `#F28B82` | `#FF0000` | Doesn't fit |
| `statusNoWindow` | `#B00020` | `#F28B82` | `#FF0000` | No window (a real night with none) |
| `statusNeutral` | `#5A5955` | `#A5A5A3` | `#AA0000` | Needs a target / a block: a missing input is not a verdict (UX-15(2)) |
| `stateUnsaved` | `#754600` | `#FFCA70` | `#FF0000` | Not saved, Saved · changed |
| `stateSettled` | `#37352F` | `#EBEBEA` | `#FF0000` | Saved, Tracking, Completed |
| `stateQuiet` | `#5A5955` | `#A5A5A3` | `#AA0000` | Partly, Not done, Old log |

- **Fit caller:** `FitText.color` in `lib/presentation/shared/night_text.dart` maps FitState to
  the AppPalette status tokens; `StatusBlock` reads that mapping for its verdict.
- **Contrast:** every token is AA as text on every surface in light and dark.
- **Field mode:** everything is red, so the word carries the difference.
- **Plan-state tones are tones, not verdicts.** Unsaved work draws attention; nothing is coloured
  good or bad (the ADR-012/ADR-013 spirit).

Current `PlanStateLabel` (Tonight/planner) and `EntryStateBadge` (Logbook/opened entries) in `plan_state.dart` instead use `HybridTokens.success/successWash` for Saved/Tracking/Completed, `caution/cautionWash` for Not saved/Saved · changed/Partly, and `AppPalette.textPrimary` on Hybrid `selection` for Not done/Old log. `EntryStateBadge.due` (Not recorded) uses the caution pair. Preserve state words and existing icon variants: a saved or completed state is not a Fits verdict or a scientific quality score. Field roles remain red/black; this documentation grants no new owner/device acceptance.

## 3. Type scale (`AppTypography.scale`)

Every theme uses one scale with the bundled owner-selected Geist family; sizes are sp
(scaled by the user's text size). Most shared roles use zero letter spacing; named roles such as sectionHeading and the adopted
Hybrid Home roles carry their explicit tracking. The 2026-10-20/21
[native migration](design/WEB_TO_FLUTTER_MIGRATION.md) supersedes the earlier
prototype-only guidance for original Hybrid / Geist.

| Style | Size / line | Weight | Role |
| --- | --- | --- | --- |
| `displaySmall` … `displayLarge` | 36/44 … 57/64 | 400 | Rare; large numbers |
| `headlineSmall` … `headlineLarge` | 24/32 … 32/40 | 400 | Rare |
| `titleLarge` | 20/28 | **600** | Screen-level headings |
| `titleMedium` | 16/24 | **600** | Section and card headings; the answer |
| `titleSmall` | 14/20 | **600** | Group headings |
| `bodyLarge` | 16/24 | 400 | Prominent body text |
| `bodyMedium` | 16/24 | 400 | Body text, values, labels |
| `bodySmall` | 13/20 | 400 | Captions, metadata (usually `textTertiary`) |
| `labelLarge` | 14/20 | 500 | Buttons |
| `labelMedium` / `labelSmall` | 14/21 / 13/20 | 500 | Chips, small labels |

- Titles are heavier than Material's defaults (500 or 400) so headings carry the hierarchy.
- The app bar's title is 22/27.5, weight 500. `hybridAppBar` measures its
  wrapping title and preserves the full text scaler.
- Tonight uses its own wrapping semantic header (`homeHeading`, 29/34.8,
  weight 500, tracking -0.87). Its plan heading is 20/28, weight 600,
  tracking -0.15; target 18/23.4, weight 500, neutral tracking; rig uses `body` 14/21.7.
  The editorial night heading is Geist 25/32.5, weight 500, tracking -0.5.
  The wordmark and welcome link are 13/17.55 (600 and 400 respectively).
- Hybrid fit-line measures use 12 sp captions, a 4 dp caption/value gap,
  15 sp/500 tabular values and 20 dp between groups. The other StatusBlock
  layouts retain their existing title/body roles.
- Hybrid Home fit explanations use 14 sp / 1.55, condition values 16 sp.
  Compact navigation labels (11 sp) and calendar captions (10 sp) are explicit
  source-derived `HybridTokens` exceptions, not a reduced base text scale.
- Tested: every style in every theme has the scale's size, line height and weight, and none is
  under 12 sp.

### Named Hybrid roles (current source)

These supplement the Material-role table above; they are not interchangeable aliases. Exact implementations/call sites in `app_typography.dart` remain the value authority.

| Named role | Size / line | Weight |
| --- | --- | --- |
| `screenTitle` | 22/27.5 | 500 |
| `sectionHeading` | 20/28, tracking -0.3 | 600 |
| `sectionSubject` | 18/23.4 | 500 |
| `itemTitle` | 16/22.4 | 600 |
| `rowTitle` | 16/24 | 500 |
| `value` | 15/21.75 | 400 |
| `body` | 14/21.7 | 400 |
| `caption` | 13/19.5 | 400 |
| `dense` | 12/18 | 400 |
| `support` | 14/22 | 400 |

The owner-approved Concept B task supersedes the earlier Source Serif 4 and Roboto role exceptions: all production prose uses Geist. `nightHeading` is 25/32.5, 500, tracking -0.5; `answerHeading` is 28/36.4, 500, tracking -0.56. Root `navigationLabel` uses Geist 11; calendar compact sizes remain explicit HybridTokens exceptions. MaterialIcons remains an icon font; historical font assets and frozen browser references are preserved. P-2 sets filled primary labels to 16/600; secondary actions retain their own role. These instructions document implemented adoption, not fresh visual/device acceptance.

## 4. Spacing and radius

| `AppSpacing` | px | Use |
| --- | --- | --- |
| `xs` | 4 | A label and its value |
| `sm` | 8 | Rows within a section |
| `md` | 16 | Component content padding and some page layouts; not a universal screen gutter |
| `lg` | 24 | Between sections |
| `xl`, `xxl` | 32, 48 | Large separations; 48 is also the minimum tap target |
| `gutter` | 20 | Existing Hybrid side-padding step; actual screen geometry is caller-owned |
| `section` | 28 | Existing Hybrid section-spacing step |

The scale supplies reusable distances; component padding and screen gutters are distinct. `lib/presentation/shared/detail_scaffold.dart` uses `md` for page sides and summary-card padding. Current Tonight (`lib/presentation/screens/tonight/tonight_home_screen.dart`) uses literal `EdgeInsets.fromLTRB(20, 20, 20, 24)` in its ready/no-site and bootstrap-error lists; the planner (`lib/presentation/screens/home/home_screen.dart`) uses `(20, 8, 20, 32)`. Both have 20 logical px sides, matching `gutter` without reading it. The Stage 5 rhythm in the `app_spacing.dart` header is not a universal current geometry rule; do not normalize these screens to 16 or change code in a documentation reconciliation.

| `AppRadius` | px | Use |
| --- | --- | --- |
| `small` | 6 | Cards, sections, text fields, buttons |
| `menu` | 8 | Plan menus |
| `large` | 12 | Dialogs, bottom sheets, a swiped row's background |
| `pill` | 999 | Pills and chips |

## 5. The gallery

`test/presentation/design_system/design_system_gallery_test.dart` renders every token sample and
shared component in the light, dark and field themes at 100 % and 200 % text on a 412 px view. It
audits them like the route sweep (`accessibility_test.dart`): no layout exception, 48 px tap
targets, a label on everything tappable, and AA text contrast in light and dark. A sanity case
proves the audit catches a faint text and an unlabelled button. It also covers what the route
sweep cannot see: components no route uses yet, and dialogs. Each Stage 5 Task adds its components
to it.

## 6. Controls (S5.2)

All set through component themes in `AppTheme._withControls`, from the tokens only, so every
existing control follows them without a screen edit. A widget's own `styleFrom` (a size, a padding)
still merges over them.

### 6.1 Buttons: one hierarchy

| Role | Widget | Look | Use |
| --- | --- | --- | --- |
| **Primary** | `FilledButton` | Filled with `colorScheme.primary`, `onPrimary` text | The screen's one main action (the planner's **Save plan**, ADR-019 §6) |
| **Secondary** | `OutlinedButton` | Transparent, `textPrimary` text, a 1 px `controlBorder` | Other actions beside it |
| **Tertiary** | `TextButton` | `textPrimary` text only | Low-weight actions; Cancel in dialogs |
| **Destructive** | `FilledButton` or `TextButton` with `AppButtonStyles.destructive` / `destructiveText` | `error` fill, or `error` text | A delete or discard (S5.8's patterns) |
| **Icon** | `IconButton` with a `tooltip` | `onSurfaceVariant` icon | Toolbar actions; the tooltip is its label |

- **All buttons:** at least 48 dp tall (filled, outlined and elevated draw 48; text and icon buttons
  keep Material's padded 48 dp tap target). Small radius. Labels: the primary (filled) one 16/600
  (`.primary-button` in the accepted Hybrid reference; QA-04, 2026-10-23), the others `labelLarge`
  14/500 (`.secondary-button`).
- **Disabled:** `textDisabled` text on transparent (secondary, tertiary), or Material's disabled
  fill (primary). WCAG exempts disabled controls from contrast.
- **`ElevatedButton`** has no elevation in this flat design. It is themed as the secondary role on
  the surface fill. New code uses `OutlinedButton`; the elevated ones are replaced as their screens
  are redesigned (S5.9's adoption list). Since S6.2 the planner's Save plan is the filled
  primary button, alone in its bottom bar, and Start is Track live in ⋮ (UX-34).

### 6.2 States and motion

- **Pressed:** a 16 % overlay of the foreground (`AppTheme.pressedOverlay`); Material's is 10 %.
  This answers 08 §8's weak "+" feedback. Focused 12 %, hovered 8 %.
- **Motion (`AppMotion`):** `highlight` 1500 ms for the fading mark on what an edit changed (S6.9, a
  capture block's row; none with reduced motion); `short` 120 ms for a state change in place, `medium` 180 ms for content
  appearing or collapsing, one curve (`Cubic(0.16, 1, 0.3, 1)`).
  `AppMotion.duration(context, …)` returns zero when the platform asks for less motion
  (`disableAnimations`). Every Stage 5 component animates through it. Subtle only
  (`.agents/rules/05-ui-design.md`).
- **Never give `AnimatedSize` a zero duration:** it throws a layout assertion (S5.5's
  reduced-motion test found it). With reduced motion, leave the `AnimatedSize` out, as
  `CollapsibleSection` does.

### 6.3 Text fields

- **Hybrid outlined fields:** the enabled outline is 1 px in `controlBorder`
  with the small radius; focus draws it 2 px in `primary`, an error in `error`.
  The earlier quiet underline (08 §6) was superseded by native Hybrid adoption.

  The field's geometry is unchanged, so no field's text room shrank (TD-069's fit test passes).
- **Label** `textSecondary`; the floating label is `primary` when focused and `error` on an error.
  **Hint** and **helper** are `textTertiary`, **error** text is `error`, and prefix and suffix icons
  are `textSecondary`: all AA. A `filled` field uses the surface colour.
- A field that sets its own border keeps it. The target search, for example, is a filled box with
  no line.

### 6.4 Dialogs, sheets, menus, messages, dividers

- **Dialogs:** the raised surface, a 1 px border, the large radius. The title is `titleLarge` in
  `textPrimary`; the content is `bodyMedium` in `textSecondary`.
- **Bottom sheets:** the raised surface, top corners large.
- **Popup and dropdown menus:** the raised surface, a 1 px border, the small radius; items
  `bodyMedium` in `textPrimary`.
- **Messages (snackbars):** light and dark invert: `textPrimary` background, background-coloured
  text and action, AA. Field mode keeps its dim message (a `#330000` background with red text),
  never a bright red block.
- **Dividers:** 1 px in `border` (TASK 12.4).

### 6.5 Icons

- **Current Hybrid glyphs:** `lib/presentation/shared/hybrid_icon.dart` carries adopted source paths; Material icons remain native/fallback controls. The following Stage 5 Material set is historical/general guidance, not an instruction to replace Hybrid glyphs. Material defaults are 24 dp, outlined where a variant exists. An icon-only
  button always has a `tooltip`.
- **One icon per common action:**
  - add `Icons.add`;
  - edit `Icons.edit_outlined`;
  - delete `Icons.delete_outline`;
  - reorder `Icons.drag_indicator`;
  - more `Icons.more_vert`;
  - info `Icons.info_outline`;
  - expand `Icons.expand_more` / collapse `Icons.expand_less`;
  - open a detail `Icons.chevron_right`.
- **Historical Stage 5 adoption note:** the following observation predates later capture-plan implementations: “The capture plan's current `drag_handle` and red delete icon (08 §14) change when Stage 6 adopts this set.” Inspect current capture-plan source/callers and [BASELINE](design/BASELINE.md) for implemented controls; this note is not pending work.

## 7. Words (S5.3)

- **One name per concept** (RD-14; ADR-019 §10). The owner's glossary
  (`refinement/research/S4.R5_LIBRARY_AND_VOCABULARY.md` §5) is normative, and
  `lib/presentation/shared/app_words.dart` (`AppWords`) holds its words once, as `QuantityText`
  holds number formats:
  - Rig;
  - Plan: New plan, Save plan, Your plan, Copy to another night;
  - Logbook; Night;
  - Capture plan and block;
  - the plan states (Not saved · Saved · Saved · changed) and the results (Tracking · Completed ·
    Partly · Not done · Old log);
  - Record result, Edit result, Track live (optional), Completed as planned;
  - the verdict words and the headline ("Fits: … needed of … usable");
  - Dark, Darkness limit, Imaging window, and the twilight names (the Night & Moon detail only);
  - Integration, Imaging time, Time needed, Total time, Budget details;
  - Relative stacking gain (√N vs one frame), never "SNR";
  - Site, Library, Progress by target;
  - Export as file, Name (optional).
- **New strings use `AppWords`**; a screen never spells a glossary term itself.
  `app_words_test.dart` pins every word to the glossary, so changing one is changing the owner's
  glossary.
- **The retired terms**: "Equipment profile", "Session planner", "Draft", "Legacy", "True Night
  Window", "Astro Dusk/Dawn", "Window load", "Acquisition", "Session budget".
  - `retired_terms_test.dart` scans `lib/presentation`'s string literals for them (any case,
    plurals included). Imports, `Key` values, comments and identifiers are exempt.
  - It compares what it finds with an explicit **baseline**: 16 occurrences in 8 files at
    `38925dd`, listed in the test. A new occurrence fails. A baseline entry that no longer occurs
    also fails, so the baseline only shrinks.
  - Stages 6, 8 and 9 remove entries as they redesign their screens, and P9.2 empties it (S5.9
    maps each entry to its Stage).
  - It reads a line at a time, so a term split across two string literals is not seen.

**S6.8 (2026-09-28), the examples' words:** "Start from the example plan" is RD-04's own phrase;
"Example plan" (TASK 4.4) and "Example rig" name the shipped examples. They live in `ExampleText`
(`lib/presentation/shared/example_text.dart`), not in `AppWords`, which holds the owner's glossary;
the owner may move them there.

**S6.6 (2026-09-28), two status words outside `AppWords`:** the planner's status applies the
glossary's "Needs a …" pattern (Needs a target, Needs a block) to a missing site and a missing rig:
**"Needs a site"** and **"Needs a rig"** (`PlanStatus.needsSite`, `needsRig`). They are not added
to `AppWords`, which holds the owner's glossary; the owner may confirm them there.

## 7a. Components and patterns

### The status block (S5.4; `lib/presentation/shared/status_block.dart`)

The answer first (ADR-019 §6; addendum §3.1–§3.2).
- **The headline:** `titleMedium`, a semantic header, in the state's status colour. It uses the
  glossary's words:
  - with both durations known: "Fits: 2 h 5 min needed of 4 h 20 min usable" (likewise Tight and
    Doesn't fit);
  - with a duration unknown: the word alone. Unknown is never shown as zero;
  - otherwise: "No window", "Needs a target" (or the missing word the screen passes), "Needs a
    block".
- **Then:** the reason (`textSecondary`); optional key numbers, each a label (`bodySmall`,
  `textTertiary`) above its value (`titleSmall`, `textPrimary`), one semantics node per pair, in a
  wrapping row (S6.16; they were inline pairs); an optional action slot (fill or trim, an outlined
  button since S6.16).
- **Current adoption:** `plan_status.dart` draws the planner's own Hybrid answer and uses `StatusBlock.headline` for wording; it does not instantiate this component or its historical 4px status edge. Tonight instantiates `StatusBlock` with its Hybrid fit-line variant. The component's other layouts remain capabilities, not universal screen requirements.
- **Plain values in.** The state, durations and reason come from the fit analysis through the
  ViewModel; durations are formatted with `QuantityText`. It calculates nothing (trap 13).
- `StatusBlock.headline(...)` is pure and tested.

### The plan-state label (S5.4; `lib/presentation/shared/plan_state.dart`)

- **`PlanState`:** Not saved · Saved · Saved · changed · Tracking · Completed · Partly · Not done ·
  Old log (ADR-019 §3). The stored statuses stay internal; "Draft" is never shown.
- **The mapping:** `PlanState.from(status:, savedBefore:, legacy:, resultKind:)` reads existing stored fields. Legacy is Old log; draft is Not saved or Saved · changed according to prior save; planned/inProgress map to Saved/Tracking; completed with `ResultKind.partly` maps to Partly, other completed results to Completed; abandoned maps to Not done. Partly is implemented, not a future Stage 8 placeholder.
- **Current labels:** `PlanStateLabel` and `EntryStateBadge` use the compact Hybrid foreground/wash pairs described in [§2.5](#25-status-and-state-tokens-s54), not an outlined labelMedium pill driven by `PlanState.tone`. Preserve their state words and existing icon variants; neither widget is tappable. This describes source adoption, not a new owner/device acceptance.

### The night and opportunity timeline (S6.12; `widgets/altitude_chart_widget.dart`)

`AltitudeChartWidget` remains available; `tonight_opportunity_widget.dart` contains a call, but that wrapper has no production instantiation in the current `lib/` tree. Current Night & Moon/Weather use the separate Hybrid browser in `night_browser_sections.dart`. The primitive's following full/compact capabilities are not evidence of current Night/planner adoption.

One primitive (`AltitudeChartWidget` over `TimelineData`) at two `TimelineDensity`s: `full` (200
px; the altitude grid with its labels in a left gutter, the Moon, the legend) and `compact` (88 px;
the bands, windows, target and time axis). Bands use `chartDay`/`chartTwilight`/`chartDark`, merged
per run, with `chartGrid` edges; windows `chartWindow`; the target `chartTarget`; "Capture ends" a
dashed `chartTarget` line; "now" `chartNow`/`chartNowCentre`. Labels are `labelSmall` in
`textSecondary`, scaled with the text size, outside the plot. A chart of the same night, target
and windows is never drawn twice.

### The stacking-gain graph (S6.11; `widgets/capture_plan/stacking_gain_graph.dart`)

Current `StackingGainGraph(curve:, groupLabel:, caption:, recorded:)` reads the existing `StackingGainCurve`; `caption` and recorded-frame count are optional. The graph presents relative improvement over integration time **normalized to the plan (1.00×)**, with text/legend entries for the plan and comparison and, when supplied, a recorded point. It is not absolute SNR or an image-quality prediction; preserve each filter/exposure group's meaning and the curve's scientific inputs.

`lib/presentation/widgets/capture_plan/stacking_gain_graph.dart` owns the current layout and text alternative: `StackingGainPainter` uses a 320:150 logical aspect reference, a Hybrid `gainStart/gainEnd` line gradient and restrained area wash, with AppPalette border/text roles. It is not the old fixed 48px-high AppPalette-only graph. `capture_budget_summary.dart` supplies the current caller data. Existing adoption is recorded as HT-F15 in the [accepted transfer record](design/migration/HYBRID_TRANSFER_STATUS.md), with its §9 exclusions; later owner/device acceptance limits remain in BASELINE/PROGRESS. The S6.11/S6.16 wording in the dated update log is historical provenance, not a mandate to restore old geometry or colours.

### The change mark (S6.10; `lib/presentation/shared/change_mark.dart`)

Cause and effect after an edit (P6.9's notes): `ChangeMark(value:, child:)` tints its child when
`value` (what the ViewModel already shows) changes, fading over `AppMotion.highlight`; never on the
first build, never with reduced motion; it keeps no calculation state. Adopted by the planner's
status and Budget details' summary. A capture block's row uses the same idea on the tile's own
colour (S6.9), since a `ListTile` must not sit on a coloured box.

### The collapsible section (S5.5; `lib/presentation/shared/collapsible_section.dart`)

Detail one tap away (ADR-019 §7; RD-06, RG-06: progressive disclosure, no modes).
- **The header:**
  - it is at least 48 dp and the whole row is tappable, with an `InkWell` ripple;
  - it shows the title (`titleSmall`, `textPrimary`), the **factual summary** (`bodyMedium`,
    `textSecondary`) and a chevron that turns (`AppMotion.short`);
  - the summary stays visible when the section is open.
- **The summary states facts, never a verdict** ("4 lines · 2 h 35 min total", not "looks
  good"). The verdict belongs to the status block. What each summary says is decided where it is
  adopted (Stage 6).
- **The content:** it opens below the header (`AnimatedSize`, `AppMotion.medium`; none with
  reduced motion). It is not built while closed.
- **Semantics:** one button node labelled "title, summary", with `expanded` true or false, the
  hint "Expand" or "Collapse", and a tap action (trap 17: `enabled` and `onTap` are set).
- **Remembered per `sectionKey`** (`DisclosureViewModel`, in `AppViewModels`; loaded before the
  first frame, like field mode):
  - closed by default, unless the caller passes `initiallyOpen`;
  - stored in `DisplayPreferencesRepository` (`section.<key>` in SharedPreferences);
  - a store that cannot be read or written is logged, and the section still opens and closes;
  - keys are stable names such as `planner.budgetDetails`: never rename one without a reason.
- **In the planner (S6.7):** five sections, their keys in `PlannerSections`
  (`lib/presentation/widgets/planner_sections.dart`):

  | Section | Summary (a fact) | Content |
  | --- | --- | --- |
  | Budget details | "Time needed 2 h 5 min · Total time 3 h" (S6.10: the glossary's words; marked when an edit changes it) | Every ADR-009 line in the glossary's words (Integration, Imaging time, Time needed, Calibration during and outside the window, Setup, Total time, Library calibration); the zone rule when the setup time is shown |
  | Relative stacking gain (√N vs one frame) | "Per filter and exposure, against one frame" | The √N explanation; the √N values stay visible below the section (SI-003) |
  | Assumptions | "Darkness limit −18° · minimum altitude 30° · margin 15 %" (the constraints that shape the window stay in view) | Every overhead and threshold, the placement rule, the link to Settings |
  | Specifications (the rig) | "400 mm · f/5.0 · Tracking: Guided" (the focal ratio's review flag stays in view) | Focal length, focal ratio, sensor, tracking. The values the plan uses and the capability warnings stay on the card |
  | Sky darkness | "Bortle 4 · SQM 21.30 mag/arcsec²", "Unknown", "not saved" | The Bortle picker, the values with source and date, the light-pollution map link |

  The accessibility sweep also audits the planner with every `PlannerSections.all` key open, so a
  new section's key joins that list.
- **The Bortle picker (S6.7):** the class's conventional colour is a swatch beside the text, which
  uses the text roles, at 48 dp. The old badge (white text on the class colour, 32 px high) failed
  the tap-target and contrast guidelines once the sweep could see it.

<a id="context-line"></a>

### The context line (S5.6; `lib/presentation/shared/context_line.dart`)

`ContextLine` exposes independent site/night choices. The constructor requires nullable `siteName` and `night` plus `onSite/onNight`; defaults are `framed:false`, `compact:false`, `noSiteLabel:ContextLine.noSite` ("No site set"). `siteDescription`, `zoneId` and `nightStartUtc` are optional and nullable.

- **Component variants:** the default layout wraps; `compact:true` uses content-sized single-line choices separated by 4 dp. The site flexes into remaining space and can ellipsize; the date retains its natural width. A short site no longer reserves an expanded column before the date (owner correction, 2026-10-24). `framed:true` optionally wraps either layout in a `context.card`. Current choices use `AppTypography.caption` and Hybrid icons/chevron in `textPrimary`, not the older titleSmall/secondary-icon styling.
- **Accessibility:** each choice retains a 48 × 48 dp minimum, enabled button semantics with its own tap action, a Choose a site/night hint and a full-label tooltip. Compact site semantics/tooltip use `siteDescription ?? siteName ?? ContextLine.noSite`; the wrapping variant uses `siteName ?? ContextLine.noSite`. `noSiteLabel` changes visible fallback text only. The full night label is "Night of …", formatted from the supplied evening date by `NightTimeFormatter.eveningDate`, even when compact display omits that prefix.
- **Night and zone visibility:** the night choice depends on `night != null`; a zone caption in `textTertiary` requires both `night` and `nightStartUtc`. `zoneRule` delegates to `NightTimeFormatter.zoneCaption` (site zone or explicitly labelled device zone). A null `siteName` alone does not suppress a supplied night: callers must pass `night:null` and no night instant without a site (ADR-007 §9).
- **Current Tonight caller:** `_Context` in `lib/presentation/screens/tonight/tonight_home_screen.dart` sets `compact:true`, `noSiteLabel:ContextLine.setSite` ("Set site"), compact `SiteLabel` display plus `siteDescription:SiteLabel.of(siteVm)`, `planVm.eveningDate` and `zoneId`. It leaves framing off and omits `nightStartUtc`, so no inline zone caption appears. `SessionPlanViewModel` supplies a null evening date for the default/no-site location. Callbacks in `home_context_sheets.dart` open Manage sites or the direct calendar (TD-120); confirmation updates the working plan, cancellation preserves it.
- **Current planner:** `lib/presentation/screens/home/home_screen.dart` uses `HybridPlanRow` ("Site and night", `planner.context`) opening `PlanContextScreen` via `openPlanContext`, not a `ContextLine` instance. Apply changes updates the working plan; Close discards unapplied choices. It still uses `ContextLine.noSite` and `pickNight` for Copy. Keep this flow distinct from Tonight's direct actions.

S5.6/S6.16 are adoption provenance, not a mandate to frame current callers: the [owner's Stage 6 decision](DECISIONS.md#stage-6-corrective-pass-decided-td-075td-080-the-planners-order-the-core-screens-finish-stage-6-2026-09-28) made a box/card optional. Current Hybrid adoption is recorded by HT-H01/HT-P01/HT-P02 in the [transfer record](design/migration/HYBRID_TRANSFER_STATUS.md); the later [TD-120 refinement](design/migration/TONIGHT_CONTEXT_FIXES_2026_10_23.md) retains its pending owner acceptance. Component/gallery variants do not prove current screen adoption or new device acceptance.

**The night picker** (`pickNight`, same file): the date picker in the app's theme, from a year ago
to five years ahead as the planner's picker allows, titled "Choose a night". It returns the chosen
evening as a `CalendarDate`, or null when cancelled. Tested red or black in field mode **by its
theme alone**, without the app-wide red filter.

### The detail-screen template (S5.7; `lib/presentation/shared/detail_scaffold.dart`)

`DetailScaffold` remains an available shared template, exercised by `galleryDetailPage` in `test/presentation/design_system/gallery_entries.dart`. Current production code has no `DetailScaffold(...)` instantiation; Night & Moon/Weather use their own Hybrid composition. S5.7 and ADR-019 §9/addendum §3.4–§3.5 record the earlier template intent, not current adoption. Its supported anatomy is:
1. **The header:**
   - the title (`titleLarge`, a semantic header);
   - its context ("Fri, Nov 13 · Ljubljana", `bodyMedium` in `textSecondary`);
   - the zone rule, exactly once (`bodySmall` in `textTertiary`; `ContextLine.zoneRule`).

   All three wrap at 200 % text. So the title lives in the page header, not in the app bar, which
   keeps only back and the actions (an app bar's title cannot wrap).
2. **The summary**, on a card: facts, no score and no good or bad colour (ADR-012 for weather).
3. **The full content:** the sections, separated by dividers. A long section is a
   `CollapsibleSection`.

**Every time on the page is in the zone the header names; a section never repeats the zone
caption.** The gallery sweeps a sample Night & Moon page (not a route) in the three themes at
100 % and 200 % text in that recorded gallery contract. A gallery sample does not prove a current route uses this template; inspect the actual screen and caller before adopting it.

### Launch (owner, 2026-10-23; `lib/presentation/shared/launch_gate.dart`)

The full launch gesture is shown before the app opens. The Android splash (12+) and the launch
window show the still mark on the first screen's background (288 dp canvas, centred); Flutter's
first frame is the same mark in the same place, and `LaunchGate` plays the gesture from
`CulminaLaunchTimeline` (generated): the still mark (0–150 ms), a light along the inner arc in its
own width (150–750 ms), the star's accent — lighter and 6 % larger, then back (650–1,100 ms) — and
the static mark (1,100–1,400 ms). The app opens when the gesture has ended and the app is ready:
the mark fades on the opaque launch background (150 ms), then the background fades to the app
(150 ms). Until then the app takes no taps and is not in the semantics tree. Waiting longer shows
a thin indeterminate line under the still mark (no progress value, no replay). Reduced motion: the
still mark, the app as soon as it is ready. A failed start: "Culmina couldn't start." with Try
again. Previews: `launch_gate_preview.dart` (the same component; slow motion only there).

`StartupMark` / `StartupCover` show the same still mark above the app only while a startup retried
from the bootstrap error reloads.

### Confirmation, feedback and deleting (S5.8; RD-09 = M + S1, DECISIONS E.1)

The interaction contracts below remain applicable. References to “today's” dialogs and adoption in Stages 6/8/9 preserve the original rollout context; they do not describe current unfinished work or override later approved caller-specific presentation. Inspect actual callers and [BASELINE](design/BASELINE.md) for current adoption.

**Which pattern for which action:**

| Action | Pattern |
| --- | --- |
| Replacing a plan with unsaved changes (New plan, Copy, Open; P6.1) | `askUnsavedChanges`: Save · Discard · Cancel |
| Deleting an edit inside a plan: a capture block | At once, with `showUndo` |
| A one-tap change to a plan's blocks: Fill or Trim, a block edit saved in its dialog, "Start from the example plan" (S6.16, TD-079) | At once, with `editBlocksWithUndo` (`widgets/capture_plan/blocks_undo.dart`) over `showUndo`: Undo restores the blocks and the example badge exactly through the normal autosave, and is refused, with a message, once the blocks were edited again; nothing outlives the message |
| Deleting a stored record: a rig, a target, a site, a Logbook entry | `confirmDestructive`, then delete |
| Abandon (a live run), Restore (a backup), resetting data | `confirmDestructive` with its own verb |
| Any action that succeeded: New plan, Copy, Open, Save | `showDone` ("New plan started", "Copied to …", "Plan saved") |
| Any action that failed | `runWithFeedback` (TASK 15.1) |

- **`askUnsavedChanges`** (`confirmation_patterns.dart`; addendum §3.3):
  - "Unsaved changes", '"M42 · Fri, Nov 13" has changes that are not saved.', then Cancel ·
    Discard · Save;
  - Discard is styled destructive;
  - back or a tap outside is Cancel;
  - it returns the choice only. Since S6.3 the planner's `askBeforeLeavingPlan`
    (`unsaved_plan_prompt.dart`) wraps it and does Save; the lifecycle does Discard (a never-saved
    plan deleted, a saved one reverted, S4-DEF-04 = R). The S1.6 guard is gone.
- **`confirmDestructive`** (same file):
  - the title names the item ('Delete rig "Refractor 400"?') and the message the consequence;
  - Cancel, then the destructive verb (`AppButtonStyles.destructiveText`);
  - it is true only when the verb is tapped: Cancel, back and a tap outside all keep the item. It
    replaces today's four differently worded delete dialogs as their screens adopt it.
- **`showUndo`** (`delete_patterns.dart`):
  - "Block deleted · Undo", shown after the edit is applied;
  - it reports **exactly one outcome**: `onUndo` when Undo is tapped, otherwise `onCommit` when
    the message closes (it timed out after 6 s, was swiped away or was replaced);
  - `persist: false` is required, because Flutter otherwise keeps any message with an action on
    screen until it is dismissed, and Undo would never commit (the time-out test found it);
  - the adopter restores exactly and tests its own restore.
- **`showDone`** (`failure_feedback.dart`, next to `runWithFeedback`): a short message naming what
  happened. It replaces the previous message.
- **The visible Delete, `DeleteButton`** (S1; UX-38): an icon button (`Icons.delete_outline`)
  whose tooltip is its label ("Delete rig"). Where it sits is decided at adoption: blocks in Stage
  6, the Logbook in Stage 8, the Library in Stage 9.
- **`SwipeToDelete`** (S1; 08 §20):
  - a swipe from the end calls the **same handler** as the visible Delete;
  - the row springs back at once, and is never left slid away behind a dialog. The handler then
    confirms or deletes with Undo, and the list drops the row when the item is really gone;
  - the background is the error colour with a delete icon, large radius.
- **Field mode:** the prompt, the confirmation and both messages are red or black by the theme
  alone (a pixel test without the app's red filter). The message is the dim field message, never a
  white flash.

## 8. Known gaps, for adoption

**Historical Stage 5 snapshot, preserved for provenance.** The counts, colours, missing adopters and future-tense instructions below describe that snapshot, not current unfinished work. Subsequent Stage 6–9 adoption, Hybrid transfer, Concept B and approved corrections supersede it within their scopes. For the current contract, use §§2–7a with actual sources and [BASELINE](design/BASELINE.md); current pending work is only in [PROGRESS](refinement/PROGRESS.md). Do not execute this list as a backlog.

What S5.1 and S5.2 changed app-wide, and what they leave to the Stages that redesign screens:
- **Changed app-wide by the theme:**
  - default text is the primary role (light `#37352F` instead of black; dark `#EBEBEA` instead of
    white);
  - light secondary text is darker (`#5A5955`, AA; `#787774` was below AA: 4.48:1 on white and
    4.17:1 on the surface);
  - titles are heavier;
  - dialogs and date pickers sit on the raised surface;
  - in light, selected segments and the navigation indicator are a light grey with primary text
    (they were the secondary grey with black text);
  - (S5.2) field underlines and chip borders are the quiet control border instead of black or
    white; buttons share one shape, 48 dp primary and secondary heights, and a stronger pressed
    overlay; elevated buttons are flat and outlined;
  - (S5.2) dialogs are bordered with a smaller title; messages invert in light and dark;
  - (S5.2) dark mode's error colour is `#F28B82` (Material's `#CF6679` was 4.26:1 on the raised
    surface), so "Doesn't fit" and error text are lighter red in dark;
  - (S5.2) the planner's "needs input" status reads in the secondary text colour, as before
    neutral;
  - (S5.2) in field mode, outlined buttons and field lines are `#880000` instead of `#660000`
    (UX-39).
- **Left for adoption:**
  - screens still colour values with `colorScheme.primary` and labels with `colorScheme.secondary`
    (e.g. `InfoRow`), and pick sizes per widget (10 `fontSize` and 34 `fontWeight` overrides);
  - `AppPalette.muted` (Material grey) is below AA as text in light: text should use
    `textTertiary`, and `muted` stays for icons and empty-state glyphs until adopted;
  - radius literals (for example a swiped row's 12) move to `AppRadius` when their screen is
    redesigned;
  - (S5.2) the 7 `ElevatedButton`s become `OutlinedButton` or `FilledButton` by role, and the
    planner's Save plan becomes primary (P6.3);
  - (S5.2) icons follow §6.5 as their screens are redesigned;
  - (S5.8) the existing delete paths (a capture block at once without undo; swipe-only rigs,
    targets and Logbook entries behind a lingering dialog; a site's dialog) keep their behaviour
    until they adopt §7a's patterns (Stages 6, 8, 9). The S1.6 guard and the silent New and
    Duplicate were replaced by S6.2 and S6.3;
  - (S5.4) the planner, Tonight and the Logbook still show their own status texts ("Draft",
    "Planned, unsaved changes", "In progress", "Abandoned", "Legacy log", "Fit tonight: …"). They
    adopt `StatusBlock` and `PlanStateLabel` in P6.1, P6.3, P6.6 and P8.5.

## 9. Adoption (S5.9)

**Historical adoption map.** P-/S-IDs, task mappings, retired terms and rendered-evidence references below preserve the original Stage 5–9 plan and recorded updates. Future-tense or unmarked rows are not evidence of a current gap, and “today” in a table refers to its original snapshot. [BASELINE](design/BASELINE.md) routes the completed Concept B/Q1–Q6/VQA-030–032 implementation and remaining acceptance limits; [PROGRESS](refinement/PROGRESS.md) owns the next permitted action. Read this section only for adoption provenance, without rewriting its historical tables or restarting those stages.

Stage 5 changed no screen's structure or wording. The theme (§2–§6) already applies everywhere; the
words, components and patterns below are adopted by the Stage that redesigns each screen. The
P-IDs are the provisional Tasks of Stages 6, 8 and 9 (`refinement/POST_ROADMAP_PLAN.md`). Each
Stage's own planning freezes them, and may move an item between its Tasks; it may not drop one
without saying where it went.

**Stage 6, frozen 2026-09-27** (`refinement/POST_ROADMAP_PLAN.md`, "Stage 6 — frozen Task
sequence"): P6.1 → S6.2 (the app bar, `PlanStateLabel`, `showDone`, `pickNight`) and S6.3
(`askUnsavedChanges`); P6.2 → S6.8; P6.3 → S6.6; P6.4 → S6.7; P6.5 → S6.5; P6.6 → S6.13 (with
TD-073's site prompt); "the Stage 6 capture-plan work" (P6.8) → S6.9. P6.9–P6.11 → S6.10–S6.12. No
item was dropped. Where the tables below say P6.x, read the S-Task.

### 9.1 By screen

| Screen or widget (today) | Adopts | P-Task | Retired terms it removes from S5.3's baseline |
| --- | --- | --- | --- |
| The planner's app bar (`home_screen.dart`: "Session planner", "+", Duplicate) | `PlanStateLabel` in the title (target · night · state); `askUnsavedChanges` instead of the S1.6 guard; `showDone` after New plan, Copy, Open and Save; `pickNight` for Copy to another night; `AppWords` (New plan, Copy to another night) | P6.1 (**S6.2 and S6.3 done**). The identity is a strip under the app bar, which wraps | Session planner (removed by S6.2) |
| The planner's body (`home_screen.dart`: empty state, "Session Date", sections, bottom bar) | `StatusBlock` first; `ContextLine` + `pickNight` instead of the "Session Date" row; text roles and the type scale instead of explicit styles; the button hierarchy (Save plan filled, the `ElevatedButton`s gone) | P6.3 (**S6.6 done**: `PlanStatus`; the context line; no empty state; `InfoRow` text roles. **S6.16**: ADR-019 §6's amended order, the framed context line, the status edge, section headings in `titleMedium`, "Tonight for this target" in the text roles) | Equipment profile (the empty state; **removed by S6.6**) |
| Budget summary and assumptions (`capture_budget_summary.dart`, `capture_assumptions_panel.dart`), rig rows, sky-darkness detail | `CollapsibleSection` (Budget details, Assumptions instead of its `ExpansionTile`, the rig's rows, sky detail) with factual summaries; `AppWords` budget names | P6.4 (**S6.7 done**: `PlannerSections`, see §7a) | Acquisition, Session budget (budget summary; **removed by S6.7**) |
| Sky darkness and weather detail (`sky_darkness_widget.dart`, `weather_forecast_widget.dart`) | `DetailScaffold` for Night & Moon and Weather; the twilight names from `AppWords`, on the Night & Moon detail only | P6.5 (**S6.5 done**: `/night`, `/weather`) | Astro Dusk, Astro Dawn, True Night Window (with TD-051; **removed by S6.5**) |
| Tonight (`tonight_home_screen.dart`: site card, night rows, plan card, actions) | `ContextLine` instead of the site card; `StatusBlock` and `PlanStateLabel` in "Your plan"; rows to the P6.5 details; `showDone` for New plan | P6.6 (**S6.13 done**; **S6.16**, the owner's corrective pass: the page title in `headlineSmall`, the framed context line, "Your plan" in `titleMedium`, Open planner always the card's `FilledButton`, the two target rows with a line each) | Draft (Tonight's status; **removed by S6.13**) |
| The capture plan (`capture_plan_widget.dart`, `capture_block_dialog.dart`) | `showUndo` for a deleted block (RD-09 M; restore tested there); `DeleteButton`; `SwipeToDelete` if block rows swipe; the §6.5 icons (reorder, delete); the dialog's Save as the primary button | Stage 6 capture-plan work (the Stage 6 table's "Capture Plan" row; RD-09) (**S6.9 done**: `DeleteButton` + `showUndo` with an exact restore; `drag_indicator`; `FilledButton` Save; rows through `BlockText`; the change mark on `AppMotion.highlight`. The rows do not swipe, so no `SwipeToDelete`) | — |
| The result form and the live tracker (`results_screen.dart`, `execution_screen.dart`) | `confirmDestructive` for Abandon; `showDone` after Save result; `PlanStateLabel` | P8.2 (**S8.2 done**: `showDone` after Save result, `PlanStateLabel` in the review; the form's Abandon became Not done, so no `confirmDestructive` there), P8.4 | — |
| The Logbook and an entry (`logbook_screen.dart`, `session_detail_screen.dart`) | `PlanStateLabel` instead of `sessionStatusLabel`; `SwipeToDelete` + `DeleteButton` + `confirmDestructive` instead of the swipe-only `Dismissible`; `AppWords` (Logbook, Export as file, Old log, the budget names); `DetailScaffold` where an entry fits it | P8.5 (**S8.5 done** for the list: `PlanStateLabel`, `SwipeToDelete`, `confirmDestructive`, the entry's `DeleteButton`, `AppWords`); the entry's remaining items moved to P8.7 and are **done by S8.7** (`DetailScaffold`, Export as file, Old log, the budget names) | — (all removed) |
| The Library lists (`equipment_selection_screen.dart`, `target_selection_screen.dart`, `sites_screen.dart`) | `SwipeToDelete` + `DeleteButton` + `confirmDestructive` (one wording instead of four); the button hierarchy; `AppWords` (Rig, Add rig) | P9.1 | Equipment profile (the empty rig list) |
| The rig editor and the other editors (`equipment_editor.dart`, site and target forms) | The field look is already themed (§6.3); `AppWords` titles and labels; the dialog's Save as the primary button | P9.2 (with Stage 7 when it reworks the forms) (**rig editor: S7.6 done**: "Add rig"/"Edit rig", "Rig name", `FilledButton` Save, the pixel size once, "More (optional)"; **site editor: S7.5**: "Sky darkness (optional)") | Equipment profile (the editor's title; **removed by S7.6**) |
| Settings and About (`settings_screen.dart`, `backup_section.dart`, `about_screen.dart`) | `confirmDestructive` for Restore; text roles; `CollapsibleSection` where RG-13 keeps advanced settings | Stage 9 (Settings, after RG-13) and P9.2 | — |
| Messages with an action (`location_feedback.dart`, `start_session.dart`; TD-073) | A decision per message: keep until dismissed, or `persist: false` | P6.6 (the site prompt: **S6.13, kept until dismissed, with a close button**), P8.4 (Track live replaces Start) | — |
| Shared rows (`info_row.dart`, `planner_summary_card.dart`) | Text roles instead of `colorScheme.primary`/`secondary` for values and labels | With the screens that show them (P6.3, P6.4) | — |
| Deletion animations everywhere (08 §20) | `AppMotion` and `SwipeToDelete`; nothing else animates | Stage 9 ("deletion interactions and animations") | — |

### 9.2 By component: at least one adopter each

| Part (S5.x) | Adopted by |
| --- | --- |
| Text roles, type scale, surfaces, spacing, radius (S5.1) | Every redesigned screen: P6.3, P6.4, P6.5, P6.6, P8.5, P9.1, P9.2 |
| Button hierarchy, `AppButtonStyles`, field look, dialogs, messages, icons, `AppMotion` (S5.2) | P6.3 (Save plan primary), Stage 6 capture plan (icons), P9.1, P9.2; `AppMotion` through every component, Stage 9 animations |
| `AppWords` and the retired-terms baseline (S5.3) | P6.1, P6.3, P6.4, P6.5, P6.6, P8.5, P9.1, P9.2 (the last empties the baseline) |
| Status tokens, `StatusBlock` (S5.4) | P6.3 (the planner's status), P6.6 (Tonight's plan card) |
| `PlanState`, `PlanStateLabel` (S5.4) | P6.1 (the app bar), P6.6, P8.2, P8.5 |
| `CollapsibleSection`, `DisclosureViewModel` (S5.5) | P6.4, P6.5 |
| `ContextLine`, `pickNight` (S5.6) | P6.3, P6.6 (`ContextLine`); P6.1 (`pickNight` for Copy) |
| `DetailScaffold` (S5.7) | P6.5 (Night & Moon, Weather); their routes join the accessibility sweep |
| `askUnsavedChanges`, `showDone` (S5.8) | P6.1 (New plan, Copy, Open, Save); `showDone` also P6.6, P8.2 |
| `confirmDestructive` (S5.8) | P8.4 (Abandon), P8.5 (Logbook entries), P9.1 (rigs, targets, sites), Stage 9 Settings (Restore) |
| `showUndo`, `DeleteButton`, `SwipeToDelete` (S5.8) | Stage 6 capture plan (`showUndo`, `DeleteButton`); P8.5 and P9.1 (`SwipeToDelete`, `DeleteButton`) |

### 9.3 The retired-terms baseline, by Stage

| Baseline entry (`retired_terms_test.dart`) | Removed by |
| --- | --- |
| `home_screen.dart`: Session planner | P6.1 (**removed by S6.2**) |
| `home_screen.dart`: Equipment profile | P6.3 (**removed by S6.6**) |
| `capture_budget_summary.dart`: Acquisition, Session budget | P6.4 (**removed by S6.7**) |
| `sky_darkness_widget.dart`: Astro Dusk, Astro Dawn, True Night Window | P6.5 (**removed by S6.5**) |
| `tonight_home_screen.dart`: Draft | P6.6 (**removed by S6.13**) |
| `logbook_screen.dart`: Legacy (2), Draft | P8.5 (**removed by S8.5**) |
| `session_detail_screen.dart`: Legacy, Window load, Session budget | P8.7 (**removed by S8.7**) |
| `equipment_selection_screen.dart`: Equipment profile | P9.1 |
| `equipment_editor.dart`: Equipment profile | P9.2 (or Stage 7 if it reworks the rig form first) (**removed by S7.6**) |

After P9.2 the baseline is empty (S5.3; ADR-019 §10).

### 9.4 Rendered evidence

Host-rendered images of the gallery and the sample detail page, for the owner's review (optional,
non-blocking): `refinement/evidence/stage5/` and
[`refinement/evidence/STAGE_5_RENDERS.md`](refinement/evidence/STAGE_5_RENDERS.md). They are made
by the opt-in `test/presentation/design_system/render_gallery_test.dart`
(`ASTROPLAN_RENDER_GALLERY`), which stays outside the gate. Host renders only: they are not device
evidence.

---

# Appendix — Update log (moved from the file header on 2026-10-18)

*The dated notes that opened this file until 2026-10-18, verbatim (newest first).*

> **S9.9, 2026-09-29:** the secondary screens (the Library lists and editors, sites, About, Settings, backup, the detail screens, sky darkness, weather, results) use the text roles and `AppSpacing`/`AppRadius` only: the list titles' bold `TextStyle`s became `titleSmall`, "Saved sites" a header in `titleSmall`, every numeric `EdgeInsets` a spacing token (12 → `md`, the FAB clearance 88 as a token sum). `secondary_consistency_test.dart` keeps ad hoc styles out of those files. The planner and Tonight stay Stage 6's.

> **S9.8, 2026-09-29:** messages: every `SnackBar` through `AppMessages.showMessage` (motion from `AppMotion`, none under reduced motion; TD-081). `showDone` after a save, delete, rename, export, backup, or a restore prepared or cancelled; none for a setting whose effect shows on the same screen (D9-5).

> **S9.6, 2026-09-29:** two visualisations under the shared rules. "When is it dark tonight?": the twilight bar on Night & Moon (bands shaded from `chartTwilight` to `chartDark` by depth; the table of times is its text). "How cloudy is each hour?": a cloud bar under each hour's number on Weather (`muted` fill in a `chartGrid` frame; the number is its text). Neither computes a planning value; colour never carries the dew risk alone (an icon marks it).

> **S9.4, 2026-09-29:** Settings adopts section headings (`titleMedium`, marked as headers for screen readers) each with a one-line consequence (`bodySmall`), value-first rows (the value with its unit as the trailing text), a stepper (− value +, tooltips "<label>: less/more") for bounded counts and durations, and `confirmDestructive` for Restore ("Restore at next start").

> **S9.2, 2026-09-29:** the rig, target and site editors follow one form pattern: a sentence-case title from `AppWords` (Add rig / Edit rig, Add a target / Edit target, New site / Edit site), sentence-case labels, and one primary `FilledButton` labelled "Save" ("Save site" at the foot of the site editor, which loses its app-bar check). `showFailure` is the failure twin of `showDone` for a failure caught outside `runWithFeedback`. **The retired-terms baseline is empty** (§9.3), and the test now requires it.

> **S9.1, 2026-09-29:** the Library lists adopt `SwipeToDelete`, `DeleteButton` (the rig and target editors, the site row) and `confirmDestructive` ("Delete this rig?", "Delete this target?", "Delete this site?", one message shape: what is deleted, that saved plans keep what they recorded, that it can't be undone), `showDone` after a delete, and `AppWords` (Rigs, Targets, Sites; Choose a rig, a target, a site; Plan this target).

> **S8.2, 2026-09-29:** the result form adopts `PlanStateLabel` (its review) and `showDone` ("Result saved."); its outcomes and Not done reasons are `ChoiceChip`s in a `Wrap`, its counts typed fields (no ±1). §9's P8.5 rows for the entry now point to P8.7, as the plan's Stage 8 amendment already said.
> **S7.6, 2026-09-29:** `CollapsibleSection` gains a controlled use (`open` + `onToggle`): the caller holds the state and no `DisclosureViewModel` is read (the rig editor's "More (optional)", not remembered). The rig editor's "Equipment profile" title is gone (§9.3), with `AppWords.addRig`/`editRig` and Save as the primary (`FilledButton`). The site editor (S7.5) uses the remembered form for "Sky darkness (optional)".

> **S6.16, 2026-09-28:** §3 records the page title's headline role (Tonight); §7a the status block's key numbers and the planner's status edge, the framed context line, the √N graph's labels, and Undo for one-tap block changes; §9.1's Tonight and planner rows note the core screens' finish.

> **S6.13, 2026-09-28:** §9's Tonight and site-prompt rows are done; "Draft" left the baseline.

> **S6.12, 2026-09-28:** §7a adds the night and opportunity timeline.

> **S6.11, 2026-09-28:** §7a adds the stacking-gain graph.

> **S6.10, 2026-09-28:** §7a adds the change mark (`ChangeMark`); Budget details' summary uses the glossary's words.

> **S6.9, 2026-09-28:** §6.2 adds `AppMotion.highlight`; §9.1's capture-plan row is done.

> **S6.8, 2026-09-28:** §7 notes the examples' words (`ExampleText`).

> **S6.7, 2026-09-28:** §7a records the planner's five collapsible sections and the Bortle picker; §9's P6.4 rows are done.

> **Status:** living, built by Stage 5 (Design System Foundation; `refinement/POST_ROADMAP_PLAN.md`,
> "Stage 5 — frozen Task sequence"). It describes the **code as built**. Each Stage 5 Task adds its
> part; Stages 6–9 adopt it on the screens (see "Adoption", written by S5.9).
> **Updated:** 2026-09-27, S5.1 (foundation tokens: text roles, surfaces, type scale, spacing,
> radius; the gallery test), S5.2 (controls: buttons, fields, dialogs, sheets, menus, messages,
> icons; states and motion), S5.3 (words: `AppWords` and the retired-terms test), S5.4 (status
> tokens, the status block, the plan-state label), S5.5 (the collapsible section), S5.6 (the
> context line and the night picker), S5.7 (the detail-screen template), S5.8 (confirmation,
> feedback and destructive-action patterns, RD-09 = M + S1) and S5.9 (the adoption plan, §9, and
> rendered evidence). 2026-09-27, Stage 6 planning: §9's Stage 6 P-Tasks mapped to the frozen
> S6-Tasks (documentation only; the code is unchanged).
> **Code:** `lib/core/theme/` (`app_colors.dart`, `app_palette.dart`, `app_typography.dart`,
> `app_spacing.dart`, `app_radius.dart`, `app_motion.dart`, `app_button_styles.dart`,
> `app_theme.dart`).
> **Tests:** `test/core/theme/` (tokens) and `test/presentation/design_system/` (the gallery).


## Superseded navigation header (2026-10-18)

Historical header relocated on 2026-10-24; BASELINE and the active introduction replace its routing.

> **How to read this file (2026-10-18 documentation cleanup; no content changed).** Sections 1–9 are the
> design system as built in Stage 5 and adopted in Stages 6–9 (tokens in `lib/core/theme/`). The dated
> notes that opened this file until 2026-10-18 record later adoption steps (S6–S9); they are kept verbatim
> at the end ("Appendix — Update log"). Open UI decisions: CA-OD1, the brand in the UI tokens (before S16.6;
> `refinement/PROGRESS.md`).
