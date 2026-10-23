import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/hybrid_tokens.dart';
import '../../../core/config/app_identity.dart';
import '../../../core/units/display_units.dart';
import '../../../domain/models/planning_preferences.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../navigation/app_router.dart';
import '../../shared/collapsible_section.dart';
import '../../shared/field_mode_button.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/confirmation_patterns.dart';
import '../../shared/hybrid_icon.dart';
import '../../shared/hybrid_parts.dart';
import '../../widgets/capture_plan/block_editor_parts.dart';
import 'backup_section.dart';
import 'settings_parts.dart';
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

  /// What leaves the device (settings.js privacy, About's privacy words).
  static const privacyText =
      'No account, no ads, no analytics and no tracking. Your sites, rigs, '
      'targets, plans and results stay on the device. The app sends a '
      'position only to fetch the weather (Open-Meteo), to show map tiles '
      '(OpenStreetMap) and — if you switch it on here, or when the site '
      'editor offers it — to look up a place name (Nominatim). Location '
      'permission is asked only when you tap "Use current position".';

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

  // The two planning disclosures stay open for this visit only, as the
  // reference's (`S.advancedOpen`).
  bool _scopeOpen = false;
  bool _advancedOpen = false;

  @override
  Widget build(BuildContext context) {
    final settingsVm = context.watch<SettingsViewModel>();
    if (_planning && _draft == null) {
      _initial = _draft = settingsVm.planningPreferences;
    }
    final p = _planning ? _draft! : settingsVm.planningPreferences;
    void update(PlanningPreferences next) => setState(() => _draft = next);

    if (!overPlan && section == null) {
      return _SettingsIndex(
        preferences: p,
        placeNames: settingsVm.placeNameLookup,
      );
    }
    final planning = _planning;
    final palette = AppPalette.of(context);
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
            padding: settingsPagePadding,
            children: [
              if (planning) ..._planningPage(context, settingsVm, p, update),
              if (!overPlan && section == SettingsSection.appearance)
                const _AppearancePage(),
              if (!overPlan && section == SettingsSection.privacy) ...[
                const SettingsHeading('Place names', top: 0),
                // TASK 16.3 (owner decision): opt-in, off by default.
                HybridSwitchRow(
                  key: const Key('settings.placeNames'),
                  title: 'Look up place names',
                  description:
                      'Optional: the app sends the chosen coordinates to '
                      'OpenStreetMap Nominatim. Off keeps coordinate labels.',
                  value: settingsVm.placeNameLookup,
                  onChanged: (on) => runWithFeedback(
                    context,
                    'save the place-name setting',
                    () => settingsVm.setPlaceNameLookup(on),
                  ),
                ),
                // F21 A6: Off is applied but not stored; say so, with Retry.
                if (settingsVm.placeNameLookupUnsaved)
                  _Unsaved(
                    key: const Key('settings.placeNames.unsaved'),
                    text:
                        'Off for now, but not saved: after a restart place '
                        'names would be on again.',
                    retryKey: const Key('settings.placeNames.retry'),
                    onRetry: () => runWithFeedback(
                      context,
                      'save the place-name setting',
                      () => settingsVm.setPlaceNameLookup(false),
                    ),
                  ),
                const SizedBox(height: AppSpacing.itemGap),
                const CollapsibleSection(
                  key: Key('settings.privacyApp'),
                  sectionKey: 'settings.privacyApp',
                  title: 'What leaves the device in the app',
                  child: SettingsCopy(SettingsScreen.privacyText),
                ),
              ],
              if (!overPlan && section == SettingsSection.backup)
                // TASK 14.4: backup and restore.
                const BackupSection(),
            ],
          ),
        ),
        bottomNavigationBar: planning
            ? SafeArea(
                top: false,
                child: ColoredBox(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Padding(
                    // settings.css `.settings-savebar`: 8 0 4, the state, 8,
                    // then Cancel and Save 12 apart.
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter,
                      AppSpacing.sm,
                      AppSpacing.gutter,
                      AppSpacing.xs,
                    ),
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
                          style: AppTypography.caption.copyWith(
                            color: palette.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          spacing: AppSpacing.itemGap,
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                key: const Key('settings.cancelPlanning'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(
                                    HybridTokens.minTarget,
                                  ),
                                ),
                                onPressed: _saving ? null : _cancel,
                                child: const Text('Cancel'),
                              ),
                            ),
                            Expanded(
                              child: FilledButton(
                                key: const Key('settings.savePlanning'),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(
                                    HybridTokens.minTarget,
                                  ),
                                ),
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
                ),
              )
            : null,
      ),
    );
  }

  /// Planning (settings.js `planningView`): the capture budget first, how
  /// the defaults apply, the imaging window, the gates and optional times,
  /// then guidance.
  List<Widget> _planningPage(
    BuildContext context,
    SettingsViewModel settingsVm,
    PlanningPreferences p,
    void Function(PlanningPreferences) update,
  ) => [
    if (overPlan)
      Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: SettingsCopy(
          SettingsScreen.scopeNotice,
          key: const Key('settings.scope'),
          primary: true,
        ),
      ),
    // F21 A5: an edit that is applied but not stored says so.
    if (settingsVm.planningPreferencesUnsaved)
      _Unsaved(
        key: const Key('settings.unsaved'),
        text:
            'These settings are in use but not saved: after a restart the '
            'last saved ones return. Retry saves them as shown.',
        retryKey: const Key('settings.retry'),
        onRetry: () => runWithFeedback(
          context,
          'save the settings',
          settingsVm.retryPlanningPreferences,
        ),
      ),
    const SettingsCopy(
      'Plan defaults. Saved snapshots stay unchanged.',
      primary: true,
    ),
    const SettingsHeading('Capture budget'),
    SettingsSlider(
      key: const Key('settings.perFrame'),
      top: AppSpacing.sm,
      // S7.2b (ADR-020 §4, I1): the one interval concept, relabelled.
      title: 'Time between frames',
      help: 'Download and delay after each exposure. Measure your rig.',
      value: p.perFrameOverheadSeconds,
      // S9.4: the model's range (0–120 s), not a narrower one.
      range: PlanningPreferences.perFrameRange,
      divisions: 120,
      label: '${p.perFrameOverheadSeconds.round()} s',
      format: (v) => '${v.round()} s',
      onChanged: (v) => update(p.copyWith(perFrameOverheadSeconds: v)),
    ),
    SettingsSlider(
      key: const Key('settings.margin'),
      title: 'Fit margin',
      help: 'Shows Tight when less than this share of usable time remains.',
      value: p.feasibilityMarginPercent,
      range: PlanningPreferences.marginRange,
      divisions: 50,
      label: QuantityText.percent(p.feasibilityMarginPercent),
      format: QuantityText.percent,
      onChanged: (v) => update(p.copyWith(feasibilityMarginPercent: v)),
    ),
    const SizedBox(height: AppSpacing.lg),
    CollapsibleSection(
      key: const Key('settings.scopeHelp'),
      sectionKey: 'settings.scopeHelp',
      title: 'How these defaults apply',
      open: _scopeOpen,
      onToggle: () => setState(() => _scopeOpen = !_scopeOpen),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.itemGap,
        children: [
          SettingsCopy(
            'Save applies these defaults to the current plan’s budget and '
            'fit. An explicit assumption in the plan overrides the matching '
            'default. A saved plan keeps its recorded values until you '
            'explicitly save changes to it.',
          ),
          SettingsCopy(
            'Window limits, gates and the optional times below change the '
            'imaging window, the capture budget and the fit. They are '
            'planning assumptions, not scientific laws.',
          ),
          SettingsCopy(
            'Time between frames is measured from one exposure’s end to the '
            'next exposure’s start. A camera’s start-to-start interval '
            'includes the exposure; subtract it first. Dither settling is '
            'separate.',
          ),
        ],
      ),
    ),
    const SettingsHeading('Imaging window'),
    const SettingsCopy('Changes when the planner counts time as usable.'),
    SettingsSlider(
      key: const Key('settings.minAltitude'),
      title: 'Minimum target altitude',
      help:
          'Below this the target is not counted as usable. Low altitude '
          'means more atmosphere, extinction and poor seeing.',
      value: p.minAltitudeDeg,
      range: PlanningPreferences.minAltitudeRange,
      divisions: 55,
      label: QuantityText.degrees(p.minAltitudeDeg),
      format: QuantityText.degrees,
      onChanged: (v) => update(p.copyWith(minAltitudeDeg: v)),
    ),
    const SizedBox(height: AppSpacing.sm),
    HybridSegmented<DarknessLimit>.settings(
      key: const Key('settings.darknessLimit'),
      legend: 'Darkness limit (Sun altitude)',
      legendStyle: settingsLegendStyle(context),
      keyPrefix: 'settings.darknessLimit',
      options: [
        for (final l in DarknessLimit.values)
          (l, QuantityText.degrees(l.degrees), l.name),
      ],
      value: p.darknessLimit,
      onChanged: (l) => update(p.copyWith(darknessLimit: l)),
    ),
    const SettingsHint(
      '−18° is full astronomical darkness. −15° or −12° give longer windows '
      'with a brighter sky background.',
      top: AppSpacing.xs,
    ),
    const SizedBox(height: AppSpacing.lg),
    // F12 (AM-01; SP11): the optional gates and times, collapsed.
    CollapsibleSection(
      key: const Key('settings.advanced'),
      sectionKey: 'settings.advanced',
      title: 'Gates and optional times',
      summary: SettingsScreen.advancedSummary(p),
      open: _advancedOpen,
      onToggle: () => setState(() => _advancedOpen = !_advancedOpen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SettingsCopy(
            'When on, the gates and optional times change the imaging '
            'window, the capture budget and the fit.',
          ),
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
            onPercent: (v) => update(p.copyWith(moonGateMinIlluminationPct: v)),
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
            onToggle: (on) => update(p.copyWith(cloudGateEnabled: on)),
            onPercent: (v) => update(p.copyWith(cloudGateMaxPct: v)),
          ),
          const SettingsCopy(
            'Optional times are assumptions. Off means not included, not '
            'measured as zero. Setup stays outside the imaging window.',
            top: AppSpacing.itemGap,
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
              p.withOptionalOverheads(ditherEveryNFrames: (on ? 3 : null,)),
            ),
            steppers: [
              if (p.ditherEveryNFrames case final n?)
                SettingsStepper(
                  key: const Key('settings.dither.every'),
                  label: 'Every',
                  value: n.toDouble(),
                  range: (1, 100),
                  step: 1,
                  format: (v) => '${v.round()} lights',
                  onChanged: (v) => update(
                    p.withOptionalOverheads(ditherEveryNFrames: (v.round(),)),
                  ),
                ),
              if (p.ditherEveryNFrames != null)
                SettingsStepper(
                  key: const Key('settings.dither.settle'),
                  label: 'Settle',
                  value: p.ditherSettleSeconds,
                  range: PlanningPreferences.overheadSecondsRange,
                  step: 5,
                  format: (v) => '${v.round()} s',
                  onChanged: (v) => update(p.copyWith(ditherSettleSeconds: v)),
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
              p.withOptionalOverheads(refocusEveryMinutes: (on ? 60.0 : null,)),
            ),
            steppers: [
              if (p.refocusEveryMinutes case final every?)
                SettingsStepper(
                  key: const Key('settings.refocus.every'),
                  label: 'Every',
                  value: every,
                  range: PlanningPreferences.refocusIntervalRange,
                  step: 10,
                  format: (v) => '${v.round()} min',
                  onChanged: (v) => update(
                    p.withOptionalOverheads(refocusEveryMinutes: (v,)),
                  ),
                ),
              if (p.refocusEveryMinutes != null)
                SettingsStepper(
                  key: const Key('settings.refocus.duration'),
                  label: 'Takes',
                  value: p.refocusSeconds,
                  range: PlanningPreferences.overheadSecondsRange,
                  step: 10,
                  format: (v) => '${v.round()} s',
                  onChanged: (v) => update(p.copyWith(refocusSeconds: v)),
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
              p.withOptionalOverheads(filterChangeSeconds: (on ? 30.0 : null,)),
            ),
            steppers: [
              if (p.filterChangeSeconds case final s?)
                SettingsStepper(
                  key: const Key('settings.filterChange.seconds'),
                  label: 'Takes',
                  value: s,
                  range: PlanningPreferences.overheadSecondsRange,
                  step: 5,
                  format: (v) => '${v.round()} s',
                  onChanged: (v) => update(
                    p.withOptionalOverheads(filterChangeSeconds: (v,)),
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
                SettingsStepper(
                  key: const Key('settings.flip.seconds'),
                  label: 'Takes',
                  value: s,
                  range: PlanningPreferences.flipSecondsRange,
                  step: 30,
                  format: (v) => '${v.round()} s',
                  onChanged: (v) => update(
                    p.withOptionalOverheads(meridianFlipSeconds: (v,)),
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
              p.withOptionalOverheads(setupMinutes: (on ? 30.0 : null,)),
            ),
            steppers: [
              if (p.setupMinutes case final m?)
                SettingsStepper(
                  key: const Key('settings.setup.minutes'),
                  label: 'Takes',
                  value: m,
                  range: PlanningPreferences.setupMinutesRange,
                  step: 5,
                  format: (v) => '${v.round()} min',
                  onChanged: (v) =>
                      update(p.withOptionalOverheads(setupMinutes: (v,))),
                ),
            ],
          ),
        ],
      ),
    ),
    const SettingsHeading('Guidance'),
    const SettingsCopy(
      'Changes advice only; never the imaging window or the fit.',
    ),
    SettingsSlider(
      key: const Key('settings.npfK'),
      title: 'NPF star-trail tolerance (k)',
      help:
          'For untracked exposures (Michaud NPF rule): 1 = round stars, up '
          'to 3 = slightly elongated. Higher allows longer sub-exposures.',
      value: p.npfK,
      range: PlanningPreferences.npfKRange,
      divisions: 4,
      label: 'k = ${p.npfK.toStringAsFixed(1)}',
      format: (v) => 'k = ${v.toStringAsFixed(1)}',
      onChanged: (v) => update(p.copyWith(npfK: v)),
    ),
    SettingsSlider(
      key: const Key('settings.dewMargin'),
      title: 'Dew warning margin',
      help:
          'Warn when the air temperature is within this margin of the dew '
          'point.',
      value: p.dewMarginC,
      range: PlanningPreferences.dewMarginRange,
      divisions: 20,
      // F21 A3: a temperature difference (2 °C = 3.6 °F).
      label: QuantityText.temperatureDifference(p.dewMarginC, unitsOf(context)),
      format: (v) => QuantityText.temperatureDifference(v, unitsOf(context)),
      onChanged: (v) => update(p.copyWith(dewMarginC: v)),
    ),
  ];
}

/// The Settings root (settings.js `rootView`): Preferences, then Data and
/// about, each a row with its current values.
class _SettingsIndex extends StatelessWidget {
  const _SettingsIndex({required this.preferences, required this.placeNames});

  final PlanningPreferences preferences;
  final bool placeNames;

  @override
  Widget build(BuildContext context) {
    final display = context.watch<DisplaySettingsViewModel?>();
    final fieldMode = context.watch<ThemeViewModel?>()?.isFieldMode ?? false;
    final p = preferences;
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
    // In the app, text follows Android's font size.
    final textSize = QuantityText.percent(
      MediaQuery.textScalerOf(context).scale(100),
    );
    return Scaffold(
      appBar: hybridAppBar(
        context,
        title: const Text('Settings'),
        actions: const [FieldModeButton()],
      ),
      body: ListView(
        padding: settingsPagePadding,
        children: [
          const SettingsHeading('Preferences', top: 0),
          SettingsRow(
            key: const Key('settings.open.appearance'),
            icon: HybridIcons.moon,
            title: 'Appearance',
            summary: units == null
                ? 'Theme, field mode and display units'
                : '${fieldMode ? 'Red field mode' : display!.appearance.label}'
                      ' · text $textSize · ${units.temperature.symbol}, '
                      '${units.wind.symbol}, ${units.elevation.symbol}',
            onTap: () => open(SettingsSection.appearance),
          ),
          SettingsRow(
            key: const Key('settings.open.planning'),
            icon: HybridIcons.target,
            title: 'Planning',
            summary:
                '${QuantityText.degrees(p.minAltitudeDeg)} altitude · '
                '${QuantityText.degrees(p.darknessLimit.degrees)} Sun · '
                '${QuantityText.percent(p.feasibilityMarginPercent)} margin · '
                '${p.perFrameOverheadSeconds.round()} s between frames',
            onTap: () => open(SettingsSection.planning),
          ),
          SettingsRow(
            key: const Key('settings.open.privacy'),
            icon: HybridIcons.pin,
            title: 'Privacy',
            summary: 'Place-name lookup ${placeNames ? 'on' : 'off'}',
            onTap: () => open(SettingsSection.privacy),
          ),
          const SettingsHeading('Data and about'),
          SettingsRow(
            key: const Key('settings.open.backup'),
            icon: HybridIcons.download,
            title: 'Backup & data',
            summary: 'Back up or restore plans, results and your library',
            onTap: () => open(SettingsSection.backup),
          ),
          SettingsRow(
            key: const Key('settings.open.about'),
            icon: HybridIcons.book,
            title: 'About',
            summary:
                '${AppIdentity.appName} ${AppIdentity.version} · data sources '
                'and licence',
            divider: false,
            onTap: () => context.push(AppRouter.about),
          ),
        ],
      ),
    );
  }
}

/// Appearance (settings.js `appearanceView`): theme and field mode, text
/// size, units, and the Weather view.
class _AppearancePage extends StatelessWidget {
  const _AppearancePage();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DisplaySettingsViewModel?>();
    final fieldMode = context.watch<ThemeViewModel?>()?.isFieldMode ?? false;
    final system = MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? 'Dark'
        : 'Light';
    void change(Future<void> Function() write) =>
        runWithFeedback(context, 'save the display setting', write);
    final units = vm?.units;
    final legend = settingsLegendStyle(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SettingsHeading('Theme', top: 0),
        if (vm != null) ...[
          HybridSegmented<Appearance>.settings(
            key: const Key('settings.appearance'),
            legend: 'Theme',
            showLegend: false,
            keyPrefix: 'settings.appearance',
            options: [for (final a in Appearance.values) (a, a.label, a.name)],
            value: vm.appearance,
            onChanged: (a) => change(() => vm.setAppearance(a)),
          ),
          SettingsHint(
            'System follows this device’s light or dark setting (now '
            '$system).${fieldMode ? ' Applies when red field mode is off.' : ''}',
            top: AppSpacing.xs,
          ),
        ],
        const FieldModeTile(),
        const SettingsHeading('Text size'),
        SettingsCopy(
          'Text follows Android’s font size (now '
          '${QuantityText.percent(MediaQuery.textScalerOf(context).scale(100))}). '
          'Change it in Android’s display settings.',
          key: const Key('settings.textSize'),
        ),
        if (vm != null && units != null) ...[
          const SettingsHeading('Units'),
          const SettingsCopy(
            'Shown units only: stored values and calculations stay in °C, '
            'km/h and m.',
          ),
          const SizedBox(height: AppSpacing.xs),
          HybridSegmented<TemperatureUnit>.settings(
            key: const Key('settings.units.temperature'),
            legend: 'Temperature',
            legendStyle: legend,
            keyPrefix: 'settings.units.temperature',
            options: [
              for (final u in TemperatureUnit.values) (u, u.symbol, u.name),
            ],
            value: units.temperature,
            onChanged: (u) =>
                change(() => vm.setUnits(units.copyWith(temperature: u))),
          ),
          const SizedBox(height: AppSpacing.xs),
          HybridSegmented<WindUnit>.settings(
            key: const Key('settings.units.wind'),
            legend: 'Wind',
            legendStyle: legend,
            keyPrefix: 'settings.units.wind',
            options: [for (final u in WindUnit.values) (u, u.symbol, u.name)],
            value: units.wind,
            onChanged: (u) =>
                change(() => vm.setUnits(units.copyWith(wind: u))),
          ),
          const SizedBox(height: AppSpacing.xs),
          HybridSegmented<ElevationUnit>.settings(
            key: const Key('settings.units.elevation'),
            legend: 'Elevation',
            legendStyle: legend,
            keyPrefix: 'settings.units.elevation',
            options: [
              for (final u in ElevationUnit.values) (u, u.symbol, u.name),
            ],
            value: units.elevation,
            onChanged: (u) =>
                change(() => vm.setUnits(units.copyWith(elevation: u))),
          ),
          // HT-W04: how the Weather page shows the night's hours.
          const SettingsHeading('Weather view', top: AppSpacing.md),
          HybridSegmented<WeatherView>.settings(
            key: const Key('settings.weatherView'),
            legend: 'Weather view',
            showLegend: false,
            keyPrefix: 'settings.weatherView',
            options: [
              for (final v in WeatherView.values)
                (v, '${v.letter} · ${v.label}', v.name),
            ],
            value: vm.weatherView,
            onChanged: (v) => change(() => vm.setWeatherView(v)),
          ),
          const SettingsHint(
            'Choose the Weather detail view. Both use the same forecast. '
            'Tonight keeps its compact weather summary; the night timeline '
            'keeps its gradient.',
            top: AppSpacing.xs,
          ),
          if (vm.unsaved)
            _Unsaved(
              key: const Key('settings.display.unsaved'),
              text:
                  'Shown now, but not saved: after a restart the saved '
                  'choice returns.',
              retryKey: const Key('settings.display.retry'),
              onRetry: () => change(vm.retry),
            ),
        ],
      ],
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HybridSwitchRow(
          title: title,
          description: enabled ? on(label) : off,
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
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      HybridSwitchRow(
        title: title,
        description: summary,
        value: enabled,
        onChanged: onToggle,
      ),
      ...steppers,
      if (steppers.isNotEmpty) const SizedBox(height: AppSpacing.lg),
    ],
  );
}

/// A choice in use but not stored (F21 A5, A6; `.workspace-error`): the
/// error-coloured 13 px words, then Retry.
class _Unsaved extends StatelessWidget {
  const _Unsaved({
    super.key,
    required this.text,
    required this.retryKey,
    required this.onRetry,
  });

  final String text;
  final Key retryKey;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final hybrid =
        Theme.of(context).extension<HybridTokens>() ?? HybridTokens.light;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: AppTypography.caption.copyWith(
              height: 1.6,
              color: hybrid.errorText,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            key: retryKey,
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
