// F08 A1–A3 in the block editor: "Take from a photo" shows an inline review
// of what the file proposes and what it only shows. It fills only fields the
// user did not type, keeps what the user typed (named), flags another mode,
// and counts as a change for the discard guard. Cancel, a cancelled pick and
// a read failure change nothing. Repeated picks end the same whatever their
// order. The applied block carries per-field file origins and the file as
// its storage evidence.

import 'package:astroplan/domain/metadata/capture_metadata_reader.dart';
import 'package:astroplan/domain/models/camera_class.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/services/block_proposal.dart';
import 'package:astroplan/presentation/widgets/capture_plan/capture_block_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/jpeg_fixture.dart';
import '../../support/memory_metadata_source.dart';
import '../../support/tiff_fixture.dart';

List<int> _jpeg({required int iso, required int exposureMicro}) {
  final exif = phoneStyleJpegExif();
  exif.exif!
    ..removeWhere((e) => e.tag == 34855 || e.tag == 33434)
    ..addAll([
      FixtureEntry.rational(33434, exposureMicro, 1000000),
      FixtureEntry.short(34855, iso),
      FixtureEntry.long(40962, 4096),
      FixtureEntry.long(40963, 3072),
      FixtureEntry.short(41987, 0),
    ]);
  return jpegFile([exifApp1(exif.build().bytes)]);
}

final _rig = EquipmentProfile(
  id: 1,
  name: 'Phone',
  cameraClass: CameraClass.phone,
  sensorWidthMm: 9.8,
  sensorHeightMm: 7.4,
  pixelPitchUm: 2.4,
  resolutionWidthPx: 4096,
  resolutionHeightPx: 3072,
  focalLengthMm: 6.57,
  focalRatio: 1.6,
);

