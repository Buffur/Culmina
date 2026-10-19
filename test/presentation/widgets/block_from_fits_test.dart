// F10 (ADR-021 C13, C21; CHK-F10.A1/A2/A4) in the block editor: a FITS
// sub-frame, read by the real reader from a synthetic header, proposes an
// astro camera's exposure, gain, filter as written and symmetric binning.
// A binning the user did not touch follows the file; one the user chose is
// kept and named, as is every other typed value. The file's size is used
// as measured, once, at the binning it was written with.

import 'package:astroplan/domain/metadata/capture_metadata_reader.dart';
import 'package:astroplan/domain/models/camera_class.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/services/block_proposal.dart';
import 'package:astroplan/domain/services/storage_estimate.dart';
import 'package:astroplan/presentation/widgets/capture_plan/capture_block_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fits_fixture.dart';
import '../../support/memory_metadata_source.dart';

/// The N.I.N.A.-style light (300 s, GAIN 100, bin 2 × 2, 3124 × 2088
/// written) with [filter] as its FILTER.
List<int> _fits({String filter = 'L-eXtreme', int binning = 2}) => fitsFile([
  for (final c in ninaLight(
    binning: binning,
    width: 6248 ~/ binning,
    height: 4176 ~/ binning,
    pixelSize: 3.76 * binning,
  ))
    if (c.$1 != 'FILTER') c,
  ('FILTER', filter),
]);

const _length = 13049280;

final _rig = EquipmentProfile(
  id: 1,
  name: 'Astro',
  cameraClass: CameraClass.astroMono,
  sensorWidthMm: 23.49,
  sensorHeightMm: 15.7,
  pixelPitchUm: 3.76,
  resolutionWidthPx: 6248,
  resolutionHeightPx: 4176,
  focalLengthMm: 400,
  focalRatio: 5,
);

