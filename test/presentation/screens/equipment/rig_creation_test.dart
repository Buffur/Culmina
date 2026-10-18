// F05 (S14.2, CA-02, UXA-C2/C4): adding a rig starts with the camera class
// ("Not sure" = Unknown), then two equal choices ordered by class; each
// required input says what needs it; a rig created for a plan action is
// chosen exactly once, a failed save keeps the edits and chooses nothing;
// a changed rig editor asks before Back or a tap outside discards it.

import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/camera_class.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/screens/equipment/equipment_selection_screen.dart';
import 'package:astroplan/presentation/screens/metadata/metadata_import_screen.dart';
import 'package:astroplan/presentation/shared/list_mode.dart';
import 'package:astroplan/presentation/shared/rig_input_text.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:astroplan/presentation/viewmodels/session_plan_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../support/add_rig.dart';
import '../../../support/in_memory_equipment_repository.dart';

class _Planner extends ChangeNotifier implements SessionPlanViewModel {
  final chosen = <EquipmentProfile>[];

  @override
  EquipmentProfile? get selectedEquipment => chosen.lastOrNull;

  @override
  Future<void> setEquipment(EquipmentProfile profile) async {
    chosen.add(profile);
    notifyListeners();
  }

  @override
  Future<void> refreshSelectedEquipment() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FailingRepository extends InMemoryEquipmentRepository {
  @override
  Future<int> insertEquipment(EquipmentProfile profile) =>
      Future.error(StateError('disk full'));
}

const _astro = EquipmentProfile(
  id: 1,
  name: 'Mono rig',
  cameraClass: CameraClass.astroMono,
  sensorWidthMm: 23.5,
  sensorHeightMm: 15.7,
  pixelPitchUm: 3.76,
  resolutionWidthPx: 6248,
  resolutionHeightPx: 4176,
  focalLengthMm: 400,
  focalRatio: 5,
);

void main() {
  late InMemoryEquipmentRepository repo;
  late _Planner planner;
  late GoRouter router;

  /// The rigs screen as the plan's missing-rig action opens it, over a
  /// caller, or as the Library opens it ([forPlan] false). The import is a
  /// stand-in that saves a rig and returns its id as the real one does.
  Future<void> start(
    WidgetTester tester, {
    bool forPlan = true,
    InMemoryEquipmentRepository? repository,
  }) async {
    repo = repository ?? InMemoryEquipmentRepository();
    planner = _Planner();
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/rigs'),
              child: const Text('caller'),
            ),
          ),
        ),
        GoRoute(
          path: '/rigs',
          builder: (context, state) => EquipmentSelectionScreen(
            mode: forPlan ? ListMode.choose : ListMode.manage,
            forPlanAction: forPlan,
          ),
        ),
        GoRoute(
          path: AppRouter.metadata,
          builder: (context, state) {
            final args = state.extra! as NewRigArgs;
            return Scaffold(
              body: TextButton(
                onPressed: () async {
                  final id = await repo.insertEquipment(
                    EquipmentProfile(
                      id: 0,
                      name: 'From the file',
                      cameraClass: args.cameraClass,
                      sensorWidthMm: 9.89,
                      sensorHeightMm: 7.42,
                      pixelPitchUm: 2.414,
                      resolutionWidthPx: 4096,
                      resolutionHeightPx: 3072,
                      focalLengthMm: 6.57,
                      focalRatio: 1.6,
                    ),
                  );
                  if (context.mounted) {
                    context.pop(args.returnsNewRig ? id : null);
                  }
                },
                child: const Text('import stand-in: save'),
              ),
            );
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GearViewModel(repo)),
          ChangeNotifierProvider<SessionPlanViewModel>.value(value: planner),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('caller'));
    await tester.pumpAndSettle();
  }

  Future<void> fill(WidgetTester tester, {String name = 'Typed rig'}) async {
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Rig name'),
      name,
    );
    await tester.enterText(find.widgetWithText(TextFormField, '6248'), '6000');
    await tester.enterText(find.widgetWithText(TextFormField, '4176'), '4000');
    await tester.enterText(
      find.byKey(const Key('equipmentEditor.pixelSize')),
      '3.76',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Effective focal length (mm)'),
      '400',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Focal ratio (f/)'),
      '5',
    );
    await tester.pump();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(const Key('rigEditor.save')));
    await tester.tap(find.byKey(const Key('rigEditor.save')));
    await tester.pumpAndSettle();
  }

  double top(String key) => find.byKey(Key(key)).evaluate().isEmpty
      ? double.nan
      : (find.byKey(Key(key)).evaluate().single.renderObject! as RenderBox)
            .localToGlobal(Offset.zero)
            .dy;

  bool enabled(WidgetTester tester, String key) =>
      tester.widget<ButtonStyleButton>(find.byKey(Key(key))).enabled;

  group('A1: the class, then both choices', () {
    testWidgets('the empty list shows both, inactive until a class is '
        'chosen', (tester) async {
      await start(tester);
      expect(find.text(RigInputText.classQuestion), findsOneWidget);
      expect(find.text(RigInputText.chooseClassFirst), findsOneWidget);
      expect(find.text(RigInputText.fromPhoto), findsOneWidget);
      expect(find.text(RigInputText.byHand), findsOneWidget);
      expect(enabled(tester, 'addRig.fromPhoto'), isFalse);
      expect(enabled(tester, 'addRig.byHand'), isFalse);
      for (final c in CameraClass.values) {
        expect(find.byKey(Key('addRig.class.${c.name}')), findsOneWidget);
      }
      expect(find.text('Not sure'), findsOneWidget);
    });

    // F05 put Enter by hand first for astro cameras "until F10"; FITS is
    // read since F10, so a photo (a FITS sub-frame) comes first for all.
    testWidgets('photo first for every class since F10; the readable formats '
        'are named, other RAW honestly', (tester) async {
      await start(tester);
      for (final c in [CameraClass.phone, CameraClass.dslrMirrorless]) {
        await tester.tap(find.byKey(Key('addRig.class.${c.name}')));
        await tester.pumpAndSettle();
        expect(top('addRig.fromPhoto'), lessThan(top('addRig.byHand')));
        expect(find.textContaining('JPEG, HEIC or DNG'), findsOneWidget);
        expect(find.textContaining('Other RAW files'), findsOneWidget);
        expect(enabled(tester, 'addRig.fromPhoto'), isTrue);
        expect(enabled(tester, 'addRig.byHand'), isTrue);
      }
      for (final c in [CameraClass.astroColour, CameraClass.astroMono]) {
        await tester.tap(find.byKey(Key('addRig.class.${c.name}')));
        await tester.pumpAndSettle();
        expect(top('addRig.fromPhoto'), lessThan(top('addRig.byHand')));
        expect(find.textContaining('a FITS sub-frame'), findsOneWidget);
      }
    });

    testWidgets('a list with rigs offers both from Add rig', (tester) async {
      await start(tester, repository: InMemoryEquipmentRepository([_astro]));
      expect(find.byKey(const Key('addRig.panel')), findsNothing);
      await tester.tap(find.byKey(const Key('rigs.add')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('addRig.fromPhoto')), findsOneWidget);
      expect(find.byKey(const Key('addRig.byHand')), findsOneWidget);
    });
  });

  group('A3: reasons, Unknown and kept classes', () {
    testWidgets('Not sure saves an explicit Unknown and says it infers '
        'nothing', (tester) async {
      await start(tester, forPlan: false);
      await tester.tap(find.byKey(const Key('addRig.class.unknown')));
      await tester.pumpAndSettle();
      expect(find.text(RigInputText.notSure), findsOneWidget);
      await tester.tap(find.byKey(const Key('addRig.byHand')));
      await tester.pumpAndSettle();
      await fill(tester);
      await save(tester);
      expect(repo.inserted.single.cameraClass, CameraClass.unknown);
    });

    testWidgets('each required input says which calculations need it', (
      tester,
    ) async {
      await start(tester, forPlan: false);
      await startAddRig(tester, cameraClass: CameraClass.phone);
      for (final spec in [
        EquipmentSpec.resolution,
        EquipmentSpec.pixelPitch,
        EquipmentSpec.sensorSize,
        EquipmentSpec.focalLength,
        EquipmentSpec.focalRatio,
      ]) {
        expect(
          find.byKey(Key('rigEditor.reason.${spec.name}')),
          findsOneWidget,
          reason: spec.name,
        );
        expect(find.text(RigInputText.reason(spec)), findsOneWidget);
      }
      // No guessed default: Save still needs every required input.
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Rig name'),
        'Only a name',
      );
      await save(tester);
      expect(repo.inserted, isEmpty);
      expect(find.text('Required'), findsWidgets);
    });

    testWidgets('the chosen class reaches the new rig; an edited rig keeps '
        'its own', (tester) async {
      await start(
        tester,
        forPlan: false,
        repository: InMemoryEquipmentRepository([_astro]),
      );
      await tester.tap(find.text('Mono rig'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Rig name'),
        'Mono rig, renamed',
      );
      await save(tester);
      expect(repo.updated.single.cameraClass, CameraClass.astroMono);

      await startAddRig(tester, cameraClass: CameraClass.dslrMirrorless);
      await fill(tester);
      await save(tester);
      expect(repo.inserted.single.cameraClass, CameraClass.dslrMirrorless);
    });

    test(
      'the example rig is a colour astro camera on a new install only',
      () async {
        expect(
          EquipmentSeeder.defaults.single.cameraClass,
          CameraClass.astroColour,
        );
        // A4's seed-class case: its light blocks record gain, with binning.
        final seeded = EquipmentSeeder.defaults.single.cameraClass;
        expect(seeded.lightSensitivity, LightSensitivity.gain);
        expect(seeded.offersLightBinning, isTrue);
        expect(seeded.offersInCameraNoiseReduction, isFalse);
        final fresh = InMemoryEquipmentRepository();
        await EquipmentSeeder(fresh).seedIfNeeded();
        expect(fresh.inserted.single.cameraClass, CameraClass.astroColour);

        // An existing install's example row keeps its stored (Unknown) class.
        final old = EquipmentSeeder.defaults.single;
        final existing = InMemoryEquipmentRepository([
          EquipmentProfile(
            id: 1,
            name: old.name,
            sensorWidthMm: old.sensorWidthMm,
            sensorHeightMm: old.sensorHeightMm,
            pixelPitchUm: old.pixelPitchUm,
            resolutionWidthPx: old.resolutionWidthPx,
            resolutionHeightPx: old.resolutionHeightPx,
            focalLengthMm: old.focalLengthMm,
            focalRatio: old.focalRatio,
          ),
        ]);
        await EquipmentSeeder(existing).seedIfNeeded();
        expect(existing.inserted, isEmpty);
        expect(existing.updated, isEmpty);
        expect(
          (await existing.getAllEquipment()).single.cameraClass,
          CameraClass.unknown,
        );
      },
    );
  });

  group('A5: chosen once for a plan action; saved only elsewhere', () {
    testWidgets('by hand: chosen exactly once, back at the caller', (
      tester,
    ) async {
      await start(tester);
      await startAddRig(tester, cameraClass: CameraClass.phone);
      await fill(tester);
      await save(tester);
      expect(planner.chosen.map((r) => r.name), ['Typed rig']);
      expect(planner.chosen.single.id, 1);
      expect(find.text('caller'), findsOneWidget);
      expect(find.text(RigInputText.savedAndChosen), findsOneWidget);
    });

    testWidgets('from a photo: the saved identity comes back and is chosen '
        'once', (tester) async {
      await start(tester);
      await startAddRig(
        tester,
        cameraClass: CameraClass.phone,
        fromPhoto: true,
      );
      await tester.tap(find.text('import stand-in: save'));
      await tester.pumpAndSettle();
      expect(planner.chosen.map((r) => (r.id, r.name)), [(1, 'From the file')]);
      expect(planner.chosen.single.cameraClass, CameraClass.phone);
      expect(find.text('caller'), findsOneWidget);
    });

    testWidgets('the Library saves without choosing, for both paths', (
      tester,
    ) async {
      await start(tester, forPlan: false);
      await startAddRig(tester, fromPhoto: true);
      await tester.tap(find.text('import stand-in: save'));
      await tester.pumpAndSettle();
      await startAddRig(tester);
      await fill(tester);
      await save(tester);
      expect(planner.chosen, isEmpty);
      expect(repo.inserted, hasLength(2));
      expect(find.text('caller'), findsNothing);
      expect(find.text('Rig saved'), findsOneWidget);
    });

    testWidgets('a failed save keeps the edits and chooses nothing', (
      tester,
    ) async {
      await start(tester, repository: _FailingRepository());
      await startAddRig(tester, cameraClass: CameraClass.phone);
      await fill(tester, name: 'Kept text');
      await save(tester);
      expect(planner.chosen, isEmpty);
      expect(find.widgetWithText(TextFormField, 'Kept text'), findsOneWidget);
      expect(find.byKey(const Key('rigEditor.save')), findsOneWidget);
      expect(find.text(RigInputText.savedAndChosen), findsNothing);
    });
  });

  group('A6: the discard guard', () {
    Future<void> openChanged(WidgetTester tester) async {
      await start(tester, forPlan: false);
      await startAddRig(tester);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Rig name'),
        'Half typed',
      );
      await tester.pump();
    }

    final editor = find.byKey(const Key('rigEditor.save'));

    testWidgets('Back on a changed editor asks; Cancel keeps it, Discard '
        'closes and writes nothing', (tester) async {
      await openChanged(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        find.text('"Half typed" has changes that are not saved.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('unsaved.cancel')));
      await tester.pumpAndSettle();
      expect(editor, findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Half typed'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('unsaved.discard')));
      await tester.pumpAndSettle();
      expect(editor, findsNothing);
      expect(repo.inserted, isEmpty);
    });

    testWidgets('a tap outside a changed editor asks too', (tester) async {
      await openChanged(tester);
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('unsaved.discard')), findsOneWidget);
      await tester.tap(find.byKey(const Key('unsaved.cancel')));
      await tester.pumpAndSettle();
      expect(editor, findsOneWidget);
    });

    testWidgets("the prompt's Save saves through the editor", (tester) async {
      await start(tester, forPlan: false);
      await startAddRig(tester);
      await fill(tester, name: 'Saved from the prompt');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('unsaved.save')));
      await tester.pumpAndSettle();
      expect(repo.inserted.single.name, 'Saved from the prompt');
      expect(editor, findsNothing);
    });

    testWidgets('an unchanged editor closes at once, by Back or a tap '
        'outside', (tester) async {
      await start(
        tester,
        forPlan: false,
        repository: InMemoryEquipmentRepository([_astro]),
      );
      await tester.tap(find.text('Mono rig'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('unsaved.discard')), findsNothing);
      expect(editor, findsNothing);

      await tester.tap(find.text('Mono rig'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('unsaved.discard')), findsNothing);
      expect(editor, findsNothing);
      expect(repo.updated, isEmpty);
    });

    testWidgets('a changed camera type alone counts as a change', (
      tester,
    ) async {
      await start(
        tester,
        forPlan: false,
        repository: InMemoryEquipmentRepository([_astro]),
      );
      await tester.tap(find.text('Mono rig'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('equipmentEditor.cameraClass')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Phone').last);
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('unsaved.discard')), findsOneWidget);
    });
  });
}
