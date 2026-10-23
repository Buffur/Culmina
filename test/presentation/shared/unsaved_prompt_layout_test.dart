// QA-05 (phone QA 2026-10-23): the plan's "Unsaved changes" prompt lays its
// actions out as plan.html `#leave-plan .leave-actions` (accepted reference
// 86873ce): a wrapping row, end-aligned, 8 apart — at a 375 dp phone Cancel
// and Discard share a row and "Save and leave" wraps below; on a wide screen
// all three share one. Before, the dialog's overflow bar stacked all three.
// Geist is loaded so the buttons have their real widths.

import 'dart:async';
import 'dart:io';

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/presentation/shared/confirmation_patterns.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final _cancel = find.byKey(const Key('unsaved.cancel'));
final _discard = find.byKey(const Key('unsaved.discard'));
final _save = find.byKey(const Key('unsaved.save'));

Future<void> _open(
  WidgetTester tester, {
  required Size size,
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  late BuildContext context;
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          body: Builder(
            builder: (c) {
              context = c;
              return const SizedBox.expand();
            },
          ),
        ),
      ),
    ),
  );
  unawaited(askUnsavedChanges(context, plan: 'Andromeda Galaxy'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    final bytes = File('assets/fonts/Geist.ttf').readAsBytesSync();
    await (FontLoader(
      'Geist',
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  });

  testWidgets('at 375 dp: Cancel and Discard share a row, Save and leave '
      'wraps below, all end-aligned and 8 apart', (tester) async {
    await _open(tester, size: const Size(375, 792));
    final cancel = tester.getRect(_cancel);
    final discard = tester.getRect(_discard);
    final save = tester.getRect(_save);

    expect(cancel.center.dy, discard.center.dy, reason: 'one row');
    expect(discard.left - cancel.right, closeTo(8, 0.5));
    expect(save.top - discard.bottom, closeTo(8, 0.5));
    expect(save.right, closeTo(discard.right, 0.5), reason: 'end-aligned');
    expect(
      save.width,
      lessThan(discard.right - cancel.left),
      reason: 'the save keeps its own width, as `width:auto`',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('on a wide screen the three actions share one row', (
    tester,
  ) async {
    await _open(tester, size: const Size(800, 900));
    final cancel = tester.getRect(_cancel);
    final discard = tester.getRect(_discard);
    final save = tester.getRect(_save);

    expect(cancel.center.dy, discard.center.dy);
    expect(save.center.dy, discard.center.dy);
    expect(cancel.right < discard.left && discard.right < save.left, isTrue);
  });

  testWidgets('at 200 % text the actions wrap without overflow and stay '
      'tappable', (tester) async {
    await _open(tester, size: const Size(375, 792), textScale: 2);
    expect(tester.takeException(), isNull);
    for (final f in [_cancel, _discard, _save]) {
      expect(f.hitTestable(), findsOneWidget);
      expect(tester.getSize(f).height, greaterThanOrEqualTo(48));
    }
  });
}
