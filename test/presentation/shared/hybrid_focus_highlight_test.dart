import 'package:astroplan/presentation/shared/hybrid_focus_highlight.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('settled keyboard focus does not request perpetual frames', (
    t,
  ) async {
    await t.pumpWidget(
      MaterialApp(
        builder: (context, child) => HybridFocusHighlight(child: child!),
        home: Scaffold(
          body: TextButton(onPressed: () {}, child: const Text('Action')),
        ),
      ),
    );
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.pumpAndSettle();
    expect(FocusManager.instance.highlightMode, FocusHighlightMode.traditional);
    expect(t.binding.hasScheduledFrame, isFalse);
    await t.pump(const Duration(seconds: 2));
    await t.pump();
    expect(t.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('keyboard focus survives editor push/pop and scrolling', (
    tester,
  ) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    final manager = FocusManager.instance;
    final oldStrategy = manager.highlightStrategy;
    manager.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
    addTearDown(() => manager.highlightStrategy = oldStrategy);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => HybridFocusHighlight(child: child!),
        home: Scaffold(
          body: Builder(
            builder: (context) => ListView(
              children: [
                TextButton(
                  focusNode: focus,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const Scaffold(body: TextField(autofocus: true)),
                    ),
                  ),
                  child: const Text('Edit target'),
                ),
                const SizedBox(height: 1200),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(focus.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    Navigator.of(tester.element(find.byType(TextField))).pop();
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isTrue);
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hybrid.keyboardFocusRing')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
