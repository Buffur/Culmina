# Plan pilot

Revision: AFTER-DARK-1.0.

## Frozen BEFORE

- File: Culmina, key `OeDvjQ58cWoHOCSMd69GCG`; page `Dark · current screens` (`3:2`).
- Exact frame: **002 · plan · Dark · Longread**.
- Verified live node: **9:135698**, **375 × 2275 px**.
- [Open BEFORE](https://www.figma.com/design/OeDvjQ58cWoHOCSMd69GCG/Culmina?node-id=9-135698).
- Live search selection, full-longread overview and dimension inspector read on 2026-10-30. Small text should be rechecked at native zoom during F01 transfer; do not treat this transcription as an export of every text node.

## Functional parity inventory

| Group | Data and actions to preserve | After component |
| --- | --- | --- |
| Chrome/identity | Back, Plan title, appearance/menu actions, night identity and saved state | AppBar/OverflowMenu/PlanState |
| Fit | Fits; needed 2 h 10 min, usable 9 h 55 min, spare 7 h 45 min; explanation | FitAnswer |
| Inputs | Site Kyiv outskirts; Night of 19 Oct; Target M31 Andromeda Galaxy; DSLR / 135 mm lens rig; each source chooser action and caption | ActionRow |
| Capture plan | Block count/frame count; Light, no filter, 120 × 60 s, 2 h integration; ISO 800, WB Auto; focus not recorded; tracking limitation | CaptureBlock/Notice |
| Block commands | Edit, move controls with positional availability, Remove, Add block, Build calibration frames, Fill the window with the existing exposure/count proposal | Action |
| Estimate | Integration, needed time, storage Unknown and evidence note, relative stacking gain ×10.95, explanations | FactRow |
| Detail disclosures | Budget and assumptions, Stacking gain details, Rig details | Disclosure |
| Night ahead | Night & Moon, Weather, source captions, sky darkness | ActionRow/SkyDarkness |
| Persistence | Explicit Save plan and source availability/remedy; reachable footer | Action/Notice |

Exact field origins, missing indicators and explanatory copy must be preserved from the original layers; do not “complete” unknown storage/focus or reinterpret tracking not set as an equipment measurement.

## State and transition contract

Current Plan is **HomeScreen**, wrapped by [SessionPlannerRoute](../../../lib/presentation/screens/home/session_planner_route.dart), not TonightHomeScreen. [HomeScreen](../../../lib/presentation/screens/home/home_screen.dart), [CapturePlanWidget](../../../lib/presentation/widgets/capture_plan_widget.dart), [PlanStatus](../../../lib/presentation/widgets/plan_status.dart), SessionPlanViewModel and CaptureAnalysisViewModel own the relevant behavior.

- Missing site/target/rig/block drives a neutral specific remedy. A no-site state has no valid night. Do not make a disabled Night chooser look actionable.
- Site and night selection modify the working plan according to their current sheet semantics; selecting in the night picker is confirmed with its explicit confirmation action.
- Add/Edit returns a CaptureBlock; the caller applies changes and supplies Undo. Preserve block ordering, constraints and calibration matching.
- Fit/needed/integration/storage/gain come from domain analysis, not the display. Keep no-window and nothing-to-fit distinct.
- Save persists explicitly; saving/persistence failure does not become Saved. Leave/New/Copy must retain unsaved guards and failure behavior. Menu commands retain their feedback.
- Dirty saved plans remain Saved · changed according to source wording, rather than falsely settled by autosave.

## Known source difference

The inspected Figma identity is compact near the fit area. Current code at HEAD `55d07528d4e6107bcd504bef632a869f2a85c434` places `planner.identityGroup` separately from `planner.statusGroup`, gives Site and Night separate rows/sheet actions, and wraps the identity at narrow widths/large text. A Git comparison against historical source commit `e631de00b58a65b830023dd63f33a883abca4300` confirms changes in these areas; it does **not** prove the current Figma node was exported from that commit. The live frame already visibly contains separate Site and Night rows. Keep the selected Figma baseline; document current caller semantics without silently replacing its composition.

Read tests [plan_identity_actions_test](../../../test/presentation/screens/home/plan_identity_actions_test.dart) and [plan_fact_layout_test](../../../test/presentation/shared/plan_fact_layout_test.dart) before any later migration. D01 read relevant source/test portions; it did not execute Flutter tests.

## After composition intent / limits

Use a clear identity line, a plain fit answer, an input group, then the capture record and supporting estimate. Keep all sections/actions, including less prominent assumptions and rig data. The proposed visual hierarchy may change; domain truth may not. F01 must compare full longread and 375 × 812 first viewport, including footer clearance. Dialogs, menu-open states, invalid inputs, no-site and failed Save are source-backed requirements, not live-inspected alternative BEFORE frames.
