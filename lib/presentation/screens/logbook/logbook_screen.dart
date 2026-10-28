import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';
import 'package:flutter/material.dart';

import '../../shared/document_section.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/theme/hybrid_tokens.dart';
import '../../../domain/models/calendar_date.dart';
import '../../../domain/models/session.dart';
import '../../../domain/services/result_action.dart';
import '../../../domain/services/saved_night_end.dart';
import '../../../domain/services/session_reconciliation.dart';
import '../../navigation/app_router.dart';
import '../../shared/app_words.dart';
import '../../shared/confirmation_patterns.dart';
import '../../shared/delete_patterns.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/field_mode_button.dart';
import '../../shared/hybrid_icon.dart';
import '../../shared/hybrid_parts.dart';
import '../../shared/night_time_formatter.dart';
import '../../shared/plan_state.dart';
import '../../viewmodels/library_viewmodels.dart';
import '../../viewmodels/astrobin_export_viewmodel.dart';
import '../execution/results_screen.dart';
import 'astrobin_export.dart';

/// An entry's identity (S8.5–S8.6; RD-14): its name when it has one, else
/// its target and night, "M42 · Mon 15 Dec" ([targetAndNight]).
String entryTitle(Session s) => s.name ?? targetAndNight(s);

/// "M42 · Mon 15 Dec": the target and the night (a legacy row's stored
/// date, on the device's calendar).
String targetAndNight(Session s) {
  final night =
      s.eveningDate ??
      CalendarDate.fromDateTimeFields(s.record.sessionDate.toLocal());
  return '${s.record.targetName} · '
      '${NightTimeFormatter.eveningDateWithWeekday(night)}';
}

/// Deletes [s] after the shared confirmation (S5.8; RD-09 S1): a stored
/// record. Returns whether it was deleted.
Future<bool> deleteEntry(BuildContext context, Session s) async {
  final sure = await confirmDestructive(
    context,
    title: 'Delete this entry?',
    message:
        '"${entryTitle(s)}" and its result are deleted from the '
        'Logbook. You can Undo immediately after deleting.',
  );
  if (!sure || !context.mounted) return false;
  final sessions = context.read<SessionsViewModel>();
  return deleteWithUndoFeedback(
    context,
    action: 'delete the entry',
    message: 'Entry deleted',
    remove: () => sessions.deleteWithUndo(s.id),
  );
}

/// The Logbook (S8.5; ADR-019 §2, §8, §10; 08 §24): saved plans and their
/// results. Upcoming (saved plans whose night has not ended) and Past; a
/// search over the target, the site and the notes; the status, target, site
/// and night filters behind one Filters button (UX-30), kept by the
/// ViewModel so they survive navigation; Progress by target (RD-07). A tap
/// opens the entry; a swipe or the entry's Delete deletes, after a
/// confirmation.
class LogbookScreen extends StatefulWidget {
  const LogbookScreen({super.key});

