# Culmina — current progress

Status: **current operational handoff**, 2026-10-24. Read [AGENTS](../../AGENTS.md); [V1–V8](../VERIFICATION_POLICY.md) alone owns checks. This file records state, not an automatically active queue.

## Current state

| Item | Current record and evidence boundary |
| --- | --- |
| Integration baseline | `develop` / `origin/develop` at `c045898d93b5e43112895592ba1d7ddb6cd26615`; fresh remote SHA matched, preflight clean, index empty, one worktree. Current published CI uses three unit shards. |
| Current authorized scope | Owner requested a measured comparison of 2 versus 3 shards with warm SDK/pub caches, preserved test inventory and explicit runner-minutes/latency tradeoff. The owner explicitly authorized this benchmark commit/push sequence, restoration to three shards and final report on 2026-10-24. No application, test, dependency, cache-key, SDK/image, main-branch or device changes. |
| Prepared benchmark | Exactly three workflow lines change: unit indexes 0/1, `run unit --shards 2`, `aggregate --shards 2`. After the two-shard run, restore the original workflow exactly and observe the three-shard run. Both use the same application/test/tooling/weight inputs on develop so they can restore its existing caches. Record actual cache hits per job; never label a miss as warm. [Protocol](../CI.md#warm-cache-comparison-protocol). |
| Local verification | Eight Python CI regressions PASS; synthetic two-shard routing/aggregation accounts for all 285 files split 142/143 and the same 2509 PASS / 6 SKIP test records, with the established inventory SHA-256. Missing/duplicate/wrong-count shards fail. This reuses recorded test streams to verify routing, not an executed two-shard suite or runtime measurement. Workflow YAML/arguments and diff/scope checks apply; application inputs are unchanged and local full suites are not repeated. |
| Measured baseline / pending | Existing cold #22: workflow 326s, runner-minutes 21.400; 2509 unit PASS / 6 SKIP + 3 host PASS. #23 documentation-only check passed. Both new warm-cache measurements, downloaded-stream coverage comparison and final recommendation remain PENDING the now-authorized comparative runs. Cold results are not a warm-cache baseline. |
| Acceptance boundary | Hybrid transfer remains accepted only within its recorded section 9 contract. P-1 through P-6, TD-120/TD-121, identity/geo owner visual acceptance, physical accessibility and F/G/release conditions remain unchanged. Host/CI does not self-approve them. |
| Preservation | Application/test/tooling/reference/evidence bytes remain unchanged. Pre-task PROGRESS preserved at [history](PROGRESS_HISTORY.md#warm-cache-shard-comparison-pre-task-handoff---2026-10-24); recoverable workflow/PROGRESS originals and synthetic fixtures are outside Git in temporary `culmina-warm-shards-kyrjn__8`. Existing remote evidence remains in the CI document and prior history. |

## Next allowed action

**Execute the owner-authorized benchmark commit/push sequence in develop:** two shards, restore the original three-shard workflow, and the final Markdown result/handoff. Then run exactly that comparative pair, verify all SDK/pub hits and unchanged test multisets, report elapsed and runner time separately, and stop. A noisy or non-warm result is inconclusive rather than an automatic additional full-run loop. Do not permanently change the default solely to perform this comparison.

## Open questions and carried criteria

This is a current routing summary, not a newly adjudicated task register. Stable criteria, findings and original evidence remain in their canonical registers and the preserved history. Do not close an item by analogy with a newer passing test.

| IDs / surface | What remains / source for a future specifically authorized task |
| --- | --- |
| F01/F06/F10/F24 and review findings | The 2026-10-19 independent review records contradicted criteria and Windows failures at its dated baseline. Reproduce only relevant findings against current code before action; later implementation and passing suites do not prove their exact closure. [Review and criterion matrix](DEVELOP_IMPLEMENTATION_REVIEW_2026_10_19.md). |
| F03 A5 versus F10 A3; F04 A4 | F03's early sample/resource-recording criterion is distinct from F10's actual real-FITS workflow gate (as the independent review explains). Real metadata/device evidence needs the exact file/workflow and unchanged reader inputs. Private samples stay outside Git. No new real-file run is claimed here. |
| F02 A2/A3; S13V-01/TD-109; S13V-02/03 | Current launch/identity is integrated and API30/physical observations exist. The old “no SDK anywhere” explanation is obsolete; criterion-specific pre-12/12+, reduced-motion and timing qualification still needs explicit mapping to the final source/artifact/environment. Do not silently close historical device rows. |
| F15 A4; F22 A1; F23 A2 | Calendar phone timing, Android process death/restoration, resolved Android dependency notices: retain exact criteria and evidence gaps. An available SDK, emulator drive or host PASS alone is insufficient. |
| F25 A4, U/W; TD-114–TD-121 | Explicit owner visual acceptance, human comprehension, physical 200%/TalkBack and other unexercised rows remain separate from implemented/host/native evidence. Consult the named delivery reports for covered and excluded scenarios. |
| G1; F26 / D6; G2–G4 | Frozen integration/CI/provider, packaging/measurement, owner signing, physical/human rehearsal, go/no-go and publication conditions remain. The combined debug-signed owner test APK is not F26 release qualification. No gate closure or publication permission is inferred. |
| S1.5/S1.11, S2V-06, S3V-08, S10V-04, S11.6/S11.7 | Retained carried device/profile/human criteria: [STAGE_11_MATRIX](STAGE_11_MATRIX.md), [device runbook](STAGE_11_DEVICE_RUNBOOK.md) and historical dispositions. S6.E remains an owner-accepted **unverified** independent-participant gap, not a performed test. |
| TD-072/S3F-01/S3F-02; TD-074; other TD/SI | Use current [TECH_DEBT](../TECH_DEBT.md) / [SCIENTIFIC_INTEGRITY](../SCIENTIFIC_INTEGRITY.md) entries and exact partial-resolution boundaries, not old “open defects not fixed” lists. This cleanup changes no finding dispositions. |
| RD-02; RG-12; S12.2 | ADK skill / skills-lock / archive retention remains owner housekeeping, licence research remains deferred, trademark check remains optional. Preserve all material; none is deletion authority. [RG/RD registers](POST_ROADMAP_PLAN.md). |
| Original evidence / external overrides | Private historical backups/device captures were not assumed available or copied into Git. Uninspected managed/cloud overrides remain unknown. Local auto-memory contains dated continuation hints; repository sources take precedence within the applicable instruction hierarchy. |

## Reusable validation evidence

Apply [V3](../VERIFICATION_POLICY.md#v3) per result, relevant inputs and environment. The CI task ran the complete host suite on its final relevant inputs. Device/owner evidence below retains its original scope; passing host tests do not approve those rows.

| Evidence | Input / applicability |
| --- | --- |
| [Combined delivery report](../design/migration/CONSOLIDATED_DELIVERY_2026_10_24.md) and [verification.json](../design/migration/evidence/consolidated-2026-10-24/verification.json) | Source `8a21e7b`; host suite/E2E plus final 16 regressions and final analysis/format/encoding, API30 seven-frame capture, normal launch/hot reload, scoped canonical-phone inspection. The report preserves the original analyzer failure; it does not label that whole invocation green. Application/native inputs remain unchanged. The current CI task changes test/tooling inputs, so its new host/CI results above supersede this older host-gate result; native evidence retains its original coverage and acceptance limits. |
| [Hybrid transfer completion](../design/migration/HYBRID_TRANSFER_STATUS.md) | Its committed source, named pairs/Android captures and §9 owner's confirmation; later affected surfaces use their refinement reports. Exclusions stay explicit. |
| [P-1–P-6 delivery](../design/migration/PHONE_QA_FIXES_DELIVERY_2026_10_23.md), [TD-120](../design/migration/TONIGHT_CONTEXT_FIXES_2026_10_23.md), [TD-121](../design/migration/GEO_OWNER_REFINEMENT_2026_10_23.md) | Scoped host/native/physical observations on their recorded inputs. The consolidation states what remained unchanged; do not generalize to untested settings, owner acceptance or F/G gates. |
| Historical application CI | Fresh GitHub connector read on 2026-10-24: run [40029616135](https://github.com/Buffur/Culmina/actions/runs/40029616135) completed/success at exact source `8a21e7b`. Historical observed CI at its source; current changed test/tooling inputs are verified by #22 above. This older run is not the new CI result or G1/F26/G2-G4 closure; the original consolidation status remains historical. |

## Historical routing

The [remote-result pre-handoff snapshot](PROGRESS_HISTORY.md#ci-delivery-pre-result-handoff---2026-10-24) preserves the completed implementation handoff. The [CI pre-task snapshot](PROGRESS_HISTORY.md#ci-optimization-pre-task-snapshot---2026-10-24) preserves the complete previous operational handoff. The [maintenance pre-fix snapshot](PROGRESS_HISTORY.md#design-skills-maintenance-pre-fix-snapshot--2026-10-24) preserves the previous handoff and its earlier nested records verbatim. Earlier governance/stage history and immutable audits/evidence retain their original bytes. Their old commands/permissions are inactive; [BASELINE](../design/BASELINE.md) maps accepted intent, implementation and evidence limits.

## How to update this file

Keep one short current handoff; preserve superseded status verbatim with source/revision in PROGRESS_HISTORY under AI_WORKFLOW. Update only invalidated claims/related registers, retain stable IDs and exact evidence/acceptance boundaries, then stop at the owner's task boundary.
