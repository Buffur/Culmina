# Hybrid transfer into Flutter — continuation (checkpoint stop, 2026-10-22)

Read this first in a new session, then the contract and the status record. Do not restart the audit: continue
from "Next steps" below.

## Initial prompt (owner, 2026-10-22, verbatim)

Attached file: `CULMINA_OPUS_HYBRID_TRANSFER_FINAL_UK.md` (copy in this folder:
[CULMINA_OPUS_HYBRID_TRANSFER_FINAL_UK.md](CULMINA_OPUS_HYBRID_TRANSFER_FINAL_UK.md); the original lives in the
owner's Downloads). Launch message:

```
Виконай усі обов’язкові пункти визначеного реєстру:
візуальна відповідність за переглянутими web/Android-парами,
під’єднана реальна функціональність, перевірені сценарії,
звичайний release APK і запуск саме цього артефакту.
Завершення визначає §9 файла; нуль неперевірених обов’язкових пунктів.

Почни з еталона та однієї capture-пари, потім реалізовуй через
контрольні точки. Тести — за §6, не весь набір після кожної правки.
Не змінюй вебеталон і не виконуй небезпечних операцій із телефоном.

Якщо всі критерії виконано — передай результат і зупинись.
Якщо виник нерозв’язний без нового дозволу/доступу блокер або
вичерпаний доступний ліміт — збережи checkpoint і заверши цей запуск
як PARTIAL/BLOCKED, не як успішно завершене перенесення.
```

The run was stopped by the owner mid-checkpoint 2 with: "record where you stopped, create a file with the initial
prompt and continuation information, then commit and push to develop". This commit is that checkpoint; the
transfer is **PARTIAL (in progress), not complete**.

## Where the work stands

- Reference: `design/home-lab/` at `86873ce` (acceptance `ed29554`), unchanged. Registry, protocol and evidence:
  [HYBRID_TRANSFER_STATUS.md](HYBRID_TRANSFER_STATUS.md), [evidence/hybrid-transfer-2026-10-22/](evidence/hybrid-transfer-2026-10-22/).
- Checkpoint 1 — done: reference fixed, tools verified (browser capture, host render, emulator drive), first
  web/host/Android pair opened, registry written.
- Checkpoint 2 — in progress (shared components + Tonight → Plan → block editor → Apply → Save → reopen):
  - Foundation done in code: Source Serif 4 (opsz 14, OFL) and Lucide licence bundled; role type scale and serif
    styles (`AppTypography`); `HybridTokens` regenerated from the final computed cascade (Notion blue, success /
    caution / error washes, selected hour, gain gradient, blue-ramp sky with black dark, Field action `#FF0000`);
    caution colour `#754600` / `#FFCA70`; buttons (WQA-01 Field primary red with black text, pressed = selection
    fill, disabled 0.55); dialogs (WQA-04: insets 20, radius 12, control-border outline, no shadow, barrier
    `#00000055`, outlined/filled actions); `HybridIcon` SVG renderer and registry; disclosure (`CollapsibleSection`
    20/600, caption, 18 px chevron, top rule); compact status labels; context chips; root navigation (Roboto 11,
    56 px buttons, subtle selected fill); shared parts (`hybrid_parts.dart`: section title, facts, notes, plan
    row, night row, choice row + radio, apply bar, close button).
  - Formats aligned with the reference: dates "19 Oct" / "Night of 19 Oct" / "Sat 24 Oct" / "25 Sep 2026",
    percent "62%", preview instant "19 Oct, 21:15 GMT+3" (old deviation D-04 dropped; it was never an owner
    decision).
  - Timeline (`NightBarSection`): reference geometry, Dark starts / Dark ends jumps, opening at dark start (or
    now), legend, encoding note, "Exact times & reading key", Field thumb/track per WQA-03 cascade.
  - Home (Tonight) rewritten to the reference composition; host pair at 375 light is within ~1–3 px (see
    engine note below); dark/field reviewed on host.
  - Plan rewritten: identity + compact state, answer, Site and night / Target / Rig rows, Capture plan blocks
    (title, math, records, source, fit, Edit/↑/↓/Remove), equal Add block / Build calibration, Estimate 2×2,
    Budget and assumptions, Stacking gain details (table + new graph), Rig details, night rows, save bar text.
    New scoped screen `plan_context_screen.dart` (Site and night with Apply changes).
  - Block editor: leaving a changed editor now asks "Discard this edit?" (Keep editing / Discard edit).
- Not yet done: everything else in the registry (see status record), Android confirmation of checkpoint-2
  surfaces, the save/reopen scenario on a file database, tests, release APK.

## Verification state at this commit

- `flutter analyze --no-pub` (whole package): no issues. `dart format`: changed files formatted.
  `dart run tool/check_encoding.dart`: passed.
- **Unit/widget tests were not run after these changes.** Expected failures to triage (update to the reference,
  never weaken): string assertions on the old date/percent formats ("Mon, Oct 19", "62 %"), Home's removed
  Welcome link (`tonight.welcome`), the root navigation (no Material `NavigationBar` any more), plan status figures
  (`status.number.Integration` removed; "Capture end: …" sentence), planner context (`ContextLine` replaced by the
  Site and night row), block rows (`ListTile` removed; `Remove` text button keyed `capture.delete.N`), assumptions
  now inside "Budget and assumptions", the gain graph (new geometry, "×" values, "Comparison:"), dialog buttons
  (outlined/filled instead of text buttons; "Save and leave"), the block editor's leave prompt, hybrid token
  values in `test/core/theme/hybrid_tokens_test.dart` (should compare with
  `evidence/hybrid-transfer-2026-10-22/web/computed-theme-vars.json`, the final cascade, not `tokens.json`).
- Host renders only for checkpoint 2; the last emulator capture is checkpoint 1 (before these changes).

## Known decisions and constraints to carry

- Engine line-height quantization: Flutter's SkParagraph rounds every line box to whole logical pixels (21.7 → 22,
  23.4 → 23, 19.5 → 20; no `StrutStyle`/leading option avoids it), so long stacks drift up to ~2–3 px against
  Chromium. Recorded as an engine constraint; owner decision may be needed if §4's "no accumulated drift" is held
  strictly.
