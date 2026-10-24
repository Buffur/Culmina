import 'package:flutter/material.dart';

import '../../shared/document_section.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/session_night.dart';
import '../../shared/hybrid_icon.dart';
import '../../shared/hybrid_parts.dart';
import '../../shared/plan_night_phrase.dart';
import '../../widgets/capture_plan/block_editor_parts.dart';
import 'home_context_sheets.dart';
import '../../../domain/services/candidate_evaluator.dart';
import '../../shared/capability_text.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/night_time_formatter.dart';
import '../../shared/opportunity_text.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/candidates_viewmodel.dart';
import '../../../core/utils/quantity_text.dart';

/// "What can I image tonight?" (TASK 10.4): every target evaluated for the
/// chosen night with the same rules as Home's opportunity card, sorted by a
/// column the user picks. Measured facts only — no score, no
/// recommendation. Hybrid (app.js `candidates` detail): the phone sheet with
/// the action as its title and chevron rows; the native list keeps its
/// sort, filters and measured captions (the reference's order is
/// illustrative).
class TonightCandidatesScreen extends StatefulWidget {
  const TonightCandidatesScreen({super.key});

  @override
  State<TonightCandidatesScreen> createState() =>
      _TonightCandidatesScreenState();
}

class _TonightCandidatesScreenState extends State<TonightCandidatesScreen> {
  Future<List<TonightCandidate>?>? _rows;

  /// The night [_rows] was evaluated for (S6.4; TD-057).
  SessionNight? _rowsNight;
  CandidateSort _sort = CandidateSort.usableTime;
  bool _withWindowOnly = true;
  bool _ownOnly = false;
  String? _type;

  /// The header names the order in use (RD-10 = O1, S6.14): the default
  /// breaks ties by frame fill; every order falls back to the name. The
  /// no-score rule stays in ADR-013, not in the header.
  static const _orderLabels = {
    CandidateSort.usableTime: 'usable time, then size in frame',
    CandidateSort.windowStart: 'window start',
    CandidateSort.maxAltitude: 'max altitude',
    CandidateSort.moonSeparation: 'Moon separation',
    CandidateSort.frameFill: 'size in frame',
    CandidateSort.name: 'name',
  };

  static const _sortLabels = {
    CandidateSort.usableTime: 'Usable time',
    CandidateSort.windowStart: 'Window start',
    CandidateSort.maxAltitude: 'Max altitude',
    CandidateSort.moonSeparation: 'Moon separation',
    CandidateSort.frameFill: 'Size in frame',
    CandidateSort.name: 'Name',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _rowsNight = context.read<SessionPlanViewModel>().sessionNight;
    _rows = context.read<CandidatesViewModel>().tonightCandidates();
  }

