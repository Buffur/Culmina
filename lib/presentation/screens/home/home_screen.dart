import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';
import 'package:astroplan/core/theme/hybrid_tokens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../shared/site_label.dart';
import '../../navigation/app_router.dart';
import '../../viewmodels/startup_viewmodel.dart';
import '../../viewmodels/site_viewmodel.dart';
import '../../viewmodels/session_plan_viewmodel.dart';
import '../../viewmodels/plan_lifecycle_viewmodel.dart';
import '../../viewmodels/night_conditions_viewmodel.dart';
import '../../viewmodels/capture_analysis_viewmodel.dart';
import '../../widgets/planner_summary_card.dart';
import '../../widgets/planner_sections.dart';
import '../../shared/info_row.dart';
import '../../shared/example_text.dart';
import '../../../domain/models/equipment_profile.dart';
import '../../shared/collapsible_section.dart';
import '../../widgets/plan_status.dart';
import '../../shared/capability_text.dart';
import '../../shared/location_feedback.dart';
import '../../shared/night_time_formatter.dart';
import '../../../domain/models/target_types.dart';
import '../../shared/field_mode_button.dart';
import '../../widgets/capture_plan_widget.dart';
import '../../widgets/plan_tracking.dart';
import '../../widgets/sky_darkness_widget.dart';
import '../../shared/night_text.dart';
import '../details/night_moon_screen.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/quantity_text.dart';
import '../../../core/theme/app_spacing.dart';
import '../../shared/app_words.dart';
import '../../shared/context_line.dart';
import '../../shared/plan_state.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/unsaved_plan_prompt.dart';
import '../../shared/plan_night_phrase.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analysisVm = context.watch<CaptureAnalysisViewModel>();
    final conditionsVm = context.watch<NightConditionsViewModel>();
    final planVm = context.watch<SessionPlanViewModel>();
    final siteVm = context.watch<SiteViewModel>();
    final startupVm = context.watch<StartupViewModel>();
    final target = planVm.selectedTarget;
    final equipment = planVm.selectedEquipment;
    final otherNight =
        (planVm.eveningDate ?? planVm.tonightKey) != planVm.tonightKey;
    // F18 A6 (AM-03): the plan's night in the words, never its values.
    String words(String text) => PlanNightPhrase.apply(
      text,
      planVm.eveningDate ?? planVm.tonightKey,
      planVm.tonightKey,
    );

    return Scaffold(
      appBar: hybridAppBar(
        context,
        // S6.2: the plan's target, night and state are in the strip below
        // (it wraps at large text, which an app bar's title cannot).
        title: const Text(AppWords.plan),
        actions: const [FieldModeButton(), _PlanMenu()],
      ),
      body: startupVm.hasBootstrapError
          ? _BootstrapErrorView(
              onRetry: () => context.read<StartupViewModel>().retryBootstrap(),
            )
          : startupVm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (siteVm.isDefaultLocation) const _DefaultLocationBanner(),
                if (planVm.autosaveFailure != null)
                  const _AutosaveFailureBanner(),
                Expanded(
                  // S6.6 (ADR-019 §6; UX-01, UX-02): the answer first. Since
                  // S6.16 (ADR-019 §6 as amended by the owner): the context,
                  // the target, the rig and the capture plan, then the
                  // target's night as supporting analysis, then the
                  // conditions. Without a target or a rig the structure
                  // stays, with a neutral status.
                  child: ListView(
                    key: const Key('planner.scroll'),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      const _PlanIdentity(),
                      const PlanStatus(showFillAction: false),
                      KeyedSubtree(
                        key: const Key('planner.context'),
                        child: ContextLine(
                          framed: false,
                          siteName: SiteLabel.of(siteVm),
                          night: planVm.eveningDate,
                          zoneId: siteVm.displayZoneId,
                          nightStartUtc: planVm.sessionNight?.startUtc,
                          onSite: () => context.push(AppRouter.selectSite),
                          onNight: () async {
                            final picked = await pickNight(
                              context,
                              initial: planVm.eveningDate,
                            );
                            if (picked != null && context.mounted) {
                              await runWithFeedback(
                                context,
                                'change the night',
                                () => planVm.setEveningDate(picked),
                              );
                            }
                          },
                        ),
                      ),
                      if (target != null) ...[
                        PlannerSummaryCard(
                          key: const Key('planner.target'),
                          label: 'Target',
                          caption: target.type,
                          title:
                              (target.commonName != null &&
                                  target.commonName != target.catalogId)
                              ? '${target.catalogId} · ${target.commonName}'
                              : target.commonName ?? target.catalogId,
                          data: {
                            'Type': target.type,
                            // ADR-010 §3: existing moving-type targets
                            // stay usable, with a visible warning.
                            if (TargetTypes.isMoving(target.type))
                              'Note': TargetTypes.movingWarning,
                            // F18 A1: "Altitude now" leads only when the
                            // plan's night is tonight; otherwise it is in the
                            // current-sky detail below.
                            if (conditionsVm.currentAltitude != null &&
                                !otherNight)
                              'Altitude now': QuantityText.degrees(
                                conditionsVm.currentAltitude!,
                                digits: 1,
                              ),
                            // TASK 10.3: inside the night's windows, not at
                            // culmination (possibly in daylight).
                            if (conditionsVm.imagingOpportunity case final o?)
                              'Max altitude in windows':
                                  o.maxAltitudeInWindowsDeg == null
                                  ? words('no window tonight')
                                  : QuantityText.degrees(
                                      o.maxAltitudeInWindowsDeg!,
                                      digits: 1,
                                    ),
                          },
                          below:
                              conditionsVm.currentAltitude != null && otherNight
                              ? CollapsibleSection(
                                  sectionKey: PlannerSections.currentSky,
                                  title: 'Current sky (not the plan\'s night)',
                                  summary:
                                      'Altitude now: ${QuantityText.degrees(conditionsVm.currentAltitude!, digits: 1)}',
                                  child: Text(
                                    'The altitude at this moment, not at any '
                                    'time on the plan\'s night; the windows '
                                    'above are for that night.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                )
                              : null,
                          onTap: () => context.push(AppRouter.selectTarget),
                        ),
                      ] else
                        _ChooseCard(
                          key: const Key('planner.noTarget'),
                          text: 'No target chosen.',
                          action: 'Choose a target',
                          onTap: () => context.push(AppRouter.selectTarget),
                        ),
                      if (equipment != null) ...[
                        PlannerSummaryCard(
                          key: const Key('planner.rig'),
                          label: AppWords.rig,
                          caption:
                              '${equipment.isExample ? '${ExampleText.rig} · ' : ''}'
                              '${_trimNumber(equipment.focalLengthMm)} mm · '
                              '${_focalRatio(equipment)}',
                          title: equipment.name,
                          data: {
                            // RD-04 (S6.8): the example says it is one.
                            if (equipment.isExample)
                              'Note': ExampleText.rigNote,
                            // S6.6: the values this plan uses first,
                            // then any active capability warning
                            // (TASK 8.6, guidance). S6.7: the reference
                            // rows are one tap away, below.
                            if (analysisVm.rigCapability case final cap?)
                              'Field of view': CapabilityText.fov(cap),
                            'Pixel scale': analysisVm.pixelScale != null
                                ? '${analysisVm.pixelScale!.toStringAsFixed(2)} arcsec/px'
                                : 'Unknown',
                            if (analysisVm.rigCapability case final cap?
                                when cap.frameFillFraction != null)
                              'Target size': CapabilityText.frameFill(cap)!,
                            if (analysisVm.rigCapability case final cap?
                                when cap.npf != null)
                              'NPF (untracked)': CapabilityText.npf(cap)!,
                            if (analysisVm.rigCapability case final cap?
                                when cap.recommendedMaxSubS != null)
                              'Max sub (guide)':
                                  CapabilityText.recommendedMaxSub(cap)!,
                          },
                          below: CollapsibleSection(
                            sectionKey: PlannerSections.rigDetails,
                            title: 'Specifications',
                            // A fact, and the review flag stays in view.
                            summary:
                                '${_trimNumber(equipment.focalLengthMm)} mm · '
                                '${_focalRatio(equipment)} · '
                                '${AppWords.tracking}: ${equipment.trackingType.label}',
                            child: Column(
                              children: [
                                for (final (label, value) in [
                                  (
                                    'Focal length',
                                    '${_trimNumber(equipment.focalLengthMm)} mm',
                                  ),
                                  ('Focal ratio', _focalRatio(equipment)),
                                  (
                                    'Sensor',
                                    '${_trimNumber(equipment.sensorWidthMm)} × ${_trimNumber(equipment.sensorHeightMm)} mm (${_trimNumber(equipment.pixelPitchUm)} µm pixels)',
                                  ),
                                  (
                                    AppWords.tracking,
                                    equipment.trackingType.label,
                                  ),
                                ])
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: InfoRow(label: label, value: value),
                                  ),
                              ],
                            ),
                          ),
                          onTap: () => context.push(AppRouter.selectRig),
                        ),
                        // S7.1 (RD-08 = T3): the plan's own tracking.
                        const PlanTrackingRow(),
                      ] else
                        _ChooseCard(
                          key: const Key('planner.noRig'),
                          text: 'No rig chosen.',
                          action: AppWords.chooseRig,
                          // D8 A: a rig created there becomes this plan's.
                          onTap: () => context.push(AppRouter.selectRigForPlan),
                        ),
                      _SectionHeader(AppWords.capturePlan),
                      CapturePlanWidget(
                        blockActions: PlanStatus.missingInput(planVm) == null
                            ? FillWindowAction(fit: analysisVm.fitAnalysis)
                            : null,
                      ),
                      // AM-01 (F18 A1): "Tonight for this target", its chart,
                      // window list and placeholder are out of the plan for
                      // this release; the status keeps the availability and
                      // the fit's reason, and Night & Moon and Weather stay
                      // one tap away below.
                      _SectionHeader('The night ahead'),
                      // S6.5 (UX-06, UX-10): the night and its
                      // forecast in full are on their detail screens;
                      // here one factual row each. Without a site the
                      // location card is shown (ADR-012).
                      if (planVm.sessionNight case final night?) ...[
                        _DetailRow(
                          key: const Key('planner.night'),
                          title: 'Night & Moon',
                          onTap: () => context.push(AppRouter.nightMoon),
                          child: NightSummary(
                            night: night,
                            dark: conditionsVm.nightTimeline?.darkAtLimit,
                            moon: conditionsVm.moonConditions,
                            zoneId: siteVm.displayZoneId,
                            words: words,
                          ),
                        ),
                        _DetailRow(
                          key: const Key('planner.weather'),
                          title: 'Weather',
                          onTap: () => context.push(AppRouter.weather),
                          child: Text(
                            WeatherText.summary(
                              conditionsVm.nightWeather,
                              conditionsVm.nightWeatherSummary,
                            ),
                          ),
                        ),
                        // S6.7: the zone rule, once for the section's
                        // times (trap 2).
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            ContextLine.zoneRule(
                              night.startUtc,
                              zoneId: siteVm.displayZoneId,
                            ),
                            key: const Key('planner.conditionsZone'),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppPalette.of(context).textTertiary,
                                ),
                          ),
                        ),
                      ] else
                        PlannerSummaryCard(
                          // Only while the default position is in use.
                          title:
                              '${AppWords.site}: '
                              '${siteVm.locationName ?? 'not set (default position)'}',
                          data: {
                            'Latitude': siteVm.latitude.toStringAsFixed(4),
                            'Longitude': siteVm.longitude.toStringAsFixed(4),
                            if (siteVm.locationNameAttribution != null)
                              'Place name': siteVm.locationNameAttribution!,
                          },
                          onTap: () => context.push(AppRouter.selectSite),
                        ),
                      const SkyDarknessWidget(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
      // F18 A5: once the planner has loaded, Save plan is always there. Its
      // prerequisites (the existing rule: a site's night, a target, a rig)
      // are said beside it with the direct action; it never disappears.
      bottomNavigationBar: startupVm.isLoading || startupVm.hasBootstrapError
          ? null
          // TASK 15.3: not a BottomAppBar — its fixed 80 px height squeezed
          // the buttons below the 48 px tap target (and clips large text).
          : Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12.0,
                  ),
                  child: _SaveBar(words: words),
                ),
              ),
            ),
    );
  }
}

