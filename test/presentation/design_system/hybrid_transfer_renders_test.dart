// Hybrid transfer (2026-10-22) host renders for web/Flutter pairs. Opt-in,
// outside the quality gate: ASTROPLAN_HYBRID_RENDERS=<directory> runs it.
// ASTROPLAN_HYBRID_SIZE=375x760 (logical app area, DPR 1), _THEMES=light,dark,
// field and _SHOTS=home,settings,... choose the frames. Real app, router,
// ViewModels and an in-memory database on the hybridTransferFixture; bundled
// Geist and Source Serif 4. Host renders only: the Android emulator run is
// the native confirmation.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../support/hybrid_transfer_fixture.dart';
import '../../support/hybrid_transfer_shots.dart';
import '../../support/sdk_fonts.dart';

const _shot = Key('hybrid.render');

Future<void> _loadFonts() async {
  Future<ByteData> sdk(String f) {
    final file = sdkMaterialFont(f);
    if (file == null) throw StateError('$f not in the SDK');
    return file.readAsBytes().then((b) => ByteData.sublistView(b));
  }

  Future<ByteData> asset(String f) =>
      File('assets/fonts/$f').readAsBytes().then(ByteData.sublistView);

  for (final family in ['Roboto', 'FlutterTest']) {
    final roboto = FontLoader(family);
    for (final f in [
      'roboto-regular.ttf',
      'roboto-medium.ttf',
      'roboto-bold.ttf',
    ]) {
      roboto.addFont(sdk(f));
    }
    await roboto.load();
  }
  await (FontLoader('Geist')..addFont(asset('Geist.ttf'))).load();
  await (FontLoader(
    'Source Serif 4',
  )..addFont(asset('SourceSerif4.ttf'))).load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(sdk('materialicons-regular.otf'))).load();
}

Future<void> _settle(WidgetTester tester) => hybridSettle(tester);

void main() {
  final out = Platform.environment['ASTROPLAN_HYBRID_RENDERS'];
  final size = (Platform.environment['ASTROPLAN_HYBRID_SIZE'] ?? '375x760')
      .split('x')
      .map(double.parse)
      .toList();
  final themes = (Platform.environment['ASTROPLAN_HYBRID_THEMES'] ?? 'light')
      .split(',');
  final shots = (Platform.environment['ASTROPLAN_HYBRID_SHOTS'] ?? 'home')
      .split(',');

  for (final theme in themes) {
    testWidgets('Hybrid transfer renders: $theme', skip: out == null, (
      tester,
    ) async {
      await tester.runAsync(_loadFonts);
      tester.view.physicalSize = Size(size[0], size[1]);
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.platformBrightnessTestValue = theme == 'light'
          ? Brightness.light
          : Brightness.dark;
      tester.platformDispatcher.textScaleFactorTestValue = 1;
      tester.platformDispatcher.alwaysUse24HourFormatTestValue = true;
      addTearDown(tester.view.reset);
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
      const pathProvider = MethodChannel('plugins.flutter.io/path_provider');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        pathProvider,
        (call) async => Directory.systemTemp.path,
      );
      await tester.pumpWidget(
        RepaintBoundary(
          key: _shot,
          child: MultiProvider(
            providers: fixture.vm.providers,
            child: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(alwaysUse24HourFormat: true),
                child: const AstroPlanApp(),
              ),
            ),
          ),
        ),
      );
      await _settle(tester);
      final c = HybridRenderContext(tester, fixture);
      for (final name in shots) {
        final step = hybridShots[name];
        if (step == null) throw ArgumentError('Unknown shot $name');
        await step(c);
        await _settle(tester);
        expect(tester.takeException(), isNull, reason: '$name $theme');
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(_shot),
        );
        // Text geometry and style beside the image, for the web comparer.
        final texts = <Map<String, Object?>>[];
        for (final e in find.byType(RichText).evaluate()) {
          final ro = e.renderObject;
          if (ro is! RenderParagraph || !ro.hasSize || !ro.attached) continue;
          final text = ro.text.toPlainText().trim();
          if (text.isEmpty) continue;
          final o = ro.localToGlobal(Offset.zero);
          if (o.dy > size[1] || o.dy + ro.size.height < 0) continue;
          final st = ro.text.style ?? const TextStyle();
          final span = ro.text is TextSpan ? ro.text as TextSpan : null;
          final first = span?.children
              ?.whereType<TextSpan>()
              .firstOrNull
              ?.style;
          final s0 = st.merge(first);
          texts.add({
            'text': text,
            'x': o.dx,
            'y': o.dy,
            'w': ro.size.width,
            'h': ro.size.height,
            'family': s0.fontFamily,
            'size': s0.fontSize,
            'weight': s0.fontWeight?.value,
            'height': s0.height,
            'ls': s0.letterSpacing,
            'color': s0.color == null
                ? null
                : '#${s0.color!.toARGB32().toRadixString(16).padLeft(8, '0')}',
          });
        }
        File(
          '$out/flutter-$name-$theme-${size[0].toInt()}.json',
        ).writeAsStringSync(const JsonEncoder.withIndent(' ').convert(texts));
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          image.dispose();
          await File('$out/flutter-$name-$theme-${size[0].toInt()}.png')
              .writeAsBytes(png!.buffer.asUint8List());
        });
      }
    });
  }
}
