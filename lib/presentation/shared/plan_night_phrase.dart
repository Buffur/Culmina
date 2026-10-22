import '../../domain/models/calendar_date.dart';
import 'night_time_formatter.dart';

/// The shared plan-night phrase (F17 A5, with F18 A6; AM-03, AM03-T = B):
/// "tonight" only when the plan's night is the current night, otherwise
/// that night's date ("on 18 Dec"). Home's night card, its candidate
/// action and the candidates screen's title use it; the tab label stays
/// "Tonight".
abstract final class PlanNightPhrase {
  /// "tonight", or "on 18 Dec".
  static String of(CalendarDate planNight, CalendarDate tonight) =>
      planNight == tonight
      ? 'tonight'
      : 'on ${NightTimeFormatter.eveningDate(planNight)}';

  /// The Home page title: "Tonight", or "Night of 18 Dec".
  static String title(CalendarDate? planNight, CalendarDate tonight) =>
      planNight == null || planNight == tonight
      ? 'Tonight'
      : 'Night of ${NightTimeFormatter.eveningDate(planNight)}';

  /// "What can I image tonight?" / "What can I image on 18 Dec?".
  static String candidatesAction(
    CalendarDate planNight,
    CalendarDate tonight,
  ) => 'What can I image ${of(planNight, tonight)}?';

  /// The candidates screen's title: "Tonight's candidates", or
  /// "Candidates for 18 Dec" (the list is for the plan's night).
  static String candidatesTitle(CalendarDate planNight, CalendarDate tonight) =>
      planNight == tonight
      ? "Tonight's candidates"
      : 'Candidates for ${NightTimeFormatter.eveningDate(planNight)}';

  /// [text] worded for the plan's night (F18 A6): unchanged when the plan's
  /// night is tonight; otherwise each "tonight" names the night. Only the
  /// words change; the value, fit or window a text reports never does.
  static String apply(
    String text,
    CalendarDate planNight,
    CalendarDate tonight,
  ) {
    if (planNight == tonight) return text;
    final on = of(planNight, tonight);
    String cap(String s, bool upper) =>
        upper ? '${s[0].toUpperCase()}${s.substring(1)}' : s;
    return text
        .replaceAllMapped(
          RegExp(r"([Tt])onight's (windows|window|dark time)"),
          (m) => cap('the ${m[2]} $on', m[1] == 'T'),
        )
        .replaceAllMapped(
          RegExp(r'\b([Tt])onight\b'),
          (m) => cap(on, m[1] == 'T'),
        );
  }
}
