> **Historical navigation copy — not active instructions.** Link destinations are rebased from `docs/audit/10_UX_AUDIT.md`. Content and acceptance statements retain their original date/scope. [Immutable original](../../../docs/audit/10_UX_AUDIT.md) · [Navigation index](../../../NAVIGATION.md). Original SHA-256: `c14261dc42ce2fa1a5a3d9a4737bd781771009e551247204a61bc890a2c01c97`.

# UX Audit: Culmina — Final completion roadmap (F01–F26, G1–G4)

**Perspective**: UX Engineer
**Date**: 2026-10-17
**Plan**: [`docs/refinement/FINAL_COMPLETION_ROADMAP.md`](../../../../../refinement/FINAL_COMPLETION_ROADMAP.md) (status PROPOSED; untracked at HEAD `b6e8c1e` when audited)

**Evidence boundary.** Read: the roadmap; the approved requirements (`research/RA_D_ROUND2_PACKAGE.md`); `POST_ROADMAP_PLAN.md` §5, Stages 12–17; audit 09 §C.5, §D.6 and P3; and the current source of every affected flow at `b6e8c1e` (application baseline `570581e`). Not done: no app run, emulator, device, test or gate. Behaviour under activity or process recreation is inferred from code and marked UNVERIFIED.

Every fix below is a **proposed local amendment** under the roadmap's change-control rule (§2, rule 3), for the owner to accept or reject. None is an owner decision, and none adds a Stage, Task or product capability. Where a fix contains a genuine choice, it says so.

## Plan Summary

The roadmap finishes the approved release in four stages:

- **A:** a safe restore and the pre-Android-12 splash.
- **B:** a reliable Capture Plan: class-first rig creation with labelled photo and manual paths, block origins and white balance, storage evidence, photo-proposed light blocks, calibration built from lights, the relative-improvement curve, actionable fit guidance, and removal of the example-plan shortcut.
- **C:** night conditions and screens: one Moon rule, a 16-night forecast, a browsable Moon calendar, a one-screen first run, a night-first Home, a checklist-led Planner, Logbook progress with Delete and "Plan this target", AstroBin CSV, Appearance and units, and route restoration.
- **D:** a signed GitHub APK with install and update instructions.

For the user, nearly every primary surface changes: first run, Home, Planner, both editors, Night & Moon, Weather, Logbook, Settings and the restore flow.

## User Journey Map

Marks: **OK** = clear · **WARN** = ambiguous · **FAIL** = missing. The four journeys W1–W4 are the plan's own workflow checks; J5 and J6 are added because they change destructive or navigational behaviour.

**J1 — First run with a phone (W1; F02, F16, F05, F08, F07, F11, F12, F18)**

| # | Trigger → action | Feedback | Outcome | Mark |
|---|---|---|---|---|
| 1 | Cold start → splash → setup screen, routed before the first frame (F02, F16 A1) | Approved mark; no Tonight flash | Setup screen | OK |
| 2 | "Use current position" (permission asked only on tap) or choose a site | Existing location feedback | Site set | OK |
| 3 | "What do you shoot with?" → Phone → "From a photo" listed first (F05) | Readable formats named | System picker opens | OK |
| 4 | Pick a photo → review → Save in the rig editor | Existing progress bar and plain-word match headline | Rig saved | WARN — no next step defined for a photo without camera data (R4); a pick interrupted by activity recreation is dropped silently (R5); a tap outside the editor discards it (C4) |
| 5 | Back on the setup screen | Rig status should show the new rig | Rig is **not** chosen for the plan | **FAIL — C2** |
| 6 | "Start planning" → Home: night card, then Your plan (F17) | — | Home | OK, but Your plan still says "Needs a rig" while C2 stands |
| 7 | Open planner → checklist site · target · rig · capture (F18 A1) | Each item opens its selector | — | OK |
| 8 | Capture item → empty Capture Plan | "No blocks yet." | No labelled next step once the example action is gone | **FAIL — C5** |
| 9 | Add light block → Take from a photo → proposal → Save (F08) | Per-field origins (F06) | Block added | WARN — proposal UI unspecified (R6); Back or a tap outside discards the form (C4) |
| 10 | Read fit, storage and relative improvement | Explained on screen (W; F07, F11, F12) | — | OK |
| 11 | Save plan | "Plan saved" (existing `showDone`) | Saved | OK |

**J2 — DSLR proposal, edit, cancel (W2; F06–F09)**

