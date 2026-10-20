import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../domain/services/target_progress.dart';
import '../../shared/app_words.dart';
import '../../shared/night_time_formatter.dart';
import '../../shared/opportunity_text.dart';
import '../../viewmodels/library_viewmodels.dart';
import '../../shared/failure_feedback.dart';

/// Progress by target (TASK 14.2, CALC-38; in the Logbook since S8.5, RD-07):
/// integration so far across nights, from logged results only (completed
/// entries: their light frames × exposure), per filter, the last night and
/// the number of entries. One progress concept: no goals, no Project.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late final Future<List<TargetProgress>> _progress = context
      .read<SessionsViewModel>()
      .targetProgress();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: hybridAppBar(
        context,
        title: const Text(AppWords.progressByTarget),
      ),
      body: FutureBuilder<List<TargetProgress>>(
        future: _progress,
        builder: (context, snapshot) {
          final list = snapshot.data;
          if (snapshot.error case final error?) {
            return LoadFailureView(action: 'load the progress', error: error);
          }
          if (list == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'No results yet. Integration adds up here once you record '
                  'how a saved plan went.',
                  key: Key('progress.empty'),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [for (final p in list) TargetProgressCard(progress: p)],
          );
        },
      ),
    );
  }
}

/// One target's progress; also shown on a session's detail.
class TargetProgressCard extends StatelessWidget {
  const TargetProgressCard({super.key, required this.progress});

  final TargetProgress progress;

  @override
  Widget build(BuildContext context) {
    final p = progress;
    final theme = Theme.of(context);
    final night = p.lastNight;
    return Container(
      key: Key('progress.${p.targetId}'),
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(p.label, style: theme.textTheme.titleMedium),
            Text(
              '${OpportunityText.duration(p.integration)} from '
              '${p.sessionCount} ${p.sessionCount == 1 ? 'result' : 'results'}',
              key: Key('progress.total.${p.targetId}'),
              style: theme.textTheme.titleSmall,
            ),
            if (night != null)
              Text('Last imaged: ${NightTimeFormatter.eveningDate(night)}'),
            for (final MapEntry(:key, :value) in p.perFilter.entries)
              Text('$key: ${OpportunityText.duration(value)}'),
          ],
        ),
      ),
    );
  }
}
