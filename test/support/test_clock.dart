import 'package:astroplan/core/time/clock.dart';

/// A clock that starts at a fixed instant and moves on with real elapsed
/// time: a test's date and night never depend on when it runs, and
/// successive writes still get increasing timestamps (F24 A1, TD-096).
class TestClock extends Clock {
  TestClock(this.start) {
    if (!start.isUtc) throw ArgumentError.value(start, 'start', 'must be UTC');
  }

  final DateTime start;
  final Stopwatch _elapsed = Stopwatch()..start();

  @override
  DateTime nowUtc() => start.add(_elapsed.elapsed);
}

/// The tests' default "now", shared by [PlannerHarness] and the
/// repositories a test builds without a clock: 18:00 UTC on 10 Nov 2026, an
/// evening after astronomical dusk at the app's default position (London),
/// so "tonight" is that night whatever the wall clock says. TD-096: a
/// morning run once found the night already over.
final testEvening = TestClock(DateTime.utc(2026, 11, 10, 18));

/// The morning after [testEvening] (F24 A1): 06:00 UTC on 11 Nov 2026, 06:00
/// at the default position (London) and 07:00 in Ljubljana, before sunrise
/// at both and before the site's mean solar noon. By ADR-007 §5 (L4) the
/// planner's night is still the one that began on the evening of 10 Nov:
/// the default night changes at mean solar noon, not at midnight or dawn.
final testMorning = TestClock(DateTime.utc(2026, 11, 11, 6));
