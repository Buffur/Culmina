import 'package:astroplan/presentation/shared/hybrid_app_bar.dart';
import 'package:astroplan/core/theme/hybrid_tokens.dart';
import 'package:flutter/material.dart';

import '../../shared/document_section.dart';

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
import '../../widgets/planner_sections.dart';
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
import '../../widgets/capture_plan/capture_budget_summary.dart';
import '../../widgets/plan_tracking.dart';
import '../../widgets/sky_darkness_widget.dart';
import '../../shared/night_text.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/quantity_text.dart';
import '../../../core/theme/app_spacing.dart';
import '../../shared/app_words.dart';
import '../../shared/context_line.dart';
import '../../shared/plan_state.dart';
import '../../shared/failure_feedback.dart';
import '../../shared/unsaved_plan_prompt.dart';
import '../../shared/plan_night_phrase.dart';
import '../../shared/hybrid_icon.dart';
import '../../shared/hybrid_parts.dart';
import '../../shared/rig_summary_text.dart';
import '../../../core/theme/app_text_theme.dart';
import '../../../domain/models/moon_conditions.dart';
import '../../../domain/models/night_timeline.dart';
import '../../../domain/models/night_weather.dart';
import '../../../domain/models/night_weather_summary.dart';
import '../../../domain/models/session_night.dart';
import '../../../domain/models/camera_class.dart';
import 'plan_context_screen.dart';

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
                      DocumentSection(
                        key: const Key('planner.statusGroup'),
                        children: const [
                          _PlanIdentity(),
                          SizedBox(height: AppSpacing.itemGap),
                          Divider(height: 1),
                          PlanStatus(showFillAction: false),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // plan.js `rowButton` (Hybrid): the plan's context,
                      // target and rig, each opening its scoped chooser.
                      DocumentSection(
                        key: const Key('planner.inputsGroup'),
                        children: [
                          HybridPlanRow(
                            key: const Key('planner.context'),
                            label: 'Site and night',
                            value: SiteLabel.of(siteVm) ?? ContextLine.noSite,
                            caption: planVm.sessionNight == null
                                ? 'No night without a site'
                                : siteVm.displayZoneId == null
                                ? 'Times in the device zone'
                                : 'Site zone: ${siteVm.displayZoneId}',
                            onTap: () => openPlanContext(context),
                          ),
                          HybridPlanRow(
                            key: Key(
                              target == null
                                  ? 'planner.noTarget'
                                  : 'planner.target',
                            ),
                            label: 'Target',
                            value: target == null
                                ? 'Not chosen'
                                : (target.commonName != null &&
                                      target.commonName != target.catalogId)
                                ? '${target.catalogId} · ${target.commonName}'
                                : target.commonName ?? target.catalogId,
                            caption: target == null
                                ? 'Choose a target'
                                : [
                                    target.type,
                                    // ADR-010 §3: existing moving-type targets
                                    // stay usable, with a visible warning.
                                    if (TargetTypes.isMoving(target.type))
                                      TargetTypes.movingWarning,
                                    // TASK 10.3: inside the night's windows,
                                    // not at culmination (possibly daylight).
                                    if (conditionsVm.imagingOpportunity
                                        case final o?)
                                      o.maxAltitudeInWindowsDeg == null
                                          ? words('no window tonight')
                                          : 'max ${QuantityText.degrees(o.maxAltitudeInWindowsDeg!, digits: 1)} in windows',
                                    // F18 A1: the altitude at this moment, said
                                    // so when the plan's night is another one.
                                    if (conditionsVm.currentAltitude
                                        case final a?)
                                      otherNight
                                          ? "now ${QuantityText.degrees(a, digits: 1)} (not the plan's night)"
                                          : 'now ${QuantityText.degrees(a, digits: 1)}',
                                  ].join(' · '),
                            onTap: () => context.push(AppRouter.selectTarget),
                          ),
                          HybridPlanRow(
                            key: Key(
                              equipment == null
                                  ? 'planner.noRig'
                                  : 'planner.rig',
                            ),
                            label: AppWords.rig,
                            value: equipment == null
                                ? 'Not chosen'
                                : equipment.name,
                            caption: equipment == null
                                ? AppWords.chooseRig
                                : RigSummaryText.of(
                                    equipment,
                                    tracking: planVm.effectiveTracking,
                                  ),
                            // D8 A: a rig created there becomes this plan's.
                            onTap: () => context.push(
                              equipment == null
                                  ? AppRouter.selectRigForPlan
                                  : AppRouter.selectRig,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      DocumentSection(
                        key: const Key('planner.captureGroup'),
                        children: [
                          HybridSectionTitle(
                            AppWords.capturePlan,
                            trailing: _blockCount(planVm),
                          ),
                          const SizedBox(height: 6),
                          CapturePlanWidget(
                            includeSummary: false,
                            blockActions:
                                PlanStatus.missingInput(planVm) == null
                                ? FillWindowAction(fit: analysisVm.fitAnalysis)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DocumentSection(
                        key: const Key('planner.estimateGroup'),
                        children: [
                          const CaptureBudgetSummary(),
                          if (equipment != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: CollapsibleSection(
                                key: const Key('planner.rigDetails'),
                                sectionKey: PlannerSections.rigDetails,
                                title: 'Rig details',
                                summary: equipment.name,
                                child: _RigDetails(rig: equipment),
                              ),
                            ),
                        ],
                      ),
                      // AM-01 (F18 A1): the night and its forecast in full
                      // are on their detail screens; here one factual row
                      // each (plan.js night rows). Without a site the
                      // location row is shown (ADR-012).
                      const SizedBox(height: 16),
                      DocumentSection(
                        key: const Key('planner.nightGroup'),
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              'The night ahead',
                              style: AppTextTheme.of(context)
                                  .resolve(
                                    AppTextTheme.of(context).nightHeading,
                                    AppTextGeometry.tightTracking,
                                  )
                                  .copyWith(
                                    color: AppPalette.of(context).textPrimary,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (planVm.sessionNight case final night?) ...[
                            HybridNightRow(
                              key: const Key('planner.night'),
                              icon: HybridIcons.lucideMoon,
                              label: 'Night & Moon',
                              value: _nightValue(
                                context,
                                night,
                                conditionsVm,
                                siteVm.displayZoneId,
                                words,
                              ),
                              extra: _moonExtra(
                                context,
                                night,
                                conditionsVm,
                                siteVm.displayZoneId,
                              ),
                              onTap: () => context.push(AppRouter.nightMoon),
                            ),
                            HybridNightRow(
                              key: const Key('planner.weather'),
                              icon: HybridIcons.lucideCloud,
                              iconColor: Theme.of(context)
                                  .extension<HybridTokens>()
                                  ?.accent,
                              label: 'Weather',
                              value: _weatherValue(conditionsVm),
                              extra: _weatherExtra(conditionsVm),
                              onTap: () => context.push(AppRouter.weather),
                            ),
                          ] else
                            HybridPlanRow(
                              // Only while the default position is in use.
                              label: AppWords.site,
                              value:
                                  siteVm.locationName ??
                                  'Not set (default position)',
                              caption:
                                  '${siteVm.latitude.toStringAsFixed(4)}, '
                                  '${siteVm.longitude.toStringAsFixed(4)}'
                                  '${siteVm.locationNameAttribution == null ? '' : ' · ${siteVm.locationNameAttribution}'}',
                              onTap: () => context.push(AppRouter.selectSite),
                            ),
                          const SkyDarknessWidget(embedded: true),
                        ],
                      ),
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
          // plan.css `.plan-savebar`: a subtle rule above, padding 12 20 8.
          : Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              shape: Border(
                top: BorderSide(color: AppPalette.of(context).border),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
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
    final session = plan.activeSession;
    final state = session == null
        ? null
        : PlanState.forWorkingPlan(
            session,
            hasUnsavedChanges: plan.hasUnsavedChanges,
          );
    // plan.js `mainBar`: the plan's persistence in words above Save plan.
    final reason = missing != null
        ? 'To save: ${words(missing.reason)}'
        : state == PlanState.saved || state == PlanState.tracking
        ? 'Saved on this device.'
        : state == PlanState.savedChanged
        ? 'Changes are not saved yet.'
        : 'This plan is not saved yet.';
    final save = FilledButton(
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
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: AppTextTheme.of(
          context,
        ).resolve(AppTextTheme.of(context).itemTitle, AppTextGeometry.standard),
      ),
      child: const Text(AppWords.savePlan),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: Text(
                  reason,
                  key: Key(
                    missing == null
                        ? 'planner.saveState'
                        : 'planner.saveReason',
                  ),
                  style: AppTextTheme.of(context)
                      .resolve(
                        AppTextTheme.of(context).caption,
                        AppTextGeometry.supporting,
                      )
                      .copyWith(color: AppPalette.of(context).textSecondary),
                ),
              ),
            ),
            // plan.css `.savebar-row` wraps: on a narrow bar the remedy's
            // words wrap instead of pushing past the edge.
            if (missing != null)
              Flexible(
                child: TextButton(
                  key: const Key('planner.saveFix'),
                  onPressed: () =>
                      context.push(missing.route ?? AppRouter.selectSite),
                  child: Text(missing.action ?? 'Set a site'),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        save,
      ],
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
            Text(
              "Couldn't load your site, settings and current plan.",
              textAlign: TextAlign.center,
              style: AppTextTheme.of(context).resolve(
                AppTextTheme.of(context).inherited,
                AppTextGeometry.recoveryBody,
              ),
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
      // plan.css `.plan-menu`: 220 wide, under the app bar.
      constraints: const BoxConstraints(minWidth: 220),
      offset: const Offset(0, AppSpacing.md),
      icon: HybridIcon(
        HybridIcons.planMore,
        size: MediaQuery.textScalerOf(context).scale(24),
        strokeWidth: 1.8,
      ),
      onSelected: (action) => switch (action) {
        _PlanAction.newPlan => _newPlan(context),
        _PlanAction.copy => _copy(context),
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          key: Key('planner.newPlan'),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          value: _PlanAction.newPlan,
          child: Text(AppWords.newPlan),
        ),
        const PopupMenuItem(
          key: Key('planner.copy'),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
    // F18 A1: the target appears once, in its row; the strip keeps the
    // night and the plan's state (plan.js `plan-identity`, Hybrid).
    final evening = plan.eveningDate;
    final session = plan.activeSession;
    return Semantics(
      key: const Key('planner.identity'),
      container: true,
      child: Wrap(
        spacing: 12,
        runSpacing: AppSpacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            evening == null
                ? 'No night without a site'
                : '${AppWords.nightOf} ${NightTimeFormatter.eveningDate(evening)}'
                      ' · Ends ${NightTimeFormatter.eveningDate(evening.addDays(1))}',
            style: AppTextTheme.of(context).caption
                .copyWith(color: AppPalette.of(context).textSecondary),
          ),
          if (session != null)
            PlanStateLabel(
              PlanState.forWorkingPlan(
                session,
                hasUnsavedChanges: plan.hasUnsavedChanges,
              ),
              withIcon: true,
            ),
        ],
      ),
    );
  }
}

/// "1 block · 120 frames" (plan.js capture heading), with the example
/// plan's flag first (RD-04).
String? _blockCount(SessionPlanViewModel plan) {
  final blocks = plan.captureBlocks;
  if (blocks.isEmpty) return null;
  final frames = blocks.fold<int>(0, (sum, b) => sum + b.frameCount);
  return [
    if (plan.isExampleCapturePlan) ExampleText.plan,
    '${blocks.length} block${blocks.length == 1 ? '' : 's'}',
    '$frames frame${frames == 1 ? '' : 's'}',
  ].join(' · ');
}

/// Plan's Night & Moon row value: "7 h 30 min dark · 21:15–04:45", or why
/// there is none (plan.js night rows; clock times without the day tag).
String _nightValue(
  BuildContext context,
  SessionNight night,
  NightConditionsViewModel c,
  String? zoneId,
  String Function(String) words,
) {
  String clock(DateTime utc) =>
      NightTimeFormatter.clockTime(context, utc, zoneId: zoneId);
  return switch (c.nightTimeline?.darkAtLimit) {
    SunCrossing(:final duskUtc, :final dawnUtc) => () {
      final from = duskUtc ?? night.startUtc, to = dawnUtc ?? night.endUtc;
      return '${QuantityText.duration(to.difference(from))} dark · '
          '${clock(from)}–${clock(to)}';
    }(),
    SunAlwaysBelow() =>
      '${QuantityText.duration(night.endUtc.difference(night.startUtc))} dark · all night',
    SunNeverBelow() => words('No dark time tonight'),
    null => 'Calculating…',
  };
}

/// "Moon-free 00:30–04:45 · Waxing gibbous, 62%".
String? _moonExtra(
  BuildContext context,
  SessionNight night,
  NightConditionsViewModel c,
  String? zoneId,
) {
  final moon = c.moonConditions;
  if (moon == null) return null;
  String clock(DateTime utc) =>
      NightTimeFormatter.clockTime(context, utc, zoneId: zoneId);
  final free = c.moonFree;
  final phase = [
    if (moon.phaseName case final p?) MoonText.phaseName(p),
    QuantityText.percent(moon.illuminationAtMidnight * 100),
  ].join(', ');
  final freeText = free == null
      ? null
      : switch (free.kind) {
          MoonFreeKind.noDark => 'No moon-free dark',
          MoonFreeKind.none => 'Moon up through dark time',
          _ =>
            'Moon-free ${free.intervals.map((i) => '${clock(i.$1)}–${clock(i.$2)}').join(', ')}',
        };
  return [?freeText, phase].join(' · ');
}

/// "Cloud 19–42% in the dark", or the forecast's state.
String _weatherValue(NightConditionsViewModel c) => switch (c.nightWeather) {
  NightWeatherIdle() || NightWeatherLoading() => 'Loading forecast',
  NightWeatherOutOfRange() => 'No forecast yet',
  NightWeatherUnavailable() => 'Forecast unavailable',
  NightWeatherAvailable() => switch (c.nightWeatherSummary) {
    final s? when s.span == NightWeatherSpan.noDark => 'No dark-time forecast',
    final s? when s.cloudCover != null =>
      'Cloud ${QuantityText.percentRange(s.cloudCover!.min, s.cloudCover!.max)} in the dark',
    _ => 'Cloud cover unknown',
  },
};

/// "Full dark-time coverage · Stale snapshot · updated 3 h ago".
String? _weatherExtra(NightConditionsViewModel c) => switch (c.nightWeather) {
  NightWeatherOutOfRange() => 'Beyond the 16-day forecast',
  NightWeatherUnavailable(:final failure) => WeatherText.failure(failure),
  final NightWeatherAvailable a => [
    if (a.refreshFailed case final failure?)
      'Refresh failed · cached forecast. ${WeatherText.failure(failure)}'
    else if (a.fromCache)
      'Cached forecast',
    if (c.nightWeatherSummary case final s?
        when s.span != NightWeatherSpan.noDark)
      s.complete ? 'Full dark-time coverage' : 'Partial dark-time coverage',
    switch (a.age) {
      WeatherAge.current => null,
      WeatherAge.aging => 'Aging snapshot',
      WeatherAge.stale => 'Stale snapshot',
    },
    'updated ${WeatherText.ago(a.ageDuration)}',
  ].whereType<String>().join(' · '),
  _ => null,
};

/// Rig details (plan.js `rigDetails`): the rig's recorded specifications,
/// what this plan derives from them, and the plan's own tracking (S7.1).
class _RigDetails extends StatelessWidget {
  const _RigDetails({required this.rig});

  final EquipmentProfile rig;

  @override
  Widget build(BuildContext context) {
    final analysis = context.watch<CaptureAnalysisViewModel>();
    final cap = analysis.rigCapability;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        HybridFacts([
          ('Camera type', rig.cameraClass.label),
          ('Camera', rig.cameraModel ?? 'Not recorded'),
          (
            'Sensor',
            '${_trimNumber(rig.sensorWidthMm)} × ${_trimNumber(rig.sensorHeightMm)} mm',
          ),
          (
            'Resolution',
            '${rig.resolutionWidthPx} × ${rig.resolutionHeightPx} px',
          ),
          ('Pixel pitch', '${_trimNumber(rig.pixelPitchUm)} µm'),
          ('Focal length', '${_trimNumber(rig.focalLengthMm)} mm'),
          ('Focal ratio', _focalRatio(rig)),
          (AppWords.tracking, rig.trackingType.label),
          if (cap != null) ('Field of view', CapabilityText.fov(cap)),
          (
            'Pixel scale',
            analysis.pixelScale != null
                ? '${analysis.pixelScale!.toStringAsFixed(2)} arcsec/px'
                : 'Unknown',
          ),
          if (cap?.frameFillFraction != null)
            ('Target size', CapabilityText.frameFill(cap!)!),
          if (cap?.npf != null) ('NPF (untracked)', CapabilityText.npf(cap!)!),
          if (cap?.recommendedMaxSubS != null)
            ('Max sub (guide)', CapabilityText.recommendedMaxSub(cap!)!),
          (
            'Recorded in blocks',
            switch (rig.cameraClass.lightSensitivity) {
              LightSensitivity.iso => 'ISO on every light block',
              LightSensitivity.gain => 'Gain on every light block',
              LightSensitivity.either =>
                'ISO or gain: set the camera type to record it',
            },
          ),
        ]),
        // S7.1 (RD-08 = T3): the plan's own tracking.
        const SizedBox(height: 8),
        const PlanTrackingRow(),
        if (rig.isExample) ...[
          const SizedBox(height: 8),
          HybridNote(ExampleText.rigNote),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

/// Opens Site and night (plan.js `context` screen): the observing site and
/// the night, applied to the working plan together.
Future<void> openPlanContext(BuildContext context) => Navigator.of(context)
    .push<void>(MaterialPageRoute(builder: (_) => const PlanContextScreen()));
