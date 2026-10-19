import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_button_styles.dart';
import '../../../domain/services/backup_service.dart';
import '../../shared/app_messages.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/night_time_formatter.dart';
import '../../viewmodels/backup_viewmodel.dart';
import '../../../core/config/app_identity.dart';

/// What the restore confirmation lets the user do (F01 A4, D2/D7, UX-S R1).
enum _RestoreChoice { cancel, backUpFirst, restore }

/// Backup and restore (TASK 14.4; F01, owner decisions D2/D7): a backup is
/// one `.astroplan` file shared wherever the user wants it. A restore is
/// checked completely when the file is picked, confirmed, and applied at
/// once: the app restarts, checks it again and replaces its data; the next
/// app instance says what happened ([RestoreOutcomeNotice]). Every action
/// reports a failure (trap 18).
/// F01 A4: the share sheet was closed without sharing, so no backup file
/// was kept anywhere.
const notShared =
    'No backup was saved: the share sheet was closed. Back up again and '
    'choose where to keep the file.';

class BackupSection extends StatelessWidget {
  const BackupSection({super.key});

  /// Why a backup was not applied, as the end of "The backup was not
  /// applied: …".
  static String problemText(BackupProblem p) => switch (p) {
    BackupProblem.notABackup =>
      'this file is not a ${AppIdentity.appName} backup, or it is damaged',
    BackupProblem.newerSchema =>
      'it was made by a newer version of ${AppIdentity.appName}. Update '
          'the app first',
    BackupProblem.tooOld =>
      'it is too old for this version of ${AppIdentity.appName}',
    BackupProblem.unusable => 'the data in it is damaged or incomplete',
    BackupProblem.notApplied =>
      'its files could not replace the ones on this device',
  };

  /// A refusal before anything changed (SP09).
  static String refusedText(BackupProblem p) =>
      'The backup was not applied: ${problemText(p)}. Your current data is '
      'unchanged.';

  /// What the app instance after a restore says, once (F01 A5).
  static String outcomeText(RestoreOutcome o) => switch (o.result) {
    RestoreResult.applied =>
      'Backup restored. Your data now comes from the backup.',
    RestoreResult.refused => refusedText(o.problem ?? BackupProblem.unusable),
    RestoreResult.completedAfterInterruption =>
      'The restore was interrupted, and has now been completed. Your data '
          'now comes from the backup.',
  };

  static String _plans(int n) => n == 1 ? '1 plan' : '$n plans';

  Future<_RestoreChoice> _confirm(BuildContext context, BackupPreview p) async {
    final choice = await showDialog<_RestoreChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore this backup?'),
        content: SingleChildScrollView(
          child: Text(
            // TD-105: the backup names its version, not this app's name.
            'Made ${NightTimeFormatter.deviceDateTime(context, p.createdAtUtc)} '
            'by version ${p.appVersion}, with ${_plans(p.sessionCount)}.\n\n'
            'All plans, results, sites, rigs, targets and settings on this '
            'device are replaced by the backup. ${AppIdentity.appName} '
            'restarts to do it, and this cannot be undone in the app.\n\n'
            'To keep your current data, back up first.',
            key: const Key('restore.message'),
          ),
        ),
        actions: [
          TextButton(
            key: const Key('confirm.cancel'),
            onPressed: () => Navigator.pop(context, _RestoreChoice.cancel),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('restore.backUpFirst'),
            onPressed: () => Navigator.pop(context, _RestoreChoice.backUpFirst),
            child: const Text('Back up first'),
          ),
          TextButton(
            key: const Key('confirm.action'),
            style: AppButtonStyles.destructiveText(
              Theme.of(context).colorScheme,
            ),
            onPressed: () => Navigator.pop(context, _RestoreChoice.restore),
            child: const Text('Restore and restart'),
          ),
        ],
      ),
    );
    return choice ?? _RestoreChoice.cancel;
  }

  Future<void> _restore(BuildContext context, BackupViewModel vm) async {
    final ({BackupPreview preview, Object file})? picked;
    try {
      picked = await vm.pick();
    } on BackupException catch (e) {
      if (context.mounted) showFailure(context, refusedText(e.problem));
      return;
    } catch (e) {
      if (context.mounted) {
        showFailure(context, FailureText.message('open the backup', e));
      }
      return;
    }
    if (picked == null || !context.mounted) return;
    var choice = await _confirm(context, picked.preview);
    while (choice == _RestoreChoice.backUpFirst) {
      if (!context.mounted) return;
      // UX-S R1: the existing backup; only its success returns to this same
      // confirmation. A failure or a cancelled backup never restores.
      var shared = false;
      final done = await runWithFeedback(
        context,
        'back up',
        () async => shared = await vm.backUp(),
      );
      if (!done || !context.mounted) return;
      // F01 A4: a share sheet closed without sharing kept no backup.
      if (!shared) return showFailure(context, notShared);
      showDone(context, 'Backup file created');
      choice = await _confirm(context, picked.preview);
    }
    if (choice != _RestoreChoice.restore || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await vm.restoreAndRestart(picked.file);
    } catch (_) {
      messenger.showMessage(
        SnackBar(content: Text(refusedText(BackupProblem.notApplied))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BackupViewModel?>();
    if (vm == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          key: const Key('backup.backUp'),
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.backup_outlined),
          title: const Text('Back up now'),
          subtitle: const Text(
            'One .astroplan file with all your data. Save it anywhere.',
          ),
          enabled: !vm.busy,
          onTap: () async {
            var shared = false;
            final done = await runWithFeedback(
              context,
              'back up',
              () async => shared = await vm.backUp(),
            );
            if (!done || !context.mounted) return;
            shared
                ? showDone(context, 'Backup file created')
                : showFailure(context, notShared);
          },
        ),
        ListTile(
          key: const Key('backup.restore'),
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.settings_backup_restore),
          title: const Text('Restore from a backup'),
          subtitle: Text(
            'Checked first; ${AppIdentity.appName} then restarts to apply it.',
          ),
          enabled: !vm.busy,
          onTap: () => _restore(context, vm),
        ),
      ],
    );
  }
}

/// Reports the last restore's outcome once, on the first screen of the app
/// instance that starts after it (F01 A5, UXA-C1), then forgets it.
class RestoreOutcomeNotice extends StatefulWidget {
  const RestoreOutcomeNotice({super.key, required this.child});

  final Widget child;

  @override
  State<RestoreOutcomeNotice> createState() => _RestoreOutcomeNoticeState();
}

class _RestoreOutcomeNoticeState extends State<RestoreOutcomeNotice> {
  bool _shown = false;

  void _showOnce(BackupViewModel vm, RestoreOutcome outcome) {
    _shown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showMessage(
        SnackBar(
          key: const Key('restore.outcome'),
          content: Text(BackupSection.outcomeText(outcome)),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );
      vm.outcomeShown();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BackupViewModel?>();
    final outcome = vm?.outcome;
    if (!_shown && vm != null && outcome != null) _showOnce(vm, outcome);
    return widget.child;
  }
}

/// Shown instead of the app while a confirmed restore is applied (D7 A):
/// nothing can be edited until the app has restarted with the result.
class RestoringBackupApp extends StatelessWidget {
  const RestoringBackupApp({super.key, this.theme, this.darkTheme});

  final ThemeData? theme;
  final ThemeData? darkTheme;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: AppIdentity.appName,
    theme: theme,
    darkTheme: darkTheme,
    debugShowCheckedModeBanner: false,
    home: const PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'Restoring the backup…',
                    key: Key('restore.restoring'),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    '${AppIdentity.appName} restarts when it is done.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
