import 'package:flutter/material.dart';

import '../../shared/document_section.dart';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/hybrid_tokens.dart';
import '../../../core/utils/quantity_text.dart';
import '../../../domain/models/plan_overrides.dart';
import '../../shared/confirmation_patterns.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/hybrid_app_bar.dart';
import '../../shared/hybrid_parts.dart';
import 'block_editor_parts.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';

/// A local edit buffer: typing does not mutate the plan or global settings.
///
/// Hybrid (plan.js `assumptionsView`): a scoped page with the four fields,
/// each with what it is and where its value comes from now or on Apply,
/// "Use global defaults", and Apply changes in the apply bar. Unlike the
/// reference, a field left empty keeps its default (the native plan stores
/// each override on its own).
class PlanOverridesEditor extends StatefulWidget {
  const PlanOverridesEditor({super.key});

  @override
  State<PlanOverridesEditor> createState() => _PlanOverridesEditorState();
}

class _PlanOverridesEditorState extends State<PlanOverridesEditor> {
  final _form = GlobalKey<FormState>();
  final _controllers = List.generate(4, (_) => TextEditingController());
  PlanOverrides? _loaded;
  bool _initialized = false;
  bool _inherit = false;
  bool _saving = false;
  bool _allowPop = false;
  bool _confirming = false;
  List<String> _initialTexts = const [];
  bool get _dirty =>
      _inherit ||
      List.generate(
        4,
        (i) => _controllers[i].text,
      ).indexed.any((entry) => entry.$2 != _initialTexts[entry.$1]);

  void _close() {
    setState(() => _allowPop = true);
    Navigator.of(context).pop();
  }

