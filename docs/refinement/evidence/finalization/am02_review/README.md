# AM-02 repeat UI/UX review — observation evidence

Evidence for [FINALIZATION_REVIEW §34](../../../FINALIZATION_REVIEW.md#34-claude-repeat-uiux-review-am-02). Assessment only: nothing here is an application change, a permanent regression test, or acceptance of a roadmap criterion.

| Item | Record |
| --- | --- |
| Baseline | HEAD `322edbd` on `main`; application, test, dependency and tooling inputs have no diff from `322edbd` (the pre-existing modified `macos/Flutter/GeneratedPluginRegistrant.swift` is outside the probe and was not touched) |
| Toolchain | `C:\flutter`, Flutter 3.47.4, Dart 3.13.3, framework revision `9584c6713b`; Windows host test runner |
| Device | `adb devices -l` on 2026-10-18 listed no device; no install, launch or uninstall happened |
| Data | Synthetic fixtures only: in-memory Drift database, mocked SharedPreferences (an in-memory platform store), fake GPS, fake geocoder, fixed clock `2026-12-15T17:00:00Z`, fixture position 46.05 N 14.5 E. No owner database, backup, metadata sample, network call or signing material |
| Probe source | [`am02_review_probe.patch`](am02_review_probe.patch) recreates the ignored file `build/finalization/am02_review/am02_review_probe_test.dart` (SHA-256 `0025854ab3e9caa7f6bc863ab4fa85bdfe1fc4048d9611e99d070e82d061354c`). It follows the P2 probe's location and orchestration (`build/` is ignored); apply it only where that file does not exist |
| Result | 10 cases, all passed ([host log](host-observation.log)); 12 observation records ([observations.json](observations.json)); 4 PNG renders. Several cases assert the **current** behaviour to record it; a pass is an observation, not a fix |
| Harness attempt | [`harness-attempt-1.log`](harness-attempt-1.log): the first run's three search cases timed out in `pumpAndSettle` because the list's progress indicator never settles. A probe defect, not an application defect; the final source pumps a fixed number of frames instead. Its other seven cases passed and wrote the same nine records as the final run |
| Path hygiene | Absolute local paths in the logs are replaced by `<repo>`, `<pub-cache>` and `<user-home>`; nothing else is edited |

Reproduce from the repository root (PowerShell):

```powershell
git apply docs/refinement/evidence/finalization/am02_review/am02_review_probe.patch
$env:FLUTTER_ROOT = 'C:\flutter'
& 'C:\flutter\bin\flutter.bat' test --no-pub --reporter expanded build/finalization/am02_review/am02_review_probe_test.dart
```

The probe writes `observations.json` and the PNGs back into this directory.

## Files

| File | What it shows | SHA-256 |
| --- | --- | --- |
| [planner_no_rig_dark_100.png](planner_no_rig_dark_100.png) | Planner with a target and no rig: status "Needs a rig", no Save plan bar (UX32-01) | `d38464ebdbb68a669ab30cd7c0c6756b9524108cb3b206b9c74e3bb6c3fede2d` |
| [planner_later_night_dark_100.png](planner_later_night_dark_100.png) | A plan for Fri, Dec 18 viewed on Dec 15: "Fill tonight's window", "Altitude now" beside "Max altitude in windows" (CRUX-01, UX32-05) | `b42b34b7a845a98d1811d6f8fba7798e3679d65c547f631a5e7ed08b573a89c0` |
| [planner_later_night_scrolled_dark_100.png](planner_later_night_scrolled_dark_100.png) | The same plan after a 900 px drag: Capture plan begins here; "+296 frames still fit tonight"; the example plan's own calibration warnings (CRUX-01, CRUX-05, CRUX-06) | `65776a11bbed4255dd19565e8f7acd2ce6a70d649e9775f6c0e0225317d62d57` |
| [home_later_night_dark_100.png](home_later_night_dark_100.png) | Home for the same plan: title "Tonight", context "Fri, Dec 18", "What can I image tonight?" (CRUX-01); context label "Current position" for a stored fixture position (CRUX-04) | `5aaa4809f0584f6fd024d14a9901047c408a97180520cf5b7816852fdeb4e4b2` |
| [observations.json](observations.json) | Machine-readable records of all 10 cases | `ec3f6117b20cd7ff90fa4ef86821c5e369ffcc40fc465f7a4b377995ecd64ee8` |
| [host-observation.log](host-observation.log) | Final run output | `2cd71ff9c8754b0e27779dac620e9f37c5d4356b40a34efeda2c68ea6d870685` |
| [harness-attempt-1.log](harness-attempt-1.log) | First run (probe defect above) | `cb15a2d0248183caa01457193ae605daccb0964b6cb9f9feed41588d3084db77` |
| [am02_review_probe.patch](am02_review_probe.patch) | Probe source | `bc850154f04d65f3ebf0325a1adc6026206d94e1c92307f8030ec5b3ba67da52` |

## Limits

Renders are host renders at 412×915, DPR 1, 100 % text, dark theme, with the SDK's Roboto and Material Icons bound explicitly; they are not device captures, and 200 % text, light and field themes, the keyboard and reduced motion were not rendered. The site editor is mounted in a plain `MaterialApp` (no router), and the target search in a two-route `GoRouter`. The settings cases exercise `SettingsViewModel` and the production `SharedPrefsPlanningPreferencesRepository` over an in-memory platform store with injected failures; they say nothing about Android's own write ordering or failure rate. No human took part: nothing here is evidence of comprehension.