  @override
  Widget build(BuildContext context) {
    final planVm = context.watch<SessionPlanViewModel>();
    final settingsVm = context.watch<SettingsViewModel>();
    final siteVm = context.watch<SiteViewModel>();
    final night = planVm.sessionNight;
    final p = AppPalette.of(context);
    // A list left open across the rollover follows the new night (S6.4).
    if (night != null && night != _rowsNight) _load();
    // app.js `candidates` detail: the phone sheet, its title the action
    // that opened it (F17 A5: the plan's night).
    final title = PlanNightPhrase.candidatesAction(
      planVm.eveningDate ?? planVm.tonightKey,
      planVm.tonightKey,
    );
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeSheetHeader(
              actions: [
                IconButton(
                  tooltip: 'Refresh candidates',
                  onPressed: () => setState(_load),
                  icon: HybridIcon(
                    HybridIcons.refresh,
                    size: MediaQuery.textScalerOf(context).scale(20),
                    color: p.textPrimary,
                  ),
                ),
              ],
            ),
            Expanded(
              child: night == null
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.gutter,
                        AppSpacing.itemGap,
                        AppSpacing.gutter,
                        AppSpacing.xl,
                      ),
                      children: [
                        _Title(title),
                        Text(
                          "Set a site to see tonight's candidates: they are "
                          'worked out for a night at a site.',
                          key: const Key('tonight.noSite'),
                          style: _secondary(context),
                        ),
                      ],
                    )
                  : FutureBuilder<List<TonightCandidate>?>(
                      future: _rows,
                      builder: (context, snapshot) {
                        if (snapshot.error case final error?) {
                          return LoadFailureView(
                            action: "evaluate tonight's targets",
                            error: error,
                          );
                        }
                        final all = snapshot.data;
                        if (all == null) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return _buildList(
                          context,
                          title,
                          planVm,
                          siteVm,
                          settingsVm,
                          all,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static TextStyle _secondary(BuildContext context) => AppTypography.body
      .copyWith(height: 1.5, color: AppPalette.of(context).textSecondary);

  Widget _buildList(
    BuildContext context,
    String title,
    SessionPlanViewModel planVm,
    SiteViewModel siteVm,
    SettingsViewModel settingsVm,
    List<TonightCandidate> all,
  ) {
    final p = AppPalette.of(context);
    final night = planVm.sessionNight!;
    final zoneId = siteVm.displayZoneId;
    final types = {for (final r in all) r.target.type}.toList()..sort();
    final rows = CandidateList.sort(
      CandidateList.filter(
        all,
        withWindowOnly: _withWindowOnly,
        type: _type,
        ownOnly: _ownOnly,
      ),
      _sort,
    );
    String at(DateTime t) => NightTimeFormatter.instant(
      context,
      t,
      windowStartUtc: night.startUtc,
      zoneId: zoneId,
    );
    final prefs = settingsVm.planningPreferences;
    final select = AppTypography.body.copyWith(
      height: 1.5,
      color: p.textPrimary,
    );

    final header = <Widget>[
      DocumentSection(
        key: const Key('candidates.contextGroup'),
        children: [
          _Title(title),
          Text(
            'Night of ${NightTimeFormatter.eveningDate(night.eveningDate)}'
            '${siteVm.locationName == null ? '' : ' at ${siteVm.locationName}'} · '
            '${rows.length} of ${all.length} targets · sorted by '
            '${_orderLabels[_sort]!}',
            key: const Key('tonight.header'),
            style: _secondary(context),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      DocumentSection(
        key: const Key('candidates.filtersGroup'),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlockField(
                label: 'Sort by',
                child: DropdownButtonFormField<CandidateSort>(
                  key: const Key('tonight.sort'),
                  isExpanded: true,
                  initialValue: _sort,
                  style: select,
                  icon: hybridSelectIcon(context),
                  decoration: const InputDecoration(
                    contentPadding: hybridSelectPadding,
                  ),
                  items: [
                    for (final e in _sortLabels.entries)
                      DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (v) => setState(() => _sort = v ?? _sort),
                ),
              ),
              const SizedBox(height: AppSpacing.itemGap),
              BlockField(
                label: 'Type',
                child: DropdownButtonFormField<String?>(
                  key: const Key('tonight.type'),
                  isExpanded: true,
                  initialValue: _type,
                  style: select,
                  icon: hybridSelectIcon(context),
                  decoration: const InputDecoration(
                    contentPadding: hybridSelectPadding,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All types', overflow: TextOverflow.ellipsis),
                    ),
                    for (final t in types)
                      DropdownMenuItem(
                        value: t,
                        child: Text(t, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (v) => setState(() => _type = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          HybridCheckRow.plan(
            key: const Key('tonight.own'),
            label: 'Targets you added',
            checked: _ownOnly,
            onChanged: (v) => setState(() => _ownOnly = v),
          ),
          HybridCheckRow.plan(
            key: const Key('tonight.all'),
            label: 'Show targets without a window',
            checked: !_withWindowOnly,
            onChanged: (v) => setState(() => _withWindowOnly = !v),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      if (rows.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Text(
            'No target matches: none has an imaging window with these '
            'filters.',
            key: const Key('tonight.empty'),
            style: _secondary(context),
          ),
        ),
    ];
    final footer = Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Text(
        'Times in ${NightTimeFormatter.zoneCaption(night.startUtc, zoneId: zoneId)}. '
        "Tap a target to make it the plan's target.",
        style: AppTypography.caption.copyWith(
          height: 1.55,
          color: p.textSecondary,
        ),
      ),
    );

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.itemGap,
        AppSpacing.gutter,
        AppSpacing.xl,
      ),
      itemCount: header.length + rows.length + 1,
      itemBuilder: (context, i) {
        if (i < header.length) return header[i];
        if (i == header.length + rows.length) return footer;
        final r = rows[i - header.length];
        final t = r.target;
        final name = t.commonName != null && t.commonName != t.catalogId
            ? '${t.commonName} (${t.catalogId})'
            : t.commonName ?? t.catalogId;
        final reason = r.noWindowReason;
        final details = reason != null
            ? 'No window: ${OpportunityText.noWindowShort(reason, darknessLimitDeg: prefs.darknessLimit.degrees, minAltitudeDeg: prefs.minAltitudeDeg)}'
            : [
                '${at(r.firstWindowStartUtc!)} – ${at(r.lastWindowEndUtc!)}',
                'max ${QuantityText.degrees(r.maxAltitudeDeg!)}',
                r.minMoonSeparationDeg == null
                    ? 'Moon down in the windows'
                    : 'Moon ≥ ${QuantityText.degrees(r.minMoonSeparationDeg!)} away',
                if (r.frameFillFraction case final f?)
                  CapabilityText.frameFillOf(f),
              ].join(' · ');
        final index = i - header.length;
        return DocumentSection(
          joinPrevious: index > 0,
          joinNext: index < rows.length - 1,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          children: [
            _CandidateRow(
              key: Key('tonight.row.${t.id}'),
              title: name,
              caption: '${t.type} · $details',
              usable: OpportunityText.duration(r.usableTime),
              onTap: () async {
                await planVm.setTarget(t);
                if (context.mounted) context.pop();
              },
            ),
          ],
        );
      },
    );
  }
}

/// The sheet's title (`.phone-detail #detail-body h2`): 23 px, 16 above
/// and below.
class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.md),
    child: Semantics(
      header: true,
      child: Text(
        text,
        style: AppTypography.homeTarget.copyWith(
          fontSize: 23,
          height: 1.3,
          color: AppPalette.of(context).textPrimary,
        ),
      ),
    ),
  );
}

/// A candidate (app.js candidates, `.candidate-button`): the 14 px name,
/// its 12 px caption, the usable time and a chevron; the whole row picks
/// the target.
class _CandidateRow extends StatelessWidget {
  const _CandidateRow({
    super.key,
    required this.title,
    required this.caption,
    required this.usable,
    required this.onTap,
  });

  final String title;
  final String caption;
  final String usable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Semantics(
      button: true,
      label: '$title, $caption, $usable usable',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.body.copyWith(
                          height: 1.5,
                          color: p.textPrimary,
                        ),
                      ),
                      Text(
                        caption,
                        style: AppTypography.dense.copyWith(
                          height: 1.5,
                          color: p.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.itemGap),
                Text(
                  usable,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w500,
                    color: p.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                HybridIcon(
                  HybridIcons.chevron,
                  size: MediaQuery.textScalerOf(context).scale(18),
                  color: p.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
