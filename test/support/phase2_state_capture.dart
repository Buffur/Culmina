import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

const phase2Boundary = Key('phase2.state.capture');

ThemeData phase2Theme(String theme) => switch (theme) {
  'light' => AppTheme.light,
  'dark' => AppTheme.dark,
  'field' => AppTheme.fieldTheme,
  _ => throw ArgumentError.value(theme, 'theme'),
};

/// Preserve the final visible state of an existing behavioral scenario.
/// Intermediate pending/failure branches still need explicit captures.
void phase2Scenario(
  String description,
  WidgetTesterCallback body, {
  required String package,
  required String theme,
}) {
  testWidgets(description, (tester) async {
    await body(tester);
    if (find.byKey(phase2Boundary).evaluate().isNotEmpty) {
      await capturePhase2State(
        tester,
        package: package,
        state: description,
        theme: theme,
      );
    }
  });
}

/// Wrap standalone hosts; AstroPlanApp already owns its Field filter.
Widget phase2Frame({
  required Widget child,
  required String theme,
  bool applyFieldFilter = true,
}) => RepaintBoundary(
  key: phase2Boundary,
  child: theme == 'field' && applyFieldFilter
      ? ColorFiltered(colorFilter: AppTheme.fieldFilter, child: child)
      : child,
);

/// Optional native evidence after the caller's real state assertions.
/// Keep state IDs specific: pending, failed and recovered are separate frames.
Future<void> capturePhase2State(
  WidgetTester tester, {
  required String package,
  required String state,
  required String theme,
}) async {
  final output = Platform.environment['CULMINA_PHASE2_RENDERS'];
  if (output == null) return;
  expect(tester.takeException(), isNull, reason: '$package/$theme/$state');
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(phase2Boundary),
  );
  final frameSize = boundary.size;
  final testDescription = tester.testDescription;
  final mediaElement =
      find.byType(Scaffold).evaluate().firstOrNull ??
      tester.element(find.byKey(phase2Boundary));
  final media = MediaQuery.maybeOf(mediaElement);
  final texts = <Map<String, Object?>>[];
  for (final element in find.byType(RichText).evaluate()) {
    final box = element.renderObject;
    if (box is! RenderParagraph || !box.attached || !box.hasSize) continue;
    final origin = box.localToGlobal(Offset.zero);
    if (origin.dy >= frameSize.height || origin.dy + box.size.height <= 0) {
      continue;
    }
    texts.add({
      'text': box.text.toPlainText(),
      'x': origin.dx,
      'y': origin.dy,
      'width': box.size.width,
      'height': box.size.height,
      'exceedsMaxLines': box.didExceedMaxLines,
    });
  }
  await tester.runAsync(() async {
    final folder = Directory('$output/$package/$theme')
      ..createSync(recursive: true);
    final safeState = state.replaceAll(RegExp(r'[^a-zA-Z0-9_.-]+'), '-');
    final baseStem = safeState.length > 80
        ? safeState.substring(0, 80)
        : safeState;
    var stem = baseStem;
    var ordinal = 1;
    while (File('${folder.path}/$stem.png').existsSync()) {
      ordinal++;
      stem = '$baseStem--$ordinal';
    }
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    File('${folder.path}/$stem.png')
        .writeAsBytesSync(data!.buffer.asUint8List());
    File('${folder.path}/$stem.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'package': package,
        'state': state,
        'test': testDescription,
        'captureOrdinal': ordinal,
        'theme': theme,
        'kind': 'native Flutter host; controlled fixture',
        'width': frameSize.width,
        'height': frameSize.height,
        'textScale': media?.textScaler.scale(1),
        'texts': texts,
      }),
    );
  });
}
