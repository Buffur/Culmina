// Owner, 2026-10-23: the startup mark is the launch mark, still; the
// cover shows it above the app only while a retried startup loads, and
// leaves at once under reduced motion. It is announced as loading, with no
// progress value.

import 'dart:ui' show PictureRecorder;

import 'package:astroplan/presentation/shared/culmina_mark_geometry.dart';
import 'package:astroplan/presentation/shared/startup_mark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {bool disableAnimations = false, Brightness? b}) =>
    MaterialApp(
      theme: ThemeData(brightness: b ?? Brightness.light),
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Scaffold(body: child),
      ),
    );

void main() {
  testWidgets('the mark is still: nothing ticks while it is shown', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const Center(child: StartupMark())));
    expect(tester.hasRunningAnimations, isFalse);
    expect(
      tester.getSize(find.byType(StartupMark)),
      const Size.square(CulminaLaunchTimeline.canvas),
    );
  });

  testWidgets('the surface decides the colours, as on the splash', (
    tester,
  ) async {
    CulminaMarkColors colours() =>
        (tester
                    .widget<CustomPaint>(
                      find.descendant(
                        of: find.byType(StartupMark),
                        matching: find.byType(CustomPaint),
                      ),
                    )
                    .painter!
                as CulminaMarkPainter)
            .colours;
    await tester.pumpWidget(_host(const StartupMark()));
    expect(colours(), CulminaMarkColors.light);
    await tester.pumpWidget(_host(const StartupMark(), b: Brightness.dark));
    await tester.pumpAndSettle(); // MaterialApp animates a theme change
    expect(colours(), CulminaMarkColors.dark);
  });

  testWidgets('announced as loading, with no progress value', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_host(const StartupMark()));
    expect(find.bySemanticsLabel('Loading'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    semantics.dispose();
  });

  testWidgets('the cover shows the mark only while loading', (tester) async {
    await tester.pumpWidget(_host(const StartupCover(loading: true)));
    expect(find.byType(StartupMark), findsOneWidget);
    await tester.pumpWidget(_host(const StartupCover(loading: false)));
    // It fades out (AppMotion.medium), then is gone.
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpAndSettle();
    expect(find.byType(StartupMark), findsNothing);
  });

  testWidgets('reduced motion: the cover leaves without a fade', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const StartupCover(loading: true), disableAnimations: true),
    );
    await tester.pumpWidget(
      _host(const StartupCover(loading: false), disableAnimations: true),
    );
    await tester.pump();
    expect(find.byType(StartupMark), findsNothing);
  });

  test('the painter draws the generated star', () {
    expect(
      CulminaMarkGeometry.star.length,
      2 + 4 * 8,
      reason: 'a move and eight quadratic curves',
    );
    final recorder = PictureRecorder();
    const CulminaMarkPainter(CulminaMarkColors.dark)
        .paint(Canvas(recorder), const Size.square(288));
    recorder.endRecording().dispose();
  });
}