| # | Trigger → action | Feedback | Outcome | Mark |
|---|---|---|---|---|
| 1 | Light editor → Take from a photo → JPEG or DNG | Proposal with sources | Fields filled, not yet saved | OK |
| 2 | Pick the camera's CR3 or NEF instead | Storage evidence only (D3); exposure and ISO not read | — | WARN — the message must point to the camera's JPEG or DNG (R4) |
| 3 | Change a proposed value | The origin becomes the user's (F06 A2) | — | OK |
| 4 | Cancel | — | Nothing stored (F08 A2) | OK |
| 5 | Build calibration from lights → preview → confirm | Undo message (existing pattern; F09 A4) | Calibration blocks added | WARN — where the action lives and when it is offered are unspecified (R8) |

**J3 — Astro camera, metadata and calibration (W3; F05, F07, F09, F10)**

| # | Trigger → action | Feedback | Outcome | Mark |
|---|---|---|---|---|
| 1 | Rig: Astro camera → "Enter by hand" first until F10 | The reason beside each required field (F05) | Rig saved | OK (C2 and C4 apply) |
| 2 | After F10: FITS file → rig review → Save | Per-field provenance | Rig saved | OK (gated on a FITS sample) |
| 3 | Lights proposed from FITS with FILTER `H-alpha`; flats entered as `Ha` | Mismatch warning (F09 A1: `H-alpha` ≠ `Ha`) | The user must reconcile the names | WARN — the filter control must show the preserved value and its origin, or the warning names something the user cannot see (R9) |
| 4 | Storage from BITPIX/NAXIS | "Theoretical, uncompressed" label | — | OK |

**J4 — Returning, multi-night (W4; F13–F15, F17, F19, F20)**

| # | Trigger → action | Feedback | Outcome | Mark |
|---|---|---|---|---|
| 1 | Next day → Home | "How did it go?" card (existing) | — | OK |
| 2 | Record the result → Logbook progress (F19) | Saved; progress updated | — | OK |
| 3 | Open Your plan | — | A never-saved copy for tonight has replaced the ended saved plan (`plan_lifecycle_viewmodel.dart:111`) | WARN — not announced (N5) |
| 4 | Browse the Moon calendar or the 16-night overview → pick Friday | — | Unspecified: browse only, edit the plan, or copy it | **FAIL — C3** |
| 5 | Export the entry as AstroBin CSV (F20) | — | CSV with an empty filter column | WARN — the row-to-filter mapping may never reach the user (R12) |

**J5 — Restore a backup, the most destructive action (F01, D2, G2 row 4)**

| # | Trigger → action | Feedback | Outcome | Mark |
|---|---|---|---|---|
| 1 | Settings → Restore from a backup → pick a file | Three refusal texts exist (`backup_section.dart`, `problemText`) | Preview | WARN — F01's new refusal reasons need actionable text, ideally before the confirmation (R2, C1) |
| 2 | Confirmation: date, version, counts; recommends backing up first | — | — | WARN — advice only (R1) |
| 3 | "Restore at next start" | "Restore ready: it runs when you reopen the app"; a tile in Settings only | Restore pending, for an unbounded time | **FAIL — C1** |
| 4 | Next cold start applies or refuses it | None: a refusal is only logged (`main.dart:65-75`); success is silent | Old or new data, unexplained | **FAIL — C1** |

**J6 — Change an assumption from the plan (F12)**

| # | Trigger → action | Feedback | Outcome | Mark |
|---|---|---|---|---|
| 1 | Planner → Assumptions → "Change in Settings" | — | Settings tab, through `context.go` | WARN — the scope (every plan) is not stated (R3) |
| 2 | Back | — | Tonight, not the plan (`app_shell.dart:45-47`) | WARN — R3 |

## Verdict: APPROVE WITH CHANGES

The plan's structure is right for users:

- It keeps the lifecycle invariants: Save · Discard · Cancel, immutable saved records, and Cancel changes nothing.
- It specifies honest states: Unknown with a remedy, partial and stale forecasts, no-dark and mixed Moon states, and Home's empty, loading, offline and error states.
- It never asks for location unprompted.
- Its U and W rules make "looks fine" observable: 412 px, 200 % text, keyboard open, real glyphs, recorded dead ends and outside look-ups, and comprehension claimed only from someone other than the builder.

The five critical issues are gaps in flows the plan already owns. Each is a local amendment to named tasks:

| Issue | Tasks amended |
|---|---|
| C1 | F01 |
| C2 | F05 and F16 |
| C3 | F13's ADR-022 decision sheet, with F15, F17 and F18 |
| C4 | F05 and F06 |
| C5 | F09, with F18 |

C1, C2 and C3 each contain one choice for the owner. C1's recommended option changes TASK 14.4's owner decision that a restore is applied at the next start.

**Applied 2026-10-17:** C1–C5 are written into the roadmap as UXA-C1 to UXA-C5, because the roadmap already uses C1–C6 for the readiness-review corrections. The three choices are listed there as D7–D9, with the recommended option applied. The recommendations and nice-to-haves below are not applied.

## Critical Issues (Must Fix)

| # | Issue | Step in Journey | Impact on User | Fix |
|---|-------|----------------|----------------|-----|
| C1 | **A staged restore waits for an unbounded time, and its outcome is never shown.** The confirmation says data is replaced "when Culmina next starts" (`backup_section.dart:46-52`), then "it runs when you reopen the app" (`:63`). The pending state appears only in Settings (`:90-96`). The restore applies only at process start; a refusal is only logged (`main.dart:65-75`), and success is silent. F01 A3/A4 cover interruption and the instruction text, not edits made in the meantime or reporting the outcome. F01's deeper validation adds new ways for activation to refuse. | J5 steps 3–4 | Coming back from Recents may apply nothing (CA-16, UNVERIFIED on a device). Results or plans recorded while the restore waits are replaced later, without warning. After a refused activation the user sees the old data with no explanation. | **F01:** (a) run the full candidate validation at pick time, before the confirmation, so a bad file is refused at once. (b) Apply the restore on an in-app "Restart now"; the app already re-runs startup in-process after the recovery screen's reset (`main.dart:96`). If the owner keeps "next start" instead, show a banner on every tab saying that changes will be replaced, with Restart and Cancel. (c) On the start that applies or refuses the restore, report it once ("Restored the backup from 12 Oct." / "The restore wasn't applied: <reason>. Your data is unchanged.") and clear the staged state. Add (c) to A3 and to G2 row 4. |
| C2 | **A rig created from "this plan needs a rig" is saved but not chosen.** Only tapping a row in the choose list sets the plan's rig (`equipment_selection_screen.dart:219`). "Add rig" and "Add from a photo" save the rig and reload the list (`:99-105`, `:135-151`). F05 puts both creation paths on the Planner and Tonight missing-rig actions and in onboarding (F16), and its A2 stops at "reaches a saved rig". | J1 steps 4–6; J3 step 1 | After the longest setup task the user is back at "Not chosen" or "Needs a rig". They must find the list and tap the rig, or leave believing it is set. A dead end in W1. | **F05 A1 and F16 A3** state the outcome. Recommended: a rig created from a plan's missing-rig action or from onboarding becomes the plan's rig on Save. The user returns to where they started, with the status updated and a message ("Rig saved and chosen for this plan"). A rig created from the Library is only saved. Owner alternative: return to the choose list with the new rig highlighted. Cover this in the W1 walkthrough. |
| C3 | **"Browse versus adopt" is required three times but never designed.** Today Home's Site ▾ · night ▾ control edits the plan. The night picker calls `setEveningDate` (`tonight_home_screen.dart:152-158`). A site change is written into the plan, as an unsaved edit on a saved plan (`session_plan_viewmodel.dart:165-171`). Night & Moon and Weather show only the plan's night (`night_moon_screen.dart:15`). F15 A2, F17 A3 and F18 A3 require explicit adoption, but the contract sits in ADR-022, which F13 calls a "bounded technical checkpoint". | J4 step 4; the Home and Planner context lines | Users cannot predict whether tapping a night or a site changes their plan. The calendar and Home may behave differently. A saved plan can pick up an unsaved night change that surfaces later as an unexpected Save/Discard prompt. | **F13:** make browse versus adopt one numbered interaction item in the ADR-022 decision sheet, shown as a flow with renders. It decides: (1) which controls browse and which edit (the Home and Planner context lines, a calendar day, an overview card); (2) the adopt control's label and place; (3) what adoption does to a draft (an edit) and to a saved plan (the existing "Copy to another night"); (4) how a browsed night is labelled ("Viewing Fri 14 Nov · your plan: Tue 10 Nov"); (5) the confirmation afterwards (existing `showDone`). F15, F17 and F18 cite that item. |
| C4 | **The rig and block editors throw away everything on a tap outside or Back.** Both open with `showDialog` (a dismissible barrier by default) and have no `PopScope` (`capture_block_dialog.dart:39`, `equipment_editor.dart:216`). The site editor is the only guarded editor (`site_editor_screen.dart:310`). It was fixed when the silent loss of a single-field edit blocked Stage 7 (TD-084). F05 lengthens the rig form; F06 adds white balance and origins to the block editor, and F08 adds a picker round trip. The U rule checks reachability, not accidental dismissal, and F22 excludes draft persistence. | J1 steps 4 and 9; J2; J3 step 1 | Tapping beside the dialog to hide the keyboard, or pressing Back, discards a long form without a word. The behaviour exists today; the roadmap raises its cost. | Add to **F05's and F06's U evidence**: "a changed editor asks before discarding (Back, a tap outside)", reusing the existing Discard prompt. Or move both editors to the site editor's full-screen pattern (a guard and a persistent Save). Also correct the wording: the code has no full-screen *dialog* (no `fullscreenDialog`, no `Dialog.fullscreen`), so "the existing full-screen dialog pattern" in U and F06 should name the site editor's full-screen route. |
| C5 | **Removing the example action leaves the empty Capture Plan with no labelled next step.** Today the empty card is "No blocks yet." plus "Start from the example plan" (`capture_plan_widget.dart:228-230`). Adding a block is an icon button with a tooltip (`:211`). F09 removes the example action, and no task defines what replaces it. "Take from a photo" (F08) sits inside the add dialog, and calibration from lights needs lights first. | J1 step 8 | A first-time user who has just finished setup meets a blank card and an unlabelled icon, at the step the app exists for. | **F09, with F18's checklist:** the empty Capture Plan names the next step with labelled actions — for example "Add light frames" and, for Phone, DSLR and Not sure, "Take from a photo" — and says that calibration can be built from the lights afterwards. The checklist's capture item opens the same state. The E2E test that replaces `capturePlan.useExample` starts from it. |

