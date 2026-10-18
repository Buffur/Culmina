// ADR-021 (F03): the capture-evidence value types. Absent or unreadable
// values read as unrecorded; bounds and the privacy rule (a basename only)
// hold; an unread file carries no dimensions or compression (D3 A).

import 'dart:convert';

import 'package:astroplan/domain/models/capture_evidence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('C1 white balance', () {
    test('round trips every mode through the stored columns and JSON', () {
      for (final wb in [
        WhiteBalance.auto(),
        WhiteBalance.preset(WhiteBalancePreset.cloudy, tint: -3),
        WhiteBalance.kelvin(5600, tint: 2.5),
        WhiteBalance.custom(),
      ]) {
        expect(
          WhiteBalance.fromStored(
            wb.mode.name,
            wb.preset?.name,
            wb.kelvinK,
            wb.tint,
          ),
          wb,
        );
        expect(WhiteBalance.fromJson(jsonDecode(jsonEncode(wb.toJson()))), wb);
      }
    });

    test('unrecorded, unknown or incomplete values read as unrecorded', () {
      expect(WhiteBalance.fromStored(null, null, null, null), isNull);
      expect(WhiteBalance.fromStored('daylightPlus', null, null, null), isNull);
      expect(WhiteBalance.fromStored('preset', 'neon', null, null), isNull);
      expect(WhiteBalance.fromStored('kelvin', null, null, null), isNull);
      expect(WhiteBalance.fromStored('kelvin', null, 999, null), isNull);
      expect(WhiteBalance.fromJson('auto'), isNull);
    });

    test('kelvin and tint bounds are sanity bounds', () {
      expect(WhiteBalance.kelvin(1000).kelvinK, 1000);
      expect(WhiteBalance.kelvin(40000).kelvinK, 40000);
      expect(() => WhiteBalance.kelvin(999), throwsArgumentError);
      expect(() => WhiteBalance.kelvin(40001), throwsArgumentError);
      expect(() => WhiteBalance.custom(tint: 1000.5), throwsArgumentError);
      expect(() => WhiteBalance.custom(tint: double.nan), throwsArgumentError);
    });

    test('auto carries no tint', () {
      expect(WhiteBalance.auto().tint, isNull);
      expect(WhiteBalance.fromStored('auto', null, null, 7)?.tint, isNull);
    });
  });

  test('C3 focus mode: af, mf, else unrecorded', () {
    expect(FocusMode.tryParse('af'), FocusMode.af);
    expect(FocusMode.tryParse('mf'), FocusMode.mf);
    expect(FocusMode.tryParse('AF'), isNull);
    expect(FocusMode.tryParse(null), isNull);
  });

  group('C4 field origins', () {
    test('round trip, with descriptor and evidence', () {
      final origins = FieldOrigins()
          .withOrigin(
            CaptureField.exposure,
            FieldOrigin(
              OriginKind.file,
              'IMG_0845.dng',
              evidence: {'tag': 'ExposureTime (33434)'},
            ),
          )
          .withOrigin(
            CaptureField.filter,
            FieldOrigin(OriginKind.copied, 'from the Ha block · 300 s'),
          );
      expect(FieldOrigins.decode(origins.encode()), origins);
      expect(
        FieldOrigins.decode(origins.encode())[CaptureField.exposure]?.evidence,
        {'tag': 'ExposureTime (33434)'},
      );
    });

    test('a field without an entry is unrecorded, never entered', () {
      expect(FieldOrigins.none[CaptureField.wb], isNull);
      expect(FieldOrigins.decode(null).isEmpty, isTrue);
      expect(FieldOrigins.none.encode(), isNull);
    });

    test('an edit replaces only that field with entered', () {
      final o = FieldOrigins({
        CaptureField.exposure: FieldOrigin(OriginKind.file, 'a.dng'),
        CaptureField.count: FieldOrigin(OriginKind.copied, 'from L'),
      }).edited(CaptureField.exposure);
      expect(o[CaptureField.exposure]?.kind, OriginKind.entered);
      expect(o[CaptureField.count]?.kind, OriginKind.copied);
    });

    test('unknown fields and kinds are skipped; bad JSON reads as none', () {
      final read = FieldOrigins.fromJson({
        'exposure': {'k': 'file', 'd': 'a.dng'},
        'iso2': {'k': 'file', 'd': 'a.dng'},
        'count': {'k': 'guessed', 'd': 'x'},
        'binning': {'k': 'entered'},
      });
      expect(read.all.keys, [CaptureField.exposure]);
      expect(FieldOrigins.decode('{not json').isEmpty, isTrue);
    });

    test('the descriptor is at most 80 characters and never empty', () {
      expect(
        FieldOrigin(OriginKind.entered, 'x' * 100).descriptor,
        hasLength(FieldOrigin.maxDescriptorLength),
      );
      expect(() => FieldOrigin(OriginKind.entered, '  '), throwsArgumentError);
    });
  });

  group('C6 file evidence', () {
    test('a read file round trips; the label is a basename only (C5)', () {
      final f = FileEvidence(
        bytes: 25172524,
        format: 'DNG',
        read: true,
        width: 4096,
        height: 3072,
        bitsPerSample: 16,
        compression: FileCompression.none,
        binning: 1,
        label: '/storage/emulated/0/DCIM/IMG_0845.dng',
      );
      expect(f.format, 'dng');
      expect(f.label, 'IMG_0845.dng');
      expect(FileEvidence.decode(f.encode()), f);
      expect(
        FileEvidence(
          bytes: 1,
          format: 'jpeg',
          read: true,
          label: r'C:\Users\me\a.jpg',
        ).label,
        'a.jpg',
      );
    });

    test('an unread file (D3 A) carries no dimensions or compression', () {
      final f = FileEvidence(
        bytes: 31457280,
        format: 'recognized:cr3',
        read: false,
        width: 6000,
        height: 4000,
        compression: FileCompression.lossy,
        label: 'IMG_1.CR3',
      );
      expect((f.width, f.height, f.compression), (null, null, null));
      expect(FileEvidence.decode(f.encode())?.read, isFalse);
    });

    test('invalid values are refused; unreadable JSON reads as none', () {
      expect(
        () => FileEvidence(bytes: 0, format: 'dng', read: true, label: 'a'),
        throwsArgumentError,
      );
      expect(
        () => FileEvidence(bytes: 1, format: 'bmp', read: true, label: 'a'),
        throwsArgumentError,
      );
      expect(
        () => FileEvidence(bytes: 1, format: 'dng', read: true, label: '/'),
        throwsArgumentError,
      );
      expect(FileEvidence.decode('{"bytes": 5}'), isNull);
      expect(FileEvidence.decode('[]'), isNull);
      expect(FileEvidence.decode(null), isNull);
    });
  });

  test('C7 capture format: known names, else unknown', () {
    expect(CaptureFormat.tryParse('fits16'), CaptureFormat.fits16);
    expect(CaptureFormat.tryParse('fits64'), isNull);
  });
}
