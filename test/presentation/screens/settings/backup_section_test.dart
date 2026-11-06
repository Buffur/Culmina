// TASK 14.4, F01 (D2/D7 A, UX-S R1, TD-105): the Settings backup section —
// back up; restore picked, checked, confirmed and applied at once (no
// pending state, no Undo); Back up first returns to the same confirmation
// only after success; a refusal says the current data is unchanged; the
// next app instance reports the outcome once.

import 'dart:async';

import 'dart:io';

import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/backup_service.dart';
import 'package:astroplan/presentation/screens/settings/backup_section.dart'
    show notShared, RestoreOutcomeNotice, RestoringBackupApp;
import 'package:astroplan/presentation/screens/settings/settings_screen.dart';
import 'package:astroplan/presentation/screens/settings/settings_parts.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/no_snapshot_weather.dart';
import '../../../support/planner_harness.dart';
import '../../../support/phase2_state_capture.dart';
import '../../../support/wave1_capture.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

class _FakeBackup implements BackupService {
  int backups = 0;
  Object? restored;
  BackupProblem? refuse;
  bool cancelPick = false;
  bool failPickIo = false;
  int picks = 0;
  int shareCalls = 0;

  /// When set, a pick waits for it (a large file being copied and checked).
  Completer<void>? pickGate;
  bool failBackup = false;
  Completer<void>? backupGate;
  bool dismissShare = false;
  bool failRestore = false;
  int sessions = 12;
  RestoreOutcome? stored;
  int cleared = 0;

  @override
  Future<bool> backUpAndShare() async {
    shareCalls++;
    if (backupGate case final gate?) await gate.future;
    if (failBackup) throw StateError('share failed');
    backups++;
    return !dismissShare;
  }

