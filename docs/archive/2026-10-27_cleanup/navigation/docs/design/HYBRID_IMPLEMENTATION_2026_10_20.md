> **Historical navigation copy — not active instructions.** Link destinations are rebased from `docs/design/HYBRID_IMPLEMENTATION_2026_10_20.md`. Content and acceptance statements retain their original date/scope. [Immutable original](../../../docs/design/HYBRID_IMPLEMENTATION_2026_10_20.md) · [Navigation index](../../../NAVIGATION.md). Original SHA-256: `82c4f5b4da9266f25979f50d25ae4c14ea40859257e6e77e7f7b6424e8b15fbc`.

# Hybrid implementation and re-assessment — 2026-10-20

Subsequent owner-authorized work: [seven focused Hybrid refinements](HYBRID_SEVEN_REFINEMENTS_2026_10_20.md). This report preserves the earlier hybrid4 implementation and its 32/40 assessment.

The owner authorised implementation of all proposals from [the application-wide review](HYBRID_REVIEW_2026_10_20.md), use of skills/subagents/CLI agents, and a final Claude design QA. This record concerns the original **Hybrid (`variant=blend`) Android browser prototype**. It does not reopen the native roadmap or adopt changes into Flutter.

## Delivered scope

| Review area | Implemented behaviour | Evidence |
| --- | --- | --- |
| H1: identity and browsing | Catalogue titles resolve the actual designation. Conditions retains viewed view/date/cursor/calendar state in the URL, restores equivalent keyboard focus and announces changes. Viewing does not adopt/save the night. | `conditions.md`, `conditions-browser.json`; Library report |
| H2: Home interaction boundary | Site/date/candidate choices use phone-bound English screens with Cancel. Opening from a scrolled Home keeps Back in the viewport. Compact Weather remains a widget. The established smooth scientific ramp and font pair remain. | `continuity-checks.json`, `qa-home-*.png` |
| H3: answers first | Moon leads with exact moon-free duration/interval and earlier calendar access; full rail guide remains disclosed. Logbook leads with outcome and planned/recorded comparison, followed by a closed read-only full snapshot. | Conditions and Logbook reports/captures |
| H4: forms | Required rig/camera/sensor/optics precede optional manufacturer/model. Unknown record groups are summarised with full records reachable. Planning has an editable budget control on the first 200% viewport. Result/calibration context is shorter. | Library/Settings report; editor screenshots |
| H5: language and controls | Needed in imaging window, Total session time and Integration name distinct quantities. Apply changes, Save plan and Save result retain separate effects. Immediate switches have visible tracks; About links have separate48px targets. Operational values lead provenance. | Browser matrix and interaction checks |
| Other page refinements | Night events/reading guide and Weather provider/trust detail remain reachable; warnings stay visible. Progress scans by actual target/filter/compatible group. Targets retain read-only versus editable identity/units; Sites keep coordinates and zone together. Privacy retains complete provider disclosure. | Per-area reports and all-page captures |
| Library → Plan continuity | Actual locally saved rig/target/site records appear in the existing pickers. Selection explicitly copies the record into the plan. Stable Library IDs distinguish equal names. Later Library management does not rewrite saved/current snapshots. | `check_bridge.mjs`; actual CRUD integration flow |
| Settings → current Plan | Supported global per-frame time, percentage fit margin and setup defaults recalculate the current budget without writing the saved plan. Save plan explicitly captures an effective budget. Explicit plan assumptions win; Use global defaults removes overrides rather than freezing a copy. Null setup means Off/0 when preferences exist; absent preferences preserve the legacy fixture. | `continuity-checks.json`, model checks |
| Return context | Conditions URL, workspace tab, Library query/selection/scroll, Logbook query/filter/selection/scroll and Home position survive appropriate returns. Unsaved workspace form drafts are not silently saved in navigation storage. Existing Cancel/discard guards remain. | Worker checks and interaction suite |
| Existing flow representations | Reachable Welcome; actual local metadata JSON validation/review/Apply; explicit browser-location request with review and manual coordinates; session text/full JSON downloads; checked full browser-prototype backup. | Library/Settings, Logbook and Backup reports |

Custom target/site coordinates produce **unknown imaging windows/conditions**, rather than using the example window as a computed prediction. Time/integration/storage budgets and explicit selection still work. Missing forecast is not zero cloud/rain. Camera-class ISO/gain/WB/focus behaviour and historical scientific values are retained.

## Backup and native-flow boundary

Settings-only JSON remains separate. Full prototype backup includes saved Plan and archive, working draft, Library, Logbook and Settings: exactly five storage keys. Files are checked before a count review and explicit confirmation. Cancel writes nothing; stale state blocks restore; refused writes attempt rollback and report incomplete rollback truthfully. Unlisted storage keys are untouched. Text session export excludes notes/coordinates; full JSON explicitly warns that it includes them.

