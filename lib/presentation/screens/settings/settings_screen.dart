import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/hybrid_tokens.dart';
import '../../../core/config/app_identity.dart';
import '../../../domain/models/planning_preferences.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../navigation/app_router.dart';
import '../../shared/field_mode_button.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/confirmation_patterns.dart';
import 'backup_section.dart';
import 'display_settings_section.dart';
import '../../shared/display_units_of.dart';
import '../../../core/utils/quantity_text.dart';
import '../../viewmodels/display_settings_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';

enum SettingsSection {
  appearance('Appearance'),
  planning('Planning'),
  privacy('Privacy'),
  backup('Backup & data');

  const SettingsSection(this.title);
  final String title;
}

/// Settings (TASK 5.2, SI-006, TD-043; rebuilt by S9.4 after RG-13's
/// research, `docs/refinement/research/S9.3_SETTINGS.md` §4, D9-3).
///
/// Sections by what a value changes: the imaging window, the fit and
/// capture time, advice only, then the display, privacy, data and About.
/// Each row shows its value with its unit and its consequence. Every value
/// is a preference with a documented default, not a scientific law; the
/// screen only edits [PlanningPreferences] through the ViewModel, and every
/// calculation stays in the domain.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.overPlan = false, this.section});

  /// The Hybrid root groups existing settings into focused native pages.
  final SettingsSection? section;

  /// Opened over the plan by "Change in Settings" (F12; UX-S R3): the
  /// planning settings only, with their global scope said; Back returns to
  /// the plan.
  final bool overPlan;

  /// The collapsed advanced group's facts: "Gates: 0 of 2 on · optional
  /// times: 1 of 5 included".
  static String advancedSummary(PlanningPreferences p) {
    final gates = [p.moonGateEnabled, p.cloudGateEnabled].where((on) => on);
    final times = [
      p.ditherEveryNFrames,
      p.refocusEveryMinutes,
      p.filterChangeSeconds,
      p.meridianFlipSeconds,
      p.setupMinutes,
    ].where((v) => v != null);
    return 'Gates: ${gates.length} of 2 on · optional times: '
        '${times.length} of 5 included';
  }

  static const scopeNotice =
      'These settings apply to every plan, including the one you came from: '
      'its budget and fit update when you save. Each saved plan keeps a '
      'copy of the values it was saved with. Back returns to your plan.';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PlanningPreferences? _draft;
  PlanningPreferences? _initial;
  bool _saving = false;
  bool _allowPop = false;
  bool _confirming = false;

  bool get overPlan => widget.overPlan;
  SettingsSection? get section => widget.section;
  bool get _planning => overPlan || section == SettingsSection.planning;
  bool get _dirty => _draft != _initial;

  void _close() {
    if (!mounted) return;
    setState(() => _allowPop = true);
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  Future<void> _cancel() async {
    if (_saving || _confirming) return;
    if (_dirty) {
      _confirming = true;
      final discard = await confirmDestructive(
        context,
        title: 'Discard your changes?',
        message: 'Planning settings stay as they were before these edits.',
        action: 'Discard',
      );
      _confirming = false;
      if (!discard || !mounted) return;
    }
    _close();
  }

  Future<void> _save(SettingsViewModel vm) async {
    if (_saving) return;
    if (!_dirty && !vm.planningPreferencesUnsaved) {
      _close();
      return;
    }
    setState(() => _saving = true);
    final saved = await runWithFeedback(
      context,
      'save the planning settings',
      () => vm.setPlanningPreferences(_draft!),
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      // Preserve the existing write contract: a failed committed Save remains
      // applied in this process and is explicitly unsaved, with Retry.
      _initial = vm.planningPreferences;
    });
    if (saved) {
      showDone(context, 'Planning defaults saved');
      _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsVm = context.watch<SettingsViewModel>();
    if (_planning && _draft == null) {
      _initial = _draft = settingsVm.planningPreferences;
    }
    final p = _planning ? _draft! : settingsVm.planningPreferences;
    void update(PlanningPreferences next) => setState(() => _draft = next);
    final small = Theme.of(context).textTheme.bodySmall;

    if (!overPlan && section == null) {
      return _SettingsIndex(
        preferences: p,
        placeNames: settingsVm.placeNameLookup,
      );
    }
    final planning = _planning;
    return PopScope(
      canPop: !planning || _allowPop || (!_dirty && !_saving),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && planning) _cancel();
      },
      child: Scaffold(
        appBar: hybridAppBar(
          context,
          title: Text(overPlan ? 'Planning settings' : section!.title),
          actions: const [FieldModeButton()],
        ),
        body: AbsorbPointer(
          absorbing: _saving,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              if (planning) ...[
                if (overPlan)
                  Card(
                    key: const Key('settings.scope'),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(SettingsScreen.scopeNotice),
                    ),
                  ),
                // F21 A5: an edit that is applied but not stored says so.
                if (settingsVm.planningPreferencesUnsaved)
                  _PlanningUnsaved(
                    onRetry: () => runWithFeedback(
                      context,
                      'save the settings',
                      settingsVm.retryPlanningPreferences,
                    ),
                  ),
                Text(
                  'These are planning preferences, not scientific laws. The '
                  'defaults are common rules of thumb; adjust them to your sky, '
                  'your targets and your rig.',
                  style: small,
                ),
                const _Section(
                  'Capture budget',
                  'Changes the capture budget and the fit verdict.',
                ),
                _SliderTile(
                  key: const Key('settings.perFrame'),
                  // S7.2b (ADR-020 §4, I1): the one interval concept, relabelled.
                  title: 'Time between frames',
                  help:
                      'From the end of one frame to the start of the next: '
                      'download, processing and any delay you set (a camera '
                      "timer's start-to-start interval minus the exposure). "
                      'Dither settling is counted separately. An assumption — '
                      'measure your rig.',
                  value: p.perFrameOverheadSeconds,
                  // S9.4: the model's range (0–120 s), not a narrower one.
                  range: PlanningPreferences.perFrameRange,
                  divisions: 120,
                  label: '${p.perFrameOverheadSeconds.round()} s',
                  format: (v) => '${v.round()} s',
                  onChanged: (v) =>
                      update(p.copyWith(perFrameOverheadSeconds: v)),
                ),
                _SliderTile(
                  key: const Key('settings.margin'),
                  title: 'Feasibility margin',
                  help:
                      'A plan that leaves less than this share of the usable time '
                      'free shows as Tight.',
                  value: p.feasibilityMarginPercent,
                  range: PlanningPreferences.marginRange,
                  divisions: 50,
                  label: QuantityText.percent(p.feasibilityMarginPercent),
                  format: QuantityText.percent,
                  onChanged: (v) =>
                      update(p.copyWith(feasibilityMarginPercent: v)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(
                    'Save applies these defaults. Saved plans keep their recorded '
                    'values until you save changes to the plan.',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppPalette.of(context).textSecondary),
                  ),
                ),
                const _Section(
                  'Imaging window',
                  'Changes when the planner counts time as usable.',
                ),
                _SliderTile(
                  key: const Key('settings.minAltitude'),
                  title: 'Minimum target altitude',
                  help:
                      'Below this the target is not counted as usable. Low '
                      'altitude means more atmosphere, extinction and poor seeing.',
                  value: p.minAltitudeDeg,
                  range: PlanningPreferences.minAltitudeRange,
                  divisions: 55,
                  label: QuantityText.degrees(p.minAltitudeDeg),
                  format: QuantityText.degrees,
                  onChanged: (v) => update(p.copyWith(minAltitudeDeg: v)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Darkness limit (Sun altitude)'),
                  subtitle: const Text(
                    '−18° is full astronomical darkness. −15° or −12° give longer '
                    'windows with a brighter sky background.',
                  ),
                  trailing: Text(QuantityText.degrees(p.darknessLimit.degrees)),
                ),
                SegmentedButton<DarknessLimit>(
                  key: const Key('settings.darknessLimit'),
                  direction: MediaQuery.textScalerOf(context).scale(14) > 21
                      ? Axis.vertical
                      : Axis.horizontal,
                  segments: [
                    for (final l in DarknessLimit.values)
                      ButtonSegment(
                        value: l,
                        label: Text(QuantityText.degrees(l.degrees)),
                      ),
                  ],
                  selected: {p.darknessLimit},
                  onSelectionChanged: (s) =>
                      update(p.copyWith(darknessLimit: s.first)),
                ),
                const SizedBox(height: AppSpacing.sm),
                // F12 (AM-01; SP11): the optional gates and times, collapsed.
                const _Section(
                  'Advanced',
                  'Optional gates and times. When on, they change the imaging '
                      'window, the capture budget and the fit.',
                ),
                ExpansionTile(
                  key: const Key('settings.advanced'),
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  title: const Text('Gates and optional times'),
                  subtitle: Text(SettingsScreen.advancedSummary(p)),
                  children: [
                    // RD-11 = S9, TD-050: the optional gates of ADR-013 (G4, G5).
                    _GateTile(
                      key: const Key('settings.moonGate'),
                      title: 'Moon gate',
                      enabled: p.moonGateEnabled,
                      percent: p.moonGateMinIlluminationPct,
                      on: (pct) =>
                          'Excludes time when the Moon is up and at least $pct lit.',
                      off: 'Off: the Moon never excludes time.',
                      onToggle: (on) => update(p.copyWith(moonGateEnabled: on)),
                      onPercent: (v) =>
                          update(p.copyWith(moonGateMinIlluminationPct: v)),
                    ),
                    _GateTile(
                      key: const Key('settings.cloudGate'),
                      title: 'Cloud gate',
                      enabled: p.cloudGateEnabled,
                      percent: p.cloudGateMaxPct,
                      on: (pct) =>
                          'Excludes forecast hours with more than $pct cloud. An hour '
                          'without a forecast is never excluded.',
                      off: 'Off: the forecast never excludes time.',
                      onToggle: (on) =>
                          update(p.copyWith(cloudGateEnabled: on)),
                      onPercent: (v) => update(p.copyWith(cloudGateMaxPct: v)),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Optional overheads. Off: the plan leaves this time out, so '
                      'your night may take longer than shown. On: it is added to the '
                      'capture plan\'s budget and fit. The values are assumptions — '
                      'measure your rig.',
                      style: small,
                    ),
                    _OptionalOverhead(
                      key: const Key('settings.dither'),
                      title: 'Dither',
                      enabled: p.ditherEveryNFrames != null,
                      summary: p.ditherEveryNFrames == null
                          ? 'Not included'
                          : 'Every ${p.ditherEveryNFrames} lights, '
                                '${p.ditherSettleSeconds.round()} s to settle each',
                      onToggle: (on) => update(
                        p.withOptionalOverheads(
                          ditherEveryNFrames: (on ? 3 : null,),
                        ),
                      ),
                      steppers: [
                        if (p.ditherEveryNFrames case final n?)
                          _Stepper(
                            key: const Key('settings.dither.every'),
                            label: 'Every',
                            value: n.toDouble(),
                            range: (1, 100),
                            step: 1,
                            format: (v) => '${v.round()} lights',
                            onChanged: (v) => update(
                              p.withOptionalOverheads(
                                ditherEveryNFrames: (v.round(),),
                              ),
                            ),
                          ),
                        if (p.ditherEveryNFrames != null)
                          _Stepper(
                            key: const Key('settings.dither.settle'),
                            label: 'Settle',
                            value: p.ditherSettleSeconds,
                            range: PlanningPreferences.overheadSecondsRange,
                            step: 5,
                            format: (v) => '${v.round()} s',
                            onChanged: (v) =>
                                update(p.copyWith(ditherSettleSeconds: v)),
                          ),
                      ],
                    ),
                    _OptionalOverhead(
                      key: const Key('settings.refocus'),
                      title: 'Refocus',
                      enabled: p.refocusEveryMinutes != null,
                      summary: p.refocusEveryMinutes == null
                          ? 'Not included'
                          : 'Every ${p.refocusEveryMinutes!.round()} min, '
                                '${p.refocusSeconds.round()} s each',
                      onToggle: (on) => update(
                        p.withOptionalOverheads(
                          refocusEveryMinutes: (on ? 60.0 : null,),
                        ),
                      ),
                      steppers: [
                        if (p.refocusEveryMinutes case final every?)
                          _Stepper(
                            key: const Key('settings.refocus.every'),
                            label: 'Every',
                            value: every,
                            range: PlanningPreferences.refocusIntervalRange,
                            step: 10,
                            format: (v) => '${v.round()} min',
                            onChanged: (v) => update(
                              p.withOptionalOverheads(
                                refocusEveryMinutes: (v,),
                              ),
                            ),
                          ),
                        if (p.refocusEveryMinutes != null)
                          _Stepper(
                            key: const Key('settings.refocus.duration'),
                            label: 'Takes',
                            value: p.refocusSeconds,
                            range: PlanningPreferences.overheadSecondsRange,
                            step: 10,
                            format: (v) => '${v.round()} s',
                            onChanged: (v) =>
                                update(p.copyWith(refocusSeconds: v)),
                          ),
                      ],
                    ),
                    _OptionalOverhead(
                      key: const Key('settings.filterChange'),
                      title: 'Filter change',
                      enabled: p.filterChangeSeconds != null,
                      summary: p.filterChangeSeconds == null
                          ? 'Not included'
                          : '${p.filterChangeSeconds!.round()} s per change',
                      onToggle: (on) => update(
                        p.withOptionalOverheads(
                          filterChangeSeconds: (on ? 30.0 : null,),
                        ),
                      ),
                      steppers: [
                        if (p.filterChangeSeconds case final s?)
                          _Stepper(
                            key: const Key('settings.filterChange.seconds'),
                            label: 'Takes',
                            value: s,
                            range: PlanningPreferences.overheadSecondsRange,
                            step: 5,
                            format: (v) => '${v.round()} s',
                            onChanged: (v) => update(
                              p.withOptionalOverheads(
                                filterChangeSeconds: (v,),
                              ),
                            ),
                          ),
                      ],
                    ),
                    _OptionalOverhead(
                      key: const Key('settings.flip'),
                      title: 'Meridian flip',
                      enabled: p.meridianFlipSeconds != null,
                      summary: p.meridianFlipSeconds == null
                          ? 'Not included'
                          : '${QuantityText.duration(Duration(seconds: p.meridianFlipSeconds!.round()))}, '
                                'once, when the target crosses the meridian',
                      onToggle: (on) => update(
                        p.withOptionalOverheads(
                          meridianFlipSeconds: (on ? 300.0 : null,),
                        ),
                      ),
                      steppers: [
                        if (p.meridianFlipSeconds case final s?)
                          _Stepper(
                            key: const Key('settings.flip.seconds'),
                            label: 'Takes',
                            value: s,
                            range: PlanningPreferences.flipSecondsRange,
                            step: 30,
                            format: (v) => '${v.round()} s',
                            onChanged: (v) => update(
                              p.withOptionalOverheads(
                                meridianFlipSeconds: (v,),
                              ),
                            ),
                          ),
                      ],
                    ),
                    _OptionalOverhead(
                      key: const Key('settings.setup'),
                      title: 'Setup before the first window',
                      enabled: p.setupMinutes != null,
                      summary: p.setupMinutes == null
                          ? 'Not included'
                          : '${p.setupMinutes!.round()} min, in the total time only',
                      onToggle: (on) => update(
                        p.withOptionalOverheads(
                          setupMinutes: (on ? 30.0 : null,),
                        ),
                      ),
                      steppers: [
                        if (p.setupMinutes case final m?)
                          _Stepper(
                            key: const Key('settings.setup.minutes'),
                            label: 'Takes',
                            value: m,
                            range: PlanningPreferences.setupMinutesRange,
                            step: 5,
                            format: (v) => '${v.round()} min',
                            onChanged: (v) => update(
                              p.withOptionalOverheads(setupMinutes: (v,)),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const _Section(
                  'Guidance',
                  'Changes advice only; never the imaging window or the fit.',
                ),
                _SliderTile(
                  key: const Key('settings.npfK'),
                  title: 'NPF star-trail tolerance (k)',
                  help:
                      'For untracked exposures (Michaud NPF rule): 1 = round stars, '
                      'up to 3 = slightly elongated. Higher allows longer '
                      'sub-exposures.',
                  value: p.npfK,
                  range: PlanningPreferences.npfKRange,
                  divisions: 4,
                  label: 'k = ${p.npfK.toStringAsFixed(1)}',
                  format: (v) => v.toStringAsFixed(1),
                  onChanged: (v) => update(p.copyWith(npfK: v)),
                ),
                _SliderTile(
                  key: const Key('settings.dewMargin'),
                  title: 'Dew warning margin',
                  help:
                      'Warn when the air temperature is within this margin of the '
                      'dew point.',
                  value: p.dewMarginC,
                  range: PlanningPreferences.dewMarginRange,
                  divisions: 20,
                  // F21 A3: a temperature difference (2 °C = 3.6 °F).
                  label: QuantityText.temperatureDifference(
                    p.dewMarginC,
                    unitsOf(context),
                  ),
                  format: (v) =>
                      QuantityText.temperatureDifference(v, unitsOf(context)),
                  onChanged: (v) => update(p.copyWith(dewMarginC: v)),
                ),
              ],
              if (!overPlan && section == SettingsSection.appearance) ...[
                const _Section(
                  'Display',
                  'How the app looks and the units it shows; no value changes.',
                ),
                const FieldModeTile(),
                const DisplaySettingsSection(),
              ],
              if (!overPlan && section == SettingsSection.privacy) ...[
                const _Section('Privacy', 'What leaves this device.'),
                // TASK 16.3 (owner decision): opt-in, off by default.
                SwitchListTile(
                  key: const Key('settings.placeNames'),
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.place_outlined),
                  title: const Text('Look up place names'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sends the chosen position to OpenStreetMap Nominatim to '
                        'show a place name. Off: positions are shown as coordinates '
                        'and nothing is sent.',
                      ),
                      // F21 A6: Off is applied but not stored; say so, with Retry.
                      if (settingsVm.placeNameLookupUnsaved) ...[
                        Text(
                          'Off for now, but not saved: after a restart place '
                          'names would be on again.',
                          key: const Key('settings.placeNames.unsaved'),
                          style: small?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        TextButton(
                          key: const Key('settings.placeNames.retry'),
                          onPressed: () => runWithFeedback(
                            context,
                            'save the place-name setting',
                            () => settingsVm.setPlaceNameLookup(false),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ],
                  ),
                  value: settingsVm.placeNameLookup,
                  onChanged: (on) => runWithFeedback(
                    context,
                    'save the place-name setting',
                    () => settingsVm.setPlaceNameLookup(on),
                  ),
                ),
              ],
              if (!overPlan && section == SettingsSection.backup) ...[
                const _Section(
                  'Data',
                  'Your plans, results, sites, rigs, targets and these settings.',
                ),
                // TASK 14.4: backup and restore.
                const BackupSection(),
              ],
            ],
          ),
        ),
        bottomNavigationBar: planning
            ? SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _saving
                            ? 'Saving…'
                            : _dirty
                            ? 'Changed · not saved'
                            : settingsVm.planningPreferencesUnsaved
                            ? 'Applied · not saved'
                            : 'No changes',
                        key: const Key('settings.draftState'),
                        style: small,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              key: const Key('settings.cancelPlanning'),
                              onPressed: _saving ? null : _cancel,
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: FilledButton(
                              key: const Key('settings.savePlanning'),
                              onPressed: _saving
                                  ? null
                                  : () => _save(settingsVm),
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class _SettingsIndex extends StatelessWidget {
  const _SettingsIndex({required this.preferences, required this.placeNames});

  final PlanningPreferences preferences;
  final bool placeNames;

  @override
  Widget build(BuildContext context) {
    final display = context.watch<DisplaySettingsViewModel?>();
    final fieldMode = context.watch<ThemeViewModel?>()?.isFieldMode ?? false;
    final p = preferences;
    Widget row({
      required String title,
      required String subtitle,
      required IconData icon,
      required VoidCallback onTap,
      required String id,
    }) => Column(
      children: [
        ListTile(
          key: Key('settings.open.$id'),
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontSize: 14),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
    void open(SettingsSection section) {
      // Hybrid opens a Settings group as a detail screen above the tabs,
      // like Plan and Night/Moon/Weather (no root navigation underneath).
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          settings: RouteSettings(name: '/settings/${section.name}'),
          builder: (_) => SettingsScreen(section: section),
        ),
      );
    }

    final units = display?.units;
    return Scaffold(
      appBar: hybridAppBar(
        context,
        title: const Text('Settings'),
        actions: const [FieldModeButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Semantics(
            header: true,
            child: Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          row(
            id: 'appearance',
            title: 'Appearance',
            subtitle: units == null
                ? 'Theme, field mode and display units'
                : '${fieldMode ? 'Red field mode' : display!.appearance.label} · ${units.temperature.symbol} · ${units.wind.symbol} · ${units.elevation.symbol}',
            icon: Icons.dark_mode_outlined,
            onTap: () => open(SettingsSection.appearance),
          ),
          row(
            id: 'planning',
            title: 'Planning',
            subtitle:
                '${QuantityText.degrees(p.minAltitudeDeg)} altitude · '
                '${QuantityText.percent(p.feasibilityMarginPercent)} margin · '
                '${p.perFrameOverheadSeconds.round()} s between frames · '
                '${QuantityText.degrees(p.darknessLimit.degrees)} Sun',
            icon: Icons.tune_outlined,
            onTap: () => open(SettingsSection.planning),
          ),
          row(
            id: 'privacy',
            title: 'Privacy',
            subtitle: 'Place-name lookup ${placeNames ? 'on' : 'off'}',
            icon: Icons.place_outlined,
            onTap: () => open(SettingsSection.privacy),
          ),
          const SizedBox(height: AppSpacing.lg),
          Semantics(
            header: true,
            child: Text(
              'Data and about',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          row(
            id: 'backup',
            title: 'Backup & data',
            subtitle: 'Back up or restore plans, results and your library',
            icon: Icons.file_download_outlined,
            onTap: () => open(SettingsSection.backup),
          ),
          row(
            id: 'about',
            title: 'About & data sources',
            subtitle:
                '${AppIdentity.appName} ${AppIdentity.version} · sources and licences',
            icon: Icons.info_outline,
            onTap: () => context.push(AppRouter.about),
          ),
        ],
      ),
    );
  }
}

/// A section heading and one line saying what its values change (S9.4).
class _Section extends StatelessWidget {
  const _Section(this.title, this.consequence);
  final String title;
  final String consequence;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, child: Text(title, style: text.titleMedium)),
          Text(consequence, style: text.bodySmall),
        ],
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    super.key,
    required this.title,
    required this.help,
    required this.value,
    required this.range,
    required this.divisions,
    required this.label,
    required this.format,
    required this.onChanged,
  });

  final String title;
  final String help;
  final double value;
  final (double, double) range;
  final int divisions;
  final String label;

  /// Writes the range's ends under the slider, in the value's own form.
  final String Function(double) format;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final secondary = AppPalette.of(context).textSecondary;
    // Hybrid's settings row (settings.css): the name and its value on one
    // line, the explanation below, the slider, then the range's ends.
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: AppSpacing.sm,
            children: [
              Text(title, style: text.titleSmall),
              Text(
                label,
                style: text.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(help, style: text.bodySmall?.copyWith(color: secondary)),
          HybridSlider(
            slider: Slider(
              value: value.clamp(range.$1, range.$2),
              min: range.$1,
              max: range.$2,
              divisions: divisions,
              label: label,
              onChanged: onChanged,
            ),
          ),
          ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final end in [range.$1, range.$2])
                  Text(
                    format(end),
                    style: text.bodySmall?.copyWith(color: secondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// An optional ADR-013 gate (S9.4; TD-050): a switch with its consequence,
/// and its percentage when on.
class _GateTile extends StatelessWidget {
  const _GateTile({
    super.key,
    required this.title,
    required this.enabled,
    required this.percent,
    required this.on,
    required this.off,
    required this.onToggle,
    required this.onPercent,
  });

  final String title;
  final bool enabled;
  final double percent;
  final String Function(String percent) on;
  final String off;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onPercent;

  @override
  Widget build(BuildContext context) {
    final label = QuantityText.percent(percent);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title),
          subtitle: Text(enabled ? on(label) : off),
          value: enabled,
          onChanged: onToggle,
        ),
        if (enabled)
          HybridSlider(
            slider: Slider(
              value: percent.clamp(0, 100),
              min: PlanningPreferences.gatePctRange.$1,
              max: PlanningPreferences.gatePctRange.$2,
              divisions: 20,
              label: label,
              onChanged: onPercent,
            ),
          ),
      ],
    );
  }
}

class _OptionalOverhead extends StatelessWidget {
  const _OptionalOverhead({
    super.key,
    required this.title,
    required this.enabled,
    required this.summary,
    required this.onToggle,
    this.steppers = const [],
  });

  final String title;
  final bool enabled;
  final String summary;
  final ValueChanged<bool> onToggle;

  /// Its values, editable while it is on (S9.4, D9-3).
  final List<Widget> steppers;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title),
        subtitle: Text(summary),
        value: enabled,
        onChanged: onToggle,
      ),
      ...steppers,
    ],
  );
}

/// One value, stepped within the model's [range] (S9.4): "Every  − 3 lights +".
class _Stepper extends StatelessWidget {
  const _Stepper({
    super.key,
    required this.label,
    required this.value,
    required this.range,
    required this.step,
    required this.format,
    required this.onChanged,
  });

  final String label;
  final double value;
  final (double, double) range;
  final double step;
  final String Function(double) format;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final shown = format(value);
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.md),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          IconButton(
            tooltip: '$label: less',
            icon: const Icon(Icons.remove),
            onPressed: value > range.$1
                ? () => onChanged((value - step).clamp(range.$1, range.$2))
                : null,
          ),
          Semantics(liveRegion: true, child: Text(shown)),
          IconButton(
            tooltip: '$label: more',
            icon: const Icon(Icons.add),
            onPressed: value < range.$2
                ? () => onChanged((value + step).clamp(range.$1, range.$2))
                : null,
          ),
        ],
      ),
    );
  }
}

