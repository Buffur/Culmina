// Optional evidence export for the bounded 2026-10-26 Wave 1 regressions.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/core/theme/app_theme.dart';

import 'sdk_fonts.dart';

final wave1CaptureKey = GlobalKey();
Future<void> Function(String)? wave1NativeCapture;
bool get wave1IsNative => Platform.isAndroid;

Widget wave1App(
  String theme, {
  required Widget home,
  GlobalKey<NavigatorState>? navigatorKey,
}) => RepaintBoundary(
  key: wave1CaptureKey,
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    navigatorKey: navigatorKey,
    theme: switch (theme) {
      'dark' => AppTheme.dark,
      'field' => AppTheme.fieldTheme,
      _ => AppTheme.light,
    },
    builder: (context, child) => theme == 'field'
        ? ColorFiltered(colorFilter: AppTheme.fieldFilter, child: child!)
        : child!,
    home: home,
  ),
);

Future<void> loadWave1Font() async {
  if (!wave1IsNative) {
    for (final family in ['Roboto', 'FlutterTest']) {
      final loader = FontLoader(family);
      for (final name in [
        'roboto-regular.ttf',
        'roboto-medium.ttf',
        'roboto-bold.ttf',
      ]) {
        loader.addFont(
          sdkMaterialFont(name)!.readAsBytes().then(ByteData.sublistView),
        );
      }
      await loader.load();
    }
    await (FontLoader('MaterialIcons')..addFont(
          sdkMaterialFont('materialicons-regular.otf')!
              .readAsBytes()
              .then(ByteData.sublistView),
        ))
        .load();
  }
  await (FontLoader(
    'Geist',
  )..addFont(rootBundle.load('assets/fonts/Geist.ttf'))).load();
}

Future<void> captureWave1(WidgetTester tester, String name) async {
  if (wave1NativeCapture case final capture?) {
    await tester.pump();
    await capture(name);
    return;
  }
  final output = Platform.environment['CULMINA_WAVE1_RENDER_DIR'];
  if (output == null) return;
  await tester.pump();
  await tester.runAsync(() async {
    final boundary =
        wave1CaptureKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    try {
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory(output).create(recursive: true);
      await File('$output/$name.png').writeAsBytes(png!.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}
