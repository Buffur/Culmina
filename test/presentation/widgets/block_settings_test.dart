// F06 (ADR-021 C1/C3/C4/C13/C14; SP05; AM-02/AM-04): the block editor
// keeps what it is given. A custom filter stays itself. Each field keeps its
// origin until the user changes it. Flats and bias never keep a light's
// proposed exposure. White balance and AF/MF are optional records. Exposure
// may be a fraction. A changed editor asks before Back or a tap outside
// discards it, and its actions say Add block / Apply changes, never Save.

import 'package:astroplan/domain/models/camera_class.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/presentation/widgets/capture_plan/capture_block_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _file = FieldOrigin(OriginKind.file, 'IMG_0845.dng');
final _copied = FieldOrigin(OriginKind.copied, 'from Ha · 300 s × 20');

CaptureBlock _light({
  String? filter = 'L',
  double exposure = 60,
  int count = 10,
  WhiteBalance? wb,
  FocusMode? focus,
  FieldOrigins? origins,
  CaptureGain gain = CaptureGain.none,
}) => CaptureBlock(
  frameType: FrameType.light,
  filterName: filter,
  exposureTimeSeconds: exposure,
  frameCount: count,
  gain: gain,
  whiteBalance: wb,
  focusMode: focus,
  origins: origins,
);

