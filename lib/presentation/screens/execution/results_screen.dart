import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/units/display_units.dart';
import '../../../core/utils/quantity_text.dart';
import '../../../domain/models/calendar_date.dart';
import '../../../domain/models/capture_block.dart';
import '../../../domain/models/session_result.dart';
import '../../../domain/services/session_reconciliation.dart';
import '../../navigation/app_router.dart';
import '../../shared/app_words.dart';
import '../../shared/confirmation_patterns.dart';
import '../../shared/deleted_plan_fallback.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/night_time_formatter.dart';
import '../../shared/opportunity_text.dart';
import '../../shared/plan_state.dart';
import '../../viewmodels/display_settings_viewmodel.dart';
import '../../viewmodels/results_viewmodel.dart';

/// "How did it go?" (S8.2; ADR-019 §3.1, §4): review the saved plan, then
/// Completed as planned · Partly (a number per light block, not ±1; UX-25)
/// · Not done (an optional reason), with optional notes and conditions, and
/// Save result. Leaving changed input asks before discarding it; Back writes
/// nothing. It never asks about the planner's plan.
class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final _form = GlobalKey<FormState>();
  final _environment = TextEditingController();
  final _processing = TextEditingController();
  final _temperature = TextEditingController();
  final _humidity = TextEditingController();
  final _cloud = TextEditingController();
  final _counts = <int, TextEditingController>{};
  ResultOutcome? _outcome;
  NotDoneReason? _reason;
  bool _filled = false;
  bool _fallback = false;
  bool _leaving = false;
  bool _asking = false;
  bool _filling = false;
  List<Object?> _initialInput = const [];

  List<Object?> get _input => [
    _outcome,
    _reason,
    _environment.text,
    _processing.text,
    _temperature.text,
    _humidity.text,
    _cloud.text,
    for (final entry in _counts.entries) (entry.key, entry.value.text),
  ];

  bool get _dirty => _filled && !listEquals(_initialInput, _input);

  Future<void> _leave() async {
    if (_asking || _leaving) return;
    if (_dirty) {
      _asking = true;
      final discard = await confirmDestructive(
        context,
        title: 'Discard result changes?',
        message: 'Your changes to this result have not been saved.',
        action: 'Discard',
      );
      _asking = false;
      if (!mounted || !discard) return;
    }
    if (!mounted) return;
    setState(() => _leaving = true);
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go(AppRouter.sessions);
    }
  }

  /// F21: the temperature is typed in the chosen unit and stored in °C; an
  /// unchanged field keeps the stored value exactly.
  late final DisplayUnits _units =
      context.read<DisplaySettingsViewModel?>()?.units ?? DisplayUnits.metric;
  String _temperatureShown = '';
  double? _temperatureStored;

  @override
  void initState() {
    super.initState();
    context.read<ResultsViewModel?>()?.load(widget.sessionId);
  }

  @override
  void dispose() {
    for (final c in [
      _environment,
      _processing,
      _temperature,
      _humidity,
      _cloud,
      ..._counts.values,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Pre-fills the form once from the stored entry: its outcome and reason,
  /// the counts (a run's confirmed counts, else the plan's), notes and
  /// conditions.
  void _fill(ResultsViewModel vm) {
    final s = vm.session;
    if (_filled || s == null) return;
    _filling = true;
    _filled = true;
    final log = s.record;
    _outcome = vm.onlyNotDone ? ResultOutcome.notDone : vm.storedOutcome;
    _reason = s.notDoneReason;
    final counted = vm.storedOutcome != null;
    for (final b in vm.lightBlocks) {
      (_counts[b.id] ??= TextEditingController()).text =
          '${counted ? vm.confirmedFor(b.id) : b.frameCount}';
    }
    _environment.text = log.environmentalNotes ?? '';
    _processing.text = log.processingNotes ?? '';
    _temperatureStored = log.temperature;
    _temperatureShown = _temperature.text = _text(switch (log.temperature) {
      final c? => double.parse(_units.temperatureOf(c).toStringAsFixed(1)),
      null => null,
    });
    _humidity.text = _text(log.humidity);
    _cloud.text = log.cloudCover?.toString() ?? '';
    _initialInput = _input;
    _filling = false;
  }

  static String _text(double? v) => v == null
      ? ''
      : (v == v.roundToDouble() ? v.round().toString() : v.toString());

  static double? _number(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  static String? Function(String?) _range(
    double min,
    double max,
    String unit,
  ) => (text) {
    if (text == null || text.trim().isEmpty) return null; // optional
    final v = _number(text);
    if (v == null) return 'Enter a number, or leave it empty.';
    if (v < min || v > max) {
      return 'Between ${min.round()} and ${max.round()} $unit.';
    }
    return null;
  };

  static String? _frames(String? text) {
    final v = int.tryParse(text?.trim() ?? '');
    if (v == null || v < 0) return 'Enter the frames you took (0 or more).';
    if (v > 100000) return 'At most 100,000 frames.';
    return null;
  }

  static String? _optional(String text) =>
      text.trim().isEmpty ? null : text.trim();

  ResultReport? _report() {
    final notes = ResultNotes(
      environmentalNotes: _optional(_environment.text),
      processingNotes: _optional(_processing.text),
      temperatureC: _temperature.text == _temperatureShown
          ? _temperatureStored
          : switch (_number(_temperature.text)) {
              final v? => _units.celsiusFrom(v),
              null => null,
            },
      humidityPct: _number(_humidity.text),
      cloudCoverPct: _number(_cloud.text)?.round(),
    );
    return switch (_outcome) {
      null => null,
      ResultOutcome.asPlanned => CompletedAsPlanned(notes: notes),
      ResultOutcome.partly => PartlyDone({
        for (final e in _counts.entries) e.key: int.parse(e.value.text.trim()),
      }, notes: notes),
      ResultOutcome.notDone => NotDone(reason: _reason, notes: notes),
    };
  }

  Future<void> _save(ResultsViewModel vm) async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final report = _report();
    if (report == null) return;
    final loaded = vm.session?.updatedAtUtc;
    final saved = await runWithFeedback(
      context,
      'save the result',
      () => vm.save(report),
    );
    if (!mounted) return;
    if (!saved) {
      // A stale form was reloaded: show the entry as it is now. After any
      // other failure the input stays, to save again (S4-DEF-08).
      if (vm.session?.updatedAtUtc != loaded) setState(() => _filled = false);
      return;
    }
    showDone(context, 'Result saved.');
    context.go(AppRouter.sessions);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ResultsViewModel?>();
    final session = vm?.session;
    // F22 A1: an entry deleted meanwhile (a restored route may name one).
    if (vm?.missingId == widget.sessionId && !_fallback) {
      _fallback = true;
      showDeletedPlanFallback(context);
    }
    if (vm == null || session == null || session.id != widget.sessionId) {
      return Scaffold(
        appBar: hybridAppBar(context, title: const Text('How did it go?')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    // F19 A5: the form fills from the saved plan once its changes are
    // resolved, never from the working edits.
    if (!vm.pendingChanges) _fill(vm);
    final theme = Theme.of(context);
    final gap = const SizedBox(height: AppSpacing.md + AppSpacing.xs);
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): _leave},
      child: Focus(
        autofocus: true,
        skipTraversal: true,
        child: PopScope(
          canPop: !_dirty || _leaving,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _leave();
          },
          child: Scaffold(
            appBar: hybridAppBar(
              context,
              title: const Text('How did it go?'),
              leading: IconButton(
                tooltip: 'Back',
                onPressed: _leave,
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            bottomNavigationBar: !vm.pendingChanges && vm.canRecord
                ? Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.viewInsetsOf(context).bottom,
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                key: const Key('results.cancel'),
                                onPressed: _leave,
                                child: const Text('Cancel'),
                              ),
                            ),
                            FilledButton(
                              key: const Key('results.save'),
                              onPressed: _outcome == null
                                  ? null
                                  : () => _save(vm),
                              child: const Text('Save result'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : null,
            body: Form(
              key: _form,
              onChanged: () {
                if (!_filling) setState(() {});
              },
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  _Review(vm: vm),
                  gap,
                  if (vm.pendingChanges)
                    _PendingChanges(
                      vm: vm,
                      onResolved: () => setState(() => _filled = false),
                    )
                  else if (!vm.canRecord)
                    _NotYet(vm: vm)
                  else ...[
                    if (vm.storedOutcome != null && vm.reconciliation != null)
                      _SoFar(reconciliation: vm.reconciliation!),
                    // F19 A2: finishing early is the user's explicit choice.
                    if (vm.nightUnderWay)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Text(
                          'This night is still under way. Saving a result now '
                          'finishes it early; you can edit the result later.',
                          key: const Key('results.early'),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    Text('How did it go?', style: theme.textTheme.titleMedium),
                    _Outcomes(
                      selected: _outcome,
                      onlyNotDone: vm.onlyNotDone,
                      onSelected: (o) => setState(() => _outcome = o),
                    ),
                    if (_outcome == ResultOutcome.asPlanned)
                      Text(
                        'Records every light block as fully taken. This is your '
                        'report, not a frame count.',
                        key: const Key('results.asPlannedNote'),
                        style: theme.textTheme.bodySmall,
                      ),
                    if (_outcome == ResultOutcome.partly)
                      for (final b in vm.lightBlocks) ...[
                        gap,
                        TextFormField(
                          key: Key('results.count.${b.id}'),
                          controller: _counts[b.id],
                          decoration: InputDecoration(
                            labelText: '${_label(b)} · light frames',
                            helperText: '${b.frameCount} planned',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: _frames,
                        ),
                      ],
                    if (_outcome == ResultOutcome.notDone)
                      _Reasons(
                        selected: _reason,
                        onSelected: (r) => setState(() => _reason = r),
                      ),
                    gap,
                    Text(
                      'Notes (optional)',
                      style: theme.textTheme.titleMedium,
                    ),
                    gap,
                    TextFormField(
                      key: const Key('results.environment'),
                      controller: _environment,
                      decoration: const InputDecoration(
                        labelText: 'Conditions and events',
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                    gap,
                    TextFormField(
                      key: const Key('results.processing'),
                      controller: _processing,
                      decoration: const InputDecoration(
                        labelText: 'Processing notes',
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                    gap,
                    Text(
                      'Conditions (optional)',
                      style: theme.textTheme.titleMedium,
                    ),
                    gap,
                    TextFormField(
                      key: const Key('results.temperature'),
                      controller: _temperature,
                      decoration: InputDecoration(
                        labelText: 'Temperature (${_units.temperature.symbol})',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      // −60…60 °C, in the unit typed.
                      validator:
                          _units.temperature == TemperatureUnit.fahrenheit
                          ? _range(-76, 140, TemperatureUnit.fahrenheit.symbol)
                          : _range(-60, 60, TemperatureUnit.celsius.symbol),
                    ),
                    gap,
                    TextFormField(
                      key: const Key('results.humidity'),
                      controller: _humidity,
                      decoration: const InputDecoration(
                        labelText: 'Relative humidity (%)',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _range(0, 100, '%'),
                    ),
                    gap,
                    TextFormField(
                      key: const Key('results.cloud'),
                      controller: _cloud,
                      decoration: const InputDecoration(
                        labelText: 'Cloud cover (%)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: _range(0, 100, '%'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _label(CaptureBlock b) =>
      '${b.filterName ?? 'Light'} · ${QuantityText.exposure(b.exposureTimeSeconds)}';
}

/// The saved plan under review (ADR-019 §3.1): the snapshot's night, target,
/// site and rig, and the planned light blocks. What it lacks is unavailable,
/// never filled from today's site or rig (SI-008).
class _Review extends StatelessWidget {
  const _Review({required this.vm});

  final ResultsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final s = vm.session!;
    final snap = vm.review;
    final theme = Theme.of(context);
    // TD-086: an unreadable saved plan's row holds the working edits.
    final working = vm.savedPlanUnreadable;
    final night = snap?.eveningDate ?? (working ? null : s.eveningDate);
    String row(String name, String? value) => '$name: ${value ?? 'unknown'}';
    return Card(
      key: const Key('results.review'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Saved plan', style: theme.textTheme.titleMedium),
                PlanStateLabel(
                  PlanState.of(s),
                  key: const Key('results.state'),
                ),
              ],
            ),
            if (snap == null)
              Text(
                "The saved plan's details can't be read.",
                key: const Key('results.reviewUnavailable'),
                style: theme.textTheme.bodySmall,
              ),
            Text(
              row(
                AppWords.night,
                night == null ? null : NightTimeFormatter.eveningDate(night),
              ),
            ),
            Text(
              row(
                'Target',
                snap?.targetName ?? (working ? null : s.record.targetName),
              ),
            ),
            Text(row(AppWords.site, snap?.siteName)),
            Text(row(AppWords.rig, snap?.rigName)),
            for (final b in vm.lightBlocks)
              Text(
                '${_ResultsScreenState._label(b)} · ${b.frameCount} planned',
                key: Key('results.planned.${b.id}'),
              ),
          ],
        ),
      ),
    );
  }
}

/// A saved night that has not started: no result yet (F19 A2; ADR-019
/// §3.1). A future night cannot be reported in advance.
class _NotYet extends StatelessWidget {
  const _NotYet({required this.vm});

  final ResultsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final start = vm.startsAt;
    final zone = vm.review?.timeZoneId ?? vm.session?.timeZoneId;
    // The start's wall date and time, in the saved plan's zone.
    String date(DateTime utc) {
      final w = NightTimeFormatter.wallClock(utc, zoneId: zone);
      return NightTimeFormatter.eveningDate(
        CalendarDate(w.year, w.month, w.day),
      );
    }

    final when = start == null
        ? 'once it begins'
        : 'from ${date(start)}, '
              '${NightTimeFormatter.clockTime(context, start, zoneId: zone)} '
              '(${NightTimeFormatter.zoneCaption(start, zoneId: zone)})';
    return Text(
      "This night hasn't started yet. You can record the result $when.",
      key: const Key('results.notYet'),
    );
  }
}

/// F19 A5: a Saved · changed plan whose night is under way. Its changes are
/// resolved first, so the result is recorded against the exact saved plan:
/// Save (the planner's plan only), Discard, or Cancel (nothing changes).
class _PendingChanges extends StatelessWidget {
  const _PendingChanges({required this.vm, required this.onResolved});

  final ResultsViewModel vm;
  final VoidCallback onResolved;

  @override
  Widget build(BuildContext context) {
    Future<void> run(String action, Future<void> Function() change) async {
      if (await runWithFeedback(context, action, change)) onResolved();
    }

    return Card(
      key: const Key('results.pending'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'This plan changed since it was saved',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              vm.canSaveChanges
                  ? 'Save or discard the changes first: the result is '
                        'recorded against the saved plan.'
                  : 'Discard the changes first: the result is recorded '
                        'against the saved plan. To keep them, open the '
                        'plan and save it.',
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                if (vm.canSaveChanges)
                  FilledButton(
                    key: const Key('results.pending.save'),
                    onPressed: () => run('save the plan', vm.saveChanges),
                    child: const Text('Save changes'),
                  ),
                OutlinedButton(
                  key: const Key('results.pending.discard'),
                  onPressed: () async {
                    final sure = await confirmDestructive(
                      context,
                      title: 'Discard the changes?',
                      message:
                          'The plan goes back to what was saved. The '
                          "changes can't be recovered.",
                      action: 'Discard',
                    );
                    if (sure && context.mounted) {
                      await run('discard the changes', vm.discardChanges);
                    }
                  },
                  child: const Text('Discard changes'),
                ),
                TextButton(
                  key: const Key('results.pending.cancel'),
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRouter.sessions),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Planned vs actual so far (CALC-37), for a run or a result being edited.
class _SoFar extends StatelessWidget {
  const _SoFar({required this.reconciliation});

  final SessionReconciliation reconciliation;

  @override
  Widget build(BuildContext context) {
    final r = reconciliation;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(ResultsText.integration(r), key: const Key('results.summary')),
          if (r.rejectedLightFrames > 0)
            Text(
              '${r.rejectedLightFrames} light frames rejected earlier',
              key: const Key('results.rejected'),
            ),
        ],
      ),
    );
  }
}

class _Outcomes extends StatelessWidget {
  const _Outcomes({
    required this.selected,
    required this.onlyNotDone,
    required this.onSelected,
  });

  final ResultOutcome? selected;
  final bool onlyNotDone;
  final ValueChanged<ResultOutcome> onSelected;

  @override
  Widget build(BuildContext context) {
    Widget chip(ResultOutcome o, String label) => ChoiceChip(
      key: Key('results.outcome.${o.name}'),
      label: Text(label),
      selected: selected == o,
      onSelected: onlyNotDone && o != ResultOutcome.notDone
          ? null
          : (_) => onSelected(o),
    );
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        chip(ResultOutcome.asPlanned, AppWords.completedAsPlanned),
        chip(ResultOutcome.partly, AppWords.partly),
        chip(ResultOutcome.notDone, AppWords.notDone),
      ],
    );
  }
}

/// Not done's optional reason (ADR-019 §4); tapping the chosen one clears it.
class _Reasons extends StatelessWidget {
  const _Reasons({required this.selected, required this.onSelected});

  final NotDoneReason? selected;
  final ValueChanged<NotDoneReason?> onSelected;

  static String _word(NotDoneReason r) => switch (r) {
    NotDoneReason.clouds => 'Clouds',
    NotDoneReason.wind => 'Wind',
    NotDoneReason.dew => 'Dew',
    NotDoneReason.equipment => 'Equipment',
    NotDoneReason.other => 'Other',
  };

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Why? (optional)', style: Theme.of(context).textTheme.bodySmall),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        children: [
          for (final r in NotDoneReason.values)
            ChoiceChip(
              key: Key('results.reason.${r.name}'),
              label: Text(_word(r)),
              selected: selected == r,
              onSelected: (on) => onSelected(on ? r : null),
            ),
        ],
      ),
    ],
  );
}

/// Wording for planned vs actual, shared with the Sessions list.
abstract final class ResultsText {
  static String integration(SessionReconciliation r) =>
      'Integration: ${integrationValue(r)}';

  /// F19 A1: an entry without counts. "Integration: 2 h planned", or
  /// "Integration: none recorded of 2 h planned" once a result is due or
  /// the night was not done.
  static String plannedOnly(SessionReconciliation r, {required bool due}) =>
      'Integration: ${due ? 'none recorded of ' : ''}'
      '${OpportunityText.duration(r.plannedIntegration)} planned';

  /// "1 h 40 min of 2 h planned".
  static String integrationValue(SessionReconciliation r) =>
      '${OpportunityText.duration(r.actualIntegration)} of '
      '${OpportunityText.duration(r.plannedIntegration)} planned';
}
