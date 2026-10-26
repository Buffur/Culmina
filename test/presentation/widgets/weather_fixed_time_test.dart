import 'package:astroplan/core/theme/app_typography.dart';
import 'package:astroplan/core/theme/app_palette.dart';
import 'package:astroplan/core/theme/hybrid_tokens.dart';
import 'package:astroplan/core/units/display_units.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/presentation/widgets/weather_details_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/hybrid_transfer_shots.dart';
import '../../support/wave1_capture.dart';
import '../../support/wave2_fixture.dart';

final weatherFixedTimeMetrics = <Map<String, Object?>>[];
final _viewport = find.byKey(const Key('weather.table'));
Finder get _table => find.descendant(
  of: _viewport,
  matching: find.byWidgetPredicate((w) => w is Table),
);
ScrollPosition _position(WidgetTester t) => t
    .state<ScrollableState>(
      find.descendant(of: _viewport, matching: find.byType(Scrollable)),
    )
    .position;

Rect _semanticRect(SemanticsNode node) {
  var rect = node.rect;
  for (
    SemanticsNode? current = node;
    current != null;
    current = current.parent
  ) {
    if (current.transform case final transform?) {
      rect = MatrixUtils.transformRect(transform, rect);
    }
  }
  return rect;
}

Future<void> _size(WidgetTester t, double width) async {
  if (wave1IsNative) {
    await t.binding.setSurfaceSize(Size(width, 812));
  } else {
    t.view.physicalSize = Size(width, 812);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
  }
}

