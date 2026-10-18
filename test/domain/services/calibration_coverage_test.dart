// F09 (TD-107, AUD-02; ADR-021 C15; CAL-1 = PD-12): warnings, missing
// coverage and the CAL-1 proposal use the whole modeled tuple. Filters
// compare trimmed and case-folded, never by alias. An unknown sensitivity is
// advisory for a warning but never proof of coverage. The proposal names each
// needed block once and leaves out what an existing block proves covered.
// No darks under in-camera noise reduction; a flat's or bias's exposure is
// entered, never a light's. Calibration never counts as integration.

import 'package:astroplan/domain/models/camera_class.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/services/calibration_builder.dart';
import 'package:astroplan/domain/services/calibration_match.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

CaptureBlock _light(
  String? filter, {
  double exposure = 300,
  int binning = 1,
  CaptureGain gain = CaptureGain.none,
}) => CaptureBlock(
  frameType: FrameType.light,
  filterName: filter,
  exposureTimeSeconds: exposure,
  frameCount: 20,
  binning: binning,
  gain: gain,
);

CaptureBlock _cal(
  FrameType type, {
  String? filter,
  double exposure = 300,
  int binning = 1,
  CaptureGain gain = CaptureGain.none,
}) => CaptureBlock(
  frameType: type,
  filterName: filter,
  exposureTimeSeconds: exposure,
  frameCount: 20,
  binning: binning,
  gain: gain,
  calibrationPolicy: CalibrationPolicy.outsideWindow,
);

EquipmentProfile _rig(CameraClass c, {bool lenr = false}) => EquipmentProfile(
  id: 1,
  name: 'Rig',
  cameraClass: c,
  inCameraNoiseReduction: lenr,
  sensorWidthMm: 23.5,
  sensorHeightMm: 15.7,
  pixelPitchUm: 3.76,
  resolutionWidthPx: 6248,
  resolutionHeightPx: 4176,
  focalLengthMm: 400,
  focalRatio: 5,
);

const _astro = CameraClass.astroMono;