void main() {
  late List<CaptureBlock?> result;

  Future<void> open(
    WidgetTester tester, {
    CaptureBlock? initial,
    CaptureBlock? proposal,
    List<CaptureBlock> blocks = const [],
    CameraClass cameraClass = CameraClass.phone,
    Size size = const Size(800, 1600),
    double textScale = 1,
  }) async {
    result = [];
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => result.add(
                await showCaptureBlockDialog(
                  context,
                  initial: initial,
                  proposal: proposal,
                  blocks: blocks,
                  cameraClass: cameraClass,
                ),
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

  Future<void> tapKey(WidgetTester tester, String key) async {
    final f = find.byKey(Key(key));
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  Future<void> choose(WidgetTester tester, String key, String item) async {
    await tapKey(tester, key);
    await tester.tap(find.text(item).last);
    await tester.pumpAndSettle();
  }

  Future<void> type(WidgetTester tester, String key, String text) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.enterText(find.byKey(Key(key)), text);
    await tester.pump();
  }

  String fieldText(WidgetTester tester, String key) => tester
      .widget<EditableText>(
        find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(EditableText),
        ),
      )
      .controller
      .text;

  Future<void> submit(WidgetTester tester) =>
      tapKey(tester, 'blockDialog.submit');

  group('A1: filters', () {
    testWidgets('an unchanged custom light filter survives an edit', (
      tester,
    ) async {
      await open(tester, initial: _light(filter: 'Ha 3nm Antlia'));
      expect(find.text('Ha 3nm Antlia'), findsOneWidget);
      await submit(tester);
      expect(result.single!.filterName, 'Ha 3nm Antlia');
    });

    testWidgets('a custom flat filter is taken from its light, and kept by '
        '"Use other values"', (tester) async {
      await open(
        tester,
        blocks: [_light(filter: 'Sloan r')],
        cameraClass: CameraClass.astroMono,
      );
      await choose(tester, 'blockDialog.frameType', 'Flat');
      await tapKey(tester, 'blockDialog.useOther');
      expect(find.text('Sloan r'), findsWidgets);
      await type(tester, 'blockDialog.exposure', '2');
      await type(tester, 'blockDialog.count', '20');
      await submit(tester);
      expect(result.single!.filterName, 'Sloan r');
    });

    // TD-108 (AUD-03): the audit's L-eXtreme case, through a type switch.
    testWidgets('a custom filter survives a type switch and back', (
      tester,
    ) async {
      await open(tester, initial: _light(filter: 'L-eXtreme'));
      await choose(tester, 'blockDialog.frameType', 'Flat');
      expect(find.text('L-eXtreme'), findsOneWidget);
      await choose(tester, 'blockDialog.frameType', 'Light');
      await submit(tester);
      expect(result.single!.filterName, 'L-eXtreme');
    });

    testWidgets('no filter stays no filter', (tester) async {
      await open(tester, initial: _light(filter: null));
      await submit(tester);
      expect(result.single!.filterName, isNull);
    });

    test('the domain still bounds a filter name', () {
      expect(() => _light(filter: 'x' * 33), throwsArgumentError);
      expect(_light(filter: 'x' * 32).filterName, hasLength(32));
    });
  });

  group('A2: origins', () {
    testWidgets('an edit replaces only the changed field\'s origin; the '
        'others keep theirs, and are shown', (tester) async {
      final initial = _light(
        origins: FieldOrigins({
          CaptureField.exposure: _file,
          CaptureField.filter: _copied,
        }),
      );
      await open(tester, initial: initial);
      // Compact, visible: the field says where its value came from.
      expect(find.text('IMG_0845.dng'), findsOneWidget);
      expect(find.text('From Ha · 300 s × 20'), findsOneWidget);
      await tapKey(tester, 'blockDialog.details');
      expect(
        find.textContaining('Where the values came from:'),
        findsOneWidget,
      );
      await type(tester, 'blockDialog.count', '25');
      await submit(tester);
      final o = result.single!.origins;
      expect(o[CaptureField.exposure], _file);
      expect(o[CaptureField.filter], _copied);
      expect(o[CaptureField.count]!.kind, OriginKind.entered);
      expect(o[CaptureField.wb], isNull, reason: 'still unrecorded');
    });

    testWidgets('changing a sourced value makes it entered', (tester) async {
      await open(
        tester,
        initial: _light(origins: FieldOrigins({CaptureField.exposure: _file})),
      );
      await type(tester, 'blockDialog.exposure', '90');
      expect(find.text('IMG_0845.dng'), findsNothing);
      await submit(tester);
      expect(
        result.single!.origins[CaptureField.exposure]!.kind,
        OriginKind.entered,
      );
    });

    testWidgets('a proposal\'s values are copied from the last light, until '
        'changed', (tester) async {
      await open(
        tester,
        proposal: _light(filter: 'Ha', exposure: 300, count: 20),
        cameraClass: CameraClass.astroMono,
      );
      expect(find.text('From Ha · 300 s × 20'), findsOneWidget);
      await type(tester, 'blockDialog.count', '12');
      await submit(tester);
      final o = result.single!.origins;
      expect(o[CaptureField.exposure], _copied);
      expect(o[CaptureField.binning], _copied);
      expect(o[CaptureField.count]!.kind, OriginKind.entered);
    });

    testWidgets('a new dark records what it inherits from its light', (
      tester,
    ) async {
      await open(
        tester,
        blocks: [_light(filter: 'Ha', exposure: 300, count: 20)],
        cameraClass: CameraClass.astroMono,
      );
      await choose(tester, 'blockDialog.frameType', 'Dark');
      await type(tester, 'blockDialog.count', '15');
      await submit(tester);
      final o = result.single!.origins;
      final inherited = FieldOrigin(
        OriginKind.inherited,
        'from Ha · 300 s × 20',
      );
      expect(o[CaptureField.exposure], inherited);
      expect(o[CaptureField.binning], inherited);
      expect(o[CaptureField.count]!.kind, OriginKind.entered);
    });

    // CHK-F06.A2: a frame-type switch is not an edit of the values it
    // leaves alone, so their origins survive it.
    testWidgets('origins survive a frame-type switch and back', (tester) async {
      await open(
        tester,
        initial: _light(
          origins: FieldOrigins({
            CaptureField.exposure: _file,
            CaptureField.filter: _copied,
          }),
        ),
      );
      await choose(tester, 'blockDialog.frameType', 'Flat');
      await choose(tester, 'blockDialog.frameType', 'Light');
      expect(find.text('IMG_0845.dng'), findsOneWidget);
      await submit(tester);
      final o = result.single!.origins;
      expect(o[CaptureField.exposure], _file);
      expect(o[CaptureField.filter], _copied);
      expect(o[CaptureField.frameType], isNull, reason: 'still a light');

      await open(
        tester,
        proposal: _light(filter: 'Ha', exposure: 300, count: 20),
        cameraClass: CameraClass.astroMono,
      );
      await choose(tester, 'blockDialog.frameType', 'Dark');
      await choose(tester, 'blockDialog.frameType', 'Light');
      expect(fieldText(tester, 'blockDialog.exposure'), '300');
      await type(tester, 'blockDialog.count', '12');
      await submit(tester);
      expect(result.single!.origins[CaptureField.exposure], _copied);
    });

    testWidgets('Cancel changes nothing', (tester) async {
      await open(
        tester,
        initial: _light(origins: FieldOrigins({CaptureField.exposure: _file})),
      );
      await type(tester, 'blockDialog.exposure', '90');
      await tapKey(tester, 'blockDialog.cancel');
      expect(result.single, isNull);
    });
  });

  group('A3: no leaked light exposure; the default filter by class', () {
    testWidgets('a flat or bias does not keep the proposed light exposure; '
        'a light gets it back', (tester) async {
      await open(
        tester,
        proposal: _light(exposure: 300),
        cameraClass: CameraClass.astroMono,
      );
      expect(fieldText(tester, 'blockDialog.exposure'), '300');
      await choose(tester, 'blockDialog.frameType', 'Flat');
      expect(fieldText(tester, 'blockDialog.exposure'), '');
      await choose(tester, 'blockDialog.frameType', 'Bias');
      expect(fieldText(tester, 'blockDialog.exposure'), '');
      await choose(tester, 'blockDialog.frameType', 'Light');
      expect(fieldText(tester, 'blockDialog.exposure'), '300');
      // A typed exposure is the user's: a type switch keeps it.
      await type(tester, 'blockDialog.exposure', '2');
      await choose(tester, 'blockDialog.frameType', 'Flat');
      expect(fieldText(tester, 'blockDialog.exposure'), '2');
    });

    for (final (cls, filter) in [
      (CameraClass.astroMono, 'L'),
      (CameraClass.astroColour, null),
      (CameraClass.phone, null),
      (CameraClass.dslrMirrorless, null),
      (CameraClass.unknown, null),
    ]) {
      testWidgets('a new ${cls.name} light starts with filter $filter', (
        tester,
      ) async {
        await open(tester, cameraClass: cls);
        await type(tester, 'blockDialog.exposure', '30');
        await type(tester, 'blockDialog.count', '5');
        await submit(tester);
        expect(result.single!.filterName, filter);
      });
    }
  });

  group('A4/A5: camera records and the basic entry', () {
    testWidgets('a phone light offers ISO, white balance and AF/MF; none is '
        'required', (tester) async {
      await open(tester);
      expect(find.byKey(const Key('blockDialog.gainValue')), findsOneWidget);
      expect(find.byKey(const Key('blockDialog.wbMode')), findsOneWidget);
      expect(find.byKey(const Key('blockDialog.focus')), findsOneWidget);
      expect(find.byKey(const Key('blockDialog.binning')), findsNothing);
      expect(find.byKey(const Key('blockDialog.gainKind')), findsNothing);
      await type(tester, 'blockDialog.exposure', '1/14');
      await type(tester, 'blockDialog.count', '200');
      await submit(tester);
      final b = result.single!;
      expect(b.exposureTimeSeconds, 1 / 14);
      expect(
        (b.gain, b.whiteBalance, b.focusMode),
        (CaptureGain.none, null, null),
      );
    });

    testWidgets('white balance, preset or Kelvin, and focus are recorded and '
        'survive an unchanged edit', (tester) async {
      await open(tester, cameraClass: CameraClass.dslrMirrorless);
      await type(tester, 'blockDialog.exposure', '30');
      await type(tester, 'blockDialog.count', '20');
      await type(tester, 'blockDialog.gainValue', '800');
      await choose(tester, 'blockDialog.wbMode', 'Kelvin');
      await type(tester, 'blockDialog.wbKelvin', '4500');
      await tapKey(tester, 'blockDialog.details');
      await type(tester, 'blockDialog.tint', '-3');
      await choose(tester, 'blockDialog.focus', 'MF (manual)');
      await submit(tester);
      final b = result.single!;
      expect(b.gain, CaptureGain.iso(800));
      expect(b.whiteBalance, WhiteBalance.kelvin(4500, tint: -3));
      expect(b.focusMode, FocusMode.mf);
      expect(b.origins[CaptureField.wb]!.kind, OriginKind.entered);

      await open(tester, initial: b, cameraClass: CameraClass.dslrMirrorless);
      expect(fieldText(tester, 'blockDialog.wbKelvin'), '4500');
      await submit(tester);
      expect(result.single!.whiteBalance, b.whiteBalance);
      expect(result.single!.focusMode, FocusMode.mf);
      expect(result.single!.origins, b.origins);

      await open(tester, cameraClass: CameraClass.phone);
      await type(tester, 'blockDialog.exposure', '30');
      await type(tester, 'blockDialog.count', '20');
      await choose(tester, 'blockDialog.wbMode', 'Preset');
      await choose(tester, 'blockDialog.wbPreset', 'Cloudy');
      await submit(tester);
      expect(
        result.single!.whiteBalance,
        WhiteBalance.preset(WhiteBalancePreset.cloudy),
      );
    });

    testWidgets('an out-of-range Kelvin or tint fails by its field', (
      tester,
    ) async {
      await open(tester);
      await type(tester, 'blockDialog.exposure', '30');
      await type(tester, 'blockDialog.count', '20');
      await choose(tester, 'blockDialog.wbMode', 'Kelvin');
      await type(tester, 'blockDialog.wbKelvin', '500');
      await submit(tester);
      expect(result, isEmpty, reason: 'still open');
      expect(find.textContaining('A whole number of kelvins'), findsOneWidget);
    });

    testWidgets('an old block without them reads "Not recorded" and stays '
        'unrecorded', (tester) async {
      await open(tester, initial: _light());
      expect(find.text('Not recorded'), findsNWidgets(2));
      await submit(tester);
      expect(
        (result.single!.whiteBalance, result.single!.focusMode),
        (null, null),
      );
    });

    testWidgets('an astro rig hides them but keeps a recorded value, named; '
        'there is never a numeric focus field', (tester) async {
      await open(
        tester,
        initial: _light(wb: WhiteBalance.auto(), focus: FocusMode.af),
        cameraClass: CameraClass.astroColour,
      );
      expect(find.byKey(const Key('blockDialog.wbMode')), findsNothing);
      expect(find.byKey(const Key('blockDialog.focus')), findsNothing);
      expect(
        find.textContaining('white balance Auto, focus AF'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextFormField, 'Focus'), findsNothing);
      await submit(tester);
      expect(result.single!.whiteBalance, WhiteBalance.auto());
      expect(result.single!.focusMode, FocusMode.af);
    });

    testWidgets('fractions and decimals; a zero denominator fails by the '
        'field', (tester) async {
      await open(tester);
      await type(tester, 'blockDialog.count', '5');
      await type(tester, 'blockDialog.exposure', '1/0');
      await submit(tester);
      expect(
        find.text('A fraction needs a denominator above 0'),
        findsOneWidget,
      );
      expect(result, isEmpty);
      await type(tester, 'blockDialog.exposure', '0.25');
      await submit(tester);
      expect(result.single!.exposureTimeSeconds, 0.25);

      await open(tester, initial: _light(exposure: 1 / 250));
      expect(fieldText(tester, 'blockDialog.exposure'), '1/250');
      await submit(tester);
      expect(result.single!.exposureTimeSeconds, 1 / 250);
    });

    // CHK-F06.A6: an error is shown by its field; nothing typed is lost.
    testWidgets('typed values stay when validation shows an error', (
      tester,
    ) async {
      await open(tester, cameraClass: CameraClass.dslrMirrorless);
      await type(tester, 'blockDialog.exposure', '1/0');
      await type(tester, 'blockDialog.count', '25');
      await type(tester, 'blockDialog.gainValue', '800');
      await choose(tester, 'blockDialog.wbMode', 'Kelvin');
      await type(tester, 'blockDialog.wbKelvin', '500');
      await submit(tester);
      expect(result, isEmpty, reason: 'still open');
      expect(
        find.text('A fraction needs a denominator above 0'),
        findsOneWidget,
      );
      expect(find.textContaining('A whole number of kelvins'), findsOneWidget);
      for (final (key, typed) in [
        ('blockDialog.exposure', '1/0'),
        ('blockDialog.count', '25'),
        ('blockDialog.gainValue', '800'),
        ('blockDialog.wbKelvin', '500'),
      ]) {
        expect(fieldText(tester, key), typed, reason: key);
      }
      await type(tester, 'blockDialog.exposure', '1/4');
      await type(tester, 'blockDialog.wbKelvin', '5200');
      await submit(tester);
      final b = result.single!;
      expect(
        (b.exposureTimeSeconds, b.frameCount, b.gain, b.whiteBalance),
        (0.25, 25, CaptureGain.iso(800), WhiteBalance.kelvin(5200)),
      );
    });

    testWidgets('412 × 915 at 200 % with the keyboard open: every field and '
        'Add block stay reachable', (tester) async {
      tester.view.viewInsets = const FakeViewPadding(bottom: 320);
      addTearDown(tester.view.resetViewInsets);
      await open(tester, size: const Size(412, 915), textScale: 2);
      for (final key in [
        'blockDialog.exposure',
        'blockDialog.count',
        'blockDialog.gainValue',
        'blockDialog.wbMode',
        'blockDialog.focus',
      ]) {
        await tester.ensureVisible(find.byKey(Key(key)));
        await tester.pumpAndSettle();
      }
      await type(tester, 'blockDialog.exposure', '30');
      await type(tester, 'blockDialog.count', '20');
      final add = find.byKey(const Key('blockDialog.submit'));
      expect(tester.getRect(add).bottom, lessThanOrEqualTo(915 - 320));
      await tester.tap(add);
      await tester.pumpAndSettle();
      expect(result.single!.frameCount, 20);
      expect(tester.takeException(), isNull, reason: 'no overflow');
    });
  });

  group('A6: the discard guard', () {
    testWidgets('a changed editor asks on Back; Cancel keeps it, Discard '
        'returns nothing', (tester) async {
      await open(tester, initial: _light());
      await type(tester, 'blockDialog.count', '99');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('"L" has changes that are not saved.'), findsOneWidget);
      await tester.tap(find.byKey(const Key('unsaved.cancel')));
      await tester.pumpAndSettle();
      expect(fieldText(tester, 'blockDialog.count'), '99');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('unsaved.discard')));
      await tester.pumpAndSettle();
      expect(result.single, isNull);
    });

    testWidgets('a tap outside asks; dismissing the prompt is Cancel', (
      tester,
    ) async {
      await open(tester);
      await type(tester, 'blockDialog.exposure', '30');
      await tester.tapAt(const Offset(2, 2));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('unsaved.discard')), findsOneWidget);
      await tester.tapAt(const Offset(2, 2)); // dismiss the prompt
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('blockDialog.submit')), findsOneWidget);
      expect(result, isEmpty);
    });

    testWidgets("the prompt's Save applies the block", (tester) async {
      await open(tester, initial: _light());
      await type(tester, 'blockDialog.count', '42');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('unsaved.save')));
      await tester.pumpAndSettle();
      expect(result.single!.frameCount, 42);
    });

    testWidgets('an unchanged editor closes at once; an explicit Cancel '
        'never applies', (tester) async {
      await open(tester, initial: _light());
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('unsaved.discard')), findsNothing);
      expect(result.single, isNull);

      await open(tester, initial: _light());
      await tester.tapAt(const Offset(2, 2));
      await tester.pumpAndSettle();
      expect(result.single, isNull);

      await open(tester, initial: _light());
      await type(tester, 'blockDialog.count', '7');
      await tapKey(tester, 'blockDialog.cancel');
      expect(find.byKey(const Key('unsaved.discard')), findsNothing);
      expect(result.single, isNull);
    });
  });

  group('A7: the block\'s own action, never the plan\'s Save', () {
    testWidgets('Add block for a new block, Apply changes for an edit, with '
        'the scope said', (tester) async {
      await open(tester);
      expect(find.text('Add block'), findsOneWidget);
      expect(find.text('Save'), findsNothing);
      expect(
        find.textContaining('Adds the block to this plan'),
        findsOneWidget,
      );
      await tapKey(tester, 'blockDialog.cancel');

      await open(tester, initial: _light());
      expect(find.text('Apply changes'), findsOneWidget);
      expect(find.text('Save'), findsNothing);
      expect(
        find.textContaining('Changes the block in this plan, with Undo'),
        findsOneWidget,
      );
    });
  });
}
