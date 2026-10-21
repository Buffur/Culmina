import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/models/night_weather.dart';
import '../../domain/models/night_weather_summary.dart';
import '../../domain/models/weather_snapshot.dart';
import '../../domain/services/forecast_overview.dart';
import '../shared/clear_outside_link.dart';
import '../shared/night_time_formatter.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/site_viewmodel.dart';
import '../viewmodels/night_conditions_viewmodel.dart';
import '../../core/utils/quantity_text.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/hybrid_tokens.dart';
import '../../core/units/display_units.dart';
import '../shared/display_units_of.dart';
import '../shared/night_text.dart';
import '../../core/theme/app_spacing.dart';
import 'weather_hourly_charts.dart';

/// The chosen night's weather (ADR-022 N6): the selected dark span,
/// per-hour indicators and per-variable ranges with explicit units, the
/// forecast's age and model, and no score or good/bad colouring. Hours
/// without a forecast say so; they are never shown as zero.
class WeatherForecastWidget extends StatelessWidget {
  final VoidCallback? onTap;

  /// False when the enclosing conditions browser already states the site zone.
  final bool showZone;

  const WeatherForecastWidget({super.key, this.onTap, this.showZone = true});

  @override
  Widget build(BuildContext context) {
    final conditionsVm = context.watch<NightConditionsViewModel>();
    final siteVm = context.watch<SiteViewModel>();
    final theme = Theme.of(context);
    final state = conditionsVm.nightWeather;
    final small = theme.textTheme.bodySmall?.copyWith(
      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.75),
    );

