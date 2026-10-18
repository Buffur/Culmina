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
