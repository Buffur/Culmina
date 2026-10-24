import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

import '../../shared/document_section.dart';

import 'package:provider/provider.dart';

import '../../../core/utils/astro_math.dart';
import '../../../domain/models/astro_target.dart';
import '../../../domain/models/target_types.dart';
import '../../shared/app_words.dart';
import '../../shared/confirmation_patterns.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/hybrid_app_bar.dart';
import '../../shared/hybrid_parts.dart';
import '../../shared/target_form_input.dart';
import '../../viewmodels/library_viewmodels.dart';
import '../library/library_parts.dart';
import '../settings/settings_parts.dart';

/// Add or edit a target you own (TASK 8.1; library.js `targetForm`): a page
/// of its own with J2000 coordinates; untouched fields keep exactly what is
/// stored. Leaving with changes asks first. Returns the saved target.
Future<AstroTarget?> showTargetEditor(
  BuildContext context, {
  AstroTarget? existing,
}) => Navigator.of(context).push<AstroTarget>(
  MaterialPageRoute(
    // A page over the record, with Back (library.js editors).
    fullscreenDialog: false,
    builder: (_) => TargetEditorScreen(existing: existing),
  ),
);

class TargetEditorScreen extends StatefulWidget {
  const TargetEditorScreen({super.key, this.existing});

  final AstroTarget? existing;

  @override
  State<TargetEditorScreen> createState() => _TargetEditorScreenState();
}

class _TargetEditorScreenState extends State<TargetEditorScreen> {
  final _form = GlobalKey<FormState>();
  late final AstroTarget? _existing = widget.existing;
  late final _name = TextEditingController(
    text: _existing?.commonName ?? _existing?.catalogId ?? '',
  );
  late final _ra = TextEditingController(
    text: _existing == null
        ? ''
        : AstroMath.formatRightAscension(_existing.rightAscension),
  );
  late final _dec = TextEditingController(
    text: _existing == null
        ? ''
        : AstroMath.formatDeclination(_existing.declination),
  );
  late final _size = TextEditingController(
    text: _existing?.angularSizeArcmin?.toString() ?? '',
  );
  late final _mag = TextEditingController(
    text: _existing?.magnitude?.toString() ?? '',
  );

  /// Types the editor offers: fixed-coordinate types only (ADR-010 §3),
  /// plus an existing target's own moving type so an edit never retypes it
  /// silently.
  late final List<String> _types = [
    ...TargetTypes.selectable,
    if (_existing != null && !TargetTypes.selectable.contains(_existing.type))
      _existing.type,
  ];
  late String _type = _existing?.type ?? _types.first;

  // The fields show rounded values (0.1 s, 1″); an untouched field keeps
  // the stored value exactly, so a rename never shifts the coordinates or
  // their provenance.
  late final String _raShown = _ra.text;
  late final String _decShown = _dec.text;
  late final List<String> _initial = _values;
  bool _saving = false;
  bool _leaving = false;

  List<String> get _values => [
    _name.text,
    _type,
    _ra.text,
    _dec.text,
    _size.text,
    _mag.text,
  ];

  bool get _dirty => !_listEquals(_values, _initial);

