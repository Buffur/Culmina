import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../shared/section_card.dart';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_theme.dart';
import '../../core/theme/hybrid_tokens.dart';
import '../../core/units/display_units.dart';
import '../../core/utils/quantity_text.dart';
import '../../domain/models/night_weather_summary.dart';
import '../../domain/services/forecast_overview.dart';
import '../../domain/models/night_weather.dart';
import '../screens/settings/settings_screen.dart';
import '../shared/clear_outside_link.dart';
import '../shared/collapsible_section.dart';
import '../shared/display_units_of.dart';
import '../shared/hybrid_icon.dart';
import '../shared/night_text.dart';
import '../shared/night_time_formatter.dart';
import '../viewmodels/display_settings_viewmodel.dart';
import '../viewmodels/night_conditions_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/site_viewmodel.dart';
import 'weather_details_table.dart';

/// One weather variable as the Hybrid reference lists it
/// (weather-variants.js `metrics`): its label, icon, tone and how its
/// value is read from an hour; [extra] is the dashed second line.
class _Metric {
  const _Metric(
    this.label,
    this.icon,
    this.tone, {
    required this.read,
    this.extra,
    this.extraLabel,
    this.percent = false,
    this.preceding = false,
    this.wind = false,
    this.temperature = false,
  });

  final String label;
  final HybridIconData icon;
  final _Tone tone;
  final double? Function(NightWeatherSlot s) read;
  final double? Function(NightWeatherSlot s)? extra;
  final String? extraLabel;
  final bool percent;
  final bool preceding;
  final bool wind;
  final bool temperature;
}

enum _Tone { temperature, moisture, cloud, wind }

final _metrics = <_Metric>[
  _Metric(
    'Temperature',
    HybridIcons.thermometer,
    _Tone.temperature,
    read: (s) => s.hour?.temperatureC,
    extra: (s) => s.hour?.dewPointC,
    extraLabel: 'Dew point',
    temperature: true,
  ),
  _Metric(
    'Relative humidity',
    HybridIcons.droplets,
    _Tone.moisture,
    read: (s) => s.hour?.relativeHumidityPct,
    percent: true,
  ),
  _Metric(
    'Cloud cover',
    HybridIcons.lucideCloud,
    _Tone.cloud,
    read: (s) => s.hour?.cloudCoverPct,
    percent: true,
  ),
  _Metric(
    'Wind / gusts',
    HybridIcons.wind,
    _Tone.wind,
    read: (s) => s.hour?.windSpeedKmh,
    extra: (s) => s.hour?.windGustsKmh,
    extraLabel: 'Gusts',
    wind: true,
  ),
  _Metric(
    'Precipitation probability',
    HybridIcons.cloudRain,
    _Tone.moisture,
    read: (s) => s.hour?.precipitationProbabilityPct,
    percent: true,
    preceding: true,
  ),
];

/// The Weather tab (conditions.js `weatherBody`, weather-variants.js;
/// HT-W01–W04): the night's answer over its dark span, how far to trust
/// it, the dark-time statistics as A · Compact rows or B · Hourly charts
/// (the Settings → Appearance choice; the same data either way), an hour
/// to inspect, the seeing limitation, the forecast details and the coming
/// nights. Nothing here writes the plan; a gap stays unknown, never 0.
class HybridWeatherView extends StatefulWidget {
  const HybridWeatherView({super.key});

  @override
  State<HybridWeatherView> createState() => _HybridWeatherViewState();
}

class _HybridWeatherViewState extends State<HybridWeatherView> {
  int _hour = 0;
  Object? _selectionContext;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<NightConditionsViewModel>();
    final site = context.watch<SiteViewModel>();
    final view =
        context.watch<DisplaySettingsViewModel?>()?.weatherView ??
        WeatherView.rows;
    final units = unitsOf(context);
    final p = AppPalette.of(context);
    final hybrid =
        Theme.of(context).extension<HybridTokens>() ?? HybridTokens.light;
    final state = c.nightWeather;
    final s = c.nightWeatherSummary;
    final zoneId = site.displayZoneId;
    final night = c.sessionNight;
    String at(DateTime utc) => NightTimeFormatter.instant(
      context,
      utc,
      windowStartUtc: night?.startUtc ?? utc,
      zoneId: zoneId,
    );
    final quiet = AppTextTheme.of(context)
        .resolve(AppTextTheme.of(context).caption, AppTextGeometry.explanatory)
        .copyWith(color: p.textSecondary);
    final status = AppTextTheme.of(context)
        .resolve(AppTextTheme.of(context).body, AppTextGeometry.standard)
        .copyWith(fontWeight: FontWeight.w600, color: p.textPrimary);
    final noDark = s?.span == NightWeatherSpan.noDark;
    final available = state is NightWeatherAvailable ? state : null;
    final unavailable = state is NightWeatherUnavailable;
    final cloudKnown = s == null ? 0 : s.totalHours - s.cloudGapHours;
    final headline = switch (state) {
      NightWeatherIdle() || NightWeatherLoading() => 'Loading the forecast',
      NightWeatherOutOfRange() => 'No forecast yet',
      NightWeatherUnavailable() => 'Forecast unavailable',
      NightWeatherAvailable() =>
        s == null || noDark
            ? 'No dark hours to summarize'
            : s.cloudCover == null
            ? 'Cloud cover unknown'
            : 'Cloud cover ${QuantityText.percentRange(s.cloudCover!.min, s.cloudCover!.max)}'
                  '${cloudKnown < s.totalHours ? ' in known dark hours' : ''}',
    };
    final slots = [
      for (final slot in s?.slots ?? const <NightWeatherSlot>[])
        if (slot.instant || slot.preceding) slot,
    ];
    final selectionContext = (site.latitude, site.longitude, night?.startUtc);
    final selectionActive = _selectionContext == selectionContext;
    final index = slots.isEmpty || !selectionActive
        ? 0
        : _hour.clamp(0, slots.length - 1);
    void selectHour(int value) => setState(() {
      _hour = value;
      _selectionContext = selectionContext;
    });
    void resetSelection() => setState(() {
      _hour = 0;
      _selectionContext = null;
    });