## Recommendations

| # | Issue | Impact | Fix |
|---|-------|--------|-----|
| R1 | **"Back up first" is advice only** (F01 A4; D2 recommends no Undo) | Restore replaces everything. Following the advice means leaving the flow, saving a file elsewhere and starting again, so most people will not. | Make "Back up first" a button in the restore confirmation. It runs the existing backup, then returns to the confirmation. No archive field, no Undo. |
| R2 | **The new refusal reasons have no user text** (F01 A1) | Three texts exist (`backup_section.dart`, `problemText`: not a backup, a newer version, too old). A truncated database, a missing schema and a failed migration are new. | Each refusal says what happened, what to do (choose another backup, or update the app first) and that the current data is unchanged. Show it at pick time where possible (C1 a). |
| R3 | **"Change in Settings" leaves the plan** (F12 A4) | The link calls `context.go(AppRouter.settings)` (`capture_assumptions_panel.dart:113`). Back from that tab goes to Tonight (`app_shell.dart:45-47`). The panel shows app-wide settings, while saved records keep the ones they were saved with (`session_snapshot.dart:6`). | Open the planning settings so that Back returns to the same plan and section. State the scope next to the link: "Applies to every plan; saved records keep their own." |
| R4 | **No next step when a picked file gives little or nothing** (F05 A3, F08, F10 A4) | Photos re-shared through messengers often lose their EXIF. CR2, CR3 and NEF are recognised but not read. F05 orders the two choices for Phone, DSLR and Astro, but not for "Not sure". | Each outcome names a remedy: pick the original from the camera folder; for native RAW, pick the camera's JPEG or DNG for exposure and ISO (the RAW still gives its size, per D3); or Enter by hand, with what was read prefilled. Put "From a photo" first for "Not sure" too. |
| R5 | **An interrupted pick vanishes** (F08, F22) | `pendingPick` is held only in memory (`MetadataDocumentChannel.kt:39`, `:73`). Recreating the activity or the process while the system picker is open drops the result. UNVERIFIED on a device. | Define the outcome: the user returns to the plan (F22) with "The file wasn't read — pick it again", not a silent restart. Add a "Don't keep activities" pass to G2 row 2. |
| R6 | **The photo-proposal interaction is unspecified** (F08 A1) | A preview dialog over the block dialog stacks modals. The rig import already has a tested pattern. | Show the proposals inline in the editor, each field with its origin and a way to clear it. Reuse the import's words ("from the file", "estimated from this one file's size", "nothing is saved until you press Save") and its progress bar. |
| R7 | **F19's "Delete with RD-09 Undo" contradicts RD-09** | Under RD-09 (M + S1), stored records are deleted after a confirmation and edits inside a plan get Undo (`delete_patterns.dart:7-12`). The rig confirmation says "This can't be undone" (`equipment_selection_screen.dart:117`). | Reword F19's scope and A4 to "a visible Delete with RD-09's stored-record confirmation". Undo for rigs and targets would change RD-09 and needs the owner. |
| R8 | **"Build calibration from lights" has no entry point** (F09) | Users find it only by chance. Today's "flats missing" and mismatch warnings say what is wrong but not how to fix it. | Put the action on the Capture Plan card once a light block exists, disabled with its reason before that, and offer it from the "flats missing" warning. The preview lists each proposed block with an include switch and an editable count. |
| R9 | **Where the new per-block detail goes is undecided** (F06, F07) | Origins, white balance and storage evidence each add lines, and the density record measures growth without a rule. "Measured from one CR3 file; image mode not read; compressed RAW sizes vary with content" wraps to several lines at 200 %. | Decide before F06. The block row shows one short source ("measured · IMG_0845.CR3"); assumptions and white-balance detail live in the editor or behind the existing `CollapsibleSection`. Show a preserved custom filter as the selected item with its origin ("H-alpha · from file"); today the dropdown can show only its fixed list (`capture_block_dialog.dart:135`). |
| R10 | **The W journeys have no expected path** | Walkthroughs record backtracks and dead ends, but without a target sequence a "backtrack" is a judgement call, and the journeys are assembled only at F25. | Before F05, write the expected steps of W1–W4: one short table each, approved by the owner. This report's journey map can seed them. Check each UI task's part against them. |
| R11 | **Route restoration can fall back silently** (F22 A1) | "An explicit valid fallback" may put the user somewhere else without a word. | When the restored item no longer exists, say so: "The plan you had open was deleted. Showing Tonight." |
| R12 | **The AstroBin filter mapping can be lost** (F20) | AstroBin ignores filter names. The plan lists them, in row order, in the share text, which many share targets drop when a file is attached. | Show the row-to-filter list in the app at export, and tell the user to set each row's filter in AstroBin after import. Define what the action shows for an entry with nothing recorded: hidden, or disabled with the reason. |
| R13 | **No one but the builder tries the new flows** | The S6.E gap is accepted as UNVERIFIED, and the roadmap changes almost every primary screen. | Optional and non-blocking: one 15-minute think-aloud of W1 by someone else before G3. It does not reopen the accepted limitation; it gives the riskiest journey one real observation. |

