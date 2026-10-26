import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/diagnostics/app_log.dart';
import '../../domain/repositories/undoable_deletion.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import 'app_messages.dart';
import 'hybrid_quiet_ink.dart';
import 'failure_feedback.dart';

// Deleting (S5.8; RD-09 = M + S1, DECISIONS E.1):
// - an edit inside a plan (a capture block) happens at once, with an Undo
//   message: [showUndo];
// - a stored record (a rig, a target, a site, a Logbook entry) is deleted
//   only after the shared confirmation (`confirmDestructive`);
//   production repositories then offer a scoped, transactional Undo;
// - every deletable item has a visible Delete ([DeleteButton]); a swipe
//   ([SwipeToDelete]) is a shortcut to the same handler.

/// Shows "[message] · Undo" after an edit was applied, and reports exactly
/// one outcome: [onUndo] when the user taps Undo, otherwise [onCommit] once
/// the message closes (it timed out, was swiped away or replaced by
/// another). The edit is applied before the message shows; [onUndo]
/// restores it. Returns whether it was undone.
Future<bool> showUndo(
  BuildContext context, {
  required String message,
  required VoidCallback onUndo,
  VoidCallback? onCommit,
  Duration duration = const Duration(seconds: 6),
}) async {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentMessage();
  final reason = await messenger
      .showMessage(
        SnackBar(
          content: Text(message),
          duration: duration,
          // A message with an action stays until dismissed unless told
          // otherwise (Flutter's `persist`); Undo must time out and commit.
          persist: false,
          action: SnackBarAction(label: 'Undo', onPressed: () {}),
        ),
      )
      .closed;
  final undone = reason == SnackBarClosedReason.action;
  if (undone) {
    onUndo();
  } else {
    onCommit?.call();
  }
  return undone;
}

/// Deletes a stored graph and offers its one in-memory Undo. The messenger is
/// captured before awaiting storage so the action survives an editor/detail
/// route being popped. Failed restoration remains retryable and never reports
/// success. A store without the optional capability gets no misleading Undo.
/// Stored Undo stays until Dismiss or replacement, matching Hybrid's workspace
/// affordance. The older capture-block Undo above retains its timed contract.
Future<bool> deleteWithUndoFeedback(
  BuildContext context, {
  required String action,
  required String message,
  required Future<DeletionReceipt?> Function() remove,
  Future<void> Function()? afterDelete,
  Future<void> Function()? afterRestore,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final DeletionReceipt? receipt;
  try {
    receipt = await remove();
  } catch (error, stack) {
    AppLog.error('ui', 'Could not $action', error: error, stackTrace: stack);
    if (messenger.mounted) {
      messenger.showMessage(
        SnackBar(content: Text(FailureText.message(action, error))),
      );
    }
    return false;
  }
  var feedback = message;
  try {
    await afterDelete?.call();
  } catch (error, stack) {
    // The delete committed already. A refresh failure must not discard its
    // receipt or tell the user the record is still present.
    AppLog.error(
      'ui',
      'Could not refresh after deletion',
      error: error,
      stackTrace: stack,
    );
    feedback = '$message. The list could not be refreshed.';
  }
  if (!messenger.mounted) return true;
  if (receipt == null) {
    messenger.showMessage(SnackBar(content: Text(feedback)));
    return true;
  }
  Future<void> restore() async {
    try {
      await receipt!.restore();
      await afterRestore?.call();
      if (messenger.mounted) {
        messenger.showMessage(const SnackBar(content: Text('Deletion undone')));
      }
    } catch (error, stack) {
      AppLog.error(
        'ui',
        'Could not undo deletion',
        error: error,
        stackTrace: stack,
      );
      if (!messenger.mounted) return;
      messenger.showMessage(
        SnackBar(
          content: Text(FailureText.message('undo the deletion', error)),
          persist: true,
          action: SnackBarAction(
            label: 'Retry Undo',
            onPressed: () => unawaited(restore()),
          ),
        ),
      );
    }
  }

  unawaited(
    messenger
        .showMessage(
          SnackBar(
            content: Text(feedback),
            persist: true,
            action: SnackBarAction(label: 'Undo', onPressed: () {}),
          ),
          actionStyle: HybridQuietInk.buttonStyle(messenger.context),
        )
        .closed
        .then((reason) async {
          if (reason == SnackBarClosedReason.action) await restore();
        }),
  );
  return true;
}

/// The visible Delete (S1; UX-38): an icon button with its label as the
/// tooltip, e.g. "Delete rig". Where it sits (a row's menu, the item's
/// editor, the row itself) is decided where it is adopted.
class DeleteButton extends StatelessWidget {
  const DeleteButton({
    super.key,
    required this.tooltip,
    required this.onPressed,
  });

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    icon: const Icon(Icons.delete_outline),
  );
}

/// A swipe from the end is a shortcut to [onDelete], the same handler as
/// the row's visible Delete (S1). The row never stays slid away behind a
/// dialog (08 §20): it springs back at once, and [onDelete] then confirms
/// (a stored record) or deletes with Undo (an edit inside a plan); the list
/// drops the row when the item is really gone.
class SwipeToDelete extends StatelessWidget {
  const SwipeToDelete({
    super.key,
    required this.itemKey,
    required this.onDelete,
    required this.child,
  });

  /// Unique within the list, e.g. `ValueKey('rig_3')`.
  final Key itemKey;
  final VoidCallback onDelete;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: itemKey,
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: scheme.error,
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        child: Icon(Icons.delete_outline, color: scheme.onError),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false; // spring back; the list removes the row when deleted
      },
      child: child,
    );
  }
}
