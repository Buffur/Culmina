import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/hybrid_tokens.dart';

/// What the user chose when unsaved changes would be left behind.
enum UnsavedChoice { save, discard, cancel }

/// The three-way prompt (S5.8; ADR-019 §3, addendum §3.3): "[plan] has
/// changes that are not saved." with Cancel · Discard · Save. Dismissing
/// it (back, a tap outside) is Cancel, so nothing is lost by accident.
/// What Save and Discard then do belongs to the caller (P6.1); this is the
/// prompt only. Discard is styled as destructive.
///
/// [library]: a Library editor's prompt (library.js `cancelEdit`): "Your
/// changes to “[plan]” are not saved.", Cancel and Discard side by side,
/// then Save the full width.
Future<UnsavedChoice> askUnsavedChanges(
  BuildContext context, {
  required String plan,
  String message = '',
  String saveLabel = 'Save and leave',
  bool library = false,
}) async {
  Widget cancel(BuildContext context) => OutlinedButton(
    key: const Key('unsaved.cancel'),
    onPressed: () => Navigator.pop(context, UnsavedChoice.cancel),
    child: const Text('Cancel'),
  );
  Widget discard(BuildContext context) => OutlinedButton(
    key: const Key('unsaved.discard'),
    onPressed: () => Navigator.pop(context, UnsavedChoice.discard),
    child: const Text('Discard'),
  );
  Widget save(BuildContext context, String label) => FilledButton(
    key: const Key('unsaved.save'),
    onPressed: () => Navigator.pop(context, UnsavedChoice.save),
    child: Text(label),
  );
  final choice = await showDialog<UnsavedChoice>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Unsaved changes'),
      content: Text(
        message.isNotEmpty
            ? message
            : library
            ? 'Your changes to “$plan” are not saved.'
            : '"$plan" has changes that are not saved.',
      ),
      // plan.html `#leave-plan`: Cancel and Discard outlined, the save
      // filled, in one row that wraps from the end, 8 apart
      // (`.leave-actions`): at a phone's width the save goes below (QA-05;
      // the dialog's own overflow bar stacked all three).
      actions: library
          ? [
              _WideActions(
                children: [
                  Row(
                    spacing: AppSpacing.sm,
                    children: [
                      Expanded(child: cancel(context)),
                      Expanded(child: discard(context)),
                    ],
                  ),
                  save(context, 'Save'),
                ],
              ),
            ]
          : [
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    cancel(context),
                    discard(context),
                    save(context, saveLabel),
                  ],
                ),
              ),
            ],
    ),
  );
  return choice ?? UnsavedChoice.cancel;
}

/// A dialog's actions the full width of the dialog, stacked 8 apart
/// (hybrid-refinement.css `.workspace-actions` in a dialog).
class _WideActions extends StatelessWidget {
  const _WideActions({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.sm,
      children: children,
    ),
  );
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
      // library.js / logbook.js `choiceDialog`: Cancel and the destructive
      // action side by side, the action outlined in the error colour.
      actions: [
        _WideActions(
          children: [
            Row(
              spacing: AppSpacing.sm,
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('confirm.cancel'),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ),
                Expanded(
                  child: OutlinedButton(
                    key: const Key('confirm.action'),
                    onPressed: () => Navigator.pop(context, true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          (Theme.of(context).extension<HybridTokens>() ??
                                  HybridTokens.light)
                              .errorText,
                    ),
                    child: Text(action),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