    final cloudSamples = [
      for (final slot in s?.slots ?? const <NightWeatherSlot>[])
        if (slot.instant && slot.hour?.cloudCoverPct != null) slot,
    ];
    NightWeatherSlot? lowest, highest;
    for (final slot in cloudSamples) {
      if (lowest == null ||
          slot.hour!.cloudCoverPct! < lowest.hour!.cloudCoverPct!) {
        lowest = slot;
      }
      if (highest == null ||
          slot.hour!.cloudCoverPct! > highest.hour!.cloudCoverPct!) {
        highest = slot;
      }
    }
    Widget changeViewAction() => TextButton(
      key: const Key('weather.changeView'),
      onPressed: () => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: '/settings/appearance'),
          builder: (_) =>
              const SettingsScreen(section: SettingsSection.appearance),
        ),
      ),
      child: const Text('Change view in Appearance'),
    );
    final children = <Widget>[
      SectionCard(
        key: const Key('weather.summaryGroup'),
        children: [
          // The answer for the dark span (`.weather-answer`).
          Semantics(
            header: true,
            child: Text(
              headline,
              key: const Key('weather.facts'),
              style: AppTextTheme.of(context)
                  .resolve(
                    AppTextTheme.of(context).answerHeading,
                    AppTextGeometry.answer,
                  )
                  .copyWith(color: p.textPrimary),
            ),
          ),
          if (available != null &&
              !noDark &&
              available.age != WeatherAge.current)
            Text(
              '${available.age == WeatherAge.stale ? 'Stale' : 'Aging'} snapshot · '
              'forecast, not current conditions.',
              key: const Key('weather.freshnessNotice'),
              style: status.copyWith(color: hybrid.weatherNotice),
            ),
          if (s != null && !noDark) ...[
            const SizedBox(height: 8),
            Text(
              'Dark ${at(s.fromUtc)} → ${at(s.toUtc)} · '
              '${QuantityText.duration(s.toUtc.difference(s.fromUtc))}',
              key: const Key('weather.span'),
              style: AppTextTheme.of(context)
                  .resolve(
                    AppTextTheme.of(context).caption,
                    AppTextGeometry.compact,
                  )
                  .copyWith(
                    color: p.textSecondary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ] else if (s != null) ...[
            const SizedBox(height: 8),
            Text(
              WeatherText.span(
                s,
                context
                    .watch<SettingsViewModel>()
                    .planningPreferences
                    .darknessLimit
                    .degrees,
                at,
              ),
              key: const Key('weather.span'),
              style: AppTextTheme.of(context)
                  .resolve(
                    AppTextTheme.of(context).caption,
                    AppTextGeometry.compact,
                  )
                  .copyWith(color: p.textSecondary),
            ),
          ],
          if (s != null &&
              !noDark &&
              s.cloudCover != null &&
              cloudKnown < s.totalHours)
            Text(
              '$cloudKnown of ${s.totalHours} hourly cloud samples known · gaps '
              'stay unknown.',
              key: const Key('weather.headlineCoverage'),
              style: status,
            ),
          if (s != null &&
              !noDark &&
              lowest != null &&
              highest != null &&
              lowest.hour!.cloudCoverPct != highest.hour!.cloudCoverPct) ...[
            const SizedBox(height: 8),
            Text(
              'Lowest hourly cloud: ${at(lowest.timeUtc)} · ${QuantityText.percent(lowest.hour!.cloudCoverPct!)}',
              key: const Key('weather.trend'),
              style: AppTextTheme.of(context).body
                  .copyWith(color: p.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Highest hourly cloud: ${at(highest.timeUtc)} · ${QuantityText.percent(highest.hour!.cloudCoverPct!)}',
              key: const Key('weather.highestCloud'),
              style: AppTextTheme.of(context).body
                  .copyWith(color: p.textPrimary),
            ),
          ],
          // How far to trust it (`.weather-trust`).
          const SizedBox(height: 12),
          if (state is NightWeatherOutOfRange)
            Text(
              WeatherText.outOfRange,
              key: const Key('weather.outOfRange'),
              style: quiet,
            )
          else if (state case NightWeatherUnavailable(:final failure))
            Text(
              WeatherText.failure(failure),
              key: const Key('weather.unavailable'),
              style: status,
            )
          else if (state is NightWeatherLoading || state is NightWeatherIdle)
            const LinearProgressIndicator(key: Key('weather.loading')),
          if (s != null)
            if (WeatherText.coverageCount(s) case final count?)
              Text(
                count
                    .replaceFirst('Coverage:', 'Dark-time coverage:')
                    .replaceFirst(
                      ' hourly samples in dark time',
                      ' hourly samples',
                    ),
                key: const Key('weather.coverage'),
                style: quiet,
              ),
          if (available != null) ...[
            const SizedBox(height: 4),
            Text(
              'Updated ${NightTimeFormatter.previewInstant(context, available.snapshot.fetchedAtUtc, zoneId: zoneId)}'
              ' · ${QuantityText.duration(available.ageDuration)} old',
              key: const Key('weather.updated'),
              style: quiet,
            ),
            if (s != null && !noDark && !s.complete)
              Text(
                'Forecast gaps remain unknown.',
                key: const Key('weather.gaps'),
                style: status.copyWith(color: hybrid.weatherNotice),
              ),
            if (available.refreshFailed case final f?)
              Text(
                'Refresh failed · cached forecast. ${WeatherText.failure(f)}',
                key: const Key('weather.refreshFailed'),
                style: status.copyWith(color: hybrid.weatherNotice),
              ),
          ],
          if (!noDark && (unavailable || available != null)) ...[
            const SizedBox(height: 10),
            OutlinedButton(
              key: const Key('weather.refresh'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: c.refreshWeather,
              child: Text(unavailable ? 'Retry forecast' : 'Refresh forecast'),
            ),
          ],
        ],
      ),
      const SizedBox(height: 12),
      // The presentation, and where it is chosen.
      if (s != null && !noDark && s.coveredHours > 0) ...[
        SectionCard(
          key: const Key('weather.statisticsGroup'),
          children: [
            Semantics(
              header: true,
              child: Text(
                view == WeatherView.charts
                    ? 'Hourly forecast'
                    : 'Dark-time statistics',
                style: AppTextTheme.of(context).sectionHeading
                    .copyWith(color: p.textPrimary),
              ),
            ),
            if (view == WeatherView.rows) ...[
              Text('View: Compact rows', style: quiet),
              SizedBox(width: double.infinity, child: changeViewAction()),
            ],
            if (view == WeatherView.charts)
              _Charts(
                slots: slots,
                units: units,
                zoneId: zoneId,
                windowStartUtc: night?.startUtc,
                selected: index,
                onSelect: selectHour,
                selectionActive: selectionActive,
                onReset: resetSelection,
              )
            else
              _Rows(slots: slots, units: units),
            if (s.dewRiskHours > 0)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.notes),
                child: Text(
                  '${s.dewRiskHours} of ${s.dewKnownHours} samples have a dew '
                  'point within '
                  '${QuantityText.temperatureDifference(s.dewMarginC, units)} of '
                  'air. A caution, not a condensation forecast.',
                  key: const Key('weather.dew'),
                  style: _note(context).copyWith(color: hybrid.caution),
                ),
              ),
            const SizedBox(height: 10),
            Text(
              view == WeatherView.charts
                  ? '+1: next day. Readings are instantaneous except gusts and '
                        'precipitation probability: preceding hour, with ≥30 min in darkness.\n'
                        '${slots.where((slot) => slot.partial).map((slot) => 'At ${NightTimeFormatter.clockTime(context, slot.timeUtc, zoneId: zoneId)}*, that hour includes ${slot.precedingMinutes} min of darkness.').join('\n')}'
                        '\nBlank endpoints are excluded. Probability (%) is not rainfall amount.'
                  : _rangeQualification,
              key: const Key('weather.precipNote'),
              style: _note(context),
            ),
          ],
        ),
      ],
      SectionCard(
        key: const Key('weather.limitGroup'),
        children: [
          Semantics(
            header: true,
            child: Text(
              'Forecast limitations',
              style: AppTextTheme.of(context).screenTitle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No forecast of astronomical seeing or transparency.',
            key: const Key('weather.notSeeing'),
            style: quiet,
          ),
          TextButton(
            key: const Key('weather.clearOutside'),
            onPressed: () => launchUrl(
              ClearOutsideLink.at(site.latitude, site.longitude),
              mode: LaunchMode.externalApplication,
            ),
            child: const Text('Open Clear Outside'),
          ),
        ],
      ),
      if (available != null)
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: SectionCard(
            key: const Key('weather.detailsGroup'),
            children: [
              CollapsibleSection(
                key: const Key('weather.details'),
                sectionKey: 'conditions.weatherDetails',
                title: 'Forecast details',
                summary: 'All hourly values, cloud layers and source',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'No forecast of astronomical seeing or transparency.',
                      style: quiet,
                    ),
                    if (view == WeatherView.charts) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(_rangeQualification, style: quiet),
                    ],
                    const SizedBox(height: 8),
                    // Charts retain their original context-preserving Settings
                    // entry. Rows without statistics keep it here as well.
                    if (view == WeatherView.charts ||
                        noDark ||
                        s == null ||
                        s.coveredHours == 0)
                      changeViewAction(),
                    _Details(
                      state: available,
                      summary: s,
                      units: units,
                      zoneId: zoneId,
                      leadDays: switch (night?.eveningDate) {
                        final n? => ForecastOverview.daysBetween(
                          ForecastOverview.localDate(
                            available.snapshot.fetchedAtUtc,
                            site.timeContext,
                          ),
                          n,
                        ),
                        null => null,
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    ];
    return Column(
      key: const Key('weather.hybrid'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

const _rangeQualification =
    'Ranges use known dark-time samples. Temperature, humidity, '
    'cloud and wind are instantaneous.\n\nGusts and precipitation '
    'probability describe the preceding hour; * marks partial '
    'dark-time overlap. Probability is %, not rainfall amount.';

TextStyle _note(BuildContext context) =>
    AppTextTheme.of(context).caption
        .copyWith(color: AppPalette.of(context).textSecondary);

/// "19 Oct, 22:00 GMT+3", with " *" when only part of its preceding hour
/// is in the dark span.
String _instant(BuildContext context, NightWeatherSlot s, String? zoneId) =>
    '${NightTimeFormatter.previewInstant(context, s.timeUtc, zoneId: zoneId)}'
    '${s.partial ? ' *' : ''}';

/// Whether an hour's value for [m] counts (N6): instantaneous values at an
/// instant in the span, preceding-hour ones with ≥ 30 min of overlap.
bool _eligible(NightWeatherSlot s, {required bool preceding}) =>
    preceding ? s.preceding : s.instant;

/// The value in the user's unit (temperature and wind convert; % stays).
double _shown(_Metric m, double v, DisplayUnits u) => m.temperature
    ? u.temperatureOf(v)
    : m.wind
    ? u.windOf(v)
    : v;

String _unit(_Metric m, DisplayUnits u) => m.temperature
    ? u.temperature.symbol
    : m.wind
    ? u.wind.symbol
    : '%';

String _number(double v) =>
    QuantityText.number(double.parse(v.toStringAsFixed(1)));

String _withUnit(double v, String unit) =>
    unit == '%' ? QuantityText.percent(v) : '${_number(v)} $unit';

String _selectedValue(
  NightWeatherSlot slot,
  double? Function(NightWeatherSlot) read,
  bool preceding,
  _Metric metric,
  DisplayUnits units,
) {
  if (!_eligible(slot, preceding: preceding)) {
    return preceding ? 'Excluded (<30 min dark)' : 'Outside dark span';
  }
  final value = read(slot);
  return value == null
      ? 'Unknown'
      : _withUnit(_shown(metric, value, units), _unit(metric, units));
}

/// "5–6.2 °C", "19–42%", or "Unknown" (weather-variants.js `range`).
String _range(
  List<NightWeatherSlot> slots,
  double? Function(NightWeatherSlot) read,
  bool preceding,
  _Metric m,
  DisplayUnits u,
) {
  final values = [
    for (final s in slots)
      if (_eligible(s, preceding: preceding))
        if (read(s) case final v?) _shown(m, v, u),
  ];
  if (values.isEmpty) return 'Unknown';
  final lo = values.reduce(math.min), hi = values.reduce(math.max);
  final unit = _unit(m, u);
  if (unit == '%') return QuantityText.percentRange(lo, hi);
  final text = _number(lo) == _number(hi)
      ? _number(lo)
      : '${_number(lo)}–${_number(hi)}';
  return '$text $unit';
}

/// "7/7 known" (weather-variants.js `coverage`).
String _coverage(
  List<NightWeatherSlot> slots,
  double? Function(NightWeatherSlot) read,
  bool preceding,
) {
  final eligible = slots.where((s) => _eligible(s, preceding: preceding));
  final known = eligible.where((s) => read(s) != null).length;
  return '$known/${eligible.length} known';
}

String _coverageLine(List<NightWeatherSlot> slots, _Metric m) =>
    '${_coverage(slots, m.read, m.preceding)}'
    '${m.extra == null ? '' : ' · ${m.extraLabel!.toLowerCase()} ${_coverage(slots, m.extra!, m.wind)}'}'
    '${m.preceding ? ' · preceding hour' : ''}'
    '${m.wind ? ' · gusts: preceding hour' : ''}';

Color _toneColor(BuildContext context, _Tone tone) =>
    (Theme.of(context).extension<HybridTokens>() ?? HybridTokens.light).accent;

/// A · Compact rows (`.wx-overview`): each variable's range over the known
/// dark-time samples and how many are known.
class _Rows extends StatelessWidget {
  const _Rows({required this.slots, required this.units});
  final List<NightWeatherSlot> slots;
  final DisplayUnits units;

  String? get commonCoverage {
    final counts = [
      for (final metric in _metrics) ...[
        _coverage(slots, metric.read, metric.preceding),
        if (metric.extra case final extra?)
          _coverage(slots, extra, metric.wind),
      ],
    ];
    // All seven series must have the same known/eligible pair. Row presence
    // and dew-risk coverage do not establish dew-point/gust completeness.
    return counts.isNotEmpty &&
            counts.toSet().length == 1 &&
            !counts.first.startsWith('0/')
        ? counts.first
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final text = AppTextTheme.of(context);
    final common = commonCoverage;
    return Padding(
      key: const Key('weather.rows'),
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (common != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                'All metrics: $common samples',
                key: const Key('weather.commonCoverage'),
                style: text.caption.copyWith(color: palette.textSecondary),
              ),
            ),
          for (final (index, metric) in _metrics.indexed)
            DecoratedBox(
              decoration: BoxDecoration(
                border: index == 0
                    ? null
                    : Border(top: BorderSide(color: palette.border)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.rowY),
                child: _WeatherMetricRow(
                  metric: metric,
                  slots: slots,
                  units: units,
                  showCoverage: common == null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Native adapter for canonical metric row 134:39784: a primary value and
/// separate paired-series/meaning caption, with complete unequal coverage.
class _WeatherMetricRow extends StatelessWidget {
  const _WeatherMetricRow({
    required this.metric,
    required this.slots,
    required this.units,
    required this.showCoverage,
  });
  final _Metric metric;
  final List<NightWeatherSlot> slots;
  final DisplayUnits units;
  final bool showCoverage;

  @override
  Widget build(BuildContext context) {
    final text = AppTextTheme.of(context);
    final palette = AppPalette.of(context);
    final label = switch (metric.label) {
      'Relative humidity' => 'Humidity',
      'Wind / gusts' => 'Wind',
      'Precipitation probability' => 'Precipitation',
      final label => label,
    };
    final secondary = metric.extra != null
        ? '${metric.extraLabel} ${_range(slots, metric.extra!, metric.wind, metric, units)}'
        : metric.label == 'Relative humidity'
        ? 'Relative humidity'
        : metric.preceding
        ? 'Probability · preceding hour'
        : null;
    final value = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _range(slots, metric.read, metric.preceding, metric, units),
          key: Key('weather.range.${metric.label}'),
          style: text.value.copyWith(
            color: palette.textPrimary,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (secondary != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            secondary,
            key: Key('weather.secondary.${metric.label}'),
            style: text.caption.copyWith(color: palette.textSecondary),
          ),
        ],
        if (showCoverage) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            _coverageLine(slots, metric),
            key: Key('weather.coverage.${metric.label}'),
            style: text.caption.copyWith(color: palette.textSecondary),
          ),
        ],
      ],
    );
    return Semantics(
      container: true,
      key: Key('weather.metric.${metric.label}'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final name = Text(
            label,
            style: text.body.copyWith(color: palette.textPrimary),
          );
          if (constraints.maxWidth < 270 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.5) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                name,
                const SizedBox(height: AppSpacing.xs),
                value,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: math.min(128, constraints.maxWidth * .42),
                child: name,
              ),
              Expanded(child: value),
            ],
          );
        },
      ),
    );
  }
}

/// B · Hourly charts (weather-variants.js `chartsView`): one hour axis to
/// select from, then a panel per variable on shared 48 px columns, each
/// with its own unit and scale; later panels repeat the hours.
const _plotAxisInset = 24.0;
const _plotEdgeInset = 14.0;
double _plotStep(double width, int count) => count < 2
    // With one timestamp there is no measured inter-tick spacing. Reserve
    // the leading half-domain for its complete preceding hour, ending at
    // the shared centered tick; do not shrink the bar to dark-overlap minutes.
    ? math.max(0.0, width - _plotAxisInset - 2 * _plotEdgeInset) / 2
    : math.max(0.0, width - _plotAxisInset - 2 * _plotEdgeInset) / (count - 1);
double _plotCenter(double width, int count, int index) => count < 2
    ? _plotAxisInset + math.max(0.0, width - _plotAxisInset) / 2
    : _plotAxisInset + _plotEdgeInset + index * _plotStep(width, count);
int _plotIndex(double x, double width, int count) => count < 2
    ? 0
    : ((x - _plotAxisInset - _plotEdgeInset) /
              math.max(1, _plotStep(width, count)))
          .round()
          .clamp(0, count - 1);

class _Charts extends StatefulWidget {
  const _Charts({
    required this.slots,
    required this.units,
    required this.zoneId,
    required this.windowStartUtc,
    required this.selected,
    required this.onSelect,
    required this.selectionActive,
    required this.onReset,
  });

  final List<NightWeatherSlot> slots;
  final DisplayUnits units;
  final String? zoneId;
  final DateTime? windowStartUtc;
  final int selected;
  final ValueChanged<int> onSelect;
  final bool selectionActive;
  final VoidCallback onReset;

  @override
  State<_Charts> createState() => _ChartsState();
}

class _ChartsState extends State<_Charts> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final p = AppPalette.of(context);
      final caption = AppTextTheme.of(context).caption
          .copyWith(color: p.textSecondary);
      final axisStyle = AppTextTheme.of(context).dense.copyWith(
        color: p.textSecondary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
      return Column(
        key: const Key('weather.charts'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          if (widget.selectionActive)
            Row(
              key: const Key('weather.selectionControls'),
              children: [
                IconButton(
                  key: const Key('weather.previousHour'),
                  tooltip: 'Previous forecast hour',
                  onPressed: widget.selected > 0
                      ? () => widget.onSelect(widget.selected - 1)
                      : null,
                  icon: const HybridIcon(HybridIcons.previous, size: 20),
                ),
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      _instant(
                        context,
                        widget.slots[widget.selected],
                        widget.zoneId,
                      ),
                      key: const Key('weather.selectedTime'),
                      style: caption.copyWith(color: p.textPrimary),
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('weather.nextHour'),
                  tooltip: 'Next forecast hour',
                  onPressed: widget.selected < widget.slots.length - 1
                      ? () => widget.onSelect(widget.selected + 1)
                      : null,
                  icon: const HybridIcon(HybridIcons.next, size: 20),
                ),
                TextButton(
                  key: const Key('weather.resetSelection'),
                  onPressed: widget.onReset,
                  child: const Text('Reset'),
                ),
              ],
            )
          else ...[
            Text(
              'Night overview · ${NightTimeFormatter.shortZone(widget.slots.first.timeUtc, zoneId: widget.zoneId)}',
              style: caption,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap a plot for any hour · axis labels every 2 h.',
              style: caption,
            ),
          ],
          for (final metric in _metrics)
            Semantics(
              key: Key('weather.chart.${metric.label}'),
              container: true,
              explicitChildNodes: true,
              slider: true,
              label: '${metric.label}, selected forecast hour',
              value: _instant(
                context,
                widget.slots[widget.selected],
                widget.zoneId,
              ),
              increasedValue: widget.selected < widget.slots.length - 1
                  ? _instant(
                      context,
                      widget.slots[widget.selected + 1],
                      widget.zoneId,
                    )
                  : null,
              decreasedValue: widget.selected > 0
                  ? _instant(
                      context,
                      widget.slots[widget.selected - 1],
                      widget.zoneId,
                    )
                  : null,
              onIncrease: widget.selected < widget.slots.length - 1
                  ? () => widget.onSelect(widget.selected + 1)
                  : null,
              onDecrease: widget.selected > 0
                  ? () => widget.onSelect(widget.selected - 1)
                  : null,
              child: GestureDetector(
                onTapDown: (details) => widget.onSelect(
                  _plotIndex(
                    details.localPosition.dx,
                    constraints.maxWidth,
                    widget.slots.length,
                  ),
                ),
                child: _Panel(
                  metric: metric,
                  slots: widget.slots,
                  units: widget.units,
                  width: constraints.maxWidth,
                  headerWidth: constraints.maxWidth,
                  scroll: _scroll,
                  selected: widget.selectionActive ? widget.selected : null,
                  hours: SizedBox(
                    height:
                        MediaQuery.textScalerOf(context)
                            .scale(axisStyle.fontSize ?? 12) *
                        (axisStyle.height ?? 1.4),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        for (final (index, slot) in widget.slots.indexed)
                          if (index.isEven || index == widget.slots.length - 1)
                            Positioned(
                              left: _plotCenter(
                                constraints.maxWidth,
                                widget.slots.length,
                                index,
                              ),
                              child: FractionalTranslation(
                                translation: const Offset(-.5, 0),
                                child: Text(
                                  '${NightTimeFormatter.clockTime(context, slot.timeUtc, zoneId: widget.zoneId).split(':').first}${slot.partial ? '*' : ''}',
                                  key: Key(
                                    'weather.axis.${metric.label}.${slot.timeUtc.millisecondsSinceEpoch}',
                                  ),
                                  style: axisStyle,
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

/// One chart panel (weather-variants.js `chart`).
class _Panel extends StatelessWidget {
  const _Panel({
    required this.metric,
    required this.slots,
    required this.units,
    required this.width,
    required this.headerWidth,
    required this.scroll,
    required this.hours,
    this.selected,
  });

  final _Metric metric;
  final List<NightWeatherSlot> slots;
  final DisplayUnits units;
  final double width;
  final double headerWidth;
  final ScrollController scroll;
  final Widget? hours;
  final int? selected;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final m = metric;
    final values = [
      for (final read in [m.read, ?m.extra])
        for (final s in slots)
          if (_eligible(s, preceding: read == m.extra ? m.wind : m.preceding))
            if (read(s) case final v?) _shown(m, v, units),
    ];
    final low = m.percent || m.wind
        ? 0
        : values.isEmpty
        ? 0
        : values.reduce(math.min).floor() - 1;
    final high = m.percent
        ? 100
        : values.isEmpty
        ? 1
        : math.max(
            low + 1,
            values.reduce(math.max).ceil() + (m.temperature ? 1 : 0),
          );
    final unit = _unit(m, units);
    final small = AppTextTheme.of(context).dense
        .copyWith(color: p.textSecondary);
    return Container(
      width: math.max(width, headerWidth),
      padding: const EdgeInsets.only(
        top: AppSpacing.md,
        bottom: AppSpacing.itemGap,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: scroll,
            builder: (context, child) => Transform.translate(
              offset: Offset(scroll.hasClients ? scroll.offset : 0, 0),
              child: child,
            ),
            child: SizedBox(
              key: Key('weather.chartHeader.${m.label}'),
              width: headerWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${m.label}, $unit',
                    style: AppTextTheme.of(context).nestedTitle
                        .copyWith(color: p.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selected == null
                        ? 'Dark time: ${_range(slots, m.read, m.preceding, m, units)}'
                        : _selectedValue(
                            slots[selected!],
                            m.read,
                            m.preceding,
                            m,
                            units,
                          ),
                    key: Key('weather.chartValue.${m.label}'),
                    style: AppTextTheme.of(context).value
                        .copyWith(color: p.textSecondary),
                  ),
                  if (m.extra case final extra?) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${m.extraLabel} ${selected == null ? _range(slots, extra, m.wind, m, units) : _selectedValue(slots[selected!], extra, m.wind, m, units)} · dashed',
                      style: small,
                    ),
                  ] else if (m == _metrics[2]) ...[
                    const SizedBox(height: 4),
                    Text('Instantaneous · 0% marked on baseline', style: small),
                  ] else if (m.preceding) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Preceding hour · bars end at each tick',
                      style: small,
                    ),
                  ],
                ],
              ),
            ),
          ),
          Semantics(
            label:
                '${m.label}; $low to $high $unit. '
                '${m.extra == null ? '' : '${m.wind ? 'Wind' : 'Temperature'} solid; ${m.extraLabel!.toLowerCase()} dashed. '}'
                'Question marks are missing values, disconnected from known '
                'samples.',
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(width, 100),
                  painter: _LinePainter(
                    gapStyle: AppTextTheme.of(context).caption,
                    axisStyle: AppTextTheme.of(context).dense.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    slots: slots,
                    metric: m,
                    units: units,
                    low: low.toDouble(),
                    high: high.toDouble(),
                    line: _toneColor(context, m.tone),
                    secondary: p.textSecondary,
                    surface: Theme.of(context).scaffoldBackgroundColor,
                    guide: p.border,
                    gap: p.textSecondary,
                  ),
                ),
                if (selected != null)
                  Positioned(
                    left: _plotCenter(width, slots.length, selected!),
                    top: 10,
                    width: 1,
                    height: 76,
                    child: CustomPaint(
                      key: Key('weather.cursor.${m.label}'),
                      painter: _SelectedHourCursor(
                        color: _toneColor(context, m.tone),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ?hours,
        ],
      ),
    );
  }
}

class _SelectedHourCursor extends CustomPainter {
  const _SelectedHourCursor({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var y = 0.0; y < size.height; y += 4) {
      canvas.drawLine(
        Offset(0, y),
        Offset(0, math.min(y + 2, size.height)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SelectedHourCursor oldDelegate) =>
      oldDelegate.color != color;
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.slots,
    required this.gapStyle,
    required this.axisStyle,
    required this.metric,
    required this.units,
    required this.low,
    required this.high,
    required this.line,
    required this.secondary,
    required this.surface,
    required this.guide,
    required this.gap,
  });

  final List<NightWeatherSlot> slots;
  final TextStyle gapStyle;
  final TextStyle axisStyle;
  final _Metric metric;
  final DisplayUnits units;
  final double low;
  final double high;
  final Color line;

  /// The dashed second line (dew point, gusts) and its hollow dots
  /// (notion-hybrid.css `.wx-secondary-line`).
  final Color secondary;
  final Color surface;
  final Color guide;
  final Color gap;

  @override
  void paint(Canvas canvas, Size size) {
    const axisInset = _plotAxisInset;
    double x(int i) => _plotCenter(size.width, slots.length, i);
    double y(double v) =>
        80 - (v - low) / ((high - low) == 0 ? 1 : high - low) * 64;
    final grid = Paint()
      ..color = guide
      ..strokeWidth = 1;
    for (final value in [low, (low + high) / 2, high]) {
      final at = y(value);
      canvas.drawLine(Offset(axisInset, at), Offset(size.width, at), grid);
      final label = TextPainter(
        text: TextSpan(
          text: value == value.roundToDouble()
              ? value.toInt().toString()
              : value.toStringAsFixed(1),
          style: axisStyle.copyWith(color: secondary),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(0, at - label.height / 2));
      label.dispose();
    }
    for (var index = 0; index < slots.length; index++) {
      canvas.drawLine(Offset(x(index), 16), Offset(x(index), 80), grid);
    }
    void series(
      double? Function(NightWeatherSlot) read,
      bool preceding, {
      required bool dashed,
    }) {
      final color = dashed ? secondary : line;
      final stroke = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      final dot = Paint()..color = dashed ? surface : color;
      final ring = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = dashed ? 1.6 : 1;
      Offset? previous;
      for (final (i, s) in slots.indexed) {
        final v = _eligible(s, preceding: preceding) ? read(s) : null;
        if (v == null) {
          previous = null;
          if (_eligible(s, preceding: preceding)) {
            final tp = TextPainter(
              text: TextSpan(
                text: '?',
                style: gapStyle.copyWith(color: gap),
              ),
              textDirection: TextDirection.ltr,
            )..layout();
            tp.paint(canvas, Offset(x(i) - tp.width / 2, 51 - tp.height + 4));
            tp.dispose();
          }
          continue;
        }
        final point = Offset(x(i), y(_shown(metric, v, units)));
        if (!dashed && (metric == _metrics[2] || metric.preceding)) {
          final intervalWidth = _plotStep(size.width, slots.length);
          final barWidth = math.min(12.0, intervalWidth * .5);
          // Cloud is an instantaneous sample centered on its tick. A
          // probability covers the complete preceding hour and ends at its
          // tick, even when only part of that hour qualifies for dark time.
          final left = metric.preceding
              ? math.max(axisInset, point.dx - intervalWidth + 1)
              : point.dx - barWidth / 2;
          final right = metric.preceding ? point.dx : point.dx + barWidth / 2;
          canvas.drawRect(
            Rect.fromLTRB(left, math.min(point.dy, 79), right, 80),
            Paint()..color = color,
          );
          continue;
        }
        if (previous != null) {
          if (dashed) {
            final d = point - previous;
            final length = d.distance;
            for (var t = 0.0; t < length; t += 9) {
              final a = previous + d * (t / length);
              final b = previous + d * (math.min(t + 5, length) / length);
              canvas.drawLine(a, b, stroke);
            }
          } else {
            canvas.drawLine(previous, point, stroke);
          }
        }
        canvas.drawCircle(point, 2.2, dot);
        canvas.drawCircle(point, 2.2, ring);
        previous = point;
      }
    }

    series(metric.read, metric.preceding, dashed: false);
    if (metric.extra case final e?) series(e, metric.wind, dashed: true);
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.gapStyle != gapStyle ||
      old.axisStyle != axisStyle ||
      old.slots != slots ||
      old.units != units ||
      old.line != line ||
      old.secondary != secondary ||
      old.low != low ||
      old.high != high;
}

class _Details extends StatelessWidget {
  const _Details({
    required this.state,
    required this.summary,
    required this.units,
    required this.zoneId,
    required this.leadDays,
  });

  final NightWeatherAvailable state;
  final NightWeatherSummary? summary;
  final DisplayUnits units;
  final String? zoneId;
  final int? leadDays;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final s = summary;
    final text = AppTextTheme.of(context)
        .resolve(
          AppTextTheme.of(context).caption,
          AppTextGeometry.weatherDescription,
        )
        .copyWith(color: p.textSecondary);
    final snapshot = state.snapshot;
    final dense = AppTextTheme.of(context).dense.copyWith(
      color: p.textPrimary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final head = AppTextTheme.of(context).dense
        .copyWith(fontWeight: FontWeight.w600, color: p.textSecondary);
    String v(double? x) => x == null ? 'Unknown' : _number(x);
    String temperature(double? x) =>
        x == null ? 'Unknown' : _number(units.temperatureOf(x));
    String wind(double? x) => x == null ? 'Unknown' : _number(units.windOf(x));
    Widget cell(String value, TextStyle style) => TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 32,
            minWidth: 96,
            maxWidth: 96,
          ),
          child: Align(
            alignment: Alignment.center,
            heightFactor: 1,
            child: Text(value, style: style, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
    final columns = [
      'Local time',
      'Cloud %',
      'Low / mid / high %',
      'Temp ${units.temperature.symbol}',
      'Dew ${units.temperature.symbol}',
      'Wind / gust ${units.wind.symbol}',
      'Precip %',
      'RH %',
      'Visibility km',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        const SizedBox(height: 4),
        if (s != null && s.span != NightWeatherSpan.noDark) ...[
          Text(
            '${s.coveredHours} of ${s.totalHours} hourly forecast rows in dark '
            'time have data; missing rows stay unknown. Cloud values: '
            '${s.totalHours - s.cloudGapHours} known.',
            key: const Key('weather.partial'),
            style: text,
          ),
          Text(WeatherText.dew(s, units), style: text),
        ],
        if (s != null && s.slots.isNotEmpty) ...[
          Text(
            'Hourly values',
            key: const Key('weather.hourlyValuesHeading'),
            style: AppTextTheme.of(context).nestedTitle
                .copyWith(color: p.textPrimary),
          ),
          Text(
            '— = excluded by the dark-time rule; Unknown = missing data',
            key: const Key('weather.tableKey'),
            style: text,
          ),
          WeatherDetailsTable(
            background:
                Theme.of(context).extension<HybridTokens>()?.surfaceSubtle ??
                Theme.of(context).cardColor,
            rows: [
              TableRow(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: p.border)),
                ),
                children: [for (final column in columns) cell(column, head)],
              ),
              for (final slot in s.slots)
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: p.border)),
                  ),
                  children: [
                    for (final value in [
                      _instant(context, slot, zoneId),
                      slot.instant ? v(slot.hour?.cloudCoverPct) : '—',
                      slot.instant
                          ? '${v(slot.hour?.cloudCoverLowPct)} / ${v(slot.hour?.cloudCoverMidPct)} / ${v(slot.hour?.cloudCoverHighPct)}'
                          : '—',
                      slot.instant ? temperature(slot.hour?.temperatureC) : '—',
                      slot.instant ? temperature(slot.hour?.dewPointC) : '—',
                      '${slot.instant ? wind(slot.hour?.windSpeedKmh) : '—'} / '
                          '${slot.preceding ? wind(slot.hour?.windGustsKmh) : '—'}',
                      slot.preceding
                          ? v(slot.hour?.precipitationProbabilityPct)
                          : '—',
                      slot.instant ? v(slot.hour?.relativeHumidityPct) : '—',
                      slot.instant
                          ? v(
                              slot.hour?.visibilityM == null
                                  ? null
                                  : slot.hour!.visibilityM! / 1000,
                            )
                          : '—',
                    ])
                      cell(value, dense),
                  ],
                ),
            ],
          ),
        ],
        Text(
          'Data source',
          key: const Key('weather.dataSourceHeading'),
          style: AppTextTheme.of(context).nestedTitle
              .copyWith(color: p.textPrimary),
        ),
        if (s != null && s.span != NightWeatherSpan.noDark)
          Text(
            'Snapshot age ${QuantityText.duration(state.ageDuration)}.'
            '${leadDays == null ? '' : ' ${WeatherText.lead(leadDays!)}; retrieval age and lead time are separate.'}',
            key: const Key('weather.lead'),
            style: text,
          ),
        Text(
          'Model: ${snapshot.provider} / ${snapshot.model}. Retrieved '
          '${NightTimeFormatter.previewInstant(context, snapshot.fetchedAtUtc, zoneId: zoneId)}. '
          'Temperature in ${units.temperature.symbol}, wind and gusts in '
          '${units.wind.symbol}, probabilities in %, visibility in km.',
          key: const Key('weather.model'),
          style: text,
        ),
        InkWell(
          onTap: () => launchUrl(
            Uri.parse('https://open-meteo.com/'),
            mode: LaunchMode.externalApplication,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Weather data by Open-Meteo.com (CC BY 4.0)',
                key: const Key('weather.attribution'),
                style: text.copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: p.textSecondary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