/// Save plan, always shown after loading (F18 A5; S6.2: the one primary
/// action). When a prerequisite is missing it is disabled, with the reason
/// in adjacent text (not a tooltip) and the direct corrective action.
class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.words});

  final String Function(String) words;

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<SessionPlanViewModel>();
    final analysis = context.read<CaptureAnalysisViewModel>();
    final missing = PlanStatus.missingInput(plan);
    final blocked = missing != null;
    final save = FilledButton.icon(
      key: const Key('planner.save'),
      onPressed: blocked
          ? null
          : () async {
              // TASK 11.3 (ADR-014): saves the plan as a planned session
              // with a fresh plan snapshot.
              final saved = await runWithFeedback(
                context,
                'save the plan',
                analysis.saveSession,
              );
              if (saved && context.mounted) showDone(context, 'Plan saved');
            },
      icon: const Icon(Icons.save_outlined),
      label: const Text(AppWords.savePlan),
    );
    if (missing == null) return save;
    final route = missing.route ?? AppRouter.selectSite;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            'To save: ${words(missing.reason)}',
            key: const Key('planner.saveReason'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        // Wraps at large text rather than overflowing (trap 17).
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            save,
            OutlinedButton(
              key: const Key('planner.saveFix'),
              onPressed: () => context.push(route),
              child: Text(missing.action ?? 'Set a site'),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  /// S6.16: the section-heading role of the type scale (DESIGN_SYSTEM §3),
  /// a semantic header, so the sections no longer outrank the answer.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 24.0,
        bottom: 12.0,
        left: 0.0,
        right: 0.0,
      ),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: AppPalette.of(context).textPrimary),
        ),
      ),
    );
  }
}

