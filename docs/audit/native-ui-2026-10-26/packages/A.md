# packages/A

Text-only audit register exported from local `.audit/decisions/category-a.json`. Original SHA-256: `f858aecd5727232bd9ab37abc36dc66d44c04270512f0717dd22478df88f8e28`. Private evidence references identify local artifacts; no raw capture, device identifier, binary or executable probe is published. User-profile paths are redacted. Original canonical bytes remain unchanged.

```json
{
  "schema_version": 2,
  "authority": "Original objective section15 and explicit owner future-scope direction2026-10-26; no current implementation execution.",
  "global_exclusions": [
    "No production edits or implementation in this audit",
    "No global design-system rewrite",
    "No science/data/UTC-zone-DST/SessionNight or persistence meaning changes",
    "No font/token/palette/navigation replacement",
    "Closed Q1-Q6 and VQA030-032 retain their original caller-specific closures",
    "No Figma import/research:15 exports remain PARTIAL_INSPECTION, FULL_INSPECTION0",
    "No device/ADB, Flutter, Figma, image generation or external source operation during package drafting.",
    "Keep private captures under .audit; no owner data access, image copying outside audit, new dependencies or publication."
  ],
  "status": "FUTURE_SCOPE_APPROVED_EXECUTION_STOPPED_AT_AUDIT_BOUNDARY",
  "generated_utc": "2026-10-25T22:29:32.073924+00:00",
  "application_source_sha": "8157dcc275f1349f299e411c611888daafc035a0",
  "input_fingerprint": "e5963d808fb8e194b1c02e7de985bbd861665b41d94a653e8ae70d1197ebdcee",
  "verified_inputs": 765,
  "implementation_authorized": false,
  "owner_acceptance": false,
  "global_fix_authorized": false,
  "after_evidence": null,
  "evidence_limit": "Finite audit evidence only; current actual images and source establish bounded issues. No implemented After, full native/state or owner visual acceptance. New amendment reviews existing evidence without new runtime.",
  "conceptual_comparison_material": "../reviews/library/final-packages/conceptual-comparisons.md (schematic comparison, not Flutter After or measured benefit)",
  "category": "A",
  "finding_count": 16,
  "deduplicated_package_count": 14,
  "ready_finding_ids": [
    "UIA-0001",
    "UIA-0002",
    "UIA-0003",
    "UIA-0004",
    "UIA-0005",
    "UIA-0006",
    "UIA-0007",
    "UIA-0008",
    "UIA-0012",
    "UIA-0013",
    "UIA-0014",
    "UIA-0015",
    "UIA-0016",
    "UIA-0017",
    "UIA-0018",
    "UIA-0009"
  ],
  "ready_package_count": 14,
  "decision_gated_finding_ids": [],
  "ready_packages": [
    {
      "root_cause_id": "RC-0001",
      "title": "Caller-specific omission of cache/failed-refresh qualification",
      "finding_ids": [
        "UIA-0001"
      ],
      "readiness": "OWNER_APPROVED_FUTURE_SCOPE",
      "requires_implementation_authorization": false,
      "proposed_boundary": "At the Plan Weather caller, qualify retained available data with a neutral failed-refresh/cache cue; reuse established truthful wording where applicable and retain age/coverage/measurements.",
      "proof_limit": "Model malformed-failure proof is actual-widget host; malformed must not be called offline. Distinct Tonight/Weather closed callers remain unchanged.",
      "global_fix_authorized": false,
      "candidate_id": "CAND-A-RC-0001",
      "priority": "P2",
      "implementation_ready": true,
      "requires_owner_layout_choice": false,
      "owner_decision_ref": null,
      "impact": "Medium",
      "expected_benefit": "Truthful failed-refresh/cache context in Plan.",
      "risk_level": "Low",
      "source_refs": [
        {
          "file": "lib/presentation/screens/home/home_screen.dart",
          "line": 704,
          "anchor": "String? _weatherExtra",
          "sha256": "259fcb4ea15da74aae27b226a72290193e9cbebba502477a1f6996d6e9aa5aef"
        },
        {
          "file": "lib/presentation/screens/tonight/tonight_home_screen.dart",
          "line": 645,
          "anchor": "if (a.refreshFailed case final failure?)",
          "sha256": "331c740c307a7a9d57b0c73913380097f802a7edc2c91dd0db7acfe3060a5888"
        },
        {
          "file": "lib/domain/models/night_weather.dart",
          "line": 58,
          "anchor": "refreshFailed",
          "sha256": "19a23c4b9563b498cb4fb3e388fa22bbb3d7736cc1eba62020ccf8c87273fdc4"
        }
      ],
      "affected_callers": [
        "PLN-017"
      ],
      "dependencies": [
        "Separate implementation authorization; independent of D-A09-NARROW and W1/C1."
      ],
      "acceptance_criteria": [
        "Current/aging/stale retained available snapshots disclose malformed/network refresh failure at Plan caller.",
        "Values/coverage/source age remain unchanged; successful refresh clears failure cue.",
        "No-cache failure, no-dark and out-of-range retain distinct existing states."
      ],
      "risks": [
        "Malformed data must not be called offline.",
        "Unknown/partial/no-dark/out-of-range forecast meanings and date/zone semantics must remain."
      ],
      "scope_exclusions": [],
      "current_evidence": [
        {
          "finding_id": "UIA-0001",
          "host_status": "CONFIRMED_HOST",
          "native_status": "UNVERIFIED_NATIVE",
          "proof": [
            {
              "path": ".audit/reviews/planning/probe-output/PLN-H001-cached-malformed.json",
              "absolute_path": ".audit/reviews/planning/probe-output/PLN-H001-cached-malformed.json",
              "sha256": "9cf6accfba63f218fdafc47b1be4fc8fbababeb550ebea4cc2e0d9227c6b0112",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/probe-output/PLN-H001-cached-malformed.png",
              "absolute_path": ".audit/reviews/planning/probe-output/PLN-H001-cached-malformed.png",
              "sha256": "0018eac0275f6031704af4d4321846a05361f41428eed48cf95eb6d20e06a34e",
              "role": "CURRENT_PROOF"
            }
          ]
        }
      ],
      "root_group_status_at_snapshot": "IN_PROGRESS_COORDINATOR_ADJUDICATION",
      "future_scope_approved": true,
      "execution_in_current_audit": false
    },
    {
      "root_cause_id": "RC-0002",
      "title": "Results read path has no explicit failure/recovery UI state",
      "finding_ids": [
        "UIA-0002"
      ],
      "readiness": "OWNER_APPROVED_FUTURE_SCOPE",
      "requires_implementation_authorization": false,
      "proposed_boundary": "Actual Results load gets explicit pending/error/missing/result outcome with local Retry and request/session ownership. Preserve deleted-id fallback, eligibility, saved snapshot and result/Save semantics.",
      "proof_limit": "Final unmodified ResultsScreen+ResultsViewModel with typed held read error, unchanged test handler: runnerFAIL, loading at0/2000ms simulated time. Former200ms/subclass proof hold is superseded; no indefinite/native/release crash claim.",
      "global_fix_authorized": false,
      "candidate_id": "CAND-A-RC-0002",
      "priority": "P2",
      "implementation_ready": true,
      "requires_owner_layout_choice": false,
      "owner_decision_ref": null,
      "impact": "High",
      "expected_benefit": "Results initial read becomes understandable and locally recoverable.",
      "risk_level": "Medium",
      "source_refs": [
        {
          "file": "lib/presentation/screens/execution/results_screen.dart",
          "line": 110,
          "marker": "context.read<ResultsViewModel?>()?.load(widget.sessionId)",
          "sha256": "aee73ff0c28eac9788eaed8c7a662a463140d0de83a1aea37faa177d5ecbcf2f"
        },
        {
          "file": "lib/presentation/screens/execution/results_screen.dart",
          "line": 241,
          "marker": "if (vm == null || session == null || session.id != widget.sessionId)",
          "sha256": "aee73ff0c28eac9788eaed8c7a662a463140d0de83a1aea37faa177d5ecbcf2f"
        },
        {
          "file": "lib/presentation/viewmodels/results_viewmodel.dart",
          "line": 184,
          "marker": "Future<void> load(int id)",
          "sha256": "00259c3a2042789ca5eb4607d5513b207d6f4ebfe2f24eaba5ee97fe4c18d77c"
        }
      ],
      "affected_callers": [
        "RES-001"
      ],
      "dependencies": [
        "Separate implementation authorization; independent of D-A09-NARROW and W1/C1."
      ],
      "acceptance_criteria": [
        "Use held pending and failed-successful Retry reads; retain deleted-id fallback.",
        "Test route/id replacement and obsolete reads against same session ownership.",
        "Do not change repository data, timing eligibility, saved-plan snapshot or result contents."
      ],
      "risks": [
        "Protect request/session identity, deleted-id fallback and obsolete completion; do not change result or save semantics.",
        "Final diagnostic retains the uncaught error and terminalFAIL; no physical/release crash or indefinite hang is proved."
      ],
      "scope_exclusions": [
        "No claim of native crash, indefinite duration or owner database failure."
      ],
      "current_evidence": [
        {
          "finding_id": "UIA-0002",
          "host_status": "CONFIRMED_HOST",
          "native_status": "UNVERIFIED_NATIVE",
          "proof": [
            {
              "path": ".audit/reviews/library/results-unmodified-probe/receipt.json",
              "absolute_path": ".audit/reviews/library/results-unmodified-probe/receipt.json",
              "sha256": "ed024e1877ab1b23deeec676045e16903056ea1e8e3b07062c386deb7f2b038f",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/results-unmodified-probe/run-1.log",
              "absolute_path": ".audit/reviews/library/results-unmodified-probe/run-1.log",
              "sha256": "aaefede8e3e6b4d7cbba3a107803c38432f14a35c373d61daca0eb949af9243d",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/results-unmodified-probe/after-failure-2000ms.png",
              "absolute_path": ".audit/reviews/library/results-unmodified-probe/after-failure-2000ms.png",
              "sha256": "1c49c26cf0a7971863d02fa4d62e9b005b4eaa0846f1f6cfbbbaeb1a90ea5f90",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/probe-evidence/result-failed-read.png",
              "absolute_path": ".audit/reviews/library/probe-evidence/result-failed-read.png",
              "sha256": "561e7ba0cbb22119367183e359e8ff53df57aea9a271447d0cf24b5af588150d",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/probe-evidence/observations.json",
              "absolute_path": ".audit/reviews/library/probe-evidence/observations.json",
              "sha256": "c7dbae7702450364f35cd0f79fe9ca0e84a771ffb55697e4bc367adf77c6067f",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/probe-run-4-final.log",
              "absolute_path": ".audit/reviews/library/probe-run-4-final.log",
              "sha256": "2a92a80a01eeec24eec50fd1f45288ea80528052d660de968890f8a244f50c13",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/results-unmodified-probe/before-failure-pending.png",
              "absolute_path": ".audit/reviews/library/results-unmodified-probe/before-failure-pending.png",
              "sha256": "a6ae07e86979dca91f038b2d94031f9d6bc568e7baf426016b1579b345f58b35",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/results-unmodified-probe/after-failure-initial.png",
              "absolute_path": ".audit/reviews/library/results-unmodified-probe/after-failure-initial.png",
              "sha256": "a6ae07e86979dca91f038b2d94031f9d6bc568e7baf426016b1579b345f58b35",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/results-unmodified-probe/results_unmodified_load_test.dart",
              "absolute_path": ".audit/reviews/library/results-unmodified-probe/results_unmodified_load_test.dart",
              "sha256": "9d28e2121d7934c4023035479f308ab1e32a9f423dc3db46c3a58d6081b6188f",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/results-unmodified-probe/observations.json",
              "absolute_path": ".audit/reviews/library/results-unmodified-probe/observations.json",
              "sha256": "e77edf9128ce9c63f791736998ba68c6d926e347b80f8df71bcd8a6a6fac1e67",
              "role": "CURRENT_PROOF"
            }
          ]
        }
      ],
      "root_group_status_at_snapshot": "IN_PROGRESS_COORDINATOR_ADJUDICATION",
      "future_scope_approved": true,
      "execution_in_current_audit": false
    },
    {
      "root_cause_id": "RC-0003",
      "title": "Editor completion drops newer accepted local input; Target also conflicts with an open Unsaved dialog",
      "finding_ids": [
        "UIA-0003"
      ],
      "readiness": "OWNER_APPROVED_FUTURE_SCOPE",
      "requires_implementation_authorization": false,
      "proposed_boundary": "Repair the two local editor completion contracts: freeze editable input during the submitted write or preserve a newer local buffer and its Apply/Discard ownership. Target separately needs route-result ownership when its Unsaved dialog is current. Preserve failures and exact submitted payloads; do not automatically persist later12 or equate Apply with explicit Save plan.",
      "proof_limit": "Target Light and Plan assumptions Dark375dp100% are separately host-observed with actual immutable payload and real in-memory Drift readback. Stored earlier payloads are correct; the loss concerns later accepted local buffers. Target debug route-result assertion is not claimed for assumptions or physical/release builds. Site/Results remain source hypotheses. Accepted Q4 Rig input/exit guards stay closed; no global editor defect or shared-code repair is inferred. Assumptions final metadata carries a historical tap-phase gateCompleted:false; awaited editor closure and actual SQL/readback establish final completion. No fabricated current-gate assertion.",
      "global_fix_authorized": false,
      "candidate_id": "CAND-A-RC-0003",
      "priority": "P1",
      "implementation_ready": true,
      "requires_owner_layout_choice": false,
      "owner_decision_ref": null,
      "impact": "High: loss of later accepted local edits",
      "expected_benefit": "Preserve later accepted local input in Target and Plan assumptions; correct Target route completion independently.",
      "risk_level": "High",
      "source_refs": [
        {
          "file": "lib/presentation/screens/target/target_editor_screen.dart",
          "line": 130,
          "marker": "Future<void> _save()",
          "sha256": "1bae0d630b1a143e1098a2cd295f1fbf2b190640c1469184599e0b79e83abd9c"
        },
        {
          "file": "lib/presentation/screens/target/target_editor_screen.dart",
          "line": 115,
          "marker": "Future<void> _leave()",
          "sha256": "1bae0d630b1a143e1098a2cd295f1fbf2b190640c1469184599e0b79e83abd9c"
        },
        {
          "file": "lib/presentation/screens/target/target_editor_screen.dart",
          "line": 184,
          "marker": "canPop: _leaving || !_dirty",
          "sha256": "1bae0d630b1a143e1098a2cd295f1fbf2b190640c1469184599e0b79e83abd9c"
        },
        {
          "file": "lib/presentation/screens/sites/site_editor_screen.dart",
          "line": 555,
          "marker": "Future<void> _onBack()",
          "sha256": "72156fc93fb6521c5ce5507e8c5a1273f58cb7cc729598ac6dc294d6cdf4a55a"
        },
        {
          "file": "lib/presentation/screens/sites/site_editor_screen.dart",
          "line": 578,
          "marker": "Future<void> _save()",
          "sha256": "72156fc93fb6521c5ce5507e8c5a1273f58cb7cc729598ac6dc294d6cdf4a55a"
        },
        {
          "file": "lib/presentation/screens/execution/results_screen.dart",
          "line": 211,
          "marker": "Future<void> _save(ResultsViewModel vm)",
          "sha256": "aee73ff0c28eac9788eaed8c7a662a463140d0de83a1aea37faa177d5ecbcf2f"
        },
        {
          "file": "lib/presentation/screens/execution/results_screen.dart",
          "line": 351,
          "marker": "key: const Key('results.save')",
          "sha256": "aee73ff0c28eac9788eaed8c7a662a463140d0de83a1aea37faa177d5ecbcf2f"
        },
        {
          "file": "lib/presentation/screens/equipment/equipment_editor.dart",
          "line": 264,
          "marker": "if (saving) return;",
          "sha256": "554a399e3d891648b6e64a4eb61401d01e4e345b0768daa96e9e245999c941a2"
        },
        {
          "file": "lib/presentation/widgets/capture_plan/plan_overrides_editor.dart",
          "line": 104,
          "sha256": "74c392ce71501e942aa5adff31ba31874512e133939b47a29b4f51281cce9a77"
        },
        {
          "file": "lib/presentation/widgets/capture_plan/plan_overrides_editor.dart",
          "line": 127,
          "sha256": "74c392ce71501e942aa5adff31ba31874512e133939b47a29b4f51281cce9a77"
        },
        {
          "file": "lib/presentation/widgets/capture_plan/plan_overrides_editor.dart",
          "line": 135,
          "sha256": "74c392ce71501e942aa5adff31ba31874512e133939b47a29b4f51281cce9a77"
        },
        {
          "file": "lib/presentation/widgets/capture_plan/plan_overrides_editor.dart",
          "line": 264,
          "sha256": "74c392ce71501e942aa5adff31ba31874512e133939b47a29b4f51281cce9a77"
        },
        {
          "file": "lib/presentation/widgets/capture_plan/plan_overrides_editor.dart",
          "line": 320,
          "sha256": "74c392ce71501e942aa5adff31ba31874512e133939b47a29b4f51281cce9a77"
        },
        {
          "file": "lib/presentation/widgets/capture_plan/plan_overrides_editor.dart",
          "line": 344,
          "sha256": "74c392ce71501e942aa5adff31ba31874512e133939b47a29b4f51281cce9a77"
        }
      ],
      "affected_callers": [
        "TGT-005",
        "TGT-008",
        "CAP-028"
      ],
      "dependencies": [
        "Separate implementation authorization; independent of D-A09-NARROW and W1/C1."
      ],
      "acceptance_criteria": [
        "Hold real add/update and verify one write; prevent later accepted input being silently dropped when Save completes.",
        "Do not attempt to complete editor through an open confirmation route; verify modal/Back/Cancel/Save and completion order.",
        "Failure retains current draft and original row; Retry submits intended visible data once.",
        "Preserve exact untouchedRA/Dec/catalogid/source and normal editor geometry.",
        "In Plan assumptions, an actual pending-state tap cannot create later input that is silently discarded when the earlier Apply finishes.",
        "If input remains editable, retain its newer buffer and explicit Apply/Discard choice; do not auto-submit it.",
        "Target route-result correction and assumptions input ownership are verified independently; preserve exact payload/readback and valid failure recovery."
      ],
      "risks": [
        "Only the named Target and Plan assumptions host cases are confirmed. Site/Results race analogies remain source-only; accepted Rig guards stay closed. Gates wrap real in-memory Drift, and no owner persistent store is touched.",
        "Keep assumptions7.5 submitted result, later12 local ownership, explicit Save-plan semantics and global planning defaults distinct."
      ],
      "scope_exclusions": [
        "Target Light and Plan assumptions Dark375dp100% are separately host-observed with actual immutable payload and real in-memory Drift readback.",
        "Stored earlier payloads are correct; the loss concerns later accepted local buffers. Target debug route-result assertion is not claimed for assumptions or physical/release builds.",
        "Site/Results remain source hypotheses. Accepted Q4 Rig input/exit guards stay closed; no global editor defect or shared-code repair is inferred.",
        "Assumptions final metadata carries a historical tap-phase gateCompleted:false; awaited editor closure and actual SQL/readback establish final completion. No fabricated current-gate assertion."
      ],
      "current_evidence": [
        {
          "finding_id": "UIA-0003",
          "host_status": "CONFIRMED_HOST",
          "native_status": "UNVERIFIED_NATIVE",
          "proof": [
            {
              "path": ".audit/reviews/library/probe-evidence/target-held-save-back.png",
              "absolute_path": ".audit\\reviews\\library\\probe-evidence\\target-held-save-back.png",
              "sha256": "02bfbb89664a8352daf2bdad7641e9a2722693ec2072196e81880c643356ce80",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/probe-evidence/observations.json",
              "absolute_path": ".audit\\reviews\\library\\probe-evidence\\observations.json",
              "sha256": "c7dbae7702450364f35cd0f79fe9ca0e84a771ffb55697e4bc367adf77c6067f",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/probe-run-4-final.log",
              "absolute_path": ".audit\\reviews\\library\\probe-run-4-final.log",
              "sha256": "2a92a80a01eeec24eec50fd1f45288ea80528052d660de968890f8a244f50c13",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/target_save_readback_probe_test.dart",
              "absolute_path": ".audit\\reviews\\library\\target_save_readback_probe_test.dart",
              "sha256": "d99f4c09bbdcf04e9b120df87e5b6bf9ba8be557829737569318b7eeef3d645c",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/target-save-readback-run-1.log",
              "absolute_path": ".audit\\reviews\\library\\target-save-readback-run-1.log",
              "sha256": "c6491cea44f4a50c4e128eca5aa5f4c073c2afb2c9f259e0718de401cdbd416d",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/target-save-readback/observations.json",
              "absolute_path": ".audit\\reviews\\library\\target-save-readback\\observations.json",
              "sha256": "cbc9d19342b43bd7636246bea6f4347480be2f1022460e8e6da3b8051d2d787a",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/target-save-readback/complete_with_prompt_open-after-completion.png",
              "absolute_path": ".audit\\reviews\\library\\target-save-readback\\complete_with_prompt_open-after-completion.png",
              "sha256": "efd3929ac9544be83ede29163f2340dc98d9a341c41a7bbe0601e358ce62529f",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/target-save-readback/complete_with_prompt_open-before-completion.png",
              "absolute_path": ".audit\\reviews\\library\\target-save-readback\\complete_with_prompt_open-before-completion.png",
              "sha256": "a5a78b52a6c1781c155085a2333d6ec0f291165b186eac8e22c73a3280aaeaed",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/target-save-readback/complete_without_back-after-completion.png",
              "absolute_path": ".audit\\reviews\\library\\target-save-readback\\complete_without_back-after-completion.png",
              "sha256": "1c60ac6411471b344c5af5e6310995b40e4f5aa9de4674244ba168ad8a39ebea",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/target-save-readback/complete_without_back-before-completion.png",
              "absolute_path": ".audit\\reviews\\library\\target-save-readback\\complete_without_back-before-completion.png",
              "sha256": "646adc62300c3f24d2d8ad857b4f110bab8058f62789c1d70d36b1f006987037",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/target-save-readback/failure_retains_newer-after-completion.png",
              "absolute_path": ".audit\\reviews\\library\\target-save-readback\\failure_retains_newer-after-completion.png",
              "sha256": "cad64eb4b143b8c1fcaca44b11e621bb3efcd0bb07d4bf8be41985d7356092b3",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/target-save-readback/failure_retains_newer-before-completion.png",
              "absolute_path": ".audit\\reviews\\library\\target-save-readback\\failure_retains_newer-before-completion.png",
              "sha256": "646adc62300c3f24d2d8ad857b4f110bab8058f62789c1d70d36b1f006987037",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/batch9-attempt3-actual-tap/r2b9-actual-tap-later-input-accepted-dark.png",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\batch9-attempt3-actual-tap\\r2b9-actual-tap-later-input-accepted-dark.png",
              "sha256": "5bbbb2e5b4928228a41f989bd623a91215c33d24485144330ef1505d340efb8f",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/batch9-attempt3-actual-tap/r2b9-actual-tap-pending-input-client-dark.png",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\batch9-attempt3-actual-tap\\r2b9-actual-tap-pending-input-client-dark.png",
              "sha256": "ba28a3eb4306430e0458bc2c6160df8b17424360fd30aa019a09c4ad56112728",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/batch9-attempt3-actual-tap/r2b9-actual-tap-reopened-readback-dark.png",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\batch9-attempt3-actual-tap\\r2b9-actual-tap-reopened-readback-dark.png",
              "sha256": "d25f329c3920d8428535272819a5d3016bb3152707df617ed369a9b7efdd0e28",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/batch9-accepted-input-candidate.json",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\batch9-accepted-input-candidate.json",
              "sha256": "190c78ccccb06707e74fee58acd0cab7e667ae92a21ee04b4799e2ad879e633f",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/state-observations-round2/planning-batch9-independent-challenge.json",
              "absolute_path": ".audit\\reviews\\library\\state-observations-round2\\planning-batch9-independent-challenge.json",
              "sha256": "2ed96252d5606736cbfed12583c2678f41f73b897838abe419b7c170c87418cb",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/state-observations-round2/planning-batch9-actual-tap-review-addendum.json",
              "absolute_path": ".audit\\reviews\\library\\state-observations-round2\\planning-batch9-actual-tap-review-addendum.json",
              "sha256": "66a3c10476b7fd4b06a359465fce5854f675ac6556479b2cdc52c1185d1140f8",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/batch9-actual-tap-terminal-receipt.json",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\batch9-actual-tap-terminal-receipt.json",
              "sha256": "8eb94e20138ff9d9fd9bc8382c8b0385de67832209da1661470a794b9be6b9c4",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/batch9-attempt3-actual-tap.log",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\batch9-attempt3-actual-tap.log",
              "sha256": "aabbee29cbcb9c977aae50355455ad0e3c7da7bd6e497e961f40a9b0e748ddaa",
              "role": "CURRENT_PROOF"
            }
          ]
        }
      ],
      "root_group_status_at_snapshot": "CONFIRMED_BOUNDED_WITH_EXPLICIT_CALLER_LIMITS",
      "future_scope_approved": true,
      "execution_in_current_audit": false,
      "priority_rationale": "High-impact local edit-flow failure: newer accepted Target/Plan-assumptions input is silently lost on earlier Save/Apply completion. Correct submitted payloads remain stored; no prior stored data corruption. Controlled host ordering proves reproducibility, not ordinary-device incidence. Separate Target prompt-route assertion remains bounded debug proof. No P0 or native/release crash claim."
    },
    {
      "root_cause_id": "RC-0004",
      "title": "Snapshot end is equated with a fixed provider-horizon cause",
      "finding_ids": [
        "UIA-0004"
      ],
      "readiness": "OWNER_APPROVED_FUTURE_SCOPE",
      "requires_implementation_authorization": false,
      "proposed_boundary": "Describe actual snapshot end, for example No forecast in this snapshot from[date]. A maximum provider horizon may be explained separately only when qualified. Keep the actual boundary, browsing and values.",
      "proof_limit": "Host plus physical Dark100% synthetic companion shows short snapshot boundary called16-day horizon. No real-provider/API or calculation failure inferred.",
      "global_fix_authorized": false,
      "candidate_id": "CAND-A-RC-0004",
      "priority": "P2",
      "implementation_ready": true,
      "requires_owner_layout_choice": false,
      "owner_decision_ref": null,
      "impact": "Medium",
      "expected_benefit": "Avoid a false forecast-horizon explanation.",
      "risk_level": "Low",
      "source_refs": [
        {
          "file": "lib/presentation/widgets/weather_hybrid_view.dart",
          "start": 1628,
          "end": 1638,
          "sha256": "1dc6b157183af1f4b53446842f3fd5ab2af4e436afca1fbbd661a007feeb528c"
        },
        {
          "file": "lib/domain/services/forecast_overview.dart",
          "start": 78,
          "end": 96,
          "sha256": "b812b8b6e0cca99f3b416ff9befad296728a983f603aca31f84656d9edc733d7"
        },
        {
          "file": "lib/presentation/viewmodels/forecast_nights.dart",
          "start": 43,
          "end": 56,
          "sha256": "7eef4a8be4df8f9a508b2b71cfb6b0ecaadba0601d9c4238a7a473e88fa8d4c5"
        }
      ],
      "affected_callers": [
        "HybridWeatherView for available short/aged snapshots"
      ],
      "dependencies": [
        "Separate implementation authorization; independent of D-A09-NARROW and W1/C1."
      ],
      "acceptance_criteria": [
        "Short, complete and aged snapshots never invent a sixteen-day cause.",
        "The displayed boundary still equals actual firstBeyond.",
        "No scientific, time-zone, cache or browsing behavior changes."
      ],
      "risks": [
        "Do not hide genuine out-of-range information.",
        "Keep missing data distinct from provider failure and current conditions."
      ],
      "scope_exclusions": [],
      "current_evidence": [
        {
          "finding_id": "UIA-0004",
          "host_status": "CONFIRMED_HOST",
          "native_status": "NATIVE_VERIFIED_BOUNDED_SYNTHETIC_DARK",
          "proof": [
            {
              "path": ".audit/evidence/android/fixture-weather-coming-nights-boundary-dark-100.png",
              "absolute_path": ".audit/evidence/android/fixture-weather-coming-nights-boundary-dark-100.png",
              "sha256": "2b93f79a7605fcf68677ee68068a02bdba8f1d4a720c3f10510146b5b5e13d62",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/evidence/host/baseline-375/weather_c-light-1.png",
              "absolute_path": ".audit/evidence/host/baseline-375/weather_c-light-1.png",
              "sha256": "d924b53423a1fd40b3c51089788bd58f04c1f369e8268e2fa0c2b1ce35b4445e",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/evidence/host/baseline-375/weather_c-light-1.json",
              "absolute_path": ".audit/evidence/host/baseline-375/weather_c-light-1.json",
              "sha256": "e4de47c04474701dc901cb1dac1f4821d48e90b9d143aa5c28fbd7c1cb4892ac",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/evidence/host/baseline-375/weather_c-dark-1.png",
              "absolute_path": ".audit/evidence/host/baseline-375/weather_c-dark-1.png",
              "sha256": "ea3a9cfe316b48329df7d0e16f8000bed4330448a9d878b76daf24d373d04dd3",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/evidence/host/baseline-375/weather_c-dark-1.json",
              "absolute_path": ".audit/evidence/host/baseline-375/weather_c-dark-1.json",
              "sha256": "6075862c06e0828841e81bebebd7e61f04334511a4f8e43f7be5164a3474ea6b",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/evidence/host/baseline-375/weather_c-field-1.png",
              "absolute_path": ".audit/evidence/host/baseline-375/weather_c-field-1.png",
              "sha256": "a62155e0cc489dc946f0aa2fb80424676767e3c25289346c2eccf5b3eb634428",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/evidence/host/baseline-375/weather_c-field-1.json",
              "absolute_path": ".audit/evidence/host/baseline-375/weather_c-field-1.json",
              "sha256": "0e72d8936695471d368692a1e50716fd5aec9853b239ddf76a198cf266cc6bfb",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/evidence/host/baseline-375/weather-light-1.png",
              "absolute_path": ".audit/evidence/host/baseline-375/weather-light-1.png",
              "sha256": "8c94f394c8a840a806ef399b9871dd0c57ecbef36839baee61e40701220284da",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/evidence/host/baseline-375/weather-light-1.json",
              "absolute_path": ".audit/evidence/host/baseline-375/weather-light-1.json",
              "sha256": "58eb4ec722f64c4ddf180c6ceb613e0c98297382c0c50b954dacb1900ce0efb6",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/evidence/host/baseline-375/weather-dark-1.png",
              "absolute_path": ".audit/evidence/host/baseline-375/weather-dark-1.png",
              "sha256": "26dfe03a70f1fb810cfbd8961c79dfa26a21e107f36f45a1fc5fcfcb7d10a1fd",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/evidence/host/baseline-375/weather-dark-1.json",
              "absolute_path": ".audit/evidence/host/baseline-375/weather-dark-1.json",
              "sha256": "6f79686d0a8bf00264ea9d614fd45069a39aea1d590b75353258a8d2e7dd7d92",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/evidence/host/baseline-375/weather-field-1.png",
              "absolute_path": ".audit/evidence/host/baseline-375/weather-field-1.png",
              "sha256": "26a98f79e6cca77951b41fc47a4168f3a852001992f84038ec3954a95347d58b",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/evidence/host/baseline-375/weather-field-1.json",
              "absolute_path": ".audit/evidence/host/baseline-375/weather-field-1.json",
              "sha256": "b141644e6ca2e55eabe5faf85bf8900999eb7ffcde4f284eafa897c6674e15f4",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/evidence/host/baseline-375/weather_forecast_lead-light-1.png",
              "absolute_path": ".audit/evidence/host/baseline-375/weather_forecast_lead-light-1.png",
              "sha256": "e670d0b85fe79101243ab6112db029af778e5ca0625cc3302e20e84923be24ee",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/evidence/host/baseline-375/weather_forecast_lead-light-1.json",
              "absolute_path": ".audit/evidence/host/baseline-375/weather_forecast_lead-light-1.json",
              "sha256": "eb91d35873a23edf1e0c296e8e8b0f3e8628f5ed01738f96b59376af3f678942",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/evidence/host/baseline-375/weather_forecast_lead-dark-1.png",
              "absolute_path": ".audit/evidence/host/baseline-375/weather_forecast_lead-dark-1.png",
              "sha256": "67fdd1c6310d6199be3f2c900c7d383863c4479dfd96fab32c6a2e4b26dfe047",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/evidence/host/baseline-375/weather_forecast_lead-dark-1.json",
              "absolute_path": ".audit/evidence/host/baseline-375/weather_forecast_lead-dark-1.json",
              "sha256": "a36c78c3c46d71284fba7ba099559a9972319ae3f3c723010478339535308667",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/evidence/host/baseline-375/weather_forecast_lead-field-1.png",
              "absolute_path": ".audit/evidence/host/baseline-375/weather_forecast_lead-field-1.png",
              "sha256": "4f818b4e62cf831b813bdee03a121ef03c1322df7def12731cf56f8103c85acf",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/evidence/host/baseline-375/weather_forecast_lead-field-1.json",
              "absolute_path": ".audit/evidence/host/baseline-375/weather_forecast_lead-field-1.json",
              "sha256": "95414a500a1852b64ad0c441017745e9f65fa1a2e065e96153bbe77325642214",
              "role": "CURRENT_PROOF"
            }
          ]
        }
      ],
      "root_group_status_at_snapshot": "IN_PROGRESS_COORDINATOR_ADJUDICATION",
      "future_scope_approved": true,
      "execution_in_current_audit": false
    },
    {
      "root_cause_id": "RC-0005",
      "title": "Local map attribution uses text/padding height as its entire tap target",
      "finding_ids": [
        "UIA-0005"
      ],
      "readiness": "OWNER_APPROVED_FUTURE_SCOPE",
      "requires_implementation_authorization": false,
      "proposed_boundary": "Give the attribution InkWell and its semantic action at least48dp in both dimensions, retaining readable copyright/link and clear space for GPS/footer/map gestures.",
      "proof_limit": "Measured191.858963x28dp all3themes375. No live map tile/provider success inferred.",
      "global_fix_authorized": false,
      "candidate_id": "CAND-A-RC-0005",
      "priority": "P2",
      "implementation_ready": true,
      "requires_owner_layout_choice": false,
      "owner_decision_ref": null,
      "impact": "Medium",
      "expected_benefit": "Restore independent target size for attribution link.",
      "risk_level": "Low-Medium",
      "source_refs": [
        {
          "file": "lib/presentation/screens/location/location_picker_screen.dart",
          "line": 343,
          "marker": "class _OsmAttribution",
          "sha256": "1f565589cd79e0cff885d7343538923c67a1e44090eaec9934e83ba66a8a4e8f"
        },
        {
          "file": "lib/presentation/screens/location/location_picker_screen.dart",
          "line": 358,
          "marker": "padding: const EdgeInsets.all(AppSpacing.xs)",
          "sha256": "1f565589cd79e0cff885d7343538923c67a1e44090eaec9934e83ba66a8a4e8f"
        }
      ],
      "affected_callers": [
        "SITE-020"
      ],
      "dependencies": [
        "Separate implementation authorization; independent of D-A09-NARROW and W1/C1."
      ],
      "acceptance_criteria": [
        "Measure pointer and semantic bounds≥48dp in both dimensions at375/412/320 with100% text.",
        "Preserve copyright text/link, red/black Field roles, map gestures and footer reachability.",
        "No overlap between attribution, GPS control and selected-point actions; retain typed offline coordinate entry."
      ],
      "risks": [
        "Map tiles absent/failed in host and are not a live-provider PASS. Target geometry is measured from actual production link/semantics.320/412 and physical target behavior remain supplementary gaps."
      ],
      "scope_exclusions": [
        "No legal-compliance certification, live provider/tile success or global InkWell/map redesign is inferred."
      ],
      "current_evidence": [
        {
          "finding_id": "UIA-0005",
          "host_status": "CONFIRMED_HOST",
          "native_status": "UNVERIFIED_NATIVE",
          "proof": [
            {
              "path": ".audit/reviews/library/probe-evidence/map-attribution-light.png",
              "absolute_path": ".audit/reviews/library/probe-evidence/map-attribution-light.png",
              "sha256": "b2869fa31557d02efe3148b1c74be819cff80c14b91b0ce21da9de9f9030a4e5",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/probe-evidence/map-attribution-dark.png",
              "absolute_path": ".audit/reviews/library/probe-evidence/map-attribution-dark.png",
              "sha256": "398ef6f4a3b0e127e5ff1a826d4490b45274d737cbba38eaf76b0157b086025a",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/probe-evidence/map-attribution-field.png",
              "absolute_path": ".audit/reviews/library/probe-evidence/map-attribution-field.png",
              "sha256": "bb8ca377f5d38ead846df6ca9e77d6a966e59c1692e71d06e87c3a0219473d9a",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/probe-evidence/observations.json",
              "absolute_path": ".audit/reviews/library/probe-evidence/observations.json",
              "sha256": "c7dbae7702450364f35cd0f79fe9ca0e84a771ffb55697e4bc367adf77c6067f",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/probe-run-4-final.log",
              "absolute_path": ".audit/reviews/library/probe-run-4-final.log",
              "sha256": "2a92a80a01eeec24eec50fd1f45288ea80528052d660de968890f8a244f50c13",
              "role": "CURRENT_PROOF"
            }
          ]
        }
      ],
      "root_group_status_at_snapshot": "IN_PROGRESS_COORDINATOR_ADJUDICATION",
      "future_scope_approved": true,
      "execution_in_current_audit": false
    },
    {
      "root_cause_id": "RC-0006",
      "title": "Library count Retry retains the previous failure without pending feedback",
      "finding_ids": [
        "UIA-0006",
        "UIA-0008",
        "UIA-0014"
      ],
      "readiness": "OWNER_APPROVED_FUTURE_SCOPE",
      "requires_implementation_authorization": false,
      "proposed_boundary": "Three caller-specific waiting projections: Candidates refresh, Entry Retry and Library count Retry. Preserve unknown/error/count guards and identity; no global FutureBuilder rewrite.",
      "proof_limit": "Direct themed MaterialApp component fixture: main root focus ring/Field filter composition is separately qualified. No canonical AppRouter, physical, indefinite-wait, crash or duplicate-retry proof. Other aggregate data sources were not independently failed.",
      "global_fix_authorized": false,
      "candidate_id": "CAND-A-RC-0006",
      "priority": "P3",
      "implementation_ready": true,
      "requires_owner_layout_choice": false,
      "owner_decision_ref": null,
      "impact": "Medium",
      "expected_benefit": "Distinguish requested refresh/Retry from settled data or error.",
      "risk_level": "Medium",
      "source_refs": [
        {
          "file": "lib/presentation/screens/tonight/tonight_candidates_screen.dart",
          "line": 80,
          "anchor": "void _load()",
          "sha256": "2021d816d74a000427c2a2bce1f491e74ce9de5fc7f2c78c0949cbda173f0106"
        },
        {
          "file": "lib/presentation/screens/tonight/tonight_candidates_screen.dart",
          "line": 137,
          "anchor": "FutureBuilder<List<TonightCandidate>?>",
          "sha256": "2021d816d74a000427c2a2bce1f491e74ce9de5fc7f2c78c0949cbda173f0106"
        },
        {
          "file": "lib/presentation/screens/logbook/session_detail_screen.dart",
          "line": 82,
          "marker": "void _load()",
          "sha256": "319178a89ae7b2f242febd0b83fad146b1fe28866ca23852bbb2933a2ebdbb58"
        },
        {
          "file": "lib/presentation/screens/logbook/session_detail_screen.dart",
          "line": 95,
          "marker": "if (snapshot.error case final error?)",
          "sha256": "319178a89ae7b2f242febd0b83fad146b1fe28866ca23852bbb2933a2ebdbb58"
        },
        {
          "file": "lib/presentation/screens/logbook/session_detail_screen.dart",
          "line": 105,
          "marker": "if (data == null)",
          "sha256": "319178a89ae7b2f242febd0b83fad146b1fe28866ca23852bbb2933a2ebdbb58"
        },
        {
          "file": "lib/presentation/screens/library/library_screen.dart",
          "line": 38,
          "sha256": "52f5d7e529c26e7bff4e1f53cd3ebebdad144d212945ad1861bdc0850e9edfd1",
          "anchor": "didChangeDependencies assigns _counts from real Gear/Target ViewModels"
        },
        {
          "file": "lib/presentation/screens/library/library_screen.dart",
          "line": 42,
          "sha256": "52f5d7e529c26e7bff4e1f53cd3ebebdad144d212945ad1861bdc0850e9edfd1",
          "anchor": "_readCounts Future.wait"
        },
        {
          "file": "lib/presentation/screens/library/library_screen.dart",
          "line": 50,
          "sha256": "52f5d7e529c26e7bff4e1f53cd3ebebdad144d212945ad1861bdc0850e9edfd1",
          "anchor": "_retry replaces _counts inside setState"
        },
        {
          "file": "lib/presentation/screens/library/library_screen.dart",
          "line": 68,
          "sha256": "52f5d7e529c26e7bff4e1f53cd3ebebdad144d212945ad1861bdc0850e9edfd1",
          "anchor": "FutureBuilder<List<int>>"
        },
        {
          "file": "lib/presentation/screens/library/library_screen.dart",
          "line": 73,
          "sha256": "52f5d7e529c26e7bff4e1f53cd3ebebdad144d212945ad1861bdc0850e9edfd1",
          "anchor": "Count text restricted to done without error"
        },
        {
          "file": "lib/presentation/screens/library/library_screen.dart",
          "line": 121,
          "sha256": "52f5d7e529c26e7bff4e1f53cd3ebebdad144d212945ad1861bdc0850e9edfd1",
          "anchor": "Unconditional snapshot.hasError branch"
        },
        {
          "file": "lib/presentation/screens/library/library_screen.dart",
          "line": 131,
          "sha256": "52f5d7e529c26e7bff4e1f53cd3ebebdad144d212945ad1861bdc0850e9edfd1",
          "anchor": "Retry counts enabled callback _retry"
        }
      ],
      "affected_callers": [
        "CAN-001",
        "CAN-002",
        "CAN-006",
        "LOG-009",
        "LIB-001"
      ],
      "dependencies": [
        "Separate implementation authorization; independent of D-A09-NARROW and W1/C1."
      ],
      "acceptance_criteria": [
        "Held refresh visibly distinguishes pending from settled content.",
        "Success/error/retry retain truthful count/context and existing sorting/filter semantics.",
        "Night-change stale-context risk needs a separate deterministic prerequisite before claiming its correction.",
        "Fail→held Retry displays an appropriate pending cue and disables duplicate recovery if needed.",
        "Resolve success/missing/error and preserve the same entry id.",
        "Keep unrelated Logbook generation guards and fixed Progress Retry unchanged.",
        "Held replacement read visibly/semantically communicates retrying across three themes.",
        "Success replaces the failure with actual counts; another failure remains clear and retryable.",
        "Original stale-count suppression, private error boundary and repository read behavior remain intact."
      ],
      "risks": [
        "Retained success/error snapshots must not be mislabeled after a new request.",
        "Avoid removing useful current data or losing staged filter/sort context.",
        "No claim of stale data publication or corrupted snapshots. This is bounded loading/feedback presentation; physical app retry not exercised.",
        "Do not reveal stale counts while a read fails/waits.",
        "Do not expose private exception markers or change repository data.",
        "Keep existing real count aggregation and retry recovery semantics."
      ],
      "scope_exclusions": [
        "Direct themed MaterialApp component fixture: main root focus ring/Field filter composition is separately qualified.",
        "No canonical AppRouter, physical, indefinite-wait, crash or duplicate-retry proof.",
        "Other aggregate data sources were not independently failed."
      ],
      "current_evidence": [
        {
          "finding_id": "UIA-0006",
          "host_status": "CONFIRMED_HOST",
          "native_status": "UNVERIFIED_NATIVE",
          "proof": [
            {
              "path": ".audit/reviews/planning/probe-output/CAN-H001-held-refresh.json",
              "absolute_path": ".audit/reviews/planning/probe-output/CAN-H001-held-refresh.json",
              "sha256": "9bd991db863ea505068fd0980ea5a6226f3e9c12d8e8291f46267c96f5c9e058",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/probe-output/CAN-H001-held-refresh.png",
              "absolute_path": ".audit/reviews/planning/probe-output/CAN-H001-held-refresh.png",
              "sha256": "9692c1c331b9beab248f13d2a51552690b17d267a2eb08eb7e357e0baf4d9bec",
              "role": "CURRENT_PROOF"
            }
          ]
        },
        {
          "finding_id": "UIA-0008",
          "host_status": "CONFIRMED_HOST",
          "native_status": "UNVERIFIED_NATIVE",
          "proof": [
            {
              "path": ".audit/reviews/library/probe-evidence/entry-held-retry.png",
              "absolute_path": ".audit/reviews/library/probe-evidence/entry-held-retry.png",
              "sha256": "38fc4cca8caecae95c61a986541d96a9119d91b2b7c818de4cf8a4208205e3af",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/probe-evidence/observations.json",
              "absolute_path": ".audit/reviews/library/probe-evidence/observations.json",
              "sha256": "c7dbae7702450364f35cd0f79fe9ca0e84a771ffb55697e4bc367adf77c6067f",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/probe-run-4-final.log",
              "absolute_path": ".audit/reviews/library/probe-run-4-final.log",
              "sha256": "2a92a80a01eeec24eec50fd1f45288ea80528052d660de968890f8a244f50c13",
              "role": "CURRENT_PROOF"
            }
          ]
        },
        {
          "finding_id": "UIA-0014",
          "host_status": "CONFIRMED_HOST",
          "native_status": "UNVERIFIED_NATIVE",
          "proof": [
            {
              "path": ".audit/reviews/library/state-observations-round2/batch-02/light-library-counts-retry-pending.png",
              "absolute_path": ".audit\\reviews\\library\\state-observations-round2\\batch-02\\light-library-counts-retry-pending.png",
              "sha256": "7ce45c5c2fddbefcc4d4082c5c9139a1a89cdaf05bde17f666a6ff993dd18da4",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/state-observations-round2/batch-02/dark-library-counts-retry-pending.png",
              "absolute_path": ".audit\\reviews\\library\\state-observations-round2\\batch-02\\dark-library-counts-retry-pending.png",
              "sha256": "4f256a7024d7dc4d4353de1460d40bc574112b185e365fc2a411ac5e1fa9d354",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/state-observations-round2/batch-02/field-library-counts-retry-pending.png",
              "absolute_path": ".audit\\reviews\\library\\state-observations-round2\\batch-02\\field-library-counts-retry-pending.png",
              "sha256": "0e9055ec48a5e25bd924ab6e75de3db0bb512673bd85a2a6018b5216de41be0f",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/library-count-retry-independent-challenge.json",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\library-count-retry-independent-challenge.json",
              "sha256": "0ad7dacf0a18334b52656a3f23702cf939d894a68c4b443e07128a2f19ed1ba5",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/state-observations-round2/batch2-receipt.json",
              "absolute_path": ".audit\\reviews\\library\\state-observations-round2\\batch2-receipt.json",
              "sha256": "530457e65a8fb3fb7335468a789f7a705c6b06429141489021f9e8210dd8250c",
              "role": "CURRENT_PROOF"
            }
          ]
        }
      ],
      "root_group_status_at_snapshot": "CONFIRMED_BOUNDED_WITH_EXPLICIT_CALLER_LIMITS",
      "future_scope_approved": true,
      "execution_in_current_audit": false
    },
    {
      "root_cause_id": "RC-0007",
      "title": "One empty-result explanation ignores which active filter removed the rows",
      "finding_ids": [
        "UIA-0007"
      ],
      "readiness": "OWNER_APPROVED_FUTURE_SCOPE",
      "requires_implementation_authorization": false,
      "proposed_boundary": "Use truthful filter-neutral no-match wording or derive a reason only from independently established active-filter cause. Offer existing filter recovery; never alter filtering to make old copy true.",
      "proof_limit": "Own-only empty despite a bundled candidate with a real window and include-windowless enabled.",
      "global_fix_authorized": false,
      "candidate_id": "CAND-A-RC-0007",
      "priority": "P3",
      "implementation_ready": true,
      "requires_owner_layout_choice": false,
      "owner_decision_ref": null,
      "impact": "Medium",
      "expected_benefit": "Explain selected-filter emptiness without false scientific diagnosis.",
      "risk_level": "Low",
      "source_refs": [
        {
          "file": "lib/presentation/screens/tonight/tonight_candidates_screen.dart",
          "line": 185,
          "anchor": "CandidateList.filter",
          "sha256": "2021d816d74a000427c2a2bce1f491e74ce9de5fc7f2c78c0949cbda173f0106"
        },
        {
          "file": "lib/presentation/screens/tonight/tonight_candidates_screen.dart",
          "line": 296,
          "anchor": "No target matches: none has an imaging window with these",
          "sha256": "2021d816d74a000427c2a2bce1f491e74ce9de5fc7f2c78c0949cbda173f0106"
        }
      ],
      "affected_callers": [
        "CAN-005",
        "CAN-009"
      ],
      "dependencies": [
        "Separate implementation authorization; independent of D-A09-NARROW and W1/C1."
      ],
      "acceptance_criteria": [
        "Own-only empty state is truthful with include-windowless both on and off.",
        "No-window and type-filter emptiness retain accurate recovery copy."
      ],
      "risks": [
        "Do not change filtering to make the current wording true.",
        "Retain useful recovery guidance and actual selected-filter meaning."
      ],
      "scope_exclusions": [],
      "current_evidence": [
        {
          "finding_id": "UIA-0007",
          "host_status": "CONFIRMED_HOST",
          "native_status": "UNVERIFIED_NATIVE",
          "proof": [
            {
              "path": ".audit/reviews/planning/probe-output/CAN-H002-own-only-empty.json",
              "absolute_path": ".audit/reviews/planning/probe-output/CAN-H002-own-only-empty.json",
              "sha256": "604c4ae8f84f05457055388439f4ec1745580fea8a0ac90fdc58109cac4d4ed1",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/probe-output/CAN-H002-own-only-empty.png",
              "absolute_path": ".audit/reviews/planning/probe-output/CAN-H002-own-only-empty.png",
              "sha256": "ca622d662988983e3e15f118e13d4d24ef2cdd326a706dadb3d9c25ce375a7e7",
              "role": "CURRENT_PROOF"
            }
          ]
        }
      ],
      "root_group_status_at_snapshot": "IN_PROGRESS_COORDINATOR_ADJUDICATION",
      "future_scope_approved": true,
      "execution_in_current_audit": false
    },
    {
      "candidate_id": "CAND-A-RC-0011",
      "root_cause_id": "RC-0011",
      "title": "Proposal guidance enumerates fields independently of current camera capabilities",
      "finding_ids": [
        "UIA-0012"
      ],
      "priority": "P3",
      "readiness": "OWNER_APPROVED_FUTURE_SCOPE",
      "implementation_ready": true,
      "requires_implementation_authorization": false,
      "requires_owner_layout_choice": false,
      "owner_decision_ref": null,
      "impact": "Low",
      "expected_benefit": "Make proposal guidance consistent with actual camera-class controls.",
      "risk_level": "Low",
      "source_refs": [
        {
          "file": "lib/presentation/widgets/capture_plan/capture_block_dialog.dart",
          "line": 864,
          "sha256": "bbcc564f96d01c0b87177847d00d275d0c09bc7a47a22d026e88e5450ce84e9c"
        },
        {
          "file": "lib/domain/models/camera_class.dart",
          "line": 35,
          "sha256": "bc5403f39b19f42513c5cbb7ba7a69b15f18f2ac5cb7f7e11e39ff20d3588a9c",
          "anchor": "bool get offersLightBinning"
        }
      ],
      "affected_callers": [
        "Add Light block with proposal; DSLR/Phone/Unknown field capability cases require truthful wording; same production caller, no global token change"
      ],
      "dependencies": [
        "Separate implementation authorization; independent of D-A09-NARROW and W1/C1."
      ],
      "acceptance_criteria": [
        "DSLR/Phone proposal guidance does not direct the user to a missing per-block binning control.",
        "Unknown guidance does not imply that a hidden ISO/gain editor is available.",
        "Astro gain/binning proposals, inherited values and Apply/Save ownership remain intact.",
        "Actual three-theme375/100% After screenshots and focused capability/copy regression pass."
      ],
      "risks": [
        "Do not add unsupported binning/ISO/gain controls to match the copy.",
        "Do not change inherited values, stored metadata, camera class or any calculation.",
        "Keep Astro camera proposal guidance understandable and Unknown explicit."
      ],
      "scope_exclusions": [
        "Copy-only recommendation; no camera-capability, calibration, persistence, science or layout change."
      ],
      "current_evidence": [
        {
          "finding_id": "UIA-0012",
          "host_status": "CONFIRMED_HOST",
          "native_status": "UNVERIFIED_NATIVE",
          "proof": [
            {
              "path": ".audit/reviews/planning/capture-gap-probes/add-proposal-top-dark.png",
              "absolute_path": ".audit/reviews/planning/capture-gap-probes/add-proposal-top-dark.png",
              "sha256": "151e40ec0bb6ccd4bdb69d997c7a17f446c83ce9d0333681e1cd21e9d2830fab",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/capture-gap-probes/add-proposal-top-field.png",
              "absolute_path": ".audit/reviews/planning/capture-gap-probes/add-proposal-top-field.png",
              "sha256": "035c969c1a459ea4aec1c5d2e9da608f2b873e749bef4712ea117fe79d9436b1",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/capture-gap-probes/add-proposal-top-light.png",
              "absolute_path": ".audit/reviews/planning/capture-gap-probes/add-proposal-top-light.png",
              "sha256": "ec3dd6ff2efbf9f02a34fe2d70be971b5e87d8217a7238ab30fe31f2eb7d9f26",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/capture-gap-probes/add-proposal-lower-light.png",
              "absolute_path": ".audit/reviews/planning/capture-gap-probes/add-proposal-lower-light.png",
              "sha256": "2a79dc43e5899c2ae51149297471df74e34453a185a2981b13b4133d893a3fb1",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/capture-gap-probes/add-proposal-lower-dark.png",
              "absolute_path": ".audit/reviews/planning/capture-gap-probes/add-proposal-lower-dark.png",
              "sha256": "7d9abc91ad2114231af316b7019d07846ad752f62999f921c925c155246b1889",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/capture-gap-probes/add-proposal-lower-field.png",
              "absolute_path": ".audit/reviews/planning/capture-gap-probes/add-proposal-lower-field.png",
              "sha256": "7fac7a33cad2985b4e209acd082f879b8deafc16eefbe0eb673091ac5b8a4776",
              "role": "CURRENT_PROOF"
            }
          ]
        }
      ],
      "root_group_status_at_snapshot": "CONFIRMED_HOST",
      "global_fix_authorized": false,
      "proposed_boundary": "Use class-neutral proposal wording or enumerate only controls actually offered for the current class. Preserve the proposal, field availability, values, provenance and Apply-to-draft behavior.",
      "proof_limit": "Actual DSLR proposal pixels and actual Details prove capability-copy mismatch. Phone/Unknown extension is source-confirmed, not separately native/pixel-proved. No control/science change.",
      "future_scope_approved": true,
      "execution_in_current_audit": false
    },
    {
      "root_cause_id": "RC-0012",
      "title": "Enabled labels lose required text contrast under active ink feedback",
      "finding_ids": [
        "UIA-0013"
      ],
      "readiness": "OWNER_APPROVED_FUTURE_SCOPE",
      "requires_implementation_authorization": false,
      "proposed_boundary": "Correct foreground/background interaction pairing in the eighteen named caller cases, including month375dp and the actual320dp week fallback. Shared TextButton/CollapsibleSection or ListTile/InkWell changes require inspection of other callers/exceptions first. Preserve state feedback, calendar viewing versus plan adoption and scientific meanings; do not globally alter palette or ink from an uninstrumented blend hypothesis.",
      "proof_limit": "Exact host caller states at100%; primary375dp with actual source-required week320dp. Composition/input/timing are per-case; no native/full-accessibility acceptance. Light failures are limited to Moon Preview, month/week Retry and stored-entry Undo and Edit-block photo action. Other confirmed failures are Dark; Field exception is unchanged. Progress guide and week-row4.467 are borderlineP3 cases within the overallP2 finding. Repeated pairing pattern is confirmed across distinct local/shared owners. Exact multilayer blend mechanism and unobserved callers remain unverified.",
      "global_fix_authorized": false,
      "candidate_id": "CAND-A-RC-0012",
      "priority": "P2",
      "implementation_ready": true,
      "requires_owner_layout_choice": false,
      "owner_decision_ref": null,
      "impact": "Local confirmed interaction/readability contract; exact observed callers only",
      "expected_benefit": "Expected correction of the observed state; no measured After or human benefit claim",
      "risk_level": "medium",
      "source_refs": [
        {
          "file": "lib/presentation/widgets/plan_tracking.dart",
          "line": 46,
          "sha256": "38a1782fa04717be33e4511fa931f75e4d89dd2b398682e0f3b8f222bcdbc044"
        },
        {
          "file": "lib/core/theme/app_theme.dart",
          "line": 87,
          "sha256": "f75e7f7b65557dbcdee1c74bed6bb1c027de994df6a62387c1986cbaf87f42bf"
        },
        {
          "file": "lib/core/theme/app_theme.dart",
          "line": 316,
          "sha256": "f75e7f7b65557dbcdee1c74bed6bb1c027de994df6a62387c1986cbaf87f42bf"
        },
        {
          "file": "lib/core/theme/app_theme.dart",
          "line": 520,
          "sha256": "f75e7f7b65557dbcdee1c74bed6bb1c027de994df6a62387c1986cbaf87f42bf"
        },
        {
          "file": "lib/core/theme/app_theme.dart",
          "line": 536,
          "sha256": "f75e7f7b65557dbcdee1c74bed6bb1c027de994df6a62387c1986cbaf87f42bf"
        },
        {
          "file": "lib/core/theme/app_typography.dart",
          "line": 113,
          "sha256": "aaf856134a50fbb638437896f37c6d8692ddd3ee5c2030fc0918bfd11be41e98"
        },
        {
          "file": "lib/core/theme/app_colors.dart",
          "line": 1,
          "sha256": "3c14f3856b23d6b05887807124d243f87bb1cd06bd53a30d29676a5fbca0aff1"
        },
        {
          "file": "lib/presentation/widgets/capture_plan/capture_block_dialog.dart",
          "line": 1212,
          "sha256": "bbcc564f96d01c0b87177847d00d275d0c09bc7a47a22d026e88e5450ce84e9c"
        },
        {
          "file": "lib/presentation/widgets/capture_plan/block_editor_parts.dart",
          "line": 326,
          "sha256": "f666b27647074de9a009fe7be2fe2b0f030f428e8436e174af23d3384614e0fd"
        },
        {
          "file": "lib/presentation/widgets/capture_plan/block_editor_parts.dart",
          "line": 349,
          "sha256": "f666b27647074de9a009fe7be2fe2b0f030f428e8436e174af23d3384614e0fd"
        },
        {
          "file": "lib/presentation/shared/collapsible_section.dart",
          "line": 95,
          "sha256": "ddde5be173d771d0b2dc785e2ce3eec87351eef3e2420a732d0c8a567a360087"
        },
        {
          "file": "lib/presentation/shared/collapsible_section.dart",
          "line": 149,
          "sha256": "ddde5be173d771d0b2dc785e2ce3eec87351eef3e2420a732d0c8a567a360087"
        },
        {
          "file": "lib/presentation/widgets/weather_hybrid_view.dart",
          "line": 1230,
          "sha256": "1dc6b157183af1f4b53446842f3fd5ab2af4e436afca1fbbd661a007feeb528c"
        },
        {
          "file": "lib/presentation/widgets/weather_hybrid_view.dart",
          "line": 1259,
          "sha256": "1dc6b157183af1f4b53446842f3fd5ab2af4e436afca1fbbd661a007feeb528c"
        },
        {
          "file": "lib/core/theme/app_colors.dart",
          "line": 31,
          "sha256": "3c14f3856b23d6b05887807124d243f87bb1cd06bd53a30d29676a5fbca0aff1"
        },
        {
          "file": "lib/core/theme/app_palette.dart",
          "line": 50,
          "sha256": "62015cbef94e3a18bd561e9221b5091acb39d353985472340bc650b885e15d6f"
        },
        {
          "file": "lib/presentation/screens/logbook/progress_screen.dart",
          "line": 110,
          "sha256": "a7b062ef4d81785e60025cfe9a6660a2dcee2205389274e47fe96c45c355c0fc",
          "end_line": 120,
          "exact_excerpt": "                      child: CollapsibleSection(\n                        key: const Key('progress.guide'),\n                        topRule: false,\n                        sectionKey: 'logbook.progressGuide',\n                        title: 'How totals are grouped',\n                        titleStyle: AppTypography.body.copyWith(\n                          fontWeight: FontWeight.w500,\n                          color: p.textPrimary,\n                        ),\n                        child: Text(\n                          'Totals per filter add every recorded frame. Beneath '"
        },
        {
          "file": "lib/presentation/shared/collapsible_section.dart",
          "line": 89,
          "sha256": "ddde5be173d771d0b2dc785e2ce3eec87351eef3e2420a732d0c8a567a360087",
          "end_line": 138,
          "exact_excerpt": "      hint: open ? 'Collapse' : 'Expand',\n      excludeSemantics: true,\n      label: [title, ?summary].join(', '),\n      child: InkWell(\n        onTap: toggle,\n        child: ConstrainedBox(\n          constraints: const BoxConstraints(minHeight: 48),\n          child: Padding(\n            padding: const EdgeInsets.symmetric(vertical: 6),\n            child: Row(\n              children: [\n                Expanded(\n                  child: Column(\n                    crossAxisAlignment: CrossAxisAlignment.start,\n                    children: [\n                      Row(\n                        children: [\n                          if (icon case final i?) ...[\n                            HybridIcon(\n                              i,\n                              size: 20,\n                              strokeWidth: 1.7,\n                              color: iconColor ?? p.textPrimary,\n                            ),\n                            const SizedBox(width: 10),\n                          ],\n                          Flexible(\n                            child: Text(\n                              title,\n                              style:\n                                  (titleStyle ??\n                                          AppTypography.sectionHeading.copyWith(\n                                            height: 1.4,\n                                            letterSpacing: 0,\n                                          ))\n                                      .copyWith(color: p.textPrimary),\n                            ),\n                          ),\n                        ],\n                      ),\n                      if (summary != null)\n                        Padding(\n                          padding: const EdgeInsets.only(top: 2),\n                          child: Text(\n                            summary!,\n                            style: AppTypography.caption.copyWith(\n                              height: 1.4,\n                              color: p.textSecondary,\n                            ),\n                          ),"
        },
        {
          "file": "lib/core/theme/app_typography.dart",
          "line": 60,
          "sha256": "aaf856134a50fbb638437896f37c6d8692ddd3ee5c2030fc0918bfd11be41e98",
          "end_line": 62,
          "exact_excerpt": "\n  /// Body: 14/400.\n  static final TextStyle body = _style(14, 21.7, FontWeight.w400);"
        },
        {
          "file": "lib/presentation/shared/collapsible_section.dart",
          "line": 92,
          "sha256": "ddde5be173d771d0b2dc785e2ce3eec87351eef3e2420a732d0c8a567a360087"
        },
        {
          "file": "lib/presentation/shared/collapsible_section.dart",
          "line": 135,
          "sha256": "ddde5be173d771d0b2dc785e2ce3eec87351eef3e2420a732d0c8a567a360087"
        },
        {
          "file": "lib/presentation/screens/details/night_moon_screen.dart",
          "line": 580,
          "sha256": "bf68b363dad27862b227ac883decffdf691f9524c0c6f3cd9e5b00b7fe745f4d"
        },
        {
          "file": "lib/core/theme/app_theme.dart",
          "line": 444,
          "sha256": "f75e7f7b65557dbcdee1c74bed6bb1c027de994df6a62387c1986cbaf87f42bf"
        },
        {
          "file": "lib/presentation/shared/app_messages.dart",
          "line": 63,
          "sha256": "3af582f67c449bef4510abe021c70243c32fff709a56dfb9d9337a151f74a955",
          "end_line": 77,
          "exact_excerpt": "        actions: [\n          if (action != null)\n            TextButton(\n              onPressed: () {\n                if (result._closed.isCompleted) return;\n                action.onPressed();\n                finish(SnackBarClosedReason.action);\n              },\n              child: Text(action.label),\n            ),\n          IconButton(\n            key: const Key('appMessage.dismiss'),\n            tooltip: 'Dismiss',\n            onPressed: () => finish(SnackBarClosedReason.dismiss),\n            icon: const Icon(Icons.close),"
        },
        {
          "file": "lib/core/theme/app_theme.dart",
          "line": 313,
          "sha256": "f75e7f7b65557dbcdee1c74bed6bb1c027de994df6a62387c1986cbaf87f42bf",
          "end_line": 331,
          "exact_excerpt": "    final label = WidgetStatePropertyAll(text.labelLarge);\n    const tall = WidgetStatePropertyAll(Size(64, 48));\n\n    // Pressed feedback stronger than Material's 10 % (08 §5, §8).\n    WidgetStateProperty<Color?> overlay(Color c) =>\n        WidgetStateProperty.resolveWith((states) {\n          if (states.contains(WidgetState.pressed)) {\n            return c.withValues(alpha: pressedOverlay);\n          }\n          if (states.contains(WidgetState.focused)) {\n            return c.withValues(alpha: 0.12);\n          }\n          if (states.contains(WidgetState.hovered)) {\n            return c.withValues(alpha: 0.08);\n          }\n          return null;\n        });\n    WidgetStateProperty<Color> onOff(Color on) =>\n        WidgetStateProperty.resolveWith("
        },
        {
          "file": "lib/core/theme/app_theme.dart",
          "line": 433,
          "sha256": "f75e7f7b65557dbcdee1c74bed6bb1c027de994df6a62387c1986cbaf87f42bf",
          "end_line": 448,
          "exact_excerpt": "      // plan.css `.quiet-button`: 14/500 secondary text, padding 8 12,\n      // at least 48 × 48.\n      textButtonTheme: TextButtonThemeData(\n        style: ButtonStyle(\n          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),\n          padding: const WidgetStatePropertyAll(\n            EdgeInsets.symmetric(horizontal: 12, vertical: 8),\n          ),\n          animationDuration: AppMotion.short,\n          shape: shape,\n          textStyle: label,\n          foregroundColor: onOff(p.textSecondary),\n          iconColor: onOff(p.textSecondary),\n          overlayColor: overlay(p.textPrimary),\n        ),\n      ),"
        },
        {
          "file": "lib/core/theme/app_typography.dart",
          "line": 110,
          "sha256": "aaf856134a50fbb638437896f37c6d8692ddd3ee5c2030fc0918bfd11be41e98",
          "end_line": 119,
          "exact_excerpt": "    titleMedium: _style(16, 24, FontWeight.w600),\n    titleSmall: _style(14, 20, FontWeight.w600),\n    bodyLarge: _style(16, 24, FontWeight.w400),\n    bodyMedium: _style(16, 24, FontWeight.w400),\n    bodySmall: _style(13, 20, FontWeight.w400),\n    labelLarge: _style(14, 20, FontWeight.w500),\n    labelMedium: _style(14, 21, FontWeight.w500),\n    labelSmall: _style(13, 20, FontWeight.w500),\n  );\n}"
        },
        {
          "file": "lib/presentation/shared/delete_patterns.dart",
          "line": 130,
          "sha256": "861f3070e953fdc88597805b011878b09b877e2c8828c28e08a5f2e3416bdb32",
          "end_line": 145,
          "exact_excerpt": "  unawaited(\n    messenger\n        .showMessage(\n          SnackBar(\n            content: Text(feedback),\n            persist: true,\n            action: SnackBarAction(label: 'Undo', onPressed: () {}),\n          ),\n        )\n        .closed\n        .then((reason) async {\n          if (reason == SnackBarClosedReason.action) await restore();\n        }),\n  );\n  return true;\n}"
        },
        {
          "file": "lib/presentation/widgets/night_browser_sections.dart",
          "line": 1359,
          "sha256": "b6afef128d8ca7162438a81d635143636155a497d6f029d1321cffcff911c5eb"
        },
        {
          "file": "lib/presentation/widgets/night_browser_sections.dart",
          "line": 1184,
          "sha256": "b6afef128d8ca7162438a81d635143636155a497d6f029d1321cffcff911c5eb"
        },
        {
          "file": "lib/presentation/widgets/night_browser_sections.dart",
          "line": 1483,
          "sha256": "b6afef128d8ca7162438a81d635143636155a497d6f029d1321cffcff911c5eb"
        },
        {
          "file": "lib/presentation/widgets/night_browser_sections.dart",
          "line": 1507,
          "sha256": "b6afef128d8ca7162438a81d635143636155a497d6f029d1321cffcff911c5eb"
        },
        {
          "file": "lib/presentation/widgets/capture_plan/capture_block_dialog.dart",
          "line": 1364,
          "sha256": "bbcc564f96d01c0b87177847d00d275d0c09bc7a47a22d026e88e5450ce84e9c"
        },
        {
          "file": "lib/core/theme/app_theme.dart",
          "line": 317,
          "sha256": "f75e7f7b65557dbcdee1c74bed6bb1c027de994df6a62387c1986cbaf87f42bf"
        },
        {
          "file": "lib/core/theme/app_theme.dart",
          "line": 435,
          "sha256": "f75e7f7b65557dbcdee1c74bed6bb1c027de994df6a62387c1986cbaf87f42bf"
        },
        {
          "file": "lib/core/theme/app_colors.dart",
          "line": 19,
          "sha256": "3c14f3856b23d6b05887807124d243f87bb1cd06bd53a30d29676a5fbca0aff1"
        },
        {
          "file": "lib/presentation/widgets/capture_plan/capture_budget_summary.dart",
          "line": 290,
          "sha256": "f057414242a6c1ce77e32dd3ef9dbe23411be1b5e05562c23bbcb86aa8513f78"
        },
        {
          "file": "lib/presentation/widgets/capture_plan/storage_actions.dart",
          "line": 83,
          "sha256": "2351d077f1764a2f668325604f4bf2d266bdb36e3973e25150a72432f53d3662"
        }
      ],
      "affected_callers": [
        "PLN-016",
        "CAP-016",
        "WEA-022",
        "PROG-003",
        "MON-003",
        "NIT-025",
        "NIT-027",
        "NIT-026",
        "MON-015",
        "MON-016",
        "LOG-008",
        "MON-008",
        "MON-007",
        "MON-012",
        "MON-013",
        "CAP-010",
        "CAP-030"
      ],
      "dependencies": [],
      "acceptance_criteria": [
        "Actual enabled Dark14sp label reaches≥4.5 in normal, focused, held and combined states under automatic keyboard/mouse input.",
        "Verify touch separately where applicable; keep48dp targets and visible focus.",
        "Selecting a choice changes only the plan override; cancellation changes nothing.",
        "Light/Field controls, globals and rig defaults do not regress.",
        "Verify remaining CollapsibleSection callers/legitimate exceptions before changing the shared component.",
        "Retain primary-versus-secondary hierarchy, choice/disclosure outcomes, selected time/date identity and focus/48dp targets.",
        "Verify all eighteen named enabled normal-text caller cases at4.5:1 in their exact specified themes/widths/states; preserve passing states and Field exceptions."
      ],
      "risks": [
        "Global ink changes could affect unrelated controls.",
        "Preserve chosen/default/Unknown semantics and plan-only tracking ownership.",
        "Preserve Light and red-only Field contracts.",
        "Preserve caller-specific text hierarchy, disclosure/selection behavior and scientific time/Unknown meaning.",
        "Preserve intentional Field red constraints and the outer production filter; do not globally promote secondary text."
      ],
      "scope_exclusions": [
        "Exact host caller states at100%; primary375dp with actual source-required week320dp. Composition/input/timing are per-case; no native/full-accessibility acceptance.",
        "Light failures are limited to Moon Preview, month/week Retry and stored-entry Undo and Edit-block photo action. Other confirmed failures are Dark; Field exception is unchanged.",
        "Progress guide and week-row4.467 are borderlineP3 cases within the overallP2 finding.",
        "Repeated pairing pattern is confirmed across distinct local/shared owners. Exact multilayer blend mechanism and unobserved callers remain unverified."
      ],
      "current_evidence": [
        {
          "finding_id": "UIA-0013",
          "host_status": "CONFIRMED_HOST",
          "native_status": "UNVERIFIED_NATIVE",
          "proof": [
            {
              "path": ".audit/reviews/planning/state-observations-round2/batch3-attempt3-automatic-input/r2b3-tracking-guided-held-focus-only-automatic-dark.png",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\batch3-attempt3-automatic-input\\r2b3-tracking-guided-held-focus-only-automatic-dark.png",
              "sha256": "72a396adb13e51b7102763d2a7356e6c05cc634404fa32165d8a71cf5f137821",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/batch3-attempt3-automatic-input/r2b3-tracking-guided-held-focused-automatic-dark.png",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\batch3-attempt3-automatic-input\\r2b3-tracking-guided-held-focused-automatic-dark.png",
              "sha256": "db7f977d1e66f4fad8922a0a1e4bbb95a6bae3b09a94762aed8b7b2618e2c776",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/batch3-attempt3-automatic-input/r2b3-tracking-guided-held-unfocused-automatic-dark.png",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\batch3-attempt3-automatic-input\\r2b3-tracking-guided-held-unfocused-automatic-dark.png",
              "sha256": "8fccedf9a0baf825df142cdb69fef2940058975ba397d9267ca62e170987c697",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/batch3-tracking-contrast-candidate.json",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\batch3-tracking-contrast-candidate.json",
              "sha256": "dad7c9c59e1b06dd7d1cb17b4e263263925320dc5203598ae29bc89e96dc2f08",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/state-observations-round2/tracking-guided-contrast-challenge.json",
              "absolute_path": ".audit\\reviews\\library\\state-observations-round2\\tracking-guided-contrast-challenge.json",
              "sha256": "6dbe60c2f7f982eff8e9ffac33ddf76b1c6dfa0d90e13744b5df83c1dcd9a59f",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/coordinator-tracking-contrast-candidate.json",
              "absolute_path": ".audit\\reviews\\coordinator-tracking-contrast-candidate.json",
              "sha256": "23754a88684399ab4872c9199d4c74fafb9108089c5e00d7e89326be2829fbd1",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/coordinator-additional-ink-cases-review.json",
              "absolute_path": ".audit\\reviews\\coordinator-additional-ink-cases-review.json",
              "sha256": "b3512b94e413f788e0eee6f62e27443f6b1b266932ea8594d6e344ba0dd1ca01",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/batch4-bounded-observations.json",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\batch4-bounded-observations.json",
              "sha256": "93ca89405ec74cc220c9dc53e99b80dff531c181628c89d2d007d4370a25712d",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/batch4-attempt1/r2b4-block-details-held-unfocused-automatic-dark.png",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\batch4-attempt1\\r2b4-block-details-held-unfocused-automatic-dark.png",
              "sha256": "2ba9f2247c3822f5a6387db86cceb8d5629b791e849f09b46ed2d8f425fd1fba",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/state-observations-round2/batch03-held-time-contrast-candidate.json",
              "absolute_path": ".audit\\reviews\\conditions\\state-observations-round2\\batch03-held-time-contrast-candidate.json",
              "sha256": "0fb76cec5b4a9e52cb68797fd437c19f377702b0d07a01126de526b8f3f2c938",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/state-observations-round2/batch03-attempt02/weather_hour_disclosure_held-dark.png",
              "absolute_path": ".audit\\reviews\\conditions\\state-observations-round2\\batch03-attempt02\\weather_hour_disclosure_held-dark.png",
              "sha256": "38833aae8e83691d490420e8aa9d7d25c8c269c887de0edb978087f81e4e7d3b",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/state-observations-round2/batch3-progress-guide-contrast-candidate.json",
              "absolute_path": ".audit\\reviews\\library\\state-observations-round2\\batch3-progress-guide-contrast-candidate.json",
              "sha256": "f95ba1d1e75f6f60aabd7bdc60ff81f2ce7177f8691f8dc8b4b7f634382c6d8a",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/state-observations-round2/batch-03-disclosure-dropdown/dark-progress-guide-held.png",
              "absolute_path": ".audit\\reviews\\library\\state-observations-round2\\batch-03-disclosure-dropdown\\dark-progress-guide-held.png",
              "sha256": "6c6494b256ad64478de3df277ab52773e75ed7125f0cc0e08bdb9aa0d84c0420",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/coordinator-ink-extension-20261025.json",
              "absolute_path": ".audit\\reviews\\coordinator-ink-extension-20261025.json",
              "sha256": "2efdeb9c4509ecb028ab79b2eb285366336a4f9aed7c5d4532946ff39968c51d",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/state-observations-round2/batch04-held-text-observations.json",
              "absolute_path": ".audit\\reviews\\conditions\\state-observations-round2\\batch04-held-text-observations.json",
              "sha256": "5a47b96a1d07fbac0dfec9d13e7484a844b6cb2c3c4dc13c48434bc6f8a57762",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/state-observations-round2/batch4-undo-contrast-candidate.json",
              "absolute_path": ".audit\\reviews\\library\\state-observations-round2\\batch4-undo-contrast-candidate.json",
              "sha256": "f1597176d6e03d5db9c7391a14dbba8bdae85113a9420b5c1041c71df8cce718",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/state-observations-round2/batch04-attempt02/moon_preview_button_held-dark.png",
              "absolute_path": ".audit\\reviews\\conditions\\state-observations-round2\\batch04-attempt02\\moon_preview_button_held-dark.png",
              "sha256": "9a69430896c33ddc4a44cce46556ecaa6f5cae43a58cc2c356c64f74289d0deb",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/state-observations-round2/batch04-attempt02/moon_preview_button_held-light.png",
              "absolute_path": ".audit\\reviews\\conditions\\state-observations-round2\\batch04-attempt02\\moon_preview_button_held-light.png",
              "sha256": "fe0cf7a22424a2ad451a47c0fb2a7dc64a3c26d7c7c36072e17a7d837bd9e506",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/state-observations-round2/batch04-attempt02/night_reading_disclosure_held-dark.png",
              "absolute_path": ".audit\\reviews\\conditions\\state-observations-round2\\batch04-attempt02\\night_reading_disclosure_held-dark.png",
              "sha256": "93472ac4eef7849221fd2974aa91ffaed5f8029b91c8117db8a2fc3eee7386a7",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/state-observations-round2/batch04-attempt02/night_moonIntervals_disclosure_held-dark.png",
              "absolute_path": ".audit\\reviews\\conditions\\state-observations-round2\\batch04-attempt02\\night_moonIntervals_disclosure_held-dark.png",
              "sha256": "73119302ae0897a09eb94d3a7700a1fda7eebd239a1da2a4d36f4a8a81652a7d",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/state-observations-round2/batch04-attempt02/night_sun_disclosure_held-dark.png",
              "absolute_path": ".audit\\reviews\\conditions\\state-observations-round2\\batch04-attempt02\\night_sun_disclosure_held-dark.png",
              "sha256": "d2a237c8ab77174e4c81cd935592b1e70094eeee50e128fd009e31fc0f9b5a1b",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/state-observations-round2/batch04-attempt02/moon_reading_disclosure_held-dark.png",
              "absolute_path": ".audit\\reviews\\conditions\\state-observations-round2\\batch04-attempt02\\moon_reading_disclosure_held-dark.png",
              "sha256": "6e20fd8e405023e1c17a6660e439c27bc4d56edecedd82b644131948ca9a1ec3",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/state-observations-round2/batch04-attempt02/moon_moonDetails_disclosure_held-dark.png",
              "absolute_path": ".audit\\reviews\\conditions\\state-observations-round2\\batch04-attempt02\\moon_moonDetails_disclosure_held-dark.png",
              "sha256": "9689e1bc9f2ccd651fb839cb0eb6dd3022878458b28d0ad7bddc444eb2a41651",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/state-observations-round2/batch-04-delete-undo/light-entry-undo-focused.png",
              "absolute_path": ".audit\\reviews\\library\\state-observations-round2\\batch-04-delete-undo\\light-entry-undo-focused.png",
              "sha256": "77cdc19ea27dc26a933362e65b23f562c4a406b0687bfa49f2c556339a7e57cd",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/state-observations-round2/batch-04-delete-undo/light-entry-undo-held.png",
              "absolute_path": ".audit\\reviews\\library\\state-observations-round2\\batch-04-delete-undo\\light-entry-undo-held.png",
              "sha256": "d01b6a5630e28d148bd9c05fc60a657710a60b4dcc175c59f62def7e5a169a09",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/state-observations-round2/batch-04-delete-undo/dark-entry-undo-focused.png",
              "absolute_path": ".audit\\reviews\\library\\state-observations-round2\\batch-04-delete-undo\\dark-entry-undo-focused.png",
              "sha256": "e343f133bd4359bc15ac8661304e9fe35d41ecdc9a34d52b9b624c01eb61768f",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/state-observations-round2/batch-04-delete-undo/dark-entry-undo-held.png",
              "absolute_path": ".audit\\reviews\\library\\state-observations-round2\\batch-04-delete-undo\\dark-entry-undo-held.png",
              "sha256": "5396a08092267421a1f82bfc141ce463c0c92dde33afd113ab466a778e9ffdc0",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/coordinator-moon-ink-extension.json",
              "absolute_path": ".audit\\reviews\\coordinator-moon-ink-extension.json",
              "sha256": "e4d85711d555068cb4460b12aca327b815d8cf810b5447c1d5c09e507e371723",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/state-observations-round2/batch05-06-held-text-observations.json",
              "absolute_path": ".audit\\reviews\\conditions\\state-observations-round2\\batch05-06-held-text-observations.json",
              "sha256": "a373f4b80a00b0fd81f213420a08dd2efbd88bac0097bfc4263a5b2fedd3adf3",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/state-observations-round2/batch05-attempt01/month_day_1_held-dark.png",
              "absolute_path": ".audit\\reviews\\conditions\\state-observations-round2\\batch05-attempt01\\month_day_1_held-dark.png",
              "sha256": "eb7ad65fee7345c355222c994374056be9d85f02dc0f66d9f3382dd28c64af83",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/state-observations-round2/batch05-attempt01/month_retry_held-dark.png",
              "absolute_path": ".audit\\reviews\\conditions\\state-observations-round2\\batch05-attempt01\\month_retry_held-dark.png",
              "sha256": "7247cdc67a077b7fd64d4a73b38b4c8961e9d6f06cd87bdfea0df023354c4c41",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/state-observations-round2/batch05-attempt01/month_retry_held-light.png",
              "absolute_path": ".audit\\reviews\\conditions\\state-observations-round2\\batch05-attempt01\\month_retry_held-light.png",
              "sha256": "a63aabcb0bf1ed718a98c197850d4ffd078b86ee596f9bd486368aa8ccb86b74",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/state-observations-round2/batch06-attempt01/week_retry_held-dark.png",
              "absolute_path": ".audit\\reviews\\conditions\\state-observations-round2\\batch06-attempt01\\week_retry_held-dark.png",
              "sha256": "95038c0ded3405fa46821023dbdd651bafce4fdc2952b277652f3df594ba7d29",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/state-observations-round2/batch06-attempt01/week_retry_held-light.png",
              "absolute_path": ".audit\\reviews\\conditions\\state-observations-round2\\batch06-attempt01\\week_retry_held-light.png",
              "sha256": "a14d79b063654e2dd2bc2a008797cdb7fe55fc9e2114d1a2f4e4422812e8b08a",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/state-observations-round2/batch06-attempt01/week_day20_held-dark.png",
              "absolute_path": ".audit\\reviews\\conditions\\state-observations-round2\\batch06-attempt01\\week_day20_held-dark.png",
              "sha256": "0eff0a57c10be0db9614cc116cda1ed48927ef46683d7882e23d941009d5d237",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/coordinator-photo-ink-extension.json",
              "absolute_path": ".audit\\reviews\\coordinator-photo-ink-extension.json",
              "sha256": "a51dd2aba578dbcf3e2186acc4004c70ab229a8e8ab971f37bc74fedb1250dc6",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/batch10-photo-held-contrast-candidate.json",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\batch10-photo-held-contrast-candidate.json",
              "sha256": "b248feb59b0f12138f040356853949107fab12af8ee058ee896eb0d92a38eb9b",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/batch10-attempt1/r2b10-photo-held-unfocused-automatic-light.png",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\batch10-attempt1\\r2b10-photo-held-unfocused-automatic-light.png",
              "sha256": "358dcc42452cd6806da7a90e64c7455c68340e0883cb6e2977e26a11b2b9f3b7",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/coordinator-storage-ink-extension.json",
              "absolute_path": ".audit\\reviews\\coordinator-storage-ink-extension.json",
              "sha256": "ed470b3602cea583035549805b63430913e1f071d4d31c2bc870a4de50c3ca8a",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/batch11-storage-held-contrast-candidate.json",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\batch11-storage-held-contrast-candidate.json",
              "sha256": "67793a919cb20f393c4bfc9c5514228c81f075e06dcdbfd846efaf0ef67475a6",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/batch11-attempt1/r2b11-storage-choose-held-unfocused-automatic-dark.png",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\batch11-attempt1\\r2b11-storage-choose-held-unfocused-automatic-dark.png",
              "sha256": "d8261e98f95dbcda803b55c146d3cf56764edd53537e4ee52c49a4f0dd0e90ec",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/batch11-attempt1/r2b11-storage-cancel-held-unfocused-automatic-dark.png",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\batch11-attempt1\\r2b11-storage-cancel-held-unfocused-automatic-dark.png",
              "sha256": "6f3b68dd0707f051d53f84dec9ebda8f6510b587011486566ba97c753ff45144",
              "role": "CURRENT_PROOF"
            }
          ]
        }
      ],
      "root_group_status_at_snapshot": "CONFIRMED_BOUNDED_WITH_EXPLICIT_CALLER_LIMITS",
      "future_scope_approved": true,
      "execution_in_current_audit": false
    },
    {
      "root_cause_id": "RC-0013",
      "title": "Calibration action footer is unavailable while the Android numeric IME is open",
      "finding_ids": [
        "UIA-0015"
      ],
      "readiness": "OWNER_APPROVED_FUTURE_SCOPE",
      "requires_implementation_authorization": false,
      "proposed_boundary": "Apply the existing local Capture Block inset approach to the calibration footer after checking the Scaffold constraints. Keep the shared bar, labels, draft/save semantics and scientific proposals intact; no global bar redesign.",
      "proof_limit": "One physical Dark375.384dp100% Gboard numeric-IME case; other keyboards/devices/themes remain scoped. Back recovers the action; no unrecoverable flow block or data-loss claim. No Cal Apply or Save was performed. Saved-plan preservation is coordinator observation, not an independent DB readback.",
      "global_fix_authorized": false,
      "candidate_id": "CAND-A-RC-0013",
      "priority": "P2",
      "implementation_ready": true,
      "requires_owner_layout_choice": false,
      "owner_decision_ref": null,
      "impact": "Local confirmed interaction/readability contract; exact observed callers only",
      "expected_benefit": "Expected correction of the observed state; no measured After or human benefit claim",
      "risk_level": "medium",
      "source_refs": [
        {
          "file": "lib/presentation/widgets/capture_plan/calibration_preview_dialog.dart",
          "line": 197,
          "sha256": "f86fa3e5474e5a6a6511556edcd0887165ffcd57c837828733696b847d52f075"
        },
        {
          "file": "lib/presentation/widgets/capture_plan/calibration_preview_dialog.dart",
          "line": 363,
          "sha256": "f86fa3e5474e5a6a6511556edcd0887165ffcd57c837828733696b847d52f075"
        },
        {
          "file": "lib/presentation/widgets/capture_plan/capture_block_dialog.dart",
          "line": 1319,
          "sha256": "bbcc564f96d01c0b87177847d00d275d0c09bc7a47a22d026e88e5450ce84e9c"
        },
        {
          "file": "lib/presentation/shared/hybrid_parts.dart",
          "line": 334,
          "sha256": "b708b26d4e81e2dea90474583954a51a2b164e0cb4ace87cf83ece7d0e59641f"
        }
      ],
      "affected_callers": [
        "CAP-020"
      ],
      "dependencies": [],
      "acceptance_criteria": [
        "Actual Android numeric IME leaves action and ownership caption visible/reachable at100%.",
        "Keyboard hide restores normal layout without extra spacing; focused field can scroll into view.",
        "Disabled/validation/dirty-close and Apply/cancel retain exact model/storage behavior.",
        "Other editor footers and all three themes do not regress."
      ],
      "risks": [
        "Avoid double insets, clipped body or footer overlap.",
        "Preserve proposal dirty-close/Discard, disabled selection and Apply-to-draft versus Save-plan ownership.",
        "Do not change counts, timing, calibration calculations or persistence."
      ],
      "scope_exclusions": [
        "One physical Dark375.384dp100% Gboard numeric-IME case; other keyboards/devices/themes remain scoped.",
        "Back recovers the action; no unrecoverable flow block or data-loss claim.",
        "No Cal Apply or Save was performed. Saved-plan preservation is coordinator observation, not an independent DB readback."
      ],
      "current_evidence": [
        {
          "finding_id": "UIA-0015",
          "host_status": "CONFIRMED_NATIVE_BOUNDED",
          "native_status": "NATIVE_VERIFIED_BOUNDED_DARK_IME",
          "proof": [
            {
              "path": ".audit/evidence/android/state-round2/calibration-editor-before-ime.png",
              "absolute_path": ".audit\\evidence\\android\\state-round2\\calibration-editor-before-ime.png",
              "sha256": "913a9fb945cb3f678b42dd227667efc31e8896766b114b80e395610eb23dcddd",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/evidence/android/state-round2/calibration-dark-count-focused-real-ime.png",
              "absolute_path": ".audit\\evidence\\android\\state-round2\\calibration-dark-count-focused-real-ime.png",
              "sha256": "6933a8a7d5c6284e2a7eff86b732f5b6d2b5a23131b6f780d4baf3431555181e",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/evidence/android/state-round2/calibration-ime-back-restores-footer.png",
              "absolute_path": ".audit\\evidence\\android\\state-round2\\calibration-ime-back-restores-footer.png",
              "sha256": "a47ee11efa97aa4c288fef493ddcfd01ea58ef1b553d03a19f44e244c00002b4",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/native-calibration-round2.json",
              "absolute_path": ".audit\\reviews\\native-calibration-round2.json",
              "sha256": "e05224265b004633cda748131d44f43ea7a1ea067fca90ffea70e522f8d40557",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/state-observations-round2/native-calibration-cross-review.json",
              "absolute_path": ".audit\\reviews\\conditions\\state-observations-round2\\native-calibration-cross-review.json",
              "sha256": "d6ebea31b4a1c70e85868b7542195960f9aa32cc713402f6069e7ae4a5e27193",
              "role": "CURRENT_PROOF"
            }
          ]
        }
      ],
      "root_group_status_at_snapshot": "CONFIRMED_BOUNDED_WITH_EXPLICIT_CALLER_LIMITS",
      "future_scope_approved": true,
      "execution_in_current_audit": false
    },
    {
      "root_cause_id": "RC-0014",
      "title": "Night browser keyboard focus reaches Previous above the visible viewport",
      "finding_ids": [
        "UIA-0016"
      ],
      "readiness": "OWNER_APPROVED_FUTURE_SCOPE",
      "requires_implementation_authorization": false,
      "proposed_boundary": "Provide bounded focus reveal for this browser/header scroll owner using actual control geometry. Verify local traversal/reveal behavior rather than changing global keyboard policy or the focus-ring painter by assumption.",
      "proof_limit": "One actual-app Dark375dp100% synthetic host loop; no physical hardware-keyboard/TalkBack/all-path claim. Two-second persistence is simulated test time, not an indefinite native duration. SDK keepVisibleAtEnd/clamp is a plausible source explanation, not an instrumented causal proof. Imperative navigation retains the base GoRouter URI; actual NightMoonScreen/caller mounting is separately verified.",
      "global_fix_authorized": false,
      "candidate_id": "CAND-A-RC-0014",
      "priority": "P2",
      "implementation_ready": true,
      "requires_owner_layout_choice": false,
      "owner_decision_ref": null,
      "impact": "Local confirmed interaction/readability contract; exact observed callers only",
      "expected_benefit": "Expected correction of the observed state; no measured After or human benefit claim",
      "risk_level": "medium",
      "source_refs": [
        {
          "file": "lib/presentation/screens/details/night_moon_screen.dart",
          "line": 196,
          "sha256": "bf68b363dad27862b227ac883decffdf691f9524c0c6f3cd9e5b00b7fe745f4d"
        },
        {
          "file": "lib/presentation/screens/details/night_moon_screen.dart",
          "line": 670,
          "sha256": "bf68b363dad27862b227ac883decffdf691f9524c0c6f3cd9e5b00b7fe745f4d"
        },
        {
          "file": "lib/presentation/screens/home/home_screen.dart",
          "line": 265,
          "sha256": "259fcb4ea15da74aae27b226a72290193e9cbebba502477a1f6996d6e9aa5aef"
        },
        {
          "file": "lib/main.dart",
          "line": 352,
          "sha256": "0fc11a0b9bfc1749fd6af45097ff0d30e62dd8f0173919f47c7142cd87a43bba"
        },
        {
          "file": "lib/presentation/shared/hybrid_focus_highlight.dart",
          "line": 44,
          "sha256": "e78cd923508dec8ce364c201bb181596a1eea16f38e12a1aa7ab884ea707e4a6"
        }
      ],
      "affected_callers": [
        "NIT-004"
      ],
      "dependencies": [],
      "acceptance_criteria": [
        "Actual automatic keyboard traversal brings HeaderPrevious/Next and back-to-plan controls into view where applicable.",
        "The observed forward-loop case has visible focus at375dp100% and retains the same saved19OctplanID.",
        "Pointer navigation, Back and browse-versus-adopt behavior remain unchanged.",
        "Verify supplementary geometry and native keyboard behavior proportionally without inferring TalkBack or owner acceptance."
      ],
      "risks": [
        "Do not alter viewed/plan night, adoption, zone/DST semantics or saved plan identity.",
        "Avoid scroll jumps on pointer-only browsing, altered focus order or global traversal changes.",
        "Preserve reduced-motion behavior, all themes and unrestricted text scaling."
      ],
      "scope_exclusions": [
        "One actual-app Dark375dp100% synthetic host loop; no physical hardware-keyboard/TalkBack/all-path claim.",
        "Two-second persistence is simulated test time, not an indefinite native duration.",
        "SDK keepVisibleAtEnd/clamp is a plausible source explanation, not an instrumented causal proof.",
        "Imperative navigation retains the base GoRouter URI; actual NightMoonScreen/caller mounting is separately verified."
      ],
      "current_evidence": [
        {
          "finding_id": "UIA-0016",
          "host_status": "CONFIRMED_HOST",
          "native_status": "UNVERIFIED_NATIVE",
          "proof": [
            {
              "path": ".audit/reviews/conditions/state-observations-round2/batch02-full-app-attempt02/actual_app_previous_automatic-dark.png",
              "absolute_path": ".audit\\reviews\\conditions\\state-observations-round2\\batch02-full-app-attempt02\\actual_app_previous_automatic-dark.png",
              "sha256": "ac4bba1c8fd9ece55698983dab696794baa13c6af67d8c234481b0b231a29f99",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/state-observations-round2/batch02-full-app-attempt02/actual_app_previous_two_seconds-dark.png",
              "absolute_path": ".audit\\reviews\\conditions\\state-observations-round2\\batch02-full-app-attempt02\\actual_app_previous_two_seconds-dark.png",
              "sha256": "ac4bba1c8fd9ece55698983dab696794baa13c6af67d8c234481b0b231a29f99",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/state-observations-round2/batch02-focus-candidate-final.json",
              "absolute_path": ".audit\\reviews\\conditions\\state-observations-round2\\batch02-focus-candidate-final.json",
              "sha256": "e075e8ad12e57f8d8de522af169f0a062f5fd170ee036a3c068c111e896bc17c",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/conditions-header-focus-independent-challenge.json",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\conditions-header-focus-independent-challenge.json",
              "sha256": "abe6f2f171eee1eca96125f485a1b25db67e948c469c36d32784b91341b34256",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/state-observations-round2/batch02-full-app-attempt02/interaction.json",
              "absolute_path": ".audit\\reviews\\conditions\\state-observations-round2\\batch02-full-app-attempt02\\interaction.json",
              "sha256": "19844e9947997784ecbcd58585185d8cad9f1e91656b62e5ded41dafa11eeeb4",
              "role": "CURRENT_PROOF"
            }
          ]
        }
      ],
      "root_group_status_at_snapshot": "CONFIRMED_BOUNDED_WITH_EXPLICIT_CALLER_LIMITS",
      "future_scope_approved": true,
      "execution_in_current_audit": false
    },
    {
      "root_cause_id": "RC-0015",
      "title": "Optional-name focus ring remains below its field after a host inset transition",
      "finding_ids": [
        "UIA-0017"
      ],
      "readiness": "OWNER_APPROVED_FUTURE_SCOPE",
      "requires_implementation_authorization": false,
      "proposed_boundary": "Refresh the focus indicator against post-layout geometry for the confirmed dialog transition. Determine the actual paint/layout invalidation boundary before changing the shared painter; retain FocusManager ownership, hit geometry and pointer behavior.",
      "proof_limit": "Synthetic host inset/TestTextInput only; no physical Android IME or hardware-keyboard reproduction. Only this empty-name transition at375dp100% across three themes; no all-field/global focus defect claim. Ring bounds are approximate pixel observations; public field bounds are exact metadata. No instrumented painter timeline or separate2s persistence sample. The later-input frame recovers ring placement. No input loss, blocked Save or data corruption is alleged.",
      "global_fix_authorized": false,
      "candidate_id": "CAND-A-RC-0015",
      "priority": "P3",
      "implementation_ready": true,
      "requires_owner_layout_choice": false,
      "owner_decision_ref": null,
      "impact": "Local confirmed interaction/readability contract; exact observed callers only",
      "expected_benefit": "Expected correction of the observed state; no measured After or human benefit claim",
      "risk_level": "medium",
      "source_refs": [
        {
          "file": "lib/presentation/shared/hybrid_focus_highlight.dart",
          "line": 20,
          "sha256": "e78cd923508dec8ce364c201bb181596a1eea16f38e12a1aa7ab884ea707e4a6",
          "end_line": 30,
          "exact_excerpt": "    super.initState();\n    WidgetsBinding.instance.addObserver(this);\n    FocusManager.instance.addListener(repaint.refresh);\n    FocusManager.instance.addHighlightModeListener(_highlightChanged);\n  }\n\n  void _highlightChanged(FocusHighlightMode mode) => repaint.refresh();\n\n  @override\n  void didChangeMetrics() => repaint.refresh();\n"
        },
        {
          "file": "lib/presentation/shared/hybrid_focus_highlight.dart",
          "line": 81,
          "sha256": "e78cd923508dec8ce364c201bb181596a1eea16f38e12a1aa7ab884ea707e4a6",
          "end_line": 136,
          "exact_excerpt": "  void paint(Canvas canvas, Size size) {\n    if (FocusManager.instance.highlightMode != FocusHighlightMode.traditional) {\n      return;\n    }\n    final focused = FocusManager.instance.primaryFocus;\n    final focusContext = focused?.context;\n    final rootBox = root.currentContext?.findRenderObject();\n    if (focusContext == null || rootBox is! RenderBox || !rootBox.hasSize) {\n      return;\n    }\n    RenderObject? target = focusContext.findRenderObject();\n    // EditableText's Focus wraps only the text; highlight its whole field.\n    focusContext.visitAncestorElements((element) {\n      final widget = element.widget;\n      if (widget is InputDecorator ||\n          widget is ButtonStyleButton ||\n          widget is Slider ||\n          widget is IconButton) {\n        target = element.findRenderObject();\n        return false;\n      }\n      if (widget is Scaffold || widget is Navigator) return false;\n      return true;\n    });\n    final box = target;\n    if (box is! RenderBox ||\n        !box.attached ||\n        !box.hasSize ||\n        box.size.isEmpty) {\n      return;\n    }\n    // A route can leave between focus notification and paint.\n    RenderObject? ancestor = box;\n    while (ancestor != null && !identical(ancestor, rootBox)) {\n      ancestor = ancestor.parent;\n    }\n    if (ancestor == null) return;\n    final offset = box.localToGlobal(Offset.zero, ancestor: rootBox);\n    final rect = (offset & box.size).inflate(4);\n    canvas.save();\n    canvas.clipRect(Offset.zero & size);\n    canvas.drawRRect(\n      RRect.fromRectAndRadius(rect, const Radius.circular(10)),\n      Paint()\n        ..color = color\n        ..style = PaintingStyle.stroke\n        ..strokeWidth = 2,\n    );\n    canvas.restore();\n  }\n\n  @override\n  bool shouldRepaint(_FocusRingPainter oldDelegate) =>\n      oldDelegate.color != color || oldDelegate.root != root;\n}\n"
        },
        {
          "file": "lib/presentation/screens/logbook/session_detail_screen.dart",
          "line": 1139,
          "sha256": "319178a89ae7b2f242febd0b83fad146b1fe28866ca23852bbb2933a2ebdbb58",
          "end_line": 1154,
          "exact_excerpt": "  }\n\n  @override\n  Widget build(BuildContext context) => AlertDialog(\n    title: const Text(AppWords.nameOptional),\n    content: TextField(\n      key: const Key('detail.nameField'),\n      controller: _field,\n      autofocus: true,\n      maxLength: SessionRepository.maxNameLength,\n      decoration: const InputDecoration(\n        helper: Text('Leave empty to show the target and night.'),\n      ),\n    ),\n    actions: [\n      TextButton("
        },
        {
          "file": "lib/main.dart",
          "line": 352,
          "sha256": "0fc11a0b9bfc1749fd6af45097ff0d30e62dd8f0173919f47c7142cd87a43bba",
          "end_line": 361,
          "exact_excerpt": "              child: HybridFocusHighlight(\n                child: RestoreOutcomeNotice(child: NightClock(child: child!)),\n              ),\n            ),\n            StartupCover(loading: loading ?? false),\n          ],\n        );\n        return themeVM.isFieldMode\n            ? ColorFiltered(colorFilter: AppTheme.fieldFilter, child: content)\n            : content;"
        }
      ],
      "affected_callers": [
        "LOG-018"
      ],
      "dependencies": [],
      "acceptance_criteria": [
        "At375dp100%, actual automatic Tab focus and an inset transition leave the outer ring aligned with the current optional-name field after layout settles.",
        "Empty/long text, inset opening/closing and three-theme focus appearance retain their exact input and Cancel/readback behavior.",
        "Verify other animated focus owners proportionally before claiming a shared fix; test native IME separately without inferring owner acceptance."
      ],
      "risks": [
        "Avoid perpetual repainting, scroll/inset jitter or focus-order changes.",
        "Preserve Field filtering, reduced motion, actual field hit targets and text input.",
        "Do not conflate this painted-geometry case with UIA-0016 browser focus reveal."
      ],
      "scope_exclusions": [
        "Synthetic host inset/TestTextInput only; no physical Android IME or hardware-keyboard reproduction.",
        "Only this empty-name transition at375dp100% across three themes; no all-field/global focus defect claim.",
        "Ring bounds are approximate pixel observations; public field bounds are exact metadata. No instrumented painter timeline or separate2s persistence sample.",
        "The later-input frame recovers ring placement. No input loss, blocked Save or data corruption is alleged."
      ],
      "current_evidence": [
        {
          "finding_id": "UIA-0017",
          "host_status": "CONFIRMED_HOST",
          "native_status": "UNVERIFIED_NATIVE",
          "proof": [
            {
              "path": ".audit/reviews/library/state-observations-round2/batch-05-entry-name/light-entry-name-focused-host-input.png",
              "absolute_path": ".audit\\reviews\\library\\state-observations-round2\\batch-05-entry-name\\light-entry-name-focused-host-input.png",
              "sha256": "70a7f56cd1c7db8caf9d54e3835341f82610c762f8e1ed840c7a0a4f393cc7b4",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/state-observations-round2/batch-05-entry-name/dark-entry-name-focused-host-input.png",
              "absolute_path": ".audit\\reviews\\library\\state-observations-round2\\batch-05-entry-name\\dark-entry-name-focused-host-input.png",
              "sha256": "e3302bfa331fbd4a85bc3d005b98138924986e057e82c91e9cdc61bd8140bedc",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/state-observations-round2/batch-05-entry-name/field-entry-name-focused-host-input.png",
              "absolute_path": ".audit\\reviews\\library\\state-observations-round2\\batch-05-entry-name\\field-entry-name-focused-host-input.png",
              "sha256": "af69d91cbeeb43ed117b36dffa28af7abb9fa7c448d9aaa967def8517641bf79",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/state-observations-round2/batch-05-entry-name/light-entry-name-long-80-host-input.png",
              "absolute_path": ".audit\\reviews\\library\\state-observations-round2\\batch-05-entry-name\\light-entry-name-long-80-host-input.png",
              "sha256": "2c059597633d26512754e44529554a6f45028a8130fb3f990bc4f3dd128c4ac4",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/state-observations-round2/batch-05-entry-name/dark-entry-name-long-80-host-input.png",
              "absolute_path": ".audit\\reviews\\library\\state-observations-round2\\batch-05-entry-name\\dark-entry-name-long-80-host-input.png",
              "sha256": "7c2181879910d332f56c4fd302b5fe1189ee11929300835049da422cdb357d4f",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/state-observations-round2/batch-05-entry-name/field-entry-name-long-80-host-input.png",
              "absolute_path": ".audit\\reviews\\library\\state-observations-round2\\batch-05-entry-name\\field-entry-name-long-80-host-input.png",
              "sha256": "02d628301391d282cb1f126ee85a38b2f1335c417aeebef263f9f43efa75ab30",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/state-observations-round2/batch5-focus-ring-candidate.json",
              "absolute_path": ".audit\\reviews\\library\\state-observations-round2\\batch5-focus-ring-candidate.json",
              "sha256": "8338073665a674aeae51359e97044310450621ea5782fdbc93b29935d3759763",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/library-name-focus-independent-challenge.json",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\library-name-focus-independent-challenge.json",
              "sha256": "0e0ce25166b1b0e0dc60a48f1770831a42d3ec9d99107c6e3ca736b9738b962a",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/state-observations-round2/batch5-receipt.json",
              "absolute_path": ".audit\\reviews\\library\\state-observations-round2\\batch5-receipt.json",
              "sha256": "c7e2300dc9832669a8265c6160a1b19a8b685800cadb8023106f9770fcdf6f4b",
              "role": "CURRENT_PROOF"
            }
          ]
        }
      ],
      "root_group_status_at_snapshot": "CONFIRMED_BOUNDED_WITH_EXPLICIT_CALLER_LIMITS",
      "future_scope_approved": true,
      "execution_in_current_audit": false
    },
    {
      "root_cause_id": "RC-0016",
      "title": "Tonight labels the changed working target Saved while its draft write is pending",
      "finding_ids": [
        "UIA-0018"
      ],
      "readiness": "OWNER_APPROVED_FUTURE_SCOPE",
      "requires_implementation_authorization": false,
      "proposed_boundary": "Qualify the current working-plan card using its actual edited/pending context so new target facts are not presented as already saved. Keep PlanState.of valid for stored records and Logbook; do not optimistically mutate SQL status or equate autosave with explicit Save plan.",
      "proof_limit": "One actual Field375dp100% synthetic host held-write scene; no native, indefinite wait or all-working-caller claim. The stored M31/planned row is correct while pending and actual M42/draft is correct after success; no SQL corruption or premature-status-write requirement. Related Light failed-assumptions screen remains PARTIAL/P3 copy consistency only: its visible top banner truthfully discloses failure and retained8.5, despite the footer saying Saved on this device. It is not a silent-success or input-loss claim. No global PlanState.of rewrite, new persistence model or production correction is authorized.",
      "global_fix_authorized": false,
      "candidate_id": "CAND-A-RC-0016",
      "priority": "P2",
      "implementation_ready": true,
      "requires_owner_layout_choice": false,
      "owner_decision_ref": null,
      "impact": "Local confirmed interaction/readability contract; exact observed callers only",
      "expected_benefit": "Expected correction of the observed state; no measured After or human benefit claim",
      "risk_level": "medium",
      "source_refs": [
        {
          "file": "lib/presentation/screens/tonight/tonight_home_screen.dart",
          "line": 357,
          "sha256": "331c740c307a7a9d57b0c73913380097f802a7edc2c91dd0db7acfe3060a5888"
        },
        {
          "file": "lib/presentation/screens/home/home_screen.dart",
          "line": 339,
          "sha256": "259fcb4ea15da74aae27b226a72290193e9cbebba502477a1f6996d6e9aa5aef"
        },
        {
          "file": "lib/presentation/screens/home/home_screen.dart",
          "line": 344,
          "sha256": "259fcb4ea15da74aae27b226a72290193e9cbebba502477a1f6996d6e9aa5aef"
        },
        {
          "file": "lib/domain/services/current_session.dart",
          "line": 78,
          "sha256": "0f07adb9279b54110e170766323c5d0caa577d4e80957378a1d84ca68946ddda"
        },
        {
          "file": "lib/domain/services/current_session.dart",
          "line": 291,
          "sha256": "0f07adb9279b54110e170766323c5d0caa577d4e80957378a1d84ca68946ddda"
        },
        {
          "file": "lib/domain/services/current_session.dart",
          "line": 299,
          "sha256": "0f07adb9279b54110e170766323c5d0caa577d4e80957378a1d84ca68946ddda"
        },
        {
          "file": "lib/presentation/viewmodels/session_plan_viewmodel.dart",
          "line": 206,
          "sha256": "b752dd1e44aeb26d231bcbfc160dcfcdb6e1d67382108e62b430bea093519b22"
        },
        {
          "file": "lib/presentation/shared/plan_state.dart",
          "line": 30,
          "sha256": "faa3fbde015c85e5048ba48f32ba31371e24d833e00f35a6a502abfc1a04da6b"
        }
      ],
      "affected_callers": [
        "TON-006"
      ],
      "dependencies": [],
      "acceptance_criteria": [
        "During this held actual adoption write, the current working M42 card communicates pending/changed status rather than unqualified Saved.",
        "After success, failure and a later recovery edit, visible wording matches working-versus-stored context without losing the working plan.",
        "Same ID/night/plannedAt and saved snapshot semantics remain; no implicit Save plan or schema change.",
        "Verify exact affected working callers proportionally and preserve stored-record PlanState mapping."
      ],
      "risks": [
        "Preserve current plan ID/night, immutable saved snapshot and explicit Save ownership.",
        "Do not change stored-record state labels in Logbook/reference callers from this working-context case.",
        "Keep unknown/failure/offline facts truthful and avoid a global state or persistence rewrite."
      ],
      "scope_exclusions": [
        "One actual Field375dp100% synthetic host held-write scene; no native, indefinite wait or all-working-caller claim.",
        "The stored M31/planned row is correct while pending and actual M42/draft is correct after success; no SQL corruption or premature-status-write requirement.",
        "Related Light failed-assumptions screen remains PARTIAL/P3 copy consistency only: its visible top banner truthfully discloses failure and retained8.5, despite the footer saying Saved on this device. It is not a silent-success or input-loss claim.",
        "No global PlanState.of rewrite, new persistence model or production correction is authorized."
      ],
      "current_evidence": [
        {
          "finding_id": "UIA-0018",
          "host_status": "CONFIRMED_HOST",
          "native_status": "UNVERIFIED_NATIVE",
          "proof": [
            {
              "path": ".audit/reviews/planning/state-observations-round2/batch9-attempt2-payload-adoption/r2b9-candidate-back-tonight-during-held-write-field.png",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\batch9-attempt2-payload-adoption\\r2b9-candidate-back-tonight-during-held-write-field.png",
              "sha256": "a5cbed79f6a70f21a46969230d7a761c45574e77e66ce83a03166c39892e7a9e",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/batch9-attempt2-payload-adoption/r2b9-candidate-write-completed-tonight-field.png",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\batch9-attempt2-payload-adoption\\r2b9-candidate-write-completed-tonight-field.png",
              "sha256": "1af806631100d0c99943bfd370b17305ff39739b65de14373957e19bb8d62415",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/batch9-attempt1/r2b9-assumptions-write-error-parent-banner-light.png",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\batch9-attempt1\\r2b9-assumptions-write-error-parent-banner-light.png",
              "sha256": "ccec7a8b79f610a0c7fe92c99bf1e9d645cb5efb2add89cd1bae28dabc8536ce",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/batch9-attempt1/r2b9-assumptions-next-edit-recovered-parent-light.png",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\batch9-attempt1\\r2b9-assumptions-next-edit-recovered-parent-light.png",
              "sha256": "d64063dacf69188bea5d0dc1727b548000c2b28fa9b6237942b23470be721a3b",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/batch9-persistence-label-candidate.json",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\batch9-persistence-label-candidate.json",
              "sha256": "f957732b3ab21e1695ae7cf5d13d3506c940dd8d858c54d01afa65ac898caa8a",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/library/state-observations-round2/planning-batch9-independent-challenge.json",
              "absolute_path": ".audit\\reviews\\library\\state-observations-round2\\planning-batch9-independent-challenge.json",
              "sha256": "2ed96252d5606736cbfed12583c2678f41f73b897838abe419b7c170c87418cb",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/planning/state-observations-round2/batch9-attempt2-payload-adoption.log",
              "absolute_path": ".audit\\reviews\\planning\\state-observations-round2\\batch9-attempt2-payload-adoption.log",
              "sha256": "ff01981e1b0c0cdf1d370a7ac0f9f3faf0f7cf1b621a81834c9de93201ea53c6",
              "role": "CURRENT_PROOF"
            }
          ]
        }
      ],
      "root_group_status_at_snapshot": "CONFIRMED_BOUNDED_WITH_EXPLICIT_CALLER_LIMITS",
      "future_scope_approved": true,
      "execution_in_current_audit": false
    },
    {
      "root_cause_id": "RC-0008",
      "title": "Shared night-picker keeps a seven-column calendar below its48dp fit threshold",
      "finding_ids": [
        "UIA-0009"
      ],
      "readiness": "OWNER_SELECTED_FUTURE_SCOPE",
      "requires_implementation_authorization": false,
      "proposed_boundary": "After selected D-A09-NARROW strategy, change only320dp NightPickerDialog day-choice composition. Preserve375/412 month anatomy, full date/month/year/input/cancel/local-date behavior and MoonCalendarSection unchanged.",
      "proof_limit": "The original day-target geometry probe did not execute physical edge taps or its year/input/IME/dismissal actions. Later shared-picker observations are recorded separately and do not expand this geometry proof or imply physical acceptance.",
      "global_fix_authorized": false,
      "candidate_id": "CAND-A-RC-0008",
      "priority": "P3",
      "implementation_ready": true,
      "requires_owner_layout_choice": false,
      "owner_decision_ref": "owner-direction-20261026.json",
      "impact": "Medium at320dp only",
      "expected_benefit": "Meet narrow picker target contract while preserving375/412.",
      "risk_level": "Medium",
      "source_refs": [
        {
          "file": "lib/presentation/shared/night_picker_dialog.dart",
          "start": 48,
          "end": 58,
          "sha256": "e7dfb6bcd543764f83886c7fb0e2e53f48e19c98c72b9f443b42f690eaae7029"
        },
        {
          "file": "lib/presentation/shared/night_picker_dialog.dart",
          "start": 236,
          "end": 278,
          "sha256": "e7dfb6bcd543764f83886c7fb0e2e53f48e19c98c72b9f443b42f690eaae7029"
        }
      ],
      "affected_callers": [
        "NightMoonScreen date header",
        "Tonight home night sheet",
        "PlanContextScreen night picker",
        "HomeScreen copy",
        "SessionDetailScreen copy"
      ],
      "dependencies": [
        "Select D-A09-NARROW strategy, then separately authorize bounded implementation."
      ],
      "acceptance_criteria": [
        "At320/375/412 verify actual independent pointer and semantic target bounds without overlap.",
        "Preserve full dated labels, selection, previous/next/year/input, Cancel/OK and Back.",
        "No production behavior/data changes beyond approved narrow composition."
      ],
      "risks": [
        "Date/year/month bounds and localcivil return",
        "Shared callers and cancellation",
        "Unrequested largertext adaptation",
        "Reopening fixed MoonCalendarSection VQA030"
      ],
      "scope_exclusions": [
        "Shared NightPickerDialog at320dp/100% only. Existing MoonCalendarSection VQA-030 fix remains verified and unchanged."
      ],
      "current_evidence": [
        {
          "finding_id": "UIA-0009",
          "host_status": "CONFIRMED_HOST",
          "native_status": "UNVERIFIED_NATIVE",
          "proof": [
            {
              "path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-dark-320.png",
              "absolute_path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-dark-320.png",
              "sha256": "798f7d9307181db8e56fcecc15599a207ad616531c5139f40afd6484d1331289",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-dark-320.json",
              "absolute_path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-dark-320.json",
              "sha256": "11649698da7a2001215c691347e7c69fc6d32600164bb7bfd281b22c24786d95",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-dark-375.png",
              "absolute_path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-dark-375.png",
              "sha256": "9455d11f4962b066650379b62ec14d0b4d192be1b8db38bbf311e72dbae6cefd",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-dark-375.json",
              "absolute_path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-dark-375.json",
              "sha256": "3ed96492a406889f1a3bfcf406ffa1f5653a6fe326e272c1c779b47d1d6cd70e",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-dark-412.png",
              "absolute_path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-dark-412.png",
              "sha256": "cceaae1863cb899b6993ec2bc283cd00831a7a0ee4464060a37b891dcff4f075",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-dark-412.json",
              "absolute_path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-dark-412.json",
              "sha256": "77f72f677c0443b08dd557fbc6523edad87ad751b6a91f56664639ce83bc2ba5",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-field-320.png",
              "absolute_path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-field-320.png",
              "sha256": "33cfb0a1b218dbcd7e0a38076d0395457ade8816c512a9be220e6aaa3b615848",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-field-320.json",
              "absolute_path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-field-320.json",
              "sha256": "5af50921a6d7d7e052208de1ac128a37cd41c645030f207b11c94fa274c9cd15",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-field-375.png",
              "absolute_path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-field-375.png",
              "sha256": "da4e489bd04abbe263d4219961ba7fbe1d998d1a5a07d3c31b16ed4f77a7306b",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-field-375.json",
              "absolute_path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-field-375.json",
              "sha256": "72d3900ba8308a1f59c070a01c030de74b94a0c111bd8a2c66d77ea399290079",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-field-412.png",
              "absolute_path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-field-412.png",
              "sha256": "4d2ba5cd4cba07321ecc8ffa27499e9dc2583c3a579b94fd97a5c6a4d1c65926",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-field-412.json",
              "absolute_path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-field-412.json",
              "sha256": "b0291c1ba4108743989177ead3215f675a0a2349144930d84106f828dee83923",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-light-320.png",
              "absolute_path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-light-320.png",
              "sha256": "5edf08c8525b7501b1e58a089a5ce060edc6f26c15c8544227db40f06b922daf",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-light-320.json",
              "absolute_path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-light-320.json",
              "sha256": "9762b0dc49621b6f771973e9ce5f4a75ac7a8bfa3dbf6ca208cf8503bfde742e",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-light-375.png",
              "absolute_path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-light-375.png",
              "sha256": "eb4f30beac96dc255628e37abea7f5009091ff42e3eafd7d952d85825bca7f6e",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-light-375.json",
              "absolute_path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-light-375.json",
              "sha256": "ac9246578db51846dece108c6039d6d548f4aadbec78382339daf03a2c09c47a",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-light-412.png",
              "absolute_path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-light-412.png",
              "sha256": "4bbd2ca116d45b476dc481ba15d25b63b46e90d6e44d752e2892d7b30664ef2c",
              "role": "CURRENT_PROOF"
            },
            {
              "path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-light-412.json",
              "absolute_path": ".audit/reviews/conditions/probes-attempt-02/night_picker_targets-light-412.json",
              "sha256": "494fc6a460152903909f83e51b9c5c1fa3cefb6a67431795d22bbd95055199d3",
              "role": "CURRENT_PROOF"
            }
          ]
        }
      ],
      "root_group_status_at_snapshot": "IN_PROGRESS_COORDINATOR_ADJUDICATION",
      "owner_decision_json": "owner-decision-A09.json",
      "owner_decision_id": "D-A09-NARROW",
      "future_scope_approved": true,
      "execution_in_current_audit": false,
      "selected_strategy": "D09-LIST",
      "decision_required": "Resolved: full-width list under insufficient48dp fit constraints; no implementation in audit."
    }
  ],
  "decision_gated_packages": [],
  "dependency_order": [
    {
      "stage": "READY_P2_STATE",
      "roots": [
        "RC-0003",
        "RC-0002"
      ],
      "purpose": "Highest draft/recovery impact; two bounded actual callers."
    },
    {
      "stage": "PENDING_PRESENTATION",
      "roots": [
        "RC-0006"
      ],
      "purpose": "One repeated waiting pattern, three local caller corrections; preserve existing data/error guards."
    },
    {
      "stage": "INDEPENDENT_TRUTH_TARGET",
      "roots": [
        "RC-0001",
        "RC-0004",
        "RC-0005",
        "RC-0007",
        "RC-0011"
      ],
      "purpose": "Local copy/target corrections; no dependency on alternatives."
    },
    {
      "stage": "LOCAL_INTERACTION_CONTRACTS",
      "roots": [
        "RC-0012",
        "RC-0013",
        "RC-0014",
        "RC-0015",
        "RC-0016"
      ],
      "purpose": "Bounded contrast, IME footer, focus reveal/paint geometry and current working-plan feedback contracts; distinct owners and no global style/navigation/persistence rewrite."
    },
    {
      "stage": "SEPARATE_OWNER_GATE",
      "roots": [
        "RC-0008"
      ],
      "purpose": "D-A09-NARROW must resolve strategy first; does not block other ready packages."
    }
  ],
  "coordinator_scope_clarification": "320dp is the measured reference, not a device equality. Owner selected a full-width date list where actual independent day targets cannot fit48dp; preserve sufficient wider calendar layouts and closed MoonCalendarSection. Derive/verify exact fit threshold during later implementation; no product geometry was changed in audit.",
  "sequence_note": "Future approved scope: prioritize actual accepted-edit loss, then read recovery/feedback and independent local repairs. UIA0009 strategy is selected; preserve wider calendar and closed MoonCalendarSection. No execution in current audit.",
  "round2_addendum_ref": "round2-addendum.json",
  "prior_coordinator_snapshot": "history/before-round2-category-a.json",
  "round2_canonical_finding_hashes": {
    "UIA-0003": "ef981c444379f18dc90b6de5501233b388124bb2268a13ad506e89a2e78ff271",
    "UIA-0013": "2ac0032622d64fc881defcd3568082d9a2ea7f7637af9716921abab419ac55f9",
    "UIA-0014": "abb3e983b39144529e12c524067d0301a635955f5c5ec8d06f43eb99a1302d83",
    "UIA-0015": "1621d4208828f037c942722b396ee6d89ff8ab6e76c9f2bc4d97c232cb655945",
    "UIA-0016": "b5d687407a4753010cc0ddb28313d7ec52804ecf1b6ac78f324df44a32276193",
    "UIA-0017": "399245551cbadda6926f2d17bbcf431e3d2ad2d1e6de9c038e3c193e4df25ba8",
    "UIA-0018": "76260ebd411007d102fd41bfcc5b3f2d18961721212749a087250c860b1d7d09"
  },
  "final_coordinator_review_ref": "../reviews/library/convergence/final-package-review.json",
  "finalized_utc": "2026-10-25T22:40:20.769164+00:00",
  "owner_direction_ref": "owner-direction-20261026.json",
  "future_scope_decision_recorded": true,
  "implementation_in_this_audit_authorized": false,
  "implementation_started": false,
  "updated_utc": "2026-10-25T23:08:39.467865+00:00",
  "original_ready_a_approved": [
    "UIA-0001",
    "UIA-0002",
    "UIA-0003",
    "UIA-0004",
    "UIA-0005",
    "UIA-0006",
    "UIA-0007",
    "UIA-0008",
    "UIA-0012",
    "UIA-0013",
    "UIA-0014",
    "UIA-0015",
    "UIA-0016",
    "UIA-0017",
    "UIA-0018"
  ],
  "future_scope_approved": true,
  "current_canonical_finding_hashes": {
    "UIA-0001.json": "d263891e45fdefa34647c5eadfa4853e8084b6f6aa84454328569751ccf10809",
    "UIA-0002.json": "373f48edb5828eda3abbfb47d055e37f49ce0788c7ef9785a0ec46fc64b4680d",
    "UIA-0003.json": "e2c01a581e199dddbb94fdbce5ce12f971c4da9d2128814dc953eee62788fbb1",
    "UIA-0004.json": "8710534d2a9cc86e6774248ddbdf6a6af193f23e0463a074b4b6031b6dd4f817",
    "UIA-0005.json": "d415200fc535fb3d053946881e3a748374f846c97270abfa7636b7df862e997b",
    "UIA-0006.json": "db2420c9e1265fd87297adf3afb353f07d8ae78cc12bde42e4c39b5b5f56ec6f",
    "UIA-0007.json": "68d0566a3db69b6d4d4e742ef5847dd278e5e7065b0a36d517b4441a640dc7b8",
    "UIA-0008.json": "b2e0d44ef3a733edb2f9ffba05fd94835efe8cb0c49684d374711ff313279acb",
    "UIA-0009.json": "29b66804b630022b1e51f8d6da718b5aa4cb1eb030931a32c4360c6ac42525c0",
    "UIA-0010.json": "a4ea40b3c314e7ba52c1ef85852e143de3bd3b14fa5865eb2f6a23d81f812a72",
    "UIA-0011.json": "b45f6e471d90487273497b841cb75a57cf095c48730b5c0980a62f904bbae492",
    "UIA-0012.json": "f1804276aafd830524cc20176624f5f577849f676d3ef88b6d461a02ae1bbb6e",
    "UIA-0013.json": "f1da95146e43e284c345abb491b043ea9e15e0851575fb77831e7ebfea67da04",
    "UIA-0014.json": "f56e2f5bb7d4a208b8062e6d6abd6a95c6effeabe655820fa98b86646b57f167",
    "UIA-0015.json": "914fd207a42e7b279445579ca273e186720139b756b622600c155e568db77a93",
    "UIA-0016.json": "693ee2be206136a81e632cec8461ae74f61a5b6991935a4397a8d7490c5c17ee",
    "UIA-0017.json": "aff8ae0fb4d2f295f76b7e7d44754a217c4f26a6539e2257233559e3920b5373",
    "UIA-0018.json": "11fdf5f322e9cb65cc44ff5b75de3d38254c11ba650490bf43a10f4f5bf39989"
  },
  "round2_canonical_finding_hashes_scope": "Historical round-two pre-owner-decision snapshot; current_canonical_finding_hashes is the amended registry.",
  "owner_scope_acceptance": true,
  "owner_acceptance_scope": "Future repair direction only. owner_acceptance=false refers to unperformed owner visual/product acceptance."
}
```
