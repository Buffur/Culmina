# Logbook refinement evidence — 2026-10-20

Scope: original Hybrid browser prototype only. Changed `logbook.js` and `logbook.css`; native Flutter/data remain untouched. Applied Culmina rules/components/spacing and Impeccable craft-floor against the authorized review.

- Outcome and planned/recorded comparison precede the closed, labelled read-only snapshot. All previous snapshot values remain reachable; camera class, sensitivity-control identity and unknown RA/Dec are explicit too.
- Result editor leads with target/night, site/rig and integration; full planned lights remain disclosed. Future-entry action copy is shorter. Progress distinguishes target totals, filter totals and the existing compatible capture groups; unknown sensitivity never merges.
- Session-only navigation context retains query/filter/list position and detail/Progress through return/remount/reload. Result drafts are not put in sessionStorage.
- Deliberate local text-summary and full JSON download actions represent existing session-sharing/export intent. Following native `entry_share_text.dart`, text omits notes and coordinates; full JSON includes both with visible privacy copy. JSON is explicitly a browser-preview envelope, not manifest v2/native backup. No provider or sharing service is called.
- Exported `validateLogbookPayload(raw)` accepts parsed or serialized envelopes and returns a pure boolean using existing historical-plan and result validators. Used by `readStore`; suitable for preview backup review. No current-plan conversion or history rewrite was introduced.

## Actual checks

Isolated fresh headless Microsoft Edge profile, `http://localhost:4173`; owner `127.0.0.1` origin/storage untouched. Eight grouped checks pass in `logbook-checks.json`: search/reload, answer hierarchy/detail reload, compact editor + invalid counts + Cancel + immutable save, exact text/JSON downloads, Back position/tab return, Delete/Undo + two filter/five compatibility groups, light/dark/field at 100/200% (no horizontal overflow or <48px buttons/disclosure headers), no page errors/plan checkpoint writes. Screenshots alongside this report.

Additional isolated check: simulated result-write failure retains count 43 and leaves storage empty; Retry saves count 43. Validator accepts valid string/object envelopes and rejects malformed JSON, duplicate entry IDs and a wrong-typed snapshot field. `node --check design/home-lab/logbook.js` passes.

These are browser prototype checks, not native Android accessibility, gesture, database, or device acceptance. Final application-wide QA/Claude review belongs to the parent integration pass.

## Final Claude-QA follow-up: result editor at 200%

Claude's integrated review found the result identity still consumed too much enlarged-text space. A bounded follow-up keeps target/night first and moves site, rig and planned integration into the existing renamed **Plan context and light frames** disclosure. The fieldset now says **Outcome**, avoiding the repeated appbar question. No fields, snapshot values or result behavior were removed.

Targeted isolated Edge confirmation passed: all three outcome choices are visible in the first phone viewport at 200% text; the first is fully visible at 41% of the scroll area's height. The disclosure retains site/rig/integration/frame identity. Dirty Cancel preserves the draft when dismissed and discards only on confirmation; negative count remains blocked; valid Save changes result counts without changing the full saved snapshot. The screenshot was visually inspected. Evidence: `logbook-result-200-qa-fix.png` and `logbook-result-qa-fix.json`. No broad suite was repeated. `node --check` passes.
