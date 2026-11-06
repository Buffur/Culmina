import 'dart:io';
import 'dart:ui' as ui;

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/core/units/display_units.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/repositories/planning_preferences_repository.dart';
import 'package:astroplan/domain/repositories/storage_failure.dart';
import 'package:astroplan/domain/services/opt_in_reverse_geocoder.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/screens/settings/settings_screen.dart';
import 'package:astroplan/presentation/screens/settings/settings_parts.dart';
import 'package:astroplan/presentation/screens/startup/unsupported_database_screen.dart';
import 'package:astroplan/presentation/shared/collapsible_section.dart';
import 'package:astroplan/presentation/shared/field_mode_button.dart';
import 'package:astroplan/presentation/shared/hybrid_parts.dart';
import 'package:astroplan/presentation/viewmodels/night_conditions_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/settings_viewmodel.dart';
import 'package:astroplan/presentation/widgets/weather_hybrid_view.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:astroplan/presentation/shared/night_time_formatter.dart';
import 'package:astroplan/core/utils/quantity_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../support/hybrid_transfer_fixture.dart';
import '../../support/hybrid_transfer_shots.dart';
import '../../support/sdk_fonts.dart';
import '../../support/in_memory_privacy_preferences.dart';
import '../../support/fake_reverse_geocoder.dart';

const _shot = Key('weather.implementation.review');
const _metrics = [
  'Temperature',
  'Relative humidity',
  'Cloud cover',
  'Wind / gusts',
  'Precipitation probability',
];
const _variants = ['light', 'dark', 'field'];
Future<void> _fonts() async {
  Future<ByteData> sdk(String f) =>
      sdkMaterialFont(f)!.readAsBytes().then(ByteData.sublistView);
  for (final family in ['Roboto', 'FlutterTest']) {
    final font = FontLoader(family);
    for (final f in [
      'roboto-regular.ttf',
      'roboto-medium.ttf',
      'roboto-bold.ttf',
    ]) {
      font.addFont(sdk(f));
    }
    await font.load();
  }
  await (FontLoader('Geist')..addFont(
        File('assets/fonts/Geist.ttf').readAsBytes().then(ByteData.sublistView),
      ))
      .load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(sdk('materialicons-regular.otf'))).load();
}

Future<void> _setup(
  WidgetTester t, {
  double width = 375,
  String theme = 'dark',
}) async {
  t.view.physicalSize = Size(width, 812);
  t.view.devicePixelRatio = 1;
  t.platformDispatcher.platformBrightnessTestValue = theme == 'light'
      ? Brightness.light
      : Brightness.dark;
  t.platformDispatcher.textScaleFactorTestValue = 1;
  addTearDown(t.view.reset);
  addTearDown(t.platformDispatcher.clearAllTestValues);
  await t.runAsync(_fonts);
}

Future<HybridTransferFixture> _app(
  WidgetTester t, {
  double width = 375,
  String theme = 'dark',
}) async {
  await _setup(t, width: width, theme: theme);
  late HybridTransferFixture f;
  await t.runAsync(() async {
    f = await HybridTransferFixture.create(
      AppDatabase(NativeDatabase.memory()),
    );
    if (theme == 'field') await f.vm.theme.toggleFieldMode();
  });
  addTearDown(() => t.runAsync(f.db.close));
  AppRouter.router.go(AppRouter.tonight);
  await t.pumpWidget(
    RepaintBoundary(
      key: _shot,
      child: MultiProvider(
        providers: f.vm.providers,
        child: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: const AstroPlanApp(),
          ),
        ),
      ),
    ),
  );
  await hybridSettle(t);
  return f;
}

List<String> _texts(Finder parent) => find
    .descendant(of: parent, matching: find.byType(Text))
    .evaluate()
    .map((e) => (e.widget as Text).data ?? '')
    .toList();
Future<void> _flush(WidgetTester t) async {
  await t.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 20)),
  );
  await t.pumpAndSettle();
}

