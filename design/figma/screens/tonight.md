# Tonight pilot

Canonical instance bindings and retained state/route boundaries are recorded in the [2026-11-04 consolidation matrix](../research/consolidation_2026-11-04.md). Screen root `84:34120` and approved appearance/content are preserved.

Revision: AFTER-DARK-1.2.

Latest owner correction, 2026-11-04: the appearance control has a centered Moon with no visible Field caption. Bottom tabs use Moon / Notebook Pen / Archive / Sliders Horizontal; their four labels and accepted rectangular selection treatment are retained. This supersedes the earlier appearance-caption wording below.

Owner designation, 2026-11-04: this Longread is an approved **Dark composition reference** for subsequent mockups, together with Plan and the current Design System state catalog. The current appearance is icon-only centered Moon without a visible Field caption; the polish also adds an 8px Night ahead bottom inset and uses SemiBold on Open planner. The older TEST name remains a stable Figma identity; it does not cancel this composition decision. See [WORKFLOW](../WORKFLOW.md) for actual verification and the distinct state, viewport, scaling and native limits. The historical entries below retain their chronology.

Historical integration chronology (superseded appearance wording retained as evidence): [Tonight](https://www.figma.com/design/OeDvjQ58cWoHOCSMd69GCG/Culmina?node-id=84-34120). On 2026-11-01 the owner authorized integration of the amended Fits concept, retaining Tonight's existing facts and Open planner action. Needed/usable figures align at the available width; Plan's capture-end caption is not added. Compact context controls, Saved state and navigation retain their accepted treatment. On 2026-11-03 the owner accepted A updated / Prototype Preview states; Night ahead now uses its Dark and Moon-free dark lanes with event-linked Preview and optional Exact times. The subsequent owner correction places Moon and Weather together in a separate compact card below Night ahead and gives Open planner a light fill with dark ink. The appearance control now uses Eye above Field in the original 48px target; the local On variant adds a check and neutral active surface. See [workflow](../WORKFLOW.md) for checks and remaining pilot limits.

## Frozen BEFORE

- Live file: Culmina, key `OeDvjQ58cWoHOCSMd69GCG`.
- Page: `Dark · current screens` (`3:2`).
- Exact frame: **001 · home · Dark · Longread**.
- Verified live node: **9:135229**, **375 × 1351 px**.
- [Open BEFORE](https://www.figma.com/design/OeDvjQ58cWoHOCSMd69GCG/Culmina?node-id=9-135229).
- Inspected via the Web Figma canvas and dimension inspector on 2026-10-30. Do not substitute the neighboring `home_blocks_source` frame: it visibly adds a Record result area and is a distinct source state.

## Visible fixture and parity checklist

| Content/action group | Frozen evidence to retain | After component |
| --- | --- | --- |
| Identity/context | Night of 19 Oct; introductory line; Kyiv outskirts and 19 Oct selectors; appearance action | AppBar/Context |
| Your plan | Saved; Andromeda Galaxy; M31 / DSLR / 135 mm lens | Section/PlanState |
| Fit | Fits; 7 h 45 min spare; needed 2 h 10 min, usable 9 h 55 min | FitAnswer |
| Primary action | Open planner | Action |
| Night ahead | Night 19:47–05:42 (+1), 9 h 55 min dark, Europe/Kyiv | ActionRow/FactRow |
| Time browser | Preview time; dark starts/ends; phase bands and moon interval; time labels; preview explanation; Exact times & reading key disclosure | NightTimeline/Disclosure |
| Moon | First quarter, 62% lit; moon-free interval and duration | ActionRow |
| Weather | 6.5°C; wind up to 9 km/h; forecast for dark hours | ActionRow |
| Discovery | What can I image on 19 Oct? | ActionRow |
| Shell | Tonight, Logbook, Library, Settings | RootTabs |

The visible Moon line includes moon-free 00:17 (+1)–05:42 (+1), 5 h 25 min. Preserve its punctuation and date notation from the original frame at build time. Do not reinterpret it as a forecast.

## Behavior beyond the screenshot

[tonight_home_screen](../../../lib/presentation/screens/tonight/tonight_home_screen.dart) owns the screen; ContextLine/home_context_sheets own selector entry. TonightViewModel, SessionPlanViewModel, SiteViewModel, NightConditionsViewModel and CaptureAnalysisViewModel supply state. Open planner enters the guarded Plan route; Night/Moon/Weather rows open the corresponding detail view. The timeline is a preview, not Save.

Source-backed state matrix for future component specimens: bootstrap/loading/failure; no site (Set site and no invented night); selected site; absent target/rig/block; each fit state; saved/changed/recorded lifecycle; weather loading/stale/unavailable. These are not all visible in this frozen frame. F01 must label extra specimens as source-backed states, not alternate captured BEFORE evidence.

## After composition intent

Keep night identity first, context directly below, then a coherent plan record with distinct fit and saved label. The owner-requested block composition keeps “The night ahead” as one bounded group with flat named rows and the full time browser. The saved-plan record, fit and Open planner action remain one coherent block. Preserve the root tabs and every action. Do not add the other source frame's Record result block to this fixture.

## Limits / differences

At the historical F01 baseline inspection, the frame was static; no tap, accessibility or native persistence behavior was tested through Figma. Later scoped Preview checks are recorded in WORKFLOW. Current source supports additional result states and conditional content not shown here; their absence from this specific fixture is not evidence of deletion. Preserve the frozen baseline as evidence; current source/product facts govern new-screen content. Historical F01 scope called for the complete longread and an independently composed 375 × 812 first viewport at the same fixture. The current [base-screen run](../REDESIGN_RUN.md) requires one full Longread and defers the second viewport unless separately requested.

## Experimental Longread — 2026-10-31

Owner update 2026-11-01: restore the compact Saved badge and earlier rectangular root navigation; shrink Geo/Date icons/labels while retaining 48px targets. Night ahead follows the compact wrapper practice of the owner's Plan inputs. These are local TEST-frame overrides; see [workflow](../WORKFLOW.md) for current evidence and owner-review status.

Owner-authorized [After V1 test Longread](https://www.figma.com/design/OeDvjQ58cWoHOCSMd69GCG/Culmina?node-id=84-34120) uses 1.2 in the existing UI Lab. See [workflow](../WORKFLOW.md) for exact source parity, measured fact-slot adaptations, the named scientific source-geometry adapter, verification and remaining acceptance limits. The immutable BEFORE is unchanged. No first-viewport or Flutter result is implied.
