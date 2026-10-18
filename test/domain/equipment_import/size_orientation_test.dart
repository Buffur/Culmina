// TD-072 (S3S-03, S3F-01; F08 A3): a size is the same in either orientation.
// A rig typed in portrait gets no "conflict" from a file with the same
// values stored the other way round. "New rig with the camera specs of" a
// portrait rig copies its sensor size in the file's orientation.

import 'package:astroplan/domain/equipment_import/equipment_matcher.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/metadata_candidates.dart';

void main() {
  final c = phoneCandidate();
  final w = c.sensorWidthMm.valueOrNull!; // the estimate, landscape
  final h = c.sensorHeightMm.valueOrNull!;

  EquipmentProfile portrait() => EquipmentProfile(
    id: 4,
    name: 'Phone, typed in portrait',
    manufacturer: 'TestMake',
    cameraModel: 'TestMake TestPhone',
    resolutionWidthPx: 3072,
    resolutionHeightPx: 4096,
    sensorWidthMm: h,
    sensorHeightMm: w,
    pixelPitchUm: c.pixelPitchUm.valueOrNull!,
    focalLengthMm: 6.57,
    focalRatio: 1.6,
  );

  test('the same sizes transposed are not a conflict, in either order', () {
    expect(w, greaterThan(h));
    final rig = portrait();
    final r = EquipmentMatcher.match(c, [rig]).rigs.single;
    expect(
      r.conflicts.map((x) => x.spec),
      isNot(
        anyOf(
          contains(EquipmentSpec.resolution),
          contains(EquipmentSpec.sensorSize),
        ),
      ),
    );
    // A real difference is still a conflict.
    final other = EquipmentProfile(
      id: 5,
      name: 'Other sensor',
      manufacturer: 'TestMake',
      cameraModel: 'TestMake TestPhone',
      resolutionWidthPx: 4096,
      resolutionHeightPx: 3072,
      sensorWidthMm: w + 1,
      sensorHeightMm: h,
      pixelPitchUm: c.pixelPitchUm.valueOrNull!,
      focalLengthMm: 6.57,
      focalRatio: 1.6,
    );
    expect(
      EquipmentMatcher.match(c, [
        other,
      ]).rigs.single.conflicts.map((x) => x.spec),
      contains(EquipmentSpec.sensorSize),
    );
  });

  test("a portrait rig's sensor size is copied in the file's orientation "
      '(S3F-01)', () {
    final file = phoneCandidate(with35: false); // no sensor estimate
    final draft = EquipmentDraft.fromCandidate(file, cameraFrom: portrait());
    final sw = double.parse(draft.initial.sensorWidth);
    final sh = double.parse(draft.initial.sensorHeight);
    expect(int.parse(draft.initial.resolutionWidth), 4096);
    expect(sw, greaterThan(sh), reason: 'landscape, like 4096 × 3072');
    expect(
      (sw, sh),
      (double.parse(w.toStringAsFixed(2)), double.parse(h.toStringAsFixed(2))),
    );
  });
}
