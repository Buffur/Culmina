import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../shared/document_section.dart';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
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
import '../viewmodels/night_browser_viewmodel.dart';
import '../viewmodels/night_conditions_viewmodel.dart';
import '../viewmodels/session_plan_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/site_viewmodel.dart';

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
  bool _hourOpen = false;

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
    final quiet = AppTypography.caption.copyWith(
      height: 1.65,
      color: p.textSecondary,
    );
    final status = AppTypography.body.copyWith(
      height: 1.5,
      fontWeight: FontWeight.w600,
      color: p.textPrimary,
    );
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
            : 'Cloud ${QuantityText.percentRange(s.cloudCover!.min, s.cloudCover!.max)}'
                  '${cloudKnown < s.totalHours ? ' in known dark hours' : ' in the dark'}',
    };
    final slots = [
      for (final slot in s?.slots ?? const <NightWeatherSlot>[])
        if (slot.instant || slot.preceding) slot,
    ];
    final index = slots.isEmpty ? 0 : _hour.clamp(0, slots.length - 1);
    final children = <Widget>[
      DocumentSection(
        key: const Key('weather.summaryGroup'),
        children: [
          // The answer for the dark span (`.weather-answer`).
          Semantics(
            header: true,
            child: Text(
              headline,
              key: const Key('weather.facts'),
              style: AppTypography.answerHeading.copyWith(
                height: 1.3,
                color: p.textPrimary,
              ),
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
              style: AppTypography.body.copyWith(
                height: 1.55,
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
              style: AppTypography.body.copyWith(
                height: 1.55,
                color: p.textSecondary,
              ),
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
          if (s != null && !noDark)
            if (WeatherText.trend(s, at) case final trend?) ...[
              const SizedBox(height: 12),
              Text(
                trend,
                key: const Key('weather.trend'),
                style: AppTypography.value.copyWith(
                  height: 1.55,
                  color: p.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          // How far to trust it (`.weather-trust`).
          const SizedBox(height: 16),
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
              Text(count, key: const Key('weather.coverage'), style: status),
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
                'Offline · cached forecast. ${WeatherText.failure(f)}',
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
      const SizedBox(height: 16),
      // The presentation, and where it is chosen.
      if (s != null && !noDark && s.coveredHours > 0) ...[
        DocumentSection(
          key: const Key('weather.statisticsGroup'),
          joinNext: true,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('${view.letter} · ${view.label} · ', style: quiet),
                InkWell(
                  key: const Key('weather.changeView'),
                  // Settings → Appearance, above the tabs as Settings opens it.
                  onTap: () => Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute<void>(
                      settings: const RouteSettings(
                        name: '/settings/appearance',
                      ),
                      builder: (_) => const SettingsScreen(
                        section: SettingsSection.appearance,
                      ),
                    ),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Center(
                      widthFactor: 1,
                      child: Text(
                        'Change in Settings → Appearance',
                        style: quiet.copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: p.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Semantics(
              header: true,
              child: Text(
                'Dark-time statistics',
                style: AppTypography.sectionHeading.copyWith(
                  color: p.textPrimary,
                ),
              ),
            ),
            if (view == WeatherView.charts)
              _Charts(
                slots: slots,
                units: units,
                zoneId: zoneId,
                windowStartUtc: night?.startUtc,
                selected: index,
                onSelect: (i) => setState(() => _hour = i),
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
              'Ranges summarize known dark-time samples. Temperature, humidity, '
              'cloud and wind are instantaneous. Gusts and precipitation '
              'probability describe the preceding hour; * marks partial '
              'dark-time overlap. Probability is %, not rainfall amount.',
              key: const Key('weather.precipNote'),
              style: _note(context),
            ),
            // `.wx-hour-slider`: an hour to inspect, then its values.
            const SizedBox(height: 16),
            Text(
              'Inspect an hour',
              style: AppTypography.caption.copyWith(
                height: 1.5,
                color: p.textSecondary,
              ),
            ),
            if (slots.length > 1)
              SliderTheme(
                // notion-hybrid.css `.wx-hour-slider input`: the browser range
                // in the accent, a small thumb, no tick marks.
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  activeTrackColor: hybrid.accent,
                  thumbColor: hybrid.accent,
                  inactiveTrackColor: p.border,
                  overlayColor: hybrid.accent.withValues(alpha: 0.12),
                  tickMarkShape: SliderTickMarkShape.noTickMark,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                    elevation: 0,
                    pressedElevation: 0,
                  ),
                  showValueIndicator: ShowValueIndicator.never,
                ),
                child: Slider(
                  key: const Key('weather.hourSlider'),
                  value: index.toDouble(),
                  min: 0,
                  max: (slots.length - 1).toDouble(),
                  divisions: slots.length - 1,
                  semanticFormatterCallback: (v) =>
                      _instant(context, slots[v.round()], zoneId),
                  onChanged: (v) => setState(() => _hour = v.round()),
                ),
              ),
            _HourDetails(
              slot: slots[index],
              units: units,
              zoneId: zoneId,
              open: _hourOpen,
              onToggle: () => setState(() => _hourOpen = !_hourOpen),
              time: NightTimeFormatter.clockTime(
                context,
                slots[index].timeUtc,
                zoneId: zoneId,
              ),
            ),
          ],
        ),
      ],
      DocumentSection(
        key: const Key('weather.limitGroup'),
        joinPrevious: s != null && !noDark && s.coveredHours > 0,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          // Q3 (PD-18): the limitation, and a page the user opens.
          const SizedBox(height: 24),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text:
                      'This forecast does not predict astronomical seeing or '
                      'transparency. ',
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: InkWell(
                    key: const Key('weather.clearOutside'),
                    onTap: () => launchUrl(
                      ClearOutsideLink.at(site.latitude, site.longitude),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Center(
                        widthFactor: 1,
                        child: Text(
                          'Look at Clear Outside',
                          style: AppTypography.caption.copyWith(
                            height: 1.7,
                            color: p.textSecondary,
                            decoration: TextDecoration.underline,
                            decorationColor: p.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            key: const Key('weather.notSeeing'),
            style: AppTypography.caption.copyWith(
              height: 1.7,
              color: p.textSecondary,
            ),
          ),
        ],
      ),
      if (available != null)
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: DocumentSection(
            key: const Key('weather.detailsGroup'),
            children: [
              CollapsibleSection(
                key: const Key('weather.details'),
                sectionKey: 'conditions.weatherDetails',
                title: 'Forecast details',
                summary: 'Hourly values, layers and source',
                child: _Details(
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
              ),
            ],
          ),
        ),
      const _ComingNights(),
    ];
    return Column(
      key: const Key('weather.hybrid'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

TextStyle _note(BuildContext context) => AppTypography.dense.copyWith(
  height: 1.6,
  color: AppPalette.of(context).textSecondary,
);

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

String _overview(List<NightWeatherSlot> slots, _Metric m, DisplayUnits u) =>
    '${_range(slots, m.read, m.preceding, m, u)}'
    '${m.extra == null ? '' : ' · ${m.extraLabel!.toLowerCase()} ${_range(slots, m.extra!, m.wind, m, u)}'}';

String _coverageLine(List<NightWeatherSlot> slots, _Metric m) =>
    '${_coverage(slots, m.read, m.preceding)}'
    '${m.extra == null ? '' : ' · ${m.extraLabel!.toLowerCase()} ${_coverage(slots, m.extra!, m.wind)}'}'
    '${m.preceding ? ' · preceding hour' : ''}'
    '${m.wind ? ' · gusts: preceding hour' : ''}';

Color _toneColor(BuildContext context, _Tone t) {
  final h = Theme.of(context).extension<HybridTokens>() ?? HybridTokens.light;
  final p = AppPalette.of(context);
  return switch (t) {
    _Tone.cloud => p.textSecondary,
    _ => h.accent,
  };
}

/// The metric's name with its data icon (`.wx-metric-name`).
class _MetricName extends StatelessWidget {
  const _MetricName(this.m, {required this.style});

  final _Metric m;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      HybridIcon(
        m.icon,
        size: 20,
        strokeWidth: 1.7,
        color: _toneColor(context, m.tone),
      ),
      const SizedBox(width: 8),
      Flexible(child: Text(m.label, style: style)),
    ],
  );
}

/// A · Compact rows (`.wx-overview`): each variable's range over the known
/// dark-time samples and how many are known.
class _Rows extends StatelessWidget {
  const _Rows({required this.slots, required this.units});

  final List<NightWeatherSlot> slots;
  final DisplayUnits units;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Padding(
      key: const Key('weather.rows'),
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final m in _metrics)
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: p.border)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.rowY),
                child: MergeSemantics(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth - 14;
                      final stacked =
                          MediaQuery.textScalerOf(context).scale(1) >= 1.5;
                      final name = _MetricName(
                        m,
                        style: AppTypography.caption.copyWith(
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                          color: p.textPrimary,
                        ),
                      );
                      final value = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _overview(slots, m, units),
                            style: AppTypography.value.copyWith(
                              height: 1.5,
                              color: p.textPrimary,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _coverageLine(slots, m),
                            style: AppTypography.dense.copyWith(
                              color: p.textSecondary,
                            ),
                          ),
                        ],
                      );
                      if (stacked) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 10,
                          children: [name, value],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: w / 2.18, child: name),
                          const SizedBox(width: 14),
                          Expanded(child: value),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// B · Hourly charts (weather-variants.js `chartsView`): one hour axis to
/// select from, then a panel per variable on shared 48 px columns, each
/// with its own unit and scale; later panels repeat the hours.
class _Charts extends StatelessWidget {
  const _Charts({
    required this.slots,
    required this.units,
    required this.zoneId,
    required this.windowStartUtc,
    required this.selected,
    required this.onSelect,
  });

  final List<NightWeatherSlot> slots;
  final DisplayUnits units;
  final String? zoneId;
  final DateTime? windowStartUtc;
  final int selected;
  final ValueChanged<int> onSelect;

  static const cell = 48.0;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final hybrid =
        Theme.of(context).extension<HybridTokens>() ?? HybridTokens.light;
    final width = slots.length * cell;
    String time(NightWeatherSlot s) =>
        NightTimeFormatter.clockTime(context, s.timeUtc, zoneId: zoneId);
    Widget hours() => ExcludeSemantics(
      child: Row(
        children: [
          for (final (i, s) in slots.indexed)
            SizedBox(
              width: cell,
              child: Text(
                time(s),
                textAlign: TextAlign.center,
                style: AppTypography.dense.copyWith(
                  fontWeight: i == selected ? FontWeight.w600 : FontWeight.w400,
                  color: i == selected ? p.textPrimary : p.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
    return Column(
      key: const Key('weather.charts'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Text(
          'Shared hourly positions; each panel keeps its own physical unit '
          'and scale. Scroll sideways for later hours.',
          style: _note(context),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          key: const Key('weather.chartScroll'),
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: math.max(width, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // `.wx-time-axis`: the hours as buttons; the chosen one on
                // the hour wash.
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: p.border)),
                  ),
                  child: Row(
                    children: [
                      for (final (i, s) in slots.indexed)
                        Semantics(
                          button: true,
                          selected: i == selected,
                          label: 'Select ${_instant(context, s, zoneId)}',
                          excludeSemantics: true,
                          // H2: the labelled node carries the tap itself.
                          onTap: () => onSelect(i),
                          child: InkWell(
                            key: Key('weather.hour.$i'),
                            onTap: () => onSelect(i),
                            child: Container(
                              width: cell,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: i == selected
                                    ? hybrid.selectedHourFill
                                    : HybridTokens.transparent,
                                border: Border(
                                  bottom: BorderSide(
                                    width: 2,
                                    color: i == selected
                                        ? hybrid.selectedHourRule
                                        : HybridTokens.transparent,
                                  ),
                                ),
                              ),
                              child: Text(
                                time(s),
                                style: AppTypography.dense.copyWith(
                                  color: i == selected
                                      ? hybrid.selectedHourText
                                      : p.textSecondary,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                for (final (i, m) in _metrics.indexed)
                  _Panel(
                    metric: m,
                    slots: slots,
                    units: units,
                    width: width,
                    hours: i == 0 ? null : hours(),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Solid temperature / dashed dew point; solid wind / dashed gusts. '
          '? = unknown; gaps stay disconnected.',
          style: _note(context),
        ),
      ],
    );
  }
}

/// One chart panel (weather-variants.js `chart`).
class _Panel extends StatelessWidget {
  const _Panel({
    required this.metric,
    required this.slots,
    required this.units,
    required this.width,
    required this.hours,
  });

  final _Metric metric;
  final List<NightWeatherSlot> slots;
  final DisplayUnits units;
  final double width;
  final Widget? hours;

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
    final small = AppTypography.dense.copyWith(color: p.textSecondary);
    final axis = values.isEmpty
        ? 'No known values'
        : '$low–$high $unit'
              '${m.extra == null ? '' : ' · ${m.extraLabel!.toLowerCase()} dashed'}'
              '${m.preceding ? ' · preceding hour' : ''}'
              '${m.wind ? ' · gusts: preceding hour' : ''}';
    return Container(
      width: width,
      padding: const EdgeInsets.only(
        top: AppSpacing.md,
        bottom: AppSpacing.itemGap,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: math.min(width, 300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MetricName(
                  m,
                  style: AppTypography.itemTitle.copyWith(
                    height: 1.45,
                    color: p.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_overview(slots, m, units)} · ${_coverageLine(slots, m).replaceAll(' · preceding hour', '').replaceAll(' · gusts: preceding hour', '')}',
                  style: small,
                ),
                const SizedBox(height: 4),
                Text(axis, style: small),
              ],
            ),
          ),
          Semantics(
            label:
                '${m.label}; $low to $high $unit. '
                '${m.extra == null ? '' : '${m.wind ? 'Wind' : 'Temperature'} solid; ${m.extraLabel!.toLowerCase()} dashed. '}'
                'Question marks are missing values, disconnected from known '
                'samples.',
            child: CustomPaint(
              size: Size(width, 80),
              painter: _LinePainter(
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
          ),
          ?hours,
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.slots,
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
    double x(int i) => 24 + i * 48.0;
    double y(double v) =>
        64 - (v - low) / ((high - low) == 0 ? 1 : high - low) * 48;
    canvas.drawLine(
      const Offset(0, 64),
      Offset(size.width, 64),
      Paint()
        ..color = guide
        ..strokeWidth = 1,
    );
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
                style: AppTypography.caption.copyWith(color: gap),
              ),
              textDirection: TextDirection.ltr,
            )..layout();
            tp.paint(canvas, Offset(x(i) - tp.width / 2, 43 - tp.height + 4));
            tp.dispose();
          }
          continue;
        }
        final point = Offset(x(i), y(_shown(metric, v, units)));
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
      old.slots != slots ||
      old.units != units ||
      old.line != line ||
      old.secondary != secondary ||
      old.low != low ||
      old.high != high;
}

/// "Hourly values" (`.wx-hour-details`): the inspected hour's every
/// variable, unknown and out-of-span values said so.
class _HourDetails extends StatelessWidget {
  const _HourDetails({
    required this.slot,
    required this.units,
    required this.zoneId,
    required this.open,
    required this.onToggle,
    required this.time,
  });

  final NightWeatherSlot slot;
  final DisplayUnits units;
  final String? zoneId;
  final bool open;
  final VoidCallback onToggle;
  final String time;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    String sample(
      _Metric m,
      double? Function(NightWeatherSlot) read,
      bool preceding,
    ) {
      if (!_eligible(slot, preceding: preceding)) {
        return slot.hour == null ? 'Unknown' : 'Outside dark span';
      }
      final v = read(slot);
      return v == null
          ? 'Unknown'
          : _withUnit(_shown(m, v, units), _unit(m, units));
    }

    final cloud = _metrics[2];
    final rows = <(String, String)>[
      for (final m in _metrics)
        (
          m.label,
          '${sample(m, m.read, m.preceding)}'
              '${m.extra == null ? '' : '\n${m.extraLabel}: ${sample(m, m.extra!, m.wind)}'}',
        ),
      (
        'Low / middle / high cloud',
        [
          for (final read in <double? Function(NightWeatherSlot)>[
            (s) => s.hour?.cloudCoverLowPct,
            (s) => s.hour?.cloudCoverMidPct,
            (s) => s.hour?.cloudCoverHighPct,
          ])
            sample(cloud, read, false),
        ].join(' / '),
      ),
      (
        'Visibility',
        slot.instant && slot.hour?.visibilityM != null
            ? '${_number(slot.hour!.visibilityM! / 1000)} km'
            : 'Unknown',
      ),
    ];
    final style = AppTypography.caption.copyWith(height: 1.5);
    return DecoratedBox(
      key: const Key('weather.hourDetails'),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: open,
            child: InkWell(
              onTap: onToggle,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.itemGap,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        open ? Icons.arrow_drop_down : Icons.arrow_right,
                        size: 18,
                        color: p.textPrimary,
                      ),
                      // Wraps at large text rather than overflow.
                      Expanded(
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          children: [
                            Text(
                              'Hourly values',
                              style: AppTypography.body.copyWith(
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                                color: p.textPrimary,
                              ),
                            ),
                            Text(
                              time,
                              key: const Key('weather.hourLabel'),
                              style: AppTypography.body.copyWith(
                                height: 1.5,
                                color: p.textSecondary,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (open)
            Semantics(
              liveRegion: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.sm,
                      bottom: AppSpacing.notes,
                    ),
                    child: Text(
                      _instant(context, slot, zoneId),
                      style: AppTypography.body.copyWith(
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        color: p.textPrimary,
                      ),
                    ),
                  ),
                  for (final (label, value) in rows)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: p.border)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        child: MergeSemantics(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  label,
                                  style: style.copyWith(color: p.textSecondary),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  value,
                                  style: style.copyWith(
                                    color: p.textPrimary,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (slot.hour == null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.notes),
                      child: Text(
                        'No sample at this hour. Missing values are unknown.',
                        style: _note(context),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Forecast details (conditions.js): coverage and age, the dew heuristic,
/// the provider and model, the full hourly table, the attribution.
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
    final text = AppTypography.caption.copyWith(
      height: 1.7,
      color: p.textSecondary,
    );
    final snapshot = state.snapshot;
    final dense = AppTypography.dense.copyWith(
      color: p.textPrimary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final head = AppTypography.dense.copyWith(
      fontWeight: FontWeight.w600,
      color: p.textSecondary,
    );
    String v(double? x) => x == null ? '—' : _number(x);
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
          Text(
            'Snapshot age ${QuantityText.duration(state.ageDuration)}.'
            '${leadDays == null ? '' : ' ${WeatherText.lead(leadDays!)}; retrieval age and lead time are separate.'}',
            key: const Key('weather.lead'),
            style: text,
          ),
          Text(WeatherText.dew(s, units), style: text),
        ],
        Text(
          'Model: ${snapshot.provider} / ${snapshot.model}. Retrieved '
          '${NightTimeFormatter.previewInstant(context, snapshot.fetchedAtUtc, zoneId: zoneId)}. '
          'Temperature in ${units.temperature.symbol}, wind and gusts in '
          '${units.wind.symbol}, probabilities in %, visibility in km. No '
          'reliability score.',
          key: const Key('weather.model'),
          style: text,
        ),
        if (s != null && s.slots.isNotEmpty)
          SingleChildScrollView(
            key: const Key('weather.table'),
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: p.border)),
                  ),
                  children: [
                    for (final c in columns)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          0,
                          AppSpacing.cellY,
                          AppSpacing.itemGap,
                          AppSpacing.cellY,
                        ),
                        child: Text(c, style: head),
                      ),
                  ],
                ),
                for (final slot in s.slots)
                  TableRow(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: p.border)),
                    ),
                    children: [
                      for (final cell in [
                        _instant(context, slot, zoneId),
                        slot.instant ? v(slot.hour?.cloudCoverPct) : '—',
                        slot.instant
                            ? '${v(slot.hour?.cloudCoverLowPct)} / ${v(slot.hour?.cloudCoverMidPct)} / ${v(slot.hour?.cloudCoverHighPct)}'
                            : '—',
                        slot.instant && slot.hour?.temperatureC != null
                            ? _number(
                                units.temperatureOf(slot.hour!.temperatureC!),
                              )
                            : '—',
                        slot.instant && slot.hour?.dewPointC != null
                            ? _number(
                                units.temperatureOf(slot.hour!.dewPointC!),
                              )
                            : '—',
                        '${slot.instant && slot.hour?.windSpeedKmh != null ? _number(units.windOf(slot.hour!.windSpeedKmh!)) : '—'} / '
                            '${slot.preceding && slot.hour?.windGustsKmh != null ? _number(units.windOf(slot.hour!.windGustsKmh!)) : '—'}',
                        slot.preceding
                            ? v(slot.hour?.precipitationProbabilityPct)
                            : '—',
                        slot.instant ? v(slot.hour?.relativeHumidityPct) : '—',
                        slot.instant && slot.hour?.visibilityM != null
                            ? _number(slot.hour!.visibilityM! / 1000)
                            : '—',
                      ])
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            0,
                            AppSpacing.cellY,
                            AppSpacing.itemGap,
                            AppSpacing.cellY,
                          ),
                          child: Text(cell, style: dense),
                        ),
                    ],
                  ),
              ],
            ),
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

/// Coming nights (conditions.js `comingNights`): the nights the one
/// forecast covers, each with its coverage and cloud, and View this night
/// (browsing only; Plan this night is the bar's action).
class _ComingNights extends StatelessWidget {
  const _ComingNights();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<NightConditionsViewModel>();
    final plan = context.watch<SessionPlanViewModel>();
    final overview = c.forecastNights;
    if (overview == null || overview.nights.isEmpty) {
      return const SizedBox.shrink();
    }
    final p = AppPalette.of(context);
    final small = AppTypography.caption.copyWith(color: p.textSecondary);
    final beyond = overview.firstBeyond;
    final browser = context.read<NightBrowserViewModel?>();
    return Padding(
      key: const Key('weather.nights'),
      padding: const EdgeInsets.only(top: AppSpacing.section),
      child: DocumentSection(
        key: const Key('weather.comingGroup'),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Coming nights',
                  style: AppTypography.sectionHeading.copyWith(
                    color: p.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The forecast covers some or all of these nights. Later dates '
                'have no forecast.',
                style: AppTypography.caption.copyWith(
                  height: 1.65,
                  color: p.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final (i, n) in overview.nights.indexed)
                DecoratedBox(
                  key: Key('weather.night.${n.eveningDate.toIso8601String()}'),
                  decoration: BoxDecoration(
                    border: i == 0
                        ? null
                        : Border(top: BorderSide(color: p.border)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Night of ${NightTimeFormatter.eveningDate(n.eveningDate)}'
                          '${n.eveningDate == plan.eveningDate ? ' · your plan' : ''}',
                          style: AppTypography.value.copyWith(
                            fontWeight: FontWeight.w500,
                            color: p.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _coverageWords(n),
                          key: Key(
                            'weather.night.${n.eveningDate.toIso8601String()}.coverage',
                          ),
                          style: small,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          n.summary.span == NightWeatherSpan.noDark
                              ? 'No dark hours to summarize'
                              : n.summary.cloudCover == null
                              ? 'Cloud unknown'
                              : 'Cloud ${QuantityText.percentRange(n.summary.cloudCover!.min, n.summary.cloudCover!.max)} '
                                    'in covered dark hours',
                          style: small,
                        ),
                        if (browser != null) ...[
                          const SizedBox(height: 8),
                          OutlinedButton(
                            key: Key(
                              'weather.night.${n.eveningDate.toIso8601String()}.view',
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            onPressed: () => browser.viewNight(n.eveningDate),
                            child: const Text('View this night'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              if (beyond != null)
                Text(
                  'No forecast from ${NightTimeFormatter.eveningDate(beyond)}: '
                  'beyond the 16-day forecast. Night and Moon browsing remain '
                  'available.',
                  key: const Key('weather.nights.beyond'),
                  style: AppTypography.caption.copyWith(
                    height: 1.65,
                    color: p.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The night's coverage in the reference's words (conditions.js `status`);
/// a partial night keeps its counts and why (F14 A1: never a bare label).
String _coverageWords(ForecastNight n) => switch (n.coverage) {
  ForecastCoverage.complete => 'Full dark-time coverage',
  ForecastCoverage.partial =>
    'Partial dark-time coverage · ${n.summary.coveredHours} of '
        '${n.summary.totalHours} dark hours (${[if (n.missingBefore > 0) 'the forecast starts later', if (n.missingAfter > 0) 'the forecast ends before dawn', if (n.gaps > 0) '${n.gaps} h missing'].join(', ')})',
  ForecastCoverage.none => 'No forecast for the dark hours',
  ForecastCoverage.noDark => 'No dark time this night',
};
