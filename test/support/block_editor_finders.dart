// Finders for the capture-block editor's Hybrid composition: a label above
// each field (`BlockField`), segmented choices for the frame type and the
// focus record, and disclosures for "From a photo" and Details.

import 'package:astroplan/presentation/widgets/capture_plan/block_editor_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The text field or dropdown under the label [label].
Finder blockField(String label) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(BlockField)),
  matching: find.byWidgetPredicate(
    (w) => w is TextFormField || w is DropdownButtonFormField,
  ),
);

/// Chooses [label] in the segmented group keyed [groupKey].
Future<void> chooseSegment(
  WidgetTester tester,
  String groupKey,
  String label,
) async {
  final option = find.descendant(
    of: find.byKey(Key(groupKey)),
    matching: find.text(label),
  );
  await tester.ensureVisible(option);
  await tester.tap(option);
  await tester.pumpAndSettle();
}

/// Opens the editor's disclosure keyed [key] ('blockDialog.photo' or
/// 'blockDialog.details') unless it is open.
Future<void> openBlockDisclosure(WidgetTester tester, String key) async {
  final disclosure = find.byKey(Key(key));
  final open = tester.widget<BlockDisclosure>(disclosure).open;
  if (open) return;
  final header = find.descendant(
    of: disclosure,
    matching: find.byType(InkWell),
  );
  await tester.ensureVisible(header.first);
  await tester.pumpAndSettle();
  await tester.tap(header.first);
  await tester.pumpAndSettle();
}
