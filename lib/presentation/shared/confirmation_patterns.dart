import 'package:flutter/material.dart';

/// What the user chose when unsaved changes would be left behind.
enum UnsavedChoice { save, discard, cancel }

/// The three-way prompt (S5.8; ADR-019 §3, addendum §3.3): "[plan] has
/// changes that are not saved." with Cancel · Discard · Save. Dismissing
/// it (back, a tap outside) is Cancel, so nothing is lost by accident.
/// What Save and Discard then do belongs to the caller (P6.1); this is the
/// prompt only. Discard is styled as destructive.
Future<UnsavedChoice> askUnsavedChanges(
  BuildContext context, {
  required String plan,
  String message = '',
  String saveLabel = 'Save and leave',
}) async {
  // plan.html `#leave-plan`: Cancel and Discard outlined, the save filled.
  final choice = await showDialog<UnsavedChoice>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Unsaved changes'),
      content: Text(
        message.isEmpty ? '"$plan" has changes that are not saved.' : message,
      ),
      actions: [
        OutlinedButton(
          key: const Key('unsaved.cancel'),
          onPressed: () => Navigator.pop(context, UnsavedChoice.cancel),
          child: const Text('Cancel'),
        ),
        OutlinedButton(
          key: const Key('unsaved.discard'),
          onPressed: () => Navigator.pop(context, UnsavedChoice.discard),
          child: const Text('Discard'),
        ),
        FilledButton(
          key: const Key('unsaved.save'),
          onPressed: () => Navigator.pop(context, UnsavedChoice.save),
          child: Text(saveLabel),
        ),
      ],
    ),
  );
  return choice ?? UnsavedChoice.cancel;
}

/// "Discard this edit?" (plan.html `#discard-edit`): an editor's unapplied
/// fields; the draft keeps what was already applied. True only for
/// Discard edit; Keep editing, Back and a tap outside keep the editor.
Future<bool> askDiscardEdit(BuildContext context) async {
  final discard = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Discard this edit?'),
      content: const Text(
        'Unapplied fields in this editor will be discarded. Changes you '
        'already applied to the draft remain.',
      ),
      actions: [
        OutlinedButton(
          key: const Key('discardEdit.keep'),
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Keep editing'),
        ),
        FilledButton(
          key: const Key('discardEdit.discard'),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Discard edit'),
        ),
      ],
    ),
  );
  return discard ?? false;
}

/// The one confirmation for a destructive action on something stored
/// (S5.8; RD-09 = M): deleting a rig, a target, a site or a Logbook entry,
/// Abandon, Restore. [title] names the item ("Delete rig "Refractor
/// 400"?"), [message] says the consequence ("Plans that use it keep their
/// saved values."), [action] is the verb on the destructive button
/// ("Delete"). True only when the user taps [action]: Cancel, back and a
/// tap outside all keep the item. Edits inside a plan use the undo message
/// instead (`showUndo`).
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String message,
  String action = 'Delete',
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        OutlinedButton(
          key: const Key('confirm.cancel'),
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('confirm.action'),
          onPressed: () => Navigator.pop(context, true),
          child: Text(action),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
