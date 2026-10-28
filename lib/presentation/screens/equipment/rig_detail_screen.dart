import 'package:flutter/material.dart';

import '../../shared/document_section.dart';

import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../core/utils/quantity_text.dart';
import '../../../domain/models/camera_class.dart';
import '../../../domain/models/equipment_profile.dart';
import '../../shared/collapsible_section.dart';
import '../../shared/confirmation_patterns.dart';
import '../../shared/delete_patterns.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/field_mode_button.dart';
import '../../shared/hybrid_app_bar.dart';
import '../../shared/hybrid_icon.dart';
import '../../shared/rig_input_text.dart';
import '../../viewmodels/library_viewmodels.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../library/library_parts.dart';
import '../settings/settings_parts.dart';
import 'equipment_editor.dart';

/// Deletes [rig] after the shared confirmation (a stored record, RD-09):
/// saved plans keep their own copy of it (ADR-014 §4); Undo restores it and
/// the plan's choice. [reload] runs after either. Returns whether it was
/// deleted.
Future<bool> deleteRig(
  BuildContext context,
  EquipmentProfile rig, {
  Future<void> Function()? reload,
}) async {
  final sure = await confirmDestructive(
    context,
    title: 'Delete this rig?',
    message:
        '“${rig.name}” is deleted from your rigs. Saved plans keep what '
        'they recorded. Undo is offered right after.',
  );
  if (!sure || !context.mounted) return false;
  final gear = context.read<GearViewModel>();
  final plan = context.read<SessionPlanViewModel>();
  final restoreSelection = plan.rememberEquipmentForUndo(rig.id);
  return deleteWithUndoFeedback(
    context,
    action: 'delete the rig',
    message: 'Rig deleted',
    remove: () => gear.deleteWithUndo(rig.id),
    afterDelete: () async {
      await plan.refreshSelectedEquipment();
      await reload?.call();
    },
    afterRestore: () async {
      await restoreSelection();
      await reload?.call();
    },
  );
}

/// One rig, read-only (library.js `detailView` rig): what it is, its
/// camera and optics, every value with its source one tap away, then Edit
/// rig first and Delete rig last. Nothing here selects it for the plan.
class RigDetailScreen extends StatefulWidget {
  const RigDetailScreen({super.key, required this.rig});

  final EquipmentProfile rig;

  @override
  State<RigDetailScreen> createState() => _RigDetailScreenState();
}

class _RigDetailScreenState extends State<RigDetailScreen> {
  late EquipmentProfile _rig = widget.rig;
  bool _fullOpen = false;

  Future<void> _reload() async {
    final all = await context.read<GearViewModel>().all();
    final now = all.where((r) => r.id == _rig.id).firstOrNull;
    if (!mounted) return;
    if (now == null) {
      Navigator.of(context).pop();
    } else {
      setState(() => _rig = now);
    }
  }

  Future<void> _edit() async {
    final saved = await showEquipmentEditor(context, existing: _rig);
    if (!mounted) return;
    // S9.8 (D9-5): a save says so.
    if (saved != null) showDone(context, 'Rig saved');
    await _reload();
    // TD-028: the plan's rig shows the edit.
    if (mounted) {
      await context.read<SessionPlanViewModel>().refreshSelectedEquipment();
    }
  }

  /// At most two decimals, no trailing zeros ("48.21", "135", "3.76").
  static String _n(double v) {
    final r = double.parse(v.toStringAsFixed(2));
    return r == r.roundToDouble() ? r.toInt().toString() : r.toString();
  }

