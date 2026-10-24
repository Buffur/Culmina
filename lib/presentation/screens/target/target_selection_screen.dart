import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import '../../shared/document_section.dart';

import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/library_viewmodels.dart';
import '../../../domain/models/astro_target.dart';
import '../../../domain/models/target_types.dart';
import '../../navigation/app_router.dart';
import '../../shared/app_words.dart';
import '../../shared/confirmation_patterns.dart';
import '../../shared/delete_patterns.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/list_mode.dart';
import '../../shared/unsaved_plan_prompt.dart';
import '../../viewmodels/plan_lifecycle_viewmodel.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../../core/theme/app_spacing.dart';
import '../../shared/hybrid_icon.dart';
import '../library/library_parts.dart';
import '../settings/settings_parts.dart';
import 'target_detail_screen.dart';
import 'target_editor_screen.dart';

/// The targets (ADR-015; S9.1, D9-1): managed in the Library, where "Plan
/// this target" starts a new plan; chosen for the plan from
/// `/select/target`. Deleting confirms (RD-09 = M + S1).
class TargetSelectionScreen extends StatefulWidget {
  const TargetSelectionScreen({super.key, this.mode = ListMode.choose});

  final ListMode mode;

  @override
  State<TargetSelectionScreen> createState() => _TargetSelectionScreenState();
}

