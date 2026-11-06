# Spacing and border

Revision: AFTER-DARK-1.2. Values live in [semantic tokens](tokens_semantic.md), except explicitly local layout constraints below. Use tokens by name; do not maintain another numeric scale.

## Grid and composition

1. Author base-screen frames at375px width with Hug-content vertical document flow by default. The owner-approved catalogue exception uses375×812 scrolling roots for6/8/24/27 and an Auto Layout footer outside the scroll on8, preserving the complete lists. Current dimensions/status belong to [REDESIGN_RUN](REDESIGN_RUN.md). Historical pilot dimensions remain evidence, not a second output requirement.
2. Use AppSpacing.gutter at each page edge. The accepted compact document flow uses AppSpacing.md (12px) between adjacent content blocks on new screens. AppSpacing.section (32px) is reserved for a genuinely independent document chapter; AppSpacing.itemGap remains for related internal rows. Do not choose 32px merely because the next block has a heading.
3. Reuse matched canonical compact records with their accepted AppSpacing.sm horizontal/vertical insets and retained row internals. Inputs and NightAhead wrappers add zero extra vertical row padding/gap; NightAhead retains its heading inset and 8px bottom inset. Fit uses its canonical compact figures; disclosures retain zero extra wrapper gap. For unmatched bounded groups use AppSpacing.md, or the generic Section record's sm horizontal/md vertical recipe where appropriate. Current owner correction (2026-11-04): use the Tonight/Plan block structure for subsequent screens. Give each coherent context, answer, scientific-browser or related-details group one raised surface with the matched 8px radius/insets and 12px separation; keep facts and prose flat inside the group, without decorative cards per item. See [authoring profile](AUTHORING_PROFILE.md).
4. Use AppSpacing.sm for related inline items and AppSpacing.xs for label/value stacks. Never use blank text layers as spacers.
5. App bars and bottom bars grow beyond their token minimum when labels wrap. System insets are separate measured frame layers, not content padding.
6. Use fill-width rows and hug-height content. For a two-column fact row, divide available width equally with AppSpacing.md between; stack below 240 px of content width multiplied by text-scale factor.
7. Do not nest more than one bounded surface within another. A chart or input may use an inset well; it is not another decorative card.
8. Action groups wrap in reading order. Each independent action keeps HybridTokens.minTarget; expanding row height is preferred to hiding the label.
9. Current base-screen runs show the persistence footer once in the Longread. A fixed save bar and safe-inset viewport are deferred unless separately requested in the [run checkpoint](REDESIGN_RUN.md). Historical F01 viewport guidance applies only to such authorized comparisons: reserve scroll-bottom space for the actual measured bar height plus safe inset.
10. Comparison boards use a **120 px horizontal gap** between each BEFORE and AFTER pair. This is canvas presentation geometry, not an app spacing token.

## Radius (5 rules)

1. Use AppRadius.small for bounded records, inputs and buttons.
2. Use AppRadius.menu for anchored menus.
3. Use AppRadius.large for modal/dialog or sheet outer corners.
4. New root destination tabs use AppRadius.small, never a pill or extra check. AppRadius.pill remains for compact status labels and explicitly retained historical/non-root recipes; do not turn ordinary rows into pills.
5. Plain sections, charts, table cells and the page canvas have square boundaries; avoid gratuitous corner rounding.

## Border width (5 rules)

1. Use ThemeData.dividerTheme.thickness for separators and ordinary outlines.
2. Use AppPalette.border for quiet separation and AppPalette.controlBorder for an identifying control boundary.
3. Focus uses AfterGeometry.focusRingWidth and ThemeData.focusColor; reserve its space so it cannot clip.
4. A scientific series stroke is part of its chart specification and legend, never a decorative separator.
5. Do not border every row in a reading section. Use a separator only where grouping would otherwise be ambiguous.

## Elevation (4 rules)

1. Reading groups use ThemeData.cardTheme.elevation.
2. App bars use ThemeData.appBarTheme.elevation.
3. Menus and sheets separate through ThemeData.colorScheme.surfaceContainerHigh, outline and placement; no decorative shadow is required in this revision.
4. Never use elevation, blur or glow to imply fit, weather quality, saved state or scientific certainty.

## Figma layout contract