    return Card(
      color: theme.scaffoldBackgroundColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (onTap != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onTap,
                child: const Text('Open weather details'),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              0,
              AppSpacing.sm,
              0,
              AppSpacing.sm,
            ),
            child: switch (state) {
              NightWeatherIdle() => const Text(
                "Set a site to see the night's forecast.",
              ),
              NightWeatherLoading() => const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(),
                  SizedBox(height: AppSpacing.sm),
                  Text(WeatherText.loading),
                ],
              ),
              NightWeatherOutOfRange() => const Text(
                WeatherText.outOfRange,
                key: Key('weather.outOfRange'),
              ),
              NightWeatherUnavailable(:final failure) => Row(
                key: const Key('weather.unavailable'),
                children: [
                  Icon(Icons.cloud_off, color: AppPalette.of(context).muted),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('No forecast.'),
                        Text(WeatherText.failure(failure), style: small),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => conditionsVm.refreshWeather(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
              NightWeatherAvailable() => _AvailableBody(
                state: state,
                showZone: showZone,
                onRefresh: () => conditionsVm.refreshWeather(),
                summary: conditionsVm.nightWeatherSummary,
                zoneId: siteVm.displayZoneId,
                windowStartUtc: conditionsVm.sessionNight?.startUtc,
                limitDeg: context
                    .watch<SettingsViewModel>()
                    .planningPreferences
                    .darknessLimit
                    .degrees,
                leadDays: switch (conditionsVm.sessionNight?.eveningDate) {
                  final night? => ForecastOverview.daysBetween(
                    ForecastOverview.localDate(
                      state.snapshot.fetchedAtUtc,
                      siteVm.timeContext,
                    ),
                    night,
                  ),
                  null => null,
                },
                latitude: siteVm.latitude,
                longitude: siteVm.longitude,
              ),
            },
          ),
          if (siteVm.locationNameAttribution case final attribution?)
            Text('Place name $attribution', style: small),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: InkWell(
              onTap: () => launchUrl(
                Uri.parse('https://open-meteo.com/'),
                mode: LaunchMode.externalApplication,
              ),
              // TASK 15.3: a 48 px tap target.
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Weather data by Open-Meteo.com (CC BY 4.0)',
                    key: const Key('weather.attribution'),
                    style: small?.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailableBody extends StatelessWidget {
  const _AvailableBody({
    required this.state,
    required this.showZone,
    required this.onRefresh,
    required this.summary,
    required this.zoneId,
    required this.windowStartUtc,
    required this.limitDeg,
    required this.leadDays,
    required this.latitude,
    required this.longitude,
  });

  final NightWeatherAvailable state;
  final bool showZone;
  final VoidCallback onRefresh;
  final NightWeatherSummary? summary;
  final String? zoneId;
  final DateTime? windowStartUtc;
  final double limitDeg;
  final int? leadDays;
  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final small = theme.textTheme.bodySmall;
    final s = summary;
    final start = windowStartUtc;
    final snapshot = state.snapshot;
    String at(DateTime t) => NightTimeFormatter.instant(
      context,
      t,
      windowStartUtc: start ?? t,
      zoneId: zoneId,
    );
    final coverage = s == null ? null : WeatherText.coverage(s);

    // F14 A3: the selected night's facts first, then the hours, then the
    // full table, model and source in Details.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (s != null && start != null) ...[
          if (s.span != NightWeatherSpan.noDark && s.coveredHours > 0) ...[
            Text(
              s.cloudCover == null
                  ? 'Cloud cover unknown'
                  : 'Cloud ${WeatherText.range(s.cloudCover, '%')} '
                        '${s.cloudGapHours > 0 ? 'in ${s.totalHours - s.cloudGapHours}/${s.totalHours} known dark hours' : 'in the dark'}',
              key: const Key('weather.facts'),
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            // Hybrid adds the dark span's length (conditions.js).
            s.span == NightWeatherSpan.noDark
                ? WeatherText.span(s, limitDeg, at)
                : '${WeatherText.span(s, limitDeg, at)} · '
                      '${QuantityText.duration(s.toUtc.difference(s.fromUtc))}',
            key: const Key('weather.span'),
            style: theme.textTheme.bodyMedium,
          ),
          if (WeatherText.trend(s, at) case final trend?) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              trend,
              key: const Key('weather.trend'),
              style: theme.textTheme.bodyMedium,
            ),
          ],
          if (showZone)
            Text(
              'Times in ${NightTimeFormatter.zoneCaption(s.fromUtc, zoneId: zoneId)}',
              key: const Key('weather.zone'),
              style: small,
            ),
          if (s.span != NightWeatherSpan.noDark && s.coveredHours > 0) ...[
            const SizedBox(height: AppSpacing.md),
            _WeatherFacts(summary: s),
          ],
          if (WeatherText.coverageCount(s) case final count?) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              count,
              key: const Key('weather.coverage'),
              style: small?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
          if (coverage != null)
            Text(
              coverage,
              key: Key(
                s.coveredHours == 0 ? 'weather.noCoverage' : 'weather.partial',
              ),
              style: small,
            ),
        ],
        // N9: the lead time and the retrieval age are two different facts.
        if (leadDays case final d?)
          Text(
            WeatherText.lead(d),
            key: const Key('weather.lead'),
            style: small,
          ),
        _FreshnessLine(state: state),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            key: const Key('weather.refresh'),
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh forecast'),
          ),
        ),
        if (s != null &&
            start != null &&
            s.span != NightWeatherSpan.noDark &&
            s.coveredHours > 0) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            WeatherText.dew(s, unitsOf(context)),
            key: const Key('weather.dew'),
            style: small?.copyWith(
              color: s.dewRiskHours > 0
                  ? theme.extension<HybridTokens>()?.weatherCaution
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          WeatherHourlyCharts(
            slots: s.slots,
            zoneId: zoneId,
            exactDescription: _HourColumn.exact,
          ),
          Text(
            'Precipitation and gusts are for the hour before each time; '
            '* marks an hour only partly in the dark span.',
            key: const Key('weather.precipNote'),
            style: small,
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        // Q3 (PD-18): the limitation, and a page the user opens.
        Text(
          WeatherText.notSeeing,
          key: const Key('weather.notSeeing'),
          style: small,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            key: const Key('weather.clearOutside'),
            onPressed: () => launchUrl(
              ClearOutsideLink.at(latitude, longitude),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Look at Clear Outside'),
          ),
        ),
        ExpansionTile(
          key: const Key('weather.details'),
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          title: const Text('Details'),
          subtitle: Text(
            'Every variable, the model and the source',
            style: small,
          ),
          children: [
            if (s != null && s.coveredHours > 0) ...[
              _Ranges(summary: s),
              const SizedBox(height: AppSpacing.md),
              Text('Hourly values', style: theme.textTheme.titleSmall),
              _HourStrip(summary: s, zoneId: zoneId),
            ],
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Model: ${snapshot.provider} / ${snapshot.model}',
              key: const Key('weather.model'),
              style: small,
            ),
            Text(
              'Retrieved ${NightTimeFormatter.clockTime(context, snapshot.fetchedAtUtc, zoneId: zoneId)}'
              ' (${WeatherText.ago(state.ageDuration)})',
              style: small,
            ),
          ],
        ),
      ],
    );
  }
}

