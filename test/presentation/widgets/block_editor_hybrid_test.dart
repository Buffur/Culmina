// OPEN-01 (Hybrid migration): the capture-block editor follows the approved
// web composition (plan.js blockView): the rig named above the form, the
// frame type as a segmented choice, "From a photo" and Details as
// disclosures, labels above the fields, a live total, and a footer that says
// what Apply does with a full-width primary action. The editor's state,
// validation and origins are unchanged (their own tests).

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/domain/models/camera_class.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/presentation/shared/block_text.dart';
import 'package:astroplan/presentation/widgets/capture_plan/capture_block_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/block_editor_finders.dart';

void main() {
  Future<void> open(
    WidgetTester tester, {
    String? rigName = 'ZWO ASI2600MC + 72 mm refractor',
    CameraClass cameraClass = CameraClass.astroColour,
    List<CaptureBlock> blocks = const [],
    bool fromPhoto = false,
    bool pickOnOpen = false,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showCaptureBlockDialog(
                context,
                rigName: rigName,
                cameraClass: cameraClass,
                blocks: blocks,
                pickOnOpen: pickOnOpen,
                fromPhoto: fromPhoto ? (_) async => null : null,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  String total(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('blockDialog.total'))).data!;

  testWidgets('the rig is named above the form, or said to be missing', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Rig: ZWO ASI2600MC + 72 mm refractor'), findsOneWidget);
    await tester.tap(find.byKey(const Key('blockDialog.cancel')));
    await tester.pumpAndSettle();
    await open(tester, rigName: null);
    expect(find.text('Rig: none chosen'), findsOneWidget);
  });

  testWidgets('the frame type is a segmented choice of every type; choosing '
      'one changes the form', (tester) async {
    final light = CaptureBlock(
      frameType: FrameType.light,
      filterName: 'Ha',
      exposureTimeSeconds: 300,
      frameCount: 20,
    );
    await open(tester, blocks: [light]);
    final handle = tester.ensureSemantics();
    for (final t in FrameType.values) {
      expect(
        find.byKey(Key('blockDialog.frameType.${t.name}')),
        findsOneWidget,
      );
    }
    expect(
      tester.getSemantics(find.byKey(const Key('blockDialog.frameType.light'))),
      isSemantics(isChecked: true, isInMutuallyExclusiveGroup: true),
    );
    await chooseSegment(tester, 'blockDialog.frameType', 'Dark');
    expect(
      tester.getSemantics(find.byKey(const Key('blockDialog.frameType.dark'))),
      isSemantics(isChecked: true),
    );
    // A dark matches the light: its source and inherited values show.
    expect(find.byKey(const Key('blockDialog.inherited')), findsOneWidget);
    expect(find.byKey(const Key('blockDialog.filter')), findsNothing);
    handle.dispose();
  });

  testWidgets('a screen reader hears each label on its text field', (
    tester,
  ) async {
    await open(tester);
    final handle = tester.ensureSemantics();
    for (final label in ['Exposure (seconds)', 'Frames', 'Gain (optional)']) {
      expect(
        find.bySemanticsLabel(RegExp('^${RegExp.escape(label)}')),
        findsOneWidget,
        reason: label,
      );
      expect(
        tester.getSemantics(
          find.bySemanticsLabel(RegExp('^${RegExp.escape(label)}')),
        ),
        isSemantics(isTextField: true),
        reason: '$label names the text field itself',
      );
    }
    handle.dispose();
  });

  testWidgets('labels sit above their fields, with the example hint', (
    tester,
  ) async {
    await open(tester);
    for (final label in ['Exposure (seconds)', 'Frames', 'Gain (optional)']) {
      final labelBox = tester.getRect(find.text(label));
      final fieldBox = tester.getRect(blockField(label));
      expect(labelBox.bottom, lessThanOrEqualTo(fieldBox.top), reason: label);
    }
    expect(find.text('For example 60, 2.5 or 1/125.'), findsOneWidget);
  });

  testWidgets('the live total follows the typed exposure and frames', (
    tester,
  ) async {
    await open(tester);
    expect(total(tester), 'Enter exposure and frames to see the total.');
    await tester.enterText(find.byKey(const Key('blockDialog.exposure')), '60');
    await tester.enterText(find.byKey(const Key('blockDialog.count')), '100');
    await tester.pump();
    expect(total(tester), '= 1 h 40 min of integration');
    await tester.enterText(
      find.byKey(const Key('blockDialog.exposure')),
      '1/0',
    );
    await tester.pump();
    expect(total(tester), 'Enter exposure and frames to see the total.');
    await tester.enterText(find.byKey(const Key('blockDialog.exposure')), '30');
    await chooseSegment(tester, 'blockDialog.frameType', 'Flat');
    await tester.enterText(find.byKey(const Key('blockDialog.exposure')), '2');
    await tester.pump();
    expect(
      total(tester),
      '= 3 min 20 s of planned flat frames, not integration',
    );
  });

  testWidgets('"From a photo" is a closed disclosure until opened; opening '
      'the editor to pick opens it', (tester) async {
    await open(tester, fromPhoto: true);
    expect(find.byKey(const Key('blockDialog.photo')), findsOneWidget);
    expect(find.byKey(const Key('blockDialog.fromPhoto')), findsNothing);
    await openBlockDisclosure(tester, 'blockDialog.photo');
    expect(find.byKey(const Key('blockDialog.fromPhoto')), findsOneWidget);
    await tester.tap(find.byKey(const Key('blockDialog.cancel')));
    await tester.pumpAndSettle();

    await open(tester, fromPhoto: true, pickOnOpen: true);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('blockDialog.fromPhoto')), findsOneWidget);
  });

  testWidgets('Details holds binning and timing and says them while closed', (
    tester,
  ) async {
    final light = CaptureBlock(
      frameType: FrameType.light,
      exposureTimeSeconds: 300,
      frameCount: 20,
    );
    await open(tester, blocks: [light]);
    final details = find.byKey(const Key('blockDialog.details'));
    expect(
      find.descendant(
        of: details,
        matching: find.text('Binning 1x1 · Inside the imaging window'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('blockDialog.binning')), findsNothing);
    await chooseSegment(tester, 'blockDialog.frameType', 'Bias');
    await tester.tap(find.byKey(const Key('blockDialog.useOther')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: details,
        matching: find.textContaining('Taken outside the imaging window'),
      ),
      findsOneWidget,
    );
    await openBlockDisclosure(tester, 'blockDialog.details');
    expect(find.byKey(const Key('blockDialog.policy')), findsOneWidget);
    expect(find.byKey(const Key('blockDialog.binning')), findsOneWidget);
  });

  testWidgets('the footer says what Apply does; the primary action spans the '
      'width', (tester) async {
    await open(tester);
    expect(
      find.textContaining('Adds to this plan. Save plan records it.'),
      findsOneWidget,
    );
    final apply = tester.getRect(find.byKey(const Key('blockDialog.submit')));
    expect(apply.width, closeTo(412 - 32, 1));
    expect(apply.height, greaterThanOrEqualTo(48));
    expect(find.byKey(const Key('blockDialog.cancel')), findsOneWidget);
  });

  testWidgets('200 %: the segmented choices wrap whole, nothing overflows', (
    tester,
  ) async {
    await open(tester, textScale: 2, cameraClass: CameraClass.dslrMirrorless);
    for (final t in FrameType.values) {
      final option = find.byKey(Key('blockDialog.frameType.${t.name}'));
      final label = BlockText.type(t);
      final paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(of: option, matching: find.text(label)),
      );
      expect(paragraph.didExceedMaxLines, isFalse, reason: t.name);
    }
    // The focus record is segmented too (a camera's light block).
    await tester.ensureVisible(find.byKey(const Key('blockDialog.focus')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('blockDialog.focus.mf')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
