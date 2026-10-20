import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/hybrid_tokens.dart';
import '../../core/units/display_units.dart';
import '../../core/utils/quantity_text.dart';
import '../../domain/models/night_weather_summary.dart';
import '../shared/display_units_of.dart';
import '../shared/night_time_formatter.dart';

/// The approved Hybrid hourly plots, fed only by the native selected-night
/// slots. Missing values break a curve; the preceding-hour edge is never
/// presented as an instantaneous temperature, cloud or humidity observation.
class WeatherHourlyCharts extends StatefulWidget {
  const WeatherHourlyCharts({
    super.key,
    required this.slots,
    required this.zoneId,
    required this.exactDescription,
  });

  final List<NightWeatherSlot> slots;
  final String? zoneId;
  final String Function(BuildContext, NightWeatherSlot, String?)
  exactDescription;

  @override
  State<WeatherHourlyCharts> createState() => _WeatherHourlyChartsState();
}

class _WeatherHourlyChartsState extends State<WeatherHourlyCharts> {
  int? _selected;

  @override
  void didUpdateWidget(WeatherHourlyCharts oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slots != widget.slots) _selected = null;
  }

  @override
  Widget build(BuildContext context) {
    final slots = widget.slots;
    if (slots.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    final tokens = theme.extension<HybridTokens>();
    final units = unitsOf(context);
    final text = theme.textTheme.bodySmall;
    final cell = 56.0 * MediaQuery.textScalerOf(context).scale(1);
    final data = WeatherPlotData.fromSlots(slots, units);
    final temperatureRange = data.temperatureRange;
    String time(NightWeatherSlot slot) => NightTimeFormatter.clockTime(
      context,
      slot.timeUtc,
      zoneId: widget.zoneId,
    );
    Widget caption(String value) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(value, style: text?.copyWith(fontWeight: FontWeight.w500)),
    );
    Widget plot(
      List<WeatherPlotSeries> series,
      double low,
      double high,
      String label,
      Key key, {
      bool guides = false,
    }) => Semantics(
      label: label,
      child: CustomPaint(
        key: key,
        size: Size(cell * slots.length, 80),
        painter: WeatherLinesPainter(
          series: series,
          minimum: low,
          maximum: high,
          grid: guides ? palette.border : HybridTokens.transparent,
        ),
      ),
    );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label:
          'Hourly forecast for the dark span: ${slots.where((s) => s.instant).length} hours. Select an hour for its exact values.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Hour by hour', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Select an hour for values. Scroll sideways for later hours.',
            style: text,
          ),
          SingleChildScrollView(
            key: const Key('weather.hours'),
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: cell * slots.length,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  caption('Cloud cover · %'),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final (i, slot) in slots.indexed)
                        Semantics(
                          key: Key('weather.plot.hour.$i'),
                          button: true,
                          selected: i == _selected,
                          enabled: true,
                          excludeSemantics: true,
                          onTap: () => setState(() => _selected = i),
                          label:
                              '${time(slot)}${slot.hour == null
                                  ? ', no forecast'
                                  : slot.instant && slot.hour?.cloudCoverPct != null
                                  ? ', cloud ${QuantityText.percent(slot.hour!.cloudCoverPct!)}'
                                  : slot.instant
                                  ? ', cloud unknown'
                                  : ', preceding-hour values only'}${slot.dewRisk == true ? ', dew risk (heuristic)' : ''}. Shows its exact values',
                          child: InkWell(
                            onTap: () => setState(() => _selected = i),
                            child: Container(
                              width: cell,
                              constraints: const BoxConstraints(minHeight: 128),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: i == _selected
                                    ? tokens?.selection ??
                                          theme.colorScheme.secondaryContainer
                                    : null,
                                border: Border(
                                  bottom: BorderSide(
                                    width: 2,
                                    color: i == _selected
                                        ? palette.textPrimary
                                        : HybridTokens.transparent,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    time(slot),
                                    style: text,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  _CloudColumn(
                                    value: slot.instant
                                        ? slot.hour?.cloudCoverPct
                                        : null,
                                    outside: !slot.instant,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    slot.hour == null
                                        ? 'no\nforecast'
                                        : !slot.instant
                                        ? '—'
                                        : slot.hour?.cloudCoverPct == null
                                        ? 'Unknown'
                                        : slot.hour!.cloudCoverPct!
                                              .toStringAsFixed(0),
                                    style: text,
                                    textAlign: TextAlign.center,
                                  ),
                                  if (slot.dewRisk == true)
                                    Icon(
                                      Icons.water_drop_outlined,
                                      size: 14,
                                      color:
                                          tokens?.weatherCaution ??
                                          palette.caution,
                                      semanticLabel: 'dew risk',
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  caption(
                    temperatureRange == null
                        ? 'Temperature and dew point · unknown'
                        : 'Temperature (solid) and dew point (dashed) · ${temperatureRange.$1.toStringAsFixed(0)} to ${temperatureRange.$2.toStringAsFixed(0)} ${units.temperature.symbol}',
                  ),
                  if (temperatureRange != null)
                    plot(
                      [
                        WeatherPlotSeries(
                          data.temperature,
                          palette.textPrimary,
                        ),
                        WeatherPlotSeries(
                          data.dewPoint,
                          palette.textSecondary,
                          dash: const [5, 4],
                        ),
                      ],
                      temperatureRange.$1,
                      temperatureRange.$2,
                      'Temperature and dew point in ${units.temperature.symbol}; gaps remain disconnected.',
                      const Key('weather.temperaturePlot'),
                    )
                  else
                    Text('No temperature or dew point samples.', style: text),
                  caption('Relative humidity · 0–100%'),
                  if (data.humidity.any((v) => v != null))
                    plot(
                      [
                        WeatherPlotSeries(
                          data.humidity,
                          palette.textPrimary,
                          dash: const [2, 4],
                        ),
                      ],
                      0,
                      100,
                      'Humidity from 0 to 100 percent; dotted line; gaps remain disconnected.',
                      const Key('weather.humidityPlot'),
                      guides: true,
                    )
                  else
                    Text('No humidity samples.', style: text),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _Legend('Temperature', palette.textPrimary),
              _Legend('Dew point', palette.textSecondary, dash: const [5, 4]),
              _Legend('Humidity · %', palette.textPrimary, dash: const [2, 4]),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 18,
                    height: 12,
                    child: CustomPaint(
                      painter: WeatherGapPainter(palette.controlBorder),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(child: Text('Cloud unknown', style: text)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Selected hour', style: text),
          if (slots.length > 1)
            Slider(
              key: const Key('weather.hourSlider'),
              min: 0,
              max: (slots.length - 1).toDouble(),
              divisions: slots.length - 1,
              value: (_selected ?? 0).toDouble(),
              semanticFormatterCallback: (v) => time(slots[v.round()]),
              onChanged: (v) => setState(() => _selected = v.round()),
            ),
          if (_selected case final i?)
            Semantics(
              liveRegion: true,
              child: Text(
                widget.exactDescription(context, slots[i], widget.zoneId),
                key: const Key('weather.hourDetail'),
                style: text,
              ),
            ),
        ],
      ),
    );
  }
}

/// Presentation data with gaps preserved; canonical values are never mutated.
class WeatherPlotData {
  const WeatherPlotData(this.temperature, this.dewPoint, this.humidity);
  final List<double?> temperature;
  final List<double?> dewPoint;
  final List<double?> humidity;

  factory WeatherPlotData.fromSlots(
    List<NightWeatherSlot> slots,
    DisplayUnits units,
  ) {
    double? shown(NightWeatherSlot s, double? value) =>
        !s.instant || value == null || !value.isFinite
        ? null
        : units.temperatureOf(value);
    return WeatherPlotData(
      [for (final s in slots) shown(s, s.hour?.temperatureC)],
      [for (final s in slots) shown(s, s.hour?.dewPointC)],
      [
        for (final s in slots)
          if (!s.instant ||
              s.hour?.relativeHumidityPct == null ||
              !s.hour!.relativeHumidityPct!.isFinite)
            null
          else
            s.hour!.relativeHumidityPct,
      ],
    );
  }

  (double, double)? get temperatureRange {
    final known = [...temperature, ...dewPoint].whereType<double>().toList();
    if (known.isEmpty) return null;
    return (
      known.reduce(math.min).floorToDouble() - 1,
      known.reduce(math.max).ceilToDouble() + 1,
    );
  }
}

class WeatherPlotSeries {
  const WeatherPlotSeries(this.values, this.color, {this.dash = const []});
  final List<double?> values;
  final Color color;
  final List<double> dash;
}

/// Returns disjoint runs so a missing forecast cannot be bridged by a line.
List<List<Offset>> weatherPlotRuns(
  List<double?> values,
  Size size,
  double minimum,
  double maximum,
) {
  final runs = <List<Offset>>[];
  var current = <Offset>[];
  for (var i = 0; i < values.length; i++) {
    final value = values[i];
    if (value == null || !value.isFinite) {
      if (current.isNotEmpty) runs.add(current);
      current = [];
      continue;
    }
    current.add(
      Offset(
        (i + .5) * size.width / values.length,
        size.height -
            8 -
            ((value - minimum) / (maximum > minimum ? maximum - minimum : 1))
                    .clamp(0, 1) *
                (size.height - 16),
      ),
    );
  }
  if (current.isNotEmpty) runs.add(current);
  return runs;
}

class WeatherLinesPainter extends CustomPainter {
  const WeatherLinesPainter({
    required this.series,
    required this.minimum,
    required this.maximum,
    required this.grid,
  });
  final List<WeatherPlotSeries> series;
  final double minimum;
  final double maximum;
  final Color grid;

  @override
  void paint(Canvas canvas, Size size) {
    final guide = Paint()
      ..color = grid
      ..strokeWidth = 1;
    canvas.drawLine(const Offset(0, 8), Offset(size.width, 8), guide);
    canvas.drawLine(
      Offset(0, size.height - 8),
      Offset(size.width, size.height - 8),
      guide,
    );
    for (final s in series) {
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      for (final run in weatherPlotRuns(s.values, size, minimum, maximum)) {
        if (run.length == 1) {
          canvas.drawCircle(run.single, 2, Paint()..color = s.color);
          continue;
        }
        final path = Path()..moveTo(run.first.dx, run.first.dy);
        for (final point in run.skip(1)) {
          path.lineTo(point.dx, point.dy);
        }
        if (s.dash.isEmpty) {
          canvas.drawPath(path, paint);
        } else {
          for (final metric in path.computeMetrics()) {
            for (
              double start = 0;
              start < metric.length;
              start += s.dash[0] + s.dash[1]
            ) {
              canvas.drawPath(
                metric.extractPath(
                  start,
                  math.min(start + s.dash[0], metric.length),
                ),
                paint,
              );
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(WeatherLinesPainter oldDelegate) =>
      series != oldDelegate.series ||
      minimum != oldDelegate.minimum ||
      maximum != oldDelegate.maximum ||
      grid != oldDelegate.grid;
}

class _CloudColumn extends StatelessWidget {
  const _CloudColumn({required this.value, required this.outside});
  final double? value;
  final bool outside;
  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return ExcludeSemantics(
      child: SizedBox(
        width: 16,
        height: 58,
        child: outside
            ? DecoratedBox(
                decoration: BoxDecoration(border: Border.all(color: p.border)),
              )
            : value == null || !value!.isFinite
            ? CustomPaint(painter: WeatherGapPainter(p.controlBorder))
            : ColoredBox(
                color: Theme.of(context).colorScheme.surface,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    key: const Key('weather.cloudBar'),
                    heightFactor: (value! / 100).clamp(0, 1),
                    widthFactor: 1,
                    child: ColoredBox(color: p.textSecondary),
                  ),
                ),
              ),
      ),
    );
  }
}

class WeatherGapPainter extends CustomPainter {
  const WeatherGapPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = -size.height; x < size.width; x += 4) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), p);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(WeatherGapPainter oldDelegate) =>
      color != oldDelegate.color;
}

class _Legend extends StatelessWidget {
  const _Legend(this.label, this.color, {this.dash = const []});
  final String label;
  final Color color;
  final List<double> dash;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CustomPaint(
        size: const Size(18, 16),
        painter: WeatherLinesPainter(
          series: [
            WeatherPlotSeries(const [0.5, 0.5], color, dash: dash),
          ],
          minimum: 0,
          maximum: 1,
          grid: HybridTokens.transparent,
        ),
      ),
      const SizedBox(width: 6),
      Flexible(
        child: Text(label, style: Theme.of(context).textTheme.bodySmall),
      ),
    ],
  );
}
