import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/library_viewmodels.dart';
import '../../../domain/models/camera_class.dart';
import '../../../domain/models/equipment_profile.dart';
import '../../../core/config/feature_scope.dart';
import '../../navigation/app_router.dart';
import '../../shared/app_words.dart';
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
import '../../../core/theme/app_typography.dart';
import '../../shared/collapsible_section.dart';
import '../../shared/hybrid_icon.dart';
import '../library/library_parts.dart';
import '../settings/settings_parts.dart';
import 'rig_detail_screen.dart';

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
  final _search = TextEditingController();
  String _query = '';
  bool _helpOpen = false;
  bool _initialLoading = true;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _loadEquipment();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
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

  /// The row's caption (library.js `rigSubtitle`): the camera type, the
  /// maker and model, then the sensor and optics.
  String _subtitle(EquipmentProfile eq) => [
    if (eq.cameraClass == CameraClass.unknown)
      'Camera type unknown'
    else
      eq.cameraClass.label,
    if (eq.manufacturer case final m? when m.isNotEmpty) m,
    if (eq.cameraModel case final m? when m.isNotEmpty) m,
    '${eq.resolutionWidthPx}×${eq.resolutionHeightPx} px',
    '${_trim(eq.pixelPitchUm)} µm',
    '${_trim(eq.focalLengthMm)} mm',
    eq.needsApertureReview
        ? 'f/${_trim(eq.focalRatio)} — please review'
        : 'f/${_trim(double.parse(eq.focalRatio.toStringAsFixed(2)))}',
  ].join(' · ');

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

  @override
  Widget build(BuildContext context) {
    final planVm = context.watch<SessionPlanViewModel>();
    final choosing = widget.mode == ListMode.choose;
    final p = AppPalette.of(context);
    final q = _query.trim().toLowerCase();
    bool has(String? t) => t != null && t.toLowerCase().contains(q);
    final shown = [
      for (final eq in _equipment)
        if (q.isEmpty ||
            has(eq.name) ||
            has(eq.manufacturer) ||
            has(eq.cameraModel) ||
            has(eq.cameraClass.label))
          eq,
    ];
    final quiet = AppTypography.caption.copyWith(color: p.textSecondary);
    return Scaffold(
      appBar: hybridAppBar(
        context,
        // D8 A: managed for the plan, the rig made here becomes its rig.
        title: Text(
          choosing || widget.forPlanAction ? AppWords.chooseRig : AppWords.rigs,
        ),
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
              padding: settingsPagePadding,
              children: [
                const SettingsCopy(AppWords.noRigs, primary: true),
                const SizedBox(height: AppSpacing.md),
                _panel(),
              ],
            )
          // library.js `listView` rigs: search, Add rig, the rows.
          : ListView(
              key: const Key('rigs.list'),
              padding: settingsPagePadding,
              children: [
                LibrarySearchField(
                  key: const Key('rigs.search'),
                  controller: _search,
                  label: 'Search rigs',
                  hint: 'Name, maker or model',
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: AppSpacing.itemGap),
                LibraryPrimaryAction(
                  key: const Key('rigs.add'),
                  icon: HybridIcons.plus,
                  label: AppWords.addRig,
                  onPressed: _showAddRig,
                ),
                if (q.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.itemGap),
                    child: Text(
                      '${shown.length} of ${_equipment.length} shown',
                      key: const Key('rigs.count'),
                      style: quiet,
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                for (final eq in shown)
                  SwipeToDelete(
                    itemKey: ValueKey('eq_${eq.id}'),
                    onDelete: () =>
                        deleteRig(context, eq, reload: _loadEquipment),
                    child: LibraryRow(
                      key: Key('rigs.row.${eq.id}'),
                      title: eq.name,
                      caption: _subtitle(eq),
                      note: [
                        if (eq.isExample) ExampleText.rig,
                        // Only when choosing: the Library describes the
                        // rigs, not the plan (S9.1).
                        if (choosing && eq.id == planVm.selectedEquipment?.id)
                          'Chosen for this plan',
                      ].join(' · ').ifEmpty,
                      onTap: choosing
                          ? () {
                              planVm.setEquipment(eq);
                              context.pop();
                            }
                          : () => _open(eq),
                    ),
                  ),
                if (shown.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SettingsCopy('Nothing matches “${_query.trim()}”.'),
                        const SizedBox(height: AppSpacing.sm),
                        OutlinedButton(
                          key: const Key('rigs.clearSearch'),
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                          child: const Text('Clear search'),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: CollapsibleSection(
                    key: const Key('rigs.fromPhotoHelp'),
                    sectionKey: 'library.rigsFromPhoto',
                    title: 'Adding a rig from a photo',
                    open: _helpOpen,
                    onToggle: () => setState(() => _helpOpen = !_helpOpen),
                    child: const SettingsCopy(
                      'Add rig offers From a photo: a JPEG, HEIC or DNG file '
                      '(or a FITS sub-frame) is read on this device and its '
                      'values are proposed for you to confirm; other RAW '
                      'files (CR3, NEF, ARW …) are not read, and nothing is '
                      'guessed. Entering a rig by hand is always available.',
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// The rig's record (library.js detail), over the list.
  Future<void> _open(EquipmentProfile eq) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => RigDetailScreen(rig: eq)));
    if (mounted) await _loadEquipment();
  }
}

extension on String {
  /// Null for an empty string (an optional note).
  String? get ifEmpty => isEmpty ? null : this;
}
