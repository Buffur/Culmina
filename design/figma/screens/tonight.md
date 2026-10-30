# Tonight pilot

Revision: AFTER-DARK-1.0.

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

Keep night identity first, context directly below, then a coherent plan record with distinct fit and saved label. “The night ahead” becomes a flat document section with well-separated named rows and the full time browser. Preserve the root tabs and every action. Do not add the other source frame's Record result block to this fixture.

## Limits / differences

The frame is static; no tap, accessibility or native persistence behavior was tested through Figma. Current source supports additional result states and conditional content not shown here; their absence from this specific fixture is not evidence of deletion. Preserve this baseline, with source semantics used only to annotate unseen behavior. F01 must inspect the complete longread and an independently composed 375 × 812 first viewport at the same fixture.
