// F15 A1/A5 (ADR-022 N1–N5, N10): a browsed night is computed by the same
// calculators as the plan's: its segments tile the night, its moon-free
// time equals MoonConditions.moonFree on the same grid, the calendar's day
// equals the night's own view, the cursor's state names the end of the
// current dark or not-dark interval, and the month's cache key changes with
// each input N10 names.

import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/iana_time_context.dart';
import 'package:astroplan/domain/models/moon_conditions.dart';
import 'package:astroplan/domain/services/moon_calendar.dart';
import 'package:astroplan/domain/services/night_view.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

final _zone = IanaTimeContext.tryCreate('Europe/Ljubljana')!;

NightView _view(CalendarDate d, {double lat = 46.05, double limit = -18}) =>
    NightView.of(
      SessionNightResolver.forEveningDate(
        d,
        latitude: lat,
        longitude: 14.51,
        timeContext: _zone,
      ),
      limitDeg: limit,
    );

void main() {
  final dec17 = CalendarDate(2026, 12, 17);

  test('segments tile the night, in order, without gaps', () {
    final v = _view(dec17);
    expect(v.segments.first.startUtc, v.night.startUtc);
    expect(v.segments.last.endUtc, v.night.endUtc);
    for (var i = 1; i < v.segments.length; i++) {
      expect(v.segments[i].startUtc, v.segments[i - 1].endUtc);
    }
    expect(
      v.segments.map((s) => s.sky),
      containsAll([SkyState.daylight, SkyState.civil, SkyState.dark]),
    );
    // The dark segments are exactly the dark span at the limit, on the grid.
    final dark = v.segments.where((s) => s.sky == SkyState.dark);
    expect(
      dark.fold(Duration.zero, (t, s) => t + s.endUtc.difference(s.startUtc)),
      v.moonFree.dark,
    );
  });

  test('the cursor names the end of the current interval: time left in the '
      'dark, or time until it', () {
    final v = _view(dec17);
    final evening = v.at(v.night.startUtc.add(const Duration(hours: 4)));
    expect(evening.dark, isFalse);
    expect(evening.darkChangeUtc, isNotNull);
    final inDark = v.at(evening.darkChangeUtc!);
    expect(inDark.dark, isTrue);
    expect(inDark.sky, SkyState.dark);
    expect(inDark.darkChangeUtc!.isAfter(inDark.instantUtc), isTrue);
    expect(
      evening.untilDarkChange,
      evening.darkChangeUtc!.difference(evening.instantUtc),
    );
    // Clamped to the night; the Moon's next change is a sample where `up`
    // flips (N1, N3).
    expect(
      v.at(v.night.endUtc.add(const Duration(days: 1))).instantUtc,
      v.night.endUtc,
    );
    final m = v.at(v.night.startUtc);
    if (m.moonChangeUtc case final c?) {
      expect(v.at(c).moonUp, isNot(m.moonUp));
    }
  });

  test('a −12° limit counts astronomical twilight as dark', () {
    final v = _view(dec17, limit: -12);
    expect(v.segments.any((s) => s.sky == SkyState.astronomical), isFalse);
    expect(v.segments.any((s) => s.sky == SkyState.dark), isTrue);
  });

  test('no dark time: a June night at 60° N is never dark at −18°', () {
    final v = _view(CalendarDate(2026, 6, 20), lat: 60);
    expect(v.segments.any((s) => s.sky == SkyState.dark), isFalse);
    expect(v.moonFree.kind, MoonFreeKind.noDark);
    final i = v.at(v.night.startUtc.add(const Duration(hours: 12)));
    expect((i.dark, i.darkChangeUtc), (false, null));
  });

  test(
    'the calendar day equals the night\'s own view (A1: one calculation)',
    () {
      final days = MoonCalendar.compute(
        const MoonCalendarRequest(
          latitude: 46.05,
          longitude: 14.51,
          zoneId: 'Europe/Ljubljana',
          limitDeg: -18,
          year: 2026,
          month: 12,
        ),
      );
      expect(days, hasLength(31));
      expect(days.first.date, CalendarDate(2026, 12, 1));
      final d = days.firstWhere((x) => x.date == dec17);
      final v = _view(dec17);
      expect(d.moonFree.kind, v.moonFree.kind);
      expect(d.moonFree.moonFree, v.moonFree.moonFree);
      expect(d.moonFree.intervals, v.moonFree.intervals);
      expect(d.phase, v.moon.phaseName);
      expect(d.illumination, v.moon.illuminationAtMidnight);
    },
  );

  test('N10: the month key changes with coordinates, zone, limit, version '
      'and month; equal inputs give equal keys', () {
    MoonCalendarRequest r({
      double lat = 46.05,
      String? zone = 'Europe/Ljubljana',
      double limit = -18,
      int month = 12,
    }) => MoonCalendarRequest(
      latitude: lat,
      longitude: 14.51,
      zoneId: zone,
      limitDeg: limit,
      year: 2026,
      month: month,
    );
    expect(r().key, r(lat: 46.054).key, reason: 'one 0.01° cell');
    for (final other in [
      r(lat: 46.06),
      r(zone: null),
      r(limit: -12),
      r(month: 11),
    ]) {
      expect(other.key, isNot(r().key));
    }
    expect(r().key, contains('v${MoonCalendarRequest.calculatorVersion}'));
  });
}
