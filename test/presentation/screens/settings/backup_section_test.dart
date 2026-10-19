// TASK 14.4, F01 (D2/D7 A, UX-S R1, TD-105): the Settings backup section —
// back up; restore picked, checked, confirmed and applied at once (no
// pending state, no Undo); Back up first returns to the same confirmation
// only after success; a refusal says the current data is unchanged; the
// next app instance reports the outcome once.

import 'dart:io';

import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/backup_service.dart';
import 'package:astroplan/presentation/screens/settings/backup_section.dart'
    show notShared;
import 'package:astroplan/presentation/screens/settings/settings_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/no_snapshot_weather.dart';
import '../../../support/planner_harness.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

class _FakeBackup implements BackupService {
  int backups = 0;
  Object? restored;
  BackupProblem? refuse;
  bool cancelPick = false;
  bool failBackup = false;
  bool dismissShare = false;
  bool failRestore = false;
  int sessions = 12;
  RestoreOutcome? stored;
  int cleared = 0;

  @override
  Future<bool> backUpAndShare() async {
    if (failBackup) throw StateError('share failed');
    backups++;
    return !dismissShare;
  }

  @override
  Future<({BackupPreview preview, Object file})?> pick() async {
    if (refuse != null) throw BackupException(refuse!);
    if (cancelPick) return null;
    return (
      preview: BackupPreview(
        createdAtUtc: DateTime.utc(2026, 12, 16, 8),
        schemaVersion: 17,
        appVersion: '0.9.0',
        sessionCount: sessions,
      ),
      file: 'backup-bytes',
    );
  }

  @override
  Future<void> restoreAndRestart(Object file) async {
    if (failRestore) throw const FileSystemException('disk full');
    restored = file;
  }

  @override
  Future<RestoreOutcome?> outcome() async => stored;

  @override
  Future<void> clearOutcome() async {
    stored = null;
    cleared++;
  }
}