From the 375px product root down to leaf rows, use explicit vertical or horizontal Auto Layout for every UI container; set all four paddings and itemSpacing deliberately from the adopted grid. Do not place UI children using manual x/y or layoutMode NONE; only explicitly identified floating badges may opt out. Vector path coordinates describe icon/scientific drawing, not UI container placement. Canvas presentation boards sit outside the product-root contract. Existing protected source/BEFORE artifacts are not retroactively rewritten by a new authoring rule. Required layer names describe their semantic role, e.g. Summary/Heading, Fit/Reason and Forecast/UpdatedAt.

## Historical owner-requested Longread block composition — 2026-10-31

The current Tonight/Plan TEST frames retain coherent bounded blocks with flat internal rows. Related blocks use AppSpacing.md separation, AppSpacing.sm horizontal / AppSpacing.md vertical insets and AppRadius.small, with surfaceRaised. This explicit local composition supersedes the generic section interval/plain-section choice for those named test groups only; the shared scale and catalog masters are unchanged. Preserve fill-width inner groups, original chart coordinates and 48px context targets. See [workflow](WORKFLOW.md) for evidence and limits.

### Historical local owner density override — 2026-11-01

For these two TEST Longreads, the later owner adjustment supersedes the preceding vertical-inset rule: preserve Plan/Inputs with zero wrapper vertical padding/gap; apply that wrapper treatment to both Night ahead groups while retaining row internals and a heading inset. Other record wrappers use sm vertical insets/gaps; Fit uses xs and the disclosure wrapper has zero gap. Related blocks retain md separation. Geo/Date use 16px icons, hugging caption labels, xs horizontal control insets and at least 48px targets. The restored active root tab uses small radius, not a pill. These are local 1.2 owner overrides; shared scales/catalog masters and Flutter are unchanged. Separate block concepts remain proposals; see [workflow](WORKFLOW.md).

### Owner refinement — 2026-11-04

The accepted pattern-class rules are now resolved in Grid and composition above for new screens; the earlier local scope remains historical, not a competing default.

Both accepted Night ahead compositions now hug content with AppSpacing.sm (8px) bottom padding. This supersedes their zero-bottom-padding rule above. Retain the existing heading inset, zero extra row gaps, row internals, horizontal insets and 303px/24h timeline scale. Plan Inputs and the flat Moon/Weather row group retain their compact wrappers: their rows already provide 8px internal text clearance. An unfilled plain section or action footer is not an inset record card. Keep 12px separation between document blocks and the document's 32px bottom clearance.

Tonight Moon/Weather and Plan Conditions also use Hug height. Conditions retains its 220px closed height through explicit 8px bottom padding, replacing the same previously visible fixed-height surplus; its open Sky darkness specimen grows rather than overlapping the footer. The DS adopted-pilot board hugs all annotations. Preserve intentionally aligned metric slots; these container repairs do not remove their measured equal heights.


## Owner correction — block composition and peer tabs, 2026-11-04

Tonight and Plan are the composition references for subsequent After Dark screens. Preserve their bounded, coherent groups, compact internal rows and clear inter-block separation. This supersedes applying the unfilled standalone-answer recipe to Night and later base-screen groups. Independent explanatory prose can remain unfilled inside its owning group; avoid nested decorative boxes.

Night/Moon/Weather peer tabs retain a 48px-high independent target. Current refinement after critical Night QA: the selected visual is a centered 36px-high highlight, at least 80px wide (capped at target width minus 8px), with at least 12px horizontal label clearance and the existing small radius. There is no selection check. Keep selected/inactive label contrast. The reduced highlight does not reduce the hit region. This is a peer-tab rule, not a change to root navigation or scientific indicators.

Historical: the preceding Night iteration used a plain answer/browser composition and inherited full-target pill/check peer tabs. The owner revised those choices after comparing Tonight and Plan; the original construction receipt remains dated evidence in REDESIGN_RUN.

Historical peer-tab size: the earlier correction used a 32px-high, label-hugging highlight with 8px horizontal inset. The owner judged it too small and requested the current larger compact highlight. The check-free rule and 48px target remain unchanged.

### Moon month overview — local geometry exception, 2026-11-05

To preserve the BEFORE month overview at 375px screen width, the Moon calendar alone uses a centered 352px block with 8px insets and a 336px grid: seven separate 48px day targets. Its local page clearance is 11.5px; other Moon blocks retain the 24px gutter and 327px width. Five Monday-first week rows grow to fit phase/duration text. This is a calendar-specific scientific density constraint, not a global gutter reduction or permission to replace the month with a week list. Keep the bounded Tonight/Plan block treatment and no horizontal clipping.