Future<void> _component(
  WidgetTester t,
  String theme,
  double width, {
  double scale = 1,
  TextDirection direction = TextDirection.ltr,
  String suffix = '',
}) async {
  await _size(t, width);
  final data = [
    [
      'Local time',
      'Cloud %',
      'Low / mid / high %',
      'Temp °C',
      'Dew °C',
      'Wind / gust km/h',
      'Precip %',
      'RH %',
      'Visibility km',
    ],
    [
      '25 Oct, 03:00 GMT+3$suffix',
      '59',
      '10 / 20 / 30',
      '6.5',
      '2',
      '9 / —',
      '—',
      '78',
      '24',
    ],
    [
      '25 Oct, 03:00 GMT+2 *$suffix',
      '—',
      '—',
      '—',
      '—',
      '— / 18',
      '5',
      '—',
      '—',
    ],
  ];
  await t.pumpWidget(
    wave1App(
      theme,
      home: Builder(
        builder: (context) {
          final tokens = Theme.of(context).extension<HybridTokens>()!;
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: Directionality(
              textDirection: direction,
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(36),
                    child: Column(
                      children: [
                        WeatherDetailsTable(
                          background: tokens.surfaceSubtle,
                          rows: [
                            for (final row in data)
                              TableRow(
                                children: [
                                  for (final cell in row)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        0,
                                        6,
                                        12,
                                        6,
                                      ),
                                      child: Text(
                                        cell,
                                        style: AppTypography.dense.copyWith(
                                          color: AppPalette.of(context)
                                              .textPrimary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 900),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
  await t.pumpAndSettle();
}

Future<void> _assertPinned(WidgetTester t, String id) async {
  final evidenceId = id.replaceAll('.', '_');
  final widget = t.widget<Table>(_table);
  final render = t.renderObject<RenderTable>(_table);
  final first = find.byWidget(
    (widget.children[1].children.first as Padding).child!,
  );
  final original = t.getRect(first);
  final originalSemantics = _semanticRect(t.getSemantics(first));
  final rowHeights = [
    for (var i = 0; i < render.rows; i++) render.getRowBox(i).height,
  ];
  final position = _position(t);
  expect(position.maxScrollExtent, greaterThan(0));
  await captureWave1(t, 'fixed-time-$evidenceId-first');
  // A real pointer drag, including one that begins on the pinned time cells.
  await t.dragFrom(t.getCenter(first), const Offset(-240, 0));
  await t.pumpAndSettle();
  expect(position.pixels, greaterThan(0));
  position.jumpTo(position.maxScrollExtent);
  await t.pumpAndSettle();
  final after = t.getRect(first);
  expect(after.left, closeTo(original.left, 1e-6));
  expect(after.top, closeTo(original.top, 1e-6));
  expect(
    _semanticRect(t.getSemantics(first)).left,
    closeTo(originalSemantics.left, 1e-6),
  );
  expect(
    t.getSemantics(first).getSemanticsData().flagsCollection.isHidden,
    isFalse,
  );
  expect(
    find.text(
      ((widget.children[1].children.first as Padding).child! as Text).data!,
    ),
    findsOneWidget,
  );
  final timeBox = t.renderObject<RenderBox>(first);
  final pointInView = timeBox.localToGlobal(timeBox.size.center(Offset.zero));
  // The render tree already gives logical view coordinates. WidgetTester's
  // hitTestOnBinding adds the live test surface transform a second time.
  final hit = BoxHitTestResult();
  t.binding.hitTestInView(hit, pointInView, t.view.viewId);
  expect(
    hit.path.any((entry) => identical(entry.target, timeBox)),
    isTrue,
    reason: 'Pinned time $id at $pointInView: $hit',
  );
  expect([
    for (var i = 0; i < render.rows; i++) render.getRowBox(i).height,
  ], rowHeights);
  await captureWave1(t, 'fixed-time-$evidenceId-far');
  weatherFixedTimeMetrics.add({
    'case': id,
    'viewportWidth': t.getSize(_viewport).width,
    'tableWidth': render.size.width,
    'tableHeight': render.size.height,
    'rows': render.rows,
    'columns': render.columns,
    'rowHeights': rowHeights,
    'timeLeftBefore': original.left,
    'timeLeftAfter': after.left,
    'semanticLeftBefore': originalSemantics.left,
    'semanticLeftAfter': _semanticRect(t.getSemantics(first)).left,
    'horizontalMax': position.maxScrollExtent,
  });
  expect(t.takeException(), isNull);
}

void main() {
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    for (final width in [320.0, 375.0, 412.0]) {
      testWidgets(
        'UIA-0010 $theme/$width: time paint, hit target and semantics stay pinned',
        (t) async {
          await _component(t, theme, width);
          await _assertPinned(t, '$theme-${width.toInt()}');
        },
      );
    }
  }
  for (final scale in [1.5, 2.0]) {
    testWidgets(
      'UIA-0010 preserves the full $scale text scaler without overflow',
      (t) async {
        await _component(t, 'light', 320, scale: scale);
        await _assertPinned(t, 'scale-$scale');
        expect(
          MediaQuery.textScalerOf(t.element(find.text('Local time'))).scale(12),
          12 * scale,
        );
      },
    );
  }
  testWidgets('UIA-0010 RTL pins time to the leading right edge', (t) async {
    await _component(t, 'dark', 375, direction: TextDirection.rtl);
    final first = find.text('25 Oct, 03:00 GMT+3');
    final before = t.getRect(first);
    _position(t).jumpTo(_position(t).maxScrollExtent);
    await t.pumpAndSettle();
    expect(t.getRect(first).right, closeTo(before.right, 1e-6));
    expect(
      t.getSemantics(first).getSemanticsData().flagsCollection.isHidden,
      isFalse,
    );
    expect(t.takeException(), isNull);
  });
  testWidgets(
    'UIA-0010 changes rows, theme, width and scale without stale geometry',
    (t) async {
      await _component(t, 'light', 375);
      final oldHeight = t.getSize(_table).height;
      _position(t).jumpTo(_position(t).maxScrollExtent);
      await t.pumpAndSettle();
      await _component(
        t,
        'field',
        412,
        scale: 2,
        suffix: ' · complete local date',
      );
      expect(t.getSize(_table).height, greaterThan(oldHeight));
      expect(find.text('25 Oct, 03:00 GMT+3'), findsNothing);
      await _assertPinned(t, 'updated');
      await t.pumpWidget(const SizedBox.shrink());
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'UIA-0010 accessibility reveal exposes metrics beside time and retains time offset',
    (t) async {
      await _component(t, 'light', 375);
      final table = t.widget<Table>(_table);
      for (var column = 1; column < 9; column++) {
        final target = find.byWidget(
          (table.children[1].children[column] as Padding).child!,
        );
        t.renderObject(target).showOnScreen();
        await t.pumpAndSettle();
        final rect = t.getRect(target);
        final viewport = t.getRect(_viewport);
        expect(rect.left, greaterThanOrEqualTo(viewport.left + 96 - 1e-6));
        expect(rect.right, lessThanOrEqualTo(viewport.right + 1e-6));
      }
      final offset = _position(t).pixels;
      t.renderObject(find.text('25 Oct, 03:00 GMT+3')).showOnScreen();
      await t.pumpAndSettle();
      expect(_position(t).pixels, closeTo(offset, 1e-6));
      expect(t.takeException(), isNull);
    },
  );
  for (final theme in ['light', 'dark', 'field']) {
    for (final width in [375.0, 412.0]) {
      for (final dst in [false, true]) {
        testWidgets(
          'UIA-0010 production $theme/$width/${dst ? 'DST12' : 'metric24'}: exact nine columns, qualification and readback',
          (t) async {
            t.platformDispatcher.alwaysUse24HourFormatTestValue = !dst;
            final f = await mountWave2(t, theme);
            await _size(t, width);
            f.seed.forecast.cloudGapEvery = 3;
            f.seed.forecast.missingFirstHours = 1;
            await t.runAsync(() async {
              if (dst) {
                await f.vm.plan.setEveningDate(CalendarDate(2026, 10, 24));
              }
              await f.vm.vms.displaySettings.setUnits(
                dst
                    ? const DisplayUnits(
                        temperature: TemperatureUnit.fahrenheit,
                        wind: WindUnit.mph,
                      )
                    : DisplayUnits.metric,
              );
              await f.vm.refreshWeather();
              await f.vm.plan.idle;
            });
            await hybridSettle(t);
            final saved = f.vm.plan.activeSession!;
            final before = await t.runAsync(
              () => f.seed.sessions.get(saved.id),
            );
            await t.tap(find.byKey(const Key('tonight.openPlanner')));
            await hybridSettle(t);
            final weather = find.byKey(const Key('planner.weather'));
            await revealWave2(t, weather);
            await t.tap(weather);
            await hybridSettle(t);
            await revealWave2(t, find.byKey(const Key('weather.details')));
            await t.tap(find.byKey(const Key('weather.details')));
            await hybridSettle(t);
            await revealWave2(t, _viewport);
            final table = t.widget<Table>(_table);
            final cells = [
              for (final row in table.children)
                [
                  for (final cell in row.children)
                    ((cell as Padding).child! as Text).data!,
                ],
            ];
            expect(cells.every((row) => row.length == 9), isTrue);
            expect(cells.first, [
              'Local time',
              'Cloud %',
              'Low / mid / high %',
              'Temp ${dst ? '°F' : '°C'}',
              'Dew ${dst ? '°F' : '°C'}',
              'Wind / gust ${dst ? 'mph' : 'km/h'}',
              'Precip %',
              'RH %',
              'Visibility km',
            ]);
            // Exact fixture readouts preserved from the reviewed current-table comparison.
            expect(
              cells[1],
              dst
                  ? [
                      '24 Oct, 8:00 PM GMT+3',
                      '59',
                      '10 / 20 / 30',
                      '43.7',
                      '35.6',
                      '5.6 / —',
                      '—',
                      '78',
                      '24',
                    ]
                  : [
                      '19 Oct, 20:00 GMT+3',
                      '59',
                      '10 / 20 / 30',
                      '6.5',
                      '2',
                      '9 / —',
                      '—',
                      '78',
                      '24',
                    ],
            );
            expect(
              cells.last,
              dst
                  ? [
                      '25 Oct, 5:00 AM GMT+2 *',
                      '—',
                      '—',
                      '—',
                      '—',
                      '— / 11.2',
                      '5',
                      '—',
                      '—',
                    ]
                  : [
                      '20 Oct, 06:00 GMT+3 *',
                      '—',
                      '—',
                      '—',
                      '—',
                      '— / 18',
                      '5',
                      '—',
                      '—',
                    ],
            );
            if (dst) {
              expect(
                cells.map((r) => r.first),
                containsAll(['25 Oct, 3:00 AM GMT+3', '25 Oct, 3:00 AM GMT+2']),
              );
            }
            final qualifier = t
                .widget<Text>(find.byKey(const Key('weather.precipNote')))
                .data!;
            expect(
              qualifier,
              contains(
                '* marks partial dark-time overlap. Probability is %, not rainfall amount.',
              ),
            );
            await _assertPinned(
              t,
              'production-$theme-${width.toInt()}-${dst ? 'DST12' : 'metric24'}',
            );
            expect([
              for (final row in t.widget<Table>(_table).children)
                [
                  for (final cell in row.children)
                    ((cell as Padding).child! as Text).data!,
                ],
            ], cells);
            expect(f.vm.plan.activeSessionId, saved.id);
            await t.runAsync(() async {
              final after = (await f.seed.sessions.get(saved.id))!;
              expect(after.planSnapshot!.json, before!.planSnapshot!.json);
              expect(after.updatedAtUtc, before.updatedAtUtc);
            });
            expect(t.takeException(), isNull);
          },
        );
      }
    }
  }
}
