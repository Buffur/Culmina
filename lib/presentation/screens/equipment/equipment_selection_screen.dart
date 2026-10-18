import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/library_viewmodels.dart';
import '../../../domain/models/camera_class.dart';
import '../../../domain/models/equipment_profile.dart';
import '../../../domain/models/tracking_type.dart';
import '../../../core/config/feature_scope.dart';
import '../../navigation/app_router.dart';
import '../../shared/app_words.dart';
import '../../shared/confirmation_patterns.dart';
import '../../shared/delete_patterns.dart';
import '../../shared/example_text.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/equipment_draft.dart';
import '../../shared/list_mode.dart';
import '../../shared/rig_input_text.dart';
import '../metadata/metadata_import_screen.dart';
import 'add_rig_panel.dart';
import 'equipment_editor.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';

/// The rigs (ADR-015; S9.1, D9-1): managed in the Library, chosen for the
/// plan from `/select/rig`. Deleting confirms (RD-09 = M + S1). A new rig
/// starts with its camera class, then From a photo or Enter by hand (F05).
class EquipmentSelectionScreen extends StatefulWidget {
  const EquipmentSelectionScreen({
    super.key,
    this.mode = ListMode.choose,
    this.forPlanAction = false,
  });

  final ListMode mode;

  /// Opened from the plan's missing-rig action or onboarding (D8 A,
  /// UXA-C2): a rig created here becomes the plan's rig and the screen
  /// returns to its caller. Elsewhere a new rig is only saved.
  final bool forPlanAction;

  @override
  State<EquipmentSelectionScreen> createState() =>
      _EquipmentSelectionScreenState();
}

