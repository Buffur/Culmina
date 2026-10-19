import '../models/calendar_date.dart';
import '../models/iana_time_context.dart';
import '../models/moon_conditions.dart';
import '../models/site_time_context.dart';
import 'night_view.dart';
import 'session_night_resolver.dart';

/// One night of the Moon calendar (F15 A1; ADR-022 N4/N5): its phase name
/// and lit fraction at local midnight, and its moon-free dark time. The
/// same calculation as the night's own view ([NightView]), so the calendar
/// and the detail agree.
class MoonCalendarDay {
  const MoonCalendarDay({
    required this.date,
    required this.phase,
    required this.illumination,
    required this.phaseLongitudeDeg,
    required this.moonFree,
  });

  /// The night's evening date.
  final CalendarDate date;
  final MoonPhaseName? phase;

  /// Lit fraction at local midnight, 0–1.
  final double illumination;

  /// The Moon − Sun ecliptic longitude at local midnight (the phase angle
  /// the glyph is drawn from), or null.
  final double? phaseLongitudeDeg;
  final MoonFreeNight moonFree;
}

/// What a month's calendar depends on (ADR-022 N10): the site cell, its zone
/// rule, the darkness limit, the calculator's version and the month. Plain
/// values, so it can be sent to an isolate; equal requests give equal
/// months, and a change of any of them is a new key (never the weather).
class MoonCalendarRequest {
  const MoonCalendarRequest({
    required this.latitude,
    required this.longitude,
    required this.zoneId,
    required this.limitDeg,
    required this.year,
    required this.month,
  });

  /// Bumped whenever the Moon or night calculation changes.
  static const calculatorVersion = 1;

  final double latitude;
  final double longitude;

  /// The site's IANA zone, or null for mean solar time (ADR-007 §6).
  final String? zoneId;
  final double limitDeg;
  final int year;
  final int month;

  /// N10: coordinates rounded to 0.01°, zone, limit, version, month.
  String get key =>
      '${latitude.toStringAsFixed(2)}:${longitude.toStringAsFixed(2)}:'
      '${zoneId ?? 'solar'}:$limitDeg:v$calculatorVersion:$year-$month';
}

/// The Moon calendar of one month (F15 A1): pure, slow enough (a full Moon
/// track per night) to run in an isolate — see [compute].
abstract final class MoonCalendar {
  /// Every evening date of [r]'s month, in order.
  static List<MoonCalendarDay> compute(MoonCalendarRequest r) {
    final SiteTimeContext context =
        IanaTimeContext.tryCreate(r.zoneId) ??
        MeanSolarTimeContext(r.longitude);
    final days = <MoonCalendarDay>[];
    for (
      var d = CalendarDate(r.year, r.month, 1);
      d.month == r.month;
      d = d.addDays(1)
    ) {
      final night = SessionNightResolver.forEveningDate(
        d,
        latitude: r.latitude,
        longitude: r.longitude,
        timeContext: context,
      );
      final view = NightView.of(night, limitDeg: r.limitDeg);
      days.add(
        MoonCalendarDay(
          date: d,
          phase: view.moon.phaseName,
          illumination: view.moon.illuminationAtMidnight,
          phaseLongitudeDeg: view.moon.phaseLongitudeAtMidnightDeg,
          moonFree: view.moonFree,
        ),
      );
    }
    return days;
  }
}