  @override
  Widget build(BuildContext context) {
    final r = _rig;
    final p = AppPalette.of(context);
    final caption = AppTextTheme.of(context)
        .resolve(AppTextTheme.of(context).caption, AppTextGeometry.standard)
        .copyWith(color: p.textSecondary);
    final camera = r.cameraClass == CameraClass.unknown
        ? 'Unknown'
        : r.cameraClass.label;
    final resolution = '${r.resolutionWidthPx} × ${r.resolutionHeightPx} px';
    final pixel = '${_n(r.pixelPitchUm)} µm';
    final sensor = '${_n(r.sensorWidthMm)} × ${_n(r.sensorHeightMm)} mm';
    final ratio = 'f/${_n(r.focalRatio)}';
    Widget heading(String text, {bool small = false}) => Padding(
      padding: EdgeInsets.only(
        top: small ? AppSpacing.itemGap : 0,
        bottom: AppSpacing.xs,
      ),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: small
              ? AppTextTheme.of(context).itemTitle
                    .copyWith(color: p.textPrimary)
              : AppTextTheme.of(context).sectionHeading
                    .copyWith(color: p.textPrimary),
        ),
      ),
    );
    return Scaffold(
      appBar: hybridAppBar(
        context,
        title: Text(r.name),
        actions: const [FieldModeButton()],
      ),
      body: ListView(
        key: const Key('rigDetail.scroll'),
        padding: settingsPagePadding,
        children: [
          DocumentSection(
            key: const Key('rigDetail.identityGroup'),
            children: [
              LibraryRecordHeader(
                caption: r.isExample
                    ? 'Example rig · not a measurement'
                    : 'Your rig · editable',
                action: LibraryPrimaryAction(
                  key: const Key('rigDetail.edit'),
                  icon: HybridIcons.edit,
                  label: 'Edit rig',
                  onPressed: _edit,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DocumentSection(
            key: const Key('rigDetail.cameraGroup'),
            children: [
              heading('Camera'),
              FactRows(key: const Key('rigDetail.camera'), [
                ('Camera type', camera, null),
                if (r.manufacturer case final m? when m.isNotEmpty)
                  ('Manufacturer', m, null),
                if (r.cameraModel case final m? when m.isNotEmpty)
                  ('Model', m, null),
                ('Resolution', resolution, null),
                ('Pixel size', pixel, null),
                ('Sensor size', sensor, null),
              ]),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DocumentSection(
            key: const Key('rigDetail.opticsGroup'),
            children: [
              heading('Optics'),
              FactRows(key: const Key('rigDetail.optics'), [
                ('Effective focal length', '${_n(r.focalLengthMm)} mm', null),
                (
                  'Focal ratio',
                  ratio,
                  r.needsApertureReview ? 'Above f/32 · please review' : null,
                ),
                if (r.apertureDiameterMm case final d?)
                  ('Aperture diameter', '${_n(d)} mm', null),
                ('Tracking', r.trackingType.label, null),
              ]),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DocumentSection(
            key: const Key('rigDetail.sourcesGroup'),
            children: [
              Padding(
                padding: EdgeInsets.zero,
                child: CollapsibleSection(
                  key: const Key('rigDetail.full'),
                  topRule: false,
                  sectionKey: 'library.rigRecord',
                  title: 'Full rig record and sources',
                  summary: 'All values, including unknowns',
                  open: _fullOpen,
                  onToggle: () => setState(() => _fullOpen = !_fullOpen),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      heading('Camera', small: true),
                      FactRows([
                        (
                          'Camera type',
                          camera,
                          r.cameraClass == CameraClass.unknown
                              ? 'The app does not work out sensor facts from the '
                                    'type.'
                              : null,
                        ),
                        (
                          'Manufacturer',
                          r.manufacturer ?? 'Not recorded',
                          null,
                        ),
                        ('Model', r.cameraModel ?? 'Not recorded', null),
                        if (r.cameraClass.offersInCameraNoiseReduction)
                          (
                            'In-camera noise reduction',
                            r.inCameraNoiseReduction
                                ? 'On: a dark as long as each light'
                                : 'Off',
                            null,
                          ),
                        ('Resolution', resolution, null),
                        ('Pixel size', pixel, null),
                        ('Sensor size', sensor, null),
                      ]),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Camera specs: '
                        '${RigInputText.source(r.cameraSource, r.cameraConfidence)}',
                        style: caption,
                      ),
                      heading('Optics', small: true),
                      FactRows([
                        (
                          'Effective focal length',
                          '${_n(r.focalLengthMm)} mm',
                          null,
                        ),
                        (
                          'Focal ratio',
                          ratio,
                          r.apertureDiameterMm != null
                              ? 'From focal length ÷ diameter'
                              : null,
                        ),
                        (
                          'Aperture diameter',
                          switch (r.apertureDiameterMm) {
                            final d? => '${_n(d)} mm',
                            null => 'Not recorded',
                          },
                          null,
                        ),
                        (
                          'Tracking (default for plans)',
                          r.trackingType.label,
                          'A plan may override it.',
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Optics: '
                        '${RigInputText.source(r.opticsSource, r.opticsConfidence)}',
                        style: caption,
                      ),
                      heading('Optional records', small: true),
                      FactRows([
                        (
                          'Maximum sub-exposure',
                          switch (r.maxExposureS) {
                            final s? => '${_n(s)} s',
                            null => 'Not recorded',
                          },
                          null,
                        ),
                        (
                          'Average RAW file size',
                          switch (r.averageRawFileSizeMB) {
                            final mb? => QuantityText.storage(mb * 1e6),
                            null => 'Not recorded',
                          },
                          'A measured size; empty leaves the storage estimate '
                              'theoretical.',
                        ),
                        (
                          'Capture format',
                          switch (r.captureFormat) {
                            final f? => RigInputText.captureFormat(f),
                            null => 'Not recorded',
                          },
                          null,
                        ),
                        (
                          'Rotation',
                          switch (r.rotationDeg) {
                            final d? => QuantityText.degrees(
                              d,
                              digits: d == d.roundToDouble() ? 0 : 2,
                            ),
                            null => 'Not recorded',
                          },
                          null,
                        ),
                      ]),
                      if (r.metadataMake != null ||
                          r.metadataModel != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Imported from a file: '
                          '${[?r.metadataMake, ?r.metadataModel].join(' ')}',
                          style: caption,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LibraryDeleteAction(
            key: const Key('rigDetail.delete'),
            label: 'Delete rig',
            onPressed: () async {
              final navigator = Navigator.of(context);
              if (await deleteRig(context, _rig) && mounted) navigator.pop();
            },
          ),
        ],
      ),
    );
  }
}
