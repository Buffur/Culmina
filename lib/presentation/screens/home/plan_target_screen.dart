import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/astro_target.dart';
import '../../../domain/models/target_alias.dart';
import '../../../domain/models/target_types.dart';
import '../../navigation/app_router.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/hybrid_app_bar.dart';
import '../../shared/hybrid_parts.dart';
import '../../viewmodels/library_viewmodels.dart';
import '../../viewmodels/session_plan_viewmodel.dart';

/// Target (plan.js `choiceView`, Hybrid): search the targets and choose
/// one as a radio list; Apply changes sets the working plan's target and
/// Save plan records it. Close discards the unapplied choice. Targets are
/// added and edited in the Library ("Add or manage targets").
class PlanTargetScreen extends StatefulWidget {
  const PlanTargetScreen({super.key});

  @override
  State<PlanTargetScreen> createState() => _PlanTargetScreenState();
}

class _PlanTargetScreenState extends State<PlanTargetScreen> {
  final _query = TextEditingController();
  List<AstroTarget> _found = const [];
  int _bundled = 0;
  int _yours = 0;
  Map<String, List<TargetAlias>> _aliases = const {};

  /// The chosen target, kept while a search hides it.
  AstroTarget? _chosen;
  bool _loading = true;
  Object? _error;

  /// Each request's number: a late answer to an older query never replaces
  /// a newer one's list (F24 A6, UX32-03).
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _chosen = context.read<SessionPlanViewModel>().selectedTarget;
    _load();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  static bool _isYours(AstroTarget t) => t.source == 'user';

  Future<void> _load() async {
    final targets = context.read<TargetsViewModel>();
    final generation = ++_generation;
    final query = _query.text;
    try {
      final all = query.trim().isEmpty ? null : await targets.search('');
      final found = await targets.search(query);
      final aliases = _aliases.isEmpty ? await targets.aliases() : _aliases;
      if (!mounted || generation != _generation) return;
      final counted = all ?? found;
      setState(() {
        _found = found;
        _aliases = aliases;
        _yours = counted.where(_isYours).length;
        _bundled = counted.length - _yours;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  /// "M31 · Andromeda Galaxy" (plan.js `targetResults`).
  static String title(AstroTarget t) =>
      t.commonName != null && t.commonName != t.catalogId
      ? '${t.catalogId} · ${t.commonName}'
      : t.commonName ?? t.catalogId;

  /// "Galaxy · also NGC 224" (plan.js `targetCaption`); your own target
  /// says so; a moving type keeps its warning (ADR-010 §3).
  String _caption(AstroTarget t) {
    final also = [
      for (final a in _aliases[t.catalogId] ?? const <TargetAlias>[])
        if (a.alias != t.commonName && a.alias != t.catalogId) a.alias,
    ];
    return [
      t.type,
      if (TargetTypes.isMoving(t.type)) TargetTypes.movingWarning,
      if (_isYours(t)) 'Your Library',
      if (also.isNotEmpty) 'also ${also.join(', ')}',
    ].join(' · ');
  }

  Future<void> _apply() async {
    final plan = context.read<SessionPlanViewModel>();
    final target = _chosen;
    if (target == null || target.id == plan.selectedTarget?.id) {
      Navigator.of(context).pop();
      return;
    }
    final ok = await runWithFeedback(
      context,
      'apply the target',
      () => plan.setTarget(target),
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final selected = context.watch<SessionPlanViewModel>().selectedTarget;
    final note = AppTypography.caption.copyWith(
      height: 1.55,
      color: p.textSecondary,
    );
    return Scaffold(
      appBar: hybridAppBar(
        context,
        leading: HybridCloseButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Target'),
      ),
      body: HybridPlanInputs(
        child: ListView(
          key: const Key('planTarget.scroll'),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            const HybridFieldLabel('Search targets'),
            const SizedBox(height: 4),
            TextField(
              key: const Key('planTarget.search'),
              controller: _query,
              autocorrect: false,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Name, M31 or NGC 224',
              ),
              onChanged: (_) => _load(),
            ),
            const SizedBox(height: 20),
            Text(
              [
                '$_bundled bundled targets and $_yours Library targets. Library '
                    'selections are copied into this plan.',
                if (selected != null) 'Selected: ${title(selected)}.',
              ].join(' '),
              key: const Key('planTarget.note'),
              style: note,
            ),
            const SizedBox(height: 8),
            Semantics(
              liveRegion: true,
              child: Text(
                _loading
                    ? 'Searching…'
                    : '${_found.length} result${_found.length == 1 ? '' : 's'}',
                key: const Key('planTarget.count'),
                style: AppTypography.caption.copyWith(color: p.textSecondary),
              ),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              LoadFailureView(
                action: 'load the targets',
                error: _error!,
                onRetry: _load,
              )
            else if (!_loading && _found.isEmpty)
              Text(
                'No matches. Try a catalogue number or another name.',
                style: AppTypography.body.copyWith(color: p.textPrimary),
              )
            else ...[
              const HybridFieldLabel('Choose a target'),
              const SizedBox(height: 6),
              for (final t in _found)
                HybridChoiceRow(
                  key: Key('planTarget.choice.${t.id}'),
                  title: title(t),
                  caption: _caption(t),
                  selected: t.id == _chosen?.id,
                  onTap: () => setState(() => _chosen = t),
                ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const Key('planTarget.manage'),
                onPressed: () async {
                  await context.push(AppRouter.manageTargets);
                  if (mounted) await _load();
                },
                child: const Text('Add or manage targets'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: HybridApplyBar(
          buttonKey: const Key('planTarget.apply'),
          label: 'Apply changes',
          onPressed: _apply,
        ),
      ),
    );
  }
}