These are real local browser operations in a **browser-only format**. Photo/RAW/FITS header extraction, map tiles/native map selection, physical GPS accuracy, native share sheets and `.astroplan` whole-database restore are not implemented or claimed by this preview. Metadata JSON/manual entry, actual browser geolocation with explicit confirmation, local downloads and all-store browser backup represent those existing tasks without simulated provider/native success. Other Planning gates/window calculations/advanced timing preferences remain explicitly stored-only in the example engine; the supported budget relationship is functional.

## Verification

- 79 model/contract tests pass:14 Plan,46 Night,15 quality,4 bridge/backup. They cover unknown sensitivity, separate integration/window/total budgets, fixed24-hour UTC/DST semantics, cursor boundaries, weather samples, snapshot isolation, settings overrides and backup stale/rollback behaviour.
- Six parent integration groups pass, using actual Library Add forms and Plan pickers, Settings Save/current budget/explicit Plan Save, reset-to-global behaviour, phone-bound Home choices/Cancel, backup dispatch and denied-storage fallback. Browser page errors: none.
- Final browser suite:36 root configurations,51 inner views,12 Home cases,9 palette cases and9 states;11 interaction groups pass. Separate targeted workers checked20 Conditions assertions,11 Library/Settings behaviours plus6 final refinements,8 Logbook groups and5 backup groups. Counts overlap and are not unique screen totals.
- The first simultaneous browser launches timed out before any completed case. Unchanged helpers mounted in diagnostic probes and sequential suites passed. Resource diagnostics saw two `ERR_NO_BUFFER_SPACE` requests during enumeration; both resources subsequently returned200 in a bounded probe. Resource pressure is a plausible explanation, not a proven root cause. Initial failed evidence is preserved.
- During the first final Home capture, opening a choice after scrolling could put Back outside the host viewport. The geometry/scroll handling was repaired; the candidate close scenario and complete Home/editor capture pass then succeeded.
- Impeccable detector ran once after implementation:8 contextual findings, identical categories to the review (seven shared/comparison font warnings and the meaningful missing-cloud hatch). Actual Hybrid uses Manrope; no font replacement or data-encoding removal was justified.
- JavaScript syntax and `git diff --check` pass. Native design-source snapshots are separately hash-checked. No Flutter analyzer/build, Android emulator/device acceptance, provider accuracy, physical GPS result or general accessibility certification is claimed. The documented field-theme secondary contrast exception remains.

## Tools and durable evidence

Applied Impeccable and Culmina rules/components/spacing/tokens/typography. Three implementation subagents owned Conditions, Library/Settings and Logbook/Backup; the parent integrated Home/Plan/shared state. AntiGravity CLI supplied a read-only bridge review; concrete validation/unknown-window concerns were reconciled against code and tests, while unsupported severity and intended Saved·changed behaviour were not treated as defects. Claude CLI completed the independent screenshot/source QA and one bounded confirmation, recorded below.

[Evidence directory](../../../../../../design/home-lab/evidence/hybrid-implementation-2026-10-20), [Conditions](../../../../../../design/home-lab/evidence/hybrid-implementation-2026-10-20/conditions.md), [Library/Settings](../../../../../../design/home-lab/evidence/hybrid-implementation-2026-10-20/library-settings.md), [Logbook](../../../../../../design/home-lab/evidence/hybrid-implementation-2026-10-20/logbook.md), [Backup](../../../../../../design/home-lab/evidence/hybrid-implementation-2026-10-20/backup.md), [Integration](../../../../../../design/home-lab/evidence/hybrid-implementation-2026-10-20/integration.md), [Screenshot catalogue](../../../../../../design/home-lab/evidence/hybrid-implementation-2026-10-20/CLAUDE_QA_SCREENSHOTS.md).

The loopback preview server remains available at `http://127.0.0.1:4173`. Tests used isolated Edge profiles on localhost; the owner's original127.0.0.1 tab/storage was not automated or cleared. All entrypoints/modules use revision `20261020-hybrid4`. No commit/push or native adoption was performed.

## Final QA correction batch

Claude CLI independently read35 screenshots and five source reads, returned `is_error:false`, and scored the first implemented state30/40 against the historical29/40. That initial result is retained in [CLAUDE_DESIGN_QA.md](../../../../../../design/home-lab/evidence/hybrid-implementation-2026-10-20/CLAUDE_DESIGN_QA.md); its partial/unseen rows are visual-method limits, not substitutes for the recorded interaction checks.

Confirmed findings were corrected in one batch: a valid settings-file review now replaces a previous invalid-file announcement and refuses older asynchronous reads; restore scope names the current budget effect; repeated target identity is reduced; all three outcomes are visible sooner at200%; fixed-minute margin help and the active budget label distinguish a global percentage; Home site/date copy and field-mode icons match; rig-name placeholder is shorter. Weather now displays existing native freshness thresholds (aging3h, stale12h) independently of sample coverage, with an immediate warning for an old example snapshot. This changes presentation, not forecast samples or scientific calculations. A real0% probability is labelled0% in sampled hours; Reload example names the actual action.

The alleged Planning header overlap was not reproduced: appbar bottom and scroll viewport top are both253.671875px. A partial radio in the mid-scroll image is normal clipping at that boundary. The first budget control is visible in the corrected first-view capture. Transient status messages are retained as nonblocking confirmations rather than hidden for screenshots.