void main() {
  late List<CaptureBlock?> result;
  late List<Object?> picks; // queued: (name, bytes), null (cancel), or error

  Future<BlockProposal?> read(int binning, {EquipmentProfile? rig}) async {
    final next = picks.removeAt(0);
    if (next == null) return null;
    if (next is Exception) throw next;
    final (name, bytes) = next as (String, List<int>);
    return BlockProposal.of(
      name: name,
      reading: await CaptureMetadataReader.read(MemoryMetadataSource(bytes)),
      lengthBytes: bytes.length,
      cameraClass: CameraClass.phone,
      rig: rig ?? _rig,
      binning: binning,
    );
  }

  Future<void> open(
    WidgetTester tester, {
    CaptureBlock? initial,
    EquipmentProfile? rig,
  }) async {
    result = [];
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => result.add(
                await showCaptureBlockDialog(
                  context,
                  initial: initial,
                  cameraClass: CameraClass.phone,
                  fromPhoto: (b) => read(b, rig: rig),
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
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(key)));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  String text(WidgetTester tester, String key) => tester
      .widget<EditableText>(
        find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(EditableText),
        ),
      )
      .controller
      .text;

  String review(WidgetTester tester) => tester
      .widget<Text>(
        find.descendant(
          of: find.byKey(const Key('blockDialog.review')),
          matching: find.byType(Text),
        ),
      )
      .data!;

  testWidgets('A1: the review lists what is proposed and what is shown; '
      'Apply stores the values with file origins and the file', (tester) async {
    picks = [('IMG_0845.jpg', _jpeg(iso: 800, exposureMicro: 71429))];
    await open(tester);
    await tapKey(tester, 'blockDialog.fromPhoto');
    expect(review(tester), contains('From IMG_0845.jpg'));
    expect(
      review(tester),
      contains('Proposed: Exposure ≈1/14 s · ISO 800 · White balance Auto.'),
    );
    expect(review(tester), contains('ISO 800 (ISO speed)'));
    expect(text(tester, 'blockDialog.gainValue'), '800');
    expect(find.text('IMG_0845.jpg'), findsWidgets, reason: 'field origins');
    await tester.enterText(find.byKey(const Key('blockDialog.count')), '120');
    await tapKey(tester, 'blockDialog.submit');
    final b = result.single!;
    expect(b.exposureTimeSeconds, 0.071429);
    expect(b.gain, CaptureGain.iso(800));
    expect(b.whiteBalance, WhiteBalance.auto());
    expect(b.fileEvidence!.label, 'IMG_0845.jpg');
    for (final f in [
      CaptureField.exposure,
      CaptureField.sensitivity,
      CaptureField.wb,
      CaptureField.fileSize,
    ]) {
      expect(b.origins[f]!.kind, OriginKind.file, reason: f.name);
      expect(b.origins[f]!.descriptor, 'IMG_0845.jpg');
    }
    expect(b.origins[CaptureField.count]!.kind, OriginKind.entered);
  });

  testWidgets('A1: a value the user typed is kept and named', (tester) async {
    picks = [('IMG_0845.jpg', _jpeg(iso: 800, exposureMicro: 71429))];
    await open(tester);
    await tester.enterText(find.byKey(const Key('blockDialog.exposure')), '30');
    await tapKey(tester, 'blockDialog.fromPhoto');
    expect(text(tester, 'blockDialog.exposure'), '30');
    expect(text(tester, 'blockDialog.gainValue'), '800');
    expect(
      review(tester),
      contains('Kept what you typed: exposure 30 s (the file says ≈1/14 s).'),
    );
  });

  testWidgets('A1: a proposed value the user then edits is entered on '
      'Apply, not the file\'s; the untouched ones keep the file', (
    tester,
  ) async {
    picks = [('IMG_0845.jpg', _jpeg(iso: 800, exposureMicro: 71429))];
    await open(tester);
    await tapKey(tester, 'blockDialog.fromPhoto');
    expect(text(tester, 'blockDialog.exposure'), '0.071429');
    await tester.enterText(find.byKey(const Key('blockDialog.exposure')), '20');
    await tester.enterText(find.byKey(const Key('blockDialog.count')), '30');
    await tapKey(tester, 'blockDialog.submit');
    final b = result.single!;
    expect(b.exposureTimeSeconds, 20);
    expect(b.origins[CaptureField.exposure], FieldOrigin.entered());
    expect(b.origins[CaptureField.sensitivity]!.kind, OriginKind.file);
    expect(b.origins[CaptureField.sensitivity]!.descriptor, 'IMG_0845.jpg');
    expect(b.gain, CaptureGain.iso(800));
  });

  testWidgets('A2: pick, edit, pick again: the typed value is kept and '
      'named; the earlier file\'s other values follow the new file', (
    tester,
  ) async {
    picks = [
      ('A.jpg', _jpeg(iso: 100, exposureMicro: 500000)),
      ('B.jpg', _jpeg(iso: 1600, exposureMicro: 2000000)),
    ];
    await open(tester);
    await tapKey(tester, 'blockDialog.fromPhoto');
    await tester.enterText(find.byKey(const Key('blockDialog.exposure')), '45');
    await tapKey(tester, 'blockDialog.fromPhoto');
    expect(text(tester, 'blockDialog.exposure'), '45');
    expect(text(tester, 'blockDialog.gainValue'), '1600');
    expect(review(tester), contains('From B.jpg'));
    expect(
      review(tester),
      contains('Kept what you typed: exposure 45 s (the file says 2 s).'),
    );
    await tester.enterText(find.byKey(const Key('blockDialog.count')), '8');
    await tapKey(tester, 'blockDialog.submit');
    final b = result.single!;
    expect((b.exposureTimeSeconds, b.gain), (45.0, CaptureGain.iso(1600)));
    expect(b.origins[CaptureField.exposure], FieldOrigin.entered());
    expect(b.origins[CaptureField.sensitivity]!.descriptor, 'B.jpg');
    expect(b.fileEvidence!.label, 'B.jpg');
  });

  testWidgets('A2: repeated picks end the same in either order', (
    tester,
  ) async {
    final a = ('A.jpg', _jpeg(iso: 100, exposureMicro: 500000));
    final b = ('B.jpg', _jpeg(iso: 1600, exposureMicro: 2000000));
    Future<CaptureBlock> pickBoth(List<(String, List<int>)> order) async {
      picks = [...order];
      await open(tester);
      await tapKey(tester, 'blockDialog.fromPhoto');
      await tapKey(tester, 'blockDialog.fromPhoto');
      await tester.enterText(find.byKey(const Key('blockDialog.count')), '5');
      await tapKey(tester, 'blockDialog.submit');
      return result.single!;
    }

    final ab = await pickBoth([a, b]);
    expect((ab.exposureTimeSeconds, ab.gain), (2.0, CaptureGain.iso(1600)));
    expect(ab.origins[CaptureField.exposure]!.descriptor, 'B.jpg');
    final ba = await pickBoth([b, a]);
    expect((ba.exposureTimeSeconds, ba.gain), (0.5, CaptureGain.iso(100)));
    expect(ba.origins[CaptureField.exposure]!.descriptor, 'A.jpg');
    // The rule is the same: the last file's values, its origin, its file.
    expect(ab.fileEvidence!.label, 'B.jpg');
    expect(ba.fileEvidence!.label, 'A.jpg');
  });

  testWidgets('A2: another pixel count is flagged visibly', (tester) async {
    picks = [('IMG_0845.jpg', _jpeg(iso: 800, exposureMicro: 71429))];
    await open(
      tester,
      rig: EquipmentProfile(
        id: 1,
        name: 'Phone',
        cameraClass: CameraClass.phone,
        sensorWidthMm: 9.8,
        sensorHeightMm: 7.4,
        pixelPitchUm: 2.4,
        resolutionWidthPx: 4064,
        resolutionHeightPx: 3056,
        focalLengthMm: 6.57,
        focalRatio: 1.6,
      ),
    );
    await tapKey(tester, 'blockDialog.fromPhoto');
    expect(
      review(tester),
      contains(
        "Not the rig's mode (another pixel count): its size is not "
        'used for storage.',
      ),
    );
  });

  testWidgets('A2: an unsaved proposal is a change for the guard; Cancel '
      'and a cancelled pick change nothing', (tester) async {
    picks = [null, ('IMG_0845.jpg', _jpeg(iso: 800, exposureMicro: 71429))];
    await open(
      tester,
      initial: CaptureBlock(
        frameType: FrameType.light,
        filterName: 'Sloan r',
        exposureTimeSeconds: 60,
        frameCount: 10,
      ),
    );
    await tapKey(tester, 'blockDialog.fromPhoto'); // cancelled pick
    expect(find.byKey(const Key('blockDialog.review')), findsNothing);
    await tapKey(tester, 'blockDialog.fromPhoto');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('unsaved.discard')), findsOneWidget);
    await tester.tap(find.byKey(const Key('unsaved.cancel')));
    await tester.pumpAndSettle();
    await tapKey(tester, 'blockDialog.cancel');
    expect(result.single, isNull, reason: 'Cancel stores nothing');
  });

  testWidgets('A3: a custom filter and a recorded source survive a pick', (
    tester,
  ) async {
    picks = [('IMG_0845.jpg', _jpeg(iso: 800, exposureMicro: 71429))];
    final entered = FieldOrigin.entered();
    await open(
      tester,
      initial: CaptureBlock(
        frameType: FrameType.light,
        filterName: 'Sloan r',
        exposureTimeSeconds: 60,
        frameCount: 10,
        focusMode: FocusMode.mf,
        origins: FieldOrigins({
          CaptureField.focusMode: entered,
          CaptureField.count: entered,
        }),
      ),
    );
    await tapKey(tester, 'blockDialog.fromPhoto');
    await tapKey(tester, 'blockDialog.submit');
    final b = result.single!;
    expect(b.filterName, 'Sloan r');
    expect(b.focusMode, FocusMode.mf);
    expect(b.origins[CaptureField.focusMode], entered);
    expect(b.origins[CaptureField.exposure]!.descriptor, 'IMG_0845.jpg');
  });

  testWidgets('A2: a read failure is said and changes nothing', (tester) async {
    picks = [Exception('the picker failed')];
    await open(tester);
    await tapKey(tester, 'blockDialog.fromPhoto');
    expect(find.textContaining("Couldn't read the file"), findsOneWidget);
    expect(find.byKey(const Key('blockDialog.review')), findsNothing);
    expect(text(tester, 'blockDialog.exposure'), '');
  });

  testWidgets('A2: a file that is not a capture file is named, nothing set', (
    tester,
  ) async {
    picks = [('notes.txt', 'hello'.codeUnits)];
    await open(tester);
    await tapKey(tester, 'blockDialog.fromPhoto');
    expect(review(tester), contains("notes.txt can't be read for a block"));
    expect(text(tester, 'blockDialog.exposure'), '');
  });
}
