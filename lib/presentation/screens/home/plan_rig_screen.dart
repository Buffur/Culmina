import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

import '../../shared/document_section.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/equipment_profile.dart';
import '../../navigation/app_router.dart';
import '../../shared/app_words.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/hybrid_app_bar.dart';
import '../../shared/hybrid_parts.dart';
import '../../shared/rig_summary_text.dart';
import '../../viewmodels/library_viewmodels.dart';
import '../../viewmodels/session_plan_viewmodel.dart';

/// Rig (plan.js `choiceView`, Hybrid): the rigs as a radio list; Apply
/// changes sets the working plan's rig and Save plan records it. Close
/// discards the unapplied choice. Rigs are added and edited in the Library
/// ("Add or manage rigs"); from the plan's missing-rig action
/// ([forPlanAction], D8 A) a rig created there becomes this plan's rig and
/// the chooser returns to its caller.
class PlanRigScreen extends StatefulWidget {
  const PlanRigScreen({super.key, this.forPlanAction = false});

  final bool forPlanAction;

  @override
  State<PlanRigScreen> createState() => _PlanRigScreenState();
}

class _PlanRigScreenState extends State<PlanRigScreen> {
  List<EquipmentProfile> _rigs = const [];
  int? _chosen;
  bool _loading = true;
  Object? _error;
  int _loadRequest = 0;

  @override
  void initState() {
    super.initState();
    _chosen = context.read<SessionPlanViewModel>().selectedEquipment?.id;
    _load(initial: true);
  }

  Future<void> _load({bool initial = false}) async {
    final request = ++_loadRequest;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rigs = await context.read<GearViewModel>().all();
      if (!mounted || request != _loadRequest) return;
      // Nothing to choose yet: straight to adding one (F05 A1), where a rig
      // created from the plan's action becomes its rig (D8 A).
      if (rigs.isEmpty && initial) {
        context.pushReplacement(
          widget.forPlanAction
              ? AppRouter.manageRigsForPlan
              : AppRouter.manageRigs,
        );
        return;
      }
      setState(() {
        _rigs = rigs;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted || request != _loadRequest) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _apply() async {
    final plan = context.read<SessionPlanViewModel>();
    final rig = _rigs.where((r) => r.id == _chosen).firstOrNull;
    if (rig == null || rig.id == plan.selectedEquipment?.id) {
      Navigator.of(context).pop();
      return;
    }
    final ok = await runWithFeedback(
      context,
      'apply the rig',
      () => plan.setEquipment(rig),
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  Future<void> _manage() async {
    final plan = context.read<SessionPlanViewModel>();
    final before = plan.selectedEquipment?.id;
    await context.push(
      widget.forPlanAction ? AppRouter.manageRigsForPlan : AppRouter.manageRigs,
    );
    if (!mounted) return;
    await plan.refreshSelectedEquipment();
    if (!mounted) return;
    // D8 A: a rig created from the plan's action is already the plan's.
    final now = plan.selectedEquipment?.id;
    if (widget.forPlanAction && now != null && now != before) {
      Navigator.of(context).pop();
      return;
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Scaffold(
      appBar: hybridAppBar(
        context,
        leading: HybridCloseButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(AppWords.rig),
      ),
      body: ListView(
        key: const Key('planRig.scroll'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.itemGap,
          AppSpacing.gutter,
          AppSpacing.lg,
        ),
        children: [
          DocumentSection(
            joinNext: true,
            children: [
              if (_loading)
                Semantics(
                  liveRegion: true,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(key: Key('planRig.loading')),
                      SizedBox(height: AppSpacing.sm),
                      Text('Loading rigs…'),
                    ],
                  ),
                )
              else if (_error != null)
                LoadFailureView(
                  action: 'load the rigs',
                  error: _error!,
                  onRetry: _load,
                )
              else if (_rigs.isEmpty)
                Text(
                  AppWords.noRigs,
                  key: const Key('planRig.empty'),
                  style: AppTypography.body.copyWith(color: p.textPrimary),
                )
              else ...[
                const HybridFieldLabel('Choose a rig'),
                const SizedBox(height: 6),
              ],
            ],
          ),
          if (!_loading && _error == null)
            for (final r in _rigs)
              DocumentSection(
                joinPrevious: true,
                joinNext: true,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                children: [
                  HybridChoiceRow(
                    key: Key('planRig.choice.${r.id}'),
                    title: r.name,
                    caption: RigSummaryText.of(r),
                    selected: r.id == _chosen,
                    onTap: () => setState(() => _chosen = r.id),
                  ),
                ],
              ),
          DocumentSection(
            joinPrevious: true,
            children: [
              const SizedBox(height: 4),
              // plan.css `.editor-help`: 13 at 1.6, secondary.
              Text(
                'Camera type comes from the rig. Blocks show ISO or gain to match '
                'it; values recorded for another type are kept.',
                key: const Key('planRig.help'),
                style: AppTypography.caption.copyWith(
                  height: 1.6,
                  color: AppPalette.of(context).textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  key: const Key('planRig.manage'),
                  onPressed: _manage,
                  child: Text(
                    _rigs.isEmpty && !_loading && _error == null
                        ? AppWords.addRig
                        : 'Add or manage rigs',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: HybridApplyBar(
        buttonKey: const Key('planRig.apply'),
        label: 'Apply changes',
        onPressed: _rigs.isEmpty ? null : _apply,
      ),
    );
  }
}