The broad matrix belongs to the pre-correction hybrid3 state; focused tests of the changed flows, current JavaScript syntax,79 model/contract checks, the six parent integration groups and new confirmation captures apply to hybrid4. Unaffected matrix cases were not repeatedly rerun. Native source hashes remain identical for all21 inventoried sources.

## Final result

Claude's bounded confirmation read eight correction images plus supporting evidence, returned `is_error:false`, and scored **32/40** (initial implementation30/40; historical baseline29/40). It withdrew the alleged Planning overlap and confirmed the restore-state, target/result hierarchy, margin and Weather corrections. It reported no P1 issue. The sole remaining actionable P2 concerned Home wording in two older images read while those paths were being refreshed. A narrow freshness correction using uniquely named final files then returned `is_error:false` and confirmed both paragraphs are word-for-word identical. That P2 is closed by the current source, parent render inspection and the CLI's exact image transcription; the score was not rerun or inflated.

[Final Claude QA](../../../../../../design/home-lab/evidence/hybrid-implementation-2026-10-20/CLAUDE_FINAL_QA.md) retains the original confirmation verbatim. [Home evidence correction](../../../../../../design/home-lab/evidence/hybrid-implementation-2026-10-20/claude-home-evidence.json) resolves its stale-image caveat. The result-editor focused test file is `logbook-result-qa-fix.json`; the confirmation prompt accidentally named `logbook-result-200-qa-fix.json`, so Claude correctly marked that optional file unseen and judged the actual PNG. The correctly named evidence remains available.

The32/40 score is expert heuristic judgment, not a usability measurement or release certification. Remaining limitations are browser/native coverage boundaries and minor optional observations: date spans deliberately retain the evening-to-morning range; short-lived nonblocking status messages may overlay scrolling content; harmless replacement of identical settings remains allowed. They do not reopen the approved refinement queue.

### Completion evidence by frozen criterion

| Criterion | Current evidence / outcome |
| --- | --- |
| C01 catalogue identity/read-only/units | Library source fix; worker catalogue and custom-target CRUD checks; final target200% capture — complete. |
| C02 Conditions focus/URL/no adoption |20 targeted assertions, URL/reload and keyboard reports; saved/draft sentinel bytes unchanged — complete. |
| C03 Home phone boundary/Cancel/200% | Six-group integration includes phone geometry, scrolled candidate close,100/200% and draft absence after Cancel; final exact-copy evidence — complete. |
| C04 Moon/Night answer/detail/time meaning | Revised renders, calendar/focus checks,46 unchanged Night model contracts; Claude visual confirmation — complete. |
| C05 compact Weather/trust/warnings | Home12-case matrix, numerical widget checks, Conditions worker states; new freshness regression with native3h/12h threshold source; final warning capture — complete. |
| C06 Logbook comparison/full immutable snapshot | Worker saved snapshot comparisons and result CRUD; final detail renders — complete. |
| C07 result/progress/future-entry scanning | Eight worker groups plus focused200% Outcome/Cancel/invalid count/Save/snapshot check; compatibility groups preserved — complete. |
| C08 rig ordering/required validation/full record | Library worker metadata/save/required-class/sensor tests,200% captures, full unknown record reachable — complete. |
| C09 site grouping/no activation | Actual site Add validation, separate explicit Plan selection; GPS review/manual fallback tests — complete. |
| C10 Planning/switch/privacy/About | First-control200% geometry,52×32 tracks with48px row targets, privacy failure/Retry, About target checks; full disclosure retained — complete. |
| C11 time/action/provenance vocabulary | Plan source and rendered labels; distinct block Apply/plan Save/result Save interaction checks; margin explanation confirmed — complete. |
| C12 Library-to-Plan snapshots | Actual Add rig/target/site forms→existing pickers→Save; later Library rename leaves snapshot bytes unchanged; bridge model tests — complete. |
| C13 Settings-to-current-Plan scope | Effective budget changes without saved-plan write; explicit Save snapshot; per-plan override/reset; Off setup0; pure bridge tests — complete for the supported fixture budget, other engine settings explicitly stored-only. |
| C14 appropriate navigation context | Library/Logbook worker Back/reload/query/scroll/tab tests, workspace tab persistence, Home session return position and Conditions URL handling — complete. |
| C15 existing-flow representations | Welcome route, actual local JSON review/Apply, explicit browser-geolocation confirmation/manual fallback, real privacy-scoped text/JSON downloads — complete as browser representations, without native extractor/map/share-sheet claims. |
| C16 checked full prototype backup | Five worker groups plus pure schema/archive/stale/rollback tests and live Settings dispatch mount — complete for the declared browser format; native database restore excluded. |
| C17 honest custom coordinates | Model returns usable/window start/end unknown; actual custom CRUD→Plan shows unknown window, Home unknown conditions; selections/budgets persist — complete. |

All requested browser implementation and QA work is complete at revision `20261020-hybrid4`. No required native adoption or external publication is implied. Current file hashes and tool outputs are retained alongside this report.
