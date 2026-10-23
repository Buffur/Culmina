// Owner, 2026-10-23 (second brief): the full launch gesture is shown before
// the app opens; data readiness never cuts it short; the app opens once,
// only when the gesture is done and the app is ready; reduced motion does
// not wait out the gesture; a failed start shows Retry; a gesture paused in
// the background continues where it was.

import 'dart:async';

import 'package:astroplan/core/units/display_units.dart';
import 'package:astroplan/presentation/shared/culmina_mark_geometry.dart';
import 'package:astroplan/presentation/shared/launch_gate.dart';
import 'package:astroplan/presentation/shared/startup_mark.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

const _gesture = CulminaLaunchTimeline.gesture;
final _exit = CulminaLaunchTimeline.markOut + CulminaLaunchTimeline.fieldOut;
const _ms = Duration(milliseconds: 1);

/// One frame: an animation takes its start time from the frame after it is
/// started.
const _frameTime = Duration(milliseconds: 16);

class _App extends StatefulWidget {
  const _App(this.onTap);

  final VoidCallback onTap;
  static int built = 0;

  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> {
  @override
  void initState() {
    super.initState();
    _App.built++;
  }

  @override
  Widget build(BuildContext context) => Center(
    child: GestureDetector(
      onTap: widget.onTap,
      child: const SizedBox.square(
        dimension: 600,
        child: Text('The app', key: Key('app')),
      ),
    ),
  );
}

class _Harness {
  int shown = 0;
  int initializeCalls = 0;
  int taps = 0;

  LaunchGate gate({
    required Future<Widget> Function() ready,
    Future<void>? splashGone,
    LaunchLook look = const LaunchLook(appearance: Appearance.dark),
  }) => LaunchGate(
    look: look,
    splashGone: splashGone,
    onShown: () => shown++,
    initialize: () {
      initializeCalls++;
      return ready();
    },
  );