class _TargetSelectionScreenState extends State<TargetSelectionScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // In-memory list avoids FutureBuilder flicker on every add/edit/delete.
  List<AstroTarget> _targets = [];
  bool _initialLoading = true;
  Object? _loadError;

  /// F24 A6 (UX32-03): each request's number; only the newest request's
  /// result or failure is shown, so a late answer to an older query can
  /// never replace the newer one's list.
  int _generation = 0;

  /// The query whose answer [_targets] (or [_loadError]) holds; while it
  /// differs from [_searchQuery] the newer search is still running.
  String _shownQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTargets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTargets() async {
    final targets = context.read<TargetsViewModel>();
    final generation = ++_generation;
    final query = _searchQuery;
    bool current() => mounted && generation == _generation;
    try {
      final results = await targets.search(query);
      if (current()) {
        setState(() {
          _targets = results;
          _loadError = null;
          _initialLoading = false;
          _shownQuery = query;
        });
      }
    } catch (e) {
      // TASK 15.1: an unreadable list says so instead of looking empty.
      if (current()) {
        setState(() {
          _loadError = e;
          _initialLoading = false;
          _shownQuery = query;
        });
      }
    }
  }

  /// Displays name without duplicating it in parentheses when name == catalogId.
  String _targetLabel(AstroTarget target) {
    final name = target.commonName ?? target.catalogId;
    if (target.commonName != null && target.commonName != target.catalogId) {
      return '$name (${target.catalogId})';
    }
    return name;
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    _loadTargets();
  }

  static String _name(AstroTarget t) => t.commonName ?? t.catalogId;

  /// Deletes [target] after the shared confirmation (a stored record,
  /// RD-09); saved plans keep what they recorded (ADR-014 §4).
  Future<bool> _delete(AstroTarget target) async {
    final sure = await confirmDestructive(
      context,
      title: 'Delete this target?',
      message:
          '“${_name(target)}” is deleted from your targets. Saved plans keep '
          'what they recorded. Undo is offered right after.',
    );
    if (!sure || !mounted) return false;
    final targets = context.read<TargetsViewModel>();
    final plan = context.read<SessionPlanViewModel>();
    final restoreSelection = plan.rememberTargetForUndo(target.id);
    return deleteWithUndoFeedback(
      context,
      action: 'delete the target',
      message: 'Target deleted',
      remove: () => targets.deleteWithUndo(target.id),
      afterDelete: () async {
        await plan.refreshSelectedTarget();
        if (mounted) await _loadTargets();
      },
      afterRestore: () async {
        await restoreSelection();
        if (mounted) await _loadTargets();
      },
    );
  }

  /// "Plan this target" (S9.1, D9-1): a new plan with [target], after the
  /// leave guard (U1), then the planner.
  Future<void> _planThis(AstroTarget target) async {
    final leaving = await askBeforeLeavingPlan(context);
    if (leaving == null || !mounted) return;
    final lifecycle = context.read<PlanLifecycleViewModel>();
    final plan = context.read<SessionPlanViewModel>();
    final started = await runWithFeedback(
      context,
      'start a new plan',
      () async {
        await lifecycle.newSession(discard: leaving == LeavingPlan.discard);
        await plan.setTarget(target);
      },
    );
    if (started && mounted) {
      showDone(context, 'New plan for ${_name(target)}');
      unawaited(context.push(AppRouter.session()));
    }
  }

  /// Edits [existing] (or adds a target) on its own page; refreshes the
  /// list and the plan's copy (TD-028). Returns the saved target.
  Future<AstroTarget?> _edit({AstroTarget? existing}) async {
    final saved = await showTargetEditor(context, existing: existing);
    if (!mounted) return saved;
    unawaited(_loadTargets());
    // TD-028: pick up an edit to the currently selected target instead of
    // leaving the planner showing stale field values. A no-op unless the
    // edited target is the selected one.
    await context.read<SessionPlanViewModel>().refreshSelectedTarget();
    return saved;
  }

  /// The target's record (library.js detail), over the list.
  Future<void> _open(AstroTarget target) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TargetDetailScreen(
          target: target,
          onPlan: _planThis,
          // HT-DEV-02: the catalogue keeps its earlier edit and delete.
          onEdit: (t) => _edit(existing: t),
          onDelete: _delete,
        ),
      ),
    );
    if (mounted) await _loadTargets();
  }

  @override
  Widget build(BuildContext context) {
    final planVm = context.watch<SessionPlanViewModel>();
    final choosing = widget.mode == ListMode.choose;
    final own = [
      for (final t in _targets)
        if (!t.isCatalogEntry) t,
    ];
    final catalogue = [
      for (final t in _targets)
        if (t.isCatalogEntry) t,
    ];
    Widget row(AstroTarget target) {
      final tile = LibraryRow(
        key: Key('targets.row.${target.id}'),
        title: _targetLabel(target),
        caption: TargetTypes.isMoving(target.type)
            ? '${target.type} · ${TargetTypes.movingWarning}'
            : target.type,
        // Only when choosing: the Library describes the targets, not the
        // plan (S9.1).
        note: choosing && target.id == planVm.selectedTarget?.id
            ? 'Chosen for this plan'
            : null,
        onTap: choosing
            ? () {
                planVm.setTarget(target);
                context.pop();
              }
            : () => _open(target),
      );
      // Every Library target can be deleted (HT-DEV-02).
      return SwipeToDelete(
        itemKey: ValueKey('target_${target.id}'),
        onDelete: () => _delete(target),
        child: tile,
      );
    }

    final searching = _shownQuery != _searchQuery;
    return Scaffold(
      appBar: hybridAppBar(
        context,
        title: Text(choosing ? AppWords.chooseTarget : AppWords.targets),
      ),
      // library.js `listView` targets: search, Add target, your targets,
      // then the catalogue.
      body: ListView(
        key: const Key('targets.list'),
        padding: settingsPagePadding,
        children: [
          DocumentSection(
            key: const Key('targets.searchGroup'),
            children: [
              LibrarySearchField(
                key: const Key('targets.search'),
                controller: _searchController,
                label: 'Search targets',
                hint: 'Designation or name, e.g. M31 or Andromeda',
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: AppSpacing.itemGap),
              LibraryPrimaryAction(
                key: const Key('targets.add'),
                icon: HybridIcons.plus,
                label: 'Add target',
                onPressed: () => _edit(),
              ),
            ],
          ),
          if (_initialLoading)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            )
          // F24 A6: an older query's list is never shown under newer text.
          else if (searching)
            Padding(
              key: const Key('targets.searching'),
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Semantics(
                liveRegion: true,
                child: SettingsCopy('Searching for "$_searchQuery"…'),
              ),
            )
          else if (_loadError != null)
            LoadFailureView(
              action: 'load the targets',
              error: _loadError!,
              onRetry: _loadTargets,
            )
          else ...[
            const SizedBox(height: AppSpacing.md),
            DocumentSection(
              joinNext: own.isNotEmpty,
              children: [
                const SettingsHeading('Your targets', top: 0),
                if (own.isEmpty)
                  SettingsCopy(
                    _searchQuery.isEmpty
                        ? 'None added yet. Add a target with its J2000 '
                              'coordinates.'
                        : 'None of your targets match.',
                  ),
              ],
            ),
            for (final (i, t) in own.indexed)
              DocumentSection(
                joinPrevious: true,
                joinNext: i < own.length - 1,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: [row(t)],
              ),
            const SizedBox(height: AppSpacing.md),
            DocumentSection(
              joinNext: catalogue.isNotEmpty,
              children: [
                const SettingsHeading('Catalogue', top: 0),
                const SettingsHint(
                  'Bundled catalogue (OpenNGC-derived)',
                  top: 0,
                ),
                if (catalogue.isEmpty)
                  SettingsCopy(
                    _searchQuery.isEmpty
                        ? 'No targets found.'
                        : 'No results for "$_searchQuery".',
                    top: AppSpacing.sm,
                  ),
              ],
            ),
            for (final (i, t) in catalogue.indexed)
              DocumentSection(
                joinPrevious: true,
                joinNext: i < catalogue.length - 1,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: [row(t)],
              ),
          ],
        ],
      ),
    );
  }
}
