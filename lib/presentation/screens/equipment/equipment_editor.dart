import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';

import '../../../domain/models/camera_class.dart';
import '../../../domain/models/capture_evidence.dart';
import '../../../domain/models/equipment_limits.dart';
import '../../../domain/models/equipment_profile.dart';
import '../../../domain/models/spec_confidence.dart';
import '../../../domain/models/spec_provenance.dart';
import '../../../domain/models/tracking_type.dart';
import '../../shared/app_words.dart';
import '../../shared/collapsible_section.dart';
import '../../shared/confirmation_patterns.dart';
import '../../shared/delete_patterns.dart';
import '../../shared/equipment_draft.dart';
import '../../shared/equipment_form_input.dart';
import '../../shared/equipment_import_text.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/rig_input_text.dart';
import '../../viewmodels/library_viewmodels.dart';

/// The rig editor's "More (optional)" section key (S7.6); its open state
/// lives in the dialog and is not remembered.
const rigEditorMoreSection = 'rigEditor.more';

/// The rig editor (S3.5): Add, Edit, or a draft pre-filled from a metadata
/// import (ADR-018 §2). Every value is built by [EquipmentDraft]; this dialog
/// holds only controllers and layout. Returns the saved rig's id, or null
/// when nothing was saved. Nothing is written unless the user presses Save.
/// A changed editor asks before Back or a tap outside discards it (F05 A6,
/// UXA-C4); an unchanged one closes at once.
Future<int?> showEquipmentEditor(
  BuildContext context, {
  EquipmentProfile? existing,
  EquipmentDraft? draft,
  Future<bool> Function()? onDelete,
}) => _EquipmentEditor(
  draft ?? EquipmentDraft.fromProfile(existing),
  onDelete,
).show(context);

class _EquipmentEditor {
  _EquipmentEditor(this.form, this.onDelete);

  final EquipmentDraft form;

  /// The visible Delete of a saved rig (S9.1; RD-09 = M + S1): confirms,
  /// deletes, and returns whether it did; the editor then closes.
  final Future<bool> Function()? onDelete;

