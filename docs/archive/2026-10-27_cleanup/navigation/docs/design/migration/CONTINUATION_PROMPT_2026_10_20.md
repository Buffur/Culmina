> **Historical navigation copy — not active instructions.** Link destinations are rebased from `docs/design/migration/CONTINUATION_PROMPT_2026_10_20.md`. Content and acceptance statements retain their original date/scope. [Immutable original](../../../../docs/design/migration/CONTINUATION_PROMPT_2026_10_20.md) · [Navigation index](../../../../NAVIGATION.md). Original SHA-256: `1cf17589479bab50a88ded34f9c05170b03d93b24bbe72eb8f76e6193634b16a`.

# Continuation prompt — Hybrid / Geist web → Flutter migration

Written 2026-10-20 by Claude Code after Codex ran out of limits mid-task. The
owner asked to record where the migration stands, write this prompt, and commit
and push the work in progress to `develop`. Paste everything below the line into
a fresh agent session (Codex or Claude Code) to resume.

---

You are resuming an **in-progress, not accepted** migration of the approved web
design ("original Hybrid", Geist font) into the Culmina Flutter app. A previous
agent (Codex) did most of the implementation and stopped when its usage limit
ran out, in the middle of triaging a failed full quality gate. Do not restart the
migration, re-run the baseline or re-audit the repository. Resume from the
ledger and the state recorded here, verified against the actual tree.

## 1. Read first (in this order, only what you need)

1. `CLAUDE.md` — project rules, Verification Policy V1–V8, Git rules.
2. `docs/design/WEB_TO_FLUTTER_MIGRATION.md` — **the migration ledger and the
   authority for status**: objective, frozen sources, accepted owner decisions
   1–9, implementation checkpoint, evidence ledger, the 7-step "Remaining
   completion sequence".
3. Registers, as each step needs them:
   - `docs/design/migration/WEB_DESIGN_INVENTORY.md` (Matrix A, 85 web obligations)
   - `docs/design/migration/FLUTTER_CAPABILITY_INVENTORY.md` (Matrix B, 63 capability rows)
   - `docs/design/migration/JSON_FIELD_ACCOUNTING.md` (179 token leaves)
   - `docs/design/migration/PLAN_IMPLEMENTATION.md`, `UNDO_IMPLEMENTATION.md`
   - `docs/design/migration/VISUAL_COMPARISON_AUDIT.md` (browser ↔ host pairs)
   - `docs/design/migration/evidence/PRESERVATION_RECONCILIATION.md`
4. Design skills: `.agents/skills/culmina-design-{tokens,typography,spacing,components,rules}/`
   and `docs/design/WORKFLOW.md`, when touching UI.

The owner's original full brief to Codex (`pasted-text-1.txt`) is in
`docs/design/migration/OWNER_BRIEF_2026_10_20.md` (verbatim, Ukrainian). It is
**the task contract**: read it in full right after `CLAUDE.md`. Its §8 (the
completion criteria and the eight-item final report to the owner, in
Ukrainian) defines when and how this work ends. Owner decisions recorded
later in the ledger ("Accepted decisions") refine it and are equally binding. If
something cannot be decided from these, ask the owner — do not invent
requirements.

## 2. What the migration is (one paragraph)

Implement the approved web prototype in `design/home-lab/` (original Hybrid
`blend`, revision `20261020-hybrid7`, with `font=Geist`; tokens in
`design/home-lab/tokens.json`, SHA-256 `0eae2143…bb51`) in the existing Flutter
app for all eight roots — Tonight, Plan, Night, Moon, Weather, Logbook, Library,
Settings — while preserving every existing capability, real data source,
calculation, validation, persistence format and native integration. Web decides
composition/hierarchy/components; JSON decides exact values it contains; Flutter
decides science and data. Browser fixtures never become production data. Four
root destinations stay (Tonight, Logbook, Library, Settings); Plan and
Night/Moon/Weather are detail routes.

Owner decisions already made (ledger §"Accepted decisions"): original Hybrid,
not Page/Soft/Desk; bundled licensed Geist (`assets/fonts/`); four nullable
per-plan overrides in **schema v27** (time between frames, setup outside window,
fixed margin, bytes per frame; explicit zero ≠ inherit; old snapshots/backups keep
their semantics); **no** standalone rig JSON import/export (A-LIB-05 accepted
omission); **full Undo** after deleting Logbook entries, rigs, targets, sites
(implemented via `DriftDeletion`/`UndoableDeletion`); Planning Settings uses a
local draft with Save/Cancel; Appearance/Privacy apply immediately.