class _RecoverablePreferences implements PlanningPreferencesRepository {
  PlanningPreferences stored = PlanningPreferences();
  bool fail = true;
  final attempted = <double>[];
  @override
  Future<PlanningPreferences> load() async => stored;
  @override
  Future<bool> lastSaveIncomplete() async => false;
  @override
  Future<void> save(PlanningPreferences p) async {
    attempted.add(p.perFrameOverheadSeconds);
    if (fail) throw const StorageFailure('synthetic preference failure');
    stored = p;
  }
}

Future<SettingsViewModel> _planning(
  WidgetTester t,
  _RecoverablePreferences store,
) async {
  await _setup(t);
  final vm = SettingsViewModel(
    store,
    InMemoryPrivacyPreferences(),
    OptInReverseGeocoder(FakeReverseGeocoder()),
  );
  await vm.load();
  addTearDown(vm.dispose);
  await t.pumpWidget(
    RepaintBoundary(
      key: _shot,
      child: ChangeNotifierProvider.value(
        value: vm,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          home: const SettingsScreen(),
        ),
      ),
    ),
  );
  await t.pumpAndSettle();
  await t.tap(find.byKey(const Key('settings.open.planning')));
  await t.pumpAndSettle();
  return vm;
}

Slider _perFrame(WidgetTester t) => t.widget<Slider>(
  find.descendant(
    of: find.byKey(const Key('settings.perFrame')),
    matching: find.byType(Slider),
  ),
);
void main() {
  for (final width in [375.0, 412.0]) {
    for (final theme in _variants) {
      testWidgets(
        'Q5 full-width plots share nearest-hour selection $width $theme',
        (t) async {
          final f = await _app(t, width: width, theme: theme);
          await t.runAsync(
            () => f.vm.vms.displaySettings.setWeatherView(WeatherView.charts),
          );
          f.forecast.cloudGapEvery = 3;
          await HybridRenderContext(t, f).push(AppRouter.weather);
          await hybridSettle(t);
          final scoped = t
              .element(find.byType(HybridWeatherView))
              .read<NightConditionsViewModel>();
          await t.runAsync(scoped.refreshWeather);
          await hybridSettle(t);
          final summary = scoped.nightWeatherSummary!;
          expect(summary.cloudGapHours, greaterThan(0));
          final originalSummary = summary;
          final chart = find.byKey(const Key('weather.charts'));
          expect(
            find.byKey(const Key('weather.selectionControls')),
            findsNothing,
          );
          for (final name in _metrics) {
            expect(find.byKey(Key('weather.cursor.$name')), findsNothing);
          }
          expect(find.byKey(const Key('weather.chartScroll')), findsNothing);
          final viewport = t.getRect(chart);
          final slots = [
            for (final slot in summary.slots)
              if (slot.instant || slot.preceding) slot,
          ];
          String selected(String name) => t
              .widget<Semantics>(find.byKey(Key('weather.chart.$name')))
              .properties
              .value!;
          final before = selected(_metrics.first);
          for (final name in _metrics) {
            final panel = find.byKey(Key('weather.chart.$name'));
            final rect = t.getRect(panel);
            expect(rect.left, closeTo(viewport.left, .5));
            expect(rect.right, closeTo(viewport.right, .5));
            expect(
              selected(name),
              before,
              reason: 'all five plots share the selected hour',
            );
            expect(
              _texts(find.byKey(Key('weather.chartHeader.$name'))).join(' '),
              contains('Dark time:'),
            );
          }
          final targetIndex = slots.indexWhere(
            (s) => s.instant && s.hour?.cloudCoverPct == null,
          );
          expect(targetIndex, greaterThanOrEqualTo(0));
          final target = find.byKey(const Key('weather.chart.Cloud cover'));
          await t.ensureVisible(target);
          await hybridSettle(t);
          final targetRect = t.getRect(target);
          await t.tapAt(
            Offset(
              targetRect.left +
                  24 +
                  (targetIndex + .5) / slots.length * (targetRect.width - 24),
              targetRect.center.dy,
            ),
          );
          await t.pump();
          final after = selected(_metrics.first);
          if (targetIndex != 0) expect(after, isNot(before));
          for (final name in _metrics) {
            expect(
              selected(name),
              after,
              reason: 'plot taps update the same hour for $name',
            );
          }
          expect(
            find.byKey(const Key('weather.selectionControls')),
            findsOneWidget,
          );
          expect(
            t.widget<Text>(find.byKey(const Key('weather.selectedTime'))).data,
            after,
          );
          double? cursorX;
          for (final name in _metrics) {
            final cursor = find.byKey(Key('weather.cursor.$name'));
            expect(
              cursor,
              findsOneWidget,
              reason: 'visible selected cursor for $name',
            );
            final rect = t.getRect(cursor);
            expect(rect.height, greaterThan(0));
            if (cursorX != null) expect(rect.left, closeTo(cursorX, .01));
            cursorX = rect.left;
          }
          expect(
            t
                .widget<Text>(
                  find.byKey(const Key('weather.chartValue.Cloud cover')),
                )
                .data,
            'Unknown',
          );
          if (targetIndex > 0) {
            await t.ensureVisible(
              find.byKey(const Key('weather.previousHour')),
            );
            await hybridSettle(t);
            await t.tap(find.byKey(const Key('weather.previousHour')));
            await hybridSettle(t);
            expect(
              t
                  .widget<Text>(find.byKey(const Key('weather.selectedTime')))
                  .data,
              isNot(after),
            );
            await t.tap(find.byKey(const Key('weather.nextHour')));
            await hybridSettle(t);
            expect(
              t
                  .widget<Text>(find.byKey(const Key('weather.selectedTime')))
                  .data,
              after,
            );
          }
          expect(scoped.nightWeatherSummary, same(originalSummary));
          expect(
            slots[targetIndex].hour?.cloudCoverPct,
            isNull,
            reason: 'selection never turns the gap into zero',
          );
          await t.ensureVisible(find.text('Forecast details'));
          await hybridSettle(t);
          await t.tap(find.text('Forecast details'));
          await hybridSettle(t);
          expect(find.byKey(const Key('weather.hourSlider')), findsNothing);
          final tableFinder = find.byKey(const Key('weather.table'));
          final table = t.widget<Table>(
            find.descendant(
              of: tableFinder,
              matching: find.byWidgetPredicate((widget) => widget is Table),
            ),
          );
          final sourceIndex = summary.slots.indexWhere(
            (slot) => slot.timeUtc == slots[targetIndex].timeUtc,
          );
          final cells = table.children[sourceIndex + 1].children;
          final values = [
            for (final cell in cells)
              t
                  .widget<Text>(
                    find.descendant(
                      of: find.byWidget(cell),
                      matching: find.byType(Text),
                    ),
                  )
                  .data!,
          ];
          expect(
            values,
            hasLength(9),
            reason: 'pinned date plus every weather column',
          );
          expect(
            values.first,
            after,
            reason: 'graph selection and exact table read the same UTC instant',
          );
          expect(
            values[1],
            'Unknown',
            reason: 'that exact selected cloud gap remains missing, never 0',
          );
          expect(find.byKey(const Key('weather.tableKey')), findsOneWidget);
          expect(
            t.widget<Text>(find.byKey(const Key('weather.selectedTime'))).data,
            after,
          );
          await t.ensureVisible(
            find.byKey(const Key('weather.resetSelection')),
          );
          await hybridSettle(t);
          await t.tap(find.byKey(const Key('weather.resetSelection')));
          await hybridSettle(t);
          expect(
            find.byKey(const Key('weather.selectionControls')),
            findsNothing,
          );
          expect(find.byKey(const Key('weather.selectedTime')), findsNothing);
          for (final name in _metrics) {
            expect(find.byKey(Key('weather.cursor.$name')), findsNothing);
            expect(
              _texts(find.byKey(Key('weather.chartHeader.$name'))).join(' '),
              contains('Dark time:'),
            );
          }
          expect(scoped.nightWeatherSummary, same(originalSummary));
          // Dispose and recreate the chart after a nonzero scroll offset.
          await t.runAsync(
            () => f.vm.vms.displaySettings.setWeatherView(WeatherView.rows),
          );
          await t.pump();
          await t.runAsync(
            () => f.vm.vms.displaySettings.setWeatherView(WeatherView.charts),
          );
          await t.pump();
          expect(t.takeException(), isNull);
        },
      );
    }
  }
  for (final scale in [1.0, 2.0]) {
    for (final hour in [3, 6]) {
      testWidgets(
        'G2 selected $hour hour is visible and truthful at $scale text',
        (t) async {
          final f = await _app(t, theme: 'dark');
          t.platformDispatcher.textScaleFactorTestValue = scale;
          t.view.physicalSize = Size(375, scale == 1 ? 2600 : 4000);
          await t.runAsync(
            () => f.vm.vms.displaySettings.setWeatherView(WeatherView.charts),
          );
          await HybridRenderContext(t, f).push(AppRouter.weather);
          await hybridSettle(t);
          final scoped = t
              .element(find.byType(HybridWeatherView))
              .read<NightConditionsViewModel>();
          final slots = [
            for (final slot in scoped.nightWeatherSummary!.slots)
              if (slot.instant || slot.preceding) slot,
          ];
          final index = slots.indexWhere(
            (slot) =>
                NightTimeFormatter.wallClock(
                  slot.timeUtc,
                  zoneId: f.vm.site.displayZoneId,
                ).hour ==
                hour,
          );
          expect(index, greaterThanOrEqualTo(0));
          final cloud = find.byKey(const Key('weather.chart.Cloud cover'));
          await t.ensureVisible(cloud);
          await hybridSettle(t);
          final rect = t.getRect(cloud);
          await t.tapAt(
            Offset(
              rect.left + 24 + (index + .5) / slots.length * (rect.width - 24),
              rect.center.dy,
            ),
          );
          await hybridSettle(t);
          final controls = find.byKey(const Key('weather.selectionControls'));
          expect(controls, findsOneWidget);
          expect(t.getRect(controls).left, greaterThanOrEqualTo(0));
          expect(t.getRect(controls).right, lessThanOrEqualTo(375));
          for (final key in [
            'weather.previousHour',
            'weather.nextHour',
            'weather.resetSelection',
          ]) {
            final bounds = t.getRect(find.byKey(Key(key)));
            expect(bounds.height, greaterThanOrEqualTo(48));
            expect(bounds.left, greaterThanOrEqualTo(0));
            expect(bounds.right, lessThanOrEqualTo(375));
          }
          for (final name in _metrics) {
            expect(find.byKey(Key('weather.cursor.$name')), findsOneWidget);
          }
          final selectedCloud = t
              .widget<Text>(
                find.byKey(const Key('weather.chartValue.Cloud cover')),
              )
              .data;
          if (hour == 3) {
            expect(slots[index].instant, isTrue);
            expect(
              selectedCloud,
              QuantityText.percent(slots[index].hour!.cloudCoverPct!),
            );
          } else {
            expect(slots[index].instant, isFalse);
            expect(selectedCloud, 'Outside dark span');
            expect(slots[index].preceding, isTrue);
            expect(
              t
                  .widget<Text>(
                    find.byKey(
                      const Key('weather.chartValue.Precipitation probability'),
                    ),
                  )
                  .data,
              QuantityText.percent(
                slots[index].hour!.precipitationProbabilityPct!,
              ),
            );
          }
          expect(t.takeException(), isNull);
          final output =
              Platform.environment['CULMINA_WEATHER_SELECTION_RENDERS'];
          if (output != null) {
            await t.runAsync(() async {
              final boundary = t.renderObject<RenderRepaintBoundary>(
                find.byKey(_shot),
              );
              final image = await boundary.toImage(pixelRatio: 1);
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              Directory(output).createSync(recursive: true);
              File(
                '$output/selected-${hour.toString().padLeft(2, '0')}-dark-${scale.toInt()}.png',
              ).writeAsBytesSync(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
        },
      );
    }
  }
  for (final theme in _variants) {
    testWidgets(
      'Q3 Weather cached malformed cue is neutral and recovers $theme',
      (t) async {
        final f = await _app(t, theme: theme);
        await HybridRenderContext(t, f).push(AppRouter.weather);
        await hybridSettle(t);
        final scoped = t
            .element(find.byType(HybridWeatherView))
            .read<NightConditionsViewModel>();
        final range = find.byKey(const Key('weather.range.Wind / gusts'));
        final values = _texts(find.byKey(const Key('weather.statisticsGroup')));
        expect(range, findsOneWidget);
        f.forecast.failure = WeatherFailure.malformed;
        await t.runAsync(scoped.refreshWeather);
        await hybridSettle(t);
        final cue = t
            .widget<Text>(find.byKey(const Key('weather.refreshFailed')))
            .data!;
        expect(cue, startsWith('Refresh failed · cached forecast.'));
        expect(cue, contains('could not be read'));
        expect(cue, isNot(contains('Offline')));
        expect(
          _texts(find.byKey(const Key('weather.statisticsGroup'))),
          values,
        );
        f.forecast.failure = null;
        await t.runAsync(scoped.refreshWeather);
        await hybridSettle(t);
        expect(find.byKey(const Key('weather.refreshFailed')), findsNothing);
        expect(t.takeException(), isNull);
      },
    );
  }
  testWidgets('Q2 Retry saves visible newer draft and stays open', (t) async {
    final store = _RecoverablePreferences();
    final vm = await _planning(t, store);
    _perFrame(t).onChanged!(15);
    await t.pump();
    await t.tap(find.byKey(const Key('settings.savePlanning')));
    await _flush(t);
    expect(vm.planningPreferencesUnsaved, isTrue);
    expect(store.stored.perFrameOverheadSeconds, 5);
    _perFrame(t).onChanged!(20);
    await t.pump();
    store.fail = false;
    await t.ensureVisible(find.byKey(const Key('settings.retry')));
    await t.tap(find.byKey(const Key('settings.retry')));
    await _flush(t);
    expect(store.attempted, [15, 20]);
    expect(store.stored.perFrameOverheadSeconds, 20);
    expect(vm.planningPreferences.perFrameOverheadSeconds, 20);
    expect(_perFrame(t).value, 20);
    expect(find.byKey(const Key('settings.unsaved')), findsNothing);
    expect(find.text('No changes'), findsOneWidget);
    await t.pageBack();
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('settings.open.planning')));
    await t.pumpAndSettle();
    expect(_perFrame(t).value, 20);
    _perFrame(t).onChanged!(25);
    await t.pump();
    await t.tap(find.byKey(const Key('settings.cancelPlanning')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('confirm.action')));
    await t.pumpAndSettle();
    expect(store.stored.perFrameOverheadSeconds, 20);
    expect(vm.planningPreferences.perFrameOverheadSeconds, 20);
  });
  testWidgets(
    'Q2 failed Retry keeps newest visible draft applied and unsaved',
    (t) async {
      final store = _RecoverablePreferences();
      final vm = await _planning(t, store);
      _perFrame(t).onChanged!(15);
      await t.pump();
      await t.tap(find.byKey(const Key('settings.savePlanning')));
      await _flush(t);
      _perFrame(t).onChanged!(20);
      await t.pump();
      await t.ensureVisible(find.byKey(const Key('settings.retry')));
      await t.tap(find.byKey(const Key('settings.retry')));
      await _flush(t);
      expect(store.attempted, [15, 20]);
      expect(store.stored.perFrameOverheadSeconds, 5);
      expect(vm.planningPreferences.perFrameOverheadSeconds, 20);
      expect(_perFrame(t).value, 20);
      expect(vm.planningPreferencesUnsaved, isTrue);
      store.fail = false;
      await t.tap(find.byKey(const Key('settings.retry')));
      await _flush(t);
      expect(store.attempted, [15, 20, 20]);
      expect(store.stored.perFrameOverheadSeconds, 20);
      expect(vm.planningPreferencesUnsaved, isFalse);
      expect(t.takeException(), isNull);
    },
  );
  for (final field in [true, false]) {
    for (final newer in [true, false]) {
      testWidgets(
        'Q3 recovery preserves ${field ? 'Field' : 'forced Dark'} system Light newer$newer',
        (t) async {
          await _setup(t);
          t.platformDispatcher.platformBrightnessTestValue = Brightness.light;
          var resetCalls = 0;
          await t.pumpWidget(
            RepaintBoundary(
              key: _shot,
              child: UnsupportedDatabaseApp(
                newerThanApp: newer,
                foundVersion: newer ? 99 : 1,
                isFieldMode: field,
                themeMode: field ? ThemeMode.system : ThemeMode.dark,
                onReset: () async {
                  resetCalls++;
                },
              ),
            ),
          );
          await t.pumpAndSettle();
          final context = t.element(find.byType(UnsupportedDatabaseScreen));
          expect(Theme.of(context).brightness, Brightness.dark);
          final filters = find.descendant(
            of: find.byType(UnsupportedDatabaseApp),
            matching: find.byType(ColorFiltered),
          );
          expect(filters, field ? findsOneWidget : findsNothing);
          expect(
            Theme.of(context).scaffoldBackgroundColor,
            field
                ? AppTheme.fieldTheme.scaffoldBackgroundColor
                : AppTheme.dark.scaffoldBackgroundColor,
          );
          if (newer) {
            expect(find.byKey(const Key('unsupportedDb.reset')), findsNothing);
          } else {
            await t.tap(find.byKey(const Key('unsupportedDb.reset')));
            await t.pumpAndSettle();
            expect(find.byType(AlertDialog), findsOneWidget);
            if (field) {
              expect(
                find.ancestor(
                  of: find.byType(AlertDialog),
                  matching: find.byType(ColorFiltered),
                ),
                findsOneWidget,
              );
            }
            expect(
              Theme.of(t.element(find.byType(AlertDialog))).brightness,
              Brightness.dark,
            );
            await t.tap(find.text('Cancel'));
            await t.pumpAndSettle();
          }
          expect(resetCalls, 0);
          expect(t.takeException(), isNull);
        },
      );
    }
  }
  testWidgets('Q6 Settings named terminal boundaries preserve sibling rules', (
    t,
  ) async {
    final f = await _app(t);
    final c = HybridRenderContext(t, f);
    await c.go(AppRouter.settings);
    expect(
      t
          .widget<SettingsRow>(
            find.byKey(const Key('settings.open.appearance')),
          )
          .divider,
      isTrue,
    );
    expect(
      t
          .widget<SettingsRow>(find.byKey(const Key('settings.open.planning')))
          .divider,
      isTrue,
    );
    expect(
      t
          .widget<SettingsRow>(find.byKey(const Key('settings.open.privacy')))
          .divider,
      isFalse,
    );
    await c.tap(find.byKey(const Key('settings.open.privacy')));
    expect(
      t
          .widget<HybridSwitchRow>(find.byKey(const Key('settings.placeNames')))
          .divider,
      isFalse,
    );
    expect(
      t
          .widget<CollapsibleSection>(
            find.byKey(const Key('settings.privacyApp')),
          )
          .topRule,
      isFalse,
    );
    await c.go(AppRouter.settings);
    await c.tap(find.byKey(const Key('settings.open.appearance')));
    expect(
      t.widget<FieldModeTile>(find.byType(FieldModeTile)).divider,
      isFalse,
    );
    expect(t.takeException(), isNull);
  });
}
