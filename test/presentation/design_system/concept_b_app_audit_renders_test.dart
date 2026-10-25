// Opt-in whole-app visual audit. Isolated in-memory fixtures per frame;
// no production edits, private files, physical data or persistence side effects.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/main.dart';
import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/domain/services/astrobin_acquisitions.dart';
import 'package:astroplan/domain/services/session_exporter.dart';
import 'package:astroplan/presentation/viewmodels/astrobin_export_viewmodel.dart';
import 'package:astroplan/domain/services/backup_service.dart';
import 'package:astroplan/presentation/viewmodels/backup_viewmodel.dart';
import 'package:astroplan/presentation/screens/settings/backup_section.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/presentation/viewmodels/metadata_import_viewmodel.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/screens/startup/unsupported_database_screen.dart';
import 'package:astroplan/presentation/screens/target/target_detail_screen.dart';
import 'package:astroplan/presentation/screens/home/plan_rig_screen.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:astroplan/domain/models/target_alias.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../support/hybrid_transfer_fixture.dart';
import '../../support/hybrid_transfer_shots.dart';
import '../../support/sdk_fonts.dart';
import '../../support/fake_capture_file_access.dart';
import '../../support/jpeg_fixture.dart';
import '../../support/held_library_reads.dart';

const _shot = Key('app.audit.render');
Future<void> _loadFonts() async {
  Future<ByteData> sdk(String f) {
    final file = sdkMaterialFont(f);
    if (file == null) throw StateError('$f not in the SDK');
    return file.readAsBytes().then((b) => ByteData.sublistView(b));
  }

  Future<ByteData> asset(String f) =>
      File('assets/fonts/$f').readAsBytes().then(ByteData.sublistView);

  for (final family in ['Roboto', 'FlutterTest']) {
    final roboto = FontLoader(family);
    for (final f in [
      'roboto-regular.ttf',
      'roboto-medium.ttf',
      'roboto-bold.ttf',
    ]) {
      roboto.addFont(sdk(f));
    }
    await roboto.load();
  }
  await (FontLoader('Geist')..addFont(asset('Geist.ttf'))).load();
  await (FontLoader(
    'Source Serif 4',
  )..addFont(asset('SourceSerif4.ttf'))).load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(sdk('materialicons-regular.otf'))).load();
}

class _AuditAstroBin implements AstroBinCsvExporter {
  @override
  Future<void> share(AstroBinExport export) async =>
      throw StateError('Audit must not share');
}

class _AuditSessionExporter implements SessionExporter {
  @override
  Future<void> share(List<ExportedSession> sessions) async =>
      throw StateError('Audit must not share');
}

class _AuditBackup implements BackupService {
  _AuditBackup({this.refuse = false});
  final bool refuse;
  @override
  Future<({BackupPreview preview, Object file})?> pick() async {
    if (refuse) throw const BackupException(BackupProblem.unusable);
    return (
      preview: BackupPreview(
        createdAtUtc: DateTime.utc(2026, 10, 24),
        schemaVersion: 25,
        appVersion: '1.0.0',
        sessionCount: 12,
      ),
      file: 'synthetic',
    );
  }

  @override
  Future<bool> backUpAndShare() async =>
      throw StateError('Audit must not share');
  @override
  Future<void> restoreAndRestart(Object file) async =>
      throw StateError('Audit must not restore');
  @override
  Future<RestoreOutcome?> outcome() async => null;
  @override
  Future<void> clearOutcome() async {}
}

