# packages/C

Text-only audit register exported from local `.audit/decisions/category-c.json`. Original SHA-256: `227910cbcaf97b9b2b5edf371194acdc347486aac1efb0155b23c103b8ff7c3a`. Private evidence references identify local artifacts; no raw capture, device identifier, binary or executable probe is published. User-profile paths are redacted. Original canonical bytes remain unchanged.

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
  "status": "C1_DEFERRED_BY_OWNER",
  "generated_utc": "2026-10-25T17:32:28.258938+00:00",
  "application_source_sha": "8157dcc275f1349f299e411c611888daafc035a0",
  "input_fingerprint": "e5963d808fb8e194b1c02e7de985bbd861665b41d94a653e8ae70d1197ebdcee",
  "verified_inputs": 765,
  "implementation_authorized": false,
  "owner_acceptance": false,
  "global_fix_authorized": false,
  "after_evidence": null,
  "evidence_limit": "Finite audit evidence only; current actual images and source establish bounded issues. No implemented After, full native/state or owner visual acceptance. New amendment reviews existing evidence without new runtime.",
  "conceptual_comparison_material": "../reviews/library/final-packages/conceptual-comparisons.md (schematic comparison, not Flutter After or measured benefit)",
  "category": "C",
  "new_significant_alternatives": [],
  "new_alternative_recommended": false,
  "existing_optional_alternatives": [
    {
      "id": "C1",
      "original_category": "C significant optional alternative",
      "current_implementation": "Weather charts expose a selected hour and metric panels; full hour details/table are separate disclosures. Chart panning alone does not change selected hour. Q5 retains panel metric/unit/scale context. Table temporal-context finding UIA0010 is separately addressable.",
      "source_refs": [
        {
          "file": "lib/presentation/widgets/weather_hybrid_view.dart",
          "line": 392
        },
        {
          "file": "lib/presentation/widgets/weather_hybrid_view.dart",
          "line": 746
        },
        {
          "file": "lib/presentation/widgets/weather_hybrid_view.dart",
          "line": 1354
        }
      ],
      "alternatives": [
        {
          "id": "C1-KEEP",
          "proposal": "Retain current selection/detail separation, with bounded CategoryB table context if selected.",
          "benefit": "Preserves familiar ownership; solves the confirmed table issue with a smaller change."
        },
        {
          "id": "C1-SHARED",
          "proposal": "One shared selected-hour strip coordinates chart and table/detail inspection while source/coverage stays reachable.",
          "benefit": "Potentially reduces effort comparing the same hour across variables."
        }
      ],
      "reference_rationale": "Existing UI_REFERENCE_LIBRARY line104 records C1 and R3/R6 structural inspiration. Current actual charts/table frames and conditions measured-pan review establish current behavior. Inspiration is not evidence of benefit or a mandate to import a kit.",
      "expected_user_benefit": "Potential easier cross-variable comparison for one selected forecast hour; not established by current fixtures or user testing.",
      "implementation_implications": "Material change to selected-hour/scroll/detail state ownership and synchronization; route reentry, resize, missing hours, forecast refresh and all entry contexts need explicit rules. Medium-high complexity. No new dependency, provider or chart type required/approved.",
      "accessibility_and_data_science_risks": "Keep selected/focused hour distinct from visible plot extent and the plan night. Preserve UTC instant versus local/DST repeated-hour identity, units, partial preceding-hour/gust/probability qualifications, Unknown gaps and independent physical scales. Keyboard/TalkBack selection and reading order need explicit verification.",
      "proposed_after_available": false,
      "decision_required": "Deferred by owner2026-10-26; no comparison or implementation now.",
      "category": "C",
      "origin": "EXISTING_OPTIONAL_NOT_NEW_CONFIRMED_FINDING",
      "new_finding": false,
      "implementation_ready": false,
      "implementation_authorized": false,
      "owner_acceptance": false,
      "after_evidence": null,
      "risk_level": "Medium-High",
      "dependencies": [
        "Explicit independent owner selection; no prerequisite for confirmed A/B fixes."
      ],
      "conceptual_visual_ref": "conceptual-comparisons.md#c1-shared-hour-inspector",
      "current_images": [
        {
          "path": ".audit/evidence/host/baseline-375/weather_charts-light-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_charts-light-1.png",
          "sha256": "ab207a1ca3dc9ebde079a600f1b7cbb3b21808a284047fba71352d5006aab0d6",
          "role": "CURRENT_ACTUAL_NOT_AFTER"
        },
        {
          "path": ".audit/evidence/host/baseline-375/weather_charts-dark-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_charts-dark-1.png",
          "sha256": "149a59dfe3ba181b41960f77305505393f124752837aa1f5f977cdf4e36f79b7",
          "role": "CURRENT_ACTUAL_NOT_AFTER"
        },
        {
          "path": ".audit/evidence/host/baseline-375/weather_charts-field-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_charts-field-1.png",
          "sha256": "0a967bd2af28d13f4e779785ee2561d01b333bbf1faf94b3d344718fc09aedca",
          "role": "CURRENT_ACTUAL_NOT_AFTER"
        },
        {
          "path": ".audit/evidence/host/baseline-375/weather_charts_b-light-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_charts_b-light-1.png",
          "sha256": "a8856943ca39e058de652b03a155eb4444c9d9c8d845e84d248c4bf55d7a8416",
          "role": "CURRENT_ACTUAL_NOT_AFTER"
        },
        {
          "path": ".audit/evidence/host/baseline-375/weather_charts_b-dark-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_charts_b-dark-1.png",
          "sha256": "d2af0d42cd3cb196eaac6dcc56823d333ea10916e31efd91cd7f3217894278dd",
          "role": "CURRENT_ACTUAL_NOT_AFTER"
        },
        {
          "path": ".audit/evidence/host/baseline-375/weather_charts_b-field-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_charts_b-field-1.png",
          "sha256": "650451fd5610e3302ee27d9c7d30fb06989d2aeb32d9732c132f41c413b51f56",
          "role": "CURRENT_ACTUAL_NOT_AFTER"
        },
        {
          "path": ".audit/evidence/host/baseline-375/weather_forecast_table-light-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_forecast_table-light-1.png",
          "sha256": "d82e018c785ac677e5382a08069dcfc3baa199583b97c33614049cc20e9f05ed",
          "role": "CURRENT_ACTUAL_NOT_AFTER"
        },
        {
          "path": ".audit/evidence/host/baseline-375/weather_forecast_table-dark-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_forecast_table-dark-1.png",
          "sha256": "37b24695bb2769369e1256afd649d12b7cf6d7cb1f3020c580396bd28f2d7838",
          "role": "CURRENT_ACTUAL_NOT_AFTER"
        },
        {
          "path": ".audit/evidence/host/baseline-375/weather_forecast_table-field-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_forecast_table-field-1.png",
          "sha256": "e833d75f7e166e8be3e187c4aa0ed06920b0c0508438b49c6680d0c89c7948d3",
          "role": "CURRENT_ACTUAL_NOT_AFTER"
        },
        {
          "path": ".audit/evidence/host/baseline-375/weather_table_later-light-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_table_later-light-1.png",
          "sha256": "f19966c86a4d550e4f499597df4bd59c1065bfef37282dddd6733962cbaf6a79",
          "role": "CURRENT_ACTUAL_NOT_AFTER"
        },
        {
          "path": ".audit/evidence/host/baseline-375/weather_table_later-dark-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_table_later-dark-1.png",
          "sha256": "c6f4095f2f44c55a3b4b1227cbb2592722c0725a6f08493ec97405627f6054cb",
          "role": "CURRENT_ACTUAL_NOT_AFTER"
        },
        {
          "path": ".audit/evidence/host/baseline-375/weather_table_later-field-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_table_later-field-1.png",
          "sha256": "47063f0ec901018d5e9161c374c55295f35bb563200d6e5c08efe64e4af58b22",
          "role": "CURRENT_ACTUAL_NOT_AFTER"
        }
      ],
      "impact": "Potential cross-chart/table hour scanning; unmeasured benefit",
      "acceptance_criteria": [
        "Compare current flow and clearly labeled conceptual alternative before approving implementation.",
        "Future actual prototype retains units, Unknown gaps, source/age/coverage, full local date/zone/DST and preceding-hour qualification.",
        "Preserve independent physical scales and accessible selection/focus; pan must not silently adopt another hour.",
        "Document interaction ownership and relation to independently selected UIA-0010 solution."
      ],
      "exclusions": [
        "No new confirmedUIA or automatic adoption.",
        "No dependency blocking Q5 closure or local table fix.",
        "No new chart type, font/palette, invented score, provider or science/model change."
      ],
      "owner_disposition": "DEFERRED_BY_OWNER"
    }
  ],
  "recommendation": "C1 deferred; no new significant alternative recommended or adopted.",
  "final_coordinator_review_ref": "../reviews/library/convergence/final-package-review.json",
  "finalized_utc": "2026-10-25T22:40:20.756971+00:00",
  "owner_direction_ref": "owner-direction-20261026.json",
  "future_scope_decision_recorded": true,
  "implementation_in_this_audit_authorized": false,
  "implementation_started": false,
  "updated_utc": "2026-10-25T23:08:39.467865+00:00",
  "owner_acceptance_scope": "Directions/deferrals recorded separately; owner_acceptance=false denotes unperformed visual/product acceptance."
}
```