void main() {
  late List<CaptureBlock?> result;
  late List<(String, List<int>)> picks;

  Future<BlockProposal?> read(int binning) async {
    final (name, bytes) = picks.removeAt(0);
    return BlockProposal.of(
      name: name,
      reading: await CaptureMetadataReader.read(MemoryMetadataSource(bytes)),
      lengthBytes: _length,
      cameraClass: CameraClass.astroMono,
      rig: _rig,
      binning: binning,
    );
  }

  Future<void> open(WidgetTester tester, {CaptureBlock? initial}) async {
    result = [];
    tester.view.physicalSize = const Size(800, 2400);
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
                  cameraClass: CameraClass.astroMono,
                  fromPhoto: read,
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

  Future<void> choose(WidgetTester tester, String key, String item) async {
    await tapKey(tester, key);
    await tester.tap(find.text(item).last);
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

  testWidgets('an astro camera gets the gain, the custom filter as written '
      'and the binning; Apply stores them with file origins, and the size is '
      'used once', (tester) async {
    picks = [('L_0001.fits', _fits())];
    await open(tester);
    await tapKey(tester, 'blockDialog.fromPhoto');
    expect(review(tester), contains('From L_0001.fits'));
    expect(
      review(tester),
      contains(
        'Proposed: Exposure 300 s · Gain 100 · Filter L-eXtreme · '
        'Binning 2 × 2.',
      ),
    );
    expect(review(tester), isNot(contains('Kept what you typed')));
    expect(text(tester, 'blockDialog.exposure'), '300');
    expect(text(tester, 'blockDialog.gainValue'), '100');
    expect(find.text('L-eXtreme'), findsOneWidget, reason: 'the filter field');
    expect(find.text('Binning 2x2'), findsOneWidget, reason: 'closed Details');
    await tester.enterText(find.byKey(const Key('blockDialog.count')), '20');
    await tapKey(tester, 'blockDialog.submit');

    final b = result.single!;
    expect(b.exposureTimeSeconds, 300);
    expect(b.gain, CaptureGain.gain(100));
    expect(b.filterName, 'L-eXtreme');
    expect(b.binning, 2);
    for (final f in [
      CaptureField.exposure,
      CaptureField.sensitivity,
      CaptureField.filter,
      CaptureField.binning,
      CaptureField.fileSize,
    ]) {
      expect(b.origins[f]!.kind, OriginKind.file, reason: f.name);
      expect(b.origins[f]!.descriptor, 'L_0001.fits', reason: f.name);
    }
    expect(
      (b.fileEvidence!.width, b.fileEvidence!.height, b.fileEvidence!.binning),
      (3124, 2088, 2),
    );
    final frame = StorageEstimate.of(b, _rig);
    expect((frame.basis, frame.bytes), (StorageBasis.blockFile, 13049280.0));
  });

  testWidgets('the binning rule: an untouched binning follows the file; one '
      'the user chose is kept and named, and its size is then not used', (
    tester,
  ) async {
    // Untouched: an edited block's own binning is replaced by the file's.
    picks = [('L_0001.fits', _fits())];
    await open(
      tester,
      initial: CaptureBlock(
        frameType: FrameType.light,
        filterName: 'L',
        exposureTimeSeconds: 120,
        frameCount: 10,
        binning: 3,
        origins: FieldOrigins({CaptureField.binning: FieldOrigin.entered()}),
      ),
    );
    await tapKey(tester, 'blockDialog.fromPhoto');
    expect(find.text('Binning 2x2'), findsOneWidget);
    await tapKey(tester, 'blockDialog.submit');
    expect(result.single!.binning, 2);
    expect(result.single!.origins[CaptureField.binning]!.kind, OriginKind.file);

    // Chosen in this editor: kept, named, entered.
    picks = [('L_0001.fits', _fits())];
    await open(tester);
    await tapKey(tester, 'blockDialog.details');
    await choose(tester, 'blockDialog.binning', '3x3');
    await tapKey(tester, 'blockDialog.fromPhoto');
    expect(
      review(tester),
      contains('Kept what you typed: binning 3 × 3 (the file says 2).'),
    );
    // TD-110: the review already says why the file's size will not count.
    expect(
      review(tester),
      contains(
        "Not the rig's mode (another binning, another pixel count): its "
        'size is not used for storage.',
      ),
    );
    await tester.enterText(find.byKey(const Key('blockDialog.count')), '5');
    await tapKey(tester, 'blockDialog.submit');
    final b = result.single!;
    expect(b.binning, 3);
    expect(b.origins[CaptureField.binning], FieldOrigin.entered());
    // The bin-2 file is never rescaled to bin 3: it is skipped, with why.
    expect(
      StorageEstimate.of(b, _rig).skipped[StorageBasis.blockFile],
      containsAll([StorageConflict.binning, StorageConflict.dimensions]),
    );
  });

  testWidgets('typed values are kept and named; a later file replaces only '
      "the earlier file's values", (tester) async {
    picks = [
      ('L_0001.fits', _fits()),
      ('Ha_0001.fits', _fits(filter: 'Ha 3nm')),
    ];
    await open(tester);
    await tester.enterText(
      find.byKey(const Key('blockDialog.exposure')),
      '120',
    );
    await tester.enterText(
      find.byKey(const Key('blockDialog.gainValue')),
      '200',
    );
    await choose(tester, 'blockDialog.filter', 'OIII');
    await tapKey(tester, 'blockDialog.fromPhoto');
    expect(text(tester, 'blockDialog.exposure'), '120');
    expect(text(tester, 'blockDialog.gainValue'), '200');
    expect(
      review(tester),
      contains(
        'Kept what you typed: exposure 120 s (the file says 300 s); '
        'gain 200 (the file says 100); filter OIII (the file says '
        'L-eXtreme).',
      ),
    );
    expect(find.text('Binning 2x2'), findsOneWidget, reason: 'untouched');

    // Another file: what was typed stays typed; the file's binning follows.
    await tapKey(tester, 'blockDialog.fromPhoto');
    expect(review(tester), contains('From Ha_0001.fits'));
    expect(review(tester), contains('filter OIII (the file says Ha 3nm)'));
    await tester.enterText(find.byKey(const Key('blockDialog.count')), '9');
    await tapKey(tester, 'blockDialog.submit');
    final b = result.single!;
    expect(b.exposureTimeSeconds, 120);
    expect(b.gain, CaptureGain.gain(200));
    expect(b.filterName, 'OIII');
    for (final f in [
      CaptureField.exposure,
      CaptureField.sensitivity,
      CaptureField.filter,
    ]) {
      expect(b.origins[f], FieldOrigin.entered(), reason: f.name);
    }
    expect(b.origins[CaptureField.binning]!.descriptor, 'Ha_0001.fits');
    expect(b.fileEvidence!.label, 'Ha_0001.fits');
  });
}
