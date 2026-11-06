import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/presentation/screens/equipment/rig_detail_screen.dart';
import 'package:astroplan/presentation/screens/library/library_parts.dart';
import 'package:astroplan/presentation/shared/fact_row.dart';
import 'package:astroplan/presentation/shared/hybrid_icon.dart';
import 'package:flutter/rendering.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/camera_class.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/target_alias.dart';
import 'package:astroplan/presentation/screens/equipment/equipment_editor.dart';
import 'package:astroplan/presentation/screens/sites/zone_picker_dialog.dart';
import 'package:astroplan/presentation/screens/target/target_detail_screen.dart';
import 'package:astroplan/presentation/shared/action_row.dart';
import 'package:astroplan/presentation/shared/hybrid_parts.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../support/in_memory_equipment_repository.dart';
import '../../support/phase2_state_capture.dart';
import '../../support/wave1_capture.dart';

class _Aliases extends ChangeNotifier implements TargetsViewModel {
  @override
  Future<Map<String, List<TargetAlias>>> aliases() async => {};
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

EquipmentProfile _rig(CameraClass camera, {bool noise = false}) =>
    EquipmentProfile(
      id: 90,
      name: 'Synthetic rig',
      cameraClass: camera,
      sensorWidthMm: 23.5,
      sensorHeightMm: 15.6,
      pixelPitchUm: 3.76,
      resolutionWidthPx: 6000,
      resolutionHeightPx: 4000,
      focalLengthMm: 400,
      focalRatio: 5,
      inCameraNoiseReduction: noise,
    );

void main() {
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    Future<void> host(
      WidgetTester t,
      Widget home, {
      GearViewModel? gear,
    }) async {
      t.view.physicalSize = const Size(375, 812);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final app = MaterialApp(
        theme: phase2Theme(theme),
        builder: (_, child) => phase2Frame(child: child!, theme: theme),
        home: home,
      );
      await t.pumpWidget(
        gear == null
            ? app
            : ChangeNotifierProvider<GearViewModel>.value(
                value: gear,
                child: app,
              ),
      );
      await t.pumpAndSettle();
    }

    Future<void> capture(WidgetTester t, String state) =>
        capturePhase2State(t, package: 'package3', state: state, theme: theme);

    testWidgets(
      '$theme record primitives preserve full labels notes Unknown and actions at 200 percent',
      (t) async {
        t.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
        var edits = 0;
        var deletes = 0;
        const title =
            'Synthetic full instrument identity with a deliberately long local record title';
        const editLabel = 'Edit the complete synthetic record';
        const deleteLabel = 'Delete the complete synthetic record';
        await host(
          t,
          Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LibraryRecordHeader(
                      title: title,
                      caption: 'Synthetic editable record',
                      action: LibraryPrimaryAction(
                        key: const Key('direct.primary'),
                        icon: HybridIcons.edit,
                        label: editLabel,
                        onPressed: () => edits++,
                      ),
                    ),
                    const FactRow(
                      label: 'Optional scientific value with a deliberately long descriptive label',
                      value: 'Unknown',
                      caption: 'Missing measurement stays unknown.',
                      provenance: 'Synthetic fixture; not a measurement',
                    ),
                    LibraryDeleteAction(
                      key: const Key('direct.delete'),
                      label: deleteLabel,
                      onPressed: () => deletes++,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        expect(find.text(title), findsOneWidget);
        expect(find.text(librarySnapshotNote), findsOneWidget);
        expect(find.text('Synthetic editable record'), findsOneWidget);
        expect(find.text('Unknown'), findsOneWidget);
        expect(find.text('Missing measurement stays unknown.'), findsOneWidget);
        expect(
          find.text('Synthetic fixture; not a measurement'),
          findsOneWidget,
        );
        expect(find.text('0'), findsNothing);
        expect(t.getSize(find.text(title)).height, greaterThan(60));
        for (final key in ['direct.primary', 'direct.delete']) {
          final control = find.byKey(Key(key));
          await t.ensureVisible(control);
          await t.pumpAndSettle();
          expect(t.getSize(control).height, greaterThanOrEqualTo(48));
          await t.tap(control);
          await t.pumpAndSettle();
        }
        expect(edits, 1);
        expect(deletes, 1);
        for (final paragraph in t.renderObjectList<RenderParagraph>(
          find.byType(RichText),
        )) {
          expect(paragraph.didExceedMaxLines, isFalse);
          expect(paragraph.size.width, lessThanOrEqualTo(343));
        }
        await capture(t, 'record-primitives-full-labels-note-unknown-200pct');
        expect(t.takeException(), isNull);
      },
    );

    for (final example in [false, true]) {
      testWidgets(
        '$theme rig record ${example ? "example" : "editable"} identity captions and optional specs are explicit',
        (t) async {
          final rig = example
              ? EquipmentSeeder.defaults.single
              : const EquipmentProfile(
                  id: 92,
                  name: 'Synthetic known camera',
                  cameraClass: CameraClass.dslrMirrorless,
                  manufacturer: 'Synthetic manufacturer',
                  cameraModel: 'Synthetic model',
                  sensorWidthMm: 23.5,
                  sensorHeightMm: 15.6,
                  pixelPitchUm: 3.76,
                  resolutionWidthPx: 6000,
                  resolutionHeightPx: 4000,
                  focalLengthMm: 400,
                  focalRatio: 40,
                );
          await host(t, RigDetailScreen(rig: rig));
          expect(
            find.text(
              example
                  ? 'Example rig · not a measurement'
                  : 'Your rig · editable',
            ),
            findsOneWidget,
          );
          expect(find.text(rig.cameraClass.label), findsOneWidget);
          expect(find.text(rig.manufacturer!), findsOneWidget);
          expect(find.text(rig.cameraModel!), findsOneWidget);
          expect(
            find.textContaining('Camera specs:'),
            findsNothing,
            reason: 'source details start collapsed',
          );
          if (!example) {
            expect(find.text('Above f/32 · please review'), findsOneWidget);
          }
          await t.ensureVisible(find.text('Full rig record and sources'));
          await t.tap(find.text('Full rig record and sources'));
          await t.pumpAndSettle();
          expect(find.textContaining('Camera specs:'), findsOneWidget);
          expect(find.text(rig.manufacturer!), findsNWidgets(2));
          expect(find.text(rig.cameraModel!), findsNWidgets(2));
          await capture(
            t,
            'rig-record-${example ? "example" : "editable"}-known-specs',
          );
          expect(t.takeException(), isNull);
        },
      );
    }

    for (final saveOn in [false, true]) {
      testWidgets(
        '$theme DSLR noise reduction toggles both ways and persists ${saveOn ? "on" : "off"}',
        (t) async {
          final original = _rig(CameraClass.dslrMirrorless);
          final repo = InMemoryEquipmentRepository([original]);
          final gear = GearViewModel(repo);
          addTearDown(gear.dispose);
          await host(
            t,
            ChangeNotifierProvider<GearViewModel>.value(
              value: gear,
              child: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () =>
                        showEquipmentEditor(context, existing: original),
                    child: const Text('Open rig'),
                  ),
                ),
              ),
            ),
            gear: gear,
          );
          await t.tap(find.text('Open rig'));
          await t.pumpAndSettle();
          final control = find.byKey(
            const Key('equipmentEditor.noiseReduction'),
          );
          Finder checkbox() => find.descendant(
            of: control,
            matching: find.byType(HybridCheckbox),
          );
          await t.ensureVisible(control);
          expect(t.widget<HybridCheckbox>(checkbox()).checked, isFalse);
          expect(
            find.textContaining(
              'the camera takes a dark as long as each light',
            ),
            findsOneWidget,
          );
          await capture(t, 'rig-noise-reduction-off');
          await t.tap(control);
          await t.pumpAndSettle();
          expect(t.widget<HybridCheckbox>(checkbox()).checked, isTrue);
          await capture(t, 'rig-noise-reduction-on');
          await t.tap(control);
          await t.pumpAndSettle();
          expect(t.widget<HybridCheckbox>(checkbox()).checked, isFalse);
          if (saveOn) {
            await t.tap(control);
            await t.pumpAndSettle();
          }
          await t.tap(find.byKey(const Key('rigEditor.save')));
          await t.pumpAndSettle();
          expect(repo.updated, hasLength(1));
          expect(repo.updated.single.inCameraNoiseReduction, saveOn);
          expect(repo.updated.single.id, original.id);
          expect(find.byKey(const Key('rigEditor.save')), findsNothing);
          expect(t.takeException(), isNull);
        },
      );
    }