Future<void> _libraryState(HybridRenderContext c, String name) async {
  final theme = Theme.of(c.tester.element(find.byType(Scaffold).last));
  final aliases = HeldAliasReads();
  final rigs = HeldGearReads();
  addTearDown(aliases.dispose);
  addTearDown(rigs.dispose);
  final target = c.fixture.vm.plan.selectedTarget!;
  final aliasScreen = name.startsWith('aliases_');
  await c.tester.pumpWidget(
    RepaintBoundary(
      key: _shot,
      child: MultiProvider(
        providers: [
          ...c.fixture.vm.providers,
          ChangeNotifierProvider<TargetsViewModel>.value(value: aliases),
          ChangeNotifierProvider<GearViewModel>.value(value: rigs),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: aliasScreen
              ? TargetDetailScreen(target: target, onPlan: (_) async {})
              : const PlanRigScreen(),
        ),
      ),
    ),
  );
  await c.tester.pump();
  if (name.endsWith('_loading')) return;
  if (name.endsWith('_error') || name == 'planrig_empty') {
    if (aliasScreen) {
      aliases.reads.last.completeError(
        StateError('Synthetic unavailable read'),
      );
    } else {
      rigs.reads.last.completeError(StateError('Synthetic unavailable read'));
    }
    await c.tester.pump();
    if (name != 'planrig_empty') return;
    await c.settle();
    await c.tester.tap(find.text('Retry'));
    await c.tester.pump();
  }
  if (aliasScreen) {
    aliases.reads.last.complete(
      name.endsWith('_empty')
          ? {}
          : {
              target.catalogId: [
                const TargetAlias(
                  catalogId: 'M31',
                  alias: 'NGC 224',
                  kind: TargetAliasKind.designation,
                ),
              ],
            },
    );
  } else {
    rigs.reads.last.complete(
      name.endsWith('_empty') ? [] : [c.fixture.vm.plan.selectedEquipment!],
    );
  }
  await c.tester.pump();
}

Future<void> _scrollPage(HybridRenderContext c, double amount) async {
  final page = find
      .byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      )
      .first;
  final position = c.tester.state<ScrollableState>(page).position;
  position.jumpTo(
    (position.pixels + amount).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    ),
  );
  await c.settle();
}

