# ROOT_CAUSES

Text-only audit register exported from local `.audit/root_causes.json`. Original SHA-256: `f0ee2d8764ebdf33863e03685fd547f6fde192b91ce0d2f32f7c42b490c99d35`. Private evidence references identify local artifacts; no raw capture, device identifier, binary or executable probe is published. User-profile paths are redacted. Original canonical bytes remain unchanged.

```json
{
  "schema_version": 2,
  "audit_id": "culmina-native-ui-20261025",
  "source_sha": "8157dcc275f1349f299e411c611888daafc035a0",
  "status": "COMPLETE_BOUNDED_FINDING_ROOT_MAP",
  "groups": [
    {
      "id": "RC-0001",
      "title": "Caller-specific omission of cache/failed-refresh qualification",
      "kind": "LOCAL_CALLER_STATE_PRESENTATION",
      "finding_ids": [
        "UIA-0001"
      ],
      "owning_components": [
        "HomeScreen._weatherExtra Plan caller; preserve measurements, coverage, science and detail navigation."
      ],
      "confirmed_callers": [
        {
          "finding_id": "UIA-0001",
          "callers": [
            "PLN-017"
          ],
          "scope_limit": [],
          "proof_status": "CONFIRMED_HOST"
        }
      ],
      "source_files": [
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
      "status": "CONFIRMED_BOUNDED_WITH_EXPLICIT_CALLER_LIMITS",
      "global_fix_authorized": false
    },
    {
      "id": "RC-0002",
      "title": "Results read path has no explicit failure/recovery UI state",
      "kind": "STATE_OWNERSHIP",
      "finding_ids": [
        "UIA-0002"
      ],
      "owning_components": [
        "ResultsScreen / ResultsViewModel load outcome"
      ],
      "confirmed_callers": [
        {
          "finding_id": "UIA-0002",
          "callers": [
            "RES-001"
          ],
          "scope_limit": [
            "No claim of native crash, indefinite duration or owner database failure."
          ],
          "proof_status": "CONFIRMED_HOST"
        }
      ],
      "source_files": [
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
      "status": "CONFIRMED_BOUNDED_WITH_EXPLICIT_CALLER_LIMITS",
      "global_fix_authorized": false
    },
    {
      "id": "RC-0003",
      "title": "Prior Save/Apply completion outlives newer accepted local buffers; Target has an additional route-result conflict",
      "kind": "REPEATED_EDITOR_INPUT_OWNERSHIP_PATTERN_WITH_DISTINCT_LOCAL_IMPLEMENTATIONS",
      "finding_ids": [
        "UIA-0003"
      ],
      "owning_components": [
        "TargetEditorScreen and PlanOverridesEditor accepted-input/completion ownership; distinct local implementations, no shared editor base"
      ],
      "confirmed_callers": [
        {
          "finding_id": "UIA-0003",
          "callers": [
            "TGT-005",
            "TGT-008",
            "CAP-028"
          ],
          "scope_limit": [
            "Target Light and Plan assumptions Dark375dp100% are separately host-observed with actual immutable payload and real in-memory Drift readback.",
            "Stored earlier payloads are correct; the loss concerns later accepted local buffers. Target debug route-result assertion is not claimed for assumptions or physical/release builds.",
            "Site/Results remain source hypotheses. Accepted Q4 Rig input/exit guards stay closed; no global editor defect or shared-code repair is inferred.",
            "Assumptions final metadata carries a historical tap-phase gateCompleted:false; awaited editor closure and actual SQL/readback establish final completion. No fabricated current-gate assertion."
          ],
          "proof_status": "CONFIRMED_BOUNDED_HOST_CALLERS_WITH_INDEPENDENT_REVIEW"
        }
      ],
      "source_files": [
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
      "status": "CONFIRMED_BOUNDED_WITH_EXPLICIT_CALLER_LIMITS",
      "global_fix_authorized": false,
      "repair_boundary": "Repair the two local editor completion contracts: freeze editable input during the submitted write or preserve a newer local buffer and its Apply/Discard ownership. Target separately needs route-result ownership when its Unsaved dialog is current. Preserve failures and exact submitted payloads; do not automatically persist later12 or equate Apply with explicit Save plan.",
      "highest_priority": "P1",
      "priority_review_ref": "reviews/design-closure/uia0003-priority-review.json"
    },
    {
      "id": "RC-0004",
      "title": "Snapshot end is equated with a fixed provider-horizon cause",
      "kind": "CALLER_COPY_SEMANTIC_INFERENCE",
      "finding_ids": [
        "UIA-0004"
      ],
      "owning_components": [
        "_ComingNights final explanatory copy"
      ],
      "confirmed_callers": [
        {
          "finding_id": "UIA-0004",
          "callers": [
            "HybridWeatherView for available short/aged snapshots"
          ],
          "scope_limit": [],
          "proof_status": "CONFIRMED_HOST"
        }
      ],
      "source_files": [
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
      "status": "CONFIRMED_BOUNDED_WITH_EXPLICIT_CALLER_LIMITS",
      "global_fix_authorized": false
    },
    {
      "id": "RC-0005",
      "title": "Local map attribution uses text/padding height as its entire tap target",
      "kind": "LOCAL_CONTROL_TARGET",
      "finding_ids": [
        "UIA-0005"
      ],
      "owning_components": [
        "_OsmAttribution InkWell constraints"
      ],
      "confirmed_callers": [
        {
          "finding_id": "UIA-0005",
          "callers": [
            "SITE-020"
          ],
          "scope_limit": [],
          "proof_status": "CONFIRMED_HOST"
        }
      ],
      "source_files": [
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
      "status": "CONFIRMED_BOUNDED_WITH_EXPLICIT_CALLER_LIMITS",
      "global_fix_authorized": false
    },
    {
      "id": "RC-0006",
      "title": "Future replacement retains old data/error while callers omit a pending-state distinction",
      "kind": "REPEATED_CALLER_ASYNC_STATE_PATTERN",
      "finding_ids": [
        "UIA-0006",
        "UIA-0008",
        "UIA-0014"
      ],
      "owning_components": [
        "Candidates request/snapshot ownership and explicit pending presentation only; preserve sort/filter/scientific evaluator and native composition.",
        "SessionDetailScreen FutureBuilder state precedence",
        "LibraryScreen _retry/_counts FutureBuilder branch projection"
      ],
      "confirmed_callers": [
        {
          "finding_id": "UIA-0006",
          "callers": [
            "CAN-001",
            "CAN-002",
            "CAN-006"
          ],
          "scope_limit": [],
          "proof_status": "CONFIRMED_HOST"
        },
        {
          "finding_id": "UIA-0008",
          "callers": [
            "LOG-009"
          ],
          "scope_limit": [],
          "proof_status": "CONFIRMED_HOST"
        },
        {
          "finding_id": "UIA-0014",
          "callers": [
            "LIB-001"
          ],
          "scope_limit": [
            "Direct themed MaterialApp component fixture: main root focus ring/Field filter composition is separately qualified.",
            "No canonical AppRouter, physical, indefinite-wait, crash or duplicate-retry proof.",
            "Other aggregate data sources were not independently failed."
          ],
          "proof_status": "CONFIRMED_HOST"
        }
      ],
      "source_files": [
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
      "status": "CONFIRMED_BOUNDED_WITH_EXPLICIT_CALLER_LIMITS",
      "global_fix_authorized": false,
      "repair_boundary": "Three actual retained-state callers: Candidates refresh, Entry Retry and Library count Retry. Repair each projection locally; do not globally rewrite FutureBuilder or weaken unknown/error guards."
    },
    {
      "id": "RC-0007",
      "title": "One empty-result explanation ignores which active filter removed the rows",
      "kind": "LOCAL_COPY_STATE_MISMATCH",
      "finding_ids": [
        "UIA-0007"
      ],
      "owning_components": [
        "Candidates empty-state wording/diagnosis only; no new candidate scoring or science changes."
      ],
      "confirmed_callers": [
        {
          "finding_id": "UIA-0007",
          "callers": [
            "CAN-005",
            "CAN-009"
          ],
          "scope_limit": [],
          "proof_status": "CONFIRMED_HOST"
        }
      ],
      "source_files": [
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
      "status": "CONFIRMED_BOUNDED_WITH_EXPLICIT_CALLER_LIMITS",
      "global_fix_authorized": false
    },
    {
      "id": "RC-0008",
      "title": "Shared night-picker keeps a seven-column calendar below its48dp fit threshold",
      "kind": "SHARED_COMPONENT_GEOMETRY",
      "finding_ids": [
        "UIA-0009"
      ],
      "owning_components": [
        "NightPickerDialog calendar constraints"
      ],
      "confirmed_callers": [
        {
          "finding_id": "UIA-0009",
          "callers": [
            "NightMoonScreen date header",
            "Tonight home night sheet",
            "PlanContextScreen night picker",
            "HomeScreen copy",
            "SessionDetailScreen copy"
          ],
          "scope_limit": [
            "Shared NightPickerDialog at320dp/100% only. Existing MoonCalendarSection VQA-030 fix remains verified and unchanged."
          ],
          "proof_status": "CONFIRMED_HOST"
        }
      ],
      "source_files": [
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
      "status": "CONFIRMED_BOUNDED_WITH_EXPLICIT_CALLER_LIMITS",
      "global_fix_authorized": false,
      "repair_boundary": "Shared NightPickerDialog adaptation below a seven-column48dp fit; verify all named callers and cancel/adopt semantics, preserve accepted MoonCalendarSection behavior."
    },
    {
      "id": "RC-0009",
      "title": "Hourly table scrolls the temporal identity column out of view",
      "kind": "LOCAL_DATA_TABLE_COMPOSITION",
      "finding_ids": [
        "UIA-0010"
      ],
      "owning_components": [
        "_Details Table / horizontal SingleChildScrollView"
      ],
      "confirmed_callers": [
        {
          "finding_id": "UIA-0010",
          "callers": [
            "HybridWeatherView from all conditions entry routes"
          ],
          "scope_limit": [],
          "proof_status": "CONFIRMED_HOST"
        }
      ],
      "source_files": [
        {
          "file": "lib/presentation/widgets/weather_hybrid_view.dart",
          "start": 1387,
          "end": 1497,
          "sha256": "1dc6b157183af1f4b53446842f3fd5ab2af4e436afca1fbbd661a007feeb528c"
        }
      ],
      "status": "CONFIRMED_BOUNDED_WITH_EXPLICIT_CALLER_LIMITS",
      "global_fix_authorized": false
    },
    {
      "id": "RC-0010",
      "title": "Long provenance prose is passed into a numeric fact value column",
      "kind": "CALLER_SPECIFIC_COMPONENT_MISUSE_OR_COMPOSITION",
      "finding_ids": [
        "UIA-0011"
      ],
      "owning_components": [
        "CaptureBudgetSummary File size basis caller; HybridFact is its general label/value renderer"
      ],
      "confirmed_callers": [
        {
          "finding_id": "UIA-0011",
          "callers": [
            "CaptureBudgetSummary's File size basis HybridFact in Plan"
          ],
          "scope_limit": [
            "No font/size/token changes",
            "No astronomy/storage calculation change",
            "No global fact-row normalization",
            "No removal/shortening of source facts",
            "No implementation during this audit"
          ],
          "proof_status": "CONFIRMED_HOST"
        }
      ],
      "source_files": [
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
      "status": "CONFIRMED_BOUNDED_WITH_EXPLICIT_CALLER_LIMITS",
      "global_fix_authorized": false,
      "repair_boundary": "File-size-basis caller prose treatment; inspect HybridFact callers first, do not globally widen numeric value columns."
    },
    {
      "id": "RC-0011",
      "title": "Proposal guidance enumerates fields independently of current camera capabilities",
      "kind": "LOCAL_COPY_CAPABILITY_MISMATCH",
      "finding_ids": [
        "UIA-0012"
      ],
      "owning_components": [
        "_CaptureBlockDialog proposal guidance text"
      ],
      "confirmed_callers": [
        {
          "finding_id": "UIA-0012",
          "callers": [
            "Add Light block with proposal; DSLR/Phone/Unknown field capability cases require truthful wording; same production caller, no global token change"
          ]
        }
      ],
      "source_files": [
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
      "repair_boundary": "Copy-only recommendation; no camera-capability, calibration, persistence, science or layout change.",
      "status": "CONFIRMED_HOST",
      "global_fix_authorized": false
    },
    {
      "id": "RC-0012",
      "title": "Enabled ink/text contrast pairing across eighteen confirmed control cases on seventeen surfaces",
      "kind": "REPEATED_STATE_PAIR_PATTERN_WITH_LOCAL_AND_SHARED_OWNERS",
      "finding_ids": [
        "UIA-0013"
      ],
      "owning_components": [
        "Repeated enabled ink/text pairing: Tracking choices, block/Progress/Night/Moon CollapsibleSection callers, Weather Hourly header, Moon-preview TextButton and inline AppMessages Undo. Local and shared owners remain distinct.; Moon month-day InkWell, narrow-week ListTile and Retry TextButton callers; Edit-block photo TextButton.icon; Storage file chooser and confirmation TextButtons"
      ],
      "confirmed_callers": [
        {
          "finding_id": "UIA-0013",
          "callers": [
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
          "scope_limit": [
            "Exact host caller states at100%; primary375dp with actual source-required week320dp. Composition/input/timing are per-case; no native/full-accessibility acceptance.",
            "Light failures are limited to Moon Preview, month/week Retry and stored-entry Undo and Edit-block photo action. Other confirmed failures are Dark; Field exception is unchanged.",
            "Progress guide and week-row4.467 are borderlineP3 cases within the overallP2 finding.",
            "Repeated pairing pattern is confirmed across distinct local/shared owners. Exact multilayer blend mechanism and unobserved callers remain unverified."
          ],
          "proof_status": "CONFIRMED_BOUNDED_HOST_CASES_WITH_COORDINATOR_REMEASUREMENT"
        }
      ],
      "source_files": [
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
      "status": "CONFIRMED_BOUNDED_WITH_EXPLICIT_CALLER_LIMITS",
      "global_fix_authorized": false,
      "repair_boundary": "Correct foreground/background interaction pairing in the eighteen named caller cases, including month375dp and the actual320dp week fallback. Shared TextButton/CollapsibleSection or ListTile/InkWell changes require inspection of other callers/exceptions first. Preserve state feedback, calendar viewing versus plan adoption and scientific meanings; do not globally alter palette or ink from an uninstrumented blend hypothesis."
    },
    {
      "id": "RC-0013",
      "title": "Calibration action footer is unavailable while the Android numeric IME is open",
      "kind": "LOCAL_INTERACTION_STATE_CONTRACT",
      "finding_ids": [
        "UIA-0015"
      ],
      "owning_components": [
        "Calibration preview Scaffold bottomNavigationBar placement; existing HybridApplyBar is not itself an IME inset owner"
      ],
      "confirmed_callers": [
        {
          "finding_id": "UIA-0015",
          "callers": [
            "CAP-020"
          ],
          "scope_limit": [
            "One physical Dark375.384dp100% Gboard numeric-IME case; other keyboards/devices/themes remain scoped.",
            "Back recovers the action; no unrecoverable flow block or data-loss claim.",
            "No Cal Apply or Save was performed. Saved-plan preservation is coordinator observation, not an independent DB readback."
          ],
          "proof_status": "CONFIRMED_NATIVE_BOUNDED"
        }
      ],
      "source_files": [
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
      "status": "CONFIRMED_BOUNDED_WITH_EXPLICIT_CALLER_LIMITS",
      "global_fix_authorized": false,
      "repair_boundary": "Apply the existing local Capture Block inset approach to the calibration footer after checking the Scaffold constraints. Keep the shared bar, labels, draft/save semantics and scientific proposals intact; no global bar redesign."
    },
    {
      "id": "RC-0014",
      "title": "Night browser keyboard focus is not revealed into the scroll viewport",
      "kind": "LOCAL_KEYBOARD_FOCUS_REVEAL_CONTRACT",
      "finding_ids": [
        "UIA-0016"
      ],
      "owning_components": [
        "NightMoonScreen scroll owner and _ViewedNightHeader focus-reveal interaction; HybridFocusHighlight paints the existing rect"
      ],
      "confirmed_callers": [
        {
          "finding_id": "UIA-0016",
          "callers": [
            "NIT-004"
          ],
          "scope_limit": [
            "One actual-app Dark375dp100% synthetic host loop; no physical hardware-keyboard/TalkBack/all-path claim.",
            "Two-second persistence is simulated test time, not an indefinite native duration.",
            "SDK keepVisibleAtEnd/clamp is a plausible source explanation, not an instrumented causal proof.",
            "Imperative navigation retains the base GoRouter URI; actual NightMoonScreen/caller mounting is separately verified."
          ],
          "proof_status": "CONFIRMED_HOST"
        }
      ],
      "source_files": [
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
      "status": "CONFIRMED_BOUNDED_WITH_EXPLICIT_CALLER_LIMITS",
      "global_fix_authorized": false,
      "repair_boundary": "Provide bounded focus reveal for this browser/header scroll owner using actual control geometry. Verify local traversal/reveal behavior rather than changing global keyboard policy or the focus-ring painter by assumption."
    },
    {
      "id": "RC-0015",
      "title": "Focus indicator geometry is stale after the optional-name dialog inset transition",
      "kind": "BOUNDED_FOCUS_PAINT_GEOMETRY_REFRESH_CONTRACT",
      "finding_ids": [
        "UIA-0017"
      ],
      "owning_components": [
        "HybridFocusHighlight geometry-refresh lifecycle around the optional Name AlertDialog inset animation"
      ],
      "confirmed_callers": [
        {
          "finding_id": "UIA-0017",
          "callers": [
            "LOG-018"
          ],
          "scope_limit": [
            "Synthetic host inset/TestTextInput only; no physical Android IME or hardware-keyboard reproduction.",
            "Only this empty-name transition at375dp100% across three themes; no all-field/global focus defect claim.",
            "Ring bounds are approximate pixel observations; public field bounds are exact metadata. No instrumented painter timeline or separate2s persistence sample.",
            "The later-input frame recovers ring placement. No input loss, blocked Save or data corruption is alleged."
          ],
          "proof_status": "CONFIRMED_HOST_BOUNDED"
        }
      ],
      "source_files": [
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
      "status": "CONFIRMED_BOUNDED_WITH_EXPLICIT_CALLER_LIMITS",
      "global_fix_authorized": false,
      "repair_boundary": "Refresh the focus indicator against post-layout geometry for the confirmed dialog transition. Determine the actual paint/layout invalidation boundary before changing the shared painter; retain FocusManager ownership, hit geometry and pointer behavior."
    },
    {
      "id": "RC-0016",
      "title": "Changed working-plan facts use an unqualified old stored-record label while writing",
      "kind": "LOCAL_WORKING_VERSUS_STORED_PRESENTATION_CONTRACT",
      "finding_ids": [
        "UIA-0018"
      ],
      "owning_components": [
        "Tonight current working-plan state presentation versus lagging CurrentSession record during optimistic selection/write"
      ],
      "confirmed_callers": [
        {
          "finding_id": "UIA-0018",
          "callers": [
            "TON-006"
          ],
          "scope_limit": [
            "One actual Field375dp100% synthetic host held-write scene; no native, indefinite wait or all-working-caller claim.",
            "The stored M31/planned row is correct while pending and actual M42/draft is correct after success; no SQL corruption or premature-status-write requirement.",
            "Related Light failed-assumptions screen remains PARTIAL/P3 copy consistency only: its visible top banner truthfully discloses failure and retained8.5, despite the footer saying Saved on this device. It is not a silent-success or input-loss claim.",
            "No global PlanState.of rewrite, new persistence model or production correction is authorized."
          ],
          "proof_status": "CONFIRMED_HOST_BOUNDED"
        }
      ],
      "source_files": [
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
      "status": "CONFIRMED_BOUNDED_WITH_EXPLICIT_CALLER_LIMITS",
      "global_fix_authorized": false,
      "repair_boundary": "Qualify the current working-plan card using its actual edited/pending context so new target facts are not presented as already saved. Keep PlanState.of valid for stored records and Logbook; do not optimistically mutate SQL status or equate autosave with explicit Save plan."
    }
  ],
  "limits": "11 deduplicated bounded root groups. Owner layout/composition gates and exact caller limits are retained. Source-only analogies do not expand confirmed scope. No implementation authorized.",
  "updated_utc": "2026-10-25T22:51:24.864117+00:00",
  "overall_audit_status": "PARTIAL_WITH_ATTENTION",
  "completion_limit": "18confirmed findings in16 bounded root groups; observed same-pattern controls and distinct local owners remain scoped. No all-state/product acceptance.",
  "design_closure_amendment_ref": "reports/design_completeness.json"
}
```
