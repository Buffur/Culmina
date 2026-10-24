// F01 A5 (UXA-C1, SP09): the app instance that starts after a restore says
// what actually happened, once, and forgets it; the restoring screen offers
// nothing to edit (D7 A).

import 'package:astroplan/domain/services/backup_service.dart';
import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/presentation/screens/settings/backup_section.dart';
import 'package:astroplan/presentation/viewmodels/backup_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _Stored implements BackupService {
  _Stored(this.stored);

  RestoreOutcome? stored;
  int cleared = 0;

  @override
  Future<RestoreOutcome?> outcome() async => stored;

  @override
  Future<void> clearOutcome() async {
    stored = null;
    cleared++;
  }

  @override
  Future<bool> backUpAndShare() => throw UnimplementedError();

  @override
  Future<({BackupPreview preview, Object file})?> pick() =>
      throw UnimplementedError();

  @override
  Future<void> restoreAndRestart(Object file) => throw UnimplementedError();
}

void main() {
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final field in [false, true]) {
      testWidgets('restore retains $mode with Field $field', (tester) async {
        await tester.pumpWidget(
          RestoringBackupApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: mode,
            isFieldMode: field,
          ),
        );
        final expected = field
            ? AppTheme.fieldTheme
            : mode == ThemeMode.light
            ? AppTheme.light
            : AppTheme.dark;
        final context = tester.element(
          find.byKey(const Key('restore.restoring')),
        );
        expect(Theme.of(context).colorScheme, expected.colorScheme);
        expect(
          find.byType(ColorFiltered),
          field ? findsOneWidget : findsNothing,
        );
        expect(find.byType(ButtonStyleButton), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }

  Future<_Stored> start(WidgetTester tester, RestoreOutcome? o) async {
    final service = _Stored(o);
    final vm = BackupViewModel(service);
    await tester.runAsync(vm.load);
    await tester.pumpWidget(
      ChangeNotifierProvider<BackupViewModel?>.value(
        value: vm,
        child: MaterialApp(
          builder: (context, child) => RestoreOutcomeNotice(child: child!),
          home: const Scaffold(body: Text('Home')),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    return service;
  }

  for (final (outcome, says, unchanged) in [
    (
      const RestoreOutcome(RestoreResult.applied),
      'Backup restored. Your data now comes from the backup.',
      false,
    ),
    (
      const RestoreOutcome(
        RestoreResult.refused,
        problem: BackupProblem.unusable,
      ),
      'The backup was not applied: the data in it is damaged or incomplete. '
          'Your current data is unchanged.',
      true,
    ),
    (
      const RestoreOutcome(RestoreResult.completedAfterInterruption),
      'The restore was interrupted, and has now been completed. Your data '
          'now comes from the backup.',
      false,
    ),
  ]) {
    testWidgets('${outcome.result.name}: reported once, then cleared', (
      tester,
    ) async {
      final service = await start(tester, outcome);
      expect(find.text(says), findsOneWidget);
      expect(
        find.textContaining('unchanged'),
        unchanged ? findsOneWidget : findsNothing,
        reason: 'never claim unchanged data after a new state committed',
      );
      await tester.runAsync(() async {});
      expect(service.cleared, 1);
      // Dismissed and rebuilt: not shown again.
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await start(tester, service.stored);
      expect(find.text(says), findsNothing);
    });
  }

  testWidgets('no outcome: nothing is shown', (tester) async {
    final service = await start(tester, null);
    expect(find.byKey(const Key('restore.outcome')), findsNothing);
    expect(service.cleared, 0);
  });

  testWidgets('the restoring screen offers nothing to edit and cannot be '
      'left with Back', (tester) async {
    await tester.pumpWidget(const RestoringBackupApp());
    expect(find.byKey(const Key('restore.restoring')), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(ButtonStyleButton), findsNothing);
    final pop = tester.widget<PopScope>(find.byType(PopScope));
    expect(pop.canPop, isFalse);
  });
}