  @override
  Future<({BackupPreview preview, Object file})?> pick() async {
    picks++;
    if (pickGate case final gate?) await gate.future;
    if (failPickIo) throw const FileSystemException('fixture unreadable file');
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
  setUpAll(loadWave1Font);
  for (final theme in ['light', 'dark', 'field']) {
    group('Phase2 backup $theme', () {
      void scenario(String description, WidgetTesterCallback callback) =>
          phase2Scenario(
            description,
            callback,
            package: 'package4',
            theme: theme,
          );

      late AppDatabase database;
      late PlannerHarness vm;
      late _FakeBackup backup;

      Future<void> pump(
        WidgetTester tester, {
        bool compact = false,
        bool pushed = false,
      }) async {
        tester.view.physicalSize = compact
            ? const Size(375, 900)
            : const Size(800, 3000);
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
            child: phase2Frame(
              theme: theme,
              child: MaterialApp(
                theme: phase2Theme(theme),
                home: RestoreOutcomeNotice(
                  child: pushed
                      ? const Scaffold(body: Text('Return destination'))
                      : const SettingsScreen(section: SettingsSection.backup),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (pushed) {
          unawaited(
            Navigator.of(tester.element(find.text('Return destination')))
                .push<void>(
                  MaterialPageRoute(
                    builder: (_) =>
                        const SettingsScreen(section: SettingsSection.backup),
                  ),
                ),
          );
          await tester.pumpAndSettle();
        }
      }

      scenario('Back up now shares a backup', (tester) async {
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

      scenario('restore: the preview is confirmed, then applied at once', (
        tester,
      ) async {
        await pump(tester);
        await openConfirmation(tester);
        // TD-105: the backup's version, not this app's name; plans, plural.
        expect(
          find.textContaining('by version 0.9.0, with 12 plans'),
          findsOne,
        );
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
            'Made ${made.day} ${months[made.month - 1]} ${made.year}, ',
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

      scenario('TD-105: one plan is singular', (tester) async {
        await pump(tester);
        backup.sessions = 1;
        await openConfirmation(tester);
        expect(find.textContaining('with 1 plan.'), findsOne);
      });

      scenario('Back up first returns to the same confirmation after success', (
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

      scenario('a failed Back up first never restores', (tester) async {
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
      scenario('Back up first whose share sheet is closed never restores', (
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

      scenario('Back up now whose share sheet is closed says no backup was '
          'saved', (tester) async {
        await pump(tester);
        backup.dismissShare = true;
        await tester.tap(find.byKey(const Key('backup.backUp')));
        await tester.pumpAndSettle();
        expect(find.text(notShared), findsOneWidget);
        expect(find.text('Backup file created'), findsNothing);
      });

      scenario('cancelling the confirmation restores nothing', (tester) async {
        await pump(tester);
        await openConfirmation(tester);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(backup.restored, isNull);
      });

      scenario('a restore that cannot start says the data is unchanged', (
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

      // TD-113: a large picked file is copied and checked first; the section
      // says so, and the refusal stays until dismissed instead of expiring.
      scenario('a pick being checked says so; a refusal stays until '
          'dismissed', (tester) async {
        await pump(tester);
        backup
          ..refuse = BackupProblem.notABackup
          ..pickGate = Completer<void>();
        await tester.tap(find.byKey(const Key('backup.restore')));
        await tester.pump();
        expect(find.byKey(const Key('backup.checking')), findsOneWidget);
        backup.pickGate!.complete();
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('backup.checking')), findsNothing);
        expect(find.textContaining('not a Culmina backup'), findsOneWidget);
        await tester.pump(const Duration(seconds: 30));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('not a Culmina backup'),
          findsOneWidget,
          reason: 'no expiry: an outcome to read',
        );
        await tester.tap(find.byKey(const Key('appMessage.dismiss')));
        await tester.pumpAndSettle();
        expect(find.textContaining('not a Culmina backup'), findsNothing);
      });

      Future<void> snap(WidgetTester tester, String state) =>
          capturePhase2State(
            tester,
            package: 'package4',
            state: state,
            theme: theme,
          );

      for (final state in [
        'idle',
        'share-pending',
        'share-cancelled',
        'share-failed',
        'pick-pending',
        'pick-cancelled',
        'restore-failed',
      ]) {
        scenario('phone branch $state', (tester) async {
          await pump(tester, compact: true);
          if (state == 'idle') {
            expect(find.byKey(const Key('backup.backUp')), findsOneWidget);
            await snap(tester, 'backup-idle');
            return;
          }
          if (state.startsWith('share')) {
            if (state == 'share-pending') backup.backupGate = Completer<void>();
            backup.dismissShare = state == 'share-cancelled';
            backup.failBackup = state == 'share-failed';
            await tester.tap(find.byKey(const Key('backup.backUp')));
            if (backup.backupGate != null) {
              await tester.pump(const Duration(milliseconds: 200));
              expect(vm.vms.backup!.busy, isTrue);
              await snap(tester, 'backup-share-pending');
              backup.backupGate!.complete();
            }
            await tester.pumpAndSettle();
            expect(vm.vms.backup!.busy, isFalse);
            if (backup.dismissShare) {
              expect(find.text(notShared), findsOneWidget);
            }
            if (backup.failBackup) {
              expect(find.textContaining("Couldn't back up"), findsOneWidget);
            }
            if (!backup.dismissShare && !backup.failBackup) {
              expect(find.text('Backup file created'), findsOneWidget);
            }
            await snap(tester, 'backup-$state-result');
            return;
          }
          backup.cancelPick = state == 'pick-cancelled';
          backup.failRestore = state == 'restore-failed';
          if (state == 'pick-pending') backup.pickGate = Completer<void>();
          await tester.tap(find.byKey(const Key('backup.restore')));
          if (backup.pickGate != null) {
            await tester.pump(const Duration(milliseconds: 200));
            expect(find.byKey(const Key('backup.checking')), findsOneWidget);
            await snap(tester, 'backup-pick-pending');
            backup.pickGate!.complete();
          }
          await tester.pumpAndSettle();
          if (backup.cancelPick) {
            expect(find.byKey(const Key('restore.message')), findsNothing);
            expect(backup.restored, isNull);
            await snap(tester, 'backup-pick-cancelled');
          } else {
            expect(find.byKey(const Key('restore.message')), findsOneWidget);
            await snap(tester, 'backup-preview-confirmation');
            if (backup.failRestore) {
              await tester.tap(find.byKey(const Key('confirm.action')));
              await tester.pumpAndSettle();
              expect(find.textContaining('unchanged'), findsOneWidget);
              await snap(tester, 'backup-restore-failed');
            } else {
              await tester.tap(find.byKey(const Key('confirm.cancel')));
              await tester.pumpAndSettle();
              expect(backup.restored, isNull);
              await snap(tester, 'backup-preview-cancelled');
            }
          }
        });
      }

      for (final problem in BackupProblem.values) {
        scenario('phone refusal ${problem.name}', (tester) async {
          await pump(tester, compact: true);
          backup.refuse = problem;
          await tester.tap(find.byKey(const Key('backup.restore')));
          await tester.pumpAndSettle();
          expect(
            find.textContaining('Your current data is unchanged'),
            findsOneWidget,
          );
          expect(backup.restored, isNull);
          final reason = switch (problem) {
            BackupProblem.notABackup => 'not a Culmina backup',
            BackupProblem.newerSchema => 'newer version',
            BackupProblem.tooOld => 'too old',
            BackupProblem.unusable => 'damaged or incomplete',
            BackupProblem.notApplied => 'could not replace',
          };
          expect(find.textContaining(reason), findsOneWidget);
          await snap(tester, 'backup-refused-${problem.name}');
          await tester.tap(find.byKey(const Key('appMessage.dismiss')));
          await tester.pumpAndSettle();
          expect(
            find.textContaining('Your current data is unchanged'),
            findsNothing,
          );
        });
      }

      for (final action in ['pick', 'share']) {
        scenario(
          'phone $action pending blocks reentry and Back prevents late UI',
          (tester) async {
            await pump(tester, compact: true, pushed: true);
            final key = action == 'pick' ? 'backup.restore' : 'backup.backUp';
            final staleAction = tester
                .widget<SettingsAction>(find.byKey(Key(key)))
                .onPressed!;
            final held = Completer<void>();
            if (action == 'pick') {
              backup.pickGate = held;
            } else {
              backup.backupGate = held;
            }
            await tester.tap(find.byKey(Key(key)));
            await tester.pump(const Duration(milliseconds: 200));
            expect(vm.vms.backup!.busy, isTrue);
            expect(
              tester
                  .widget<SettingsAction>(
                    find.byKey(const Key('backup.backUp')),
                  )
                  .onPressed,
              isNull,
            );
            expect(
              tester
                  .widget<SettingsAction>(
                    find.byKey(const Key('backup.restore')),
                  )
                  .onPressed,
              isNull,
            );
            staleAction();
            await tester.pump();
            expect(action == 'pick' ? backup.picks : backup.shareCalls, 1);
            await snap(tester, 'backup-$action-pending-single-request');
            await tester.binding.handlePopRoute();
            await tester.pumpAndSettle();
            expect(find.text('Return destination'), findsOneWidget);
            held.complete();
            await tester.pumpAndSettle();
            expect(vm.vms.backup!.busy, isFalse);
            expect(find.byKey(const Key('restore.message')), findsNothing);
            expect(find.text('Backup file created'), findsNothing);
            expect(find.byType(MaterialBanner), findsNothing);
            expect(backup.restored, isNull);
            await snap(
              tester,
              'backup-$action-completed-after-back-no-late-ui',
            );
          },
        );
      }

      scenario('phone generic pick I/O failure preserves current data', (
        tester,
      ) async {
        await pump(tester, compact: true);
        backup.failPickIo = true;
        await tester.tap(find.byKey(const Key('backup.restore')));
        await tester.pumpAndSettle();
        expect(find.textContaining('open the backup'), findsOneWidget);
        expect(find.byKey(const Key('restore.message')), findsNothing);
        expect(backup.restored, isNull);
        await snap(tester, 'backup-pick-io-error');
      });

      for (final dismiss in ['Back', 'barrier']) {
        scenario('phone restore preview $dismiss cancels without writes', (
          tester,
        ) async {
          await pump(tester, compact: true);
          await openConfirmation(tester);
          expect(find.byKey(const Key('restore.message')), findsOneWidget);
          if (dismiss == 'Back') {
            await tester.binding.handlePopRoute();
          } else {
            await tester.tapAt(const Offset(5, 5));
          }
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('restore.message')), findsNothing);
          expect(backup.restored, isNull);
          expect(backup.backups, 0);
          await snap(
            tester,
            'backup-preview-${dismiss.toLowerCase()}-cancelled',
          );
        });
      }

      scenario(
        'phone refused outcome without a reason is explicit Unknown fallback',
        (tester) async {
          await pump(tester, compact: true);
          backup.stored = const RestoreOutcome(RestoreResult.refused);
          await vm.vms.backup!.load();
          await tester.pumpAndSettle();
          expect(find.textContaining('damaged or incomplete'), findsOneWidget);
          expect(
            find.textContaining('Your current data is unchanged'),
            findsOneWidget,
          );
          expect(backup.restored, isNull);
          await snap(tester, 'backup-refused-outcome-without-reason');
        },
      );

      for (final result in RestoreResult.values) {
        scenario('phone outcome ${result.name} is shown once', (tester) async {
          await pump(tester, compact: true);
          backup.stored = RestoreOutcome(
            result,
            problem: result == RestoreResult.refused
                ? BackupProblem.unusable
                : null,
          );
          await vm.vms.backup!.load();
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('restore.outcome')), findsOneWidget);
          await snap(tester, 'backup-outcome-${result.name}');
          await tester.tap(find.byKey(const Key('appMessage.dismiss')));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('restore.outcome')), findsNothing);
          expect(backup.cleared, 1);
        });
      }

      scenario('phone restoring cover blocks navigation', (tester) async {
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          phase2Frame(
            theme: theme,
            applyFieldFilter: false,
            child: RestoringBackupApp(
              theme: phase2Theme(theme),
              darkTheme: phase2Theme(theme),
              isFieldMode: theme == 'field',
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.byKey(const Key('restore.restoring')), findsOneWidget);
        final guard = tester.widget<PopScope>(find.byType(PopScope));
        expect(guard.canPop, isFalse);
        await snap(tester, 'backup-restoring-cover');
      });

      for (final (problem, reason) in [
        (BackupProblem.newerSchema, 'newer version of Culmina'),
        (BackupProblem.unusable, 'damaged or incomplete'),
        (BackupProblem.notABackup, 'not a Culmina backup'),
      ]) {
        scenario('a refused file (${problem.name}) is explained at pick time', (
          tester,
        ) async {
          await pump(tester);
          backup.refuse = problem;
          await tester.tap(find.byKey(const Key('backup.restore')));
          await tester.pumpAndSettle();
          expect(find.textContaining('The backup was not applied'), findsOne);
          expect(find.textContaining(reason), findsOneWidget);
          expect(
            find.textContaining('Your current data is unchanged'),
            findsOne,
          );
          expect(find.text('Restore this backup?'), findsNothing);
          expect(backup.restored, isNull);
        });
      }
    });
  }
}
