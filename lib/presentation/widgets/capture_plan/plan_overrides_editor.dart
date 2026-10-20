import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/plan_overrides.dart';
import '../../../core/utils/quantity_text.dart';
import '../../shared/confirmation_patterns.dart';
import '../../shared/failure_feedback.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';

/// A local edit buffer: typing does not mutate the plan or global settings.
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

  Future<void> _leave() async {
    if (_saving || _confirming) return;
    if (!_dirty) return _close();
    _confirming = true;
    final choice = await askUnsavedChanges(context, plan: 'Plan assumptions');
    _confirming = false;
    if (!mounted) return;
    switch (choice) {
      case UnsavedChoice.cancel:
        return;
      case UnsavedChoice.discard:
        _close();
      case UnsavedChoice.save:
        await _apply();
    }
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
    final labels = [
      'Time between frames (seconds)',
      'Setup outside the window (minutes)',
      'Fit margin (minutes)',
      'Theoretical file size per frame (MB)',
    ];
    final hints = [
      'Global: ${preferences.perFrameOverheadSeconds} s',
      preferences.setupMinutes == null
          ? 'Global: not included'
          : 'Global: ${preferences.setupMinutes!} min',
      'Global: ${preferences.feasibilityMarginPercent}%',
      'Use file / rig evidence',
    ];
    return PopScope(
      canPop: _allowPop || (!_dirty && !_saving),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        appBar: hybridAppBar(context, title: const Text('Plan assumptions')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _form,
            onChanged: () {
              if (mounted) setState(() => _inherit = false);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This plan only',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Optional overrides. Leave a field empty to use its default. '
                  'A fixed margin replaces the global percentage; setup stays '
                  'outside the imaging window. File size is an estimate.',
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 20,
                      children: [
                        for (var i = 0; i < 4; i++)
                          SizedBox(
                            width: width,
                            child: TextFormField(
                              key: Key('planOverride.$i'),
                              controller: _controllers[i],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: labels[i],
                                helperText: hints[i],
                                helperMaxLines: 3,
                                errorMaxLines: 3,
                              ),
                              validator: (text) {
                                if (text == null || text.trim().isEmpty) {
                                  return null;
                                }
                                final number = double.tryParse(text.trim());
                                if (number == null ||
                                    !number.isFinite ||
                                    number < 0 ||
                                    (i == 3 && number == 0)) {
                                  return i == 3
                                      ? 'Enter a positive number or leave empty.'
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
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  key: const Key('planOverride.reset'),
                  onPressed: _saving
                      ? null
                      : () {
                          _form.currentState?.reset();
                          for (final controller in _controllers) {
                            controller.clear();
                          }
                          setState(() => _inherit = true);
                        },
                  child: const Text('Use defaults'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 12,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: _saving ? null : _leave,
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    key: const Key('planOverride.apply'),
                    onPressed: _saving ? null : _apply,
                    child: const Text('Apply to this plan'),
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
