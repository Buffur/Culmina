import 'package:flutter/material.dart';

import '../../shared/document_section.dart';

import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

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
import '../../shared/hybrid_app_bar.dart';
import '../../shared/hybrid_parts.dart';
import '../library/library_parts.dart';
import '../settings/settings_parts.dart';
import '../../shared/equipment_draft.dart';
import '../../shared/equipment_form_input.dart';
import '../../shared/equipment_import_text.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/rig_input_text.dart';
import '../../viewmodels/library_viewmodels.dart';

/// The rig editor's "More (optional)" section key (S7.6); its open state
/// lives in the dialog and is not remembered.
const rigEditorMoreSection = 'rigEditor.more';

/// The rig editor (S3.5; library.js `rigForm`): Add, Edit, or a draft
/// pre-filled from a metadata import (ADR-018 §2), on a page of its own.
/// Every value is built by [EquipmentDraft]; this page holds only
/// controllers and layout. Returns the saved rig's id, or null when nothing
/// was saved. Nothing is written unless the user presses Save rig. A
/// changed editor asks before Back discards it (F05 A6, UXA-C4); an
/// unchanged one closes at once. Delete is on the rig's record (S9.1).
Future<int?> showEquipmentEditor(
  BuildContext context, {
  EquipmentProfile? existing,
  EquipmentDraft? draft,
}) =>
    _EquipmentEditor(draft ?? EquipmentDraft.fromProfile(existing))
        .show(context);

class _EquipmentEditor {
  _EquipmentEditor(this.form);

