import 'dart:async';
import 'dart:ui' as ui;

import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/services/moon_calendar.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/screens/details/night_moon_screen.dart';
import 'package:astroplan/presentation/viewmodels/night_browser_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../support/fake_capture_file_access.dart';
import '../../support/hybrid_transfer_shots.dart';
import '../../support/tiff_fixture.dart';
import '../../support/wave1_capture.dart';
import '../../support/wave2_fixture.dart';
import '../../support/wave3_focus.dart';
import '../../support/wave3_ink.dart';

Future<void> _planner(WidgetTester t) async {
  await t.tap(find.byKey(const Key('tonight.openPlanner')));
  await hybridSettle(t);
}

Finder _headerInk(Finder header) =>
    find.descendant(of: header, matching: find.byType(InkWell)).first;
Finder _caption(Finder header) =>
    find.descendant(of: header, matching: find.byType(Text)).last;

Future<void> _pushNight(
  WidgetTester t, {
  int page = 0,
  MonthComputer? compute,
}) async {
  unawaited(
    Navigator.of(t.element(find.byKey(const Key('tonight.openPlanner'))))
        .push<void>(
          MaterialPageRoute(
            builder: (_) =>
                NightMoonScreen(initialPage: page, computeMonth: compute),
          ),
        ),
  );
  await hybridSettle(t);
}

Future<Map<String, Object?>> _graph(Wave2Fixture f) async => {
  for (final table in [
    'session_logs',
    'capture_blocks',
    'session_events',
    'devices',
    'camera_modules',
    'optical_rigs',
  ])
    table: (await f.db.customSelect('SELECT * FROM $table ORDER BY id').get())
        .map((r) => r.data)
        .toList(),
};

