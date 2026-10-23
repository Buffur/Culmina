import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:astroplan/presentation/screens/equipment/equipment_selection_screen.dart';
import 'package:astroplan/domain/repositories/equipment_repository.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';

import 'package:astroplan/presentation/screens/library/library_parts.dart';
import 'package:astroplan/presentation/shared/equipment_form_input.dart';
import 'package:astroplan/presentation/shared/list_mode.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:astroplan/presentation/viewmodels/session_plan_viewmodel.dart';

import '../../../support/add_rig.dart';
import '../../../support/library_finders.dart';

class MockEquipmentRepository implements EquipmentRepository {
  final List<EquipmentProfile> _profiles = [];

  @override
  Future<List<EquipmentProfile>> getAllEquipment() async => _profiles;

  @override
  Future<EquipmentProfile?> getEquipmentById(int id) async => null;

  @override
  Future<int> insertEquipment(EquipmentProfile equipment) async {
    _profiles.add(equipment);
    return 1;
  }

  final List<EquipmentProfile> updated = [];

  @override
  Future<void> updateEquipment(EquipmentProfile equipment) async =>
      updated.add(equipment);

  @override
  Future<void> deleteEquipment(int id) async {}

  Future<void> clearAll() async {}
}

class MockSessionPlanViewModel extends ChangeNotifier
    implements SessionPlanViewModel {
  EquipmentProfile? _selectedEquipment;

  @override
  EquipmentProfile? get selectedEquipment => _selectedEquipment;

  @override
  Future<void> setEquipment(EquipmentProfile profile) async {
    _selectedEquipment = profile;
    notifyListeners();
  }

  @override
  Future<void> refreshSelectedEquipment() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Opens the first rig's record, then its editor (library.js: Edit rig).
Future<void> editFirstRig(WidgetTester tester) async {
  await tester.tap(find.byType(LibraryRow).first);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('rigDetail.edit')));
  await tester.pumpAndSettle();
}

/// Opens the rig editor's "More (optional)" section (S7.6).
Future<void> openMore(WidgetTester tester) async {
  final header = find.byKey(const Key('section.rigEditor.more'));
  await tester.ensureVisible(header);
  await tester.pumpAndSettle();
  await tester.tap(header);
  await tester.pumpAndSettle();
}