- Kept native adaptations (record them, do not hide): five frame types (Dark flat), filter list instead of free
  text, From a photo only where files can be read (old D-08); fill/trim action under the block actions; native
  capability rows (FOV, pixel scale, NPF, max sub) and the plan's tracking override inside Rig details; target
  max-altitude / altitude-now in the Target row caption; the Flutter example plan differs from the web demo plan
  (domain data, not changed).
- Superseded dirty work (2026-10-21 rig/target editor fixes) is still uncommitted and untouched; its diff is
  preserved locally in `evidence/hybrid-transfer-2026-10-22/preexisting-dirty-2026-10-21.patch` (SHA-256
  `d4595caa…74`, deliberately not committed). These files are excluded from this commit.
- Devices: only the disposable emulator `emulator-5554` (AVD `culmina_hybrid_native_qa`); the owner's phone
  (`PRRGPZ8PZ5E6OJ7T`) was connected and never touched. The emulator was set to `wm density 320`,
  `wm size 750x1697` and gestural navigation (375 × 760 dp app area); `wm size reset` / `wm density reset` restore it.
- Tooling: [tool/design/hybrid_transfer/README.md](../../../tool/design/hybrid_transfer/README.md).

## Next steps (in order)

1. Run the targeted tests of the changed areas (theme/tokens, Tonight, planner, capture plan, night browser,
   confirmation patterns, navigation) and update old assertions to the reference; fix real regressions.
2. Finish the block editor footer per the reference (note "Apply updates the draft. Save plan records it.",
   16/600 Apply, no extra Cancel; × keeps `blockDialog.cancel` semantics via the discard prompt), editor spacing,
   and verify validation/Apply/Discard/Back.
3. Restyle the Target and Rig choosers as the reference's scoped radio lists with Apply changes (HT-P02) — note
   the target screen file holds the superseded dirty edits: apply the patch decision first (ask the owner whether
   to discard it, or build on top without committing those hunks).
4. Android capture of Home/Plan/editor/context on the emulator; scenario Tonight → Plan → Edit → Apply → Save →
   cold restart on an isolated file database → reopen.
5. Continue the registry: Night/Moon, Weather A/B + the Weather view preference (HT-W04), Logbook, Library,
   Settings, then the final checks and the release APK smoke (§7, §9).