Owner-approved audit refinement,2026-11-06: use exact single-line duration notation such as5h25m,30m and0m, with an adjacent h/m legend. Preserve all31 dates, glyphs, selected night and computed minutes. Historical spaced h/min text wrapped onto two lines; it is superseded only inside the compact month grid, not in prose or the scientific value itself.

### Weather date dialog — local source constraint, 2026-11-05

The owner-selected ordinary date calendar uses a centered 360px dialog with 12px insets and a 336px grid at the 375px reference width. This adapts NightPickerDialog's 360px maximum and seven 48px day targets; its selected circle remains 40px inside the target. It is a local modal constraint, not a change to the 24px page gutters or peer-category selection. Use the existing 8px radius, named Geist roles, semantic modal/border/foreground fills and quiet Cancel/OK actions. The date header retains a quiet 64×48 Edit entry, and the month/year chooser uses a separate canonical vector chevron. These visual adaptations are authoring judgments, not a claim of native pixel parity. Prototype interaction coverage belongs to REDESIGN_RUN.

### Weather read-only table density — 2026-11-05

Owner-requested density adjustment: the header and eleven hourly rows use 40px cell height, 4px vertical cell insets and centered horizontal/vertical content. Preserve the existing dense12/16 text role, wrapped headers, 96px pinned local-time column, eight112px weather columns and horizontal overflow. This is a local read-only table constraint; buttons, calendar days and selected-hour controls retain their48px targets. Long or scaled content must grow rather than clip; the40px fixture is not accessibility/text-scale proof.

### Weather graph edge clearance — 2026-11-05

Retain plot frame x32–299, but inset the shared hourly-center domain by 14px on both sides: centers x46 + 23.9i for eleven hours. All lines, points, guides, selection cursors, labels and nearest-hour hit regions use that same mapping. Twelve-pixel instantaneous cloud bars then retain at least 8px visible edge clearance; preceding-hour probability intervals retain 14px at the final boundary. Keep source sample timing and Y/value geometry unchanged. This is plot padding, not removal of boundary samples or an extra forecast interval.

## Layout and geometry control — owner rule, 2026-11-05

1. **Strict Auto Layout:** every product-root container declares layoutMode, paddingTop/Right/Bottom/Left and itemSpacing using the adopted 4/8/12/16/24px grid. No manual x/y placement or NONE layout for UI content; only an explicitly named floating badge may use an exception. Set values deliberately when cloning or instantiating a proven canonical wrapper.
2. **Row centering:** every horizontal row combining text, icons, badges or values uses counterAxisAlignItems CENTER. A row of multiline body paragraphs may use top alignment only with an explicit reason. Preserve text alignment within its semantic slot; centering a row does not mean centering prose horizontally.
3. **Fill and Hug:** blocks/cards/content rows inside vertical containers default to layoutSizingHorizontal FILL and layoutSizingVertical HUG. Fixed control targets, glyph dimensions and true scientific dimensions retain their explicit size roles; do not make every icon a fill-width row.
4. **Proven wrappers:** instantiate canonical DS masters or clone the matching Tonight/Plan structural wrapper before creating raw frames. Resolve a real component gap centrally, retaining named typography and semantic bindings.
5. **Pre-export gate:** inspect node properties before every review PNG: no multi-child NONE frame, no accidental zero insets/gaps, no overflowing visible child bounds; also inspect row CENTER, Fill/Hug and linked instances. Zero is intentional only for documented joined rows/flush root flow or centered glyph/hit-target wrappers; record that reason rather than treating every zero as a defect or silently waiving it. A failed check blocks export until fixed or explicitly reported.

This rule supersedes the earlier general allowance for absolute-positioned UI/chart overlay containers in newly authored product layouts. Preserve source-driven drawing geometry, and keep historical resource/capture receipts separate from current authoring requirements. Do not mass-rewrite protected BEFORE or unrelated screens.


## Candidates search — owner-selected Notion shell, 2026-11-05

The dedicated Candidates search/filter wrapper is an explicitly authorized local pill exception to ordinary input radius. It has 24px corners and56px shell height around independent48px controls, fills the311px context content width and groups independent input/48px filter targets under one outline. Final shell insets are12px horizontal/4px vertical, with an intentional zero joined-control gap; the inner input retains its own readable inset. The earlier48px/zero-vertical shell was superseded during Preview QA. All UI uses Auto Layout and centered horizontal alignment. Do not extend this exception to ordinary rows, navigation tabs or shared catalog inputs. Exact current IDs/status belong to [authoring profile](AUTHORING_PROFILE.md) and [run](REDESIGN_RUN.md).
