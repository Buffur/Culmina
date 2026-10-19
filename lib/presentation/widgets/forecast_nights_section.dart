import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../domain/models/night_weather_summary.dart';
import '../../domain/services/forecast_overview.dart';
import '../shared/display_units_of.dart';
import '../shared/night_text.dart';
import '../shared/night_time_formatter.dart';
import '../shared/plan_this_night.dart';
import '../viewmodels/night_conditions_viewmodel.dart';
import '../viewmodels/session_plan_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/site_viewmodel.dart';

/// The coming nights one forecast serves (F14 A1/A6; ADR-022 N6/N7/N9):
/// a card per night with its own dark span, how much of it the forecast
/// covers, the cloud range, the dew heuristic and the lead time. Opening a
/// card only shows more; "Plan this night" is the one action that changes
/// the plan, through D9 ([planThisNight]). Never "16 nights", never a
/// score: a partial or missing night says so.
class ForecastNightsSection extends StatelessWidget {
  const ForecastNightsSection({super.key});

  /// "Complete: 9 of 9 dark hours", "Partial: 4 of 9 dark hours (the
  /// forecast starts later)", … (N7).
  static String coverage(ForecastNight n) {
    final s = n.summary;
    return switch (n.coverage) {
      ForecastCoverage.complete =>
        'Complete: ${s.totalHours} of ${s.totalHours} dark hours',
      ForecastCoverage.none => 'No forecast for the dark hours',
      ForecastCoverage.noDark => 'No dark time this night',
      ForecastCoverage.partial =>
        'Partial: ${s.coveredHours} of ${s.totalHours} dark hours (${[if (n.missingBefore > 0) 'the forecast starts later', if (n.missingAfter > 0) 'the forecast ends before dawn', if (n.gaps > 0) '${n.gaps} h missing'].join(', ')})',
    };
  }

  @override
  Widget build(BuildContext context) {
    final conditions = context.watch<NightConditionsViewModel>();
    final plan = context.watch<SessionPlanViewModel>();
    final site = context.watch<SiteViewModel>();
    final limit = context
        .watch<SettingsViewModel>()
        .planningPreferences
        .darknessLimit
        .degrees;
    final overview = conditions.forecastNights;
    if (overview == null || overview.nights.isEmpty) {
      return const SizedBox.shrink();
    }
    final text = Theme.of(context).textTheme;
    final beyond = overview.firstBeyond;
    return Column(
      key: const Key('weather.nights'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text('Coming nights', style: text.titleMedium),
        ),
        Text(
          'One forecast, each night cut to its own dark span. Viewing a '
          "night changes no plan; 'Plan this night' does.",
          style: text.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final n in overview.nights)
          _NightCard(
            night: n,
            isPlan: n.eveningDate == plan.eveningDate,
            limitDeg: limit,
            zoneId: site.displayZoneId,
          ),
        if (beyond != null)
          Text(
            'No forecast from ${NightTimeFormatter.eveningDate(beyond)}: '
            'beyond the 16-day forecast.',
            key: const Key('weather.nights.beyond'),
            style: text.bodySmall,
          ),
      ],
    );
  }
}

class _NightCard extends StatelessWidget {
  const _NightCard({
    required this.night,
    required this.isPlan,
    required this.limitDeg,
    required this.zoneId,
  });

  final ForecastNight night;
  final bool isPlan;
  final double limitDeg;
  final String? zoneId;

  @override
  Widget build(BuildContext context) {
    final small = Theme.of(context).textTheme.bodySmall;
    final s = night.summary;
    final date = night.eveningDate;
    String at(DateTime t) => NightTimeFormatter.instant(
      context,
      t,
      windowStartUtc: night.night.startUtc,
      zoneId: zoneId,
    );
    final covered = s.span != NightWeatherSpan.noDark && s.coveredHours > 0;
    final key = date.toIso8601String();
    return Card(
      key: Key('weather.night.$key'),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ExpansionTile(
        title: Text(
          '${NightTimeFormatter.eveningDate(date)}'
          '${isPlan ? " · your plan's night" : ''}',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(WeatherText.span(s, limitDeg, at), style: small),
            Text(
              ForecastNightsSection.coverage(night),
              key: Key('weather.night.$key.coverage'),
              style: small,
            ),
            if (covered)
              Text(
                'Cloud ${WeatherText.range(s.cloudCover, '%')}',
                style: small,
              ),
            Text(WeatherText.lead(night.leadDays), style: small),
          ],
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        children: [
          if (covered) ...[
            Text(
              'Temperature ${WeatherText.temperatureRange(s.temperature, unitsOf(context))} · dew '
              'point ${WeatherText.temperatureRange(s.dewPoint, unitsOf(context))}',
              style: small,
            ),
            Text(
              'Wind ${WeatherText.windRange(s.windSpeed, unitsOf(context))} · gusts '
              '${WeatherText.windRange(s.windGusts, unitsOf(context))} · precipitation '
              'chance ${WeatherText.range(s.precipitationProbability, '%')}',
              style: small,
            ),
            Text(WeatherText.dew(s, unitsOf(context)), style: small),
          ],
          if (!isPlan)
            TextButton(
              key: Key('weather.night.$key.plan'),
              onPressed: () => planThisNight(context, date),
              child: const Text('Plan this night'),
            ),
        ],
      ),
    );
  }
}