void main() {
  late AppDatabase database;
  late PlannerHarness vm;
  late _FakeBackup backup;

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({});
      database = AppDatabase(NativeDatabase.memory());
      backup = _FakeBackup();
      vm = PlannerHarness(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        _NoWeather(),
        DriftLocationRepository(database),
        locationService: FakeLocationService(),
        backup: backup,
      );
      await vm.ready;
      await vm.vms.backup!.load();
    });
    addTearDown(() => tester.runAsync(database.close));
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Back up now shares a backup', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('backup.backUp')));
    await tester.pumpAndSettle();
    expect(backup.backups, 1);
    expect(find.text('Backup file created'), findsOneWidget); // S9.8
  });

  Future<void> openConfirmation(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('backup.restore')));
    await tester.pumpAndSettle();
  }

  testWidgets('restore: the preview is confirmed, then applied at once', (
    tester,
  ) async {
    await pump(tester);
    await openConfirmation(tester);
    // TD-105: the backup's version, not this app's name; plans, plural.
    expect(find.textContaining('by version 0.9.0, with 12 plans'), findsOne);
    expect(find.textContaining('by Culmina'), findsNothing);
    // S13.2, TD-093: the confirmation names the backup's date and time.
    final made = DateTime.utc(2026, 12, 16, 8).toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    expect(
      find.textContaining(
        'Made ${months[made.month - 1]} ${made.day}, ${made.year}, ',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('(device zone, UTC'), findsOneWidget);
    // D2 A: truthful recovery, no Undo and no unreachable safety copy.
    expect(find.textContaining('cannot be undone in the app'), findsOne);
    expect(find.textContaining('safety copy'), findsNothing);
    expect(find.text('Undo'), findsNothing);
    expect(find.byKey(const Key('restore.backUpFirst')), findsOneWidget);
    expect(backup.restored, isNull, reason: 'nothing before confirmation');

    await tester.tap(find.byKey(const Key('confirm.action')));
    await tester.pumpAndSettle();
    expect(backup.restored, 'backup-bytes');
    // D7 A: no pending restore is ever shown.
    expect(find.byKey(const Key('backup.staged')), findsNothing);
    expect(find.textContaining('Restore ready'), findsNothing);
  });

  testWidgets('TD-105: one plan is singular', (tester) async {
    await pump(tester);
    backup.sessions = 1;
    await openConfirmation(tester);
    expect(find.textContaining('with 1 plan.'), findsOne);
  });

  testWidgets('Back up first returns to the same confirmation after success', (
    tester,
  ) async {
    await pump(tester);
    await openConfirmation(tester);
    await tester.tap(find.byKey(const Key('restore.backUpFirst')));
    await tester.pumpAndSettle();
    expect(backup.backups, 1);
    expect(backup.restored, isNull);
    expect(find.text('Restore this backup?'), findsOneWidget);
    expect(find.textContaining('with 12 plans'), findsOne);
    await tester.tap(find.byKey(const Key('confirm.action')));
    await tester.pumpAndSettle();
    expect(backup.restored, 'backup-bytes');
  });

  testWidgets('a failed Back up first never restores', (tester) async {
    await pump(tester);
    backup.failBackup = true;
    await openConfirmation(tester);
    await tester.tap(find.byKey(const Key('restore.backUpFirst')));
    await tester.pumpAndSettle();
    expect(find.text('Restore this backup?'), findsNothing);
    expect(find.textContaining("Couldn't back up"), findsOneWidget);
    expect(backup.restored, isNull);
  });

  // F01 A4: a share sheet closed without sharing kept no backup, so the
  // confirmation does not come back and nothing is restored.
  testWidgets('Back up first whose share sheet is closed never restores', (
    tester,
  ) async {
    await pump(tester);
    backup.dismissShare = true;
    await openConfirmation(tester);
    await tester.tap(find.byKey(const Key('restore.backUpFirst')));
    await tester.pumpAndSettle();
    expect(backup.backups, 1);
    expect(find.text('Restore this backup?'), findsNothing);
    expect(find.text(notShared), findsOneWidget);
    expect(find.text('Backup file created'), findsNothing);
    expect(backup.restored, isNull);
  });

  testWidgets('Back up now whose share sheet is closed says no backup was '
      'saved', (tester) async {
    await pump(tester);
    backup.dismissShare = true;
    await tester.tap(find.byKey(const Key('backup.backUp')));
    await tester.pumpAndSettle();
    expect(find.text(notShared), findsOneWidget);
    expect(find.text('Backup file created'), findsNothing);
  });

  testWidgets('cancelling the confirmation restores nothing', (tester) async {
    await pump(tester);
    await openConfirmation(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(backup.restored, isNull);
  });

  testWidgets('a restore that cannot start says the data is unchanged', (
    tester,
  ) async {
    await pump(tester);
    backup.failRestore = true;
    await openConfirmation(tester);
    await tester.tap(find.byKey(const Key('confirm.action')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Your current data is unchanged'), findsOne);
    expect(find.byKey(const Key('backup.restore')), findsOneWidget);
  });

  for (final (problem, reason) in [
    (BackupProblem.newerSchema, 'newer version of Culmina'),
    (BackupProblem.unusable, 'damaged or incomplete'),
    (BackupProblem.notABackup, 'not a Culmina backup'),
  ]) {
    testWidgets('a refused file (${problem.name}) is explained at pick time', (
      tester,
    ) async {
      await pump(tester);
      backup.refuse = problem;
      await tester.tap(find.byKey(const Key('backup.restore')));
      await tester.pumpAndSettle();
      expect(find.textContaining('The backup was not applied'), findsOne);
      expect(find.textContaining(reason), findsOneWidget);
      expect(find.textContaining('Your current data is unchanged'), findsOne);
      expect(find.text('Restore this backup?'), findsNothing);
      expect(backup.restored, isNull);
    });
  }
}