void main() {
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    testWidgets('UIA-0013 C03 $theme: selected hourly time held ink', (
      t,
    ) async {
      final f = await mountWave2(t, theme);
      await _planner(t);
      final weather = find.byKey(const Key('planner.weather'));
      await revealWave2(t, weather);
      await t.tap(weather);
      await hybridSettle(t);
      final label = find.byKey(const Key('weather.hourLabel'));
      await revealWave2(t, label);
      final header = find
          .ancestor(of: label, matching: find.byType(InkWell))
          .first;
      final before = f.vm.plan.activeSession!;
      await wave3HeldContrast(t, header, label, 'wave3-C03-$theme-held', theme);
      expect(f.vm.plan.activeSessionId, before.id);
      expect(
        f.vm.plan.activeSession!.planSnapshot!.json,
        before.planSnapshot!.json,
      );
    });

    testWidgets('UIA-0013 C04 $theme: Progress guide held ink', (t) async {
      final f = await mountWave2(t, theme);
      await t.runAsync(f.seed.seedLogbook);
      AppRouter.router.go(AppRouter.logbookProgress);
      await hybridSettle(t);
      final guide = find.byKey(const Key('section.logbook.progressGuide'));
      await revealWave2(t, guide);
      await wave3HeldContrast(
        t,
        _headerInk(guide),
        _caption(guide),
        'wave3-C04-$theme-held',
        theme,
      );
    });

    testWidgets('UIA-0013 C05-C10 $theme: Night/Moon caller feedback', (
      t,
    ) async {
      final f = await mountWave2(t, theme);
      final saved = f.vm.plan.activeSession!;
      await _pushNight(t);
      for (final (id, section) in [
        ('C06', 'reading'),
        ('C07', 'moonIntervals'),
        ('C08', 'sun'),
      ]) {
        final header = find.byKey(Key('section.conditions.$section'));
        await revealWave2(t, header);
        await wave3HeldContrast(
          t,
          _headerInk(header),
          _caption(header),
          'wave3-$id-$theme-held',
          theme,
        );
      }
      await t.tap(find.widgetWithText(Tab, 'Moon'));
      await hybridSettle(t);
      final preview = find.byKey(const Key('nightMoon.previewMoon'));
      await revealWave2(t, preview);
      await wave3HeldContrast(
        t,
        preview,
        find.descendant(
          of: preview,
          matching: find.text('Preview Moon through the night'),
        ),
        'wave3-C05-$theme-held',
        theme,
      );
      for (final (id, section) in [
        ('C09', 'reading'),
        ('C10', 'moonDetails'),
      ]) {
        final header = find.byKey(Key('section.conditions.$section'));
        await revealWave2(t, header);
        await wave3HeldContrast(
          t,
          _headerInk(header),
          _caption(header),
          'wave3-$id-$theme-held',
          theme,
        );
      }
      expect(f.vm.plan.activeSessionId, saved.id);
      expect(
        f.vm.plan.activeSession!.planSnapshot!.json,
        saved.planSnapshot!.json,
      );
    });

    testWidgets(
      'UIA-0013 C11 $theme: stored-entry Undo held then actual restore',
      (t) async {
        final f = await mountWave2(t, theme);
        await t.runAsync(f.seed.seedLogbook);
        final before = await t.runAsync(() => _graph(f));
        final count = (await t.runAsync(f.seed.sessions.list))!.length;
        AppRouter.router.go(AppRouter.sessions);
        await hybridSettle(t);
        final id = f.seed.logbookIds['M31 2026-10-12']!;
        unawaited(AppRouter.router.push(AppRouter.sessionDetail(id)));
        await hybridSettle(t);
        final delete = find.byKey(const Key('detail.delete'));
        await revealWave2(t, delete);
        await t.tap(delete);
        await hybridSettle(t);
        await t.tap(find.byKey(const Key('confirm.action')));
        await hybridSettle(t);
        final undo = find.widgetWithText(TextButton, 'Undo');
        await wave3TabTo(t, undo);
        await wave3FocusContrast(
          t,
          find.text('Undo'),
          'wave3-C11-$theme-focus',
          theme,
        );
        await wave3HeldContrast(
          t,
          undo,
          find.text('Undo'),
          'wave3-C11-$theme-mouse-held',
          theme,
          kind: ui.PointerDeviceKind.mouse,
        );
        expect((await t.runAsync(f.seed.sessions.list))!.length, count - 1);
        await t.tap(undo);
        await hybridSettle(t);
        expect(await t.runAsync(() => _graph(f)), before);
        expect((await t.runAsync(f.seed.sessions.list))!.length, count);
      },
    );

    testWidgets(
      'UIA-0013 C12-C15 $theme: real month/week branches and Retry ink',
      (t) async {
        final f = await mountWave2(t, theme);
        var fail = false;
        var requests = 0;
        Future<List<MoonCalendarDay>> compute(
          MoonCalendarRequest request,
        ) async {
          requests++;
          if (fail) throw StateError('synthetic month refusal');
          return MoonCalendar.compute(request);
        }

        await _pushNight(t, page: 1, compute: compute);
        final calendar = find.byKey(const Key('nightMoon.calendar'));
        await revealWave2(t, calendar);
        final browser = t.element(calendar).read<NightBrowserViewModel>();
        expect(find.byKey(const Key('nightMoon.month')), findsOneWidget);
        final date = CalendarDate(2026, 10, 1);
        final day = find.byKey(Key('nightMoon.day.${date.toIso8601String()}'));
        await revealWave2(t, day);
        final duration = find.descendant(of: day, matching: find.text('5 min'));
        expect(duration, findsOneWidget);
        await wave3HeldContrast(
          t,
          day,
          duration,
          'wave3-C12-$theme-held',
          theme,
        );
        final selected = find.byKey(const Key('nightMoon.day.2026-10-19'));
        await revealWave2(t, selected);
        await captureWave1(t, 'wave3-C12-$theme-selected');
        fail = true;
        final next = find.byKey(const Key('nightMoon.nextMonth'));
        await revealWave2(t, next);
        await t.tap(next);
        await hybridSettle(t);
        final monthRetry = find.widgetWithText(TextButton, 'Retry month');
        await revealWave2(t, monthRetry);
        final beforeRetry = requests;
        await wave3HeldContrast(
          t,
          monthRetry,
          find.text('Retry month'),
          'wave3-C13-$theme-held',
          theme,
        );
        expect(requests, beforeRetry);
        fail = false;
        await t.tap(monthRetry);
        await hybridSettle(t);
        expect(monthRetry, findsNothing);
        expect(browser.viewedDate, CalendarDate(2026, 10, 19));
        Navigator.of(t.element(calendar)).pop();
        await hybridSettle(t);
        t.view.physicalSize = Size(
          320 * t.view.devicePixelRatio,
          812 * t.view.devicePixelRatio,
        );
        await t.binding.setSurfaceSize(const Size(320, 812));
        addTearDown(() => t.binding.setSurfaceSize(null));
        addTearDown(t.view.reset);
        fail = false;
        await _pushNight(t, page: 1, compute: compute);
        expect(find.byKey(const Key('nightMoon.week')), findsOneWidget);
        fail = true;
        final nextWeek = find.byKey(const Key('nightMoon.nextWeek'));
        await revealWave2(t, nextWeek);
        await t.tap(nextWeek);
        await hybridSettle(t);
        final weekRetry = find.widgetWithText(TextButton, 'Retry week');
        await revealWave2(t, weekRetry);
        await wave3HeldContrast(
          t,
          weekRetry,
          find.text('Retry week'),
          'wave3-C14-$theme-held',
          theme,
        );
        fail = false;
        await t.tap(weekRetry);
        await hybridSettle(t);
        expect(find.byKey(const Key('nightMoon.week')), findsOneWidget);
        expect(weekRetry, findsNothing);
        final previousWeek = find.byKey(const Key('nightMoon.prevWeek'));
        await revealWave2(t, previousWeek);
        await t.tap(previousWeek);
        await hybridSettle(t);
        final weekDate = CalendarDate(2026, 10, 20);
        final row = find.byKey(
          Key('nightMoon.day.${weekDate.toIso8601String()}'),
        );
        await revealWave2(t, row);
        final label = find
            .descendant(of: row, matching: find.byType(Text))
            .first;
        expect(t.widget<Text>(label).data, startsWith('20 Oct:'));
        await wave3HeldContrast(t, row, label, 'wave3-C15-$theme-held', theme);
        expect(f.vm.eveningDate, CalendarDate(2026, 10, 19));
      },
    );

    testWidgets('UIA-0013 C17/C18 $theme: Storage Choose and Cancel held ink', (
      t,
    ) async {
      final files = FakeCaptureFileAccess();
      files.file(
        'Synthetic.dng',
        (TiffFixture()..ifd0.addAll(phoneStyleDngIfd0())).build().bytes,
        length: 24012345,
      );
      final f = await mountWave2(t, theme, captureFiles: files);
      final before = await t.runAsync(() => _graph(f));
      await _planner(t);
      final choose = find.byKey(const Key('capturePlan.chooseFile'));
      final budget = find.byKey(const Key('section.planner.budgetDetails'));
      await revealWave2(t, budget);
      await t.tap(budget);
      await hybridSettle(t);
      await revealWave2(t, choose);
      await wave3HeldContrast(
        t,
        choose,
        find.text('Choose one file'),
        'wave3-C17-$theme-mouse-held',
        theme,
        kind: ui.PointerDeviceKind.mouse,
      );
      expect(files.picks, 0);
      await t.tap(choose);
      await hybridSettle(t);
      expect(find.byKey(const Key('storageFile.use')), findsOneWidget);
      final cancel = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(TextButton, 'Cancel'),
      );
      final label = find.descendant(of: cancel, matching: find.text('Cancel'));
      await wave3HeldContrast(
        t,
        cancel,
        label,
        'wave3-C18-$theme-mouse-held',
        theme,
        kind: ui.PointerDeviceKind.mouse,
      );
      expect(await t.runAsync(() => _graph(f)), before);
      await t.tap(cancel);
      await hybridSettle(t);
      expect(find.byKey(const Key('storageFile.use')), findsNothing);
      expect(await t.runAsync(() => _graph(f)), before);
      expect(files.picks, 1);
    });
  }
}