class _WeatherFacts extends StatelessWidget {
  const _WeatherFacts({required this.summary});
  final NightWeatherSummary summary;

  @override
  Widget build(BuildContext context) {
    final units = unitsOf(context);
    final text = Theme.of(context).textTheme;
    final facts = [
      (
        'Air temperature',
        WeatherText.temperatureRange(summary.temperature, units),
      ),
      ('Dew point', WeatherText.temperatureRange(summary.dewPoint, units)),
      (
        'Wind and gusts',
        '${WeatherText.windRange(summary.windSpeed, units)}\n'
            'Gusts ${WeatherText.windRange(summary.windGusts, units)}',
      ),
      (
        'Rain chance',
        '${WeatherText.range(summary.precipitationProbability, '%')} '
            'in sampled hours',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final large = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
        final width = large
            ? constraints.maxWidth
            : (constraints.maxWidth - 16) / 2;
        return Wrap(
          spacing: 16,
          runSpacing: 24,
          children: [
            for (final (label, value) in facts)
              SizedBox(
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: text.bodySmall),
                    const SizedBox(height: 4),
                    Text(value, style: text.bodyMedium),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FreshnessLine extends StatelessWidget {
  const _FreshnessLine({required this.state});

  final NightWeatherAvailable state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = WeatherText.freshness(state);
    final failed = state.refreshFailed;
    final prefix = failed == null
        ? ''
        : failed == WeatherFailure.unavailable
        ? 'Offline, showing the cached forecast. '
        : 'Refresh failed, showing the cached forecast. ';
    final warn = failed != null || state.age != WeatherAge.current;
    final caution = theme.extension<HybridTokens>()?.weatherCaution;
    return Row(
      key: const Key('weather.freshness'),
      children: [
        if (warn) ...[
          Icon(Icons.history, size: 16, color: caution),
          const SizedBox(width: AppSpacing.xs),
        ],
        Expanded(
          child: Text(
            '$prefix$text',
            style: theme.textTheme.bodySmall?.copyWith(
              color: warn ? caution : null,
              fontWeight: warn ? FontWeight.bold : null,
            ),
          ),
        ),
      ],
    );
  }
}

WeatherRange? _km(WeatherRange? m) =>
    m == null ? null : WeatherRange(m.min / 1000, m.max / 1000);

class _Ranges extends StatelessWidget {
  const _Ranges({required this.summary});

  final NightWeatherSummary summary;

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final rows = <(String, String)>[
      ('Cloud cover (total)', WeatherText.range(s.cloudCover, '%')),
      ('Low cloud (below 3 km)', WeatherText.range(s.cloudCoverLow, '%')),
      ('Mid cloud (3–8 km)', WeatherText.range(s.cloudCoverMid, '%')),
      ('High cloud (above 8 km)', WeatherText.range(s.cloudCoverHigh, '%')),
      (
        // Open-Meteo's value covers the preceding hour (S1.13; SCI-02).
        'Chance of precipitation (preceding hour)',
        WeatherText.range(s.precipitationProbability, '%'),
      ),
      ('Wind at 10 m', WeatherText.windRange(s.windSpeed, unitsOf(context))),
      (
        'Gusts (max of preceding hour)',
        WeatherText.windRange(s.windGusts, unitsOf(context)),
      ),
      (
        'Temperature',
        WeatherText.temperatureRange(s.temperature, unitsOf(context)),
      ),
      ('Dew point', WeatherText.temperatureRange(s.dewPoint, unitsOf(context))),
      ('Relative humidity', WeatherText.range(s.relativeHumidity, '%')),
      (
        'Horizontal visibility (not transparency)',
        WeatherText.range(_km(s.visibility), 'km', digits: 1),
      ),
    ];
    final style = Theme.of(context).textTheme.bodySmall;
    return Column(
      key: const Key('weather.ranges'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Night ranges', style: Theme.of(context).textTheme.labelLarge),
        for (final (label, value) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs / 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(label, style: style)),
                // S1.10 (UX-31): never runs into the label at large text.
                const SizedBox(width: AppSpacing.sm),
                Text(
                  value,
                  style: style?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The dark span's hours on its time axis (F14 A3; ADR-022 N6): one
/// column per row, a legend column first giving each row's unit. Cloud is a
/// bar under its number; temperature with dew point; wind with gusts;
/// precipitation chance. A row without a forecast says so (a gap, never
/// zero or clear). Tapping an hour shows its exact values, the cloud layers,
/// humidity and visibility included. The strip takes the height of its text
/// and the columns widen with the text size, so nothing is clipped at 200 %
/// text (S1.10; UX-31, trap 17).
class _HourStrip extends StatefulWidget {
  const _HourStrip({required this.summary, required this.zoneId});

  final NightWeatherSummary summary;
  final String? zoneId;

  @override
  State<_HourStrip> createState() => _HourStripState();
}

class _HourStripState extends State<_HourStrip> {
  int? _selected;

  static List<(IconData, String)> _rows(DisplayUnits u) => [
    (Icons.cloud, 'cloud %'),
    (Icons.thermostat, 'temp. ${u.temperature.symbol}'),
    (Icons.opacity, 'dew pt. ${u.temperature.symbol}'),
    (Icons.air, 'wind/gust ${u.wind.symbol}'),
    (Icons.water_drop_outlined, 'precip. %'),
  ];

  @override
  void didUpdateWidget(_HourStrip old) {
    super.didUpdateWidget(old);
    if (old.summary != widget.summary) _selected = null;
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    final s = widget.summary;
    final slots = s.slots;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final selected = _selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label:
              'Hourly forecast for the dark span: ${s.totalHours} hours, cloud '
              '${WeatherText.range(s.cloudCover, '%')}, temperature '
              '${WeatherText.temperatureRange(s.temperature, unitsOf(context))}. Select an hour for '
              'its exact values.',
          child: SingleChildScrollView(
            key: const Key('weather.tableHours'),
            scrollDirection: Axis.horizontal,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 96 * scale,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('Hour', style: style),
                        for (final (icon, label) in _rows(
                          unitsOf(context),
                        )) ...[
                          // S9.6: room for the hour columns' cloud bar.
                          if (icon == Icons.cloud) SizedBox(height: _barHeight),
                          Row(
                            children: [
                              Icon(icon, size: 12),
                              const SizedBox(width: AppSpacing.xs),
                              Flexible(
                                child: Text(
                                  label,
                                  style: style,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  for (final (i, slot) in slots.indexed)
                    _HourColumn(
                      key: Key('weather.hour.$i'),
                      slot: slot,
                      zoneId: widget.zoneId,
                      style: style,
                      width: 64 * scale,
                      selected: i == selected,
                      onTap: () =>
                          setState(() => _selected = i == selected ? null : i),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (selected != null && selected < slots.length)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Semantics(
              liveRegion: true,
              child: Text(
                _HourColumn.exact(context, slots[selected], widget.zoneId),
                key: const Key('weather.tableHourDetail'),
                style: style,
              ),
            ),
          ),
      ],
    );
  }
}

/// The cloud bar's height (S9.6).
const double _barHeight = 20;

class _HourColumn extends StatelessWidget {
  const _HourColumn({
    super.key,
    required this.slot,
    required this.zoneId,
    required this.style,
    required this.width,
    required this.selected,
    required this.onTap,
  });

  final NightWeatherSlot slot;
  final String? zoneId;
  final TextStyle? style;
  final double width;
  final bool selected;
  final VoidCallback onTap;

  static String _v(double? x, {int digits = 0}) =>
      x == null ? '—' : x.toStringAsFixed(digits);

  /// Every value of [slot], in words with units (the selection's text).
  static String exact(
    BuildContext context,
    NightWeatherSlot slot,
    String? zoneId,
  ) {
    final time = NightTimeFormatter.clockTime(
      context,
      slot.timeUtc,
      zoneId: zoneId,
    );
    final h = slot.hour;
    if (h == null) return '$time: no forecast for this hour.';
    String v(double? x, String unit, {int digits = 0}) =>
        x == null ? 'no forecast' : '${x.toStringAsFixed(digits)} $unit';
    // F21: shown in the chosen units; the forecast stays in °C and km/h.
    final u = unitsOf(context);
    double? t(double? c) => c == null ? null : u.temperatureOf(c);
    double? w(double? kmh) => kmh == null ? null : u.windOf(kmh);
    final deg = u.temperature.symbol, speed = u.wind.symbol;
    final partial = slot.partial
        ? ' (${slot.precedingMinutes} min of that hour in the dark span)'
        : '';
    return [
      if (slot.instant) ...[
        '$time: cloud ${v(h.cloudCoverPct, '%')} (low '
            '${v(h.cloudCoverLowPct, '%')}, mid ${v(h.cloudCoverMidPct, '%')}, '
            'high ${v(h.cloudCoverHighPct, '%')})',
        'temperature ${v(t(h.temperatureC), deg, digits: 1)}, dew point '
            '${v(t(h.dewPointC), deg, digits: 1)}, humidity '
            '${v(h.relativeHumidityPct, '%')}',
        'wind ${v(w(h.windSpeedKmh), speed)}',
        'visibility ${v(h.visibilityM == null ? null : h.visibilityM! / 1000, 'km', digits: 1)}',
      ] else
        '$time: after the dark span ends',
      if (slot.preceding)
        'in the hour before: gusts up to ${v(w(h.windGustsKmh), speed)}, '
            'precipitation chance ${v(h.precipitationProbabilityPct, '%')}'
            '$partial',
    ].join('; ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final h = slot.hour;
    final star = slot.partial ? '*' : '';
    final time = Text(
      NightTimeFormatter.clockTime(context, slot.timeUtc, zoneId: zoneId),
      style: style?.copyWith(fontWeight: FontWeight.bold),
    );
    String instant(double? x, {int digits = 0}) =>
        slot.instant ? _v(x, digits: digits) : '';
    // F21: the chosen units; the forecast stays in °C and km/h.
    final u = unitsOf(context);
    double? t(double? c) => c == null ? null : u.temperatureOf(c);
    double? w(double? kmh) => kmh == null ? null : u.windOf(kmh);
    final cloud = slot.instant && h?.cloudCoverPct != null
        ? ', cloud ${QuantityText.percent(h!.cloudCoverPct!)}'
        : h == null
        ? ', no forecast'
        : '';
    return Semantics(
      button: true,
      selected: selected,
      // The InkWell's own semantics are excluded with its label, so the
      // tap is given here, or a double tap would do nothing.
      enabled: true,
      onTap: onTap,
      excludeSemantics: true,
      label:
          '${NightTimeFormatter.clockTime(context, slot.timeUtc, zoneId: zoneId)}'
          '$cloud${slot.dewRisk == true ? ', dew risk' : ''}. Shows its exact '
          'values',
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: width,
          decoration: selected
              ? BoxDecoration(
                  border: Border.all(color: theme.colorScheme.primary),
                )
              : null,
          child: h == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    time,
                    const SizedBox(height: _barHeight),
                    Text(
                      'no\nforecast',
                      textAlign: TextAlign.center,
                      style: style?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    time,
                    // S9.6 (08 §12): cloud cover as a bar under its number;
                    // the number is the text, so the bar is not read out.
                    _CloudBar(percent: slot.instant ? h.cloudCoverPct : null),
                    Text(instant(h.cloudCoverPct), style: style),
                    Text(instant(t(h.temperatureC)), style: style),
                    // S9.6: dew risk is marked by an icon too, never by
                    // colour alone (the shared rules).
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (slot.dewRisk == true)
                          Icon(
                            Icons.water_drop,
                            key: Key('weather.dewRisk.${slot.timeUtc.hour}'),
                            size: 12,
                            color:
                                theme
                                    .extension<HybridTokens>()
                                    ?.weatherCaution ??
                                AppPalette.of(context).caution,
                            semanticLabel: 'dew risk',
                          ),
                        Text(
                          instant(t(h.dewPointC)),
                          style: slot.dewRisk == true
                              ? style?.copyWith(
                                  color:
                                      theme
                                          .extension<HybridTokens>()
                                          ?.weatherCaution ??
                                      AppPalette.of(context).caution,
                                  fontWeight: FontWeight.bold,
                                )
                              : style,
                        ),
                      ],
                    ),
                    Text(
                      '${instant(w(h.windSpeedKmh))}/'
                      '${slot.preceding ? '${_v(w(h.windGustsKmh))}$star' : ''}',
                      style: style,
                    ),
                    Text(
                      slot.preceding
                          ? '${_v(h.precipitationProbabilityPct)}$star'
                          : '',
                      style: style,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// One hour's total cloud cover as a bar, 0–100 % of its box (S9.6); an
/// unknown value draws nothing, never an empty or a full bar.
class _CloudBar extends StatelessWidget {
  const _CloudBar({required this.percent});

  final double? percent;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final pct = percent;
    return ExcludeSemantics(
      child: SizedBox(
        height: _barHeight,
        width: 16,
        child: pct == null
            ? null
            : DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: p.chartGrid),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    key: const Key('weather.tableCloudBar'),
                    heightFactor: (pct / 100).clamp(0.0, 1.0),
                    widthFactor: 1,
                    child: ColoredBox(color: p.muted),
                  ),
                ),
              ),
      ),
    );
  }
}