## 3. Where it stopped (state at hand-over, 2026-10-20 ~21:55 local)

Baseline commit: `8048cfa` (develop). All migration work was uncommitted until
the hand-over commit that adds this file; resolve its hash with
`git log --oneline -3`.

Completion sequence from the ledger, with actual status:

| Step | Status at hand-over |
| --- | --- |
| 1. Finish Calendar, Planning Settings, stored Undo | **Done in code**, focused tests passed (`undo-final-tests.log` 53, `undo-ui-state-schema-tests.log` 239, `settings-draft-tests.log`, `focus-feedback-metadata-sites-recheck.log` 59). |
| 2. Full analyzer + tests + host E2E, resolve regressions | **IN PROGRESS.** Full gate ran 21:37–21:45 and **FAILED** (`evidence/full-quality-gate.log`, `full-quality-gate-failures.json`): Format 1 file, Analyze 5 infos, Test 2386 passed / 5 skipped / **19 failed**, host E2E `core_loop_test.dart` **failed**, `perf_scenarios` passed, `hybrid_migration_smoke_test` skipped on host. Codex then edited ~55 lib/test files to repair (all touched after the gate log). The re-check at hand-over is in §4: still failing (21 unit/widget + `perf_scenarios`). |
| 3. Android scenarios on emulator **5582** | Not started for the final tree. AVD `culmina_hybrid_native_qa` (412×915 dp, 24 h) prepared; first drive attempt failed on a finder bug, since fixed (`evidence/native/README.md`, `drive.log`). |
| 4. Regenerate matched browser ↔ host pairs | Browser side recaptured 21:50 (90 PNGs, zero diagnostics). **Host side is stale** (last 21:35, before the post-gate repairs). Gallery `evidence/matched/gallery/index.html` still pairs with the intermediate host run. |
| 5. Normal `lib/main.dart` APK + real hot reload on 5582 | Not started. |
| 6. Update every Matrix A/B row and JSON status from evidence | Not started (rows still carry PARTIAL / HOST TESTED / FINAL QA PENDING). |
| 7. Final read-only Claude CLI review | Prepared, not run: `evidence/FINAL_CLAUDE_REVIEW_PREPARATION.md` + `FINAL_CLAUDE_REVIEW_PROMPT.md`. |

Visual-audit repairs that the audit assigned to the "parent" agent and that are
**now in code** (not yet re-verified by a host recapture): measured
`hybridAppBar` title height (`lib/presentation/shared/hybrid_app_bar.dart`),
11 px navigation label (`HybridTokens.navigationLabelSize`), `FieldModeButton`
on Library/Logbook/Settings roots, Logbook visible search/inline filters/count.
Still to confirm in the recapture: Tonight plan block ~45 px too low and the
needed-duration seconds, Plan capture list below the fold, Night/Moon/Weather
context taking an extra row, Planning summary missing the Sun limit.

## 4. Re-check run at hand-over (on the committed tree)

Before re-running, the hand-over session made only two mechanical fixes:
`lib/presentation/shared/detail_scaffold.dart` passed `context` (the `String?`
field) instead of `buildContext` to `hybridAppBar` — a compile error left by a
bulk replace — and `dart format` on six files Codex left unformatted. No other
code was changed.

Full gate `dart run tool/check.dart` on that tree (Windows, Flutter 3.47.4,
2026-10-20 ~22:00), log `evidence/handover-full-gate-2026-10-20.log`:

| Check | Result |
| --- | --- |
| Encoding, Format | PASS |
| Analyze | FAIL — 5 `curly_braces_in_flow_control_structures` infos: `hybrid_view_entrance.dart:42`, `night_moon_screen.dart:239`, `hybrid_focus_highlight.dart:83/88/105` |
| Unit/widget | FAIL — 2389 passed, 5 skipped, **21 failed** (list below) |
| Host E2E `core_loop_test.dart` | **PASS** (failed in Codex's run) |
| Host E2E `hybrid_migration_smoke_test.dart` | PASS (skipped on host by design) |
| Host E2E `perf_scenarios_test.dart` | **FAIL** — "the Stage 10 scenarios" (passed in Codex's run; new regression from the post-gate repairs) |

Fixed since Codex's gate: `unsupported_database_test` (v27 pins),
`reference_plan_density_test`, `equipment_editor_fit_test`,
`presentation_style_rules_test`, `field_mode_darkness_test`,
`planner_sky_darkness_test`, `stacking_gain_graph_test`, `core_loop_test`.

Still failing or newly failing (21):

- `accessibility_test.dart` — "every screen meets the guidelines", all 6
  theme × text variants. Causes seen in the log: finders for old text
  (`"1 h 48 min"`, `"10 min"`) now that durations show seconds
  (`1 h 48 min 20 s`, the Tonight precision repair), missing key
  `section.planner.rigDetails`, and non-empty guideline violation lists — check
  each: real contrast/tap-target issue vs. stale finder.
- `planner_structure_test.dart` — "first screen answers the seven questions"
  (light/dark/field) and "status says what FitAnalyzer and the budget say".
- `planner_disclosure_test.dart` — collapsed sections state a fact.
- `capture_outputs_test.dart` — Time needed · Total time equal the calculator
  (ADR-009 §8 E1) — **science-adjacent: confirm displayed values still equal
  `CaptureBudgetCalculator`, only formatting may change.**
- `tonight_home_screen_test.dart` — a huge plan doesn't fit, with the reason.
- `settings_screen_test.dart` — all workspace roots expose the same
  field-mode action (new test, Logbook/Library/Settings `FieldModeButton`).
- `stage11_host_fixes_test.dart` — "Altitude now" in current-sky detail (F18
  A1) and typographic minus (S11H-02).
- `location_picker_tiles_failing_test.dart` — map controls usable, typed
  position shown and used.
- Guard tests: `media_query_aspects_test` (a new `MediaQuery.of` in lib —
  use `MediaQuery.sizeOf`/`textScalerOf` etc.), `quantity_text_usage_test`,
  `secondary_consistency_test`, `viewmodel_rules_test` (a ViewModel is over
  ~250 lines — split, do not raise the limit).

Not re-checked at hand-over: Android/emulator runs, host visual recapture,
schema-migration and backup round-trip probes beyond what the unit suite holds.

## 5. What to do next

Follow the ledger's sequence; one step at a time, recording evidence under
`docs/design/migration/evidence/` and updating the ledger as you go.

1. **Close step 2.** Fix the remaining failures from §4. For each one decide,
   with evidence, whether the test caught a real regression (fix the code) or
   pins pre-migration presentation the owner has now replaced (update the test
   to the approved Hybrid contract and say so in the commit). Never delete or
   weaken a guard test to get green — in particular the style guards
   (`presentation_style_rules_test`, `secondary_consistency_test`,
   `quantity_text_usage_test`, `viewmodel_rules_test` ≤250 lines,
   `media_query_aspects_test`) encode project invariants: move colours/sizes
   into `HybridTokens`/theme, split oversized ViewModels, route quantities
   through `QuantityText`. Also fix the 5 analyzer infos and the
   `perf_scenarios` E2E regression. Run
   `dart format` on changed files, then the full gate
   `dart run tool/check.dart` once, serially (Windows holds `sqlite3.dll`; never
   run two Flutter test processes at once).
2. Steps 3–5: Android on **emulator-5582 only** (5580 belongs to the owner's
   Android Studio session; a physical phone may be attached — never install to
   it). Every adb command names `-s emulator-5582`. Label evidence HOST /
   EMULATOR accurately.
3. Step 4 host recapture, then per-pair review in `VISUAL_COMPARISON_AUDIT.md`.
4. Step 6 matrices, step 7 final CLI review (read-only, preserve its output),
   fix confirmed findings, verify touched paths.

## 6. Rules that matter here

- High-risk surfaces are touched (schema v27, persistence/Undo, backup/export,
  fonts/assets in `pubspec.yaml`): V1 high-risk verification applies — schema
  migration and compatibility probes, backup round trip, not just widget tests.
- Unknown stays unknown; √N is relative stacking gain, never absolute SNR; no
  invented thresholds. Browser illustrative/demo notices stay out of production.
- Git: commit coherent checkpoints on `develop`. Push only when the owner asks.
  Never force-push, reset --hard, or touch `main`. Raw agent transcripts
  (`*-stream.jsonl`), `.claude/settings.local.json` and `.playwright-cli/` are
  git-ignored because they contain account identity — keep them out of commits.
- Report honestly: the migration is **not accepted** until steps 2–7 pass and
  the owner accepts it. Use COMPLETE only if every condition passed, otherwise
  PARTIAL_WITH_ATTENTION with the open list.
- Reply to the owner in the language of the conversation (usually Ukrainian);
  keep persistent docs in English.
