// F10 A3 (host part) and A4: a synthetic FITS sub-frame through the real
// import pipeline over SQLite. The review lists its values. "New rig from
// this file" opens the editor with the native geometry normalized once, and
// Save stores one rig. Cancel stores nothing. A real astro-camera FITS
// remains the owner-sample row (NEEDS ATTENTION).

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/screens/equipment/equipment_selection_screen.dart';
import 'package:astroplan/presentation/screens/metadata/metadata_import_screen.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:astroplan/presentation/viewmodels/metadata_import_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/session_plan_viewmodel.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../support/fake_capture_file_access.dart';
import '../../../support/fits_fixture.dart';
import '../../../support/library_finders.dart';

class _Planner extends ChangeNotifier implements SessionPlanViewModel {
  @override
  EquipmentProfile? get selectedEquipment => null;

  @override
  Future<void> refreshSelectedEquipment() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('a FITS sub-frame proposes a rig with its native geometry; '
      'Cancel stores nothing, Save one rig', (t) async {
    final db = AppDatabase(NativeDatabase.memory());
    final repo = DriftEquipmentRepository(db);
    addTearDown(() => t.runAsync(db.close));
    final files = FakeCaptureFileAccess();
    final vm = MetadataImportViewModel(files, repo);
    final gear = GearViewModel(repo);
    addTearDown(vm.dispose);
    addTearDown(gear.dispose);
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const EquipmentSelectionScreen()),
        GoRoute(
          path: AppRouter.metadata,
          builder: (_, state) => MetadataImportScreen(
            args: state.extra as NewRigArgs? ?? const NewRigArgs(),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    t.view.physicalSize = const Size(800, 4000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: gear),
          ChangeNotifierProvider<SessionPlanViewModel>.value(value: _Planner()),
          ChangeNotifierProvider<MetadataImportViewModel?>.value(value: vm),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    Future<void> settle() async {
      for (var i = 0; i < 8; i++) {
        await t.runAsync(() => Future<void>.delayed(Duration.zero));
        await t.pump();
      }
      await t.pumpAndSettle();
    }

    await settle();
    // A4: the add-rig panel names FITS for an astro camera.
    await t.tap(find.byKey(const Key('addRig.class.astroMono')));
    await t.pumpAndSettle();
    expect(find.textContaining('FITS sub-frame'), findsOneWidget);
    await t.tap(find.byKey(const Key('addRig.fromPhoto')));
    await settle();
    expect(find.textContaining('FITS'), findsWidgets);

    files.file('L_0001.fits', fitsFile(ninaLight()), length: 13049280);
    await t.tap(find.byKey(const Key('metadata.pick')));
    await settle();
    expect(find.text('FITS'), findsOneWidget);
    expect(find.text('Ha'), findsOneWidget);

    await t.tap(find.byKey(const Key('import.new')));
    await settle();
    String text(String label) => t
        .widget<EditableText>(
          find.descendant(
            of: fieldLabeled(label),
            matching: find.byType(EditableText),
          ),
        )
        .controller
        .text;
    expect(text('Pixel size (µm)'), '3.76');
    expect(text('Effective focal length (mm)'), '400');
    await t.tap(find.byKey(const Key('rigEditor.cancel')));
    await settle();
    expect(await t.runAsync(repo.getAllEquipment), isEmpty);

    await t.tap(find.byKey(const Key('import.new')));
    await settle();
    await t.enterText(fieldLabeled('Focal ratio (f/)'), '5');
    await t.ensureVisible(find.byKey(const Key('rigEditor.save')));
    await t.tap(find.byKey(const Key('rigEditor.save')));
    await settle();
    final rigs = (await t.runAsync(repo.getAllEquipment))!;
    expect(rigs, hasLength(1));
    final rig = rigs.single;
    expect((rig.resolutionWidthPx, rig.resolutionHeightPx), (6248, 4176));
    expect(rig.pixelPitchUm, 3.76);
    expect(rig.focalLengthMm, 400);
    expect(rig.cameraClass.name, 'astroMono');
    expect(
      rig.provenanceOf(EquipmentSpec.focalLength)?.source,
      'metadata:fits',
    );
  });
}
