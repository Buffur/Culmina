import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/models/camera_class.dart';
import '../../../domain/models/capture_block.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/hybrid_tokens.dart';
import '../../../core/utils/quantity_text.dart';
import '../../../domain/services/block_proposal.dart';
import '../../../domain/services/calibration_match.dart';
import '../../../domain/services/exposure_input.dart';
import '../../shared/block_text.dart';
import '../../shared/calibration_text.dart';
import '../../shared/capture_settings_text.dart';
import '../../shared/confirmation_patterns.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/proposal_text.dart';
import '../../shared/display_units_of.dart';
import 'block_editor_parts.dart';

const _filters = ['L', 'R', 'G', 'B', 'Ha', 'OIII', 'SII', 'OSC', 'None'];

/// Scoped full-page editor for one capture block (TASK 4.1; policy, binning and a
/// typed gain added in TASK 5.6). Validation mirrors the domain bounds
/// (TASK 5.3), so an invalid block can never be submitted. It returns the
/// block (null when cancelled) and changes nothing itself: the caller adds
/// it, or applies an edit with Undo (TD-079, S6.16). [initial] makes it an
/// edit of that block.
///
/// S7.2b (ADR-020 §3, §5), ADR-021 C13 (AM-04): a light block shows what
/// applies to the rig's [cameraClass]: ISO for phones and cameras, gain for
/// astro cameras, and for Unknown no ISO/gain field but a way to say the
/// camera type; binning only for astro cameras and Unknown, in Details. A
/// value the class does not show is kept as recorded, and named. A new
/// light block starts from [proposal] (the plan's last light block): its
/// exposure, ISO or gain and binning, marked as a proposal and stored only
/// on Add block.
///
/// S7.3a (ADR-020 §6–§7; RG-10 = L1, D1, H1): a new dark, bias, flat or dark
/// flat takes what it must match from a block of the plan's [blocks] (a
/// light, or a flat for a dark flat; the first by default), shown with its
/// origin; "Use other values" makes those fields the user's. A short tip per
/// calibration type, more on demand, hideable ([tipsShown], [onTipsShown]).
///
/// F06 (ADR-021 C1/C3/C4/C14; SP05): exposure as decimal seconds or a
/// fraction; a custom filter stays itself; flats and bias never keep a
/// light's proposed exposure; white balance and AF/MF are optional records
/// for phones, cameras and Unknown; each field keeps its origin unless the
/// user changes it. A changed editor asks before Back or Close discards it.
/// The existing function name is retained for its callers.
Future<CaptureBlock?> showCaptureBlockDialog(
  BuildContext context, {
  CaptureBlock? initial,
  CameraClass cameraClass = CameraClass.unknown,
  CaptureBlock? proposal,
  List<CaptureBlock> blocks = const [],
  bool tipsShown = true,
  ValueChanged<bool>? onTipsShown,
  Future<BlockProposal?> Function(int binning)? fromPhoto,
  bool pickOnOpen = false,
  String? rigName,
}) {
  return Navigator.of(context, rootNavigator: true).push<CaptureBlock>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (ctx) => _CaptureBlockDialog(
        initial: initial,
        cameraClass: cameraClass,
        proposal: initial == null ? proposal : null,
        blocks: blocks,
        tipsShown: tipsShown,
        onTipsShown: onTipsShown,
        fromPhoto: fromPhoto,
        pickOnOpen: pickOnOpen && fromPhoto != null,
        rigName: rigName,
      ),
    ),
  );
}

class _CaptureBlockDialog extends StatefulWidget {
  const _CaptureBlockDialog({
    required this.initial,
    required this.cameraClass,
    required this.proposal,
    required this.blocks,
    required this.tipsShown,
    required this.onTipsShown,
    required this.fromPhoto,
    this.pickOnOpen = false,
    this.rigName,
  });

  /// The plan's rig, named above the form (Hybrid's "Rig: …"); null when
  /// none is chosen.
  final String? rigName;

  final CaptureBlock? initial;
  final CameraClass cameraClass;
  final CaptureBlock? proposal;
  final List<CaptureBlock> blocks;
  final bool tipsShown;
  final ValueChanged<bool>? onTipsShown;

  /// F08: reads one file and proposes this block's values; null when the
  /// user cancels. Absent where reading files is not available.
  final Future<BlockProposal?> Function(int binning)? fromPhoto;

  /// The empty plan's "Take from a photo" (F09 A6): pick as the dialog
  /// opens; a cancelled pick leaves an empty light block to fill.
  final bool pickOnOpen;

  @override
  State<_CaptureBlockDialog> createState() => _CaptureBlockDialogState();
}

class _CaptureBlockDialogState extends State<_CaptureBlockDialog> {
  final _formKey = GlobalKey<FormState>();
  late FrameType _type;
  late String _filter;
  late int _binning;
  late CalibrationPolicy _policy;
  late final TextEditingController _exposure;
  late final TextEditingController _count;
  late final TextEditingController _gainValue;
  late final TextEditingController _kelvin;
  late final TextEditingController _tint;
  WhiteBalanceMode? _wbMode;
  WhiteBalancePreset _wbPreset = WhiteBalancePreset.daylight;
  FocusMode? _focus;
  late bool _tipsShown = widget.tipsShown;
  bool _tipMore = false;
  bool _details = false;

  /// Hybrid's "From a photo" disclosure: open when the editor opened to
  /// pick a file, and whenever a file has been read.
  late bool _photoOpen = widget.pickOnOpen;

  /// A valid filter outside the list (an older plan's, an import's): kept
  /// as itself, never coerced to None (F06 A1).
  String? _customFilter;

  /// S7.3a: which of the plan's blocks a new calibration block matches, and
  /// whether it still takes its values from it (until "Use other values").
  int _sourceIndex = 0;
  bool _inherit = true;

  /// S7.V1 (TD-083): whether the user has typed or cleared the ISO or gain;
  /// a source then no longer proposes a flat's.
  bool _gainEdited = false;

