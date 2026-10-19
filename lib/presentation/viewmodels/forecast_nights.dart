import '../../domain/models/calendar_date.dart';
import '../../domain/models/night_weather.dart';
import '../../domain/models/planning_preferences.dart';
import '../../domain/services/forecast_overview.dart';
import '../../domain/services/visibility_calculator.dart';
import 'site_viewmodel.dart';

typedef ForecastNights = ({
  List<ForecastNight> nights,
  CalendarDate? firstBeyond,
});

/// The coming nights one forecast serves (F14; ADR-022 N6/N7/N9), for
/// [NightConditionsViewModel.forecastNights]: tonight and the next 15
/// nights at the site, each sliced to its own dark span. Cached per input;
/// browsing them never changes the plan (D9).
class ForecastNightsCache {
  Object? _key;
  ForecastNights? _value;

  ForecastNights? of(
    NightWeather weather,
    SiteViewModel site,
    PlanningPreferences prefs,
  ) {
    final darknessLimitDeg = prefs.darknessLimit.degrees;
    final dewMarginC = prefs.dewMarginC;
    if (weather is! NightWeatherAvailable || site.isDefaultLocation) {
      return null;
    }
    final tonight = site.nightAt(null);
    final key = (
      weather.snapshot,
      tonight,
      site.timeContext.id,
      darknessLimitDeg,
      dewMarginC,
    );
    if (_key != key) {
      _value = ForecastOverview.of(
        weather.snapshot,
        [
          for (var i = 0; i < 16; i++)
            VisibilityCalculator.calculateNightTimelineForNight(
              i == 0 ? tonight : site.nightAt(tonight.eveningDate.addDays(i)),
              darknessLimitDeg: darknessLimitDeg,
            ),
        ],
        dewMarginC: dewMarginC,
        timeContext: site.timeContext,
      );
      _key = key;
    }
    return _value;
  }
}