## Nice-to-Haves

| # | Suggestion | Rationale |
|---|------------|-----------|
| N1 | Keep "Not sure" as the label of the Unknown class | It is S14.2's user wording; the consolidation says only "explicit Unknown". |
| N2 | Use sentence case in the block editor ("Add Capture Block", "Frame Type", "Frame Count"; `capture_block_dialog.dart:318`) | The rest of the app uses sentence case ("Add rig", "Choose a rig"), and F06 changes the dialog anyway. |
| N3 | Add the new labels to `AppWords` | "Add from a photo" (the rig route), "From a photo" (the class choice) and "Take from a photo" (the block) are close. One glossary keeps each tied to one flow. |
| N4 | Give the calendar a loading state (F15) | A month grid with placeholders while the isolate computes, and no invented values. |
| N5 | Announce the ended-plan copy once on Home | The rollover (`plan_lifecycle_viewmodel.dart:111`) changes what Your plan opens without saying so. For example: "Last night's plan is in the Logbook; this is a copy for tonight." |
| N6 | Add a Releases link in About | Excluded by §5 (CA-20). Listed only because a GitHub-only app has no other way to tell users that an update exists. |

## Interaction Consistency Check

**Matches existing patterns**

- **Plan lifecycle.** Save · Discard · Cancel (`askBeforeLeavingPlan`, `unsaved_plan_prompt.dart`) is kept for every new entry point (rule 6; F15 A2, F17 A3, F18 A3).
- **Undo for edits, confirmation for records.** RD-09 (M + S1, `delete_patterns.dart:7-12`) gives in-plan edits an Undo and stored records a confirmation. F09's confirm-then-Undo for calibration matches; F19's wording does not (R7).
- **Feedback.** `runWithFeedback`, `showDone`, `showFailure` and `LoadFailureView` (`failure_feedback.dart`) cover every action that writes, and new actions should use them. The restore activation is the exception (C1).
- **Import review.** F05 and F10 reuse "Add from a photo" (`/equipment/import`) unchanged. It is a full-screen route with a progress bar, a plain-word match headline, "Use the file's …" switches and provenance words. F08 should use the same words (R6).
- **Progressive disclosure.** Planner sections are `CollapsibleSection`s with remembered state (S6.7). The new detail should use them (R9).

