import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/core/theme/hybrid_tokens.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/moon_conditions.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/site_time_context.dart';
import 'package:astroplan/domain/services/moon_calendar.dart';
import 'package:astroplan/presentation/viewmodels/night_browser_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/session_plan_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/settings_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/site_viewmodel.dart';
import 'package:astroplan/presentation/widgets/night_browser_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _Site extends ChangeNotifier implements SiteViewModel {
  @override
  double get latitude => 46;
  @override
  double get longitude => 14;
  @override
  SiteTimeContext get timeContext => MeanSolarTimeContext(longitude);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Plan extends ChangeNotifier implements SessionPlanViewModel {
  @override
  CalendarDate get eveningDate => CalendarDate(2026, 12, 30);
  @override
  CalendarDate get tonightKey => eveningDate;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Settings extends ChangeNotifier implements SettingsViewModel {
  @override
  PlanningPreferences get planningPreferences => PlanningPreferences();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

List<MoonCalendarDay> _days(MoonCalendarRequest request) => [
  for (
    var day = 1;
    day <= DateTime.utc(request.year, request.month + 1, 0).day;
    day++
  )
    MoonCalendarDay(
      date: CalendarDate(request.year, request.month, day),
      phase: day == 4 ? null : MoonPhaseName.waxingGibbous,
      illumination: .82,
      phaseLongitudeDeg: day == 4 ? null : 130,
      moonFree: MoonFreeNight(
        kind: day == 2
            ? MoonFreeKind.none
            : day == 3
            ? MoonFreeKind.noDark
            : MoonFreeKind.allNight,
        intervals: const [],
        moonFree: day == 2 || day == 3
            ? Duration.zero
            : const Duration(hours: 10, minutes: 55),
        dark: const Duration(hours: 12),
      ),
    ),
];

void main() {
  late _Site site;
  late _Plan plan;
  late _Settings settings;
  late NightBrowserViewModel browser;
  final calls = <(int, int), int>{};

  setUp(() {
    site = _Site();
    plan = _Plan();
    settings = _Settings();
    calls.clear();
    browser = NightBrowserViewModel(
      site: site,
      plan: plan,
      settings: settings,
      nowUtc: () => DateTime.utc(2026, 12, 30),
      computeMonth: (request) async {
        final key = (request.year, request.month);
        calls[key] = (calls[key] ?? 0) + 1;
        return _days(request);
      },
    );
  });
  tearDown(() {
    browser.dispose();
    site.dispose();
    plan.dispose();
    settings.dispose();
  });

  Future<void> show(
    WidgetTester tester, {
    double scale = 1,
    ThemeData? theme,
    double width = 412,
    bool settle = true,
  }) async {
    tester.view.physicalSize = Size(width, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: browser,
        child: RepaintBoundary(
          key: const Key('phase2.calendar.capture'),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme ?? AppTheme.light,
            builder: (context, child) => theme == AppTheme.fieldTheme
                ? ColorFiltered(
                    colorFilter: AppTheme.fieldFilter,
                    child: child!,
                  )
                : child!,
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(width, 915),
                textScaler: TextScaler.linear(scale),
              ),
              child: const Scaffold(
                body: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 19.5, vertical: 20),
                  child: MoonCalendarSection(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  for (final (name, theme) in [
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
    ('field', AppTheme.fieldTheme),
  ]) {
    testWidgets('$name month uses hours/minutes and selected Hybrid fill', (
      tester,
    ) async {
      // The test font's square glyphs make "Moon calendar" (20 px) and
      // "December 2026" far wider than the app's fonts, which share one row
      // at 412 px (host render evidence); 600 px gives the test font that
      // room, so the row rule is still checked.
      await show(tester, theme: theme, width: 600);
      expect(find.text('Moon calendar'), findsOneWidget);
      expect(
        tester.getCenter(find.text('Moon calendar')).dy,
        closeTo(
          tester.getCenter(find.byKey(const Key('nightMoon.prevMonth'))).dy,
          0.1,
        ),
        reason: 'The normal-scale heading and month controls share one row.',
      );
      expect(find.text('10h55m'), findsWidgets);
      expect(find.text('10.9 h'), findsNothing);
      expect(find.text('0m'), findsOneWidget);
      expect(find.text('no dark'), findsOneWidget);
      final day = find.byKey(const Key('nightMoon.day.2026-12-30'));
      final semantics = tester.ensureSemantics();
      expect(
        tester.getSemantics(day).label,
        contains('moon-free dark 10 h 55 min'),
      );
      semantics.dispose();
      final decoration =
          tester
                  .widget<Container>(
                    find
                        .descendant(of: day, matching: find.byType(Container))
                        .first,
                  )
                  .decoration!
              as BoxDecoration;
      expect(decoration.color, theme.extension<HybridTokens>()!.selection);
      expect(decoration.borderRadius, BorderRadius.circular(6));
      expect(tester.takeException(), isNull);
    });
  }

  for (final (mode, theme) in [
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
    ('field', AppTheme.fieldTheme),
  ]) {
    for (final state in ['month', 'loading', 'error', 'week']) {
      testWidgets('Phase2 calendar $state $mode', (tester) async {
        await (FontLoader(
          'Geist',
        )..addFont(rootBundle.load('assets/fonts/Geist.ttf'))).load();
        Completer<List<MoonCalendarDay>>? pending;
        if (state == 'loading' || state == 'error') {
          browser.dispose();
          pending = Completer<List<MoonCalendarDay>>();
          browser = NightBrowserViewModel(
            site: site,
            plan: plan,
            settings: settings,
            nowUtc: () => DateTime.utc(2026, 12, 30),
            computeMonth: (_) => pending!.future,
          );
          expect(browser.monthDays, isNull);
          if (state == 'error') {
            await tester.runAsync(() async {
              pending!.completeError(StateError('fixture compute failure'));
              await browser.idle;
            });
          }
        }
        await show(
          tester,
          theme: theme,
          width: 375,
          scale: state == 'week' ? 2 : 1,
          settle: state != 'loading',
        );
        if (state == 'month') {
          final semantics = tester.ensureSemantics();
          expect(
            tester
                .getSemantics(find.byKey(const Key('nightMoon.day.2026-12-04')))
                .label,
            contains('phase unknown'),
          );
          semantics.dispose();
        }
        if (state == 'loading') {
          expect(
            find.byKey(const Key('nightMoon.calendarLoading')),
            findsOneWidget,
          );
        } else if (state == 'error') {
          expect(
            find.byKey(const Key('nightMoon.calendarError')),
            findsOneWidget,
          );
          expect(find.text('Retry month'), findsOneWidget);
        } else {
          expect(
            find.byKey(const Key('nightMoon.day.2026-12-30')),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('nightMoon.nextWeek')),
            state == 'week' ? findsOneWidget : findsNothing,
          );
        }
        final output = Platform.environment['CULMINA_PHASE2_RENDERS'];
        if (output != null && output.isNotEmpty) {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const Key('phase2.calendar.capture')),
          );
          await tester.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: 1);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File('$output/package1/calendar-$state-$mode.png');
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        if (state == 'loading') {
          await tester.runAsync(() async {
            pending!.complete(const []);
            await browser.idle;
          });
        }
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final (mode, theme) in [
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
    ('field', AppTheme.fieldTheme),
  ]) {
    testWidgets('Phase2 calendar adjacent week loading failure retry $mode', (
      tester,
    ) async {
      browser.dispose();
      final pending = Completer<List<MoonCalendarDay>>();
      var januaryRequests = 0;
      browser = NightBrowserViewModel(
        site: site,
        plan: plan,
        settings: settings,
        nowUtc: () => DateTime.utc(2026, 12, 30),
        computeMonth: (request) {
          if (request.month == 12) return Future.value(_days(request));
          januaryRequests++;
          return januaryRequests == 1
              ? pending.future
              : Future.value(_days(request));
        },
      );
      await (FontLoader(
        'Geist',
      )..addFont(rootBundle.load('assets/fonts/Geist.ttf'))).load();
      await show(tester, theme: theme, width: 375, scale: 2, settle: false);
      await tester.pump();
      expect(find.byKey(const Key('nightMoon.weekLoading')), findsOneWidget);
      Future<void> capture(String state) async {
        final output = Platform.environment['CULMINA_PHASE2_RENDERS'];
        if (output == null || output.isEmpty) return;
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const Key('phase2.calendar.capture')),
        );
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File('$output/package1/calendar-$state-$mode.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      await capture('week-loading');
      await tester.runAsync(() async {
        pending.completeError(StateError('adjacent month fixture failure'));
        await browser.idle;
      });
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('nightMoon.weekError')), findsOneWidget);
      expect(find.text('Retry week'), findsOneWidget);
      expect(januaryRequests, 1, reason: 'no rebuild retry loop');
      await capture('week-error');
      await tester.ensureVisible(find.text('Retry week'));
      await tester.tap(find.text('Retry week'));
      await tester.pumpAndSettle();
      expect(januaryRequests, 2);
      expect(find.byKey(const Key('nightMoon.weekError')), findsNothing);
      expect(find.byKey(const Key('nightMoon.day.2027-01-03')), findsOneWidget);
      expect(
        browser.viewedDate,
        plan.eveningDate,
        reason: 'retry never adopts a night',
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('200% week navigation crosses year boundary without adoption', (
    tester,
  ) async {
    await show(tester, scale: 2);
    expect(find.byKey(const Key('nightMoon.month')), findsNothing);
    for (final date in ['2026-12-28', '2026-12-30', '2027-01-03']) {
      expect(find.byKey(Key('nightMoon.day.$date')), findsOneWidget);
    }
    expect(calls[(2026, 12)], 1);
    expect(calls[(2027, 1)], 1);
    await tester.tap(find.byKey(const Key('nightMoon.nextWeek')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('nightMoon.day.2027-01-04')), findsOneWidget);
    expect(find.byKey(const Key('nightMoon.day.2027-01-10')), findsOneWidget);
    expect(browser.viewedDate, CalendarDate(2026, 12, 30));
    expect(plan.eveningDate, CalendarDate(2026, 12, 30));
    await tester.tap(find.byKey(const Key('nightMoon.prevWeek')));
    await tester.pumpAndSettle();
    final january = find.byKey(const Key('nightMoon.day.2027-01-02'));
    await tester.ensureVisible(january);
    await tester.tap(january);
    await tester.pumpAndSettle();
    expect(browser.viewedDate, CalendarDate(2027, 1, 2));
    expect(plan.eveningDate, CalendarDate(2026, 12, 30));
    expect(calls[(2026, 12)], 1);
    expect(calls[(2027, 1)], 1);
    expect(tester.takeException(), isNull);
  });

  test(
    'adjacent requests deduplicate and failures stay scoped until retry',
    () async {
      browser.dispose();
      final december = Completer<List<MoonCalendarDay>>();
      var attempts = 0;
      browser = NightBrowserViewModel(
        site: site,
        plan: plan,
        settings: settings,
        nowUtc: () => DateTime.utc(2026, 12, 30),
        computeMonth: (request) {
          if (request.month == 12) return december.future;
          attempts++;
          return attempts == 1
              ? Future.error(StateError('temporary month failure'))
              : Future.value(_days(request));
        },
      );
      expect(browser.monthDays, isNull);
      expect(browser.calendarDays(2026, 12), isNull);
      browser.calendarDays(2027, 1);
      await Future<void>.delayed(Duration.zero);
      expect(browser.monthError, isNull);
      expect(browser.calendarError(2027, 1), isA<StateError>());
      browser.calendarDays(2027, 1);
      expect(
        attempts,
        1,
        reason: 'rebuilds do not retry failed work in a loop',
      );
      browser.retryCalendar(2027, 1);
      december.complete(const []);
      await browser.idle;
      expect(browser.calendarError(2027, 1), isNull);
      expect(browser.calendarDays(2027, 1), hasLength(31));
      expect(attempts, 2);
      expect(browser.month, (2026, 12));
      expect(plan.eveningDate, CalendarDate(2026, 12, 30));
    },
  );
}