/// Shown instead of the whole screen when the initial load
/// (`StartupViewModel.hasBootstrapError`) failed.
class _BootstrapErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _BootstrapErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            const Text(
              "Couldn't load your site, settings and current plan.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A missing target or rig in its section (S6.6): says so and offers the
/// picker; the planner's structure stays around it.
class _ChooseCard extends StatelessWidget {
  const _ChooseCard({
    super.key,
    required this.text,
    required this.action,
    required this.onTap,
  });

  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HybridTokens.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(text),
            OutlinedButton(onPressed: onTap, child: Text(action)),
          ],
        ),
      ),
    );
  }
}

/// A number without trailing zeros (e.g. 400.0 → "400", 3.76 → "3.76").
String _trimNumber(double value) =>
    value == value.roundToDouble() ? value.toInt().toString() : '$value';

/// The rig's focal ratio, with its review flag (TASK 8.4, trap 3).
String _focalRatio(EquipmentProfile rig) => rig.needsApertureReview
    ? 'f/${_trimNumber(rig.focalRatio)} — please review'
    : 'f/${rig.focalRatio.toStringAsFixed(1)}';

/// The first-run prompt (TASK 7.3), shown while the ViewModel has no site
/// or position and is using the hard-coded default. Nothing asks for the
/// location permission until the user chooses "Use current position".
class _DefaultLocationBanner extends StatelessWidget {
  const _DefaultLocationBanner();

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: const Icon(Icons.location_off_outlined),
      content: const Text(
        'Set up your observing site. Until then a default location is used '
        'and night times are not shown.',
      ),
      actions: [
        TextButton(
          onPressed: () => useCurrentPositionWithFeedback(
            context,
            context.read<SiteViewModel>(),
          ),
          child: const Text('Use current position'),
        ),
        TextButton(
          onPressed: () => context.push(AppRouter.selectSite),
          child: const Text('Set site'),
        ),
      ],
    );
  }
}