void main() {
  group('the tuple rule (V13, V14)', () {
    final ha1 = _light('Ha', binning: 1);
    final oiii2 = _light('OIII', binning: 2);
    final flatHa2 = _cal(FrameType.flat, filter: 'Ha', exposure: 2, binning: 2);

    test('V13: a Ha/bin-2 flat covers neither Ha/bin-1 nor OIII/bin-2', () {
      expect(CalibrationMatch.covers(flatHa2, ha1, _astro), isFalse);
      expect(CalibrationMatch.covers(flatHa2, oiii2, _astro), isFalse);
      // The warning says so (the old per-field check found the Ha filter
      // and a bin-2 light and said nothing).
      expect(CalibrationMatch.of(flatHa2, [ha1, oiii2, flatHa2], _astro), [
        CalibrationMismatch.binningMatchesNoLight,
      ]);
      // Missing coverage: both groups.
      expect(
        CalibrationMatch.lightsWithoutFlats([
          ha1,
          oiii2,
          flatHa2,
        ], _rig(_astro)),
        [(filter: 'Ha', binning: 1), (filter: 'OIII', binning: 2)],
      );
    });

    test('V14: "Ha" = " HA "; "H-alpha" ≠ "Ha"; the spelling is kept', () {
      expect(CalibrationMatch.sameFilter('Ha', ' HA '), isTrue);
      expect(CalibrationMatch.sameFilter('H-alpha', 'Ha'), isFalse);
      expect(CalibrationMatch.sameFilter(null, '  '), isTrue);
      final flat = _cal(FrameType.flat, filter: ' HA ', exposure: 2);
      expect(CalibrationMatch.of(flat, [ha1], _astro), isEmpty);
      expect(flat.filterName, 'HA', reason: 'trimmed by the domain only');
    });

    test('an unknown sensitivity warns no one but proves nothing (C15)', () {
      final iso800 = _light('L', gain: CaptureGain.iso(800));
      final unknownDark = _cal(FrameType.dark);
      expect(
        CalibrationMatch.of(unknownDark, [iso800], CameraClass.dslrMirrorless),
        isEmpty,
        reason: 'advisory: no warning',
      );
      expect(
        CalibrationMatch.covers(
          unknownDark,
          iso800,
          CameraClass.dslrMirrorless,
        ),
        isFalse,
      );
      expect(
        CalibrationMatch.covers(
          _cal(FrameType.dark, gain: CaptureGain.iso(800)),
          _light('L'),
          CameraClass.dslrMirrorless,
        ),
        isFalse,
        reason: 'a known value does not prove an unknown one',
      );
      expect(
        CalibrationMatch.covers(unknownDark, _light('L'), CameraClass.unknown),
        isTrue,
        reason: 'neither recorded',
      );
    });

    test("binning a class does not offer is not compared (hidden binning)", () {
      final phone = _light('L', binning: 2);
      final flat = _cal(FrameType.flat, filter: 'L', exposure: 1, binning: 1);
      expect(CalibrationMatch.covers(flat, phone, CameraClass.phone), isTrue);
      expect(CalibrationMatch.covers(flat, phone, _astro), isFalse);
    });
  });

  group('the CAL-1 proposal', () {
    test('a camera: darks per exposure/ISO/binning, flats per filter/binning, '
        'one bias per ISO/binning; each once', () {
      final iso = CaptureGain.iso(800);
      final p = CalibrationBuilder.propose([
        _light('L', exposure: 60, gain: iso),
        _light(' l ', exposure: 60, gain: iso),
        _light('Sloan r', exposure: 120, gain: iso),
      ], _rig(CameraClass.dslrMirrorless));
      String key(ProposedCalibration b) =>
          '${b.type.name} ${b.filterName} ${b.exposureSeconds} ${b.gain.value}';
      expect(p.blocks.map(key), [
        'dark null 60.0 800.0',
        'dark null 120.0 800.0',
        'flat L null 800.0',
        'flat Sloan r null 800.0',
        'bias null null 800.0',
      ]);
      expect(p.darksByCamera, isFalse);
    });

    test('an astro camera: dark flats for every flat, no bias', () {
      final existingFlat = _cal(
        FrameType.flat,
        filter: 'Ha',
        exposure: 3,
        binning: 2,
        gain: CaptureGain.gain(100),
      );
      final p = CalibrationBuilder.propose([
        _light('Ha', binning: 2, gain: CaptureGain.gain(100)),
        _light('OIII', binning: 2, gain: CaptureGain.gain(100)),
        existingFlat,
      ], _rig(_astro));
      expect(p.blocks.where((b) => b.type == FrameType.bias), isEmpty);
      final flats = p.blocks.where((b) => b.type == FrameType.flat).toList();
      expect(flats.map((f) => f.filterName), ['OIII'], reason: 'Ha is covered');
      final darkFlats = p.blocks.where((b) => b.type == FrameType.darkFlat);
      expect(darkFlats.length, 2, reason: 'the plan\'s flat and the new one');
      expect(darkFlats.first.exposureSeconds, 3);
      expect(darkFlats.last.flatIndex, p.blocks.indexOf(flats.single));
    });

    test('a proven duplicate is left out; an unproven one stays visible', () {
      final iso = CaptureGain.iso(800);
      final lights = [_light('L', exposure: 60, gain: iso)];
      final proven = CalibrationBuilder.propose([
        ...lights,
        _cal(FrameType.dark, exposure: 60, gain: iso),
      ], _rig(CameraClass.dslrMirrorless));
      expect(proven.blocks.where((b) => b.type == FrameType.dark), isEmpty);
      final unproven = CalibrationBuilder.propose([
        ...lights,
        _cal(FrameType.dark, exposure: 60),
      ], _rig(CameraClass.dslrMirrorless));
      expect(
        unproven.blocks.where((b) => b.type == FrameType.dark),
        hasLength(1),
      );
    });

    test('in-camera noise reduction: no darks, and it says why', () {
      final p = CalibrationBuilder.propose([
        _light('L'),
      ], _rig(CameraClass.dslrMirrorless, lenr: true));
      expect(p.blocks.where((b) => b.type == FrameType.dark), isEmpty);
      expect(p.darksByCamera, isTrue);
    });

    test('confirm: entered flat/bias exposures, inherited dark exposure, '
        'editable counts, origins; nothing is integration', () {
      final light = _light('Ha', exposure: 300, gain: CaptureGain.iso(800));
      final p = CalibrationBuilder.propose([
        light,
      ], _rig(CameraClass.dslrMirrorless));
      expect(
        () => CalibrationBuilder.confirm(
          p,
          counts: [for (final _ in p.blocks) 20],
          exposures: [for (final _ in p.blocks) null],
          descriptor: (_) => 'from the Ha block',
        ),
        throwsArgumentError,
        reason: "a flat's exposure is never taken from the light",
      );
      final blocks = CalibrationBuilder.confirm(
        p,
        counts: [15, 25, 40],
        exposures: [null, 2, 0.001],
        descriptor: (_) => 'from the Ha block',
      );
      final dark = blocks[0], flat = blocks[1], bias = blocks[2];
      expect((dark.exposureTimeSeconds, dark.frameCount), (300.0, 15));
      expect(dark.origins[CaptureField.exposure]!.kind, OriginKind.inherited);
      expect((flat.exposureTimeSeconds, flat.filterName), (2.0, 'Ha'));
      expect(flat.origins[CaptureField.exposure]!.kind, OriginKind.entered);
      expect(flat.origins[CaptureField.sensitivity]!.kind, OriginKind.copied);
      expect(bias.exposureTimeSeconds, 0.001);
      expect(bias.origins[CaptureField.count]!.kind, OriginKind.entered);

      final before = CaptureBudgetCalculator.calculate(blocks: [light]);
      final after = CaptureBudgetCalculator.calculate(
        blocks: [light, ...blocks],
      );
      expect(after.integrationMs, before.integrationMs);
      expect(after.outsideWindowCalibrationMs, greaterThan(0));
      expect(after.windowLoadMs, before.windowLoadMs, reason: 'outside');
    });
  });
}
