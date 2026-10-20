import 'package:astroplan/core/theme/hybrid_view_entrance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('view change animates once; input rebuild does not restart it', (
    tester,
  ) async {
    var trigger = 0;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return Scaffold(
              body: HybridViewEntrance(
                trigger: trigger,
                child: const TextField(),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'M31');
    update(() {});
    await tester.pump();
    expect(tester.widget<Opacity>(find.byType(Opacity).first).opacity, 1);
    update(() => trigger++);
    await tester.pump();
    expect(tester.widget<Opacity>(find.byType(Opacity).first).opacity, .72);
    await tester.pumpAndSettle();
    expect(tester.widget<Opacity>(find.byType(Opacity).first).opacity, 1);
    expect(find.text('M31'), findsOneWidget);
  });

  testWidgets('reduced motion renders the complete view immediately', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: HybridViewEntrance(trigger: 1, child: Text('Night')),
        ),
      ),
    );
    expect(find.byType(Opacity), findsNothing);
    expect(find.text('Night'), findsOneWidget);
  });
}
