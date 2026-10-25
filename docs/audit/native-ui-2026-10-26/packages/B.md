# packages/B

Text-only audit register exported from local `.audit/decisions/category-b.json`. Original SHA-256: `db44009dd20d03a9981a12790f0c58c45b10492f74182df774c2e6b6c5658bc8`. Private evidence references identify local artifacts; no raw capture, device identifier, binary or executable probe is published. User-profile paths are redacted. Original canonical bytes remain unchanged.

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
  "status": "OWNER_DIRECTIONS_RECORDED_B10_PREIMPLEMENTATION_COMPARISON_REQUIRED",
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
  "category": "B",
  "confirmed_new_finding_count": 2,
  "confirmed_packages": [
    {
      "finding_id": "UIA-0010",
      "root_cause_id": "RC-0009",
      "current": "Far-right viewport shows Wind/gust, Precipitation probability, RH and Visibility values, but no Local time values. Local time column and every hour cell have x=-385.8407 and width125.532; the full column is outside375dp viewport. Values cannot be directly associated with an hour without panning away.",
      "alternatives": [
        {
          "id": "B-TABLE-KEEP",
          "proposal": "Retain current table.",
          "benefit": "No new interaction or width cost.",
          "cost": "Reading later variables still requires panning away to recover the hour."
        },
        {
          "id": "B-TABLE-TIME",
          "proposal": "Retain a compact frozen Local time reference while the other existing columns pan.",
          "benefit": "Associate each later-variable value with its actual row hour in the same viewport.",
          "cost": "Consumes horizontal width; requires synchronized row heights/scrolling and coherent semantics."
        },
        {
          "id": "B-TABLE-REPEAT",
          "proposal": "Repeat the time beside bounded metric groups while retaining all table data.",
          "benefit": "Explicit temporal identity without a separate fixed column.",
          "cost": "Wider/duplicated presentation and more repeated semantics; must preserve row alignment."
        }
      ],
      "recommendation": "Review B-TABLE-TIME as the smallest composition change. Actual proposed Flutter geometry must be demonstrated before adoption; no After exists.",
      "reference_rationale": "Current actual first/later table captures establish the problem. ConceptB clarity and existing R3/R6 references support retained data identity; they do not mandate an inspector or establish benefit by themselves.",
      "implementation_implications": "Local _Details table anatomy only; keep all nine columns and exact values/units, provider/source link, Unknown markers, partial preceding-hour stars and dated/zone/DST identity. C1 and Q5 charts remain separate.",
      "a11y_science_risks": "Duplicated time must not be announced twice ambiguously; preserve reading order and untruncated dated labels. Frozen/scrolling panes must remain aligned for mixed-height text. Never invent a value or equate precipitation probability with duration.",
      "decision_required": "Before implementation: actual visual comparison and complexity assessment for compact fixed time column; owner preference is preliminary. No further option-selection question during audit.",
      "after_evidence": null,
      "implementation_ready": false,
      "candidate_id": "CAND-B-UIA-0010",
      "category": "B",
      "priority": "P2",
      "requires_owner_decision": true,
      "impact": "High temporal readability",
      "risk_level": "Medium",
      "scope": "Owner-reviewed table context retention, such as preserving a compact time reference while panning later columns. Preserve nine columns, units, values, unknown markers and preceding-hour qualification.",
      "current_evidence": [
        {
          "path": ".audit/evidence/android/fixture-weather-table-first-dark-100.png",
          "absolute_path": ".audit/evidence/android/fixture-weather-table-first-dark-100.png",
          "sha256": "955802ef464e13e3fcb39af3b5a0118e9c858c967441a991a95767c31332c6cc",
          "role": "CURRENT_PROOF"
        },
        {
          "path": ".audit/evidence/android/fixture-weather-table-later-dark-100.png",
          "absolute_path": ".audit/evidence/android/fixture-weather-table-later-dark-100.png",
          "sha256": "0dc170ce95a0953bc10bc7492ed56eb7005463d918b83e9509a5930c1fb9a0b9",
          "role": "CURRENT_PROOF"
        },
        {
          "path": ".audit/evidence/host/baseline-375/weather_table_later-light-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_table_later-light-1.png",
          "sha256": "f19966c86a4d550e4f499597df4bd59c1065bfef37282dddd6733962cbaf6a79",
          "role": "CURRENT_PROOF"
        },
        {
          "path": ".audit/evidence/host/baseline-375/weather_table_later-light-1.json",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_table_later-light-1.json",
          "sha256": "39044f753c9a3da13d7d22b6f9b16b2eb377a48d69ec4b63bae76d5487b7de1f",
          "role": "CURRENT_PROOF"
        },
        {
          "path": ".audit/evidence/host/baseline-375/weather_table_later-dark-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_table_later-dark-1.png",
          "sha256": "c6f4095f2f44c55a3b4b1227cbb2592722c0725a6f08493ec97405627f6054cb",
          "role": "CURRENT_PROOF"
        },
        {
          "path": ".audit/evidence/host/baseline-375/weather_table_later-dark-1.json",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_table_later-dark-1.json",
          "sha256": "b2ce792c9b776543b91e1f8d030af1447d58f75e0b3b1baed2d4e6a763be0fbb",
          "role": "CURRENT_PROOF"
        },
        {
          "path": ".audit/evidence/host/baseline-375/weather_table_later-field-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_table_later-field-1.png",
          "sha256": "47063f0ec901018d5e9161c374c55295f35bb563200d6e5c08efe64e4af58b22",
          "role": "CURRENT_PROOF"
        },
        {
          "path": ".audit/evidence/host/baseline-375/weather_table_later-field-1.json",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_table_later-field-1.json",
          "sha256": "b9c8978ea6719e1319c8caba31bbf36fdbbb7f1ba42007fb9a63e2543aaff89c",
          "role": "CURRENT_PROOF"
        },
        {
          "path": ".audit/evidence/host/baseline-375/weather_forecast_table-light-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_forecast_table-light-1.png",
          "sha256": "d82e018c785ac677e5382a08069dcfc3baa199583b97c33614049cc20e9f05ed",
          "role": "CURRENT_PROOF"
        },
        {
          "path": ".audit/evidence/host/baseline-375/weather_forecast_table-light-1.json",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_forecast_table-light-1.json",
          "sha256": "266d32cddc75ba2e1945a3c37dca0434817f51bf1c6375838f90466d13fb9eb2",
          "role": "CURRENT_PROOF"
        },
        {
          "path": ".audit/evidence/host/baseline-375/weather_forecast_table-dark-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_forecast_table-dark-1.png",
          "sha256": "37b24695bb2769369e1256afd649d12b7cf6d7cb1f3020c580396bd28f2d7838",
          "role": "CURRENT_PROOF"
        },
        {
          "path": ".audit/evidence/host/baseline-375/weather_forecast_table-dark-1.json",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_forecast_table-dark-1.json",
          "sha256": "c50fd25751dbec5d20104ece8d0215f6c95e1d675da32444149489616cff9f44",
          "role": "CURRENT_PROOF"
        },
        {
          "path": ".audit/evidence/host/baseline-375/weather_forecast_table-field-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_forecast_table-field-1.png",
          "sha256": "e833d75f7e166e8be3e187c4aa0ed06920b0c0508438b49c6680d0c89c7948d3",
          "role": "CURRENT_PROOF"
        },
        {
          "path": ".audit/evidence/host/baseline-375/weather_forecast_table-field-1.json",
          "absolute_path": ".audit/evidence/host/baseline-375/weather_forecast_table-field-1.json",
          "sha256": "65535e9f733b52f93d2c06514c254b13730d6b74d9d92bc470a74465c1c3ad4b",
          "role": "CURRENT_PROOF"
        }
      ],
      "native_status": "NATIVE_VERIFIED_BOUNDED_SYNTHETIC_DARK",
      "native_scope_limit": "Actual physical Android interaction, Dark100%,375.384615dp, memory-only companion APK770f91. No canonical owner-data, all-theme, real-provider or release acceptance.",
      "source_refs": [
        {
          "file": "lib/presentation/widgets/weather_hybrid_view.dart",
          "start": 1387,
          "end": 1497,
          "sha256": "1dc6b157183af1f4b53446842f3fd5ab2af4e436afca1fbbd661a007feeb528c"
        }
      ],
      "acceptance_criteria": [
        "At375/412dp a later-column value can be associated with its actual hour without losing that value.",
        "First and last rows, unknown values and partial-hour stars remain factual.",
        "Light/Dark/Field100% retain legibility and scrolling."
      ],
      "exclusions": [],
      "dependencies": [
        "Owner selects bounded local composition, then separately authorizes implementation.",
        "No C1 or global shared-component rewrite prerequisite."
      ],
      "conceptual_visual_ref": "conceptual-comparisons.md#b-table-hour-context",
      "owner_direction_ref": "owner-direction-20261026.json",
      "execution_in_current_audit": false,
      "selected_strategy": "B-TABLE-TIME",
      "owner_selection_status": "PRELIMINARY_CONDITIONAL"
    },
    {
      "finding_id": "UIA-0011",
      "root_cause_id": "RC-0010",
      "current": "File size basis is a short left label, but its full explanatory/recovery paragraph is rendered as a right-aligned HybridFact value. Current three-theme PNGs show eight short lines. Sidecars record143.5dp available text width and160dp paragraph height. Surrounding numeric facts benefit from the compact label/value layout; prose is harder to scan in the same narrow alignment.",
      "alternatives": [
        {
          "id": "B-FILE-KEEP",
          "proposal": "Retain current numeric label/value treatment.",
          "benefit": "Consistent with surrounding budget rows.",
          "cost": "Long source/recovery prose remains narrow and harder to scan."
        },
        {
          "id": "B-FILE-PROSE",
          "proposal": "Use local label-above/full-width left-aligned prose for File size basis only.",
          "benefit": "Read Unknown/source/recovery reasoning as a coherent paragraph.",
          "cost": "Changes local hierarchy and vertical rhythm; may need a carefully retained semantic label/content group."
        },
        {
          "id": "B-FILE-DISCLOSE",
          "proposal": "Keep a concise source fact plus an existing disclosure for the unchanged complete explanation.",
          "benefit": "Short initial scan.",
          "cost": "Adds an interaction and risks hiding critical Unknown/recovery context; not preferred without stronger need."
        }
      ],
      "recommendation": "Owner selected full-width explanation with local heading for future implementation; preserve exact text, unknown/provenance semantics and other numeric rows.",
      "reference_rationale": "Actual current three-theme Plan images plus existing full-width prose/source patterns support a caller-specific treatment. Q6/VQA015 Target Source is a separate already-closed caller, not reopened.",
      "implementation_implications": "Change CaptureBudgetSummary File size basis composition only. Retain the entire StorageText.plan content including Unknown, measured/theoretical basis, conflicts and recovery guidance. No numerical, file, rig or persistence behavior change.",
      "a11y_science_risks": "Preserve associated label/value announcement, natural wrapping and Field semantic roles. Long filenames and multi-block/conflict text need the same readable treatment. Do not imply estimates are measured or Unknown is zero.",
      "decision_required": "Resolved: full-width explanation with local heading; execute only in later implementation task.",
      "after_evidence": null,
      "implementation_ready": true,
      "candidate_id": "CAND-B-UIA-0011",
      "category": "B",
      "priority": "P3",
      "requires_owner_decision": false,
      "impact": "Medium local prose readability",
      "risk_level": "Low-Medium",
      "scope": "After bounded owner approval, use a local label-above/full-width prose presentation or equivalent existing full-width source pattern for this one paragraph caller. Preserve numeric HybridFact rows and all semantic/data content. Do not globally redesign HybridFact.",
      "current_evidence": [
        {
          "path": ".audit/evidence/host/baseline-375/plan_budget_facts-light-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/plan_budget_facts-light-1.png",
          "sha256": "658ebabd6dc1975d00bf94bbc609d466672119308b77724a28b8afcf71852806",
          "role": "CURRENT_PROOF"
        },
        {
          "path": ".audit/evidence/host/baseline-375/plan_budget_facts-light-1.json",
          "absolute_path": ".audit/evidence/host/baseline-375/plan_budget_facts-light-1.json",
          "sha256": "0b6b60fe174a3d0e9a55172e10df13c0fc2debbb15ff9c6c6da310133de17200",
          "role": "CURRENT_PROOF"
        },
        {
          "path": ".audit/evidence/host/baseline-375/plan_budget_facts-dark-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/plan_budget_facts-dark-1.png",
          "sha256": "c2094f61c6991ee573b24dffa1b18cf238f9e7ff165773d51508932a541710db",
          "role": "CURRENT_PROOF"
        },
        {
          "path": ".audit/evidence/host/baseline-375/plan_budget_facts-dark-1.json",
          "absolute_path": ".audit/evidence/host/baseline-375/plan_budget_facts-dark-1.json",
          "sha256": "99f140c9c874a455a6d4e33a9a2707a4ed4c50ba72fd4c329ca475f3cc3037c9",
          "role": "CURRENT_PROOF"
        },
        {
          "path": ".audit/evidence/host/baseline-375/plan_budget_facts-field-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/plan_budget_facts-field-1.png",
          "sha256": "d32898e02f71ea6111887ba61bb34d02304dd8b14cfed21b6160fd72ffe7626e",
          "role": "CURRENT_PROOF"
        },
        {
          "path": ".audit/evidence/host/baseline-375/plan_budget_facts-field-1.json",
          "absolute_path": ".audit/evidence/host/baseline-375/plan_budget_facts-field-1.json",
          "sha256": "e93ff3f80db79bcdbb9716ec10bf3b82efe267705c59783ffad45a359beffcd2",
          "role": "CURRENT_PROOF"
        }
      ],
      "native_status": "UNVERIFIED_NATIVE",
      "native_scope_limit": "Host only; no physical/owner acceptance.",
      "source_refs": [
        {
          "file": "lib/presentation/widgets/capture_plan/capture_budget_summary.dart",
          "line": 268,
          "anchor": "'File size basis'",
          "sha256": "f057414242a6c1ce77e32dd3ef9dbe23411be1b5e05562c23bbcb86aa8513f78"
        },
        {
          "file": "lib/presentation/shared/hybrid_parts.dart",
          "line": 53,
          "anchor": "class HybridFact",
          "sha256": "b708b26d4e81e2dea90474583954a51a2b164e0cb4ace87cf83ece7d0e59641f"
        },
        {
          "file": "lib/presentation/shared/storage_text.dart",
          "line": 75,
          "anchor": "static String plan(",
          "sha256": "5d8e70127c54610f24715ccbcef771ff6e7f04313dbbe8153dc38c35c8e886ca"
        }
      ],
      "acceptance_criteria": [
        "Compare actual current and proposed Flutter375/412/320dp states in all3themes at100% with unchanged text/data.",
        "Unknown, measured, theoretical, conflict and multi-block source prose remains complete, associated with File size basis and reachable by scrolling.",
        "Numeric budget rows, file/rig actions, Apply/Save and storage tests remain unchanged in meaning."
      ],
      "exclusions": [
        "No font/size/token changes",
        "No astronomy/storage calculation change",
        "No global fact-row normalization",
        "No removal/shortening of source facts",
        "No implementation during this audit"
      ],
      "dependencies": [
        "Owner selects bounded local composition, then separately authorizes implementation.",
        "No C1 or global shared-component rewrite prerequisite."
      ],
      "conceptual_visual_ref": "conceptual-comparisons.md#b-file-size-prose",
      "owner_direction_ref": "owner-direction-20261026.json",
      "execution_in_current_audit": false,
      "selected_strategy": "B-FILE-PROSE",
      "owner_selection_status": "SELECTED_FUTURE_SCOPE",
      "future_scope_approved": true
    }
  ],
  "existing_optional_choices": [
    {
      "id": "W1/VQA-029",
      "original_category": "B optional composition choice; carried here for complete owner alternatives overview",
      "current_implementation": "Welcome ListView places Start planning after both optional setup sections. Current populated375 first viewport contains site and partial rig setup; lower viewport shows complete rig actions and Start planning. Optional steps and completion work; no defect is asserted.",
      "source_refs": [
        {
          "file": "lib/presentation/screens/welcome/welcome_screen.dart",
          "line": 102
        },
        {
          "file": "lib/presentation/screens/welcome/welcome_screen.dart",
          "line": 160
        }
      ],
      "alternatives": [
        {
          "id": "W1-KEEP",
          "proposal": "Retain current completion placement.",
          "benefit": "No extra footer/inset complexity."
        },
        {
          "id": "W1-FOOTER",
          "proposal": "Keep optional setup intact and show Start planning in a persistent completion footer.",
          "benefit": "Completion remains discoverable before scrolling through optional setup."
        },
        {
          "id": "W1-COPY",
          "proposal": "Retain button position and clarify the existing optional/skip guidance.",
          "benefit": "Smaller presentation change with less overlay/IME risk."
        }
      ],
      "reference_rationale": "Existing UI_REFERENCE_LIBRARY line103 records the choice and R2/mobile composition rationale. Current actual upper/lower images show current placement.15 Figma exports remain PARTIAL_INSPECTION and prove no responsive or prototype benefit.",
      "expected_user_benefit": "Potentially clearer permission to start planning without finishing optional setup; benefit remains a proposal, not measured usability evidence.",
      "implementation_implications": "Local Welcome footer/list inset only if selected; preserve completion/back persistence, optional rig/site actions, camera choice/metadata conditions and permission policy. Do not add a new onboarding step.",
      "accessibility_and_data_science_risks": "Footer may obscure lower actions or keyboard; preserve focus order,48dp targets, unrestricted text scaling and reachable complete explanations. Do not imply site/rig are mandatory or change scientific defaults.",
      "proposed_after_available": false,
      "decision_required": "Deferred by owner2026-10-26; no comparison or implementation now.",
      "category": "B",
      "origin": "EXISTING_OPTIONAL_NOT_NEW_CONFIRMED_FINDING",
      "new_finding": false,
      "implementation_ready": false,
      "implementation_authorized": false,
      "owner_acceptance": false,
      "after_evidence": null,
      "risk_level": "Low-Medium",
      "dependencies": [
        "Explicit independent owner selection; no prerequisite for confirmed A/B fixes."
      ],
      "conceptual_visual_ref": "conceptual-comparisons.md#w1-welcome-completion",
      "current_images": [
        {
          "path": ".audit/evidence/host/baseline-375/welcome-light-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/welcome-light-1.png",
          "sha256": "8a072c52014a290c1cc2802c8fe9c8f74c580d23822e6fcb49445a60367bd70c",
          "role": "CURRENT_ACTUAL_NOT_AFTER"
        },
        {
          "path": ".audit/evidence/host/baseline-375/welcome-dark-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/welcome-dark-1.png",
          "sha256": "9f7f06fae84d3359167dea1e9a2b5902c06eefe6966e97df72206ad74bfebb42",
          "role": "CURRENT_ACTUAL_NOT_AFTER"
        },
        {
          "path": ".audit/evidence/host/baseline-375/welcome-field-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/welcome-field-1.png",
          "sha256": "9ce30cffa4f9210e20d3bd3d37a2b3b7ae7744b67230066a5f8a7a886635720b",
          "role": "CURRENT_ACTUAL_NOT_AFTER"
        },
        {
          "path": ".audit/evidence/host/baseline-375/welcome_b-light-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/welcome_b-light-1.png",
          "sha256": "39b9c90cf68e71a71e85e19cf546a3e89a2feab38056db256aa559660faad6d6",
          "role": "CURRENT_ACTUAL_NOT_AFTER"
        },
        {
          "path": ".audit/evidence/host/baseline-375/welcome_b-dark-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/welcome_b-dark-1.png",
          "sha256": "b74cda9dedf172496fe146249dbeafb61aecdd9f11e67f90173160ca639902c1",
          "role": "CURRENT_ACTUAL_NOT_AFTER"
        },
        {
          "path": ".audit/evidence/host/baseline-375/welcome_b-field-1.png",
          "absolute_path": ".audit/evidence/host/baseline-375/welcome_b-field-1.png",
          "sha256": "7310179bf371d3e85c6d054ea5b567fc8572bf69752656795bd974a53651f602",
          "role": "CURRENT_ACTUAL_NOT_AFTER"
        }
      ],
      "impact": "Potential completion discoverability; unmeasured benefit",
      "acceptance_criteria": [
        "Compare current/proposed empty and populated optional setup at375/320/412and100%all themes.",
        "Keep optional site/rig choices, completion/Back persistence and permission-on-tap.",
        "If footer selected, verify list/IME insets, focus order, reachable full lower controls and48dp targets; no new onboarding step."
      ],
      "exclusions": [
        "No new confirmedUIA, mandatory setup or new onboarding sequence."
      ],
      "owner_disposition": "DEFERRED_BY_OWNER"
    }
  ],
  "recommendation": "Implement only in later bounded task; B11 direction selected. B10 first requires actual comparison and complexity assessment. W1 deferred.",
  "final_coordinator_review_ref": "../reviews/library/convergence/final-package-review.json",
  "finalized_utc": "2026-10-25T22:40:20.745939+00:00",
  "owner_direction_ref": "owner-direction-20261026.json",
  "future_scope_decision_recorded": true,
  "implementation_in_this_audit_authorized": false,
  "implementation_started": false,
  "updated_utc": "2026-10-25T23:08:39.467865+00:00",
  "owner_acceptance_scope": "Directions/deferrals recorded separately; owner_acceptance=false denotes unperformed visual/product acceptance."
}
```