  @override
  State<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends State<LogbookScreen> {
  late Future<List<Session>> _sessionsFuture;
  final _search = TextEditingController();
  final _searchFocus = FocusNode();

  /// Whether the filters are open below the search (logbook.js
  /// `ui.filtersOpen`).
  bool _filtersOpen = false;

  /// The ViewModel's [SessionsViewModel.revision] this list was read at.
  int _seen = 0;

  /// Whether this page was on screen at its last build (S11.C1, TD-092).
  bool _wasVisible = true;
  ({Map<int, String> targets, Map<int, String> sites}) _options = (
    targets: const {},
    sites: const {},
  );

  /// Planned vs actual for completed sessions (TASK 13.4), by id.
  Map<int, SessionReconciliation> _results = const {};

  /// Every saved entry, unfiltered (the count's whole).
  int? _total;
  int _readGeneration = 0;

  @override
  void initState() {
    super.initState();
    final vm = context.read<SessionsViewModel>();
    _search.text = vm.query;
    _seen = vm.revision;
    _refresh();
  }

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _refresh() {
    final sessions = context.read<SessionsViewModel>();
    final filter = sessions.filter;
    final generation = ++_readGeneration;
    setState(() {
      _sessionsFuture = sessions.saved(filter).then((list) async {
        final results = await sessions.reconciliations(list);
        final options = await sessions.filterOptions();
        // "2 of 6 entries": the filters narrow the query, so the whole
        // Logbook is counted apart.
        final total = filter.isEmpty
            ? list.length
            : (await sessions.saved()).length;
        if (mounted && generation == _readGeneration) {
          setState(() {
            _results = results;
            _options = options;
            _total = total;
          });
        }
        return list;
      });
    });
  }

  void _setFilter(SessionFilter f) {
    context.read<SessionsViewModel>().setFilter(f);
    _refresh();
  }

  void _searchAction(SessionsViewModel vm) {
    if (_search.text.isNotEmpty) {
      _search.clear();
      vm.setQuery('');
    }
    _searchFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SessionsViewModel>();
    // S11.C1 (TD-092): the shell keeps this tab alive, and a covering page
    // (the planner) hides it; a plan saved or edited meanwhile changes the
    // list. Coming back into view (its tickers enabled again) reads it again.
    final visible = TickerMode.valuesOf(context).enabled;
    final cameBack = visible && !_wasVisible;
    _wasVisible = visible;
    if (vm.revision != _seen || cameBack) {
      // An entry changed elsewhere (a name, a result): read them again.
      _seen = vm.revision;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _refresh();
      });
    }
    final astrobin = context.read<AstroBinExportViewModel?>();
    final p = AppPalette.of(context);
    return Scaffold(
      appBar: hybridAppBar(
        context,
        title: const Text(AppWords.logbook),
        actions: [
          const FieldModeButton(),
          // TASK 14.3 (owner): every saved entry in one manifest file. S9.8:
          // a labelled item in the Logbook's menu, not an icon alone.
          if (vm.canExport || astrobin != null)
            PopupMenuButton<void>(
              key: const Key('logbook.menu'),
              tooltip: 'More',
              // The plan's menu (plan.css `.plan-menu`).
              constraints: const BoxConstraints(minWidth: 220),
              offset: const Offset(0, AppSpacing.md),
              icon: HybridIcon(
                HybridIcons.planMore,
                size: MediaQuery.textScalerOf(context).scale(24),
              ),
              itemBuilder: (_) => [
                if (vm.canExport)
                  PopupMenuItem<void>(
                    key: const Key('logbook.exportAll'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    onTap: () async {
                      final done = await runWithFeedback(
                        context,
                        'export the Logbook',
                        vm.exportAll,
                      );
                      if (done && context.mounted) {
                        showDone(context, 'Export file created');
                      }
                    },
                    child: const Text(AppWords.exportAllAsFile),
                  ),
                // F20: the AstroBin acquisition CSV, after its preview.
                if (astrobin != null)
                  PopupMenuItem<void>(
                    key: const Key('logbook.astrobin'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    onTap: () => exportForAstroBinFlow(context),
                    child: const Text(exportForAstroBin),
                  ),
              ],
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.itemGap,
              AppSpacing.gutter,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _searchField(context, vm),
                  if (_filtersOpen)
                    DecoratedBox(
                      key: const Key('logbook.filters'),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: p.border)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: AppSpacing.itemGap,
                          bottom: AppSpacing.gutter,
                        ),
                        child: _FilterPanel(
                          filter: vm.filter,
                          options: _options,
                          onChanged: _setFilter,
                        ),
                      ),
                    ),
                  // logbook.js: Progress by target, a row of its own.
                  const SizedBox(height: 16),
                  DocumentSection(
                    key: const Key('logbook.progressGroup'),
                    children: [
                      _ProgressRow(
                        onTap: () => context.push(AppRouter.logbookProgress),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          FutureBuilder<List<Session>>(
            future: _sessionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              if (snapshot.error case final error?) {
                return SliverToBoxAdapter(
                  child: LoadFailureView(
                    action: 'load the Logbook',
                    error: error,
                    onRetry: _refresh,
                  ),
                );
              }
              final all = snapshot.data ?? const <Session>[];
              final filtered = vm.searched(all);
              final narrowed = !vm.filter.isEmpty || vm.query.trim().isNotEmpty;
              final total = vm.filter.isEmpty
                  ? all.length
                  : _total ?? all.length;
              final entries = '$total ${total == 1 ? 'entry' : 'entries'}';
              final count = narrowed
                  ? '${filtered.length} of $entries'
                  : entries;
              // Owner sketch 2026-10-21 (logbook.js renderResults): one list,
              // newest night first, grouped by month only; the count on the
              // first month's line.
              final ordered = [...filtered]
                ..sort((a, b) => _night(b).compareTo(_night(a)));
              final months = <(int, int), List<Session>>{};
              for (final s in ordered) {
                final n = _night(s);
                (months[(n.year, n.month)] ??= []).add(s);
              }
              final quiet = AppTextTheme.of(context).caption
                  .copyWith(color: p.textSecondary);
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  0,
                  AppSpacing.gutter,
                  AppSpacing.xl,
                ),
                sliver: SliverList.list(
                  children: [
                    if (all.isEmpty || filtered.isEmpty)
                      _Empty(
                        narrowed: narrowed,
                        count: count,
                        onClear: () {
                          _search.clear();
                          vm.setQuery('');
                          _setFilter(const SessionFilter());
                        },
                      ),
                    for (final (i, MapEntry(key: (year, month), value: list))
                        in months.entries.indexed) ...[
                      const SizedBox(height: 16),
                      DocumentSection(
                        key: ValueKey('logbook.month.$year.$month'),
                        joinNext: true,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Expanded(
                                child: Semantics(
                                  header: true,
                                  child: Text(
                                    '${_monthNames[month - 1]} $year',
                                    style: AppTextTheme.of(context)
                                        .resolve(quiet, AppTextGeometry.compact)
                                        .copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              if (i == 0)
                                Text(
                                  count,
                                  key: const Key('logbook.resultCount'),
                                  style: quiet,
                                ),
                            ],
                          ),
                        ],
                      ),
                      for (final (rowIndex, session) in list.indexed)
                        DocumentSection(
                          joinPrevious: true,
                          joinNext: rowIndex != list.length - 1,
                          padding: EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            rowIndex == list.length - 1 ? 16 : 0,
                          ),
                          children: [_row(context, vm, session)],
                        ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static CalendarDate _night(Session s) =>
      s.eveningDate ??
      CalendarDate.fromDateTimeFields(s.record.sessionDate.toLocal());

  /// The search field (owner sketch 2026-10-21): the Filters button inside
  /// it opens the filters; the magnifier only marks the field, or clears
  /// what was typed.
  Widget _searchField(BuildContext context, SessionsViewModel vm) {
    final p = AppPalette.of(context);
    final h = Theme.of(context).extension<HybridTokens>() ?? HybridTokens.light;
    final count = vm.filter.count;
    final scale = MediaQuery.textScalerOf(context);
    final typed = _search.text.isNotEmpty;
    return HybridPlanInputs(
      child: TextField(
        key: const Key('logbook.search'),
        controller: _search,
        focusNode: _searchFocus,
        textInputAction: TextInputAction.search,
        style: AppTextTheme.of(context).caption.copyWith(color: p.textPrimary),
        decoration: InputDecoration(
          hintText: 'Name, target, site or notes',
          hintStyle: AppTextTheme.of(context).caption
              .copyWith(color: p.textSecondary, fontStyle: FontStyle.italic),
          contentPadding: const EdgeInsets.fromLTRB(12, 14, 0, 14),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                button: true,
                label: count == 0 ? 'Filters' : 'Filters · $count on',
                expanded: _filtersOpen,
                excludeSemantics: true,
                onTap: _toggleFilters,
                child: Material(
                  color: _filtersOpen ? h.selection : HybridTokens.transparent,
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    key: const Key('logbook.filterToggle'),
                    borderRadius: BorderRadius.circular(6),
                    onTap: _toggleFilters,
                    child: SizedBox.square(
                      dimension: HybridTokens.minTarget,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          HybridIcon(
                            HybridIcons.filter,
                            size: scale.scale(20),
                            strokeWidth: 1.7,
                            color: _filtersOpen
                                ? p.textPrimary
                                : p.textSecondary,
                          ),
                          if (count > 0)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                key: const Key('logbook.filterCount'),
                                constraints: const BoxConstraints(minWidth: 16),
                                height: 16,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: p.textPrimary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$count',
                                  textAlign: TextAlign.center,
                                  // The reference's 11 px, at the
                                  // project's 12 sp floor.
                                  style: AppTextTheme.of(context)
                                      .resolve(
                                        AppTextTheme.of(context).dense,
                                        AppTextGeometry.chartCaption,
                                      )
                                      .copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                      ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (typed)
                IconButton(
                  key: const Key('logbook.searchToggle'),
                  tooltip: 'Clear search',
                  onPressed: () => _searchAction(vm),
                  icon: HybridIcon(
                    HybridIcons.close,
                    size: scale.scale(20),
                    strokeWidth: 1.7,
                    color: p.textSecondary,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 12),
                  child: ExcludeSemantics(
                    child: HybridIcon(
                      HybridIcons.search,
                      key: const Key('logbook.searchToggle'),
                      size: scale.scale(20),
                      strokeWidth: 1.7,
                      color: p.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        onChanged: (q) {
          vm.setQuery(q);
          setState(() {});
        },
      ),
    );
  }

  void _toggleFilters() => setState(() => _filtersOpen = !_filtersOpen);

  /// "Record from 24 Oct, 12:56 · Europe/Kyiv (GMT+3)." (logbook.js
  /// `resultWhen`; F19 A2/A5): when a saved night ahead can take its result,
  /// in the saved plan's zone.
  static String _resultWhen(BuildContext context, Session s) {
    final start = SavedNightEnd.startOf(s);
    if (start == null) {
      return 'A result can be recorded once the night begins.';
    }
    final zone = s.timeZoneId ?? s.planSnapshot?.timeZoneId;
    final date = NightTimeFormatter.eveningDate(
      CalendarDate.fromDateTimeFields(
        NightTimeFormatter.wallClock(start, zoneId: zone),
      ),
    );
    final short = NightTimeFormatter.shortZone(start, zoneId: zone);
    return 'Record from $date, '
        '${NightTimeFormatter.clockTime(context, start, zoneId: zone)} · '
        '${zone == null ? 'device zone' : '$zone ($short)'}.';
  }

  Widget _row(BuildContext context, SessionsViewModel vm, Session session) {
    final p = AppPalette.of(context);
    final log = session.record;
    final action = vm.resultAction(session);
    final record = action == ResultAction.record;
    // F19 A1: a saved night awaiting its report (from its start, never by
    // elapsed time alone); its row's blocks are the saved plan's only when
    // it is Saved or Not done.
    final dueReport =
        record && session.status != SessionStatus.inProgress && !session.legacy;
    final plannedOnly =
        !session.legacy &&
        (session.status == SessionStatus.planned ||
            session.status == SessionStatus.abandoned);
    final details = [
      if (session.name != null) targetAndNight(session),
      log.equipmentName,
      ?log.locationName,
    ].join(' · ');
    final caption = AppTextTheme.of(context)
        .resolve(AppTextTheme.of(context).caption, AppTextGeometry.supporting)
        .copyWith(color: p.textSecondary);
    final integration = AppTextTheme.of(context)
        .resolve(AppTextTheme.of(context).caption, AppTextGeometry.standard)
        .copyWith(
          color: p.textPrimary,
          fontFeatures: const [FontFeature.tabularFigures()],
        );
    return SwipeToDelete(
      itemKey: ValueKey('logbook_${session.id}'),
      onDelete: () async {
        if (await deleteEntry(context, session) && mounted) _refresh();
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: p.border)),
        ),
        child: InkWell(
          key: Key('logbook.entry.${session.id}'),
          onTap: () async {
            // TASK 14.1 (owner): the entry; Record or Edit result is its
            // primary action there (owner sketch: no row buttons).
            await context.push(AppRouter.sessionDetail(session.id));
            if (mounted) _refresh();
          },
          child: Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.itemGap,
              bottom: AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 2,
              children: [
                // The state is the entry's right column, beside the title
                // and its first details line.
                LayoutBuilder(
                  builder: (context, constraints) {
                    final information = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          entryTitle(session),
                          key: Key('logbook.title.${session.id}'),
                          style: AppTextTheme.of(context).rowTitle
                              .copyWith(color: p.textPrimary),
                        ),
                        Text(
                          details,
                          style: AppTextTheme.of(context)
                              .resolve(
                                AppTextTheme.of(context).body,
                                AppTextGeometry.reading,
                              )
                              .copyWith(color: p.textSecondary),
                        ),
                      ],
                    );
                    final states = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        EntryStateBadge(
                          PlanState.of(session),
                          key: Key('logbook.status.${session.id}'),
                        ),
                        if (dueReport)
                          EntryStateBadge.due(
                            key: Key('logbook.noResult.${session.id}'),
                          ),
                      ],
                    );
                    // Keep complete status labels readable as text grows. A side column
                    // receives unbounded width in a Row; stacking uses the actual group width.
                    if (MediaQuery.textScalerOf(context).scale(1) >= 1.5 ||
                        constraints.maxWidth < 280) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          information,
                          const SizedBox(height: 8),
                          states,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: information),
                        const SizedBox(width: AppSpacing.itemGap),
                        states,
                      ],
                    );
                  },
                ),
                // TASK 13.4 (owner): planned vs actual for a result; F19 A1:
                // the plan alone for an entry without counts.
                if (_results[session.id] case final r?)
                  Text(
                    ResultsText.integration(r),
                    key: Key('logbook.integration.${session.id}'),
                    style: integration,
                  )
                else if (plannedOnly)
                  Text(
                    ResultsText.plannedOnly(
                      SessionReconciliation.plannedOnly(session.blocks),
                      // A Not done run may hold earlier confirmations, so
                      // "none recorded" is said only of a due report.
                      due: dueReport,
                    ),
                    key: Key('logbook.integration.${session.id}'),
                    style: integration,
                  ),
                // F19 A5: a saved night ahead offers no Record result yet;
                // its row says from when one can be recorded.
                if (action == ResultAction.none && session.isSavedPlan)
                  Text(
                    _resultWhen(context, session),
                    key: Key('logbook.resultWhen.${session.id}'),
                    style: caption,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Progress by target (logbook.js `data-open-progress`): a 16/500 title, a
/// 14 px caption, the chevron; padding 16 0 and a rule below.
class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: InkWell(
          key: const Key('logbook.progress'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        AppWords.progressByTarget,
                        style: AppTextTheme.of(context).rowTitle
                            .copyWith(color: p.textPrimary),
                      ),
                      Text(
                        'Integration so far, from your results',
                        style: AppTextTheme.of(context)
                            .resolve(
                              AppTextTheme.of(context).body,
                              AppTextGeometry.reading,
                            )
                            .copyWith(color: p.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                HybridIcon(
                  HybridIcons.next,
                  size: MediaQuery.textScalerOf(context).scale(18),
                  strokeWidth: 1.7,
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

/// No entries yet, or none matching (logbook.js `renderResults`).
class _Empty extends StatelessWidget {
  const _Empty({
    required this.narrowed,
    required this.count,
    required this.onClear,
  });

  final bool narrowed;
  final String count;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            count,
            key: const Key('logbook.resultCount'),
            style: AppTextTheme.of(context).caption
                .copyWith(color: p.textSecondary),
          ),
          const SizedBox(height: AppSpacing.itemGap),
          Text(
            narrowed
                ? 'Nothing matches the search or the filters.'
                : 'Nothing saved yet. Save a plan, then return here to '
                      'record its result.',
            key: const Key('logbook.empty'),
            style: AppTextTheme.of(context)
                .resolve(AppTextTheme.of(context).body, AppTextGeometry.reading)
                .copyWith(color: p.textSecondary),
          ),
          const SizedBox(height: AppSpacing.itemGap),
          OutlinedButton(
            key: Key(narrowed ? 'logbook.clearAll' : 'logbook.openPlanner'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(HybridTokens.minTarget),
            ),
            onPressed: narrowed
                ? onClear
                : () => context.push(AppRouter.session()),
            child: Text(narrowed ? 'Clear search and filters' : 'Open planner'),
          ),
        ],
      ),
    );
  }
}

/// The filters (logbook.js `listView`; S8.5, UX-30): the states, the
/// target, the site and the nights, shown as they change and cleared at
/// once.
class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.filter,
    required this.options,
    required this.onChanged,
  });

  final SessionFilter filter;
  final ({Map<int, String> targets, Map<int, String> sites}) options;
  final ValueChanged<SessionFilter> onChanged;

  static const _statusLabels = {
    SessionListStatus.planned: AppWords.saved,
    SessionListStatus.completed: AppWords.completed,
    SessionListStatus.abandoned: AppWords.notDone,
    SessionListStatus.inProgress: AppWords.tracking,
  };

  SessionFilter _copy({
    Set<SessionListStatus>? statuses,
    int? Function()? targetId,
    int? Function()? siteId,
    (CalendarDate?, CalendarDate?)? range,
  }) => SessionFilter(
    statuses: statuses ?? filter.statuses,
    targetId: targetId == null ? filter.targetId : targetId(),
    siteId: siteId == null ? filter.siteId : siteId(),
    from: range == null ? filter.from : range.$1,
    to: range == null ? filter.to : range.$2,
  );

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final label = AppTextTheme.of(context).caption
        .copyWith(color: p.textSecondary);
    final f = filter;
    Widget select(String key, String title, int? value, Map<int, String> all) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: label),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<int>(
              key: Key(key),
              initialValue: value ?? -1,
              isExpanded: true,
              icon: hybridSelectIcon(context),
              style: AppTextTheme.of(context).caption
                  .copyWith(color: p.textPrimary),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              items: [
                const DropdownMenuItem(value: -1, child: Text('All')),
                for (final MapEntry(:key, :value) in all.entries)
                  DropdownMenuItem(value: key, child: Text(value)),
              ],
              onChanged: (id) => onChanged(
                key == 'logbook.filter.target'
                    ? _copy(targetId: () => id == null || id < 0 ? null : id)
                    : _copy(siteId: () => id == null || id < 0 ? null : id),
              ),
            ),
          ],
        );
    Widget date(String key, String title, CalendarDate? value, bool from) =>
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: label),
              const SizedBox(height: AppSpacing.xs),
              OutlinedButton(
                key: Key(key),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(HybridTokens.minTarget),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(now.year + 5),
                    initialDate: value == null
                        ? now
                        : DateTime(value.year, value.month, value.day),
                    helpText: from ? 'First night' : 'Last night',
                  );
                  if (picked == null) return;
                  final d = CalendarDate.fromDateTimeFields(picked);
                  onChanged(_copy(range: from ? (d, f.to) : (f.from, d)));
                },
                child: Text(
                  value == null
                      ? 'Any'
                      : NightTimeFormatter.recordedDate(value),
                  style: AppTextTheme.of(context).caption.copyWith(
                    color: value == null ? p.textSecondary : p.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
    final inverted =
        f.from != null && f.to != null && f.from!.compareTo(f.to!) > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(header: true, child: Text('State', style: label)),
        const SizedBox(height: AppSpacing.xs),
        for (final MapEntry(:key, :value) in _statusLabels.entries)
          HybridCheckRow(
            key: Key('logbook.filter.${key.name}'),
            label: value,
            checked: f.statuses.contains(key),
            onChanged: (on) => onChanged(
              _copy(
                statuses: on
                    ? {...f.statuses, key}
                    : ({...f.statuses}..remove(key)),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Text(
            'Completed includes Partly results.',
            style: AppTextTheme.of(context)
                .resolve(label, AppTextGeometry.supporting),
          ),
        ),
        const SizedBox(height: AppSpacing.gutter),
        select('logbook.filter.target', 'Target', f.targetId, options.targets),
        const SizedBox(height: AppSpacing.gutter),
        select('logbook.filter.site', AppWords.site, f.siteId, options.sites),
        const SizedBox(height: AppSpacing.gutter),
        Text('Nights (evening date)', style: label),
        const SizedBox(height: AppSpacing.xs),
        Row(
          key: const Key('logbook.filter.dates'),
          spacing: AppSpacing.itemGap,
          children: [
            date('logbook.filter.from', 'From', f.from, true),
            date('logbook.filter.to', 'To', f.to, false),
          ],
        ),
        if (inverted)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              // The app applies the range as given (TASK 14.1), so an
              // inverted one matches nothing; it says so.
              'The first night is after the last, so no night matches.',
              key: const Key('logbook.filter.rangeError'),
              style: label.copyWith(
                color:
                    (Theme.of(context).extension<HybridTokens>() ??
                            HybridTokens.light)
                        .errorText,
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.gutter),
        OutlinedButton(
          key: const Key('logbook.filters.clear'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(HybridTokens.minTarget),
          ),
          onPressed: f.isEmpty ? null : () => onChanged(const SessionFilter()),
          child: const Text('Clear filters'),
        ),
      ],
    );
  }
}
