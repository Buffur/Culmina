import 'dart:io';

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/core/theme/hybrid_tokens.dart';
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
        'Q5 pinned chart headers and one shared hour offset $width $theme',
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
          final chart = find.byKey(const Key('weather.chartScroll'));
          final scrollables = find.descendant(
            of: chart,
            matching: find.byType(Scrollable),
          );
          expect(
            scrollables,
            findsOneWidget,
            reason: 'all plots and repeated axes share one physical scroll position',
          );
          final position = t.state<ScrollableState>(scrollables).position;
          final page = t
              .state<ScrollableState>(
                find
                    .ancestor(
                      of: find.byKey(const Key('weather.summaryGroup')),
                      matching: find.byType(Scrollable),
                    )
                    .first,
              )
              .position;
          final heading = find.byKey(
            const Key('weather.chartHeader.Temperature'),
          );
          page.jumpTo(page.pixels + t.getTopLeft(heading).dy - 180);
          await hybridSettle(t);
          final viewport = t.getRect(chart);
          final headerRects = <String, Rect>{};
          final headerTexts = <String, List<String>>{};
          for (final name in _metrics) {
            final key = find.byKey(Key('weather.chartHeader.$name'));
            headerRects[name] = t.getRect(key);
            headerTexts[name] = _texts(key);
          }
          final hourZero = t
              .widget<Text>(
                find.descendant(
                  of: find.byKey(const Key('weather.hour.0')),
                  matching: find.byType(Text),
                ),
              )
              .data!;
          final repeated = find.descendant(
            of: chart,
            matching: find.text(hourZero),
          );
          final hourXs = [
            for (final element in repeated.evaluate())
              (element.renderObject as RenderBox).localToGlobal(Offset.zero).dx,
          ];
          expect(hourXs.length, greaterThanOrEqualTo(5));
          await t.drag(
            find.byKey(const Key('weather.hour.0')),
            const Offset(-400, 0),
          );
          await hybridSettle(t);
          expect(position.pixels, greaterThan(0));
          for (final name in _metrics) {
            final key = find.byKey(Key('weather.chartHeader.$name'));
            final rect = t.getRect(key);
            expect(
              rect.left,
              closeTo(headerRects[name]!.left, 0.5),
              reason: '$name stays pinned',
            );
            expect(rect.right, lessThanOrEqualTo(viewport.right + 0.5));
            expect(rect.left, greaterThanOrEqualTo(viewport.left - 0.5));
            expect(
              _texts(key),
              headerTexts[name],
              reason: 'same values, units, coverage and independent scale',
            );
          }
          final afterXs = [
            for (final element in repeated.evaluate())
              (element.renderObject as RenderBox).localToGlobal(Offset.zero).dx,
          ];
          expect(afterXs.length, hourXs.length);
          for (var i = 0; i < hourXs.length; i++) {
            expect(
              afterXs[i] - hourXs[i],
              closeTo(-position.pixels, 0.5),
              reason: 'time axis $i shares chart offset',
            );
          }
          expect(scoped.nightWeatherSummary, same(originalSummary));
          if (width == 375) {
            // A wider viewport clamps the same controller's old end offset.
            // Pinning must remain correct after content-dimension corrections.
            t.view.physicalSize = const Size(412, 812);
            await hybridSettle(t);
            final resizedViewport = t.getRect(chart);
            for (final name in _metrics) {
              final rect = t.getRect(
                find.byKey(Key('weather.chartHeader.$name')),
              );
              expect(
                rect.left,
                closeTo(resizedViewport.left, 0.5),
                reason: '$name remains pinned after375->412 viewport clamp',
              );
            }
          }
          final slots = [
            for (final slot in summary.slots)
              if (slot.instant || slot.preceding) slot,
          ];
          final last = slots.length - 1;
          final target = find.byKey(Key('weather.hour.$last'));
          final labelBefore = t
              .widget<Text>(find.byKey(const Key('weather.hourLabel')))
              .data;
          await t.tap(target);
          await t.pump();
          expect(
            t.widget<Text>(find.byKey(const Key('weather.hourLabel'))).data,
            isNot(labelBefore),
          );
          final cell = t.widget<Container>(
            find.descendant(of: target, matching: find.byType(Container)),
          );
          final tokens = Theme.of(t.element(target)).extension<HybridTokens>()!;
          expect(
            (cell.decoration! as BoxDecoration).color,
            tokens.selectedHourFill,
          );
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
