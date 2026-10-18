# F13 — One Moon-up rule and moon-free intervals (evidence)

Run: full final-plan group, second cloud session, 2026-10-18. Environment: Linux container,
Flutter 3.47.4 / Dart 3.13.3. ADR-022 accepted in full by the owner the same day.

## Changed files

- `lib/domain/services/moon_calculator.dart`: `upThresholdDeg`/`isUp` (N1, derivation in the doc
  comment and ADR-022), `sampleAt` (the one grid sample for single night and batch, N3/M5),
  `riseSetForNight` and `conditionsForNight` on that predicate (N2), the phase longitude at mean
  solar midnight; `aboveGeocentricH0` kept only as the classical check for M2. `topocentric`
  also returns the parallax.
- `lib/domain/models/moon_conditions.dart`: `MoonSample.up`; `duringDark` and the closest
  approach count `up`; `MoonPhaseName` (N5); `MoonFreeKind`/`MoonFreeNight.classify` and
  `MoonConditions.moonFree` (N4).
- `lib/domain/services/imaging_opportunity_calculator.dart`, `candidate_evaluator.dart`:
  `OpportunityMoon.up`, read by the Moon gate G4 and the windows' Moon note; `MoonTrack` uses
  `sampleAt`.
- `lib/presentation/viewmodels/night_conditions_viewmodel.dart` (`moonFree`),
  `lib/presentation/shared/night_text.dart` (`MoonText.phaseName`, `MoonText.moonFree`),
  `lib/presentation/widgets/sky_darkness_widget.dart` (Night & Moon: "Phase: …" and the
  moon-free line).
- Docs: `DECISIONS.md` ADR-022; `SCIENTIFIC_INTEGRITY.md` SI-015 resolved, CALC-28/29/33/43.

## Criterion results

| Criterion | Result | Evidence |
| --- | --- | --- |
| CHK-F13.A1 | PASS (TEST + derivation) | ADR-022 N1 derives −(0.2725 π + 0.5667°) topocentric from MF-c and shows it is Meeus' geocentric h₀ moved frame; `moon_up_predicate_test.dart` M1 (−0.8256° for π = 0.95°, strict) and M2 (topocentric vs `aboveGeocentricH0` differ only within one 5-minute step of a crossing: Ljubljana, Tromsø, Quito × three nights) |
| CHK-F13.A2 | PASS (TEST) | N2 test: rise/set events sit on the samples' own crossings; `duringDark`, the closest approach, the gate and the window note read `up`; M4 (78.2° N, December 2026: nights with the Moon always up and always down, no events, moon-free none/allNight); M5 batch (`MoonTrack`) = single (`conditionsForNight`); USNO rise/set reference test passes on the new predicate. Mutation back to altitude > 0°: M1, M2 (Tromsø) and USNO fail |
| CHK-F13.A3 | PASS (TEST) | M6 synthetic streams for noDark, none, allNight, evening, morning, middle, mixed (with intervals and durations, two dark spans); M7 phase bins (22.4 → New, 22.6 → Waxing crescent, 337.6 → New …); N5 night phase; `MoonText.moonFree` for every class and the eight names (`night_summary_text_test.dart`); the Night & Moon section shows both (`sky_darkness_moon_test.dart`). The phase name is separate from the interval text |
| CHK-F13.A4 | PASS (DOC + TEST) | SI-015 resolved with the evidence above; CALC-28/29/33/43 updated; no "good night" threshold added |
| CHK-F13.A5 | PASS (OWNER) | ADR-022 N11 (the D9 control matrix) and N12 (renders: the P3 proposals now, the implemented screens' renders in F15/F17/F18) accepted by the owner |

## Commands (final working tree)

- `flutter test --no-pub -r failures-only test` → `+1982 ~2: All other tests passed!`
- `flutter test --no-pub integration_test/core_loop_test.dart -d flutter-tester` → `+2`;
  `integration_test/perf_scenarios_test.dart` → `+1`
- `flutter analyze --no-pub` → `No issues found!`; format and encoding pass.
