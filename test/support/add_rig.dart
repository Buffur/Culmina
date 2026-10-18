import 'package:astroplan/domain/models/camera_class.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Starts a new rig the F05 way on the rigs screen: the empty list's panel,
/// or Add rig's sheet over a list, then the camera class ("Not sure" by
/// default), then Enter by hand or From a photo.
Future<void> startAddRig(
  WidgetTester tester, {
  CameraClass cameraClass = CameraClass.unknown,
  bool fromPhoto = false,
}) async {
  final add = find.byKey(const Key('rigs.add'));
  if (add.evaluate().isNotEmpty) {
    await tester.tap(add);
    await tester.pumpAndSettle();
  }
  final chip = find.byKey(Key('addRig.class.${cameraClass.name}'));
  await tester.ensureVisible(chip);
  await tester.tap(chip);
  await tester.pumpAndSettle();
  final choice = find.byKey(
    Key(fromPhoto ? 'addRig.fromPhoto' : 'addRig.byHand'),
  );
  await tester.ensureVisible(choice);
  await tester.pumpAndSettle();
  await tester.tap(choice);
  await tester.pumpAndSettle();
}