class _EquipmentSelectionScreenState extends State<EquipmentSelectionScreen> {
  // In-memory list — avoids FutureBuilder flicker on every add/edit/delete.
  List<EquipmentProfile> _equipment = [];
  bool _initialLoading = true;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _loadEquipment();
  }

  Future<void> _loadEquipment() async {
    final gear = context.read<GearViewModel>();
    try {
      final results = await gear.all();
      if (mounted) {
        setState(() {
          _equipment = results;
          _loadError = null;
          _initialLoading = false;
        });
      }
    } catch (e) {
      // TASK 15.1: an unreadable list says so instead of looking empty.
      if (mounted) {
        setState(() {
          _loadError = e;
          _initialLoading = false;
        });
      }
    }
  }

  /// Build a concise subtitle for an equipment card.
  String _subtitle(EquipmentProfile eq) {
    // RD-04 (S6.8): the shipped example is labelled where it is listed.
    final parts = <String>[if (eq.isExample) ExampleText.rig];
    if (eq.manufacturer != null && eq.manufacturer!.isNotEmpty) {
      parts.add(eq.manufacturer!);
    }
    if (eq.cameraModel != null && eq.cameraModel!.isNotEmpty) {
      parts.add(eq.cameraModel!);
    }
    parts.add('${eq.resolutionWidthPx}×${eq.resolutionHeightPx} px');
    parts.add('${eq.pixelPitchUm} µm');
    parts.add('${_trim(eq.focalLengthMm)} mm');
    parts.add(
      eq.needsApertureReview
          ? 'f/${_trim(eq.focalRatio)} — please review'
          : 'f/${eq.focalRatio.toStringAsFixed(1)}',
    );
    // S7.2a: the camera class, once the user chose one (never inferred).
    if (eq.cameraClass != CameraClass.unknown) parts.add(eq.cameraClass.label);
    if (eq.trackingType != TrackingType.unknown) {
      parts.add(eq.trackingType.label);
    }
    return parts.join(' · ');
  }

  static String _trim(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';

  /// Opens the metadata import for a new rig of [cameraClass]; a rig saved
  /// there shows up on return, and is chosen for a plan action (D8).
  Future<void> _importFromPhoto(CameraClass cameraClass) async {
    final id = await context.push<int>(
      AppRouter.metadata,
      extra: NewRigArgs(
        cameraClass: cameraClass,
        returnsNewRig: widget.forPlanAction,
      ),
    );
    if (!mounted) return;
    await _loadEquipment();
    if (!mounted) return;
    await context.read<SessionPlanViewModel>().refreshSelectedEquipment();
    if (id != null) await _chooseCreated(id);
  }

  /// A new rig by hand, of the class chosen first.
  Future<void> _addByHand(CameraClass cameraClass) async {
    final id = await showEquipmentEditor(
      context,
      draft: EquipmentDraft.fromProfile(null).withCameraClass(cameraClass),
    );
    if (!mounted) return;
    await _loadEquipment();
    if (!mounted || id == null) return;
    if (widget.forPlanAction) {
      await _chooseCreated(id);
    } else {
      showDone(context, 'Rig saved');
    }
  }

  /// D8 A: the rig just created from a plan action becomes the plan's rig,
  /// once, and the screen returns to its caller with the result. Elsewhere
  /// it is only saved (the list shows it).
  Future<void> _chooseCreated(int id) async {
    final created = _equipment.where((e) => e.id == id).firstOrNull;
    if (!widget.forPlanAction || created == null) {
      if (created != null) showDone(context, 'Rig saved');
      return;
    }
    await context.read<SessionPlanViewModel>().setEquipment(created);
    if (!mounted) return;
    showDone(context, RigInputText.savedAndChosen);
    context.pop();
  }

  /// The class-first choices in a sheet, over a list that already has rigs.
  Future<void> _showAddRig() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: _panel(close: () => Navigator.of(sheet).pop()),
        ),
      ),
    );
  }

  Widget _panel({VoidCallback? close}) => AddRigPanel(
    onByHand: (c) {
      close?.call();
      _addByHand(c);
    },
    onFromPhoto: FeatureScope.metadataImport
        ? (c) {
            close?.call();
            _importFromPhoto(c);
          }
        : null,
  );

  /// Deletes [eq] after the shared confirmation (a stored record, RD-09):
  /// saved plans keep their own copy of it (ADR-014 §4). Returns whether it
  /// was deleted.
  Future<bool> _delete(EquipmentProfile eq) async {
    final sure = await confirmDestructive(
      context,
      title: 'Delete this rig?',
      message:
          '"${eq.name}" is deleted from your rigs. Saved plans keep what '
          "they recorded. This can't be undone.",
    );
    if (!sure || !mounted) return false;
    final deleted = await runWithFeedback(
      context,
      'delete the rig',
      () => context.read<GearViewModel>().delete(eq.id),
    );
    if (!mounted) return deleted;
    if (deleted) showDone(context, 'Rig deleted');
    await _loadEquipment();
    // TD-028: clear the planner's selection if this was it.
    if (mounted) {
      await context.read<SessionPlanViewModel>().refreshSelectedEquipment();
    }
    return deleted;
  }

  Future<void> _showEquipmentDialog({EquipmentProfile? existing}) async {
    final saved = await showEquipmentEditor(
      context,
      existing: existing,
      onDelete: existing == null ? null : () => _delete(existing),
    );
    // S9.8 (D9-5): a save says so.
    if (saved != null && mounted) showDone(context, 'Rig saved');
    // Always refresh list after dialog closes.
    unawaited(_loadEquipment());
    // TD-028: pick up an edit to the currently selected equipment instead of
    // leaving the planner showing stale field values. A no-op unless the
    // edited profile is the selected one.
    if (mounted) {
      await context.read<SessionPlanViewModel>().refreshSelectedEquipment();
    }
  }

  @override
  Widget build(BuildContext context) {
    final planVm = context.watch<SessionPlanViewModel>();
    final choosing = widget.mode == ListMode.choose;

    return Scaffold(
      appBar: AppBar(
        title: Text(choosing ? AppWords.chooseRig : AppWords.rigs),
      ),
      body: _initialLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? LoadFailureView(
              action: 'load the rigs',
              error: _loadError!,
              onRetry: _loadEquipment,
            )
          : _equipment.isEmpty
          // F05 A1: the empty list offers both ways to add a rig.
          ? ListView(
              key: const Key('rigs.empty'),
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                const Text(AppWords.noRigs),
                const SizedBox(height: AppSpacing.md),
                _panel(),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _equipment.length,
              itemBuilder: (context, index) {
                final eq = _equipment[index];
                // Only when choosing: the Library describes the rigs, not
                // the plan (S9.1).
                final isSelected =
                    choosing && eq.id == planVm.selectedEquipment?.id;

                final card = Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primary.withAlpha(0),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.large),
                  ),
                  child: ListTile(
                    title: Text(
                      eq.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    subtitle: Text(_subtitle(eq)),
                    trailing: choosing
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                tooltip: AppWords.editRig,
                                onPressed: () =>
                                    _showEquipmentDialog(existing: eq),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: AppPalette.of(context).selected,
                                ),
                            ],
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: choosing
                        ? () {
                            planVm.setEquipment(eq);
                            context.pop();
                          }
                        : () => _showEquipmentDialog(existing: eq),
                  ),
                );

                return SwipeToDelete(
                  itemKey: ValueKey('eq_${eq.id}'),
                  onDelete: () => _delete(eq),
                  child: card,
                );
              },
            ),
      floatingActionButton: _equipment.isEmpty || _initialLoading
          ? null
          : FloatingActionButton.extended(
              key: const Key('rigs.add'),
              heroTag: 'rigs.add',
              onPressed: _showAddRig,
              icon: const Icon(Icons.add),
              label: const Text(AppWords.addRig),
            ),
    );
  }
}
