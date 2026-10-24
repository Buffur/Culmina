# Culmina — current progress

Status: **current operational handoff**, 2026-10-24. Read [AGENTS](../../AGENTS.md); [V1–V8](../VERIFICATION_POLICY.md) alone owns checks. This file records state, not an automatically active queue.

## Current state

| Item | Current record and evidence boundary |
| --- | --- |
| Integration baseline | `develop` at `89c6c4879fb91b002f15caffcdcf3aeda004d58f`, the exact restoration of the original three-shard workflow from `c045898`; remote result #25 success. Final Markdown delivery follows; no application/test/tooling input changes. |
| Current authorized scope | Owner-authorized warm-cache 2/3-shard benchmark, restoration to three shards and final report are complete. Only final Markdown commit/push and its lightweight CI observation remain within this delivery. No permanent two-shard adoption or further benchmark loop, roadmap/UI/build/device action is authorized. |
| Actual comparative runs | Two shards: [#24](https://github.com/Buffur/Culmina/actions/runs/40046527390), `9fb503e`, **300s / 799 runner-seconds (13.317 min)**. Three shards: [#25](https://github.com/Buffur/Culmina/actions/runs/40047002928), `89c6c48`, **273s / 966 runner-seconds (16.100 min)**. Every heavy job in both runs had SDK and pub cache hits. Same app/tests/tooling, weights, cache keys, SDK and OS image. |
| Coverage verification | **PASS in both full runs**: 2509 unit/widget PASS / 6 SKIP across 285 files once per run, plus 3 host PASS. All 13 artifact ZIP digests verified; raw JSONL profiles reconstructed and matched to receipts/remote aggregates. Exact unit and host file/name/outcome multisets equal the reference; unit SHA-256 `3caf5bdd9d52388f030328b5b85b22545ab057128b55aa162a99660dbbe04c44`. Static checks, 8 Python regressions, schema/selection/aggregate safeguards and final scope/links/whitespace checks PASS. No extra local full suite. |
| Conclusion / limits | In this measured pair, two shards saved **167 runner-seconds (2.783 min, 17.3%)** for **27s more elapsed CI (+9.9%)**. It is a reasonable resource-saving tradeoff if about half a minute longer feedback is acceptable; three remains preferable for minimum latency. No owner tolerance was invented. One pair is not a statistical guarantee; runner provisioner versions differed although OS image matched. Three shards are restored exactly as requested. [Detailed metrics and machine-readable summary](../CI.md#warm-cache-results---2026-10-24). |
| Acceptance boundary | Hybrid transfer section 9, P-1 through P-6, TD-120/TD-121, identity/geo owner visual acceptance, physical accessibility and F/G/release conditions are unchanged; this CI comparison approves none of those separate criteria. |
| Preservation | Application/test/tooling/reference/evidence bytes unchanged; common source tree fingerprint `d683acebeb7b5c4c801e520c1d4cb3f4b2213a5303c7cf7279b97c5b001488cc`. Prior handoff preserved at [history](PROGRESS_HISTORY.md#warm-cache-shard-comparison-pre-result-handoff---2026-10-24). Raw reports, verified metrics and originals remain outside Git in temporary `culmina-warm-shards-kyrjn__8/remote24` and `remote25`; Actions artifacts expire 2026-11-07. |

## Next allowed action

**Stop after the final Markdown commit/push, exact remote-SHA check and its documentation-only CI check.** The requested comparison is complete and the default is back to three shards. A permanent two-shard switch is a separate owner decision; neither another full run nor weight/fixture tuning is automatically authorized. Existing owner/device/F/G criteria remain unchanged.

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

The [warm-cache pre-result snapshot](PROGRESS_HISTORY.md#warm-cache-shard-comparison-pre-result-handoff---2026-10-24) preserves the benchmark handoff before this measured result. The [remote-result pre-handoff snapshot](PROGRESS_HISTORY.md#ci-delivery-pre-result-handoff---2026-10-24) preserves the completed implementation handoff. The [CI pre-task snapshot](PROGRESS_HISTORY.md#ci-optimization-pre-task-snapshot---2026-10-24) preserves the complete previous operational handoff. The [maintenance pre-fix snapshot](PROGRESS_HISTORY.md#design-skills-maintenance-pre-fix-snapshot--2026-10-24) preserves the previous handoff and its earlier nested records verbatim. Earlier governance/stage history and immutable audits/evidence retain their original bytes. Their old commands/permissions are inactive; [BASELINE](../design/BASELINE.md) maps accepted intent, implementation and evidence limits.

## How to update this file

Keep one short current handoff; preserve superseded status verbatim with source/revision in PROGRESS_HISTORY under AI_WORKFLOW. Update only invalidated claims/related registers, retain stable IDs and exact evidence/acceptance boundaries, then stop at the owner's task boundary.
