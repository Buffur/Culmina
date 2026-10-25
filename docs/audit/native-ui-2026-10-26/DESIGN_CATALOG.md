# DESIGN_CATALOG

Text-only audit register exported from local `.audit/reports/design_completeness.json`. Original SHA-256: `459fe6f9a6b4aaa89d697e4cf3e06e341734b4cc5288e72789487b44ab781f44`. Private evidence references identify local artifacts; no raw capture, device identifier, binary or executable probe is published. User-profile paths are redacted. Original canonical bytes remain unchanged.

```json
{
  "status": "FINAL_BOUNDED_DESIGN_COMPLETENESS_AMENDMENT_PARTIAL_WITH_ATTENTION",
  "updated_utc": "2026-10-25T23:14:51.085481+00:00",
  "source_sha": "8157dcc275f1349f299e411c611888daafc035a0",
  "source_inputs": 765,
  "input_fingerprint": "e5963d808fb8e194b1c02e7de985bbd861665b41d94a653e8ae70d1197ebdcee",
  "scope": "Eight design dimensions on existing valid actual Flutter frames; no new captures/runtime/prototypes/implementation.",
  "prior_independent_review_conclusion": "Earlier11-family composition report synthesizes specialist reviewbooks; it is not a fresh independent second opinion for every main screen, every normal/lower view or every dimension. Source/tests/image counts are not visual-quality acceptance.",
  "current_independent_review_conclusion": "Two cross-family peers add new design judgments for Planning/Library and Conditions/Settings/Startup. Original Library specialist provides labelled second look for18source owners; coordinator independently crosschecks12named main compositions/17frames. No claim that every main/child screen has two independent complete reviews.",
  "review_record_count": 49,
  "dimension_judgments": 392,
  "unit_count_limit": "49 review records include main, child, conditional, modal and component-only presentations, with some shared source; they are not49 unique complete screens. Root12 units overlap and are not added to49.",
  "dimensions": [
    "hierarchy",
    "vertical_rhythm",
    "composition",
    "density",
    "grouping",
    "redundant_frames",
    "typography_consistency",
    "professional_quality"
  ],
  "records": [
    {
      "id": "DPL-01",
      "name": "Tonight",
      "families": [
        "F01"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_COMPOSITION",
      "source_refs": [
        {
          "surface_id": "TON-001",
          "widget_class": "TonightHomeScreen",
          "file": "lib/presentation/screens/tonight/tonight_home_screen.dart",
          "line": 49,
          "sha256": "331c740c307a7a9d57b0c73913380097f802a7edc2c91dd0db7acfe3060a5888",
          "anchor": "class TonightHomeScreen"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0064",
          "path": "evidence/host/baseline-375/home-light-1.png",
          "sha256": "c00ef22cc390549cad560a3694d299633bcb9977d0f6903a3165c0fd34c60d8b",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0088",
          "path": "evidence/host/baseline-375/home_timeline-light-1.png",
          "sha256": "7d16d6be71be690f08865acccc4393d76ee81b0487b662a3bd0ef719e886e3d0",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0062",
          "path": "evidence/host/baseline-375/home-dark-1.png",
          "sha256": "8eadd4bfa4390ff5666bf16d64eb7ac4f5b39fcf2f1463556226319b80fd940b",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Dated heading leads to Your plan, target, Fits/reason and one Open planner action before secondary night information.",
          "evidence_ids": [
            "EVD-0064",
            "EVD-0088",
            "EVD-0062"
          ],
          "whole_screen_pass_claim": false
        },
        "vertical_rhythm": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "20dp outer edges and repeated group gaps align plan, timeline and lower conditions.",
          "evidence_ids": [
            "EVD-0064",
            "EVD-0088",
            "EVD-0062"
          ],
          "whole_screen_pass_claim": false
        },
        "composition": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Plan, night information and next action have distinct places; the preview remains inside its night group.",
          "evidence_ids": [
            "EVD-0064",
            "EVD-0088",
            "EVD-0062"
          ],
          "whole_screen_pass_claim": false
        },
        "density": {
          "verdict": "PURPOSEFUL_TRADEOFF_OBSERVED",
          "observation": "First viewport prioritizes the plan and starts The night ahead; scrolling for details is a purposeful answer-first tradeoff.",
          "evidence_ids": [
            "EVD-0064",
            "EVD-0088",
            "EVD-0062"
          ],
          "whole_screen_pass_claim": false
        },
        "grouping": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Saved status stays with the plan; Night/Moon/Weather share a reading group; candidates is a next action.",
          "evidence_ids": [
            "EVD-0064",
            "EVD-0088",
            "EVD-0062"
          ],
          "whole_screen_pass_claim": false
        },
        "redundant_frames": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Two task surfaces and lower rules avoid a card around every fact; boundary outlines identify controls.",
          "evidence_ids": [
            "EVD-0064",
            "EVD-0088",
            "EVD-0062"
          ],
          "whole_screen_pass_claim": false
        },
        "typography_consistency": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Named Geist Home heading, target, value and caption roles form visible levels, rather than a font-family change.",
          "evidence_ids": [
            "EVD-0064",
            "EVD-0088",
            "EVD-0062"
          ],
          "whole_screen_pass_claim": false
        },
        "professional_quality": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Light/Dark saved-plan views are restrained and aligned; normal coherence does not close changed-working-plan wording.",
          "evidence_ids": [
            "EVD-0064",
            "EVD-0088",
            "EVD-0062"
          ],
          "whole_screen_pass_claim": false
        }
      },
      "limits": [
        "Saved synthetic M31 top/lower only; no complete no-site, changed-draft, due-result or all-theme acceptance."
      ],
      "disposition": "NO_NEW_SUBSTANTIAL_FINDING_IN_VIEWED_COMPOSITION",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-planning-library/assessment.json"
    },
    {
      "id": "DPL-02",
      "name": "Candidates",
      "families": [
        "F01"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_COMPOSITION",
      "source_refs": [
        {
          "surface_id": "CAN-001",
          "widget_class": "TonightCandidatesScreen",
          "file": "lib/presentation/screens/tonight/tonight_candidates_screen.dart",
          "line": 35,
          "sha256": "2021d816d74a000427c2a2bce1f491e74ce9de5fc7f2c78c0949cbda173f0106",
          "anchor": "class TonightCandidatesScreen"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0070",
          "path": "evidence/host/baseline-375/home_candidates-light-1.png",
          "sha256": "cf854befaa2ebc8a8bfda362aeac7b15c37e67b91c3f9b6c961bff9b7d0fab22",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0025",
          "path": "evidence/host/baseline-375/candidates_b-light-1.png",
          "sha256": "8a4fc3e573cebd8ba02054511b1dc4449617dda0cf934f320d1a17b9dc466938",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-1062",
          "path": "reviews/planning/final-completion-audit/content-closure/candidates-normal-terminal-light.png",
          "sha256": "3397da0e10150dd3a090cbff0c5961e5f346d4e99971883bcc65c0f92a3bdb03",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Question/night/site/count/order precede filters and ranked rows, with a separate usable-duration column.",
          "evidence_ids": [
            "EVD-0070",
            "EVD-0025",
            "EVD-1062"
          ],
          "whole_screen_pass_claim": false
        },
        "vertical_rhythm": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Question, filter and joined result groups have predictable gaps; multiline scientific facts do not collide with durations.",
          "evidence_ids": [
            "EVD-0070",
            "EVD-0025",
            "EVD-1062"
          ],
          "whole_screen_pass_claim": false
        },
        "composition": {
          "verdict": "PURPOSEFUL_TRADEOFF_OBSERVED",
          "observation": "Context scrolls away in deep results; consistent row anatomy and the zone footer remain. No wrong-night effect was demonstrated.",
          "evidence_ids": [
            "EVD-0070",
            "EVD-0025",
            "EVD-1062"
          ],
          "whole_screen_pass_claim": false
        },
        "density": {
          "verdict": "PURPOSEFUL_TRADEOFF_OBSERVED",
          "observation": "First result starts near590dp, giving one full initial row. Readable context/filters trade against first-fold row count; this is not a new defect.",
          "evidence_ids": [
            "EVD-0070",
            "EVD-0025",
            "EVD-1062"
          ],
          "whole_screen_pass_claim": false
        },
        "grouping": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Sorting/type and independent filters share one controls group; results form a continuous ranked document.",
          "evidence_ids": [
            "EVD-0070",
            "EVD-0025",
            "EVD-1062"
          ],
          "whole_screen_pass_claim": false
        },
        "redundant_frames": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Question, filters and results serve different jobs; repeated durations are per-target facts rather than decoration.",
          "evidence_ids": [
            "EVD-0070",
            "EVD-0025",
            "EVD-1062"
          ],
          "whole_screen_pass_claim": false
        },
        "typography_consistency": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Question is prominent; names, compact Moon/window metadata and durations remain distinguishable in top/middle/terminal views.",
          "evidence_ids": [
            "EVD-0070",
            "EVD-0025",
            "EVD-1062"
          ],
          "whole_screen_pass_claim": false
        },
        "professional_quality": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "The list is a precise specialist tool. A denser header or sticky context would require future comparison, not a confirmed issue here.",
          "evidence_ids": [
            "EVD-0070",
            "EVD-0025",
            "EVD-1062"
          ],
          "whole_screen_pass_claim": false
        }
      },
      "limits": [
        "One calculated result set at375 Light, top/middle/terminal; no all-filter, enlarged-type or per-theme completeness."
      ],
      "disposition": "NO_NEW_SUBSTANTIAL_FINDING_IN_VIEWED_COMPOSITION",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-planning-library/assessment.json"
    },
    {
      "id": "DPL-03",
      "name": "Plan main route and composition",
      "families": [
        "F02"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_COMPOSITION",
      "source_refs": [
        {
          "surface_id": "PLN-002",
          "widget_class": "HomeScreen",
          "file": "lib/presentation/screens/home/home_screen.dart",
          "line": 54,
          "sha256": "259fcb4ea15da74aae27b226a72290193e9cbebba502477a1f6996d6e9aa5aef",
          "anchor": "class HomeScreen"
        },
        {
          "surface_id": "PLN-001",
          "widget_class": "SessionPlannerRoute",
          "file": "lib/presentation/screens/home/session_planner_route.dart",
          "line": 22,
          "sha256": "3dde067322f419729a2d6856da448cad83c95cdc95a144c1bb2eefd657afefee",
          "anchor": "class SessionPlannerRoute"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0232",
          "path": "evidence/host/baseline-375/plan-light-1.png",
          "sha256": "0e5161d516a68ab0b6e07edf18457b311ed9814cdfcd269493cb1afb08220a34",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0244",
          "path": "evidence/host/baseline-375/plan_b-light-1.png",
          "sha256": "cf5fbc8804df2a7222bd75cb5198ca4f0c4e6275003a3fd4c3d68a17dd99ae7c",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0256",
          "path": "evidence/host/baseline-375/plan_c-light-1.png",
          "sha256": "c66e40a626cb28b9f50c9c5511253c602027bbc71df1f0da68c4bc5b960c1e2e",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0231",
          "path": "evidence/host/baseline-375/plan-field-1.png",
          "sha256": "c1f015eac893b4b4eabb7abb604af0c72f88c3f9d89e34dd9c054a92402c9263",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Night/Saved/Fits/reason lead, followed by context choices; persistent Save plan is stronger than navigation/disclosures.",
          "evidence_ids": [
            "EVD-0232",
            "EVD-0244",
            "EVD-0256",
            "EVD-0231"
          ],
          "whole_screen_pass_claim": false
        },
        "vertical_rhythm": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Status, context, capture/estimate and night groups repeat their spacing; the fixed action bar has a distinct boundary.",
          "evidence_ids": [
            "EVD-0232",
            "EVD-0244",
            "EVD-0256",
            "EVD-0231"
          ],
          "whole_screen_pass_claim": false
        },
        "composition": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Answer, inputs, capture plan, estimate and supporting conditions follow the planning task rather than a generic dashboard.",
          "evidence_ids": [
            "EVD-0232",
            "EVD-0244",
            "EVD-0256",
            "EVD-0231"
          ],
          "whole_screen_pass_claim": false
        },
        "density": {
          "verdict": "PURPOSEFUL_TRADEOFF_OBSERVED",
          "observation": "Answer and three context rows consume the first viewport; capture editing requires scrolling. No comparative improvement was demonstrated.",
          "evidence_ids": [
            "EVD-0232",
            "EVD-0244",
            "EVD-0256",
            "EVD-0231"
          ],
          "whole_screen_pass_claim": false
        },
        "grouping": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Context inputs share one group; Estimate owns its explanations; Night/Moon/Weather/Sky darkness form supporting context.",
          "evidence_ids": [
            "EVD-0232",
            "EVD-0244",
            "EVD-0256",
            "EVD-0231"
          ],
          "whole_screen_pass_claim": false
        },
        "redundant_frames": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Flat semantic groups avoid nested outlined fact cards; Save bar and field/button outlines have actual ownership.",
          "evidence_ids": [
            "EVD-0232",
            "EVD-0244",
            "EVD-0256",
            "EVD-0231"
          ],
          "whole_screen_pass_claim": false
        },
        "typography_consistency": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "App bar, Fits, headings, values and captions share Geist roles; the Field sample preserves their hierarchy.",
          "evidence_ids": [
            "EVD-0232",
            "EVD-0244",
            "EVD-0256",
            "EVD-0231"
          ],
          "whole_screen_pass_claim": false
        },
        "professional_quality": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Saved-plan top/lower views are orderly. Existing B11 prose and working-versus-stored wording remain separate attention items.",
          "evidence_ids": [
            "EVD-0232",
            "EVD-0244",
            "EVD-0256",
            "EVD-0231"
          ],
          "whole_screen_pass_claim": false
        }
      },
      "limits": [
        "PLN-001 readiness gate is included with this main layout, not another screen. One-block saved fixture; no all-state/all-theme acceptance."
      ],
      "disposition": "NO_NEW_SUBSTANTIAL_FINDING_IN_VIEWED_COMPOSITION",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-planning-library/assessment.json"
    },
    {
      "id": "DPL-04",
      "name": "Site and night chooser",
      "families": [
        "F02"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_COMPOSITION",
      "source_refs": [
        {
          "surface_id": "PLN-007",
          "widget_class": "PlanContextScreen",
          "file": "lib/presentation/screens/home/plan_context_screen.dart",
          "line": 29,
          "sha256": "e62b34430a36f55aaece89ec35d17c71cf0d19577f10c21506c2f48e5d5d4964",
          "anchor": "class PlanContextScreen"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0265",
          "path": "evidence/host/baseline-375/plan_context-light-1.png",
          "sha256": "41fd920562cf37904201bd3e7e16234b4dbef12aafc7cf8bf12433b6dfb3c7dd",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Observing site precedes Night; fixed Apply changes states draft versus Save-plan ownership.",
          "evidence_ids": [
            "EVD-0265"
          ],
          "whole_screen_pass_claim": false
        },
        "vertical_rhythm": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Two choices have consistent outer margins; radio, management action and explanatory copy have readable internal gaps.",
          "evidence_ids": [
            "EVD-0265"
          ],
          "whole_screen_pass_claim": false
        },
        "composition": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "A short staged task has explicit Close and Apply positions; site and night are not conflated.",
          "evidence_ids": [
            "EVD-0265"
          ],
          "whole_screen_pass_claim": false
        },
        "density": {
          "verdict": "PURPOSEFUL_TRADEOFF_OBSERVED",
          "observation": "Unused lower space comes from one site and a short task; filling it would add no demonstrated value.",
          "evidence_ids": [
            "EVD-0265"
          ],
          "whole_screen_pass_claim": false
        },
        "grouping": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Site selection/management are together; night selector, zone and copy warning stay together.",
          "evidence_ids": [
            "EVD-0265"
          ],
          "whole_screen_pass_claim": false
        },
        "redundant_frames": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Two surfaces represent two choices; only the actual selector adds an inner control outline.",
          "evidence_ids": [
            "EVD-0265"
          ],
          "whole_screen_pass_claim": false
        },
        "typography_consistency": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Page title, site name, labels and zone explanation follow the same staged-chooser role hierarchy.",
          "evidence_ids": [
            "EVD-0265"
          ],
          "whole_screen_pass_claim": false
        },
        "professional_quality": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "The complete short form is composed and restrained, with a stable action footer.",
          "evidence_ids": [
            "EVD-0265"
          ],
          "whole_screen_pass_claim": false
        }
      },
      "limits": [
        "One-site whole body/footer at375 Light; no long/many-site list or open-calendar design coverage."
      ],
      "disposition": "NO_NEW_SUBSTANTIAL_FINDING_IN_VIEWED_COMPOSITION",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-planning-library/assessment.json"
    },
    {
      "id": "DPL-05",
      "name": "Plan target chooser",
      "families": [
        "F02"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_COMPOSITION",
      "source_refs": [
        {
          "surface_id": "PLN-009",
          "widget_class": "PlanTargetScreen",
          "file": "lib/presentation/screens/home/plan_target_screen.dart",
          "line": 26,
          "sha256": "17f167fd21a97e135e6f89127b91724d12955cc80dfa94948b2247acbbdb48c3",
          "anchor": "class PlanTargetScreen"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0301",
          "path": "evidence/host/baseline-375/plan_target-light-1.png",
          "sha256": "0aea20d2bbb1662dfc97c064164ba7890a4df27d71e434e4866f62effd7f974b",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Search and current collection/selection context precede radio choices and the fixed Apply action.",
          "evidence_ids": [
            "EVD-0301"
          ],
          "whole_screen_pass_claim": false
        },
        "vertical_rhythm": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Search/context group and joined choice rows use consistent insets and rules around multiline names/aliases.",
          "evidence_ids": [
            "EVD-0301"
          ],
          "whole_screen_pass_claim": false
        },
        "composition": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Current selected M31 is named above the catalogue, even when its row is outside the initial viewport.",
          "evidence_ids": [
            "EVD-0301"
          ],
          "whole_screen_pass_claim": false
        },
        "density": {
          "verdict": "PURPOSEFUL_TRADEOFF_OBSERVED",
          "observation": "Context lowers initial result count; total collection and filtered-result counts have different roles despite matching here.",
          "evidence_ids": [
            "EVD-0301"
          ],
          "whole_screen_pass_claim": false
        },
        "grouping": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Query/context and choices are separate; aliases remain attached to their target.",
          "evidence_ids": [
            "EVD-0301"
          ],
          "whole_screen_pass_claim": false
        },
        "redundant_frames": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Search and choice surfaces have separate jobs; individual aliases are not separately framed.",
          "evidence_ids": [
            "EVD-0301"
          ],
          "whole_screen_pass_claim": false
        },
        "typography_consistency": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Target names are stronger than types/aliases, matching other chooser label/value distinctions.",
          "evidence_ids": [
            "EVD-0301"
          ],
          "whole_screen_pass_claim": false
        },
        "professional_quality": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "The initial populated chooser is clean, but cannot establish every terminal or long-name layout.",
          "evidence_ids": [
            "EVD-0301"
          ],
          "whole_screen_pass_claim": false
        }
      },
      "limits": [
        "Only initial164-result viewport/footer opened; full lower catalogue and arbitrary long result names remain unreviewed."
      ],
      "disposition": "NO_NEW_SUBSTANTIAL_FINDING_IN_VIEWED_COMPOSITION",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-planning-library/assessment.json"
    },
    {
      "id": "DPL-06",
      "name": "Plan rig chooser",
      "families": [
        "F02"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_COMPOSITION",
      "source_refs": [
        {
          "surface_id": "PLN-010",
          "widget_class": "PlanRigScreen",
          "file": "lib/presentation/screens/home/plan_rig_screen.dart",
          "line": 28,
          "sha256": "1b372ab3da0e3022bc729e8d4d816879889896c8ec8bf5a4e2d140dfc1dd5fc3",
          "anchor": "class PlanRigScreen"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0286",
          "path": "evidence/host/baseline-375/plan_rig-light-1.png",
          "sha256": "01ef27ad7d757dd7f5594dfd2f5df4a00ebea93e5cc972f27c53056cc407ffb6",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Choice label, selected name, camera summary, consequence text and management link precede Apply.",
          "evidence_ids": [
            "EVD-0286"
          ],
          "whole_screen_pass_claim": false
        },
        "vertical_rhythm": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Radio row, separator, explanation and link have consistent breathing room above the detached footer.",
          "evidence_ids": [
            "EVD-0286"
          ],
          "whole_screen_pass_claim": false
        },
        "composition": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Full one-rig choice fits as a short staged task, with camera/tracking context visible before application.",
          "evidence_ids": [
            "EVD-0286"
          ],
          "whole_screen_pass_claim": false
        },
        "density": {
          "verdict": "PURPOSEFUL_TRADEOFF_OBSERVED",
          "observation": "Large lower blank area reflects a short collection; compacting or adding filler has no demonstrated benefit.",
          "evidence_ids": [
            "EVD-0286"
          ],
          "whole_screen_pass_claim": false
        },
        "grouping": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Rig identity and behavior/management context share one choice group; draft ownership is in the footer.",
          "evidence_ids": [
            "EVD-0286"
          ],
          "whole_screen_pass_claim": false
        },
        "redundant_frames": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "One document surface and one footer are sufficient, without nested content frames.",
          "evidence_ids": [
            "EVD-0286"
          ],
          "whole_screen_pass_claim": false
        },
        "typography_consistency": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Selected name is stronger than camera/tracking metadata in the common Geist hierarchy.",
          "evidence_ids": [
            "EVD-0286"
          ],
          "whole_screen_pass_claim": false
        },
        "professional_quality": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "The sparse normal chooser is orderly; content length is not an aesthetic defect.",
          "evidence_ids": [
            "EVD-0286"
          ],
          "whole_screen_pass_claim": false
        }
      },
      "limits": [
        "One-rig normal Light375 whole body; no multi-rig lower list, empty redirect or error-state review."
      ],
      "disposition": "NO_NEW_SUBSTANTIAL_FINDING_IN_VIEWED_COMPOSITION",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-planning-library/assessment.json"
    },
    {
      "id": "DPL-07",
      "name": "Embedded capture plan and block actions",
      "families": [
        "F03"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_COMPOSITION",
      "source_refs": [
        {
          "surface_id": "CAP-001",
          "widget_class": "CapturePlanWidget / _BlockList",
          "file": "lib/presentation/widgets/capture_plan_widget.dart",
          "line": 41,
          "sha256": "452406f69127c2e5678f9265e5c9f45fd0d7c366dd6c57b02aa83fd7b597d782",
          "anchor": "class CapturePlanWidget"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0587",
          "path": "evidence/android/fixture-plan-capture-section-dark-100.png",
          "sha256": "58bccfd1af33a203ab9cdca801d840be52db4a9848e0985bec42e8998ec02c8c",
          "evidence_layer": "NATIVE_VERIFIED"
        },
        {
          "evidence_id": "EVD-0235",
          "path": "evidence/host/baseline-375/plan_actions-light-1.png",
          "sha256": "e6123718323e5f12ff5e7705d59842bd5da86698801f955e708be9c894f63204",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Heading/count lead to block identity, integration, records and warnings; block/list actions follow their facts.",
          "evidence_ids": [
            "EVD-0587",
            "EVD-0235"
          ],
          "whole_screen_pass_claim": false
        },
        "vertical_rhythm": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Whole-block native view and host lower actions show separation between facts, remedy, actions and Estimate.",
          "evidence_ids": [
            "EVD-0587",
            "EVD-0235"
          ],
          "whole_screen_pass_claim": false
        },
        "composition": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Edit/remove/move belong to the block; Add/calibration/fill belong to the list; Save plan remains global.",
          "evidence_ids": [
            "EVD-0587",
            "EVD-0235"
          ],
          "whole_screen_pass_claim": false
        },
        "density": {
          "verdict": "PURPOSEFUL_TRADEOFF_OBSERVED",
          "observation": "Tracking-unrecorded warning and several actions add height but preserve real capture choices and remedies.",
          "evidence_ids": [
            "EVD-0587",
            "EVD-0235"
          ],
          "whole_screen_pass_claim": false
        },
        "grouping": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Block facts/actions share a group; Estimate starts separately; CapturePlanWidget does not duplicate the planner heading.",
          "evidence_ids": [
            "EVD-0587",
            "EVD-0235"
          ],
          "whole_screen_pass_claim": false
        },
        "redundant_frames": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Outlined Edit/Add/calibration/fill controls are functional affordances, not decorative nested cards.",
          "evidence_ids": [
            "EVD-0587",
            "EVD-0235"
          ],
          "whole_screen_pass_claim": false
        },
        "typography_consistency": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Block title/integration are stronger than records/warnings, retaining units in host and native views.",
          "evidence_ids": [
            "EVD-0587",
            "EVD-0235"
          ],
          "whole_screen_pass_claim": false
        },
        "professional_quality": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "The one-block state is detailed but controlled. Action count and warning height are purposeful, not unsupported card redundancy.",
          "evidence_ids": [
            "EVD-0587",
            "EVD-0235"
          ],
          "whole_screen_pass_claim": false
        }
      },
      "limits": [
        "Existing bounded native synthetic-companion Dark supplement plus Light host lower actions; not new canonical/device acceptance. No multi-block/mixed-calibration composition review."
      ],
      "disposition": "NO_NEW_SUBSTANTIAL_FINDING_IN_VIEWED_COMPOSITION",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-planning-library/assessment.json"
    },
    {
      "id": "DPL-08",
      "name": "Full-screen Add/Edit block",
      "families": [
        "F03"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_COMPOSITION",
      "source_refs": [
        {
          "surface_id": "CAP-006",
          "widget_class": "_CaptureBlockDialog",
          "file": "lib/presentation/widgets/capture_plan/capture_block_dialog.dart",
          "line": 89,
          "sha256": "bbcc564f96d01c0b87177847d00d275d0c09bc7a47a22d026e88e5450ce84e9c",
          "anchor": "class _CaptureBlockDialog"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0268",
          "path": "evidence/host/baseline-375/plan_editor-light-1.png",
          "sha256": "c7213ed23e78e958613e542a64b999429ba6b5ab19b12a90d7dba60cd3a82169",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0271",
          "path": "evidence/host/baseline-375/plan_editor_bottom-light-1.png",
          "sha256": "7efb143d5343e716d0896b1000f3ed89a45e0c70dfb8ef39b806147db194d428",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Rig/frame type lead, then exposure/count/live integration, filter/ISO and optional records/details.",
          "evidence_ids": [
            "EVD-0268",
            "EVD-0271"
          ],
          "whole_screen_pass_claim": false
        },
        "vertical_rhythm": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Labels, fields and short hints repeat consistently; lower white-balance/focus and Details groups have matching gaps.",
          "evidence_ids": [
            "EVD-0268",
            "EVD-0271"
          ],
          "whole_screen_pass_claim": false
        },
        "composition": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Close/header and Apply footer frame a task; primary capture values are separated from optional camera records.",
          "evidence_ids": [
            "EVD-0268",
            "EVD-0271"
          ],
          "whole_screen_pass_claim": false
        },
        "density": {
          "verdict": "PURPOSEFUL_TRADEOFF_OBSERVED",
          "observation": "Two rows of frame-type choices and scrolling lower records preserve readable controls instead of squeezing the form.",
          "evidence_ids": [
            "EVD-0268",
            "EVD-0271"
          ],
          "whole_screen_pass_claim": false
        },
        "grouping": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Frame context, capture values, white-balance/focus and timing details are distinct editing jobs.",
          "evidence_ids": [
            "EVD-0268",
            "EVD-0271"
          ],
          "whole_screen_pass_claim": false
        },
        "redundant_frames": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Document groups organize tasks; outlined fields and single-choice segments are actual control boundaries.",
          "evidence_ids": [
            "EVD-0268",
            "EVD-0271"
          ],
          "whole_screen_pass_claim": false
        },
        "typography_consistency": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Labels, numbers, hints and optional choices use one family and a predictable role scale.",
          "evidence_ids": [
            "EVD-0268",
            "EVD-0271"
          ],
          "whole_screen_pass_claim": false
        },
        "professional_quality": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Normal editor top/lower are clean and legible; this does not prove IME/errors or all camera-class branches.",
          "evidence_ids": [
            "EVD-0268",
            "EVD-0271"
          ],
          "whole_screen_pass_claim": false
        }
      },
      "limits": [
        "DSLR Light top/lower100% only; phone/astro/unknown, photo-review/calibration variants and native IME remain separate."
      ],
      "disposition": "NO_NEW_SUBSTANTIAL_FINDING_IN_VIEWED_COMPOSITION",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-planning-library/assessment.json"
    },
    {
      "id": "DPL-09",
      "name": "Calibration builder",
      "families": [
        "F03"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_COMPOSITION",
      "source_refs": [
        {
          "surface_id": "CAP-020",
          "widget_class": "_CalibrationPreview",
          "file": "lib/presentation/widgets/capture_plan/calibration_preview_dialog.dart",
          "line": 42,
          "sha256": "f86fa3e5474e5a6a6511556edcd0887165ffcd57c837828733696b847d52f075",
          "anchor": "class _CalibrationPreview"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0259",
          "path": "evidence/host/baseline-375/plan_cal-light-1.png",
          "sha256": "faf1a24b2b328cfd955427531c25a2ea99ae3f96cc0caa19e1d38adf7899119c",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0262",
          "path": "evidence/host/baseline-375/plan_cal_b-light-1.png",
          "sha256": "bd0df1786e30ad5b40f18472e1ffd8aca67213729310503445e24eafbcec0fee",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Proposal/reference explanation leads to Dark/Flat/Bias groups, with Add selected frames as the bottom action.",
          "evidence_ids": [
            "EVD-0259",
            "EVD-0262"
          ],
          "whole_screen_pass_claim": false
        },
        "vertical_rhythm": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Type label, check row, count/exposure and source notes repeat predictably through the lower viewport.",
          "evidence_ids": [
            "EVD-0259",
            "EVD-0262"
          ],
          "whole_screen_pass_claim": false
        },
        "composition": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Light-source identity precedes proposals; lower prose distinguishes session time/storage from integration.",
          "evidence_ids": [
            "EVD-0259",
            "EVD-0262"
          ],
          "whole_screen_pass_claim": false
        },
        "density": {
          "verdict": "PURPOSEFUL_TRADEOFF_OBSERVED",
          "observation": "Per-type fields lengthen the form but preserve independent inclusion and matching provenance.",
          "evidence_ids": [
            "EVD-0259",
            "EVD-0262"
          ],
          "whole_screen_pass_claim": false
        },
        "grouping": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Each calibration type is a distinct editable proposal; shared reference context is separated.",
          "evidence_ids": [
            "EVD-0259",
            "EVD-0262"
          ],
          "whole_screen_pass_claim": false
        },
        "redundant_frames": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Flat surfaces and internal rules organize the form without another decorative border around every input.",
          "evidence_ids": [
            "EVD-0259",
            "EVD-0262"
          ],
          "whole_screen_pass_claim": false
        },
        "typography_consistency": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Type/field labels, values and timing/source notes use the block-editor family and role hierarchy.",
          "evidence_ids": [
            "EVD-0259",
            "EVD-0262"
          ],
          "whole_screen_pass_claim": false
        },
        "professional_quality": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Normal100% form is composed. Accepted future A15's recorded native IME/footer condition remains a separate implementation item.",
          "evidence_ids": [
            "EVD-0259",
            "EVD-0262"
          ],
          "whole_screen_pass_claim": false
        }
      },
      "limits": [
        "Normal Light proposal top/lower; no matched dark-flat/multiple-Light groups or new active-IME review. No A15 After/implementation."
      ],
      "disposition": "NO_NEW_SUBSTANTIAL_FINDING_IN_VIEWED_COMPOSITION",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-planning-library/assessment.json"
    },
    {
      "id": "DPL-10",
      "name": "Estimate, budget and stacking-gain details",
      "families": [
        "F03"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_COMPOSITION",
      "source_refs": [
        {
          "surface_id": "CAP-023",
          "widget_class": "CaptureBudgetSummary",
          "file": "lib/presentation/widgets/capture_plan/capture_budget_summary.dart",
          "line": 36,
          "sha256": "f057414242a6c1ce77e32dd3ef9dbe23411be1b5e05562c23bbcb86aa8513f78",
          "anchor": "class CaptureBudgetSummary"
        },
        {
          "surface_id": "CAP-024",
          "widget_class": "CollapsibleSection / CaptureBudgetSummary",
          "file": "lib/presentation/widgets/capture_plan/capture_budget_summary.dart",
          "line": 194,
          "sha256": "f057414242a6c1ce77e32dd3ef9dbe23411be1b5e05562c23bbcb86aa8513f78",
          "anchor": "key: const Key('capturePlan.assumptions')"
        },
        {
          "surface_id": "CAP-025",
          "widget_class": "CollapsibleSection / _GainTable",
          "file": "lib/presentation/widgets/capture_plan/capture_budget_summary.dart",
          "line": 311,
          "sha256": "f057414242a6c1ce77e32dd3ef9dbe23411be1b5e05562c23bbcb86aa8513f78",
          "anchor": "key: const Key('capturePlan.gainDetails')"
        },
        {
          "surface_id": "CAP-026",
          "widget_class": "StackingGainGraph",
          "file": "lib/presentation/widgets/capture_plan/stacking_gain_graph.dart",
          "line": 23,
          "sha256": "8827d2fe3d1b41923dfb1629ca1911b0448449ceea8f6caed7c0e2fd779fb0db",
          "anchor": "class StackingGainGraph"
        },
        {
          "surface_id": "CAP-027",
          "widget_class": "CaptureAssumptionsPanel",
          "file": "lib/presentation/widgets/capture_plan/capture_assumptions_panel.dart",
          "line": 29,
          "sha256": "ff0b5f9dc4714a62e25d2a5ba5092e5a14ab8c29655eee1d595394dbca460ea9",
          "anchor": "class CaptureAssumptionsPanel"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0244",
          "path": "evidence/host/baseline-375/plan_b-light-1.png",
          "sha256": "cf5fbc8804df2a7222bd75cb5198ca4f0c4e6275003a3fd4c3d68a17dd99ae7c",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0250",
          "path": "evidence/host/baseline-375/plan_budget_facts-light-1.png",
          "sha256": "658ebabd6dc1975d00bf94bbc609d466672119308b77724a28b8afcf71852806",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0247",
          "path": "evidence/host/baseline-375/plan_budget_assumptions-light-1.png",
          "sha256": "39f6cb769b61c38e22d4213e84dbb0b309d238b2b560bc57a2bbe4dba737ab34",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0253",
          "path": "evidence/host/baseline-375/plan_budget_notes-light-1.png",
          "sha256": "9eb9b21a0ce76e66555a9218c727035fc1ca46f0ffd3fc0c4b4090101f847a99",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0280",
          "path": "evidence/host/baseline-375/plan_gain_open-light-1.png",
          "sha256": "3508338918d9076611dbea928698e6b55bf5c5b97f68014e638e2a517b86cb80",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Two-column Integration/session/storage/gain overview and named disclosures scan clearly; File size basis is the local exception.",
          "evidence_ids": [
            "EVD-0244",
            "EVD-0250",
            "EVD-0247",
            "EVD-0253",
            "EVD-0280"
          ],
          "whole_screen_pass_claim": false
        },
        "vertical_rhythm": {
          "verdict": "KNOWN_EXISTING_B11_CONCERN",
          "observation": "The narrow right-aligned File size basis paragraph creates a tall run that interrupts concise fact rhythm.",
          "evidence_ids": [
            "EVD-0244",
            "EVD-0250",
            "EVD-0247",
            "EVD-0253",
            "EVD-0280"
          ],
          "whole_screen_pass_claim": false
        },
        "composition": {
          "verdict": "KNOWN_EXISTING_B11_CONCERN",
          "observation": "Numeric label/value anatomy suits most rows, but forces multi-sentence recovery/source prose into the numeric lane.",
          "evidence_ids": [
            "EVD-0244",
            "EVD-0250",
            "EVD-0247",
            "EVD-0253",
            "EVD-0280"
          ],
          "whole_screen_pass_claim": false
        },
        "density": {
          "verdict": "KNOWN_EXISTING_B11_CONCERN",
          "observation": "Actual prose has roughly143.5dp width/eight short lines. Remaining detail and the graph are deliberate specialist density.",
          "evidence_ids": [
            "EVD-0244",
            "EVD-0250",
            "EVD-0247",
            "EVD-0253",
            "EVD-0280"
          ],
          "whole_screen_pass_claim": false
        },
        "grouping": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Estimate, assumptions, gain and rig details have clear ownership; reminders remain with the relevant budget.",
          "evidence_ids": [
            "EVD-0244",
            "EVD-0250",
            "EVD-0247",
            "EVD-0253",
            "EVD-0280"
          ],
          "whole_screen_pass_claim": false
        },
        "redundant_frames": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Rules, facts, table and graph stay within their document group; no separate card is needed for every row/legend.",
          "evidence_ids": [
            "EVD-0244",
            "EVD-0250",
            "EVD-0247",
            "EVD-0253",
            "EVD-0280"
          ],
          "whole_screen_pass_claim": false
        },
        "typography_consistency": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Geist and tabular values are consistent; B11 concerns prose width/alignment, not font-family mismatch or absolute-SNR wording.",
          "evidence_ids": [
            "EVD-0244",
            "EVD-0250",
            "EVD-0247",
            "EVD-0253",
            "EVD-0280"
          ],
          "whole_screen_pass_claim": false
        },
        "professional_quality": {
          "verdict": "KNOWN_EXISTING_B11_CONCERN",
          "observation": "Overview/graph are controlled; the narrow explanatory paragraph is less resolved than surrounding facts, independently supporting existing B11.",
          "evidence_ids": [
            "EVD-0244",
            "EVD-0250",
            "EVD-0247",
            "EVD-0253",
            "EVD-0280"
          ],
          "whole_screen_pass_claim": false
        }
      },
      "limits": [
        "Existing owner-selected B11 only, no new finding or After. Single comparable Light group/unknown file basis; conflicts, filenames, multi-group and all-theme variants not reviewed."
      ],
      "disposition": "EXISTING_B11_ONLY",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-planning-library/assessment.json"
    },
    {
      "id": "DPL-11",
      "name": "Plan assumptions editor",
      "families": [
        "F03"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_COMPOSITION",
      "source_refs": [
        {
          "surface_id": "CAP-028",
          "widget_class": "PlanOverridesEditor",
          "file": "lib/presentation/widgets/capture_plan/plan_overrides_editor.dart",
          "line": 29,
          "sha256": "74c392ce71501e942aa5adff31ba31874512e133939b47a29b4f51281cce9a77",
          "anchor": "class PlanOverridesEditor"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0238",
          "path": "evidence/host/baseline-375/plan_asm-light-1.png",
          "sha256": "37e5e752c162b89687ebc5fe4b145681a21b37cc978f35e5f791f0dae97639df",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0241",
          "path": "evidence/host/baseline-375/plan_asm_b-light-1.png",
          "sha256": "3a4a5494c2704cb4a548ea5b2e819f8782a4686874fa0a6b10fa1ab6f0624710",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Plan-only override explanation leads to Timing/Storage; each blank field includes its current global default.",
          "evidence_ids": [
            "EVD-0238",
            "EVD-0241"
          ],
          "whole_screen_pass_claim": false
        },
        "vertical_rhythm": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Label/input/help/current-default blocks repeat consistently, with lower Storage/reset separated.",
          "evidence_ids": [
            "EVD-0238",
            "EVD-0241"
          ],
          "whole_screen_pass_claim": false
        },
        "composition": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Local versus global ownership is explicit, using the same Apply-to-draft footer as other Plan editors.",
          "evidence_ids": [
            "EVD-0238",
            "EVD-0241"
          ],
          "whole_screen_pass_claim": false
        },
        "density": {
          "verdict": "PURPOSEFUL_TRADEOFF_OBSERVED",
          "observation": "Repeated current-default explanations add height because blank fields inherit; this is functional reassurance.",
          "evidence_ids": [
            "EVD-0238",
            "EVD-0241"
          ],
          "whole_screen_pass_claim": false
        },
        "grouping": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Timing and theoretical-storage overrides are separate concerns; Use global defaults is a secondary action outside inputs.",
          "evidence_ids": [
            "EVD-0238",
            "EVD-0241"
          ],
          "whole_screen_pass_claim": false
        },
        "redundant_frames": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Two semantic surfaces, normal field outlines and the footer avoid a nested-card hierarchy around hints.",
          "evidence_ids": [
            "EVD-0238",
            "EVD-0241"
          ],
          "whole_screen_pass_claim": false
        },
        "typography_consistency": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Labels, values and default/help prose retain units and predictable weights in one family.",
          "evidence_ids": [
            "EVD-0238",
            "EVD-0241"
          ],
          "whole_screen_pass_claim": false
        },
        "professional_quality": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Normal form is precise and utilitarian; aesthetics do not close its known newer-input/completion ownership finding.",
          "evidence_ids": [
            "EVD-0238",
            "EVD-0241"
          ],
          "whole_screen_pass_claim": false
        }
      },
      "limits": [
        "Normal blank overrides Light375 only; accepted-input race and pending/error behavior retain independent findings."
      ],
      "disposition": "NO_NEW_SUBSTANTIAL_FINDING_IN_VIEWED_COMPOSITION",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-planning-library/assessment.json"
    },
    {
      "id": "DPL-12",
      "name": "Library root",
      "families": [
        "F06"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_COMPOSITION",
      "source_refs": [
        {
          "surface_id": "LIB-001",
          "widget_class": "LibraryScreen",
          "file": "lib/presentation/screens/library/library_screen.dart",
          "line": 24,
          "sha256": "52f5d7e529c26e7bff4e1f53cd3ebebdad144d212945ad1861bdc0850e9edfd1",
          "anchor": "class LibraryScreen"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0139",
          "path": "evidence/host/baseline-375/library-light-1.png",
          "sha256": "e463f7094a44455a00ce54d3174dd76ed80dc0d14e5faf27565fee3467e66df2",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Three destinations have icon, label and count/meaning; Logbook progress is secondary guidance.",
          "evidence_ids": [
            "EVD-0139"
          ],
          "whole_screen_pass_claim": false
        },
        "vertical_rhythm": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Equal destination rows, separators and a note outside the shared group create predictable rhythm.",
          "evidence_ids": [
            "EVD-0139"
          ],
          "whole_screen_pass_claim": false
        },
        "composition": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "A directory of collections stays distinct from a planning dashboard; root navigation remains below.",
          "evidence_ids": [
            "EVD-0139"
          ],
          "whole_screen_pass_claim": false
        },
        "density": {
          "verdict": "PURPOSEFUL_TRADEOFF_OBSERVED",
          "observation": "Three destinations leave space below; another panel would invent an extra task.",
          "evidence_ids": [
            "EVD-0139"
          ],
          "whole_screen_pass_claim": false
        },
        "grouping": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Collection destinations stay together; progress is correctly referred to Logbook rather than mixed in.",
          "evidence_ids": [
            "EVD-0139"
          ],
          "whole_screen_pass_claim": false
        },
        "redundant_frames": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "One joined group is enough for three rows, without framing each collection or note.",
          "evidence_ids": [
            "EVD-0139"
          ],
          "whole_screen_pass_claim": false
        },
        "typography_consistency": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Title, row names and summaries have the established navigation/metadata hierarchy.",
          "evidence_ids": [
            "EVD-0139"
          ],
          "whole_screen_pass_claim": false
        },
        "professional_quality": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "The populated directory is calm and legible; count pending/error feedback is a separate concern.",
          "evidence_ids": [
            "EVD-0139"
          ],
          "whole_screen_pass_claim": false
        }
      },
      "limits": [
        "One synthetic count set, not cross-compared against differently seeded collection fixtures. No all-theme/count-failure design acceptance."
      ],
      "disposition": "NO_NEW_SUBSTANTIAL_FINDING_IN_VIEWED_COMPOSITION",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-planning-library/assessment.json"
    },
    {
      "id": "DPL-13",
      "name": "Rigs collection",
      "families": [
        "F06"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_COMPOSITION",
      "source_refs": [
        {
          "surface_id": "RIG-001",
          "widget_class": "EquipmentSelectionScreen",
          "file": "lib/presentation/screens/equipment/equipment_selection_screen.dart",
          "line": 40,
          "sha256": "1c7aab13e8e385b0e8de0dcd1d997d52347e3dc3d7a7bebde8d0643af66e0cc9",
          "anchor": "class EquipmentSelectionScreen"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0166",
          "path": "evidence/host/baseline-375/manage_rigs-light-1.png",
          "sha256": "e8ea09525635ba01369f1779481926224781395326f11502d9cdfdd3d3526814",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0164",
          "path": "evidence/host/baseline-375/manage_rigs-dark-1.png",
          "sha256": "11751c4d9fa50f5f7def928f6a3897b30e8a10e800e4290f57fc777624d81458",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Search/Add rig lead to the collection; the photo-add guide is secondary and collapsed.",
          "evidence_ids": [
            "EVD-0166",
            "EVD-0164"
          ],
          "whole_screen_pass_claim": false
        },
        "vertical_rhythm": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Search/action, rig record and guide share aligned edges and consistent Light/Dark gaps.",
          "evidence_ids": [
            "EVD-0166",
            "EVD-0164"
          ],
          "whole_screen_pass_claim": false
        },
        "composition": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Name plus camera/optical/sensor summary identifies the rig before the optional guide.",
          "evidence_ids": [
            "EVD-0166",
            "EVD-0164"
          ],
          "whole_screen_pass_claim": false
        },
        "density": {
          "verdict": "PURPOSEFUL_TRADEOFF_OBSERVED",
          "observation": "Rich summary fits two supporting lines here; blank space below one rig is a normal content-length result.",
          "evidence_ids": [
            "EVD-0166",
            "EVD-0164"
          ],
          "whole_screen_pass_claim": false
        },
        "grouping": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Controls, actual rig facts and photo-add guidance are separate jobs, with facts attached to the rig name.",
          "evidence_ids": [
            "EVD-0166",
            "EVD-0164"
          ],
          "whole_screen_pass_claim": false
        },
        "redundant_frames": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Semantic search/list/guide surfaces are meaningful; data within a row stays unboxed prose.",
          "evidence_ids": [
            "EVD-0166",
            "EVD-0164"
          ],
          "whole_screen_pass_claim": false
        },
        "typography_consistency": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Name and metadata have a primary/secondary split; guide uses the common disclosure heading.",
          "evidence_ids": [
            "EVD-0166",
            "EVD-0164"
          ],
          "whole_screen_pass_claim": false
        },
        "professional_quality": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Viewed Light/Dark state is restrained and predictable; many rigs may change balance and are not inferred.",
          "evidence_ids": [
            "EVD-0166",
            "EVD-0164"
          ],
          "whole_screen_pass_claim": false
        }
      },
      "limits": [
        "One-rig managed list; many-rig lower content, expanded guide, class-first empty entry and editor screens not newly reviewed."
      ],
      "disposition": "NO_NEW_SUBSTANTIAL_FINDING_IN_VIEWED_COMPOSITION",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-planning-library/assessment.json"
    },
    {
      "id": "DPL-14",
      "name": "Targets collection",
      "families": [
        "F06"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_COMPOSITION",
      "source_refs": [
        {
          "surface_id": "TGT-001",
          "widget_class": "TargetSelectionScreen",
          "file": "lib/presentation/screens/target/target_selection_screen.dart",
          "line": 34,
          "sha256": "c896df94fe2c83f6bb7ce90fa5e3a5bd136179dca5de1cf91cfe8cc445730bec",
          "anchor": "class TargetSelectionScreen"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0169",
          "path": "evidence/host/baseline-375/manage_targets-light-1.png",
          "sha256": "c9f29ec5e57015b37bb3efff93e86e7f2691fcc227e4950eeb419e3386db2b79",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0168",
          "path": "evidence/host/baseline-375/manage_targets-field-1.png",
          "sha256": "b2a1fe9ebf3a24f2433e19b80e6691de177f03b4f92cb87e9e54b29b53f57a76",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Search/Add target lead to Your targets and a separately labelled bundled Catalogue.",
          "evidence_ids": [
            "EVD-0169",
            "EVD-0168"
          ],
          "whole_screen_pass_claim": false
        },
        "vertical_rhythm": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Own-target explanation is separated from the catalogue; repeated object rows use stable spacing/rules.",
          "evidence_ids": [
            "EVD-0169",
            "EVD-0168"
          ],
          "whole_screen_pass_claim": false
        },
        "composition": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Personal-coordinate entry and OpenNGC-derived browsing remain distinct, under a clear page title.",
          "evidence_ids": [
            "EVD-0169",
            "EVD-0168"
          ],
          "whole_screen_pass_claim": false
        },
        "density": {
          "verdict": "PURPOSEFUL_TRADEOFF_OBSERVED",
          "observation": "Empty-own-target copy lowers first-fold row count but explains data ownership, not redundant filler.",
          "evidence_ids": [
            "EVD-0169",
            "EVD-0168"
          ],
          "whole_screen_pass_claim": false
        },
        "grouping": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Controls, user data and bundled data are separate groups; lazy catalogue fragments form a continuous surface.",
          "evidence_ids": [
            "EVD-0169",
            "EVD-0168"
          ],
          "whole_screen_pass_claim": false
        },
        "redundant_frames": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Three semantic jobs justify their surfaces; each object does not become another floating card.",
          "evidence_ids": [
            "EVD-0169",
            "EVD-0168"
          ],
          "whole_screen_pass_claim": false
        },
        "typography_consistency": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Group headings, names and types have clear Light/Field levels; hint ellipsis is not a truncated selected value.",
          "evidence_ids": [
            "EVD-0169",
            "EVD-0168"
          ],
          "whole_screen_pass_claim": false
        },
        "professional_quality": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Initial collection is precise; neutral single-family typography suits operating a catalogue.",
          "evidence_ids": [
            "EVD-0169",
            "EVD-0168"
          ],
          "whole_screen_pass_claim": false
        }
      },
      "limits": [
        "Initial no-own-target/populated-catalogue Light/Field only; terminal catalogue and populated/long own-target groups not inspected."
      ],
      "disposition": "NO_NEW_SUBSTANTIAL_FINDING_IN_VIEWED_COMPOSITION",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-planning-library/assessment.json"
    },
    {
      "id": "DPL-15",
      "name": "Saved sites and position choices",
      "families": [
        "F06"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_COMPOSITION",
      "source_refs": [
        {
          "surface_id": "SITE-001",
          "widget_class": "SitesScreen",
          "file": "lib/presentation/screens/sites/sites_screen.dart",
          "line": 36,
          "sha256": "b45355fa5de54567d025557790978c995ffc8be81cfcc6b733fbec13a6dce2f2",
          "anchor": "class SitesScreen"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0058",
          "path": "evidence/host/baseline-375/geo_sites-light-1.png",
          "sha256": "854e1de73122325fa88c633f4fb346566a149bccdfc8143a0056f91755fe43e8",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Header/search/Add precede selected sites with coordinate/zone facts and edit, then alternative position sources.",
          "evidence_ids": [
            "EVD-0058"
          ],
          "whole_screen_pass_claim": false
        },
        "vertical_rhythm": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Search, saved rows and position actions retain aligned edges, rules and space for wrapped coordinate/zone metadata.",
          "evidence_ids": [
            "EVD-0058"
          ],
          "whole_screen_pass_claim": false
        },
        "composition": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Selection, editing and using another position remain distinct under accepted geo-flow anatomy.",
          "evidence_ids": [
            "EVD-0058"
          ],
          "whole_screen_pass_claim": false
        },
        "density": {
          "verdict": "PURPOSEFUL_TRADEOFF_OBSERVED",
          "observation": "Two saved rows and alternate-position choices fit375dp while preserving readable units/zone context.",
          "evidence_ids": [
            "EVD-0058"
          ],
          "whole_screen_pass_claim": false
        },
        "grouping": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Stored sites stay together; current position/map are a distinct source group, not implicit live replacements.",
          "evidence_ids": [
            "EVD-0058"
          ],
          "whole_screen_pass_claim": false
        },
        "redundant_frames": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Three surfaces serve search, saved choices and position sources; radios/edit icons express real actions.",
          "evidence_ids": [
            "EVD-0058"
          ],
          "whole_screen_pass_claim": false
        },
        "typography_consistency": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Site names are stronger than coordinate/zone metadata, matching collection identity roles.",
          "evidence_ids": [
            "EVD-0058"
          ],
          "whole_screen_pass_claim": false
        },
        "professional_quality": {
          "verdict": "BOUNDED_OBSERVATION_NO_NEW_SUBSTANTIAL_FINDING",
          "observation": "Viewed page is composed. Tertiary Add site differs from filled Add rig/target under accepted selection-first geo design, with no demonstrated adverse consequence.",
          "evidence_ids": [
            "EVD-0058"
          ],
          "whole_screen_pass_claim": false
        }
      },
      "limits": [
        "Two synthetic sites Light375 only; long/many sites, error and picker/editor content are not newly judged. TD-121 remains accepted."
      ],
      "disposition": "NO_NEW_SUBSTANTIAL_FINDING_IN_VIEWED_COMPOSITION",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-planning-library/assessment.json"
    },
    {
      "id": "DCS-01",
      "name": "Night tab",
      "families": [
        "F04"
      ],
      "unit_kind": "MAIN_CONDITIONAL_OR_EXPLICIT_COMPONENT_ONLY",
      "source_refs": [
        {
          "file": "lib/presentation/screens/details/night_moon_screen.dart",
          "sha256": "bf68b363dad27862b227ac883decffdf691f9524c0c6f3cd9e5b00b7fe745f4d",
          "verified_class_declarations": [
            {
              "class": "NightMoonScreen",
              "declaration_line": 40
            },
            {
              "class": "_NightMoonBody",
              "declaration_line": 75
            },
            {
              "class": "_NightAnswer",
              "declaration_line": 381
            }
          ]
        },
        {
          "file": "lib/presentation/widgets/night_browser_sections.dart",
          "sha256": "b6afef128d8ca7162438a81d635143636155a497d6f029d1321cffcff911c5eb",
          "verified_class_declarations": [
            {
              "class": "NightBarSection",
              "declaration_line": 36
            }
          ]
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0196",
          "path": "evidence/host/baseline-375/night-light-1.png",
          "sha256": "859104eec42ac5ab22b18bec1a0064a67b1c7f710caae637bfc20d7b443f8316",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0197",
          "path": "evidence/host/baseline-375/night_b-dark-1.png",
          "sha256": "80a2660d26b9ab3fa0d2d70ec380d147b553c3c1971fb211d320a91bd5b761b7",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0202",
          "path": "evidence/host/baseline-375/night_c-light-1.png",
          "sha256": "82703c4bbda3d71041dccb04466f31e51517e686fcbe3f777cf97df233187fca",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0211",
          "path": "evidence/host/baseline-375/night_exact_open-light-1.png",
          "sha256": "2e1c51f44f4890c215fe6f1d1f3827d562ae79406fd3f52c06df8c8c4d3f756d",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0217",
          "path": "evidence/host/baseline-375/night_moon_tail-light-1.png",
          "sha256": "f3340422d6a9c6f18c8e0fe677ef8ffebbbf015b5a451c64e6feb5722bb47024",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Site/date context precedes the large dark-time answer; preview and reading material follow. The substantive answer is easy to find.",
          "evidence_ids": [
            "EVD-0196",
            "EVD-0197",
            "EVD-0202",
            "EVD-0211",
            "EVD-0217"
          ]
        },
        "vertical_rhythm": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Clear gaps separate answer, timeline and reading group. Within the timeline, labels stay close to their values; disclosure rows use a tighter cadence.",
          "evidence_ids": [
            "EVD-0196",
            "EVD-0197",
            "EVD-0202",
            "EVD-0211",
            "EVD-0217"
          ]
        },
        "composition": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Context, answer, preview and reading form a coherent sequence. The expanded Moon explanation stays in the reading group.",
          "evidence_ids": [
            "EVD-0196",
            "EVD-0197",
            "EVD-0202",
            "EVD-0211",
            "EVD-0217"
          ]
        },
        "density": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The overview is moderate in density. Opening the exact reading key reveals a compact interval reference; the default remains concise.",
          "evidence_ids": [
            "EVD-0196",
            "EVD-0197",
            "EVD-0202",
            "EVD-0211",
            "EVD-0217"
          ]
        },
        "grouping": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Jump controls, preview instant, lanes and remaining-time statement belong together. Moon/Sun explanations sit with the reading guide.",
          "evidence_ids": [
            "EVD-0196",
            "EVD-0197",
            "EVD-0202",
            "EVD-0211",
            "EVD-0217"
          ]
        },
        "redundant_frames": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "One flat surface contains the disclosure rows; bordered jump controls have a distinct functional purpose. There is no card per fact.",
          "evidence_ids": [
            "EVD-0196",
            "EVD-0197",
            "EVD-0202",
            "EVD-0211",
            "EVD-0217"
          ]
        },
        "typography_consistency": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Duration, section headings, dates and compact exact intervals have visibly distinct roles. Wrapped exact times preserve date and zone information.",
          "evidence_ids": [
            "EVD-0196",
            "EVD-0197",
            "EVD-0202",
            "EVD-0211",
            "EVD-0217"
          ]
        },
        "professional_quality": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The sampled composition is a deliberate scientific utility: answer first, inspectable encoding second, explanation third. No new composition defect is demonstrated.",
          "evidence_ids": [
            "EVD-0196",
            "EVD-0197",
            "EVD-0202",
            "EVD-0211",
            "EVD-0217"
          ]
        }
      },
      "limits": [
        "Static375dp/100% Light/Dark/Field samples only; no added interaction/native/accessibility claim.",
        "Expanded MoonSummary is viewed through Night, not proof of its entire Moon-tab lower wrapper."
      ],
      "disposition": "SUPPORTED_IN_OBSERVED_SCOPE",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-conditions-settings/assessment.json"
    },
    {
      "id": "DCS-02",
      "name": "Moon tab",
      "families": [
        "F04"
      ],
      "unit_kind": "MAIN_CONDITIONAL_OR_EXPLICIT_COMPONENT_ONLY",
      "source_refs": [
        {
          "file": "lib/presentation/screens/details/night_moon_screen.dart",
          "sha256": "bf68b363dad27862b227ac883decffdf691f9524c0c6f3cd9e5b00b7fe745f4d",
          "verified_class_declarations": [
            {
              "class": "NightMoonScreen",
              "declaration_line": 40
            },
            {
              "class": "_MoonAnswer",
              "declaration_line": 458
            },
            {
              "class": "_MoonSummary",
              "declaration_line": 941
            }
          ]
        },
        {
          "file": "lib/presentation/widgets/night_browser_sections.dart",
          "sha256": "b6afef128d8ca7162438a81d635143636155a497d6f029d1321cffcff911c5eb",
          "verified_class_declarations": [
            {
              "class": "MoonCalendarSection",
              "declaration_line": 1046
            },
            {
              "class": "NightBarSection",
              "declaration_line": 36
            }
          ]
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0190",
          "path": "evidence/host/baseline-375/moon-light-1.png",
          "sha256": "379941bfbb36ea67dd8d9a37e28a1140ac3652cc39f312e4462cf404c08d1663",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0191",
          "path": "evidence/host/baseline-375/moon_b-dark-1.png",
          "sha256": "21c7bf89469a4a10b16677fb7c0c216b705be6056b4eda658519dce8444a6fc8",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0498",
          "path": "reviews/conditions/probes/moon_calendar_tail-dark-375.png",
          "sha256": "71e75f82da7a8a5e60ca8b826cfef7d9b24ad372176273def5a52415529f3089",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Moon-free duration and interval lead; phase is supporting context. Calendar browsing follows the planning answer.",
          "evidence_ids": [
            "EVD-0190",
            "EVD-0191",
            "EVD-0498"
          ]
        },
        "vertical_rhythm": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Answer/calendar separation is clear; date, icon and duration cells repeat regularly. A larger gap introduces the later timeline.",
          "evidence_ids": [
            "EVD-0190",
            "EVD-0191",
            "EVD-0498"
          ]
        },
        "composition": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The month is a genuine comparison surface followed by the shared preview language; it does not merely duplicate the answer card.",
          "evidence_ids": [
            "EVD-0190",
            "EVD-0191",
            "EVD-0498"
          ]
        },
        "density": {
          "verdict": "ACCEPTED_INFORMATION_DENSITY_TRADEOFF",
          "assessment": "Seven columns are information-dense but consistently structured. Compact calendar density is purposeful, not a reason to invent a replacement.",
          "evidence_ids": [
            "EVD-0190",
            "EVD-0191",
            "EVD-0498"
          ]
        },
        "grouping": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "One month group contains all cells. The selected19th and plan dot identify context; preview remains a separate group.",
          "evidence_ids": [
            "EVD-0190",
            "EVD-0191",
            "EVD-0498"
          ]
        },
        "redundant_frames": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Individual dates are not separately boxed. Only selection and the overall functional group receive boundaries.",
          "evidence_ids": [
            "EVD-0190",
            "EVD-0191",
            "EVD-0498"
          ]
        },
        "typography_consistency": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Large answer text contrasts with compact dates/durations. The12-hour tail is a separate recorded display preference, not inconsistent formatting within one fixture.",
          "evidence_ids": [
            "EVD-0190",
            "EVD-0191",
            "EVD-0498"
          ]
        },
        "professional_quality": {
          "verdict": "SUPPORTED_WITH_LOWER_COMPOSITION_LIMIT",
          "assessment": "The top and calendar/timeline middle are coherent. Full final Moon-tab disclosure placement is not independently established by these frames.",
          "evidence_ids": [
            "EVD-0190",
            "EVD-0191",
            "EVD-0498"
          ]
        }
      },
      "limits": [
        "INSUFFICIENT_EVIDENCE for the final lower Moon-tab wrapper; same MoonSummary internals are inspected through Night only.",
        "No added320dp/week/pressed-state/native claim."
      ],
      "disposition": "SUPPORTED_IN_OBSERVED_SCOPE",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-conditions-settings/assessment.json"
    },
    {
      "id": "DCS-03",
      "name": "Weather direct entry and shared Weather tab",
      "families": [
        "F05"
      ],
      "unit_kind": "MAIN_CONDITIONAL_OR_EXPLICIT_COMPONENT_ONLY",
      "source_refs": [
        {
          "file": "lib/presentation/screens/details/weather_detail_screen.dart",
          "sha256": "2988b080e195dba24e65c5fb20ce4bae7c5fb8b00b55be03fd16517398059aab",
          "verified_class_declarations": [
            {
              "class": "WeatherDetailScreen",
              "declaration_line": 7
            }
          ]
        },
        {
          "file": "lib/presentation/screens/details/night_moon_screen.dart",
          "sha256": "bf68b363dad27862b227ac883decffdf691f9524c0c6f3cd9e5b00b7fe745f4d",
          "verified_class_declarations": [
            {
              "class": "NightMoonScreen",
              "declaration_line": 40
            }
          ]
        },
        {
          "file": "lib/presentation/widgets/weather_hybrid_view.dart",
          "sha256": "1dc6b157183af1f4b53446842f3fd5ab2af4e436afca1fbbd661a007feeb528c",
          "verified_class_declarations": [
            {
              "class": "HybridWeatherView",
              "declaration_line": 113
            },
            {
              "class": "_Charts",
              "declaration_line": 746
            },
            {
              "class": "_Details",
              "declaration_line": 1354
            },
            {
              "class": "_ComingNights",
              "declaration_line": 1527
            }
          ]
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0385",
          "path": "evidence/host/baseline-375/weather-light-1.png",
          "sha256": "8c94f394c8a840a806ef399b9871dd0c57ecbef36839baee61e40701220284da",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0386",
          "path": "evidence/host/baseline-375/weather_b-dark-1.png",
          "sha256": "e13b988ccf3a757506953b1700c6b07c793f379fda4767e499ed4ace045b66ef",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0391",
          "path": "evidence/host/baseline-375/weather_c-light-1.png",
          "sha256": "d924b53423a1fd40b3c51089788bd58f04c1f369e8268e2fa0c2b1ce35b4445e",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0394",
          "path": "evidence/host/baseline-375/weather_charts-light-1.png",
          "sha256": "ab207a1ca3dc9ebde079a600f1b7cbb3b21808a284047fba71352d5006aab0d6",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0396",
          "path": "evidence/host/baseline-375/weather_charts_b-field-1.png",
          "sha256": "650451fd5610e3302ee27d9c7d30fb06989d2aeb32d9732c132f41c413b51f56",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0405",
          "path": "evidence/host/baseline-375/weather_forecast_table-field-1.png",
          "sha256": "e833d75f7e166e8be3e187c4aa0ed06920b0c0508438b49c6680d0c89c7948d3",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0422",
          "path": "evidence/host/baseline-375/weather_table_later-dark-1.png",
          "sha256": "c6f4095f2f44c55a3b4b1227cbb2592722c0725a6f08493ec97405627f6054cb",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Cloud range, dark span, known-sample coverage and freshness precede Refresh and detailed metrics. Trust/context does not disappear below charts.",
          "evidence_ids": [
            "EVD-0385",
            "EVD-0386",
            "EVD-0391",
            "EVD-0394",
            "EVD-0396",
            "EVD-0405",
            "EVD-0422"
          ]
        },
        "vertical_rhythm": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Compact rows have regular separators and label/value gaps. The full-width wind/gust line is legible; chart panels repeat title/range/plot/axis spacing.",
          "evidence_ids": [
            "EVD-0385",
            "EVD-0386",
            "EVD-0391",
            "EVD-0394",
            "EVD-0396",
            "EVD-0405",
            "EVD-0422"
          ]
        },
        "composition": {
          "verdict": "KNOWN_BOUNDED_DEFICIENCY",
          "assessment": "A is a useful summary and B a clearly labelled alternative. The far-right full table loses local-time identity, the existing UIA-0010 structural limit.",
          "evidence_ids": [
            "EVD-0385",
            "EVD-0386",
            "EVD-0391",
            "EVD-0394",
            "EVD-0396",
            "EVD-0405",
            "EVD-0422"
          ]
        },
        "density": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Compact metrics are scannable; B intentionally requires more browsing and states physical scales. The dense far-right table is harder to interpret without its time column.",
          "evidence_ids": [
            "EVD-0385",
            "EVD-0386",
            "EVD-0391",
            "EVD-0394",
            "EVD-0396",
            "EVD-0405",
            "EVD-0422"
          ]
        },
        "grouping": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Answer, metric inspection, source/details and Coming nights have distinct groups. Every repeated View this night action has its own dated context.",
          "evidence_ids": [
            "EVD-0385",
            "EVD-0386",
            "EVD-0391",
            "EVD-0394",
            "EVD-0396",
            "EVD-0405",
            "EVD-0422"
          ]
        },
        "redundant_frames": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Rules/panels separate physical quantities, not every individual value. Repeated night actions are functional, though they consume vertical space.",
          "evidence_ids": [
            "EVD-0385",
            "EVD-0386",
            "EVD-0391",
            "EVD-0394",
            "EVD-0396",
            "EVD-0405",
            "EVD-0422"
          ]
        },
        "typography_consistency": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Bold ranges, subdued known counts and compact table headers share consistent roles. Units, unknown dashes and attribution stay visible.",
          "evidence_ids": [
            "EVD-0385",
            "EVD-0386",
            "EVD-0391",
            "EVD-0394",
            "EVD-0396",
            "EVD-0405",
            "EVD-0422"
          ]
        },
        "professional_quality": {
          "verdict": "COHERENT_WITH_EXISTING_DEFICIENCIES",
          "assessment": "The design is deliberate, but the visible16-day explanation and detached far-right values weaken trust: existing UIA-0004 and UIA-0010, not new discoveries.",
          "evidence_ids": [
            "EVD-0385",
            "EVD-0386",
            "EVD-0391",
            "EVD-0394",
            "EVD-0396",
            "EVD-0405",
            "EVD-0422"
          ]
        }
      },
      "limits": [
        "No provider fetch, gesture, link, native or accessibility action was run.",
        "A/B is an existing preference; no C1 alternative is adopted.",
        "Normal composition does not resolve canonical pending/error/contrast findings."
      ],
      "disposition": "SUPPORTED_IN_OBSERVED_SCOPE",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-conditions-settings/assessment.json"
    },
    {
      "id": "DCS-04",
      "name": "Settings index",
      "families": [
        "F09"
      ],
      "unit_kind": "MAIN_CONDITIONAL_OR_EXPLICIT_COMPONENT_ONLY",
      "source_refs": [
        {
          "file": "lib/presentation/screens/settings/settings_screen.dart",
          "sha256": "94a1f9c7cf60e4a84631456c88d16e809fb6d65be743e7e224611cf215a74a12",
          "verified_class_declarations": [
            {
              "class": "_SettingsIndex",
              "declaration_line": 714
            }
          ]
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0349",
          "path": "evidence/host/baseline-375/settings-light-1.png",
          "sha256": "c6605eb803c4f597f188d1195b6da01638c8c0977c067e8d6ef1edde834ab39e",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0348",
          "path": "evidence/host/baseline-375/settings-field-1.png",
          "sha256": "9b379a462dd59ebe8622d17ef72acc2646c878a59abca36888e76d8739b16211",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Preferences precedes Data and about; each row includes useful current context. Title and selected root navigation make location clear.",
          "evidence_ids": [
            "EVD-0349",
            "EVD-0348"
          ]
        },
        "vertical_rhythm": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Icon/title/summary alignment repeats predictably; group spacing is greater than internal row spacing.",
          "evidence_ids": [
            "EVD-0349",
            "EVD-0348"
          ]
        },
        "composition": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Two groups fit all five destinations above navigation. This is an overview rather than a duplicate configuration form.",
          "evidence_ids": [
            "EVD-0349",
            "EVD-0348"
          ]
        },
        "density": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Summaries help destination choice without a wall of controls; longer Planning/About captions wrap naturally.",
          "evidence_ids": [
            "EVD-0349",
            "EVD-0348"
          ]
        },
        "grouping": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Appearance/Planning/Privacy and Backup/About are understandable task groups. Icons reinforce full labels.",
          "evidence_ids": [
            "EVD-0349",
            "EVD-0348"
          ]
        },
        "redundant_frames": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Two flat groups with dividers replace five separate cards; navigation selection has a different location function.",
          "evidence_ids": [
            "EVD-0349",
            "EVD-0348"
          ]
        },
        "typography_consistency": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Headings, row titles and smaller current-value summaries are consistent in Light and Field; units and punctuation remain readable.",
          "evidence_ids": [
            "EVD-0349",
            "EVD-0348"
          ]
        },
        "professional_quality": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The observed index is orderly and recognizably part of the product. No new composition deficiency is visible.",
          "evidence_ids": [
            "EVD-0349",
            "EVD-0348"
          ]
        }
      },
      "limits": [
        "Two static themes at100%; individual configuration behavior and navigation are not revalidated."
      ],
      "disposition": "SUPPORTED_IN_OBSERVED_SCOPE",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-conditions-settings/assessment.json"
    },
    {
      "id": "DCS-05",
      "name": "Appearance",
      "families": [
        "F09"
      ],
      "unit_kind": "MAIN_CONDITIONAL_OR_EXPLICIT_COMPONENT_ONLY",
      "source_refs": [
        {
          "file": "lib/presentation/screens/settings/settings_screen.dart",
          "sha256": "94a1f9c7cf60e4a84631456c88d16e809fb6d65be743e7e224611cf215a74a12",
          "verified_class_declarations": [
            {
              "class": "_AppearancePage",
              "declaration_line": 818
            }
          ]
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0608",
          "path": "reviews/conditions/root-probes/evidence-attempt-01/appearance_top-light-375.png",
          "sha256": "b8f3807a36c0f0ab4956366d6c7aedd03fdeab9037e012253d8880a8ea7b0d0d",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0611",
          "path": "reviews/conditions/root-probes/evidence-attempt-01/appearance_units-dark-375.png",
          "sha256": "5df160e2d6e3d4100407d2ba5cf5d9a2580b630bafefd8c7aa33daebe24be62c",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0618",
          "path": "reviews/conditions/root-probes/evidence-attempt-01/appearance_weather_charts_selected-light-375.png",
          "sha256": "a3e997ffcb61a2c5c3848fe9a80d35f6f05a1cd074ceec5bdf23d217dc1af93a",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Theme leads, then text-size information, units and Weather view. Identity and data-display preferences have separate headings.",
          "evidence_ids": [
            "EVD-0608",
            "EVD-0611",
            "EVD-0618"
          ]
        },
        "vertical_rhythm": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Choice heights and gaps repeat; explanatory copy sits close to the qualified control. Sections have stronger separation.",
          "evidence_ids": [
            "EVD-0608",
            "EVD-0611",
            "EVD-0618"
          ]
        },
        "composition": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Four preference groups form a coherent page. Three-option groups consistently wrap two-plus-one; the full-row final option is not itself a hierarchy defect.",
          "evidence_ids": [
            "EVD-0608",
            "EVD-0611",
            "EVD-0618"
          ]
        },
        "density": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The page is long because options retain useful targets. Units and Weather alternatives remain individually scannable.",
          "evidence_ids": [
            "EVD-0608",
            "EVD-0611",
            "EVD-0618"
          ]
        },
        "grouping": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Display-only units are separated from calculation storage. Field mode belongs with Theme; text size is information, not a competing custom scaler.",
          "evidence_ids": [
            "EVD-0608",
            "EVD-0611",
            "EVD-0618"
          ]
        },
        "redundant_frames": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Borders mark real peer choices; flat outer groups establish meaning, without a card per label.",
          "evidence_ids": [
            "EVD-0608",
            "EVD-0611",
            "EVD-0618"
          ]
        },
        "typography_consistency": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Heading/body roles match Settings. Unit and Weather labels wrap without visible clipping in the lower frames.",
          "evidence_ids": [
            "EVD-0608",
            "EVD-0611",
            "EVD-0618"
          ]
        },
        "professional_quality": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The observed page is coherent. Accepted unit wrapping is preserved; preference for another option arrangement alone is not a finding.",
          "evidence_ids": [
            "EVD-0608",
            "EVD-0611",
            "EVD-0618"
          ]
        }
      },
      "limits": [
        "Category fixtures do not establish the production Back stack; absent Back is not treated as a defect.",
        "No200%/TalkBack or state-write claim."
      ],
      "disposition": "SUPPORTED_IN_OBSERVED_SCOPE",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-conditions-settings/assessment.json"
    },
    {
      "id": "DCS-06",
      "name": "Planning defaults",
      "families": [
        "F09"
      ],
      "unit_kind": "MAIN_CONDITIONAL_OR_EXPLICIT_COMPONENT_ONLY",
      "source_refs": [
        {
          "file": "lib/presentation/screens/settings/settings_screen.dart",
          "sha256": "94a1f9c7cf60e4a84631456c88d16e809fb6d65be743e7e224611cf215a74a12",
          "verified_class_declarations": [
            {
              "class": "SettingsScreen",
              "declaration_line": 51
            },
            {
              "class": "_GateTile",
              "declaration_line": 967
            },
            {
              "class": "_OptionalOverhead",
              "declaration_line": 1015
            }
          ]
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0700",
          "path": "reviews/conditions/root-probes/evidence-attempt-03/planning_save_held-light-375.png",
          "sha256": "bf416f51f20fd5f643bd624b4c2c618f3eb8ee3619bdee45ebbfdbadacbe5766",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0628",
          "path": "reviews/conditions/root-probes/evidence-attempt-01/planning_defaults_apply-light-375.png",
          "sha256": "2310608a47941ab7853ca0c7e5d05de53af075ceea04ce10afa021b412bdd65f",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0644",
          "path": "reviews/conditions/root-probes/evidence-attempt-01/planning_imaging_window-light-375.png",
          "sha256": "6819f713f38d9018098aa9675226e7d2931a4fc36604fa9bef7da5e2754ba10d",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0633",
          "path": "reviews/conditions/root-probes/evidence-attempt-01/planning_gates_on-dark-375.png",
          "sha256": "5a6a93efc623bc59bb0a6576c8d2be039dcfd75727e063b0173e1ba4a9d8ed1e",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0652",
          "path": "reviews/conditions/root-probes/evidence-attempt-01/planning_optional_on_lower-field-375.png",
          "sha256": "54cb4ff68b41c0a3d45f89f12a3ef098843ef58b6e1972bc7360134e77569198",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0639",
          "path": "reviews/conditions/root-probes/evidence-attempt-01/planning_guidance_bottom-light-375.png",
          "sha256": "6038b95ca58d78abb75894c970296d43328b54276398fbbc16bf2fa1934e3980",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The top states these are defaults and saved snapshots stay unchanged. Budget precedes windows, gates/times and Guidance; Save/Cancel remain visible.",
          "evidence_ids": [
            "EVD-0700",
            "EVD-0628",
            "EVD-0644",
            "EVD-0633",
            "EVD-0652",
            "EVD-0639"
          ]
        },
        "vertical_rhythm": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Label/value/explanation/slider patterns repeat. Optional-time steppers keep a consistent minus/value/plus cadence across units.",
          "evidence_ids": [
            "EVD-0700",
            "EVD-0628",
            "EVD-0644",
            "EVD-0633",
            "EVD-0652",
            "EVD-0639"
          ]
        },
        "composition": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Policy and advanced controls expand on demand. The fixed action bar distinguishes Saving and Changed-not-saved from the form.",
          "evidence_ids": [
            "EVD-0700",
            "EVD-0628",
            "EVD-0644",
            "EVD-0633",
            "EVD-0652",
            "EVD-0639"
          ]
        },
        "density": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "This is a long technical form, but collapsed enabled-count summaries and progressive disclosure manage the detail.",
          "evidence_ids": [
            "EVD-0700",
            "EVD-0628",
            "EVD-0644",
            "EVD-0633",
            "EVD-0652",
            "EVD-0639"
          ]
        },
        "grouping": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Budget, usable windows, optional times and advice are separated; assumptions are explicitly distinguished from science.",
          "evidence_ids": [
            "EVD-0700",
            "EVD-0628",
            "EVD-0644",
            "EVD-0633",
            "EVD-0652",
            "EVD-0639"
          ]
        },
        "redundant_frames": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Groups contain related controls rather than boxing each measurement. Dividers have a relationship function.",
          "evidence_ids": [
            "EVD-0700",
            "EVD-0628",
            "EVD-0644",
            "EVD-0633",
            "EVD-0652",
            "EVD-0639"
          ]
        },
        "typography_consistency": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Explicit degrees, percentages, seconds, minutes and k are readable. Titles, labels and lighter explanations form a stable hierarchy.",
          "evidence_ids": [
            "EVD-0700",
            "EVD-0628",
            "EVD-0644",
            "EVD-0633",
            "EVD-0652",
            "EVD-0639"
          ]
        },
        "professional_quality": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The sampled form is professionally organized. Its length reflects meaningful controls, not a demonstrated global density defect.",
          "evidence_ids": [
            "EVD-0700",
            "EVD-0628",
            "EVD-0644",
            "EVD-0633",
            "EVD-0652",
            "EVD-0639"
          ]
        }
      },
      "limits": [
        "The top sample is an actual Saving state, used for composition rather than untouched-default or correctness proof.",
        "Fixture chrome, persistence, keyboard and native behavior remain separate."
      ],
      "disposition": "SUPPORTED_IN_OBSERVED_SCOPE",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-conditions-settings/assessment.json"
    },
    {
      "id": "DCS-07",
      "name": "Privacy",
      "families": [
        "F09"
      ],
      "unit_kind": "MAIN_CONDITIONAL_OR_EXPLICIT_COMPONENT_ONLY",
      "source_refs": [
        {
          "file": "lib/presentation/screens/settings/settings_screen.dart",
          "sha256": "94a1f9c7cf60e4a84631456c88d16e809fb6d65be743e7e224611cf215a74a12",
          "verified_class_declarations": [
            {
              "class": "SettingsScreen",
              "declaration_line": 51
            }
          ]
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0662",
          "path": "reviews/conditions/root-probes/evidence-attempt-01/privacy_top-light-375.png",
          "sha256": "f3f0cb6212b06950c07f6c4c3689526d8d3ce3d2e6887d8278f8b2d430470b93",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0655",
          "path": "reviews/conditions/root-probes/evidence-attempt-01/privacy_expanded-dark-375.png",
          "sha256": "dc2b3074e5ba6f10ea80be2210018dae4213f8ea2a3308642a0148ad33625347",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The opt-in place-name switch leads; broader explanation follows. The only setting is not buried inside policy text.",
          "evidence_ids": [
            "EVD-0662",
            "EVD-0655"
          ]
        },
        "vertical_rhythm": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Title/control/copy spacing is regular; the two-line information heading expands naturally without clipping.",
          "evidence_ids": [
            "EVD-0662",
            "EVD-0655"
          ]
        },
        "composition": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Two groups suit a page with one setting. Blank lower space in the collapsed state is purposeful sparsity.",
          "evidence_ids": [
            "EVD-0662",
            "EVD-0655"
          ]
        },
        "density": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The expanded paragraph is dense but readable full-width; provider and permission facts fit in the observed group.",
          "evidence_ids": [
            "EVD-0662",
            "EVD-0655"
          ]
        },
        "grouping": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Opt-in Nominatim/off behavior is separate from the broader app data-flow explanation.",
          "evidence_ids": [
            "EVD-0662",
            "EVD-0655"
          ]
        },
        "redundant_frames": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Two flat groups suffice; there is no frame for every provider or another frame around the switch.",
          "evidence_ids": [
            "EVD-0662",
            "EVD-0655"
          ]
        },
        "typography_consistency": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Headings and smaller explanatory copy remain distinct, with complete provider names and control explanation visible.",
          "evidence_ids": [
            "EVD-0662",
            "EVD-0655"
          ]
        },
        "professional_quality": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The sampled page is restrained and transparent. No new composition defect is demonstrated.",
          "evidence_ids": [
            "EVD-0662",
            "EVD-0655"
          ]
        }
      },
      "limits": [
        "Canonical Privacy action-state evidence remains separate; no lookup/GPS/permission/settings write was performed."
      ],
      "disposition": "SUPPORTED_IN_OBSERVED_SCOPE",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-conditions-settings/assessment.json"
    },
    {
      "id": "DCS-08",
      "name": "Backup and data / restore confirmation",
      "families": [
        "F09"
      ],
      "unit_kind": "MAIN_CONDITIONAL_OR_EXPLICIT_COMPONENT_ONLY",
      "source_refs": [
        {
          "file": "lib/presentation/screens/settings/settings_screen.dart",
          "sha256": "94a1f9c7cf60e4a84631456c88d16e809fb6d65be743e7e224611cf215a74a12",
          "verified_class_declarations": [
            {
              "class": "SettingsScreen",
              "declaration_line": 51
            }
          ]
        },
        {
          "file": "lib/presentation/screens/settings/backup_section.dart",
          "sha256": "f2e47f69624e1c4c40e8433f07a86390e0b723439c309b5d5a6ba4973dbb863a",
          "verified_class_declarations": [
            {
              "class": "BackupSection",
              "declaration_line": 34
            }
          ]
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0355",
          "path": "evidence/host/baseline-375/settings_backup_b-light-1.png",
          "sha256": "2fa23313f579db89ddbc4cda618309527d8be8679f93f93c41525fbe41ea483d",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0016",
          "path": "evidence/host/baseline-375/backup_restore-light-1.png",
          "sha256": "b5caf715567b5c4d6733dab4cb4619148f5f5a4519bb2fccf489886650fb4c98",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Archive scope is explained before the peer Back up/Restore tasks. Confirmation leads with backup identity before destructive consequences.",
          "evidence_ids": [
            "EVD-0355",
            "EVD-0016"
          ]
        },
        "vertical_rhythm": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Both groups repeat title/copy/button rhythm; confirmation paragraphs separate provenance, replacement and mitigation.",
          "evidence_ids": [
            "EVD-0355",
            "EVD-0016"
          ]
        },
        "composition": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The normal page is intentionally sparse. Narrow-width action stacking keeps Cancel, Back up first and Restore/restart readable.",
          "evidence_ids": [
            "EVD-0355",
            "EVD-0016"
          ]
        },
        "density": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Normal actions fit comfortably. Confirmation copy is longer for a reason and still fits without visible clipping.",
          "evidence_ids": [
            "EVD-0355",
            "EVD-0016"
          ]
        },
        "grouping": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Export and restore are separate. The confirmation keeps consequences before actions instead of scattering them across screens.",
          "evidence_ids": [
            "EVD-0355",
            "EVD-0016"
          ]
        },
        "redundant_frames": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Two meaningful task groups are enough; heading/action repetition is functional, not nested decorative framing.",
          "evidence_ids": [
            "EVD-0355",
            "EVD-0016"
          ]
        },
        "typography_consistency": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Date/zone/version, .astroplan and the synthetic12-plan count are readable. Destructive red text differs from safe alternatives.",
          "evidence_ids": [
            "EVD-0355",
            "EVD-0016"
          ]
        },
        "professional_quality": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The normal and confirmation compositions are clear and appropriately cautious. No new deficiency is shown.",
          "evidence_ids": [
            "EVD-0355",
            "EVD-0016"
          ]
        }
      },
      "limits": [
        "No export/share/picker/restore activation or owner-data operation; no OS cancellation/success claim."
      ],
      "disposition": "SUPPORTED_IN_OBSERVED_SCOPE",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-conditions-settings/assessment.json"
    },
    {
      "id": "DCS-09",
      "name": "About",
      "families": [
        "F09"
      ],
      "unit_kind": "MAIN_CONDITIONAL_OR_EXPLICIT_COMPONENT_ONLY",
      "source_refs": [
        {
          "file": "lib/presentation/screens/about/about_screen.dart",
          "sha256": "1dec96c344dd2814cf89b9469b4f88166d37d7b41571150195ee5625e9240b2e",
          "verified_class_declarations": [
            {
              "class": "AboutScreen",
              "declaration_line": 22
            },
            {
              "class": "_Notice",
              "declaration_line": 309
            }
          ]
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0547",
          "path": "evidence/android/canonical-about-top-dark-100.png",
          "sha256": "93d2a46ef4c3ae53125c3ad25a82c5f4ef84222d3db087fc3327e22dfc71ec28",
          "evidence_layer": "NATIVE_VERIFIED"
        },
        {
          "evidence_id": "EVD-0352",
          "path": "evidence/host/baseline-375/settings_about_b-light-1.png",
          "sha256": "1cadd3fc31e39018a1e6e48ddf5644fa23e08365c37321128a0cbeebdf61931c",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Identity/version/creator links lead, followed by source credits. Licence has a distinct lower heading and its own source/licence actions.",
          "evidence_ids": [
            "EVD-0547",
            "EVD-0352"
          ]
        },
        "vertical_rhythm": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Native credit links have generous touch-oriented spacing. Lower legal paragraphs retain regular leading and paragraph gaps.",
          "evidence_ids": [
            "EVD-0547",
            "EVD-0352"
          ]
        },
        "composition": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Top and lower content use the same document grouping. Provenance/legal prose stays full-width rather than in a numeric-value column.",
          "evidence_ids": [
            "EVD-0547",
            "EVD-0352"
          ]
        },
        "density": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "This secondary reference page is lengthy but source bullets, disclosure and links give structure to the detail.",
          "evidence_ids": [
            "EVD-0547",
            "EVD-0352"
          ]
        },
        "grouping": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Identity, data sources, privacy and licence have distinct homes. The OpenNGC notice is visibly an optional disclosure.",
          "evidence_ids": [
            "EVD-0547",
            "EVD-0352"
          ]
        },
        "redundant_frames": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Flat groups and internal separators are meaningful; every credit sentence is not boxed separately.",
          "evidence_ids": [
            "EVD-0547",
            "EVD-0352"
          ]
        },
        "typography_consistency": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Native top and host lower use compatible Geist heading/body/link roles; the long lower licence paragraph wraps without visible clipping.",
          "evidence_ids": [
            "EVD-0547",
            "EVD-0352"
          ]
        },
        "professional_quality": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The inspected regions are professional and information-led. Full middle content and expanded notices/licence routes are not implied.",
          "evidence_ids": [
            "EVD-0547",
            "EVD-0352"
          ]
        }
      },
      "limits": [
        "Top is an existing valid native100% capture; lower is host evidence, not the same continuous session.",
        "Expanded OpenNGC content and actual licence list/detail were not opened; no full child-composition claim."
      ],
      "disposition": "SUPPORTED_IN_OBSERVED_SCOPE",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-conditions-settings/assessment.json"
    },
    {
      "id": "DCS-10",
      "name": "Welcome",
      "families": [
        "F10"
      ],
      "unit_kind": "MAIN_CONDITIONAL_OR_EXPLICIT_COMPONENT_ONLY",
      "source_refs": [
        {
          "file": "lib/presentation/screens/welcome/welcome_screen.dart",
          "sha256": "cb7e7c77664ff154c4f8355b105328dedaaf7c1f41bc669f9aa7ef6bbe856553",
          "verified_class_declarations": [
            {
              "class": "WelcomeScreen",
              "declaration_line": 32
            },
            {
              "class": "_Step",
              "declaration_line": 169
            }
          ]
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0427",
          "path": "evidence/host/baseline-375/welcome-light-1.png",
          "sha256": "8a072c52014a290c1cc2802c8fe9c8f74c580d23822e6fcb49445a60367bd70c",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0428",
          "path": "evidence/host/baseline-375/welcome_b-dark-1.png",
          "sha256": "b74cda9dedf172496fe146249dbeafb61aecdd9f11e67f90173160ca639902c1",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The introduction says both setup steps are optional. Numbered Site/Rig steps explain purpose before actions; Start planning is the completion action.",
          "evidence_ids": [
            "EVD-0427",
            "EVD-0428"
          ]
        },
        "vertical_rhythm": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Steps repeat title/current-choice/explanation/action rhythm. Camera choices wrap with regular gaps; completion is separated from setup.",
          "evidence_ids": [
            "EVD-0427",
            "EVD-0428"
          ]
        },
        "composition": {
          "verdict": "ACCEPTED_TRADEOFF_WITH_EXISTING_OWNER_CHOICE",
          "assessment": "The sequence is understandable, but completion is below the first viewport: the existing W1/VQA-029 owner choice, not a newly invented mandatory defect.",
          "evidence_ids": [
            "EVD-0427",
            "EVD-0428"
          ]
        },
        "density": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The first viewport is text-heavy to explain setup and privacy. The lower view still preserves space for camera choices and import/manual alternatives.",
          "evidence_ids": [
            "EVD-0427",
            "EVD-0428"
          ]
        },
        "grouping": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Site and equipment are distinct tasks. Camera prerequisites precede disabled import/manual actions, with saved-rig selection as another route.",
          "evidence_ids": [
            "EVD-0427",
            "EVD-0428"
          ]
        },
        "redundant_frames": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Step borders express the numbered workflow and smaller option borders are functional. This accepted variant need not be flattened merely to mimic Settings.",
          "evidence_ids": [
            "EVD-0427",
            "EVD-0428"
          ]
        },
        "typography_consistency": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The conversational16sp body is larger than compact captions; headings/questions still establish a readable hierarchy and full explanations.",
          "evidence_ids": [
            "EVD-0427",
            "EVD-0428"
          ]
        },
        "professional_quality": {
          "verdict": "COHERENT_WITH_EXISTING_OPTIONAL_CHOICE",
          "assessment": "The composition is coherent with an already optional planning-first completion-placement tradeoff. No alternative is adopted.",
          "evidence_ids": [
            "EVD-0427",
            "EVD-0428"
          ]
        }
      },
      "limits": [
        "W1/VQA-029 remains an owner option, not reopened or implemented.",
        "Seeded site/rig context does not prove first-run empty, import, permission, saving or completion behavior."
      ],
      "disposition": "SUPPORTED_IN_OBSERVED_SCOPE",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-conditions-settings/assessment.json"
    },
    {
      "id": "DCS-11",
      "name": "Launch, waiting and failure",
      "families": [
        "F10"
      ],
      "unit_kind": "MAIN_CONDITIONAL_OR_EXPLICIT_COMPONENT_ONLY",
      "source_refs": [
        {
          "file": "lib/presentation/shared/launch_gate.dart",
          "sha256": "bebebacac9b946e08e3046020bb1fe5976701f236b17035806ef7d265ebc3ff2",
          "verified_class_declarations": [
            {
              "class": "LaunchGate",
              "declaration_line": 49
            },
            {
              "class": "_Waiting",
              "declaration_line": 356
            },
            {
              "class": "_Failure",
              "declaration_line": 379
            }
          ]
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0707",
          "path": "reviews/conditions/root-probes/evidence-attempt-04/launch_waiting-dark-375.png",
          "sha256": "adf6be2297f71054999a2734583216937a1fa1d0f8252591cf3bd0b44b948f1f",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0703",
          "path": "reviews/conditions/root-probes/evidence-attempt-04/launch_failure-light-375.png",
          "sha256": "e1b8b449fd61af5f33ce7c8dab44108443b632a32cfabfd72ce3332e797d0d5c",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The current mark is the sole waiting focus. Failure adds a short reason and labelled Try again without competing actions.",
          "evidence_ids": [
            "EVD-0707",
            "EVD-0703"
          ]
        },
        "vertical_rhythm": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The mark stays centered; failure text/action sit below it. The waiting line is subordinate and not crowded.",
          "evidence_ids": [
            "EVD-0707",
            "EVD-0703"
          ]
        },
        "composition": {
          "verdict": "STATIC_SUPPORTED_TEMPORAL_COMPOSITION_INSUFFICIENT",
          "assessment": "Static waiting/failure canvases are controlled. Complete ready-gesture/keyframe transitions are not established by these stills.",
          "evidence_ids": [
            "EVD-0707",
            "EVD-0703"
          ]
        },
        "density": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Sparse content suits an exclusive startup task; no dashboard/decorative copy competes with readiness.",
          "evidence_ids": [
            "EVD-0707",
            "EVD-0703"
          ]
        },
        "grouping": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Mark, readiness indicator and recovery are grouped by state. Retry belongs only to failure.",
          "evidence_ids": [
            "EVD-0707",
            "EVD-0703"
          ]
        },
        "redundant_frames": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "No cards or nested borders surround the mark; the one retry border marks a genuine target.",
          "evidence_ids": [
            "EVD-0707",
            "EVD-0703"
          ]
        },
        "typography_consistency": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The short failure/action text is readable. The identity palette is a documented local contract, not a drift from ordinary settings colors.",
          "evidence_ids": [
            "EVD-0707",
            "EVD-0703"
          ]
        },
        "professional_quality": {
          "verdict": "STATIC_QUALITY_SUPPORTED_MOTION_UNVERIFIED",
          "assessment": "The static states are deliberate. Timing, reduced motion, continuity and platform handover remain visually unverified.",
          "evidence_ids": [
            "EVD-0707",
            "EVD-0703"
          ]
        }
      },
      "limits": [
        "INSUFFICIENT_EVIDENCE for the complete1400ms ready gesture and temporal composition.",
        "No launch/Retry/device/reduced-motion attempt was added."
      ],
      "disposition": "SUPPORTED_IN_OBSERVED_SCOPE",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-conditions-settings/assessment.json"
    },
    {
      "id": "DCS-12",
      "name": "Restoring backup root",
      "families": [
        "F09"
      ],
      "unit_kind": "MAIN_CONDITIONAL_OR_EXPLICIT_COMPONENT_ONLY",
      "source_refs": [
        {
          "file": "lib/presentation/screens/settings/backup_section.dart",
          "sha256": "f2e47f69624e1c4c40e8433f07a86390e0b723439c309b5d5a6ba4973dbb863a",
          "verified_class_declarations": [
            {
              "class": "RestoringBackupApp",
              "declaration_line": 272
            }
          ]
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0310",
          "path": "evidence/host/baseline-375/restore_wait-light-1.png",
          "sha256": "8c86260ab55612f0491c039310e7dfc17cfa716676fd2a3f78dde8cea06667f3",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Spinner and restoring status are primary; the next sentence explains the restart.",
          "evidence_ids": [
            "EVD-0310"
          ]
        },
        "vertical_rhythm": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Indicator and two lines form a centered group with comfortable separation.",
          "evidence_ids": [
            "EVD-0310"
          ]
        },
        "composition": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "One exclusive busy canvas matches the restoration state; no editable controls compete behind it.",
          "evidence_ids": [
            "EVD-0310"
          ]
        },
        "density": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Low density is appropriate for a noninteractive data operation; extra framing would not add useful information.",
          "evidence_ids": [
            "EVD-0310"
          ]
        },
        "grouping": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Status and next-step explanation are one compact unit.",
          "evidence_ids": [
            "EVD-0310"
          ]
        },
        "redundant_frames": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "No cards, nested frames or decorative containers.",
          "evidence_ids": [
            "EVD-0310"
          ]
        },
        "typography_consistency": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Two short body lines are readable; centering suits concise status content.",
          "evidence_ids": [
            "EVD-0310"
          ]
        },
        "professional_quality": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "This static waiting composition is clean. Duration, progress accuracy and eventual outcome are not established.",
          "evidence_ids": [
            "EVD-0310"
          ]
        }
      },
      "limits": [
        "Only a synthetic static busy state; no real restore or temporal behavior."
      ],
      "disposition": "SUPPORTED_IN_OBSERVED_SCOPE",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-conditions-settings/assessment.json"
    },
    {
      "id": "DCS-13",
      "name": "Unsupported older data",
      "families": [
        "F10"
      ],
      "unit_kind": "MAIN_CONDITIONAL_OR_EXPLICIT_COMPONENT_ONLY",
      "source_refs": [
        {
          "file": "lib/presentation/screens/startup/unsupported_database_screen.dart",
          "sha256": "557d57819b31123b01e472f884cde8640a32b89fa83250c02e27b4b2312decac",
          "verified_class_declarations": [
            {
              "class": "UnsupportedDatabaseApp",
              "declaration_line": 17
            },
            {
              "class": "UnsupportedDatabaseScreen",
              "declaration_line": 53
            }
          ]
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0586",
          "path": "reviews/library/supplemental-host/frames/unsupported_older-light-1.png",
          "sha256": "1ca1a989bf29ceb65d7eeb66793dfdbe26636539c82df82205259e7d03ce097a",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "A bold stop reason follows the app title and precedes the specific data consequence. One fresh-start action follows the preservation explanation.",
          "evidence_ids": [
            "EVD-0586"
          ]
        },
        "vertical_rhythm": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Clear heading/body and body/action gaps make the explanation readable; empty space is not filled artificially.",
          "evidence_ids": [
            "EVD-0586"
          ]
        },
        "composition": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "A focused blocking explanation is appropriate here. Fresh-start consequences are explained before action.",
          "evidence_ids": [
            "EVD-0586"
          ]
        },
        "density": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The short exceptional-state copy is proportionate. Compacting the blank lower canvas would not expose useful content.",
          "evidence_ids": [
            "EVD-0586"
          ]
        },
        "grouping": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Cause, unchanged-data assurance and fresh-start choice form one logical unit.",
          "evidence_ids": [
            "EVD-0586"
          ]
        },
        "redundant_frames": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "No outer card repeats the page boundary. Only the recovery action is filled/framed.",
          "evidence_ids": [
            "EVD-0586"
          ]
        },
        "typography_consistency": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "App title,20sp-class stop heading and16sp body retain the product hierarchy; the explicit version value fits the flow.",
          "evidence_ids": [
            "EVD-0586"
          ]
        },
        "professional_quality": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The exceptional screen is clear and restrained. Preservation copy is visible, but pixels do not prove filesystem effects.",
          "evidence_ids": [
            "EVD-0586"
          ]
        }
      },
      "limits": [
        "Only a static source-matched100% view. No reset/update/file operation or physical failure was executed."
      ],
      "disposition": "SUPPORTED_IN_OBSERVED_SCOPE",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-conditions-settings/assessment.json"
    },
    {
      "id": "DCS-14",
      "name": "Unsupported newer data",
      "families": [
        "F10"
      ],
      "unit_kind": "MAIN_CONDITIONAL_OR_EXPLICIT_COMPONENT_ONLY",
      "source_refs": [
        {
          "file": "lib/presentation/screens/startup/unsupported_database_screen.dart",
          "sha256": "557d57819b31123b01e472f884cde8640a32b89fa83250c02e27b4b2312decac",
          "verified_class_declarations": [
            {
              "class": "UnsupportedDatabaseApp",
              "declaration_line": 17
            },
            {
              "class": "UnsupportedDatabaseScreen",
              "declaration_line": 53
            }
          ]
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0581",
          "path": "reviews/library/supplemental-host/frames/unsupported_newer-dark-1.png",
          "sha256": "068c8d92b26e5e4c0b6b83edfd9460df016c73d25fb6d73b28a0c8c17469cde3",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "A bold stop reason follows the app title and precedes the specific data consequence. No destructive action is offered for newer data.",
          "evidence_ids": [
            "EVD-0581"
          ]
        },
        "vertical_rhythm": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Clear heading/body and body/action gaps make the explanation readable; empty space is not filled artificially.",
          "evidence_ids": [
            "EVD-0581"
          ]
        },
        "composition": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "A focused blocking explanation is appropriate here. Install-latest guidance is explicit.",
          "evidence_ids": [
            "EVD-0581"
          ]
        },
        "density": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The short exceptional-state copy is proportionate. Compacting the blank lower canvas would not expose useful content.",
          "evidence_ids": [
            "EVD-0581"
          ]
        },
        "grouping": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Cause, unchanged-data assurance and upgrade instruction form one logical unit.",
          "evidence_ids": [
            "EVD-0581"
          ]
        },
        "redundant_frames": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "No outer card repeats the page boundary. Absence of a reset action is intentional.",
          "evidence_ids": [
            "EVD-0581"
          ]
        },
        "typography_consistency": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "App title,20sp-class stop heading and16sp body retain the product hierarchy; the explicit version value fits the flow.",
          "evidence_ids": [
            "EVD-0581"
          ]
        },
        "professional_quality": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The exceptional screen is clear and restrained. Preservation copy is visible, but pixels do not prove filesystem effects.",
          "evidence_ids": [
            "EVD-0581"
          ]
        }
      },
      "limits": [
        "Only a static source-matched100% view. No reset/update/file operation or physical failure was executed."
      ],
      "disposition": "SUPPORTED_IN_OBSERVED_SCOPE",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-conditions-settings/assessment.json"
    },
    {
      "id": "DCS-15",
      "name": "Restore outcome notice (component only)",
      "families": [
        "F09"
      ],
      "unit_kind": "MAIN_CONDITIONAL_OR_EXPLICIT_COMPONENT_ONLY",
      "source_refs": [
        {
          "file": "lib/presentation/screens/settings/backup_section.dart",
          "sha256": "f2e47f69624e1c4c40e8433f07a86390e0b723439c309b5d5a6ba4973dbb863a",
          "verified_class_declarations": [
            {
              "class": "RestoreOutcomeNotice",
              "declaration_line": 233
            }
          ]
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-1047",
          "path": "reviews/conditions/root-state-reconciliation/restore-outcome-probe/attempt-02/applied_visible_once-light.png",
          "sha256": "4ad4ab602b69549151d16b2342277f1b1ca9fd8034f09fda3a0dfce6f650ca70",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "Within the actual band, outcome copy leads and acknowledgement/dismissal follows. The fixture title is excluded from production hierarchy.",
          "evidence_ids": [
            "EVD-1047"
          ]
        },
        "vertical_rhythm": {
          "verdict": "INSUFFICIENT_EVIDENCE_FOR_FULL_SCREEN",
          "assessment": "Notice text/actions fit without overlap, but surrounding page rhythm is not assessable from the fixture.",
          "evidence_ids": [
            "EVD-1047"
          ]
        },
        "composition": {
          "verdict": "INSUFFICIENT_EVIDENCE_FOR_FULL_SCREEN",
          "assessment": "The actual notice is visible; the Restore outcome fixture title/body are harness content. Whole first-screen integration is insufficient.",
          "evidence_ids": [
            "EVD-1047"
          ]
        },
        "density": {
          "verdict": "INSUFFICIENT_EVIDENCE_FOR_FULL_SCREEN",
          "assessment": "The short sentence is readable; density of the actual app underneath is unknown.",
          "evidence_ids": [
            "EVD-1047"
          ]
        },
        "grouping": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "One band contains outcome and controls; no assumption is made about app content grouping.",
          "evidence_ids": [
            "EVD-1047"
          ]
        },
        "redundant_frames": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "A single separating band avoids stacked frames. Two dismiss affordances alone do not establish harmful redundancy.",
          "evidence_ids": [
            "EVD-1047"
          ]
        },
        "typography_consistency": {
          "verdict": "COHERENT_IN_OBSERVED_SCOPE",
          "assessment": "The real notice copy/actions are readable. Fixture heading/body are excluded from product typography judgments.",
          "evidence_ids": [
            "EVD-1047"
          ]
        },
        "professional_quality": {
          "verdict": "INSUFFICIENT_EVIDENCE_FOR_FULL_SCREEN",
          "assessment": "The notice component is restrained; whole production-screen composition cannot be approved from this fixture.",
          "evidence_ids": [
            "EVD-1047"
          ]
        }
      },
      "limits": [
        "INSUFFICIENT_EVIDENCE for production first-screen integration or native restore outcome.",
        "Only the real component is judged; harness-only content is excluded."
      ],
      "disposition": "COMPONENT_ONLY_FULL_COMPOSITION_INSUFFICIENT",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-conditions-settings/assessment.json"
    },
    {
      "id": "DCS-16",
      "name": "Flutter open-source licence list/detail",
      "families": [
        "F09"
      ],
      "unit_kind": "MAIN_CONDITIONAL_OR_EXPLICIT_COMPONENT_ONLY",
      "source_refs": [
        {
          "file": "lib/presentation/screens/about/about_screen.dart",
          "sha256": "1dec96c344dd2814cf89b9469b4f88166d37d7b41571150195ee5625e9240b2e",
          "verified_class_declarations": []
        }
      ],
      "evidence": [],
      "dimensions": {
        "hierarchy": {
          "verdict": "INSUFFICIENT_EVIDENCE",
          "assessment": "INSUFFICIENT_EVIDENCE: no actual full LicensePage capture was opened.",
          "evidence_ids": []
        },
        "vertical_rhythm": {
          "verdict": "INSUFFICIENT_EVIDENCE",
          "assessment": "INSUFFICIENT_EVIDENCE: no actual full LicensePage capture was opened.",
          "evidence_ids": []
        },
        "composition": {
          "verdict": "INSUFFICIENT_EVIDENCE",
          "assessment": "INSUFFICIENT_EVIDENCE: no actual full LicensePage capture was opened.",
          "evidence_ids": []
        },
        "density": {
          "verdict": "INSUFFICIENT_EVIDENCE",
          "assessment": "INSUFFICIENT_EVIDENCE: no actual full LicensePage capture was opened.",
          "evidence_ids": []
        },
        "grouping": {
          "verdict": "INSUFFICIENT_EVIDENCE",
          "assessment": "INSUFFICIENT_EVIDENCE: no actual full LicensePage capture was opened.",
          "evidence_ids": []
        },
        "redundant_frames": {
          "verdict": "INSUFFICIENT_EVIDENCE",
          "assessment": "INSUFFICIENT_EVIDENCE: no actual full LicensePage capture was opened.",
          "evidence_ids": []
        },
        "typography_consistency": {
          "verdict": "INSUFFICIENT_EVIDENCE",
          "assessment": "INSUFFICIENT_EVIDENCE: no actual full LicensePage capture was opened.",
          "evidence_ids": []
        },
        "professional_quality": {
          "verdict": "INSUFFICIENT_EVIDENCE",
          "assessment": "INSUFFICIENT_EVIDENCE: no actual full LicensePage capture was opened.",
          "evidence_ids": []
        }
      },
      "limits": [
        "The About route/action exists, but actual list/detail composition is not inferred from framework defaults, source or tests. No attempt added."
      ],
      "disposition": "INSUFFICIENT_EVIDENCE",
      "review_relation": "CROSS_FAMILY_PEER_DIFFERENT_FROM_ORIGINAL_SPECIALIST",
      "review_book": "reviews/design-closure/peer-conditions-settings/assessment.json"
    },
    {
      "id": "DCL-LIB-01",
      "name": "AddRigPanel",
      "families": [
        "F07"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_OR_HELPER_COMPOSITION",
      "source_refs": [
        {
          "file": "lib/presentation/screens/equipment/add_rig_panel.dart",
          "line": 12,
          "anchor_text": "class AddRigPanel extends StatefulWidget {",
          "sha256": "237a35aa9b33e6d7005741b68c461a5e5f2319cd2aabf15c5d2fe25a2690cac7"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0322",
          "path": "evidence/host/baseline-375/rig_add_sheet-light-1.png",
          "sha256": "9d7c5d08dda2bf7bebec0bbe928816714d0cbc98c5901823c3db8a4d122989b3",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": "One camera question precedes choices and the next-step actions.",
        "vertical_rhythm": "Wrap spacing and the gap before actions separate selection from progression.",
        "composition": "Bottom-sheet content is compact and full-width; it is not a duplicate complete editor.",
        "density": "Four wrapping choices fit without squeezing labels into a horizontal strip.",
        "grouping": "Selection, explanatory note and two next actions form one coherent decision.",
        "redundant_frames": "No separate cards enclose individual choices.",
        "typography_consistency": "Material titleMedium/bodySmall and shared action styles retain Geist.",
        "professional_quality": "Clear gated progression; the unselected state is purposeful, not unexplained disabled UI."
      },
      "limits": [
        "Representative375dp/100% host frames plus existing native Dark Rigs/Targets/map. No per-class Cartesian3theme/native matrix or full accessibility/owner acceptance.",
        "Site-detail and Site-editor top/lower pairs have identical hashes: no extra lower/expanded coverage. Expanded Site-detail optional facts were source-read but not visually reopened in this second look.",
        "Expanded equipment photo-help, every populated Target list/search variant, every editor class/metadata match outcome, every export/permission/IME/state branch are outside this focused visual selection; earlier state books retain their exact dispositions.",
        "Field frames support composition only. Accepted Field colour exception remains; no blanket contrast pass.",
        "Native loaded map is EVD-1001 only. Grey/blank host map is chrome/dialog evidence, never loaded provider-basemap proof.",
        "Existing behavior/state findings and971global mandatory verification gaps are not closed by normal composition frames.",
        "No new design preference is promoted to defect without demonstrated substantial consequence."
      ],
      "disposition": "BOUNDED_COMPOSITION_ASSESSED_NO_NEW_SUBSTANTIAL_CANDIDATE",
      "review_relation": "ORIGINAL_SPECIALIST_SECOND_LOOK; no fresh independent per-unit claim",
      "coordinator_crosscheck_ref": null,
      "review_book": "reviews/design-closure/peer-editors-logbook/assessment.json"
    },
    {
      "id": "DCL-LIB-02",
      "name": "EquipmentSelectionScreen / _showAddRig / photo help",
      "families": [
        "F06",
        "F07"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_OR_HELPER_COMPOSITION",
      "source_refs": [
        {
          "file": "lib/presentation/screens/equipment/equipment_selection_screen.dart",
          "line": 40,
          "anchor_text": "class EquipmentSelectionScreen extends StatefulWidget {",
          "sha256": "1c7aab13e8e385b0e8de0dcd1d997d52347e3dc3d7a7bebde8d0643af66e0cc9"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0810",
          "path": "evidence/android/fixture-rigs-list-dark-100.png",
          "sha256": "30767c419da7f65056c25e0749c7c40563e5df06f0e8e8bd7ba98af7966d15c7",
          "evidence_layer": "NATIVE_VERIFIED"
        },
        {
          "evidence_id": "EVD-0322",
          "path": "evidence/host/baseline-375/rig_add_sheet-light-1.png",
          "sha256": "9d7c5d08dda2bf7bebec0bbe928816714d0cbc98c5901823c3db8a4d122989b3",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": "Search/Add leads, followed by rig identity rows and secondary photo help.",
        "vertical_rhythm": "Joined rows maintain consistent caption spacing and a distinct help gap.",
        "composition": "One list group presents the three rigs; Add opens a separate bounded sheet.",
        "density": "Multi-line technical captions keep sensor and optics context; extra height supports identification.",
        "grouping": "Search/actions, joined records and help have separate responsibilities.",
        "redundant_frames": "No per-fact or per-caption cards; rows share their enclosing group.",
        "typography_consistency": "Rig names lead secondary source/spec captions consistently.",
        "professional_quality": "Readable populated native composition; expanded photo-help body is not visually rechecked here."
      },
      "limits": [
        "Representative375dp/100% host frames plus existing native Dark Rigs/Targets/map. No per-class Cartesian3theme/native matrix or full accessibility/owner acceptance.",
        "Site-detail and Site-editor top/lower pairs have identical hashes: no extra lower/expanded coverage. Expanded Site-detail optional facts were source-read but not visually reopened in this second look.",
        "Expanded equipment photo-help, every populated Target list/search variant, every editor class/metadata match outcome, every export/permission/IME/state branch are outside this focused visual selection; earlier state books retain their exact dispositions.",
        "Field frames support composition only. Accepted Field colour exception remains; no blanket contrast pass.",
        "Native loaded map is EVD-1001 only. Grey/blank host map is chrome/dialog evidence, never loaded provider-basemap proof.",
        "Existing behavior/state findings and971global mandatory verification gaps are not closed by normal composition frames.",
        "No new design preference is promoted to defect without demonstrated substantial consequence."
      ],
      "disposition": "BOUNDED_COMPOSITION_ASSESSED_NO_NEW_SUBSTANTIAL_CANDIDATE",
      "review_relation": "ORIGINAL_SPECIALIST_SECOND_LOOK; no fresh independent per-unit claim",
      "coordinator_crosscheck_ref": null,
      "review_book": "reviews/design-closure/peer-editors-logbook/assessment.json"
    },
    {
      "id": "DCL-LIB-03",
      "name": "RigDetailScreen",
      "families": [
        "F07"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_OR_HELPER_COMPOSITION",
      "source_refs": [
        {
          "file": "lib/presentation/screens/equipment/rig_detail_screen.dart",
          "line": 66,
          "anchor_text": "class RigDetailScreen extends StatefulWidget {",
          "sha256": "2e43e07ad569762b7a6bc7a1298c5f2e1707b9fb63e5210d7ec2c1dca6b329aa"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0094",
          "path": "evidence/host/baseline-375/lib_rig-light-1.png",
          "sha256": "47a5b0d55d94dadfefe961b56cd98a62d1aa414101c0c878284ae2e35d1995a5",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0097",
          "path": "evidence/host/baseline-375/lib_rig_b-light-1.png",
          "sha256": "d3acdbe0980013d85899c26cdadcae09ef86eb66303bae2fb6f955139779ad15",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0338",
          "path": "evidence/host/baseline-375/rig_record_sources-dark-1.png",
          "sha256": "76cd0f2eb8ee089ab834e7c70ff1db9fdb0ef793bd432d0af32040029c84ad9c",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": "Identity/Edit lead Camera and Optics; full record and Delete are later.",
        "vertical_rhythm": "Fact rows are compact; larger group gaps separate identity, facts and destruction.",
        "composition": "Read-only label/value facts and a disclosure support scan then detail.",
        "density": "Full-source mode is intentionally denser; Unknown and provenance remain explicit.",
        "grouping": "Camera, Optics and Optional records are real semantic groups.",
        "redundant_frames": "Full sources expand inside one group; individual facts are not framed cards.",
        "typography_consistency": "Headings, values and secondary provenance have consistent relative emphasis.",
        "professional_quality": "Units and provenance remain legible. The wrapped RAW hint is not the separately confirmed UIA-0011 plan prose case."
      },
      "limits": [
        "Representative375dp/100% host frames plus existing native Dark Rigs/Targets/map. No per-class Cartesian3theme/native matrix or full accessibility/owner acceptance.",
        "Site-detail and Site-editor top/lower pairs have identical hashes: no extra lower/expanded coverage. Expanded Site-detail optional facts were source-read but not visually reopened in this second look.",
        "Expanded equipment photo-help, every populated Target list/search variant, every editor class/metadata match outcome, every export/permission/IME/state branch are outside this focused visual selection; earlier state books retain their exact dispositions.",
        "Field frames support composition only. Accepted Field colour exception remains; no blanket contrast pass.",
        "Native loaded map is EVD-1001 only. Grey/blank host map is chrome/dialog evidence, never loaded provider-basemap proof.",
        "Existing behavior/state findings and971global mandatory verification gaps are not closed by normal composition frames.",
        "No new design preference is promoted to defect without demonstrated substantial consequence."
      ],
      "disposition": "BOUNDED_COMPOSITION_ASSESSED_NO_NEW_SUBSTANTIAL_CANDIDATE",
      "review_relation": "ORIGINAL_SPECIALIST_SECOND_LOOK_PLUS_REPRESENTATIVE_COORDINATOR_CROSSCHECK",
      "coordinator_crosscheck_ref": "reviews/design-closure/coordinator-editors-logbook.json",
      "review_book": "reviews/design-closure/peer-editors-logbook/assessment.json"
    },
    {
      "id": "DCL-LIB-04",
      "name": "_EquipmentEditor.show",
      "families": [
        "F07"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_OR_HELPER_COMPOSITION",
      "source_refs": [
        {
          "file": "lib/presentation/screens/equipment/equipment_editor.dart",
          "line": 51,
          "anchor_text": "class _EquipmentEditor {",
          "sha256": "554a399e3d891648b6e64a4eb61401d01e4e345b0768daa96e9e245999c941a2"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0331",
          "path": "evidence/host/baseline-375/rig_new-light-1.png",
          "sha256": "53673931dcc5eef54dd8e136b5658cba4eeee67ab20f7853c2f3c97779cfe16c",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0334",
          "path": "evidence/host/baseline-375/rig_new_b-light-1.png",
          "sha256": "d5c31528a37ec6dbdf37f44d732326ae84ce926e6275e0c52f278c2062ae3bc7",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0103",
          "path": "evidence/host/baseline-375/lib_rig_edit-light-1.png",
          "sha256": "fa13916d01b4c0d866f3bf8ac4c9fbed364165b73fb1235affb0d88ab3500102",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0106",
          "path": "evidence/host/baseline-375/lib_rig_edit_b-light-1.png",
          "sha256": "b14422348e03daea29bb3f38e5af332bddbd5a7c00015bf87bad8ec1269aef87",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0326",
          "path": "evidence/host/baseline-375/rig_more_open-dark-1.png",
          "sha256": "d7f09c332a15c0a16643d0bfb602573d77db312df03c904c660a2a922d1d6681",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0861",
          "path": "reviews/library/remaining-gap-probes/frames/gap_rig_phone-light-1.png",
          "sha256": "deba0098a8b31525ffe981adde3990be22292b8d6c5b7b4b795fc64120569548",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0922",
          "path": "reviews/library/remaining-gap-probes/frames/gap_rig_astroColour-field-1.png",
          "sha256": "61204851ae683ce65588ac079bf1f290c707718f026568c9e7eb1dfd2eccd0da",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": "Name/intent, camera, sensor and optics follow input dependencies; More is later.",
        "vertical_rhythm": "Stacked full-width fields and attached hints maintain predictable vertical intervals.",
        "composition": "Scroll body and stable equal-width footer support a long scientific form.",
        "density": "Long form and exact 48.214285714285715 aperture text are visible; no clipped value is demonstrated.",
        "grouping": "Sensor, Optics and optional manufacturer/file fields are grouped by purpose.",
        "redundant_frames": "No frame for each input; optional records share one disclosure.",
        "typography_consistency": "Shared caption/value roles and selected camera cues persist across branches.",
        "professional_quality": "Coherent editor; exact editable precision is not a demonstrated defect and must not be rounded by aesthetic preference."
      },
      "limits": [
        "Representative375dp/100% host frames plus existing native Dark Rigs/Targets/map. No per-class Cartesian3theme/native matrix or full accessibility/owner acceptance.",
        "Site-detail and Site-editor top/lower pairs have identical hashes: no extra lower/expanded coverage. Expanded Site-detail optional facts were source-read but not visually reopened in this second look.",
        "Expanded equipment photo-help, every populated Target list/search variant, every editor class/metadata match outcome, every export/permission/IME/state branch are outside this focused visual selection; earlier state books retain their exact dispositions.",
        "Field frames support composition only. Accepted Field colour exception remains; no blanket contrast pass.",
        "Native loaded map is EVD-1001 only. Grey/blank host map is chrome/dialog evidence, never loaded provider-basemap proof.",
        "Existing behavior/state findings and971global mandatory verification gaps are not closed by normal composition frames.",
        "No new design preference is promoted to defect without demonstrated substantial consequence."
      ],
      "disposition": "BOUNDED_COMPOSITION_ASSESSED_NO_NEW_SUBSTANTIAL_CANDIDATE",
      "review_relation": "ORIGINAL_SPECIALIST_SECOND_LOOK_PLUS_REPRESENTATIVE_COORDINATOR_CROSSCHECK",
      "coordinator_crosscheck_ref": "reviews/design-closure/coordinator-editors-logbook.json",
      "review_book": "reviews/design-closure/peer-editors-logbook/assessment.json"
    },
    {
      "id": "DCL-LIB-05",
      "name": "MetadataImportScreen / _EquipmentCard / _Result",
      "families": [
        "F07"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_OR_HELPER_COMPOSITION",
      "source_refs": [
        {
          "file": "lib/presentation/screens/metadata/metadata_import_screen.dart",
          "line": 38,
          "anchor_text": "class MetadataImportScreen extends StatefulWidget {",
          "sha256": "9853e4766338b21dc5280291551b3486f54b8a8fd1a18da0d91cb095170915d0"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0175",
          "path": "evidence/host/baseline-375/metadata-light-1.png",
          "sha256": "05df3d6b08417140b41b5489218fe81e2b74c7c6d27cbb9dcb53e0d94a94cf9c",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0184",
          "path": "evidence/host/baseline-375/metadata_ready-light-1.png",
          "sha256": "1699c4ae9a368131bb3a79937d89bc15f772f7711cfa33ecb31ddac3a8762c35",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0178",
          "path": "evidence/host/baseline-375/metadata_read-light-1.png",
          "sha256": "7e17ffa161962993fc4710683d97ddfe6bbe495b629819f52c39d4741d717733",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0181",
          "path": "evidence/host/baseline-375/metadata_read_b-light-1.png",
          "sha256": "6230ad28665da020203bcab2791f1d31cd8f235a6acc1a0c2a7fa4b0297f06af",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0896",
          "path": "reviews/library/remaining-gap-probes/frames/metadata_gap_match_keep-dark-1.png",
          "sha256": "9ba0c235068c9c9de04fb51bf21a0b41b60b9e37d77fe8c07756cf721d16d9f3",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": "Local-file explanation and Choose lead; equipment decision precedes raw metadata.",
        "vertical_rhythm": "Paragraph/action gap and separate 16dp-padded cards distinguish decision from evidence.",
        "composition": "Conflict switches stay beside saved/file values; full-width Open/Create choices follow.",
        "density": "Raw metadata is long and repetitive because absence/provenance remain explicit; match review is dense but attributable.",
        "grouping": "Equipment proposal and raw file are distinct meaningful cards, not a card for every metadata row.",
        "redundant_frames": "Outlined Material cards differ from flat DocumentSection elsewhere but do not multiply per fact.",
        "typography_consistency": "Material body/default16 and label/source roles are visibly larger than some Library14 prose; Geist remains consistent.",
        "professional_quality": "A local utility density/type variation is real, but no substantial obstruction warrants a new redesign finding."
      },
      "limits": [
        "Representative375dp/100% host frames plus existing native Dark Rigs/Targets/map. No per-class Cartesian3theme/native matrix or full accessibility/owner acceptance.",
        "Site-detail and Site-editor top/lower pairs have identical hashes: no extra lower/expanded coverage. Expanded Site-detail optional facts were source-read but not visually reopened in this second look.",
        "Expanded equipment photo-help, every populated Target list/search variant, every editor class/metadata match outcome, every export/permission/IME/state branch are outside this focused visual selection; earlier state books retain their exact dispositions.",
        "Field frames support composition only. Accepted Field colour exception remains; no blanket contrast pass.",
        "Native loaded map is EVD-1001 only. Grey/blank host map is chrome/dialog evidence, never loaded provider-basemap proof.",
        "Existing behavior/state findings and971global mandatory verification gaps are not closed by normal composition frames.",
        "No new design preference is promoted to defect without demonstrated substantial consequence."
      ],
      "disposition": "BOUNDED_COMPOSITION_ASSESSED_NO_NEW_SUBSTANTIAL_CANDIDATE",
      "review_relation": "ORIGINAL_SPECIALIST_SECOND_LOOK_PLUS_REPRESENTATIVE_COORDINATOR_CROSSCHECK",
      "coordinator_crosscheck_ref": "reviews/design-closure/coordinator-editors-logbook.json",
      "review_book": "reviews/design-closure/peer-editors-logbook/assessment.json"
    },
    {
      "id": "DCL-LIB-06",
      "name": "TargetSelectionScreen",
      "families": [
        "F06",
        "F07"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_OR_HELPER_COMPOSITION",
      "source_refs": [
        {
          "file": "lib/presentation/screens/target/target_selection_screen.dart",
          "line": 34,
          "anchor_text": "class TargetSelectionScreen extends StatefulWidget {",
          "sha256": "c896df94fe2c83f6bb7ce90fa5e3a5bd136179dca5de1cf91cfe8cc445730bec"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-1095",
          "path": "evidence/android/state-round2/targets-before-add.png",
          "sha256": "49cf2c3f69c3c9a7bfcc5e168399a309b298ac2eb7e651c775bb0948c0dc1187",
          "evidence_layer": "NATIVE_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": "Search/Add precede Your targets and Catalogue.",
        "vertical_rhythm": "Large group gaps separate custom and catalogue lists; joined catalogue rows keep regular rhythm.",
        "composition": "Native full-width list and type captions match record-selection purpose.",
        "density": "Visible catalogue names are concise; list extends beyond viewport naturally.",
        "grouping": "Custom empty state is separate from the bundled-source catalogue.",
        "redundant_frames": "No individual card per catalogue result.",
        "typography_consistency": "Names are primary; object types/source text are secondary.",
        "professional_quality": "Clear record ownership. Populated custom-list/search branches were not reopened in this design pass."
      },
      "limits": [
        "Representative375dp/100% host frames plus existing native Dark Rigs/Targets/map. No per-class Cartesian3theme/native matrix or full accessibility/owner acceptance.",
        "Site-detail and Site-editor top/lower pairs have identical hashes: no extra lower/expanded coverage. Expanded Site-detail optional facts were source-read but not visually reopened in this second look.",
        "Expanded equipment photo-help, every populated Target list/search variant, every editor class/metadata match outcome, every export/permission/IME/state branch are outside this focused visual selection; earlier state books retain their exact dispositions.",
        "Field frames support composition only. Accepted Field colour exception remains; no blanket contrast pass.",
        "Native loaded map is EVD-1001 only. Grey/blank host map is chrome/dialog evidence, never loaded provider-basemap proof.",
        "Existing behavior/state findings and971global mandatory verification gaps are not closed by normal composition frames.",
        "No new design preference is promoted to defect without demonstrated substantial consequence."
      ],
      "disposition": "BOUNDED_COMPOSITION_ASSESSED_NO_NEW_SUBSTANTIAL_CANDIDATE",
      "review_relation": "ORIGINAL_SPECIALIST_SECOND_LOOK; no fresh independent per-unit claim",
      "coordinator_crosscheck_ref": null,
      "review_book": "reviews/design-closure/peer-editors-logbook/assessment.json"
    },
    {
      "id": "DCL-LIB-07",
      "name": "TargetDetailScreen",
      "families": [
        "F07"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_OR_HELPER_COMPOSITION",
      "source_refs": [
        {
          "file": "lib/presentation/screens/target/target_detail_screen.dart",
          "line": 30,
          "anchor_text": "class TargetDetailScreen extends StatefulWidget {",
          "sha256": "b4ae2e2a6a91deaede8b8605fa4cb7cb5a1df11a72d640b89a90335ff7eca427"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0127",
          "path": "evidence/host/baseline-375/lib_target-light-1.png",
          "sha256": "d2792662087d0f7a30bbd72e14501918878cb3c44016909b8e36e59867dec375",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0130",
          "path": "evidence/host/baseline-375/lib_target_b-light-1.png",
          "sha256": "e1214daf6d074ead6cf887c9c209752912a489c11e94ff5f9b76e5387f76a7c9",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0905",
          "path": "reviews/library/remaining-gap-probes/frames/gap_custom_target-dark-1.png",
          "sha256": "e8d49818f0496b585392d95dff2ebf0d312f5c36098906d1370fbf245e76b883",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": "Catalogue/custom identity and Edit precede facts and Plan/Delete.",
        "vertical_rhythm": "Fact rhythm is compact; meaningful group spacing separates action ownership.",
        "composition": "Label/value layout preserves units; catalogue Source occupies a full-width line.",
        "density": "Coordinate labels wrap without dropping J2000; full names and Unknown values remain readable.",
        "grouping": "Identity, scientific facts and planning/destructive actions are separate.",
        "redundant_frames": "Facts share one group; no decorative frame for each quantity.",
        "typography_consistency": "Fact labels are secondary, values primary, Edit and Plan have distinct emphasis.",
        "professional_quality": "Strong scan/detail balance for the two inspected catalogue/custom variants."
      },
      "limits": [
        "Representative375dp/100% host frames plus existing native Dark Rigs/Targets/map. No per-class Cartesian3theme/native matrix or full accessibility/owner acceptance.",
        "Site-detail and Site-editor top/lower pairs have identical hashes: no extra lower/expanded coverage. Expanded Site-detail optional facts were source-read but not visually reopened in this second look.",
        "Expanded equipment photo-help, every populated Target list/search variant, every editor class/metadata match outcome, every export/permission/IME/state branch are outside this focused visual selection; earlier state books retain their exact dispositions.",
        "Field frames support composition only. Accepted Field colour exception remains; no blanket contrast pass.",
        "Native loaded map is EVD-1001 only. Grey/blank host map is chrome/dialog evidence, never loaded provider-basemap proof.",
        "Existing behavior/state findings and971global mandatory verification gaps are not closed by normal composition frames.",
        "No new design preference is promoted to defect without demonstrated substantial consequence."
      ],
      "disposition": "BOUNDED_COMPOSITION_ASSESSED_NO_NEW_SUBSTANTIAL_CANDIDATE",
      "review_relation": "ORIGINAL_SPECIALIST_SECOND_LOOK_PLUS_REPRESENTATIVE_COORDINATOR_CROSSCHECK",
      "coordinator_crosscheck_ref": "reviews/design-closure/coordinator-editors-logbook.json",
      "review_book": "reviews/design-closure/peer-editors-logbook/assessment.json"
    },
    {
      "id": "DCL-LIB-08",
      "name": "TargetEditorScreen",
      "families": [
        "F07"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_OR_HELPER_COMPOSITION",
      "source_refs": [
        {
          "file": "lib/presentation/screens/target/target_editor_screen.dart",
          "line": 36,
          "anchor_text": "class TargetEditorScreen extends StatefulWidget {",
          "sha256": "1bae0d630b1a143e1098a2cd295f1fbf2b190640c1469184599e0b79e83abd9c"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0133",
          "path": "evidence/host/baseline-375/lib_target_new-light-1.png",
          "sha256": "f4ccb4152429e63e2b5b46c8f9cf1171693291cd106e0b8c55dcb9d1f2898db0",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0136",
          "path": "evidence/host/baseline-375/lib_target_new_b-light-1.png",
          "sha256": "783c6023e7a62eecd0d9766d106da63b79ae0ba823b09fb03d4bb9ffc9b9ba93",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": "Name/type precede required J2000 coordinates, then optional quantities.",
        "vertical_rhythm": "Full-width RA/Dec and attached examples avoid cramped paired inputs.",
        "composition": "Long form scrolls above a stable Save/Cancel footer.",
        "density": "Coordinate examples and bounds add useful density; optional absence is explicit.",
        "grouping": "Identity/type, coordinates and optional facts are three task groups.",
        "redundant_frames": "Several inputs share each group rather than independent cards.",
        "typography_consistency": "Field labels, values and secondary help follow shared roles.",
        "professional_quality": "Normal Add composition is coherent; UIA-0003 pending ownership remains a separate behavior defect, not visual approval."
      },
      "limits": [
        "Representative375dp/100% host frames plus existing native Dark Rigs/Targets/map. No per-class Cartesian3theme/native matrix or full accessibility/owner acceptance.",
        "Site-detail and Site-editor top/lower pairs have identical hashes: no extra lower/expanded coverage. Expanded Site-detail optional facts were source-read but not visually reopened in this second look.",
        "Expanded equipment photo-help, every populated Target list/search variant, every editor class/metadata match outcome, every export/permission/IME/state branch are outside this focused visual selection; earlier state books retain their exact dispositions.",
        "Field frames support composition only. Accepted Field colour exception remains; no blanket contrast pass.",
        "Native loaded map is EVD-1001 only. Grey/blank host map is chrome/dialog evidence, never loaded provider-basemap proof.",
        "Existing behavior/state findings and971global mandatory verification gaps are not closed by normal composition frames.",
        "No new design preference is promoted to defect without demonstrated substantial consequence."
      ],
      "disposition": "BOUNDED_COMPOSITION_ASSESSED_NO_NEW_SUBSTANTIAL_CANDIDATE",
      "review_relation": "ORIGINAL_SPECIALIST_SECOND_LOOK_PLUS_REPRESENTATIVE_COORDINATOR_CROSSCHECK",
      "coordinator_crosscheck_ref": "reviews/design-closure/coordinator-editors-logbook.json",
      "review_book": "reviews/design-closure/peer-editors-logbook/assessment.json"
    },
    {
      "id": "DCL-LIB-09",
      "name": "SitesScreen",
      "families": [
        "F06",
        "F07"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_OR_HELPER_COMPOSITION",
      "source_refs": [
        {
          "file": "lib/presentation/screens/sites/sites_screen.dart",
          "line": 36,
          "anchor_text": "class SitesScreen extends StatefulWidget {",
          "sha256": "b45355fa5de54567d025557790978c995ffc8be81cfcc6b733fbec13a6dce2f2"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0058",
          "path": "evidence/host/baseline-375/geo_sites-light-1.png",
          "sha256": "854e1de73122325fa88c633f4fb346566a149bccdfc8143a0056f91755fe43e8",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0061",
          "path": "evidence/host/baseline-375/geo_transient-light-1.png",
          "sha256": "ec1d97b85d3fc5db273a9ad20eb8a96f07116000f086622d25d36a5b80d6fa65",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": "Search/Add precede selected saved/transient positions and alternative position actions.",
        "vertical_rhythm": "Joined site rows and the gap before alternatives form a regular list.",
        "composition": "Radio selection and edit/plus affordances flank readable names/coordinates.",
        "density": "Zone and Not saved wrap in captions without dropping coordinates.",
        "grouping": "Saved/current-position choices are distinct from Use another position.",
        "redundant_frames": "No separate card for every coordinate or edit icon.",
        "typography_consistency": "Names lead secondary coordinate/zone lines consistently.",
        "professional_quality": "Transient ownership is explicit; the inspected rows show no misattribution."
      },
      "limits": [
        "Representative375dp/100% host frames plus existing native Dark Rigs/Targets/map. No per-class Cartesian3theme/native matrix or full accessibility/owner acceptance.",
        "Site-detail and Site-editor top/lower pairs have identical hashes: no extra lower/expanded coverage. Expanded Site-detail optional facts were source-read but not visually reopened in this second look.",
        "Expanded equipment photo-help, every populated Target list/search variant, every editor class/metadata match outcome, every export/permission/IME/state branch are outside this focused visual selection; earlier state books retain their exact dispositions.",
        "Field frames support composition only. Accepted Field colour exception remains; no blanket contrast pass.",
        "Native loaded map is EVD-1001 only. Grey/blank host map is chrome/dialog evidence, never loaded provider-basemap proof.",
        "Existing behavior/state findings and971global mandatory verification gaps are not closed by normal composition frames.",
        "No new design preference is promoted to defect without demonstrated substantial consequence."
      ],
      "disposition": "BOUNDED_COMPOSITION_ASSESSED_NO_NEW_SUBSTANTIAL_CANDIDATE",
      "review_relation": "ORIGINAL_SPECIALIST_SECOND_LOOK; no fresh independent per-unit claim",
      "coordinator_crosscheck_ref": null,
      "review_book": "reviews/design-closure/peer-editors-logbook/assessment.json"
    },
    {
      "id": "DCL-LIB-10",
      "name": "SiteDetailScreen",
      "families": [
        "F07"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_OR_HELPER_COMPOSITION",
      "source_refs": [
        {
          "file": "lib/presentation/screens/sites/site_detail_screen.dart",
          "line": 56,
          "anchor_text": "class SiteDetailScreen extends StatefulWidget {",
          "sha256": "d993fac2d2874e76fa4c1e847ef2c5d232e978887626f85e610edc73da059517"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0115",
          "path": "evidence/host/baseline-375/lib_site-light-1.png",
          "sha256": "e1556e99b160f3fc4d87792f4f111e2208359e84dd32a6793f82606c7c315597",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0118",
          "path": "evidence/host/baseline-375/lib_site_b-light-1.png",
          "sha256": "e1556e99b160f3fc4d87792f4f111e2208359e84dd32a6793f82606c7c315597",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": "Planning role and Edit/Delete lead position/time-zone facts.",
        "vertical_rhythm": "Three clear groups avoid compressing helper text against facts.",
        "composition": "Compact read-only summary with optional details disclosure reduces initial burden.",
        "density": "Collapsed optional data keeps the first screen short.",
        "grouping": "Action ownership, position and optional sky/notes data are separate.",
        "redundant_frames": "Facts share a surface; no card per latitude/longitude.",
        "typography_consistency": "Secondary coordinate explanations stay below aligned values.",
        "professional_quality": "Good collapsed summary. The two selected frames are byte-identical; expanded detail body is a visual gap in this second look."
      },
      "limits": [
        "Representative375dp/100% host frames plus existing native Dark Rigs/Targets/map. No per-class Cartesian3theme/native matrix or full accessibility/owner acceptance.",
        "Site-detail and Site-editor top/lower pairs have identical hashes: no extra lower/expanded coverage. Expanded Site-detail optional facts were source-read but not visually reopened in this second look.",
        "Expanded equipment photo-help, every populated Target list/search variant, every editor class/metadata match outcome, every export/permission/IME/state branch are outside this focused visual selection; earlier state books retain their exact dispositions.",
        "Field frames support composition only. Accepted Field colour exception remains; no blanket contrast pass.",
        "Native loaded map is EVD-1001 only. Grey/blank host map is chrome/dialog evidence, never loaded provider-basemap proof.",
        "Existing behavior/state findings and971global mandatory verification gaps are not closed by normal composition frames.",
        "No new design preference is promoted to defect without demonstrated substantial consequence."
      ],
      "disposition": "BOUNDED_COMPOSITION_ASSESSED_NO_NEW_SUBSTANTIAL_CANDIDATE",
      "review_relation": "ORIGINAL_SPECIALIST_SECOND_LOOK_PLUS_REPRESENTATIVE_COORDINATOR_CROSSCHECK",
      "coordinator_crosscheck_ref": "reviews/design-closure/coordinator-editors-logbook.json",
      "review_book": "reviews/design-closure/peer-editors-logbook/assessment.json"
    },
    {
      "id": "DCL-LIB-11",
      "name": "SiteEditorScreen",
      "families": [
        "F07"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_OR_HELPER_COMPOSITION",
      "source_refs": [
        {
          "file": "lib/presentation/screens/sites/site_editor_screen.dart",
          "line": 79,
          "anchor_text": "class SiteEditorScreen extends StatefulWidget {",
          "sha256": "72156fc93fb6521c5ce5507e8c5a1273f58cb7cc729598ac6dc294d6cdf4a55a"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0121",
          "path": "evidence/host/baseline-375/lib_site_edit-light-1.png",
          "sha256": "2c361dbe756b914fb01403cdbe782804b67552211e3c0aa10cd2751c922614da",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0124",
          "path": "evidence/host/baseline-375/lib_site_edit_b-light-1.png",
          "sha256": "2c361dbe756b914fb01403cdbe782804b67552211e3c0aa10cd2751c922614da",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0053",
          "path": "evidence/host/baseline-375/geo_more-dark-1.png",
          "sha256": "8b389b1590e18dcdf440ff0d251f87dbd8f2a78c0b77d8d8c9653123e99ea257",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": "Position comes before site name/time zone, then optional details.",
        "vertical_rhythm": "Paired decimal coordinate fields fit this view; later single fields retain full width.",
        "composition": "Map/current-position choices, form groups and fixed footer retain a clear task sequence.",
        "density": "Optional elevation/Bortle/SQM/source/notes are long but disclosed; no fabricated conversion shortcuts.",
        "grouping": "Position, identity/zone and More form meaningful sections.",
        "redundant_frames": "No additional border/frame around each optional explanation.",
        "typography_consistency": "Common labels/hints/selected values persist across Light top and Dark More.",
        "professional_quality": "Coherent normal editor; duplicated top/lower bytes do not establish extra scroll coverage or OS/permission variants."
      },
      "limits": [
        "Representative375dp/100% host frames plus existing native Dark Rigs/Targets/map. No per-class Cartesian3theme/native matrix or full accessibility/owner acceptance.",
        "Site-detail and Site-editor top/lower pairs have identical hashes: no extra lower/expanded coverage. Expanded Site-detail optional facts were source-read but not visually reopened in this second look.",
        "Expanded equipment photo-help, every populated Target list/search variant, every editor class/metadata match outcome, every export/permission/IME/state branch are outside this focused visual selection; earlier state books retain their exact dispositions.",
        "Field frames support composition only. Accepted Field colour exception remains; no blanket contrast pass.",
        "Native loaded map is EVD-1001 only. Grey/blank host map is chrome/dialog evidence, never loaded provider-basemap proof.",
        "Existing behavior/state findings and971global mandatory verification gaps are not closed by normal composition frames.",
        "No new design preference is promoted to defect without demonstrated substantial consequence."
      ],
      "disposition": "BOUNDED_COMPOSITION_ASSESSED_NO_NEW_SUBSTANTIAL_CANDIDATE",
      "review_relation": "ORIGINAL_SPECIALIST_SECOND_LOOK_PLUS_REPRESENTATIVE_COORDINATOR_CROSSCHECK",
      "coordinator_crosscheck_ref": "reviews/design-closure/coordinator-editors-logbook.json",
      "review_book": "reviews/design-closure/peer-editors-logbook/assessment.json"
    },
    {
      "id": "DCL-LIB-12",
      "name": "_ZonePickerDialog",
      "families": [
        "F07"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_OR_HELPER_COMPOSITION",
      "source_refs": [
        {
          "file": "lib/presentation/screens/sites/zone_picker_dialog.dart",
          "line": 18,
          "anchor_text": "class _ZonePickerDialog extends StatefulWidget {",
          "sha256": "438967bc1f897d2061cc4059370a7244c9fe393ff1786da131ae68cb81c22ac0"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0433",
          "path": "evidence/host/baseline-375/zone_dialog-light-1.png",
          "sha256": "0d660c1bdc052b2343032e1c0e7e0bb749da69fec459c514399d7371338b0577",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": "Title/search lead; selected Unknown includes the solar-time consequence.",
        "vertical_rhythm": "Search, current choice, list and Cancel have clear spacing.",
        "composition": "Tall dialog allocates most area to the scrollable zone list.",
        "density": "Zone names remain single readable rows; explanation occurs only on Unknown.",
        "grouping": "Unknown and named zones are separated without nested cards.",
        "redundant_frames": "One dialog frame; no row cards.",
        "typography_consistency": "Dialog title, standard search field and smaller zone rows have readable rank.",
        "professional_quality": "Functional choice composition; no keyboard/long-query acceptance inferred from this static frame."
      },
      "limits": [
        "Representative375dp/100% host frames plus existing native Dark Rigs/Targets/map. No per-class Cartesian3theme/native matrix or full accessibility/owner acceptance.",
        "Site-detail and Site-editor top/lower pairs have identical hashes: no extra lower/expanded coverage. Expanded Site-detail optional facts were source-read but not visually reopened in this second look.",
        "Expanded equipment photo-help, every populated Target list/search variant, every editor class/metadata match outcome, every export/permission/IME/state branch are outside this focused visual selection; earlier state books retain their exact dispositions.",
        "Field frames support composition only. Accepted Field colour exception remains; no blanket contrast pass.",
        "Native loaded map is EVD-1001 only. Grey/blank host map is chrome/dialog evidence, never loaded provider-basemap proof.",
        "Existing behavior/state findings and971global mandatory verification gaps are not closed by normal composition frames.",
        "No new design preference is promoted to defect without demonstrated substantial consequence."
      ],
      "disposition": "BOUNDED_COMPOSITION_ASSESSED_NO_NEW_SUBSTANTIAL_CANDIDATE",
      "review_relation": "ORIGINAL_SPECIALIST_SECOND_LOOK; no fresh independent per-unit claim",
      "coordinator_crosscheck_ref": null,
      "review_book": "reviews/design-closure/peer-editors-logbook/assessment.json"
    },
    {
      "id": "DCL-LIB-13",
      "name": "LocationPickerScreen / _CoordinateEntryDialog / _OsmAttribution",
      "families": [
        "F07"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_OR_HELPER_COMPOSITION",
      "source_refs": [
        {
          "file": "lib/presentation/screens/location/location_picker_screen.dart",
          "line": 23,
          "anchor_text": "class LocationPickerScreen extends StatefulWidget {",
          "sha256": "1f565589cd79e0cff885d7343538923c67a1e44090eaec9934e83ba66a8a4e8f"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-1001",
          "path": "evidence/android/fixture-site-map-dark-100.png",
          "sha256": "a5003b91e5e8d950ebcf442819a2018804e05e61fe980302ec822453c0c80c20",
          "evidence_layer": "NATIVE_VERIFIED"
        },
        {
          "evidence_id": "EVD-0172",
          "path": "evidence/host/baseline-375/map_coordinates-light-1.png",
          "sha256": "d670417a3c80e7e3efb3222e6fe2e92c0a6e68863ac8cccc44183d3b00c8e301",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": "Map dominates; selected coordinate and Use remain in a fixed footer.",
        "vertical_rhythm": "Footer label/action, coordinate and Use have clear vertical gaps.",
        "composition": "Native loaded map, marker and location action coexist with a separate exact-value confirmation area.",
        "density": "Coordinates are large enough to scan; attribution is small and must remain present.",
        "grouping": "Map exploration is distinct from explicit selected-point commit; dialog groups coordinate entry.",
        "redundant_frames": "No extra cards obscure the map; one small attribution strip is necessary.",
        "typography_consistency": "Map labels are provider content; app coordinate/footer/dialog roles remain Geist.",
        "professional_quality": "Strong map/commit separation. Existing UIA-0005 attribution hitbox issue remains; grey host dialog background is not loaded-basemap proof."
      },
      "limits": [
        "Representative375dp/100% host frames plus existing native Dark Rigs/Targets/map. No per-class Cartesian3theme/native matrix or full accessibility/owner acceptance.",
        "Site-detail and Site-editor top/lower pairs have identical hashes: no extra lower/expanded coverage. Expanded Site-detail optional facts were source-read but not visually reopened in this second look.",
        "Expanded equipment photo-help, every populated Target list/search variant, every editor class/metadata match outcome, every export/permission/IME/state branch are outside this focused visual selection; earlier state books retain their exact dispositions.",
        "Field frames support composition only. Accepted Field colour exception remains; no blanket contrast pass.",
        "Native loaded map is EVD-1001 only. Grey/blank host map is chrome/dialog evidence, never loaded provider-basemap proof.",
        "Existing behavior/state findings and971global mandatory verification gaps are not closed by normal composition frames.",
        "No new design preference is promoted to defect without demonstrated substantial consequence."
      ],
      "disposition": "BOUNDED_COMPOSITION_ASSESSED_NO_NEW_SUBSTANTIAL_CANDIDATE",
      "review_relation": "ORIGINAL_SPECIALIST_SECOND_LOOK_PLUS_REPRESENTATIVE_COORDINATOR_CROSSCHECK",
      "coordinator_crosscheck_ref": "reviews/design-closure/coordinator-editors-logbook.json",
      "review_book": "reviews/design-closure/peer-editors-logbook/assessment.json"
    },
    {
      "id": "DCL-LIB-14",
      "name": "LogbookScreen",
      "families": [
        "F08"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_OR_HELPER_COMPOSITION",
      "source_refs": [
        {
          "file": "lib/presentation/screens/logbook/logbook_screen.dart",
          "line": 74,
          "anchor_text": "class LogbookScreen extends StatefulWidget {",
          "sha256": "6db298c6d875135170d8d08d5bd60088c9bfc13e40f6dcbceea7a805dd84a61a"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0145",
          "path": "evidence/host/baseline-375/logbook-light-1.png",
          "sha256": "019f73a11bd5845b0a95a87f4ea81e89030b553927372e64624832e2a6698abb",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0157",
          "path": "evidence/host/baseline-375/logbook_lower-light-1.png",
          "sha256": "525c3da93b303fe8f616d17c9d49531086ab8d605c73070f2512f1822bb495be",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0152",
          "path": "evidence/host/baseline-375/logbook_filters-dark-1.png",
          "sha256": "f2f2b841bafa481070466a87bb2754933fb6a57ab8ea2879a69c85ff234e1c14",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": "Search/filter and Progress precede month-grouped entries; title leads integration and recording time.",
        "vertical_rhythm": "Joined rows use consistent bottom rules; long identity/date and right badges increase individual height.",
        "composition": "Right status column preserves Saved versus Not recorded alongside full target/evening date.",
        "density": "Oct wraps onto a second line; this costs scan compactness but does not clip identity/date or demonstrate wrong selection.",
        "grouping": "Month groups and inline expanded filters are meaningful; outcomes and planned/recorded totals remain distinct.",
        "redundant_frames": "No card per entry/fact; continuous month surface avoids repeated frames.",
        "typography_consistency": "RowTitle16 leads body14 details and caption13 integration/provenance; tabular integration supports scanning.",
        "professional_quality": "Specific density tradeoff is acceptable on inspected375dp frames. No new substantial hierarchy defect is established."
      },
      "limits": [
        "Representative375dp/100% host frames plus existing native Dark Rigs/Targets/map. No per-class Cartesian3theme/native matrix or full accessibility/owner acceptance.",
        "Site-detail and Site-editor top/lower pairs have identical hashes: no extra lower/expanded coverage. Expanded Site-detail optional facts were source-read but not visually reopened in this second look.",
        "Expanded equipment photo-help, every populated Target list/search variant, every editor class/metadata match outcome, every export/permission/IME/state branch are outside this focused visual selection; earlier state books retain their exact dispositions.",
        "Field frames support composition only. Accepted Field colour exception remains; no blanket contrast pass.",
        "Native loaded map is EVD-1001 only. Grey/blank host map is chrome/dialog evidence, never loaded provider-basemap proof.",
        "Existing behavior/state findings and971global mandatory verification gaps are not closed by normal composition frames.",
        "No new design preference is promoted to defect without demonstrated substantial consequence."
      ],
      "disposition": "BOUNDED_COMPOSITION_ASSESSED_NO_NEW_SUBSTANTIAL_CANDIDATE",
      "review_relation": "ORIGINAL_SPECIALIST_SECOND_LOOK_PLUS_REPRESENTATIVE_COORDINATOR_CROSSCHECK",
      "coordinator_crosscheck_ref": "reviews/design-closure/coordinator-editors-logbook.json",
      "review_book": "reviews/design-closure/peer-editors-logbook/assessment.json"
    },
    {
      "id": "DCL-LIB-15",
      "name": "_Preview (AstroBin export)",
      "families": [
        "F08"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_OR_HELPER_COMPOSITION",
      "source_refs": [
        {
          "file": "lib/presentation/screens/logbook/astrobin_export.dart",
          "line": 51,
          "anchor_text": "class _Preview extends StatelessWidget {",
          "sha256": "8b1d72a21a85d9b88b321514f85d2bbe4e659ecb1f059f63bc0b4315e68f05ee"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0010",
          "path": "evidence/host/baseline-375/astrobin_preview-light-1.png",
          "sha256": "c4b9c2bd8298518f26550e3a35a583755c14b41da968350895afbf3e14b31c3e",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0032",
          "path": "evidence/host/baseline-375/entry_csv_preview-dark-1.png",
          "sha256": "3dcf4e0e39819519d83b819408bb8f5431fdfeb2a367289777266b49840dd48c",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": "Export purpose/caveat precedes ordered rows and exclusion reasons, then Share.",
        "vertical_rhythm": "Section gaps distinguish included and skipped lists; dialog actions stay separate.",
        "composition": "Single scrollable dialog handles whole-log and short single-entry content.",
        "density": "Whole-log preview is text-dense, but row order and Not included are labelled rather than hidden.",
        "grouping": "Included rows and skipped reasons have separate headings.",
        "redundant_frames": "One dialog; no redundant row cards or empty skipped group in single-entry view.",
        "typography_consistency": "Title/body/section labels and primary Share maintain clear rank.",
        "professional_quality": "Professional disclosure of what will be exported; no actual OS sharing acceptance claimed."
      },
      "limits": [
        "Representative375dp/100% host frames plus existing native Dark Rigs/Targets/map. No per-class Cartesian3theme/native matrix or full accessibility/owner acceptance.",
        "Site-detail and Site-editor top/lower pairs have identical hashes: no extra lower/expanded coverage. Expanded Site-detail optional facts were source-read but not visually reopened in this second look.",
        "Expanded equipment photo-help, every populated Target list/search variant, every editor class/metadata match outcome, every export/permission/IME/state branch are outside this focused visual selection; earlier state books retain their exact dispositions.",
        "Field frames support composition only. Accepted Field colour exception remains; no blanket contrast pass.",
        "Native loaded map is EVD-1001 only. Grey/blank host map is chrome/dialog evidence, never loaded provider-basemap proof.",
        "Existing behavior/state findings and971global mandatory verification gaps are not closed by normal composition frames.",
        "No new design preference is promoted to defect without demonstrated substantial consequence."
      ],
      "disposition": "BOUNDED_COMPOSITION_ASSESSED_NO_NEW_SUBSTANTIAL_CANDIDATE",
      "review_relation": "ORIGINAL_SPECIALIST_SECOND_LOOK; no fresh independent per-unit claim",
      "coordinator_crosscheck_ref": null,
      "review_book": "reviews/design-closure/peer-editors-logbook/assessment.json"
    },
    {
      "id": "DCL-LIB-16",
      "name": "SessionDetailScreen / _PlanVsActual / _Disclosure / _SnapshotSections / _NameDialog",
      "families": [
        "F08"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_OR_HELPER_COMPOSITION",
      "source_refs": [
        {
          "file": "lib/presentation/screens/logbook/session_detail_screen.dart",
          "line": 63,
          "anchor_text": "class SessionDetailScreen extends StatefulWidget {",
          "sha256": "319178a89ae7b2f242febd0b83fad146b1fe28866ca23852bbb2933a2ebdbb58"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0565",
          "path": "reviews/library/supplemental-host/frames/entry-light-1.png",
          "sha256": "344cf48176743b19e177285e2bcaeeb6a955423bcd7536b22d247f4f5185505e",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0568",
          "path": "reviews/library/supplemental-host/frames/entry_b-light-1.png",
          "sha256": "ddc015a3a345be17f12f700385ebbf8e7ac4c5aa4be62466ba9eff18a46784e7",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0571",
          "path": "reviews/library/supplemental-host/frames/entry_c-light-1.png",
          "sha256": "eabb5ca1fe2186e3076e04595fa3c84275ab9e334f916fb845294589c990c7ba",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0878",
          "path": "reviews/library/remaining-gap-probes/frames/gap_entry_gain-dark-1.png",
          "sha256": "4bc55ac9788d29154acf2437d50379936496513625ab2bad02d099fed98de4ff",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0849",
          "path": "reviews/library/remaining-gap-probes/frames/gap_entry_gain_tail-light-1.png",
          "sha256": "47598c50e078d2213a84001fd2e9f4cb9ae4d5f76042c0895c9fe080846b37a5",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0043",
          "path": "evidence/host/baseline-375/entry_snapshot_lower-light-1.png",
          "sha256": "7cc51269ec8f6e9e11c48cb904434f23223a3e4fc9fe85f0cbd3eeeae7ae7c8b",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0035",
          "path": "evidence/host/baseline-375/entry_export_open-dark-1.png",
          "sha256": "e14d6e62af16eaace44db40be8d2aaa0ef4c74e39363970cbd0bca784d4d48d3",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0040",
          "path": "evidence/host/baseline-375/entry_name-light-1.png",
          "sha256": "8bcafa734517e263a0aed4c5a960ced6bdecdb779973a42aad8577f1a030eeb4",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": "Identity/site/zone/outcome and Edit result lead, followed by planned/recorded comparison, snapshot, notes and later actions.",
        "vertical_rhythm": "Regular group separation and compact comparison rows make the long document predictable.",
        "composition": "Two comparison columns, optional gain plots and full-width action stack match different reading tasks.",
        "density": "Content is long because saved snapshot, reported result and cumulative target record are different data; disclosures reduce initial density.",
        "grouping": "Plan/record comparison, snapshot, Notes, cumulative progress and actions are semantically distinct.",
        "redundant_frames": "Embedded TargetProgressCard does not add another enclosing card; one later action group contains export/name/delete.",
        "typography_consistency": "Section headings and body/caption/numeric values remain consistent; legend symbols separate plan/record/comparison.",
        "professional_quality": "Positive detail composition; full exact snapshot/source precision and relative gain caveats are preserved. No universal state/native acceptance follows."
      },
      "limits": [
        "Representative375dp/100% host frames plus existing native Dark Rigs/Targets/map. No per-class Cartesian3theme/native matrix or full accessibility/owner acceptance.",
        "Site-detail and Site-editor top/lower pairs have identical hashes: no extra lower/expanded coverage. Expanded Site-detail optional facts were source-read but not visually reopened in this second look.",
        "Expanded equipment photo-help, every populated Target list/search variant, every editor class/metadata match outcome, every export/permission/IME/state branch are outside this focused visual selection; earlier state books retain their exact dispositions.",
        "Field frames support composition only. Accepted Field colour exception remains; no blanket contrast pass.",
        "Native loaded map is EVD-1001 only. Grey/blank host map is chrome/dialog evidence, never loaded provider-basemap proof.",
        "Existing behavior/state findings and971global mandatory verification gaps are not closed by normal composition frames.",
        "No new design preference is promoted to defect without demonstrated substantial consequence."
      ],
      "disposition": "BOUNDED_COMPOSITION_ASSESSED_NO_NEW_SUBSTANTIAL_CANDIDATE",
      "review_relation": "ORIGINAL_SPECIALIST_SECOND_LOOK_PLUS_REPRESENTATIVE_COORDINATOR_CROSSCHECK",
      "coordinator_crosscheck_ref": "reviews/design-closure/coordinator-editors-logbook.json",
      "review_book": "reviews/design-closure/peer-editors-logbook/assessment.json"
    },
    {
      "id": "DCL-LIB-17",
      "name": "ResultsScreen / _Review",
      "families": [
        "F08"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_OR_HELPER_COMPOSITION",
      "source_refs": [
        {
          "file": "lib/presentation/screens/execution/results_screen.dart",
          "line": 39,
          "anchor_text": "class ResultsScreen extends StatefulWidget {",
          "sha256": "aee73ff0c28eac9788eaed8c7a662a463140d0de83a1aea37faa177d5ecbcf2f"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0577",
          "path": "reviews/library/supplemental-host/frames/result-light-1.png",
          "sha256": "09c528604ca34462b18e4dccc41d45a81bab68ca98a67f12916c0fc20e8a098c",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0580",
          "path": "reviews/library/supplemental-host/frames/result_b-light-1.png",
          "sha256": "b387645583b1556f475995df07689d8c953ae4903c6b32cde2a7a46efbfcbadf",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0880",
          "path": "reviews/library/remaining-gap-probes/frames/gap_result_review-dark-1.png",
          "sha256": "564621f67f4ffd34336aa3c3ec408fa65a5ee76955f26670815b2cd0a4a89763",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0318",
          "path": "evidence/host/baseline-375/result_notdone-field-1.png",
          "sha256": "8fde33b6389a417d47264982ea6dd1e68b1646cf66b630641c1a893d07e60e8a",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": "Identity/context and integration precede Outcome, counts or reasons, then optional notes/conditions.",
        "vertical_rhythm": "Each full-width count retains its planned hint; later fields have predictable intervals.",
        "composition": "Compact disclosure keeps saved-plan context optional; fixed Save/Cancel remain distinct from scrolling form.",
        "density": "Optional conditions are long but later; Not done substitutes reason choices instead of irrelevant count fields.",
        "grouping": "Outcome, actual light frames, reasons, notes and conditions reflect actual task branches.",
        "redundant_frames": "Expanded review is plain text rather than an unnecessary nested panel.",
        "typography_consistency": "Common body/heading/hint roles persist; Field remains the accepted red-only variant.",
        "professional_quality": "Clear normal recording flow. Existing UIA-0002 load error remains separate; this pass does not certify runtime recovery or native IME."
      },
      "limits": [
        "Representative375dp/100% host frames plus existing native Dark Rigs/Targets/map. No per-class Cartesian3theme/native matrix or full accessibility/owner acceptance.",
        "Site-detail and Site-editor top/lower pairs have identical hashes: no extra lower/expanded coverage. Expanded Site-detail optional facts were source-read but not visually reopened in this second look.",
        "Expanded equipment photo-help, every populated Target list/search variant, every editor class/metadata match outcome, every export/permission/IME/state branch are outside this focused visual selection; earlier state books retain their exact dispositions.",
        "Field frames support composition only. Accepted Field colour exception remains; no blanket contrast pass.",
        "Native loaded map is EVD-1001 only. Grey/blank host map is chrome/dialog evidence, never loaded provider-basemap proof.",
        "Existing behavior/state findings and971global mandatory verification gaps are not closed by normal composition frames.",
        "No new design preference is promoted to defect without demonstrated substantial consequence."
      ],
      "disposition": "BOUNDED_COMPOSITION_ASSESSED_NO_NEW_SUBSTANTIAL_CANDIDATE",
      "review_relation": "ORIGINAL_SPECIALIST_SECOND_LOOK_PLUS_REPRESENTATIVE_COORDINATOR_CROSSCHECK",
      "coordinator_crosscheck_ref": "reviews/design-closure/coordinator-editors-logbook.json",
      "review_book": "reviews/design-closure/peer-editors-logbook/assessment.json"
    },
    {
      "id": "DCL-LIB-18",
      "name": "ProgressScreen / TargetProgressCard",
      "families": [
        "F08"
      ],
      "unit_kind": "MAIN_OR_MEANINGFUL_CHILD_OR_HELPER_COMPOSITION",
      "source_refs": [
        {
          "file": "lib/presentation/screens/logbook/progress_screen.dart",
          "line": 25,
          "anchor_text": "class ProgressScreen extends StatefulWidget {",
          "sha256": "a7b062ef4d81785e60025cfe9a6660a2dcee2205389274e47fe96c45c355c0fc"
        }
      ],
      "evidence": [
        {
          "evidence_id": "EVD-0160",
          "path": "evidence/host/baseline-375/logbook_progress-light-1.png",
          "sha256": "32a2461a724b1cd89ef1b2e3414f44b29c4628aa2c3e3a4e4dcce9b1fc521ce6",
          "evidence_layer": "HOST_VERIFIED"
        },
        {
          "evidence_id": "EVD-0305",
          "path": "evidence/host/baseline-375/progress_guide_open-dark-1.png",
          "sha256": "8961e2af8b7eb1067e9ee8f4b7e4ae3033329c1d8fb220084258397c95f4f5a4",
          "evidence_layer": "HOST_VERIFIED"
        }
      ],
      "dimensions": {
        "hierarchy": "Target identity and total lead filter totals, comparable exposure/sensitivity/rig groups, then guide.",
        "vertical_rhythm": "Dividers and regular group gaps make repeated technical records scannable.",
        "composition": "Name/total Wrap and simple rows serve integration accounting without ornamental charts.",
        "density": "Many numeric details are justified by compatibility; unknown sensitivity gets its own explicit caveat.",
        "grouping": "Target, filter and comparable-group hierarchy matches the domain grouping contract.",
        "redundant_frames": "Embedded cards avoid double framing; one top-level surface per target, no card per exposure subgroup.",
        "typography_consistency": "Strong title/total and smaller counts/provenance maintain consistent Geist/tabular hierarchy.",
        "professional_quality": "Professional scientific grouping; guide prose explicitly disclaims image-quality/SNR inference. Existing UIA-0013 active-guide contrast is separate from settled composition."
      },
      "limits": [
        "Representative375dp/100% host frames plus existing native Dark Rigs/Targets/map. No per-class Cartesian3theme/native matrix or full accessibility/owner acceptance.",
        "Site-detail and Site-editor top/lower pairs have identical hashes: no extra lower/expanded coverage. Expanded Site-detail optional facts were source-read but not visually reopened in this second look.",
        "Expanded equipment photo-help, every populated Target list/search variant, every editor class/metadata match outcome, every export/permission/IME/state branch are outside this focused visual selection; earlier state books retain their exact dispositions.",
        "Field frames support composition only. Accepted Field colour exception remains; no blanket contrast pass.",
        "Native loaded map is EVD-1001 only. Grey/blank host map is chrome/dialog evidence, never loaded provider-basemap proof.",
        "Existing behavior/state findings and971global mandatory verification gaps are not closed by normal composition frames.",
        "No new design preference is promoted to defect without demonstrated substantial consequence."
      ],
      "disposition": "BOUNDED_COMPOSITION_ASSESSED_NO_NEW_SUBSTANTIAL_CANDIDATE",
      "review_relation": "ORIGINAL_SPECIALIST_SECOND_LOOK_PLUS_REPRESENTATIVE_COORDINATOR_CROSSCHECK",
      "coordinator_crosscheck_ref": "reviews/design-closure/coordinator-editors-logbook.json",
      "review_book": "reviews/design-closure/peer-editors-logbook/assessment.json"
    }
  ],
  "source_file_inventory_count": 36,
  "source_file_dispositions": [
    {
      "file": "lib/presentation/screens/about/about_screen.dart",
      "sha256": "1dec96c344dd2814cf89b9469b4f88166d37d7b41571150195ee5625e9240b2e",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DCS-09",
        "DCS-16"
      ],
      "source_route_chain": "AppRouter settings/about; LicensePage and notice disclosures stay SET-028/029.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/details/night_moon_screen.dart",
      "sha256": "bf68b363dad27862b227ac883decffdf691f9524c0c6f3cd9e5b00b7fe745f4d",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DCS-01",
        "DCS-02",
        "DCS-03"
      ],
      "source_route_chain": "AppRouter /night and /moon, Weather wrapper /weather; three-page stateful shell.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/details/weather_detail_screen.dart",
      "sha256": "2988b080e195dba24e65c5fb20ce4bae7c5fb8b00b55be03fd16517398059aab",
      "kind": "ROUTE_ALIAS_NOT_ANOTHER_SCREEN",
      "review_record_ids": [
        "DCS-03"
      ],
      "source_route_chain": "AppRouter /weather -> WeatherDetailScreen -> NightMoonScreen(initialPage:2).",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/equipment/add_rig_panel.dart",
      "sha256": "237a35aa9b33e6d7005741b68c461a5e5f2319cd2aabf15c5d2fe25a2690cac7",
      "kind": "MEANINGFUL_CHILD_OR_INLINE_HELPER",
      "review_record_ids": [
        "DCL-LIB-01"
      ],
      "source_route_chain": "EquipmentSelectionScreen empty inline or nonempty Add sheet; Welcome rig step.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/equipment/equipment_editor.dart",
      "sha256": "554a399e3d891648b6e64a4eb61401d01e4e345b0768daa96e9e245999c941a2",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DCL-LIB-04"
      ],
      "source_route_chain": "showEquipmentEditor -> _EquipmentEditor.show MaterialPageRoute; rig collection/detail, metadata proposal, Welcome and storage Enter size.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/equipment/equipment_selection_screen.dart",
      "sha256": "1c7aab13e8e385b0e8de0dcd1d997d52347e3dc3d7a7bebde8d0643af66e0cc9",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DPL-13",
        "DCL-LIB-02"
      ],
      "source_route_chain": "AppRouter179/249 always mode.manage. forPlanAction remains active on manage route; constructor default choose has no current lib adopter. PlanRigScreen owns scoped choose route.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/equipment/rig_detail_screen.dart",
      "sha256": "2e43e07ad569762b7a6bc7a1298c5f2e1707b9fb63e5210d7ec2c1dca6b329aa",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DCL-LIB-03"
      ],
      "source_route_chain": "EquipmentSelectionScreen._open Navigator push; stored rig detail, edit/delete.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/execution/results_screen.dart",
      "sha256": "aee73ff0c28eac9788eaed8c7a662a463140d0de83a1aea37faa177d5ecbcf2f",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DCL-LIB-17"
      ],
      "source_route_chain": "AppRouter /session/:id/results; result load/form/missing/pending/future/legacy context.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/home/home_screen.dart",
      "sha256": "259fcb4ea15da74aae27b226a72290193e9cbebba502477a1f6996d6e9aa5aef",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DPL-03"
      ],
      "source_route_chain": "SessionPlannerRoute ready/current outcome -> HomeScreen; no invented top-level Home tab.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/home/plan_context_screen.dart",
      "sha256": "e62b34430a36f55aaece89ec35d17c71cf0d19577f10c21506c2f48e5d5d4964",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DPL-04"
      ],
      "source_route_chain": "HomeScreen openPlanContext imperative push; staged site/night with Apply and Close.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/home/plan_rig_screen.dart",
      "sha256": "1b372ab3da0e3022bc729e8d4d816879889896c8ec8bf5a4e2d140dfc1dd5fc3",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DPL-06"
      ],
      "source_route_chain": "AppRouter /select/rig; empty redirects to manage list, for=plan semantics.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/home/plan_target_screen.dart",
      "sha256": "17f167fd21a97e135e6f89127b91724d12955cc80dfa94948b2247acbbdb48c3",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DPL-05"
      ],
      "source_route_chain": "AppRouter /select/target; staged query and Apply plus Add/manage route.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/home/session_planner_route.dart",
      "sha256": "3dde067322f419729a2d6856da448cad83c95cdc95a144c1bb2eefd657afefee",
      "kind": "ROUTE_ALIAS_NOT_ANOTHER_SCREEN",
      "review_record_ids": [
        "DPL-03"
      ],
      "source_route_chain": "AppRouter /session/:id; named/current/restored route state gate.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/library/library_parts.dart",
      "sha256": "6a7e34c45fe6d2de00fe081f83b5f47547a28ceb930aac708fa2ddc3a98931e5",
      "kind": "MEANINGFUL_CHILD_OR_INLINE_HELPER",
      "review_record_ids": [],
      "source_route_chain": "Reusable component definitions; exact production constructor callers in helper_components below.",
      "disposition": "SOURCE_INVENTORIED_PARENT_ALIAS_OR_HELPER; NO_DISTINCT_INDEPENDENT_PIXEL_VERDICT",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/library/library_screen.dart",
      "sha256": "52f5d7e529c26e7bff4e1f53cd3ebebdad144d212945ad1861bdc0850e9edfd1",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DPL-12"
      ],
      "source_route_chain": "AppRouter /library shell; three SettingsRow collection actions.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/location/location_picker_screen.dart",
      "sha256": "1f565589cd79e0cff885d7343538923c67a1e44090eaec9934e83ba66a8a4e8f",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DCL-LIB-13"
      ],
      "source_route_chain": "AppRouter /site/pick pickOnly or /position transient; coordinate modal, GPS and attribution.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/logbook/astrobin_export.dart",
      "sha256": "8b1d72a21a85d9b88b321514f85d2bbe4e659ecb1f059f63bc0b4315e68f05ee",
      "kind": "MEANINGFUL_CHILD_OR_INLINE_HELPER",
      "review_record_ids": [
        "DCL-LIB-15"
      ],
      "source_route_chain": "Logbook menu whole export or nonlegacy detail per-entry export -> prepared _Preview modal.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/logbook/logbook_screen.dart",
      "sha256": "6db298c6d875135170d8d08d5bd60088c9bfc13e40f6dcbceea7a805dd84a61a",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DCL-LIB-14"
      ],
      "source_route_chain": "FeatureScope.logbook=true AppRouter /sessions; filters/date pickers/menu/delete distinct.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/logbook/progress_screen.dart",
      "sha256": "a7b062ef4d81785e60025cfe9a6660a2dcee2205389274e47fe96c45c355c0fc",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DCL-LIB-18"
      ],
      "source_route_chain": "AppRouter /sessions/progress; TargetProgressCard also embedded in entry detail.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/logbook/session_detail_screen.dart",
      "sha256": "319178a89ae7b2f242febd0b83fad146b1fe28866ca23852bbb2933a2ebdbb58",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DCL-LIB-16"
      ],
      "source_route_chain": "AppRouter /sessions/:id; actual entry result/export/name/snapshot/copy contexts.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/metadata/metadata_import_screen.dart",
      "sha256": "9853e4766338b21dc5280291551b3486f54b8a8fd1a18da0d91cb095170915d0",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DCL-LIB-05"
      ],
      "source_route_chain": "FeatureScope.metadataImport=true AppRouter /equipment/import from class-first add flows; Android provider supplied.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/settings/backup_section.dart",
      "sha256": "f2e47f69624e1c4c40e8433f07a86390e0b723439c309b5d5a6ba4973dbb863a",
      "kind": "MEANINGFUL_CHILD_OR_INLINE_HELPER",
      "review_record_ids": [
        "DCS-08",
        "DCS-12",
        "DCS-15"
      ],
      "source_route_chain": "Settings backup section -> BackupSection; main _restartForRestore -> RestoringBackupApp; restore notices.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/settings/settings_parts.dart",
      "sha256": "f3e7fc8c562074002f6a689262ccfa9367fcc53634b2bbe1f5a7c16f6a376f5c",
      "kind": "MEANINGFUL_CHILD_OR_INLINE_HELPER",
      "review_record_ids": [],
      "source_route_chain": "Reusable component definitions; exact production constructor callers in helper_components below.",
      "disposition": "SOURCE_INVENTORIED_PARENT_ALIAS_OR_HELPER; NO_DISTINCT_INDEPENDENT_PIXEL_VERDICT",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/settings/settings_screen.dart",
      "sha256": "94a1f9c7cf60e4a84631456c88d16e809fb6d65be743e7e224611cf215a74a12",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DCS-04",
        "DCS-05",
        "DCS-06",
        "DCS-07",
        "DCS-08"
      ],
      "source_route_chain": "AppRouter /settings root, /plan/settings overPlan, imperative SettingsSection pages, Weather Appearance link.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/sites/site_detail_screen.dart",
      "sha256": "d993fac2d2874e76fa4c1e847ef2c5d232e978887626f85e610edc73da059517",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DCL-LIB-10"
      ],
      "source_route_chain": "SitesScreen._open Navigator push with site id, missing-record branch; edit/delete.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/sites/site_editor_screen.dart",
      "sha256": "72156fc93fb6521c5ce5507e8c5a1273f58cb7cc729598ac6dc294d6cdf4a55a",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DCL-LIB-11"
      ],
      "source_route_chain": "AppRouter /site/edit SiteEditorArgs new/existing; exact original versus staged changes.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/sites/sites_screen.dart",
      "sha256": "b45355fa5de54567d025557790978c995ffc8be81cfcc6b733fbec13a6dce2f2",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DPL-15",
        "DCL-LIB-09"
      ],
      "source_route_chain": "AppRouter /library/sites manage and /select/site choose; Tonight/Welcome/Plan/conditions callers.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/sites/zone_picker_dialog.dart",
      "sha256": "438967bc1f897d2061cc4059370a7244c9fe393ff1786da131ae68cb81c22ac0",
      "kind": "MEANINGFUL_CHILD_OR_INLINE_HELPER",
      "review_record_ids": [
        "DCL-LIB-12"
      ],
      "source_route_chain": "SiteEditor._chooseZone -> showZonePicker -> _ZonePickerDialog.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/startup/unsupported_database_screen.dart",
      "sha256": "557d57819b31123b01e472f884cde8640a32b89fa83250c02e27b4b2312decac",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DCS-13",
        "DCS-14"
      ],
      "source_route_chain": "main unsupported database outcome -> standalone UnsupportedDatabaseApp/Screen before router; older/newer differ.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/target/target_detail_screen.dart",
      "sha256": "b4ae2e2a6a91deaede8b8605fa4cb7cb5a1df11a72d640b89a90335ff7eca427",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DCL-LIB-07"
      ],
      "source_route_chain": "TargetSelectionScreen._open Navigator push; catalogue/custom data and action branches.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/target/target_editor_screen.dart",
      "sha256": "1bae0d630b1a143e1098a2cd295f1fbf2b190640c1469184599e0b79e83abd9c",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DCL-LIB-08"
      ],
      "source_route_chain": "TargetSelectionScreen._edit -> showTargetEditor Navigator push; new or custom existing.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/target/target_selection_screen.dart",
      "sha256": "c896df94fe2c83f6bb7ce90fa5e3a5bd136179dca5de1cf91cfe8cc445730bec",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DPL-14",
        "DCL-LIB-06"
      ],
      "source_route_chain": "AppRouter184/244 always mode.manage. Constructor default choose exists but has no current lib adopter; PlanTargetScreen owns scoped choose route.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/tonight/home_context_sheets.dart",
      "sha256": "08bd27ff17baa9606a2d88498ae450b41070b12bc41757728bf3e8b698ebfa94",
      "kind": "MEANINGFUL_CHILD_OR_INLINE_HELPER",
      "review_record_ids": [],
      "source_route_chain": "Tonight context invokes active site route/pickNight; HomeSheetHeader is independently active at Candidates:105. No dormant sheet helper is defined.",
      "disposition": "SOURCE_INVENTORIED_PARENT_ALIAS_OR_HELPER; NO_DISTINCT_INDEPENDENT_PIXEL_VERDICT",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/tonight/tonight_candidates_screen.dart",
      "sha256": "2021d816d74a000427c2a2bce1f491e74ce9de5fc7f2c78c0949cbda173f0106",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DPL-02"
      ],
      "source_route_chain": "AppRouter /tonight/candidates -> candidates list; filters/empty/error/held refresh distinct.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/tonight/tonight_home_screen.dart",
      "sha256": "331c740c307a7a9d57b0c73913380097f802a7edc2c91dd0db7acfe3060a5888",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DPL-01"
      ],
      "source_route_chain": "AppRouter /tonight initial or shell; bootstrap/no-site/ready and descendants.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    },
    {
      "file": "lib/presentation/screens/welcome/welcome_screen.dart",
      "sha256": "cb7e7c77664ff154c4f8355b105328dedaaf7c1f41bc669f9aa7ef6bbe856553",
      "kind": "PRODUCTION_MAIN_OWNER",
      "review_record_ids": [
        "DCS-10"
      ],
      "source_route_chain": "main firstLocation -> /welcome; root route, stored first-run completion; optional Site/Rig actions.",
      "disposition": "BOUNDED_RECORDS_WITH_EXPLICIT_VARIANT_LIMITS",
      "limit": "36 source files are not36 independent screens. Same-file categories, wrappers, helpers and conditional presentations retain separate record limits; matching source cannot prove unseen pixels."
    }
  ],
  "honest_gaps": [
    {
      "scope": "Flutter LicensePage actual populated list and detail; expanded About notices",
      "disposition": "UNVERIFIED",
      "reason": "No valid full list/detail or expanded notice image was independently reopened; original incomplete license fixtures remain invalid. About action/source is not a visual substitute.",
      "resumption": "Only a separately requested exact composition continuation; no retries now.",
      "records": [
        "DCS-09",
        "DCS-16"
      ]
    },
    {
      "scope": "Moon final lower disclosure wrapper",
      "disposition": "UNVERIFIED",
      "reason": "Shared MoonSummary was viewed through Night; this does not certify the complete Moon-tab lower wrapper.",
      "resumption": "Exact Moon lower view if separately requested.",
      "records": [
        "DCS-02"
      ]
    },
    {
      "scope": "Ready Launch full1400ms temporal composition",
      "disposition": "UNVERIFIED",
      "reason": "Valid waiting/failure stills do not establish complete ready motion/gesture. No timing or device rerun performed.",
      "resumption": "Only an explicitly scoped motion-evidence task.",
      "records": [
        "DCS-11"
      ]
    },
    {
      "scope": "RestoreOutcomeNotice in actual production first-screen context",
      "disposition": "UNVERIFIED",
      "reason": "Actual component fixture establishes local notice composition; harness scaffolding is excluded from production-screen verdict.",
      "resumption": "Only named integration scenario if separately authorized.",
      "records": [
        "DCS-15"
      ]
    },
    {
      "scope": "Expanded Site-detail optional facts and duplicate lower samples",
      "disposition": "UNVERIFIED",
      "reason": "Named Site top/lower pairs are byte-identical; duplicate captures add no expanded-content coverage.",
      "resumption": "Exact expanded content if separately requested.",
      "records": [
        "DCL-LIB-10",
        "DCL-LIB-11"
      ]
    },
    {
      "scope": "Normal untouched Planning-defaults top",
      "disposition": "UNVERIFIED_NORMAL_STATE_IN_THIS_CROSS_REVIEW",
      "reason": "Opened top frame is an actual Saving state. Its grouping is observed; it does not certify untouched-default normal behavior or composition.",
      "resumption": "Reuse a known exact valid normal frame if later requested; no new attempt now.",
      "records": [
        "DCS-06"
      ]
    },
    {
      "scope": "Per-main complete lower/long/empty/theme breadth",
      "disposition": "BOUNDED_ONLY; exact missing variants remain per-record",
      "reason": "Finite review uses representative100% mostly375dp compositions. Long collection tails, multi-block/calibration variants, empty/import/editor variants and every theme/state combination are not universally inspected. Privacy mislabeled Field frames remain excluded.",
      "resumption": "Named missing contract only; no Cartesian expansion.",
      "records": [
        "DPL-01",
        "DPL-02",
        "DPL-08",
        "DPL-09",
        "DPL-13",
        "DPL-14",
        "DPL-15"
      ]
    }
  ],
  "new_substantial_design_findings": 0,
  "new_finding_ids": [],
  "known_visual_findings_reconfirmed": [
    "UIA-0010: temporal row identity lost after table pan",
    "UIA-0011: long provenance prose in narrow numeric lane"
  ],
  "related_current_content_concern": "UIA-0004 truthful forecast provenance remains a known content/state finding, not a newly invented composition defect.",
  "positive_proof_examples": [
    {
      "scope": "Tonight/Plan",
      "evidence_ids": [
        "EVD-0064",
        "EVD-0088",
        "EVD-0232",
        "EVD-0244"
      ],
      "proof": "Context and plan/action precede supplementary night facts; Plan separates input choices, capture content and estimates with consistent document rhythm."
    },
    {
      "scope": "Night/Moon/Weather",
      "evidence_ids": [
        "EVD-0196",
        "EVD-0211",
        "EVD-0190",
        "EVD-0394"
      ],
      "proof": "Answer first, inspectable timeline/metric panels second, reading/provenance third; headings and units establish identity without cards around each fact."
    },
    {
      "scope": "Record editors/details",
      "evidence_ids": [
        "EVD-0094",
        "EVD-0103",
        "EVD-0106",
        "EVD-0115",
        "EVD-0121",
        "EVD-0133",
        "EVD-0136"
      ],
      "proof": "Camera/Optics and Position/Name/zone are meaningful groups; Save/Cancel footer and field/helper hierarchy repeat. Optional records remain disclosures; scientific precision is preserved."
    },
    {
      "scope": "Progress/Entry",
      "evidence_ids": [
        "EVD-0160",
        "EVD-0046",
        "EVD-0043"
      ],
      "proof": "Target/filter totals precede separated exposure groups; expanded snapshot uses local headings inside one surface. Density carries recorded scientific meaning rather than decorative nesting."
    }
  ],
  "no_findings_quota": "Logbook title/date wraps, stacked saved/recorded badges, sparse collections, Candidates first-fold filters, detailed unknown facts and full-precision editor values are documented tradeoffs where no substantial consequence is proved. No fix is inferred from preference.",
  "remaining_unique_mandatory_states": 971,
  "state_freeze_unchanged": true,
  "all_main_screen_professional_quality_certified": false,
  "owner_visual_acceptance": false,
  "owner_direction_ref": "decisions/owner-direction-20261026.json",
  "priority_review_ref": "reviews/design-closure/uia0003-priority-review.json",
  "review_books": [
    "reviews/design-closure/peer-planning-library/assessment.json",
    "reviews/design-closure/peer-conditions-settings/assessment.json",
    "reviews/design-closure/peer-editors-logbook/assessment.json",
    "reviews/design-closure/coordinator-editors-logbook.json"
  ],
  "stop": "P7 and audit delivered at implementation boundary. No further research loop without specific new critical evidence. UIA0010 future comparison/complexity prerequisite remains; no implementation now."
}
```
