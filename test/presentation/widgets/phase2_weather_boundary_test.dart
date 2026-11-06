import 'dart:io';
import 'dart:ui' as ui;

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/core/units/display_units.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/night_weather.dart';
import 'package:astroplan/domain/models/night_weather_summary.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/models/site_time_context.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/repositories/display_settings_repository.dart';
import 'package:astroplan/domain/services/night_weather_summarizer.dart';
import 'package:astroplan/domain/services/night_view.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:astroplan/presentation/viewmodels/disclosure_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/display_settings_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/night_conditions_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/settings_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/site_viewmodel.dart';
import 'package:astroplan/presentation/widgets/weather_hybrid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Synthetic boundary fixtures, using the production summarizer and view.
// They isolate finite presentational states; service/cache integration remains
// in weather_hybrid_view_test and forecast_nights_test.
class _Conditions extends ChangeNotifier implements NightConditionsViewModel {
  _Conditions(this.nightWeather, this.nightWeatherSummary, this.sessionNight);
  @override
  final NightWeather nightWeather;
  @override
  final NightWeatherSummary? nightWeatherSummary;
  @override
  final SessionNight? sessionNight;
  int refreshes = 0;
  @override
  Future<void> refreshWeather() async {
    refreshes++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Site extends ChangeNotifier implements SiteViewModel {
  _Site(this.latitude);
  @override
  final double latitude;
  @override
  double get longitude => 14;
  @override
  String? get displayZoneId => 'Europe/Ljubljana';
  @override
  SiteTimeContext get timeContext => MeanSolarTimeContext(14);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Settings extends ChangeNotifier implements SettingsViewModel {
  @override
  PlanningPreferences get planningPreferences => PlanningPreferences();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Disclosure extends ChangeNotifier implements DisclosureViewModel {
  bool open = false;
  @override
  bool isOpen(String key, {bool initiallyOpen = false}) => open;
  @override
  Future<void> setOpen(String key, bool value) async {
    open = value;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DisplayStore implements DisplaySettingsRepository {
  @override
  Future<DisplaySettings> load() async => const DisplaySettings();
  @override
  Future<void> save(DisplaySettings value) async {}
  @override
  Future<bool> lastSaveIncomplete() async => false;
}

void main() {
  for (final (mode, theme) in [
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
    ('field', AppTheme.fieldTheme),
  ]) {
    for (final state in [
      'idle',
      'loading',
      'no-dark',
      'polar-night',
      'partial-rows',
      'partial-cloud',
      'complete-metrics',
      'no-dew-risk',
      'unknown-dew',
      'unknown-fields',
      'all-series-unknown',
      'charts-selected',
      'charts-gaps',
      'charts-zero',
      'charts-single-hour',
      'rows-narrow',
      'rows-large-text',
    ]) {
      testWidgets('Phase2 weather boundary $state $mode', (tester) async {
        tester.view.physicalSize = Size(
          state == 'rows-narrow' ? 320 : 375,
          812,
        );
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        if (state == 'rows-large-text') {
          tester.platformDispatcher.textScaleFactorTestValue = 2;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        }
        await (FontLoader(
          'Geist',
        )..addFont(rootBundle.load('assets/fonts/Geist.ttf'))).load();
        final latitude = state == 'polar-night'
            ? 88.0
            : state == 'no-dark'
            ? 78.0
            : 46.0;
        final night = SessionNightResolver.forEveningDate(
          state == 'polar-night'
              ? CalendarDate(2026, 12, 15)
              : state == 'no-dark'
              ? CalendarDate(2027, 6, 20)
              : CalendarDate(2026, 10, 19),
          latitude: latitude,
          longitude: 14,
          timeContext: MeanSolarTimeContext(14),
        );
        final polar = state == 'polar-night' || state == 'no-dark';
        final span = NightWeatherSummarizer.spanOf(
          NightView.of(night, limitDeg: -18).timeline,
        );
        final from = polar
            ? span.fromUtc
            : state == 'charts-single-hour'
            ? DateTime.utc(2026, 10, 19, 18, 20)
            : DateTime.utc(2026, 10, 19, 18, 40);
        final to = polar
            ? span.toUtc
            : state == 'charts-single-hour'
            ? DateTime.utc(2026, 10, 19, 19, 10)
            : DateTime.utc(2026, 10, 20, 4, 42);
        final snapshot = WeatherSnapshot(
          provider: 'fixture',
          model: 'boundary',
          fetchedAtUtc: from,
          latitude: latitude,
          longitude: 14,
          hours: [
            for (var i = 0; i < (polar ? 26 : 12); i++)
              if (!(state == 'partial-rows' || state == 'charts-gaps') ||
                  i != 4)
                WeatherHour(
                  timeUtc: DateTime.utc(
                    from.year,
                    from.month,
                    from.day,
                    from.hour + i,
                  ),
                  cloudCoverPct:
                      state == 'all-series-unknown' ||
                          (state == 'partial-cloud' && i == 4)
                      ? null
                      : state == 'charts-zero' || i == 1
                      ? 0
                      : (i * 7 % 101).toDouble(),
                  cloudCoverLowPct:
                      (state == 'unknown-fields' ||
                          state == 'all-series-unknown')
                      ? null
                      : 10,
                  cloudCoverMidPct:
                      (state == 'unknown-fields' ||
                          state == 'all-series-unknown')
                      ? null
                      : 15,
                  cloudCoverHighPct:
                      (state == 'unknown-fields' ||
                          state == 'all-series-unknown')
                      ? null
                      : 25,
                  temperatureC:
                      (state == 'unknown-fields' ||
                          state == 'all-series-unknown')
                      ? null
                      : 8,
                  dewPointC:
                      state == 'unknown-dew' ||
                          (state == 'unknown-fields' ||
                              state == 'all-series-unknown')
                      ? null
                      : state == 'no-dew-risk'
                      ? -3
                      : 7,
                  windSpeedKmh:
                      (state == 'unknown-fields' ||
                          state == 'all-series-unknown')
                      ? null
                      : 12,
                  windGustsKmh:
                      (state == 'unknown-fields' ||
                          state == 'all-series-unknown')
                      ? null
                      : 20,
                  relativeHumidityPct:
                      (state == 'unknown-fields' ||
                          state == 'all-series-unknown')
                      ? null
                      : 75,
                  precipitationProbabilityPct:
                      (state == 'unknown-fields' ||
                          state == 'all-series-unknown')
                      ? null
                      : state == 'charts-zero'
                      ? 0
                      : 5,
                  visibilityM:
                      (state == 'unknown-fields' ||
                          state == 'all-series-unknown')
                      ? null
                      : 24000,
                ),
          ],
        );
        final summary = NightWeatherSummarizer.summarize(
          snapshot,
          fromUtc: from,
          toUtc: to,
          dewMarginC: 2,
          span: polar ? span.span : NightWeatherSpan.dark,
        );
        final conditions = _Conditions(
          switch (state) {
            'idle' => const NightWeatherIdle(),
            'loading' => const NightWeatherLoading(),
            _ => NightWeatherAvailable(
              snapshot: snapshot,
              age: WeatherAge.current,
              ageDuration: Duration.zero,
              fromCache: false,
            ),
          },
          state == 'idle' || state == 'loading' ? null : summary,
          night,
        );
        final site = _Site(latitude);
        final settings = _Settings();
        final disclosure = _Disclosure();
        final display = DisplaySettingsViewModel(_DisplayStore());
        addTearDown(conditions.dispose);
        addTearDown(site.dispose);
        addTearDown(settings.dispose);
        addTearDown(disclosure.dispose);
        addTearDown(display.dispose);
        if (state.startsWith('charts')) {
          await display.setWeatherView(WeatherView.charts);
        }
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<NightConditionsViewModel>.value(
                value: conditions,
              ),
              ChangeNotifierProvider<SiteViewModel>.value(value: site),
              ChangeNotifierProvider<SettingsViewModel>.value(value: settings),
              ChangeNotifierProvider<DisclosureViewModel>.value(
                value: disclosure,
              ),
              ChangeNotifierProvider<DisplaySettingsViewModel>.value(
                value: display,
              ),
            ],
            child: RepaintBoundary(
              key: const Key('capture'),
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: theme,
                builder: (context, child) => mode == 'field'
                    ? ColorFiltered(
                        colorFilter: AppTheme.fieldFilter,
                        child: child!,
                      )
                    : child!,
                home: const Scaffold(
                  body: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: HybridWeatherView(),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        if (state == 'idle' || state == 'loading') {
          expect(find.byKey(const Key('weather.loading')), findsOneWidget);
          expect(find.byKey(const Key('weather.refresh')), findsNothing);
        } else if (state == 'no-dark') {
          expect(find.text('No dark hours to summarize'), findsOneWidget);
          expect(
            find.byKey(const Key('weather.statisticsGroup')),
            findsNothing,
          );
          expect(find.byKey(const Key('weather.refresh')), findsNothing);
        } else {
          expect(
            find.byKey(const Key('weather.statisticsGroup')),
            findsOneWidget,
          );
          if (state == 'partial-rows' || state == 'charts-gaps') {
            expect(find.byKey(const Key('weather.gaps')), findsOneWidget);
          }
          if (state == 'partial-cloud') {
            expect(
              find.byKey(const Key('weather.headlineCoverage')),
              findsOneWidget,
            );
            expect(find.textContaining('in known dark hours'), findsOneWidget);
          }
          if (state == 'no-dew-risk' || state == 'unknown-dew') {
            expect(find.byKey(const Key('weather.dew')), findsNothing);
          }
          if (state.startsWith('charts')) {
            final panel = find.byKey(const Key('weather.chart.Cloud cover'));
            await tester.ensureVisible(panel);
            final bounds = tester.getRect(panel);
            final selected = state == 'charts-gaps'
                ? summary.slots.indexWhere(
                    (slot) => slot.instant && slot.hour == null,
                  )
                : state == 'charts-zero'
                ? 1
                : 0;
            await tester.tapAt(
              Offset(
                bounds.left +
                    24 +
                    (bounds.width - 24) *
                        (selected + .5) /
                        summary.slots.length,
                bounds.center.dy,
              ),
            );
            await tester.pump();
            final valueKey = state == 'charts-gaps'
                ? 'weather.chartValue.Cloud cover'
                : 'weather.chartValue.Precipitation probability';
            expect(
              tester.widget<Text>(find.byKey(Key(valueKey))).data,
              state == 'charts-gaps'
                  ? 'Unknown'
                  : state == 'charts-zero'
                  ? '0%'
                  : state == 'charts-single-hour'
                  ? '5%'
                  : 'Excluded (<30 min dark)',
            );
            expect(
              find.byKey(const Key('weather.selectionControls')),
              findsOneWidget,
            );
            expect(
              find.byKey(const Key('weather.selectedTime')),
              findsOneWidget,
            );
            if (state == 'charts-single-hour') {
              expect(summary.slots, hasLength(1));
              expect(summary.slots.single.precedingMinutes, 40);
              expect(
                tester
                    .widget<IconButton>(
                      find.byKey(const Key('weather.previousHour')),
                    )
                    .onPressed,
                isNull,
              );
              expect(
                tester
                    .widget<IconButton>(
                      find.byKey(const Key('weather.nextHour')),
                    )
                    .onPressed,
                isNull,
              );
            }
            if (state == 'charts-selected' ||
                state == 'charts-zero' ||
                state == 'charts-single-hour') {
              final probability = find.byKey(
                const Key('weather.chart.Precipitation probability'),
              );
              final paints = tester.widgetList<CustomPaint>(
                find.descendant(
                  of: probability,
                  matching: find.byType(CustomPaint),
                ),
              );
              final paint = paints.firstWhere(
                (paint) =>
                    paint.painter.runtimeType.toString() == '_LinePainter',
              );
              final width = paint.size.width.round();
              expect(
                ((paint.painter as dynamic).axisStyle as TextStyle).fontSize,
                12,
              );
              expect(
                ((paint.painter as dynamic).gapStyle as TextStyle).fontSize,
                13,
                reason: 'axis density does not shrink unknown markers',
              );
              final axisLabels = tester.widgetList<Text>(
                find.byWidgetPredicate(
                  (widget) =>
                      widget is Text &&
                      widget.key.toString().contains('weather.axis.'),
                ),
              );
              expect(axisLabels, isNotEmpty);
              expect(
                axisLabels.every((label) => label.style!.fontSize == 12),
                isTrue,
              );

              // A preceding-hour probability owns the interval before its tick;
              // the same interval retains its full width for a partial end hour.
              await tester.runAsync(() async {
                final recorder = ui.PictureRecorder();
                final canvas = Canvas(recorder);
                paint.painter!.paint(canvas, paint.size);
                final picture = recorder.endRecording();
                final image = await picture.toImage(width, 100);
                final bytes = (await image.toByteData(
                  format: ui.ImageByteFormat.rawRgba,
                ))!.buffer.asUint8List();
                final step = (paint.size.width - 24) / summary.slots.length;
                final x = state == 'charts-single-hour'
                    ? (24 + (paint.size.width - 24) * .25).floor()
                    : (24 + step * 1.5 - step * .7).floor();
                final y = state == 'charts-zero' ? 79 : 78;
                final color = (paint.painter as dynamic).line as Color;
                final offset = (y * width + x) * 4;
                expect(bytes[offset], (color.r * 255).round());
                expect(bytes[offset + 1], (color.g * 255).round());
                expect(bytes[offset + 2], (color.b * 255).round());
                image.dispose();
                picture.dispose();
              });
            }
          }
        }
        if (state == 'rows-narrow' || state == 'rows-large-text') {
          final label = find.text('Temperature');
          final value = find.byKey(const Key('weather.range.Temperature'));
          expect(
            tester.getRect(value).top,
            greaterThan(tester.getRect(label).bottom),
            reason: 'local row stacks naturally for narrow width or large text',
          );
          expect(tester.widget<Text>(value).data, '8 °C');
          if (state == 'rows-large-text') {
            final context = tester.element(value);
            expect(
              MediaQuery.textScalerOf(context).scale(1),
              2,
              reason: 'the user text scale is preserved',
            );
          }
          await tester.ensureVisible(
            find.byKey(const Key('weather.metric.Temperature')),
          );
          await tester.pump();
        }
        Future<void> capture([String suffix = '']) async {
          final output = Platform.environment['CULMINA_PHASE2_RENDERS'];
          if (output != null && output.isNotEmpty) {
            final boundary = tester.renderObject<RenderRepaintBoundary>(
              find.byKey(const Key('capture')),
            );
            await tester.runAsync(() async {
              final image = await boundary.toImage(pixelRatio: 1);
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final file = File(
                '$output/package1/weather-boundary-$state-$mode$suffix.png',
              );
              await file.parent.create(recursive: true);
              await file.writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
        }

        if (state == 'charts-single-hour') {
          await tester.ensureVisible(
            find.byKey(const Key('weather.selectionControls')),
          );
          await tester.pump();
        }
        await capture();
        if (state == 'charts-single-hour') {
          await tester.ensureVisible(
            find.byKey(const Key('weather.chart.Precipitation probability')),
          );
          await tester.pump();
          await capture('-probability');
          await tester.ensureVisible(
            find.byKey(const Key('weather.resetSelection')),
          );
          await tester.tap(find.byKey(const Key('weather.resetSelection')));
          await tester.pump();
          expect(
            find.byKey(const Key('weather.selectionControls')),
            findsNothing,
          );
          expect(
            tester
                .widget<Text>(
                  find.byKey(
                    const Key('weather.chartValue.Precipitation probability'),
                  ),
                )
                .data,
            'Dark time: 5%',
          );
          expect(conditions.nightWeatherSummary, same(summary));
        }
        if (state == 'complete-metrics' || state == 'no-dew-risk') {
          expect(
            find.text('All metrics: 10/10 known samples'),
            findsOneWidget,
            reason: 'equal seven series; dew-point data not dew-risk count',
          );
          for (final metric in [
            'Temperature',
            'Relative humidity',
            'Cloud cover',
            'Wind / gusts',
            'Precipitation probability',
          ]) {
            expect(find.byKey(Key('weather.coverage.$metric')), findsNothing);
          }
        }
        if (state == 'partial-cloud' ||
            state == 'unknown-dew' ||
            state == 'all-series-unknown') {
          expect(find.byKey(const Key('weather.commonCoverage')), findsNothing);
          expect(
            find.byKey(const Key('weather.coverage.Temperature')),
            findsOneWidget,
          );
        }
        if (state == 'all-series-unknown') {
          expect(find.text('Cloud cover unknown'), findsOneWidget);
          expect(find.byKey(const Key('weather.commonCoverage')), findsNothing);
          for (final metric in [
            'Temperature',
            'Relative humidity',
            'Cloud cover',
            'Wind / gusts',
            'Precipitation probability',
          ]) {
            expect(
              tester
                  .widget<Text>(find.byKey(Key('weather.range.$metric')))
                  .data,
              'Unknown',
            );
            expect(
              tester
                  .widget<Text>(find.byKey(Key('weather.coverage.$metric')))
                  .data,
              contains('0/10 known'),
            );
          }
        }
        if (state == 'complete-metrics' ||
            state == 'unknown-dew' ||
            (state == 'unknown-fields' || state == 'all-series-unknown')) {
          await tester.ensureVisible(find.text('Forecast details'));
          await tester.tap(find.text('Forecast details'));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('weather.tableKey')), findsOneWidget);
          final table = find.byKey(const Key('weather.table'));
          expect(
            find.descendant(of: table, matching: find.text('Unknown')),
            state == 'unknown-dew' ||
                    (state == 'unknown-fields' || state == 'all-series-unknown')
                ? findsWidgets
                : findsNothing,
          );
          expect(
            find.descendant(of: table, matching: find.text('—')),
            findsWidgets,
          );
          final data = tester.widget<Table>(
            find.descendant(
              of: table,
              matching: find.byWidgetPredicate((widget) => widget is Table),
            ),
          );
          if (state == 'complete-metrics') {
            await tester.ensureVisible(table);
            await tester.pump();
            await capture('-table');
            final pinned = find.descendant(
              of: find.byWidget(data.children[1].children.first),
              matching: find.byType(Text),
            );
            final leading = tester.getRect(pinned).left;
            await tester.drag(table, const Offset(-800, 0));
            await tester.pumpAndSettle();
            expect(
              tester.getRect(pinned).left,
              closeTo(leading, .1),
              reason: 'local time stays pinned while weather columns scroll',
            );
            expect(
              tester.getRect(find.text('Visibility km')).right,
              lessThanOrEqualTo(tester.getRect(table).right + .1),
            );
            await capture('-table-scrolled');
          }
          for (final row in data.children) {
            for (final cell in row.children) {
              final text = tester.widget<Text>(
                find.descendant(
                  of: find.byWidget(cell),
                  matching: find.byType(Text),
                ),
              );
              expect(text.textAlign, TextAlign.center);
            }
          }
          if ((state == 'unknown-fields' || state == 'all-series-unknown')) {
            final visibility = tester.widget<Text>(
              find.descendant(
                of: find.byWidget(data.children[1].children.last),
                matching: find.byType(Text),
              ),
            );
            expect(visibility.data, 'Unknown');
          }
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