  final EquipmentDraft form;

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
      // The fields' own text, as typed (not a formatted quantity).
      if (raw.trim().isNotEmpty) 'RAW ${raw.trim()} MB', // as typed
      if (format != null) captureFormatLabel(format),
      if (rotation.trim().isNotEmpty)
        'rotation ${rotation.trim()}°', // as typed
    ];
    return set.isEmpty
        ? 'Maximum exposure, RAW size, format, rotation: not set'
        : set.join(' · ');
  }

  /// A capture format in words (ADR-021 C7).
  static String captureFormatLabel(CaptureFormat f) =>
      RigInputText.captureFormat(f);

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
        style: AppTypography.caption.copyWith(
          height: 1.55,
          color: AppPalette.of(context).textSecondary,
        ),
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
          style: AppTypography.caption.copyWith(
            height: 1.55,
            color: AppPalette.of(context).textSecondary,
          ),
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

    /// Back or Cancel (F05 A6): an unchanged editor closes; a changed one
    /// asks first, the site editor's prompt (TD-084).
    Future<void> leave(BuildContext context, StateSetter setDialogState) async {
      if (!changed()) {
        Navigator.of(context).pop();
        return;
      }
      final label = nameCtrl.text.trim().isEmpty
          ? (isEdit ? existing.name : AppWords.addRig)
          : nameCtrl.text.trim();
      final choice = await askUnsavedChanges(
        context,
        plan: label,
        library: true,
      );
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

    final route = MaterialPageRoute<void>(
      // A page over the record, with Back (library.js editors).
      fullscreenDialog: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final p = AppPalette.of(context);
          final style = libraryInputStyle(context);
          final stacked =
              MediaQuery.textScalerOf(context).scale(1) >= 1.5 ||
              MediaQuery.sizeOf(context).width -
                      2 * (AppSpacing.gutter + AppSpacing.md) <
                  400;
          Widget pair(Widget a, Widget b) => stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [a, b],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.itemGap,
                  children: [
                    Expanded(child: a),
                    Expanded(child: b),
                  ],
                );
          Widget legend(String text) => Padding(
            padding: EdgeInsets.zero,
            child: Semantics(
              header: true,
              child: Text(
                text,
                style: AppTypography.sectionHeading.copyWith(
                  color: p.textPrimary,
                ),
              ),
            ),
          );
          final hint = AppTypography.caption.copyWith(
            height: 1.55,
            color: p.textSecondary,
          );
          final sensor =
              sensorWCtrl.text.trim().isEmpty || sensorHCtrl.text.trim().isEmpty
              ? null
              : '${sensorWCtrl.text} × ${sensorHCtrl.text} mm';
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) leave(context, setDialogState);
            },
            child: Scaffold(
              appBar: hybridAppBar(
                context,
                // S7.6: the glossary words; "Equipment profile" is retired.
                title: Text(isEdit ? AppWords.editRig : AppWords.addRig),
              ),
              bottomNavigationBar: LibrarySaveBar(
                saveKey: const Key('rigEditor.save'),
                cancelKey: const Key('rigEditor.cancel'),
                saveLabel: 'Save rig',
                onCancel: () => leave(context, setDialogState),
                // S7.6 (DESIGN_SYSTEM §9): Save is the primary button.
                onSave: () => save(context, setDialogState),
              ),
              body: Form(
                key: formKey,
                child: HybridPlanInputs(
                  child: SingleChildScrollView(
                    key: const Key('rigEditor.scroll'),
                    padding: settingsPagePadding,
                    // Every field is built, so Save validates them all.
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DocumentSection(
                          key: const Key('rigEditor.identityGroup'),
                          children: [
                            SettingsCopy(
                              isEdit
                                  ? 'Untouched values stay as recorded.'
                                  : 'Add the camera, sensor and optics. Unknown '
                                        'values are never guessed.',
                            ),
                            if (existing?.needsApertureReview ?? false)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.sm,
                                ),
                                child: _reviewBanner(context, existing!),
                              ),
                            if (existing != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.xs,
                                ),
                                child: Text(
                                  _provenance(existing),
                                  key: const Key('editor.provenance'),
                                  style: hint,
                                ),
                              ),
                            LibraryField(
                              label: 'Rig name',
                              child: TextFormField(
                                controller: nameCtrl,
                                style: style,
                                decoration: const InputDecoration(
                                  hintText: 'e.g. DSLR rig',
                                ),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DocumentSection(
                          key: const Key('rigEditor.cameraGroup'),
                          children: [
                            // S7.2a (ADR-020 §2): the user's choice, never
                            // inferred; it decides the capture settings offered.
                            legend(
                              isEdit
                                  ? 'Camera type'
                                  : 'What takes the pictures?',
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            LibraryChoiceGrid<CameraClass>(
                              key: const Key('equipmentEditor.cameraClass'),
                              legend: 'Camera type',
                              keyPrefix: 'equipmentEditor.cameraClass',
                              options: [
                                for (final c in CameraClass.values)
                                  (
                                    c,
                                    c == CameraClass.unknown
                                        ? 'Not sure (Unknown)'
                                        : c.label,
                                    c.name,
                                  ),
                              ],
                              value: cameraClass,
                              onChanged: (c) =>
                                  setDialogState(() => cameraClass = c),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.xs,
                              ),
                              child: Text(
                                cameraClass == CameraClass.unknown
                                    ? 'The type stays Unknown. The app does not work '
                                          'out sensor facts from it; you can set it '
                                          'later.'
                                    : 'Chosen by you, never inferred from a name. It '
                                          'decides the capture settings a plan '
                                          'offers (ISO or gain, binning).',
                                style: hint,
                              ),
                            ),
                            // S7.3b (ADR-020 §8): the user's statement of a camera
                            // setting, off by default; offered only where a camera
                            // takes a dark per frame. A stored value is kept for
                            // other types, and ignored.
                            if (cameraClass.offersInCameraNoiseReduction)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.itemGap,
                                ),
                                child: MergeSemantics(
                                  child: Semantics(
                                    checked: noiseReduction,
                                    child: InkWell(
                                      key: const Key(
                                        'equipmentEditor.noiseReduction',
                                      ),
                                      onTap: () => setDialogState(
                                        () => noiseReduction = !noiseReduction,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: AppSpacing.sm,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(width: 4),
                                            HybridCheckbox(
                                              checked: noiseReduction,
                                            ),
                                            const SizedBox(width: 15),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                spacing: 2,
                                                children: [
                                                  Text(
                                                    'In-camera noise reduction',
                                                    style: AppTypography.body
                                                        .copyWith(
                                                          height: 1.5,
                                                          color: p.textPrimary,
                                                        ),
                                                  ),
                                                  Text(
                                                    'Long-exposure noise reduction: '
                                                    'the camera takes a dark as long '
                                                    'as each light. The plan counts '
                                                    'that time.',
                                                    style: hint,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DocumentSection(
                          key: const Key('rigEditor.sensorGroup'),
                          children: [
                            legend('Camera sensor'),
                            pair(
                              LibraryField(
                                label: 'Resolution width (px)',
                                child: TextFormField(
                                  key: const Key('rigEditor.resolutionWidth'),
                                  controller: resWCtrl,
                                  style: style,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) =>
                                      setDialogState(autoSensorSize),
                                  decoration: const InputDecoration(
                                    hintText: '6248',
                                  ),
                                  validator:
                                      EquipmentFormInput.validateResolution,
                                ),
                              ),
                              LibraryField(
                                label: 'Resolution height (px)',
                                child: TextFormField(
                                  key: const Key('rigEditor.resolutionHeight'),
                                  controller: resHCtrl,
                                  style: style,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) =>
                                      setDialogState(autoSensorSize),
                                  decoration: const InputDecoration(
                                    hintText: '4176',
                                  ),
                                  validator:
                                      EquipmentFormInput.validateResolution,
                                ),
                              ),
                            ),
                            reasonNote(context, EquipmentSpec.resolution),
                            prefillNote(context, EquipmentSpec.resolution),
                            // S7.6 (UX-22): the pixel size is asked once (square
                            // pixels); it was two fields on one controller.
                            LibraryField(
                              label: 'Pixel size (µm)',
                              hint: 'Square pixels: one value.',
                              child: TextFormField(
                                key: const Key('equipmentEditor.pixelSize'),
                                controller: pixelCtrl,
                                style: style,
                                keyboardType: _decimal,
                                onChanged: (_) =>
                                    setDialogState(autoSensorSize),
                                decoration: const InputDecoration(
                                  hintText: '3.76',
                                ),
                                validator: EquipmentFormInput.required(
                                  EquipmentLimits.pixelPitchUm,
                                  'µm',
                                ),
                              ),
                            ),
                            // S3.V8: a saved rig's pixel size of another output
                            // mode was not copied; say why while empty.
                            if (form.withheldFromSavedRig case final w?
                                when pixelCtrl.text.trim().isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.xs,
                                ),
                                child: Text(
                                  PrefillText.withheld(w),
                                  key: const Key('editor.withheld'),
                                  style: hint,
                                ),
                              ),
                            reasonNote(context, EquipmentSpec.pixelPitch),
                            prefillNote(context, EquipmentSpec.pixelPitch),
                            // The sensor size, derived from resolution × pixel size
                            // (library.js `library-derived`); still checked.
                            FormField<void>(
                              key: const Key('rigEditor.sensorSize'),
                              validator: (_) =>
                                  EquipmentFormInput.required(
                                    EquipmentLimits.sensorSideMm,
                                    'mm',
                                  )(sensorWCtrl.text) ??
                                  EquipmentFormInput.required(
                                    EquipmentLimits.sensorSideMm,
                                    'mm',
                                  )(sensorHCtrl.text),
                              builder: (field) => Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.itemGap,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sensor size (mm)',
                                      style: AppTypography.value.copyWith(
                                        height: 1.5,
                                        color: p.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      sensor ??
                                          'Not recorded until resolution and pixel '
                                              'size are entered',
                                      key: const Key(
                                        'rigEditor.sensorSizeValue',
                                      ),
                                      style: AppTypography.value.copyWith(
                                        height: 1.5,
                                        color: sensor == null
                                            ? p.textSecondary
                                            : p.textPrimary,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: AppSpacing.xs,
                                      ),
                                      child: Text(
                                        'Auto-calculated from resolution × pixel '
                                        'size.',
                                        style: hint,
                                      ),
                                    ),
                                    if (field.errorText case final e?)
                                      Text(
                                        e,
                                        style: hint.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            reasonNote(context, EquipmentSpec.sensorSize),
                            prefillNote(context, EquipmentSpec.sensorSize),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DocumentSection(
                          key: const Key('rigEditor.opticsGroup'),
                          children: [
                            legend('Optics'),
                            LibraryField(
                              label: 'Effective focal length (mm)',
                              child: TextFormField(
                                key: const Key('rigEditor.focalLength'),
                                controller: focalCtrl,
                                style: style,
                                keyboardType: _decimal,
                                onChanged: (_) =>
                                    setDialogState(deriveFocalRatio),
                                validator: EquipmentFormInput.required(
                                  EquipmentLimits.focalLengthMm,
                                  'mm',
                                ),
                              ),
                            ),
                            reasonNote(context, EquipmentSpec.focalLength),
                            prefillNote(context, EquipmentSpec.focalLength),
                            pair(
                              LibraryField(
                                label: 'Focal ratio (f/)',
                                hint: diameterCtrl.text.trim().isNotEmpty
                                    ? 'From focal length ÷ diameter'
                                    : null,
                                child: TextFormField(
                                  key: const Key('rigEditor.focalRatio'),
                                  controller: apertureCtrl,
                                  style: style,
                                  onChanged: (_) => setDialogState(() {}),
                                  // ADR-011 §4: with a diameter, N = f / D.
                                  readOnly: diameterCtrl.text.trim().isNotEmpty,
                                  keyboardType: _decimal,
                                  validator: diameterCtrl.text.trim().isNotEmpty
                                      ? null
                                      : EquipmentFormInput.required(
                                          EquipmentLimits.focalRatio,
                                          '',
                                        ),
                                ),
                              ),
                              LibraryField(
                                label: 'Aperture diameter (mm, optional)',
                                child: TextFormField(
                                  key: const Key('rigEditor.diameter'),
                                  controller: diameterCtrl,
                                  style: style,
                                  keyboardType: _decimal,
                                  onChanged: (_) =>
                                      setDialogState(deriveFocalRatio),
                                  validator: EquipmentFormInput.optional(
                                    EquipmentLimits.apertureDiameterMm,
                                    'mm',
                                  ),
                                ),
                              ),
                            ),
                            reasonNote(context, EquipmentSpec.focalRatio),
                            prefillNote(context, EquipmentSpec.focalRatio),
                            if (apertureError != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.sm,
                                ),
                                child: Text(
                                  apertureError!,
                                  style: hint.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            LibraryField(
                              // S7.1 (RD-08 = T3): a plan may override it.
                              label: 'Tracking (default for plans)',
                              hint: 'A plan may override it.',
                              child: DropdownButtonFormField<TrackingType>(
                                key: const Key('rigEditor.tracking'),
                                initialValue: trackingType,
                                // S3.10: the chosen label wraps inside the field
                                // instead of overflowing on a phone at large text.
                                isExpanded: true,
                                style: style,
                                icon: hybridSelectIcon(context),
                                decoration: const InputDecoration(
                                  contentPadding: hybridSelectPadding,
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
                            ),
                          ],
                        ),
                        // S7.6 (UX-22): the rare values one tap away, their
                        // meaning unchanged; the summary states what is set.
                        const SizedBox(height: AppSpacing.md),
                        DocumentSection(
                          key: const Key('rigEditor.moreGroup'),
                          children: [
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    pair(
                                      LibraryField(
                                        label: 'Manufacturer (optional)',
                                        top: 0,
                                        child: TextFormField(
                                          controller: manufacturerCtrl,
                                          style: style,
                                          decoration: const InputDecoration(
                                            hintText: 'e.g. ZWO',
                                          ),
                                        ),
                                      ),
                                      LibraryField(
                                        label: 'Model (optional)',
                                        top: stacked ? AppSpacing.itemGap : 0,
                                        child: TextFormField(
                                          controller: cameraModelCtrl,
                                          style: style,
                                          decoration: const InputDecoration(
                                            hintText: 'e.g. ASI2600MC',
                                          ),
                                        ),
                                      ),
                                    ),
                                    LibraryField(
                                      label: 'Maximum sub-exposure (s)',
                                      hint:
                                          'Optional — your mount/guiding limit',
                                      child: TextFormField(
                                        controller: maxExposureCtrl,
                                        style: style,
                                        keyboardType: _decimal,
                                        validator: EquipmentFormInput.optional(
                                          EquipmentLimits.maxExposureS,
                                          's',
                                        ),
                                      ),
                                    ),
                                    LibraryField(
                                      label: 'Average RAW file size (MB)',
                                      hint:
                                          'Optional: makes the storage estimate '
                                          'real',
                                      child: TextFormField(
                                        controller: averageRawFileSizeMBCtrl,
                                        style: style,
                                        onChanged: (_) => setDialogState(() {}),
                                        keyboardType: _decimal,
                                        validator: EquipmentFormInput.optional(
                                          EquipmentLimits.rawFileSizeMB,
                                          'MB',
                                        ),
                                      ),
                                    ),
                                    prefillNote(
                                      context,
                                      EquipmentSpec.rawFileSize,
                                    ),
                                    LibraryField(
                                      label: 'Capture format (optional)',
                                      hint:
                                          'Gives a theoretical file size when no '
                                          'file is measured; compressed formats have '
                                          'none.',
                                      child:
                                          DropdownButtonFormField<
                                            CaptureFormat?
                                          >(
                                            key: const Key(
                                              'rigEditor.captureFormat',
                                            ),
                                            initialValue: captureFormat,
                                            isExpanded: true,
                                            style: style,
                                            icon: hybridSelectIcon(context),
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  hybridSelectPadding,
                                            ),
                                            items: [
                                              const DropdownMenuItem(
                                                value: null,
                                                child: Text('Not set'),
                                              ),
                                              for (final f
                                                  in CaptureFormat.values)
                                                DropdownMenuItem(
                                                  value: f,
                                                  child: Text(
                                                    captureFormatLabel(f),
                                                  ),
                                                ),
                                            ],
                                            onChanged: (f) => setDialogState(
                                              () => captureFormat = f,
                                            ),
                                          ),
                                    ),
                                    LibraryField(
                                      label: 'Rotation (°)',
                                      child: TextFormField(
                                        controller: rotationCtrl,
                                        style: style,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                              signed: true,
                                            ),
                                        validator: EquipmentFormInput.optional(
                                          EquipmentLimits.rotationDeg,
                                          '°',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
    await Navigator.of(context).push(route);
    return savedId;
  }
}
