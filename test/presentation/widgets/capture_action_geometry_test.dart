import 'dart:io';

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/presentation/screens/target/target_detail_screen.dart';
import 'package:astroplan/presentation/screens/settings/settings_parts.dart';
import 'package:astroplan/presentation/shared/document_section.dart';
import 'package:astroplan/presentation/widgets/capture_plan_widget.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../support/hybrid_transfer_fixture.dart';
import '../../support/hybrid_transfer_shots.dart';
import '../../support/sdk_fonts.dart';

Future<void> _fonts() async {
  for (final entry in {
    'Geist': File('assets/fonts/Geist.ttf'),
    'MaterialIcons': sdkMaterialFont('materialicons-regular.otf')!,
  }.entries) {
    final loader = FontLoader(entry.key);
    loader.addFont(entry.value.readAsBytes().then(ByteData.sublistView));
    await loader.load();
  }
}

Future<HybridTransferFixture> _setup(WidgetTester t, double width) async {
  t.view.physicalSize = Size(width, 1800);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  late HybridTransferFixture fixture;
  await t.runAsync(() async {
    await _fonts();
    fixture = await HybridTransferFixture.create(
      AppDatabase(NativeDatabase.memory()),
    );
  });
  addTearDown(() async {
    await t.pumpWidget(const SizedBox.shrink());
    fixture.vm.dispose();
    await t.runAsync(fixture.db.close);
  });
  return fixture;
}

void main() {
  for (final theme in [
    ('Light', AppTheme.light),
    ('Dark', AppTheme.dark),
    ('Field', AppTheme.fieldTheme),
  ]) {
    for (final width in [375.0, 412.0]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('capture action bands $width ${theme.$1} scale $scale', (
          t,
        ) async {
          final fixture = await _setup(t, width);
          await t.runAsync(() async {
            for (final seconds in [90.0, 120.0]) {
              await fixture.vm.plan.addCaptureBlock(
                CaptureBlock(
                  frameType: FrameType.light,
                  exposureTimeSeconds: seconds,
                  frameCount: 5,
                ),
              );
            }
            await fixture.vm.plan.idle;
          });
          await t.pumpWidget(
            MultiProvider(
              providers: fixture.vm.providers,
              child: MaterialApp(
                theme: theme.$2,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: const Scaffold(
                  body: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: DocumentSection(
                      children: [CapturePlanWidget(includeSummary: false)],
                    ),
                  ),
                ),
              ),
            ),
          );
          await hybridSettle(t);
          for (var i = 0; i < 3; i++) {
            final keys = [
              'capture.edit.$i',
              'capture.moveUp.$i',
              'capture.moveDown.$i',
              'capture.delete.$i',
            ];
            for (final key in keys) {
              final finder = find.byKey(Key(key));
              await t.ensureVisible(finder);
              await t.pump();
              final rect = t.getRect(finder);
              expect(rect.width, greaterThanOrEqualTo(48 - .01), reason: key);
              expect(rect.height, greaterThanOrEqualTo(48 - .01), reason: key);
              expect(rect.left, greaterThanOrEqualTo(36 - .01), reason: key);
              expect(
                rect.right,
                lessThanOrEqualTo(width - 36 + .01),
                reason: key,
              );
            }
            // Read all positions at the same scroll offset.
            final rects = [
              for (final key in keys) t.getRect(find.byKey(Key(key))),
            ];
            if (scale == 1) {
              for (final rect in rects.skip(1)) {
                expect(
                  rect.center.dy,
                  closeTo(rects.first.center.dy, .5),
                  reason: 'All four actions share one band at100% when content fits',
                );
              }
            }
            for (var a = 0; a < rects.length; a++) {
              for (var b = a + 1; b < rects.length; b++) {
                expect(rects[a].overlaps(rects[b]), isFalse);
              }
            }
            for (final action in ['capture.edit.$i', 'capture.delete.$i']) {
              final text = find
                  .descendant(
                    of: find.byKey(Key(action)),
                    matching: find.byType(RichText),
                  )
                  .first;
              final paragraph = t.renderObject<RenderParagraph>(text);
              expect(paragraph.didExceedMaxLines, isFalse);
              expect(
                paragraph.getBoxesForSelection(
                  TextSelection(
                    baseOffset: 0,
                    extentOffset: paragraph.text.toPlainText().length,
                  ),
                ),
                hasLength(1),
                reason: 'Edit and Remove remain complete words',
              );
            }
          }
          Finder move(String key) => find.descendant(
            of: find.byKey(Key(key)),
            matching: find.byType(IconButton),
          );
          expect(
            t.widget<IconButton>(move('capture.moveUp.0')).onPressed,
            isNull,
          );
          expect(
            t.widget<IconButton>(move('capture.moveDown.1')).onPressed,
            isNotNull,
          );
          expect(
            t.widget<IconButton>(move('capture.moveDown.2')).onPressed,
            isNull,
          );
          expect(t.takeException(), isNull);
        });
      }

      testWidgets(
        'Target Source uses the full facts column $width ${theme.$1}',
        (t) async {
          final fixture = await _setup(t, width);
          await t.pumpWidget(
            MultiProvider(
              providers: fixture.vm.providers,
              child: MaterialApp(
                theme: theme.$2,
                home: TargetDetailScreen(
                  target: fixture.vm.plan.selectedTarget!,
                  onPlan: (_) async {},
                ),
              ),
            ),
          );
          await hybridSettle(t);
          final group = t.getRect(
            find.byKey(const Key('targetDetail.factsGroup')),
          );
          final source = find.byKey(const Key('targetDetail.source'));
          final sourceRect = t.getRect(source);
          final label = find.descendant(
            of: find.byKey(const Key('targetDetail.factsGroup')),
            matching: find.widgetWithText(SettingsHint, 'Source'),
          );
          expect(t.getRect(label).left, closeTo(group.left + 16, .01));
          expect(sourceRect.left, closeTo(group.left + 16, .01));
          expect(sourceRect.width, closeTo(group.width - 32, .01));
          expect(
            find.text("OpenNGC, via the app's bundled catalogue"),
            findsOneWidget,
          );
          expect(find.text('Right ascension (J2000)'), findsOneWidget);
          expect(find.text('Declination (J2000)'), findsOneWidget);
          expect(t.takeException(), isNull);
        },
      );
    }
  }
}
