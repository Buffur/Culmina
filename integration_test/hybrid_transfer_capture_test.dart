// Hybrid transfer (2026-10-22) Android captures for web/Flutter pairs, on a
// disposable emulator only. Same fixture and steps as the host renders
// (test/support/hybrid_transfer_*.dart): real widgets, router, ViewModels,
// astronomy and SQLite. --dart-define=HYBRID_SHOTS=home,settings and
// HYBRID_THEMES=light,dark,field choose the frames.
import 'dart:io';

import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import '../test/support/hybrid_transfer_fixture.dart';
import '../test/support/hybrid_transfer_shots.dart';

const _shots = String.fromEnvironment('HYBRID_SHOTS', defaultValue: 'home');
const _themes = String.fromEnvironment('HYBRID_THEMES', defaultValue: 'light');
const _scale = String.fromEnvironment('HYBRID_SCALE', defaultValue: '1');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  for (final theme in _themes.split(',')) {
    testWidgets('Hybrid transfer captures: $theme', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = theme == 'light'
          ? Brightness.light
          : Brightness.dark;
      tester.platformDispatcher.textScaleFactorTestValue = double.parse(_scale);
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      AppRouter.router.go(AppRouter.tonight);
      late HybridTransferFixture fixture;
      await tester.runAsync(() async {
        fixture = await HybridTransferFixture.create(
          AppDatabase(NativeDatabase.memory()),
        );
        if (theme == 'field') await fixture.vm.theme.toggleFieldMode();
      });
      addTearDown(() => tester.runAsync(fixture.db.close));
      await tester.pumpWidget(
        MultiProvider(
          providers: fixture.vm.providers,
          child: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(alwaysUse24HourFormat: true),
              child: const AstroPlanApp(),
            ),
          ),
        ),
      );
      await hybridSettle(tester);
      await binding.convertFlutterSurfaceToImage();
      await tester.pump();
      final view = tester.view;
      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['view-$theme'] = {
        'physical': [view.physicalSize.width, view.physicalSize.height],
        'dpr': view.devicePixelRatio,
        'paddingTop': view.padding.top / view.devicePixelRatio,
        'paddingBottom': view.padding.bottom / view.devicePixelRatio,
        'textScale': tester.platformDispatcher.textScaleFactor,
      };
      final c = HybridRenderContext(tester, fixture);
      for (final name in _shots.split(',')) {
        await hybridShots[name]!(c);
        await hybridSettle(tester);
        expect(tester.takeException(), isNull, reason: '$name $theme');
        await binding.takeScreenshot('android-$name-$theme');
      }
      // The screenshots need the device's integration_test plugin; the host
      // gate (tool/check.dart) runs this folder on flutter-tester.
    }, skip: !Platform.isAndroid);
  }
}