  /// For Unknown (no ISO/gain field, ADR-021 C13): a source's recorded ISO
  /// or gain taken by "Use other values" or a flat's proposal, kept as
  /// recorded, never relabelled.
  CaptureGain? _copiedGain;

  /// F06 A3: whether the exposure field still holds the light proposal's
  /// value, which a flat, bias or dark flat must not keep.
  bool _exposureFromProposal = false;

  /// ADR-021 C4: values taken from a source while the dialog is open (the
  /// proposal, "Use other values"), with their origin. A field that still
  /// holds that value keeps the origin on submit; a changed one is entered.
  final Map<CaptureField, (Object?, FieldOrigin)> _seeds = {};

  /// F08: the block's storage file (C6) and the latest file proposal, with
  /// the fields it did not change because the user had typed them.
  FileEvidence? _fileEvidence;
  BlockProposal? _picked;
  List<String> _keptYours = const [];
  bool _reading = false;

  /// The dialog's state when it opened, for the discard guard (F06 A6).
  late final List<Object?> _opened;

  /// Set when the dialog closes on purpose, so the guard lets it go.
  bool _leaving = false;

  List<CaptureBlock> get _sources =>
      CalibrationMatch.sourcesFor(_type, widget.blocks);

  /// The block a new calibration block takes its values from, while it does.
  CaptureBlock? get _inheritFrom {
    if (widget.initial != null || _type == FrameType.light || !_inherit) {
      return null;
    }
    final sources = _sources;
    return sources.isEmpty
        ? null
        : sources[_sourceIndex.clamp(0, sources.length - 1)];
  }

  /// The recorded values this dialog starts from: the block being edited,
  /// else the proposal (S7.2b), else nothing.
  CaptureBlock? get _source => widget.initial ?? widget.proposal;

  /// The sensitivity kind a block of this class records (ADR-020 §3; RG-10
  /// §4 gives calibration frames the lights' kind); null for Unknown, which
  /// records none until the camera type is set (ADR-021 C13).
  GainKind? get _fixedKind => switch (widget.cameraClass.lightSensitivity) {
    LightSensitivity.iso => GainKind.iso,
    LightSensitivity.gain => GainKind.gain,
    LightSensitivity.either => null,
  };

  /// Binning, for every frame type, only where the class offers it (RG-10
  /// §4: not applicable for phones and cameras, where it is the rig's mode).
  bool get _showBinning => widget.cameraClass.offersLightBinning;

  /// White balance and focus mode (ADR-021 C1, C3; AM-04): offered on a
  /// light block of a phone, camera or Unknown rig.
  bool get _showCameraRecords =>
      widget.cameraClass.offersCameraRecords && _type == FrameType.light;