  /// Close or Back (plan.js `requestCloseScreen`): an unchanged editor
  /// closes; a changed one asks "Discard this edit?" first.
  Future<void> _leave() async {
    if (_saving || _confirming) return;
    if (!_dirty) return _close();
    _confirming = true;
    final discard = await askDiscardEdit(context);
    _confirming = false;
    if (mounted && discard) _close();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final value = context.watch<SessionPlanViewModel>().planOverrides;
    if (!_initialized || !identical(value, _loaded)) {
      _initialized = true;
      _loaded = value;
      final values = [
        value?.interframeSeconds,
        value?.outsideSetupSeconds == null
            ? null
            : value!.outsideSetupSeconds! / 60,
        value?.fixedMarginSeconds == null
            ? null
            : value!.fixedMarginSeconds! / 60,
        value?.bytesPerFrame == null ? null : value!.bytesPerFrame! / 1e6,
      ];
      for (var i = 0; i < values.length; i++) {
        _controllers[i].text = values[i] == null
            ? ''
            : QuantityText.number(values[i]!);
      }
      _initialTexts = _controllers.map((c) => c.text).toList();
      _inherit = false;
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _apply() async {
    if (_saving || !_form.currentState!.validate()) return;
    double? value(int i, [double scale = 1]) {
      if (_controllers[i].text == _initialTexts[i]) {
        return [
          _loaded?.interframeSeconds,
          _loaded?.outsideSetupSeconds,
          _loaded?.fixedMarginSeconds,
          _loaded?.bytesPerFrame,
        ][i];
      }
      final number = double.tryParse(_controllers[i].text.trim());
      return number == null ? null : number * scale;
    }

    final next = _inherit || _controllers.every((c) => c.text.trim().isEmpty)
        ? null
        : PlanOverrides(
            interframeSeconds: value(0),
            outsideSetupSeconds: value(1, 60),
            fixedMarginSeconds: value(2, 60),
            bytesPerFrame: value(3, 1e6),
          );
    setState(() => _saving = true);
    final saved = await runWithFeedback(
      context,
      'apply the plan assumptions',
      () => context.read<SessionPlanViewModel>().setPlanOverrides(next),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (saved) _close();
  }

  @override
  Widget build(BuildContext context) {
    final preferences = context.watch<SettingsViewModel>().planningPreferences;
    final p = AppPalette.of(context);
    // plan.js ASSUMPTION_FIELDS: the label, what it is, its global value.
    const labels = [
      'Time between frames (seconds)',
      'Setup outside the window (minutes)',
      'Fit margin (minutes)',
      'Theoretical file size per frame (MB)',
    ];
    const hints = [
      'Download, dither or settle time added to every frame.',
      'Set-up and alignment done before the imaging window.',
      'Fixed minutes when overridden. The global percentage uses the '
          'usable window.',
      'A planning figure, not measured from your files.',
    ];
    final globals = [
      'Global default, '
          '${QuantityText.number(preferences.perFrameOverheadSeconds)} s',
      preferences.setupMinutes == null
          ? 'Global default, not included'
          : 'Global default, '
                '${QuantityText.number(preferences.setupMinutes!)} min',
      'Global default, '
          '${QuantityText.percent(preferences.feasibilityMarginPercent)} of '
          'the usable window',
      'Your file or rig evidence',
    ];
    final recorded = [
      _loaded?.interframeSeconds,
      _loaded?.outsideSetupSeconds,
      _loaded?.fixedMarginSeconds,
      _loaded?.bytesPerFrame,
    ];
    // plan.js `assumptionFieldSource`: what applies now, or on Apply.
    String source(int i) {
      final text = _controllers[i].text.trim();
      if (_inherit) return '${globals[i]} on Apply';
      if (text != _initialTexts[i]) {
        return text.isEmpty
            ? '${globals[i]} on Apply'
            : 'Plan override on Apply';
      }
      return recorded[i] == null
          ? 'Current: ${globals[i]}'
          : 'Current: Plan override';
    }

    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): _leave},
      child: Focus(
        autofocus: true,
        skipTraversal: true,
        child: PopScope(
          canPop: _allowPop || (!_dirty && !_saving),
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _leave();
          },
          child: Scaffold(
            appBar: hybridAppBar(
              context,
              leading: HybridCloseButton(onPressed: _leave),
              title: const Text('Plan assumptions'),
            ),
            body: HybridPlanInputs(
              child: SingleChildScrollView(
                key: const Key('planOverride.scroll'),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  AppSpacing.itemGap,
                  AppSpacing.gutter,
                  AppSpacing.gutter,
                ),
                child: Form(
                  key: _form,
                  onChanged: () {
                    if (mounted) setState(() => _inherit = false);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // plan.css `.screen-intro`: 14 at 1.6, secondary.
                      Text(
                        _inherit
                            ? 'Apply removes plan overrides. Sources below '
                                  'show what will apply.'
                            : 'Overrides for this plan only. Leave a field '
                                  'empty to use its default.',
                        key: const Key('planOverride.intro'),
                        style: AppTypography.body.copyWith(
                          height: 1.6,
                          color: p.textSecondary,
                        ),
                      ),
                      for (final indices in const [
                        [0, 1, 2],
                        [3],
                      ])
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: DocumentSection(
                            children: [
                              Semantics(
                                header: true,
                                child: Text(
                                  indices.first == 0 ? 'Timing' : 'Storage',
                                  style: AppTypography.sectionHeading.copyWith(
                                    color: p.textPrimary,
                                  ),
                                ),
                              ),
                              for (final i in indices)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: AppSpacing.itemGap,
                                  ),
                                  // Hybrid's label above the field: it wraps at large
                                  // text, so its unit is never cut off. The field
                                  // keeps the label as its accessible name.
                                  child: BlockField(
                                    label: labels[i],
                                    hint: hints[i],
                                    note: source(i),
                                    noteKey: Key('planOverride.source.$i'),
                                    child: TextFormField(
                                      key: Key('planOverride.$i'),
                                      controller: _controllers[i],
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      decoration: const InputDecoration(
                                        errorMaxLines: 3,
                                      ),
                                      validator: (text) {
                                        if (text == null ||
                                            text.trim().isEmpty) {
                                          return null;
                                        }
                                        final number = double.tryParse(
                                          text.trim(),
                                        );
                                        if (number == null ||
                                            !number.isFinite ||
                                            number < 0 ||
                                            (i == 3 && number == 0)) {
                                          return i == 3
                                              ? 'Enter a positive number or leave '
                                                    'empty.'
                                              : 'Enter zero or more, or leave empty.';
                                        }
                                        const maxima = [3600, 720, 720, 10000];
                                        if (number > maxima[i]) {
                                          return 'Enter ${maxima[i]} or less.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      // plan.css `.quiet-button`: 14/500 secondary, 48 tall.
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton(
                          key: const Key('planOverride.reset'),
                          style: TextButton.styleFrom(
                            foregroundColor: p.textSecondary,
                            minimumSize: const Size(0, HybridTokens.minTarget),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.itemGap,
                              vertical: AppSpacing.sm,
                            ),
                            textStyle: AppTypography.body.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: _saving
                              ? null
                              : () {
                                  _form.currentState?.reset();
                                  for (final controller in _controllers) {
                                    controller.clear();
                                  }
                                  setState(() => _inherit = true);
                                },
                          child: const Text('Use global defaults'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: HybridApplyBar(
                buttonKey: const Key('planOverride.apply'),
                label: 'Apply changes',
                onPressed: _saving ? null : _apply,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
