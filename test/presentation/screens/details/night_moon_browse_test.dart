// F15 A1/A2/A3/A5 (ADR-022 N10/N11; D9 A; AM-01 SP07/SP08): the Night &
// Moon detail opens on the plan's night with the shared bar and its time
// slider, and the month of Moon nights (computed in an isolate). Tapping a
// night only views it, labelled against the plan's; Back, a site change
// and a reopen change no plan, night or saved snapshot; "Plan this night"
// is the one adoption. The slider browses instants of the viewed night,
// "Now" only inside it. At large text the month is a week list. Through
// the real app and database.

import 'dart:convert';
import 'dart:io';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/core/theme/app_palette.dart';
import 'package:astroplan/core/utils/quantity_text.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/night_view.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/shared/night_time_formatter.dart';
import 'package:astroplan/presentation/viewmodels/night_browser_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/night_conditions_viewmodel.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_device_time_zone.dart';
import '../../../support/fake_location_service.dart';
import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/no_snapshot_weather.dart';
import '../../../support/planner_harness.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

void main() {
  late AppDatabase db;
  late PlannerHarness vm;
  final now = DateTime.utc(2026, 12, 15, 20); // 21:00 in Ljubljana
  final tonight = CalendarDate(2026, 12, 15);
  final viewed = CalendarDate(2026, 12, 17);

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// Lets the month's isolate finish.
  Future<void> month(WidgetTester tester) async {
    for (var i = 0; i < 40; i++) {
      if (find
          .byKey(const Key('nightMoon.calendarLoading'))
          .evaluate()
          .isEmpty) {
        break;
      }
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
    }
    await settle(tester);
  }

  Future<void> start(
    WidgetTester tester, {
    double textScale = 1,
    bool activeSite = true,
  }) async {
    tester.view.physicalSize = const Size(800, 5000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      await CatalogSeeder(DriftTargetRepository(db)).seedIfNeeded();
      await EquipmentSeeder(DriftEquipmentRepository(db)).seedIfNeeded();
      final siteId = await DriftLocationRepository(db).insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Ljubljana',
          latitude: 46.05,
          longitude: 14.51,
          elevation: 300,
          timeZoneId: 'Europe/Ljubljana',
        ),
      );
      SharedPreferences.setMockInitialValues({
        if (activeSite) 'activeLocationId': siteId,
      });
      final clock = FixedClock(now);
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoWeather(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(),
        clock: clock,
        sessionRepository: DriftSessionRepository(db, clock: clock),
      );
      await vm.ready;
    });
    addTearDown(() => tester.runAsync(db.close));
    AppRouter.router.go(AppRouter.nightMoon);
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
    if (!activeSite) return;
    // Hybrid separates Moon/calendar into its own reachable tab.
    expect(find.byKey(const Key('conditions.page.0')), findsOneWidget);
    await tester.tap(find.widgetWithText(Tab, 'Moon'));
    await settle(tester);
    await month(tester);
    // Full scientific readout remains reachable in Hybrid's reading disclosure.
    await tester.ensureVisible(find.text('Read the time browser'));
    await tester.tap(find.text('Read the time browser'));
    await settle(tester);
  }

  NightBrowserViewModel browser(WidgetTester tester) =>
      Provider.of<NightBrowserViewModel>(
        tester.element(find.byKey(const Key('nightMoon.bar'))),
        listen: false,
      );

  String textOf(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  /// The slider's spoken read-out at the cursor (its semantic value).
  String readout(WidgetTester tester) {
    final slider = tester.widget<Slider>(
      find.byKey(const Key('nightMoon.slider')),
    );
    return slider.semanticFormatterCallback!(slider.value);
  }

  for (final mode in ['light', 'dark', 'field']) {
    testWidgets('P-4: tab colors and weights follow selection in $mode', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = mode == 'dark'
          ? Brightness.dark
          : Brightness.light;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await start(tester, activeSite: false);
      if (mode == 'field') {
        await tester.runAsync(vm.theme.toggleFieldMode);
        await settle(tester);
      }
      final palette = AppPalette.of(tester.element(find.byType(TabBar)));
      for (final selected in ['Night', 'Moon', 'Weather']) {
        await tester.tap(find.widgetWithText(Tab, selected));
        await settle(tester);
        for (final label in ['Night', 'Moon', 'Weather']) {
          final element = tester.element(find.text(label).last);
          final style = DefaultTextStyle.of(element).style;
          expect(
            style.color,
            label == selected ? palette.textPrimary : palette.textSecondary,
            reason: '$mode $label with $selected selected',
          );
          expect(
            style.fontWeight,
            label == selected ? FontWeight.w600 : FontWeight.w400,
          );
          expect(style.fontSize, 14);
        }
        final bar = tester.widget<TabBar>(find.byType(TabBar));
        expect((bar.indicator! as UnderlineTabIndicator).borderSide.width, 2);
      }
    });
  }

  for (final scale in [1.0, 2.0]) {
    testWidgets('P-5: exact-time values reach the row edge at $scale', (
      tester,
    ) async {
      final bytes = File('assets/fonts/Geist.ttf').readAsBytesSync();
      await (FontLoader(
        'Geist',
      )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
      await start(tester, textScale: scale);
      tester.view.physicalSize = const Size(375, 5000);
      await tester.tap(find.widgetWithText(Tab, 'Night'));
      await settle(tester);
      await tester.ensureVisible(find.text('Exact times & reading key'));
      await tester.tap(find.text('Exact times & reading key'));
      await settle(tester);
      final section = find
          .ancestor(
            of: find.text('Exact times & reading key'),
            matching: find.byType(Column),
          )
          .first;
      var rows = 0;
      var intervals = 0;
      for (final element
          in find
              .descendant(of: section, matching: find.byType(Row))
              .evaluate()) {
        final row = element.widget as Row;
        if (row.children.length != 3 || row.children.last is! Flexible) {
          continue;
        }
        final value = (row.children.last as Flexible).child;
        if (value is! Text || value.textAlign != TextAlign.right) continue;
        final rowFinder = find.byWidget(row);
        final valueFinder = find.descendant(
          of: rowFinder,
          matching: find.byWidget(value),
        );
        expect(
          tester.getRect(valueFinder).right,
          closeTo(tester.getRect(rowFinder).right, 0.01),
          reason: 'Value ${value.data} must end at the content edge',
        );
        rows++;
        if (value.data!.contains('\nto ')) {
          intervals++;
          final paragraph = tester.renderObject<RenderParagraph>(valueFinder);
          var offset = 0;
          for (final line in value.data!.split('\n')) {
            final end = offset + line.trimRight().length;
            // Measure the last glyph, excluding line-break/trailing-space
            // selection boxes, which can extend beyond the painted text.
            final box = paragraph
                .getBoxesForSelection(
                  TextSelection(baseOffset: end - 1, extentOffset: end),
                )
                .single;
            expect(
              box.right,
              closeTo(paragraph.size.width, 0.1),
              reason: 'Each interval line ends at the right edge',
            );
            offset += line.length + 1;
          }
        }
      }
      expect(rows, greaterThanOrEqualTo(8));
      expect(intervals, greaterThan(0));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('missing-site conditions offer the real site picker', (
    tester,
  ) async {
    await start(tester, activeSite: false);
    expect(find.text('Set an observing site'), findsOneWidget);
    expect(find.byKey(const Key('nightMoon.bar')), findsNothing);
    await tester.tap(find.byKey(const Key('conditions.chooseSite')));
    await settle(tester);
    expect(find.widgetWithText(AppBar, 'Choose a site'), findsOneWidget);
    expect(vm.site.isDefaultLocation, isTrue);
  });

  testWidgets('A1: the plan\'s night with the bar, legend, text alternative '
      'and the month; the calendar agrees with the detail', (tester) async {
    await start(tester);
    expect(find.byKey(const Key('nightMoon.viewing')), findsNothing);
    expect(find.byKey(const Key('nightMoon.legend')), findsOneWidget);
    final handle = tester.ensureSemantics();
    expect(
      find.bySemanticsLabel(RegExp('Night bar: Daylight')),
      findsOneWidget,
    );
    handle.dispose();
    expect(find.byKey(const Key('nightMoon.month')), findsOneWidget);
    final b = browser(tester);
    final day = b.monthDays!.firstWhere((d) => d.date == tonight);
    expect(day.moonFree.moonFree, b.view.moonFree.moonFree);
    // The plan's own rows use the same answer (one predicate, N1/N4).
    expect(vm.conditions.moonFree!.moonFree, b.view.moonFree.moonFree);
    // Hybrid's Moon answer leads with that total as its primary number.
    if (b.view.moonFree.moonFree > Duration.zero) {
      expect(
        textOf(tester, 'nightMoon.moonFreeTotal'),
        QuantityText.duration(b.view.moonFree.moonFree),
      );
    }
    expect(
      find.byKey(Key('nightMoon.day.${viewed.toIso8601String()}')),
      findsOneWidget,
    );
  });

  testWidgets(
    'Hybrid tabs retain viewed night and weather follows it without adopting',
    (tester) async {
      await start(tester);
      final b = browser(tester);
      final planNight = vm.eveningDate;
      b.viewNight(viewed);
      await settle(tester);
      await tester.tap(find.widgetWithText(Tab, 'Weather'));
      await settle(tester);
      final conditions = tester
          .element(find.byKey(const Key('conditions.page.2')))
          .read<NightConditionsViewModel>();
      expect(conditions.sessionNight!.eveningDate, viewed);
      expect(vm.conditions.sessionNight!.eveningDate, planNight);
      expect(vm.eveningDate, planNight);
      await tester.tap(find.widgetWithText(Tab, 'Night'));
      await settle(tester);
      expect(identical(browser(tester), b), isTrue);
      expect(b.viewedDate, viewed);
      expect(vm.eveningDate, planNight);
      expect(tester.takeException(), isNull);
    },
  );

  // H2 (G1-S11-01): a day cell's label replaces the InkWell's semantics, so
  // the labelled node itself must carry the tap, and it views that night.
  testWidgets('A5: a calendar day can be activated by a screen reader', (
    tester,
  ) async {
    await start(tester);
    final handle = tester.ensureSemantics();
    final cell = find.byKey(Key('nightMoon.day.${viewed.toIso8601String()}'));
    await tester.ensureVisible(cell);
    await settle(tester);
    final node = tester.getSemantics(cell);
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    tester.semantics.tap(find.semantics.byPredicate((n) => n.id == node.id));
    await settle(tester);
    expect(find.byKey(const Key('nightMoon.viewing')), findsOneWidget);
    expect(vm.eveningDate, tonight, reason: 'viewing is not adopting');
    handle.dispose();
  });

  testWidgets('A2/A5: tapping a night views it; the slider browses it; '
      'nothing about the plan changes; Back to the plan', (tester) async {
    await start(tester);
    final blocks = vm.captureBlocks;
    // Now lies in the plan's night: the cursor starts at now.
    expect(browser(tester).nowInView, isTrue);
    final cell = find.byKey(Key('nightMoon.day.${viewed.toIso8601String()}'));
    await tester.ensureVisible(cell);
    await tester.tap(cell);
    await settle(tester);
    expect(
      textOf(tester, 'nightMoon.viewing'),
      'Your plan: Night of ${NightTimeFormatter.eveningDate(tonight)}. '
      'Browsing changes nothing.',
    );
    expect(vm.eveningDate, tonight, reason: 'viewing is not adopting');
    expect(vm.captureBlocks, blocks);
    final b = browser(tester);
    expect(b.view.night.eveningDate, viewed);
    // Now is not in the viewed night: the cursor starts where dark starts
    // (owner 2026-10-22, web startCursor).
    expect(b.cursorUtc, b.jumpTarget(end: false));
    expect(readout(tester), contains('Dark (Sun below −18°)'));
    b.setCursor(b.view.night.startUtc);
    await settle(tester);
    final before = readout(tester);
    expect(before, contains('Daylight'));
    expect(before, contains('darkness in'));
    // Drag the slider to the middle of the night (midnight): dark.
    b.setCursor(b.view.night.startUtc.add(const Duration(hours: 12)));
    await settle(tester);
    final mid = readout(tester);
    expect(mid, contains('Dark (Sun below −18°)'));
    expect(mid, contains('dark for another'));
    expect(mid, contains('site zone Europe/Ljubljana, CET'));
    expect(vm.eveningDate, tonight);
    // "Dark starts" jumps there; another night resets the cursor too.
    await tester.ensureVisible(find.byKey(const Key('nightMoon.jumpStart')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('nightMoon.jumpStart')));
    await settle(tester);
    expect(b.cursorUtc, b.jumpTarget(end: false));
    await tester.ensureVisible(find.byKey(const Key('nightMoon.backToPlan')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('nightMoon.backToPlan')));
    await settle(tester);
    expect(find.byKey(const Key('nightMoon.viewing')), findsNothing);
    expect(b.view.night.eveningDate, tonight);
    expect(
      b.nowInView,
      isTrue,
      reason: 'back on the plan night, now is in view',
    );
  });

  testWidgets('A2: Plan this night adopts a viewed night through D9; a saved '
      'plan is copied and keeps its night', (tester) async {
    await start(tester);
    await tester.runAsync(() async {
      final target = (await DriftTargetRepository(db).getAllTargets()).first;
      final rig = (await DriftEquipmentRepository(db).getAllEquipment()).first;
      await vm.setTarget(target);
      await vm.setEquipment(rig);
      await vm.plan.idle;
      await vm.saveSession();
    });
    await settle(tester);
    final saved = vm.activeSession!;
    final cell = find.byKey(Key('nightMoon.day.${viewed.toIso8601String()}'));
    await tester.ensureVisible(cell);
    await tester.tap(cell);
    await settle(tester);
    await tester.tap(find.byKey(const Key('nightMoon.planThisNight')));
    await settle(tester);
    expect(vm.eveningDate, viewed);
    expect(vm.activeSession?.id, isNot(saved.id));
    final kept = await tester.runAsync(
      () => DriftSessionRepository(db).get(saved.id),
    );
    expect(kept!.eveningDate, tonight);
    expect(
      jsonEncode(kept.planSnapshot!.json),
      jsonEncode(saved.planSnapshot!.json),
      reason: 'never rewritten',
    );
    expect(
      find.byKey(const Key('nightMoon.viewing')),
      findsNothing,
      reason: 'the viewed night is now the plan\'s',
    );
  });

  testWidgets('A3: a site change while viewing keeps the plan and the saved '
      'snapshot; reopening starts on the plan\'s night', (tester) async {
    await start(tester);
    await tester.runAsync(() async {
      final target = (await DriftTargetRepository(db).getAllTargets()).first;
      final rig = (await DriftEquipmentRepository(db).getAllEquipment()).first;
      await vm.setTarget(target);
      await vm.setEquipment(rig);
      await vm.plan.idle;
      await vm.saveSession();
    });
    await settle(tester);
    final saved = vm.activeSession!;
    final cell = find.byKey(Key('nightMoon.day.${viewed.toIso8601String()}'));
    await tester.ensureVisible(cell);
    await tester.tap(cell);
    await settle(tester);
    final b = browser(tester);
    b.setCursor(b.view.night.startUtc.add(const Duration(hours: 10)));
    await tester.runAsync(() async {
      final id = await vm.site.saveSite(
        domain.LocationProfile(
          id: 0,
          name: 'Trieste',
          latitude: 45.65,
          longitude: 13.78,
          timeZoneId: 'Europe/Rome',
        ),
      );
      await vm.site.selectSite(id);
    });
    await settle(tester);
    // Revalidated to the new night's default (owner 2026-10-22, web
    // startCursor): the start of its dark time.
    expect(b.cursorUtc, b.jumpTarget(end: false), reason: 'revalidated');
    final kept = await tester.runAsync(
      () => DriftSessionRepository(db).get(saved.id),
    );
    expect(kept!.eveningDate, tonight);
    expect(
      jsonEncode(kept.planSnapshot!.json),
      jsonEncode(saved.planSnapshot!.json),
    );
    // Reopen: browsing state is transient.
    AppRouter.router.go(AppRouter.tonight);
    await settle(tester);
    AppRouter.router.go(AppRouter.nightMoon);
    await settle(tester);
    expect(find.byKey(const Key('nightMoon.viewing')), findsNothing);
  });

  testWidgets('A5: across the October DST change the readout names each '
      'instant\'s zone; the month view follows the viewed night', (
    tester,
  ) async {
    await start(tester);
    final b = browser(tester);
    b.viewNight(CalendarDate(2026, 10, 24));
    await settle(tester);
    await month(tester);
    expect(b.month, (2026, 10));
    b.setCursor(DateTime.utc(2026, 10, 24, 21)); // 23:00 CEST
    await settle(tester);
    expect(readout(tester), contains('CEST'));
    b.setCursor(DateTime.utc(2026, 10, 25, 3)); // 04:00 CET
    await settle(tester);
    expect(readout(tester), contains(', CET, UTC+01:00'));
    expect(vm.eveningDate, tonight);
  });

  /// Makes a polar site the active one.
  Future<void> polarSite(WidgetTester tester, double latitude) async {
    await tester.runAsync(() async {
      final id = await vm.site.saveSite(
        domain.LocationProfile(
          id: 0,
          name: 'Polar $latitude',
          latitude: latitude,
          longitude: 15.6,
          timeZoneId: 'Arctic/Longyearbyen',
        ),
      );
      await vm.site.selectSite(id);
    });
    await settle(tester);
  }

  testWidgets('A5 polar: under the midnight Sun (78° N, June) the readout '
      'says there is no more dark time, all night', (tester) async {
    await start(tester);
    await polarSite(tester, 78);
    final b = browser(tester);
    b.viewNight(CalendarDate(2027, 6, 20));
    await settle(tester);
    expect(b.view.segments.map((s) => s.sky).toSet(), {
      SkyState.daylight,
    }, reason: 'no twilight and no dark at all');
    for (final hours in [0, 6, 12, 18, 23]) {
      b.setCursor(b.view.night.startUtc.add(Duration(hours: hours)));
      await settle(tester);
      final text = readout(tester);
      expect(text, contains('Daylight · '), reason: '+$hours h');
      expect(text, contains('no more dark time this night'));
      expect(text, isNot(contains('darkness in')));
    }
    expect(vm.eveningDate, tonight, reason: 'browsing changes no plan');
  });

  testWidgets('A5 polar: in the polar night (88° N, December) the readout '
      'says dark until the night ends, with no dark-time change', (
    tester,
  ) async {
    await start(tester);
    await polarSite(tester, 88);
    final b = browser(tester);
    expect(b.view.segments.map((s) => s.sky).toSet(), {SkyState.dark});
    for (final hours in [0, 12, 23]) {
      b.setCursor(b.view.night.startUtc.add(Duration(hours: hours)));
      await settle(tester);
      expect(b.cursor.darkChangeUtc, isNull);
      final text = readout(tester);
      expect(text, contains('Dark (Sun below −18°)'), reason: '+$hours h');
      expect(text, contains('dark until the night ends'));
      expect(text, isNot(contains('dark for another')));
    }
  });

  testWidgets('A5: the slider moves by keyboard, five minutes per arrow '
      'key, and reads its instant to assistive technology', (tester) async {
    await start(tester);
    final handle = tester.ensureSemantics();
    final b = browser(tester);
    b.setCursor(b.view.night.startUtc.add(const Duration(hours: 6)));
    await settle(tester);
    final slider = find.byKey(const Key('nightMoon.slider'));
    expect(slider, findsOneWidget);
    final before = b.cursorUtc;

    // Its semantics: a slider whose value is the instant the readout
    // starts with, with increase / decrease actions.
    SemanticsNode node() =>
        find.semantics.byFlag(SemanticsFlag.isSlider).evaluate().single;
    expect(node().value, isNotEmpty);
    expect(node().value, startsWith('${node().label}, '));
    expect(node().value, contains('Moon'));
    expect(node().value, readout(tester));
    expect(
      node().getSemanticsData().hasAction(SemanticsAction.increase),
      isTrue,
    );
    expect(
      node().getSemanticsData().hasAction(SemanticsAction.decrease),
      isTrue,
    );

    // Reach it with Tab, then the arrows.
    bool focused() =>
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<Slider>() ==
        tester.widget<Slider>(slider);
    for (var i = 0; i < 60 && !focused(); i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    expect(focused(), isTrue, reason: 'reachable by keyboard');
    expect(b.cursorUtc, before, reason: 'focusing moves nothing');
    // A step up or down is announced as the instant it goes to.
    final up = node().increasedValue;
    expect(up, isNot(node().value));
    expect(node().decreasedValue, isNot(node().value));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await settle(tester);
    expect(b.cursorUtc, before.add(const Duration(minutes: 5)));
    expect(readout(tester), startsWith('${node().label}, '));
    expect(node().value, up);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await settle(tester);
    expect(b.cursorUtc, before);
    expect(vm.eveningDate, tonight);
    handle.dispose();
  });

  testWidgets('large text: the month becomes a week list', (tester) async {
    await start(tester, textScale: 2);
    expect(find.byKey(const Key('nightMoon.week')), findsOneWidget);
    expect(find.byKey(const Key('nightMoon.month')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text: no tab label is clipped (migration review F1)', (
    tester,
  ) async {
    await start(tester, textScale: 2);
    for (final label in ['Night', 'Moon', 'Weather']) {
      final paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(of: find.byType(TabBar), matching: find.text(label)),
      );
      expect(
        paragraph.size.width,
        greaterThanOrEqualTo(
          paragraph.getMaxIntrinsicWidth(double.infinity) - 0.5,
        ),
        reason: '$label is laid out at its full width',
      );
    }
  });
}