  List<String> get _filterOptions => [
    ..._filters.where((f) => f != 'None'),
    ?_customFilter,
    'None',
  ];

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    final from = _source;
    _type = i?.frameType ?? FrameType.light;
    final filter = i == null ? _defaultFilter : (i.filterName ?? 'None');
    _filter = filter;
    if (!_filters.contains(filter)) _customFilter = filter;
    _binning = from?.binning ?? 1;
    _policy = i?.calibrationPolicy ?? CalibrationPolicy.outsideWindow;
    _exposure = TextEditingController(
      text: from == null ? '' : ExposureInput.format(from.exposureTimeSeconds),
    );
    _count = TextEditingController(text: i?.frameCount.toString() ?? '');
    // A value of another kind than this class records stays as it was and
    // is named instead of being shown in the field (ADR-020 §3).
    final gv = from?.gain.value;
    final fixed = _fixedKind;
    final shown = fixed != null && from?.gain.kind == fixed;
    _gainValue = TextEditingController(
      text: gv == null || !shown ? '' : _trimZeros(gv),
    );
    final wb = i?.whiteBalance;
    _wbMode = wb?.mode;
    _wbPreset = wb?.preset ?? WhiteBalancePreset.daylight;
    _kelvin = TextEditingController(text: wb?.kelvinK?.toString() ?? '');
    _tint = TextEditingController(
      text: wb?.tint == null ? '' : _trimZeros(wb!.tint!),
    );
    _focus = i?.focusMode;
    _fileEvidence = i?.fileEvidence;
    final p = widget.proposal;
    if (p != null) {
      _exposureFromProposal = true;
      final origin = FieldOrigin(
        OriginKind.copied,
        CaptureSettingsText.fromBlock(BlockText.row(p, null)),
      );
      _seeds[CaptureField.exposure] = (p.exposureTimeSeconds, origin);
      _seeds[CaptureField.binning] = (p.binning, origin);
      if (shown) _seeds[CaptureField.sensitivity] = (p.gain, origin);
    }
    _opened = _state();
    if (widget.pickOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _takeFromPhoto();
      });
    }
  }

  /// A new block's filter by class (F06 A3): a mono astro camera's
  /// luminance, otherwise none (a colour sensor, a phone or Unknown).
  String get _defaultFilter =>
      widget.cameraClass == CameraClass.astroMono ? 'L' : 'None';

  @override
  void dispose() {
    _exposure.dispose();
    _count.dispose();
    _gainValue.dispose();
    _kelvin.dispose();
    _tint.dispose();
    super.dispose();
  }

  /// Everything the user can change, for the discard guard.
  List<Object?> _state() => [
    _type,
    _filter,
    _binning,
    _policy,
    _exposure.text.trim(),
    _count.text.trim(),
    _gainValue.text.trim(),
    _wbMode,
    _wbPreset,
    _kelvin.text.trim(),
    _tint.text.trim(),
    _focus,
    _sourceIndex,
    _inherit,
    // F08 A2 (UXA-C4): an unsaved file proposal is a change.
    _fileEvidence,
    _picked,
  ];

  bool get _changed {
    final now = _state();
    for (var i = 0; i < now.length; i++) {
      if (now[i] != _opened[i]) return true;
    }
    return false;
  }

  /// Whole numbers print without a trailing ".0" (60.0 -> "60").
  static String _trimZeros(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  String? _validateGain(String? value) {
    final text = (value ?? '').trim();
    final kind = _fixedKind;
    if (kind == null || text.isEmpty) return null;
    final v = double.tryParse(text);
    if (kind == GainKind.iso) {
      if (v == null || v != v.roundToDouble() || v < 1 || v > 1000000) {
        return 'ISO is a whole number from 1 to 1000000';
      }
    } else if (v == null || v < 0 || v > 10000) {
      return 'Gain is a number from 0 to 10000';
    }
    return null;
  }

  CaptureGain _gain() {
    final v = double.tryParse(_gainValue.text.trim());
    final fixed = _fixedKind;
    final kept = widget.initial?.gain ?? CaptureGain.none;
    if (fixed == null) {
      // ADR-021 C13: Unknown records none of its own; an edited block keeps
      // its value, a source's is taken as recorded.
      return _copiedGain ?? kept;
    }
    if (v != null) {
      return fixed == GainKind.iso
          ? CaptureGain.iso(v.round())
          : CaptureGain.gain(v);
    }
    // Cleared: none; a value of another kind is kept as recorded.
    return kept.kind == fixed ? CaptureGain.none : kept;
  }

  String? _validateKelvin(String? value) {
    if (_wbMode != WhiteBalanceMode.kelvin) return null;
    final k = int.tryParse((value ?? '').trim());
    if (k == null || k < WhiteBalance.minKelvin || k > WhiteBalance.maxKelvin) {
      return 'A whole number of kelvins, ${WhiteBalance.minKelvin}–'
          '${WhiteBalance.maxKelvin}';
    }
    return null;
  }

  String? _validateTint(String? value) {
    final t = (value ?? '').trim();
    if (t.isEmpty || !_tintApplies) return null;
    final v = double.tryParse(t);
    if (v == null || v.abs() > WhiteBalance.maxAbsTint) {
      return 'A number from −${WhiteBalance.maxAbsTint.round()} to '
          '${WhiteBalance.maxAbsTint.round()}, as the camera shows it';
    }
    return null;
  }

  bool get _tintApplies => _wbMode != null && _wbMode != WhiteBalanceMode.auto;

  /// The white balance as set in the dialog; null = not recorded.
  WhiteBalance? _whiteBalance() {
    if (!_showCameraRecords) return widget.initial?.whiteBalance;
    final tintText = _tint.text.trim();
    final tint = tintText.isEmpty ? null : double.tryParse(tintText);
    return switch (_wbMode) {
      null => null,
      WhiteBalanceMode.auto => WhiteBalance.auto(),
      WhiteBalanceMode.preset => WhiteBalance.preset(_wbPreset, tint: tint),
      WhiteBalanceMode.kelvin => WhiteBalance.kelvin(
        int.parse(_kelvin.text.trim()),
        tint: tint,
      ),
      WhiteBalanceMode.custom => WhiteBalance.custom(tint: tint),
    };
  }

  FocusMode? _focusMode() =>
      _showCameraRecords ? _focus : widget.initial?.focusMode;

  /// A new flat's ISO or gain is proposed from its light block (RG-10 §4:
  /// prefilled and overridable), until the user edits it (S7.V1); its
  /// binning is taken from it.
  void _prefillFlatGain() {
    final from = _inheritFrom;
    if (_type != FrameType.flat || from == null || _gainEdited) return;
    _copyGain(from.gain, _sourceOrigin(from, OriginKind.copied));
  }

  /// Puts [g] in the ISO or gain field, unless this class records the other
  /// kind: never relabelled as it (SI-004), the field is left empty.
  void _copyGain(CaptureGain g, FieldOrigin origin) {
    final fixed = _fixedKind;
    final fits = fixed != null && g.kind == fixed;
    _gainValue.text = g.value == null || !fits ? '' : _trimZeros(g.value!);
    if (fixed == null) _copiedGain = g;
    if (fits || fixed == null) _seeds[CaptureField.sensitivity] = (g, origin);
  }

  FieldOrigin _sourceOrigin(CaptureBlock from, OriginKind kind) => FieldOrigin(
    kind,
    CaptureSettingsText.fromBlock(BlockText.row(from, null)),
  );

  /// Whether the exposure is the user's to type (not taken from a source).
  bool get _typesExposure =>
      _inheritFrom == null || !CalibrationMatch.takesExposure(_type);

  void _setType(FrameType type) {
    setState(() {
      _type = type;
      _sourceIndex = 0;
      final p = widget.proposal;
      if (type == FrameType.light) {
        // Back to a light: the proposal again, unless the user typed one.
        if (p != null && _exposure.text.trim().isEmpty) {
          _exposure.text = ExposureInput.format(p.exposureTimeSeconds);
          _exposureFromProposal = true;
        }
      } else if (type != FrameType.dark && _exposureFromProposal) {
        // F06 A3: a flat's, bias's or dark flat's exposure is its own.
        _exposure.clear();
        _exposureFromProposal = false;
      }
      _prefillFlatGain();
    });
  }

  /// "Use other values" (ADR-020 §6): the values still taken from the source
  /// become the fields', which are the user's from now on. What was already
  /// the user's (a flat's or bias's exposure, a flat's ISO or gain) is kept
  /// (S7.V1, TD-083).
  void _useOtherValues() {
    final from = _inheritFrom;
    if (from == null) return;
    final origin = _sourceOrigin(from, OriginKind.copied);
    setState(() {
      _inherit = false;
      if (CalibrationMatch.takesExposure(_type)) {
        _exposure.text = ExposureInput.format(from.exposureTimeSeconds);
        _exposureFromProposal = false;
        _seeds[CaptureField.exposure] = (from.exposureTimeSeconds, origin);
      }
      _binning = from.binning;
      _seeds[CaptureField.binning] = (from.binning, origin);
      if (CalibrationMatch.takesSensitivity(_type)) {
        _copyGain(from.gain, origin);
      }
      if (_type == FrameType.flat) {
        final filter = from.filterName ?? 'None';
        if (!_filters.contains(filter)) _customFilter = filter;
        _filter = filter;
        _seeds[CaptureField.filter] = (from.filterName, origin);
      }
    });
  }

  /// [field]'s origin for [value] (ADR-021 C4): an edited block's own while
  /// the value is unchanged, a source's while it holds that source's value,
  /// otherwise entered; null when nothing is recorded for a new block.
  FieldOrigin? _origin(CaptureField field, Object? value, Object? before) {
    final i = widget.initial;
    if (i != null && value == before) return i.origins[field];
    if (_seeds[field] case (final seeded, final origin) when seeded == value) {
      return origin;
    }
    if (i == null && value == null) return null;
    return FieldOrigin.entered();
  }

  CaptureBlock _build() {
    final isLight = _type == FrameType.light;
    final from = _inheritFrom;
    final i = widget.initial;
    final filter = (isLight || _type == FrameType.flat) && _filter != 'None'
        ? _filter
        : null;
    final exposure = _typesExposure
        ? ExposureInput.parse(_exposure.text)!
        : from!.exposureTimeSeconds;
    final count = int.parse(_count.text.trim());
    final gain = _gain();
    final wb = _whiteBalance();
    final focus = _focusMode();
    final binning = _binning;
    var origins = i?.origins ?? FieldOrigins.none;
    for (final (field, value, before) in [
      (CaptureField.frameType, _type, i?.frameType),
      (CaptureField.filter, filter, i?.filterName),
      (CaptureField.exposure, exposure, i?.exposureTimeSeconds),
      (CaptureField.count, count, i?.frameCount),
      (
        CaptureField.sensitivity,
        gain == CaptureGain.none ? null : gain,
        i?.gain == CaptureGain.none ? null : i?.gain,
      ),
      (CaptureField.binning, _showBinning ? binning : null, i?.binning),
      (CaptureField.wb, wb, i?.whiteBalance),
      (CaptureField.focusMode, focus, i?.focusMode),
      (CaptureField.fileSize, _fileEvidence, i?.fileEvidence),
    ]) {
      // A hidden binning of an edited block keeps its origin.
      if (field == CaptureField.binning && !_showBinning && i != null) continue;
      origins = origins.withOrigin(field, _origin(field, value, before));
    }
    final block = CaptureBlock(
      id: i?.id ?? 0,
      sessionLogId: i?.sessionLogId ?? 0,
      frameType: _type,
      filterName: filter,
      exposureTimeSeconds: exposure,
      frameCount: count,
      binning: binning,
      gain: gain,
      calibrationPolicy: isLight ? null : _policy,
      whiteBalance: wb,
      focusMode: focus,
      origins: origins,
      fileEvidence: _fileEvidence,
    );
    return from == null
        ? block
        : CalibrationMatch.matched(
            block,
            from,
            origin: _sourceOrigin(from, OriginKind.inherited),
          );
  }

  /// F08 (ADR-021 C2/C4/C13): reads one file and applies its proposals to
  /// the fields that still hold a value the user did not type (empty, the
  /// block's own, or a source's); a typed value is kept and named. A later
  /// pick replaces an earlier file's values the same way, so the outcome
  /// does not depend on the order of picks. Nothing is stored before Apply.
  Future<void> _takeFromPhoto() async {
    final read = widget.fromPhoto;
    if (read == null) return;
    setState(() {
      _reading = true;
      _photoOpen = true;
    });
    BlockProposal? got;
    try {
      // A failure to pick or open is said, and changes nothing (F08 A2).
      await runWithFeedback(
        context,
        'read the file',
        () async => got = await read(_binning),
      );
    } finally {
      if (mounted) setState(() => _reading = false);
    }
    if (got == null || !mounted) return;
    final p = got!;
    if (p.unreadable) {
      setState(() => _picked = p);
      return;
    }
    final kept = <String>[];
    setState(() {
      _picked = p;
      if (p.exposure case final e?) {
        final now = ExposureInput.parse(_exposure.text);
        if (_mayReplace(CaptureField.exposure, now)) {
          _exposure.text = ExposureInput.format(e.value);
          _exposureFromProposal = false;
          _seeds[CaptureField.exposure] = (e.value, e.origin);
        } else {
          kept.add(
            'exposure ${QuantityText.exposure(now!)} (the file says '
            '${QuantityText.exposure(e.value)})',
          );
        }
      }
      if (p.sensitivity case final g?) {
        final now = _typedGain();
        final word = g.value.kind == GainKind.iso ? 'ISO' : 'gain';
        if (_mayReplace(CaptureField.sensitivity, now)) {
          _gainValue.text = _trimZeros(g.value.value!);
          _seeds[CaptureField.sensitivity] = (g.value, g.origin);
        } else {
          kept.add(
            '$word ${_gainValue.text.trim()} (the file says '
            '${_trimZeros(g.value.value!)})',
          );
        }
      }
      // FITS (F10): the filter as written, and a symmetric binning.
      if (p.filter case final f?) {
        final now = _filter == 'None' ? null : _filter;
        if (_mayReplace(CaptureField.filter, now) || now == _defaultFilter) {
          if (!_filters.contains(f.value)) _customFilter = f.value;
          _filter = f.value;
          _seeds[CaptureField.filter] = (f.value, f.origin);
        } else {
          kept.add('filter $now (the file says ${f.value})');
        }
      }
      if (p.binning case final b? when _showBinning) {
        final untouched = _binning == (_source?.binning ?? 1);
        if (untouched || _mayReplace(CaptureField.binning, _binning)) {
          _binning = b.value;
          _seeds[CaptureField.binning] = (b.value, b.origin);
        } else {
          kept.add('binning $_binning × $_binning (the file says ${b.value})');
        }
      }
      if (p.whiteBalance case final wb?) {
        final now = _wbOrNull();
        if (_mayReplace(CaptureField.wb, now)) {
          _wbMode = wb.value.mode;
          _seeds[CaptureField.wb] = (wb.value, wb.origin);
        } else {
          kept.add('your white balance (the file says Auto)');
        }
      }
      if (p.file case final file?) {
        _fileEvidence = file;
        _seeds[CaptureField.fileSize] = (
          file,
          FieldOrigin(OriginKind.file, p.label),
        );
      }
      _keptYours = kept;
    });
  }

  /// Whether a file may set [field] now holding [current]: nothing typed,
  /// the edited block's own value, or a source's value (the proposal, an
  /// earlier file).
  bool _mayReplace(CaptureField field, Object? current) {
    if (current == null) return true;
    final i = widget.initial;
    if (i != null && current == _initialValue(field)) return true;
    return switch (_seeds[field]) {
      (final seeded, _) => seeded == current,
      null => false,
    };
  }

  Future<void> _submit() async {
    // A field inside the closed Details is not built, so the form cannot
    // check it: open Details first when its tint is invalid, so the check
    // runs and its message shows (never a silent drop or a dead button).
    if (!_details &&
        _showCameraRecords &&
        _tintApplies &&
        _validateTint(_tint.text) != null) {
      setState(() => _details = true);
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final block = _build();
    _leaving = true;
    Navigator.pop(context, block);
  }

  /// Back or the close affordance: an unchanged editor closes; a changed
  /// one asks with the shared prompt, whose dismissal keeps the editor.
  Future<void> _leave() async {
    if (!_changed) {
      _leaving = true;
      Navigator.pop(context);
      return;
    }
    final i = widget.initial;
    final choice = await askUnsavedChanges(
      context,
      plan: i == null ? 'New block' : BlockText.identity(i),
    );
    if (!mounted) return;
    switch (choice) {
      case UnsavedChoice.cancel:
        return;
      case UnsavedChoice.discard:
        _leaving = true;
        Navigator.pop(context);
      case UnsavedChoice.save:
        await _submit();
    }
  }

  void _setTipsShown(bool shown) {
    setState(() => _tipsShown = shown);
    widget.onTipsShown?.call(shown);
  }

  /// The recorded values a block keeps without showing them (ADR-020 §3,
  /// ADR-021 C3/C13): named, so nothing is hidden silently.
  List<String> _kept() {
    if (_inheritFrom != null) return const []; // the source's values show
    final i = widget.initial;
    final fixed = _fixedKind;
    final gain =
        (fixed == null ? _copiedGain : null) ?? i?.gain ?? CaptureGain.none;
    return [
      if (!_showBinning && _binning != 1) '$_binning × $_binning binning',
      if ((fixed == null || gain.kind != fixed) && gain.value != null)
        switch (gain.kind) {
          GainKind.iso => 'ISO ${_trimZeros(gain.value!)}',
          GainKind.gain => 'gain ${_trimZeros(gain.value!)}',
          GainKind.unknown =>
            'ISO or gain ${_trimZeros(gain.value!)} (kind not recorded)',
        },
      if (!_showCameraRecords) ...[
        if (i?.whiteBalance case final wb?)
          'white balance ${CaptureSettingsText.whiteBalance(wb)}',
        if (i?.focusMode case final f?) 'focus ${CaptureSettingsText.focus(f)}',
      ],
    ];
  }

  /// "From …" under a field that still holds a source's value (ADR-021 C4):
  /// a compact, visible origin; Details lists them all.
  String? _from(CaptureField field, Object? value) {
    final i = widget.initial;
    final origin = i != null && value == _initialValue(field)
        ? i.origins[field]
        : switch (_seeds[field]) {
            (final seeded, final o) when seeded == value => o,
            _ => null,
          };
    if (origin == null || origin.kind == OriginKind.entered) return null;
    return CaptureSettingsText.origin(origin);
  }

  Object? _initialValue(CaptureField field) {
    final i = widget.initial!;
    return switch (field) {
      CaptureField.filter => i.filterName,
      CaptureField.exposure => i.exposureTimeSeconds,
      CaptureField.sensitivity => i.gain,
      CaptureField.binning => i.binning,
      CaptureField.wb => i.whiteBalance,
      CaptureField.focusMode => i.focusMode,
      CaptureField.count => i.frameCount,
      CaptureField.frameType => i.frameType,
      CaptureField.fileSize => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isLight = _type == FrameType.light;
    final fixed = _fixedKind;
    final kept = _kept();
    final muted = Theme.of(context).textTheme.bodySmall;
    final from = _inheritFrom;
    final sources = _sources;
    final tip = CalibrationText.tip(_type);
    // What the source gives is not typed while it is taken (ADR-020 §6).
    final takesGain = from != null && CalibrationMatch.takesSensitivity(_type);
    final takesBinning = from != null;
    final takesFilter = from != null && _type == FrameType.flat;
    final origins = widget.initial?.origins.all ?? const {};
    final binning = _showBinning && !takesBinning
        ? BlockField(
            label: 'Binning',
            child: DropdownButtonFormField<int>(
              key: const Key('blockDialog.binning'),
              initialValue: _binning,
              isExpanded: true, // S7.2b: wraps at 200 % text
              decoration: InputDecoration(
                helperText:
                    _from(CaptureField.binning, _binning) ??
                    '1x1 is no binning.',
              ),
              items: [
                for (final b in [1, 2, 3, 4])
                  DropdownMenuItem(value: b, child: Text('${b}x$b')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _binning = v);
              },
            ),
          )
        : null;
    final text = Theme.of(context).textTheme;
    final secondary = AppPalette.of(context).textSecondary;
    // plan.css: .screen-context 13 px, secondary.
    final context13 = text.bodySmall?.copyWith(fontSize: 13, color: secondary);
    final policyShort = switch (_policy) {
      CalibrationPolicy.outsideWindow => 'outside the imaging window',
      CalibrationPolicy.inWindow => 'during the imaging window',
      CalibrationPolicy.library => 'from your library',
    };
    final detailsSummary = [
      if (_showBinning) 'Binning ${_binning}x$_binning',
      isLight ? 'Inside the imaging window' : 'Taken $policyShort',
      // A recorded tint is said while Details is closed.
      if (_showCameraRecords && _tintApplies && _tint.text.trim().isNotEmpty)
        'Tint ${_tint.text.trim()}',
    ].join(' · ');
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): _leave},
      child: Focus(
        autofocus: true,
        skipTraversal: true,
        child: PopScope(
          canPop: _leaving,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _leave();
          },
          child: Scaffold(
            key: const Key('blockEditor.screen'),
            appBar: hybridAppBar(
              context,
              toolbarHeight: MediaQuery.textScalerOf(context).scale(1) >= 1.5
                  ? 96
                  : 56,
              leading: IconButton(
                key: const Key('blockEditor.close'),
                tooltip: 'Close editor',
                onPressed: _leave,
                icon: const Icon(Icons.close),
              ),
              // Hybrid's scoped-screen titles (plan.js screenTitle).
              title: Text(
                widget.initial == null ? 'Add block' : 'Edit block',
                maxLines: 2,
              ),
            ),
            body: SafeArea(
              top: false,
              bottom: false,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  key: const Key('blockEditor.scroll'),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  // Hybrid's scoped form (plan.js blockView, plan.css
                  // .scoped-form): one column, 20 px between its parts.
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 20,
                    children: [
                      Text(
                        'Rig: ${widget.rigName ?? 'none chosen'}',
                        key: const Key('blockDialog.rig'),
                        style: context13,
                      ),
                      if (widget.proposal != null && isLight)
                        Text(
                          'Proposed from your last light block: exposure, '
                          '${fixed == GainKind.gain ? 'gain' : 'ISO'} and '
                          'binning. Change them if needed.',
                          key: const Key('blockDialog.proposal'),
                          style: context13,
                        ),
                      HybridSegmented<FrameType>(
                        key: const Key('blockDialog.frameType'),
                        legend: 'Frame type',
                        keyPrefix: 'blockDialog.frameType',
                        value: _type,
                        options: [
                          for (final t in FrameType.values)
                            (t, BlockText.type(t), t.name),
                        ],
                        onChanged: (t) {
                          if (t != _type) _setType(t);
                        },
                      ),
                      if (tip != null && _tipsShown)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _tipMore ? '${tip.$1} ${tip.$2}' : tip.$1,
                              key: const Key('blockDialog.tip'),
                              style: muted,
                            ),
                            Wrap(
                              spacing: 8,
                              children: [
                                TextButton(
                                  key: const Key('blockDialog.tipMore'),
                                  onPressed: () =>
                                      setState(() => _tipMore = !_tipMore),
                                  child: Text(_tipMore ? 'Less' : 'More'),
                                ),
                                TextButton(
                                  key: const Key('blockDialog.hideTips'),
                                  onPressed: () => _setTipsShown(false),
                                  child: const Text('Hide tips'),
                                ),
                              ],
                            ),
                          ],
                        )
                      else if (tip != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            key: const Key('blockDialog.showTips'),
                            onPressed: () => _setTipsShown(true),
                            child: const Text('Show tips'),
                          ),
                        ),
                      if (from != null) ...[
                        BlockField(
                          label: _type == FrameType.darkFlat
                              ? 'Matches the flat block'
                              : 'Matches the light block',
                          child: DropdownButtonFormField<int>(
                            key: const Key('blockDialog.source'),
                            initialValue: _sourceIndex.clamp(
                              0,
                              sources.length - 1,
                            ),
                            isExpanded: true,
                            items: [
                              for (var i = 0; i < sources.length; i++)
                                DropdownMenuItem(
                                  value: i,
                                  child: Text(BlockText.row(sources[i], null)),
                                ),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() {
                                  _sourceIndex = v;
                                  _prefillFlatGain();
                                });
                              }
                            },
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              CalibrationText.inherited(
                                _type,
                                from,
                                withBinning:
                                    widget.cameraClass.offersLightBinning,
                              ),
                              key: const Key('blockDialog.inherited'),
                            ),
                            TextButton(
                              key: const Key('blockDialog.useOther'),
                              onPressed: _useOtherValues,
                              child: const Text('Use other values'),
                            ),
                          ],
                        ),
                      ],
                      // Hybrid's "From a photo" disclosure, light blocks only.
                      if (widget.fromPhoto != null && isLight)
                        BlockDisclosure(
                          key: const Key('blockDialog.photo'),
                          title: 'From a photo',
                          summary: _picked == null
                              ? null
                              : ProposalText.title(_picked!),
                          open: _photoOpen,
                          onToggle: () =>
                              setState(() => _photoOpen = !_photoOpen),
                          children: _photoReview(muted),
                        ),
                      if (_typesExposure)
                        BlockField(
                          label: 'Exposure (seconds)',
                          // Where the value came from (.field-source).
                          note: _from(
                            CaptureField.exposure,
                            ExposureInput.parse(_exposure.text),
                          ),
                          noteKey: const Key('blockDialog.exposureSource'),
                          hint: _type == FrameType.bias
                              ? 'The shortest your camera allows.'
                              : 'For example 60, 2.5 or 1/125.',
                          child: TextFormField(
                            key: const Key('blockDialog.exposure'),
                            controller: _exposure,
                            decoration: const InputDecoration(
                              hintText: 'e.g. 60 or 1/14',
                              errorMaxLines: 3,
                            ),
                            // Fractions need "/", which a number pad lacks (C14).
                            keyboardType: TextInputType.text,
                            autocorrect: false,
                            onChanged: (_) =>
                                setState(() => _exposureFromProposal = false),
                            validator: (value) =>
                                ExposureInput.problem(value ?? ''),
                          ),
                        ),
                      BlockField(
                        label: 'Frames',
                        child: TextFormField(
                          key: const Key('blockDialog.count'),
                          controller: _count,
                          decoration: const InputDecoration(
                            hintText: 'e.g. 30',
                            errorMaxLines: 3,
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            final count = int.tryParse((value ?? '').trim());
                            if (count == null || count < 1) {
                              return 'Enter a whole number of at least 1';
                            }
                            if (count > CaptureBlock.maxFrameCount) {
                              return 'At most ${CaptureBlock.maxFrameCount}';
                            }
                            return null;
                          },
                        ),
                      ),
                      // Hybrid's live total (.live-total), from the typed values.
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          _total(),
                          key: const Key('blockDialog.total'),
                          style: text.bodyMedium?.copyWith(
                            fontSize: 14,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      if ((isLight || _type == FrameType.flat) && !takesFilter)
                        BlockField(
                          label: 'Filter (optional)',
                          hint: 'None means no filter.',
                          note: _from(
                            CaptureField.filter,
                            _filter == 'None' ? null : _filter,
                          ),
                          child: DropdownButtonFormField<String>(
                            key: const Key('blockDialog.filter'),
                            initialValue: _filter,
                            isExpanded: true, // S7.2b: wraps at 200 % text
                            items: [
                              for (final f in _filterOptions)
                                DropdownMenuItem(value: f, child: Text(f)),
                            ],
                            onChanged: (v) {
                              if (v != null) setState(() => _filter = v);
                            },
                          ),
                        ),
                      if (fixed != null && !takesGain)
                        BlockField(
                          label: fixed == GainKind.iso
                              ? 'ISO (optional)'
                              : 'Gain (optional)',
                          hint:
                              'Recorded only; it does not change the plan. '
                              'Leave blank to keep it unrecorded.',
                          note: _from(CaptureField.sensitivity, _typedGain()),
                          child: TextFormField(
                            key: const Key('blockDialog.gainValue'),
                            controller: _gainValue,
                            decoration: const InputDecoration(
                              hintText: 'Unrecorded',
                              errorMaxLines: 3,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: _validateGain,
                            onChanged: (_) =>
                                setState(() => _gainEdited = true),
                          ),
                        ),
                      // ADR-021 C13: Unknown records no ISO or gain; the remedy is
                      // the rig's camera type, never a guessed kind.
                      if (fixed == null && !takesGain)
                        Text(
                          'ISO or gain: set the rig’s camera type (Rigs → Edit '
                          'rig) to record it here.',
                          key: const Key('blockDialog.chooseClass'),
                          style: muted,
                        ),
                      if (_showCameraRecords) ..._cameraRecords(muted),
                      if (kept.isNotEmpty)
                        Text(
                          'Also recorded: ${kept.join(', ')} (kept as it was).',
                          key: const Key('blockDialog.kept'),
                          style: muted,
                        ),
                      // Hybrid's Details disclosure (binning and timing), with the
                      // current values in its summary so nothing hides silently.
                      BlockDisclosure(
                        key: const Key('blockDialog.details'),
                        title: 'Details',
                        summary: detailsSummary,
                        open: _details,
                        onToggle: () => setState(() => _details = !_details),
                        children: [
                          ?binning,
                          if (isLight)
                            Text(
                              'Light frames are planned inside the imaging '
                              'window.',
                              style: muted,
                            )
                          else
                            BlockField(
                              label: 'Planned timing',
                              child: DropdownButtonFormField<CalibrationPolicy>(
                                key: const Key('blockDialog.policy'),
                                initialValue: _policy,
                                isExpanded: true, // S7.2b: wraps at 200 % text
                                decoration: const InputDecoration(
                                  helperText:
                                      'Proposed: outside the window, so '
                                      'calibration doesn’t use imaging time.',
                                  helperMaxLines: 3,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: CalibrationPolicy.outsideWindow,
                                    child: Text(
                                      'Outside the window (twilight/dawn)',
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: CalibrationPolicy.inWindow,
                                    child: Text('During the window'),
                                  ),
                                  DropdownMenuItem(
                                    value: CalibrationPolicy.library,
                                    child: Text(
                                      'From your library (no window time)',
                                    ),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v != null) setState(() => _policy = v);
                                },
                              ),
                            ),
                          if (_showCameraRecords && _tintApplies)
                            BlockField(
                              label: 'White balance tint (optional)',
                              child: TextFormField(
                                key: const Key('blockDialog.tint'),
                                controller: _tint,
                                decoration: const InputDecoration(
                                  helperText:
                                      'As the camera shows it; no unit.',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                validator: _validateTint,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          if (origins.isNotEmpty)
                            Text(
                              [
                                'Where the values came from:',
                                for (final e in origins.entries)
                                  '${CaptureSettingsText.field(e.key)}: '
                                      '${CaptureSettingsText.origin(e.value)}',
                              ].join('\n'),
                              key: const Key('blockDialog.origins'),
                              style: muted,
                            ),
                        ],
                      ),
                      Text(
                        'Records describe how you plan to shoot. Culmina does not '
                        'control a camera.',
                        style: muted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Hybrid's editor footer: what Apply does, then the full-width
            // primary action; Cancel stays beside the explanation.
            bottomNavigationBar: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: SafeArea(
                top: false,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppPalette.of(context).border),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            // F06 A7 (AM-02): what the button changes, and what
                            // it does not; no extra confirmation.
                            Expanded(
                              child: Text(
                                // Hybrid's wording ("Apply updates the draft.
                                // Save plan records it."), naming the Undo.
                                widget.initial == null
                                    ? 'Adds to this plan. Save plan records it.'
                                    : 'Changes this plan, with Undo. Save plan '
                                          'records it.',
                                key: const Key('blockDialog.scope'),
                                style: muted,
                              ),
                            ),
                            TextButton(
                              key: const Key('blockDialog.cancel'),
                              onPressed: () {
                                _leaving = true;
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        // S6.9: the editor's primary action; F06 A7: Add block /
                        // Apply changes, never the plan's Save.
                        FilledButton(
                          key: const Key('blockDialog.submit'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(
                              HybridTokens.minTarget,
                            ),
                          ),
                          onPressed: _submit,
                          child: Text(
                            widget.initial == null
                                ? 'Add block'
                                : 'Apply changes',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Hybrid's live total (plan.js integrationText): the light block's
  /// integration, or a calibration block's planned time, which is not
  /// integration; a prompt while exposure or frames are missing.
  String _total() {
    final exposure = _typesExposure
        ? ExposureInput.parse(_exposure.text)
        : _inheritFrom?.exposureTimeSeconds;
    final count = int.tryParse(_count.text.trim());
    if (exposure == null || count == null || count < 1) {
      return 'Enter exposure and frames to see the total.';
    }
    final total = QuantityText.budgetDuration(
      Duration(microseconds: (exposure * count * 1e6).round()),
    );
    return _type == FrameType.light
        ? '= $total of integration'
        : '= $total of planned ${BlockText.type(_type).toLowerCase()} '
              'frames, not integration';
  }

  /// F08: "Take from a photo" and the inline review of what it read.
  List<Widget> _photoReview(TextStyle? muted) {
    final p = _picked;
    // At the binning the block will have: a kept binning other than the
    // file's makes its size unusable (TD-110).
    final mode = p == null ? null : ProposalText.mode(p, binning: _binning);
    return [
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          key: const Key('blockDialog.fromPhoto'),
          onPressed: _reading ? null : _takeFromPhoto,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: Text(p == null ? 'Take from a photo' : 'Another photo'),
        ),
      ),
      if (p == null)
        Text(
          'Reads exposure, ISO or gain, white balance, and a FITS filter '
          'and binning from a DNG, JPEG, HEIC or FITS file on this device; '
          'nothing is saved until you apply the block.',
          style: muted,
        )
      else
        Container(
          key: const Key('blockDialog.review'),
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            [
              ProposalText.title(p),
              if (p.unreadable)
                ProposalText.unreadable(p)
              else ...[
                ProposalText.proposed(p),
                for (final e in p.evidence)
                  ProposalText.evidence(e, unitsOf(context)),
                if (p.file case final f? when !f.read)
                  'Its size counts for storage (mode not read; compressed '
                      'sizes vary with content).',
                ?mode,
                if (_keptYours.isNotEmpty)
                  'Kept what you typed: ${_keptYours.join('; ')}.',
              ],
            ].join('\n'),
            style: muted,
          ),
        ),
    ];
  }

  /// White balance and focus mode, optional records (ADR-021 C1, C3).
  List<Widget> _cameraRecords(TextStyle? muted) => [
    BlockField(
      label: 'White balance (optional)',
      child: DropdownButtonFormField<WhiteBalanceMode?>(
        key: const Key('blockDialog.wbMode'),
        initialValue: _wbMode,
        isExpanded: true,
        decoration: InputDecoration(
          helperText: _from(CaptureField.wb, _wbOrNull()),
        ),
        items: [
          const DropdownMenuItem(value: null, child: Text('Not recorded')),
          for (final m in WhiteBalanceMode.values)
            DropdownMenuItem(
              value: m,
              child: Text(CaptureSettingsText.mode(m)),
            ),
        ],
        onChanged: (m) => setState(() => _wbMode = m),
      ),
    ),
    if (_wbMode == WhiteBalanceMode.preset)
      BlockField(
        label: 'Preset',
        child: DropdownButtonFormField<WhiteBalancePreset>(
          key: const Key('blockDialog.wbPreset'),
          initialValue: _wbPreset,
          isExpanded: true,
          items: [
            for (final p in WhiteBalancePreset.values)
              DropdownMenuItem(
                value: p,
                child: Text(CaptureSettingsText.preset(p)),
              ),
          ],
          onChanged: (p) {
            if (p != null) setState(() => _wbPreset = p);
          },
        ),
      ),
    if (_wbMode == WhiteBalanceMode.kelvin)
      BlockField(
        label: 'Colour temperature (K)',
        child: TextFormField(
          key: const Key('blockDialog.wbKelvin'),
          controller: _kelvin,
          decoration: const InputDecoration(
            hintText: 'e.g. 5600',
            errorMaxLines: 3,
          ),
          keyboardType: TextInputType.number,
          validator: _validateKelvin,
          onChanged: (_) => setState(() {}),
        ),
      ),
    // Hybrid's focus record: a segmented choice (plan.js radioGroup).
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HybridSegmented<FocusMode?>(
          key: const Key('blockDialog.focus'),
          legend: 'Focus mode (optional)',
          keyPrefix: 'blockDialog.focus',
          value: _focus,
          options: const [
            (null, 'Unrecorded', 'none'),
            (FocusMode.af, 'AF', 'af'),
            (FocusMode.mf, 'MF', 'mf'),
          ],
          onChanged: (f) => setState(() => _focus = f),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _from(CaptureField.focusMode, _focus) ??
              (_focus == FocusMode.mf
                  ? 'Manual focus is a record only. Culmina has no '
                        'lens-position value or camera focus control.'
                  : 'A record only; the app does not control the camera.'),
          key: const Key('blockDialog.focusNote'),
          style: muted,
        ),
      ],
    ),
  ];

  /// The ISO or gain as typed, or null while it is empty or invalid.
  CaptureGain? _typedGain() {
    final text = _gainValue.text.trim();
    if (text.isEmpty || _validateGain(text) != null) return null;
    return _gain();
  }

  /// The white balance as currently set, or null while it cannot be built.
  WhiteBalance? _wbOrNull() {
    try {
      return _validateKelvin(_kelvin.text) == null &&
              _validateTint(_tint.text) == null
          ? _whiteBalance()
          : null;
    } on ArgumentError {
      return null;
    }
  }
}
