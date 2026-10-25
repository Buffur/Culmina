import 'package:astroplan/presentation/shared/hybrid_icon.dart';
import 'package:astroplan/presentation/shared/hybrid_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final builders = <String, Widget Function(VoidCallback)>{
    'Plan input': (tap) => HybridPlanRow(
      key: const Key('subject'),
      label: 'Target',
      value: 'M31',
      onTap: tap,
    ),
    'Night link': (tap) => HybridNightRow(
      key: const Key('subject'),
      icon: HybridIcons.lucideMoon,
      label: 'Night',
      value: '9 h of dark time',
      onTap: tap,
    ),
    'Radio choice': (tap) => HybridChoiceRow(
      key: const Key('subject'),
      title: 'Synthetic target',
      selected: true,
      onTap: tap,
    ),
  };
  for (final entry in builders.entries) {
    testWidgets(
      '${entry.key}: semantic activation invokes the existing action once',
      (tester) async {
        var taps = 0;
        final handle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            MaterialApp(home: Scaffold(body: entry.value(() => taps++))),
          );
          final node = tester.getSemantics(find.byKey(const Key('subject')));
          expect(
            node.getSemanticsData().hasAction(SemanticsAction.tap),
            isTrue,
          );
          tester.semantics.tap(
            find.semantics.byPredicate((candidate) => candidate.id == node.id),
          );
          await tester.pump();
          expect(taps, 1);
        } finally {
          handle.dispose();
        }
      },
    );
  }
}
