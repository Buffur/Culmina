import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../domain/services/astrobin_acquisitions.dart';
import '../../shared/failure_feedback.dart';
import '../../viewmodels/astrobin_export_viewmodel.dart';
import 'logbook_screen.dart' show entryTitle;

/// The label of the AstroBin export (F20) in the Logbook's menu and on an
/// entry.
const exportForAstroBin = 'Export for AstroBin (CSV)';

/// F20 A3: prepares the AstroBin acquisition CSV of entry [id] (the whole
/// Logbook when null), shows its rows in the file's order with their
/// filter names and the entries that give none, then shares exactly that
/// on Share CSV. Cancel, back or a tap outside share nothing.
Future<void> exportForAstroBinFlow(BuildContext context, {int? id}) async {
  final vm = context.read<AstroBinExportViewModel?>();
  if (vm == null) return;
  AstroBinExport? prepared;
  final ok = await runWithFeedback(
    context,
    'prepare the AstroBin CSV',
    () async => prepared = await vm.prepare(id: id),
  );
  if (!ok || prepared == null || !context.mounted) return;
  final a = prepared!;
  final share = await showDialog<bool>(
    context: context,
    builder: (context) => _Preview(export: a),
  );
  if (share != true || !context.mounted) return;
  final done = await runWithFeedback(
    context,
    'share the AstroBin CSV',
    () => vm.share(a),
  );
  if (done && context.mounted) showDone(context, 'AstroBin CSV created');
}

/// Why an entry gives no row, in words.
String astroBinSkipReason(AstroBinSkip why) => switch (why) {
  AstroBinSkip.noResult => 'no result recorded',
  AstroBinSkip.notRecorded => 'result not recorded',
  AstroBinSkip.notDone => 'not done: nothing recorded as acquired',
  AstroBinSkip.oldLog => 'old log: no per-block record',
  AstroBinSkip.noLightFrames => 'no light frames recorded',
};

class _Preview extends StatelessWidget {
  const _Preview({required this.export});

  final AstroBinExport export;

  @override
  Widget build(BuildContext context) {
    final a = export;
    final theme = Theme.of(context);
    return AlertDialog(
      key: const Key('astrobin.preview'),
      title: const Text('Export for AstroBin'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "A CSV of your recorded frames for AstroBin's Import CSV. "
              'Its filter column is left empty: AstroBin takes its own '
              "equipment ID there, so choose each row's filter on AstroBin.",
            ),
            const SizedBox(height: AppSpacing.md),
            if (a.rows.isEmpty)
              const Text(
                'Nothing to export: no entry has recorded frames.',
                key: Key('astrobin.empty'),
              )
            else ...[
              Text(
                "Rows, in the file's order",
                style: theme.textTheme.titleSmall,
              ),
              for (final (i, line) in a.rowLines.indexed)
                Text(line, key: Key('astrobin.row.$i')),
            ],
            if (a.skipped.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text('Not included', style: theme.textTheme.titleSmall),
              for (final (s, why) in a.skipped)
                Text(
                  '${entryTitle(s)}: ${astroBinSkipReason(why)}',
                  key: Key('astrobin.skipped.${s.id}'),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('astrobin.cancel'),
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('astrobin.share'),
          onPressed: a.rows.isEmpty ? null : () => Navigator.pop(context, true),
          child: const Text('Share CSV'),
        ),
      ],
    );
  }
}
