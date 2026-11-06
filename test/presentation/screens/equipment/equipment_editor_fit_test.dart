// S3.10 (TD-069): on the owner's phone (375 dp wide, font scale 1.0) the
// editor's read-only sensor-size fields showed "9.8" for 9.89. A clipped
// text field raises no layout error, so the accessibility sweep cannot see
// it; this test compares each W × H field's text width with its box. It
// loads the application's bundled Geist font, because an unresolved family
// falls back to the test font and exaggerates each character's width.

import '../../../support/phase2_state_capture.dart';
import '../../../support/wave1_capture.dart';

import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/presentation/screens/equipment/equipment_editor.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../support/in_memory_equipment_repository.dart';
import '../../../support/metadata_candidates.dart';

/// Current resolution/pixel inputs whose numeric text is wider than its box.
/// The derived sensor Text and manual-ratio scrolling are checked separately.
Finder _dimensionInputs() => find.descendant(
  of: find.byWidgetPredicate(
    (widget) => const [
      Key('rigEditor.resolutionWidth'),
      Key('rigEditor.resolutionHeight'),
      Key('equipmentEditor.pixelSize'),
    ].contains(widget.key),
  ),
  matching: find.byType(EditableText),
);

List<String> _clipped(WidgetTester tester) => [
  for (final e in tester.widgetList<EditableText>(_dimensionInputs()))
    if (RegExp(r'^[0-9.]+$').hasMatch(e.controller.text))
      if (tester.renderObject<RenderEditable>(
            find.descendant(
              of: find.byWidget(e),
              matching: find.byWidgetPredicate(
                (w) => w.runtimeType.toString() == '_Editable',
              ),
            ),
          )
          case final r
          when r.getMaxIntrinsicWidth(double.infinity) > r.size.width + 0.5)
        '"${e.controller.text}" needs '
            '${r.getMaxIntrinsicWidth(double.infinity).toStringAsFixed(1)} '
            'in ${r.size.width.toStringAsFixed(1)}',
];

Future<void> _open(
  WidgetTester tester,
  EquipmentDraft draft, {
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => GearViewModel(InMemoryEquipmentRepository()),
      child: MaterialApp(
        theme: phase2Theme(_phase2Theme),
        builder: (_, child) => phase2Frame(child: child!, theme: _phase2Theme),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showEquipmentEditor(context, draft: draft),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

late String _phase2Theme;

void main() {
  for (final theme in ['light', 'dark', 'field']) {
    group('Phase2 $theme', () {
      setUp(() => _phase2Theme = theme);
      setUpAll(loadWave1Font);

      final drafts = {
        'the M4 phone draft': EquipmentDraft.fromCandidate(phoneCandidate()),
        'the seeded rig': EquipmentDraft.fromProfile(
          EquipmentSeeder.defaults.single,
        ),
      };
      for (final scale in [1.0, 1.3, 2.0]) {
        for (final MapEntry(key: name, value: draft) in drafts.entries) {
          testWidgets(
            'numeric fields show their whole value on a 375 dp phone: '
            '$name, text ${(scale * 100).round()} %',
            (tester) async {
              await _open(tester, draft, textScale: scale);
              expect(
                _dimensionInputs(),
                findsNWidgets(3),
                reason: 'current resolution and pixel controls must exist',
              );
              final sensor = find.byKey(const Key('rigEditor.sensorSizeValue'));
              expect(sensor, findsOneWidget);
              final sensorParagraph = tester.renderObject<RenderParagraph>(
                find.descendant(of: sensor, matching: find.byType(RichText)),
              );
              expect(sensorParagraph.didExceedMaxLines, isFalse);
              expect(
                sensorParagraph.size.height + .5,
                greaterThanOrEqualTo(
                  sensorParagraph.getMinIntrinsicHeight(
                    sensorParagraph.size.width,
                  ),
                ),
              );
              if (name == 'the seeded rig' && scale == 2.0) {
                final ratio = find.byKey(const Key('rigEditor.focalRatio'));
                await tester.ensureVisible(ratio);
                final editFinder = find.descendant(
                  of: ratio,
                  matching: find.byType(EditableText),
                );
                final derived = tester.widget<EditableText>(editFinder);
                final original = draft.initial.focalRatio;
                expect(derived.controller.text, original);
                expect(
                  derived.readOnly,
                  isTrue,
                  reason: 'diameter owns the calculated ratio',
                );
                expect(
                  find.text('From focal length ÷ diameter'),
                  findsOneWidget,
                );
                final diameter = find.byKey(const Key('rigEditor.diameter'));
                await tester.ensureVisible(diameter);
                await tester.enterText(diameter, '');
                await tester.pumpAndSettle();
                final edit = tester.widget<EditableText>(editFinder);
                expect(
                  edit.readOnly,
                  isFalse,
                  reason: 'clearing diameter enables manual ratio editing',
                );
                expect(
                  edit.controller.text,
                  original,
                  reason: 'mode transition keeps all calculated digits',
                );
                await tester.ensureVisible(ratio);
                await tester.showKeyboard(ratio);
                await tester.enterText(ratio, original);
                await tester.pumpAndSettle();
                final render = tester.renderObject<RenderEditable>(
                  find.descendant(
                    of: editFinder,
                    matching: find.byWidgetPredicate(
                      (w) => w.runtimeType.toString() == '_Editable',
                    ),
                  ),
                );
                expect(
                  render.offset.pixels,
                  greaterThan(0),
                  reason: 'full precision remains horizontally accessible at the caret',
                );
                expect(
                  edit.controller.text,
                  original,
                  reason: 'focus and scroll preserve all stored digits',
                );
                await capturePhase2State(
                  tester,
                  package: 'package3',
                  state: 'rig-focal-ratio-precision-horizontal-edit-200pct',
                  theme: _phase2Theme,
                );
                tester.testTextInput.hide();
              }
              // Scroll the editor through, checking every part.
              final problems = <String>{..._clipped(tester)};
              final list = find.descendant(
                of: find.byKey(const Key('rigEditor.scroll')),
                matching: find.byType(Scrollable),
                matchRoot: true,
              );
              for (var i = 0; i < 6; i++) {
                await tester.drag(list.first, const Offset(0, -250));
                await tester.pumpAndSettle();
                problems.addAll(_clipped(tester));
              }
              expect(problems, isEmpty);
            },
          );
        }
      }
    });
  }
}
