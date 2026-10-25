# reviews/UIA-0003-PRIORITY

Text-only audit register exported from local `.audit/reviews/design-closure/uia0003-priority-review.json`. Original SHA-256: `20f90f76f90d89de2ffe6e82b174009fb96c95d9d171e8739b34d6cc953a7b7b`. Private evidence references identify local artifacts; no raw capture, device identifier, binary or executable probe is published. User-profile paths are redacted. Original canonical bytes remain unchanged.

```json
{
  "review": "Independent priority adjudication of existing proof; same Library specialist, not blind independent reproduction",
  "finding_id": "UIA-0003",
  "existing_priority": "P2",
  "recommended_priority": "P1",
  "decision": "RECOMMEND_P1_BOUNDED_ACCEPTED_INPUT_FLOW_FAILURE",
  "source_sha": "8157dcc275f1349f299e411c611888daafc035a0",
  "input_fingerprint": "e5963d808fb8e194b1c02e7de985bbd861665b41d94a653e8ae70d1197ebdcee",
  "rubric_ref": {
    "file": ".audit/objective.md",
    "lines": [
      793,
      794,
      795,
      796
    ],
    "sha256": "6437d50e3b9e0c285cbf6b97387dde89e6eb52fd6499f893f2bc257452f57a96"
  },
  "rationale": "P1 high-impact flow failure applies to silent destruction of accepted newer editor work on successful completion of an earlier write, plus the separate Target confirmation-route result collision. This is an interaction ownership failure in the primary edit/Save or Apply workflow, not only a cosmetic state inconsistency. Unknown real-world timing probability limits prevalence claims; it does not make the demonstrated loss merely visual.",
  "cases": [
    {
      "caller": "TargetEditorScreen",
      "impact": "Newer accepted Name draft disappears without Back/Discard when prior Save resolves; caller returns earlier Submitted target. Exact earlier write and RA/Dec remain correct.",
      "trigger": "A user edits again while a Save is still in flight, then the earlier write completes.",
      "repeatability": "Controlled actual-widget/real in-memory Drift scenario deterministically asserts one write, returned route result, absent editor, and stored earlier name. Host text entry uses WidgetTester.enterText; it is not a physical IME proof.",
      "recovery": "Newer draft is not retained after successful exit; user must remember/re-enter it. Failure control instead retains newer draft and original stored row. No recovery of the discarded buffer was established.",
      "separate_route_case": "Completion while Unsaved changes is current raises actual AstroTarget versus UnsavedChoice framework assertion; editor/dialog remain and earlier submitted row is already stored. Diagnostic run 2PASS/1FAIL is preserved, not a clean suite or proven release/native crash."
    },
    {
      "caller": "PlanOverridesEditor",
      "impact": "Actual pending-state tap and registered client accept12 after Apply7.5; prior completion closes without Discard and SQL/VM/reopened field remain7.5. Later unapplied12 is lost.",
      "trigger": "Edit enabled non-readOnly numeric field during held earlier Apply, then earlier completion.",
      "repeatability": "Stronger actual-tap supplement 1PASS verifies focus/client/enabledness and exact real SQL readback. Later input is through the registered host test client; no controller mutation or later forced focus.",
      "recovery": "Reopening restores submitted7.5, not newer12. User can re-enter if remembered. Later12 must not be silently auto-applied as a remedy.",
      "metadata_limit": "gateCompleted:false in final metadata is historical tap-phase context; awaited completion, closure and SQL readback establish final outcome."
    }
  ],
  "probability": "UNKNOWN in ordinary device latency. Held synthetic futures establish a valid ordering, not its frequency.",
  "why_not_P0": "No confirmed critical loss of previously stored user data, corruption, duplicate write, unsafe physical action or app-wide essential-workflow failure. Correct immutable submitted payloads are stored.",
  "why_P1_over_P2": "Loss of accepted local work and a confirmed confirmation-route failure are higher impact than repeated presentation/state inconsistency. The recommendation is bounded to two named callers and the exact ordering; it is not a claim of widespread architecture failure.",
  "native_boundary": "UNVERIFIED_NATIVE for the race/loss/assertion. Existing native focus/IME/guard observations do not reproduce asynchronous completion ownership. No release crash claim.",
  "exclusions": [
    "Site and Results remain source hypotheses.",
    "Accepted Q4 Rig AbsorbPointer/ExcludeFocus guard remains a positive exception.",
    "No shared editor-base fix or global accepted-input loss claim.",
    "No production implementation or canonical priority mutation."
  ],
  "source_refs": [
    {
      "file": "lib/presentation/screens/target/target_editor_screen.dart",
      "lines": [
        115,
        130,
        147,
        158,
        162,
        184
      ],
      "sha256": "1bae0d630b1a143e1098a2cd295f1fbf2b190640c1469184599e0b79e83abd9c"
    },
    {
      "file": "lib/presentation/widgets/capture_plan/plan_overrides_editor.dart",
      "lines": [
        104,
        127,
        135,
        264
      ],
      "sha256": "74c392ce71501e942aa5adff31ba31874512e133939b47a29b4f51281cce9a77"
    },
    {
      "file": "lib/presentation/screens/equipment/equipment_editor.dart",
      "lines": [
        405
      ],
      "sha256": "554a399e3d891648b6e64a4eb61401d01e4e345b0768daa96e9e245999c941a2"
    }
  ],
  "evidence_refs": [
    {
      "path": "reviews/library/probe-evidence/target-held-save-back.png",
      "sha256": "02bfbb89664a8352daf2bdad7641e9a2722693ec2072196e81880c643356ce80",
      "evidence_id": "EVD-0540",
      "validity": "VALID_BOUNDED_HOST",
      "verified_sha256": "02bfbb89664a8352daf2bdad7641e9a2722693ec2072196e81880c643356ce80"
    },
    {
      "path": "reviews/library/probe-evidence/observations.json",
      "sha256": "c7dbae7702450364f35cd0f79fe9ca0e84a771ffb55697e4bc367adf77c6067f",
      "verified_sha256": "c7dbae7702450364f35cd0f79fe9ca0e84a771ffb55697e4bc367adf77c6067f"
    },
    {
      "path": "reviews/library/probe-run-4-final.log",
      "sha256": "2a92a80a01eeec24eec50fd1f45288ea80528052d660de968890f8a244f50c13",
      "verified_sha256": "2a92a80a01eeec24eec50fd1f45288ea80528052d660de968890f8a244f50c13"
    },
    {
      "path": "reviews/library/target_save_readback_probe_test.dart",
      "sha256": "d99f4c09bbdcf04e9b120df87e5b6bf9ba8be557829737569318b7eeef3d645c",
      "verified_sha256": "d99f4c09bbdcf04e9b120df87e5b6bf9ba8be557829737569318b7eeef3d645c"
    },
    {
      "path": "reviews/library/target-save-readback-run-1.log",
      "sha256": "c6491cea44f4a50c4e128eca5aa5f4c073c2afb2c9f259e0718de401cdbd416d",
      "verified_sha256": "c6491cea44f4a50c4e128eca5aa5f4c073c2afb2c9f259e0718de401cdbd416d"
    },
    {
      "path": "reviews/library/target-save-readback/observations.json",
      "sha256": "cbc9d19342b43bd7636246bea6f4347480be2f1022460e8e6da3b8051d2d787a",
      "verified_sha256": "cbc9d19342b43bd7636246bea6f4347480be2f1022460e8e6da3b8051d2d787a"
    },
    {
      "path": "reviews/library/target-save-readback/complete_with_prompt_open-after-completion.png",
      "sha256": "efd3929ac9544be83ede29163f2340dc98d9a341c41a7bbe0601e358ce62529f",
      "evidence_id": "EVD-0556",
      "validity": "VALID_BOUNDED_HOST",
      "verified_sha256": "efd3929ac9544be83ede29163f2340dc98d9a341c41a7bbe0601e358ce62529f"
    },
    {
      "path": "reviews/library/target-save-readback/complete_with_prompt_open-before-completion.png",
      "sha256": "a5a78b52a6c1781c155085a2333d6ec0f291165b186eac8e22c73a3280aaeaed",
      "evidence_id": "EVD-0557",
      "validity": "VALID_BOUNDED_HOST",
      "verified_sha256": "a5a78b52a6c1781c155085a2333d6ec0f291165b186eac8e22c73a3280aaeaed"
    },
    {
      "path": "reviews/library/target-save-readback/complete_without_back-after-completion.png",
      "sha256": "1c60ac6411471b344c5af5e6310995b40e4f5aa9de4674244ba168ad8a39ebea",
      "evidence_id": "EVD-0558",
      "validity": "VALID_BOUNDED_HOST",
      "verified_sha256": "1c60ac6411471b344c5af5e6310995b40e4f5aa9de4674244ba168ad8a39ebea"
    },
    {
      "path": "reviews/library/target-save-readback/complete_without_back-before-completion.png",
      "sha256": "646adc62300c3f24d2d8ad857b4f110bab8058f62789c1d70d36b1f006987037",
      "evidence_id": "EVD-0559",
      "validity": "VALID_BOUNDED_HOST",
      "verified_sha256": "646adc62300c3f24d2d8ad857b4f110bab8058f62789c1d70d36b1f006987037"
    },
    {
      "path": "reviews/library/target-save-readback/failure_retains_newer-after-completion.png",
      "sha256": "cad64eb4b143b8c1fcaca44b11e621bb3efcd0bb07d4bf8be41985d7356092b3",
      "evidence_id": "EVD-0560",
      "validity": "VALID_BOUNDED_HOST",
      "verified_sha256": "cad64eb4b143b8c1fcaca44b11e621bb3efcd0bb07d4bf8be41985d7356092b3"
    },
    {
      "path": "reviews/library/target-save-readback/failure_retains_newer-before-completion.png",
      "sha256": "646adc62300c3f24d2d8ad857b4f110bab8058f62789c1d70d36b1f006987037",
      "evidence_id": "EVD-0561",
      "validity": "VALID_BOUNDED_HOST",
      "verified_sha256": "646adc62300c3f24d2d8ad857b4f110bab8058f62789c1d70d36b1f006987037"
    },
    {
      "path": "reviews/planning/state-observations-round2/batch9-attempt3-actual-tap/r2b9-actual-tap-later-input-accepted-dark.png",
      "sha256": "5bbbb2e5b4928228a41f989bd623a91215c33d24485144330ef1505d340efb8f",
      "evidence_id": "EVD-2008",
      "validity": "VALID_BOUNDED_HOST",
      "verified_sha256": "5bbbb2e5b4928228a41f989bd623a91215c33d24485144330ef1505d340efb8f"
    },
    {
      "path": "reviews/planning/state-observations-round2/batch9-attempt3-actual-tap/r2b9-actual-tap-pending-input-client-dark.png",
      "sha256": "ba28a3eb4306430e0458bc2c6160df8b17424360fd30aa019a09c4ad56112728",
      "evidence_id": "EVD-2009",
      "validity": "VALID_BOUNDED_HOST",
      "verified_sha256": "ba28a3eb4306430e0458bc2c6160df8b17424360fd30aa019a09c4ad56112728"
    },
    {
      "path": "reviews/planning/state-observations-round2/batch9-attempt3-actual-tap/r2b9-actual-tap-reopened-readback-dark.png",
      "sha256": "d25f329c3920d8428535272819a5d3016bb3152707df617ed369a9b7efdd0e28",
      "evidence_id": "EVD-2010",
      "validity": "VALID_BOUNDED_HOST",
      "verified_sha256": "d25f329c3920d8428535272819a5d3016bb3152707df617ed369a9b7efdd0e28"
    },
    {
      "path": "reviews/planning/state-observations-round2/batch9-accepted-input-candidate.json",
      "sha256": "190c78ccccb06707e74fee58acd0cab7e667ae92a21ee04b4799e2ad879e633f",
      "verified_sha256": "190c78ccccb06707e74fee58acd0cab7e667ae92a21ee04b4799e2ad879e633f"
    },
    {
      "path": "reviews/library/state-observations-round2/planning-batch9-independent-challenge.json",
      "sha256": "2ed96252d5606736cbfed12583c2678f41f73b897838abe419b7c170c87418cb",
      "verified_sha256": "2ed96252d5606736cbfed12583c2678f41f73b897838abe419b7c170c87418cb"
    },
    {
      "path": "reviews/library/state-observations-round2/planning-batch9-actual-tap-review-addendum.json",
      "sha256": "66a3c10476b7fd4b06a359465fce5854f675ac6556479b2cdc52c1185d1140f8",
      "verified_sha256": "66a3c10476b7fd4b06a359465fce5854f675ac6556479b2cdc52c1185d1140f8"
    },
    {
      "path": "reviews/planning/state-observations-round2/batch9-actual-tap-terminal-receipt.json",
      "sha256": "8eb94e20138ff9d9fd9bc8382c8b0385de67832209da1661470a794b9be6b9c4",
      "verified_sha256": "8eb94e20138ff9d9fd9bc8382c8b0385de67832209da1661470a794b9be6b9c4"
    },
    {
      "path": "reviews/planning/state-observations-round2/batch9-attempt3-actual-tap.log",
      "sha256": "aabbee29cbcb9c977aae50355455ad0e3c7da7bd6e497e961f40a9b0e748ddaa",
      "verified_sha256": "aabbee29cbcb9c977aae50355455ad0e3c7da7bd6e497e961f40a9b0e748ddaa"
    }
  ],
  "images_opened_this_review": [
    "EVD-0556",
    "EVD-0558",
    "EVD-0559",
    "EVD-2008",
    "EVD-2009",
    "EVD-2010"
  ],
  "status": "REVIEW_COMPLETE_COORDINATOR_ADJUDICATION_REQUIRED"
}
```