  Future<Widget> after(Duration d) =>
      Future.delayed(d, () => _App(() => taps++));
}

LaunchGestureFrame _frame(WidgetTester tester) =>
    (tester
                .widget<CustomPaint>(
                  find.descendant(
                    of: find.byKey(const Key('launch.mark')),
                    matching: find.byType(CustomPaint),
                  ),
                )
                .painter!
            as CulminaMarkPainter)
        .frame;

bool _appMounted() => find.byKey(const Key('app')).evaluate().isNotEmpty;

void main() {
  setUp(() => _App.built = 0);

  testWidgets('ready at once: the whole gesture plays first, then one reveal', (
    tester,
  ) async {
    final h = _Harness();
    await tester.pumpWidget(h.gate(ready: () => h.after(_ms * 80)));
    expect(
      _frame(tester).isStill,
      isTrue,
      reason: 'the first frame is the mark',
    );
    await tester.pump(_ms * 100);
    await tester.pump(_ms * 500);
    expect(_frame(tester).isStill, isFalse, reason: 'the gesture is playing');
    expect(_appMounted(), isFalse, reason: 'ready, but not shown early');
    await tester.pump(_gesture - _ms * 620);
    expect(_appMounted(), isFalse);
    // The gesture's clock started at the frame after pumpWidget (100 ms).
    await tester.pump(_ms * 140); // the gesture has ended
    await tester.pump(_frameTime);
    expect(_appMounted(), isTrue);
    expect(h.shown, 0, reason: 'still under the launch background');
    await tester.pump(_frameTime); // the exit's first frame
    await tester.pump(_exit);
    await tester.pump(_frameTime);
    expect(h.shown, 1);
    expect(find.byKey(const Key('launch.mark')), findsNothing);
    await tester.pumpAndSettle();
    expect(h.shown, 1);
    expect(_App.built, 1);
  });

  testWidgets('ready mid-gesture: the gesture is not cut short', (
    tester,
  ) async {
    final h = _Harness();
    await tester.pumpWidget(h.gate(ready: () => h.after(_ms * 700)));
    await tester.pump();
    await tester.pump(_ms * 800);
    expect(_frame(tester).isStill, isFalse);
    await tester.pump(_ms * 500); // 1,300 ms in
    expect(_appMounted(), isFalse);
    await tester.pump(_ms * 150);
    await tester.pump();
    expect(_appMounted(), isTrue);
    await tester.pumpAndSettle();
    expect(h.shown, 1);
  });

  testWidgets(
    'ready after the gesture: the still mark waits, a quiet hint, no replay',
    (tester) async {
      final h = _Harness();
      await tester.pumpWidget(h.gate(ready: () => h.after(_gesture * 4)));
      await tester.pump();
      await tester.pump(_gesture + _ms * 50);
      expect(_frame(tester).isStill, isTrue);
      expect(find.byKey(const Key('launch.waiting')), findsNothing);
      await tester.pump(_ms * 1600);
      expect(find.byKey(const Key('launch.waiting')), findsOneWidget);
      expect(_frame(tester).isStill, isTrue, reason: 'the gesture never loops');
      expect(_appMounted(), isFalse);
      await tester.pump(_gesture * 4);
      await tester.pump();
      await tester.pumpAndSettle();
      expect(h.shown, 1);
      expect(_App.built, 1);
    },
  );

  testWidgets('ready as the gesture ends: one transition', (tester) async {
    final h = _Harness();
    await tester.pumpWidget(h.gate(ready: () => h.after(_gesture)));
    await tester.pump();
    await tester.pump(_gesture);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(h.shown, 1);
    expect(_App.built, 1);
  });

  testWidgets('the hidden app takes no taps and is not in the semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final h = _Harness();
    await tester.pumpWidget(h.gate(ready: () => h.after(_ms * 10)));
    await tester.pump();
    await tester.pump(_gesture);
    await tester.pump(_frameTime);
    await tester.pump(_frameTime); // mounted under the launch background
    expect(_appMounted(), isTrue);
    expect(find.text('The app'), findsOneWidget);
    expect(find.bySemanticsLabel('The app'), findsNothing);
    await tester.tapAt(tester.getCenter(find.byKey(const Key('app'))));
    expect(h.taps, 0);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('The app'), findsOneWidget);
    await tester.tap(find.byKey(const Key('app')));
    expect(h.taps, 1);
    semantics.dispose();
  });

  testWidgets('reduced motion: the still mark, no wait for the gesture', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final h = _Harness();
    await tester.pumpWidget(h.gate(ready: () => h.after(_ms * 50)));
    await tester.pump();
    expect(_frame(tester).isStill, isTrue);
    await tester.pump(_ms * 60);
    await tester.pump();
    await tester.pump();
    expect(h.shown, 1, reason: 'shown when ready, not after 1,400 ms');
  });

  testWidgets('a failed start shows Retry after the gesture; Retry starts it', (
    tester,
  ) async {
    final h = _Harness();
    var fail = true;
    await tester.pumpWidget(
      h.gate(
        ready: () async {
          await Future<void>.delayed(_ms * 20);
          if (fail) throw StateError('storage');
          return _App(() => h.taps++);
        },
      ),
    );
    await tester.pump();
    await tester.pump(_ms * 300);
    expect(find.byKey(const Key('launch.error')), findsNothing);
    await tester.pump(_gesture);
    expect(find.byKey(const Key('launch.error')), findsOneWidget);
    fail = false;
    await tester.tap(find.byKey(const Key('launch.retry')));
    await tester.pump(_ms * 30);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(h.initializeCalls, 2);
    expect(h.shown, 1);
  });

  testWidgets('failure Retry has a semantic tap and cannot initialize twice', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final retry = Completer<Widget>();
    var calls = 0;
    await tester.pumpWidget(
      LaunchGate(
        look: const LaunchLook(),
        animate: false,
        initialize: () {
          calls++;
          if (calls == 1) return Future<Widget>.error(StateError('storage'));
          return retry.future;
        },
      ),
    );
    await tester.pumpAndSettle();
    final semantics = tester.getSemantics(
      find.byKey(const Key('launch.retrySemantics')),
    );
    expect(semantics.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    final action = SemanticsActionEvent(
      viewId: tester.view.viewId,
      nodeId: semantics.id,
      type: SemanticsAction.tap,
    );
    tester.binding.performSemanticsAction(action);
    tester.binding.performSemanticsAction(action);
    await tester.pump();
    expect(calls, 2, reason: 'rapid retries share one startup attempt');
    retry.complete(const SizedBox(key: Key('retry.app')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('retry.app')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('a fresh keyed start replaces a completed recovery root', (
    tester,
  ) async {
    var calls = 0;
    Widget start({required bool animate, required String screen}) => LaunchGate(
      key: UniqueKey(),
      look: const LaunchLook(),
      animate: animate,
      initialize: () async {
        calls++;
        return Text(screen);
      },
    );
    await tester.pumpWidget(start(animate: true, screen: 'Recovery'));
    await tester.pumpAndSettle();
    expect(find.text('Recovery'), findsOneWidget);
    await tester.pumpWidget(start(animate: false, screen: 'Fresh database'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('Recovery'), findsNothing);
    expect(find.text('Fresh database'), findsOneWidget);
  });

  testWidgets('a gesture paused in the background continues where it was', (
    tester,
  ) async {
    final h = _Harness();
    await tester.pumpWidget(h.gate(ready: () => h.after(_ms * 10)));
    await tester.pump();
    await tester.pump(_ms * 500);
    // Android sends `inactive` at once and `hidden`/`paused` only after its
    // minimise animation (~0.75 s on HyperOS, measured): frames still run
    // in between, so the gesture must already stop at `inactive`.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump(_ms * 750);
    expect(_frame(tester).isStill, isFalse, reason: 'held where it was');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(_gesture * 10);
    expect(_appMounted(), isFalse, reason: 'background time is not counted');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(_gesture - _ms * 600);
    expect(_appMounted(), isFalse, reason: 'the rest of the gesture plays');
    await tester.pump(_ms * 200);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(h.shown, 1);
  });

  testWidgets('the gesture waits for the Android splash to leave', (
    tester,
  ) async {
    final h = _Harness();
    final gone = Completer<void>();
    await tester.pumpWidget(
      h.gate(ready: () => h.after(_ms * 10), splashGone: gone.future),
    );
    await tester.pump();
    await tester.pump(_ms * 300);
    expect(_frame(tester).isStill, isTrue, reason: 'not under the splash');
    gone.complete();
    await tester.pump();
    await tester.pump(_frameTime); // the gesture's first frame
    await tester.pump(_ms * 500);
    expect(_frame(tester).isStill, isFalse);
    await tester.pumpAndSettle();
    expect(h.shown, 1);
  });

  testWidgets('without word from the splash, the gesture starts anyway', (
    tester,
  ) async {
    final h = _Harness();
    await tester.pumpWidget(
      h.gate(
        ready: () => h.after(_ms * 10),
        splashGone: Completer<void>().future,
      ),
    );
    await tester.pump();
    await tester.pump(_ms * 700); // past the 600 ms safety net
    await tester.pump(_ms * 400);
    expect(_frame(tester).isStill, isFalse);
    await tester.pumpAndSettle();
    expect(h.shown, 1);
  });

  testWidgets('field mode: black launch background, the field mark', (
    tester,
  ) async {
    final h = _Harness();
    await tester.pumpWidget(
      h.gate(
        ready: () => h.after(_ms * 10),
        look: const LaunchLook(fieldMode: true, appearance: Appearance.light),
      ),
    );
    final painter =
        tester
                .widget<CustomPaint>(
                  find.descendant(
                    of: find.byKey(const Key('launch.mark')),
                    matching: find.byType(CustomPaint),
                  ),
                )
                .painter!
            as CulminaMarkPainter;
    expect(painter.colours, CulminaMarkColors.field);
    expect(
      tester.widgetList<ColoredBox>(find.byType(ColoredBox)).first.color,
      CulminaMarkColors.field.background,
    );
    await tester.pumpAndSettle();
  });

  test('the gesture: the static mark at both ends, an accent between', () {
    expect(LaunchGestureFrame.at(0).isStill, isTrue);
    expect(LaunchGestureFrame.at(0.05).isStill, isTrue, reason: '0-150 ms');
    expect(LaunchGestureFrame.at(1).isStill, isTrue);
    expect(LaunchGestureFrame.at(0.9).isStill, isTrue, reason: '1,100-1,400');
    final glint = LaunchGestureFrame.at(0.3);
    expect(glint.glintOpacity, greaterThan(0.9));
    expect(glint.glintEnd, greaterThan(glint.glintStart));
    final peak = LaunchGestureFrame.at(880 / 1400);
    expect(peak.starAccent, closeTo(1, 1e-9));
    expect(peak.starScale, closeTo(CulminaLaunchTimeline.starScale, 1e-9));
    // The light reaches the arc's end before the star takes up the accent.
    expect(LaunchGestureFrame.at(0.5).glintEnd, closeTo(1, 1e-9));
  });

  test('semantics flags are available for the mark', () {
    // Guards the import of the semantics library used by the tests above.
    expect(SemanticsFlag.isButton, isNotNull);
  });
}