  static bool _listEquals(List<String> a, List<String> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    for (final c in [_name, _ra, _dec, _size, _mag]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Back or Cancel (library.js `cancelEdit`): a changed editor asks
  /// Cancel · Discard · Save first.
  Future<void> _leave() async {
    if (_dirty) {
      final name = _name.text.trim();
      final choice = await askUnsavedChanges(
        context,
        plan: name.isEmpty ? 'this target' : name,
        library: true,
      );
      if (choice == UnsavedChoice.save && mounted) await _save();
      if (choice != UnsavedChoice.discard || !mounted) return;
    }
    setState(() => _leaving = true);
    Navigator.of(context).pop();
  }

  Future<void> _save() async {
    if (_saving || !(_form.currentState?.validate() ?? false)) return;
    final existing = _existing;
    final target = AstroTarget.userEdit(
      original: existing,
      name: _name.text.trim(),
      type: _type,
      rightAscension: existing != null && _ra.text == _raShown
          ? existing.rightAscension
          : AstroMath.parseRightAscension(_ra.text)!,
      declination: existing != null && _dec.text == _decShown
          ? existing.declination
          : AstroMath.parseDeclination(_dec.text)!,
      angularSizeArcmin: TargetFormInput.optionalNumber(_size.text),
      magnitude: TargetFormInput.optionalNumber(_mag.text),
    );
    final targets = context.read<TargetsViewModel>();
    setState(() => _saving = true);
    var id = target.id;
    final saved = await runWithFeedback(
      context,
      'save the target',
      () async => existing == null
          ? id = await targets.add(target)
          : await targets.update(target),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (!saved) return;
    // S9.8 (D9-5): a save says so.
    showDone(context, 'Target saved');
    setState(() => _leaving = true);
    Navigator.of(context).pop(
      AstroTarget(
        id: id,
        catalogId: target.catalogId,
        commonName: target.commonName,
        rightAscension: target.rightAscension,
        declination: target.declination,
        type: target.type,
        epoch: target.epoch,
        source: target.source,
        angularSizeArcmin: target.angularSizeArcmin,
        magnitude: target.magnitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final existing = _existing;
    final style = libraryInputStyle(context);
    const decimal = TextInputType.numberWithOptions(decimal: true);
    return PopScope(
      canPop: _leaving || !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        appBar: hybridAppBar(
          context,
          title: Text(existing == null ? 'Add target' : AppWords.editTarget),
        ),
        bottomNavigationBar: LibrarySaveBar(
          saveKey: const Key('targetEditor.save'),
          cancelKey: const Key('targetEditor.cancel'),
          saveLabel: 'Save target',
          onCancel: _saving ? null : _leave,
          onSave: _saving ? null : _save,
        ),
        body: Form(
          key: _form,
          onChanged: () => setState(() {}),
          child: HybridPlanInputs(
            child: SingleChildScrollView(
              key: const Key('targetEditor.scroll'),
              padding: settingsPagePadding,
              // Every field is built, so Save validates them all.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DocumentSection(
                    key: const Key('targetEditor.identityGroup'),
                    children: [
                      SettingsCopy(
                        '${existing == null ? '' : 'Catalogue id: ${existing.catalogId}. '}'
                        'Coordinates are J2000. '
                        '${existing == null ? 'Optional fields left empty stay unknown.' : 'Values you leave untouched keep exactly what is stored.'}',
                      ),
                      LibraryField(
                        label: 'Name',
                        child: TextFormField(
                          key: const Key('targetEditor.name'),
                          controller: _name,
                          style: style,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Andromeda Galaxy',
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      LibraryField(
                        label: 'Object type',
                        hint: TargetTypes.isMoving(_type)
                            ? TargetTypes.movingWarning
                            : 'New targets have fixed coordinates; moving objects '
                                  'are not offered.',
                        child: DropdownButtonFormField<String>(
                          key: const Key('targetEditor.type'),
                          // F25 A1: a long type wraps instead of overflowing at
                          // large text.
                          isExpanded: true,
                          initialValue: _type,
                          style: style,
                          icon: hybridSelectIcon(context),
                          decoration: const InputDecoration(
                            contentPadding: hybridSelectPadding,
                          ),
                          items: [
                            for (final t in _types)
                              DropdownMenuItem(
                                value: t,
                                child: Text(t, overflow: TextOverflow.ellipsis),
                              ),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _type = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DocumentSection(
                    key: const Key('targetEditor.positionGroup'),
                    children: [
                      LibraryField(
                        label: 'Right ascension (J2000)',
                        top: 0,
                        hint:
                            'Hours 0–24 (a bare number is hours), or degrees with '
                            '°: 83.82°',
                        child: TextFormField(
                          key: const Key('targetEditor.ra'),
                          controller: _ra,
                          style: style,
                          decoration: const InputDecoration(
                            hintText: '05h35m17s, 5:35:17 or 5.588 h',
                          ),
                          validator: TargetFormInput.validateRightAscension,
                        ),
                      ),
                      LibraryField(
                        label: 'Declination (J2000)',
                        hint: 'Degrees, −90 to +90',
                        child: TextFormField(
                          key: const Key('targetEditor.dec'),
                          controller: _dec,
                          style: style,
                          decoration: const InputDecoration(
                            hintText: '−05°23′28″, -5:23:28 or -5.39',
                          ),
                          validator: TargetFormInput.validateDeclination,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DocumentSection(
                    key: const Key('targetEditor.optionalGroup'),
                    children: [
                      LibraryField(
                        label: 'Apparent size (arcmin, optional)',
                        top: 0,
                        hint: 'Above 0, at most 3000′. Empty is unknown.',
                        child: TextFormField(
                          key: const Key('targetEditor.size'),
                          controller: _size,
                          style: style,
                          keyboardType: decimal,
                          validator: TargetFormInput.validateAngularSize,
                        ),
                      ),
                      LibraryField(
                        label: 'Magnitude (optional)',
                        hint: '−30 to 30. Empty is unknown.',
                        child: TextFormField(
                          key: const Key('targetEditor.magnitude'),
                          controller: _mag,
                          style: style,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          validator: TargetFormInput.validateMagnitude,
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
  }
}