final _auditShots = <String, HybridStep>{
  ...hybridShots,

  'night_reading_body': (c) async {
    await hybridShots['night_reading_open']!(c);
    await Scrollable.ensureVisible(
      c.tester.element(find.byKey(const Key('nightMoon.readingNote'))),
      alignment: .82,
    );
    await c.settle();
  },
  'night_exact_events': (c) async {
    await hybridShots['night_exact_open']!(c);
    await Scrollable.ensureVisible(
      c.tester.element(find.text('Sun events')),
      alignment: .12,
    );
    await c.settle();
  },
  'night_exact_intervals': (c) async {
    await hybridShots['night_exact_open']!(c);
    final last = find
        .descendant(
          of: find.byKey(const Key('nightMoon.exactTimes')),
          matching: find.text('Moon-free dark'),
        )
        .last;
    await Scrollable.ensureVisible(c.tester.element(last), alignment: .72);
    await c.settle();
  },
  'night_sun_tail': (c) async {
    await hybridShots['night_sun_open']!(c);
    final note = find.byWidgetPredicate(
      (w) => w is Text && (w.data?.startsWith('Twilight limits:') ?? false),
    );
    await Scrollable.ensureVisible(c.tester.element(note), alignment: .82);
    await c.settle();
  },
  'night_moon_tail': (c) async {
    await hybridShots['night_moon_open']!(c);
    final note = find.byWidgetPredicate(
      (w) =>
          w is Text &&
          (w.data?.startsWith('Moon-free means dark time') ?? false),
    );
    await Scrollable.ensureVisible(c.tester.element(note), alignment: .85);
    await c.settle();
  },
  'plan_budget_facts': (c) async {
    await c.push(AppRouter.session());
    await c.tapKey('section.planner.budgetDetails');
    await Scrollable.ensureVisible(
      c.tester.element(find.byKey(const Key('budget.timeNeeded'))),
      alignment: .12,
    );
    await c.settle();
  },
  'plan_budget_assumptions': (c) async {
    await c.push(AppRouter.session());
    await c.tapKey('section.planner.budgetDetails');
    await Scrollable.ensureVisible(
      c.tester.element(find.byKey(const Key('capturePlan.assumptionsBody'))),
      alignment: .08,
    );
    await c.settle();
  },
  'plan_budget_notes': (c) async {
    await c.push(AppRouter.session());
    await c.tapKey('section.planner.budgetDetails');
    await Scrollable.ensureVisible(
      c.tester.element(find.byKey(const Key('planOverride.edit'))),
      alignment: .82,
    );
    await c.settle();
  },
  'plan_gain_open': (c) async {
    await c.push(AppRouter.session());
    await c.tapKey('section.planner.gainHelp');
    await Scrollable.ensureVisible(
      c.tester.element(find.byKey(const Key('capturePlan.gainTable'))),
      alignment: .1,
    );
    await c.settle();
  },
  'block_details_light': (c) async {
    await hybridShots['plan_editor']!(c);
    await c.tapKey('section.blockEditor.Details');
    await c.scrollBy(10000, key: 'blockEditor.scroll');
  },
  'block_details_calibration': (c) async {
    await hybridShots['plan_editor']!(c);
    await c.tapText('Dark');
    await c.tapKey('section.blockEditor.Details');
    await c.scrollBy(10000, key: 'blockEditor.scroll');
  },

  'plan_rig_facts': (c) async {
    await c.push(AppRouter.session());
    await c.tapKey('section.planner.rigDetails');
    await Scrollable.ensureVisible(
      c.tester.element(find.text('Camera type')),
      alignment: .12,
    );
    await c.settle();
  },
  'plan_rig_tracking': (c) async {
    await c.push(AppRouter.session());
    await c.tapKey('section.planner.rigDetails');
    await Scrollable.ensureVisible(
      c.tester.element(find.byKey(const Key('planner.tracking'))),
      alignment: .82,
    );
    await c.settle();
  },

  'logbook_lower': (c) async {
    await hybridShots['logbook']!(c);
    await _scrollPage(c, 10000);
  },
  'rig_record_lower': (c) async {
    await hybridShots['lib_rig_full']!(c);
    await _scrollPage(c, 10000);
  },
  'rig_record_sources': (c) async {
    await hybridShots['lib_rig_full']!(c);
    final source = find.byWidgetPredicate(
      (w) => w is Text && (w.data?.startsWith('Camera specs:') ?? false),
    );
    await Scrollable.ensureVisible(c.tester.element(source), alignment: .12);
    await c.settle();
  },
  'rig_more_open': (c) async {
    await hybridShots['lib_rig_edit']!(c);
    await c.tapText('More (optional)');
    await c.scrollBy(10000, key: 'rigEditor.scroll');
  },
  'site_details_lower': (c) async {
    await hybridShots['lib_site']!(c);
    await c.tapKey('siteDetail.details');
    await _scrollPage(c, 10000);
  },
  'progress_guide_open': (c) async {
    await hybridShots['logbook_progress']!(c);
    await c.tapKey('progress.guide');
    await _scrollPage(c, 10000);
  },
  'entry_snapshot_open': (c) async {
    await hybridShots['entry']!(c);
    await c.tapKey('detail.snapshot');
    await Scrollable.ensureVisible(
      c.tester.element(find.byKey(const Key('detail.night'))),
      alignment: .12,
    );
    await c.settle();
  },
  'entry_snapshot_lower': (c) async {
    await hybridShots['entry']!(c);
    await c.tapKey('detail.snapshot');
    await Scrollable.ensureVisible(
      c.tester.element(find.byKey(const Key('detail.weather'))),
      alignment: .72,
    );
    await c.settle();
  },
  'entry_export_open': (c) async {
    await hybridShots['entry']!(c);
    await c.tapKey('detail.exportSection');
    await c.scrollBy(10000, key: 'detail.scroll');
  },
  'entry_csv_preview': (c) async {
    await hybridShots['entry']!(c);
    await c.tapKey('detail.exportSection');
    await c.tapKey('detail.astrobin');
  },
  'weather_hour_open': (c) async {
    await c.push(AppRouter.weather);
    await c.tapKey('weather.hourDetails');
    await Scrollable.ensureVisible(
      c.tester.element(find.byKey(const Key('weather.hourDetails'))),
      alignment: .12,
    );
    await c.settle();
  },
  'weather_forecast_open': (c) async {
    await c.push(AppRouter.weather);
    await c.tapKey('weather.details');
    await _scrollPage(c, 700);
  },
  'weather_forecast_table': (c) async {
    await c.push(AppRouter.weather);
    await c.tapKey('weather.details');
    await Scrollable.ensureVisible(
      c.tester.element(find.byKey(const Key('weather.table'))),
      alignment: .12,
    );
    await c.settle();
  },
  'weather_forecast_lead': (c) async {
    await c.push(AppRouter.weather);
    await c.tapKey('weather.details');
    await Scrollable.ensureVisible(
      c.tester.element(find.byKey(const Key('weather.partial'))),
      alignment: .12,
    );
    await c.settle();
  },
  'weather_table_later': (c) async {
    await c.push(AppRouter.weather);
    await c.tapKey('weather.details');
    final table = find.byKey(const Key('weather.table'));
    await Scrollable.ensureVisible(c.tester.element(table), alignment: .12);
    final position = c.tester
        .state<ScrollableState>(
          find.descendant(of: table, matching: find.byType(Scrollable)).first,
        )
        .position;
    position.jumpTo(position.maxScrollExtent);
    await c.settle();
  },

  for (final kind in ['aliases', 'planrig'])
    for (final state in ['loading', 'error', 'empty', 'populated'])
      '${kind}_$state': (c) => _libraryState(c, '${kind}_$state'),
  'welcome': (c) => c.push(AppRouter.welcome),
  'metadata': (c) => c.push(AppRouter.metadata),
  'result_notdone': (c) async {
    await hybridShots['result']!(c);
    await c.tapText('Not done');
  },
  'result_completed': (c) async {
    await hybridShots['result']!(c);
    await c.tapText('Completed as planned');
  },

  'logbook_empty': (c) => c.go(AppRouter.sessions),
  'progress_empty': (c) => c.push(AppRouter.logbookProgress),
  'rigs_no_results': (c) async {
    await c.push(AppRouter.manageRigs);
    await c.tester.enterText(find.byKey(const Key('rigs.search')), 'NoSuchRig');
  },
  'targets_no_results': (c) async {
    await c.push(AppRouter.manageTargets);
    await c.tester.enterText(
      find.byKey(const Key('targets.search')),
      'NoSuchTarget',
    );
  },
  'plan_empty': (c) async {
    await c.tester.runAsync(() async {
      while (c.fixture.vm.plan.captureBlocks.isNotEmpty) {
        await c.fixture.vm.plan.removeCaptureBlock(0);
      }
      await c.fixture.vm.plan.idle;
    });
    await c.push(AppRouter.session());
  },

  'storage_file': (c) async {
    await c.push(AppRouter.session());
    await c.tapKey('section.planner.budgetDetails');
    await c.tapKey('capturePlan.chooseFile');
  },

  'map_coordinates': (c) async {
    await c.push(AppRouter.position);
    await c.tapKey('location.coordinates');
  },

  'entry_name': (c) async {
    await hybridShots['entry']!(c);
    await c.tapKey('detail.name');
  },
  'entry_copy': (c) async {
    await hybridShots['entry']!(c);
    await c.tapText('Copy to another night');
  },
  'site_name_consent': (c) async {
    await c.push(AppRouter.siteEdit);
    await c.tester.enterText(
      find.byKey(const Key('siteEditor.latitude')),
      '50.4',
    );
    await c.tester.enterText(
      find.byKey(const Key('siteEditor.longitude')),
      '30.6',
    );
    await c.settle();
    await c.tapKey('siteEditor.lookupName');
  },
  'unsupported_confirm': (c) async {
    await c.tester.pumpWidget(
      RepaintBoundary(
        key: _shot,
        child: UnsupportedDatabaseApp(
          newerThanApp: false,
          foundVersion: 1,
          isFieldMode: c.fixture.vm.theme.isFieldMode,
          themeMode:
              Theme.of(c.tester.element(find.byType(Scaffold).last))
                      .brightness ==
                  Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          onReset: () async {},
        ),
      ),
    );
    await c.settle();
    await c.tapKey('unsupportedDb.reset');
  },
  'result_ime': (c) async {
    await hybridShots['result_b']!(c);
  },

  'restore_wait': (c) async {
    await c.tester.pumpWidget(
      RepaintBoundary(
        key: _shot,
        child: RestoringBackupApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          isFieldMode: c.fixture.vm.theme.isFieldMode,
        ),
      ),
    );
  },

  'backup_restore': (c) async {
    await hybridShots['settings_backup']!(c);
    await c.tapKey('backup.restore');
  },
  'backup_error': (c) async {
    await hybridShots['settings_backup']!(c);
    await c.tapKey('backup.restore');
  },
  'licenses': (c) async {
    await c.push(AppRouter.about);
    await c.tapText('Open-source licences');
  },
  'zone_dialog': (c) async {
    await c.push(AppRouter.siteEdit);
    await c.tapKey('siteEditor.zone');
  },
  'site_pick': (c) => c.push(AppRouter.sitePick),

  'capture_ime': (c) async {
    await hybridShots['plan_editor']!(c);
  },
  'rig_ime': (c) async {
    await hybridShots['lib_rig_edit']!(c);
  },
  'site_ime': (c) async {
    await hybridShots['lib_site_edit']!(c);
  },
  'target_ime': (c) async {
    await hybridShots['lib_target_new']!(c);
  },
  'target_invalid': (c) async {
    await hybridShots['lib_target_new']!(c);
    await c.tapKey('targetEditor.save');
  },
  'astrobin_preview': (c) async {
    await hybridShots['logbook']!(c);
    await c.tapKey('logbook.menu');
    await c.tapKey('logbook.astrobin');
  },

  'metadata_ready': (c) => c.push(AppRouter.metadata),
  'metadata_read': (c) => c.push(AppRouter.metadata),
  'metadata_read_b': (c) async {
    await c.push(AppRouter.metadata);
    await c.scrollBy(1400);
  },
  'metadata_unreadable': (c) => c.push(AppRouter.metadata),
  'plan_actions': (c) async {
    await c.push(AppRouter.session());
    final action = find.byKey(const Key('capturePlan.addBlock'));
    final scroll = find
        .descendant(
          of: find.byKey(const Key('planner.scroll')),
          matching: find.byType(Scrollable),
        )
        .first;
    await c.tester.scrollUntilVisible(action, 300, scrollable: scroll);
    await Scrollable.ensureVisible(c.tester.element(action), alignment: .25);
  },

  'welcome_b': (c) async {
    await c.push(AppRouter.welcome);
    await c.scrollBy(1500);
  },
  'rig_add_sheet': (c) async {
    await c.push(AppRouter.manageRigs);
    await c.tapKey('rigs.add');
  },
  'rig_new': (c) async {
    await c.push(AppRouter.manageRigs);
    await c.tapKey('rigs.add');
    await c.tapKey('addRig.class.dslrMirrorless');
    await c.tapKey('addRig.byHand');
    expect(find.byKey(const Key('rigEditor.save')), findsOneWidget);
  },
  'rig_new_b': (c) async {
    await c.push(AppRouter.manageRigs);
    await c.tapKey('rigs.add');
    await c.tapKey('addRig.class.dslrMirrorless');
    await c.tapKey('addRig.byHand');
    expect(find.byKey(const Key('rigEditor.save')), findsOneWidget);
    await c.scrollBy(1800, key: 'rigEditor.scroll');
  },
  'settings_backup_b': (c) async {
    await hybridShots['settings_backup']!(c);
    await c.scrollBy(1000);
  },
  'settings_about_b': (c) async {
    await hybridShots['settings_about']!(c);
    await c.scrollBy(1500);
  },
  'lib_site_b': (c) async {
    await hybridShots['lib_site']!(c);
    await c.scrollBy(1400);
  },
  'lib_target_b': (c) async {
    await hybridShots['lib_target']!(c);
    await c.scrollBy(1200);
  },
  'lib_rig_b': (c) async {
    await hybridShots['lib_rig']!(c);
    await c.scrollBy(1000);
  },
  'logbook_progress_b': (c) async {
    await hybridShots['logbook_progress']!(c);
    await c.scrollBy(1200);
  },
  'candidates_b': (c) async {
    await c.push(AppRouter.candidates);
    await c.scrollBy(1400);
  },

  'manage_rigs': (c) => c.push(AppRouter.manageRigs),
  'manage_targets': (c) => c.push(AppRouter.manageTargets),
  'select_sites': (c) => c.push(AppRouter.selectSite),
  'plan_settings': (c) => c.push(AppRouter.planSettings),
  'lib_target_new_b': (c) async {
    await hybridShots['lib_target_new']!(c);
    await c.scrollBy(1000, key: 'targetEditor.scroll');
  },
  'lib_rig_edit_b': (c) async {
    await hybridShots['lib_rig_edit']!(c);
    await c.scrollBy(1400, key: 'rigEditor.scroll');
  },
  'lib_site_edit_b': (c) async {
    await hybridShots['lib_site_edit']!(c);
    await c.scrollBy(1300, key: 'siteEditor.scroll');
  },
  for (final newer in [true, false])
    (newer ? 'unsupported_newer' : 'unsupported_older'): (c) async {
      await c.tester.pumpWidget(
        RepaintBoundary(
          key: _shot,
          child: UnsupportedDatabaseApp(
            newerThanApp: newer,
            foundVersion: newer ? 999 : 1,
            isFieldMode: c.fixture.vm.theme.isFieldMode,
            themeMode:
                Theme.of(c.tester.element(find.byType(Scaffold).last))
                        .brightness ==
                    Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light,
            onReset: () async {},
          ),
        ),
      );
    },
};