  static String _trim(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';

  static String _confidence(SpecConfidence? c) => switch (c) {
    SpecConfidence.verified => 'verified',
    SpecConfidence.reported => 'reported',
    SpecConfidence.estimated => 'estimated',
    null => 'source unknown',
  };

  static String _named(SpecProvenance? p) => p == null
      ? _confidence(null)
      : '${_confidence(p.confidence)}'
            '${p.source == null ? '' : ' (${p.source})'}';

  /// Where the specs came from (ADR-008 §6, TASK 8.5), read per spec
  /// (ADR-018 §5; S3.V7, S3S-01): one phrase for a group whose specs share
  /// a provenance, else one per spec. Never the group pair alone, which is
  /// `user` on an imported rig whose values the user did not type.
  static String _provenance(EquipmentProfile eq) =>
      '${_group(eq, camera: true)} · ${_group(eq, camera: false)}';

  static String _group(EquipmentProfile eq, {required bool camera}) {
    final specs = eq.groupProvenance(camera: camera);
    if ({for (final (_, p) in specs) p}.length == 1) {
      return '${camera ? 'Camera specs' : 'Optics'}: ${_named(specs.first.$2)}';
    }
    return [
      for (final (spec, p) in specs)
        '${EquipmentImportText.spec(spec)}: ${_named(p)}',
    ].join(' · ');
  }

  static final _decimal = const TextInputType.numberWithOptions(decimal: true);

  /// The "More (optional)" summary: what is set, in words (S7.6).
  static String _moreSummary(
    String maxExposure,
    String raw,
    String rotation,
    CaptureFormat? format,
  ) {
    final set = [
      if (maxExposure.trim().isNotEmpty) 'maximum ${maxExposure.trim()} s',
      if (raw.trim().isNotEmpty) 'RAW ${raw.trim()} MB',
      if (format != null) captureFormatLabel(format),
      if (rotation.trim().isNotEmpty) 'rotation ${rotation.trim()}°',
    ];
    return set.isEmpty
        ? 'Maximum exposure, RAW size, format, rotation: not set'
        : set.join(' · ');
  }

  /// A capture format in words (ADR-021 C7).
  static String captureFormatLabel(CaptureFormat f) => switch (f) {
    CaptureFormat.dngUncompressed16 => 'Uncompressed DNG, 16-bit',
    CaptureFormat.fits16 => 'FITS, 16-bit integer',
    CaptureFormat.fits32float => 'FITS, 32-bit float',
    CaptureFormat.compressedRaw => 'Compressed RAW (CR3, NEF, ARW …)',
    CaptureFormat.jpegHeic => 'JPEG or HEIC',
  };

  /// ADR-011 §6: a stored focal ratio above f/32 is shown for review, never
  /// converted. The f/ field's own bounds make the user fix it on save.
  static Widget _reviewBanner(BuildContext context, EquipmentProfile eq) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Please review: the stored focal ratio is '
        'f/${_trim(eq.focalRatio)}, above f/32. It may be an aperture '
        'diameter typed into the f/ field. Enter the focal ratio, or the '
        'diameter in mm.',
        style: TextStyle(color: scheme.onErrorContainer),
      ),
    );
  }

  Future<int?> show(BuildContext context) async {
    final existing = form.existing;
    final isEdit = existing != null;
    final formKey = GlobalKey<FormState>();

    final t = form.initial;
    final nameCtrl = TextEditingController(text: t.name);
    final manufacturerCtrl = TextEditingController(text: t.manufacturer);
    final cameraModelCtrl = TextEditingController(text: t.cameraModel);
    final resWCtrl = TextEditingController(text: t.resolutionWidth);
    final resHCtrl = TextEditingController(text: t.resolutionHeight);
    final pixelCtrl = TextEditingController(text: t.pixelPitch);
    final sensorWCtrl = TextEditingController(text: t.sensorWidth);
    final sensorHCtrl = TextEditingController(text: t.sensorHeight);
    final focalCtrl = TextEditingController(text: t.focalLength);
    final apertureCtrl = TextEditingController(text: t.focalRatio);
    final diameterCtrl = TextEditingController(text: t.diameter);
    final averageRawFileSizeMBCtrl = TextEditingController(text: t.rawFileSize);
    final rotationCtrl = TextEditingController(text: t.rotation);
    final maxExposureCtrl = TextEditingController(text: t.maxExposure);
    var trackingType = form.trackingType;
    var cameraClass = form.cameraClass;
    var noiseReduction = form.inCameraNoiseReduction;
    // ADR-021 C7 (F07): the format the user declares, for a theoretical
    // size; a file's format is never set from here.
    var captureFormat = form.existing?.captureFormat;
    String? apertureError;
    int? savedId;

    EquipmentFormTexts currentTexts() => EquipmentFormTexts(
      name: nameCtrl.text,
      manufacturer: manufacturerCtrl.text,
      cameraModel: cameraModelCtrl.text,
      resolutionWidth: resWCtrl.text,
      resolutionHeight: resHCtrl.text,
      pixelPitch: pixelCtrl.text,
      sensorWidth: sensorWCtrl.text,
      sensorHeight: sensorHCtrl.text,
      focalLength: focalCtrl.text,
      focalRatio: apertureCtrl.text,
      diameter: diameterCtrl.text,
      rawFileSize: averageRawFileSizeMBCtrl.text,
      rotation: rotationCtrl.text,
      maxExposure: maxExposureCtrl.text,
    );

    /// Whether anything differs from what the editor opened with (F05 A6).
    bool changed() =>
        !currentTexts().sameAs(t) ||
        trackingType != form.trackingType ||
        cameraClass != form.cameraClass ||
        noiseReduction != form.inCameraNoiseReduction ||
        captureFormat != form.existing?.captureFormat;

    /// Why a required input is asked for (F05 A3; ADR-021 C20).
    Widget reasonNote(BuildContext context, EquipmentSpec spec) => Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        RigInputText.reason(spec),
        key: Key('rigEditor.reason.${spec.name}'),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );

    /// ADR-018 §4, §7: where a pre-filled value came from, while unchanged.
    Widget prefillNote(BuildContext context, EquipmentSpec spec) {
      final p = form.unchangedPrefill(spec, currentTexts());
      if (p == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          PrefillText.note(p),
          key: Key('editor.prefill.${spec.name}'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    /// Whether a value in the "More" section is invalid (S7.6): a closed
    /// section's fields are not validated by the form, so Save opens it.
    bool moreInvalid() =>
        EquipmentFormInput.optional(EquipmentLimits.maxExposureS, 's')(
              maxExposureCtrl.text,
            ) !=
            null ||
        EquipmentFormInput.optional(EquipmentLimits.rawFileSizeMB, 'MB')(
              averageRawFileSizeMBCtrl.text,
            ) !=
            null ||
        EquipmentFormInput.optional(EquipmentLimits.rotationDeg, '°')(
              rotationCtrl.text,
            ) !=
            null;
    // Open when the draft pre-fills a value in it (the RAW size from a
    // DNG), so the value and its origin show (ADR-018 §4, §7).
    var moreOpen = form.prefilled.containsKey(EquipmentSpec.rawFileSize);

    /// With a diameter, the focal ratio is derived: N = f / D (ADR-011 §4).
    void deriveFocalRatio() {
      final focal = EquipmentFormInput.parse(focalCtrl.text);
      final diameter = EquipmentFormInput.parse(diameterCtrl.text);
      if (focal != null && diameter != null && diameter > 0) {
        apertureCtrl.text = (focal / diameter).toStringAsFixed(2);
      }
    }

    /// The sensor size from resolution × pixel pitch (the form model).
    void autoSensorSize() {
      final size = EquipmentDraft.sensorSizeText(
        resWCtrl.text,
        resHCtrl.text,
        pixelCtrl.text,
      );
      if (size != null) {
        sensorWCtrl.text = size.width;
        sensorHCtrl.text = size.height;
      }
    }

    /// Save (S7.6: the primary button), also offered by the discard prompt.
    Future<void> save(BuildContext context, StateSetter setDialogState) async {
      if (!moreOpen && moreInvalid()) {
        setDialogState(() => moreOpen = true);
        await WidgetsBinding.instance.endOfFrame;
        if (!context.mounted) return;
      }
      if (!formKey.currentState!.validate()) return;
      final name = nameCtrl.text.trim();
      if (name.isEmpty) return;
      final gear = context.read<GearViewModel>();
      // S3.5: the form model builds the profile and its
      // provenance (TASK 8.5, ADR-018 §5).
      final result = form.build(
        currentTexts(),
        trackingType,
        cameraClass: cameraClass,
        inCameraNoiseReduction: noiseReduction,
        captureFormat: () => captureFormat,
      );
      final recorded = result.profile;
      if (recorded == null) {
        setDialogState(
          () => apertureError = EquipmentFormInput.apertureMessage(
            result.apertureProblem!,
          ),
        );
        return;
      }
      int? id;
      final saved = await runWithFeedback(context, 'save the rig', () async {
        if (isEdit) {
          await gear.update(recorded);
          id = recorded.id;
        } else {
          id = await gear.add(recorded);
        }
      });
      // A failed save keeps the editor and its edits open (F05 A5).
      if (!saved) return;
      savedId = id;
      if (context.mounted) Navigator.of(context).pop();
    }

    /// Back or a tap outside (F05 A6): an unchanged editor closes; a changed
    /// one asks first, the site editor's prompt (TD-084).
    Future<void> leave(BuildContext context, StateSetter setDialogState) async {
      if (!changed()) {
        Navigator.of(context).pop();
        return;
      }
      final label = nameCtrl.text.trim().isEmpty
          ? (isEdit ? existing.name : AppWords.addRig)
          : nameCtrl.text.trim();
      final choice = await askUnsavedChanges(context, plan: label);
      if (!context.mounted) return;
      switch (choice) {
        case UnsavedChoice.cancel:
          return;
        case UnsavedChoice.discard:
          Navigator.of(context).pop();
        case UnsavedChoice.save:
          await save(context, setDialogState);
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) leave(context, setDialogState);
              },
              child: AlertDialog(
                // S7.6: the glossary words; "Equipment profile" is retired.
                title: Text(isEdit ? AppWords.editRig : AppWords.addRig),
                // Constrain width on larger screens. `sizeOf`, not `of`: the
                // form must not rebuild on every frame of the keyboard's
                // inset animation (S10.3; 08 §22).
                content: SizedBox(
                  width: min(MediaQuery.sizeOf(context).width * 0.9, 480),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Profile Identity ────────────────────────────
                          TextFormField(
                            controller: nameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Rig name',
                              hintText: 'e.g. ASI2600MC + 400 mm refractor',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: manufacturerCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Manufacturer',
                                    hintText: 'e.g. ZWO',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: cameraModelCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Model',
                                    hintText: 'e.g. ASI2600MC',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // S7.2a (ADR-020 §2): the user's choice, never
                          // inferred; it decides the capture settings offered.
                          DropdownButtonFormField<CameraClass>(
                            key: const Key('equipmentEditor.cameraClass'),
                            initialValue: cameraClass,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Camera type',
                            ),
                            items: [
                              for (final c in CameraClass.values)
                                DropdownMenuItem(
                                  value: c,
                                  child: Text(c.label),
                                ),
                            ],
                            onChanged: (c) {
                              if (c != null) {
                                setDialogState(() => cameraClass = c);
                              }
                            },
                          ),
                          // S7.3b (ADR-020 §8): the user's statement of a
                          // camera setting, off by default; offered only where
                          // a camera takes a dark per frame. A stored value is
                          // kept for other types, and ignored.
                          if (cameraClass.offersInCameraNoiseReduction)
                            SwitchListTile(
                              key: const Key('equipmentEditor.noiseReduction'),
                              contentPadding: EdgeInsets.zero,
                              title: const Text('In-camera noise reduction'),
                              subtitle: const Text(
                                'Long-exposure noise reduction: the camera '
                                'takes a dark as long as each light. The plan '
                                'counts that time.',
                              ),
                              value: noiseReduction,
                              onChanged: (v) =>
                                  setDialogState(() => noiseReduction = v),
                            ),
                          const SizedBox(height: 20),
                          // ── Sensor Section (Stellarium layout) ──────────
                          Text(
                            'Camera sensor',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                          ),
                          const SizedBox(height: 8),
                          // Resolution W × H px
                          _StellariumRow(
                            label: 'Resolution',
                            unit: 'px',
                            fieldW: TextFormField(
                              controller: resWCtrl,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              onChanged: (_) => setDialogState(autoSensorSize),
                              decoration: const InputDecoration(
                                hintText: '6248',
                              ),
                              validator: EquipmentFormInput.validateResolution,
                            ),
                            fieldH: TextFormField(
                              controller: resHCtrl,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              onChanged: (_) => setDialogState(autoSensorSize),
                              decoration: const InputDecoration(
                                hintText: '4176',
                              ),
                              validator: EquipmentFormInput.validateResolution,
                            ),
                          ),
                          reasonNote(context, EquipmentSpec.resolution),
                          prefillNote(context, EquipmentSpec.resolution),
                          const SizedBox(height: 8),
                          // S7.6 (UX-22): the pixel size is asked once (square
                          // pixels); it was two fields on one controller.
                          TextFormField(
                            key: const Key('equipmentEditor.pixelSize'),
                            controller: pixelCtrl,
                            keyboardType: _decimal,
                            onChanged: (_) => setDialogState(autoSensorSize),
                            decoration: const InputDecoration(
                              labelText: 'Pixel size (µm)',
                              hintText: '3.76',
                              helperText: 'Square pixels: one value',
                            ),
                            validator: EquipmentFormInput.required(
                              EquipmentLimits.pixelPitchUm,
                              'µm',
                            ),
                          ),
                          const SizedBox(height: 8),
                          // S3.V8: a saved rig's pixel size of another
                          // output mode was not copied; say why while empty.
                          if (form.withheldFromSavedRig case final w?
                              when pixelCtrl.text.trim().isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                PrefillText.withheld(w),
                                key: const Key('editor.withheld'),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          reasonNote(context, EquipmentSpec.pixelPitch),
                          prefillNote(context, EquipmentSpec.pixelPitch),
                          // Sensor Size W × H mm — auto-calculated
                          _StellariumRow(
                            label: 'Sensor size',
                            unit: 'mm',
                            fieldW: TextFormField(
                              controller: sensorWCtrl,
                              readOnly: true,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textAlign: TextAlign.center,
                              // S11.C2 (S11H-01): a derived value, in the
                              // secondary text role (AA), not the disabled one.
                              style: TextStyle(
                                color: AppPalette.of(context).textSecondary,
                              ),
                              decoration: const InputDecoration(
                                hintText: '23.50',
                                filled: true,
                              ),
                              validator: EquipmentFormInput.required(
                                EquipmentLimits.sensorSideMm,
                                'mm',
                              ),
                            ),
                            fieldH: TextFormField(
                              controller: sensorHCtrl,
                              readOnly: true,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textAlign: TextAlign.center,
                              // S11.C2 (S11H-01): a derived value, in the
                              // secondary text role (AA), not the disabled one.
                              style: TextStyle(
                                color: AppPalette.of(context).textSecondary,
                              ),
                              decoration: const InputDecoration(
                                hintText: '15.70',
                                filled: true,
                              ),
                              validator: EquipmentFormInput.required(
                                EquipmentLimits.sensorSideMm,
                                'mm',
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Auto-calculated from resolution × pixel size',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppPalette.of(context).textTertiary,
                                ),
                          ),
                          reasonNote(context, EquipmentSpec.sensorSize),
                          prefillNote(context, EquipmentSpec.sensorSize),
                          const SizedBox(height: 12),
                          // Bit Depth removed
                          const SizedBox(height: 20),
                          Text(
                            'Optics',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                          ),
                          const SizedBox(height: 8),
                          if (existing?.needsApertureReview ?? false)
                            _reviewBanner(context, existing!),
                          if (existing != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                _provenance(existing),
                                key: const Key('editor.provenance'),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          TextFormField(
                            controller: focalCtrl,
                            keyboardType: _decimal,
                            onChanged: (_) => setDialogState(deriveFocalRatio),
                            decoration: const InputDecoration(
                              labelText: 'Effective focal length (mm)',
                            ),
                            validator: EquipmentFormInput.required(
                              EquipmentLimits.focalLengthMm,
                              'mm',
                            ),
                          ),
                          reasonNote(context, EquipmentSpec.focalLength),
                          prefillNote(context, EquipmentSpec.focalLength),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: apertureCtrl,
                                  onChanged: (_) => setDialogState(() {}),
                                  // ADR-011 §4: with a diameter, N = f / D.
                                  readOnly: diameterCtrl.text.trim().isNotEmpty,
                                  keyboardType: _decimal,
                                  decoration: InputDecoration(
                                    labelText: 'Focal ratio (f/)',
                                    helperText:
                                        diameterCtrl.text.trim().isNotEmpty
                                        ? 'From focal length ÷ diameter'
                                        : null,
                                  ),
                                  validator: diameterCtrl.text.trim().isNotEmpty
                                      ? null
                                      : EquipmentFormInput.required(
                                          EquipmentLimits.focalRatio,
                                          '',
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: diameterCtrl,
                                  keyboardType: _decimal,
                                  onChanged: (_) =>
                                      setDialogState(deriveFocalRatio),
                                  decoration: const InputDecoration(
                                    labelText: 'Aperture diameter (mm)',
                                    hintText: 'Optional',
                                  ),
                                  validator: EquipmentFormInput.optional(
                                    EquipmentLimits.apertureDiameterMm,
                                    'mm',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          reasonNote(context, EquipmentSpec.focalRatio),
                          prefillNote(context, EquipmentSpec.focalRatio),
                          if (apertureError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                apertureError!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<TrackingType>(
                            initialValue: trackingType,
                            // S3.10: the chosen label wraps inside the field
                            // instead of overflowing on a phone at large text.
                            isExpanded: true,
                            decoration: const InputDecoration(
                              // S7.1 (RD-08 = T3): a plan may override it.
                              labelText: 'Tracking (default for plans)',
                            ),
                            items: [
                              for (final t in TrackingType.values)
                                DropdownMenuItem(
                                  value: t,
                                  child: Text(t.label),
                                ),
                            ],
                            onChanged: (t) {
                              if (t != null) trackingType = t;
                            },
                          ),
                          const SizedBox(height: 12),
                          // S7.6 (UX-22): the rare values one tap away, their
                          // meaning unchanged; the summary states what is set
                          // (rebuilt only by these three fields' typing).
                          ListenableBuilder(
                            listenable: Listenable.merge([
                              maxExposureCtrl,
                              averageRawFileSizeMBCtrl,
                              rotationCtrl,
                            ]),
                            builder: (context, _) => CollapsibleSection(
                              sectionKey: rigEditorMoreSection,
                              open: moreOpen,
                              onToggle: () =>
                                  setDialogState(() => moreOpen = !moreOpen),
                              title: 'More (optional)',
                              summary: _moreSummary(
                                maxExposureCtrl.text,
                                averageRawFileSizeMBCtrl.text,
                                rotationCtrl.text,
                                captureFormat,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: maxExposureCtrl,
                                    keyboardType: _decimal,
                                    decoration: const InputDecoration(
                                      labelText: 'Maximum sub-exposure (s)',
                                      hintText:
                                          'Optional — your mount/guiding limit',
                                    ),
                                    validator: EquipmentFormInput.optional(
                                      EquipmentLimits.maxExposureS,
                                      's',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: averageRawFileSizeMBCtrl,
                                    onChanged: (_) => setDialogState(() {}),
                                    keyboardType: _decimal,
                                    decoration: const InputDecoration(
                                      labelText: 'Average RAW file size (MB)',
                                      hintText: 'e.g. 50.0',
                                    ),
                                    validator: EquipmentFormInput.optional(
                                      EquipmentLimits.rawFileSizeMB,
                                      'MB',
                                    ),
                                  ),
                                  prefillNote(
                                    context,
                                    EquipmentSpec.rawFileSize,
                                  ),
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<CaptureFormat?>(
                                    key: const Key('rigEditor.captureFormat'),
                                    initialValue: captureFormat,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Capture format (optional)',
                                      helperText:
                                          'Gives a theoretical file size when no file is measured; '
                                          'compressed formats have none.',
                                      helperMaxLines: 3,
                                    ),
                                    items: [
                                      const DropdownMenuItem(
                                        value: null,
                                        child: Text('Not set'),
                                      ),
                                      for (final f in CaptureFormat.values)
                                        DropdownMenuItem(
                                          value: f,
                                          child: Text(captureFormatLabel(f)),
                                        ),
                                    ],
                                    onChanged: (f) =>
                                        setDialogState(() => captureFormat = f),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: rotationCtrl,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                          signed: true,
                                        ),
                                    decoration: const InputDecoration(
                                      labelText: 'Rotation (°)',
                                      hintText: 'Optional',
                                    ),
                                    validator: EquipmentFormInput.optional(
                                      EquipmentLimits.rotationDeg,
                                      '°',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  if (onDelete case final delete?)
                    DeleteButton(
                      key: const Key('rigEditor.delete'),
                      tooltip: 'Delete rig',
                      onPressed: () async {
                        if (await delete() && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  // S7.6 (DESIGN_SYSTEM §9): Save is the primary button.
                  FilledButton(
                    key: const Key('rigEditor.save'),
                    onPressed: () => save(context, setDialogState),
                    child: const Text(AppWords.save),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    return savedId;
  }
}

/// A Stellarium-style row: the label, then [FieldW] × [FieldH] Unit.
class _StellariumRow extends StatelessWidget {
  const _StellariumRow({
    required this.label,
    required this.unit,
    required this.fieldW,
    required this.fieldH,
  });

  final String label;
  final String unit;
  final Widget fieldW;
  final Widget fieldH;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // S3.10 (TD-069): the label sits above the W × H fields, so the fields
    // get the dialog's whole width. Beside a fixed 90 dp label they were
    // too narrow on a phone, and the read-only sensor fields clipped
    // "9.89" to "9.8".
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: fieldW),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text('×', style: theme.textTheme.titleMedium),
            ),
            Expanded(child: fieldH),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(unit, style: theme.textTheme.bodySmall),
            ),
          ],
        ),
      ],
    );
  }
}