    for (final catalog in [false, true]) {
      testWidgets(
        '$theme ${catalog ? "catalogue" : "own"} target missing size and magnitude stay unrecorded',
        (t) async {
          final aliases = _Aliases();
          addTearDown(aliases.dispose);
          final target = AstroTarget(
            id: 91,
            catalogId: 'SYN-91',
            commonName: 'Synthetic missing measurements',
            rightAscension: 10.68,
            declination: 41.27,
            type: 'Galaxy',
            source: catalog ? 'catalog:synthetic' : 'user',
          );
          await host(
            t,
            ChangeNotifierProvider<TargetsViewModel>.value(
              value: aliases,
              child: TargetDetailScreen(target: target, onPlan: (_) async {}),
            ),
          );
          expect(find.text('Apparent size (arcmin)'), findsOneWidget);
          expect(
            find.text(catalog ? 'Magnitude (V)' : 'Magnitude'),
            findsOneWidget,
          );
          expect(find.text('Not recorded'), findsNWidgets(2));
          expect(find.text('0'), findsNothing);
          expect(find.text('0′'), findsNothing);
          if (catalog) {
            expect(
              find.text('Not in the catalogue; never estimated.'),
              findsOneWidget,
            );
            expect(
              find.text("OpenNGC, via the app's bundled catalogue"),
              findsOneWidget,
            );
            expect(find.text('None recorded'), findsOneWidget);
            expect(find.byKey(const Key('targetDetail.edit')), findsNothing);
            expect(find.text('Bundled catalogue · read-only'), findsOneWidget);
            expect(
              find.text(
                'For different values, add your own target. The bundled record stays unchanged.',
              ),
              findsOneWidget,
            );
          } else {
            expect(
              find.text('Not in the catalogue; never estimated.'),
              findsNothing,
            );
            final editButton = find.descendant(
              of: find.byKey(const Key('targetDetail.edit')),
              matching: find.byType(TextButton),
            );
            expect(t.widget<TextButton>(editButton).onPressed, isNull);
          }
          expect(find.byKey(const Key('targetDetail.delete')), findsNothing);
          expect(
            t
                .widget<TextButton>(find.byKey(const Key('targetDetail.plan')))
                .onPressed,
            isNotNull,
          );
          await t.ensureVisible(
            find.text(catalog ? 'Magnitude (V)' : 'Magnitude'),
          );
          await t.pumpAndSettle();
          await capture(
            t,
            'target-${catalog ? "catalogue" : "own"}-unknown-size-magnitude',
          );
          expect(t.takeException(), isNull);
        },
      );
    }