**Deviates or is ambiguous**

- **Context-line semantics (C3).** On Home and in the Planner, Site ▾ · night ▾ edits the plan today, while the calendar and the 16-night overview introduce browsing. Unless ADR-022 defines it once, the same gesture — pick a night — will mean "edit" in one place and "look" in another.
- **Editors (C4).** The site editor is a full-screen route with a discard guard and a persistent Save (`site_editor_screen.dart:310`; DESIGN_SYSTEM §9). The rig and block editors are dismissible alert dialogs with no guard. The "existing full-screen dialog pattern" the roadmap names does not exist as a dialog in the code; the site editor's route is the nearest match.
- **Creating versus choosing (C2).** Everywhere else, an action taken for this plan changes the plan: choosing a site, a target or a night. Creating a rig from the plan's "Needs a rig" does not.
- **Leaving the plan for Settings (R3).** Detail screens open above the planner, and Back returns to it (`/night` and `/weather` on the root navigator). "Change in Settings" switches tabs instead.
- **Labels.** "Add from a photo", "From a photo" and "Take from a photo" are close; keep each tied to one flow (N3). The block editor's title case breaks the sentence-case convention (N2).
- **New plan.** It moves from Home into the Planner's ⋮ menu (approved PD-03). The W4 walkthrough should include "plan something different tonight" to confirm people still find it.

## Verdict Details

- **Discoverability: CONCERNS.** The empty Capture Plan loses its only labelled action (C5). Calibration from lights has no defined entry point (R8). New plan lives only in a ⋮ menu; this is approved, so verify it in W4.
- **Flow Completeness: CONCERNS.** Creating a rig from a missing-rig action does not complete the plan (C2), and "adopt this night" has no defined flow (C3).
- **Error Recovery: CONCERNS.** The editors are unguarded (C4). Photos without data and unread RAW files have no next step (R4). Interrupted picks are dropped (R5). Restore refusals at activation go unexplained (C1).
- **Feedback & Status: CONCERNS.** A pending restore is visible only in Settings, and its outcome is never shown (C1). Route restoration can fall back silently (R11).
- **Consistency: CONCERNS.** One gesture has two meanings (C3), the editors follow two patterns (C4), and F19's Delete wording contradicts RD-09 (R7).

## Files read

- **Plans and requirements:** `docs/refinement/FINAL_COMPLETION_ROADMAP.md`, `PROGRESS.md` (current state), `research/RA_D_ROUND2_PACKAGE.md`, `POST_ROADMAP_PLAN.md` §5 (Stages 12–17), `docs/audit/09_COMPREHENSIVE_AUDIT.md` (§C.5, §D.6, P3), `docs/TECH_DEBT.md` (TD-084).
- **Code:**
  - `lib/presentation/navigation/`: `app_router.dart`, `app_shell.dart`.
  - `lib/presentation/screens/`: `welcome/welcome_screen.dart`, `tonight/tonight_home_screen.dart`, `home/home_screen.dart` (plan menu, identity strip), `details/night_moon_screen.dart`, `settings/backup_section.dart`, `equipment/equipment_selection_screen.dart`, `equipment/equipment_editor.dart`, `metadata/metadata_import_screen.dart`, `sites/site_editor_screen.dart`.
  - `lib/presentation/widgets/`: `capture_plan_widget.dart`, `capture_plan/capture_block_dialog.dart`, `capture_plan/capture_assumptions_panel.dart`.
  - `lib/presentation/shared/`: `unsaved_plan_prompt.dart`, `confirmation_patterns.dart`, `delete_patterns.dart`, `failure_feedback.dart`, `equipment_import_text.dart`.
  - `lib/presentation/viewmodels/`: `backup_viewmodel.dart`, `session_plan_viewmodel.dart`, `plan_lifecycle_viewmodel.dart`.
  - Elsewhere: `lib/main.dart`, `lib/domain/models/session_snapshot.dart`, `android/app/src/main/kotlin/io/github/buffur/culmina/MetadataDocumentChannel.kt`.