void main() {
  Widget createTestWidget(
    EquipmentRepository repo,
    SessionPlanViewModel planner,
  ) {
    return MultiProvider(
      providers: [
        Provider<EquipmentRepository>.value(value: repo),
        ChangeNotifierProvider(create: (_) => GearViewModel(repo)),
        ChangeNotifierProvider<SessionPlanViewModel>.value(value: planner),
      ],
      // The Library's rigs: a tap opens the rig's record (library.js).
      child: const MaterialApp(
        home: EquipmentSelectionScreen(mode: ListMode.manage),
      ),
    );
  }

  testWidgets('empty required field is rejected', (WidgetTester tester) async {
    final repo = MockEquipmentRepository();
    final planner = MockSessionPlanViewModel();

    await tester.pumpWidget(createTestWidget(repo, planner));
    await tester.pumpAndSettle();

    // Tap FloatingActionButton to add equipment
    await startAddRig(tester);
    await tester.pumpAndSettle();

    // Tap save without entering anything
    await tester.tap(find.text('Save rig'));
    await tester.pump();

    // Validation errors should appear
    expect(find.text('Required'), findsWidgets);
  });

  testWidgets('non-numeric input is rejected', (WidgetTester tester) async {
    final repo = MockEquipmentRepository();
    final planner = MockSessionPlanViewModel();

    await tester.pumpWidget(createTestWidget(repo, planner));
    await tester.pumpAndSettle();

    await startAddRig(tester);
    await tester.pumpAndSettle();

    // Enter valid name
    await tester.enterText(fieldLabeled('Rig name'), 'Test Profile');

    // Enter non-numeric in Resolution Width (hint: '6248')
    await tester.enterText(find.widgetWithText(TextFormField, '6248'), 'abc');

    await tester.tap(find.text('Save rig'));
    await tester.pump();

    // Validation error should appear, saying what to type
    expect(find.text('Enter whole pixels, e.g. 6248'), findsWidgets);
  });

  testWidgets('zero is rejected where invalid', (WidgetTester tester) async {
    final repo = MockEquipmentRepository();
    final planner = MockSessionPlanViewModel();

    await tester.pumpWidget(createTestWidget(repo, planner));
    await tester.pumpAndSettle();

    await startAddRig(tester);
    await tester.pumpAndSettle();

    await tester.enterText(fieldLabeled('Rig name'), 'Test Profile');
    await tester.enterText(find.widgetWithText(TextFormField, '6248'), '0');

    await tester.tap(find.text('Save rig'));
    await tester.pump();

    // TASK 8.4 (ADR-011 §4): bounds replaced "> 0"; a zero resolution now
    // shows the plausibility range with its unit.
    expect(find.text('Must be 100–30000 px'), findsWidgets);
  });

  testWidgets('valid values can still be saved', (WidgetTester tester) async {
    final repo = MockEquipmentRepository();
    final planner = MockSessionPlanViewModel();

    await tester.pumpWidget(createTestWidget(repo, planner));
    await tester.pumpAndSettle();

    await startAddRig(tester);
    await tester.pumpAndSettle();

    // We must enter all required fields because they now validate
    await tester.enterText(fieldLabeled('Rig name'), 'Valid Rig');

    // Find inputs by hint text to target specific Stellarium rows
    final resW = find.widgetWithText(TextFormField, '6248');
    final resH = find.widgetWithText(TextFormField, '4176');
    // S7.6 (UX-22): the pixel size is one field.
    final pixel = fieldLabeled('Pixel size (µm)');
    // The sensor size is derived from resolution × pixel size.
    final focal = fieldLabeled('Effective focal length (mm)');
    // TASK 8.4 relabelled the f/ field (ADR-011 §3: unit-explicit names).
    final aperture = fieldLabeled('Focal ratio (f/)');

    await tester.enterText(resW, '6000');
    await tester.enterText(resH, '4000');
    await tester.enterText(pixel, '3.76');
    await tester.enterText(focal, '400');
    await tester.enterText(aperture, '5.6');

    await tester.tap(find.text('Save rig'));
    await tester.pumpAndSettle();

    // Dialog should close, no validation errors
    expect(find.text('Required'), findsNothing);
    expect(find.text('Enter whole pixels, e.g. 6248'), findsNothing);
    expect(find.text(EquipmentFormInput.notANumber), findsNothing);
    expect(find.text('> 0'), findsNothing);
    expect(find.text('Must be > 0'), findsNothing);

    // The list should now contain "Valid Rig"
    expect(find.text('Valid Rig'), findsOneWidget);
  });

  testWidgets(
    'the pixel-pitch label renders µm, not mojibake (TASK 4.3, TD-015)',
    (WidgetTester tester) async {
      final repo = MockEquipmentRepository();
      await repo.insertEquipment(
        const EquipmentProfile(
          id: 1,
          name: 'Test Rig',
          sensorWidthMm: 23.5,
          sensorHeightMm: 15.7,
          pixelPitchUm: 3.76,
          resolutionWidthPx: 6248,
          resolutionHeightPx: 4176,
          focalLengthMm: 400.0,
          focalRatio: 5.6,
        ),
      );

      await tester.pumpWidget(
        createTestWidget(repo, MockSessionPlanViewModel()),
      );
      await tester.pumpAndSettle();

      // Asserting the correct text is enough; tool/check_encoding.dart is
      // what guards against the old mojibake creeping back into source, and
      // a literal mojibake string in this file would itself trip that check.
      expect(find.textContaining('µm'), findsOneWidget);

      await editFirstRig(tester);

      // The pixel size's label (S7.6: one field), and the "Rotation (°)"
      // field, one tap away in "More (optional)".
      expect(find.text('Pixel size (µm)'), findsOneWidget);
      await openMore(tester);
      expect(find.text('Rotation (°)'), findsOneWidget);
    },
  );

  // TASK 8.4 (ADR-011)
  Future<void> tallView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  Future<void> fillSensor(WidgetTester tester) async {
    await tester.enterText(fieldLabeled('Rig name'), 'Refractor');
    await tester.enterText(find.widgetWithText(TextFormField, '6248'), '6248');
    await tester.enterText(find.widgetWithText(TextFormField, '4176'), '4176');
    await tester.enterText(fieldLabeled('Pixel size (µm)'), '3.76');
  }

  final focalField = fieldLabeled('Effective focal length (mm)');
  final ratioField = fieldLabeled('Focal ratio (f/)');
  final diameterField = fieldLabeled('Aperture diameter (mm, optional)');

  testWidgets('a diameter derives the focal ratio (N = f / D) and is saved', (
    tester,
  ) async {
    await tallView(tester);
    final repo = MockEquipmentRepository();
    await tester.pumpWidget(createTestWidget(repo, MockSessionPlanViewModel()));
    await tester.pumpAndSettle();
    await startAddRig(tester);
    await tester.pumpAndSettle();

    await fillSensor(tester);
    await tester.enterText(focalField, '400');
    await tester.enterText(diameterField, '72');
    await tester.pump();
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: ratioField,
              matching: find.byType(EditableText),
            ),
          )
          .controller
          .text,
      '5.56',
    );
    expect(find.text('From focal length ÷ diameter'), findsOneWidget);

    // Open the tracking dropdown (showing "Unknown") and pick "Guided".
    // S7.2a: the camera type also reads Unknown, so the dropdown is named.
    await tester.tap(
      find.descendant(
        of: find.byType(DropdownButtonFormField<TrackingType>),
        matching: find.text('Unknown'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guided').last);
    await tester.pumpAndSettle();
    await openMore(tester); // S7.6: one tap away
    await tester.enterText(fieldLabeled('Maximum sub-exposure (s)'), '300');
    await tester.tap(find.text('Save rig'));
    await tester.pumpAndSettle();

    final saved = repo._profiles.single;
    expect(saved.focalRatio, closeTo(400 / 72, 1e-9));
    expect(saved.apertureDiameterMm, 72);
    expect(saved.trackingType, TrackingType.guided);
    expect(saved.maxExposureS, 300);
    // library.js `rigSubtitle`: the ratio to two decimals.
    expect(find.textContaining('f/5.56'), findsOneWidget);
  });

  testWidgets('a ratio above f/32 is rejected by the form', (tester) async {
    await tallView(tester);
    final repo = MockEquipmentRepository();
    await tester.pumpWidget(createTestWidget(repo, MockSessionPlanViewModel()));
    await tester.pumpAndSettle();
    await startAddRig(tester);
    await tester.pumpAndSettle();

    await fillSensor(tester);
    await tester.enterText(focalField, '400');
    await tester.enterText(ratioField, '72');
    await tester.tap(find.text('Save rig'));
    await tester.pumpAndSettle();

    expect(find.text('Must be 0.5–32'), findsOneWidget);
    expect(repo._profiles, isEmpty);
  });

  testWidgets('a stored f/72 is flagged for review, never converted', (
    tester,
  ) async {
    await tallView(tester);
    final repo = MockEquipmentRepository();
    await repo.insertEquipment(
      const EquipmentProfile(
        id: 5,
        name: 'Old scope',
        sensorWidthMm: 23.5,
        sensorHeightMm: 15.7,
        pixelPitchUm: 3.76,
        resolutionWidthPx: 6248,
        resolutionHeightPx: 4176,
        focalLengthMm: 400,
        focalRatio: 72,
      ),
    );
    await tester.pumpWidget(createTestWidget(repo, MockSessionPlanViewModel()));
    await tester.pumpAndSettle();
    expect(find.textContaining('f/72 — please review'), findsOneWidget);

    await editFirstRig(tester);
    expect(find.textContaining('Please review'), findsOneWidget);
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: ratioField,
              matching: find.byType(EditableText),
            ),
          )
          .controller
          .text,
      '72',
      reason: 'the stored value is shown as it is',
    );

    // The user fixes it by entering the diameter.
    await tester.enterText(diameterField, '72');
    await tester.pump();
    await tester.tap(find.text('Save rig'));
    await tester.pumpAndSettle();
    final fixed = repo.updated.single;
    expect(fixed.focalRatio, closeTo(400 / 72, 1e-9));
    expect(fixed.apertureDiameterMm, 72);
  });

  testWidgets('every equipment number shows its unit', (tester) async {
    await tallView(tester);
    await tester.pumpWidget(
      createTestWidget(MockEquipmentRepository(), MockSessionPlanViewModel()),
    );
    await tester.pumpAndSettle();
    await startAddRig(tester);
    await tester.pumpAndSettle();
    await openMore(tester); // S7.6: the rare values, one tap away
    for (final label in [
      'Resolution width (px)',
      'Resolution height (px)',
      'Pixel size (µm)',
      'Sensor size (mm)',
      'Effective focal length (mm)',
      'Focal ratio (f/)',
      'Aperture diameter (mm, optional)',
      'Maximum sub-exposure (s)',
      'Average RAW file size (MB)',
      'Rotation (°)',
    ]) {
      expect(find.text(label), findsWidgets, reason: label);
    }
  });

  // TASK 8.5
  testWidgets('saving a verified seed unchanged keeps it verified, and the '
      'editor shows the provenance', (tester) async {
    await tallView(tester);
    final repo = MockEquipmentRepository();
    final seed = EquipmentSeeder.defaults.single;
    await repo.insertEquipment(
      EquipmentProfile(
        id: 9,
        name: seed.name,
        manufacturer: seed.manufacturer,
        cameraModel: seed.cameraModel,
        sensorWidthMm: seed.sensorWidthMm,
        sensorHeightMm: seed.sensorHeightMm,
        pixelPitchUm: seed.pixelPitchUm,
        resolutionWidthPx: seed.resolutionWidthPx,
        resolutionHeightPx: seed.resolutionHeightPx,
        focalLengthMm: seed.focalLengthMm,
        focalRatio: seed.focalRatio,
        apertureDiameterMm: seed.apertureDiameterMm,
        cameraSource: seed.cameraSource,
        cameraConfidence: seed.cameraConfidence,
        opticsSource: seed.opticsSource,
        opticsConfidence: seed.opticsConfidence,
      ),
    );
    await tester.pumpWidget(createTestWidget(repo, MockSessionPlanViewModel()));
    await tester.pumpAndSettle();
    await editFirstRig(tester);
    expect(find.textContaining('Camera specs: verified'), findsOneWidget);
    expect(find.textContaining('Optics: estimated'), findsOneWidget);

    await tester.tap(find.text('Save rig'));
    await tester.pumpAndSettle();
    final saved = repo.updated.single;
    expect(saved.cameraConfidence, SpecConfidence.verified);
    expect(saved.opticsConfidence, SpecConfidence.estimated);
    expect(saved.sensorWidthMm, seed.sensorWidthMm);
    expect(saved.focalRatio, seed.focalRatio);
  });
}
