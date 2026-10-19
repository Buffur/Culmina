import '../../domain/models/calendar_date.dart';
import 'night_time_formatter.dart';

/// The shared plan-night phrase (F17 A5, with F18 A6; AM-03, AM03-T = B):
/// "tonight" only when the plan's night is the current night, otherwise
/// that night's date ("on Fri, Dec 18"). Home's night card, its candidate
/// action and the candidates screen's title use it; the tab label stays
/// "Tonight".
abstract final class PlanNightPhrase {
  /// "tonight", or "on Fri, Dec 18".
  static String of(CalendarDate planNight, CalendarDate tonight) =>
      planNight == tonight
      ? 'tonight'
      : 'on ${NightTimeFormatter.eveningDate(planNight)}';

  /// The Home page title: "Tonight", or "Night of Fri, Dec 18".
  static String title(CalendarDate? planNight, CalendarDate tonight) =>
      planNight == null || planNight == tonight
      ? 'Tonight'
      : 'Night of ${NightTimeFormatter.eveningDate(planNight)}';

  /// "What can I image tonight?" / "What can I image on Fri, Dec 18?".
  static String candidatesAction(
    CalendarDate planNight,
    CalendarDate tonight,
  ) => 'What can I image ${of(planNight, tonight)}?';

  /// The candidates screen's title: "Tonight's candidates", or
  /// "Candidates for Fri, Dec 18" (the list is for the plan's night).
  static String candidatesTitle(CalendarDate planNight, CalendarDate tonight) =>
      planNight == tonight
      ? "Tonight's candidates"
      : 'Candidates for ${NightTimeFormatter.eveningDate(planNight)}';
}