    testWidgets(
      '$theme zone picker starts with Unknown selected and moves selection to a real zone',
      (t) async {
        String? current;
        await host(
          t,
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  final selected = await showZonePicker(
                    context,
                    current: current,
                  );
                  current = selected?.zoneId;
                },
                child: const Text('Open zones'),
              ),
            ),
          ),
        );
        await t.tap(find.text('Open zones'));
        await t.pumpAndSettle();
        final unknown = find.widgetWithText(ActionRow, 'Unknown');
        expect(t.widget<ActionRow>(unknown).selected, isTrue);
        expect(find.text('Night uses mean solar time'), findsOneWidget);
        await capture(t, 'zone-initial-unknown-selected');
        await t.enterText(find.byType(TextField), 'Kyiv');
        await t.pumpAndSettle();
        expect(
          t
              .widget<ActionRow>(find.widgetWithText(ActionRow, 'Europe/Kyiv'))
              .selected,
          isFalse,
        );
        await t.tap(find.text('Europe/Kyiv'));
        await t.pumpAndSettle();
        expect(current, 'Europe/Kyiv');
        await t.tap(find.text('Open zones'));
        await t.pumpAndSettle();
        expect(t.widget<ActionRow>(unknown).selected, isFalse);
        await t.tap(find.text('Cancel'));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
      },
    );
  }
}
