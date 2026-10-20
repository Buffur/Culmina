import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
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
import '../../shared/night_time_formatter.dart';
import '../../shared/plan_state.dart';
import '../../viewmodels/library_viewmodels.dart';
import '../../viewmodels/astrobin_export_viewmodel.dart';
import '../execution/results_screen.dart';
import 'astrobin_export.dart';

/// An entry's identity (S8.5–S8.6; RD-14): its name when it has one, else
/// its target and night, "M42 · Mon, Dec 15" ([targetAndNight]).
String entryTitle(Session s) => s.name ?? targetAndNight(s);

/// "M42 · Mon, Dec 15": the target and the night (a legacy row's stored
/// date, on the device's calendar).
String targetAndNight(Session s) {
  final night =
      s.eveningDate ??
      CalendarDate.fromDateTimeFields(s.record.sessionDate.toLocal());
  return '${s.record.targetName} · ${NightTimeFormatter.eveningDate(night)}';
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
  final _filters = ExpansibleController();

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
    _filters.dispose();
    super.dispose();
  }

  void _refresh() {
    final sessions = context.read<SessionsViewModel>();
    setState(() {
      _sessionsFuture = sessions.saved(sessions.filter).then((list) async {
        final results = await sessions.reconciliations(list);
        final options = await sessions.filterOptions();
        if (mounted) {
          setState(() {
            _results = results;
            _options = options;
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
    final count = vm.filter.count;
    final astrobin = context.read<AstroBinExportViewModel?>();
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
              itemBuilder: (_) => [
                if (vm.canExport)
                  PopupMenuItem<void>(
                    key: const Key('logbook.exportAll'),
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
                    child: const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.file_download_outlined),
                      title: Text(AppWords.exportAllAsFile),
                    ),
                  ),
                // F20: the AstroBin acquisition CSV, after its preview.
                if (astrobin != null)
                  PopupMenuItem<void>(
                    key: const Key('logbook.astrobin'),
                    onTap: () => exportForAstroBinFlow(context),
                    child: const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.table_view_outlined),
                      title: Text(exportForAstroBin),
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    key: const Key('logbook.search'),
                    controller: _search,
                    focusNode: _searchFocus,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      hintText: 'Name, target, site or notes',
                      suffixIcon: IconButton(
                        key: const Key('logbook.searchToggle'),
                        tooltip: _search.text.isEmpty
                            ? 'Search'
                            : 'Clear search',
                        icon: Icon(
                          _search.text.isEmpty ? Icons.search : Icons.close,
                        ),
                        onPressed: () => _searchAction(vm),
                      ),
                    ),
                    onChanged: vm.setQuery,
                  ),
                  ExpansionTile(
                    key: const Key('logbook.filters'),
                    controller: _filters,
                    maintainState: true,
                    tilePadding: EdgeInsets.zero,
                    title: Text(count == 0 ? 'Filters' : 'Filters · $count on'),
                    children: [
                      _FilterPanel.body(
                        context,
                        vm.filter,
                        _options,
                        _setFilter,
                        onDone: _filters.collapse,
                      ),
                    ],
                  ),
                  ListTile(
                    key: const Key('logbook.progress'),
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.stacked_line_chart),
                    title: const Text(AppWords.progressByTarget),
                    subtitle: const Text(
                      'Integration so far, from your results',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRouter.logbookProgress),
                  ),
                  const Divider(height: 1),
                  if (count > 0)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        key: const Key('logbook.filter.clear'),
                        onPressed: () => _setFilter(const SessionFilter()),
                        icon: const Icon(Icons.filter_list_off),
                        label: Text(
                          '$count ${count == 1 ? 'filter' : 'filters'} on · Clear',
                        ),
                      ),
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
                  child: Center(child: CircularProgressIndicator()),
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
              final groups = vm.grouped(filtered);
              final narrowed = !vm.filter.isEmpty || vm.query.trim().isNotEmpty;
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                sliver: SliverList.list(
                  children: [
                    Text(
                      '${filtered.length} ${filtered.length == 1 ? 'entry' : 'entries'}',
                      key: const Key('logbook.resultCount'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (groups.upcoming.isEmpty && groups.past.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          narrowed
                              ? 'Nothing matches the search or the filters.'
                              : 'Nothing saved yet. Plans you save appear here, '
                                    'and their results once you record them.',
                          key: const Key('logbook.empty'),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (groups.upcoming.isNotEmpty) ...[
                      const _GroupHeader(
                        'Upcoming',
                        key: Key('logbook.upcoming'),
                      ),
                      for (final s in groups.upcoming) _row(context, vm, s),
                    ],
                    if (groups.past.isNotEmpty) ...[
                      const _GroupHeader('Past', key: Key('logbook.past')),
                      for (final s in groups.past) _row(context, vm, s),
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

  /// When a saved night ahead can take its result (F19 A2/A5), in the
  /// saved plan's zone: the entry detail's wording.
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
    return 'A result can be recorded once the night begins: from $date, '
        '${NightTimeFormatter.clockTime(context, start, zoneId: zone)}.';
  }

  Widget _row(BuildContext context, SessionsViewModel vm, Session session) {
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
    return SwipeToDelete(
      itemKey: ValueKey('logbook_${session.id}'),
      onDelete: () async {
        if (await deleteEntry(context, session) && mounted) _refresh();
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          onTap: () async {
            // TASK 14.1 (owner): the entry; the planner opens from there.
            await context.push(AppRouter.sessionDetail(session.id));
            if (mounted) _refresh();
          },
          title: Text(
            entryTitle(session),
            key: Key('logbook.title.${session.id}'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          subtitle: DefaultTextStyle.merge(
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontSize: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    PlanStateLabel(
                      PlanState.of(session),
                      key: Key('logbook.status.${session.id}'),
                    ),
                    if (dueReport)
                      Row(
                        key: Key('logbook.noResult.${session.id}'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.pending_actions, size: 14),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(child: Text(AppWords.resultNotRecorded)),
                        ],
                      ),
                  ],
                ),
                Text(details),
                // TASK 13.4 (owner): planned vs actual for a result; F19 A1:
                // the plan alone for an entry without counts.
                if (_results[session.id] case final r?)
                  Text(
                    ResultsText.integration(r),
                    key: Key('logbook.integration.${session.id}'),
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
                  ),
                // F19 A5: a saved night ahead offers no Record result yet;
                // its card says from when one can be recorded, rather than
                // leaving the action unexplained.
                if (action == ResultAction.none && session.isSavedPlan)
                  Text(
                    _resultWhen(context, session),
                    key: Key('logbook.resultWhen.${session.id}'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                // S8.2 (I-6): Record result once the saved night has ended;
                // Edit result for a result.
                if (action != ResultAction.none)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      key: Key(
                        '${record ? 'logbook.recordResult' : 'logbook.editResults'}'
                        '.${session.id}',
                      ),
                      onPressed: () async {
                        await context.push(AppRouter.results(session.id));
                        if (mounted) _refresh();
                      },
                      child: Text(
                        record ? AppWords.recordResult : AppWords.editResult,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, AppSpacing.md, 0, AppSpacing.sm),
    child: Semantics(
      header: true,
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    ),
  );
}

/// The filters in one panel (S8.5; UX-30): today's status, target, site and
/// night semantics (TASK 14.1), shown as they change and cleared at once.
abstract final class _FilterPanel {
  static const _statusLabels = {
    SessionListStatus.planned: AppWords.saved,
    SessionListStatus.inProgress: AppWords.tracking,
    SessionListStatus.completed: AppWords.completed,
    SessionListStatus.abandoned: AppWords.notDone,
  };

  static SessionFilter _copy(
    SessionFilter f, {
    Set<SessionListStatus>? statuses,
    int? Function()? targetId,
    int? Function()? siteId,
    (CalendarDate?, CalendarDate?)? range,
  }) => SessionFilter(
    statuses: statuses ?? f.statuses,
    targetId: targetId == null ? f.targetId : targetId(),
    siteId: siteId == null ? f.siteId : siteId(),
    from: range == null ? f.from : range.$1,
    to: range == null ? f.to : range.$2,
  );

  static Future<int?> _pick(
    BuildContext context,
    String title,
    Map<int, String> choices,
  ) => showModalBottomSheet<int?>(
    context: context,
    builder: (sheet) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(title: Text(title), enabled: false),
          ListTile(
            key: const Key('logbook.pick.all'),
            title: const Text('All'),
            onTap: () => Navigator.of(sheet).pop(-1),
          ),
          for (final MapEntry(:key, :value) in choices.entries)
            ListTile(
              key: Key('logbook.pick.$key'),
              title: Text(value),
              onTap: () => Navigator.of(sheet).pop(key),
            ),
        ],
      ),
    ),
  );

  static Widget body(
    BuildContext context,
    SessionFilter f,
    ({Map<int, String> targets, Map<int, String> sites}) options,
    ValueChanged<SessionFilter> onChanged, {
    required VoidCallback onDone,
  }) {
    String dates() {
      if (f.from == null && f.to == null) return 'Any night';
      final a = f.from == null ? '…' : NightTimeFormatter.eveningDate(f.from!);
      final b = f.to == null ? '…' : NightTimeFormatter.eveningDate(f.to!);
      return '$a – $b';
    }

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('State', style: theme.textTheme.bodySmall),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              for (final MapEntry(:key, :value) in _statusLabels.entries)
                FilterChip(
                  key: Key('logbook.filter.${key.name}'),
                  label: Text(value),
                  selected: f.statuses.contains(key),
                  onSelected: (on) => onChanged(
                    _copy(
                      f,
                      statuses: on
                          ? {...f.statuses, key}
                          : ({...f.statuses}..remove(key)),
                    ),
                  ),
                ),
            ],
          ),
          ListTile(
            key: const Key('logbook.filter.target'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Target'),
            subtitle: Text(
              f.targetId == null
                  ? 'All'
                  : options.targets[f.targetId] ?? 'Selected',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final id = await _pick(context, 'Target', options.targets);
              if (id != null) {
                onChanged(_copy(f, targetId: () => id < 0 ? null : id));
              }
            },
          ),
          ListTile(
            key: const Key('logbook.filter.site'),
            contentPadding: EdgeInsets.zero,
            title: const Text(AppWords.site),
            subtitle: Text(
              f.siteId == null ? 'All' : options.sites[f.siteId] ?? 'Selected',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final id = await _pick(context, 'Site', options.sites);
              if (id != null) {
                onChanged(_copy(f, siteId: () => id < 0 ? null : id));
              }
            },
          ),
          ListTile(
            key: const Key('logbook.filter.dates'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Nights'),
            subtitle: Text(dates()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final now = DateTime.now();
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(now.year + 5),
                helpText: 'Nights from – to',
              );
              if (range != null) {
                onChanged(
                  _copy(
                    f,
                    range: (
                      CalendarDate.fromDateTimeFields(range.start),
                      CalendarDate.fromDateTimeFields(range.end),
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: const Key('logbook.filters.clear'),
                  onPressed: f.isEmpty
                      ? null
                      : () => onChanged(const SessionFilter()),
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  key: const Key('logbook.filters.done'),
                  onPressed: onDone,
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