void main() {
  final out = Platform.environment['CULMINA_AUDIT_RENDERS'];
  if (out == null) {
    test(
      'whole-app visual audit is opt-in',
      () {},
      skip: 'Set CULMINA_AUDIT_RENDERS',
    );
    return;
  }

  final themes = (Platform.environment['CULMINA_AUDIT_THEMES'] ?? 'dark').split(
    ',',
  );
  final names =
      (Platform.environment['CULMINA_AUDIT_SHOTS'] ??
              _auditShots.keys.join(','))
          .split(',');
  final scale = double.parse(
    Platform.environment['CULMINA_AUDIT_SCALE'] ?? '1',
  );
  const width = 375.0;
  const height = 812.0;
  for (final theme in themes) {
    for (final name in names) {
      testWidgets('Concept B app audit: $name $theme $scale', (tester) async {
        await tester.runAsync(_loadFonts);
        tester.view.physicalSize = const Size(width, height);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.platformBrightnessTestValue = theme == 'light'
            ? Brightness.light
            : Brightness.dark;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        tester.platformDispatcher.alwaysUse24HourFormatTestValue = true;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearAllTestValues);
        AppRouter.router.go(AppRouter.tonight);
        late HybridTransferFixture fixture;
        await tester.runAsync(() async {
          fixture = await HybridTransferFixture.create(
            AppDatabase(NativeDatabase.memory()),
            savePlan: name != 'logbook_empty',
            withSite: name != 'home_nosite',
          );
          if (theme == 'field') await fixture.vm.theme.toggleFieldMode();
        });
        addTearDown(() => tester.runAsync(fixture.db.close));
        BackupViewModel? auditBackup;
        if (name.startsWith('backup_')) {
          auditBackup = BackupViewModel(
            _AuditBackup(refuse: name == 'backup_error'),
          );
          addTearDown(auditBackup.dispose);
        }
        MetadataImportViewModel? metadataModel;
        if (name.startsWith('metadata_') || name == 'storage_file') {
          final files = FakeCaptureFileAccess();
          metadataModel = MetadataImportViewModel(
            files,
            DriftEquipmentRepository(fixture.db),
          );
          if (name != 'metadata_ready') {
            files.file(
              'synthetic-qa.jpg',
              name == 'metadata_unreadable'
                  ? [0, 1, 2]
                  : jpegFile([exifApp1(phoneStyleJpegExif().build().bytes)]),
              length: name == 'storage_file' ? 5000000 : null,
            );
            if (name != 'storage_file') {
              await tester.runAsync(metadataModel.pickAndRead);
            }
          }
          addTearDown(metadataModel.dispose);
        }

        const pathProvider = MethodChannel('plugins.flutter.io/path_provider');
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          pathProvider,
          (call) async => Directory.systemTemp.path,
        );
        await tester.pumpWidget(
          RepaintBoundary(
            key: _shot,
            child: MultiProvider(
              providers: [
                ...fixture.vm.providers,
                if (name == 'entry_export_open' || name == 'entry_csv_preview')
                  ChangeNotifierProvider<SessionsViewModel>(
                    create: (_) => SessionsViewModel(
                      fixture.sessions,
                      exporter: _AuditSessionExporter(),
                      clock: FixedClock(hybridTransferNow),
                    ),
                  ),
                if (name == 'astrobin_preview' ||
                    name == 'entry_export_open' ||
                    name == 'entry_csv_preview')
                  Provider<AstroBinExportViewModel>(
                    create: (_) => AstroBinExportViewModel(
                      DriftSessionRepository(fixture.db),
                      _AuditAstroBin(),
                    ),
                  ),
                if (auditBackup != null)
                  ChangeNotifierProvider<BackupViewModel>.value(
                    value: auditBackup,
                  ),
                if (metadataModel != null)
                  ChangeNotifierProvider<MetadataImportViewModel>.value(
                    value: metadataModel,
                  ),
              ],
              child: Builder(
                builder: (context) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(alwaysUse24HourFormat: true),
                  child: const AstroPlanApp(),
                ),
              ),
            ),
          ),
        );
        await hybridSettle(tester);
        Object? routeError;
        try {
          await _auditShots[name]!(HybridRenderContext(tester, fixture));
          await hybridSettle(tester);
          if (name.endsWith('_ime')) {
            await tester.showKeyboard(find.byType(TextFormField).first);
            tester.view.viewInsets = const FakeViewPadding(bottom: 300);
            await hybridSettle(tester);
          }
        } catch (e) {
          routeError = e;
        }
        final exception = tester.takeException();
        final texts = <Map<String, Object?>>[];
        final geometry = <Map<String, Object?>>[];
        for (final e in find.byType(RichText).evaluate()) {
          final ro = e.renderObject;
          if (ro is! RenderParagraph || !ro.hasSize || !ro.attached) continue;
          final text = ro.text.toPlainText().trim();
          final o = ro.localToGlobal(Offset.zero);
          if (text.isEmpty || o.dy > height || o.dy + ro.size.height < 0) {
            continue;
          }
          final span = ro.text is TextSpan ? ro.text as TextSpan : null;
          final st = (ro.text.style ?? const TextStyle()).merge(
            span?.children?.whereType<TextSpan>().firstOrNull?.style,
          );
          texts.add({
            'text': text,
            'x': o.dx,
            'y': o.dy,
            'w': ro.size.width,
            'h': ro.size.height,
            'family': st.fontFamily,
            'maxLines': ro.maxLines,
            'didExceedMaxLines': ro.didExceedMaxLines,
            'size': st.fontSize,
            'weight': st.fontWeight?.value,
            'height': st.height,
          });
        }
        const kinds = {
          'DocumentSection',
          'Padding',
          'Card',
          'FilledButton',
          'OutlinedButton',
          'TextButton',
          'IconButton',
          'TextFormField',
          'SettingsRow',
          'HybridRow',
          'ListTile',
          'Scaffold',
          'SafeArea',
          'Divider',
        };
        for (final e
            in find
                .byWidgetPredicate(
                  (w) => kinds.contains(w.runtimeType.toString()),
                )
                .evaluate()) {
          final ro = e.renderObject;
          if (ro is! RenderBox || !ro.hasSize || !ro.attached) continue;
          final o = ro.localToGlobal(Offset.zero);
          if (o.dy > height || o.dy + ro.size.height < 0) continue;
          geometry.add({
            'type': e.widget.runtimeType.toString(),
            'key': e.widget.key?.toString(),
            'x': o.dx,
            'y': o.dy,
            'w': ro.size.width,
            'h': ro.size.height,
            if (e.widget is Padding)
              'padding': (e.widget as Padding).padding.toString(),
          });
        }
        final file = '$out/$name-$theme-${scale.toInt()}';
        File('$file.json').writeAsStringSync(
          const JsonEncoder.withIndent('  ').convert({
            'name': name,
            // The capture runner supplies real provenance; absent stays unknown.
            'captureUtc': Platform.environment['CULMINA_RENDER_CAPTURE_UTC'],
            'captureKind': 'native Flutter host',
            'sourceHead': Platform.environment['CULMINA_RENDER_HEAD'],
            'inputManifest':
                Platform.environment['CULMINA_RENDER_INPUT_MANIFEST'],
            'proposalOnly': name.startsWith('u4_'),
            'fixtureSucceeded': routeError == null && exception == null,
            'devicePixelRatio': tester.view.devicePixelRatio,
            'visibleScreens': [
              for (final element
                  in find
                      .byWidgetPredicate(
                        (w) =>
                            w.runtimeType.toString().endsWith('Screen') ||
                            w.runtimeType.toString() == 'HybridWeatherView',
                      )
                      .evaluate())
                element.widget.runtimeType.toString(),
            ],
            'theme': theme,
            'scale': scale,
            'width': width,
            'height': height,
            'route': AppRouter.router.routeInformationProvider.value.uri
                .toString(),
            'routeError': routeError?.toString(),
            'layoutError': exception?.toString(),
            'texts': texts,
            'geometry': geometry,
          }),
        );
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(_shot),
        );
        await tester.runAsync(() async {
          final frame = await boundary.toImage();
          final png = await frame.toByteData(format: ui.ImageByteFormat.png);
          frame.dispose();
          File('$file.png').writeAsBytesSync(png!.buffer.asUint8List());
        });
        expect(routeError, isNull, reason: '$name route');
        expect(exception, isNull, reason: '$name layout');
      });
    }
  }
}
