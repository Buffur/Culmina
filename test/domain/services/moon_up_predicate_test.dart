// ADR-022 (F13): one Moon-up predicate, the moon-free intervals and the phase
// name, against the decision sheet's vectors M1, M2, M4–M7. M3 (USNO rise and
// set) is moon_calculator_test.dart's reference test, which now runs on the
// same predicate.

import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/imaging_opportunity.dart';
import 'package:astroplan/domain/models/moon_conditions.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/models/site_time_context.dart';
import 'package:astroplan/domain/services/candidate_evaluator.dart';
import 'package:astroplan/domain/services/imaging_opportunity_calculator.dart';
import 'package:astroplan/domain/services/moon_calculator.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

SessionNight _night(CalendarDate d, double lat, double lon) =>
    SessionNightResolver.forEveningDate(
      d,
      latitude: lat,
      longitude: lon,
      timeContext: MeanSolarTimeContext(lon),
    );

void main() {
  test('M1: the threshold for π = 0.95° is −0.8256° topocentric', () {
    expect(MoonCalculator.upThresholdDeg(0.95), closeTo(-0.8256, 0.00005));
    expect(MoonCalculator.isUp(-0.8255, 0.95), isTrue);
    expect(MoonCalculator.isUp(-0.8257, 0.95), isFalse);
    // N3: exactly at the threshold is down.
    expect(
      MoonCalculator.isUp(MoonCalculator.upThresholdDeg(0.95), 0.95),
      isFalse,
    );
  });

  // CHK-F13.A1/A2: between −0.83° and 0° the centre is below the geometric
  // horizon but its upper limb is above the apparent one, so the Moon is up
  // (ADR-022 N1): never `altitude > 0`, nor Meeus' geocentric h₀ copied
  // into the topocentric frame. The threshold follows the parallax: across
  // π = 0.90°…1.00° it runs −0.81195°…−0.8392°.
  test('N1 boundary vectors: −0.84° down, −0.83° by the parallax, −0.5° '
      'and 0° up', () {
    for (final (alt, upAt) in [
      (-0.84, {0.90: false, 0.95: false, 1.00: false}),
      (-0.83, {0.90: false, 0.95: false, 1.00: true}),
      (-0.5, {0.90: true, 0.95: true, 1.00: true}),
      (0.0, {0.90: true, 0.95: true, 1.00: true}),
    ]) {
      for (final MapEntry(key: pi, value: up) in upAt.entries) {
        expect(MoonCalculator.isUp(alt, pi), up, reason: 'h $alt° at π $pi°');
      }
    }
    expect(MoonCalculator.upThresholdDeg(0.90), closeTo(-0.81195, 1e-9));
    expect(MoonCalculator.upThresholdDeg(1.00), closeTo(-0.8392, 1e-9));
  });

  test('on real nights, a sample between −0.81° and 0° is up for rise/set, '
      'the batch track and the Moon gate; one below −0.85° is down', () {
    var sawBand = 0;
    var sawBelow = 0;
    for (var day = 0; day < 30; day++) {
      final night = _night(
        CalendarDate(2026, 12, 1).addDays(day),
        46.05,
        14.51,
      );
      final c = MoonCalculator.conditionsForNight(night);
      final batch = MoonTrack.forNight(night);
      final n = c.samples.length;
      final gated = ImagingOpportunityCalculator.fromSamples(
        night: night,
        sunAltitudesDeg: List.filled(n, -30),
        targetAltitudesDeg: List.filled(n, 60),
        darknessLimitDeg: -18,
        minAltitudeDeg: 30,
        gates: const OptionalGates(moonMinIlluminationPct: 0),
        moon: OpportunityMoon.fromConditions(c),
      );
      final upCount = c.samples.where((s) => s.up).length;
      expect(
        gated.samples.where((s) => s.failing.contains(OpportunityGate.moon)),
        hasLength(upCount),
      );
      for (final (i, s) in c.samples.indexed) {
        final moonGate = gated.samples[i].failing.contains(
          OpportunityGate.moon,
        );
        if (s.altitudeDeg > -0.81 && s.altitudeDeg <= 0) {
          sawBand++;
          expect(
            (s.up, batch.up[i], moonGate),
            (true, true, true),
            reason: '$i',
          );
        } else if (s.altitudeDeg < -0.85) {
          sawBelow++;
          expect((s.up, batch.up[i], moonGate), (false, false, false));
        }
      }
      // Rise/set: an event exactly where `up` changes, a band sample too.
      expect(c.riseSet.aboveAtStart, c.samples.first.up);
      final events = {for (final e in c.riseSet.events) e.utc: e.kind};
      for (var i = 1; i < n; i++) {
        final prev = c.samples[i - 1].up;
        final now = c.samples[i].up;
        expect(
          events[c.samples[i].instantUtc],
          prev == now
              ? isNull
              : now
              ? MoonEventKind.rise
              : MoonEventKind.set,
          reason: '$i',
        );
      }
    }
    expect(sawBand, greaterThan(0), reason: 'the band was sampled');
    expect(sawBelow, greaterThan(0));
  });

  // M2: the topocentric predicate and the classical geocentric h₀ form are
  // one event: they disagree only within one grid step of a crossing.
  group('M2: equivalent to Meeus h₀ in the geocentric frame', () {
    for (final (site, lat, lon) in [
      ('Ljubljana', 46.05, 14.51),
      ('Tromsø', 69.65, 18.96),
      ('Quito', -0.18, -78.47),
    ]) {
      test(site, () {
        for (final d in [
          CalendarDate(2026, 3, 1),
          CalendarDate(2026, 9, 22),
          CalendarDate(2027, 1, 15),
        ]) {
          final night = _night(d, lat, lon);
          final c = MoonCalculator.conditionsForNight(night);
          final geo = [
            for (final s in c.samples)
              MoonCalculator.aboveGeocentricH0(s.instantUtc, lat, lon),
          ];
          final topo = [for (final s in c.samples) s.up];
          for (var i = 0; i < topo.length; i++) {
            if (topo[i] == geo[i]) continue;
            final nearCrossing = [i - 1, i + 1].any(
              (j) =>
                  j >= 0 &&
                  j < topo.length &&
                  (topo[j] != topo[i] || geo[j] != geo[i]),
            );
            expect(
              nearCrossing,
              isTrue,
              reason: '$site $d sample $i (${c.samples[i].instantUtc})',
            );
          }
        }
      });
    }
  });

  test('M4: a Moon that never sets or never rises has no event and is '
      'classified, at 78.2° N over a month', () {
    var sawUp = false;
    var sawDown = false;
    for (var day = 0; day < 30; day++) {
      final d = CalendarDate(2026, 12, 1).addDays(day);
      final night = _night(d, 78.2, 15.6);
      final c = MoonCalculator.conditionsForNight(night);
      final ups = c.samples.map((s) => s.up).toSet();
      if (ups.length != 1) continue;
      expect(c.riseSet.events, isEmpty, reason: '$d');
      final allUp = ups.single;
      expect(c.riseSet.aboveAtStart, allUp);
      final sun = SunTrack.forNight(night).altitudesDeg;
      final free = c.moonFree(sunAltitudesDeg: sun, darknessLimitDeg: -6);
      if (free.kind != MoonFreeKind.noDark) {
        expect(
          free.kind,
          allUp ? MoonFreeKind.none : MoonFreeKind.allNight,
          reason: '$d',
        );
      }
      if (allUp) sawUp = true;
      if (!allUp) sawDown = true;
    }
    expect((sawUp, sawDown), (true, true));
  });

  test('M5: the batch track and the single night give identical samples', () {
    final night = _night(CalendarDate(2026, 12, 15), 46.05, 14.51);
    final single = MoonCalculator.conditionsForNight(night);
    final batch = MoonTrack.forNight(night);
    expect(batch.up, [for (final s in single.samples) s.up]);
    expect(batch.altitudesDeg, [for (final s in single.samples) s.altitudeDeg]);
    expect(ImagingOpportunityCalculator.gridCount, single.samples.length);
  });

  test('N2: rise/set, the Moon-up count and the samples agree', () {
    final night = _night(CalendarDate(2026, 12, 15), 46.05, 14.51);
    final c = MoonCalculator.conditionsForNight(night);
    expect(c.riseSet.aboveAtStart, c.samples.first.up);
    for (final e in c.riseSet.events) {
      final i = c.samples.indexWhere((s) => s.instantUtc == e.utc);
      expect(c.samples[i].up, e.kind == MoonEventKind.rise);
      expect(c.samples[i - 1].up, e.kind != MoonEventKind.rise);
    }
    expect(
      MoonCalculator.riseSetForNight(night).events.map((e) => e.utc),
      c.riseSet.events.map((e) => e.utc),
    );
  });

  group('M6: moon-free classification (synthetic samples)', () {
    final t0 = DateTime.utc(2026, 12, 15, 12);
    MoonFreeNight classify(String dark, String up) {
      final n = dark.length;
      return MoonFreeNight.classify(
        instants: [
          for (var i = 0; i < n; i++) t0.add(Duration(minutes: 5 * i)),
        ],
        dark: [for (final c in dark.split('')) c == 'D'],
        moonUp: [for (final c in up.split('')) c == 'M'],
      );
    }

    test('noDark, none, allNight', () {
      expect(classify('......', '......').kind, MoonFreeKind.noDark);
      expect(classify('.DDDD.', 'MMMMMM').kind, MoonFreeKind.none);
      final all = classify('.DDDD.', 'M....M');
      expect(all.kind, MoonFreeKind.allNight);
      expect(all.moonFree, const Duration(minutes: 20));
      expect(all.dark, const Duration(minutes: 20));
    });

    test('evening, morning, middle, mixed, with intervals', () {
      final evening = classify('.DDDD.', '...MMM');
      expect(evening.kind, MoonFreeKind.evening);
      expect(evening.intervals, [
        (
          t0.add(const Duration(minutes: 5)),
          t0.add(const Duration(minutes: 15)),
        ),
      ]);
      expect(classify('.DDDD.', 'MMM...').kind, MoonFreeKind.morning);
      expect(classify('DDDDDD', 'MM..MM').kind, MoonFreeKind.middle);
      final mixed = classify('DDDDDD', '.MM.M.');
      expect(mixed.kind, MoonFreeKind.mixed);
      expect(mixed.intervals, hasLength(3));
      expect(mixed.moonFree, const Duration(minutes: 15));
    });

    test('two dark spans (dark at both ends) still classify by the first '
        'and last dark sample', () {
      expect(classify('DD..DD', '......').kind, MoonFreeKind.mixed);
      expect(classify('DD..DD', '....MM').kind, MoonFreeKind.evening);
    });
  });

  test('M7: phase-name bins', () {
    for (final (l, name) in [
      (0.0, MoonPhaseName.newMoon),
      (22.4, MoonPhaseName.newMoon),
      (22.6, MoonPhaseName.waxingCrescent),
      (90.0, MoonPhaseName.firstQuarter),
      (180.0, MoonPhaseName.full),
      (270.0, MoonPhaseName.lastQuarter),
      (337.4, MoonPhaseName.waningCrescent),
      (337.6, MoonPhaseName.newMoon),
      (359.9, MoonPhaseName.newMoon),
    ]) {
      expect(MoonPhaseName.of(l), name, reason: '$l');
    }
  });

  test('N5: the night has a phase name from its midnight phase longitude', () {
    final night = _night(CalendarDate(2026, 12, 15), 46.05, 14.51);
    final c = MoonCalculator.conditionsForNight(night);
    expect(
      c.phaseName,
      MoonPhaseName.of(
        MoonCalculator.phaseLongitudeDeg(
          night.startUtc.add(const Duration(hours: 12)),
        ),
      ),
    );
  });
}
