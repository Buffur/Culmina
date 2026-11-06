import 'dart:async';

import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/location_profile.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/presentation/screens/library/library_screen.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:astroplan/presentation/viewmodels/site_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/startup_viewmodel.dart';
import 'package:astroplan/domain/metadata/capture_file_access.dart';
import 'package:astroplan/domain/models/camera_class.dart';
import 'package:astroplan/presentation/screens/equipment/add_rig_panel.dart';
import 'package:astroplan/presentation/screens/equipment/rig_detail_screen.dart';
import 'package:astroplan/presentation/screens/metadata/metadata_import_screen.dart';
import 'package:astroplan/presentation/screens/sites/zone_picker_dialog.dart';
import 'package:astroplan/presentation/screens/sites/site_detail_screen.dart';
import 'package:astroplan/presentation/viewmodels/metadata_import_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../support/in_memory_equipment_repository.dart';
import '../../support/phase2_state_capture.dart';
import '../../support/wave1_capture.dart';

class _HeldFilePicker implements CaptureFileAccess {
  final result = Completer<CaptureFile?>();
  int calls = 0;
  @override
  Future<CaptureFile?> pick() {
    calls++;
    return result.future;
  }
}

class _LibraryGear extends ChangeNotifier implements GearViewModel {
  final gate = Completer<List<EquipmentProfile>>();
  List<EquipmentProfile> records = [];
  @override
  Future<List<EquipmentProfile>> all() =>
      gate.isCompleted ? Future.value(records) : gate.future;
  void populate() {
    records = EquipmentSeeder.defaults;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _LibraryTargets extends ChangeNotifier implements TargetsViewModel {
  @override
  Future<List<AstroTarget>> search(String query) async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _LibrarySites extends ChangeNotifier implements SiteViewModel {
  _LibrarySites({this.records = const [], this.active});
  final List<LocationProfile> records;
  final LocationProfile? active;
  @override
  List<LocationProfile> get sites => records;
  @override
  LocationProfile? get activeSite => active;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _LibraryStartup extends ChangeNotifier implements StartupViewModel {
  bool loading = true;
  bool failed = false;
  @override
  bool get isLoading => loading;
  @override
  bool get hasBootstrapError => failed;
  void fail() {
    loading = false;
    failed = true;
    notifyListeners();
  }

  @override
  Future<void> retryBootstrap() async {
    failed = false;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    Future<void> host(WidgetTester tester, Widget child) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: phase2Theme(theme),
          builder: (_, child) => phase2Frame(child: child!, theme: theme),
          home: child,
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> capture(WidgetTester t, String state) =>
        capturePhase2State(t, package: 'package3', state: state, theme: theme);

    testWidgets(
      '$theme Library pending and bootstrap failure never fabricate counts',
      (t) async {
        final gear = _LibraryGear();
        final targets = _LibraryTargets();
        final sites = _LibrarySites();
        final startup = _LibraryStartup();
        addTearDown(gear.dispose);
        addTearDown(targets.dispose);
        addTearDown(sites.dispose);
        addTearDown(startup.dispose);
        // An unresolved repository read requires bounded pumps, not settle.
        t.view.physicalSize = const Size(375, 812);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        await t.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<GearViewModel>.value(value: gear),
              ChangeNotifierProvider<TargetsViewModel>.value(value: targets),
              ChangeNotifierProvider<SiteViewModel>.value(value: sites),
              ChangeNotifierProvider<StartupViewModel>.value(value: startup),
            ],
            child: MaterialApp(
              theme: phase2Theme(theme),
              builder: (_, child) => phase2Frame(child: child!, theme: theme),
              home: const LibraryScreen(),
            ),
          ),
        );
        await t.pump();
        expect(find.text('Loading library counts…'), findsOneWidget);
        expect(find.textContaining('Count unavailable'), findsOneWidget);
        expect(find.textContaining('0 rigs'), findsNothing);
        await capture(t, 'library-counts-and-startup-pending');
        gear.gate.complete([]);
        await t.pumpAndSettle();
        expect(find.textContaining('0 rigs'), findsOneWidget);
        expect(find.textContaining('0 targets'), findsOneWidget);
        startup.fail();
        await t.pumpAndSettle();
        expect(find.textContaining('Count unavailable'), findsOneWidget);
        expect(find.text('Retry loading saved site'), findsOneWidget);
        await capture(t, 'library-bootstrap-failed-zero-records');
        await t.tap(find.text('Retry loading saved site'));
        await t.pumpAndSettle();
        expect(find.textContaining('Count unavailable'), findsNothing);
        expect(find.textContaining('0 saved'), findsOneWidget);
        gear.populate();
        await t.pumpAndSettle();
        expect(find.textContaining('1 rig ·'), findsOneWidget);
        await capture(t, 'library-counts-populated-startup-recovered');
        expect(t.takeException(), isNull);
      },
    );

    testWidgets(
      '$theme full rig record retains Unknown and missing optional specs',
      (t) async {
        const rig = EquipmentProfile(
          id: 77,
          name: 'Synthetic unknown camera',
          sensorWidthMm: 23.5,
          sensorHeightMm: 15.6,
          pixelPitchUm: 3.76,
          resolutionWidthPx: 6000,
          resolutionHeightPx: 4000,
          focalLengthMm: 400,
          focalRatio: 40,
        );
        await host(t, const RigDetailScreen(rig: rig));
        expect(find.text('Unknown'), findsWidgets);
        final disclosure = find.text('Full rig record and sources');
        await t.ensureVisible(disclosure);
        await t.tap(disclosure);
        await t.pumpAndSettle();
        expect(find.text('Not recorded'), findsWidgets);
        expect(
          find.textContaining('The app does not work out sensor facts'),
          findsOneWidget,
        );
        expect(find.text('Full rig record and sources'), findsOneWidget);
        await capture(t, 'rig-record-unknown-full-specs');
        expect(t.takeException(), isNull);
      },
    );

    for (final known in [false, true]) {
      testWidgets(
        '$theme site detail ${known ? "sourced" : "unknown"} facts remain distinct',
        (t) async {
          final site = LocationProfile(
            id: 88,
            name: 'Synthetic site',
            latitude: 50.4,
            longitude: 30.6,
            timeZoneId: known ? 'Europe/Kyiv' : null,
            elevation: known ? 125 : null,
            bortleClass: known ? 4 : null,
            bortleSource: known ? 'user' : null,
            sqm: known ? 20.4 : null,
            sqmSource: known ? 'user' : null,
            notes: known ? 'Synthetic observation note' : null,
          );
          final sites = _LibrarySites(
            records: [site],
            active: known ? site : null,
          );
          addTearDown(sites.dispose);
          await host(
            t,
            ChangeNotifierProvider<SiteViewModel>.value(
              value: sites,
              child: const SiteDetailScreen(siteId: 88),
            ),
          );
          expect(
            find.text(known ? 'Used for planning' : 'Saved site'),
            findsOneWidget,
          );
          expect(
            find.text(
              known ? 'Europe/Kyiv' : 'Unknown — night uses mean solar time',
            ),
            findsOneWidget,
          );
          expect(find.text('50.40000°'), findsOneWidget);
          expect(find.text('30.60000°'), findsOneWidget);
          expect(find.text('Elevation'), findsNothing);
          expect(find.text('Bortle class'), findsNothing);
          expect(find.text('SQM'), findsNothing);
          await t.ensureVisible(find.text('Site details'));
          await t.tap(find.text('Site details'));
          await t.pumpAndSettle();
          if (known) {
            expect(find.text('Bortle 4'), findsOneWidget);
            expect(find.text('20.40 mag/arcsec²'), findsOneWidget);
            expect(find.text('Source: user'), findsNWidgets(2));
            expect(find.text('Synthetic observation note'), findsOneWidget);
          } else {
            expect(find.text('Unknown'), findsNWidgets(3));
            expect(find.text('None'), findsOneWidget);
          }
          expect(
            find.text('Bortle and SQM are never converted into each other.'),
            findsOneWidget,
          );
          await capture(
            t,
            'site-record-${known ? "sourced" : "unknown"}-details',
          );
          expect(t.takeException(), isNull);
        },
      );
    }

    testWidgets(
      '$theme deleted site record is explicit and offers no stale actions',
      (t) async {
        final sites = _LibrarySites();
        addTearDown(sites.dispose);
        await host(
          t,
          ChangeNotifierProvider<SiteViewModel>.value(
            value: sites,
            child: const SiteDetailScreen(siteId: 999),
          ),
        );
        expect(find.text('This site no longer exists.'), findsOneWidget);
        expect(find.byKey(const Key('siteDetail.edit')), findsNothing);
        expect(find.byKey(const Key('siteDetail.delete')), findsNothing);
        await capture(t, 'site-record-deleted');
        expect(t.takeException(), isNull);
      },
    );

    testWidgets(
      '$theme add rig preserves explicit camera choice and unavailable photo',
      (t) async {
        CameraClass? selected;
        await host(
          t,
          Scaffold(
            body: SingleChildScrollView(
              child: AddRigPanel(onByHand: (value) => selected = value),
            ),
          ),
        );
        expect(find.byKey(const Key('addRig.fromPhoto')), findsNothing);
        expect(
          t
              .widget<FilledButton>(find.byKey(const Key('addRig.byHand')))
              .onPressed,
          isNull,
        );
        await capture(t, 'add-rig-unselected-no-file-access');
        for (final camera in AddRigPanel.classes) {
          await t.ensureVisible(find.byKey(Key('addRig.class.${camera.name}')));
          await t.tap(find.byKey(Key('addRig.class.${camera.name}')));
          await t.pumpAndSettle();
          await t.ensureVisible(find.byKey(const Key('addRig.byHand')));
          await t.tap(find.byKey(const Key('addRig.byHand')));
          expect(selected, camera);
          await capture(t, 'add-rig-camera-${camera.name}');
        }
        expect(t.takeException(), isNull);
      },
    );

    testWidgets('$theme photo entry preserves every camera class', (t) async {
      CameraClass? selected;
      await host(
        t,
        Scaffold(
          body: SingleChildScrollView(
            child: AddRigPanel(
              onByHand: (_) {},
              onFromPhoto: (value) => selected = value,
            ),
          ),
        ),
      );
      final photo = find.byKey(const Key('addRig.fromPhoto'));
      expect(t.widget<FilledButton>(photo).onPressed, isNull);
      await capture(t, 'add-rig-unselected-file-access');
      for (final camera in AddRigPanel.classes) {
        await t.ensureVisible(find.byKey(Key('addRig.class.${camera.name}')));
        await t.tap(find.byKey(Key('addRig.class.${camera.name}')));
        await t.pumpAndSettle();
        await t.ensureVisible(photo);
        await t.tap(photo);
        expect(selected, camera);
        await capture(t, 'add-rig-photo-${camera.name}');
      }
      expect(t.takeException(), isNull);
    });

    testWidgets(
      '$theme metadata pending disables repick and cancellation recovers',
      (t) async {
        final files = _HeldFilePicker();
        final vm = MetadataImportViewModel(
          files,
          InMemoryEquipmentRepository(),
        );
        addTearDown(vm.dispose);
        await host(
          t,
          ChangeNotifierProvider<MetadataImportViewModel?>.value(
            value: vm,
            child: const MetadataImportScreen(),
          ),
        );
        await capture(t, 'metadata-idle');
        final pick = find.byKey(const Key('metadata.pick'));
        await t.tap(pick);
        await t.pump();
        expect(find.text('Reading capture file…'), findsOneWidget);
        expect(t.widget<FilledButton>(pick).onPressed, isNull);
        expect(files.calls, 1);
        await capture(t, 'metadata-reading-pending');
        files.result.complete(null);
        await t.pumpAndSettle();
        expect(find.text('Reading capture file…'), findsNothing);
        expect(t.widget<FilledButton>(pick).onPressed, isNotNull);
        expect(find.byKey(const Key('metadata.result')), findsNothing);
        await capture(t, 'metadata-cancelled-no-result');
      },
    );

    testWidgets(
      '$theme zone search empty explains recovery and Unknown returns null zone',
      (t) async {
        ZoneChoice? result;
        await host(
          t,
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async => result = await showZonePicker(
                  context,
                  current: 'Europe/Kyiv',
                ),
                child: const Text('Open zones'),
              ),
            ),
          ),
        );
        await t.tap(find.text('Open zones'));
        await t.pumpAndSettle();
        await capture(t, 'zone-populated-selected');
        final search = find.byType(TextField);
        await t.enterText(search, 'not-a-real-time-zone');
        await t.pumpAndSettle();
        expect(find.text('No matching time zones'), findsOneWidget);
        expect(
          find.text('Try another city or choose Unknown.'),
          findsOneWidget,
        );
        await capture(t, 'zone-no-matches');
        await t.enterText(search, 'Kyiv');
        await t.pumpAndSettle();
        expect(find.text('Europe/Kyiv'), findsOneWidget);
        await capture(t, 'zone-search-recovered');
        await t.tap(find.text('Unknown'));
        await t.pumpAndSettle();
        expect(result, isNotNull);
        expect(result!.zoneId, isNull);
        await t.tap(find.text('Open zones'));
        await t.pumpAndSettle();
        await t.enterText(find.byType(TextField), 'Kyiv');
        await t.pumpAndSettle();
        await t.tap(find.text('Europe/Kyiv'));
        await t.pumpAndSettle();
        expect(result!.zoneId, 'Europe/Kyiv');
        await t.tap(find.text('Open zones'));
        await t.pumpAndSettle();
        await capture(t, 'zone-cancel-available');
        await t.tap(find.text('Cancel'));
        await t.pumpAndSettle();
        expect(result, isNull);

        expect(t.takeException(), isNull);
      },
    );
  }
}
