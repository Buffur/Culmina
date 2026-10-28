import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';
import 'package:flutter/material.dart';

import '../../shared/document_section.dart';

import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/utils/quantity_text.dart';
import '../../shared/entry_text.dart';
import '../../shared/collapsible_section.dart';
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
  late Future<List<TargetProgress>> _progress = context
      .read<SessionsViewModel>()
      .targetProgress();

  void _retry() => setState(() {
    _progress = context.read<SessionsViewModel>().targetProgress();
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final copy = AppTextTheme.of(context)
        .resolve(AppTextTheme.of(context).body, AppTextGeometry.reading)
        .copyWith(color: p.textSecondary);
    return Scaffold(
      appBar: hybridAppBar(
        context,
        title: const Text(AppWords.progressByTarget),
      ),
      body: FutureBuilder<List<TargetProgress>>(
        future: _progress,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data;
          if (snapshot.error case final error?) {
            return LoadFailureView(
              action: 'load the progress',
              error: error,
              onRetry: _retry,
            );
          }
          if (list == null) {
            return const Center(child: CircularProgressIndicator());
          }
          // logbook.js `progressView`.
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.itemGap,
              AppSpacing.gutter,
              AppSpacing.xl,
            ),
            children: [
              Text('Recorded integration by target and filter.', style: copy),
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Text(
                    'No results yet. Integration adds up here once you '
                    'record how a saved plan went.',
                    key: const Key('progress.empty'),
                    style: copy,
                  ),
                )
              else ...[
                for (final (i, t) in list.indexed)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: DocumentSection(
                      children: [
                        TargetProgressCard(
                          progress: t,
                          first: i == 0,
                          embedded: true,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                DocumentSection(
                  key: const Key('progress.guideGroup'),
                  children: [
                    Padding(
                      padding: EdgeInsets.zero,
                      child: CollapsibleSection(
                        key: const Key('progress.guide'),
                        readableFeedback: true,
                        topRule: false,
                        sectionKey: 'logbook.progressGuide',
                        title: 'How totals are grouped',
                        titleStyle: AppTextTheme.of(context).body.copyWith(
                          fontWeight: FontWeight.w500,
                          color: p.textPrimary,
                        ),
                        child: Text(
                          'Totals per filter add every recorded frame. Beneath '
                          'each filter, frames are grouped only when exposure, '
                          'ISO or gain, binning and rig all match; "reported as '
                          'planned" counts are your report, not counted files. '
                          'This is integration time, not a measure of signal or '
                          'image quality.',
                          style: copy,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// One target's progress (logbook.js `targetProgressView`); also on an
/// entry's detail: the name and its total, the results and the last night,
/// then each filter's total and the groups beneath it.
class TargetProgressCard extends StatelessWidget {
  const TargetProgressCard({
    super.key,
    required this.progress,
    this.first = true,
    this.embedded = false,
  });

  final TargetProgress progress;

  /// A later target starts below a rule.
  final bool first;

  /// Parent owns the group surface and inter-section spacing.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final t = progress;
    final p = AppPalette.of(context);
    final night = t.lastNight;
    final caption = AppTextTheme.of(context)
        .resolve(AppTextTheme.of(context).caption, AppTextGeometry.supporting)
        .copyWith(color: p.textSecondary);
    final rule = BorderSide(color: p.border);
    Widget heading(String name, String total, TextStyle style, Key? key) =>
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          children: [
            Semantics(header: true, child: Text(name, style: style)),
            Text(
              total,
              key: key,
              style: style.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        );
    return Container(
      key: Key('progress.${t.targetId}'),
      margin: embedded
          ? EdgeInsets.zero
          : EdgeInsets.only(top: first ? AppSpacing.md : AppSpacing.section),
      padding: EdgeInsets.only(top: embedded || first ? 0 : AppSpacing.md),
      decoration: BoxDecoration(
        border: embedded || first ? null : Border(top: rule),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          heading(
            t.label,
            OpportunityText.duration(t.integration),
            AppTextTheme.of(context).itemTitle.copyWith(color: p.textPrimary),
            Key('progress.total.${t.targetId}'),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${EntryText.plural(t.sessionCount, 'result')}'
            '${night == null ? '' : ' · Last imaged ${NightTimeFormatter.eveningDateWithWeekday(night)}'}',
            key: Key('progress.results.${t.targetId}'),
            style: caption,
          ),
          for (final MapEntry(key: filter, value: total)
              in t.perFilter.entries) ...[
            const SizedBox(height: AppSpacing.md),
            heading(
              filter,
              OpportunityText.duration(total),
              AppTextTheme.of(context).body
                  .copyWith(fontWeight: FontWeight.w600, color: p.textPrimary),
              null,
            ),
            for (final g in t.groups[filter] ?? const <ProgressGroup>[])
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.itemGap),
                padding: const EdgeInsets.only(top: AppSpacing.itemGap),
                decoration: BoxDecoration(border: Border(top: rule)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.xs,
                  children: [
                    Text(
                      [
                        QuantityText.exposure(g.exposureSeconds),
                        EntryText.sensitivity(g.sensitivity, g.cameraClass),
                        if (g.binning > 1) 'bin ${g.binning}×${g.binning}',
                        g.rig,
                      ].join(' · '),
                      style: AppTextTheme.of(context)
                          .resolve(
                            AppTextTheme.of(context).body,
                            AppTextGeometry.standard,
                          )
                          .copyWith(
                            fontWeight: FontWeight.w500,
                            color: p.textPrimary,
                          ),
                    ),
                    Text(
                      '${EntryText.plural(g.frames, 'frame')} · '
                      '${OpportunityText.duration(g.integration)} · '
                      '${EntryText.plural(g.nights.length, 'night')}',
                      style: AppTextTheme.of(context)
                          .resolve(
                            AppTextTheme.of(context).caption,
                            AppTextGeometry.standard,
                          )
                          .copyWith(
                            color: p.textPrimary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                    if (!g.known)
                      Text(
                        'Sensitivity not recorded: kept separate, never '
                        'combined with another group.',
                        style: caption,
                      ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
