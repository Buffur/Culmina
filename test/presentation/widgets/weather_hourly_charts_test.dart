import 'dart:ui' as ui;

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/core/units/display_units.dart';
import 'package:astroplan/domain/models/night_weather_summary.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/presentation/widgets/weather_hourly_charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

NightWeatherSlot slot(
  int hour, {
  double? temperature,
  double? dew,
  double? humidity,
  double? cloud,
  bool instant = true,
  bool missing = false,
}) {
  final time = DateTime.utc(2026, 10, 20, hour);
  return NightWeatherSlot(
    timeUtc: time,
    hour: missing
        ? null
        : WeatherHour(
            timeUtc: time,
            temperatureC: temperature,
            dewPointC: dew,
            relativeHumidityPct: humidity,
            cloudCoverPct: cloud,
          ),
    dewSpreadC: null,
    dewRisk: null,
    instant: instant,
    precedingMinutes: instant ? 60 : 45,
  );
}

void main() {
  test('canonical slots retain gaps, distinct instantaneous boundaries and Fahrenheit conversion', () {
    final slots = [
      slot(19, temperature: 0, dew: -2, humidity: 80),
      slot(20, missing: true),
      slot(21, temperature: 10, humidity: 0),
      slot(22, temperature: 99, dew: 99, humidity: 99, instant: false),
    ];
    final data = WeatherPlotData.fromSlots(
      slots,
      const DisplayUnits(temperature: TemperatureUnit.fahrenheit),
    );
    expect(data.temperature, [32, null, 50, null]);
    expect(data.dewPoint, [28.4, null, null, null]);
    expect(data.humidity, [80, null, 0, null]);
    expect(data.temperatureRange, (27, 51));
    expect(
      slots.last.hour!.temperatureC,
      99,
      reason: 'display must not rewrite source',
    );
    expect(
      WeatherPlotData.fromSlots([
        slot(0, missing: true),
      ], DisplayUnits.metric).temperatureRange,
      isNull,
    );
  });

  test('line runs break on missing variables and keep an isolated point at its real hour', () {
    final runs = weatherPlotRuns(
      [0, 50, null, 100],
      const Size(224, 80),
      0,
      100,
    );
    expect(runs.length, 2);
    expect(runs.first, const [Offset(28, 72), Offset(84, 40)]);
    expect(runs.last, const [Offset(196, 8)]);
    expect(weatherPlotRuns([null, null], const Size(112, 80), 0, 100), isEmpty);
  });

  test('painted missing interval stays blank and a single known sample remains visible', () async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawColor(Colors.white, BlendMode.src);
    const painter = WeatherLinesPainter(
      series: [
        WeatherPlotSeries([50, null, 50], Colors.black),
      ],
      minimum: 0,
      maximum: 100,
      grid: Colors.transparent,
    );
    painter.paint(canvas, const Size(168, 80));
    final picture = recorder.endRecording();
    final image = await picture.toImage(168, 80);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    int red(int x, int y) => bytes!.getUint8((y * 168 + x) * 4);
    expect(red(28, 40), lessThan(20));
    expect(
      red(84, 40),
      255,
      reason: 'a gap cannot be interpolated into a forecast',
    );
    expect(red(140, 40), lessThan(20));
    image.dispose();
    picture.dispose();
  });

  testWidgets(
    '200 percent chart exposes unknown and exact hour controls, without changing data',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final slots = [
        slot(19, temperature: 0, dew: -2, humidity: 80, cloud: 40),
        slot(20, missing: true),
        slot(21, temperature: 2, humidity: 50, cloud: 0),
        slot(22, temperature: 100, instant: false),
      ];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.fieldTheme,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(360, 900),
              textScaler: TextScaler.linear(2),
            ),
            child: Scaffold(
              body: SingleChildScrollView(
                child: WeatherHourlyCharts(
                  slots: slots,
                  zoneId: 'UTC',
                  exactDescription: (_, s, _) =>
                      '${s.timeUtc.hour}: ${s.hour == null
                          ? 'no forecast'
                          : s.instant
                          ? 'known'
                          : 'preceding only'}',
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.byKey(const Key('weather.temperaturePlot')), findsOneWidget);
      expect(find.byKey(const Key('weather.humidityPlot')), findsOneWidget);
      expect(find.byKey(const Key('weather.cloudBar')), findsNWidgets(2));
      expect(find.text('no\nforecast'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('weather.plot.hour.1')));
      await tester.tap(find.byKey(const Key('weather.plot.hour.1')));
      await tester.pump();
      expect(find.text('20: no forecast'), findsOneWidget);
      final slider = tester.widget<Slider>(
        find.byKey(const Key('weather.hourSlider')),
      );
      slider.onChanged!(3);
      await tester.pump();
      expect(find.text('22: preceding only'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(
        slots[2].hour!.cloudCoverPct,
        0,
        reason: 'known zero differs from unknown',
      );
    },
  );
}