/// F21 A5: the newest planning edit is applied but not stored (a failed
/// write, or a save before a restart that did not finish), with Retry.
class _PlanningUnsaved extends StatelessWidget {
  const _PlanningUnsaved({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      key: const Key('settings.unsaved'),
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'These settings are in use but not saved: after a restart the '
              'last saved ones return. Retry saves them as shown.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: scheme.onErrorContainer),
            ),
            TextButton(
              key: const Key('settings.retry'),
              // On the error colour, in its own foreground (AA contrast).
              style: TextButton.styleFrom(
                foregroundColor: scheme.onErrorContainer,
              ),
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hybrid's range control (settings.css): the full width of the column, a
/// solid track, no division ticks, 48 px tall to touch. The thumb's radius
/// is the inset, so it stays inside the column's edges.
class HybridSlider extends StatelessWidget {
  const HybridSlider({super.key, required this.slider});

  final Slider slider;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return SizedBox(
      height: HybridTokens.minTarget,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          trackHeight: 6,
          activeTrackColor: palette.textPrimary,
          inactiveTrackColor: palette.border,
          thumbColor: palette.textPrimary,
          tickMarkShape: SliderTickMarkShape.noTickMark,
          thumbShape: const RoundSliderThumbShape(
            enabledThumbRadius: AppSpacing.sm,
          ),
        ),
        child: slider,
      ),
    );
  }
}
