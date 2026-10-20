import 'dart:async';

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
      phase: MoonPhaseName.waxingGibbous,
      illumination: .82,
      phaseLongitudeDeg: 130,
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
  }) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: browser,
        child: MaterialApp(
          theme: theme ?? AppTheme.light,
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(412, 915),
              textScaler: TextScaler.linear(scale),
            ),
            child: const Scaffold(
              body: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: MoonCalendarSection(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final (name, theme) in [
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
    ('field', AppTheme.fieldTheme),
  ]) {
    testWidgets('$name month uses hours/minutes and selected Hybrid fill', (
      tester,
    ) async {
      await show(tester, theme: theme);
      expect(find.text('Moon calendar'), findsOneWidget);
      expect(
        tester.getCenter(find.text('Moon calendar')).dy,
        closeTo(
          tester.getCenter(find.byKey(const Key('nightMoon.prevMonth'))).dy,
          0.1,
        ),
        reason: 'The normal-scale heading and month controls share one row.',
      );
      expect(find.text('10 h 55 min'), findsWidgets);
      expect(find.text('10.9 h'), findsNothing);
      expect(find.text('0 min'), findsOneWidget);
      expect(find.text('no dark'), findsOneWidget);
      final day = find.byKey(const Key('nightMoon.day.2026-12-30'));
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