/// A factual summary row that opens a detail screen (S6.5; ADR-019 §6): a
/// title, the summary below it (wrapping at large text), and a chevron.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    super.key,
    required this.title,
    required this.child,
    required this.onTap,
  });

  final String title;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HybridTokens.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    child,
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// A plan edit could not be saved (TASK 15.1): the change is still on
/// screen, and the next edit tries again.
class _AutosaveFailureBanner extends StatelessWidget {
  const _AutosaveFailureBanner();

  @override
  Widget build(BuildContext context) {
    return const MaterialBanner(
      key: Key('planner.autosaveFailure'),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(Icons.sync_problem),
      content: Text(
        "Your latest changes couldn't be saved on this device. They stay "
        'on screen and are saved again with your next change.',
      ),
      actions: [SizedBox.shrink()],
    );
  }
}

/// The plan's actions (S6.2; ADR-019 §6): New plan and Copy to another
/// night; Track live left with the tracker (S8.4). Each says what happened.
class _PlanMenu extends StatelessWidget {
  const _PlanMenu();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_PlanAction>(
      key: const Key('planner.menu'),
      tooltip: 'Plan actions',
      icon: const Icon(Icons.more_vert),
      onSelected: (action) => switch (action) {
        _PlanAction.newPlan => _newPlan(context),
        _PlanAction.copy => _copy(context),
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          key: Key('planner.newPlan'),
          value: _PlanAction.newPlan,
          child: Text(AppWords.newPlan),
        ),
        const PopupMenuItem(
          key: Key('planner.copy'),
          value: _PlanAction.copy,
          child: Text(AppWords.copyToAnotherNight),
        ),
      ],
    );
  }

  static Future<void> _newPlan(BuildContext context) async {
    // S6.3 (U1): Save · Discard · Cancel before an unsaved plan is left.
    final leaving = await askBeforeLeavingPlan(context);
    if (leaving == null || !context.mounted) return;
    final started = await runWithFeedback(
      context,
      'start a new plan',
      () => context.read<PlanLifecycleViewModel>().newSession(
        discard: leaving == LeavingPlan.discard,
      ),
    );
    if (started && context.mounted) showDone(context, 'New plan started');
  }

  /// TASK 11.4: a copy of the current plan as a new draft for another
  /// night; the current session is not changed.
  static Future<void> _copy(BuildContext context) async {
    final lifecycle = context.read<PlanLifecycleViewModel>();
    final night = context.read<SessionPlanViewModel>().eveningDate;
    final leaving = await askBeforeLeavingPlan(context);
    if (leaving == null || !context.mounted) return;
    final picked = await pickNight(context, initial: night?.addDays(1));
    if (picked == null || !context.mounted) return;
    final copied = await runWithFeedback(
      context,
      'copy the plan',
      () => lifecycle.duplicateForNight(
        picked,
        discard: leaving == LeavingPlan.discard,
      ),
    );
    if (copied && context.mounted) {
      showDone(context, 'Copied to ${NightTimeFormatter.eveningDate(picked)}');
    }
  }
}

enum _PlanAction { newPlan, copy }

/// Which plan the planner shows (S6.2; UX-04, ADR-019 §6): the target, the
/// night and the plan's state, under the app bar. It wraps at large text.
class _PlanIdentity extends StatelessWidget {
  const _PlanIdentity();

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<SessionPlanViewModel>();
    // F18 A1: the target appears once, in its card; the strip keeps the
    // night and the plan's state.
    final evening = plan.eveningDate;
    final session = plan.activeSession;
    final text = Theme.of(context).textTheme;
    return Semantics(
      key: const Key('planner.identity'),
      container: true,
      child: Material(
        color: HybridTokens.transparent,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  evening == null
                      ? 'No night without a site'
                      : '${AppWords.nightOf} '
                            '${NightTimeFormatter.eveningDate(evening)}',
                  style: text.bodySmall,
                ),
                if (session != null) PlanStateLabel(PlanState.of(session)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
